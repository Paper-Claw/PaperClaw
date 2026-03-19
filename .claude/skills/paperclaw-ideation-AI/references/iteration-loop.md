# Iteration Loop — Detailed Logic

## Why Iterate?

A single pass through literature and brainstorming is not enough for a top-conference idea. The best papers are typically refined 3-5 times before the contribution is truly sharp. This document defines the loop mechanics so each iteration has a clear purpose and termination condition.

## Loop Structure

Each iteration covers revision based on reviewer feedback:

```
Iteration N
  ├── Read reviewer feedback (./ideation/reviews/iteration-N/metareview.md)
  ├── Identify primary concerns (qualitative themes, NOT scores)
  ├── Determine which phases to revisit
  ├── Re-run from earliest affected phase
  └── Regenerate draft Proposal.md → set state to review-pending
```

**Maximum iterations:** 10. After 10 rounds of review feedback, the orchestrator generates the final Proposal anyway with a caveat note. The iteration count is managed by the review-gate orchestrator, not the ideation model.

---

## Loop Entry Conditions

| Entry Point | When to Use |
|-------------|-------------|
| Phase 0 | First session, raw idea with no prior search |
| Phase 2 | Direction needs a new angle; reviewer feedback suggests overlap with existing work |
| Phase 3 | Direction is fixed, but evidence base is thin |
| Phase 4 | Method/question needs tightening; reviewers flagged weak method or theory |

---

## Revision Based on Reviewer Feedback

When reviewer feedback is available at `./ideation/reviews/iteration-N/metareview.md`:

1. Read the feedback file carefully — it contains qualitative themes and concerns, NOT numeric scores
2. Identify the primary concerns raised by reviewers
3. For each concern, determine which phase to revisit using the mapping below
4. Re-run from the earliest affected phase forward
5. Regenerate `./Proposal.md` draft
6. Set state to `Phase: review-pending`

### Feedback-to-Phase Mapping

| Reviewer Feedback Theme | Phase to Revisit | Targeted Actions |
|------------------------|-----------------|------------------|
| "Overlaps with existing work" / "Insufficient differentiation from [Paper X]" | Phase 2 | Search for the 3 most similar papers, identify what they do NOT cover, find the intersection of gaps, reformulate the research question around that intersection. Consider: narrower scope, different technical approach, domain crossing, new constraint. |
| "Problem importance unclear" / "Motivation is weak" / "Why does this matter?" | Phase 0/2 | Search for survey/position papers naming this as an open problem, find industry papers describing this as a bottleneck, find benchmarks where SOTA is unsatisfying, reframe by zooming out to the higher-order problem. |
| "Method underspecified" / "Claims not supported" / "Design choices not justified" | Phase 4 | Identify the single most important technical claim, find 1-2 papers establishing the foundation, sketch a clear input→transformation→output pipeline, specify loss function/objective, write pseudocode. If Lean 4 previously failed, re-examine theorem statements before regenerating proofs. |
| "Experiments unrealistic" / "Baselines unavailable" / "Compute requirements too high" | Phase 4 | Verify all datasets are publicly available, estimate compute using domain-standard metrics, identify reproducible baselines with code, find reduced-scale proof-of-concept experiments, scope down to 1-2 primary datasets. |
| "Theoretical claims not formally verified" / "Missing formal verification" | Phase 4 | Attempt Lean 4 verification for all formalizable claims. If previously failed, try weaker bounds, check missing assumptions, split complex theorems into smaller lemmas. |
| "Related work incomplete" / "Missing key references" | Phase 3 | Run additional targeted searches for the specific papers/areas reviewers mentioned, update comparison matrix and gap card. |

---

## Auto-Pilot Checkpoint Protocol

In auto-pilot mode, checkpoints are logged but do not pause for user input.

**Phase transition checkpoint (auto):**
- Present phase completion summary as text output (visible to user in real-time)
- Log any auto-decisions made during the phase to `./ideation/questions.md`
- Auto-proceed to the next phase immediately

**Review handoff checkpoint (auto):**
- Generate draft Proposal.md
- Set state to `Phase: review-pending`
- Output: "Draft Proposal submitted to independent review panel."
- STOP and await review feedback

**Revision checkpoint (auto):**
- Read `./ideation/reviews/iteration-N/metareview.md`
- Present the reviewer concerns as text output
- Auto-proceed to the earliest affected phase
- Log the revision decision to `./ideation/questions.md`

**Override (post-hoc):**
After the Proposal is generated, the user can review `./ideation/questions.md` and re-invoke the skill with override instructions to change any auto-decision. See the "Resume with User Overrides" section in SKILL.md.

---

## State Tracking Between Sessions

At the start of every session, read `./ideation/state.md`:
- If state exists: resume from the current phase and iteration
- If no state: start from Phase 0
- If state shows `Phase: review-pending`: the ideation model waits for `./ideation/reviews/iteration-N/metareview.md` to appear
- If state shows `Phase: revision-N`: read the feedback file and begin revision

After every completed phase or review handoff, do two things:
1. **Overwrite** `./ideation/state.md` with the current snapshot (always up-to-date)
2. **Append** a new entry to `./ideation/log.md` (never overwrite — full audit trail)

See SKILL.md "Persistent State & Log" section for the exact file formats.

---

## Edge Case Protocols

### Niche Topic (< 10 relevant papers found)

**Symptoms:** Phase 1 search returns fewer than 10 directly relevant papers.

**Protocol:**
1. Broaden the search to adjacent fields — identify the 2-3 closest related domains and search there
2. Lower the Phase 1 paper count requirement to 5-8 papers (quality over quantity)
3. Include workshop papers, preprints, and technical reports — not just top-venue papers
4. Check if the scarcity signals an untapped opportunity (high novelty) or an abandoned direction (lack of community interest)
5. In Phase 2, explicitly flag "niche topic" and discuss whether the limited literature is a feature (novelty) or a risk

### Concurrent Work Discovery

**Symptoms:** During any phase, a very recent paper (< 3 months old) is found that closely matches the current direction.

**Protocol:**
1. Do NOT panic — concurrent work weakens but does not eliminate novelty
2. Immediately perform a detailed comparison: what does the concurrent paper do vs. what we propose?
3. Identify the delta: different method? different setting? different analysis? complementary angle?
4. If the delta is too small, trigger a targeted novelty improvement loop
5. If the delta is sufficient, proceed but add "Concurrent Work" as a risk in the proposal

### Stale Literature (> 2 years without new work)

**Symptoms:** The most recent paper on this topic is more than 2 years old.

**Protocol:**
1. Determine cause — is this a **mature field** (problem considered solved) or an **abandoned direction** (problem too hard / not interesting)?
2. **Mature field signals**: widely-used benchmarks exist, SOTA is stable, methods are deployed in industry
3. **Abandoned direction signals**: negative results papers, no follow-up citations, key labs moved on
4. If mature: the opportunity is likely in a new angle, new application, or challenging an assumption
5. If abandoned: investigate why — if the blocking factor has been removed by new technology, this could be a strong opportunity
