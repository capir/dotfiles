#!/usr/bin/env bash
# pdfshrink: compress a PDF with ghostscript

infile="$1"
outfile="${2:-shrinked.pdf}"

if [[ -z "$infile" ]]; then
  echo "Usage: pdfshrink input.pdf [output.pdf]"
  exit 1
fi

gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
  -dNOPAUSE -dQUIET -dBATCH \
  -sOutputFile="$outfile" "$infile"

echo "✅ Compressed: $outfile"
