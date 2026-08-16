# /plan — ใช้ยังไง

เก็บแผนฟอร์แมต **Cursor Plan** ที่ workspace:

`.cursor/plans/<slug>_<8hex>.plan.md`

รันทีละ todo ด้วย `/plan run`  
ไฟล์รูปเดียวกับ Plan mode ของ Cursor แต่เข้าผ่าน skill `/plan` (คนละทางกับปุ่ม Plan ใน IDE)

แผนอยู่ที่ workspace เท่านั้น — **ไม่** รวมใน git pack `agent-skills` ปกติ

## vs `/feature`

| สถานการณ์ | ใช้ |
|-----------|-----|
| สร้างหน้า/หลาย todo เป็น `.plan.md` | `/plan` |
| ฟีเจอร์ผลิตภัณฑ์ ≥2 สไลซ์ / pipeline migrate+review+ship | `/feature` |

## คำสั่ง

| พิมพ์ | โหมด | ผล |
|--------|------|-----|
| `/plan` · `/plan …` · `ทำแผน` | draft | สร้าง/แก้ `.plan.md` (ยังไม่ลงมือโค้ด) |
| chat-only · `อย่าเซฟ` | chat | ร่างในแชทอย่างเดียว — **ไม่** เขียน `.plan.md` |
| `/plan list` | list | รายการใน `.cursor/plans/` |
| `/plan run` | run | todo `pending` ถัดไปของแผนล่าสุด |
| `/plan run <ไฟล์\|ชื่อ>` | run | เลือกแผน |
| `/plan run … ยืนยัน` | run | ทำ **1 todo** ในเทิร์นเดียว |

Consent รัน todo = `ยืนยัน`/`confirm`/`yes` เท่านั้น — `continue`/`ทำต่อ`/`ทำเลย`/`ok` **ยังไม่ใช่** consent

## ตัวอย่าง

**ร่างแผน**
```
/plan สร้างหน้า LINE ด้วย html
```
→ เช่น `.cursor/plans/line_home_html_e7b92c1a.plan.md`

**รัน**
```
/plan run line_home_html_e7b92c1a.plan.md ยืนยัน
```

**ลิสต์**
```
/plan list
```

**Facebook / UI อื่น**
```
/plan สร้างหน้า Facebook dark เป็น HTML ตามรูป
/plan run facebook_home_html_c8f41a2e.plan.md ยืนยัน
```

## รูปไฟล์

```yaml
---
name: …
overview: …
todos:
  - id: line-shell
    content: "`/make line-shell` — …"
    status: pending
isProject: false
---
```

ทุก todo ควรมี `/make` หรือ `/fix` ใน `content` — ถ้าไม่มี ตอน run จะ infer หรือถาม  
งานจัดโครงสร้างให้ AI หาโค้ดถูกไฟล์ → แยก todo ตาม **หน้าที่** (ชื่อโมดูลบอกงาน) ไม่ซอยบรรทัดเท่าๆ กัน

**สำคัญ:** `ยืนยัน` ของ `/plan run` ≠ ยืนยัน enterprise  
ถ้า todo เจอพื้นผิว enterprise ต้อง `AWAITING_CONFIRM` + BLAST_RADIUS/ROLLBACK อีกรอบก่อนเขียน (migrate run = ยืนยันอีกครั้ง + ระบุ env)

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| ฟีเจอร์หลายสไลซ์ / pipeline migrate+review+ship | `/feature` |
| งานชิ้นเดียวไม่เก็บแผน | `/make` |
| บั๊กไม่รู้สาเหตุ | `/fix` |
