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

## When `browser_click` times out
Symptom: `waiting for element to be visible, enabled and stable` repeats even though the
element isn't moving. Common cause: a global `transition: all` (e.g. on `body`) or many
running animations keep Playwright's "stable" check from ever settling.

On the **first** such timeout, don't retry the same call. Instead:
1. Check in-page that the element really is still and clickable (`browser_evaluate`):
   ```js
   (el) => {
     const r = el.getBoundingClientRect();
     const top = document.elementFromPoint(r.x + r.width / 2, r.y + r.height / 2);
     return { rect: [r.x, r.y, r.width, r.height], covered: !el.contains(top),
              animations: document.getAnimations().length, disabled: el.disabled };
   }
   ```
   Not covered and not disabled → it's a tool problem, not an app problem.
2. Click programmatically with `browser_evaluate`: `(el) => el.click()`.
3. **Re-query after the click.** The component often re-renders, so any node you
   captured before the click may be stale. Take a fresh `browser_snapshot` (or query the
   DOM again) before judging whether the menu opened or the form submitted. Reading a
   stale node is how you get a false "menu did not open".
4. In `action-log.md`, note `(clicked via evaluate)` on that row. It skips some checks
   a real click does, which is why step 1 checks for overlays and the disabled state.
5. Don't report the timeout or the animations as a UI defect unless you've confirmed a
   user-visible problem (see "Tool errors are not app defects" below).

If the same app needs this repeatedly, note it in `knowledge/apps/<app>.md` so the next
run uses the fallback straight away.

## Tool errors are not app defects
An automation error describes **the tool's model of the page**, not what a user
experiences. Never turn one into a finding directly. Before any related finding reaches
`report.md`, reproduce the user-visible symptom in-page and write that verification in
the action-log row:

| Tool says / you suspect | Verify with (`browser_evaluate`) | It's a real finding only if… |
|---|---|---|
| "element is not stable" / "it's animating" | `document.getAnimations().length` (page and element), and sample `getBoundingClientRect()` across a few `requestAnimationFrame` ticks | animations are actually running on that element and a user would notice them |
| "element is covered / not visible" | `document.elementFromPoint(...)` at its centre; a screenshot | a real overlay blocks it for a user, too |
| "no focus ring" | a **real key press** (see below) | Tab focus is still invisible |
| "button does nothing" | re-query the DOM after the click; check network for the request | nothing changes for a user either |

### Focus visibility: always use the keyboard
Programmatic `el.focus()` does **not** trigger `:focus-visible`, which by design applies to
keyboard focus. Measuring outlines after `.focus()` will wrongly show "no focus ring
anywhere". Instead:
1. Click on an empty part of the page (or focus `body`), then `browser_press_key` `Tab`.
2. Check the focused element:
   `() => { const el = document.activeElement; const cs = getComputedStyle(el);
   return { tag: el.tagName, text: el.textContent?.trim().slice(0, 40),
   focusVisible: el.matches(':focus-visible'), outline: cs.outlineStyle + ' ' + cs.outlineWidth,
   boxShadow: cs.boxShadow }; }`
3. Repeat `Tab` through the key controls and screenshot a few stops.
A focus finding needs a key-driven reproduction **and** a screenshot.

If you catch yourself nearly reporting a tool artefact, log it in `improvements.md` as a
`false-positive` entry. That's how these rules get better.

## Browser selection
The task file gives a **Default browser** and optional per-role overrides. Map them to
the browser servers in `.mcp.json` (the tools are prefixed `mcp__<server>__`):

| Task value | Server / tools | Meaning |
|---|---|---|
| `chrome` or `chrome:<profile>` | `mcp__chrome__*` | User's real Chrome via the Playwright Extension. For a named profile, ask the user to have that profile's window focused and approve the extension from it |
| `edge` or `edge:<profile>` | `mcp__edge__*` | User's real Edge via the Playwright Extension |
| `cdp` / `cdp:<port>` | `mcp__cdp__*` | Any Chromium browser started with `scripts/launch-browser.sh` (Brave, Vivaldi, a dedicated Inspekta profile). The default port is 9222; for another port, ask the user to update `.mcp.json` |

