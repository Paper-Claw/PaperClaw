# Conference Readiness Criteria

Evaluation rubric for assessing whether a research idea is ready for top-venue submission.

**Target venues:** NeurIPS, ICML, ICLR, ACL, KDD, AAAI

---

## Scoring Rubric (1-5 per dimension, total 20)

**Readiness threshold:** Total ≥ 16/20, no single dimension < 3.

---

### Dimension 1: Novelty (N)

Does the work make a claim that has not been made before?

| Score | Meaning |
|-------|---------|
| 5 | Defines a new problem, proposes a fundamentally new method, or demonstrates a result that contradicts existing understanding |
| 4 | New combination of ideas, new application of existing method to a clearly unstudied domain, or new empirical finding with theoretical justification |
| 3 | Meaningful improvement over prior work with a clear technical reason why it works better |
| 2 | Incremental improvement; the core idea appears in prior work with minor variation |
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
- [ ] Compute estimate: < 200 GPU-hours for proof-of-concept experiment
- [ ] Data size: training set large enough to show effect but not requiring TPU-scale
- [ ] Timeline: core results achievable in 3 months

**Reducing feasibility risk:**
- Use a pretrained backbone (e.g., BERT, ResNet, GPT-2) to reduce training cost
- Start with a small-scale proof of concept (1 dataset, 1 baseline, 1 metric)
- Choose evaluation tasks with standardized train/dev/test splits
- Use publicly available implementation of the hardest component

---

## Venue-Specific Notes

### NeurIPS / ICML / ICLR (Machine Learning)

**What reviewers prioritize:**
- Theoretical insights or rigorous empirical analysis
- Clear positioning against recent SOTA (last 12 months)
- Code and reproducibility (increasingly expected)
- Ablations that justify design choices

**Common rejection reasons:**
- "Lacks novelty over [specific concurrent paper]"
- "Experiments are not comprehensive enough to support claims"
- "Motivation is not convincing — why does this matter?"
- "Related work is missing [key paper]"

**What tends to get in:**
- New problem formulation with a clear motivation
- New dataset or benchmark + first methods
- Negative results with insight (why a commonly assumed approach fails)
- Principled method + theory + experiments

### ACL / EMNLP / NAACL (NLP)

**What reviewers prioritize:**
- Linguistic or cognitive motivation (not just benchmark improvement)
- Cross-lingual or multilingual coverage when making general claims
- Human evaluation for generation tasks
- Efficiency analysis for production-relevant claims

### KDD (Data Mining / Applied ML)

**What reviewers prioritize:**
- Real-world application with scale
- Practical deployment considerations
- Industrial data and collaboration are a plus
- Reproducibility and open data

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
    T < 3? → Phase 4: strengthen method sketch
    F < 3? → Phase 4: reduce scope, find public resources
    Multiple dims weak? → Consider direction change (Phase 2)
```

---

## Journal-Specific Notes

### Nature / Science / Cell

**What editors and reviewers prioritize:**
- Broad impact beyond a single subfield — the work must be of interest to a wide scientific audience
- Strong narrative arc: clear problem → elegant insight → convincing evidence → broader implications
- Experimental rigor at the highest level: multiple validation approaches, controls, statistical tests
- Novelty must be conceptual, not just methodological — a new understanding, not just a new technique

**Key differences from CS conferences:**
- Review cycle: 3-6+ months (vs. 2-3 months for conferences)
- Desk rejection rate is high — the "significance" bar is much higher
- Supplementary materials can be extensive (no page limit for appendix)
- Negative results are rarely published unless they overturn a major assumption
- Single-blind review (Nature) vs. double-blind (most CS conferences)

**Readiness threshold adjustment:** Significance must score ≥ 4 (not just ≥ 3) for these venues.

### PNAS (Proceedings of the National Academy of Sciences)

**What reviewers prioritize:**
- Scientific rigor and methodological soundness
- Cross-disciplinary relevance (especially valued for computational work with domain applications)
- Direct contribution track requires NAS member sponsorship
- Contributed articles have a shorter review cycle than direct submissions

**Key differences:**
- Three review tracks: Direct Submission, Contributed, and Invited
- Page limit: ~6 pages for main text + unlimited SI
- Broader audience than CS-specific venues — write for scientists, not just ML researchers

### CVPR / ECCV / ICCV (Computer Vision)

**What reviewers prioritize:**
- Visual results — qualitative examples matter as much as quantitative metrics
- Strong baselines on standard benchmarks (ImageNet, COCO, ADE20K, etc.)
- Real-time or efficient inference is a plus for applied work
- Ablation studies that clearly isolate each design choice

**Common rejection reasons:**
- "Results are only shown on one dataset"
- "Missing comparison with [recent concurrent work]"
- "Qualitative results do not show meaningful improvement"

### Venue Selection Decision Guide

```
Is the contribution primarily a new scientific understanding?
  YES → Nature / Science / PNAS
  NO  →
    Is it a new ML method with theoretical grounding?
      YES → NeurIPS / ICML / ICLR
      NO  →
        Is it focused on language / text?
          YES → ACL / EMNLP / NAACL
          NO  →
            Is it focused on vision / images / video?
              YES → CVPR / ECCV / ICCV
              NO  →
                Is it applied ML with real-world data?
                  YES → KDD / WWW / AAAI
                  NO  → Reassess scope and contribution type
```
