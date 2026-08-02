---
name: plan
description: >-
  Draft a short Task Graph without editing source or config. Use when the user
  invokes /plan, or asks for a plan/task breakdown before implementation.
disable-model-invocation: true
---

# /plan

**No edits** to app source, config, CI, or deploy. `CHANGES: none (no-edit)`.

## Steps

1. Clarify goal in one line.
2. Draft short TASK GRAPH (ordered steps).
3. OWNERS (layer/area), NON-GOALS, RISK, conflict priority if tradeoffs: Security → A11y → SSoT → SoC → Perf.
4. EXCEPTIONS if intentionally diverging: owner | reason | scope | expiry.
5. Status `PLAN_READY`. Do not implement even if user says “do it now” in the same turn — finish plan and stop; suggest `/make` or `/feature`.

## Output

Follow [templates/response/plan.md](../../templates/response/plan.md). Short.
