# /note — ใช้ยังไง

ความจำข้ามเซสชันแบบสั้น — **Memory ≠ Runtime** (ไม่จด log/stack/secrets)  
เซฟไฟล์เป็นค่าเริ่มต้น ที่ `notes/<project>/YYYY-MM-DD-<slug>.md`

## คำสั่ง

| พิมพ์ | โหมด | ผล |
|--------|------|-----|
| `/note` · `/note <project> …` | write | จดจากแชท/ข้อความ — **เขียนไฟล์** |
| `/note list` · `/note list <project>` | list | รายการโฟลเดอร์หรือไฟล์ |
| `/note find <query>` | find | ค้นใน notes |
| … + chat-only / อย่าเซฟ | write | แสดงในแชทอย่างเดียว |

## ตัวอย่าง

**จดจากบทสนทนา**
```
/note
```

**ระบุโปรเจกต์**
```
/note agent-skills
```
```
/note my-app ตัดสินใจใช้ Postgres ไม่ใช่ SQLite
```

**ลิสต์ / ค้น**
```
/note list
```
```
/note list agent-skills
```
```
/note find junction
```

## ชนิด (KIND)

`decision` · `constraint` · `exception` · `gotcha`

- หมดอายุ: frontmatter `expires: YYYY-MM-DD` — หมดแล้วติด `[expired]` ตอน list/find  
- อย่าเขียนทับไฟล์หมดอายุ — จดไฟล์ใหม่ถ้ายังต้องใช้

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| บันทึก error log ทั้งก้อน | (อย่าจด) แก้ด้วย `/fix` |
| เปลี่ยนโค้ด | `/make` / `/fix` |
| commit | `/ship` |
