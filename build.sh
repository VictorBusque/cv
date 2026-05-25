#!/usr/bin/env bash
# Build the CV PDF from main.tex using XeLaTeX
# Usage: ./build.sh [clean]
set -euo pipefail

OUTDIR="out"
TEX="main.tex"

if [ "${1:-}" = "clean" ]; then
    echo "🧹 Cleaning build artifacts..."
    rm -rf "$OUTDIR"
    echo "Done."
    exit 0
fi

mkdir -p "$OUTDIR"

echo "📄 Building $TEX -> $OUTDIR/main.pdf (pass 1)..."
xelatex -interaction=nonstopmode -output-directory="$OUTDIR" "$TEX" > /dev/null

echo "📄 Building $TEX -> $OUTDIR/main.pdf (pass 2)..."
xelatex -interaction=nonstopmode -output-directory="$OUTDIR" "$TEX" > /dev/null

echo "✅ Done: $OUTDIR/main.pdf ($(du -h "$OUTDIR/main.pdf" | cut -f1))"
