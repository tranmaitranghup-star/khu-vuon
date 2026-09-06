#!/usr/bin/env python3
"""Bộ đo bố cục cho khối GIỜ DEEPWORK TÁCH BA LOẠI VIỆC (làn S, 17/08).

Song sinh với `thu-bocuc.py` / `thu-lan-r.py`: nó RÚT NGUYÊN khối <style>,
NGUYÊN thẻ HTML và NGUYÊN các hàm từ `public/index.html`, nên không bao giờ
soi nhầm bản cũ. Chỉ thay đúng hai thứ: dữ liệu (số giả) và lớp nối máy chủ.

    python3 thu-rvd.py          # ghi ra public/thu-rvd.html
    # xem ở localhost:8080/thu-rvd.html rồi:
    rm public/thu-rvd.html      # ⚠️ public/ là thư mục lên sóng thật

`.gitignore` đã có `public/thu-*.html` nên quên xoá cũng không lọt lên sóng,
nhưng cứ xoá cho sạch.
"""
import re
import pathlib

GOC = pathlib.Path(__file__).parent
SRC = (GOC / 'public/index.html').read_text()


def khoi_style(src):
    return re.search(r'<style>(.*?)</style>', src, re.S).group(1)


def the_html(src, ma_id):
    """Rút một thẻ <div id="..."> ... </div> bằng cách đếm thẻ div lồng nhau."""
    i = src.index(f'id="{ma_id}"')
    dau = src.rindex('<div', 0, i)
    sau, sau_c, j = 0, 0, dau
    while j < len(src):
        if src.startswith('<div', j):
            sau += 1
        elif src.startswith('</div>', j):
            sau_c += 1
            if sau_c == sau:
                return src[dau:j + 6]
        j += 1
    raise ValueError(f'không đóng được thẻ #{ma_id}')


def ham(src, ten, kieu='function'):
    """Rút một hàm/hằng bằng cách khớp ngoặc nhọn hoặc lấy hết một dòng."""
    if kieu == 'function':
        i = src.index(f'function {ten}(')
        j = src.index('{', i)
        sau = 0
        while j < len(src):
            if src[j] == '{':
                sau += 1
            elif src[j] == '}':
                sau -= 1
                if sau == 0:
                    return src[i:j + 1]
            j += 1
    if kieu == 'dong':                      # const x = ...;  (một dòng)
        m = re.search(r'^const %s\s*=.*?;$' % re.escape(ten), src, re.M)
        return m.group(0)
    if kieu == 'khoi':                      # const X = [ ... ];
        i = src.index(f'const {ten}')
        j = src.index(';', i)
        return src[i:j + 1]
    if kieu == 'mui':                       # const x = p => { ... };  (nhiều dòng)
        i = src.index(f'const {ten}')
        j = src.index('{', i)
        sau = 0
        while j < len(src):
            if src[j] == '{':
                sau += 1
            elif src[j] == '}':
                sau -= 1
                if sau == 0:
                    return src[i:j + 2]     # +2 để nuốt cả dấu ';'
            j += 1
    raise ValueError(kieu)


