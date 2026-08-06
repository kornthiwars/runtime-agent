# model-rust

Small Rust CLI for AI memory on MongoDB Atlas: **`turns`** (chat/ops) + **`notes`** (durable `/note`).

Lives in the **agent-skills** pack: `agent-skills/model-rust/`.  
Workspace may expose `Skills/model-rust` as a junction to this folder.

## Env

| File | Purpose |
|------|---------|
| `.env.example` | Template (commit OK) |
| `.env` | Secrets only here (gitignored) |

```env
MONGODB_URI=mongodb+srv://USER:PASS@HOST/?retryWrites=true&w=majority
MONGODB_DB=model-rust
```

## Commands

```powershell
cd agent-skills\model-rust
cargo run -- ping
cargo run -- add --json examples\turn-stub.json
cargo run -- search --q "ship confirm" --limit 5
cargo run -- get --id <turnObjectId>
cargo run -- turns-purge --older-than-days 90 --dry-run
cargo run -- turns-purge --older-than-days 90 --yes
cargo run -- note add --json examples\note-stub.json
cargo run -- note list --project agent-skills --limit 5
cargo run -- note find -q junction --limit 10
cargo run -- note expire --id <noteObjectId>
cargo run -- note purge --project agent-skills --dry-run
cargo run -- note purge --project agent-skills --yes
```

`add` prints: `id`, `project`, `source`, `skill`.  
`note add` prints: `id`, `project`, `kind`, `title`.  
Never prints URI/password.

**Breaking (pack 3.0):** `add` requires `summary` — legacy JSON fields `problem` / `solutionSummary` / `solution` are **rejected**.

## Search quality

- Keep `--q` short (2–5 keywords from the task). Prefer `--project` when known.
- Cap: search ≤5 turns; note find ≤10. Cite hits or `none` / `unavailable` — never invent.
- Notes < code/tests/user when they conflict.

## Retention

| Collection | Default policy | CLI |
|------------|----------------|-----|
| `turns` | purge older than 90 days when desired | `turns-purge --older-than-days 90 --yes` |
| `notes` | keep until expired; purge expired docs | `note expire` then `note purge --yes` |

Always `--dry-run` first. Destructive deletes need `--yes`.

## Auto (Cursor)

Pack sources live in `agent-skills/cursor-hooks/` + `rules/model-rust-auto.mdc`.  
`.\scripts\install-windows.ps1` (or unix) copies them into workspace `.cursor/`.

Windows uses **Node** (`model-rust-auto.mjs`) because PowerShell `-File` often gets empty stdin from Cursor.

- Stage on `beforeSubmitPrompt` → attach reply on `afterAgentResponse` → `add` on `stop` → collection **`turns`**
- Agent sets **`project`** via reply line `MODEL-RUST-PROJECT: <slug>` (hooks do not hardcode)
- Agent **search**es turns at start (`MODEL-RUST:`); `/note` uses `note list|find|add`
- Agent `add` only if hooks `FAIL`/`SKIP` or disabled
- Proof log: `.cursor/hooks/state/model-rust-auto.log`

Disable: `MODEL_RUST_AUTO=0` or create `.cursor/hooks/state/model-rust-auto.off`.

If Hooks tab shows nothing / still skips: **restart Cursor once**, confirm Node is on PATH (`node -v`).

## Schema

See [`schema.json`](schema.json) — flat `turns` + `notes` only.
