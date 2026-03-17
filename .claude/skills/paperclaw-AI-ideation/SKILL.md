---
name: paperclaw-AI-ideation
description: Use when the user wants to "brainstorm a research idea", "polish a paper idea", "find a research direction", "identify research gaps", "start a new project", "check if my idea can get into NeurIPS/ICML/ICLR", or shares any raw research concept that needs refinement. Runs an iterative loop of literature search → synthesis → user dialogue → refinement until the idea reaches top-conference publication quality.
version: 1.0.0
---

# Research Ideation — Iterative Idea Polishing Loop

An interactive, literature-driven loop that takes a raw research spark and refines it through repeated cycles of search, synthesis, and dialogue until it reaches top-conference (NeurIPS / ICML / ICLR / ACL / KDD) publication quality.

## Core Principle

**Do NOT generate a final research proposal until the idea passes the Conference Readiness Gate.**
Every loop iteration ends with a readiness score. If the idea is not ready, identify the weakest dimension and loop back with a targeted improvement task. Surface the score to the user at each checkpoint.

---

## Workflow Overview

```
Raw Idea
  │
  ▼
[Phase 0] Capture            — Understand the spark via 5W1H (one question at a time)
  │
  ▼
[Phase 1] Literature Probe   — Quick scan: 10-15 papers, map the landscape
  │
  ▼
[Phase 2] Synthesis Report   — Identify gaps, present landscape, propose 2-3 directions
  │
  USER CHOOSES DIRECTION ─── or ─── "All sound good" / no preference
  │                                        │
  │                                        ▼
  │                              [Phase 2.5] Feasibility Scout
  │                              Quick-check each direction (2-3 searches each)
  │                              Auto-select best feasibility profile
  │                                        │
  ◄────────────────────────────────────────┘
  │
  ▼
[Phase 3] Deep Dive           — 20-30 focused papers, detailed gap analysis
  │
  ▼
[Phase 4] Sharpen             — SMART RQ, theory, method design, experiment plan
  │
  ▼
[Gate]  Conference Readiness Check (Novelty / Significance / Soundness / Feasibility)
  │
  ├─ NOT READY → identify weakest dimension → loop back to Phase 2 or 3
  │
  └─ READY → generate full Research Proposal
```

Persist loop state to `./ideation/state.md` so the session can be resumed.

---

## Tool Usage by Phase

| Phase | Tool | Purpose |
|-------|------|---------|
| Phase 0 | `WebSearch` | Field survey — dominant paradigms, key labs, breakthroughs, open problems |
| Phase 0 | (text output) | Background Briefing — educate user on field landscape before Q&A |
| Phase 1 | `WebSearch` | Search arXiv, Semantic Scholar, Google Scholar for 10-15 papers |
| Phase 2 | `AskUserQuestion` | Present 2-3 directions with trade-offs for user choice (includes "All sound good" option) |
| Phase 2.5 | `WebSearch` | Feasibility Scout — quick-check each direction (2-3 searches each) when user has no preference |
| Phase 3 | `WebSearch` | Deep search for 20-30 focused papers on the chosen direction |
| Phase 4 | `WebSearch` | Search for theoretical tools, proof techniques, and related formal analysis |
| Phase 4 | `AskUserQuestion` | Confirm research question, theory, method, and experiment plan |
| Gate | `AskUserQuestion` | Present score card, ask whether to iterate or proceed |
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

**Goal:** Understand the raw idea well enough to search meaningfully. Do a field survey first, then present a comprehensive background briefing to the user before asking any questions.

### Step 0 — Field Survey (silent research, before any user interaction)

Before posing the first question, run 3-5 fast WebSearch queries to build a solid grasp of the field:
- What are the dominant paradigms and open problems in this area?
- Who are the key labs and recurring authors?
- What are the most-cited benchmarks or datasets?
- What recent breakthroughs or trend shifts have occurred (last 1-2 years)?
- What are the main unsolved challenges the community is actively working on?

Example search queries for a topic like "EEG-based emotion recognition":
- `"EEG emotion recognition" survey OR review 2024 2025`
- `"affective computing" EEG deep learning NeurIPS OR ICML OR ICLR`
- `"EEG decoding" benchmark dataset state-of-the-art`

### Step 1 — Background Briefing (MUST present to user before asking any questions)

**This step is mandatory.** After completing the field survey, write and present a structured background briefing to the user. The briefing educates the user on the current state of the field so they can make informed decisions during the Q&A that follows. The briefing should be written in the user's language and cover:

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

After presenting the briefing, pause briefly to let the user absorb it, then proceed to the Q&A.

### Step 2 — Interactive Q&A (one question at a time)

