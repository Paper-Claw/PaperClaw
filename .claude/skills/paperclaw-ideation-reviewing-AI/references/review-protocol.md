# Review Protocol — Aggregation & Feedback Synthesis

## Score Aggregation Rules

### Per-Dimension Aggregation
For each of the 4 dimensions (Novelty, Significance, Technical Soundness, Experimental Feasibility):
1. Collect scores from all N reviewers
2. If N >= 5, **drop the highest score** before averaging (stricter evaluation)
3. Compute the **mean** of the (remaining) scores, rounded to one decimal place

### Total Score
Sum the 4 mean dimension scores.

### Pass Condition
- Mean total **>= 16.0/20**
- No single mean dimension **< 3.0**
- Both conditions must be met

### Split Decision Detection
If any dimension has a range (max - min) > 2 across reviewers:
1. Flag that dimension as "split decision"
2. Include all reviewer justifications for that dimension in the aggregation report
3. If the mean for that dimension is below 3.5 (borderline), flag as a weakness in feedback synthesis

---

## Lean 4 Verification Audit

The orchestrator independently audits Lean 4 verification status. This is separate from what individual reviewers assess from Proposal.md Section 4.

### Audit Procedure
1. Read `./ideation/theory.md` — classify each claim as formalizable or not
2. Check `./ideation/lean4/` for corresponding `.lean` files
3. Check `lake build` results if available
4. Read the actual `.lean` source files and audit formalization quality:
   - Compare each Lean theorem statement against the NL claim in `theory.md`. Does the Lean statement prove the general case, or only a special case? Are the Lean hypotheses stronger than what is claimed informally?
   - Examine each `sorry`: is it placed on a trivial sub-goal (Empirical / Library gap / Simplification) or on the core proof step that constitutes the paper's theoretical contribution?
   - Check that every `def` in the Lean files matches the corresponding notation in `theory.md`. If definitions differ, the proof may be proving something other than what was claimed.
   - If discrepancies are found between Lean formalization and the NL claims, flag as **FORMAL MISMATCH** in the aggregation report and apply the corresponding Soundness adjustment.

### Soundness Score Adjustment

Lean 4 verification is **expected** for all theoretical work — having it does not add bonus points. Missing or incomplete verification incurs a penalty. The "justified skip" exception requires **both** a compelling, explicit justification for not formalizing AND a careful natural-language proof audit that confirms soundness; apply this exception conservatively.

| Status | Condition | Adjustment |
|--------|-----------|------------|
| **FULL PASS** | `lake build` succeeds, no `sorry` | No change (verification is expected, not a bonus) |
| **PARTIAL PASS** | `sorry` on any sub-goals (empirical or otherwise) | -1 to mean Soundness (floor at 1) |
| **FAIL** | Verification attempted, failed after retries | -1 to mean Soundness (floor at 1) |
| **SKIPPED (justified + rigorous NL proof)** | No formalizable claims exist OR skip is explicitly justified AND NL proof is carefully audited and sound | No change — apply conservatively; default to -1 if in doubt |
| **SKIPPED (unjustified or NL proof insufficient)** | Formalizable claims exist but no verification; or justification is weak; or NL proof has gaps | -1 to mean Soundness (floor at 1) |
| **ESCALATION** | Ideation pipeline flagged `Lean4Escalation: true` | Cap mean Soundness at 2 |
| **FORMAL MISMATCH** | Lean code compiles but theorem statement is materially weaker than the NL claim (significantly stronger hypotheses, special-case proof presented as general, definitions inconsistent with theory.md) | -1 to mean Soundness (floor at 1; cumulative with other penalties) |

> **Note:** This table is the single source of truth for Lean 4 adjustment rules. Both `conference-readiness.md` and the reviewing SKILL.md reference this table — do not duplicate the rules elsewhere.

---

## Information Barrier

### What the Ideation Model Must NEVER See
- Numeric scores (X/5, XX/20)
- Dimension names as scoring labels
- Pass/fail thresholds or threshold language
- The scoring rubric itself
- Individual reviewer identities or model names

### What the Ideation Model DOES See
- Qualitative themes (strengths and concerns)
- Specific suggestions from reviewers
- Questions reviewers want addressed
- Decision via `state.md` (`Phase: Done` = pass, `Phase: revision-N` = revise)

### Synthesis Process
1. Read all individual reviews from `./ideation/reviews/iteration-N/`
2. Extract all strengths, weaknesses, and questions
3. Group weaknesses by **theme** (not by reviewer or dimension)
4. Strip all numeric scores and dimension labels
5. Write synthesized feedback to `./ideation/reviews/iteration-N/metareview.md`

---

## Metareview Format

The metareview is the ONLY review artifact the ideation model reads. It must contain zero numeric scores, zero dimension labels, zero threshold language.

