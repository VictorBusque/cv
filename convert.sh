#!/usr/bin/env bash
# Convert main.tex to Markdown and HTML using pandoc.
# Usage: ./convert.sh [md|html|all]
set -euo pipefail

OUTDIR="out"
TEX="main.tex"
FORMAT="${1:-all}"

if ! command -v pandoc &> /dev/null; then
    echo "❌ pandoc is required but not installed."
    echo "   Install: https://pandoc.org/installing.html"
    exit 1
fi

mkdir -p "$OUTDIR"

# Create a simplified .tex file for pandoc
SIMPLIFIED="$OUTDIR/main_simplified.tex"

# Extract content between \begin{document} and \end{document}, then expand macros
awk '
/\\begin\{document\}/ { in_doc=1; next }
/\\end\{document\}/ { in_doc=0; next }
in_doc { print }
' "$TEX" > "$SIMPLIFIED"

# Expand custom macros to standard LaTeX
sed -i \
  -e 's/\\resumeItemListStart/\\begin{itemize}/g' \
  -e 's/\\resumeItemListEnd/\\end{itemize}/g' \
  -e 's/\\resumeSubHeadingListStart/\\begin{itemize}[leftmargin=0in, label={}]/g' \
  -e 's/\\resumeSubHeadingListEnd/\\end{itemize}/g' \
  "$SIMPLIFIED"

# Expand \resumeItem{text} → \item text
# Use perl for multi-line capability if available, otherwise sed
if command -v perl &> /dev/null; then
    perl -0777 -pi -e 's/\\resumeItem\{([^}]*)\}/\\item $1/g' "$SIMPLIFIED"
else
    sed -i 's/\\resumeItem{\([^}]*\)}/\\item \1/g' "$SIMPLIFIED"
fi

# Expand \resumeSubheading{a}{b}{c}{d}
# → \textbf{a} \hfill b \\ \textit{c} \hfill d
# Handle nested braces by matching greedily
if command -v perl &> /dev/null; then
    perl -0777 -pi -e '
      s/\\resumeSubheading\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/\\textbf{$1} \\hfill $2 \\\\ \\textit{$3} \\hfill $4/g;
    ' "$SIMPLIFIED"
else
    # Fallback: simpler sed (may not handle nested braces perfectly)
    sed -i '/\\resumeSubheading/{
        N;N;N
        s/\\resumeSubheading\s*\n\s*{\([^}]*\)}\s*\n\s*{\([^}]*\)}\s*\n\s*{\([^}]*\)}\s*\n\s*{\([^}]*\)}/\\textbf{\1} \\hfill \2 \\\\ \\textit{\3} \\hfill \4/
    }' "$SIMPLIFIED"
fi

# Expand \resumeProjectHeading{a}{b} → a \hfill b
if command -v perl &> /dev/null; then
    perl -0777 -pi -e '
      s/\\resumeProjectHeading\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}\s*\n?\s*\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}/$1 \\hfill $2/g;
    ' "$SIMPLIFIED"
else
    sed -i '/\\resumeProjectHeading/{
        N
        s/\\resumeProjectHeading\s*\n\s*{\([^}]*\)}\s*\n\s*{\([^}]*\)}/\1 \\hfill \2/
    }' "$SIMPLIFIED"
fi

# Remove custom commands and preamble leftovers that confuse pandoc
sed -i \
  -e '/\\documentclass/d' \
  -e '/\\usepackage/d' \
  -e '/\\definecolor/d' \
  -e '/\\renewcommand/d' \
  -e '/\\addtolength/d' \
  -e '/\\urlstyle/d' \
  -e '/\\raggedbottom/d' \
  -e '/\\raggedright/d' \
  -e '/\\setlength/d' \
  -e '/\\titleformat/d' \
  -e '/\\newcommand/d' \
  -e '/\\pagestyle/d' \
  -e '/\\fancyhf/d' \
  -e '/\\renewcommand{\\headrulewidth}/d' \
  -e '/\\renewcommand{\\footrulewidth}/d' \
  -e 's/\\hspace{[^}]*}//g' \
  -e 's/\\vspace{[^}]*}//g' \
  -e 's/\\color{[^}]*}//g' \
  "$SIMPLIFIED"

# Convert
generate_html() {
    echo "📄 Generating HTML..."
    pandoc "$SIMPLIFIED" \
        -f latex \
        -t html5 \
        --standalone \
        --metadata title="Víctor Busqué Somacarrera — CV" \
        -o "$OUTDIR/main.html"

    # Embed CV stylesheet inline so the HTML is fully self-contained
    CSS_FILE="assets/cv.css"
    if [ -f "$CSS_FILE" ]; then
        python3 -c "
import sys, re
css = open('$CSS_FILE').read()
html = open('$OUTDIR/main.html').read()
html = re.sub(r'<style>.*?</style>', '<style>\n' + css + '\n</style>', html, flags=re.DOTALL)
open('$OUTDIR/main.html', 'w').write(html)
"
        # Remove empty stylesheet link tag
        sed -i '/<link rel="stylesheet" href="" \/>/d' "$OUTDIR/main.html"
    fi

    # Clean up pandoc artifacts
    # Remove the <header> title block (hidden by CSS anyway)
    perl -0777 -pi -e 's|<header id="title-block-header">\s*<h1 class="title">.*?</h1>\s*</header>\n?||s' "$OUTDIR/main.html"
    # Strip all math inline spans, keeping their text content (handles split tags)
    perl -0777 -pi -e 's#<span\s+class="math inline">(.*?)</span>#$1#gs' "$OUTDIR/main.html"
    # Clean up any orphaned span tags that weren't matched
    perl -0777 -pi -e 's#</?span class="math inline">##gs' "$OUTDIR/main.html"
    # Normalize pipe separators: collapse whitespace around pipes
    perl -0777 -pi -e 's#\s*\|\s*# | #g' "$OUTDIR/main.html"
    echo "✅ $OUTDIR/main.html"
}

generate_md() {
    echo "📄 Generating Markdown..."
    pandoc "$SIMPLIFIED" \
        -f latex \
        -t gfm \
        --wrap=none \
        -o "$OUTDIR/main.md"
    echo "✅ $OUTDIR/main.md"
}

case "$FORMAT" in
    html) generate_html ;;
    md)   generate_md ;;
    all)  generate_html; generate_md ;;
    *)    echo "Usage: $0 [md|html|all]"; exit 1 ;;
esac

# Clean up
rm -f "$SIMPLIFIED"
echo "🎉 Done."
