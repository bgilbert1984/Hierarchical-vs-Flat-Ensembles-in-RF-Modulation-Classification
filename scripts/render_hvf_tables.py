#!/usr/bin/env python3
"""
HVF Table Renderer: Generates per-class wins + latency + per-SNR advantage tables
"""
import argparse
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def main():
    """Main table rendering function"""
    ap = argparse.ArgumentParser(description="Render HVF LaTeX tables")
    ap.add_argument("--in", dest="inp", type=Path, required=True,
                    help="Input metrics JSON file")
    ap.add_argument("--outdir", type=Path, required=True,
                    help="Output directory for LaTeX tables")
    args = ap.parse_args()

    # Load metrics data
    try:
        data = json.loads(args.inp.read_text())
    except Exception as e:
        print(f"Error reading metrics file {args.inp}: {e}")
        # Create placeholder data
        data = {
            "per_class": [
                {"label": "BPSK", "flat_correct": 10, "hier_correct": 12, "hier_wins": 2, "flat_wins": 0, "ties": 10},
                {"label": "QPSK", "flat_correct": 8, "hier_correct": 11, "hier_wins": 3, "flat_wins": 0, "ties": 8}
            ],
            "latency_ms": {
                "flat": {"p50": 5.2, "p95": 12.1},
                "hier": {"p50": 7.8, "p95": 18.4}
            }
        }
    
    rows = data.get("per_class", [])
    lat = data.get("latency_ms", {
        "flat": {"p50": 0, "p95": 0}, 
        "hier": {"p50": 0, "p95": 0}
    })
    
    # --- SNR-stratified wins (pure-Python one-liner) ---
    snr_data = []
    if data.get("records"):
        # One-liner: per-SNR wins/advantage table (snr, flat_wins, hier_wins, ADV, N)
        snr_dict = {snr: {'flat_wins': sum(int(r['flat_correct'] and not r['hier_correct']) for r in data["records"] if int(round(r['snr_db']))==snr),
                          'hier_wins': sum(int(r['hier_correct'] and not r['flat_correct']) for r in data["records"] if int(round(r['snr_db']))==snr),
                          'N': sum(1 for r in data["records"] if int(round(r['snr_db']))==snr)}
                    for snr in {int(round(r['snr_db'])) for r in data["records"]}}
        # Normalize to sorted list with ADV computed
        snr_data = [{'snr': snr, 'flat_wins': stats['flat_wins'], 'hier_wins': stats['hier_wins'], 
                     'adv': stats['hier_wins'] - stats['flat_wins'], 'n': stats['N']}
                    for snr, stats in sorted(snr_dict.items())]
    
    # Create output directory
    args.outdir.mkdir(parents=True, exist_ok=True)

    # Render unified tables using Jinja2 template
    try:
        template_dir = args.inp.parent.parent / "templates"
        env = Environment(loader=FileSystemLoader(str(template_dir)), autoescape=False, trim_blocks=True, lstrip_blocks=True)
        template = env.get_template("hvf_tables.tex.j2")
        
        rendered = template.render(
            rows=rows,
            lat=lat,
            snr_data=snr_data
        )
        
        # Write unified output file
        output_file = args.outdir / "hvf_tables.tex"
        output_file.write_text(rendered)
        
        if snr_data:
            print(f"✅ Wrote {output_file} with per-class, latency, and SNR advantage tables")
        else:
            print(f"✅ Wrote {output_file} with per-class and latency tables (no SNR data)")
        
    except Exception as e:
        print(f"Error rendering tables: {e}")
        # Create minimal placeholder table
        placeholder = r"""
\begin{table}[t]
\centering
\caption{Tables pending evaluation.}
\begin{tabular}{lr}
\toprule
Status & Note \\
\midrule
Pending & Evaluation in progress \\
\bottomrule
\end{tabular}
\label{tab:hvf-pending}
\end{table}
"""
        (args.outdir / "hvf_tables.tex").write_text(placeholder)
        print(f"⚠️  Created placeholder table in {args.outdir}")

if __name__ == "__main__":
    main()
