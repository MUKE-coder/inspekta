#!/usr/bin/env bash
# Launch a Chromium-based browser with a debugging port so Inspekta's "cdp" browser
# server can attach to it. Use this for Brave, Vivaldi, Chromium, Chrome Beta/Canary,
# Edge (if the extension route doesn't work), or a dedicated Inspekta testing profile.
#
# Usage:
#   bash scripts/launch-browser.sh <browser> [profile-name] [port]
#     browser:      chrome | edge | brave | chromium | vivaldi | <path to binary>
#     profile-name: folder under ~/.inspekta/profiles (default: default). Sign into your
#                   demo/Google accounts in it once; it stays signed in for future runs.
#     port:         default 9222
#
# Why a separate profile? Chrome 136+ refuses debugging ports on your main profile (a
# security measure). To use your MAIN Chrome/Edge profile, use the "chrome"/"edge"
# servers (Playwright Extension) instead of this script.
set -euo pipefail

BROWSER="${1:?usage: launch-browser.sh <chrome|edge|brave|chromium|vivaldi|path> [profile] [port]}"
PROFILE="${2:-default}"
PORT="${3:-9222}"
DATA_DIR="$HOME/.inspekta/profiles/$PROFILE"
mkdir -p "$DATA_DIR"

find_bin() {
  case "$(uname -s)" in
    Darwin)
      case "$1" in
        chrome)   echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ;;
        edge)     echo "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" ;;
        brave)    echo "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ;;
        chromium) echo "/Applications/Chromium.app/Contents/MacOS/Chromium" ;;
        vivaldi)  echo "/Applications/Vivaldi.app/Contents/MacOS/Vivaldi" ;;
        *) echo "$1" ;;
      esac ;;
    MINGW*|MSYS*|CYGWIN*)
      case "$1" in
        chrome)   echo "/c/Program Files/Google/Chrome/Application/chrome.exe" ;;
        edge)     echo "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" ;;
        brave)    echo "/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe" ;;
        *) echo "$1" ;;
      esac ;;
    *)
      case "$1" in
        chrome)   command -v google-chrome || command -v google-chrome-stable ;;
        edge)     command -v microsoft-edge || command -v microsoft-edge-stable ;;
        brave)    command -v brave-browser || command -v brave ;;
        chromium) command -v chromium || command -v chromium-browser ;;
        vivaldi)  command -v vivaldi ;;
        *) echo "$1" ;;
      esac ;;
  esac
}

BIN="$(find_bin "$BROWSER" || true)"
[ -n "$BIN" ] && [ -x "$BIN" ] || { echo "Browser not found: $BROWSER ($BIN)" >&2; exit 1; }

echo "Launching $BROWSER with profile '$PROFILE' on port $PORT"
echo "Profile dir: $DATA_DIR"
"$BIN" --remote-debugging-port="$PORT" --user-data-dir="$DATA_DIR" \
  --no-first-run --no-default-browser-check >/dev/null 2>&1 &
sleep 2
if curl -fsS "http://localhost:$PORT/json/version" >/dev/null 2>&1; then
  echo "Ready. In the task file set:  Browser: cdp   (port $PORT)"
else
  echo "Started, but port $PORT isn't answering yet. Give it a few seconds."
fi
