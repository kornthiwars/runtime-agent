# /feature response

Include shared [report.md](report.md).

**Plan turn:** `STATUS: AWAITING_CONFIRM` — no app code.  
**Slice turn** (after confirm): include slice result; still one slice only.

```
POLICY PIPELINE: plan → make/fix → review → ship
PHASE: plan | slice
SLICES:
  - slice-1 → /make ... | risk ... | pending|done
IRREVERSIBLES: migrate | delete | ... | none
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
ACTIVE_SLICE: slice-1 → /make|/fix ... | —
CONFIRM PROMPT: reply "ยืนยัน" for next slice only — or /review / /ship when done
NEXT: ยืนยัน slice-N | /review | /ship | —
```
