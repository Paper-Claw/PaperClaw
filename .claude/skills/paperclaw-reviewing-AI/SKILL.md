---
name: paperclaw-reviewing-AI
description: >
  Independent review panel orchestrator for research proposal evaluation. Dispatches
  3-5 reviewers from different AI model families (Claude, GPT, Gemini, DeepSeek, Kimi),
  aggregates scores, strips numeric scores from feedback sent to the ideation model,
  and manages the pass/fail gate. Use when ./ideation/state.md shows Phase: review-pending.
version: 1.0.0
---

# Review Gate Orchestrator

Manages the independent, multi-model review panel for research proposals. This skill is triggered when the ideation model completes Phase 4 and sets `./ideation/state.md` to `Phase: review-pending`.

## Trigger Condition

Read `./ideation/state.md`. If `Phase: review-pending`, begin the review process.

---

## Step 1: Auto-Detect Available Reviewers

Detect available AI CLI tools and select the best model from each family:

```bash
# Check available tools
command -v codex &>/dev/null && echo "codex available"
command -v opencode &>/dev/null && echo "opencode available"
# Claude Code is always available via Agent tool
```

**Model selection (best per family):**

| Priority | Family | Best Model | Tool | Fallback |
|----------|--------|-----------|------|----------|
| 1 | Claude | `claude-opus-4-6` | Agent tool (`paperclaw-reviewer` agent) | Always available |
| 2 | GPT | `gpt-5.4` | `codex exec` | Skip if codex unavailable |
| 3 | Gemini | `gemini-3.1-pro-preview` | `opencode run -m github-copilot/gemini-3.1-pro-preview` | Skip if opencode unavailable |
| 4 | DeepSeek | `deepseek-reasoner` | `opencode run -m deepseek/deepseek-reasoner` | Skip if unavailable |
| 5 | Kimi | `k2p5` | `opencode run -m kimi-for-coding/k2p5` | Skip if unavailable |

**Minimum 3 reviewers required.** If fewer than 3 model families are available, use Claude with different personas to fill the gap.

---

## Step 2: Assign Reviewer Personas

Each reviewer gets a unique persona to maximize review diversity:

| Reviewer | Persona | Focus Areas |
|----------|---------|-------------|
| R1 (Claude) | Theory-focused senior researcher | Theoretical rigor, mathematical soundness, proof quality, Lean 4 verification audit |
| R2 (GPT) | Applied ML researcher | Practical impact, experimental design, baseline selection, reproducibility |
| R3 (Gemini) | Methodical novelty assessor | Novelty assessment, related work positioning, contribution clarity |
| R4 (DeepSeek) | Devil's advocate / reasoning-heavy critic | Edge cases, failure modes, assumptions that may not hold |
| R5 (Kimi) | Breadth reviewer | Cross-disciplinary connections, broader impact, missing perspectives |

---

## Step 3: Dispatch Reviewers in Parallel

All reviewers run simultaneously. Each receives:
1. Their assigned persona
2. The full scoring rubric (from `references/conference-readiness.md`)
3. Instructions to read ONLY `./Proposal.md`
4. The required output format

### Claude Reviewer (R1)
Launch via Agent tool with `paperclaw-reviewer` agent. Pass persona as part of the prompt.

### Codex CLI Reviewers (R2)
```bash
codex exec \
  -c model="gpt-5.4" \
  -c 'sandbox_permissions=["disk-full-read-access"]' \
  -o ./ideation/reviews/iteration-N/R2-gpt.md \
  "$(cat <<'PROMPT'
[Persona + rubric + format instructions]
Read ONLY ./Proposal.md. Do NOT read files in ./ideation/.
PROMPT
)"
```

### OpenCode Reviewers (R3, R4, R5)
```bash
opencode run \
  -m [provider/model] \
  --dir . \
  "[Persona + rubric + format instructions. Read ONLY ./Proposal.md.]"
```

Save each review to `./ideation/reviews/iteration-N/RX-[model].md`.

