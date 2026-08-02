# /note response

Include shared [report.md](report.md).

Pick the block that matches the mode. Empty fields → `—`.

## write

Persist unless chat-only.

```
MODE: write
KIND: decision | constraint | exception | gotcha
PROJECT: <slug>
TITLE: ...
BODY: <short durable text — no log/stack>
EXPIRES: YYYY-MM-DD | —
PATH: notes/<PROJECT>/YYYY-MM-DD-<slug>.md | <user path> | —
```

## list

```
MODE: list
PROJECT: <slug> | * (all)
ITEMS:
- <path-or-folder> · <title-or-count> · [expired]?
NEXT: —
```

## find

```
MODE: find
QUERY: ...
PROJECT: <slug> | *
HITS:
- <path> · <title> · <one-line context> · [expired]?
NEXT: —
```
