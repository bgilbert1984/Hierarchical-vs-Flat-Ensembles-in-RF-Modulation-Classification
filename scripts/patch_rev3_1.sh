#!/usr/bin/env bash
set -euo pipefail
TEX=main_hier_vs_flat.tex

# Insert dataset paragraph right after \section{Method}
# Creates a .bak once; idempotent because we guard on a marker.
MARK='Rev31DatasetMarker'
grep -q "$MARK" "$TEX" || sed -i.bak "/\\\section{Method}/a \\
\\\paragraph{Dataset.} All results are on the standard RML2016.10a dataset~\\\cite{oshea2016radioml}, filtered to \\{BPSK, QPSK, 8PSK, 16QAM, 64QAM\\}, yielding 20{,}000 test examples (4{,}000 per class) evenly distributed across \$-10\$ to \$+18\$\\,dB SNR. % $MARK
" "$TEX"

# Ensure refs hook exists (no-op if already present)
grep -q '\\bibliography{refs}' "$TEX" || cat >> "$TEX" <<'EOF'

% ---- Bibliography (added by Rev3.1 script) ----
\bibliographystyle{IEEEtran}
\bibliography{refs}
EOF

echo "✅ Rev3.1 dataset sentence injected into $TEX"