**Interaction rules:**
- Ask questions **one at a time**. Never ask multiple questions in one message.
- **Always use the `AskUserQuestion` tool** for multiple-choice questions — it renders a proper interactive dialog with labeled options and descriptions. Do NOT present choices as plain text lists.
- **Each option must have a `description`** that explains what it means, its implications, and the key trade-off — never list bare option names. Do not ask bare questions like "What method do you want to use?" without explaining what the main method families are.
- Use `preview` for options that benefit from visual comparison (e.g., method sketches, architecture diagrams in ASCII).
- Use `multiSelect: true` only when choices are genuinely non-exclusive (e.g., "which aspects matter to you?").
- Fall back to open-ended text only for questions that have no enumerable options.
- **Context from briefing**: Reference specific findings from the Background Briefing when asking questions — e.g., "In the briefing, we saw that Method X struggles with Y. Given this, which approach appeals to you?"
- **Stop condition**: Stop asking once you can answer all 6 dimensions with reasonable confidence. Specifically, you should be able to write a coherent 1-paragraph summary that covers What (specific problem), Why (motivation), Who (audience), and How (initial approach). When/Where may remain partially open — that is acceptable.

**5W1H checklist** (continuously revisited throughout all phases — see below):

| Dimension | Core Question | Example Follow-up Questions |
|-----------|--------------|----------------------------|
| **What** | What problem or phenomenon do you want to study? | "Can you describe a specific failure case?", "What would a solution look like in practice?" |
| **Why** | Why does this problem matter? What is currently broken? | "What happens if this problem is not solved?", "Is this a bottleneck for a larger goal?" |
| **Who** | Who cares — which research community, which application users? | "Which conference would you submit this to?", "Who would use this in production?" |
| **When** | What is the timing context? New capability, new dataset, new regulation? | "Has anything changed recently that makes this newly possible?", "Are there upcoming deadlines?" |
| **Where** | Which domain or application scenario? | "Is this specific to one domain or generalizable?", "Which datasets or benchmarks are standard here?" |
| **How** | Any early intuition about the method or technical approach? | "Do you have a preference for a method family?", "What resources (GPU, data) do you have access to?" |

**Output of Phase 0:** A 1-paragraph idea summary written back to the user for confirmation before proceeding.

**Output quality checklist:**
- [ ] All 6 dimensions (What/Why/Who/When/Where/How) are addressed, even if some are tentative
- [ ] The summary is specific enough to generate meaningful search queries
- [ ] The user has confirmed the summary before proceeding

---

## Phase 1: Literature Probe

**Goal:** Map the existing landscape quickly. Do not go deep yet — coverage matters more than depth.

**Search targets:**
- arXiv (cs.LG, cs.CV, cs.CL, stat.ML — choose based on domain)
- Semantic Scholar for citation counts and influential papers
- Top-venue proceedings: NeurIPS, ICML, ICLR, ACL, KDD, AAAI (last 3 years)

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

**User checkpoint:** Present directions via `AskUserQuestion` with the following options:
- One option per proposed direction (A, B, C), each with a description summarizing its trade-offs
- **Always include a final option: "All sound good — you recommend"** with description: "I don't have a strong preference. Run a quick feasibility check on all directions and pick the most viable one."

When the user selects "All sound good" (or responds with equivalent phrases like "都可以", "any is fine", "you decide"), **trigger Phase 2.5: Feasibility Scout** before proceeding to Phase 3.

When the user selects a specific direction, skip Phase 2.5 and go directly to Phase 3.

Do NOT proceed to Phase 3 until direction is confirmed (either by user choice or by scout recommendation).

**Output quality checklist:**
- [ ] Exactly 2-3 directions proposed (not 1, not 4+)
- [ ] Each direction has explicit trade-offs (risk vs. reward, novelty vs. feasibility)
- [ ] Each direction includes feasibility signals (datasets, baselines, compute)
- [ ] A clear recommendation is given with reasoning
- [ ] Gap analysis references specific papers from Phase 1 landscape table
- [ ] "All sound good" option is always included in AskUserQuestion

---

## Phase 2.5: Feasibility Scout (conditional — only when user has no preference)

**Trigger:** The user selected "All sound good — you recommend" in Phase 2, or responded with equivalent phrases ("都可以", "any is fine", "you decide", "no preference").

**Goal:** Quickly validate the feasibility of all 2-3 proposed directions before committing to the expensive Phase 3 deep-dive. Catch dead-end paths early with minimal search cost.

**For each proposed direction, run 2-3 targeted WebSearches to check:**
1. **Dataset availability** — Are there public, commonly-used datasets for this direction? Are they accessible?
2. **Baseline reproducibility** — Do the key baseline papers have open-source code? Can results be reproduced?
3. **Concurrent work risk** — Are there very recent papers (< 3 months) that closely overlap this direction?
4. **Compute/resource fit** — Does this direction require resources (data scale, GPU hours, proprietary tools) that may be out of reach?

