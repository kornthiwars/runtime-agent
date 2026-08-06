# /note — ใช้ยังไง

เซฟใน Mongo collection `notes` (ผ่าน `model-rust`) เป็นค่าเริ่มต้น — **ไม่มีไฟล์** `notes/*.md`

## คำสั่ง

| พิมพ์ | โหมด | ผล |
|-------|------|-----|
| `/note` · `/note <project> …` | write | จดจากแชท — **`note add`** |
| `/note list` · `/note list <project>` | list | รายการล่าสุด |
| `/note find <query>` | find | ค้นใน DB |

## ตัวอย่าง

```
/note
```

จด decision สำคัญจากเทิร์นนี้ (ถาม project ถ้ายังไม่รู้)

```
/note agent-skills
```

```
/note my-app ตัดสินใจใช้ Postgres ไม่ใช่ SQLite
```

```
/note list
```

```
/note list agent-skills
```

```
/note find junction
```

อย่าเซฟ: พิมพ์ `อย่าเซฟ` / chat-only → REPORT โดยไม่เรียก `note add`
