---
name: paperclaw-experiment-AI
description: >-
  Use when the user wants to "run experiments", "reproduce baselines",
  "implement our method", "set up experiment server", "generate experiment report",
  or has a Proposal.md ready and needs to execute the full experiment pipeline.
  Runs an auto-pilot loop of server setup → experiment planning → baseline reproduction →
  our method implementation → report generation. All working state lives in ./experiment/.
  Produces Report.md, Report.html, Report_cn.md, and Report_cn.html as final deliverables.
version: 1.2.0
---

# PaperClaw Experiment AI — Full Experiment Execution Pipeline

Automate the complete experiment lifecycle: from remote server setup, through baseline reproduction and our method implementation, to polished experiment reports — all driven by a Proposal.md produced by the ideation skill.

## Core Principle

> **Reproduce first, innovate second, report thoroughly.**
>
> Every claimed number in the final report must be backed by a runnable script and a logged result.
> Every failure is an opportunity to learn — record it.
> Every claim in the Proposal must be proven by a dedicated experiment.

## Unified Project Principles

All experiment code on the remote server MUST follow these 7 principles. They are the authoritative source — agents reference them, not hardcoded directory layouts.

1. **Single project** — All methods (baselines + ours) live in one Python project with a shared `pyproject.toml` or `setup.py`, not in separate isolated folders.
2. **Common model interface** — All methods (baselines + ours) implement a shared base class or interface, registered via a model registry/factory pattern.
3. **Config-driven switching** — Switch between methods via config files (YAML/JSON), not by running scripts from different directories.
4. **Shared infrastructure** — Data loading, training loop, evaluation metrics, and logging are shared across all methods to ensure fair comparison.
5. **Unified entry points** — Single `train.py`, `eval.py`, etc. that work for any method via config. No separate per-method scripts.
6. **Adapt to existing codebases** — When baselines have official repos, extract and adapt their model code into the unified project's model module rather than running the cloned repo directly. If the project follows an existing codebase, respect that codebase's conventions.
7. **README.md** — Every experiment project must include a `README.md` documenting: project structure, how to install dependencies, how to run training/evaluation for each method, how to reproduce key results, and dataset preparation.

---

## Workflow Overview

```mermaid
flowchart TD
    P0["Phase 0: Server Setup & Hardware Probe"]
    P1["Phase 1: Read Proposal → Experiment Plan"]
    P2["Phase 2: Baseline Reproduction"]
    P3["Phase 3: Our Method Implementation"]
    P4["Phase 4: Completeness Check → Report Generation"]

    P0 --> P1
    P1 -->|"1.1–1.3: executor"| P1a["Research baselines & datasets"]
    P1a -->|"1.4: strategist"| P1b["Design experiment matrix"]
    P1b -->|"1.5–1.7: executor"| P1c["Write plan.md & results.md"]
    P1c --> P2

    P2 -->|"iterative: executor"| P2loop{"Results match\nreported numbers?"}
    P2loop -->|No, iter ≤ 5| P2
    P2loop -->|No, iter > 5| User1["Escalate to user"]
    P2loop -->|Yes| P3

    P3 -->|"3.1: strategist"| P3a["Implement core architecture"]
    P3a -->|"3.2–3.3: executor"| P3loop{"Beats all\nbaselines?"}
    P3loop -->|"No, iter 1–2: executor"| P3
    P3loop -->|"No, iter ≥ 3: strategist"| P3diag["Diagnose & fix"]
    P3diag --> P3
    P3loop -->|"No, iter > 10"| User2["Escalate to user"]
    P3loop -->|Yes| P3b["3.5–3.9: Ablation + Multi-seed + Claim-proof + Analysis"]
    P3b --> P4

    P4 -->|"4.1: executor"| P4a["Completeness check"]
    P4a -->|"4.2: strategist"| P4b["Generate Report.md"]
    P4b -->|"4.3–4.6: executor"| P4c["HTML + Chinese + Git commit"]

    style P1b fill:#f9e2af
    style P3a fill:#f9e2af
    style P3diag fill:#f9e2af
    style P4b fill:#f9e2af
```

> Yellow nodes = strategist (opus). All other nodes = executor (sonnet).

All phases run on the **local machine** (where Claude Code is running).
Compute-heavy training/evaluation is executed on the **experiment server** via SSH.

---

## Agent Architecture

This skill dispatches work to two dedicated agents. The entry model of the current session does not matter — routing is determined by agent definitions.

| Agent | Model | Role |
|-------|-------|------|
| `paperclaw-experiment-executor` | sonnet | Default: all execution, SSH, research, debugging, logging, git, translation |
| `paperclaw-experiment-strategist` | opus | High-judgment only: 4 tasks requiring original reasoning |

### Strategist Triggers

| Phase.Step | Task |
|------------|------|
| 1.4 | Design full experiment matrix + claim-proof table |
| 3.1 | Implement core method architecture from Proposal.md |
| 3.3 (iter ≥ 3, i.e., starting from iteration 3) | Diagnose structural performance gap and form fix hypothesis |
| 4.2 | Generate Report.md (full synthesis of all results) |

Everything else → executor. After strategist returns, resume with executor.

---

## Resume Protocol

When starting a new session, check if `./experiment/state.md` exists:

