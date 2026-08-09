# Rules

กฎ Cursor ที่เปิดตลอดในแพ็กนี้ (`alwaysApply: true`) — สคริปต์ install จะลิงก์ไปที่ `.cursor/rules/` ของ workspace แม่

| ไฟล์ | Responsibility | สรุป |
|------|----------------|------|
| [skill-router.mdc](skill-router.mdc) | Skill ownership | **WHO** owns the task — เลือก skill เจ้าของเดียวต่อเทิร์น; `/slash` ที่ระบุชัดชนะ |
| [agent-ops.mdc](agent-ops.mdc) | Agent behavior | **HOW** the agent operates — เกตยืนยัน, no-edit, Full/Lite, risk/verify, งบอ่าน–เขียน, locate-before-read, REPORT, recall |
| [enterprise-safety.mdc](enterprise-safety.mdc) | Safety boundary | **WHEN** to stop — DB/migration, auth, payments, PII, infra/prod + BLAST_RADIUS / ROLLBACK |
| [explicit-intent.mdc](explicit-intent.mdc) | Code quality | **HOW** code should look — ทำให้ implementation และ business intent อ่านแล้วเข้าใจได้ทันที |
| [model-rust-auto.mdc](model-rust-auto.mdc) | Memory mechanism | **HOW** memory persists — `turns` (chat/ops) vs `/note` (`notes`) ผ่าน `model-rust` |

## Rule Boundaries

- `skill-router` decides **WHO owns the task**.
- `agent-ops` decides **HOW the agent operates while performing the task**.
- `enterprise-safety` decides **WHEN the agent must stop and require confirmation**.
- `explicit-intent` decides **HOW code should be written or modified for clarity**.
- `model-rust-auto` defines **HOW operational memory is persisted and retrieved**.
- Module/file splits for cheap locate → `agent-ops` (read budget).
- Identifier names, predicates, and control-flow clarity → `explicit-intent`.

### Overlap resolution

- Skill ownership conflict → `skill-router` wins.
- Safety conflict → `enterprise-safety` wins.
- Agent operation conflict → `agent-ops` wins.
- Code clarity conflict → `explicit-intent` wins.
- Memory persistence conflict → `model-rust-auto` wins.

### Architecture

```
                    ┌─────────────────┐
                    │  skill-router   │
                    │  WHO owns task  │
                    └────────┬────────┘
                             ↓
                    ┌─────────────────┐
                    │   agent-ops     │
                    │ HOW agent works │
                    └────────┬────────┘
                             ↓
                 ┌───────────┴───────────┐
                 ↓                       ↓
       ┌──────────────────┐    ┌──────────────────┐
       │ enterprise-safety│    │ explicit-intent  │
       │  WHEN to stop    │    │ HOW code looks   │
       └──────────────────┘    └──────────────────┘

                    ┌─────────────────┐
                    │ model-rust-auto │
                    │  memory layer   │
                    └─────────────────┘
```

อย่าเพิ่ม rule แยกสำหรับ “โค้ดอ้อม/กำกวม” — ใช้ `explicit-intent` เป็นตำแหน่งเดียว
