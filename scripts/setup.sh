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

echo "==> Installing all skills from skills.txt (one go, no prompts)"
bash scripts/install-skills.sh "$@" || echo "WARN: some skills failed; re-run: bash scripts/install-skills.sh"

echo "==> Pre-fetching Playwright MCP"
npx -y @playwright/mcp@latest --help >/dev/null 2>&1 || echo "WARN: could not pre-fetch @playwright/mcp"

mkdir -p .playwright-out runs
chmod +x scripts/*.sh

cat <<'EOF'

Done. Remaining manual steps:
  1. Pick your browser (README "Choosing the browser"):
     - chrome / edge: install the "Playwright Extension" (Playwright MCP Bridge) in that
       browser (in each profile you want Inspekta to use).
     - cdp (Brave, Vivaldi, a dedicated profile):  bash scripts/launch-browser.sh brave myprofile
  2. Sign in to any Google accounts the test roles use, in that browser.
  3. Open this folder with Claude Code: run  claude  here, or in VS Code use
     File > Open Folder > inspekta and open the Claude Code panel
  4. Run /mcp to check the chrome / edge / cdp servers are listed, then type:  NEW TASK
EOF
