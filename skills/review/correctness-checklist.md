# /review — correctness checklist

- [ ] Happy path matches stated intent
- [ ] Edge: empty, null, overflow, timezone, concurrency
- [ ] Error paths: user-visible vs logged; no silent swallow
- [ ] Tests updated or justified absent
- [ ] Scope creep: unrelated refactors in the same diff
- [ ] API/contract breaks called out
- [ ] Rollback / feature-flag story if MED/HIGH
- [ ] Performance footguns only when evidence (N+1, unbounded list)

No Critical without CLAIM + EVIDENCE (see SKILL.md).
