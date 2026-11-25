#!/usr/bin/env bash
# Create (or update) the GitHub labels Inspekta uses for self-reported issues.
# Usage: bash scripts/setup-labels.sh [owner/repo]   (default: MUKE-coder/inspekta)
set -uo pipefail
REPO="${1:-${INSPEKTA_REPO:-MUKE-coder/inspekta}}"
label() {
  gh api -X POST "repos/$REPO/labels" -f name="$1" -f color="$2" -f description="$3" >/dev/null 2>&1 \
  || gh api -X PATCH "repos/$REPO/labels/$(printf '%s' "$1" | sed 's/:/%3A/g; s/ /%20/g')" \
       -f color="$2" -f description="$3" >/dev/null 2>&1 \
  || { echo "failed: $1"; return 1; }
  echo "ok: $1"
}
label "self-reported"     "5319e7" "Filed by Inspekta itself during a run"
label "friction"          "d93f0b" "Something slowed Inspekta down or made it work around a problem"
label "skill-gap"         "fbca04" "A skill or instruction was missing, unclear or wrong"
label "tooling"           "1d76db" "Browser server, scripts, settings or MCP problem"
label "report-quality"    "0e8a16" "Reports, scoring or fix prompt could be better"
label "false-positive"    "c5def5" "Inspekta reported something that turned out not to be a problem"
label "idea"              "a2eeef" "Suggestion for a new capability"
label "priority:high"     "b60205" "Blocks or badly degrades runs"
label "priority:medium"   "e99695" "Noticeable cost, workaround exists"
label "priority:low"      "f9d0c4" "Nice to have"
