# Changelog

## 3.0.3 — 2026-08-09

Rule boundaries (no new rule file):

- `rules/README.md`: responsibility table + Rule Boundaries + overlap resolution + architecture diagram
- `explicit-intent`: rewrite Purpose/Rules/AI Readability/Do Not/Out of scope/Principle; MUST NOT own search/read budget/confirm/skill ownership
- Frontmatter role keywords on all five rules; `agent-ops` clarifies ops ≠ code style

## 3.0.2 — 2026-08-09

Explicit Intent & Readability (code quality / maintainability):

- New always-on rule `rules/explicit-intent.mdc`: do/don’t pairs + AI Readability + principle (not a vague “no ambiguous code” ban)
- Complements `agent-ops` read budget (locate cheaply vs write intent clearly)
- `/make` · `/fix` Never: ban compressing for line-count at expense of explicit intent
- README / skills README rule lists updated; `rules/README.md` summarizes each rule

## 3.0.1 — 2026-08-08

Read budget + AI-navigable modules (no Mongo schema change):

- `agent-ops`: **read budget** (locate-before-read) + purpose-named splits; write budget wording clarified
- `/make` · `/fix`: checklist + Never encode locate-before-read; ban equal-size chops without discoverable names
- `/plan` draft: AI-nav / token-structure todos split by responsibility
- `/review` correctness: Suggestion for god files / names that force full-blob scans
- `make` response template: `READ` line; USAGE sync for make/fix

## 3.0.0 — 2026-08-06

Closed-loop pack bar + memory CLI cleanup:

- **Breaking:** `model-rust add` rejects legacy `problem` / `solutionSummary` / `solution`; require `summary`
- `note expire` · `note purge` · `turns-purge` (+ retention / search-quality docs)
- Behavior evals (`evals/behavior` + `run-behavior-evals.*`) in CI alongside structural fixtures
- Structural fixtures: plan-run confirm · feature review-before-ship · note write · upgrades apply confirm · make enterprise blast
- `/review` memory parity; drop versioned REPORT branding; shared REPORT keeps `MODEL-RUST` / `NOTES`
- See [MIGRATE.md](MIGRATE.md)

## 2.4.2 — 2026-08-06

- Drop versioned REPORT branding; keep shared REPORT + `MODEL-RUST` / `NOTES` fields
- Rename eval fixture to `report-shared-fields`; upgrades/evals wording uses Formats / required strings

## 2.4.1 — 2026-08-06

- `/review` memory parity with `agent-ops`: required `search` + `note list` cites (`MODEL-RUST` / `NOTES`); no longer optional
- `agent-ops` memory gate includes `/review`; review template + fixture assert recall fields

## 2.4.0 — 2026-08-06

Shared REPORT fields for close-out:

- `templates/response/report.md`: required `MODEL-RUST` / `NOTES` + field rules
- `agent-ops` + `enterprise-safety`: close-out / enterprise gates cite shared REPORT
- Skill response templates + Output lines sync to shared REPORT
- Eval fixture guards skill↔report drift

## 2.3.3 — 2026-08-06

Pack audit hardening (`pack_audit_hardening`):

- Skills `/fix`·`/make`·`/feature`·`/plan`: checklist/USAGE require `search` + `note list` cites (`MODEL-RUST` / `NOTES`)
- `MONGODB_DB` SSoT default `model-rust` (schema + CLI + note reference)
- Hooks: redact `mongodb+srv://user:pass@…` and similar credential URIs; Unix prompt-key parity with Node
- Evals: assert `expect_status` / `expect_redirect_hint` / `expect_depth` / `expect_verdict_any` / `forbidden_actions`

## 2.3.2 — 2026-08-06

- Hooks: strip UTF-8 BOM before JSON parse; richer prompt key probe + key logging
- Rules: mandatory `model-rust search` before substantive `/fix|/make|/feature|/plan` (cite MODEL-RUST)

## 2.3.1 — 2026-08-06

- `project` is set by the agent (`MODEL-RUST-PROJECT: <slug>`); hooks no longer hardcode `agent-skills`

## 2.3.0 — 2026-08-06

- Flatten Mongo schema: `turns` + `notes` only (drop prompts/problems/solutions/cases triad)
- `model-rust add|search|get` operate on `turns`; hooks write flat turn stubs
- Legacy JSON fields `problem` / `solutionSummary` still map into `summary`

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