1. **If exists** → Read state.md to determine current phase/step
2. **Read log.md** for recent events and context
3. **Check remote server** via SSH: reachable? Check for active tmux sessions (`tmux list-sessions 2>/dev/null | grep '^paperclaw-'`). If a training job is still running in a `paperclaw-*` session, resume monitoring it instead of restarting. Check latest checkpoint.
   - If SSH **unreachable**: do NOT escalate immediately. Retry once after 30 seconds.
   - If still unreachable: ask user via `AskUserQuestion` with three options:
     1. **Wait** — user will restore server access; resume after confirmation
     2. **Local-only mode** — skip all remote operations; continue with local files (plan.md, results.md, report generation only)
     3. **Abort** — save state and exit cleanly
   - Record the decision in log.md and proceed accordingly.
4. **Resume** from the last incomplete step recorded in state.md
5. **If Phase 2/3** → also read comparison.md / ours.md for iteration history

If the user wants to restart a phase, they must explicitly say so.

### state.md Format

```markdown
---
updated: <timestamp>
---

# Experiment State

- **Current Phase**: <0-4>
- **Current Step**: <e.g., 2.3>
- **Status**: [running / blocked / waiting-for-user / complete]
- **Blocker**: <description or "none">
- **Last Action**: <brief description>
- **Server**: <connected / disconnected>

## Progress Tracking

- **Total Experiments**: <N> (baselines: <N>, ablations: <N>, claim-proofs: <N>, analysis: <N>)
- **Completed**: <N>
- **Remaining**: <N>
- **Estimated Time Per Job**: <minutes>
- **Estimated Remaining Time**: <H hours M minutes>

## Active Jobs

| Session ID | Experiment | GPU(s) | Est. RAM | Started | Status |
|------------|-----------|--------|----------|---------|--------|
| paperclaw-train-baseline-X | Baseline X on Dataset A | 0 | 12G | <timestamp> | running |
| paperclaw-train-baseline-Y | Baseline Y on Dataset B | 1 | 8G | <timestamp> | running |

- **Max Concurrent GPU Jobs**: <N> (from server.md)
- **Max Concurrent CPU Jobs**: <N> (from server.md)
```

**Update state.md** at: phase start, step start/end, blockers, user input requests, job start/finish, concurrent job launch/completion.

### Progress Tracking & ETA

When a job finishes, update `Estimated Time Per Job` with a running average:

```
avg = (previous_avg * completed_count + this_job_time) / (completed_count + 1)
remaining_time = remaining_experiments * avg
```

When the user asks progress, report:

```
📊 Experiment Progress
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

## Working Files

All internal files live under `./experiment/`:

| File | Type | Purpose |
|------|------|---------|
| `server.md` | Overwrite | Server connection info, hardware specs |
| `plan.md` | Overwrite | Experiment plan (datasets, baselines, metrics, schedule) |
| `comparison.md` | Append-only | Baseline reproduction log (iterations, errors, fixes) |
| `ours.md` | Append-only | Our method implementation log (iterations, errors, fixes) |
| `state.md` | Overwrite | Current phase, step, blockers, progress tracking |
| `log.md` | Append-only | Timestamped event log across all phases |
| `results.md` | Overwrite | Running experiment result tables |
| `figures/` | Directory | Visualization outputs downloaded from server (PNG, 300dpi) |

Final outputs in project root (`./`):

| File | Format | Language | Audience |
|------|--------|----------|----------|
| `Report.md` | Markdown | English | Detailed report for paper writing |
| `Report_cn.md` | Markdown | Chinese | Chinese translation for paper writing |
| `Report.html` | HTML | English | Polished report for user review |
| `Report_cn.html` | HTML | Chinese | Polished report for user review |

### Iteration Log Entry Template

Used in both `comparison.md` and `ours.md`:

```markdown
## <Title> — Iteration <N>

**Date**: <timestamp>  |  **Status**: [Success / Partial / Failed / Improved / Regressed]

### Configuration
- Command: `<full command>`
- Key params: <hyperparameters or changes made>

### Results
| Dataset | Metric | Target/Previous | Actual | Δ |
|---------|--------|-----------------|--------|---|

### Issues & Fix
- **Issue**: <description>
- **Fix**: <what was changed and why>

### Git Commit
- `<hash>`: `<message>`
```

### log.md Event Format

```markdown
### [<timestamp>] <Event Title>

**Phase**: <N>  |  **Type**: [milestone / decision / error / user-input / resume]
**Details**: <what happened>
```

Log events for: phase start/end, reproduction complete, iteration start/end, errors, user decisions, session resume, git commits.

---

## Phase 0: Server Setup & Hardware Probe

### Goal

Establish a reliable connection to the experiment server and record its capabilities.

### Steps

#### Step 0.1: Ask for Server Info

Prompt the user with `AskUserQuestion`:
1. SSH host (e.g., `user@hostname` or IP)
2. SSH port (default 22)
3. Working directory on the server (e.g., `/home/user/experiments`)

> **Sudo password**: Do NOT ask upfront. Most experiment workflows do not need sudo. If a command fails because sudo is required, ask the user for the password at that specific point only, then proceed. Never store sudo password in any file — session memory only. Redact credentials in all logs with `<REDACTED>`.

#### Step 0.2: Test SSH Connection

```bash
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new <user>@<host> -p <port> "echo 'Connection OK'"
```

If connection fails: report error, ask for corrected credentials, retry (max 3 attempts).

#### Step 0.3: Probe Hardware

```bash
ssh <server> "nvidia-smi --query-gpu=index,name,memory.total,memory.used,driver_version --format=csv,noheader 2>/dev/null || echo 'No GPU'; \
  lscpu | grep -E 'Model name|^CPU\(s\)|Core|Thread'; nproc; free -h | head -2; free -m | grep Mem; df -h <workdir>; \
  python3 --version 2>/dev/null; nvcc --version 2>/dev/null; head -4 /etc/os-release"
