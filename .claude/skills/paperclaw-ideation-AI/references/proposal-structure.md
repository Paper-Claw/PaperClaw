# Proposal Structure Template

> **Template file:** `references/proposal-template.md` contains the authoritative Proposal.md skeleton. This file provides the full structure with detailed generation instructions. When in doubt, follow the template file for structure and this document for content guidance.

**Citation convention:** All sections use in-text citations as "[N]" referencing the numbered list in Section 10. Every paper mentioned by name MUST have a corresponding entry in Section 10 and in `./reference.bib`.

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
[Structured survey organized by method category. For EACH category, produce a
dedicated table — do NOT use prose paragraphs.

### 3.1 [Category Name 1]
| Venue/Year | Paper | Technical Summary | Gap for Our Problem |
|-----------|-------|-------------------|---------------------|
| ... | ... | 1-2 sentences: what they do, how | What limitation remains relevant to our research question |

### 3.2 [Category Name 2]
| Venue/Year | Paper | Technical Summary | Gap for Our Problem |
|-----------|-------|-------------------|---------------------|
| ... | ... | ... | ... |

(Repeat for 2-4 method categories, 3-8 papers per table.)

### Research Gap Summary
[One paragraph synthesizing the gaps from all tables into the specific niche
this proposal fills. This paragraph should make it crystal clear why existing
methods are insufficient and what opportunity remains.]

Reference specific papers from ./ideation/papers.md and ./ideation/literature.md.
Use in-text citations as "[N]" referencing the numbered list in Section 10.]

## 4. Theoretical Analysis

**CRITICAL: Proposal.md is the ONLY material the review panel sees.** They cannot access
`./ideation/theory.md`, `./ideation/lean4/`, or any working files. Therefore, Section 4
must be **completely self-contained** — every definition, every proof step, every Lean 4
source file must be fully embedded here. Do NOT summarize or abbreviate. Completeness
is more important than brevity in this section.

### 4.1 Why This Theory Is Needed
[1-2 paragraphs explaining:
- What specific limitation of existing methods this theory addresses
- Why a theoretical foundation (not just empirical results) is necessary
- How the theoretical results prove the method's superiority or correctness,
  or demonstrate that existing methods are provably insufficient
- What would go wrong without this theoretical grounding
This subsection bridges Sections 2-3 (problems/gaps) and the formal results below.]

### 4.2 Mathematical Foundation
[Problem formalization with precise notation. This must be rigorous and complete:
- Define ALL notation used in subsequent proofs (variable names, spaces, operators)
- Define the input space, output space, and objective function formally
- State all constraints and assumptions explicitly
- Provide the formal mathematical model of the proposed solution
- Include key definitions (Definition 1, Definition 2, ...) that proofs depend on
- If the method introduces new mathematical objects, define them precisely here

Target: complete enough that a reviewer can follow every proof below without
needing any external reference.]

