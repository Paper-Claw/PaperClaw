# File Classification & Rsync Commands

## File Classification

| Category | Where it lives | Tracked by git? | Sync strategy |
|----------|---------------|-----------------|---------------|
| **Code** (`codebase/`) | Local `./experiment/codebase/` | Yes (PaperClaw repo) | **Push** before each job; never edit on remote |
| **Datasets** | Remote `<workdir>/data/` | No | Re-download per server; too large to sync |
| **Checkpoints** (`checkpoints/`) | Local `./experiment/checkpoints/` | No (`.gitignore`) | **Pull** after each job; never pushed |
| **Results** (`results/`) | Local `./experiment/results/` | No (`.gitignore`) | **Pull** after each job |
| **Figures** (`figures/`) | Local `./experiment/figures/` | No (`.gitignore`) | **Pull** after each job |
| **Runtime** (`.venv/`, `__pycache__/`) | Remote `<workdir>/` | No | Ephemeral; never synced |

`.gitignore` entries (added by Step 0.6):
```
experiment/checkpoints/
experiment/results/
experiment/figures/
```

## Canonical PUSH Command (local codebase → remote, before each job)

```bash
# Key-based auth:
rsync -avz --delete \
  --exclude='data/' \
  --exclude='checkpoints/' \
  --exclude='results/' \
  --exclude='figures/' \
  --exclude='wandb/' \
  --exclude='.env' \
  --exclude='.venv/' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  --exclude='.git/' \
  -e "ssh -p <Port>" \
  ./experiment/codebase/ \
  <Host>:<Working Directory>/

# With password:
rsync -avz --delete \
  --exclude='data/' \
  --exclude='checkpoints/' \
  --exclude='results/' \
  --exclude='figures/' \
  --exclude='wandb/' \
  --exclude='.env' \
  --exclude='.venv/' \
  --exclude='__pycache__/' \
  --exclude='*.pyc' \
  --exclude='.git/' \
  -e "sshpass -p '<Password>' ssh -p <Port>" \
  ./experiment/codebase/ \
  <Host>:<Working Directory>/
```

- Run this immediately before launching any training/evaluation job on `<server>`.
- `--delete` ensures stale files from old runs are removed on the remote.
- **Targeted**: push only to the server receiving the next job (not all servers).
- **Local server exception**: If the server is local and `Working Directory` resolves to `./experiment/codebase/` (same path), skip the push — the directory IS the source.

## Canonical PULL Commands (remote artifacts → local, after each job)

Pull all raw results and logs immediately after each job completes. All performance computation (mean, std, aggregation) is done locally after pulling.

```bash
# Pull checkpoints
rsync -avz \
  -e "ssh -p <Port>" \
  <Host>:<Working Directory>/checkpoints/ \
  ./experiment/checkpoints/<server-name>/

# Pull results / logs (raw JSON, CSV, txt — everything)
rsync -avz \
  -e "ssh -p <Port>" \
  <Host>:<Working Directory>/results/ \
  ./experiment/results/<server-name>/

# Pull figures
rsync -avz \
  -e "ssh -p <Port>" \
  <Host>:<Working Directory>/figures/ \
  ./experiment/figures/<server-name>/
```

Add `sshpass -p '<Password>'` prefix to `-e "ssh ..."` if the server has a `Password` field.

### Artifact README

Each of `checkpoints/`, `results/`, `figures/` maintains a `README.md` (English) and `README_zh.md` (Chinese) that describes every file and subdirectory inside it. The executor **appends** a new entry after each pull. This is the user's primary reference for understanding what was pulled and what it corresponds to.

**README entry format** (append after each pull):

```markdown
## <server-name>/<relative-path> — <experiment name>

- **Method**: <method name>
- **Dataset**: <dataset name>
- **Server**: <server-name> (GPU <index>)
- **Tmux Session**: paperclaw-<safe-id>
- **Completed**: <ISO timestamp>
- **Duration**: <Xh Ym>

### Key Metrics

| Metric | Value | Target | Gap |
|--------|-------|--------|-----|
| F1     | 85.1  | 85.2   | -0.1 ✓ |

### Files

| File | Description | Size |
|------|-------------|------|
| `model_best.pt` | Best checkpoint (epoch 87) | 420 MB |
| `metrics.json` | Final evaluation metrics | 2 KB |
| `train.log` | Full training log | 15 KB |
```

**README_zh.md** uses the same structure but in Chinese (technical terms keep English in parentheses).

**Rules:**
- Initialize `README.md` and `README_zh.md` with a title header (`# Checkpoints`, `# Results`, or `# Figures`) when the directory is first created (Phase 0 Step 0.6).
- Append a new `## ...` section after each pull — never overwrite previous entries.
- If the same experiment re-runs (debug iteration), append a new entry with the iteration number in the title (e.g., `## server-A/resnet50/ — ResNet-50 reproduction (iter 3)`).

### Pull Rules

- Run after every job completes (training, evaluation, ablation, claim-proof, analysis).
- Sub-directory per server (`<server-name>/`) prevents filename collisions across servers.
- Update `Last Pull` timestamp in state.md after each pull.
- **After pulling**: compute metrics (mean, std across seeds, aggregated tables) locally using the pulled JSON/CSV files. Never run metric aggregation scripts on the remote server.
- **Local server exception**: If the server is local and the working directory is `./experiment/codebase/`, skip the pull — artifacts are already local. Figures may be in `./experiment/codebase/figures/`; move them to `./experiment/figures/` if needed. Still update the README files.
