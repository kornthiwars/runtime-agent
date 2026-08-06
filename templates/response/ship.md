# /ship response

Include shared [report.md](report.md) (**CONTRACT v2**).

If the user message has no confirm: `STATUS: AWAITING_CONFIRM`.  
If `/ship ยืนยัน` (same message) and inspect is clean: proceed, then `STATUS: READY`.

```
GIT: branch | dirty? | ahead/behind
DIFF SUMMARY: ...
STAGE: <paths to add> | none (empty → do not commit)
SECRETS SCAN: clean | flagged (abort until override)
COMMIT MSG: <proposed; why; match git log style>
IRREVERSIBLES: commit | push | force-push | ...
CONFIRM: same-message | follow-up | awaiting
SCOPE NOTE: pack repo vs plans/demos — …
POST-VERIFY: remote HEAD / CI — after commit/push only
```