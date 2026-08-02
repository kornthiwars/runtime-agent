# /ship response

Include shared [report.md](report.md).

If the user message has no confirm: `STATUS: AWAITING_CONFIRM`.  
If `/ship ยืนยัน` (same message) and inspect is clean: proceed, then `STATUS: READY`.

```
GIT: branch | dirty? | ahead/behind
DIFF SUMMARY: ...
SECRETS SCAN: clean | flagged
COMMIT MSG: <proposed>
IRREVERSIBLES: commit | push | force-push | ...
CONFIRM: same-message | follow-up | awaiting
POST-VERIFY: remote HEAD / CI — after commit/push only
```
