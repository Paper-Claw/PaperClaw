---
name: paperclaw-AI-ideation
description: Use when the user wants to "brainstorm a research idea", "polish a paper idea", "find a research direction", "identify research gaps", "start a new project", "check if my idea can get into a top conference", or shares any raw research concept that needs refinement. Runs an auto-pilot loop of literature search → synthesis → auto-decision → refinement until the idea reaches top-conference publication quality (target venues defined in references/domain.md). Produces a complete Proposal with all auto-decisions logged for user review. Supports re-running with user overrides.
version: 1.0.0
---

# Research Ideation — Iterative Idea Polishing Loop

An **auto-pilot**, literature-driven loop that takes a raw research spark and refines it through repeated cycles of search, synthesis, and autonomous decision-making until it reaches top-conference publication quality (target venues defined in `references/domain.md`). The entire pipeline runs without user interaction — the user reviews the finished Proposal and can override any auto-decision by re-running.

## Core Principle

**Do NOT generate a final research proposal until the idea passes the Conference Readiness Gate.**
Every loop iteration ends with a readiness score. If the idea is not ready, identify the weakest dimension and loop back with a targeted improvement task. All decisions are made autonomously and logged to `./ideation/questions.md` for post-hoc user review.

---

## Workflow Overview

```
Raw Idea
  │
  ▼
[Phase 0] Capture            — Field Survey + auto-infer 5W1H from raw idea
  │                            (no user Q&A — decisions logged to questions.md)
  ▼
[Phase 1] Literature Probe   — Quick scan: 10-15 papers, map the landscape
  │
  ▼
[Phase 2] Synthesis Report   — Identify gaps, propose 2-3 directions
  │
  ▼ (always triggers — no user choice needed)
[Phase 2.5] Feasibility Scout — Quick-check all directions (2-3 searches each)
  │                             Auto-select best feasibility profile
  ▼
[Phase 3] Deep Dive           — 20-30 focused papers, detailed gap analysis
  │
  ▼
[Phase 4] Sharpen             — SMART RQ, theory, Lean 4 verify, method design, experiment plan
  │                             ├─ Lean 4 PASS → continue to Method Design
  │                             ├─ Lean 4 FAIL (fixable) → retry Step 2 (max 5)
  │                             └─ Lean 4 FAIL (fundamental) → escalate to earlier phase
  ▼
[Gate]  Conference Readiness Check (Novelty / Significance / Soundness / Feasibility)
  │
  ├─ NOT READY → auto loop back (max 4 iterations)
  │
  └─ READY → generate full Research Proposal (with Section 9: Alternative Directions)
```

Persist loop state to `./ideation/state.md` so the session can be resumed.
All auto-decisions are logged to `./ideation/questions.md` for post-hoc review.

---

## Auto-Pilot Mode

This skill runs in **auto-pilot by default**: the entire pipeline executes without calling `AskUserQuestion`. Every decision point that previously required user input is now handled autonomously and logged to `./ideation/questions.md`.

### Auto-Decision Priority

When choosing between options, apply this priority order:
1. **Feasibility** — can we actually execute this with available data, compute, and code?
2. **Significance** — does solving this matter to the community?
3. **Low risk** — avoid directions with concurrent work overlap or missing baselines
4. **Novelty** — prefer fresher angles, but not at the expense of feasibility

### What Gets Auto-Decided

| Decision Point | Original Behavior | Auto-Pilot Behavior |
|---------------|-------------------|---------------------|
| Phase 0 Q&A | Ask user 5W1H one-by-one | Auto-infer from raw idea + field survey |
| Phase 0 summary confirmation | Wait for user OK | Auto-proceed, log to questions.md |
| Phase 2 direction choice | AskUserQuestion with options | Always trigger Phase 2.5 Feasibility Scout |
| Phase 2.5 confirmation | Wait for user to confirm recommendation | Auto-select best feasibility profile |
| Phase 4 RQ/method confirmation | AskUserQuestion | Auto-proceed, log to questions.md |
| Phase 4 Lean 4 verification | N/A (new) | Auto-retry on failure (max 5), auto-escalate if fundamental flaw |
| Gate decision | Ask user to iterate or accept | Auto loop-back if NOT READY (max 4 iterations) |

### Resume with User Overrides

After reviewing the Proposal and `./ideation/questions.md`, the user can re-invoke this skill with override instructions:

```
"重新运行 ideation，修改决策 #2 为 Direction B"
"Re-run ideation, override decision #3: use contrastive learning instead"
```

**Override protocol:**
1. Read `./ideation/questions.md` — load all prior auto-decisions
2. Apply user overrides to the specified decision numbers
3. Determine the **earliest affected phase** (e.g., overriding direction → Phase 2)
4. Re-run from that phase forward, keeping unaffected prior decisions
5. Regenerate all three Proposal files with updated Section 9

---

## Tool Usage by Phase