# ── số giả: cố ý đủ các ca đáng nhìn ────────────────────────────────────────
#   người dồn hết vào cam kết · người bị việc phát sinh chiếm quá nửa ·
#   người chỉ chạy việc cố định · người chưa có phiên nào · tên dài tràn ô
SO_GIA = """
const DOI = [
  {id:'u1',  ten:'Tracy'},        {id:'u2',  ten:'Hằng'},
  {id:'u3',  ten:'John'},         {id:'u4',  ten:'Duyên'},
  {id:'u5',  ten:'Khoa'},         {id:'u6',  ten:'Nguyễn Minh Anh'},
  {id:'u7',  ten:'Tuấn'},         {id:'u8',  ten:'Ngọc'},
  {id:'u9',  ten:'Hoàng'},        {id:'u10', ten:'Lan'},
  {id:'u11', ten:'Bảo'},          {id:'u12', ten:'Vy'},
];
const ME = {id:'u1'};
let RV_TUAN  = '2026-08-11';
let RVD_TUAN = '2026-08-11';   // tuần khối đang nói tới (rvdVe đọc biến này)
let RVD_SAN  = true;
/* Tuần trước — chỉ để tính mức chênh. Cố ý ĐỂ THIẾU u6 và u12: người không có
   dữ liệu tuần trước thì mức chênh phải VẮNG MẶT, không được bịa số 0 để trừ. */
let RVD_TRUOC = {
  u1:{cam_ket:430, co_dinh:200, phat_sinh:182, phien:13},
  u2:{cam_ket:300, co_dinh:140, phat_sinh: 94, phien:10},
  u3:{cam_ket:340, co_dinh:110, phat_sinh:252, phien:14},
  u4:{cam_ket:300, co_dinh:120, phat_sinh: 78, phien:11},
  u5:{cam_ket:120, co_dinh:180, phat_sinh: 52, phien: 8},
  u7:{cam_ket:220, co_dinh: 60, phat_sinh:232, phien: 9},
  u8:{cam_ket:380, co_dinh:100, phat_sinh: 66, phien:12},
  u9:{cam_ket: 40, co_dinh:150, phat_sinh: 74, phien: 6},
  u10:{cam_ket:260, co_dinh:120, phat_sinh: 90, phien:10},
  u11:{cam_ket:160, co_dinh: 80, phat_sinh:158, phien: 9},
};
let RVD = {
  u1:{cam_ket:498, co_dinh:186, phat_sinh:172, phien:14},
  u2:{cam_ket:392, co_dinh:120, phat_sinh: 64, phien:11},
  u3:{cam_ket:214, co_dinh: 96, phat_sinh:298, phien:13},
  u4:{cam_ket:336, co_dinh:154, phat_sinh: 88, phien:12},
  u5:{cam_ket: 78, co_dinh:212, phat_sinh:126, phien: 9},
  u6:{cam_ket:288, co_dinh: 60, phat_sinh:142, phien:10},
  u7:{cam_ket:162, co_dinh: 48, phat_sinh:236, phien: 8},
  u8:{cam_ket:410, co_dinh: 96, phat_sinh: 52, phien:12},
  u9:{cam_ket:  0, co_dinh:174, phat_sinh: 36, phien: 5},
  u10:{cam_ket:246, co_dinh:132, phat_sinh:104, phien:10},
  u11:{cam_ket:118, co_dinh: 72, phat_sinh:190, phien: 9},
  u12:{cam_ket:  0, co_dinh:  0, phat_sinh:  0, phien: 0},
};
"""

