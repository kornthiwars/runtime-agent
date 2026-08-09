# Rules

กฎ Cursor ที่เปิดตลอดในแพ็กนี้ (`alwaysApply: true`) — สคริปต์ install จะลิงก์ไปที่ `.cursor/rules/` ของ workspace แม่

| ไฟล์ | ทำอะไร |
|------|--------|
| [agent-ops.mdc](agent-ops.mdc) | การทำงานประจำวันของ agent: เกตยืนยัน, โหมดห้ามแก้, Full vs Lite, risk/verify, งบเขียน + งบอ่าน (locate-before-read), ความลับ/PII, REPORT, ดึงความจำ |
| [enterprise-safety.mdc](enterprise-safety.mdc) | หยุดแข็งสำหรับ DB/migration, auth, payments, PII, infra/prod — ต้องยืนยันพร้อม BLAST_RADIUS + ROLLBACK ก่อนลงมือ |
| [skill-router.mdc](skill-router.mdc) | เลือก skill **เจ้าของเดียว** ต่อเทิร์นเมื่อข้อความทับกันได้; `/slash` ที่ระบุชัดชนะ |
| [model-rust-auto.mdc](model-rust-auto.mdc) | ความจำแชท/ops อัตโนมัติผ่าน `model-rust` (คอลเลกชัน `turns`, source=`chat`) — ตัดสินใจถาวรใช้ `/note` (`notes`) |
| [explicit-intent.mdc](explicit-intent.mdc) | คุณภาพโค้ด: เขียน/แก้ให้เจตนาชัด (Explicit Intent & AI Readability) — คู่กับงบอ่านของ agent-ops |

skill ทับกัน → `skill-router` · วิธีเขียน vs วิธีหาจุดแก้ → `explicit-intent` vs งบอ่านใน `agent-ops`
