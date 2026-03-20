# HTML Rendering Rules

> **Template file:** `references/proposal-html-template.html` contains the authoritative HTML/CSS template with KaTeX, Mermaid, and collapsible section styling. Use it as the base when generating Proposal.html and Proposal_zh.html.

The HTML files (`Proposal.html` and `Proposal_zh.html`) must include basic CSS styling (clean typography, section numbering, table borders, math rendering via KaTeX CDN) for readability.

## Collapsible Sections

Use `<details>` and `<summary>` elements for:

1. **Detailed proofs** (Section 4): Each theorem's detailed proof wrapped in a collapsible block. Proof outline remains visible. Default: **collapsed**.
   ```html
   <details>
   <summary>Detailed Proof of Theorem N</summary>
   <div class="proof">[Full proof content with KaTeX math]</div>
   </details>
   ```

2. **Lean 4 verification code** (Section 4): `.lean` source for each theorem in a collapsible block. Default: **collapsed**.
   ```html
   <details>
   <summary>Lean 4 Verification Code — Theorem N</summary>
   <pre><code class="language-lean">[Lean 4 source from ./ideation/lean4/IdeationProofs/]</code></pre>
   <p><strong>Status:</strong> [FULL PASS / PARTIAL PASS (sorry items: ...) / FAIL]</p>
   </details>
   ```

3. **CSS for collapsible sections** (add to the `<style>` block):
   ```css
   details { margin: 1em 0; border: 1px solid #ddd; border-radius: 6px; padding: 0.5em 1em; }
   details[open] { background: #fafafa; }
   summary { cursor: pointer; font-weight: bold; color: #2c3e50; padding: 0.3em 0; }
   summary:hover { color: #3498db; }
   .proof { margin-top: 0.5em; padding-left: 1em; border-left: 3px solid #3498db; }
   ```

## Markdown vs. HTML Differences

The Markdown file (`Proposal.md`) includes everything inline with no collapsing:
- **Proof outlines:** always visible
- **Detailed proofs:** fully expanded inline, every step shown
- **Lean 4 source code:** complete `.lean` file content in fenced ```lean blocks (NOT summaries — the FULL source)
- **Verification logs:** `lake build` output included
- **Sorry analysis:** each `sorry` item explained if any exist

This is critical because Proposal.md is the ONLY material the review panel receives.