```markdown
# Meta-Review — Iteration N

## Key Strengths Noted by Reviewers
- [theme 1, with specific details from multiple reviews]
- [theme 2]
- [theme 3]

## Primary Concerns
1. **[Concern Theme]**: [synthesized from multiple reviewers — what, why, how to fix]
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

> **No `## Gate Result` line.** The gate decision is communicated exclusively via `state.md` and stored in `aggregation.md`. The metareview must remain score-free and decision-free.

---

## Standardized Review Output Format

All reviewers (Claude agent, codex, opencode) must produce reviews in this exact format. The orchestrator parses scores from the `## Scores` section.

```markdown
## Review — [Assigned Persona] ([Model Name])

### Overall Assessment
[2-3 sentence summary of the proposal's strengths and weaknesses]

### Scores
- Novelty: [1-5]/5 — [one sentence justification]
- Significance: [1-5]/5 — [one sentence justification]
- Technical Soundness: [1-5]/5 — [one sentence justification]
- Experimental Feasibility: [1-5]/5 — [one sentence justification]
- **Total: [sum]/20**

### Strengths
1. [specific, citing proposal sections by name]
2. [strength]
3. [strength]

### Weaknesses
1. [specific, actionable — what should be improved and how]
2. [weakness]
3. [weakness]

### Questions for Authors
1. [specific question that, if answered well, would address a concern]
2. [question]

### Suggestions for Improvement
- [actionable suggestion]
- [actionable suggestion]

### Lean 4 Verification Audit
[Evaluate based on Proposal.md Section 4 only. Do NOT treat Lean compilation status as evidence of NL proof correctness — they are independent.]

#### Presence & Compilation
- Formalizable claims found: [list each theorem/bound/guarantee from Section 4]
- Lean 4 code included: [yes — full source / yes — partial / no]
- Verification status per claim: [PASS / PARTIAL (N sorry items) / FAIL / NOT ATTEMPTED]

#### Natural Language Proof Correctness
[Evaluate independently of the Lean result. A FULL PASS in Lean does NOT mean the NL proof is correct.]
- Proof of [Theorem 1]: [sound / has gap at step X / incorrect because Y]
- Proof of [Theorem 2]: [...]
- Overall NL proof assessment: [all proofs sound / gaps present / errors found]

#### Lean Formalization Fidelity
[Check whether the Lean theorem statement faithfully captures the NL claim.]
- Lean statement vs. claimed theorem: [faithful / weakened — (specify how) / different problem]
- Lean hypotheses stronger than NL assumptions? [no / yes — (list extra hypotheses added)]
- sorry placement: [not applicable / on trivial sub-goals only / on core proof step at: ...]
- Definition consistency with Section 4.2 notation: [consistent / inconsistencies at: ...]

#### Assessment
- Assessment: [adequate / partially adequate / missing / not applicable]
- Issues found: [none / list specific concerns with section references]

### Recommendation: Accept / Revise / Reject
[1-2 sentence summary]
```

---

## Math Expert Veto Rule

The orchestrator dispatches a dedicated math auditor (`paperclaw-math-auditor`) in parallel with regular reviewers. This agent evaluates mathematical correctness of NL proofs in Proposal.md Section 4 independently. Its verdict takes priority over score aggregation.

### Veto Logic

1. Read `./ideation/reviews/iteration-N/math-audit.md` **before** performing score aggregation
2. If `Verdict: VETO`:
   - Skip score aggregation entirely
   - Go directly to the FAIL path (same as score-based FAIL)
   - Include the math auditor's Fatal Issues in the metareview as qualitative concerns (strip veto mechanism language — present as "Reviewers identified the following mathematical errors in the theoretical analysis: ...")
   - Write the gate result to `aggregation.md` with a note: "VETO by math audit — score aggregation skipped"
3. If `Verdict: PASS`:
   - Proceed normally to score aggregation
   - Include any Non-fatal Concerns from math-audit.md in the metareview as additional concerns

### Metareview Translation (information barrier)

When incorporating math audit findings into the metareview, strip all of the following:
- The word "VETO" or any reference to a veto mechanism
- References to "math auditor" or "math expert" as a distinct reviewer
- Any language that reveals the bypass of score aggregation

Present findings as: "Reviewers raised concerns about the mathematical correctness of [specific theorem]: [description of error]."

---

## Persona-Specific Instructions

Append these to the common prompt based on the assigned persona:

| Persona | Additional Focus |
|---------|-----------------|
| Theory-focused senior researcher | Mathematical rigor, proof quality, Lean 4 verification completeness, assumption clarity; **must independently evaluate NL proof correctness — do not treat Lean FULL PASS as evidence that NL proofs are correct** |
| Applied ML researcher | Practical impact, experimental design quality, baseline fairness, reproducibility, compute budget |
| Methodical novelty assessor | Differentiation from closest existing work, method-vs-application novelty, related work positioning |
| Devil's advocate / reasoning critic | Hidden assumptions, failure modes, edge cases, unsupported claims |
| Breadth reviewer | Cross-disciplinary connections, broader impact, missing perspectives, appeal to adjacent communities |
