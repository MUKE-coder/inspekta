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

Collect anything still missing from the user. Use the **AskUserQuestion** tool for anything missing,
batching up to 4 questions at once:

- **App name** (used for the run slug)
- **App directory** (absolute path to the codebase) — required unless scope is QA-only
- **Live app URL** and **sign-in URL**
- **Credentials** per role (email/username + password). Accept them in chat; never write
  the raw password to disk.
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
Create a task list (TaskCreate) with: Login, each checklist group, UX sweep, Code review,
Report, Verify run.

## 4. Execute
- Scope includes QA → follow `/qa`
- Scope includes code → follow `/code-review` (can be delegated to the `code-reviewer`
  subagent so it runs with a fresh context while you continue)
- Then `/report`

## 5. Finish
Run `bash scripts/check-run.sh <run>`, fix anything it flags, then tell the user:
QA score + grade, code score + grade, top 3 issues, and the run folder path.
