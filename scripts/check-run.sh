#!/usr/bin/env bash
# Verify a run folder before handing it over.
# Checks: referenced images exist, unreferenced evidence, leftover placeholders,
# possible raw passwords.
# Usage: bash scripts/check-run.sh <run-dir>
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN="${1:-$(ls -dt "$ROOT"/runs/*/ 2>/dev/null | head -1)}"
RUN="${RUN%/}"
[ -d "$RUN" ] || { echo "run folder not found: $RUN" >&2; exit 1; }
cd "$RUN"
problems=0

# 1. Missing images
refs=$(grep -ohE '\(evidence/[^)]+\)' ./*.md 2>/dev/null | sed -E 's/^\(|\)$//g' | sort -u)
for r in $refs; do
  [ -f "$r" ] || { echo "MISSING  $r"; problems=$((problems+1)); }
done

# 2. Unreferenced evidence (warning only)
if [ -d evidence ]; then
  for f in evidence/*; do
    [ -e "$f" ] || continue
    grep -qF "$f" ./*.md || echo "UNUSED   $f (warning)"
  done
fi

# 3. Leftover template placeholders
[ -f fix-prompt.md ] || { echo "MISSING  fix-prompt.md (run /fix-prompt)"; problems=$((problems+1)); }
if grep -nE '\{\{[^}]*\}\}' report.md code-review.md fix-prompt.md 2>/dev/null; then
  echo "PLACEHOLDERS left above"; problems=$((problems+1))
fi

# 4. Possible raw credentials (skips code blocks, inline code and names like ForgotPassword)
if ! awk -f "$ROOT/scripts/lib/secret-scan.awk" ./*.md; then
  echo "POSSIBLE CREDENTIAL above — redact it (•••• or <demo password>)"; problems=$((problems+1))
fi

# 5b. Cleanup ledger: nothing may be left PENDING
if [ -f created.md ]; then
  pending=$(grep -cE '\|[[:space:]]*PENDING[[:space:]]*\|' created.md || true)
  residue=$(grep -cE '\|[[:space:]]*RESIDUE[[:space:]]*\|' created.md || true)
  if [ "${pending:-0}" -gt 0 ]; then
    echo "PENDING  $pending record(s) in created.md not cleaned up or verified — finish cleanup (/report step 1b)"
    problems=$((problems+1))
  fi
  [ "${residue:-0}" -gt 0 ] && echo "RESIDUE  $residue record(s) left in the app — make sure they're in report.md and fix-prompt.md (warning)"
fi

# 5. Self-review present (warning only)
if [ ! -f improvements.md ]; then echo "UNUSED   improvements.md missing (warning)"
elif ! grep -q '^### \[' improvements.md && ! grep -qi 'no issues\|went smoothly\|nothing to report' improvements.md; then
  echo "NOTE     improvements.md has no entries. Log friction/ideas, or say the run was smooth (warning)"
fi

if [ "$problems" -eq 0 ]; then
  echo "OK  $(basename "$RUN") — $(ls evidence 2>/dev/null | wc -l | tr -d ' ') evidence file(s)"
else
  echo "$problems problem(s) found"; exit 1
fi
