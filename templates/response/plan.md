# /plan response

Include shared [report.md](report.md).

## draft

`STATUS: PLAN_READY`. App unchanged. `CHANGES` = plan path or `none (chat-only)`.

```
MODE: draft
NAME: …
PATH: .cursor/plans/<slug>_<8hex>.plan.md | —
FORMAT: Cursor Plan (.plan.md in workspace)
TODOS: N pending
NEXT: /plan run <filename>
```

Mention that the file lives under workspace `.cursor/plans/` (Plan-mode format).

## list

```
MODE: list
ITEMS:
- <file> · <name> · pending N / done M
NEXT: /plan run <file> | —
```

## run

Before confirm: `AWAITING_CONFIRM` (unless same-message `ยืนยัน` after inspect).

```
MODE: run
PATH: .cursor/plans/…
TODO: <id> · <content>
SKILL: /make | /fix (explicit | inferred | asked)
CONFIRM: same-message | follow-up | awaiting
CHANGES: … | —
NEXT: /plan run | ยืนยัน | /review | /ship | —
```
