---
name: paperclaw-reviewing-AI
description: >
  Independent review panel orchestrator for research proposal evaluation. Dispatches
  3-5 reviewers from different AI model families (Claude, GPT, Gemini, DeepSeek, Kimi),
  aggregates scores, strips numeric scores from feedback sent to the ideation model,
  and manages the pass/fail gate. Use when ./ideation/state.md shows Phase: review-pending.
version: 1.1.0
---

# Review Gate Orchestrator

Manages the independent, multi-model review panel for research proposals. This skill is triggered when the ideation model completes Phase 4 and sets `./ideation/state.md` to `Phase: review-pending`.

## Trigger Condition

Read `./ideation/state.md`. If `Phase: review-pending`, begin the review process.

---

## Step 1: Auto-Detect Available Reviewers & Models

Detect available AI CLI tools, query their model lists at runtime, and select the best model from each family.

### 1a. Check tool availability

```bash
command -v codex &>/dev/null && echo "codex available"
command -v opencode &>/dev/null && echo "opencode available"
# Claude Code is always available via Agent tool
```

### 1b. Query available models dynamically

**Do NOT hardcode model names.** Always query models at runtime:

```bash
# Codex: read default model from config, or list via exec help
cat ~/.codex/config.toml 2>/dev/null | grep '^model' | head -1

# OpenCode: list all available models (this is the authoritative source)
opencode models 2>/dev/null
```

### 1c. Select best model per family from the live model list

Parse the `opencode models` output and pick the **best** (highest version number) model for each family:

| Family | Selection Rule | Provider Prefix | Example Pick |
|--------|---------------|-----------------|-------------|
| GPT | Highest versioned non-mini, non-codex GPT model from `openai/` or `github-copilot/` | `openai/`, `github-copilot/` | e.g. `github-copilot/gpt-5.4` |
| Gemini | Highest versioned `gemini-*-pro*` from `github-copilot/` | `github-copilot/` | e.g. `github-copilot/gemini-3.1-pro-preview` |
| DeepSeek | Prefer `deepseek/deepseek-reasoner`, fallback to `deepseek/deepseek-chat` | `deepseek/` | e.g. `deepseek/deepseek-reasoner` |
| Kimi | Prefer highest versioned `kimi-for-coding/k*` model | `kimi-for-coding/` | e.g. `kimi-for-coding/k2p5` |

**For codex (GPT via codex):** Use the model from `~/.codex/config.toml` as default. This is the user's pre-configured best GPT model. Use `codex exec -m <model>` only if you want to override it.

### 1d. Assemble the reviewer panel

| Priority | Reviewer | Tool | How to Select Model |
|----------|----------|------|---------------------|
| 1 | R1 (Claude) | Agent tool (`paperclaw-reviewer` agent) | Always available, no model query needed |
| 2 | R2 (GPT) | `codex exec` | Use default from `~/.codex/config.toml` |
| 3 | R3 (Gemini) | `opencode run -m <best-gemini>` | Pick from `opencode models` output |
| 4 | R4 (DeepSeek) | `opencode run -m <best-deepseek>` | Pick from `opencode models` output |
| 5 | R5 (Kimi) | `opencode run -m <best-kimi>` | Pick from `opencode models` output |

**Minimum 3 reviewers required.** If fewer than 3 external model families are available, use Claude with different personas to fill the gap (see Step 3 fallback).

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

## Step 3: Dispatch Reviewers in Parallel (with Timeout & Fallback)

All reviewers run simultaneously. Each receives:
1. Their assigned persona
2. The full scoring rubric (from `references/conference-readiness.md`)
3. Instructions to read ONLY `./Proposal.md`
4. The required output format

**Timeout: 5 minutes per external reviewer.** If a reviewer process does not complete within 5 minutes, kill it and trigger the fallback chain.

### Fallback Chain (per reviewer slot)

When an external reviewer fails (error, timeout, model not found), apply this fallback order:

```
codex (GPT) → opencode (same family) → opencode (any available family) → Claude persona
```

Specifically:
- **R2 (GPT) fails**: Try `opencode run -m <best-gpt-from-opencode-models>` → Claude "Applied ML" persona
- **R3 (Gemini) fails**: Try next best Gemini model from opencode → Claude "Novelty Assessor" persona
- **R4 (DeepSeek) fails**: Try `deepseek/deepseek-chat` if `deepseek-reasoner` failed → Claude "Devil's Advocate" persona
- **R5 (Kimi) fails**: Try alternative Kimi model → Claude "Breadth Reviewer" persona

