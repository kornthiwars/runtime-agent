---
name: review
description: >-
  Produce a no-edit review verdict (approve / nits / request-changes / block)
  with severity rubric and claim-vs-evidence. Use when the user invokes /review,
  or asks for a PR/diff/pre-merge check. Do not use to patch (/fix|/make),
  draft plans (/plan), orchestrate features (/feature), or commit (/ship).
disable-model-invocation: true
---

# /review

**No edits.** `CHANGES: none (no-edit)`. `STATUS: VERDICT`.

Depth checklists (read when needed):  
[security-checklist.md](security-checklist.md) · [correctness-checklist.md](correctness-checklist.md)

## Severity → verdict

| Highest finding | Verdict |
|-----------------|--------|
| Critical — **unsafe to ship** (exploit, data loss, authz hole, broken prod path) with evidence | `block` |
| Critical — **must fix before merge** but not an immediate ship hazard (proven bug, missing gate) | `request-changes` |
| Suggestion — correctness/security/contract should-fix before merge | `request-changes` |
| Suggestion — style/clarity only, no correctness/security impact | `approve-with-nits` |
| Nice-to-have only | `approve-with-nits` |
| None material | `approve` |

**Tie-break:** if unsure whether Critical is ship-unsafe → prefer `request-changes` and say why (not `block` on vibes). Suggestion: if unsure whether it is must-fix vs nit → prefer `request-changes`. `block` = do not merge/ship until fixed or explicitly accepted.

**Example:** CLAIM AuthZ is UI-only · EVIDENCE `Settings.tsx:88` client check; none in `api/settings.ts`.

## Steps

1. Scope diff/PR/files.
2. Walk correctness + security checklists (link above).
3. Enterprise surfaces → `enterprise-safety`; gaps may be Critical/`block`.
4. Map findings → verdict. Recommend only — do not patch.

## Failure playbook

| Issue | Do |
|-------|-----|
| Diff too large / unclear scope | Ask once for path/PR; verdict `request-changes` on process if still blind |
| Suspected Critical, unverified | State “not verified”; do not `block` on vibes alone — or `request-changes` asking for proof path |

## Never

Edit code · invent Critical without evidence · style-nit as `block`

## Golden

In: `/review` diff with client `API_KEY`  
Out: `VERDICT: block` · Critical + path:line · `NEXT: /fix` or remove then `/ship`

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/review.md](../../templates/response/review.md). Shared [report.md](../../templates/response/report.md).
