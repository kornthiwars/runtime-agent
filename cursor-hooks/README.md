# cursor-hooks

Pack source for Cursor Agent hooks. Install copies into **parent** and **pack** `.cursor/`.

| File | Role |
|------|------|
| `hooks.windows.json` / `hooks.unix.json` | Event wiring → `notes-daily.*` |
| `notes-daily.ps1` / `notes-daily.sh` | Append prompts; fill Result |
| `state.gitignore` | Ignore hook state runtime files |

## Event chain

1. `beforeSubmitPrompt` — append entry under `## Prompts` with pending marker  
2. `afterAgentResponse` — summarize reply → **Result** (preferred so missing `stop` is OK)  
3. `stop` — if still pending, fill/upgrade Result; clear last-response cache  

Opt-out: `NOTES_DAILY_AUTO=0` or `.cursor/hooks/state/notes-daily.off`  
Debug: `.cursor/hooks/state/notes-daily.debug.log`
