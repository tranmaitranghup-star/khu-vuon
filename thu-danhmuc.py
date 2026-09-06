#!/usr/bin/env python3
"""Bản thử BA CỬA VÀO TUẦN MỚI + danh mục việc cố định — không cần đăng nhập.

Cùng mẹo với `thu-bocuc.py` / `thu-manxacnhan.py`: rút NGUYÊN khối <style> và
NGUYÊN cụm hàm `vcd*` từ `public/index.html` rồi nhúng vào một trang mới, nên
không bao giờ soi nhầm bản cũ. Supabase được thay bằng một kho giả trong bộ nhớ.

    python3 thu-danhmuc.py
    → http://localhost:8080/thu-danhmuc.html
    dọn: rm public/thu-danhmuc.html
"""
import re, pathlib

GOC = pathlib.Path(__file__).parent
src = (GOC / 'public' / 'index.html').read_text()
style = '\n'.join(m.group(1) for m in re.finditer(r'<style>(.*?)</style>', src, re.S))

i = src.rindex('<script>'); j = src.index('</script>', i)
js = src[i + 8:j]

# Rút đúng cụm hàm cần thử, từ `const vcdConTrong` tới hết `vcdDungViecDo`.
a = js.index('const vcdConTrong')
b = js.index('async function vcdDungViecDo')
b = js.index('\n}', b) + 2
cum = js[a:b]

