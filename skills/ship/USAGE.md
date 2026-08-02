# /ship — ใช้ยังไง

ตรวจ git → เสนอ commit/push → **รอ `ยืนยัน`** → ทำครั้งเดียว → ตรวจ remote  
แค่พิมพ์ `/ship` **ยังไม่ใช่** consent

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/ship` | สรุป diff + ข้อความ commit + irreversibles — ยังไม่ commit |
| `/ship` + ขอ push | แผนรวม push (หลังยืนยัน) |
| ตอบ `ยืนยัน` | commit (และ push ถ้าเสนอไว้) |

Force-push `main`/`master` ทำเฉพาะเมื่อขอชัดเจนเป็นคำๆ

## ตัวอย่าง

```
/ship
```

```
/ship commit และ push origin main
```

หลังอ่าน DIFF SUMMARY / SECRETS SCAN / COMMIT MSG:

```
ยืนยัน
```

ถ้าต้อง force (เช่น เขียนประวัติใหม่):

```
ยืนยัน force push
```

## ลำดับที่แนะนำ

1. งานโค้ดจบ (`/make` / `/fix` / …)  
2. (MED/HIGH) `/review`  
3. `/ship` → ตรวจสรุป  
4. `ยืนยัน` → POST-VERIFY remote HEAD

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ยังมีบั๊กไม่จบ | `/fix` |
| ยังไม่รีวิวงานเสี่ยง | `/review` ก่อน |
| แคจดจำการตัดสินใจ | `/note` |
