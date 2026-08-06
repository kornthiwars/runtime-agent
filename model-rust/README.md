# model-rust

Small Rust CLI for AI ops memory (prompt / problem / solution) on MongoDB Atlas.

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
cargo run -- search --q "ship confirm" --limit 5
cargo run -- get --id <caseObjectId>
cargo run -- add --json examples\stub.json
cargo run -- note add --json examples\note-stub.json
cargo run -- note list --project agent-skills --limit 5
cargo run -- note find -q junction --limit 10
```

`add` prints ids only: `case`, `prompt`, `problem`, `solution`.  
`note add` prints `id`, `project`, `kind`, `title`.  
Never prints URI/password.

## Auto (Cursor)

Pack sources live in `agent-skills/cursor-hooks/` + `rules/model-rust-auto.mdc`.  
`.\scripts\install-windows.ps1` (or unix) copies them into workspace `.cursor/`.

Windows uses **Node** (`model-rust-auto.mjs`) because PowerShell `-File` often gets empty stdin from Cursor.

- Stage on `beforeSubmitPrompt` → attach reply on `afterAgentResponse` → `add` on `stop` (`project: agent-skills`)
- Agent **search**es cases at start (`MODEL-RUST:`); `/note` uses `note list|find|add` (collection `notes`)
- Agent `add` (cases) only if hooks `FAIL`/`SKIP` or disabled
- Proof log: `.cursor/hooks/state/model-rust-auto.log`

Disable: `MODEL_RUST_AUTO=0` or create `.cursor/hooks/state/model-rust-auto.off`.

If Hooks tab shows nothing / still skips: **restart Cursor once**, confirm Node is on PATH (`node -v`).

## Schema

See [`schema.json`](schema.json) for collection field layout.
