# /plan response

Include shared [report.md](report.md). Prefer `OUTCOME:` for daily notes Result.

## draft

`STATUS: PLAN_READY`. App unchanged. `CHANGES` = plan path (file written).

```
MODE: draft
NAME: …
PATH: .cursor/plans/<slug>_<8hex>.plan.md
FORMAT: Cursor Plan (.plan.md in workspace)
TODOS: N pending
NEXT: /plan run <filename>
```

## chat

User asked chat-only / อย่าเซฟ. Do **not** write `.plan.md`.

```
MODE: chat
CHANGES: none (chat-only)
NEXT: /plan … (to save) | —
```

## list

```
MODE: list
ITEMS:
- <file> · <name> · pending N / done M
NEXT: /plan run <file> | —
```

## run

Before confirm: `AWAITING_CONFIRM` (unless same-message `ยืนยัน`/`confirm`/`yes` after inspect).

```
MODE: run
PATH: .cursor/plans/…
TODO: <id> · <content>
SKILL: /make | /fix (explicit | inferred | asked)
CONFIRM: same-message | follow-up | awaiting
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
CHANGES: … | —
NEXT: /plan run | ยืนยัน | /review | /ship | —
```

If the todo hits schema/auth/payments/infra/data/prod: nested `AWAITING_CONFIRM` + BLAST_RADIUS/ROLLBACK **before** writes — todo `ยืนยัน` alone is not enough.
