
# Makefile for Paper 11: Hierarchical vs Flat Ensembles
PY := python3
PAPER_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SCRIPTS := $(PAPER_DIR)scripts
FIGS := $(PAPER_DIR)figs
DATA := $(PAPER_DIR)data
TABLES := $(PAPER_DIR)tables

FIG_PDFS := $(FIGS)/per_class_wins.pdf \
            $(FIGS)/confusion_flat.pdf \
            $(FIGS)/confusion_hier.pdf \
            $(FIGS)/confusion_delta.pdf \
            $(FIGS)/agreement_hist.pdf \
            $(FIGS)/latency_box.pdf

TABLE_TEXS := $(TABLES)/hvf_tables.tex

all: press

pdf: press

figs: $(FIG_PDFS)

tables-hvf: $(TABLE_TEXS)

$(FIGS)/%.pdf: $(SCRIPTS)/gen_figs_hier_vs_flat.py
	@echo "==> Generating figures (first call renders all)"
	$(PY) $(SCRIPTS)/gen_figs_hier_vs_flat.py

# Single target for unified table generation
$(TABLES)/hvf_tables.tex: $(DATA)/hier_vs_flat_metrics.json $(SCRIPTS)/render_hvf_tables.py $(PAPER_DIR)templates/hvf_tables.tex.j2
	@echo "==> Rendering unified HVF tables"
	@mkdir -p $(TABLES)
	$(PY) $(SCRIPTS)/render_hvf_tables.py --in $(DATA)/hier_vs_flat_metrics.json --outdir $(TABLES)

press: figs tables-hvf
	@echo "==> Building LaTeX PDF"
	cd $(PAPER_DIR) && pdflatex -halt-on-error -interaction=nonstopmode main_hier_vs_flat.tex >/dev/null || true
	@echo "==> Output: $(PAPER_DIR)main_hier_vs_flat.pdf"

# Rev3.1 surgical patches
rev3_1: scripts/patch_rev3_1.sh
	@bash scripts/patch_rev3_1.sh
	$(MAKE) pdf

rev3_1_titleabs: scripts/patch_rev3_1_title_abs.sh
	@bash scripts/patch_rev3_1_title_abs.sh

# Build normally
pdf:
	cd $(PAPER_DIR) && pdflatex -interaction=nonstopmode -halt-on-error main_hier_vs_flat.tex

# Build with Rev3.1 title/abstract guard enabled
pdf-rev3_1:
	cd $(PAPER_DIR) && pdflatex -interaction=nonstopmode -halt-on-error "\def\REVTHREEONE{}\input{main_hier_vs_flat.tex}"

# Bibliography targets
bib:
	@echo "==> BibTeX pass"
	@cd $(PAPER_DIR) && bibtex main_hier_vs_flat || true

pdf-with-bib:
	@echo "==> Building with bibliography"
	cd $(PAPER_DIR) && pdflatex -interaction=nonstopmode -halt-on-error main_hier_vs_flat.tex >/dev/null
	cd $(PAPER_DIR) && bibtex main_hier_vs_flat || true
	cd $(PAPER_DIR) && pdflatex -interaction=nonstopmode -halt-on-error main_hier_vs_flat.tex >/dev/null
	cd $(PAPER_DIR) && pdflatex -interaction=nonstopmode -halt-on-error main_hier_vs_flat.tex >/dev/null
	@echo "==> Output: $(PAPER_DIR)main_hier_vs_flat.pdf"

# Convenience: patch + full build
rev3_1_bib:
	@bash scripts/patch_bib_block.sh
	$(MAKE) pdf-with-bib

# Complete Rev3.1 submission build (all patches + enhanced title/abstract + bibliography)
submission:
	@echo "🚀 Building complete Rev3.1 submission version..."
	@bash scripts/patch_bib_block.sh
	$(MAKE) pdf-rev3_1
	@echo "✅ SUBMISSION READY: main_hier_vs_flat.pdf"
	@echo "📊 File size: $$(ls -lh main_hier_vs_flat.pdf | awk '{print $$5}')"
	@echo "📄 Pages: $$(pdfinfo main_hier_vs_flat.pdf 2>/dev/null | grep Pages | awk '{print $$2}' || echo 'unknown')"
	@echo ""
	@echo "🎯 Ready for submission to:"
	@echo "   • IEEE Signal Processing Letters"
	@echo "   • MILCOM 2026"
	@echo "   • IEEE ICC 2026 WCNC track"

clean:
	rm -f $(PAPER_DIR)*.aux $(PAPER_DIR)*.log $(PAPER_DIR)*.out
	rm -f $(FIGS)/*.pdf $(DATA)/hier_vs_flat_metrics.json
	rm -f $(TABLES)/*.tex

.PHONY: all figs tables-hvf press clean
	rm -f $(FIGS)/*.pdf $(DATA)/hier_vs_flat_metrics.json
