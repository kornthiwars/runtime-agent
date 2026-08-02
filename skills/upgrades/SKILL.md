---
name: upgrades
description: >-
  Improve this pack’s skills so they run sharper and more reliably (clarity,
  accuracy, gates, examples). Use when the user invokes /upgrades, or asks to
  tighten, refine, or level-up skills/rules/templates — not for app features.
disable-model-invocation: true
---

# /upgrades

Make **this pack** better: skills that are clearer, stricter where needed, and
less ambiguous for the agent. Scope: `agent-skills/` (skills, rules, templates,
scripts, USAGE). Not app product work — use `/make` / `/feature` for those.

**Primary goal:** quality of agent behavior (แม่นขึ้น / คมขึ้น).  
**Secondary:** hygiene (skill ↔ template ↔ README ↔ install stay aligned).

## Modes

| Invocation | Mode |
|------------|------|
| `/upgrades` · `/upgrades audit` | **audit** — score gaps; no edits |
| `/upgrades propose …` | **propose** — upgrade plan; no edits |
| `/upgrades apply …` | **apply** — edit after gates |

## Quality lenses (use on audit/propose/apply)

1. **Trigger** — description/USAGE เมื่อไหร่ควรยิง skill นี้ชัดหรือยังสับสนกับ skill อื่น  
2. **Steps** — ลำดับทำจริงได้ไหม มีช่องให้เดาสุ่มหรือข้าม gate  
3. **Gates** — confirm / no-edit / enterprise / budget ครบตอนที่ควรหยุด  
4. **Contracts** — REPORT / template / path ตรงกับที่ skill สัญญา  
5. **Examples** — USAGE มีตัวอย่างที่ทำให้ใช้ถูกโหมด  
6. **Drift** — README, `SkillNames`, junctions หลังเพิ่ม/rename

Prefer **small precise upgrades** over rewrites. Do not invent new slash commands unless asked.

## Steps

1. Scope: skill(s) / rules / templates (default: whole pack or named target).
2. Read `SKILL.md`, linked templates, `USAGE.md`, and related rules.
3. **audit / propose:** list IMPROVEMENTS (quality) ranked High/Med/Low; note DRIFT/BREAKING. `CHANGES: none (no-edit)`. Status `PLAN_READY` or `VERDICT`.
4. **apply:** RISK + budget. Renaming slash commands or changing shared REPORT = confirm (`ยืนยัน`). Keep `disable-model-invocation: true` unless user asks otherwise.
5. After apply: sync install `SkillNames` + README if needed; suggest re-run `scripts/install-windows.ps1` when junctions must refresh.
6. Hand off publish to `/ship` — do not ship inside this skill.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/upgrades.md](../../templates/response/upgrades.md).
