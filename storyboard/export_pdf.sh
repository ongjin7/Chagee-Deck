#!/bin/sh
# Export the storyboard deck to PDF with headless Chrome: one 1280 x 720 page per slide, every step shown.
#   sh storyboard/export_pdf.sh
# Writes storyboard/chagee_storyboard.pdf and storyboard/chagee_storyboard_notes.pdf (each slide, then its notes).
set -e
cd "$(dirname "$0")"
MAC_CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
WIN_CHROME="/c/Program Files/Google/Chrome/Application/chrome.exe"     # Windows (Git Bash)
if [ -z "$CHROME" ]; then
  if [ -x "$MAC_CHROME" ]; then CHROME="$MAC_CHROME"; else CHROME="$WIN_CHROME"; fi
fi
# Windows has no python3 (only a Microsoft Store stub), so fall back to python
if python3 -c "" 2>/dev/null; then PY=python3; else PY=python; fi
"$PY" build_storyboard.py
DIR="$(pwd -W 2>/dev/null || pwd)"                                     # pwd -W gives C:/... in Git Bash
URL="file:///${DIR#/}/chagee_storyboard.html"
for spec in "chagee_storyboard.pdf|?print=1" "chagee_storyboard_notes.pdf|?print=1&notes=1"; do
  out="${spec%%|*}"; query="${spec#*|}"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=8000 \
    --print-to-pdf="$DIR/$out" "$URL$query" 2>/dev/null
  echo "wrote storyboard/$out"
done
