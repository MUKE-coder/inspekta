# Created records — {{RUN_ID}}

Every record this run creates in the app, logged **the moment it's created**, including
side effects (e.g. approving an application created a student). `/report` verifies each one
is gone before the run is finished.

Status: `PENDING` (still exists, not yet cleaned) · `DELETED` (removal verified) ·
`RESIDUE` (couldn't be removed; give the reason) · `KEPT` (task allows it to stay)

| # | Time | Role | Resource | Identifier (ID / name) | How created | Status | Verified how / reason |
|---|------|------|----------|------------------------|-------------|--------|-----------------------|
