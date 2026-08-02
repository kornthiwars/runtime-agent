# /feature — ใช้ยังไง

ออเคสตราฟีเจอร์ตามนโยบาย: **plan → make/fix → review → ship**  
เทิร์นแรก**ไม่ลงมือโค้ด** — รอ `ยืนยัน` ก่อนสไลซ์แรก

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/feature <name>` | ตั้งชื่อฟีเจอร์ + ร่าง SLICES + irreversibles |
| ตอบ `ยืนยัน` | เริ่มสไลซ์แรก (`/make` หรือ `/fix`) |

## ตัวอย่าง

```
/feature checkout-v2
```

```
/feature team-invites รวม email + role admin
```

หลังได้ SLICES / IRREVERSIBLES / ENTERPRISE (ถ้ามี):

```
ยืนยัน
```

## ลำดับที่แนะนำ

1. `/feature <name>` → อ่านสไลซ์ + ความเสี่ยง  
2. `ยืนยัน` → ทำสไลซ์ทีละชิ้น  
3. MED/HIGH: อย่าข้าม `/review` ก่อน `/ship`  
4. `/ship` เมื่อพร้อมปล่อย

แตะ migration/DB/auth/ฯลฯ → ตาม `enterprise-safety` (BLAST_RADIUS + ROLLBACK)

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| งานชิ้นเดียวชัดๆ | `/make` |
| บั๊กอย่างเดียว | `/fix` |
| อยากได้แค่แผน | `/plan` |
| commit อย่างเดียว | `/ship` |
