#!/usr/bin/env bash
#
# HVF Pre-commit Hook - Auto-generate LaTeX tables when metrics JSON changes
# Part of Paper 11: Hierarchical vs Flat Ensembles automation
#

# Check if HVF metrics JSON is being committed
if git diff --cached --name-only | grep -q "paper_Hier_vs_Flat_Ensembles/data/hier_vs_flat_metrics\.json$"; then
    echo "pre-commit: HVF JSON changed; running tables-hvf..."
    
    # Generate tables
    if make -C paper_Hier_vs_Flat_Ensembles tables-hvf 2>/dev/null; then
        # Stage the generated tables
        git add paper_Hier_vs_Flat_Ensembles/tables/hvf_wins_table.tex 2>/dev/null || true
        git add paper_Hier_vs_Flat_Ensembles/tables/hvf_latency_table.tex 2>/dev/null || true
        
        echo "pre-commit: staged updated HVF tables."
    else
        echo "pre-commit: HVF table generation failed, but continuing..."
    fi
fi