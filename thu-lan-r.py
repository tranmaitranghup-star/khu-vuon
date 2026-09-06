#!/usr/bin/env python3
"""Bản thử LÀN R — cửa ＋ (hàng Deadline·Ghi + khay thẻ việc) · sổ 📝 của phiên ·
hàng ngày của màn Dọn. Không cần đăng nhập.

Cùng mẹo với `thu-bocuc.py` / `thu-cua-ghichu.py`: rút NGUYÊN khối <style>,
NGUYÊN thẻ và NGUYÊN cụm hàm từ `public/index.html`, nên không soi nhầm bản cũ.

    python3 thu-lan-r.py
    → http://localhost:8080/thu-lan-r.html
    dọn: rm public/thu-lan-r.html
"""
import re, pathlib

GOC = pathlib.Path(__file__).parent
src = (GOC / 'public' / 'index.html').read_text()
style = '\n'.join(m.group(1) for m in re.finditer(r'<style>(.*?)</style>', src, re.S))


def ham(ten):
    """Rút NGUYÊN một hàm theo tên. Hàm trong file này luôn đóng bằng `\\n}`."""
    m = re.search(r'(?:async )?function ' + ten + r'\(.*?\n\}', src, re.S)
    if not m:
        raise SystemExit(f'không thấy hàm {ten}')
    return m.group(0)


def the(mo_dau, ket_thuc):
    a = src.index(mo_dau)
    b = src.index(ket_thuc, a)
    return src[a:b].strip()


# ── Thẻ thật ────────────────────────────────────────────────────────────────
cua_them = the('<div class="cua-noi-nen" id="dw-them"', '<!-- 📝 ghi một Ý')
cua_note = the('<div class="cua-noi-nen" id="dw-note"', '<!-- Lời của trạng thái CHỌN')

# ── Hàm thật ────────────────────────────────────────────────────────────────
HAM = '\n\n'.join([
    ham('oNgay'), ham('nhanNgay'), ham('moLich'),
    ham('dwNhanTheDi'), ham('dwThemVeDs'),
    ham('donNgayHen'), ham('nhanNutDon'), ham('veDonDong'), ham('veODon'),
    ham('donNgay'), ham('donGhiChu'), ham('donHanGo'), ham('donCho'), ham('donDatTT'),
])
DON_TT = re.search(r'const DON_TT = \[.*?\n\];', src, re.S).group(0)

