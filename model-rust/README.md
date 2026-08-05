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
```

`add` prints ids only: `case`, `prompt`, `problem`, `solution`.
Never prints URI/password.

## Auto (Cursor)

Workspace hooks + pack rule (`rules/model-rust-auto.mdc`) save **every submitted Agent turn** (not every keystroke):

- Stage on `beforeSubmitPrompt` → attach reply on `afterAgentResponse` → `add` on `stop`
- Agent also **search**es at start and **add**s at end (visible `MODEL-RUST` / `MODEL-RUST-SAVE`)
- Proof log: `.cursor/hooks/state/model-rust-auto.log`

Disable: `MODEL_RUST_AUTO=0` or create `.cursor/hooks/state/model-rust-auto.off`.

If Hooks tab shows nothing after a chat: restart Cursor once so `.cursor/hooks.json` reloads.

## Schema

See [`schema.json`](schema.json) for collection field layout.