### 4.3 Main Theoretical Results
[For EACH theorem/proposition, provide ALL of the following in full:

**Theorem N: [Name]**

- **Assumptions:** List every assumption required (numbered A1, A2, ... for
  cross-referencing). State whether each assumption is standard or novel.

- **Statement:** Formal mathematical statement with all variables defined.
  Self-contained — a reader should understand this without reading prior sections.

- **Proof Outline:** 3-5 step high-level proof strategy (always visible in all formats).

- **Detailed Proof:** Complete, step-by-step proof with ALL intermediate steps
  justified. Do NOT skip steps or write "it is easy to see that..." — every
  derivation must be explicit. Include:
  - Key lemmas (stated and proved inline if not standalone)
  - All algebraic manipulations shown
  - References to which assumptions are used at each step
  - Connections to known results (with citations)
  In Proposal.md: inline, fully expanded.
  In HTML files: inside a collapsible `<details>` block, default collapsed.

- **Lean 4 Verification:** This subsection must include:
  1. **Status:** FULL PASS / PARTIAL PASS (with sorry count) / FAIL (with explanation)
  2. **Complete Lean 4 source code:** The FULL `.lean` file content, not a summary.
     Include all imports, definitions, and proof terms. In Proposal.md: as a fenced
     ```lean code block. In HTML: inside a collapsible `<details>` block.
  3. **Verification log:** The `lake build` output (success or error messages)
  4. **Sorry items** (if any): List each `sorry` with an explanation of why it
     could not be discharged and what it would require
  5. **Gap analysis** (if PARTIAL/FAIL): What the gap between the paper proof and
     the Lean proof tells us about the claim's robustness

- **Implications:** What this result means for the proposed method; how it addresses
  a specific gap from Section 3. What would change in the method design if this
  result did not hold.

Explicitly state all assumptions required for each result.
Source: copy FULL content from ./ideation/theory.md + ./ideation/lean4/
Target: 1-3 theorems/propositions with COMPLETE proofs and COMPLETE Lean 4 code.]

### 4.4 Verification Summary

| Theorem | Formalizable? | Lean 4 Status | Sorry Count | Key Insight |
|---------|--------------|---------------|-------------|-------------|
| Theorem 1: [Name] | Yes/Partially | PASS/PARTIAL/FAIL | N | [what verification revealed] |
| ... | ... | ... | ... | ... |

[If any claims were not formalized in Lean 4, explain WHY for each one
(e.g., requires dependent types not yet in Mathlib, involves probabilistic
reasoning beyond current Lean 4 libraries, etc.). The review panel will
independently assess whether the justification is valid.]

## 5. Proposed Method

### 5.1 Overview
[High-level overview: algorithm flow or architecture diagram.
Use Mermaid diagrams for flowcharts, architecture overviews, and pipeline diagrams.
Pseudocode for the core algorithm.]

### 5.2 Component Details
[For EACH key component or design choice, provide ALL of the following:
1. **What**: Technical description of the component
2. **Why this design**: What specific problem or limitation motivated this choice
   (reference specific papers/methods from Section 3 that have this limitation)
3. **Why not alternatives**: What simpler or more obvious approaches were considered
   and why they are insufficient
4. **Advantage**: What concrete benefit this design provides (theoretical guarantee,
   efficiency gain, robustness property, etc.)]

### 5.3 Training / Inference Procedure
[Step-by-step procedure with enough detail for implementation.
Key hyperparameters and their roles.]

### 5.4 Design Rationale Summary
| Component | Addresses Limitation Of | Advantage Over Alternative |
|-----------|------------------------|---------------------------|
| [component 1] | [method X from Section 3] lacks... | [concrete advantage] |
| [component 2] | [method Y from Section 3] fails when... | [concrete advantage] |
| ... | ... | ... |

Target: 4-7 paragraphs + pseudocode + rationale table.]

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
are expected and why?]

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

## 9. Alternative Directions & Auto-Decisions
[This section is generated from ./ideation/questions.md. It provides full
transparency into every autonomous decision made during the ideation process.

**IMPORTANT:** The Context column is MANDATORY and must NOT be summarized or truncated.
It is the user's primary way to evaluate whether auto-decisions were well-founded and
to identify alternative exploration directions.]

### Decision Log

| # | Phase | Question | Context (Background + Options + Evidence) | Auto-Choice | Reasoning | Confidence |
|---|-------|----------|------------------------------------------|-------------|-----------|------------|
| 1 | Phase 0 | What problem? | [field survey findings: key papers, open challenges, gaps identified] | [choice] | [why] | High/Med/Low |
| 2 | Phase 0 | Why important? | [field survey findings on community interest, practical impact] | [choice] | [why] | High/Med/Low |
| ... | ... | ... | ... | ... | ... | ... |
| N | Phase 2.5 | Direction | **Options:** A: [title] (★★★★★) / B: [title] (★★★☆☆) / C: [title] (★★☆☆☆). **Evidence:** [feasibility scout summary] | Direction X | [why] | High |

**Generation rule:** When generating Section 9, read `./ideation/questions.md` entry by entry.
For each decision, the Context column MUST contain:
- For Phase 0 decisions: the field survey findings that informed the inference
- For Phase 2/2.5 decisions: ALL proposed options with their feasibility scores
- For Phase 4 decisions: the theoretical claims, Lean 4 results, and error analyses
- For Gate decisions: the full score card with per-dimension justifications

### Explored but Not Chosen

#### Direction [Y]: [Title]
- Core claim: ...
- Feasibility profile: ...
- Why not chosen: ...
- Under what conditions it becomes better: ...

#### Direction [Z]: [Title]
- ...

### How to Override
To modify any decision, re-invoke this skill with instructions like:
- "重新运行 ideation，修改决策 #N 为 [你的选择]"
- "Re-run ideation, override decision #N: [your choice]"

The pipeline will re-run from the earliest affected phase forward.

## 10. References
[Complete numbered reference list of all papers cited in the proposal.
Every paper mentioned by name in Sections 1-7 MUST appear here.

Format: numbered list, sorted by first author surname.

[1] Author(s). "Paper Title." Venue, Year.
[2] Author(s). "Paper Title." Venue, Year.
...

In-text citations throughout Sections 1-7 should use "[N]" format referencing
this list (e.g., "POMO [3] exploits solution symmetries...").

Source: ./ideation/papers.md and ./ideation/literature.md]
```

**Proposal Appendix sections (inside Proposal.md):**

```markdown
### Appendix A. Review Panel Summary
[Populated by the review-gate orchestrator after review passes. Contains aggregated
reviewer feedback themes and final decision. The ideation model does not generate
this section — it is filled in by the orchestrator.]

### Appendix B. Timeline
- Month 1-2: ...
- Month 3-4: ...
- Month 5-6: ...

### Appendix C. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
```
