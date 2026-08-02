---
name: review
description: >-
  Produce a review verdict without editing code. Use when the user invokes
  /review, or asks for a PR/diff review, verdict, or pre-merge check.
disable-model-invocation: true
---

# /review

**No edits.** Verdict only. `CHANGES: none (no-edit)`. Status `VERDICT`.

**vs others:** not `/plan` (no new task graph) · not `/feature` (no slice orchestration) ·
not `/make`/`/fix` (no patches). After a `/plan run` or `/feature` MED/HIGH path,
run `/review` before `/ship`.

## Steps

1. Optional notes recall (`agent-ops`) if PROJECT is clear — constraints only.
2. Scope the diff/PR/files under review.
3. Check correctness, edge cases, tests, scope creep.
4. Security checklist: secrets in client, XSS sinks, AuthZ ≠ UI hide, open redirect, raw errors to users, PII.
5. If the diff touches DB/migration, authz, payments, infra, or bulk data: also apply
   `enterprise-safety` lenses (destructive DDL, shipped-migration edits, missing
   rollback, widened access). Flag gaps as Critical or `block` when appropriate.
6. Separate CLAIM VS EVIDENCE.
7. Verdict: `approve` | `approve-with-nits` | `request-changes` | `block`.
8. Findings: Critical / Suggestion / Nice-to-have. Recommend only — do not patch.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/review.md](../../templates/response/review.md).