**Claude persona fallback**: When falling back to Claude, launch a `paperclaw-reviewer` agent with the specific persona instructions. Tag the review file with `[Claude-fallback]` so aggregation knows.

### Claude Reviewer (R1)
Launch via Agent tool with `paperclaw-reviewer` agent. Pass persona as part of the prompt.

### Codex CLI Reviewer (R2 — GPT)
```bash
# Use default model from ~/.codex/config.toml (no need to specify -c model)
timeout 300 codex exec \
  -c 'sandbox_permissions=["disk-full-read-access"]' \
  "$(cat <<'PROMPT'
[Persona + rubric + format instructions]
Read ONLY ./Proposal.md. Do NOT read files in ./ideation/.
Write your review to ./ideation/reviews/iteration-N/R2-gpt.md
PROMPT
)"
```

### OpenCode Reviewers (R3, R4, R5)
```bash
# Use the model selected dynamically in Step 1c
timeout 300 opencode run \
  -m <selected-provider/model> \
  "[Persona + rubric + format instructions. Read ONLY ./Proposal.md. Write review to ./ideation/reviews/iteration-N/RX-<family>.md]"
```

### Handling Failures

After dispatching all reviewers in parallel (via background Bash with `run_in_background`):
1. Wait for each reviewer to complete (up to 5 min timeout)
2. Check if the expected review file was created and is non-empty
3. If missing or empty: log the failure reason, trigger the next fallback in the chain
4. Continue until at least 3 valid reviews are collected

Save each review to `./ideation/reviews/iteration-N/RX-[family].md`.

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
2. Write the full aggregation report (with scores) to `./ideation/reviews/iteration-N/aggregation.md`
3. Write `./ideation/review-feedback-N.md` with the gate result: `GATE: PASS`
4. **Explicitly invoke the ideation skill** to generate final output files by passing this instruction:
   > "The review panel has issued a PASS. Read `./Proposal.md` and generate the three final output files: `./Proposal.html` (English, styled HTML with KaTeX), `./Proposal_cn.html` (Chinese translation, styled HTML with KaTeX), and `./reference.bib` (BibTeX). Follow the HTML rendering rules in the Research Proposal Output section exactly. Do not alter `./Proposal.md`."
5. **Validate outputs**: after the ideation skill completes, verify all four files exist and are non-empty:
   ```bash
   test -s ./Proposal.md && echo "OK" || echo "MISSING: Proposal.md"
   test -s ./Proposal.html && echo "OK" || echo "MISSING: Proposal.html"
   test -s ./Proposal_cn.html && echo "OK" || echo "MISSING: Proposal_cn.html"
   test -s ./reference.bib && echo "OK" || echo "MISSING: reference.bib"
   ```
6. If any file is missing or empty: re-issue the generation instruction for that specific file only. Repeat up to 2 times.

### FAIL (below threshold)
1. Update `./ideation/state.md`: `Phase: revision-N`
2. Write the qualitative feedback file (scores stripped)
3. Increment iteration counter
4. If iteration count < 10: signal the ideation model to revise
5. If iteration count = 10: force-proceed with caveat note

### Force-Proceed (after 10 iterations)
1. Update `./ideation/state.md`: `Phase: Done`
2. Add caveat note to the feedback: "The review panel did not reach consensus on readiness after 10 rounds. The following concerns remain unresolved: [list]"
3. **Explicitly invoke the ideation skill** to generate final output files with caveat by passing this instruction:
   > "The review panel has exhausted 10 revision rounds without reaching consensus. Read `./Proposal.md` and generate the three final output files: `./Proposal.html`, `./Proposal_cn.html`, and `./reference.bib`. Add the following caveat at the top of Section 9 in all three files: 'NOTE: This proposal did not pass the review gate after 10 rounds. Remaining reviewer concerns: [list from feedback].'"
4. **Validate outputs** (same bash check as in PASS step 5). Retry up to 2 times if any file is missing.

---

## Reference Files

Load on demand:
- `references/conference-readiness.md` — scoring rubric with dimension definitions and thresholds
- `references/review-protocol.md` — aggregation rules, feedback synthesis templates, split decision handling
