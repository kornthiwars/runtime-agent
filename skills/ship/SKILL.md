---
name: ship
description: >-
  Inspect git state, propose commit/push, wait for confirm, then ship once and
  verify remote. Use when the user invokes /ship, or asks to commit, push, or
  publish. Do not use to implement features (/make|/feature), fix bugs (/fix),
  or only review (/review). Slash alone is not consent.
disable-model-invocation: true
---

# /ship

Slash alone ≠ consent. Inspect → propose → confirm → commit/push **once** → verify remote.

**Same-message confirm:** `/ship ยืนยัน` (or `confirm`/`yes` in the same message)
is valid **after** steps 1–3 in that turn — then step 5. No confirm word →
`AWAITING_CONFIRM`.

## Repo scope

- Run git from the **repo that owns the changes** (often `agent-skills/` for this pack).
- Default: do **not** stage workspace-only paths into the pack repo: `.cursor/plans/`,
  `.cursor/features/`, demo apps outside the pack
  (`youtube-home/`, `facebook-home/`, …) unless the user explicitly asks.
- Follow **git hygiene** in `agent-ops`.

## Steps

1. Parallel: `git status`, `git diff`, `git diff --staged`, `git log -5 --oneline`, branch tracking.
2. **DIFF SUMMARY** + **SECRETS SCAN** (`.env`, keys, tokens, credential files). If flagged → abort ship until user overrides explicitly.
3. Decide stage set (relevant files only). Do **not** create an empty commit when there is nothing to ship.
4. Propose **COMMIT MSG**: 1–2 sentences on **why**; match recent `git log` style. List **IRREVERSIBLES** (commit, push, force-push, …).
5. If no confirm yet: `AWAITING_CONFIRM` — do not commit/push.
6. After confirm: `git add` selected paths → commit → push only if requested or clearly implied.
7. Never force-push `main`/`master` unless user explicitly confirms force (e.g. `ยืนยัน force push`).
8. Never `--amend` of a commit already pushed unless user explicitly asks and force rules allow.
9. **POST-VERIFY:** remote HEAD / upstream. HIGH risk: one-line ROLLBACK.

## Failure playbook

| Status | Do |
|--------|-----|
| Secrets flagged | Abort; list paths; wait for explicit override |
| Nothing to commit | `READY` or `BLOCKED` with empty stage — **no** empty commit |
| Push rejected | Report remote error; do not force unless user confirms force |
| Wrong repo dirty | Ask once which repo; do not stage parent workspace junk into pack |

## Never

- Commit on inspect-only `/ship`  
- Ship secrets or “fix later” credential files  
- Force-push protected defaults without explicit force confirm  
- Drain unrelated dirty files “while we’re here”

## Golden

In: `/ship ยืนยัน` after pack skill edits, secrets clean.  
Out: commit once → push if implied → `POST-VERIFY` remote HEAD · `STATUS: READY`.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/ship.md](../../templates/response/ship.md). Shared [report.md](../../templates/response/report.md).
