# Resource-Aware Parallel Scheduling

Experiment servers often have finite resources and may be **shared with other users**. Blindly launching all jobs at once can cause OOM kills, CPU saturation, or the machine becoming unresponsive — even if capacity looked sufficient at the start of the session. All scheduling decisions MUST use **live resource checks**, not static capacity estimates.

> **Shared-server rule**: Never assume the server is idle. Always measure free resources immediately before launching a job. Other users' processes may appear or disappear at any time.

## F.1: Scheduling Thresholds

**GPU pre-check is soft and conditional.** For the first job on an idle GPU, launch immediately with no memory check. For co-locating a second or subsequent job on an already-occupied GPU, check memory and utilization first.

| Resource | First job on idle GPU | Co-locating on occupied GPU | Local server (`Local?: yes`) |
|---|---|---|---|
| GPU memory | No pre-check — launch immediately | `memory.free > Est. VRAM × 1.1` | Same rules apply |
| GPU utilization | No pre-check | `utilization.gpu < 70%` | Same rules apply |
| RAM | Usage < 80% of total | Usage < 80% of total | Free RAM > `max(4 GiB, 20% of total)` |
| CPU | 1-min load avg < 85% | 1-min load avg < 85% | 1-min load avg < 50% |
| Disk | Usage < 90% | Usage < 90% | Usage < 90% |
| Process priority | normal | normal | `nice -n 19` + `taskset -c 0-<floor(nproc/2)-1>` + `ulimit -v <allowed_kb>` |

**VRAM estimation rules** (used for `Est. VRAM` when a job is first queued):
1. **Known job** — same method + dataset ran before: use `Actual VRAM` from last run × 1.2
2. **Unknown job, first run**: conservative default = `min(40% of GPU total VRAM, 20480 MiB)`
3. **CPU-only job** (evaluation, data download, analysis scripts): `Est. VRAM = 0`; assign `CUDA_VISIBLE_DEVICES=""`; does not occupy a GPU slot

After each job's first checkpoint, query actual VRAM used and record in the Active Jobs `Actual VRAM` column. This feeds future estimates for the same job type.

**Local server launch command template** (computed at launch time):
```bash
ALLOWED_CORES=$(($(nproc) / 2 - 1))
TOTAL_MB=$(free -m | awk '/Mem:/{print $2}')
FREE_MB=$(free -m | awk '/Mem:/{print $4}')
RESERVED_MB=$(( TOTAL_MB * 20 / 100 ))
[ "$RESERVED_MB" -lt 4096 ] && RESERVED_MB=4096
ALLOWED_MB=$(( FREE_MB - RESERVED_MB ))
[ "$ALLOWED_MB" -lt 0 ] && ALLOWED_MB=0
ssh -p <Port> <Host> "tmux new-session -d -s paperclaw-<id> \
  'cd <workdir> && <Activation> && \
   nice -n 19 taskset -c 0-${ALLOWED_CORES} \
   bash -c \"ulimit -v $((ALLOWED_MB * 1024)); python train.py --config <cfg> 2>&1 | tee train.log\"; \
   tmux wait-for -S paperclaw-<id>-done'"
```