---

## Step 4: Aggregate Scores

After all reviews are collected:

1. Parse each review's scores (Novelty, Significance, Soundness, Feasibility)
2. For each dimension, compute the **median** score across all reviewers
3. Compute the median total

### Pass Condition
- Median total ≥ 16/20 **AND** no median dimension < 3

### Split Decision Detection
If any dimension has reviewer disagreement > 2 points (e.g., one reviewer gives 2/5 and another gives 5/5), flag as "split decision" and note this in the aggregation report.

### Lean 4 Verification Audit
Read `./ideation/theory.md` independently:
- If formalizable claims exist (theorems, bounds, convergence proofs)
- Check if `./ideation/lean4/` contains corresponding `.lean` files
- If formalizable claims exist but no Lean code: apply -1 to median Soundness (floor at 1)
- If `lake build` results show FULL PASS: apply +1 to median Soundness (cap at 5)
- If PARTIAL PASS or verification was skipped for valid reasons: no adjustment

---

## Step 5: Synthesize Feedback for Ideation Model

**This is the critical information barrier step.**

Convert reviewer commentary into qualitative improvement guidance. **Strip ALL of the following:**
- Numeric scores (1-5, X/20)
- Rubric dimension names as scoring labels ("Novelty: 2/5", "Soundness score")
- Pass/fail threshold language ("below threshold", "does not meet the bar")
- Any reference to the scoring rubric itself

**Transform weaknesses into qualitative themes:**

| Reviewer wrote | Feedback to ideation model |
|---------------|---------------------------|
| "Novelty: 2/5 — overlaps significantly with [Paper X]" | "Reviewers noted significant overlap with [Paper X] and questioned what differentiates the proposed approach" |
| "Soundness: 2/5 — method lacks pseudocode" | "The method description was flagged as insufficiently detailed for reproduction — reviewers wanted to see concrete pseudocode and design choice justifications" |
| "Feasibility: 2/5 — compute budget unrealistic" | "Several reviewers questioned whether the proposed experiments can be completed within a standard compute budget" |
| "Significance: 2/5 — niche problem" | "Reviewers were unconvinced about the practical importance of this problem and suggested connecting to a broader research trend" |

**Group concerns by theme**, not by reviewer or dimension:

```markdown
# Review Feedback — Iteration N

## Key Strengths Noted by Reviewers
- [theme 1, with specific citations from reviewers]
- [theme 2]

## Primary Concerns
1. [Concern theme]: [synthesized description from multiple reviewers]
2. [Concern theme]: [synthesized description]
3. [Concern theme]: [synthesized description]

## Specific Suggestions
- [actionable suggestion 1]
- [actionable suggestion 2]

## Questions Reviewers Want Addressed
1. [question]
2. [question]
```

Write this to `./ideation/review-feedback-N.md`.

---

## Step 6: Gate Decision

### PASS (median total ≥ 16, no median dim < 3)
1. Update `./ideation/state.md`: `Phase: Done`
2. Signal the ideation model to generate final output files (HTML, CN, BibTeX)
3. Write the full aggregation report (with scores) to `./ideation/reviews/iteration-N/aggregation.md`

### FAIL (below threshold)
1. Update `./ideation/state.md`: `Phase: revision-N`
2. Write the qualitative feedback file (scores stripped)
3. Increment iteration counter
4. If iteration count < 4: signal the ideation model to revise
5. If iteration count = 4: force-proceed with caveat note

### Force-Proceed (after 4 iterations)
1. Update `./ideation/state.md`: `Phase: Done`
2. Add caveat note to the feedback: "The review panel did not reach consensus on readiness after 4 rounds. The following concerns remain unresolved: [list]"
3. Signal the ideation model to generate final output with the caveat in Section 9

---

## Reference Files

Load on demand:
- `references/conference-readiness.md` — scoring rubric with dimension definitions and thresholds
- `references/review-protocol.md` — aggregation rules, feedback synthesis templates, split decision handling
