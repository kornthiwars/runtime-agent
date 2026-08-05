---
name: review
description: >-
  Produce a no-edit review verdict (approve / nits / request-changes / block)
  with severity rubric and claim-vs-evidence. Use when the user invokes /review,
  or asks for a PR/diff/pre-merge check. Do not use to patch code (/fix|/make),
  draft plans (/plan), orchestrate features (/feature), or commit (/ship).
disable-model-invocation: true
---

# /review

**No edits.** Verdict only. `CHANGES: none (no-edit)`. `STATUS: VERDICT`.

**vs others:** not `/plan` · not `/feature` · not `/make`/`/fix` · not `/ship`.  
After `/plan run` or `/feature` MED/HIGH → `/review` before `/ship`.

## Severity → verdict

| Highest finding | Verdict |
|-----------------|--------|
| Critical (correctness/security/data loss; proven or high-confidence) | `block` or `request-changes` |
| Suggestion only (should fix before merge; not catastrophic) | `request-changes` if merge-blocking; else `approve-with-nits` |
| Nice-to-have only | `approve-with-nits` or `approve` |
| No material findings | `approve` |

Use `block` when shipping would be unsafe (secrets, AuthZ hole, destructive migration without rollback). Use `request-changes` when fixable defects should land before merge.

## Claim vs evidence (required)

Every Critical/Suggestion must separate:

- **CLAIM** — what you assert  
- **EVIDENCE** — file/line, diff hunk, test output, or “not verified”

**Example A — good**  
CLAIM: AuthZ only hides the button.  
EVIDENCE: `Settings.tsx:88` client `if (!isAdmin)`; no server check in `api/settings.ts`.

**Example B — bad**  
CLAIM: “Probably insecure.” EVIDENCE: none → downgrade to Nice-to-have or omit.

## Steps

1. Optional notes recall (`agent-ops`) if PROJECT clear — constraints only.
2. Scope diff/PR/files.
3. Correctness, edge cases, tests, scope creep.
4. Security: secrets in client, XSS, AuthZ ≠ UI hide, open redirect, raw errors, PII.
5. If DB/migration, authz, payments, infra, bulk data → `enterprise-safety` lenses; gaps as Critical/`block` when appropriate.
6. Map findings → verdict via rubric above.
7. Recommend only — do not patch.

## Never

- Edit app or pack code in this skill  
- Invent Critical without evidence  
- Treat style nits as `block`

## Golden

In: `/review` on a diff that adds `API_KEY` to a client bundle.  
Out: `VERDICT: block` · Critical: secret in client · EVIDENCE: path+line · `NEXT: /fix` or remove then `/ship`.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/review.md](../../templates/response/review.md).