```

Record in server.md the **resource capacity** for scheduling (see Appendix F):
- Number of GPUs and per-GPU memory (MiB)
- Total CPU cores (physical) and threads
- Total RAM (MiB)
- Available disk space

#### Step 0.4: Check Working Directory

```bash
ssh <server> "test -d <workdir> && test -w <workdir> && echo 'OK' || echo 'FAIL'; ls -A <workdir> | head -5"
```

If not empty, ask the user: proceed (preserve existing files) or choose a different directory?

#### Step 0.5: Write server.md

Write `./experiment/server.md` with sections:
- **Connection**: host, port, user, workdir
- **Hardware**: GPU table (index, name, memory each), CPU (cores, threads), total RAM, storage
- **Software Environment**: OS, Python, CUDA, driver version
- **Scheduling Capacity** (see Appendix F): per-GPU total memory, max concurrent CPU jobs, RAM thresholds, measured job memory footprints

#### Step 0.6: Probe Local Hardware

Detect local machine specs (`system_profiler` on macOS) and append a "Local Machine" section to `server.md`.

### Completion Criteria

- [x] SSH connection confirmed
- [x] Hardware specs recorded in server.md
- [x] Working directory is writable

---

## Phase 1: Read Proposal → Experiment Plan

### Goal

Parse the Proposal.md and generate a comprehensive, actionable experiment plan.

### Prerequisites

- `./Proposal.md` must exist (output of paperclaw-ideation-AI)
- If not found: ask the user for the path

### Steps

#### Step 1.1: Parse Proposal.md

Read and extract:
1. **Research question** and core claims
2. **Proposed method** architecture and key components
3. **Datasets** (name, source, size, task)
4. **Baseline methods** (name, paper, venue)
5. **Evaluation metrics** (accuracy, F1, BLEU, etc.)
6. **Ablation study** plans
7. **Analysis experiments** (visualization, case study, efficiency)

#### Step 1.2: Research Baseline Methods

For each baseline method in the Proposal:
1. Search for the paper, extract reported results, find official code repository
2. Check reproducibility: clear instructions? pre-trained models?

**Additionally**, mine each baseline's own comparison tables:
3. What methods did *they* compare against?
4. What datasets did *they* use that we haven't included?
5. Identify gaps: any SOTA method (published ≤ 2 years, top venue) appearing in ≥ 2 comparison tables but missing from our plan?

**Augment** the plan with missing SOTA methods and benchmark datasets. Flag augmented entries as `[Added]`.

Build a **Baseline Reference Table**:

```markdown
| Method | Venue | Year | GitHub | Dataset1-Metric | Dataset2-Metric | Reproducibility | Source |
|--------|-------|------|--------|-----------------|-----------------|-----------------|--------|
| MethodA | NeurIPS'24 | 2024 | url | 85.3 | 72.1 | High | Proposal |
| MethodC | ICLR'24 | 2024 | url | 86.1 | 73.4 | High | [Added] from MethodA table |
```

#### Step 1.3: Research Datasets

For each dataset: find download source, verify availability, check size, note preprocessing.

Build a **Dataset Reference Table**:

```markdown
| Dataset | Task | Size | Source | Download | Preprocessing |
|---------|------|------|--------|----------|---------------|
```

#### Step 1.4: Design Experiment Matrix *(strategist)*

Extract all explicit and implicit claims from Proposal.md. Each claim must map to at least one experiment:

```markdown
## Main Experiments
| Experiment | Datasets | Methods | Metrics | Purpose |
|------------|----------|---------|---------|---------|

## Ablation Studies
| Experiment | Variants | Dataset | Purpose |
|------------|----------|---------|---------|

## Claim-Proof Experiments
| Claim (from Proposal) | Experiment Design | Dataset | Metric | Expected Result |
|-----------------------|-------------------|---------|--------|-----------------|

## Analysis Experiments
| Experiment | Type | Dataset | Purpose |
|------------|------|---------|---------|
```

> **Rule**: Every non-trivial claim must have a Claim-Proof row. If untestable, flag it in plan.md.
>
> **Output rule**: The strategist writes all four tables directly into `./experiment/plan.md` under an `## Experiment Matrix` section. Do NOT create separate files (e.g., `experiment_matrix.md`).

#### Step 1.5: Finalize plan.md

The executor supplements the strategist's experiment matrix (already in plan.md from Step 1.4) with:
- Estimated compute budget (GPU hours)
- Execution order and dependencies
- Risk assessment and fallback plans

#### Step 1.6: Initialize Unified Project & Git Repository

On the remote server:
1. Create the unified Python project scaffold following the **Unified Project Principles** above: `pyproject.toml` (or `setup.py`), a model registry/factory, shared data loading, shared training loop, shared evaluation, and unified entry points (`train.py`, `eval.py`). The concrete directory layout is decided by the strategist based on the project domain and any existing codebase conventions.
2. Write an initial `README.md` documenting the project structure, installation, and basic usage.
3. `git init`, create `.gitignore` (exclude `__pycache__/`, `.venv/`, `data/`, `*.pt`, `*.pth`, `wandb/`, `.env`, credentials, etc.), initial commit.

