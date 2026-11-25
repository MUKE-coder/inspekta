#!/usr/bin/env bash
# File one self-improvement issue on Inspekta's own GitHub repo.
#
#   bash scripts/file-issue.sh "<title>" "<label,label>" <body-file>
#   bash scripts/file-issue.sh --flush        # file everything saved in improvements/inbox/
#
# - Same open issue title already exists → adds a "seen again" comment instead (that count is
#   a priority signal).
# - The body is checked for private details (emails, non-public URLs, secrets) because the
#   repo may be public. If it finds any, nothing is filed: rewrite the body anonymised.
# - No gh CLI / not logged in → saved to improvements/inbox/ to file later with --flush.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${INSPEKTA_REPO:-MUKE-coder/inspekta}"
INBOX="$ROOT/improvements/inbox"
mkdir -p "$INBOX"

have_gh() { command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; }

check_private() {   # $1 = file. Prints offending lines, returns 1 if any.
  local bad=0
  # emails other than example.com / noreply
  if grep -nEo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$1" \
       | grep -viE '@(example\.(com|org)|users\.noreply\.github\.com|anthropic\.com)' ; then bad=1; fi
  # URLs other than public docs/tools and localhost
  if grep -nEo 'https?://[^ )>"]+' "$1" \
       | grep -viE 'https?://(localhost|127\.0\.0\.1|([a-z0-9-]+\.)*(github\.com|githubusercontent\.com|gritframework\.dev|playwright\.dev|claude\.com|anthropic\.com|npmjs\.com|example\.(com|org)))' ; then bad=1; fi
  # secrets / credentials (shared, narrow scanner: ignores code and names like ForgotPassword)
  if ! awk -f "$ROOT/scripts/lib/secret-scan.awk" "$1"; then bad=1; fi
  return $bad
}

file_one() {   # title labels bodyfile
  local title="$1" labels="$2" body="$3"
  [ -s "$body" ] || { echo "empty body: $body" >&2; return 1; }
  if ! check_private "$body"; then
    echo "REFUSED: body above contains private-looking details. Anonymise it and retry." >&2
    return 2
  fi
  labels="self-reported${labels:+,$labels}"

  if ! have_gh; then
    local f="$INBOX/$(date +%Y%m%d-%H%M%S)-$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g' | cut -c1-50).md"
    { echo "title: $title"; echo "labels: $labels"; echo "---"; cat "$body"; } > "$f"
    echo "SAVED (gh not available/logged in): $f  → later: bash scripts/file-issue.sh --flush"
    return 0
  fi

  # duplicate check: open issues with the same title
  local existing
  existing="$(gh api -X GET "repos/$REPO/issues" -f state=open -f labels=self-reported -f per_page=100 \
              --jq '.[] | "\(.number)\t\(.title)"' 2>/dev/null | tr -d '\r' \
              | awk -F'\t' -v t="$title" '$2 == t { print $1; exit }')"
  if [ -n "$existing" ]; then
    gh api -X POST "repos/$REPO/issues/$existing/comments" \
      -f body="Seen again during a run on $(date +%Y-%m-%d).

$(cat "$body")" >/dev/null && echo "COMMENTED on #$existing (duplicate): $title"
    return 0
  fi

  local args=(-X POST "repos/$REPO/issues" -f title="$title" -f body="$(cat "$body")")
  IFS=',' read -ra L <<<"$labels"
  for l in "${L[@]}"; do l="$(echo "$l" | xargs)"; [ -n "$l" ] && args+=(-f "labels[]=$l"); done
  local url
  url="$(gh api "${args[@]}" --jq .html_url)" && echo "FILED: $url" || { echo "gh failed; saving locally"; INBOX_FORCE=1; }
  if [ "${INBOX_FORCE:-0}" = 1 ]; then
    local f="$INBOX/$(date +%Y%m%d-%H%M%S)-retry.md"
    { echo "title: $title"; echo "labels: $labels"; echo "---"; cat "$body"; } > "$f"; echo "SAVED: $f"
  fi
}

if [ "${1:-}" = "--flush" ]; then
  have_gh || { echo "gh CLI not installed or not logged in (gh auth login)"; exit 1; }
  shopt -s nullglob
  for f in "$INBOX"/*.md; do
    title="$(sed -n 's/^title: //p' "$f" | head -1)"
    labels="$(sed -n 's/^labels: //p' "$f" | head -1 | sed 's/^self-reported,\{0,1\}//')"
    tmp="$(mktemp)"; sed '1,/^---$/d' "$f" > "$tmp"
    if file_one "$title" "$labels" "$tmp"; then mkdir -p "$INBOX/../filed" && mv "$f" "$INBOX/../filed/"; fi
    rm -f "$tmp"
  done
  exit 0
fi

[ $# -eq 3 ] || { sed -n '2,12p' "$0"; exit 1; }
file_one "$1" "$2" "$3"
