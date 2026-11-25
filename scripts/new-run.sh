#!/usr/bin/env bash
# Create a new Inspekta run folder: runs/<slug>-<YYYY-MM-DD-HHMM>/
# Usage: bash scripts/new-run.sh "<app name or slug>"
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: new-run.sh <app-name>}"
SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
STAMP="$(date +%Y-%m-%d-%H%M)"
RUN_ID="${SLUG}-${STAMP}"
RUN="$ROOT/runs/$RUN_ID"

if [ -e "$RUN" ]; then
  RUN="${RUN}-$(date +%S)"; RUN_ID="$(basename "$RUN")"
fi

NAME_ESC="$(printf '%s' "$NAME" | sed 's/[|&\\]/\\&/g')"
mkdir -p "$RUN/evidence"
for f in report.md code-review.md action-log.md task.md improvements.md created.md; do
  sed -e "s|{{RUN_ID}}|$RUN_ID|g" \
      -e "s|{{DATE}}|$(date +%Y-%m-%d)|g" \
      -e "s|{{APP_NAME}}|$NAME_ESC|g" \
      "$ROOT/templates/$f" > "$RUN/$f"
done

mkdir -p "$ROOT/.playwright-out"
echo "$RUN"