**Produce a Feasibility Comparison Table:**

```markdown
## Feasibility Scout Results

| Dimension | Direction A | Direction B | Direction C |
|-----------|------------|------------|------------|
| Public datasets | ✅ 3 datasets (X, Y, Z) | ⚠️ 1 dataset, proprietary | ✅ 2 datasets (X, Y) |
| Baselines with code | ✅ 4/5 have code | ❌ 1/5 have code | ✅ 3/5 have code |
| Concurrent work risk | ⚠️ 1 recent overlap | ✅ Low | ✅ Low |
| Compute feasibility | ✅ Single GPU OK | ❌ Needs 8×A100 | ✅ Single GPU OK |
| **Quick Score** | **★★★★☆** | **★★☆☆☆** | **★★★★☆** |

**Recommendation:** Direction [X], because it has the best feasibility profile: [specific reasoning].
**Runner-up:** Direction [Y] is also viable but carries risk in [dimension].
**Eliminated:** Direction [Z] has a critical blocker: [specific issue].
```

**After presenting the table:**
- Explain the recommendation clearly, connecting feasibility findings to the user's context
- Let the user confirm or override the recommendation before proceeding to Phase 3
- If the user disagrees, they can pick any direction — the scout is advisory, not binding

**Output quality checklist:**
- [ ] All proposed directions are scouted (not just the recommended one)
- [ ] Each feasibility dimension has specific evidence (paper names, dataset names, code links), not just ✅/❌
- [ ] A clear recommendation is given with reasoning tied to the feasibility findings
- [ ] The user is asked to confirm before proceeding

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

**Gate outcome:**
- **READY (≥16, no dim <3):** Proceed to Research Proposal generation.
- **NOT READY:** Report the weakest dimension, explain what is missing, propose a targeted improvement task, and loop back:
  - Low Novelty → back to Phase 2 (find a sharper angle or different direction)
  - Low Significance → back to Phase 0/2 (reframe problem or switch domain)
  - Low Soundness → back to Phase 4 (strengthen the method sketch)
  - Low Feasibility → back to Phase 4 (adjust scope or resources)

Show the score card to the user at every gate check. Let them decide whether to continue refining or accept the current state.

---

## Research Proposal Output

Generated only after passing the Conference Readiness Gate (or explicit user override).

**Three output files are produced:**

| File | Format | Language | Purpose |
|------|--------|----------|---------|
| `./Proposal.md` | Markdown | English | Source of truth, version-controlled |
| `./Proposal.html` | HTML | English | Readable standalone document with styling |
| `./Proposal_cn.html` | HTML | Chinese | Chinese translation for local collaboration |

All three files share the same 8-section structure. The HTML files should include basic CSS styling (clean typography, section numbering, table borders, math rendering via KaTeX CDN) for readability.

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
└── theory.md     ← problem formalization and theoretical analysis from Phase 4

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

## Key Interaction Principles

1. **One question at a time** — never overwhelm with multiple questions
2. **Use `AskUserQuestion` for choices** — always use the tool for multiple-choice questions; each option must have a description explaining its implications; use `preview` for visual comparisons
3. **Context-rich questions** — every question must include enough background for the user to make an informed choice; never ask bare questions
3. **Always propose 2-3 options** — never commit to one path without alternatives
4. **Literature first, speculation second** — every claim must be grounded in papers
5. **First principles always on** — at every decision point, decompose to fundamentals, challenge inherited assumptions, and rebuild from scratch (see "Two Persistent Mental Frameworks" above)
6. **5W1H is a living model** — revisit all six dimensions after every new piece of evidence, not just in Phase 0
7. **Show scores at every gate** — keep the user informed of idea quality
8. **Explicit user checkpoints** — wait for confirmation at Phase 0, 2, and Gate
9. **YAGNI for scope** — cut any claim or experiment that is not needed to demonstrate the core insight
10. **Resume from state** — always check `./ideation/state.md` before starting; append to `./ideation/log.md` after every phase
11. **Language matching** — detect the language of the user's message and use that language throughout the entire response, including all generated documents (state.md, log.md, literature.md, theory.md, Proposal.md, Proposal.html, Proposal_cn.html)

---

## Reference Files

Load on demand:
- `references/iteration-loop.md` — detailed loop logic and loop-back decision tree
- `references/conference-readiness.md` — top venue criteria, scoring rubrics, rejection patterns
- `references/gap-analysis-guide.md` — 5 gap types, analysis dimensions, examples
- `references/5w1h-framework.md` — 5W1H framework for Phase 0
- `references/literature-search-strategies.md` — keyword construction and database search tips
- `references/research-question-formulation.md` — SMART criteria, question types, evaluation