**Scheduling capacity** stored per-server in state.md (under each server's section) after Phase 0 probe:
```markdown
## Scheduling Capacity - Server <name>
- GPUs: <N> × <name> (<M> MiB total each)
- RAM Headroom: reserve 20% of total RAM for OS + SSH + other users

### Thresholds (checked LIVE before each launch — no GPU memory check)
- RAM usage > 80% of total
- CPU usage > 85% sustained (1-min avg)
- Disk usage > 90%
```

## F.2: Live Resource Check Commands

Run these **immediately before each saturation loop pass**:

```bash
# Full live snapshot — RAM, CPU, disk, and per-GPU stats
ssh <server> "echo '=== RAM ==='; free -m | grep Mem; \
  echo '=== CPU ==='; top -bn1 | grep 'Cpu(s)' | awk '{print \"CPU used: \" 100-\$8 \"%\"}'; \
  echo '=== DISK ==='; df -h <workdir> | tail -1; \
  echo '=== GPU ==='; nvidia-smi --query-gpu=index,memory.free,memory.total,utilization.gpu \
    --format=csv,noheader 2>/dev/null || echo 'No GPU'; \
  echo '=== OTHER USERS ==='; who | wc -l; \
  echo '=== OUR JOBS ==='; tmux list-sessions 2>/dev/null | grep '^paperclaw-' || echo 'None'"
```

Parse the `=== GPU ===` lines and update the **GPU Slots** table in state.md (`VRAM Free`, `Util%`, `Last Checked`) before making any co-location decision.

If **any** RAM/CPU/disk threshold is exceeded on all servers, do not launch — wait for a running job to finish, then re-check (poll every 60 seconds).

## F.3: Saturation Loop

**Trigger**: run at session start and after every job completes. Goal: fill ALL available GPU capacity before stopping.

```
LOOP:
  0. Re-read ./experiment/server.md and compare to active server list:
     - Any server whose Connection block was REMOVED: immediately stop scheduling jobs to it;
       remove it from GPU Slots and Servers table in state.md; log "server <name> removed by user"
     - Any server whose Connection block was ADDED (Status: untested or absent): run Phase 0
       Steps 0.2–0.5 for it before continuing the loop

  1. Run live resource check (F.2) on ALL connected servers simultaneously
     → Update GPU Slots table in state.md (VRAM Free, Util%, Last Checked)

  2. For each server that passes RAM/CPU/disk thresholds (F.1):
       a. Collect all queued jobs for this server (by priority order)
       b. For each GPU on this server (index 0, 1, 2, ...):
            - If GPU has no running jobs:
                → Assign next queued job; no memory check needed; mark GPU slot busy
            - If GPU already has running jobs (co-location candidate):
                → Check: memory.free > job's Est. VRAM × 1.1  AND  utilization.gpu < 70%
                → If both pass: assign job to this GPU; mark slot busy
                → If either fails: skip this GPU; try next GPU or next server
       c. After all GPU assignments for this server are decided:
            - Push codebase to this server ONCE (not per job)
            - Launch all assigned jobs in parallel, each with CUDA_VISIBLE_DEVICES=<gpu_index>
            - Update GPU Slots, Job Queue, Active Jobs in state.md
            - Log all launches in log.md with resource snapshot

  3. Continue until queue is empty OR no GPU on any server can accept another job

  4. If no capacity anywhere: poll every 60s; re-run loop when any job finishes
```

**Key rules:**
- Never stop after filling one slot — fill ALL available capacity in one pass
- One push per server per loop pass, not one push per job
- CPU-only jobs (`Est. VRAM = 0`): assign `CUDA_VISIBLE_DEVICES=""`, skip GPU slot tracking entirely
- After each job completes: query `nvidia-smi` for that GPU, update GPU Slots, record `Actual VRAM` in Active Jobs

**Server selection**: prefer the server with the most free GPU slots and lowest RAM/CPU load. Honor TIP hints when choosing between equivalent options. For local servers: verify conservative thresholds (F.1) before assigning any job.

## F.4: Monitoring Active Jobs (Multi-Server)

When multiple jobs are running across servers:

```bash
# Check all paperclaw sessions on each connected server
ssh <server-A> "tmux list-sessions 2>/dev/null | grep '^paperclaw-' || echo 'None'"
ssh <server-B> "tmux list-sessions 2>/dev/null | grep '^paperclaw-' || echo 'None'"

# Check a specific job's latest output
ssh <server> "tmux capture-pane -t paperclaw-<id> -p | tail -20"

# Quick health check per server (catches other users' impact on resources)
ssh <server> "free -m | grep Mem; nvidia-smi --query-gpu=index,memory.free,memory.total,utilization.gpu --format=csv,noheader 2>/dev/null; uptime"
```

When a job finishes:
1. Remove it from the Active Jobs table in state.md.
2. Run live resource checks on all servers (F.2).
3. Launch next queued experiment on the best available server.

## F.5: What Can Run in Parallel

| Scenario | Parallel? | Notes |
|----------|-----------|-------|
| Different baselines on different servers | Yes | Fill all servers simultaneously |
| Different baselines on different GPUs (same server) | Yes | Each job just launches; no memory pre-check |
| Different seeds on different servers or GPUs | Yes | Best use of multi-server setup |
| Ablation variants across servers or GPUs | Yes | Fill all available capacity |
| CPU evaluation while GPU trains (same server) | Yes | Check live RAM only |
| Dataset download while training (same server) | Yes | I/O-bound; check disk space |
| venv setup on Server B while jobs run on Server A | Yes | CPU-light pipeline prep |
| Code push to Server B while Server A trains | Yes | Network-bound, doesn't affect training |
| Strategist running while baselines train remotely | Yes | Strategist uses local CPU/RAM only |
| Phase 3 scaffold while Phase 2 baselines run | Yes | Strategist writes locally; no conflict |
| Our method while baseline still running | Yes | Assign to idle server/GPU |

## F.6: Job Queue Management

The Job Queue in state.md is the master list of all pending and running experiments. It drives the saturation loop (F.3).

**Priority ordering** (higher priority = assigned first):
1. Baselines (Phase 2) — required before our method can be evaluated
2. Our method initial training (Phase 3.2)
3. Our method iterations (Phase 3.3)
4. Ablation studies (Phase 3.5)
5. Multi-seed runs (Phase 3.6)
6. Claim-proof experiments (Phase 3.7)
7. Analysis experiments (Phase 3.8)

**Queue initialization**: at the start of each phase, add all jobs for that phase to the queue with status `queued`. As jobs launch, update to `running`. On completion, update to `done` and remove from queue.

**Pipeline prep jobs** (not in the queue, but run opportunistically alongside queued jobs):
- Download datasets on idle servers while other jobs run
- Set up `.venv` on servers not yet initialized
- Push codebase to servers scheduled for upcoming jobs

## F.7: Adaptive Capacity Adjustment

If a job triggers an OOM kill or the machine becomes unresponsive (can happen more often on shared servers):
1. After recovery, reduce the RAM threshold by 5% for that server in the `## Servers` section of state.md (e.g., 80% → 75%) and log the incident.
2. Log the incident in log.md with the resource state at the time (include `who` output to note if other users were active).
3. For subsequent jobs on that server: reduce batch size or enable gradient checkpointing.
4. If a single job OOMs even alone → handle per Appendix D.
5. If a server repeatedly causes OOM incidents, add a warning to that server's `### Hardware - <name>` section in state.md so future sessions are aware.