#### Step 1.7: Create results.md

Initialize `./experiment/results.md` with empty experiment tables (headers + reported baseline values, reproduced and ours rows set to `-`).

Git commit locally: `docs(experiment): generate experiment plan`

### Completion Criteria

- [x] plan.md contains baselines, datasets, experiment matrix, claim-proof table
- [x] results.md initialized with all table headers
- [x] Git repo initialized on server
- [x] All [Added] methods/datasets flagged for user review

---

## Phase 2: Baseline Reproduction

### Goal

Reproduce all baseline methods and verify results match reported numbers (within tolerance: ±2% relative or ±1 absolute point).

### Steps

#### Step 2.0: Create Virtual Environment

```bash
ssh <server> "cd <workdir> && python3 -m venv .venv"
```

**Critical**: ALL subsequent Python commands MUST activate the venv first:
```bash
ssh <server> "cd <workdir> && source .venv/bin/activate && <command>"
```

Install common dependencies (torch, numpy, scipy, scikit-learn, pandas, matplotlib, tqdm, wandb, etc.).

#### Step 2.1: Download Datasets

For each dataset in plan.md: create `data/<dataset>/`, download, verify integrity. Git commit after datasets are ready.

#### Step 2.2: Setup Baseline Code

For each baseline:
- **Option A**: Clone official repo as reference → extract and adapt model code into the unified project's model module, conforming to the common model interface. Write a config file for the baseline. If following an existing codebase, respect its conventions.
- **Option B**: Implement from paper if no code available, as a model class in the unified project conforming to the common interface.

Git commit after each baseline code setup.

#### Step 2.3: Run Baselines (Resource-Aware Parallel)

Use the project's unified training and evaluation entry points with each baseline's config file.

**Parallel scheduling** (see Appendix F for full rules):
1. Before launching a new job, run the **resource check** commands (Appendix F.2) to get current CPU%, RAM%, and per-GPU memory usage.
2. Consult the scheduling capacity in server.md to determine how many concurrent jobs are allowed.
3. If resources permit, launch **independent baselines in parallel** — e.g., different baselines on different GPUs, or CPU-light evaluation alongside GPU training. Each gets its own tmux session (`paperclaw-train-baseline-<method>`).
4. If launching would exceed any threshold (RAM > 85%, GPU memory > 90%, CPU > 90%), **wait** for a running job to finish before launching the next one.
5. Monitor all active sessions; when one finishes, check resources again and launch the next queued experiment.
6. Update the **Active Jobs** table in state.md whenever a job starts or finishes.

> **Important**: Jobs that share the same GPU or write to the same files are NOT independent — run them sequentially. Only parallelize truly independent experiments (different methods, different datasets, different GPUs).

#### Step 2.4: Compare Results

Compare reproduced results against reported numbers.

If results DO NOT match:

```mermaid
flowchart TD
    A["Reproduction mismatch"] --> B["Log in comparison.md"]
    B --> C["Diagnose: hyperparams → data → seed → framework → weights"]
    C --> D["Apply fix & re-run"]
    D --> E{"Match?"}
    E -->|"No, iter ≤ 5"| C
    E -->|"No, iter > 5"| F["Escalate to user"]
    E -->|Yes| G["Mark reproduced ✅"]
```

#### Step 2.5: Log Each Iteration

Append to `./experiment/comparison.md` using the **Iteration Log Entry** template (see Working Files section).

#### Step 2.6: Update results.md

After each successful reproduction, update the "reproduced" rows in results.md.

Git commit locally after each baseline reproduced: `docs(results): reproduce <method> on <dataset>`

#### Step 2.7: Git Commit Milestones

Commit on remote server after each major milestone (see Git Strategy for message format):
- Each baseline successfully reproduced
- Dataset preparation complete
- Unified evaluation pipeline ready

### Completion Criteria

- [x] ALL baselines reproduced within tolerance
- [x] comparison.md has complete iteration logs
- [x] results.md updated with all reproduced numbers
- [x] If any baseline failed after 5 iterations: user decision recorded

---

## Phase 3: Our Method Implementation

### Goal

Implement the proposed method, achieve SOTA results on all datasets, conduct ablation + claim-proof + analysis experiments.

### Steps

#### Step 3.1: Implement Core Method *(strategist)*

Based on Proposal.md method design:
1. Implement our method as a new model class in the unified project's model module, conforming to the common model interface
2. Implement model architecture (PyTorch, type hints, docstrings, ≤400 lines/file)
3. Write a config file for our method (config-driven hyperparameters, checkpoint saving, seed setting)
4. Ensure the unified entry points (`train.py`, `eval.py`) work with our method's config
5. Update `README.md` with our method's usage instructions

Git commit on remote: `feat(method): implement core method architecture`

#### Step 3.2: Initial Training & Debugging

Run on each dataset. Debug common issues: shape mismatches, NaN/Inf loss, OOM, non-convergence.

Git commit after training runs successfully: `feat(method): initial training working on <dataset>`

#### Step 3.3: Iterative Performance Improvement

**Target**: Beat ALL baselines on ALL datasets.

