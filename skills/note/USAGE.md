# /note — ใช้ยังไง

เก็บ **ปัญหารายโปรเจกต์ + วิธีแก้** เป็นไฟล์ markdown ใต้ workspace  

แชทรายวัน (ทุก prompt) = hooks → `.cursor/notes/daily/YYYY-MM-DD.md` (ไม่ใช่ `/note`)

## ที่เก็บ

```text
.cursor/notes/projects/<project>/problems/YYYY-MM-DD-<slug>.md
```

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/note add` | สร้าง note ปัญหาใหม่ |
| `/note list` | ลิสต์ล่าสุดในโปรเจกต์ (default ทุกสถานะ; ขอ **open only** แล้วค่อยข้าม resolved) — **no-edit** |
| `/note find <คำค้น>` | ค้นใน problems ของโปรเจกต์ — **no-edit** |
| `/note resolve …` | ปิด note (`status: resolved`) |
| `/note update …` | แก้ส่วนที่ระบุใน note เดิม |

รับ `project=<slug>` / `title=…` หรือข้อความอิสระ  
ระบุ `project` เป็น slug เช่น `checkout-app`, `billing-app`

## ตัวอย่าง

```
/note add project=checkout-app title=checkout total flaky
```

```
/note list project=checkout-app
```

```
/note find project=checkout-app tax rounding
```

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| แผนหลาย todo / UI clone | `/plan` |
| แค่ commit | `/ship` |
| บันทึกทุก prompt อัตโนมัติ | hooks daily (ดู README) — ไม่ใช้ `/note` |
| ความลับ / PII | ห้ามเก็บ |
