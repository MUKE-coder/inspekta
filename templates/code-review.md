# {{APP_NAME}} — Senior Code Review

| | |
|---|---|
| **Run** | {{RUN_ID}} |
| **Date** | {{DATE}} |
| **Codebase** | `{{APP_DIR}}` |
| **Commit** | {{GIT_SHA}} ({{BRANCH}}) |
| **Framework** | {{Grit vX — single / double / triple}} |
| **Size** | {{Go LOC / TS LOC / files}} |
| **Reviewer** | Inspekta (Claude) |

## Executive summary
{{3–5 sentences: overall health, biggest risks, verdict}}

## Scorecard

| Category | Weight | Score | Why |
|---|---|---|---|
| Security | 20 | {{}} | {{}} |
| Correctness & error handling | 20 | {{}} | {{}} |
| Architecture & conventions | 15 | {{}} | {{}} |
| Data layer & performance | 15 | {{}} | {{}} |
| Maintainability & readability | 15 | {{}} | {{}} |
| Frontend quality | 10 | {{}} | {{}} |
| Tests & tooling | 5 | {{}} | {{}} |
| **Weighted total** | **100** | **{{CODE_SCORE}}** | Grade **{{CODE_GRADE}}** |

## Static checks

| Tool | Result |
|---|---|
| `go vet ./...` | {{}} |
| `gofmt -l .` | {{}} |
| `tsc --noEmit` / lint | {{}} |

## Findings

| ID | Severity | Title | Location | QA link |
|---|---|---|---|---|
| CR-01 | {{}} | {{}} | `{{file:line}}` | {{QA-Fxx}} |

<!-- Detailed findings below, using the format in inspekta-code-review skill -->

## Live-bug root causes

| QA finding | Root cause | Code finding |
|---|---|---|
| {{QA-F03}} | {{}} | {{CR-04}} |

## What's done well
- {{}}

## Refactoring roadmap
1. {{Fix — refs — effort S/M/L}}
