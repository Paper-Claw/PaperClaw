# Baseline Reproduction Guide

## Common Pitfalls & Solutions

### 1. Data Preprocessing Mismatch

**Symptom**: Results consistently off by a fixed margin.

**Checks**:
- Tokenization method (BPE vs WordPiece vs SentencePiece)
- Text normalization (lowercasing, punctuation handling)
- Feature normalization (z-score vs min-max vs none)
- Train/val/test split ratios and method (random vs chronological vs stratified)
- Data filtering criteria (min/max length, quality filters)

**Fix**: Read the paper's appendix and supplementary material carefully. Check the official repo's data preprocessing scripts.

### 2. Hyperparameter Discrepancy

**Symptom**: Training converges but to a worse optimum.

**Checks**:
- Learning rate and schedule (warmup steps, decay type)
- Batch size (effective batch size with gradient accumulation)
- Weight decay, dropout rates
- Number of epochs / training steps
- Early stopping criteria

**Fix**: Use exact hyperparameters from paper Table/Appendix. If not available, check the official repo's config files or run scripts.

### 3. Framework Version Issues

**Symptom**: Errors during execution or subtly different behavior.

**Checks**:
- PyTorch version (attention implementation changed across versions)
- CUDA version compatibility
- Transformers library version (tokenizer behavior changes)
- NumPy/SciPy version (random number generation changes)

**Fix**: Check repo's requirements.txt or setup.py for pinned versions. Consider using Docker if available.

### 4. Evaluation Protocol Mismatch

**Symptom**: Our metric computation gives different numbers even on same predictions.

**Checks**:
- Metric implementation (custom vs sklearn vs official evaluation script)
- Macro vs micro vs weighted averaging
- Handling of edge cases (empty predictions, ties)
- Post-processing before evaluation (decoding strategy, thresholding)

**Fix**: Use the paper's official evaluation script if provided. Verify on a small known example first.

### 5. Random Seed Sensitivity

**Symptom**: Results vary significantly across runs.

**Checks**:
- Paper may report best run, not average
- Some methods are inherently unstable (GAN, RL)
- Data shuffling order can matter

**Fix**: Run 3-5 seeds and compare mean to reported numbers. If paper reports a single number, compare against our best run.

## Reproduction Tolerance

| Metric Type | Acceptable Δ (absolute) | Acceptable Δ (relative) |
|-------------|--------------------------|--------------------------|
| Accuracy (%) | ±1.0 | ±2% |
| F1 Score | ±0.01 | ±2% |
| BLEU | ±0.5 | ±2% |
| ROUGE | ±0.5 | ±2% |
| MSE/MAE | ±5% | ±5% |
| Perplexity | ±2.0 | ±3% |

## When to Give Up

After 5 honest attempts with different strategies:
1. Document the best achieved result and the gap
2. Note what was tried and why it didn't work
3. Check if other papers report similar reproduction difficulties
4. Ask the user for guidance:
   - Accept the gap and proceed
   - Try a fundamentally different approach
   - Use the paper's reported numbers as reference (with a note)
   - Skip this baseline entirely
