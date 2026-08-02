# /plan — ใช้ยังไง

ร่าง Task Graph สั้นๆ — **ห้ามแก้** source / config / CI / deploy ในเทิร์นนี้

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/plan` | วางแผนจากบริบทในแชท |
| `/plan …` | ระบุเป้าหมายที่จะแตกงาน |

แม้จะพิมพ์ว่า “ทำเลย” ในเทิร์นเดียวกับ `/plan` — skill นี้จบที่แผน แล้วชี้ไป `/make` หรือ `/feature`

## ตัวอย่าง

```
/plan
```

```
/plan เพิ่มระบบ refund ใน checkout
```

```
/plan ย้าย auth ไป session cookie — NON-GOALS: ยังไม่แตะ mobile
```

## ได้จากแผน

- อ่าน notes ของโปรเจกต์ก่อน (≤3 ไฟล์ ที่ยังไม่หมดอายุ)  
- TASK GRAPH เรียงลำดับ  
- OWNERS / NON-GOALS / RISK  
- EXCEPTIONS ถ้าจงใจเบี่ยงมาตรฐาน (มี expiry)  
- Status `PLAN_READY` · `CHANGES: none (no-edit)`

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| พร้อมลงมือชิ้นเล็ก | `/make` |
| บั๊กไม่รู้สาเหตุ | `/fix` |
| ต้องการ pipeline + confirm ก่อนเริ่ม | `/feature` |
| อยากได้คำตัดสิน PR | `/review` |
