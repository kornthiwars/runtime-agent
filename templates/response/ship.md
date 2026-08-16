# /ship response

Include shared [report.md](report.md). Prefer ending with `OUTCOME:` so daily notes Result stays short.

Status split (do not collapse):

- No ship-confirm word → `STATUS: AWAITING_SHIP_CONFIRM`.
- MED/HIGH app work **or** pack always-on `rules/*.mdc` / shared REPORT / slash rename missing `/review` (and no waive) → `STATUS: AWAITING_REVIEW` — **stop**; `/ship ยืนยัน` does **not** waive.
- Waive only: `ship without review` / `ข้าม review`.
- Confirm after inspect + review gate clear → commit/push, then `STATUS: READY`.

```
GIT: branch | dirty? | ahead/behind
DIFF SUMMARY: ...
STAGE: <paths to add> | none (empty → do not commit)
SECRETS SCAN: clean | flagged (abort until ยืนยัน/confirm/yes naming paths)
REVIEW: done | AWAITING_REVIEW | waived | n/a (pack-only LOW wording)
COMMIT MSG: <proposed; why; match git log style>
IRREVERSIBLES: commit | push | force-push | ...
CONFIRM: same-message | follow-up | awaiting
SCOPE NOTE: pack repo vs plans/demos — …
POST-VERIFY: remote HEAD / CI — after commit/push only
```
