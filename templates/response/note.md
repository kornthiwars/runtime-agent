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
ID: <Mongo ObjectId> | —
```

## list

```
MODE: list
PROJECT: <slug> | * (all)
ITEMS:
- <id> · <kind> · <title> · [expired]?
NEXT: —
```

## find

```
MODE: find
QUERY: ...
PROJECT: <slug> | *
HITS:
- <id> · <title> · <one-line context> · [expired]?
NEXT: —
```