| Phase | Tool | Purpose |
|-------|------|---------|
| Phase 0 | `WebSearch` | Field survey — dominant paradigms, key labs, breakthroughs, open problems |
| Phase 0 | (text output) | Background Briefing — educate user on field landscape |
| Phase 0 | `Write` | Auto-infer 5W1H, log decisions to `./ideation/questions.md` |
| Phase 1 | `WebSearch` | Search databases listed in `references/domain.md` for 10-15 papers |
| Phase 2 | `Write` | Log 2-3 proposed directions and trade-offs to `./ideation/questions.md` |
| Phase 2.5 | `WebSearch` | Feasibility Scout — quick-check all directions (always triggered) |
| Phase 2.5 | `Write` | Log feasibility comparison and auto-selected direction to `./ideation/questions.md` |
| Phase 3 | `WebSearch` | Deep search for 20-30 focused papers on the chosen direction |
| Phase 4 | `WebSearch` | Search for theoretical tools, proof techniques, and related formal analysis |
| Phase 4 | `Bash` | Install Lean 4 locally via elan (if not present); run `lake build` to verify proofs |
| Phase 4 | `Write` | Generate `.lean` files in `./ideation/lean4/`; log verification results to questions.md |
| Phase 4 | `Write` | Log SMART RQ and method design decisions to `./ideation/questions.md` |
| Gate | `Write` | Log score card and loop-back decision to `./ideation/questions.md` |
| Proposal | `Write` | Generate `./Proposal.md`, `./Proposal.html`, `./Proposal_cn.html` |
| All | `TodoWrite` | Track current phase and progress within each phase |

**WebSearch best practices:**
- Construct queries using Boolean operators (see `references/literature-search-strategies.md`)
- Run 3-5 searches per phase with different keyword combinations
- Prioritize top-venue papers from the last 3 years
- Extract paper title, venue, year, and core claim from search results
- Record all papers found in `./ideation/papers.md` to avoid duplicate searches

---

## Two Persistent Mental Frameworks

These two frameworks apply at **every phase**, not just Phase 0. Revisit them actively after each new piece of evidence (a paper, a user answer, a gate score).

### 5W1H — Continuously Updated

The 5W1H is not a one-time questionnaire. Treat it as a living model of the idea that gets sharper with each iteration:

| Dimension | What to re-examine after new evidence |
|-----------|--------------------------------------|
| **What** | Is the problem statement still precise? Did new papers reveal a better framing? |
| **Why** | Is the motivation still the strongest available? Did we find a more compelling failure case? |
| **Who** | Has the target community or application user changed with the chosen direction? |
| **When** | Is there new concurrent work that changes the timing? |
| **Where** | Has the domain or application scenario become more or less promising? |
| **How** | Is the method intuition still the best fit given what we now know from the literature? |

If any dimension weakens after new evidence, flag it explicitly and address it before moving to the next phase.

### First Principles Thinking — Always On

At every decision point, strip away assumptions and reason from fundamentals:

1. **Decompose the problem** — break the research question into its most basic components. What is the core tension or trade-off that makes this hard?
2. **Challenge inherited assumptions** — question every "everyone does it this way" claim. Why does the field use this method? Is the reason still valid?
3. **Rebuild from scratch** — given only the fundamental constraints (data, compute, physics, math), what is the most natural solution? Compare it to what the field actually does.
4. **Identify the real bottleneck** — what is the single constraint that, if removed, would make this problem trivial? That constraint is often the most valuable thing to attack.
5. **Avoid analogy-driven reasoning** — "this worked in domain X so it should work here" is a hypothesis, not a justification. Ground every claim in first principles before committing to a direction.

---

## Phase 0: Capture the Spark

**Goal:** Understand the raw idea well enough to search meaningfully. Do a field survey first, then present a background briefing, then auto-infer all 5W1H dimensions.

### Step 0 — Field Survey (silent research, before any user interaction)

Before posing the first question, run 3-5 fast WebSearch queries to build a solid grasp of the field:
- What are the dominant paradigms and open problems in this area?
- Who are the key labs and recurring authors?
- What are the most-cited benchmarks or datasets?
- What recent breakthroughs or trend shifts have occurred (last 1-2 years)?
- What are the main unsolved challenges the community is actively working on?

Example search queries — see `references/domain.md` "Example Search Queries" section for domain-appropriate templates.

### Step 1 — Background Briefing (MUST present to user before auto-inference)

**This step is mandatory.** After completing the field survey, write and present a structured background briefing to the user. The briefing educates the user on the current state of the field and provides context for the auto-inferred decisions that follow. The briefing should be written in the user's language and cover:

```markdown
## 🔍 Field Background Briefing: [Topic Area]

### Current Landscape
[2-3 paragraphs summarizing: What is this field about? What are the dominant approaches?
What has been achieved so far? Include specific method names, key papers, and performance
numbers where available.]

### Key Players & Venues
[Which research groups/labs are leading this area? Which conferences/journals publish
the most relevant work? List 3-5 key groups with their focus areas.]

### Recent Breakthroughs (Last 1-2 Years)
[What has changed recently? Any paradigm shifts, new datasets, new capabilities?
Highlight 2-3 specific papers or developments that reshaped the field.]

### Open Challenges & Active Debates
[What problems remain unsolved? Where does the community disagree?
List 3-5 concrete open questions, each with a brief explanation of why it matters.]

### Where Your Idea Fits (Initial Impression)
[Based on what you've shared so far, here's where your idea sits relative to the
landscape above. This is a preliminary assessment — we'll refine it together.]
```

