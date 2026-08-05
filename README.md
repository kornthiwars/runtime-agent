# agent-skills — Daily Skills & Rules Pack

Version: see [VERSION](VERSION) · [CHANGELOG](CHANGELOG.md)  
Source of truth: this folder only. Nothing is installed into user home.

## Commands

| Command | When | Gate |
|---------|------|------|
| `/fix` | Bug, unknown cause | Full |
| `/make <capability-id>` | Clear goal | Lite (`--full` when risky) |
| `/plan` | Cursor-style `.plan.md` + run todos | `.cursor/plans/` · 1 todo / confirm |
| `/feature <name>` | Pipeline by Policy | `.cursor/features/` · 1 slice / confirm |
| `/review` | Verdict | No edits |
| `/ship` | Commit / push | Await confirm |
| `/note` | Write memory | `notes/<project>/` · list · find |
| `/upgrades` | Sharpen this pack’s skills | audit · propose · apply |

Skill conflicts: `rules/skill-router.mdc`. Per-skill: [skills/README.md](skills/README.md).

## Setup

Windows:

```powershell
.\scripts\install-windows.ps1
# optional: .\scripts\install-hooks.ps1
```

macOS / Linux:

```bash
chmod +x ./scripts/install-unix.sh ./scripts/install-hooks.sh
./scripts/install-unix.sh
# optional: ./scripts/install-hooks.sh
```

Links into the **parent** workspace (junctions on Windows, symlinks on Unix):

- `../.cursor/skills/<name>` → `skills/<name>`
- `../.cursor/rules` → `rules/` (`.mdc` project rules)

Open parent `Skills` as workspace → restart Cursor → Agent `/`.

## Layout

```
../.cursor/skills/ # skill junctions (workspace root)
../.cursor/rules/  # rules junction (workspace root)
skills/            # SKILL.md source
rules/             # agent-ops · enterprise-safety · skill-router
templates/         # response + memory + ops/verify-matrix
scripts/           # install · validate-* · run-evals · hooks
evals/             # fixtures + samples (CI)
.github/workflows/ # pack-ci
VERSION · CHANGELOG.md
```

## CI / validate

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
```

GitHub Action `pack-ci` runs validate + evals on push/PR to `main`.

## Notes

Workspace: `notes/<project>/YYYY-MM-DD-<slug>.md` — Memory ≠ runtime.

## Plans

`.cursor/plans/<slug>_<8hex>.plan.md` — Cursor Plan format (workspace only; not pack git by default).

## Features

`.cursor/features/<slug>_<8hex>.feature.md` — `/feature` slice persistence (workspace only).
