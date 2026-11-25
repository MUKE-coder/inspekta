---
description: Run the live browser test for the current Inspekta run
argument-hint: [run folder, defaults to latest in runs/]
---

Load the `inspekta-qa` and `inspekta-ux-eye` skills and follow them.
Run folder: $ARGUMENTS (if empty, use the newest folder in `runs/`).

Order:
1. **Connect the right browser.** Read the default browser and per-role overrides from
   `task.md`, then connect with the matching server (`chrome` / `edge` / `cdp`). Ask the
   user to approve the Playwright Extension if prompted (and to focus the right profile's
   window for `chrome:<profile>`). Retry once, then ask. Open a **new tab**; don't hijack
   the user's tabs. Confirm the browser/profile and the signed-in Google account if needed.
2. **First impression**: load each login site logged out. Screenshot. Note load time,
   visual quality, and anything off before logging in.
3. **Per role, in order:**
   a. Log in on **that role's login site** with **its auth method** (password typed
      slowly; Google via the account chooser; OTP/magic link via the dev inbox), following
      "Auth methods" in `inspekta-qa`.
   b. On the first password login, also test: wrong password, empty submit, show/hide,
      forgot-password link, enter-to-submit, redirect after login.
   c. Run that role's checklist items TC by TC: snapshot → act → observe → screenshot →
      console/network check → log a row in `action-log.md`.
   d. Run that role's permission checks (menu + direct URL + other login sites).
   e. Log out, confirm the session has ended, then move to the next role (or browser).
5. **UX sweep (TC-X)** — loading, empty, error, success states; desktop 1440×900 and
   mobile 390×844; dark mode; keyboard-only navigation of one key flow; focus visibility.
6. After every few TCs run `bash scripts/collect-evidence.sh <run>` to move screenshots
   into `evidence/`.
8. Log out at the end and close only the tab you opened.

Write findings into `report.md` as you go (Findings table + details), not only at the end.
