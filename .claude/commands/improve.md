---
description: Work on Inspekta itself — pick self-reported GitHub issues and fix them in this repo
argument-hint: [issue number(s), or blank to choose]
---

You are now improving **Inspekta itself** (this repository), not testing a client app.
Arguments: $ARGUMENTS

1. **Pull first:** `git pull`.
2. **Pick issues.**
   - Numbers given → fetch them:
     `gh api repos/MUKE-coder/inspekta/issues/<n>` and its comments
     (`gh api repos/MUKE-coder/inspekta/issues/<n>/comments`).
   - None given → list open self-reported issues with their comment count ("seen again"
     = recurring) and labels:
     `gh api -X GET repos/MUKE-coder/inspekta/issues -f labels=self-reported -f state=open -f per_page=100 --jq '.[] | "#\(.number) [\([.labels[].name] | join(","))] (seen +\(.comments)) \(.title)"'`
     Propose the top 3–5 by priority × recurrence and ask the user which to do
     (AskUserQuestion, multi-select).
3. **Fix each issue** in Inspekta's own files: skills (`.claude/skills/`), commands
   (`.claude/commands/`), `CLAUDE.md`, templates, scripts, settings, README.
   - Keep changes focused. Instructions should be general patterns, not tied to one client app.
   - Scripts must keep working in Git Bash on Windows (CRLF-safe, no GNU-only flags) and
     on macOS/Linux. Run `bash -n` on every changed script and test it when you can.
   - If a fix changes how users run Inspekta, update README.
4. **Commit per issue:** `git commit -m "<summary> (fixes #<n>)"`.
5. **Ship it:** ask the user whether to (a) push to `main`, or (b) push a branch
   `improve/<n>-<slug>` and open a pull request. Never push without their yes.
   `fixes #n` in the commit closes the issue once it reaches `main`.
6. **Report back:** issues fixed, what changed (files), and anything deferred. For
   deferred issues, comment on the issue explaining why:
   `gh api -X POST repos/MUKE-coder/inspekta/issues/<n>/comments -f body="…"`.
