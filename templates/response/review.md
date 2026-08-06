# /review response

Include shared [report.md](report.md) (**CONTRACT v2**). `CHANGES: none (no-edit)`. `STATUS: VERDICT`.

```
VERDICT: approve | approve-with-nits | request-changes | block
FINDINGS:
  Critical: ...      # → usually block or request-changes
  Suggestion: ...    # → request-changes or approve-with-nits
  Nice-to-have: ...  # → approve-with-nits or approve
SECURITY: AuthZ≠UI | secrets | XSS | redirect | PII | —
CLAIM VS EVIDENCE:
  - CLAIM: ...
    EVIDENCE: path:line | diff | test | not verified
```

Map severity → verdict per `skills/review/SKILL.md` rubric. No Critical without evidence.