# Review Protocol — Aggregation & Feedback Synthesis

## Score Aggregation Rules

### Per-Dimension Aggregation
For each of the 4 dimensions (Novelty, Significance, Technical Soundness, Experimental Feasibility):
1. Collect scores from all N reviewers
2. Compute the **median** (not mean — robust to outliers)
3. If N is even, take the lower of the two middle values (conservative)

### Total Score
Sum the 4 median dimension scores.

### Pass Condition
- Median total ≥ 16/20
- No single median dimension < 3
- Both conditions must be met

### Split Decision Detection
If any dimension has a range (max - min) > 2 across reviewers:
1. Flag that dimension as "split decision"
2. Include all reviewer justifications for that dimension in the aggregation report
3. If the median for that dimension is exactly 3 (borderline), consider it a weakness in feedback synthesis

---

## Lean 4 Verification Audit Protocol

The orchestrator independently audits Lean 4 verification:

1. Read `./ideation/theory.md`
2. Classify each claim as formalizable or not (using the same table in the ideation skill)
3. Check `./ideation/lean4/` for corresponding `.lean` files
4. Check `lake build` results if available

### Adjustment to Soundness Score
| Verification Status | Adjustment |
|--------------------|------------|
| FULL PASS (no sorry) | +1 to median Soundness (cap at 5) |
| PARTIAL PASS (sorry only on empirical sub-goals) | No change |
| Verification attempted but FAILED after retries | -1 to median Soundness (floor at 1) |
| Formalizable claims exist but NO verification attempted | -1 to median Soundness (floor at 1) |
| No formalizable claims exist (purely empirical) | No change |

---

## Feedback Synthesis Rules

### Information Barrier
The ideation model must NEVER see:
- Numeric scores (X/5, XX/20)
- Dimension names as scoring labels
- Pass/fail thresholds
- The scoring rubric itself
- Individual reviewer identities or model names

### What the Ideation Model DOES See
- Qualitative themes (strengths and concerns)
- Specific suggestions from reviewers
- Questions reviewers want addressed
- Whether to revise (via state.md Phase: revision-N) or finalize (Phase: Done)

### Synthesis Process
1. Read all individual reviews from `./ideation/reviews/iteration-N/`
2. Extract all strengths, weaknesses, and questions
3. Group weaknesses by theme (not by reviewer or dimension)
4. Remove all numeric scores and dimension labels
5. Write synthesized feedback to `./ideation/review-feedback-N.md`

### Feedback File Format
```markdown
# Review Feedback — Iteration N

## Key Strengths Noted by Reviewers
- [theme 1, with specific details from multiple reviews]
- [theme 2]
- [theme 3]

## Primary Concerns
1. **[Concern Theme]**: [synthesized from multiple reviewers — what the concern is, why it matters, what would address it]
2. **[Concern Theme]**: [synthesized description]
3. **[Concern Theme]**: [synthesized description]

## Specific Suggestions
- [actionable suggestion derived from reviewer comments]
- [actionable suggestion]

## Questions to Address in Revision
1. [question that, if answered, would strengthen the proposal]
2. [question]

## Revision Guidance
Based on the concerns above, consider revisiting:
- [Phase X for concern 1]
- [Phase Y for concern 2]
```

---

## Reviewer Prompt Templates

### Common Prefix (all reviewers)
```
You are an independent reviewer evaluating a research proposal for conference readiness.

YOUR PERSONA: [assigned persona]

INSTRUCTIONS:
1. Read ONLY the file ./Proposal.md — this is the ONLY file you should read
2. Do NOT read any files in ./ideation/ directory
3. The Proposal is self-contained: Section 4 (Theoretical Analysis) includes complete
   mathematical foundations, full proofs (every step), complete Lean 4 source code,
   verification logs, and a verification summary table. Evaluate all of these.
4. Score the proposal on 4 dimensions using the rubric below
5. Provide specific, actionable feedback

SCORING RUBRIC:
[Full rubric from conference-readiness.md]

OUTPUT FORMAT:
[Standard review format]
```

### Persona-Specific Additions
- **Theory-focused:** "Pay special attention to: mathematical rigor, proof quality, whether Lean 4 verification was attempted for formal claims, whether assumptions are clearly stated"
- **Applied ML:** "Pay special attention to: practical impact, experimental design quality, baseline selection fairness, reproducibility, compute budget realism"
- **Methodical novelty assessor:** "Pay special attention to: how the contribution differs from the closest existing work, whether the novelty is in the method or just the application domain, positioning in the related work section"
- **Devil's advocate:** "Actively look for: hidden assumptions, failure modes, edge cases where the method might break, claims that are not well-supported"
- **Breadth reviewer:** "Consider: cross-disciplinary connections, broader impact, whether the problem framing could appeal to adjacent communities"
