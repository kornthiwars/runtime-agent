# /make — ใช้ยังไง

สร้าง/เติมความสามารถที่**เป้าหมายชัด** ค่าเริ่มต้น **Lite** (แพตช์เล็ก + verify)

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/make <capability-id>` | ทำตาม id/ขอบเขตนั้น |
| `/make <capability-id> --full` | บังคับ Full (สืบลึกกว่า Lite) |

Auto-Full เมื่อแตะ schema/migration, auth/security, shared/SSoT, secrets/env, เส้นทาง prod → ตาม `enterprise-safety` ถ้าเกี่ยว DB/auth/ฯลฯ  

Migration ความสามารถเดียว (one patch shape) → `/make --full` · หลายสไลซ์ / ต้อง `/review` ก่อน `/ship` → `/feature` (ดู `skill-router`)

## ตัวอย่าง

```
/make add-logout-button
```

```
/make export-csv --full
```

```
/make dark-mode เฉพาะ Settings page ไม่แตะ billing
```

## ลำดับที่แนะนำ

0. Memory recall (`agent-ops`): `model-rust search` → cite `MODEL-RUST:` · `note list` → cite `NOTES:` (ไม่ใช่ไฟล์ `notes/*.md`)  
1. จาก `/plan run` todo หรือ `/plan` แล้วรัน — หรือเรียก `/make` ตรงๆ  
2. `/make <id>` →  
3. `/review` (ถ้า MED/HIGH) →  
4. `/ship`

งบประมาณเขียนเริ่มต้น: ≤5 ไฟล์ / ≤120 บรรทัด (เกินต้องขอ OK)  
อ่าน: locate-before-read — ค้นจากหน้าที่/ชื่อโมดูลก่อน แล้วเปิดเฉพาะไฟล์ที่เกี่ยว (ดู `agent-ops` read budget)  
โมดูลใหม่/แยกไฟล์: ชื่อต้องบอกหน้าที่ — ห้ามซอยเท่าๆ กันแค่ลดบรรทัด  
Verify ตาม [verify-matrix](../../templates/ops/verify-matrix.md)

## Golden (ตรง SKILL)

In: `/make add-health-endpoint` → Lite · patch เล็ก · VERIFY เขียว

## vs `/fix`

| สถานการณ์ | ใช้ |
|-----------|-----|
| เป้าหมายชัด รู้รูปการเปลี่ยน | `/make` |
| ไม่รู้สาเหตุ / รีเกรสชัน / flaky | `/fix` |
| ระหว่าง make แล้วสาเหตุมืด | หยุด Lite → ทำแบบ `/fix` |

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ไม่รู้สาเหตุ / บั๊กมึน | `/fix` |
| แค่แผน ไม่ลงมือ | `/plan` |
| ออเคสตราหลายสไลซ์ + confirm | `/feature` |
| อัปเกรด pack skills | `/upgrades` |
