---
name: inspekta-qa
description: How Inspekta tests a live web app in the user's real Chrome via Playwright MCP — realistic login, checklist execution, live action logging, screenshot evidence, console/network checks. Use during /qa or any live browser test run.
---

# Inspekta live QA method

## Tools (Playwright MCP, `--extension` mode)
| Need | Tool |
|---|---|
| See the page / find refs | `browser_snapshot` |
| Evidence | `browser_take_screenshot` (`filename: "TC-04-empty-state.png"`, `fullPage` when useful) |
| Act | `browser_click`, `browser_type` (`slowly: true` for login), `browser_press_key`, `browser_hover`, `browser_select_option`, `browser_fill_form` |
| Wait | `browser_wait_for` (text appear/disappear or time) |
| Viewports | `browser_resize` 1440×900 desktop, 768×1024 tablet, 390×844 mobile |
| Health | `browser_console_messages`, `browser_network_requests` |
| Tabs | `browser_tabs` — open your own tab, leave the user's alone |

## Per test case loop
1. `browser_snapshot` → locate the element by role/name, not guesswork.
2. Do the action the way a user would (menu → page, not deep links, unless the TC is about deep links).
3. Observe: did feedback appear within ~100ms? Did a spinner/skeleton show? How long until usable?
4. Screenshot the outcome. Screenshot the *failure* moment for bugs.
5. Check console + network since the last check. Note JS errors, failed requests,
   requests > 1s, duplicate identical calls, large payloads.
6. Append the row to `action-log.md` immediately.
7. If FAIL/PARTIAL → add a finding `QA-Fnn` to `report.md`.

## Realistic login checklist (always, even if not asked)
- Page loads logged-out; autofill from the user's browser behaves sensibly
- Wrong password → clear, non-revealing error; field not cleared unnecessarily
- Empty submit → inline validation, focus moves to first error
- Enter key submits; button shows loading and blocks double submit
- Password show/hide; "Forgot password" exists
- Successful login lands on a sensible page; refresh keeps session; back button doesn't break
- Logout works and protected URLs redirect to sign-in afterwards

## States to provoke deliberately
- **Loading**: first load, slow filters/search (look for skeletons vs layout jump)
- **Empty**: search with no results, new account with no data, filtered-to-nothing lists
- **Error**: invalid form input, 404 URL, (if allowed) offline toggle
- **Success**: create/update confirmation, toast wording, list updating without reload
- **Edge data**: very long text, special characters, emoji, large numbers, pagination end

## Severity
- **Critical** — blocks a core flow, data loss, security exposure
- **High** — core flow works badly / wrong data / no workaround for many users
- **Medium** — noticeable defect with workaround, broken state, poor feedback
- **Low** — polish, copy, minor visual inconsistency

## Finding format (in report.md)
```
### QA-F03 · High · Creating a client twice on double-click
**Where:** /clients/new  **Role:** admin  **TC:** TC-05
**Steps:** 1… 2… 3…
**Expected:** … **Actual:** …
**Evidence:** ![](evidence/TC-05-duplicate-client.png)
**Console/Network:** POST /api/clients ×2 (201, 201)
**Suggested fix:** disable submit while pending; idempotency on API. Likely cause → CR-04
```

## Safety
Demo accounts only. Ask the user before destructive or outward-facing actions not in the
checklist (deletes, emails, invites, payments, security settings). Never capture a
visible password. If a CAPTCHA or 2FA appears, stop and ask the user to complete it in the
browser, then continue.
