# Literature Search Strategies

A systematic approach to literature search that helps researchers efficiently find relevant papers.

## 1. Keyword Construction

### 1.1 Core Concept Identification

Extract core concepts from the research interest:

**Example**: Research interest "Transformer model interpretability"
- Core concept 1: Transformer
- Core concept 2: Interpretability / Explainability

### 1.2 Synonyms and Variants

List synonyms and variants for each core concept:

| Core Concept | Synonyms / Variants |
|-------------|---------------------|
| Transformer | Attention mechanism, Self-attention, BERT, GPT |
| Interpretability | Explainability, Transparency, Understanding |

### 1.3 Boolean Operators

Combine keywords using Boolean operators:

```
(Transformer OR "attention mechanism" OR BERT OR GPT)
AND
(interpretability OR explainability OR transparency)
```

### 1.4 Domain-Specific Terminology

Add domain-specific terms:

- **Method terms**: probing, attention visualization, saliency maps
- **Application domains**: NLP, computer vision, speech recognition
- **Evaluation metrics**: faithfulness, plausibility, human evaluation

## 2. Academic Database Selection

See `references/domain.md` "Primary Databases" for the full database list with strengths and use cases.

### Search Strategies

**arXiv search** (use arXiv categories from `references/domain.md`):
```
cat:[CATEGORY] AND ([keyword1] OR [keyword2]) AND ([keyword3] OR [keyword4])
```

**Google Scholar search**:
- Use quotes for exact matching: "transformer interpretability"
- Restrict time range: 2022-2026
- Exclude patents: -patent

## 3. Search Techniques

### 3.1 Iterative Search

1. **Initial search** — Use core keywords
2. **Analyze results** — Check keywords from highly-cited papers
3. **Refine query** — Add newly discovered terms
4. **Repeat** — Until enough relevant papers are found

### 3.2 Citation Tracking

**Forward citation**:
- Check which newer papers cite this paper
- Understand follow-up developments

**Backward citation**:
- Check which papers this paper cites
- Understand the foundational context

### 3.3 Author Tracking

- Identify key researchers in the field
- Check their other related work
- Follow their latest publications

## 4. Paper Screening Criteria

### 4.1 Initial Screening (based on title and abstract)

**Inclusion criteria**:
- Directly relevant to the research topic
- Published at top venues (see `references/domain.md` "Top Venue Filter")
- High citation count (relative to publication date)

**Exclusion criteria**:
- Unrelated to the research topic
- Published in low-quality venues
- Clearly outdated methods (unless they are foundational papers)

### 4.2 Deep Screening (based on full text)

**Quality assessment**:
1. **Methodological innovation** — Does it propose a new method or perspective?
2. **Experimental rigor** — Is the experimental design sound and the results credible?
3. **Writing quality** — Is the paper clear and well-written?
4. **Reproducibility** — Are code and data provided?

## 5. DOI Extraction for Paper Indexing

### 5.1 DOI Extraction Methods

**DOI from URL patterns**:
- `https://doi.org/10.xxxx/xxxxx` — Direct DOI link
- `https://dl.acm.org/doi/10.xxxx/xxxxx` — ACM Digital Library
- `https://arxiv.org/abs/xxxx.xxxxx` — arXiv (DOI format: `10.48550/arXiv.xxxx.xxxxx`)
- `https://ieeexplore.ieee.org/document/xxxxx` — IEEE (extract from page)

### 5.2 Handling Papers Without DOI

- **arXiv preprints**: Use `10.48550/arXiv.{id}` format
- **Conference proceedings**: Try to locate DOI from the publisher page
- **No DOI available**: Record the paper URL and metadata manually
