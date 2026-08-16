# Skills — คู่มือสั้น

แต่ละคำสั่งมี `USAGE.md` ในโฟลเดอร์ตัวเอง

| คำสั่ง | โฟลเดอร์ | เมื่อไหร่ |
|--------|---------|----------|
| `/fix` | [fix/USAGE.md](fix/USAGE.md) | บั๊ก ไม่รู้สาเหตุ |
| `/make` | [make/USAGE.md](make/USAGE.md) | สร้างของ เป้าหมายชัด |
| `/plan` | [plan/USAGE.md](plan/USAGE.md) | `.cursor/plans/*.plan.md` + run todo |
| `/feature` | [feature/USAGE.md](feature/USAGE.md) | หลายสไลซ์ / gated pipeline · `.cursor/features/` |
| `/review` | [review/USAGE.md](review/USAGE.md) | คำตัดสิน — ไม่แก้โค้ด |
| `/ship` | [ship/USAGE.md](ship/USAGE.md) | commit / push หลังยืนยัน |
| `/note` | [note/USAGE.md](note/USAGE.md) | ปัญหารายโปรเจกต์ใต้ `.cursor/notes` |
| `/upgrades` | [upgrades/USAGE.md](upgrades/USAGE.md) | ทำให้ skill ใน pack แม่น/คมขึ้น |

**เลือกคำสั่ง (หนึ่งตัวต่อเทิร์น):** ดู `../rules/skill-router.mdc` — `/make` = งานเดียว · `/plan` = UI demo / HTML clone · `/feature` = ≥2 slices หรือ gated pipeline · `/note` = ปัญหา+แก้ (≠ daily auto)

กฎแพ็ก: ดู [../rules/README.md](../rules/README.md) — `agent-ops` · `enterprise-safety` · `skill-router` · `explicit-intent`  
Validate: `../scripts/validate-skill-names.ps1` · Evals: `../scripts/run-evals.ps1` · Behavior: `../scripts/run-behavior-evals.ps1` · Smoke: `../scripts/smoke-notes-daily.ps1` · [evals/README.md](../evals/README.md)  
Version: [../VERSION](../VERSION) · Shared REPORT → [../templates/response/report.md](../templates/response/report.md)
