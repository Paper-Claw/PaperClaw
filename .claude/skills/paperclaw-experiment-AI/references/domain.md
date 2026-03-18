# Domain Configuration for Experiments

## Target Venues & Experiment Expectations

### NeurIPS / ICML / ICLR
- **Baselines**: At least 3-5 strong recent baselines (within 2 years)
- **Datasets**: Standard community benchmarks (not toy datasets)
- **Metrics**: Must include primary metric used by the community
- **Ablation**: Component-level ablation required
- **Statistical significance**: Multiple runs with mean ± std preferred
- **Reproducibility**: Code and configs must be shareable

### ACL / EMNLP / NAACL
- **Baselines**: Include both classic and SOTA methods
- **Datasets**: Multiple datasets across different domains/languages
- **Metrics**: Task-specific (BLEU, ROUGE, F1, etc.)
- **Analysis**: Error analysis / qualitative examples expected
- **Human evaluation**: Often expected for generation tasks

### KDD / AAAI
- **Baselines**: Include both ML and domain-specific methods
- **Scalability**: Efficiency experiments often required
- **Real-world**: Industrial applicability appreciated

### Nature / Science / Cell / PNAS
- **Baselines**: Comprehensive comparison with field standards
- **Datasets**: Multiple independent datasets for validation
- **Statistical rigor**: Proper statistical tests, p-values, effect sizes
- **Visualization**: Publication-quality figures
- **Reproducibility**: Detailed methods and supplementary materials

## Experiment Quality Checklist

### Must-Have
- [ ] All baselines from Proposal.md are reproduced
- [ ] Results on ALL specified datasets
- [ ] Primary metric reported for each experiment
- [ ] Ablation study covering key components
- [ ] Fair comparison (same data splits, preprocessing, evaluation protocol)

### Should-Have
- [ ] Multiple random seeds (≥3) with std reported
- [ ] Statistical significance tests
- [ ] Efficiency comparison (time, memory, parameters)
- [ ] Visualization (t-SNE, attention, etc.)
- [ ] Error analysis / failure cases

### Nice-to-Have
- [ ] Hyperparameter sensitivity analysis
- [ ] Scaling experiments (data size, model size)
- [ ] Cross-domain / transfer experiments
- [ ] Real-world deployment metrics
