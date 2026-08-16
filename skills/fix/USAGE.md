# /fix — ใช้ยังไง

แก้บั๊กที่**ยังไม่รู้สาเหตุ** แบบ Full เท่านั้น — ห้ามเดาแพตช์ก่อนมี repro + สมมติฐานที่หักล้างได้

## คำสั่ง

| พิมพ์ | ผล |
|--------|-----|
| `/fix` | เริ่มสืบจากบริบท/บั๊กในแชท |
| `/fix …` | ระบุอาการ / ไฟล์ / เทสที่พัง |

## ตัวอย่าง

```
/fix
```

```
/fix login คืน 401 ทั้งที่รหัสถูก
```

```
/fix เทส OrderService flaky บน CI
```

ผิว enterprise → หยุดรายงาน `BLAST_RADIUS` + `ROLLBACK` เป็น `AWAITING_CONFIRM` **ก่อนเขียน** (before writing) · รัน migration จริงต้อง `ยืนยัน` อีกรอบและระบุ env ชื่อ (local/staging/prod)

## ลำดับที่ skill ทำ

1. Reproduce (หรือบอกว่าทำไม่ได้ → `BLOCKED`)  
2. หา fail path — Grep/สัญลักษณ์ก่อน; ไฟล์ยาวมากอ่านแบบช่วง ไม่ dump ทั้งไฟล์เป็นค่าเริ่มต้น (`agent-ops` read budget)  
3. สมมติฐาน 3–5 ข้อ หักทีละข้อ (`ATTEMPT: #n`)  
4. RISK — ตามตาราง `agent-ops` (ห้ามลดเป็น LOW เพื่อข้าม review)  
5. แพตช์น้อยสุด + ROLLBACK หนึ่งบรรทัด — งบ ≤5 ไฟล์ / ≤120 บรรทัด (เกินต้อง `ยืนยัน`/`confirm`/`yes`)  
6. Verify: IDENTIFY → RUN → READ ตาม [verify-matrix](../../templates/ops/verify-matrix.md)
7. MED/HIGH → แนะนำ `/review` แล้ว `/ship`

## Golden (ตรง SKILL)

In: `/fix` checkout total ผิดเป็นพักๆ → repro → cause → patch เล็ก → VERIFY ผ่าน  
อย่าใช้ `/fix` สร้าง UI demo → ใช้ `/plan`

## vs `/make`

| สถานการณ์ | ใช้ |
|-----------|-----|
| ไม่รู้สาเหตุ / พัง / flaky / ข้อมูลผิดโดยไม่รู้สาเหตุ | `/fix` |
| รู้สาเหตุแล้ว รูปแพตช์ชัด (เช่น เปลี่ยน floor เป็น round) | `/make` |

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| เป้าหมายชัด รู้ว่าจะสร้างอะไร | `/make` |
| UI / หลายขั้น เก็บเป็นแผน | `/plan` |
| อยากได้แผนก่อน ไม่แก้โค้ด | `/plan` |
| ฟีเจอร์ใหญ่หลายสไลซ์ | `/feature` |
| รีวิวอย่างเดียว | `/review` |