```mermaid
flowchart TD
    A["Gap detected"] --> B["Analyze source"]
    B --> C["Hypothesize improvement"]
    C --> D["Implement & test"]
    D --> E["Log in ours.md"]
    E --> F{"Beats all?"}
    F -->|"No, iter 1–2: executor debug"| B
    F -->|"No, iter ≥ 3: strategist"| G["Deep diagnosis"]
    G --> D
    F -->|"No, iter > 10\n(total, counted from iter 1)"| H["Escalate to user"]
    F -->|Yes| I["Proceed to 3.5"]
```

Improvement priority: hyperparameters → architecture → training strategy → loss function → ensemble.

Git commit after each significant improvement: `feat(method): improve <component> (+X.X on <dataset>)`

#### Step 3.4: Log Each Iteration

Append to `./experiment/ours.md` using the **Iteration Log Entry** template (see Working Files section).

#### Step 3.5: Ablation Studies (Resource-Aware Parallel)

Once our method beats all baselines:
1. **Component ablation** — Remove each key component one at a time
2. **Hyperparameter sensitivity** — Vary key hyperparameters
3. **Module replacement** — Replace our components with alternatives

**Parallel scheduling**: Ablation variants are independent — launch multiple in parallel following the resource-aware rules (Appendix F). Each variant gets its own tmux session (`paperclaw-ablation-<variant>`). Check resources before each launch; wait if thresholds are exceeded.

Record results in ours.md and results.md. Git commit: `feat(ablation): complete component ablation study`

#### Step 3.6: Multi-Seed Runs (Resource-Aware Parallel)

Run final config with 3–5 seeds (42, 123, 456, 789, 1024). Report **mean ± std** in results.md.

**Parallel scheduling**: Different seeds are independent — launch multiple seed runs in parallel on separate GPUs or when resources permit. Each gets its own tmux session (`paperclaw-seed-<seed>`). Follow Appendix F resource checks.

Git commit: `feat(method): complete multi-seed runs (mean±std reported)`

#### Step 3.7: Claim-Proof Experiments (Resource-Aware Parallel)

Run all claim-proof experiments from the Claim-Proof table in plan.md. Independent claim-proof experiments can run in parallel following Appendix F.
1. Implement measurement/comparison code
2. Run experiment
3. Check if result supports the claim
4. **If result contradicts a claim** → do NOT stop or escalate immediately. Instead:
   - Add a `⚠️ CLAIM CONTRADICTION` entry to ours.md and log.md with full details
   - Add a "Contradictions" section to results.md listing all contradicted claims
   - Continue running remaining experiments
   - Contradictions will be surfaced to the user during the Phase 4 completeness check

Record in ours.md with verdict (Supported / Partially Supported / Contradicted). Update results.md "Claim Verification" section.

Git commit per claim: `feat(claim-proof): verify claim "<claim_summary>"`

#### Step 3.8: Analysis Experiments

Conduct analysis from plan.md: efficiency, visualization (t-SNE, attention maps), case studies, scalability. Download figures via scp to `./experiment/figures/`.

Git commit: `feat(analysis): complete <analysis_type> experiments`

#### Step 3.9: Update results.md & README.md

Fill in all remaining rows: ours main results, ablation tables, analysis tables, figure references.

Update the project's `README.md` on the remote server with final reproduction commands for all methods.

Git commit locally: `docs(results): update results for all experiments`

### Completion Criteria

- [x] Our method beats all baselines on all main metrics (Step 3.3)
- [x] All ablation studies done (Step 3.5)
- [x] Multi-seed runs complete, mean±std reported (Step 3.6)
- [x] All claim-proof experiments done; contradictions logged in results.md (Step 3.7)
- [x] All analysis experiments done (Step 3.8)
- [x] results.md fully populated (Step 3.9)
- [x] ours.md has complete iteration history

---

## Phase 4: Completeness Check & Report Generation

### Goal

Verify all experiments are complete, then generate four report files.

### Steps

#### Step 4.1: Completeness Check

Verify plan.md against results.md:
- All main comparison results present
- All baseline reproductions within tolerance
- Our method beats all baselines (flag exceptions)
- All ablation / claim-proof / analysis experiments completed
- results.md fully populated (no `-` or `TBD` remaining)
- comparison.md and ours.md have complete iteration logs

If incomplete → go back to the relevant phase.

**Claim Contradiction Check**: Read the "Contradictions" section of results.md (populated in Step 3.7).
- If one or more claims are contradicted → surface all contradictions to the user via `AskUserQuestion` **before** generating the report:
  > "The following claims from Proposal.md were contradicted by experiments: [list]. How would you like to proceed? (a) Revise the Proposal claims and continue to report generation; (b) Re-run specific experiments; (c) Proceed to report generation as-is (contradictions will be documented)."
- Record the user's decision in log.md, then proceed accordingly.

#### Step 4.2: Generate Report.md *(strategist)*

Write a comprehensive English report to **`./Report.md`** (project root, NOT `./experiment/`) following `references/report-template.md`. Required sections:

1. **Method Design** — Overview, architecture (with Mermaid diagram), key components, training pipeline, implementation details
2. **Datasets** — Per-dataset: task, size, source, citation, preprocessing
3. **Comparison Methods** — Per-baseline: venue, core idea, key difference, citation
4. **Experimental Results** — Main comparison, ablation, claim verification, analysis (each with table + analysis)
5. **Conclusion** — Performance highlights, robustness, efficiency, key takeaways
6. **Execution Log** — Baseline reproduction summary, our method development summary
7. **Appendix** — Server config, software environment, reproduction commands

