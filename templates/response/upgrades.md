# /upgrades response

Include shared [report.md](report.md). Close with `OUTCOME:` (1–3 lines) when useful for daily notes Result.

```
MODE: audit | propose | apply
SCOPE: skills/… | rules/… | templates/… | pack
IMPROVEMENTS:
  - [High|Med|Low] …   # sharper trigger / steps / gates / examples / …
DRIFT: skill↔template↔README↔install | none
BREAKING: rename slash | REPORT change | none
NEXT: propose … | apply … | /ship | —
```

`audit`: `STATUS: VERDICT`. `propose`: `STATUS: PLAN_READY`. Both: `CHANGES: none (no-edit)`.
`apply` before renames, shared REPORT rewrites, or always-on `rules/*.mdc`: `STATUS: AWAITING_CONFIRM`.
Named/locked apply confirm covers write-budget override when the file list exceeds ≤5/≤120.
