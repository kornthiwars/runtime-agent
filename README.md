# agent-skills — Daily Skills & Rules Pack

Source of truth: this folder only. Nothing is installed into user home.

## Commands

| Command | When | Gate |
|---------|------|------|
| `/fix` | Bug, unknown cause | Full |
| `/make <capability-id>` | Clear goal | Lite (`--full` when risky) |
| `/plan` | Draft Task Graph | Short · no source edits |
| `/feature <name>` | Pipeline by Policy | Confirm required |
| `/review` | Verdict | No edits |
| `/ship` | Commit / push | Await confirm |
| `/note` | Write memory | `notes/<project>/` · list · find |

## Setup

```powershell
.\scripts\install-windows.ps1
```

Creates junctions in the **parent** workspace:

- `../.cursor/skills/<name>` → `skills/<name>`
- `../.cursor/rules` → `rules/` (`.mdc` project rules)

Open parent `Skills` as workspace → restart Cursor → Agent `/`.

## Layout

```
../.cursor/skills/ # skill junctions (workspace root)
../.cursor/rules/  # rules junction (workspace root)
skills/            # SKILL.md source
rules/             # .mdc project rules (alwaysApply)
templates/         # response + memory templates
scripts/
```

## Notes

Workspace root: `notes/<project>/YYYY-MM-DD-<slug>.md`

| Command | Does |
|---------|------|
| `/note` · `/note <project>` | Write (always save unless chat-only) |
| `/note list` · `/note list <project>` | List folders / files (`[expired]` if past `expires`) |
| `/note find <query>` | Search note text |

Memory ≠ runtime. No secrets, logs, or stacks in notes.
