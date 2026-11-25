# Inspekta

**A Claude agent that tests live apps like a senior QA + UI/UX lead, and reviews code like a senior engineer.**

Inspekta logs into your running app **in your normal Chrome** (real session, real login
behaviour), works through your checklist, records every action, captures screenshots, and
writes a **scored Markdown report** — plus suggestions a senior designer would make even
when the checklist didn't ask. It then reviews the codebase (tuned for
[Grit](https://gritframework.dev) apps) and writes a scored **code review**, linking live
bugs to their root causes in the code.

```
runs/acme-crm-2026-11-25-1030/
├── report.md         # Live QA + UI/UX review, scored 0–100, grade A–F
├── code-review.md    # Senior code review, scored 0–100, grade A–F
├── action-log.md     # Every step: action, expected, observed, result, evidence
├── task.md           # Intake (credentials redacted)
└── evidence/         # Screenshots referenced from the reports
```

## How it works

```
NEW TASK ─► intake (asks for dir, URL, creds, checklist)
        ─► runs/<app>-<date>/ created from templates/
        ─► /qa          Playwright MCP drives your real Chrome (--extension)
                        logs each action, screenshots, console/network checks,
                        senior UI/UX sweep (states, themes, a11y, mobile, copy)
        ─► /code-review code-reviewer subagent reads the codebase (read-only)
                        Grit conventions, security, GORM/N+1, React, tests
        ─► /report      weighted scores, findings, suggestions, next steps
        ─► check-run.sh verifies evidence links, no leaked passwords
```

## Setup (once)

Requirements: [Claude Code](https://docs.claude.com/en/docs/claude-code), Node.js 20+,
Google Chrome. Optional: the `grit` CLI.

```bash
git clone https://github.com/<you>/inspekta.git
cd inspekta
bash scripts/setup.sh
```

`setup.sh` installs every skill listed in [`skills.txt`](skills.txt) in one go, with no
prompts. To install or update only the skills later:

```bash
bash scripts/install-skills.sh            # into this project (.claude/skills)
bash scripts/install-skills.sh --global   # for all your projects (~/.claude/skills)
bash scripts/install-skills.sh --list     # show what it will install
```

To add a skill, add one line to `skills.txt` (`<source> skill-a, skill-b`) and re-run.
Current list:

| Skill | Used for |
|---|---|
| `mattpocock/skills` → `code-review` | Code review pass |
| `mattpocock/skills` → `grill-me` | Sharp intake questions |
| `mattpocock/skills` → `grill-with-docs` | Checking conventions against docs |
| `mattpocock/skills` → `handoff` | Resuming long runs in a fresh session |
| `vercel-labs/agent-browser` → `agent-browser` | Browser fallback |
| `uizze.sh` | UI/UX design review |
| `MUKE-coder/grit-expert-skills` | Grit reviewer, security, perf, UI/UX, data… |

Inspekta's own skills live in `.claude/skills/`:
`inspekta-qa`, `inspekta-ux-eye`, `inspekta-code-review`, `inspekta-report`.

### Choosing the browser

Inspekta uses your **real browser session**, so it gets your cookies and the Google
accounts you're already signed into. `.mcp.json` defines three browser connections, and
the task file says which one to use: a default, plus optional overrides per role.

| Task value | Use when | Setup |
|---|---|---|
| `chrome` | Your normal Chrome | Install the **Playwright Extension** (Playwright MCP Bridge; see [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)) in Chrome and approve it on first connect |
| `chrome:<profile>` | A specific Chrome profile (e.g. `chrome:Work`) | Install the extension **in that profile**. When Inspekta connects, approve from that profile's window |
| `edge` / `edge:<profile>` | Microsoft Edge | Install the same extension in Edge (it accepts Chrome Web Store extensions) |
| `cdp` / `cdp:9222` | Brave, Vivaldi, Chromium, Chrome Beta, or a **dedicated Inspekta profile** | Run `bash scripts/launch-browser.sh brave myprofile` (or `chrome`, `edge`…), sign into your demo/Google accounts in that window once, and it stays signed in |

Notes:
- Chrome 136+ blocks debugging ports on your **main** profile, which is why `chrome` and `edge`
  go through the extension, and `cdp` uses a separate profile folder (`~/.inspekta/profiles/`).
- Firefox and Safari can't share a real session through Playwright MCP. Use a Chromium
  browser for those tests.
- Roles can use different browsers. That's handy when two roles need to be signed in
  at the same time (e.g. a teacher publishes results while a parent watches).
- The `--browser msedge` flag for extension mode depends on your Playwright MCP version.
  If `edge` won't connect, use `cdp` with `launch-browser.sh edge`.

### Google / SSO sign-in

For roles that use **"Sign in with Google"** (or Microsoft/GitHub SSO), put the Google
account's email in the task file. Make sure that account is already signed in to the
browser Inspekta will use. Inspekta clicks the app's Google button and picks that account
from Google's account chooser. It **never types a Google password or 2FA code**: if Google
asks for one, it stops and hands over to you. It approves the OAuth consent screen only if
the task says `Consent screen allowed: yes`.

## Usage

```bash
cd inspekta
claude
```
then type:

```
NEW TASK
```

Inspekta asks for anything it needs:

- app directory (e.g. `/Users/me/code/acme-crm`)
- login sites: one or more sign-in URLs (admin panel, staff portal, parent portal…)
- roles & accounts: per role, its login site, auth method (password / Google / OTP…),
  account and browser
- browser: which session to use (`chrome`, `chrome:Work`, `edge`, `cdp`)
- the checklist (paste it, or a path to a `.md`)
- scope: both (default) / qa / code

Or prepare a task file — copy `tasks/examples/task.example.md` to `tasks/acme.md`
(`tasks/` is gitignored because it holds credentials) and run:

```
/new-task tasks/acme.md
```

## Prepare a task with your project's AI (recommended)

The AI that builds and maintains your app (Claude Code, Cursor, etc.) already knows its
routes, roles, seed data and features. Paste the prompt below **in the app's repo**. It
writes `.inspekta/task.md` in the app, with everything Inspekta needs: URLs, demo
logins for every role, every login site, how each role signs in (password / Google /
OTP), which browser to use, a feature map and a full checklist.

Then in Inspekta, just run:

```
/new-task /absolute/path/to/your-app
```

Inspekta finds `<app>/.inspekta/task.md` on its own and only asks about what's missing.

### Copy-paste prompt

````text
You are preparing this project for Inspekta, an AI agent that will (1) log into the LIVE
app in a real browser with demo accounts, test it against a checklist and review its
UI/UX, and (2) do a senior code review of this codebase. Inspekta runs separately and
knows nothing about this project, so your file is its only briefing.

Investigate the codebase first (routes/pages, API endpoints, auth and roles, seeders,
env/config, README, .grit/project-profile.md if present, recent git history). Don't
guess. If something can't be found (e.g. the live URL or a password), ask me instead
of inventing it.

Then create `.inspekta/task.md` at the repo root, and add `.inspekta/` to .gitignore
(the file contains demo credentials and must never be committed). Use exactly this
structure:

# Inspekta task — <App name>

## 1. Basics
- **App name:**
- **App directory:** <absolute path of this repo on this machine>
- **Framework / stack:** <e.g. Grit v3 triple — Go/Gin/GORM API, Next.js web, admin>
- **Other surfaces:** <API base URL, docs/Swagger URL, dev mail inbox (e.g. Mailhog), if any>
- **Scope:** both   <!-- both | qa | code -->

## 2. Browser
ASK ME these. You can't know them from the code:
- **Default browser:** <chrome | chrome:<profile name> | edge | edge:<profile> | cdp:<port>>
- **Google accounts already signed in to that browser** (only if any role uses Google):

## 3. Login sites
Find EVERY sign-in entry point in the code (admin panel, staff portal, parent/student
portal, customer app, separate subdomains, /login vs /admin/login, etc.).
| ID | Site | Sign-in URL (live) | Auth methods offered |
|----|------|--------------------|----------------------|
<L1, L2… Auth methods: password, google, microsoft, github, magic-link, otp, sso>

## 4. Roles & accounts
Find EVERY role in the code (enums, role tables, middleware, seeders, route guards).
One row per role to test:
| Role | Login site | Auth method | Email / username | Password | Browser | What this role can do |
|------|-----------|-------------|------------------|----------|---------|-----------------------|
<Demo/seed accounts ONLY, never a real person's account.
- Auth method = how THIS role signs in for the test (e.g. headteacher → google).
- For google/SSO roles: the Google account email, password column "—".
- For otp/magic-link roles: where the code arrives (e.g. Mailhog URL).
- Browser: "default", or an override like "edge" / "cdp:9222" when a role must use a
  different browser session (ASK ME).
- If a role has no demo account on the live app, tell me so I can create one.>

- **Role test order:** <e.g. super admin → headteacher → teacher → parent>
- **2FA / CAPTCHA / email verification on login?** <yes/no + details, per site>
- **Sign-up flow exists?** <yes/no, per site; may Inspekta create a test account? ask me>

## 5. OAuth / Google sign-in (only if any role uses Google/SSO)
- **Consent screen allowed?** <yes / ask me>  (and which scopes the app requests)
- Reminder for Inspekta: use the already-signed-in account; never type a Google password.

## 6. Feature map
For each main area: name, URL path, which roles can see it, and what a user does there.
| Area | Path | Roles | Key actions |
|------|------|-------|-------------|

## 7. Test data
- Records that already exist and are safe to view/edit (e.g. "Client: Acme Demo"):
- Data Inspekta may CREATE (and how to name it, e.g. prefix "INSPEKTA-TEST"):
- Sample files for uploads, if needed (paths):
- Sandbox/test payment details, if payments exist (test mode only):

## 8. Constraints (off-limits)
<e.g. don't delete seed records, don't send real emails/SMS, don't touch billing,
don't change the admin password, rate limits, environments to avoid>

## 9. Known issues / recent changes
<things already known broken (so they aren't re-reported as new), and features
changed recently that deserve extra attention>

## 10. Checklist
Write a thorough, testable checklist grouped by area. Each item is one observable check
with the role to use, e.g. "- [ ] (admin) Create a client with all fields → appears at
top of list with success toast". Cover:
- Auth, per role, on that role's own login site with its own auth method: login,
  wrong password / wrong code, logout, session persistence, password reset page,
  protected routes redirect to the RIGHT login site when logged out
- Google/SSO roles: the Google button works, the correct account is chosen, and a
  Google account with no matching user gets a clear error
- Cross-site: each role's credentials on the OTHER login sites (should fail or route
  correctly)
- Every main feature from the feature map: create / read / update / delete, search,
  filter, sort, pagination, exports/downloads, uploads
- Permissions, per role: everything it SHOULD reach works, and everything it should NOT
  reach is blocked (hidden in the menu AND blocked by direct URL AND blocked by API).
  Tag every item with its role, e.g. "(teacher)". Group the checklist by role.
- Forms: required fields, validation messages, invalid input, double-submit
- States: loading, empty (e.g. search with no results), error, success
- UI: colours/theme (light & dark if supported), responsive/mobile, consistency
- Anything risky in the code you noticed while investigating (fragile logic,
  missing checks): list it as "Areas of concern" so Inspekta tests it harder

## 11. Code review focus
- Main directories (api / web / admin / packages):
- How to run lint/typecheck/tests locally (exact commands):
- Areas you consider risky or messy:

When done, show me the file path, a summary (number of roles, login sites, auth methods,
areas, checklist items) and anything you couldn't determine and need from me.
````

Other commands: `/qa`, `/code-review`, `/report` (each defaults to the newest run).

## Scoring

**Live QA & UI/UX (report.md)** — Functionality 30 · UX & flows 20 · Visual design 15 ·
States 10 · Accessibility 10 · Performance 10 · Responsive 5.
**Code (code-review.md)** — Security 20 · Correctness 20 · Architecture 15 · Data &
performance 15 · Maintainability 15 · Frontend 10 · Tests 5.
Grades: A ≥ 90 · B ≥ 80 · C ≥ 70 · D ≥ 60 · F. Open Critical issues cap the score at 59.
Full rubric: `.claude/skills/inspekta-report/SKILL.md`.

## Safety

- Use **demo accounts** only. Passwords are never written to disk; `task.md` stores them
  redacted, and `check-run.sh` fails if one slips into a report.
- Destructive or outward-facing actions not in your checklist (deletes, emails, invites,
  payments) require your confirmation. CAPTCHAs / 2FA are handed back to you.
- Code review is **read-only** unless you ask for fixes.
- `runs/` is gitignored by default so screenshots of your apps don't get pushed. Remove
  those lines in `.gitignore` if you want reports in git.

## Repo layout

```
CLAUDE.md                  agent brain: workflow, browser, recording, review rules
.mcp.json                  browser servers: chrome, edge (extension), cdp
.claude/settings.json      tool permissions
.claude/commands/          /new-task /qa /code-review /report
.claude/agents/            code-reviewer subagent
.claude/skills/            inspekta-qa, inspekta-ux-eye, inspekta-code-review, inspekta-report
templates/                 report, code-review, action-log, task
scripts/                   setup, install-skills, new-run, collect-evidence, check-run, launch-browser
skills.txt                 list of external skills to install
tasks/examples/            example task file
runs/                      outputs (one folder per run)
```

## License
MIT
