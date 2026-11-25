#!/usr/bin/env bash
# One-time setup for Inspekta. Run from the repo root:  bash scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> Checking prerequisites"
command -v node >/dev/null || { echo "Node.js 20+ is required"; exit 1; }
node -e 'process.exit(+process.versions.node.split(".")[0] >= 20 ? 0 : 1)' \
  || { echo "Node.js 20+ is required (found $(node -v))"; exit 1; }
command -v claude >/dev/null || echo "WARN: Claude Code CLI not found — install it before use"
command -v grit >/dev/null || echo "NOTE: grit CLI not found — Grit skills will still install via npx"

echo "==> Installing external skills into this project (.claude/skills)"
add() { npx -y skills add "$@" || echo "WARN: failed: skills add $*"; }
add https://github.com/mattpocock/skills --skill code-review
add https://github.com/mattpocock/skills --skill grill-me
add https://github.com/mattpocock/skills --skill grill-with-docs
add https://github.com/mattpocock/skills --skill handoff
add https://github.com/vercel-labs/agent-browser --skill agent-browser
add https://uizze.sh/
add MUKE-coder/grit-expert-skills

echo "==> Pre-fetching Playwright MCP"
npx -y @playwright/mcp@latest --help >/dev/null 2>&1 || echo "WARN: could not pre-fetch @playwright/mcp"

mkdir -p .playwright-out runs
chmod +x scripts/*.sh

cat <<'EOF'

Done. Remaining manual step:
  1. Install the "Playwright Extension" (Playwright MCP Bridge) in your normal Chrome
     — see https://github.com/microsoft/playwright-mcp (extension README).
  2. Open this folder with Claude Code:  claude
  3. Approve the "playwright" MCP server when asked, then type:  NEW TASK
EOF