- Before the first action in each browser, confirm the session: take a screenshot of a
  neutral page (or the app's sign-in page) and check that it's the expected browser/profile.
  If Google sign-in is planned, open `https://myaccount.google.com` *only to read* which
  account is signed in (don't change anything), or check the Google account chooser later.
- Firefox and Safari can't share a real session through these tools. If the task asks
  for one, say so and suggest a Chromium browser or a `cdp` testing profile.
- If the requested browser server won't connect after one retry, stop and ask. Don't
  quietly switch to another browser; its session (cookies, Google account) is different.
- Connection problems should already have shown up in the **browser preflight**
  (`/new-task` step 1b). If you're mid-run and a browser stops answering, use the same
  options: retry once, then ask (fix and retry / `cdp` fallback / skip the affected roles).

## Roles & login sites
Many apps have several roles (admin, headteacher, teacher, parent…) and several login
sites (admin panel, staff portal, parent portal). The task's **Login sites** and
**Roles & accounts** tables say which role uses which site, auth method and browser.

- Test roles in the given **order**. For each role: log in on *its* login site → run the
  checklist items tagged for that role → run that role's permission checks → log out.
- **Session isolation:** between roles in the same browser, log out fully and confirm
  the protected page redirects to sign-in. If logout leaves the session alive, that's a
  finding. Then continue. If two roles must be signed in at once (e.g. teacher publishes
  results and the parent views them), use different browsers or profiles from the table,
  or ask the user.
- **Permission matrix:** for every role, try each restricted area through the menu
  **and** through its direct URL. Also try another role's login site with this role's
  credentials. Record each check in the report's Role × Area matrix.
- **API permission sweep: read the envelope total, not the status code.** For list
  endpoints, build a Role × Endpoint matrix and record the **total from the response
  envelope** (e.g. `meta.total`, `total`, `count`, `pagination.total_items`):
  | Response for this role | Meaning |
  |---|---|
  | 401 / 403 | blocked ✅ (if the role shouldn't reach it) |
  | **200 with total = 0** | **correct scoping ✅**: the API filtered to what this role owns. **Not a leak.** |
  | 200 with rows this role shouldn't see (other tenant/school/user) | **leak ❌, Critical** |
  | 200 with rows it *should* see | allowed ✅ |
  - Never count the `data` array: with `page_size=1` (or any page size) it's capped by the
    page, so its length says nothing about how much is reachable.
  - Request with a small page size (e.g. `?page=1&page_size=1`) and read the total, then
    inspect one row to confirm *whose* data it is (tenant/owner IDs).
  - Counts shown in the UI (badges, "42 students", dashboard tiles) should match the same
    total for that role. A mismatch is a finding.
  - Run these checks from the role's own logged-in session (same cookies/token the UI
    uses), via `browser_evaluate` with `fetch(…, { credentials: 'include' })`, so you test what
    that user can actually reach.
- Prefix action-log rows and screenshots with the role, e.g.
  `TC-07-teacher-staff-url-blocked.png`.

## Auth methods
- **password**: type it slowly into the real form. Never write it to a file.
- **google** ("Sign in with Google"): click the app's Google button, then pick the
  **account named in the task** from Google's account chooser. It's already signed in
  to the browser. **Never type a Google password or 2FA code.** If Google asks for a
  password, verification or a CAPTCHA, stop and ask the user to finish it in the
  browser. Only approve the OAuth **consent screen** if the task says
  `Consent screen allowed: yes`; otherwise ask first. Note the scopes requested in the
  report. If the wrong account gets used, or the chooser is skipped while several
  accounts are signed in, that's a finding.
- **microsoft / github / other SSO**: same rules as Google.
- **magic-link / otp**: if the task names a dev mail inbox (e.g. Mailhog for Grit apps),
  read the code or link there. Otherwise ask the user to read it to you. Also test a
  wrong code and an expired code.
- **2FA (TOTP / SMS)**: always hand it to the user.

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

## Test data: the cleanup ledger (`created.md`)
Leaving test data in a client's live system is the worst mistake Inspekta can make.
- **At the moment you create anything** (a record, upload, invite, comment, application…)
  append a row to `<run>/created.md` with status `PENDING`: resource, ID or unique name,
  role, and how it was created. Also log **side effects** you notice. If approving an
  application creates a student or account, that's a row too.
- Name what you create recognisably (use the task's prefix, e.g. `INSPEKTA-TEST …`), so it
  can be found and cleaned later.
- Clean up when the test no longer needs it (often at the end of that role's block), using
  the app's own UI or API as that role, then **verify it's gone** (search for it, open its
  URL, or check the list total) and set `DELETED` + how you verified.
- If it can't be removed, try the next most-privileged role in the task. If it still can't
  be removed, mark it `RESIDUE` with the exact reason (no delete control, delete returns 403/404
  to a role that should be able to, no delete endpoint…).
- **"Couldn't clean up" is a finding about the app**, not just an operational note: an app
  that can't delete what it creates (or whose delete fails for a role with the right
  permission) has a real gap. File it as `QA-Fnn` (usually Medium; High if it involves
  personal data or blocks the admin).
- Respect the task's constraints: never delete seed/existing records to "clean up". Only
  delete what's in the ledger.

## Safety
Demo accounts only. Ask the user before destructive or outward-facing actions not in the
checklist (deletes, emails, invites, payments, security settings). Never capture a
visible password. If a CAPTCHA or 2FA appears, stop and ask the user to complete it in the
browser, then continue.
