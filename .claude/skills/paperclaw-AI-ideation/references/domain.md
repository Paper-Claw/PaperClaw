# Domain Configuration: AI / Machine Learning

This file defines all domain-specific parameters for the research ideation skill.
To adapt this skill for a different research domain, replace this file with one tailored to the target field.

---

## Target Venues

### Top Conferences

| Venue | Area | Review Cycle | Key Traits |
|-------|------|-------------|------------|
| NeurIPS | Machine Learning | ~3 months | Theory + experiments, code expected |
| ICML | Machine Learning | ~3 months | Strong theory preferred |
| ICLR | Representation Learning | ~3 months | Open review, reproducibility |
| ACL / EMNLP / NAACL | NLP | ~3 months | Linguistic motivation, human eval |
| KDD | Data Mining / Applied ML | ~3 months | Real-world scale, industry data |
| AAAI | General AI | ~3 months | Broad AI scope |
| CVPR / ECCV / ICCV | Computer Vision | ~3 months | Visual results, standard benchmarks |

### Top Journals

| Venue | Area | Review Cycle | Key Traits |
|-------|------|-------------|------------|
| Nature / Science / Cell | Broad science | 3-6+ months | Conceptual novelty, broad impact, Significance ≥ 4 |
| PNAS | Cross-disciplinary | 2-4 months | Three review tracks, NAS sponsorship for contributed |

### Top Venue Filter (for literature screening)

NeurIPS, ICML, ICLR, ACL, AAAI, KDD (last 3 years)

---

## Venue-Specific Reviewer Priorities

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

---

## Venue Selection Decision Guide

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

---

## Search Configuration

### Primary Databases

| Database | Strength | When to Use |
|----------|----------|-------------|
| arXiv | Preprints, fast updates | Latest research |
| Semantic Scholar | Citation graph, influence | Impact analysis |
| Google Scholar | Broadest coverage | General search |
| OpenReview | Peer reviews, acceptance decisions | Venue-specific review quality, rejected/accepted paper analysis |
| ACL Anthology | NLP-focused | NLP domain deep search |
| IEEE Xplore | Engineering-focused | Hardware/systems papers |

### arXiv Categories

- cs.LG (Machine Learning)
- cs.CV (Computer Vision)
- cs.CL (Computational Linguistics)
- cs.AI (Artificial Intelligence)
- stat.ML (Statistics - Machine Learning)

### arXiv Search Example

```
cat:cs.LG AND (transformer OR attention) AND (interpretability OR explainability)
```

---

## Resource Estimates

### Compute

- Proof-of-concept: < 200 GPU-hours, single GPU OK
- Full experiments: 4-8 GPUs typical
- Reduce cost: use pretrained backbone (e.g., BERT, ResNet, GPT-2)

### Feasibility Signals

- "Single GPU OK" = high feasibility
- "Needs 8×A100" = low feasibility
- Standard train/dev/test splits preferred

---

## Domain Examples

These examples are used in reference files to illustrate domain-agnostic frameworks (5W1H, gap analysis, SMART questions). When adapting this skill for a new domain, replace these with domain-appropriate examples.

### Example Research Topic

"EEG-based emotion recognition"

### Example Search Queries

- `"EEG emotion recognition" survey OR review 2024 2025`
- `"affective computing" EEG deep learning NeurIPS OR ICML OR ICLR`
- `"EEG decoding" benchmark dataset state-of-the-art`

### Example 5W1H

| Dimension | Example |
|-----------|---------|
| What | Study the interpretability of Transformer attention mechanisms |
| Why | Transformers are widely deployed but lack interpretability |
| Who | NLP researchers, model safety community |
| When | 6-12 months; Transformers are widely deployed but lack interpretability |
| Where | Text classification, machine translation, QA systems, and other NLP tasks |
| How | Probing, attention visualization, saliency maps, ablation experiments |

### Example 5W1H (Alternative Topic)

| Dimension | Example |
|-----------|---------|
| What | Explore the effectiveness of few-shot learning methods in medical image diagnosis |
| Why | Medical data annotation is expensive; few-shot learning can reduce data requirements |
| Who | Medical AI researchers, radiologists, hospitals |
| When | 12-18 months, as few-shot learning techniques mature |
| Where | X-ray, CT scan, MRI, and other medical imaging diagnosis |
| How | Meta-learning, transfer learning, data augmentation; validate on real medical datasets |

### Example Gap Analysis

| Gap Type | Example |
|----------|---------|
| Literature gap | Application of Transformers to time-series forecasting is under-studied |
| Methodological gap | Existing attention mechanisms are inefficient on long sequences |
| Application gap | Few-shot learning in medical imaging is still in its early stages |
| Application gap | Self-supervised learning for industrial quality inspection is under-explored |
| Interdisciplinary gap | Cross-fertilization between cognitive science and deep learning |
| Temporal gap | Prompt engineering research in the era of large language models |

### Example SMART Research Questions

| Quality | Example |
|---------|---------|
| Bad (too broad) | How can we improve model performance? |
| Good (specific) | How can we improve Transformer performance on long-text understanding tasks by refining the attention mechanism? |

### Example Measurability

| Vague | Specific |
|-------|----------|
| Improve performance | Improve F1 score on SQuAD |
| Improve interpretability | Improve faithfulness score in human evaluation |

### Example Evaluation Metrics

- **Quantitative**: accuracy, F1, BLEU, perplexity
- **Qualitative**: human evaluation, case analysis
- **Efficiency**: training time, inference speed, memory usage

### Example Resource Assessment

- Compute resources: GPU quantity and type
- Data resources: Dataset availability and quality
- Time resources: Research timeline (3 months, 6 months, 1 year)

### Example Exploratory Question

"What patterns does the Transformer attention mechanism exhibit when processing long texts?"

### Example Confirmatory Question

"Does increasing model depth improve long-text understanding performance?"
