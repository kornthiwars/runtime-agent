# /note — reference

## Storage

- **MongoDB** database from `model-rust/.env` (`MONGODB_DB`, default `model-rust`)
- Collection: **`notes`** (standalone; not `turns` / chat ops)
- CLI: `agent-skills/model-rust` binary — `note add` · `note list` · `note find` · `note expire` · `note purge`
- **Never** write `notes/<project>/*.md` or under `USERPROFILE`

## Project slug

`PROJECT`: lowercase `[a-z0-9-]+`.

1. User names it (`/note <project>`, `project:<name>`, “for project X”, or list/find arg)
2. Else infer from git root / top app folder being edited
3. Else if about this pack / install / skills → `agent-skills`
4. Else ask once; do not write until known

## Expiry

- `expires` = YYYY-MM-DD last valid day; omit / empty = no expiry
- **Expired** = today > `expires`
- **list / find:** show `expired: true` / `[expired]`; not active guidance
- **write:** do not update expired in place — `note add` a new document
- **expire:** `note expire --id <ObjectId> [--date YYYY-MM-DD]` (default: today)
- **purge:** `note purge [--project …] --dry-run` then `--yes` to delete expired docs

## Retention (turns)

- Ops history can grow; optional: `turns-purge --older-than-days 90 --dry-run` then `--yes`
- Prefer project filter when purging

## CLI

```powershell
cd agent-skills\model-rust
cargo run -- note add --json examples\note-stub.json
cargo run -- note list --project agent-skills --limit 3
cargo run -- note find -q junction --project agent-skills --limit 10
cargo run -- note expire --id <ObjectId>
cargo run -- note purge --project agent-skills --dry-run
cargo run -- note purge --project agent-skills --yes
```

Flags for `note add`: `--project` `--kind` `--title` `--body` `--tag` `--expires`.

## Validate

No markdown file validator. Smoke: `cargo build` in `model-rust/` + `note list` (needs `MONGODB_URI`).
