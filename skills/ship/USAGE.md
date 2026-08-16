# /ship — ใช้ยังไง

ตรวจ git → เสนอ commit/push → ต้องมี `ยืนยัน` → ทำครั้งเดียว → ตรวจ remote  
แค่ `/ship` **ยังไม่ใช่** consent

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/ship` | สรุป diff + commit msg — รอ `ยืนยัน` |
| `/ship ยืนยัน` | inspect ในเทิร์นนี้แล้ว **commit + push** (default ของ pack) |
| `/ship commit only ยืนยัน` | commit จบ ไม่ push |
| ตอบ `ยืนยัน` หลัง `/ship` | เหมือน `/ship ยืนยัน` (commit+push) |
| `ship without review` · `ข้าม review` | ข้ามเกต MED/HIGH `/review` โดยชัดเจน (**ไม่ใช่** คำว่า `ยืนยัน`) |
| `ยืนยัน force push` | อนุญาต force `main`/`master` โดยเฉพาะ |

**สำคัญ:** `/ship ยืนยัน` ≠ ข้าม `/review`  
งานแอป MED/HIGH หรือแพ็ก always-on / REPORT / เปลี่ยนชื่อ slash ที่ยังไม่ได้ `/review` (หรือ verdict `block` / `request-changes`) → `AWAITING_REVIEW` ก่อน อย่า commit  
คำว่า `approve` / `appove` **ยังไม่ใช่** consent

## ตัวอย่าง

```
/ship
```

แล้วค่อย:

```
ยืนยัน
```

หรือข้อความเดียว:

```
/ship ยืนยัน
```

```
/ship commit และ push origin main
ยืนยัน
```

## ลำดับที่แนะนำ

1. งานโค้ดจบ → (MED/HIGH) `/review`  
2. `/ship` หรือ `/ship ยืนยัน`  
3. POST-VERIFY remote HEAD

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ยังมีบั๊กไม่จบ | `/fix` |
| ยังไม่รีวิวงานเสี่ยง | `/review` ก่อน |

Ship จากโฟลเดอร์ git ของ pack (`agent-skills/`) — โดยปกติไม่ stage `.cursor/plans/`, หรือโฟลเดอร์ demo นอก pack  
ว่างไม่มี diff → `STATUS: READY` · `STAGE: none` — ไม่สร้าง empty commit · secrets flagged → หยุดจนกว่า `ยืนยัน`/`confirm`/`yes` ระบุ path (ไม่ใช่ `ok`/`continue`/`approve`)
