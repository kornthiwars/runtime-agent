# Changelog

## 2.2.0 — 2026-08-06

- `/note` stores in Mongo `notes` via `model-rust note add|list|find` — remove file-based `notes/*.md`
- Delete `validate-note.*`, `note-template.md`, CI sample note markdown
- Docs/rules: recall uses `note list`; split `notes` vs chat `cases`

## 2.1.2 — 2026-08-06

- Reduce skill overlap: `skill-router` priority ladder + anti-overlap table
- `/make` vs `/feature` exclusive (≥2 slices / review-before-ship); `/plan` points single capability → `/make`
- Memory split: `/note` durable files vs model-rust auto (no double-write) in `agent-ops` + `model-rust-auto` + `/note`
- `install-windows.ps1`: replace whole-folder `.cursor/skills` junction before per-skill links (safe dual-pack workspaces)

## 2.1.1 — 2026-08-06

- Hooks: save on `status=completed` only (ignore `loop_count`); `project: agent-skills`; spawn `cwd` = crate root for `.env`
- Unix hook: prompt keys match Node (`prompt_text` / `text` / …)
- `model-rust-auto` rule: hooks own persist; agent `add` only on FAIL/SKIP/disabled
- Docs: plan validate paths `../.cursor/plans`; skills README lists `model-rust-auto`; `/fix` HIGH → `AWAITING_CONFIRM`

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
