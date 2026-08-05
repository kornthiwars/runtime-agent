# Changelog

## 2.1.0 — 2026-08-06

- Add `model-rust/` (Mongo AI ops CLI) + `rules/model-rust-auto.mdc`
- Add `cursor-hooks/` and extend install to recreate workspace `.cursor` (skills, rules, hooks, model-rust junction) after delete

## 2.0.0 — 2026-08-05

Toward 10/10 agent-ops pack bar:

- `/feature` persists slices under workspace `.cursor/features/*.feature.md`
- Skill conflict router (`rules/skill-router.mdc`)
- Runnable eval fixtures + `scripts/run-evals.*` + GitHub Actions CI
- `/review` progressive checklists; `/fix`·`/make` verify matrix + failure playbooks
- Pack `VERSION`, validate hooks, USAGE/Golden sync

## 1.x

Prior releases through `719f848` (top-tier skill patterns: rubrics, references, validate scripts).
