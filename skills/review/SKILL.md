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
| Critical (proven / high-confidence safety or correctness) | `block` or `request-changes` |
| Suggestion (should fix before merge) | `request-changes` or `approve-with-nits` |
| Nice-to-have only | `approve-with-nits` or `approve` |
| None material | `approve` |

`block` = unsafe to ship. Every Critical/Suggestion needs **CLAIM** + **EVIDENCE** (path/line, diff, test, or “not verified”). No evidence → downgrade/omit.

**Example:** CLAIM AuthZ is UI-only · EVIDENCE `Settings.tsx:88` client check; none in `api/settings.ts`.

## Steps

1. Optional notes recall if PROJECT clear.
2. Scope diff/PR/files.
3. Walk correctness + security checklists (link above).
4. Enterprise surfaces → `enterprise-safety`; gaps may be Critical/`block`.
5. Map findings → verdict. Recommend only — do not patch.

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

Follow [templates/response/review.md](../../templates/response/review.md). Shared REPORT **CONTRACT v2**.
