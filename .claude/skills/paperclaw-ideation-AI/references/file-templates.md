# File Templates (Ideation Pipeline)

## state.md — Current Snapshot

Overwrite this file after every phase transition.

```markdown
# Ideation State

**Idea:** [one-line summary]
**Phase:** [0 / 1 / 2 / 2.5 / 3 / 4 / review-pending / revision-N / user-revision / generating-outputs / Done]
**Iteration:** [N]
**Direction:** [chosen direction title, or "TBD"]
**Lean4Status:** [not_started / in_progress / pass / partial_pass / fail]
**Lean4Attempt:** [0-10]
**UserRevisionCycle:** [C — which user-initiated revision cycle; increments each time user initiates a new revision; absent until first user-initiated revision]
**UserRevisionRound:** [R — which review round within current cycle; resets to 1 each new cycle; increments on FAIL]
**UserRevisionBudget:** [3 / 2 / 1 / 0 — remaining review attempts in current cycle; resets to 3 each new cycle]
**Next Action:** [what to do when this session resumes]
**Updated:** [YYYY-MM-DD]
```

## log.md — Append-Only History

Append one entry per completed phase or gate check. Never overwrite. Source for Proposal Section 8.

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
[Record every significant change — direction pivots, scope adjustments, method revisions,
problem reframing. This feeds Section 8 (Revision History) of the final proposal.]

| Change Type | What Changed | Why | Outcome |
|-------------|-------------|-----|---------|
| [Direction pivot / Scope change / Method revision / Problem reframing / ...] | [description] | [reason] | [result] |

### Handoff / Revision (if this was a review handoff or revision)
**Action:** [Handed off draft Proposal to review panel / Received reviewer feedback / Final Proposal generated]
**Reviewer Feedback Themes:** [list of qualitative concerns from ./ideation/reviews/iteration-N/metareview.md, if revising]
**Decision:** [what was chosen — which phases to revisit, or "proceed to final"]

---
```

## papers.md — Append-Only Paper Index

Append new papers as they are found. Never overwrite existing entries.

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

## questions.md — Auto-Pilot Decision Log

Append new decisions as they are made. Never overwrite existing entries. Source for Proposal Section 9.

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

## Decision #L — Phase 4: Lean 4 Verification (Attempt M/10)
**Question:** Do the key theoretical claims formally verify in Lean 4?
**Formalizable Claims:** [list of claims identified from theory.md, with classification: Yes/Partially/No for each]
**Claims Not Formalized:** [list any claims classified as "No" with explanation why each is empirical/non-formalizable]
**Result:** [FULL PASS / PARTIAL PASS / FAIL: error description]
**Sorry Items:** [list with justification, or "none"]
**Error Analysis:** [for failures: what went wrong, diagnosis, planned fix]
**Auto-Choice:** [Proceed to Step 4.4 / Retry with fix / Escalate to Phase N]
**Reasoning:** [why this choice]
**Confidence:** High / Medium / Low

---

## Decision #M — Handoff: Draft Proposal Submitted
**Question:** Is the draft Proposal ready for external review?
**Context:** [Summary of what was completed in Phases 0-4]
**Auto-Choice:** Submit to review panel
**Reasoning:** [Phase 4 checklist items completed]
**Confidence:** High
```