**Briefing quality requirements:**
- Must be **substantive and educational**, not a vague overview — include specific paper names, method names, numbers, and dates
- Must help the user understand the field well enough to answer the follow-up questions intelligently
- Must explicitly connect the user's raw idea to the landscape (the "Where Your Idea Fits" section)
- Length: 400-800 words (enough to be informative, not so long it's overwhelming)

After presenting the briefing, proceed immediately to auto-inference (no pause needed in auto-pilot mode).

### Step 2 — Auto-Infer 5W1H (no user interaction)

**In auto-pilot mode, do NOT call `AskUserQuestion`.** Instead, infer all 5W1H dimensions from the raw idea + field survey results.

**Auto-inference rules:**
- For each 5W1H dimension, synthesize the best answer from: (1) the user's raw idea text, (2) the field survey findings, (3) common sense about the research landscape
- Mark each inference with a **confidence level** (High / Medium / Low) — Low confidence items are flagged as priority override candidates
- Use field survey findings to fill gaps — e.g., if the user didn't specify a target venue, infer from the topic area; if no method preference, infer from dominant paradigms
- Prefer conservative, feasible choices when information is ambiguous

**5W1H checklist** (continuously revisited throughout all phases — see below):

| Dimension | Core Question | Auto-Inference Source |
|-----------|--------------|---------------------|
| **What** | What problem or phenomenon to study? | User's raw idea + field survey open problems |
| **Why** | Why does this problem matter? | Field survey: community interest, active debates, practical impact |
| **Who** | Target community and application users? | Infer from topic → most relevant top venue (see `references/domain.md`) |
| **When** | Timing context? | Field survey: recent breakthroughs, new capabilities, trending topics |
| **Where** | Domain or application scenario? | User's raw idea + field survey: standard benchmarks and datasets |
| **How** | Method or technical approach? | Field survey: dominant paradigms + identified gaps → most promising approach |

**Log to `./ideation/questions.md`:** For each 5W1H dimension, record the question, context, auto-inferred answer, reasoning, and confidence level.

**Output of Phase 0:** A 1-paragraph idea summary presented to the user as text output, then auto-proceed to Phase 1.

**Output quality checklist:**
- [ ] All 6 dimensions (What/Why/Who/When/Where/How) are addressed, even if some are tentative
- [ ] The summary is specific enough to generate meaningful search queries
- [ ] Each auto-inference is logged to `./ideation/questions.md` with confidence level

---

## Phase 1: Literature Probe

**Goal:** Map the existing landscape quickly. Do not go deep yet — coverage matters more than depth.

**Search targets:**
- Databases and arXiv categories listed in `references/domain.md` (choose based on topic)
- Semantic Scholar for citation counts and influential papers
- Top-venue proceedings listed in `references/domain.md` (last 3 years)

**Search strategy:**
1. Extract 2-4 core concept pairs from Phase 0 summary
2. Build keyword variants (see `references/literature-search-strategies.md`)
3. Run 3-5 targeted searches; collect 10-15 most relevant papers
4. Skim abstracts and conclusions — do NOT read full papers at this stage

**Produce a Landscape Table:**

| Paper | Venue/Year | TLDR | Core Claim | Method | Key Limitation |
|-------|-----------|------|------------|--------|---------------|
| ... | ... | ... | ... | ... | ... |

Present this table to the user as Phase 1 output before continuing.

**Output quality checklist:**
- [ ] Landscape table contains 10-15 papers (or 5-8 for niche topics — see `references/iteration-loop.md`)
- [ ] Papers span the last 3 years and include recent SOTA
- [ ] At least 2 different method families are represented
- [ ] Key limitations column is filled for every paper (not just "N/A")

---

## Phase 2: Synthesis & Direction Proposals

**Goal:** Identify gaps and propose 2-3 concrete research directions.

**Gap analysis** (use `references/gap-analysis-guide.md`):
- Literature gaps: topics not yet studied
- Methodological gaps: common limitations across all existing methods
- Application gaps: theory-to-practice transfer opportunities
- Temporal gaps: new capabilities or demands not yet addressed

**Proposal format (from brainstorming skill):**
Always propose **exactly 2-3 directions** with explicit trade-offs. Lead with your recommended option and explain why. Never commit to one direction without presenting alternatives.

```
Direction A: [Title]
  Core claim: ...
  Key insight: ...
  Why it could work: ...
  Main risk: ...
  Estimated novelty: High / Medium
  Estimated difficulty: Hard / Medium / Easy
  Feasibility signals: [known public datasets? reproducible baselines? compute estimate?]

Direction B: [Title]
  ...

Direction C: [Title]
  ...

My recommendation: Direction [X], because ...
```

**Auto-pilot behavior:** After proposing 2-3 directions, **always proceed to Phase 2.5 Feasibility Scout** to validate all directions before committing. Do NOT call `AskUserQuestion`. Log the proposed directions and their trade-offs to `./ideation/questions.md`.

**Output quality checklist:**
- [ ] Exactly 2-3 directions proposed (not 1, not 4+)
- [ ] Each direction has explicit trade-offs (risk vs. reward, novelty vs. feasibility)
- [ ] Each direction includes feasibility signals (datasets, baselines, compute)
- [ ] A clear recommendation is given with reasoning
- [ ] Gap analysis references specific papers from Phase 1 landscape table
- [ ] All directions and trade-offs are logged to `./ideation/questions.md`

---

## Phase 2.5: Feasibility Scout (always triggered in auto-pilot)

**Trigger:** Always runs after Phase 2 in auto-pilot mode. This replaces the previous user choice step.

**Goal:** Quickly validate the feasibility of all 2-3 proposed directions before committing to the expensive Phase 3 deep-dive. Auto-select the direction with the best feasibility-significance profile.

**For each proposed direction, run 2-3 targeted WebSearches to check:**
1. **Dataset availability** — Are there public, commonly-used datasets for this direction? Are they accessible?
2. **Baseline reproducibility** — Do the key baseline papers have open-source code? Can results be reproduced?
3. **Concurrent work risk** — Are there very recent papers (< 3 months) that closely overlap this direction?
4. **Compute/resource fit** — Does this direction require resources beyond what is typical for the domain? (See `references/domain.md` "Resource Estimates" for thresholds.)

**Produce a Feasibility Comparison Table:**

```markdown
## Feasibility Scout Results

| Dimension | Direction A | Direction B | Direction C |
|-----------|------------|------------|------------|
| Public datasets | ✅ 3 datasets (X, Y, Z) | ⚠️ 1 dataset, proprietary | ✅ 2 datasets (X, Y) |
| Baselines with code | ✅ 4/5 have code | ❌ 1/5 have code | ✅ 3/5 have code |
| Concurrent work risk | ⚠️ 1 recent overlap | ✅ Low | ✅ Low |
| Compute feasibility | ✅ Within budget | ❌ Exceeds budget | ✅ Within budget |
| **Quick Score** | **★★★★☆** | **★★☆☆☆** | **★★★★☆** |

**Recommendation:** Direction [X], because it has the best feasibility profile: [specific reasoning].
**Runner-up:** Direction [Y] is also viable but carries risk in [dimension].
**Eliminated:** Direction [Z] has a critical blocker: [specific issue].
```

**Auto-pilot behavior after producing the table:**
- **Auto-select** the direction with the best feasibility profile, prioritizing: feasibility > significance > low concurrent-work risk > novelty
- Log the full Feasibility Comparison Table, the selected direction, runner-up, and eliminated directions to `./ideation/questions.md`
- Proceed directly to Phase 3 with the selected direction

**Output quality checklist:**
- [ ] All proposed directions are scouted (not just the recommended one)
- [ ] Each feasibility dimension has specific evidence (paper names, dataset names, code links), not just ✅/❌
- [ ] A clear recommendation is given with reasoning tied to the feasibility findings
- [ ] Full comparison table and selection rationale are logged to `./ideation/questions.md`

**Cost budget:** ~6-9 WebSearches total (2-3 per direction). This is much cheaper than a full Phase 3 deep-dive (20-30 papers) on the wrong path.

---

## Phase 3: Deep Dive

**Goal:** Build a thorough literature foundation for the chosen direction.

**Search targets:** 20-30 papers specifically on the chosen direction.

**Deliverables:**
1. **Comparison matrix** — methods, datasets, metrics, limitations side-by-side
2. **Gap card** — one paragraph precisely stating the gap this work will fill
3. **Baseline candidates** — 3-5 papers the proposed method must outperform

Save to `./ideation/literature.md`.

**Output quality checklist:**
- [ ] 20-30 papers collected, focused specifically on the chosen direction
- [ ] Comparison matrix covers methods, datasets, metrics, and limitations
- [ ] Gap card is specific enough to directly inform a Related Work section
- [ ] 3-5 baseline candidates identified with available code/reproducible results

---

## Phase 4: Sharpen the Research Question

**Goal:** Produce a precise, SMART research question, a theoretical foundation, and a detailed experimental plan.

### Step 1 — SMART Research Question

Use `references/research-question-formulation.md`:
- **Specific**: name the method, task, and scenario explicitly
- **Measurable**: name the datasets and evaluation metrics
- **Achievable**: check resource and time feasibility
- **Relevant**: articulate academic and practical value
- **Time-bound**: estimate 3-month and 6-month milestones

### Step 2 — Problem Formalization & Theoretical Analysis

Formalize the research problem mathematically and build theoretical justification for the proposed approach. Save to `./ideation/theory.md`.

**Required content:**
1. **Problem formalization** — define the problem with precise mathematical notation (input space, output space, objective function, constraints)
2. **Mathematical model** — formulate the proposed approach as a formal optimization or learning problem
3. **Theoretical justification** — prove or argue why the proposed solution is superior to existing methods. Include any of the following that apply:
   - Theorems with proofs (e.g., convergence guarantees, approximation bounds)
   - Generalization bounds (PAC-learning, Rademacher complexity, etc.)
   - Convergence rate analysis (optimization perspective)
   - Computational complexity analysis
   - Information-theoretic arguments (lower bounds, capacity)
4. **Key assumptions** — explicitly state all assumptions required for the theoretical results to hold

### Step 2.5 — Lean 4 Formal Verification

After generating `./ideation/theory.md`, formally verify key theoretical claims using Lean 4. This step creates a hard gate: if the core theorems cannot be machine-verified, the pipeline must fix the theory before proceeding to method design.

#### 2.5.1 — Local Lean 4 Environment Setup

All Lean 4 toolchains and binaries are kept **inside the project** to avoid polluting the global system.

**First-time setup** (skip if `./ideation/lean4/.elan/bin/lean` already exists):

1. Set local elan home and install elan locally:
   ```bash
   export ELAN_HOME="$(pwd)/ideation/lean4/.elan"
   curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | ELAN_HOME="$(pwd)/ideation/lean4/.elan" sh -s -- -y --default-toolchain none
   export PATH="$(pwd)/ideation/lean4/.elan/bin:$PATH"
   ```
2. Initialize the Lean 4 project:
   ```bash
   mkdir -p ./ideation/lean4 && cd ./ideation/lean4
   echo "leanprover/lean4:v4.18.0-rc1" > lean-toolchain
   lake init IdeationProofs
   ```
3. If Mathlib is needed (determined in step 2.5.3), add it to `lakefile.lean` and run:
   ```bash
   cd ./ideation/lean4 && lake update && lake exe cache get
   ```

**On subsequent runs:** Check `./ideation/lean4/.elan/bin/lean --version`. If present, just set `ELAN_HOME` and `PATH`, skip installation.

**All Bash commands in this step MUST prefix with:**
```bash
export ELAN_HOME="$(pwd)/ideation/lean4/.elan" && export PATH="$(pwd)/ideation/lean4/.elan/bin:$PATH" &&
```

#### 2.5.2 — Identify Formalizable Claims

Scan `./ideation/theory.md` and classify each theoretical claim:

| Claim Type | Formalizable? | Example |
|-----------|--------------|---------|
| Convergence theorem | Yes | "Algorithm A converges at rate O(1/t)" |
| Approximation bound | Yes | "Error ≤ epsilon for all inputs in class C" |
| Algebraic property | Yes | "Operator T is a contraction mapping" |
| Complexity bound | Yes | "Algorithm runs in O(n log n)" |
| Generalization bound | Partially | PAC bounds — structure formalizable, constants may need sorry |
| Empirical claim | No | "Method X outperforms Y on dataset Z" |
| Intuitive argument | No | "This should work because..." |

**Rules:**
- Only formalize claims marked "Yes" or "Partially"
- For "Partially" formalizable: formalize structure, use `sorry` for empirical sub-goals, document why
- If NO claims are formalizable (purely empirical work) → skip this step, log skip decision to `./ideation/questions.md`, proceed to Step 3

#### 2.5.3 — Generate Lean 4 Code

For each formalizable claim, create a `.lean` file in `./ideation/lean4/IdeationProofs/`:

**File naming:** `Theorem1.lean`, `Theorem2.lean`, etc. — one file per major theorem/proposition.

**Code structure:**
```lean
/-
  Theorem: [name from theory.md]
  Source: theory.md, Section [N]
  Claim: [natural language statement]
-/
import Mathlib.Topology.MetricSpace.Basic  -- import as needed

-- Definitions
def [relevant_definitions] := ...

-- Main theorem
theorem [theorem_name] : [formal_statement] := by
  [proof_tactics]
```

**Guidelines:**
- Import from Mathlib for standard math objects (metric spaces, norms, probability, measure theory)
- Prefer simple tactic proofs (`simp`, `ring`, `omega`, `linarith`, `norm_num`) over term-mode
- Every `sorry` must have a comment explaining why it cannot be proven at this stage
- Register new files in `./ideation/lean4/IdeationProofs.lean` (the root file that imports all modules)

#### 2.5.4 — Compile and Check

```bash
export ELAN_HOME="$(pwd)/ideation/lean4/.elan" && export PATH="$(pwd)/ideation/lean4/.elan/bin:$PATH" && cd ./ideation/lean4 && lake build
```

**Bash timeout:** 300000ms (5 minutes). First build with Mathlib can be slow.

#### 2.5.5 — Result Classification

| Result | Classification | Action |
|--------|---------------|--------|
| Build succeeds, no sorry | **FULL PASS** | Proceed to Step 3. Log success to questions.md. |
| Build succeeds, sorry on empirical sub-goals only | **PARTIAL PASS** | Proceed to Step 3. Log sorry'd items to questions.md. |
| Build fails: type mismatch / tactic failure | **Proof Error** | Analyze error → retry (counts toward limit). |
| Build fails: unknown identifier / import error | **Syntax Error** | Fix imports/definitions → retry (does NOT count toward limit). |
| Build fails: timeout / OOM | **Resource Error** | Simplify theorem → retry (counts toward limit). |

#### 2.5.6 — Retry Logic

**Max retries:** 5 proof-error attempts per gate iteration. Track in `./ideation/state.md` as `Lean4Attempt: N`.

**On Proof Error (counts toward limit):**
1. Parse Lean 4 error — identify which theorem and proof step failed
2. Diagnose:
   - **Wrong proof strategy** → rewrite tactics, keep theorem statement
   - **Wrong theorem statement** → theory.md claim may be incorrect → update theory.md, regenerate .lean
   - **Missing lemma** → add intermediate lemma and retry
3. Log error, diagnosis, and fix plan to `./ideation/questions.md`
4. Retry from step 2.5.3

**On Syntax Error (does NOT count toward limit):** Fix and retry immediately.

**After 5 failed attempts:**
- If theorem *statement* kept changing across attempts → theory may be unsound → **escalate** (see 2.5.7)
- If only proof *strategy* failed but statement seems correct → proceed to Step 3 with soundness penalty flag

#### 2.5.7 — Escalation (Fundamental Flaw Detected)

If 5 retries reveal the **approach itself is flawed** (not just a proof difficulty):
1. Log to questions.md: "Lean 4 verification revealed fundamental flaw: [description]"
2. Set `Lean4Escalation: true` in `./ideation/state.md`
3. Do NOT proceed to Step 3. Instead loop back to:
   - **Phase 4 Step 2** — if formalization needs rethinking (weaken assumptions, change bounds)
   - **Phase 3** — if gap analysis needs revision (the approach itself is wrong)
   - **Phase 2** — if the direction is fundamentally unsound
4. This escalation is separate from the Gate loop-back — it happens within Phase 4 itself

### Step 3 — Method Design

Describe the proposed method in detail. This should be concrete enough to serve as a blueprint for implementation:
- Architecture or algorithm overview (with pseudocode or diagram if applicable)
- Key components and their roles
- Training/inference procedure
- How the method addresses the identified gap

### Step 4 — Experimental Plan

Design a comprehensive experimental plan:
- Datasets (with sizes, splits, preprocessing)
- Baselines to compare against (with citations)
- Evaluation metrics (primary and secondary)
- Experiments to conduct:
  - Main comparison with SOTA
  - Ablation studies (which components contribute how much)
  - Analysis experiments (visualization, case studies, sensitivity analysis)
- Expected results (what does "better" look like, quantitatively?)

**Output quality checklist:**
- [ ] Research question satisfies all 5 SMART dimensions
- [ ] Problem is formally defined with mathematical notation
- [ ] At least one theoretical result (theorem, bound, or formal argument) is provided
- [ ] Formalizable claims from theory.md are identified and classified
- [ ] Lean 4 project exists in `./ideation/lean4/` (or skip justified for purely empirical work)
- [ ] All formalizable theorems have corresponding `.lean` files
- [ ] `lake build` passes (full or partial pass with documented sorry items)
- [ ] Every Lean 4 attempt is logged to `./ideation/questions.md`
- [ ] Method description names specific techniques with enough detail for implementation
- [ ] At least 1 dataset and 1 metric are named explicitly
- [ ] Experimental plan includes main comparison, ablation, and analysis experiments
- [ ] Expected result is quantifiable or clearly falsifiable

---

## Conference Readiness Gate

Evaluate the current idea state on four dimensions. Score each 1-5.

**Scoring rubric** (detailed in `references/conference-readiness.md`):

| Dimension | Score | What to Check |
|-----------|-------|---------------|
| **Novelty** | /5 | Is the core insight new? Does it challenge or go beyond SOTA? |
| **Significance** | /5 | Do top-venue researchers care? Is the problem important enough? |
| **Technical Soundness** | /5 | Is the method theoretically grounded? Are claims testable? |
| **Experimental Feasibility** | /5 | Can experiments be run with available compute and data? |

**Readiness threshold:** Total ≥ 16/20, with no single dimension below 3.

**Lean 4 Verification Factor (adjusts Technical Soundness score):**
- FULL PASS (no sorry): Soundness +1 (cap at 5)
- PARTIAL PASS (sorry only on empirical sub-goals): no adjustment
- Skipped (no formalizable claims): no adjustment
- FAIL after 5 retries (proceeded anyway): Soundness -1 (floor at 1)
- Escalation triggered: Soundness automatically ≤ 2 (triggers loop-back)

**Gate outcome:**
- **READY (≥16, no dim <3):** Proceed to Research Proposal generation.
- **NOT READY:** Report the weakest dimension, explain what is missing, propose a targeted improvement task, and loop back:
  - Low Novelty → back to Phase 2 (find a sharper angle or different direction)
  - Low Significance → back to Phase 0/2 (reframe problem or switch domain)
  - Low Soundness → back to Phase 4 (strengthen the method sketch; if Lean 4 verification failed, re-examine theory.md and retry verification)
  - Low Feasibility → back to Phase 4 (adjust scope or resources)

**Auto-pilot gate behavior:**
- **READY:** Proceed directly to Proposal generation.
- **NOT READY:** Automatically loop back to the appropriate phase based on the weakest dimension. Log the gate score, weakest dimension, and loop-back decision to `./ideation/questions.md`.
- **Max 4 iterations:** If after 4 gate checks the idea still does not pass, generate the Proposal anyway with a caveat note in Section 9. Log all gate scores and the decision to proceed despite not passing.

Present the score card as text output (for the user to see in real-time) but do NOT wait for user input.

---

## Research Proposal Output

Generated only after passing the Conference Readiness Gate (or explicit user override).

**Three output files are produced:**

| File | Format | Language | Purpose |
|------|--------|----------|---------|
| `./Proposal.md` | Markdown | English | Source of truth, version-controlled |
| `./Proposal.html` | HTML | English | Readable standalone document with styling |
| `./Proposal_cn.html` | HTML | Chinese | Chinese translation for local collaboration |

All three files share the same 9-section structure (Sections 1-8 are content; Section 9 is the auto-pilot decision log). The HTML files should include basic CSS styling (clean typography, section numbering, table borders, math rendering via KaTeX CDN) for readability.

### Proposal Structure

```markdown
# Research Proposal: [Title]

## 1. Research Background
[Why this problem matters. Describe the real-world or scientific significance of the
problem. Include the broader context: what application domains are affected, what
consequences arise from the current limitations, and why now is the right time to
address this. Ground every claim in literature. Target: 2-3 paragraphs.]

## 2. Research Problem
[Formal problem definition. Start with an intuitive description, then formalize:
- Define the input space, output space, and objective
- State the problem mathematically (optimization, learning, inference)
- Clarify what "solving" this problem means — what constitutes success
- Highlight the key technical challenges that make this problem hard
Target: 1-2 paragraphs of intuition + formal mathematical definition.]

## 3. Related Work
[Structured survey of existing work organized by method family or theme.
For each group of related work:
- What they solve and how
- Their connection to the proposed problem
- What remains unsolved (the gap)
End with a clear statement of the research gap this proposal addresses.
Reference specific papers from ./ideation/papers.md and ./ideation/literature.md.
Target: 3-5 paragraphs covering 2-3 method families.]

## 4. Theoretical Analysis
[Mathematical foundation for the proposed approach.
- Formal mathematical model of the proposed solution
- Theorems with proofs (or proof sketches) showing why the approach works
- Theoretical advantages over existing methods (tighter bounds, better rates, etc.)
- Where applicable: generalization bounds, convergence rates, computational
  complexity, information-theoretic arguments
- Explicitly state all assumptions
Source: ./ideation/theory.md
Target: 1-3 theorems/propositions with proofs or proof sketches.]

## 5. Proposed Method
[Detailed technical description of the method.
- High-level overview (algorithm flow or architecture diagram in ASCII/text)
- Key components and their roles
- Training / inference procedure
- Pseudocode for the core algorithm (if applicable)
- How each component addresses a specific challenge from Section 2
Target: 3-5 paragraphs + pseudocode or algorithm block.]

## 6. Experimental Design
[Comprehensive experiment plan.

### 6.1 Datasets
| Dataset | Domain | Size | Split | Source |
|---------|--------|------|-------|--------|

### 6.2 Baselines
| Method | Venue/Year | Why included |
|--------|-----------|--------------|

### 6.3 Evaluation Metrics
- Primary: ...
- Secondary: ...

### 6.4 Experiments
| Experiment | Purpose | Expected Finding |
|-----------|---------|-----------------|
| Main comparison | Compare against SOTA | ... |
| Ablation study | Validate each component | ... |
| Sensitivity analysis | Robustness to hyperparameters | ... |
| Case study / Visualization | Qualitative understanding | ... |

### 6.5 Expected Results
[Quantitative predictions for main experiments. What margins of improvement
are expected and why?]]

## 7. Conclusion
[Highlight the key contributions and expected impact.
- Technical highlights (what is novel about the method)
- Expected experimental highlights (what results will be eye-catching)
- Broader impact and potential applications
- Limitations and future work
Target: 2-3 paragraphs, written to be compelling and memorable.]

## 8. Revision History
[Chronological record of major changes from project inception to final proposal.
Source: ./ideation/log.md

| Date | Iteration | Change Type | What Changed | Why | Outcome |
|------|-----------|-------------|-------------|-----|---------|
| YYYY-MM-DD | N | Direction pivot / Scope change / Method revision / ... | [description] | [reason] | [result] |
]

## 9. Alternative Directions & Auto-Decisions
[This section is generated from ./ideation/questions.md. It provides full
transparency into every autonomous decision made during the ideation process.]

### Decision Log

| # | Phase | Question | Context | Auto-Choice | Reasoning | Confidence |
|---|-------|----------|---------|-------------|-----------|------------|
| 1 | Phase 0 | What problem? | [field survey context] | [auto-inferred] | [why] | High/Med/Low |
| 2 | Phase 0 | Why important? | [field survey context] | [auto-inferred] | [why] | High/Med/Low |
| ... | ... | ... | ... | ... | ... | ... |
| N | Phase 2.5 | Direction | [feasibility scout results] | Direction X | [feasibility reasoning] | High |

### Explored but Not Chosen

#### Direction [Y]: [Title]
- Core claim: ...
- Feasibility profile: ...
- Why not chosen: ...
- Under what conditions it becomes better: ...

#### Direction [Z]: [Title]
- ...

### How to Override
To modify any decision, re-invoke this skill with instructions like:
- "重新运行 ideation，修改决策 #N 为 [你的选择]"
- "Re-run ideation, override decision #N: [your choice]"

The pipeline will re-run from the earliest affected phase forward.

---

## Appendix

### A. Conference Readiness Score
Novelty: X/5 | Significance: X/5 | Soundness: X/5 | Feasibility: X/5
Total: XX/20

### B. Timeline
- Month 1-2: ...
- Month 3-4: ...
- Month 5-6: ...

### C. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
```

---

## Persistent State & Log

All session data lives under `./ideation/`:

```
./ideation/
├── state.md      ← current snapshot, overwritten after every phase
├── log.md        ← append-only history of every attempt and score
├── papers.md     ← append-only index of all papers ever retrieved
├── literature.md ← structured analysis notes from Phase 3 deep dive
├── theory.md     ← problem formalization and theoretical analysis from Phase 4
├── questions.md  ← auto-pilot decision log (append-only) — source for Proposal Section 9
└── lean4/                ← Lean 4 formal verification project
    ├── .elan/            ← local elan installation (toolchains, binaries — NOT committed to git)
    ├── lean-toolchain
    ├── lakefile.lean
    ├── IdeationProofs.lean
    └── IdeationProofs/
        ├── Basic.lean
        ├── Theorem1.lean
        └── ...

./Proposal.md      ← final proposal (English, Markdown) — written only after Gate passes
./Proposal.html    ← final proposal (English, styled HTML with KaTeX)
./Proposal_cn.html ← final proposal (Chinese, styled HTML with KaTeX)
```

**At session start:** read `./ideation/state.md` to resume from the correct phase and iteration. Also read `./ideation/papers.md` to know which papers have already been retrieved — do not re-search or re-summarize papers already recorded there.

---

### papers.md — Append-Only Paper Index

Append new papers as they are found in each phase. Never overwrite existing entries. The TLDR column should be a one-sentence summary of what the paper studies/proposes.

```markdown
# Papers Index

## Phase 1: Literature Probe

| Paper | Venue/Year | TLDR | Core Claim | Method | Key Limitation |
|-------|-----------|------|------------|--------|---------------|
| ... | ... | ... | ... | ... | ... |

## Phase 3: Deep Dive

| Paper | Venue/Year | TLDR | Core Claim | Method | Key Limitation |
|-------|-----------|------|------------|--------|---------------|
| ... | ... | ... | ... | ... | ... |
```

---

### state.md — Current Snapshot

Overwrite this file after every phase transition. It always reflects the latest state.

```markdown
# Ideation State

**Idea:** [one-line summary]
**Phase:** [0 / 1 / 2 / 2.5 / 3 / 4 / Gate / Done]
**Iteration:** [N]
**Direction:** [chosen direction title, or "TBD"]
**Last Score:** N: X/5 | S: X/5 | T: X/5 | F: X/5 | Total: XX/20  (or "-" if not yet scored)
**Lean4Status:** [not_started / in_progress / pass / partial_pass / fail / skipped / escalated]
**Lean4Attempt:** [0-5]
**Lean4Escalation:** [true / false]
**Next Action:** [what to do when this session resumes]
**Updated:** [YYYY-MM-DD]
```

---

### log.md — Append-Only History

Append one entry per completed phase or gate check. Never overwrite. This is the full audit trail and the source for the Revision History section (Section 8) of the final proposal.

```markdown
# Ideation Log

## [YYYY-MM-DD] Iteration N — Phase X

**Summary:** [one sentence describing what was done this phase]

### Literature / Directions Explored
- [paper or direction title]: [key finding or trade-off]
- ...

### Problems Identified
- [problem 1]: [why it's a problem]
- [problem 2]: ...

### Key Decisions & Changes
[Record every significant change — direction pivots, scope adjustments, method revisions, problem reframing. This feeds Section 8 (Revision History) of the final proposal.]

| Change Type | What Changed | Why | Outcome |
|-------------|-------------|-----|---------|
| [Direction pivot / Scope change / Method revision / Problem reframing / ...] | [description] | [reason] | [result] |

### Gate Score (if this was a Gate check)
| Dimension | Score | Reason |
|-----------|-------|--------|
| Novelty | X/5 | [one-line justification] |
| Significance | X/5 | [one-line justification] |
| Soundness | X/5 | [one-line justification] |
| Feasibility | X/5 | [one-line justification] |
| **Total** | **XX/20** | [READY / NOT READY] |

**Weakest dimension:** [name]
**Decision:** [what was chosen — direction, fix, pivot, or "proceed"]

---
```

---

### questions.md — Auto-Pilot Decision Log

Append new decisions as they are made in each phase. Never overwrite existing entries. This file is the source for Section 9 of the Proposal.

```markdown
# Auto-Pilot Decision Log

## Decision #1 — Phase 0: Problem Definition (What)
**Question:** What specific problem does this research address?
**Context:** [field survey findings relevant to this dimension]
**Auto-Choice:** [inferred answer]
**Reasoning:** [why this inference, based on what evidence]
**Confidence:** High / Medium / Low

---

## Decision #2 — Phase 0: Motivation (Why)
**Question:** Why does this problem matter?
**Context:** [field survey findings on community interest, practical impact]
**Auto-Choice:** [inferred answer]
**Reasoning:** [why]
**Confidence:** High / Medium / Low

---

## Decision #N — Phase 2.5: Research Direction
**Question:** Which research direction to pursue?
**Options:**
- A: [title + one-line summary + feasibility score]
- B: [title + one-line summary + feasibility score]
- C: [title + one-line summary + feasibility score]
**Context:** [Feasibility Comparison Table summary]
**Auto-Choice:** Direction [X]
**Reasoning:** [Best feasibility profile because: datasets available, baselines reproducible, low concurrent risk]
**Confidence:** High

---

## Decision #L — Phase 4: Lean 4 Verification (Attempt M/5)
**Question:** Do the key theoretical claims formally verify in Lean 4?
**Formalizable Claims:** [list of claims attempted]
**Result:** [FULL PASS / PARTIAL PASS / FAIL: error description]
**Sorry Items:** [list with justification, or "none"]
**Error Analysis:** [for failures: what went wrong, diagnosis, planned fix]
**Auto-Choice:** [Proceed to Step 3 / Retry with fix / Escalate to Phase N]
**Reasoning:** [why this choice]
**Confidence:** High / Medium / Low

---

## Decision #M — Gate: Iteration Loop-Back
**Question:** Iterate or proceed?
**Context:** [Gate score: N:X S:X T:X F:X = XX/20, weakest: dimension]
**Auto-Choice:** Loop back to Phase [N] / Proceed to Proposal
**Reasoning:** [weakest dimension analysis]
**Confidence:** High
```

---

## Key Interaction Principles

1. **Auto-pilot by default** — run the full pipeline without user interaction; do NOT call `AskUserQuestion`
2. **Log every auto-decision** — every decision that would have required user input must be recorded in `./ideation/questions.md` with question, context, auto-choice, reasoning, and confidence
3. **Always propose 2-3 options internally** — never commit to one path without considering alternatives; log all options even if only one is chosen
4. **Literature first, speculation second** — every claim must be grounded in papers
5. **First principles always on** — at every decision point, decompose to fundamentals, challenge inherited assumptions, and rebuild from scratch (see "Two Persistent Mental Frameworks" above)
6. **5W1H is a living model** — revisit all six dimensions after every new piece of evidence, not just in Phase 0
7. **Show scores at every gate** — present gate scores as text output (visible to user in real-time) but do not pause
8. **Feasibility-first selection** — when choosing between options, prioritize feasibility > significance > low risk > novelty
9. **YAGNI for scope** — cut any claim or experiment that is not needed to demonstrate the core insight
10. **Resume from state** — always check `./ideation/state.md` and `./ideation/questions.md` before starting; append to `./ideation/log.md` after every phase
11. **Language matching** — detect the language of the user's message and use that language throughout the entire response, including all generated documents (state.md, log.md, literature.md, theory.md, questions.md, Proposal.md, Proposal.html, Proposal_cn.html)
12. **Override support** — when re-invoked with override instructions, read `./ideation/questions.md`, apply overrides, and re-run from the earliest affected phase

---

## Reference Files

Load on demand:
- `references/domain.md` — **domain configuration** (target venues, databases, resource estimates, domain examples). Replace this file to adapt the skill for a different research domain.
- `references/iteration-loop.md` — detailed loop logic and loop-back decision tree
- `references/conference-readiness.md` — scoring rubrics, checklists, readiness decision tree
- `references/gap-analysis-guide.md` — 5 gap types, analysis dimensions, examples
- `references/5w1h-framework.md` — 5W1H framework for Phase 0
- `references/literature-search-strategies.md` — keyword construction and database search tips
- `references/research-question-formulation.md` — SMART criteria, question types, evaluation
