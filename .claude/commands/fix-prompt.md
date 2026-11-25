---
description: Write fix-prompt.md for a finished run, a copy-paste prompt for the app's maintainer AI to verify and fix the findings
argument-hint: [run folder]
---

Run folder: $ARGUMENTS (default: newest in `runs/`).

1. Read `<run>/report.md`, `<run>/code-review.md` and `<run>/task.md`.
2. Copy `templates/fix-prompt.md` to `<run>/fix-prompt.md` and fill every placeholder:
   - `{{APP_NAME}}`, `{{RUN_ID}}`, `{{APP_DIR}}` from task.md
   - `{{REPORT_PATH}}`, `{{CODE_REVIEW_PATH}}`, `{{ACTION_LOG_PATH}}`, `{{EVIDENCE_DIR}}`:
     **absolute paths** to the files in this run folder, because the maintainer AI works in a
     different folder. On Windows, use the form the user's tools show (e.g. `D:\...\runs\...`).
   - scores and grades from the reports
   - `{{FINDINGS_TABLE}}`: every QA-F, CR and UX-S item as a Markdown table
     `| Priority | ID | Severity | Title | Where | Linked IDs |`, sorted Critical → Low,
     with linked pairs (QA-F03 ↔ CR-04) on adjacent rows. UX-S items go last unless
     their severity is High. Priority is 1, 2, 3…
3. No credentials in this file, not even redacted ones. The maintainer doesn't need them.
4. Leave no `{{…}}` placeholders. Then tell the user:
   "Fix prompt ready: `<run>/fix-prompt.md`. Copy the box into the AI in your app's repo."
