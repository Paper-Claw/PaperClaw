# File Templates (Experiment Pipeline)

## state.md Format

```markdown
---
updated: <timestamp>
---

# Experiment State

- Current Phase: <0-4>
- Current Step: <e.g., 2.3>
- Status: running | blocked | waiting-for-user | stopped | complete
- Blocker: <description or "none">
- Last Action: <brief description>

## Servers

| Name | Host | Status | GPUs | Free RAM (at last check) | Last Checked | Local? | Last Pull |
|------|------|--------|------|--------------------------|--------------|--------|-----------|
| main | alice@gpu1.example.com | connected | 4× A100 80G | 120G / 512G | <timestamp> | no | <timestamp> |
| gpu2 | bob@192.168.1.42 | disconnected | — | — | <timestamp> | no | never |
| local | alice@localhost | connected | 1× RTX 3090 | 18G / 32G | <timestamp> | **yes** | <timestamp> |

## GPU Slots

| Server | GPU | Model | VRAM Total | VRAM Free | Util% | Jobs | Last Checked |
|--------|-----|-------|------------|-----------|-------|------|--------------|
| main   | 0   | A100  | 81920 MiB  | 70000 MiB | 12%   | paperclaw-bert | <timestamp> |
| main   | 1   | A100  | 81920 MiB  | 81920 MiB | 0%    | —    | <timestamp> |
| local  | 0   | RTX3090 | 24576 MiB | 8000 MiB | 78%  | paperclaw-gpt2, paperclaw-roberta | <timestamp> |

## Job Queue

| Priority | Experiment | Est. VRAM | Est. Time | Server | GPU | Status |
|----------|-----------|-----------|-----------|--------|-----|--------|
| 1 | Baseline-A / Dataset-X | 12000 MiB | 2h | — | — | queued |
| 2 | Baseline-B / Dataset-X | 8000 MiB | 1.5h | main | 1 | running |

## Progress Tracking

- Total Experiments: <N> (baselines: <N>, ablations: <N>, claim-proofs: <N>, analysis: <N>)
- Completed: <N>
- Remaining: <N>
- Estimated Time Per Job: <minutes>
- Estimated Remaining Time: <H hours M minutes>

## Active Jobs

| Session ID | Server | GPU | Experiment | Est. VRAM | Actual VRAM | Started | Status |
|------------|--------|-----|-----------|-----------|-------------|---------|--------|
| paperclaw-baseline-bert | main | 0 | Baseline BERT on Dataset A | 12000 MiB | 11200 MiB | <timestamp> | running |
| paperclaw-baseline-gpt2 | local | 0 | Baseline GPT-2 on Dataset B | 8000 MiB | — | <timestamp> | running |

## Server Details

### Hardware - main
<!-- Updated by skill on each probe — do not edit -->
| GPU | Name | Total (MiB) | Free at probe (MiB) |
|-----|------|-------------|----------------------|
| 0   | A100 80GB SXM4 | 81920 | 71200 |

- CPU: 128 cores / 256 threads (AMD EPYC 7763)
- Total RAM: 512 GiB  |  In use at probe: 82 GiB
- Disk (/home/alice/paperclaw-experiments): 20 TiB total, 14 TiB free
- Active users at probe: 3

### Software Environment - main
<!-- Updated by skill on each probe — do not edit -->
- OS: Ubuntu 22.04.3 LTS
- Python: 3.10.12
- CUDA: 12.1 / Driver: 530.30.02

### Scheduling Capacity - main
<!-- Updated by skill on each probe — do not edit -->
- GPUs: 8 × A100 80G (81920 MiB each)
- RAM Headroom: reserve 20% (≈102 GiB) for OS + other users
- Thresholds: RAM > 80%, CPU > 85% (1-min avg), Disk > 90%

---

### Hardware - local
<!-- Updated by skill on each probe — do not edit -->
- CPU: 12 cores / 12 threads (Apple M2 Pro)
- Total RAM: 32 GiB  |  In use at probe: 8 GiB
- Disk (/home/alice/PaperClaw/experiment/codebase): 1 TiB total, 600 GiB free

### Software Environment - local
<!-- Updated by skill on each probe — do not edit -->
- OS: macOS 14.3
- Python: 3.11.6
- CUDA: N/A

### Scheduling Capacity - local
<!-- Updated by skill on each probe — do not edit -->
- GPUs: none
- RAM Headroom: reserve max(4 GiB, 20% total) for Claude Code + OS
- Thresholds: RAM > 50% (conservative — local), CPU > 50% (1-min avg, conservative — local), Disk > 90%

## Local Machine
<!-- Updated by skill at Phase 0 — do not edit -->
- CPU: Apple M2 Pro, 12 cores
- RAM: 32 GiB
- OS: macOS 14.3
```

**Update state.md** at: phase start, step start/end, blockers, user input requests, job start/finish, concurrent job launch/completion.

**Every time state.md is written, immediately:**
1. Write `./experiment/status.json` with the same data in machine-readable form.
2. Sync the Todo list (see below).

Both actions (status.json write + TodoWrite call) are performed by the **skill in the main session** — never by the executor subagent.

---

## status.json Format

