---
description: Turn this run's improvements.md into anonymised GitHub issues on Inspekta's own repo
argument-hint: [run folder]
---

Load `inspekta-self-improve` and follow section 3 ("File issues at the end").
Run folder: $ARGUMENTS (default: newest in `runs/`).

1. Read `<run>/improvements.md`. Also look back over this session for friction you didn't
   log yet (retries, workarounds, permission prompts, confusing instructions, things you
   had to guess) and add those first.
2. Consolidate into issues. Anonymise every one: no client app names, URLs, emails,
   people, screenshots or code from the app. The repo is public.
3. Write each body to `<run>/improvements/issue-NN.md` and file it:
   `bash scripts/file-issue.sh "<title>" "<type>,priority:<level>" <run>/improvements/issue-NN.md`
   If the script refuses a body, rewrite it without the flagged details and retry.
   If gh isn't available, the script saves the issue to `improvements/inbox/`; tell the
   user to run `gh auth login` then `bash scripts/file-issue.sh --flush`.
4. Update `knowledge/apps/<app-slug>.md` with what you learned about this app
   (section 2 of the skill).
5. List the filed issues (titles + URLs) under "## Filed" in `improvements.md` and in your
   reply to the user, in one short list.
