# Research Question Formulation

A systematic method for transforming research interests into specific, actionable research questions.

## 1. SMART Criteria

A good research question should satisfy the SMART criteria:

### 1.1 Specific

**Bad question**:
- "How to improve model performance?" (too broad)

**Good question** (see `references/domain.md` "Example SMART Research Questions" for domain-appropriate examples):
- Clearly names the research subject, improvement direction, task scenario, and objective

**Key elements**:
- Clear research subject
- Specific direction for improvement
- Defined task scenario
- Clear objective

### 1.2 Measurable

The research question should have clear evaluation criteria:

**Examples**:
See `references/domain.md` "Example Measurability" and "Example Evaluation Metrics" for domain-appropriate examples.

**Evaluation dimensions**:
- Quantitative metrics (domain-specific — see `references/domain.md`)
- Qualitative metrics: human evaluation, case analysis
- Efficiency metrics: training time, inference speed, memory usage

### 1.3 Achievable

Consider resource and capability constraints:

**Resource assessment**:
- Compute resources: domain-standard compute resources (see `references/domain.md` "Resource Estimates")
- Data resources: Dataset availability and quality
- Time resources: Research timeline (3 months, 6 months, 1 year)

**Feasibility checklist**:
- Is there similar work to build upon?
- Is the required technology mature enough?
- Are the datasets publicly available?
- Is the compute cost within budget?

### 1.4 Relevant

The research question should have value for academia or industry:

**Academic value**:
- Fills a research gap
- Challenges existing assumptions
- Provides new theoretical perspectives
- Advances methodology

**Practical value**:
- Solves real application problems
- Improves system performance
- Reduces cost or resource consumption

### 1.5 Time-bound

Set a reasonable research timeline:

**Short-term goals** (1-3 months):
- Literature survey and problem definition
- Preliminary experiments and proof of concept

**Mid-term goals** (3-6 months):
- Method development and optimization
- Comprehensive experiments and analysis

**Long-term goals** (6-12 months):
- Paper writing and submission
- Code open-sourcing and community outreach

## 2. Research Question Types

### 2.1 Exploratory Questions

**Characteristics**: Explore unknown territory, discover new phenomena

**Example**:
- See `references/domain.md` "Example Exploratory Question" for a domain-appropriate example

**Best suited for**:
- Emerging research areas
- Phenomena lacking theoretical foundations

### 2.2 Confirmatory Questions

**Characteristics**: Validate hypotheses or theories

**Example**:
- "Does increasing model depth improve long-text understanding performance?"

**Best suited for**:
- Clear hypotheses that need validation
- Challenging existing theories or assumptions

### 2.3 Applied Questions

**Characteristics**: Solve practical application problems

**Example**:
- "How can we reduce model size by 50% while maintaining performance?"

**Best suited for**:
- Clear application requirements
- Industry collaboration projects

## 3. Research Question Evaluation Criteria

### 3.1 Significance

**Scoring criteria** (1-5):
- 5: Breakthrough question, impacts the entire field
- 4: Important question, multiple research groups interested
- 3: Valuable question, some researchers interested
- 2: Marginal question, few people interested
- 1: Trivial question, almost nobody interested

### 3.2 Novelty

**Scoring criteria** (1-5):
- 5: Entirely new problem or breakthrough method
- 4: New problem or significantly improved method
- 3: New perspective or method combination
- 2: Incremental improvement
- 1: Duplicates existing work

### 3.3 Feasibility

**Scoring criteria** (1-5):
- 5: Fully feasible, ample resources
- 4: Generally feasible, sufficient resources
- 3: Challenging but doable, requires effort
- 2: Significant difficulty, requires breakthroughs
- 1: Nearly infeasible

### 3.4 Decision Matrix

| Significance | Novelty | Feasibility | Recommendation |
|-------------|---------|-------------|----------------|
| High | High | High | Execute immediately |
| High | High | Medium | Worth attempting |
| High | Medium | High | Safe choice |
| Medium | High | High | Worth considering |
| Low | * | * | Reconsider |