Every claim from the Proposal must appear in section 4 with a pass/fail verdict.

#### Step 4.3: Generate Report.html

Convert Report.md to styled HTML using `references/report-html-template.html` as base. Requirements: academic serif typography, responsive layout, sortable tables, collapsible `<details>` sections, Mermaid rendering via CDN, print-friendly. `lang="en"`.

#### Step 4.4: Generate Report_cn.md

Chinese Markdown translation of Report.md. Rules:
- Keep numbers, method names, dataset names, math notation, citations in English
- Table and section structure identical to Report.md
- Technical terms with English in parentheses: "消融实验 (Ablation Study)"
- All file/code paths unchanged

#### Step 4.5: Generate Report_cn.html

Chinese HTML version using same template. Change `lang="zh-CN"`, use Chinese fonts (`PingFang SC`, `Microsoft YaHei`). Same translation rules as Report_cn.md.

#### Step 4.6: Final Git Commit

Update `README.md` on the remote server with final reproduction commands for all experiments.

```bash
git add experiment/ Report.md Report_cn.md Report.html Report_cn.html
git commit -m "feat(experiment): complete experiment pipeline — all phases done"
```

### Completion Criteria

- [x] Report.md covers all 7 sections per template
- [x] Report.html renders correctly with Mermaid diagrams
- [x] Report_cn.md and Report_cn.html are complete translations
- [x] All 4 output files exist in project root
- [x] Final git commit made

---

## Appendix

### A. Auto-Pilot Decision Making

This skill operates autonomously by default. Decisions are logged to `./experiment/log.md`.

**ALWAYS ask** (never auto-decide):
1. Server credentials and connection setup (Phase 0.1)
2. SSH unreachable during resume (offer: wait / local-only / abort)
3. Baseline reproduction fails after 5 iterations
4. Our method cannot beat a baseline after 10 total iterations
5. Non-empty working directory found on server
6. Dataset requires registration/login to download
7. Plan.md ready for review before execution
8. Sudo is required for a specific command (ask at that moment only; do NOT ask upfront)

**Auto-decide and log**:
1. Hyperparameter adjustments during reproduction
2. Bug fixes in baseline code
3. Architecture refinements
4. Optimization strategy choices
5. Git commit timing and messages

Decision log format:

```markdown
### [<timestamp>] <Decision Title>

**Phase**: <N>  |  **Context**: <what led to this>
**Options**: 1. <A>  2. <B>
**Decision**: <chosen>  |  **Rationale**: <why>
```

### B. SSH Command Patterns

All remote commands follow these patterns:

```bash
# Simple command
ssh -o ConnectTimeout=30 <user>@<host> -p <port> "cd <workdir> && <command>"

# With venv
ssh -o ConnectTimeout=30 <user>@<host> -p <port> "cd <workdir> && source .venv/bin/activate && <command>"

# Long-running training (use tmux, NOT nohup)
# Session naming: paperclaw-<experiment_id> (e.g., paperclaw-train-baseline-pomo, paperclaw-ablation-01)
# The command auto-closes the tmux session when the program finishes.
ssh <server> "tmux new-session -d -s paperclaw-<experiment_id> 'cd <workdir> && source .venv/bin/activate && python train.py --config <config> 2>&1 | tee train.log; tmux wait-for -S paperclaw-<experiment_id>-done'"

# Check training status (attach or read log)
ssh <server> "tmux capture-pane -t paperclaw-<experiment_id> -p | tail -50"
# Or read the log file directly:
ssh <server> "cd <workdir> && tail -50 train.log"

# Check if a tmux session is still running
ssh <server> "tmux has-session -t paperclaw-<experiment_id> 2>/dev/null && echo 'RUNNING' || echo 'FINISHED'"

# Wait for a tmux session to finish (blocking)
ssh <server> "tmux wait-for paperclaw-<experiment_id>-done"

# Kill a stuck session (only when explicitly needed)
ssh <server> "tmux kill-session -t paperclaw-<experiment_id>"

# List all paperclaw sessions
ssh <server> "tmux list-sessions 2>/dev/null | grep '^paperclaw-' || echo 'No active sessions'"

# File transfer
scp -P <port> <user>@<host>:<workdir>/results/* ./experiment/figures/
```

**Tmux session lifecycle:**
1. Start: `tmux new-session -d -s paperclaw-<id> '<command>; tmux wait-for -S paperclaw-<id>-done'`
2. Monitor: `tmux has-session -t paperclaw-<id>` to check if still running, or `tmux capture-pane` to read output
3. Auto-cleanup: When the command finishes, the session closes automatically (since the shell command was the only process). The `tmux wait-for -S` signal lets the local side know it's done.
4. **Never leave orphaned sessions.** If a session is no longer needed (e.g., after error recovery), kill it explicitly with `tmux kill-session`.

Timeout handling: use `tmux` for all long-running jobs (training, evaluation, dataset download), `ConnectTimeout=30` for short commands, retry 3× on SSH drop.

### C. Git Strategy

#### Remote Server Git (experiment code)

