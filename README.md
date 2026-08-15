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
| `/note` | Project problem knowledge | `.cursor/notes/projects/…/problems/` |
| `/upgrades` | Sharpen this pack’s skills | audit · propose · apply |

Skill conflicts: `rules/skill-router.mdc`. Per-skill: [skills/README.md](skills/README.md). Per-rule: [rules/README.md](rules/README.md).

## Setup (another machine)

Parent folder = Cursor workspace (e.g. `Skills/`). Clone/copy this pack as `Skills/agent-skills/`, then:

Windows:

```powershell
.\scripts\install-windows.ps1
# optional git pre-commit: .\scripts\install-hooks.ps1
```

macOS / Linux:

```bash
chmod +x ./scripts/install-unix.sh ./scripts/install-hooks.sh
./scripts/install-unix.sh
# optional: ./scripts/install-hooks.sh
```

Install recreates workspace `.cursor` from this pack (safe after deleting `.cursor`):

| Workspace path | Comes from pack |
|----------------|-----------------|
| `.cursor/skills/<name>` | `skills/<name>` (junction/symlink) |
| `.cursor/rules` | `rules/` |
| `.cursor/hooks.json` + `.cursor/hooks/*` | `cursor-hooks/` (notes-daily auto; opt-out supported) |
| `.cursor/plans/` · `.cursor/features/` | empty dirs (runtime) |
| `.cursor/notes/daily` · `.cursor/notes/projects` | empty dirs (runtime; problems via `/note`) |

Open **parent** workspace in Cursor → restart once → Agent `/`.

## Layout

```
cursor-hooks/      # Cursor agent hooks (install copies into ../.cursor)
skills/            # SKILL.md source
rules/             # agent-ops · enterprise-safety · skill-router · explicit-intent
templates/         # response + workspace (plan/feature) + ops/verify-matrix
scripts/           # install · validate-* · run-evals · git hooks
evals/             # fixtures + samples (CI)
.github/workflows/ # pack-ci
VERSION · CHANGELOG.md
```

## CI / validate

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
```

GitHub Action `pack-ci` runs validate + structural + behavior evals on push/PR to `main`.

Upgrade to 1.0.0: [MIGRATE.md](MIGRATE.md).

## Plans / Features / Notes (runtime)

`.cursor/plans/`, `.cursor/features/`, and `.cursor/notes/` are workspace-only (recreated empty by install; not pack git).  
`/note` writes under `.cursor/notes/projects/<project>/problems/`.  
**Daily prompts:** hooks append every user prompt to `.cursor/notes/daily/YYYY-MM-DD.md` (redacts secrets).  
Disable: `NOTES_DAILY_AUTO=0` or create `.cursor/hooks/state/notes-daily.off`.
