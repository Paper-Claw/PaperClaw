# Report Writing Guide

## Style Guidelines

### report.md (Detailed, for Paper Writing)
- **Audience**: The author (you), writing the paper later
- **Tone**: Technical, precise, data-rich
- **Detail level**: Include every number, every configuration detail
- **Length**: As long as needed — this is a reference document
- **Code references**: Include file:line references for key implementations
- **Tables**: Full tables with all metrics, all datasets, all methods

### report.html (English, for User Review)
- **Audience**: Collaborators, advisors, quick review
- **Tone**: Clear, professional, well-organized
- **Detail level**: Key results and insights, hide details in collapsible sections
- **Length**: Readable in 10-15 minutes
- **Visual**: Clean tables, color-coded metrics, responsive layout
- **Collapsible**: Use `<details>` for iteration logs, full configs, etc.

### report_cn.html (Chinese, for User Review)
- **Audience**: Chinese-speaking collaborators
- **Tone**: Academic Chinese, natural expression
- **Translation rules**:
  - Keep method names in English: "Transformer", "BERT", "GPT"
  - Keep dataset names in English: "CIFAR-10", "ImageNet"
  - Keep metric names in English: "Accuracy", "F1 Score"
  - Translate section headers with English in parentheses
  - Use Chinese punctuation (，。；：)
  - Numbers and units in English/Arabic numerals

## Section-Specific Writing Tips

### Method Design Section
- Start with a one-paragraph overview
- Use a figure reference if architecture diagram exists
- Map each component to its code file
- Include the loss function with LaTeX notation
- Describe the training procedure step by step

### Dataset Section
- Use a consistent table format
- Include citation for each dataset
- Mention any non-standard preprocessing
- State the evaluation metric used for each dataset

### Comparison Methods Section
- 2-3 sentences per method: what it is, core idea, limitation
- Group by approach type if there are many baselines
- Include venue and year for credibility

### Experimental Results Section
- Each experiment gets its own subsection
- Start with "Purpose" — what question does this experiment answer?
- Present the table
- End with "Analysis" — what do the numbers tell us?
- Highlight our best numbers in bold
- Use color coding in HTML: green for improvements, red for degradations

### Conclusion Section
- Lead with the strongest result
- Use exact numbers: "improves by X.X% over the previous SOTA"
- Cover three dimensions: performance, robustness, efficiency
- Be honest about limitations

### Execution Log Section
- Bullet-point format for readability
- Group by method/phase
- Focus on non-trivial challenges and their solutions
- This section is valuable for reproducibility discussions in the paper

## HTML Rendering Details

### Table Styling
```html
<!-- Highlight best result in each column -->
<td style="font-weight: bold; color: #2c3e50;">86.5</td>

<!-- Show improvement -->
<td><span class="metric-up">+2.3</span></td>

<!-- Show degradation -->
<td><span class="metric-down">-0.5</span></td>
```

### Collapsible Sections
```html
<details>
  <summary>Click to expand: Iteration details for MethodA reproduction</summary>
  <div>
    <!-- Detailed iteration log content -->
  </div>
</details>
```

### Figure Embedding
```html
<!-- If figures are available as base64 or local files -->
<figure>
  <img src="data:image/png;base64,..." alt="t-SNE visualization" style="max-width: 100%;">
  <figcaption>Figure 1: t-SNE visualization of learned representations.</figcaption>
</figure>
```
