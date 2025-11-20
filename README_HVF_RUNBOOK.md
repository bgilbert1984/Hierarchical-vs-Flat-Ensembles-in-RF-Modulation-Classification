# Hierarchical vs Flat Ensembles - Quick Runbook

This document outlines the complete automation pipeline for Paper 11: "Hierarchical vs Flat Ensembles".

## Overview

The system automatically generates LaTeX tables comparing hierarchical and flat ensemble approaches by:
1. Running classification evaluation on both approaches
2. Collecting latency and accuracy metrics with breadcrumb tracking 
3. Generating camera-ready LaTeX tables from JSON metrics
4. Automatically rebuilding tables when metrics change via Git hooks

## Quick Start

### 1. Evaluate Classification Performance

```bash
# Run evaluation with real classifier (if available)
python3 paper_Hier_vs_Flat_Ensembles/scripts/hvf_eval.py \
  --cfg '{"hierarchical_enabled": true, "specialized_models_path": "models"}' \
  --limit 5000 \
  --out paper_Hier_vs_Flat_Ensembles/data/hier_vs_flat_metrics.json

# OR generate mock data for testing
python3 paper_Hier_vs_Flat_Ensembles/scripts/hvf_eval.py \
  --mock \
  --limit 1000 \
  --out paper_Hier_vs_Flat_Ensembles/data/hier_vs_flat_metrics.json
```

### 2. Render LaTeX Tables

```bash
# Generate tables from metrics JSON
make -C paper_Hier_vs_Flat_Ensembles tables-hvf
```

### 3. Build Complete Paper

```bash
# Build paper with figures and tables
make -C paper_Hier_vs_Flat_Ensembles pdf
```

## Automation Features

### Git Hooks (Auto-regeneration)

When `hier_vs_flat_metrics.json` is committed, tables are automatically regenerated:

```bash
# Hooks are already installed - just commit changes
git add paper_Hier_vs_Flat_Ensembles/data/hier_vs_flat_metrics.json
git commit -m "Update HVF evaluation metrics"
# Tables automatically regenerated and included in commit
```

### Pre-commit Framework Integration

The system integrates with the existing pre-commit framework:

```bash
# Already configured in .pre-commit-config.yaml
pre-commit run hvf-tables --all-files
```

## File Structure

```
paper_Hier_vs_Flat_Ensembles/
├── code/
│   ├── hierarchical_ml_classifier.py    # Main classifier with breadcrumb logging
│   ├── hierarchical_classifier.py       # Standalone classifier script
│   └── core.py                         # Signal processing framework
├── data/
│   └── hier_vs_flat_metrics.json       # Evaluation results JSON
├── scripts/
│   ├── hvf_eval.py                     # Evaluation runner
│   ├── render_hvf_tables.py            # Table generator
│   ├── gen_figs_hier_vs_flat.py        # Figure generator
│   └── hvf_pre_commit.sh               # Git hook script
├── tables/                             # Generated LaTeX tables
│   ├── hvf_wins_table.tex
│   └── hvf_latency_table.tex
├── figs/                               # Generated figures
├── Makefile                            # Build automation
└── main_hier_vs_flat.tex               # Paper LaTeX source
```

## Metrics Collected

### Classification Performance
- **Per-class wins**: Which approach (hier/flat) performs better per modulation type
- **Confusion matrices**: Detailed classification results for both approaches
- **Overall accuracy**: Aggregate performance metrics

### Latency Analysis
- **Base latency**: Time for flat/baseline classification
- **Specialized latency**: Additional time for hierarchical specialized models
- **Total latency**: End-to-end classification time
- **Percentile analysis**: P50, P95 latency distributions

### Breadcrumb Metadata

Each signal processed gets these metadata fields:
- `base_pred`: Flat classifier prediction
- `specialized_pred`: Hierarchical classifier prediction (if used)
- `used_specialized`: Boolean flag for whether specialized model was triggered
- `lat_base_ms`: Base classification latency
- `lat_spec_ms`: Specialized model latency
- `lat_total_ms`: Total latency

## Integration with "Press Battlefield"

This system integrates seamlessly with the existing OSR trilogy automation:

- **Cross-paper hooks**: Git hooks handle both OSR and HVF JSON changes
- **Unified build system**: Make targets compatible across all papers
- **Consistent table generation**: Same Jinja2 + fallback pattern
- **Pre-commit integration**: Part of the same .pre-commit-config.yaml

## Troubleshooting

### Mock Mode for Testing

If the real classifier isn't available:

```bash
python3 scripts/hvf_eval.py --mock --limit 100
```

### Manual Table Generation

If automation fails:

```bash
python3 scripts/render_hvf_tables.py \
  --in data/hier_vs_flat_metrics.json \
  --outdir tables
```

### Check Generated Tables

```bash
ls -la tables/
cat tables/hvf_wins_table.tex
cat tables/hvf_latency_table.tex
```

## Dependencies

- **Python 3.12+**: Core evaluation and table generation
- **Jinja2**: Template rendering (auto-installed if needed)
- **NumPy**: Numerical computations and mock data generation
- **PyTorch**: Neural network models (optional - mock mode available)
- **LaTeX**: PDF generation (pdflatex, bibtex)

## Next Steps

1. **Real Data Integration**: Replace mock evaluation with real RadioML/NPZ datasets
2. **Model Training**: Train specialized models for different signal types
3. **Extended Metrics**: Add confusion matrix visualizations, ROC curves
4. **Performance Optimization**: Profile and optimize latency bottlenecks