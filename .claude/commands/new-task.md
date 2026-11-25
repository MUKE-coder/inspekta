---
description: Start a new Inspekta run — intake, run folder, plan, then QA + code review + report
argument-hint: [optional: path to a task file in tasks/]
---

You are starting a **new Inspekta task**. Arguments: $ARGUMENTS

## 1. Intake
Find the brief, in this order:
1. `$ARGUMENTS` is a path to a task file → read it.
2. `$ARGUMENTS` (or the app directory the user gives) is a directory → if
   `<dir>/.inspekta/task.md` exists, read it. That file is written by the project's own AI
   using the prompt in README ("Prepare a task with your project's AI"). Trust its feature
   map, test data, constraints and known issues. Turn its checklist and "Areas of concern"
   into test cases, and use "Code review focus" for /code-review. Don't re-report its
   "Known issues" as new findings; note whether they're still present.
3. Otherwise collect everything from the user.

Read `knowledge/apps/<app-slug>.md` if it exists: notes earlier runs left about this app
(login quirks, navigation, widgets, known non-bugs). Use them, but re-verify anything that
could have changed.

If `<app dir>/.inspekta/fix-summary.md` exists, this is a **re-test**: add its
"Re-test checklist" as the first test cases (`TC-R01…`) and, in the report, mark each
earlier finding Fixed / Still open / Regressed.

Collect anything still missing from the user. Use the **AskUserQuestion** tool for anything missing,
batching up to 4 questions at once:

- **App name** (used for the run slug)
- **App directory** (absolute path to the codebase) — required unless scope is QA-only
- **Login sites**: every sign-in URL (admin panel, staff portal, parent portal…) and the
  auth methods on each
- **Roles & accounts**: per role, its login site, auth method (password / google / sso /
  magic-link / otp), account, browser override and test order. Accept passwords in
  chat; never write a raw password to disk. Google roles need the Google account email
  that is already signed in to the browser, not a password.
- **Browser**: default session to use: `chrome`, `chrome:<profile>`, `edge`,
  `edge:<profile>` or `cdp:<port>` (see README "Choosing the browser"). If the user
  doesn't say, ask once and offer these as options.
- **OAuth consent**: may Inspekta approve a Google/SSO consent screen? (default: ask)
- **Checklist** (pasted or a file path)
- **Scope**: `both` (default) / `qa` / `code`
- **Constraints**: anything destructive that's off-limits, environments to avoid, focus areas

Grill once (grill-me style) on genuine ambiguities in the checklist — e.g. "'check
payments' — test with a sandbox card or only check the UI up to the pay button?".
Don't ask what you can find out by looking.

## 2. Set up the run
```bash
bash scripts/new-run.sh "<app-slug>"
```
Write `<run>/task.md` from `templates/task.md` with intake details, credentials redacted.
If the app directory has `.grit/project-profile.md`, read it — it describes the Grit app.

## 3. Plan
Convert the checklist into numbered test cases `TC-01…TC-NN` under **Test Plan** in
`<run>/action-log.md`. Add `TC-X1…` for the standard senior-UX sweep (states,
responsive, a11y, dark mode, console/network) even if not in the checklist.
Group test cases by **role** in the role test order, and add a permission-check TC per
role × restricted area. Create a task list (TaskCreate) with: one item per role (login +
its checklist + permission checks), UX sweep, Code review, Report, Verify run.

## 4. Execute
- Scope includes QA → follow `/qa`
- Scope includes code → follow `/code-review` (can be delegated to the `code-reviewer`
  subagent so it runs with a fresh context while you continue)
- Then `/report`

## 5. Finish
Run `bash scripts/check-run.sh <run>`, fix anything it flags, then tell the user:
QA score + grade, code score + grade, top 3 issues, and the run folder path.
