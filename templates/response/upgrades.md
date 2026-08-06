# /upgrades response

Include shared [report.md](report.md).

```
MODE: audit | propose | apply
SCOPE: skills/… | rules/… | templates/… | pack
IMPROVEMENTS:
  - [High|Med|Low] …   # sharper trigger / steps / gates / examples / …
DRIFT: skill↔template↔README↔install | none
BREAKING: rename slash | REPORT change | none
NEXT: propose … | apply … | /ship | —
```

`audit` / `propose`: `CHANGES: none (no-edit)`.
`apply` before renames or shared REPORT rewrites: `STATUS: AWAITING_CONFIRM`.
