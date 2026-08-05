# /note — reference

## Storage

- `NOTES_ROOT` = `<workspace-root>/notes` (create if missing)
- Never write under `USERPROFILE` or outside the workspace unless the user gives an explicit path
- File path: `notes/<PROJECT>/YYYY-MM-DD-<slug>.md`
- Skills hub: many projects share one `notes/` — keep folders separate
- Single-app repo: `PROJECT` defaults to that repo folder name

## Project slug

`PROJECT`: lowercase `[a-z0-9-]+`.

1. User names it (`/note <project>`, `project:<name>`, “for project X”, or list/find arg)
2. Else infer from git root / top app folder being edited
3. Else if about this pack / install / skills → `agent-skills`
4. Else ask once; do not write until known

## Expiry

- Frontmatter `expires: YYYY-MM-DD` = last valid day; empty = no expiry
- **Expired** = today > `expires`
- **list / find:** show `[expired]`; not active guidance
- **write:** do not revive expired in place — add a new note

## Validate

```powershell
.\scripts\validate-note.ps1 -Path "..\notes\agent-skills\2026-08-05-example.md"
```

```bash
./scripts/validate-note.sh ../notes/agent-skills/2026-08-05-example.md
```