TRANG = """<!doctype html>
<html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Đo bố cục — Giờ deep work ba loại việc</title>
<style>%(css)s</style>
<style>
  /* ⚠️ TUYỆT ĐỐI KHÔNG khai đè `.the` ở đây. Bản đầu viết
     `.the{padding:15px 13px}` và `body{padding:12px}` — rộng hơn app thật 18px,
     nên mọi kết luận "không tràn" lấy từ bộ đo đều lạc quan hơn sự thật đúng
     bằng ấy, và đó chính là biên che mất hai lỗi tràn nặng ở ba ô số.
     App thật: `.man{padding:16px 16px 24px}` + `.the{border:1px;padding:18px}`
     → lòng thẻ 305px ở màn 375, 250px ở màn 320. Dựng đúng khung ấy bằng cách
     bọc trong `.man.hien` và để nguyên `.the` của app. */
  body{background:var(--bg);margin:0}
  .thanh-thu{display:flex;gap:6px;padding:10px 16px 0}
  .thanh-thu button{flex:1;background:var(--card2);color:var(--dim);border:1px solid var(--line);
    border-radius:8px;padding:7px 4px;font:inherit;font-size:.72rem}
  .thanh-thu button.on{background:var(--xanh-dam);color:var(--text)}
</style>
</head><body>

<div class="thanh-thu">
  <button class="on" onclick="caDu()">Số đủ</button>
  <button onclick="caTrong()">Chưa ai có phiên</button>
  <button onclick="caMot()">Đúng một người</button>
  <button onclick="caAn()">Chưa chạy SQL</button>
</div>

<!-- id="man-doi" là BẮT BUỘC: luật xếp hai cột trên màn rộng nhắm `#man-doi`,
     không có id thì bộ đo không soi được nó. Ba thẻ giả bao quanh để dựng đúng
     cảnh thật — mục ROVA có BỐN thẻ, và lưới hai cột chỉ lộ ra khi có đủ. -->
<div class="man hien" id="man-doi">
  <div class="dau"><div><h1>ROVA</h1><div class="ngay">hôm nay + 7 ngày gần nhất</div></div></div>

  <div class="the"><h2>Kết quả trong ngày</h2>
    <p class="trong" style="padding:0 0 12px;text-align:left;font-size:.76rem">
      Đếm <b>quả</b> — việc đã xong mà có giờ deepwork thật. Đây là bảng chính.</p>

      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">1</span><span style="flex:1"><b style="font-size:.9rem">Andy</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 22 quả</div></span><b style="font-size:.95rem">🍎 2</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">2</span><span style="flex:1"><b style="font-size:.9rem">Tracy</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 17 quả</div></span><b style="font-size:.95rem">🍎 1</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">3</span><span style="flex:1"><b style="font-size:.9rem">Justin</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 16 quả</div></span><b style="font-size:.95rem">🍎 1</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">4</span><span style="flex:1"><b style="font-size:.9rem">Hafi</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 4 quả</div></span><b style="font-size:.95rem">🍎 1</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">5</span><span style="flex:1"><b style="font-size:.9rem">Sydney</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 4 quả</div></span><b style="font-size:.95rem">🍎 1</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">6</span><span style="flex:1"><b style="font-size:.9rem">John</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 4 quả</div></span><b style="font-size:.95rem">🍎 1</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">7</span><span style="flex:1"><b style="font-size:.9rem">Peter</b><div style="color:var(--dim);font-size:.72rem">7 ngày: 0 quả</div></span><b style="font-size:.95rem">—</b></div></div>

  <div class="the"><h2>Giờ tập trung</h2>
    <p class="trong" style="padding:0 0 12px;text-align:left;font-size:.76rem">
      Đếm <b>giờ</b> đã đổ vào vườn. Ngày nào cũng thắng được — chỉ cần có mặt.</p>

      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">1</span><span style="flex:1"><b style="font-size:.9rem">Andy</b><div style="color:var(--dim);font-size:.72rem">24 lần chăm · 7/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 33.2h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">2</span><span style="flex:1"><b style="font-size:.9rem">Justin</b><div style="color:var(--dim);font-size:.72rem">19 lần chăm · 6/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 27.4h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">3</span><span style="flex:1"><b style="font-size:.9rem">Tracy</b><div style="color:var(--dim);font-size:.72rem">32 lần chăm · 7/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 24.4h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">4</span><span style="flex:1"><b style="font-size:.9rem">John</b><div style="color:var(--dim);font-size:.72rem">7 lần chăm · 4/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 10.6h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">5</span><span style="flex:1"><b style="font-size:.9rem">Sydney</b><div style="color:var(--dim);font-size:.72rem">5 lần chăm · 5/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 8.5h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">6</span><span style="flex:1"><b style="font-size:.9rem">Hafi</b><div style="color:var(--dim);font-size:.72rem">4 lần chăm · 3/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">💧 8.3h</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">7</span><span style="flex:1"><b style="font-size:.9rem">Peter</b><div style="color:var(--dim);font-size:.72rem">0 lần chăm · 0/7 ngày làm có ra vườn</div></span><b style="font-size:.95rem">—</b></div></div>

%(html)s

  <div class="the"><h2>🔁 Việc cố định của cả đội</h2>

      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">1</span><span style="flex:1"><b style="font-size:.9rem">Andy</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">5/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">2</span><span style="flex:1"><b style="font-size:.9rem">Tracy</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">7/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">3</span><span style="flex:1"><b style="font-size:.9rem">Justin</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">6/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">4</span><span style="flex:1"><b style="font-size:.9rem">Hafi</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">3/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">5</span><span style="flex:1"><b style="font-size:.9rem">Sydney</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">4/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">6</span><span style="flex:1"><b style="font-size:.9rem">John</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">2/7</b></div>
      <div style="display:flex;align-items:center;gap:10px;padding:9px 0;border-bottom:1px solid var(--line)"><span style="color:var(--dim2);font-size:.7rem">7</span><span style="flex:1"><b style="font-size:.9rem">Peter</b><div style="color:var(--dim);font-size:.72rem">💎💎🪨💎💩💎💎</div></span><b style="font-size:.95rem">0/7</b></div></div>
</div>

<script>
%(sogia)s
/* ⚠️ Phải cất CẢ HAI kho. Bản đầu chỉ cất `RVD`, nên bấm "Chưa ai có phiên"
   một lần là `RVD_TRUOC` mất sạch và MỌI mức chênh biến mất ở tất cả các ca
   sau — nhìn ảnh chụp tưởng app hỏng, thật ra hỏng ở đây. */
const RVD_GOC       = JSON.parse(JSON.stringify(RVD));
const RVD_TRUOC_GOC = JSON.parse(JSON.stringify(RVD_TRUOC));
%(hams)s

const phucHoi = () => { RVD       = JSON.parse(JSON.stringify(RVD_GOC));
                        RVD_TRUOC = JSON.parse(JSON.stringify(RVD_TRUOC_GOC)); };

function caDu(){   phucHoi();                                  RVD_SAN = true;  ve(); }
function caTrong(){RVD = {}; RVD_TRUOC = {};                   RVD_SAN = true;  ve(); }
function caMot(){  phucHoi();
                   RVD = {u7:{cam_ket:0, co_dinh:0, phat_sinh:35, phien:1}};
                                                               RVD_SAN = true;  ve(); }
function caAn(){                                               RVD_SAN = false; ve(); }
function ve(){
  document.querySelectorAll('.thanh-thu button').forEach((b,i) =>
    b.classList.toggle('on', i === [caDu,caTrong,caMot,caAn].indexOf(window.__ca)));
  rvdVe();
}
['caDu','caTrong','caMot','caAn'].forEach(n => {
  const g = window[n];
  window[n] = () => { window.__ca = g; g(); };
});
window.__ca = caDu;
rvdVe();
</script>
</body></html>
"""

