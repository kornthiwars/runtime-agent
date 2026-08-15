# Shared REPORT

Use on skill close-out, BLOCKED, or AWAITING_CONFIRM. Mid-turn: `STATUS` + `OBJECTIVE` + `EVIDENCE` or `NEXT` only.

```
REPORT
STATUS: READY | BLOCKED | IN_PROGRESS | FAILED | AWAITING_CONFIRM | PLAN_READY | VERDICT
MODE: Full | Lite | n/a
RISK: LOW | MED | HIGH
OBJECTIVE: ...
EVIDENCE: ...
CHANGES: ... | none (no-edit)
VERIFY: IDENTIFY | RUN | READ | skip
NEXT: ...
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
OUTCOME: ...
```

## Field rules

- Empty narrative fields → `—`. Keep short. Expand only when BLOCKED, HIGH risk, or user asks.
- When `enterprise-safety` applies: `ENTERPRISE` + `BLAST_RADIUS` + `ROLLBACK` required **before** acting. Otherwise `ENTERPRISE: none` (or omit only on mid-turn short form).

## Daily notes (`OUTCOME`)

Hooks write `.cursor/notes/daily/YYYY-MM-DD.md` **Result** from the last agent reply, in order:

1. `OUTCOME:` block (1–6 lines) — preferred short close for humans + daily
2. Else `STATUS` / `OBJECTIVE` / `CHANGES` / `NEXT` / `VERIFY` from REPORT
3. Else last ≤6 non-empty lines of the reply (chat fallback)

Put `OUTCOME:` at the end of skill (or chat) answers when you want daily Result to stay crisp. One to three lines is enough; max six.
