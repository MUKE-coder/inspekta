# Fix prompt — {{APP_NAME}} ({{RUN_ID}})

Copy everything inside the box below and paste it into the AI that maintains
**{{APP_NAME}}** (Claude Code, Cursor, etc.), opened in `{{APP_DIR}}`.

````text
You are the maintainer of {{APP_NAME}}. An independent reviewer (Inspekta) has tested the
LIVE app in a real browser and done a senior code review of this repository. Your job:
read the review, verify each finding against the code, and fix them in priority order.

## The review
- Live QA & UI/UX report: {{REPORT_PATH}}
  (QA score {{QA_SCORE}}/100, grade {{QA_GRADE}})
- Code review: {{CODE_REVIEW_PATH}}
  (code score {{CODE_SCORE}}/100, grade {{CODE_GRADE}})
- Step-by-step test log: {{ACTION_LOG_PATH}}
- Screenshots: {{EVIDENCE_DIR}}  (open the ones a finding links to; you can view images)

Read both reports in full before changing anything.

## Findings to fix, in this order
{{FINDINGS_TABLE}}
<!-- table: Priority | ID | Severity | Title | Where (file:line or URL) | Linked IDs -->

IDs: QA-Fnn = bug seen live · UX-Snn = senior UI/UX suggestion (beyond the checklist) ·
CR-nn = code review finding. "QA-F03 ↔ CR-04" means the live bug's likely root cause is
that code finding: fix the root cause once, not the symptom twice.

## Test data left in the live app
{{RESIDUE}}
<!-- Inspekta couldn't remove these records it created while testing. Remove them by hand
     (or ask me), and fix the linked finding so the app can delete what it creates. "None" if empty. -->

## How to work
1. **Verify first.** For each finding, open the cited file/route and confirm the problem
   is real. Inspekta reads code without running it and sees the live app from outside,
   so it can be wrong. If a finding is wrong or already fixed, don't change code; mark
   it `REJECTED` or `ALREADY FIXED` with a one-line reason.
2. **Plan, then ask me once** before you start, if any fix:
   - changes the database schema or needs a migration on live data,
   - changes auth, roles or permissions behaviour users will notice,
   - is large (more than ~1 day of work) or needs a product decision (most UX-S items),
   - would break the API contract for the web/admin/mobile apps.
   Everything else: just fix it.
3. **Fix in priority order**: all Critical, then High, then Medium, then Low and UX-S.
   One finding (or one root cause) per commit. Commit message: `fix(QA-F03, CR-04): …`.
4. **Follow this project's conventions** (for Grit: handler → service → model, generated
   hooks/types, shadcn tokens for colours). Don't refactor unrelated code.
5. **Prove each fix**: add or update a test where practical (Go table tests for services
   and handlers; component or e2e tests for UI), then run the project's lint, typecheck
   and tests. Don't mark a fix done while they fail.
6. **Permissions findings** (a role reaching what it shouldn't) must be fixed
   **server-side** (middleware/service checks), not only by hiding UI.
7. Don't push or deploy unless I ask.

## When you're done
Write `.inspekta/fix-summary.md` at the repo root (keep `.inspekta/` gitignored):

| ID | Status (FIXED / PARTIAL / REJECTED / ALREADY FIXED / DEFERRED) | What changed (files) | Commit | How to re-test |
|----|---------------------------------------------------------------|----------------------|--------|----------------|

Then add:
- **Needs a decision from me:** anything you deferred, and why
- **Re-test checklist:** a short checklist of exactly what Inspekta should re-test live
  (role + page + expected result) to confirm the fixes, in the same style as the
  original checklist

Finally, give me a short summary: fixed / rejected / deferred counts and anything risky.
````

After the fixes, re-run Inspekta on the same app. It reads `.inspekta/fix-summary.md` and
uses its re-test checklist.
