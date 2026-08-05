# agent-skills — Daily Skills & Rules Pack

Source of truth: this folder only. Nothing is installed into user home.

## Commands

| Command | When | Gate |
|---------|------|------|
| `/fix` | Bug, unknown cause | Full |
| `/make <capability-id>` | Clear goal | Lite (`--full` when risky) |
| `/plan` | Cursor-style `.plan.md` + run todos | `.cursor/plans/` · 1 todo / confirm |
| `/feature <name>` | Pipeline by Policy | Confirm required |
| `/review` | Verdict | No edits |
| `/ship` | Commit / push | Await confirm |
| `/note` | Write memory | `notes/<project>/` · list · find |
| `/upgrades` | Sharpen this pack’s skills | audit · propose · apply |


Per-skill usage: [skills/README.md](skills/README.md) · each folder’s `USAGE.md`.

## Setup

Windows:

```powershell
.\scripts\install-windows.ps1
```

macOS / Linux:

```bash
chmod +x ./scripts/install-unix.sh
./scripts/install-unix.sh
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
rules/             # agent-ops.mdc + enterprise-safety.mdc (alwaysApply)
templates/         # response + memory templates
scripts/           # install + skill-names.txt + validate-*.ps1/.sh
evals/             # regression prompts for pack smoke checks
```

- `rules/agent-ops.mdc` — confirm, no-edit, Full/Lite, risk/verify, secrets/PII
- `rules/enterprise-safety.mdc` — DB/migration, auth, payments, data, infra (HIGH + BLAST_RADIUS + ROLLBACK)

Validate after skill add/rename:

```powershell
.\scripts\validate-skill-names.ps1
```

## Notes

Workspace root: `notes/<project>/YYYY-MM-DD-<slug>.md`

| Command | Does |
|---------|------|
| `/note` · `/note <project>` | Write (always save unless chat-only) |
| `/note list` · `/note list <project>` | List folders / files (`[expired]` if past `expires`) |
| `/note find <query>` | Search note text |

Memory ≠ runtime. No secrets, logs, or stacks in notes.

## Plans

Cursor Plan **file format** at **workspace** (not in `agent-skills` pack git):

`.cursor/plans/<slug>_<8hex>.plan.md`

Same YAML shape as native Cursor Plan mode; entry is the `/plan` skill.

| Command | Does |
|---------|------|
| `/plan` · `/plan …` | Draft + save `.plan.md` |
| `/plan list` | List workspace plans |
| `/plan run` · `/plan run <file\|name>` | Run next `pending` todo (1 confirm = 1 todo) |

`8hex` = eight random hex digits; regenerate if the filename already exists.  
Do not use legacy `plans/<project>/` folders.