| Milestone | Commit Message |
|-----------|---------------|
| Init | `chore: initialize unified experiment project` |
| Dataset ready | `feat(data): download and verify <dataset>` |
| Baseline code setup | `feat(baseline): integrate <method> into unified project` |
| Baseline reproduced | `feat(baseline): reproduce <method> (metric=XX.X)` |
| Our method initial | `feat(method): implement core method architecture` |
| Training working | `feat(method): initial training working on <dataset>` |
| Each improvement | `feat(method): improve <component> (+X.X on <dataset>)` |
| Ablation done | `feat(ablation): complete component ablation study` |
| Multi-seed done | `feat(method): complete multi-seed runs (mean±std)` |
| Claim-proof done | `feat(claim-proof): verify claim "<summary>"` |
| Analysis done | `feat(analysis): complete <type> experiments` |
| All done | `feat: complete all experiments` |

#### Local Git (working files)

| Milestone | Commit Message |
|-----------|---------------|
| Plan ready | `docs(experiment): generate experiment plan` |
| Baseline reproduced | `docs(results): reproduce <method> on <dataset>` |
| Ours beats baseline | `docs(results): ours beats <method> on <dataset> (+X.X)` |
| Ablation done | `docs(results): complete ablation study` |
| Claim proof done | `docs(results): verify claim "<short>"` |
| Analysis done | `docs(results): complete <type> analysis` |
| Results updated | `docs(results): update results for <method/dataset>` |
| Report generated | `docs(report): generate experiment reports (EN + CN)` |

**Rule**: Never squash or amend local experiment commits. The git log is the full history of the experiment, useful for tracing decisions and writing the paper.

### D. Error Recovery

| Error | Action |
|-------|--------|
| SSH connection lost | Wait 30s → retry 3× → ask user. Training preserved via `tmux` — check `tmux has-session -t paperclaw-<id>` on reconnect. |
| Training crash | Check `tail -100 train.log`. Common fixes: reduce batch size, check data path, verify GPU. Resume from latest checkpoint. |
| Out of disk | `df -h && du -sh <workdir>/*`. Clean old checkpoints, cached data. Ask user if still insufficient. |
| Out of GPU memory | Reduce batch size → gradient accumulation → mixed precision (fp16/bf16) → gradient checkpointing. |
| Machine unresponsive (OOM kill / CPU saturated) | SSH will likely timeout. Wait 2 min, retry. If reachable: check `dmesg | tail -30` for OOM kills, `tmux list-sessions` for surviving jobs. Reduce max concurrent jobs in server.md by 1. Restart killed jobs from checkpoint. If unreachable after 3 retries: ask user to hard-reboot, then resume per Resume Protocol. |

### E. Tool Reference

| Tool | Primary Use |
|------|-------------|
| `AskUserQuestion` | Server credentials, escalation decisions |
| `Bash` | SSH commands, git operations, scp transfers |
| `Read` | Proposal.md, plan.md, results.md, comparison.md, ours.md |
| `Write` / `Edit` | All working files, report files |
| `WebSearch` / `WebFetch` | Paper search, repo discovery, dataset sources |
| `TodoWrite` | Phase/step progress tracking |
| `Agent` | Dispatch strategist/executor sub-agents |

### F. Resource-Aware Parallel Scheduling

The experiment server has finite resources. Blindly launching all jobs at once can cause OOM kills, CPU saturation, or the machine becoming unresponsive. This appendix defines how to safely parallelize experiments.

#### F.1: Scheduling Capacity (determined in Phase 0)

After hardware probing, compute and record in server.md:

```markdown
## Scheduling Capacity

- **GPUs**: <N> × <name> (<M> MiB each)
- **Max Concurrent CPU-Only Jobs**: <floor(total_threads / 4)> (cap at 4)
- **RAM Headroom**: reserve 15% of total RAM for OS + SSH + monitoring

### Thresholds (do NOT launch new jobs if exceeded)
- RAM usage > 85% of total
- GPU: free memory on target GPU < estimated peak memory of the new job
- CPU usage > 90% sustained (1-min avg)
- Disk usage > 90%
```

**Capacity rules:**
- **Same GPU, multiple jobs**: Allowed as long as the GPU has enough **free memory** to fit the new job. No fixed headroom — use all available memory, just don't exceed total. Example: a 24 GiB GPU running a 10 GiB job has ~14 GiB free; a second job needing 8 GiB can launch on the same GPU.
- **Multi-GPU (N GPUs)**: Prefer spreading jobs across GPUs first. Only stack on the same GPU when all GPUs are partially occupied and free memory permits.
- **CPU-only jobs**: can run alongside GPU jobs as long as RAM and CPU thresholds are respected.
- **Estimating GPU memory**: If a job's GPU memory footprint is unknown, run it once solo and record peak usage via `nvidia-smi`. Use that measurement for subsequent scheduling. Before the first measurement, assume **70% of one GPU's total memory** as a conservative estimate.

#### F.2: Resource Check Commands

Run these **before launching any new job**:

```bash
# Combined resource snapshot (single SSH call)
ssh <server> "echo '=== GPU ==='; nvidia-smi --query-gpu=index,memory.used,memory.total,utilization.gpu --format=csv,noheader 2>/dev/null || echo 'No GPU'; \
  echo '=== RAM ==='; free -m | grep Mem; \
  echo '=== CPU ==='; top -bn1 | grep 'Cpu(s)' | awk '{print \"CPU used: \" 100-\$8 \"%\"}'; \
  echo '=== DISK ==='; df -h <workdir> | tail -1; \
  echo '=== ACTIVE JOBS ==='; tmux list-sessions 2>/dev/null | grep '^paperclaw-' || echo 'None'"
```