css = khoi_style(SRC)
html = the_html(SRC, 'rvd-the').replace('style="display:none"', '')
# ⚠️ Thứ tự có ý nghĩa: `rvCong` gọi `d2s`, nên `d2s` phải đứng trước. Thiếu nó
# thì trang im lặng rỗng chứ KHÔNG báo lỗi ra màn — lần dựng đầu đã dính đúng
# vậy, phải gọi tay `rvdVe()` trong console mới lòi ra `d2s is not defined`.
hams = '\n\n'.join([
    ham(SRC, 'RVD_COT', 'khoi'),
    ham(SRC, 'd2s', 'dong'),
    ham(SRC, 'rvdHmm', 'mui'),
    ham(SRC, 'rvChuNgay', 'dong'),
    ham(SRC, 'rvCong', 'dong'),
    ham(SRC, 'chuSach'),
    ham(SRC, 'rvdVe'),
])

ra = GOC / 'public/thu-rvd.html'
ra.write_text(TRANG % {'css': css, 'html': html, 'sogia': SO_GIA, 'hams': hams})
print(f'✅ đã ghi {ra}  ({ra.stat().st_size:,} byte)')
print('   xem: http://localhost:8080/thu-rvd.html')
print('   ⚠️  xem xong nhớ:  rm public/thu-rvd.html')
