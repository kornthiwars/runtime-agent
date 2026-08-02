# /make — ใช้ยังไง

สร้าง/เติมความสามารถที่**เป้าหมายชัด** ค่าเริ่มต้น **Lite** (แพตช์เล็ก + verify)

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/make <capability-id>` | ทำตาม id/ขอบเขตนั้น |
| `/make <capability-id> --full` | บังคับ Full (สืบลึกกว่า Lite) |

Auto-Full เมื่อแตะ schema/migration, auth/security, shared/SSoT, secrets/env, เส้นทาง prod → ตาม `enterprise-safety` ถ้าเกี่ยว DB/auth/ฯลฯ

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

0. อ่าน notes ของโปรเจกต์ (≤3 ไฟล์ ที่ยังไม่หมดอายุ)  
1. จาก `/plan run` todo หรือ `/plan` แล้วรัน — หรือเรียก `/make` ตรงๆ  
2. `/make <id>` →  
3. `/review` (ถ้า MED/HIGH) →  
4. `/ship`

งบประมาณเริ่มต้น: ≤5 ไฟล์ / ≤120 บรรทัด (เกินต้องขอ OK)

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
