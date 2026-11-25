---
description: Finalise and score the Inspekta reports for the current run
argument-hint: [run folder]
---

Load `inspekta-report`. Run folder: $ARGUMENTS (default: newest in `runs/`).

1. Run `bash scripts/collect-evidence.sh <run>` one last time.
2. Complete `report.md`: executive summary, scorecard (weighted 0–100 + grade),
   checklist results table, findings (sorted by severity), **Senior UI/UX Suggestions
   (beyond the checklist)**, what works well, prioritised next steps.
3. Make sure `code-review.md` is complete and its score appears in the `report.md` summary.
4. Write `<run>/fix-prompt.md` by following `/fix-prompt`: a copy-paste prompt for the
   app's maintainer AI to verify and fix every finding in priority order.
5. Run `/file-issues` for this run: anonymised self-improvement issues on Inspekta's repo,
   plus an update to `knowledge/apps/<app-slug>.md`.
6. Run `bash scripts/check-run.sh <run>` — every referenced image exists, no raw
   passwords, no empty template placeholders, fix prompt present. Fix and re-run until clean.
7. Reply to the user with the scores, top 3 issues, the folder path,
   "Fix prompt: `<run>/fix-prompt.md`", and the Inspekta issues filed (titles + links).
