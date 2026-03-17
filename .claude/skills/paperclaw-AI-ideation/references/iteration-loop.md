# Iteration Loop — Detailed Logic

## Why Iterate?

A single pass through literature and brainstorming is not enough for a top-conference idea. The best papers are typically refined 3-5 times before the contribution is truly sharp. This document defines the loop mechanics so each iteration has a clear purpose and termination condition.

## Loop Structure

Each loop iteration covers Phases 2-4 plus the Gate:

```
Iteration N
  ├── [Phase 2] New literature (or re-analysis of existing)
  ├── [Phase 3] Gap update (what did we learn this round?)
  ├── [Phase 4] Sharpened question and method
  └── [Gate]   Readiness check
       ├── READY  → exit loop → generate proposal
       └── NOT READY → diagnose → plan targeted improvement → Iteration N+1
```

**Maximum iterations:** 4. After 4 failed gate checks, generate the Proposal anyway with a caveat note in Section 9 (Alternative Directions) listing the unresolved weaknesses. Log the forced-proceed decision to `./ideation/questions.md`.

---

## Loop Entry Conditions

| Entry Point | When to Use |
|-------------|-------------|
| Phase 0 | First session, raw idea with no prior search |
| Phase 2 | Direction needs a new angle; prior direction was rejected |
| Phase 3 | Direction is fixed, but evidence base is thin |
| Phase 4 | Method/question needs tightening; novelty or soundness is low |

---

## Targeted Improvement Tasks by Weak Dimension

When the Gate score reveals a weak dimension, run one of these targeted tasks in the next iteration.

### Novelty < 3

**Diagnosis:** The idea overlaps too much with existing work.

**Targeted actions:**
1. Search for the 3 most similar papers to the current direction
2. For each, identify exactly what they do NOT cover
3. Find the intersection of all three gaps — that is the novelty space
4. Reformulate the research question around that intersection

**Common fixes:**
- Change the problem scope (narrower is often more novel)
- Change the technical approach to something unused in this domain
- Change the application domain (method is known, but domain crossing is novel)
- Add a new constraint or evaluation dimension that no prior work addresses

### Significance < 3

**Diagnosis:** The problem is not important enough, or the framing does not communicate importance.

**Targeted actions:**
1. Search for survey papers or position papers that name this as an open problem
2. Search for industry/application papers that describe this as a bottleneck
3. Find a benchmark or competition where the current SOTA is unsatisfying
4. Reframe: zoom out to find the higher-order problem this work contributes to

**Common fixes:**
- Ground the motivation in a concrete failure case (real system, real data)
- Connect to a broader trend (scaling, safety, efficiency, generalization)
- Find a dataset or benchmark that quantifies how bad the current situation is
- Identify a community of researchers actively working on adjacent problems

### Technical Soundness < 3

**Diagnosis:** The method sketch is vague, speculative, or not sufficiently grounded.

**Targeted actions:**
1. Identify the single most important technical claim
2. Find 1-2 papers that establish the theoretical or empirical foundation for that claim
3. Sketch a 3-step technical pipeline: input → transformation → output
4. Identify the key design choice that makes this method work (and why alternatives fail)

**Common fixes:**
- Replace vague verbs ("improve", "enhance") with specific operations
- Anchor the method in an existing technique and state the delta clearly
- Specify the loss function, objective, or optimization procedure
- Write a pseudocode-level description of the core algorithm

### Experimental Feasibility < 3

**Diagnosis:** The experiments are too expensive, the data is unavailable, or the comparison is infeasible.

**Targeted actions:**
1. List all datasets needed and verify they are publicly available
2. Estimate compute requirements (model size, training steps, GPU hours)
3. Identify which baselines are reproducible (code available?)
4. Find a reduced-scale version of the experiment that proves the concept

**Common fixes:**
- Use a smaller public dataset as proof-of-concept before scaling
- Replace expensive baselines with lighter-weight approximations
- Scope down to 1-2 primary datasets rather than comprehensive benchmarks
- Use a pretrained backbone instead of training from scratch
- Design ablations that are cheap but informative

---

## Auto-Pilot Checkpoint Protocol

In auto-pilot mode, checkpoints are logged but do not pause for user input.

**Phase transition checkpoint (auto):**
- Present phase completion summary as text output (visible to user in real-time)
- Log any auto-decisions made during the phase to `./ideation/questions.md`
- Auto-proceed to the next phase immediately

**Gate checkpoint (auto):**
- Present the score card as text output:
  > "Conference Readiness Score — Iteration [N]:
  > Novelty: X/5 | Significance: X/5 | Soundness: X/5 | Feasibility: X/5
  > Total: XX/20 — [READY / NOT READY]"
- If NOT READY: automatically identify the weakest dimension and loop back to the appropriate phase. Log the decision to `./ideation/questions.md`.
- If READY: proceed to Proposal generation.

**Override (post-hoc):**
After the Proposal is generated, the user can review `./ideation/questions.md` and re-invoke the skill with override instructions to change any auto-decision. See the "Resume with User Overrides" section in SKILL.md.

---

## State Tracking Between Sessions

At the start of every session, read `./ideation/state.md`:
- If state exists: resume from the current phase and iteration
- If no state: start from Phase 0

After every completed phase or gate check, do two things:
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
4. Check if the scarcity signals an untapped opportunity (high novelty) or an abandoned direction (low significance)
5. In Phase 2, explicitly flag "niche topic" and discuss with the user whether the limited literature is a feature (novelty) or a risk (lack of community interest)

### Concurrent Work Discovery

**Symptoms:** During any phase, a very recent paper (< 3 months old) is found that closely matches the current direction.

**Protocol:**
1. Do NOT panic — concurrent work weakens but does not eliminate novelty
2. Immediately perform a detailed comparison: what does the concurrent paper do vs. what we propose?
3. Identify the delta: different method? different setting? different analysis? complementary angle?
4. Re-score the Novelty dimension with the concurrent work factored in
5. If Novelty drops below 3, trigger a targeted novelty improvement loop (see "Novelty < 3" above)
6. If Novelty remains ≥ 3, proceed but add "Concurrent Work" as a risk in the proposal

### Stale Literature (> 2 years without new work)

**Symptoms:** The most recent paper on this topic is more than 2 years old; no arXiv preprints in the last 12 months.

**Protocol:**
1. Determine cause — is this a **mature field** (problem considered solved) or an **abandoned direction** (problem too hard / not interesting)?
2. **Mature field signals**: widely-used benchmarks exist, SOTA is stable, methods are deployed in industry
3. **Abandoned direction signals**: negative results papers, no follow-up citations, key labs moved on
4. If mature: the opportunity is likely in a new angle, new application, or challenging an assumption that became a "settled" convention
5. If abandoned: investigate why — the reason for abandonment is critical. If the blocking factor has been removed by new technology (e.g., new model capabilities, new data), this could be a strong opportunity
6. Discuss findings with the user before committing — stale topics carry higher risk of "reviewers won't care" (low Significance)

---

## Loop Termination Conditions

| Condition | Action |
|-----------|--------|
| Gate score ≥ 16/20, no dim < 3 | Generate proposal, exit loop |
| 4 iterations without reaching threshold | Generate proposal with caveat note in Section 9, log forced-proceed to questions.md |
| User re-invokes with overrides | Read questions.md, apply overrides, re-run from earliest affected phase |
| User asks to abandon | Save state, summarize what was learned |
