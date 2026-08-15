# /feature response

Include shared [report.md](report.md). Prefer `OUTCOME:` for daily notes Result.

**Plan turn:** `STATUS: AWAITING_CONFIRM` — no app code; must write/update `.feature.md` (**reuse** newest matching `<slug>_*.feature.md` when one exists).  
**List turn:** no edits.  
**Slice turn** (after confirm): one slice only; update that slice `status` in file.

## list

```
MODE: list
ITEMS:
- <file> · <name> · pending N / done M
NEXT: /feature <name> | ยืนยัน slice-N | —
```

## plan / slice

```
POLICY PIPELINE: plan → make/fix → review → ship
PHASE: plan | slice
MODE: plan | slice
PATH: .cursor/features/<slug>_<8hex>.feature.md
REUSE: yes (existing) | no (created)
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
