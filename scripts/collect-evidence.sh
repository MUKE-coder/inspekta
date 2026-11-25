#!/usr/bin/env bash
# Move screenshots written by Playwright MCP into <run>/evidence/
# Usage: bash scripts/collect-evidence.sh <run-dir>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN="${1:-$(ls -dt "$ROOT"/runs/*/ 2>/dev/null | head -1)}"
RUN="${RUN%/}"
[ -d "$RUN" ] || { echo "run folder not found: $RUN" >&2; exit 1; }

SRC="$ROOT/.playwright-out"
mkdir -p "$RUN/evidence"
moved=0
if [ -d "$SRC" ]; then
  while IFS= read -r -d '' f; do
    dest="$RUN/evidence/$(basename "$f")"
    [ -e "$dest" ] && dest="$RUN/evidence/$(date +%H%M%S)-$(basename "$f")"
    mv "$f" "$dest"; moved=$((moved+1))
  done < <(find "$SRC" -path "$SRC/fixtures" -prune -o -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webm' -o -iname '*.zip' \) -print0)
fi
echo "moved $moved file(s) into $RUN/evidence ($(find "$RUN/evidence" -type f | wc -l | tr -d ' ') total)"