Parse the output and compare against thresholds. If **any** threshold is exceeded, **do not launch** — wait for a running job to finish, then re-check.

#### F.3: Launch Protocol

Before starting a new experiment:

1. **Check active jobs**: `tmux list-sessions | grep '^paperclaw-'` — count running jobs.
2. **Check resources**: Run F.2 resource snapshot.
3. **Evaluate**:
   - **GPU job**: Check each GPU's free memory (`memory.total - memory.used`). If any GPU has free memory ≥ the new job's estimated peak GPU memory → OK to launch on that GPU (prefer the GPU with the most free memory).
   - **CPU-only job**: If RAM < 85% AND CPU < 90% → OK to launch.
   - Otherwise → **wait**. Poll every 60 seconds until a slot opens (a running job finishes and frees resources).
4. **Pin GPU**: For GPU jobs, always set `CUDA_VISIBLE_DEVICES=<gpu_index>` in the tmux command:
   ```bash
   ssh <server> "tmux new-session -d -s paperclaw-<id> 'cd <workdir> && source .venv/bin/activate && CUDA_VISIBLE_DEVICES=<gpu_index> python train.py --config <config> 2>&1 | tee <logfile>; tmux wait-for -S paperclaw-<id>-done'"
   ```
5. **Update state.md**: Add the new job to the Active Jobs table.
6. **Log**: Record the launch in log.md with the resource snapshot at launch time.

#### F.4: Monitoring Active Jobs

When multiple jobs are running concurrently:

```bash
# Check which sessions are still alive
ssh <server> "tmux list-sessions 2>/dev/null | grep '^paperclaw-'"

# Check a specific job's latest output
ssh <server> "tmux capture-pane -t paperclaw-<id> -p | tail -20"

# Quick health check: are resources still within thresholds?
ssh <server> "free -m | grep Mem; nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv,noheader 2>/dev/null"
```

When a job finishes:
1. Remove it from the Active Jobs table in state.md.
2. Check resources again (F.2).
3. Launch next queued experiment if resources permit.

#### F.5: What Can Run in Parallel

| Scenario | Parallel? | Notes |
|----------|-----------|-------|
| Different baselines on different GPUs | Yes | Pin each to its own GPU |
| Different baselines on same GPU | Yes, if memory fits | Sum of peak GPU memory of all jobs on that GPU must < GPU total memory |
| Different seeds of same method on different GPUs | Yes | Pin each to its own GPU |
| Different seeds on same GPU | Yes, if memory fits | Same rule: sum of peak memory < total |
| Ablation variants on same/different GPUs | Yes, if memory fits | Prefer spreading across GPUs first |
| CPU evaluation while GPU is training | Yes | As long as RAM permits |
| Dataset download while GPU is training | Yes | I/O bound, minimal CPU/RAM |
| Two training jobs on a single-GPU machine | Yes, if memory fits | Check free memory ≥ new job's peak; if not, wait |
| Our method iteration while a baseline is still running | Yes, if memory fits | OK on same GPU if free memory sufficient; prefer different GPU |

#### F.6: Adaptive Capacity Adjustment

If a job triggers an OOM kill or the machine becomes unresponsive:
1. After recovery, reduce `Max Concurrent GPU Jobs` by 1 in server.md.
2. Log the incident in log.md with the resource state at the time.
3. For subsequent jobs, also reduce batch size or enable gradient checkpointing.
4. If max concurrent drops to 0 (i.e., even a single job OOMs), this is a single-job OOM issue — handle per Appendix D (reduce batch size, mixed precision, etc.).

---

## Key Interaction Principles

1. **Reproduce before innovate** — Never skip baseline reproduction
2. **Log everything** — Every iteration, every failure, every fix
3. **Git frequently** — Commit at every milestone; never squash local experiment commits
4. **Venv always** — Never install packages globally on the server
5. **Numbers must match** — Reproduced baselines within tolerance before proceeding
6. **Beat all baselines** — Our method must win on all datasets before reporting
7. **Prove every claim** — Every non-trivial claim must have a dedicated claim-proof experiment
8. **Expand comparison coverage** — Mine baselines' comparison tables to add SOTA methods and datasets
9. **Track progress** — Update state.md at every job boundary; report ETA when asked
10. **Reports serve two audiences** — HTML for quick review, MD (EN + CN) for paper writing
11. **Never store secrets** — Sudo password in session memory only
12. **Ask when stuck** — 5 iterations for baselines, 10 for our method, then escalate
13. **Download results locally** — Keep `experiment/figures/` synced for reports
14. **Respect machine limits** — Always check resources before launching jobs; never saturate the server (see Appendix F)

---

## Reference Files

These files are co-located with this skill. Try paths in order until one succeeds:
- **Project install:** `.claude/skills/paperclaw-experiment-AI/references/`
- **Global install:** `~/.claude/skills/paperclaw-experiment-AI/references/`

Load on demand:
- `<ref-dir>/domain.md` — target venue standards, experiment expectations, and resource estimates
- `<ref-dir>/reproduction-guide.md` — common reproduction pitfalls, tolerance table, and when-to-give-up criteria
- `<ref-dir>/report-template.md` — Report.md section structure and writing guide (7 required sections)
- `<ref-dir>/report-html-template.html` — HTML/CSS template for Report.html and Report_cn.html