trang = f'''<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>Thử danh mục việc cố định</title>
<style>{style}</style>
<style>
body{{padding:14px;max-width:520px;margin:0 auto}}
#gat{{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:14px}}
#gat button{{font-size:11px;padding:6px 10px;border-radius:7px;background:#2a3a44;color:#cfe}}
#log{{margin-top:14px;font:11px/1.5 ui-monospace,monospace;color:var(--dim);
  white-space:pre-wrap;border-top:1px solid var(--line);padding-top:10px}}
</style></head><body>

<div id="gat">
  <button onclick="canh('rong')">① Danh mục RỖNG</button>
  <button onclick="canh('tuandau')">② Tuần đầu · có tuần trước</button>
  <button onclick="canh('day')">③ Đủ ba cửa</button>
  <button onclick="canh('gan-day')">④ Còn 1 chỗ</button>
</div>

<h2 class="vcd-tieu">🔁 5 việc cố định bạn làm mỗi ngày trong tuần này</h2>
<div id="vcd-chon"></div>
<div id="ds-tuan"></div>
<div id="log"></div>

<script>
/* ── kho giả ─────────────────────────────────────────────────────────────── */
let NHIP = [], VCD = [], VCD_SAN = true, VCD_TICK = new Set();
let ME = {{id:'me', chuc_nang_id:4}};
let TUAN_TRUOC = null;
const chuSach = s => String(s??'').replace(/[&<>"]/g, c => (
  {{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}}[c]));
const homNay = () => '2026-08-14';
const thuHai = () => '2026-08-10';
const ngayDep = d => d ? d.slice(8,10)+'/'+d.slice(5,7) : '';
const toast = m => ghi('toast: ' + m);
const baoLoiNhip = e => '⚠️ ' + (e.message||e.code);
function ghi(s){{ document.getElementById('log').textContent = s + '\\n'
  + document.getElementById('log').textContent; }}
async function taiTuan(){{ veTuan(); await veChonViec(); }}
function veTuan(){{
  let h = '';
  for (let i=1;i<=5;i++){{
    const n = NHIP.find(x=>x.thu_tu===i);
    h += `<div class="vcd-the${{n?'':' cho-trong'}}"><div class="vcd-dau">
      <input placeholder="Việc ${{i}}…" value="${{n?chuSach(n.ten):''}}"></div></div>`;
  }}
  document.getElementById('ds-tuan').innerHTML = h;
}}
/* `.select()` trả một chuỗi nối được — để `vcdTuanChep` THẬT chạy qua đây chứ
   không phải thay bằng một bản giả. Bản giả thì bản thử không còn thử cái gì. */
function chuoiTruyVan(ketQua){{
  const t = {{ then: (r) => Promise.resolve(ketQua).then(r) }};
  ['eq','lt','gt','gte','lte','order','limit','in','neq'].forEach(k => t[k] = () => t);
  return t;
}}
const sb = {{from: t => ({{
  select: () => chuoiTruyVan(
    t === 'nhip' && TUAN_TRUOC ? {{data:[{{tuan_bat_dau: TUAN_TRUOC}}], error:null}}
                               : {{data:[], error:null}}),
  insert: r => ({{ select: async () => {{
    ghi('INSERT ' + t + ' ← ' + JSON.stringify(r));
    if (t === 'nhip'){{
      const v = VCD.find(x=>x.id===r.viec_id);
      NHIP.push({{...r, id: Math.random(), ten: v ? v.ten : r.ten}});
    }} else {{
      const row = {{...r, id: Date.now()%100000, dang_dung:true, so_tuan_da_dung:0}};
      VCD.push(row); return {{data:[row], error:null}};
    }}
    return {{data:[r], error:null}};
  }}, then: undefined }}),
  update: p => ({{ eq: async (_c,id) => {{
    ghi('UPDATE ' + t + ' #' + id + ' ← ' + JSON.stringify(p));
    const row = (t==='nhip'?NHIP:VCD).find(x=>x.id===id);
    if (row) Object.assign(row, p);
    if (t==='viec_co_dinh') NHIP.filter(n=>n.viec_id===id).forEach(n=>n.ten=p.ten||n.ten);
    return {{error:null}};
  }} }}),
}})}};

/* ── cụm hàm THẬT, rút từ public/index.html ──────────────────────────────── */
{cum}

/* ── bốn cảnh ────────────────────────────────────────────────────────────── */
const KHO = [
  {{id:1, ten:'Họp giao ban',          don_vi:'Lần/ngày', dang_dung:true, so_tuan_da_dung:6, tuan_gan_nhat:'2026-08-03'}},
  {{id:2, ten:'Gọi 10 khách mới',      don_vi:'Lần/ngày', dang_dung:true, so_tuan_da_dung:6, tuan_gan_nhat:'2026-08-03'}},
  {{id:3, ten:'Chấm bài học viên',     don_vi:'Lần/ngày', dang_dung:true, so_tuan_da_dung:2, tuan_gan_nhat:'2026-07-20'}},
  {{id:4, ten:'Import data revshare',  don_vi:'Lần/ngày', dang_dung:true, so_tuan_da_dung:5, tuan_gan_nhat:'2026-08-03'}},
  {{id:5, ten:'Soát đơn hàng tồn',     don_vi:'Lần/ngày', dang_dung:true, so_tuan_da_dung:1, tuan_gan_nhat:null}},
];
function canh(k){{
  VCD_TICK = new Set();
  document.getElementById('log').textContent = '';
  if (k === 'rong')     {{ VCD = []; NHIP = []; TUAN_TRUOC = null; }}
  if (k === 'tuandau')  {{ VCD = []; NHIP = []; TUAN_TRUOC = '2026-08-03'; }}
  if (k === 'day')      {{ VCD = KHO.map(o=>({{...o}})); NHIP = []; TUAN_TRUOC = '2026-08-03'; }}
  if (k === 'gan-day')  {{ VCD = KHO.map(o=>({{...o}})); TUAN_TRUOC = '2026-08-03';
    NHIP = [1,2,3,4].map((v,i)=>({{id:100+i, viec_id:v, thu_tu:i+1,
      ten: KHO[v-1].ten}})); }}
  taiTuan();
}}
canh('day');
</script></body></html>'''

out = GOC / 'public' / 'thu-danhmuc.html'
out.write_text(trang)
print(f'✓ {out}  ({len(trang)/1024:.0f} KB)')
print('  http://localhost:8080/thu-danhmuc.html · dọn: rm public/thu-danhmuc.html')
