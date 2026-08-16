# /review — ใช้ยังไง

ให้คำตัดสิน (verdict) อย่างเดียว — **ห้ามแก้โค้ด** · `CHANGES: none (no-edit)`

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/review` | รีวิว diff / บริบทในแชท / ไฟล์ที่เปิด |
| `/review …` | ระบุ PR, branch, หรือขอบเขตไฟล์ |

## ตัวอย่าง

```
/review
```

```
/review diff ล่าสุดก่อน ship
```

```
/review PR #42 โฟกัส authz
```

## ได้จากรีวิว

- Verdict จาก rubric ใน `SKILL.md`: Critical unsafe-to-ship → `block`; Critical must-fix → `request-changes`; Suggestion ถูกต้อง/security/สัญญา → `request-changes`; สไตล์อย่างเดียว → `approve-with-nits`; ไม่ชัวร์ → prefer `request-changes`  
- Findings: Critical / Suggestion / Nice-to-have — **ห้าม Critical ไม่มี evidence**  
- CLAIM vs EVIDENCE แยกรายข้อ  
- Security + `enterprise-safety` เมื่อแตะ migration/auth/payments/infra  

แนะนำอย่างเดียว — ไม่แพตช์; แก้ด้วย `/fix` หรือ `/make`

หลัง verdict ผ่าน (หรือไม่ block) → `/ship` (MED/HIGH ห้ามข้าม; ถ้าข้อความเดียวมีทั้ง `/review` และ `/ship` ให้รีวิวก่อนตาม `skill-router`)

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ต้องการให้แก้เลย | `/fix` / `/make` |
| วางแผน / รัน todo จาก `.plan.md` | `/plan` |
| ออเคสตราฟีเจอร์ + confirm สไลซ์ | `/feature` |
| commit / push | `/ship` |
