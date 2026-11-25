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
├── fix-prompt.md     # Copy-paste prompt for your app's AI to verify & fix the findings
├── improvements.md   # Inspekta's self-review → filed as GitHub issues on this repo
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

## Using it from VS Code (Claude Code extension)

1. In VS Code, **File → Open Folder…** and open the `inspekta` folder itself, not a parent
   folder. That's how the extension finds `CLAUDE.md`, `.claude/` (commands, skills,
   subagent) and `.mcp.json` (browsers).
2. Open the Claude Code panel and type `NEW TASK`, or pick `/new-task` from the slash
   command menu. `/qa`, `/code-review` and `/report` work the same way.
3. Check the browsers are connected: run `/mcp` in the panel. You should see `chrome`,
   `edge` and `cdp`. They're pre-approved in `.claude/settings.json`, so the extension
   doesn't need to ask.
4. **If `/mcp` shows nothing or the browser tools are missing**, register the server
   once from a terminal with the standalone CLI (`npm i -g @anthropic-ai/claude-code`),
   then reload the window (**Developer: Reload Window**):
   ```bash
   cd inspekta
   claude mcp list          # approves/loads the project's .mcp.json servers
   # still missing? add Chrome at user level as a fallback:
   claude mcp add chrome -s user -- npx @playwright/mcp@latest --extension --output-dir ./.playwright-out
   ```
5. Approvals (opening the browser, typing into forms, etc.) appear as prompts in the
   panel. Keep the panel visible during a run.

Windows: Claude Code runs the scripts with Git Bash, which you already have.

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

Other commands: `/qa`, `/code-review`, `/report`, `/fix-prompt`, `/file-issues` (each defaults to the newest run), and `/improve` to work on Inspekta itself.

## After the review: fix prompt

Every run ends with **`fix-prompt.md`** in the run folder. Copy the box in it into the AI
that maintains your app (in the app's repo). That AI will:

1. read the QA report, code review, test log and screenshots (absolute paths are filled in)
2. verify each finding against the code, and reject false positives with a reason
3. ask you once about risky fixes (migrations, auth/role changes, product decisions)
4. fix everything in priority order (Critical → Low, then UI/UX suggestions), fixing
   linked bugs at the root cause, with tests and one commit per finding
5. write `.inspekta/fix-summary.md` with the status of each finding and a **re-test checklist**

Then run Inspekta again on the same app (`/new-task <app dir>`). It sees the fix summary,
re-tests those items first, and marks each earlier finding Fixed / Still open / Regressed.

For a run that finished before this feature existed: `/fix-prompt runs/<run-folder>`.

## Self-improving: Inspekta files issues about itself

Every run, Inspekta also reviews **itself**. Whenever something slows it down or could
work better, it notes it in `runs/<run>/improvements.md` straight away:

| Label | What it captures |
|---|---|
| `friction` | retries, workarounds, confusing flows it had to fight through |
| `skill-gap` | missing, unclear or wrong instructions/skills |
| `tooling` | browser connection, scripts, settings, permission prompts |
| `report-quality` | templates, scoring, fix prompt |
| `false-positive` | something it nearly reported that wasn't a problem, and what misled it |
| `idea` | new checks or capabilities worth adding |

At the end of the run (`/report`, or `/file-issues` on its own) it files them as
**GitHub issues on this repo**, labelled `self-reported` plus type and `priority:*`.
If the same problem happens again, it comments "seen again" on the existing issue instead
of opening a duplicate, so recurring problems rise to the top.

**Privacy:** this repo is public, so issues are anonymised: no client app names,
URLs, emails, logins, screenshots or code. `scripts/file-issue.sh` refuses any body that
contains emails, non-public URLs or secrets.

**App notes:** Inspekta also keeps `knowledge/apps/<app>.md` (local, gitignored) with what it
learned about each app, such as login quirks, navigation and known non-bugs. It reads them at the
start of the next run on that app.

**Fixing the issues:** open Inspekta and run

```
/improve            # lists open self-reported issues by priority & recurrence; you pick
/improve 12 15      # fix specific issues
```

It edits Inspekta's own skills, commands, templates and scripts, commits with
`fixes #n`, and asks before pushing.

Setup: install the [GitHub CLI](https://cli.github.com) and run `gh auth login` once.
Without it, issues are saved to `improvements/inbox/`; file them later with
`bash scripts/file-issue.sh --flush`. Labels are created by `bash scripts/setup-labels.sh`
(already done for MUKE-coder/inspekta).

## Permissions (no approval prompts)

`.claude/settings.json` lets Inspekta run a whole test without asking:

- all browser tools on the `chrome`, `edge` and `cdp` servers
- reading/writing files, search, skills, subagents, and shell commands
- file edits auto-accepted (`defaultMode: acceptEdits`)

These are still blocked: `git push`, `git reset --hard`, `git clean`, recursive deletes,
`grit migrate/seed/deploy` and `docker compose down`. Inspekta's own rules still make it
ask before deleting app data, sending real emails, or other outward-facing actions not
in your checklist.

**Reading your app's code without prompts.** Claude Code asks before reading folders
outside `inspekta`. Allow your projects folder once by creating
`.claude/settings.local.json` (gitignored, specific to your machine):

```json
{
  "permissions": {
    "additionalDirectories": ["D:/PROJECTS"]
  }
}
```

**Still getting prompts?**
- Reload VS Code (**Developer: Reload Window**) after pulling, so settings are re-read.
- Check that VS Code opened the `inspekta` folder itself; settings only apply there.
- Your user settings (`~/.claude/settings.json`) can override these. Remove any
  `ask` rules for `mcp__…` there.
- Fully hands-off (no prompts at all, at your own risk): in VS Code settings set
  **Claude Code: Initial Permission Mode** to *bypass permissions*, or run
  `claude --dangerously-skip-permissions` in a terminal. Only do this in the
  `inspekta` folder with demo accounts.

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
.claude/commands/          /new-task /qa /code-review /report /fix-prompt /file-issues /improve
.claude/agents/            code-reviewer subagent
.claude/skills/            inspekta-qa, inspekta-ux-eye, inspekta-code-review, inspekta-report
templates/                 report, code-review, action-log, task, fix-prompt, improvements
knowledge/apps/            per-app notes from earlier runs (local, gitignored)
scripts/                   setup, install-skills, new-run, collect-evidence, check-run, launch-browser,
                           file-issue, setup-labels
skills.txt                 list of external skills to install
tasks/examples/            example task file
runs/                      outputs (one folder per run)
```

## License
MIT
