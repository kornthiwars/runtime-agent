# /feature — ใช้ยังไง

ออเคสตราฟีเจอร์: **plan → make/fix → review → ship**  
`ยืนยัน` หนึ่งครั้ง = **หนึ่งสไลซ์** (agent รัน `/make` หรือ `/fix` ให้เอง)

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/feature <name>` | ร่าง SLICES → เซฟ `.cursor/features/*.feature.md` — **ยังไม่โค้ด** (reuse ไฟล์เดิมถ้ามี slug ตรง) |
| `/feature <name> ยืนยัน` | ร่างแผนในเทิร์นเดียวกันแล้วรันสไลซ์แรก **ชิ้นเดียว** (same-message) |
| `/feature list` | ลิสต์ `.feature.md` ใน workspace (no-edit) |
| `ยืนยัน` · `confirm` · `yes` | รันสไลซ์ถัดไป **ชิ้นเดียว** + อัปเดตสถานะในไฟล์ |
| `/review` แล้ว `/ship` | หลังสไลซ์ครบ (MED/HIGH ห้ามข้าม review) |

ถ้ามี `<slug>_*.feature.md` อยู่แล้ว → **reuse** ไฟล์ล่าสุดที่ match — อย่าสร้างไฟล์ซ้ำสำหรับฟีเจอร์เดิม

คำว่า `continue` / `ทำต่อ` / `ทำเลย` / `ok` = อยากทำต่อ แต่**ยังไม่ใช่** consent — ต้องมี `ยืนยัน`/`confirm`/`yes` ตาม `agent-ops`

สถานะสไลซ์อยู่ที่ไฟล์ ไม่พึ่งความจำแชท — เปิด workspace เดิมแล้วยืนยันต่อได้

## ตัวอย่าง

```
/feature checkout-v2
```

ได้ `PATH: .cursor/features/checkout_v2_<8hex>.feature.md` แล้ว:

```
ยืนยัน
```

เมื่อสไลซ์ 1 จบ จะบอก `NEXT: ยืนยัน slice-2` — ยืนยันอีกครั้งเพื่อสไลซ์ 2 อย่าคาดว่ายืนยันครั้งเดียวจบทั้งฟีเจอร์

## ลำดับที่แนะนำ

1. `/feature <name>` → แผน + ความเสี่ยง  
2. `ยืนยัน` → สไลซ์ 1  
3. `ยืนยัน` ซ้ำต่อสไลซ์  
4. MED/HIGH → `/review` → `/ship`

แตะ migration/DB/auth/ฯลฯ → ตาม `enterprise-safety`  

**สำคัญ:** `ยืนยัน` ของสไลซ์ ≠ ยืนยัน enterprise  
ถ้า `/make`|`/fix` ในสไลซ์เจอพื้นผิว enterprise ต้องหยุด `AWAITING_CONFIRM` + BLAST_RADIUS/ROLLBACK อีกรอบก่อนเขียนไฟล์ (migrate run = ยืนยันครั้งที่สาม + ระบุ env)

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| งานชิ้นเดียวชัดๆ (แม้ MED/HIGH) | `/make` แล้ว `/review` |
| UI demo / HTML ตามรูป (หลาย todo) | `/plan` |
| บั๊กไม่รู้สาเหตุ | `/fix` |
| อยากได้แค่แผน / UI todos ใน `.plan.md` | `/plan` |
| commit อย่างเดียว | `/ship` |
