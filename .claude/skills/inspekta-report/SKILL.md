---
name: inspekta-report
description: Scoring rubrics (weighted 0–100 + A–F grade) and report-writing rules for Inspekta's report.md (live QA + UI/UX) and code-review.md. Use when scoring or finalising any Inspekta report.
---

# Scoring & reporting

## QA / UI-UX rubric (report.md) — weighted 0–100

| Category | Weight | What 100 looks like |
|---|---|---|
| Functionality (checklist) | 30 | Every checklist item passes; no data bugs |
| UX & flows | 20 | Tasks are obvious, few steps, good feedback, no dead ends |
| Visual design & consistency | 15 | Clean hierarchy, consistent components, themes polished |
| States & resilience | 10 | Loading/empty/error/success all designed; no raw errors |
| Accessibility | 10 | Keyboard-able, visible focus, contrast passes, labels/alt |
| Performance (perceived + network) | 10 | Fast first content, no slow/duplicate calls, no console errors |
| Responsive / mobile | 5 | Works well at 390px with no horizontal scroll |

**Functionality score** starts from checklist pass rate (PASS = 1, PARTIAL = 0.5,
FAIL/BLOCKED = 0) × 100, then subtract 10 per Critical and 5 per High finding (min 0).
Other categories: judge 0–100 against the "what 100 looks like" column; one-line
justification each.

Any ❌ in the permission matrix where a role can reach data or actions it shouldn't is
**Critical** (privilege escalation / data exposure).

**Overall** = Σ(score × weight) / 100, rounded. **Caps:** any open Critical → overall
max 59 (F); login broken → max 40.

## Code rubric (code-review.md) — weighted 0–100

| Category | Weight |
|---|---|
| Security | 20 |
| Correctness & error handling | 20 |
| Architecture & framework conventions (Grit handler→service→model, etc.) | 15 |
| Data layer & performance | 15 |
| Maintainability & readability | 15 |
| Frontend quality | 10 |
| Tests & tooling | 5 |

Caps: an exploitable security issue (auth bypass, IDOR, injection, leaked secret) →
max 59.

## Grades
A 90–100 · B 80–89 · C 70–79 · D 60–69 · F < 60

## Calibration
- Typical decent MVP: QA 65–78, code 60–75. Reserve 90+ for genuinely excellent work.
- Don't double-penalise: one root cause = one finding (cross-linked), not five.
- Every category score has a one-line "why" and links to the findings that drove it.

## Report rules
- Executive summary first: 3–5 sentences, scores, verdict (Ready / Ready with fixes / Not ready).
- Findings sorted by severity, IDs stable (`QA-F01`, `UX-S01`, `CR-01`).
- Senior UI/UX Suggestions section is **explicitly beyond the checklist**.
- Evidence images embedded with relative paths `![caption](evidence/file.png)`.
- "What works well" — real strengths only, short.
- Next steps: top 5 fixes ordered by impact ÷ effort, each referencing finding IDs.
- No raw passwords anywhere. No unfilled `{{placeholders}}`.
