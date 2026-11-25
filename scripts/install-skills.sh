#!/usr/bin/env bash
# Install every skill listed in skills.txt in one go, with no prompts.
# Skills from the same source go into a single `npx skills add` call.
#
# Usage:
#   bash scripts/install-skills.sh            # project level (.claude/skills), default
#   bash scripts/install-skills.sh --global   # user level (~/.claude/skills), all projects
#   bash scripts/install-skills.sh --list     # show what would be installed
set -uo pipefail
cd "$(dirname "$0")/.."

SCOPE=()
LIST_ONLY=0
for a in "$@"; do
  case "$a" in
    -g|--global) SCOPE=(-g) ;;
    --list) LIST_ONLY=1 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

[ -f skills.txt ] || { echo "skills.txt not found" >&2; exit 1; }

ok=0; failed=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"                       # strip comments
  read -r source rest <<<"$line" || true
  [ -z "${source:-}" ] && continue

  args=()
  if [ -n "${rest:-}" ]; then
    for s in ${rest//,/ }; do args+=(--skill "$s"); done
    label="$source → ${rest}"
  else
    args+=(--skill '*')
    label="$source → all skills"
  fi

  if [ "$LIST_ONLY" -eq 1 ]; then echo "  $label"; continue; fi

  echo "==> $label"
  if npx -y skills add "$source" "${args[@]}" -a claude-code "${SCOPE[@]}" -y </dev/null; then
    ok=$((ok+1))
  else
    failed+=("$source")
  fi
done < skills.txt

[ "$LIST_ONLY" -eq 1 ] && exit 0
echo
echo "Installed from $ok source(s)."
if [ "${#failed[@]}" -gt 0 ]; then
  echo "Failed: ${failed[*]}"
  echo "Re-run this script, or try one by hand:  npx skills add <source> --list"
  exit 1
fi
