# Skills — คู่มือสั้น

แต่ละคำสั่งมี `USAGE.md` ในโฟลเดอร์ตัวเอง

| คำสั่ง | โฟลเดอร์ | เมื่อไหร่ |
|--------|---------|----------|
| `/fix` | [fix/USAGE.md](fix/USAGE.md) | บั๊ก ไม่รู้สาเหตุ |
| `/make` | [make/USAGE.md](make/USAGE.md) | สร้างของ เป้าหมายชัด |
| `/plan` | [plan/USAGE.md](plan/USAGE.md) | `.cursor/plans/*.plan.md` + run todo |
| `/feature` | [feature/USAGE.md](feature/USAGE.md) | ฟีเจอร์หลายสไลซ์ · `.cursor/features/` |
| `/review` | [review/USAGE.md](review/USAGE.md) | คำตัดสิน — ไม่แก้โค้ด |
| `/ship` | [ship/USAGE.md](ship/USAGE.md) | commit / push หลังยืนยัน |
| `/note` | [note/USAGE.md](note/USAGE.md) | ความจำข้ามเซสชัน |
| `/upgrades` | [upgrades/USAGE.md](upgrades/USAGE.md) | ทำให้ skill ใน pack แม่น/คมขึ้น |

**เลือกคำสั่ง (หนึ่งตัวต่อเทิร์น):** ดู `../rules/skill-router.mdc` — `/make` = งานเดียว · `/plan` = UI/todo graph · `/feature` = ≥2 slices หรือต้อง review ก่อน ship · `/note` = Mongo `notes` (≠ auto `turns`)

กฎแพ็ก: ดู [../rules/README.md](../rules/README.md) — `agent-ops` · `enterprise-safety` · `skill-router` · `model-rust-auto` · `explicit-intent`  
Validate: `../scripts/validate-skill-names.ps1` · Evals: `../scripts/run-evals.ps1` · [evals/README.md](../evals/README.md)  
Version: [../VERSION](../VERSION) · Shared REPORT → [../templates/response/report.md](../templates/response/report.md)
