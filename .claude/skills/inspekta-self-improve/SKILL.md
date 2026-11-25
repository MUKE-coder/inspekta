---
name: inspekta-self-improve
description: How Inspekta improves itself — logging friction, gaps and ideas during every run in improvements.md, keeping per-app notes, and filing anonymised GitHub issues on its own repo at the end of a run. Use throughout every run, in /file-issues, and in /improve.
---

# Self-improvement

Inspekta gets better from every run in two ways:

1. **App notes**: what it learns about a specific app, so the next run on that app is faster
   (`knowledge/apps/<app-slug>.md`, local only).
2. **Self-reports**: problems and ideas about *Inspekta itself* (its skills, commands,
   scripts, browser setup, reports), filed as GitHub issues on Inspekta's repo and fixed
   later with `/improve`.

Bugs in the **app under test** are never self-reports. They go in report.md / code-review.md.

## 1. Log as you go: `<run>/improvements.md`

Whenever one of these happens, append an entry **immediately** (one or two lines is fine
mid-run; expand at the end):

| Type | Label | Examples |
|---|---|---|
| Friction | `friction` | Needed 3 tries to click a shadcn dropdown; login redirect loop confused the flow; had to guess how to switch roles |
| Skill gap | `skill-gap` | No guidance for testing file uploads / date pickers / OTP; Grit review checklist missed something you found; instruction was ambiguous or contradictory |
| Tooling | `tooling` | Browser server wouldn't connect; screenshot didn't land in evidence/; script failed on Windows; a permission prompt interrupted the run |
| Report quality | `report-quality` | A template section didn't fit; the scoring felt miscalibrated (and why); the fix prompt was missing something |
| False positive | `false-positive` | Something you were about to report turned out fine. What misled you? |
| Idea | `idea` | A check worth adding (e.g. "test the PDF export opens"), a new command, a faster way to do something |

Entry format:
```
### [friction] Shadcn Select needs keyboard to open in Playwright snapshot
- When: TC-07, choosing a class in a dropdown
- What happened: click on the trigger didn't open it; worked with Enter after focusing
- Cost: ~4 extra steps, 2 minutes
- Suggested fix: add a "Radix/shadcn widgets" section to inspekta-qa with the Enter/ArrowDown approach
- Priority: medium   <!-- high = blocks or badly degrades runs · medium = real cost · low = nice to have -->
```

Be honest and specific: the point is to make the next run better. Aim for 2–8 good entries
per run. Don't pad; if a run went perfectly, say so in one line.

## 2. App notes: `knowledge/apps/<app-slug>.md`

At intake, if this file exists, **read it first**. At the end of a run, update it with
durable, app-specific facts that would have saved time:
login quirks, where things live in the nav, flaky areas, widgets that need special handling,
seed data that's safe to use, things previously confirmed as *not* bugs.
Keep it under ~60 lines; replace stale facts. Never store passwords. `knowledge/apps/`
is gitignored (it describes client apps).

## 3. File issues at the end: `/file-issues`

Inspekta's repo is **public**. Every issue must be **anonymised**:
- No app names, company/school names, URLs, emails, logins, people's names, screenshots of
  the app, or code copied from the app.
- Describe the *pattern* instead: "a Grit triple app whose staff portal uses Google SSO",
  "a shadcn `<Select>` inside a dialog", "a GORM list endpoint without pagination".
- Code snippets only from **Inspekta's own files**, or tiny generic examples you wrote.

`scripts/file-issue.sh` refuses bodies containing emails, non-public URLs or secrets, but
it can't catch names. That part is up to you.

Steps:
1. Read `<run>/improvements.md`. Merge duplicates, drop trivia, and turn each remaining
   entry into one issue.
2. Check existing open issues (the script de-duplicates by exact title, so reuse an
   existing title when it's the same problem; that adds a "seen again" comment, which
   signals priority). To see them:
   `gh api -X GET repos/MUKE-coder/inspekta/issues -f labels=self-reported -f state=open --jq '.[] | "#\(.number) \(.title)"'`
3. For each issue, write a body file (in the run folder, e.g. `improvements/issue-01.md`)
   using the template below, then:
   `bash scripts/file-issue.sh "<title>" "<type label>,priority:<p>" <body-file>`
4. Record the resulting issue URLs (or "saved to inbox") at the bottom of `improvements.md`.

Title: imperative and specific, ≤ 70 chars, e.g.
`Add Radix/shadcn Select handling to inspekta-qa`.

Issue body template:
```
## What happened
<anonymised description of the situation and what went wrong / could be better>

## Impact
<time lost, accuracy, missed findings, user interruptions… and how often it's likely to occur>

## Suggested change
<concrete: which Inspekta file(s) — e.g. `.claude/skills/inspekta-qa/SKILL.md` — and what to add/change>

## Acceptance
<how we'll know it's fixed, e.g. "a run on an app with a shadcn Select picks an option in one step">

---
_Self-reported by Inspekta · run type: <qa/code/both> · stack: <e.g. Grit triple, Next.js, Playwright MCP extension, Windows>_
```

## 4. Fixing them: `/improve`

When the user runs `/improve`, you are working **on Inspekta itself** (this repo), not on a
client app. See `.claude/commands/improve.md`.
