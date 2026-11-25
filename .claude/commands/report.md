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
4. Run `bash scripts/check-run.sh <run>` — every referenced image exists, no raw
   passwords, no empty template placeholders. Fix and re-run until clean.
5. Reply to the user with the scores, top 3 issues and the folder path.