```json
{
  "schema_version": "1.0",
  "updated": "<ISO-timestamp>",
  "phase": 2,
  "step": "2.3",
  "status": "running",
  "blocker": null,
  "last_action": "Launched Baseline BERT on main:GPU0",

  "servers": [
    {
      "name": "main",
      "host": "alice@gpu1.example.com",
      "port": 22,
      "status": "connected",
      "local": false,
      "gpus": "4× A100 80G",
      "free_ram": "120G / 512G",
      "last_checked": "<ISO-timestamp>",
      "last_pull": "<ISO-timestamp>"
    }
  ],

  "gpu_slots": [
    {
      "server": "main", "gpu": 0, "model": "A100",
      "vram_total_mib": 81920, "vram_free_mib": 70000,
      "util_pct": 12, "jobs": ["paperclaw-bert"],
      "last_checked": "<ISO-timestamp>"
    }
  ],

  "job_queue": [
    {
      "priority": 1, "experiment": "Baseline-A / Dataset-X",
      "est_vram_mib": 12000, "est_time": "2h",
      "server": null, "gpu": null, "status": "queued"
    }
  ],

  "progress": {
    "total": 20, "completed": 5, "remaining": 15,
    "baselines": {"total": 8, "done": 3},
    "ablations": {"total": 6, "done": 1},
    "claim_proofs": {"total": 4, "done": 1},
    "analysis": {"total": 2, "done": 0},
    "avg_time_min": 45,
    "eta_min": 675
  },

  "active_jobs": [
    {
      "session_id": "paperclaw-baseline-bert",
      "server": "main", "gpu": 0,
      "experiment": "Baseline BERT on Dataset A",
      "est_vram_mib": 12000, "actual_vram_mib": 11200,
      "started": "<ISO-timestamp>",
      "status": "running"
    }
  ]
}
```

---

## Todo Sync

The **skill in the main session** calls TodoWrite every time state.md is updated. The executor never touches todos. Todos are rebuilt from scratch on each sync (read current list, replace all `paperclaw-*` entries with the new set).

### Todo Structure (max ~10 items)

**1. Current Phase** (always 1 item, `in_progress`)

```
Phase <N>: <Phase Name> — <completed>/<total> experiments done, Step <X.Y>
```

Example: `Phase 2: Baseline Reproduction — 5/8 experiments done, Step 2.3`

**2. Doing Jobs** — one item per active job (`in_progress`)

```
[running] <session_id> on <server>:GPU<N> (since <HH:MM>Z)
```

Example: `[running] paperclaw-baseline-bert on main:GPU0 (since 09:00Z)`

**3. Next Jobs** — up to 3 queued items from job queue (`pending`)

```
[next] <experiment> (~<est_vram> MiB, ~<est_time>)
```

Example: `[next] Baseline-C / Dataset-X (~12000 MiB, ~2h)`

**4. Blocker** — only when `Status: blocked` (`in_progress`)

```
BLOCKED: <description> — reply: <option A> / <option B> / <option C>
```

The reply options must be specific to the blocker type:

| Blocker type | Reply options |
|---|---|
| Baseline cannot reproduce after 5 iters | `"skip"` / `"retry with hint: <your suggestion>"` / `"accept gap"` |
| Our method cannot beat baseline after 10 iters | `"keep trying"` / `"diagnose: <your hypothesis>"` / `"accept result"` |
| All servers unreachable | `"wait"` / `"local-only mode"` / `"abort"` |
| Dataset requires login | `"credentials: <user> <pass>"` / `"skip dataset"` |
| Non-empty working directory | `"proceed (keep files)"` / `"use different dir: <path>"` |
| Sudo required | `"password: <sudo password>"` / `"skip command"` |

Example blocker todo:
```
BLOCKED: Baseline BERT -3.2% after 5 iters — reply: "skip" / "retry with hint: <your suggestion>" / "accept gap"
```

### When the session expired and you restart

The skill reads `status.json` on startup and immediately syncs todos before doing anything else. If `Status: blocked`, it re-asks the question in chat **and** shows the blocker todo with reply options so you know exactly what to type.

---

## Progress Tracking & ETA

When a job finishes, update `Estimated Time Per Job` with a running average:

```
avg = (previous_avg * completed_count + this_job_time) / (completed_count + 1)
remaining_time = remaining_experiments * avg
```

When the user asks progress, report:

```
Experiment Progress
━━━━━━━━━━━━━━━━━━━━━
Phase: <name>  |  Step: <step>

Progress: <completed>/<total> experiments
  ├── Baselines:    <X>/<N>
  ├── Ablations:    <X>/<N>
  ├── Claim proofs: <X>/<N>
  └── Analysis:     <X>/<N>

Current job: <description> (running <elapsed>)
Avg time/job: ~<M>min  |  Est. remaining: ~<H>h <M>m
```

---

## Iteration Log Entry Template

Used in both `comparison.md` and `ours.md`.

Title format: `## <ISO-timestamp> | iter=<N> | status=<status> | <Title>`

Valid `status` values: `success` `partial` `failed` `improved` `regressed`

```markdown
## 2026-03-20T09:00:00Z | iter=1 | status=failed | Baseline BERT

### Configuration
- Command: `<full command>`
- Key params: <hyperparameters or changes made>

### Results
| Dataset | Metric | Target/Previous | Actual | Δ |
|---------|--------|-----------------|--------|---|

### Issues & Fix
- Issue: <description>
- Fix: <what was changed and why>

### Git Commit
- `<hash>`: `<message>`
```

## log.md Event Format

Title format: `### <ISO-timestamp> | phase=<N> | type=<type> | <Event Title>`

Valid `type` values: `milestone` `decision` `error` `user-input` `resume`

```markdown
### 2026-03-20T09:00:00Z | phase=2 | type=milestone | Baseline BERT Reproduced

Details: <what happened>
```

Log events for: phase start/end, reproduction complete, iteration start/end, errors, user decisions, session resume, git commits.
