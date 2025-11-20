#!/usr/bin/env bash
set -euo pipefail

TEX="main_hier_vs_flat.tex"
BIB="refs.bib"

# 0) Ensure cite package
if ! grep -q '^[^%]*\\usepackage{cite}' "$TEX"; then
  sed -i.bib_bak '/\\documentclass/a \\usepackage{cite}' "$TEX"
  echo "✅ Added \\usepackage{cite}"
fi

# 1) Remove any bibliography commands after \end{document}
if grep -q '\\end{document}' "$TEX"; then
  # Remove everything after \end{document} including bibliography commands
  sed -i '/\\end{document}/,$d' "$TEX"
fi

# 2) Inject bibliography block before \end{document} if missing
if ! grep -q '^[^%]*\\bibliographystyle' "$TEX"; then
  # Add bibliography commands before \end{document}
  cat >> "$TEX" <<'EOF'

\bibliographystyle{IEEEtran}
\bibliography{refs}
\end{document}
EOF
  echo "✅ Inserted \\bibliographystyle + \\bibliography before \\end{document}"
else
  # Just add \end{document} back
  echo "\end{document}" >> "$TEX"
fi

# 3) Seed refs.bib if absent (or empty)
if [ ! -s "$BIB" ]; then
  cat > "$BIB" <<'EOF'
@misc{oshea2016radioml,
  title        = {RadioML 2016.10a: Radio Machine Learning Dataset Generation with GNU Radio},
  author       = {O'Shea, Timothy J. and Corgan, Johnathan and Clancy, T. Charles},
  year         = {2016},
  note         = {Dataset release (RadioML 2016.10a)},
  howpublished = {\url{https://www.deepsig.ai/datasets}}
}

@article{oshea2018over,
  title   = {Over-the-Air Deep Learning Based Radio Signal Classification},
  author  = {O'Shea, Timothy J. and West, Nathan},
  journal = {arXiv preprint arXiv:1712.04578},
  year    = {2018}
}

@inproceedings{guo2017calibration,
  title     = {On Calibration of Modern Neural Networks},
  author    = {Guo, Chuan and Pleiss, Geoff and Sun, Yu and Weinberger, Kilian Q.},
  booktitle = {ICML},
  year      = {2017}
}

@article{scheirer2013openset,
  title   = {Toward Open Set Recognition},
  author  = {Scheirer, Walter J. and de Rezende Rocha, Anderson and Sapkota, Archana and Boult, Terrance E.},
  journal = {IEEE TPAMI},
  year    = {2013},
  volume  = {35},
  number  = {7},
  pages   = {1757--1772}
}
EOF
  echo "✅ Seeded refs.bib with common entries (incl. oshea2016radioml)"
fi

echo "🎯 Bibliography patch complete."