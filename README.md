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

`setup.sh` installs these skills into the project:

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

### Connect your normal Chrome

Inspekta uses **Playwright MCP in `--extension` mode** (configured in `.mcp.json`), which
attaches to your real Chrome profile instead of launching a clean robot browser.

1. Install the **Playwright Extension** (Playwright MCP Bridge) in Chrome — see the
   extension README in [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp).
2. Start Claude Code in this folder (`claude`) and approve the `playwright` MCP server.
3. On the first browser action, click the extension and allow the connection.

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
- live URL + sign-in URL
- demo credentials (one or more roles)
- the checklist (paste it, or a path to a `.md`)
- scope: both (default) / qa / code

Or prepare a task file — copy `tasks/examples/task.example.md` to `tasks/acme.md`
(`tasks/` is gitignored because it holds credentials) and run:

```
/new-task tasks/acme.md
```

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
.mcp.json                  Playwright MCP (--extension) config
.claude/settings.json      tool permissions
.claude/commands/          /new-task /qa /code-review /report
.claude/agents/            code-reviewer subagent
.claude/skills/            inspekta-qa, inspekta-ux-eye, inspekta-code-review, inspekta-report
templates/                 report, code-review, action-log, task
scripts/                   setup, new-run, collect-evidence, check-run
tasks/examples/            example task file
runs/                      outputs (one folder per run)
```

## License
MIT
