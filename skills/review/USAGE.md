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

- Verdict: `approve` \| `approve-with-nits` \| `request-changes` \| `block`  
- Findings: Critical / Suggestion / Nice-to-have  
- แยก CLAIM vs EVIDENCE  
- เช็ค security สั้นๆ (secrets, XSS, AuthZ, redirect, PII, …)  
- ถ้าแตะ migration/auth/payments/infra → ไล่ตาม `enterprise-safety` ด้วย  

แนะนำอย่างเดียว — ไม่แพตช์ใน skill นี้ ถ้าจะแก้ใช้ `/fix` หรือ `/make`

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ต้องการให้แก้เลย | `/fix` / `/make` |
| commit / push | `/ship` |
| วางแผนงานใหม่ | `/plan` |
