---
description: Run the live browser test for the current Inspekta run
argument-hint: [run folder, defaults to latest in runs/]
---

Load the `inspekta-qa` and `inspekta-ux-eye` skills and follow them.
Run folder: $ARGUMENTS (if empty, use the newest folder in `runs/`).

Order:
1. Connect to the user's Chrome through Playwright MCP (`--extension`). If the tools fail
   to connect, tell the user to click the Playwright Extension icon and approve, then retry
   once. Open a **new tab** for testing; don't hijack the user's existing tabs.
2. **First impression** — load the sign-in URL logged out. Screenshot. Note load time,
   visual quality, and anything off before logging in.
3. **Login like a human** — type credentials slowly into the real form, submit, observe.
   Also test: wrong password, empty submit, show/hide password, "forgot password" link
   presence, enter-to-submit, redirect after login. Log out and back in once.
4. **Checklist** — work TC by TC. For each: snapshot → act → observe → screenshot →
   console/network check → log row in `action-log.md`.
5. **UX sweep (TC-X)** — loading, empty, error, success states; desktop 1440×900 and
   mobile 390×844; dark mode; keyboard-only navigation of one key flow; focus visibility.
6. After every few TCs run `bash scripts/collect-evidence.sh <run>` to move screenshots
   into `evidence/`.
7. Repeat key flows per role if multiple credentials were given.
8. Log out at the end and close only the tab you opened.

Write findings into `report.md` as you go (Findings table + details), not only at the end.
