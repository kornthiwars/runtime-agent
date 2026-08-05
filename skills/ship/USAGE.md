# /ship — ใช้ยังไง

ตรวจ git → เสนอ commit/push → ต้องมี `ยืนยัน` → ทำครั้งเดียว → ตรวจ remote  
แค่ `/ship` **ยังไม่ใช่** consent

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/ship` | สรุป diff + commit msg — รอ `ยืนยัน` |
| `/ship ยืนยัน` | inspect ในเทิร์นนี้แล้ว commit/push ต่อได้เลย (ถ้า secrets ผ่าน) |
| ตอบ `ยืนยัน` หลัง `/ship` | เหมือนกัน |
| `ยืนยัน force push` | อนุญาต force `main`/`master` โดยเฉพาะ |

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
| แคจดจำการตัดสินใจ | `/note` |

Ship จากโฟลเดอร์ git ของ pack (`agent-skills/`) — โดยปกติไม่ stage `notes/`, `.cursor/plans/`, หรือโฟลเดอร์ demo นอก pack  
ว่างไม่มี diff → ไม่สร้าง empty commit · secrets flagged → หยุดจนกว่าจะ override