trang = f'''<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>Thử làn R</title>
<style>{style}</style>
<style>
body{{padding:14px;max-width:520px;margin:0 auto;background:#0d1418}}
#gat{{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px}}
#gat button{{font-size:11px;padding:6px 10px;border-radius:7px;background:#2a3a44;color:#cfe}}
#do{{margin-top:12px;font:11px/1.55 ui-monospace,monospace;color:#8fb;white-space:pre-wrap}}
h4{{color:#cfe;font-size:12px;margin:14px 0 6px}}
</style></head><body>

<div id="gat">
  <button onclick="moThem()">Cửa ＋ (Deadline·Ghi)</button>
  <button onclick="moThemNgay()">Cửa ＋ có ngày</button>
  <button onclick="moNote()">Sổ 📝 của phiên</button>
  <button onclick="DW_THE_SUA=102;dwThemVeDs();do2()">Mở mặt SỬA một thẻ</button>
  <button onclick="dong()">Đóng cả hai</button>
</div>

<h4>Hàng ngày của màn Dọn — cửa ⏳ Chưa xong</h4>
<div id="don-ds"></div>

{cua_them}
{cua_note}
<div id="do"></div>

<script>
/* ── Nẹp đỡ tối thiểu: chỉ những thứ hàng ngày của màn Dọn thật sự chạm ─── */
const chuSach = s => String(s ?? '').replace(/[&<>"']/g, c =>
  ({{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}})[c]);
const chuSoanDuoc = chuSach;
const d2s = d => new Date(d.getTime() - d.getTimezoneOffset()*60000).toISOString().slice(0,10);
const homNay = () => d2s(new Date());
const richKhai = () => {{}};
const timO = () => ({{ma:'O5', ten:'Giải pháp + tính năng app'}});
const TT_NHAN = {{}};
const DON_KIEU = 'sang';
let DON_TAM = {{}};
let DW_VIEC_PHIEN = [], DW_VIEC_PHIEN_ID = null, DW_THE_SUA = null;

{DON_TT}

/* ── Hàm THẬT, rút từ public/index.html ─────────────────────────────────── */
{HAM}

/* `veDon` thật vẽ cả màn; ở đây chỉ vẽ đúng một dòng để soi hàng ngày. */
const VIEC = {{id: 1, noi_dung: 'Giải pháp + tính năng app', tieu_diem_ma: 'O5',
  so_ngay_delay: 3, so_lan_hoan: 2, het_cua_hen_ngay: false,
  da_chot: false, trang_thai: 'Chua_xong', ghi_chu_chot: ''}};
const NO_CU = [VIEC];
function veDon(){{
  document.getElementById('don-ds').innerHTML = veDonDong(VIEC);
  do2();
}}

/* ── Ba cửa gạt ─────────────────────────────────────────────────────────── */
function dong(){{
  ['dw-them','dw-note'].forEach(i => document.getElementById(i).classList.remove('hien'));
  do2();
}}
function moThem(ngay){{
  dong();
  document.getElementById('dw-them').classList.add('hien');
  document.getElementById('dw-them-o').value = 'Bộ sưu tập ';
  const o = document.getElementById('dw-them-han');
  o.value = ngay || ''; nhanNgay(o);
  DW_VIEC_PHIEN = [
    {{id: 101, noi_dung: 'Bộ sưu tập ảnh nền mùa thu', ngay: null}},
    {{id: 102, noi_dung: 'Hỏi Lâm Saa về hai phương án hợp tác', ngay: homNay()}},
    {{id: 103, noi_dung: 'Rà lại công thức điểm ngày cho việc cố định', ngay: '2026-08-20'}},
  ];
  dwThemVeDs();
  do2();
}}
const moThemNgay = () => moThem('2026-08-20');
function moNote(){{
  dong();
  document.getElementById('dw-note').classList.add('hien');
  const go = document.getElementById('dw-note-o');
  go.value = ['Ai đề xuất giải pháp thì người đó chạy thử trước.',
    '',
    'Nút "về kho" phải nằm cạnh ô ngày, không nằm dưới — mắt đi ngang trước khi đi xuống.',
    '',
    'Hỏi lại: bảng đo tuần có nói được câu "tuần này khá hơn tuần trước ở chỗ nào" không?',
    '', 'Đoạn thứ tư để thử cuộn.', '', 'Đoạn thứ năm.'].join('\\n');
  go.focus(); go.selectionStart = go.selectionEnd = go.value.length;
  go.scrollTop = go.scrollHeight;
  do2();
}}

/* ── Máy đo ─────────────────────────────────────────────────────────────── */
function DO(){{
  const r = el => el ? el.getBoundingClientRect() : null;
  const them = document.getElementById('dw-them');
  const note = document.getElementById('dw-note');
  const k = {{khung: innerWidth + '×' + innerHeight,
    trangCuonNgang: document.documentElement.scrollWidth - document.documentElement.clientWidth}};

  if (them.classList.contains('hien')){{
    const ng = r(document.getElementById('dw-them-han-nut'));
    const nut = r(them.querySelector('.dw-them-hang .nut'));
    const hop = r(them.querySelector('.cua-noi'));
    k.oNgay = Math.round(ng.width) + 'px @' + Math.round(ng.left);
    k.nutGhi = Math.round(nut.width) + 'px @' + Math.round(nut.left);
    k.deLenNhau = ng.right > nut.left + 0.5 ? '❌ CÒN ĐÈ ' + Math.round(ng.right - nut.left) + 'px' : '✅ không';
    k.chuDeadline = document.getElementById('dw-them-han-chu').textContent;
    k.hopThem = Math.round(hop.width) + '×' + Math.round(hop.height);
    k.tranMan = Math.round(hop.bottom - innerHeight) + 'px (âm = còn trong màn)';
    k.soThe = document.querySelectorAll('#dw-them-ds .dw-the-viec').length;
    k.nhanThe = [...document.querySelectorAll('#dw-them-ds .di')].map(x => x.textContent).join(' | ');
  }}
  if (note.classList.contains('hien')){{
    const go = document.getElementById('dw-note-o');
    const hop = r(note.querySelector('.cua-noi'));
    k.oSo = Math.round(r(go).width) + '×' + Math.round(r(go).height);
    k.conTro = go.selectionStart === go.value.length ? '✅ ở cuối' : '❌ ' + go.selectionStart;
    k.oCuon = go.scrollHeight - go.clientHeight + 'px';
    k.hopNote = Math.round(hop.width) + '×' + Math.round(hop.height);
    k.tranMan = Math.round(hop.bottom - innerHeight) + 'px (âm = còn trong màn)';
  }}
  const hangNgay = document.querySelector('#don-ds .don-hang-ngay');
  if (hangNgay){{
    k.donNgayChu = document.getElementById('don-ngay-1-chu')?.textContent;
    k.donNhac = hangNgay.querySelector('span')?.textContent;
    k.donNutKho = hangNgay.querySelector('.don-kho')?.textContent || '(không có)';
    k.donNutChinh = document.querySelector('#don-ds .don-nut.mot button')?.textContent.trim();
    k.donTamNgay = JSON.stringify(DON_TAM[1]?.ngay);
  }}
  return k;
}}
function do2(){{
  document.getElementById('do').textContent =
    Object.entries(DO()).map(([a,b]) => a.padEnd(15) + b).join('\\n');
}}
addEventListener('resize', do2);

donDatTT(1, 'Chua_xong');   // mở đúng cửa cần soi
moThem();
</script></body></html>'''

out = GOC / 'public' / 'thu-lan-r.html'
out.write_text(trang)
print(f'✓ {out}  ({len(trang)/1024:.0f} KB)')
print('  http://localhost:8080/thu-lan-r.html · dọn: rm public/thu-lan-r.html')
