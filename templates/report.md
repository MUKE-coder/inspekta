# {{APP_NAME}} — Live QA & UI/UX Review

| | |
|---|---|
| **Run** | {{RUN_ID}} |
| **Date** | {{DATE}} |
| **App URL** | {{APP_URL}} |
| **Roles tested** | {{ROLES}} |
| **Login sites** | {{LOGIN_SITES}} |
| **Browser(s)** | {{e.g. Chrome (Work profile) via extension; Edge for teacher}} |
| **Viewports** | 1440×900, 390×844 |
| **Reviewer** | Inspekta (Claude) |

## Executive summary
{{SUMMARY — 3–5 sentences: what was tested, headline problems, verdict}}

**Verdict:** {{Ready / Ready with fixes / Not ready}}

**Checklist pass rate:** {{x% (n/N scored; m blocked by environment, not counted)}}

| Report | Score | Grade |
|---|---|---|
| Live QA & UI/UX | {{QA_SCORE}}/100 | {{QA_GRADE}} |
| Code review ([code-review.md](code-review.md)) | {{CODE_SCORE}}/100 | {{CODE_GRADE}} |

## Scorecard

| Category | Weight | Score | Why |
|---|---|---|---|
| Functionality (checklist) | 30 | {{}} | {{pass rate x% (n/N), severity adj −y — see rubric}} |
| UX & flows | 20 | {{}} | {{}} |
| Visual design & consistency | 15 | {{}} | {{}} |
| States & resilience | 10 | {{}} | {{}} |
| Accessibility | 10 | {{}} | {{}} |
| Performance | 10 | {{}} | {{}} |
| Responsive / mobile | 5 | {{}} | {{}} |
| **Weighted total** | **100** | **{{QA_SCORE}}** | Grade **{{QA_GRADE}}** |

## Checklist results

| TC | Item | Result | Evidence | Finding |
|---|---|---|---|---|
| TC-01 | {{}} | {{PASS/FAIL/PARTIAL/BLOCKED}} | [img](evidence/{{}}) | {{QA-F01}} |

Pass rate: {{n}}/{{N}} ({{%}}). Full step-by-step log: [action-log.md](action-log.md).

## Roles & access

| Role | Login site | Auth method | Login result | Checklist pass | Notes |
|---|---|---|---|---|---|
| {{}} | {{}} | {{}} | {{PASS/FAIL}} | {{n/N}} | {{}} |

**Permission matrix:** ✅ allowed as expected · ⛔ blocked as expected · ❌ wrong (finding)

| Area / action | {{role 1}} | {{role 2}} | {{role 3}} |
|---|---|---|---|
| {{/admin (menu)}} | {{}} | {{}} | {{}} |
| {{/admin (direct URL)}} | {{}} | {{}} | {{}} |

## Findings

| ID | Severity | Title | TC | Code link |
|---|---|---|---|---|
| QA-F01 | {{}} | {{}} | {{}} | {{CR-xx}} |

<!-- Detailed findings below, using the format in inspekta-qa skill -->

## Senior UI/UX suggestions (beyond the checklist)

> Observations from a senior UI/UX perspective that the checklist did not ask for.

| ID | Priority | Suggestion | Area |
|---|---|---|---|
| UX-S01 | {{}} | {{}} | {{}} |

<!-- Detailed suggestions below, using the format in inspekta-ux-eye skill -->

## Console & network health

| Page | JS errors | Failed requests | Slow (>1s) | Notes |
|---|---|---|---|---|
| {{}} | {{}} | {{}} | {{}} | {{}} |

## Test data & cleanup

| Resource | Identifier | Created by | Final status | Notes |
|---|---|---|---|---|
| {{}} | {{}} | {{role}} | {{DELETED / RESIDUE / KEPT}} | {{how verified / why it remains}} |

**Residue left in the app:** {{none / list with the reason each couldn't be removed and the finding ID}}

## What works well
- {{}}

## Recommended next steps
1. {{Fix — refs}}
