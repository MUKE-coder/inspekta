---
description: Senior code review of the app directory for the current Inspekta run
argument-hint: [app directory] [run folder]
---

Load `inspekta-code-review`. Arguments: $ARGUMENTS
(If not given, take the app directory from `<run>/task.md` and the newest run folder.)

You may delegate the heavy reading to the `code-reviewer` subagent
(`.claude/agents/code-reviewer.md`), giving it the app dir, the run folder and the list of
QA findings so it can look for root causes.

Steps:
1. **Map the project** — detect Grit architecture (single / double / triple), read
   `.grit/project-profile.md` if present, `go.mod`, `package.json`s, `docker-compose.yml`.
   Note LOC and the biggest files.
2. **Run cheap static signals** where tools exist (don't install globally without asking):
   `go vet ./...`, `gofmt -l .`, `pnpm -r lint` / `tsc --noEmit` if configured.
   Record results; tool failures are themselves findings.
3. **Review by area** using the checklist in the skill: API handlers/services/models,
   data & queries (N+1, missing indexes, unbounded lists), security (authz on every
   route, input validation, secrets, CORS, uploads), frontend (React Query usage,
   re-renders, bundle size, error/loading states, accessibility), config & deploy, tests.
4. **Cross-link** QA findings to code root causes.
5. Write `<run>/code-review.md` from the template, with the weighted score.

Read-only: do not edit the target codebase unless the user asks.
