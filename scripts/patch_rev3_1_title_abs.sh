#!/usr/bin/env bash
set -euo pipefail

# Adjust if your TeX filename differs
TEX="main_hier_vs_flat.tex"

NEW_TITLE='Hierarchical Classifiers Strictly Dominate Flat Ensembles in Digital Modulation Recognition'
ABS_TAIL='We find a hierarchical classifier is never worse than a flat ensemble of identical capacity on RML2016.10a, with strict gains on higher-order modulations and at high SNR.'

# 1) Ensure a visible guard hint after \documentclass (commented by default)
if ! grep -q 'REVTHREEONE GUARD' "$TEX"; then
  sed -i.bak '/\\documentclass/a \
% ---- Rev3.1 title/abstract switch (uncomment to enable) ---- REVTHREEONE GUARD\
% \\newcommand{\\REVTHREEONE}{}\
' "$TEX"
  echo "✅ Inserted guard hint after \\documentclass"
fi

# 2) Wrap \title{...} with \ifdefined\REVTHREEONE block (idempotent)
if ! grep -q 'REV31-TITLE-BLOCK' "$TEX"; then
  # Replace a single-line \title{...}
  sed -i -E "s|^\\\title\{(.*)\}$|\\\ifdefined\\\REVTHREEONE\\
\\\title{$NEW_TITLE} % REV31-TITLE-BLOCK\\
\\\else\\
\\\title{\1}\\
\\\fi|g" "$TEX"
  echo "✅ Wrapped \\title{...} with Rev3.1 guard"
fi

# 3) Append abstract tail under guard (before \end{abstract}), once
if ! grep -q 'REV31-ABS-TAIL' "$TEX"; then
  awk -v tail="$ABS_TAIL" '
    BEGIN { done=0 }
    {
      if (!done && $0 ~ /\\end{abstract}/) {
        print "\\ifdefined\\REVTHREEONE";
        print "\\par\\smallskip\\noindent\\textit{" tail "}";
        print "\\fi % REV31-ABS-TAIL";
        done=1;
      }
      print $0;
    }
  ' "$TEX" > "$TEX.tmp" && mv "$TEX.tmp" "$TEX"
  echo "✅ Inserted guarded abstract tail line"
fi

echo "🎯 Rev3.1 title/abstract guard patch complete → $TEX"