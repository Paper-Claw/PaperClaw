# Conference Readiness Criteria

Evaluation rubric for assessing whether a research idea is ready for top-venue submission.

**Target venues:** See `references/domain.md` for the full venue list.

---

## Scoring Rubric (1-5 per dimension, total 20)

**Readiness threshold:** Total ≥ 16/20, no single dimension < 3.

---

### Dimension 1: Novelty (N)

Does the work make a claim that has not been made before?

| Score | Meaning |
|-------|---------|
| 5 | Defines a new problem, proposes a fundamentally new method, or demonstrates a result that contradicts existing understanding |
| 4 | Introduces a genuinely new technical mechanism or theoretical insight that did not exist before; the novelty is in the METHOD itself, not merely in where it is applied |
| 3 | Meaningful adaptation of existing methods to a new domain or setting, with non-trivial technical modifications required to make it work; OR a new combination of ideas that produces emergent properties not present in any individual component |
| 2 | Straightforward application of existing method(s) to a new domain with minor modifications; the core technique is known, the transfer is the contribution |
| 1 | Reproduces existing work with no new contribution |

**Top-venue novelty patterns that work:**
- "Nobody has applied X to domain Y because of challenge Z — we solve Z"
- "Everyone assumes A, but we show empirically that A is false under condition B"
- "Existing methods all share limitation L — our insight is that L comes from design choice D, which we replace"
- "We formalize an informal practice and show it works for principled reason R"

**Common novelty pitfalls:**
- "We are the first to combine A and B" — not sufficient unless the combination is non-trivial
- "We improve accuracy by X%" — not sufficient unless the improvement has an explanation
- "Concurrent work" — if someone else published the same idea in the past 3 months, the novelty is weakened but not eliminated
- "We apply proven technique X to unstudied domain Y" — this is a Score 2-3 contribution, NOT Score 4. Score 4 requires that the METHOD itself contains a new mechanism. The novelty lies in what technical challenges the transfer required, not the transfer itself.

**Novelty self-test for Score 4:**
> "If I remove the domain/application context, is there still a new technical idea here
> that would interest researchers working on different problems?"
> If yes → Score 4. If the novelty disappears without the domain context → Score 2-3.

**Domain-specific novelty calibration:** See `references/domain.md` "Domain-Specific Novelty Calibration" section for field-specific scoring examples.

---

### Dimension 2: Significance (S)

Do top-venue reviewers care about this problem?

| Score | Meaning |
|-------|---------|
| 5 | Core open problem in the field; multiple influential papers cite this as "future work" |
| 4 | Active research area; several recent papers address related aspects |
| 3 | Clear practical or theoretical value; the community would benefit from this answer |
| 2 | Niche problem; only a small subset of researchers would care |
| 1 | Problem is not recognized as important by the community |

**High-significance framing strategies:**
- Connect to a large-scale failure mode (model collapses, hallucinations, distribution shift)
- Ground in a widely-used benchmark where all methods perform poorly
- Show that solving this problem enables something not otherwise possible
- Link to a practical deployment concern (efficiency, fairness, safety, robustness)

**Significance self-test:**
> "If this paper were published, would it be cited in the Related Work section of future papers on [topic]?"
> If yes → high significance. If uncertain → need stronger motivation section.

---

### Dimension 3: Technical Soundness (T)

Is the method well-defined and are the claims defensible?

| Score | Meaning |
|-------|---------|
| 5 | Method is fully specified; theoretical guarantees or strong empirical justification; ablations designed |
| 4 | Method is clearly described; key design choices are justified; experimental plan is solid |
| 3 | Core method is clear; some design choices need justification; experiments cover main claims |
| 2 | Method sketch exists but key components are vague; experiments may not support the claims |
| 1 | Method is undefined or implausible |

**Soundness checklist:**
- [ ] The core algorithm/procedure can be described in pseudocode
- [ ] Every major design choice has a reason (theoretical or empirical)
- [ ] The proposed method directly addresses the stated limitation of prior work
- [ ] There is at least one experiment that isolates the proposed contribution (ablation)
- [ ] Failure cases or negative results are acknowledged

