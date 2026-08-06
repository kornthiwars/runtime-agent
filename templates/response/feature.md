# /feature response

Include shared [report.md](report.md).

**Plan turn:** `STATUS: AWAITING_CONFIRM` — no app code; must write/update `.feature.md`.  
**Slice turn** (after confirm): one slice only; update that slice `status` in file.

```
POLICY PIPELINE: plan → make/fix → review → ship
PHASE: plan | slice
PATH: .cursor/features/<slug>_<8hex>.feature.md
SLICES:
  - slice-1 → /make ... | risk ... | pending|in_progress|completed
IRREVERSIBLES: migrate | delete | ... | none
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
ACTIVE_SLICE: slice-1 → /make|/fix ... | —
CONFIRM PROMPT: reply "ยืนยัน" for next slice only — or /review / /ship when done
NEXT: ยืนยัน slice-N | /review | /ship | —
```
