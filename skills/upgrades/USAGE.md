# /upgrades — ใช้ยังไง

ทำให้ **skills ใน pack นี้ดีขึ้น / แม่นขึ้น / คมขึ้น** (ขั้นตอนชัด เกตครบ ตัวอย่างถูกโหมด)  
งานซิงก์ไฟล์เป็นเรื่องรอง — ไม่ใช่เป้าหมายหลัก

ไม่ใช่ฟีเจอร์แอป → ใช้ `/make` / `/feature`  
หลังเพิ่ม/rename skill แล้วรีสตาร์ท Cursor:

```powershell
.\scripts\install-windows.ps1
```

```bash
./scripts/install-unix.sh
```

## คำสั่ง

| พิมพ์ | โหมด | ผล |
|--------|------|-----|
| `/upgrades` · `/upgrades audit` | audit | ชี้จุดที่ skill ยังคลุมเครือ/อ่อน — **ไม่แก้** |
| `/upgrades propose …` | propose | แผนอัปเกรดคุณภาพ — **ไม่แก้** |
| `/upgrades apply …` | apply | ลงมือปรับ skill/rule/template (กระทบ slash / REPORT / **rules always-on** → รอ `ยืนยัน`) |

## ตัวอย่าง

**ทั้ง pack — อะไรยังไม่แม่น**
```
/upgrades
```
```
/upgrades audit
```

**โฟกัส skill เดียวให้คมขึ้น**
```
/upgrades propose ship — กันลืม secrets scan และ force-push gate
```
```
/upgrades propose fix — ห้ามแพตช์ก่อนมี repro ให้เด่นกว่านี้
```
```
/upgrades propose make — งบประมาณและ enterprise ให้อ่านแล้วทำตามได้ทันที
```

**ปรับตามที่ตกลง**
```
/upgrades apply make — งบประมาณและ enterprise ให้อ่านแล้วทำตามได้ทันที
```
```
/upgrades apply agent-ops — เพิ่ม git hygiene สั้นๆ
ยืนยัน
```
(always-on rule → ต้อง confirm)

**คุณภาพ + ตรวจ drift**
```
/upgrades audit skills/ship skills/make
```

## มุมที่ skill นี้จะไล่

1. Trigger ชัดไหม (ไม่ปนกับ skill อื่น)  
2. Steps ทำให้ agent ทำซ้ำได้ไหม  
3. Gates ครบตอนเสี่ยง  
4. Template/REPORT ตรงฟอร์แมต  
5. USAGE มีตัวอย่างที่ใช้ถูก  
6. Drift README / install (รอง)

## ลำดับที่แนะนำ

1. `/upgrades` หรือ `/upgrades audit` → อ่าน IMPROVEMENTS  
2. `/upgrades propose <skill> …` → ล็อกแผน  
3. `/upgrades apply …` → แก้ (ยืนยันถ้าขอ)  
4. รีลิงก์ skills ถ้าเพิ่ม/rename (`skill-names.txt` + install script)  
5. `.\scripts\validate-skill-names.ps1` (และ validate-plan ถ้าแตะ)  
6. `/ship` → commit/push  
7. Smoke: [evals/README.md](../../evals/README.md)

## ไม่ใช้เมื่อ

| งาน | ใช้แทน |
|-----|--------|
| แก้บั๊กแอป | `/fix` |
| สร้างฟีเจอร์แอป | `/make` / `/feature` |
| commit / push | `/ship` |