**Common soundness issues at ideation stage:**
- Method relies on a component that does not exist yet
- Claims generalization without testing on diverse settings
- Comparison against weak or unfair baselines
- No way to measure the property that was claimed to improve

**Lean 4 Formal Verification Penalty:**

Lean 4 verification is expected for all theoretical claims. Having it does **not** add bonus points; missing or incomplete verification incurs a penalty. See `references/review-protocol.md` "Soundness Score Adjustment" table for the authoritative rules. Summary:

| Status | Adjustment |
|--------|------------|
| FULL PASS (no `sorry`) | No change (verification is expected, not a bonus) |
| PARTIAL PASS (`sorry` on any sub-goals) | -1 (floor at 1) |
| FAIL (attempted, failed after retries) | -1 (floor at 1) |
| SKIPPED — justified + rigorous NL proof (apply conservatively) | No change — **only** when: (a) a careful NL proof audit confirms the proof is sound, AND (b) the justification for skipping formalization is explicit and compelling |
| SKIPPED — unjustified, or NL proof insufficient | -1 (floor at 1) |
| ESCALATION (`Lean4Escalation: true` in state.md) | Cap at 2 |

---

### Dimension 4: Experimental Feasibility (F)

Can these experiments actually be run?

| Score | Meaning |
|-------|---------|
| 5 | All datasets public; baselines reproducible; compute within standard PhD budget; timeline realistic |
| 4 | Most resources available; one or two components need modest effort to obtain |
| 3 | Feasible with moderate effort; some resource constraints but not blocking |
| 2 | Significant compute or data challenges; would require unusual resources or partnerships |
| 1 | Experiments are not feasible within a reasonable research timeline |

**Feasibility checklist:**
- [ ] Primary dataset: name it, confirm it is publicly available
- [ ] Baselines: code available for top 2-3 baselines
- [ ] Compute estimate: within domain-standard compute budget (see `references/domain.md` "Resource Estimates")
- [ ] Data size: training set large enough to show effect but not requiring TPU-scale
- [ ] Timeline: core results achievable in 3 months

**Reducing feasibility risk:**
- Use pretrained models standard in the domain (see `references/domain.md`) to reduce training cost
- Start with a small-scale proof of concept (1 dataset, 1 baseline, 1 metric)
- Choose evaluation tasks with standardized train/dev/test splits
- Use publicly available implementation of the hardest component

---

## Venue-Specific Notes

**Venue-specific reviewer priorities, common rejection reasons, and what tends to get accepted:** See `references/domain.md` "Venue-Specific Reviewer Priorities" section.

---

## The "Killer Experiment" Test

Before leaving the ideation phase, identify the single experiment that would make or break the paper.

> "If this one experiment succeeds, the paper is publishable.
> If it fails, the premise is wrong."

A good idea has a clear killer experiment. A vague idea does not.

**Format:**
- Dataset: [name]
- Baseline: [name]
- Metric: [name]
- Expected result: [our method achieves X% improvement / or demonstrates property Y]
- What failure would mean: [the core assumption is wrong]

If you cannot articulate this experiment, the idea is not yet sharp enough to pass the Gate.

---

## Related Work Positioning

Before the gate check, verify positioning against the 5 most similar papers:

| Paper | What they do | What we do differently | Why ours is better |
|-------|-------------|----------------------|-------------------|
| ... | ... | ... | ... |

If the "What we do differently" column cannot be filled in clearly, Novelty will score low.

---

## Readiness Decision Tree

```
Total ≥ 16 AND all dims ≥ 3?
  YES → Generate Proposal
  NO  →
    N < 3? → Phase 2: find sharper angle
    S < 3? → Phase 0/2: reframe problem importance
    T < 3? → Phase 4: strengthen method sketch; if Lean 4 verification failed, re-examine theory.md and retry
    F < 3? → Phase 4: reduce scope, find public resources
    Multiple dims weak? → Consider direction change (Phase 2)
```

---

## Journal-Specific Notes

**Journal-specific reviewer priorities, readiness threshold adjustments, and venue selection decision guide:** See `references/domain.md` "Journal-Specific Notes" and "Venue Selection Decision Guide" sections.
