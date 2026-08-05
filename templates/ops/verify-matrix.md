# VERIFY matrix (/fix · /make)

After a patch, pick **one primary** command from the row that matches the diff.
State it in REPORT as IDENTIFY → RUN → READ.

| Diff kind | Prefer IDENTIFY | Notes |
|-----------|-----------------|-------|
| Unit / pure logic | existing test for module, or nearest test file | Fail → fix or BLOCKED |
| API / route | focused test or `curl`/HTTP to local handler | Assert status + body key |
| UI / HTML / CSS | open or serve file; smoke assert visible text/selector | Screenshot only if user asks |
| SQL / migration | migrate dry-run or test DB up+down | Never prod without named confirm |
| Script / CLI | run script with safe args; check exit 0 + stdout | |
| Pack skill / docs only | `.\scripts\validate-skill-names.ps1` (+ plan/note validate if touched) | |
| Ambiguous | smallest existing project test / lint / typecheck | Say why chosen |

**Never:** close with “should work” and no READ output.  
**Blocked verify:** no runnable command → `STATUS: BLOCKED`, ask once for how they usually verify.
