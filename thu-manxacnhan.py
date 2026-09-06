#!/usr/bin/env python3
"""Dựng bản thử MÀN XÁC NHẬN trước phiên deepwork để đo bố cục bằng máy.

Song sinh với `thu-bocuc.py` — nó dựng màn ĐANG CHẠY, cái này dựng màn CHỌN
(`#dw-chon`). Cùng một mẹo: rút NGUYÊN khối <style> từ `public/index.html` rồi
nhúng vào một trang mới, nên không bao giờ soi nhầm CSS cũ.

    python3 thu-manxacnhan.py
    → mở http://localhost:8080/thu-manxacnhan.html
    dọn: rm public/thu-manxacnhan.html

Trang có hai nút gạt: XÁC NHẬN (một thẻ) ↔ DANH SÁCH (nhiều thẻ), và một hộp
số góc trái tự phán khối nào tràn.
"""
import re, pathlib

GOC = pathlib.Path(__file__).parent
src = (GOC / 'public' / 'index.html').read_text()
style = '\n'.join(m.group(1) for m in re.finditer(r'<style>(.*?)</style>', src, re.S))

THE_TASK = '''
    <div class="dw-muc chon" onclick="void 0">
      <span class="cham"></span>
      <div class="nd">Dựng lại bộ khung báo cáo BOD quý 3 cho X3com
        <div class="meta2">
          <span class="o-so nho l2">2</span>
          <span class="mt-chu">Báo cáo tài chính</span>
          <span>⏰ 16/08</span>
          <span style="color:var(--tt-lam)">💧 2h15′</span>
        </div>
      </div>
    </div>'''

THE_NHIP = '''
    <div class="dw-muc chon" onclick="void 0">
      <span class="cham"></span>
      <div class="nd">Check tỉnh thức ROVA
        <div class="meta2">
          <span>Mục tiêu 1 Lần/ngày</span>
          <span style="color:var(--tt-lam)">hôm nay 1</span>
          <span>6/9 bước</span>
        </div>
      </div>
    </div>'''

DOI = ''

trang = f'''<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>Thử màn xác nhận</title>
<style>{style}</style>
<style>
#bao{{position:fixed;left:6px;top:6px;z-index:999;background:#000d;color:#0f8;
  font:11px/1.45 ui-monospace,monospace;padding:8px 10px;border-radius:8px;
  white-space:pre;pointer-events:none;max-width:62vw}}
#gat{{position:fixed;right:6px;top:6px;z-index:999;display:flex;gap:6px}}
#gat button{{font-size:11px;padding:5px 9px;border-radius:7px;background:#2a3a44;color:#cfe}}
</style></head><body>
<div id="gat">
  <button onclick="dat('xn-task')">Xác nhận · task</button>
  <button onclick="dat('xn-nhip')">Xác nhận · cố định</button>
  <button onclick="dat('ds')">Danh sách</button>
</div>
<div id="bao"></div>

<div id="dw" class="hien nen-anh">
  <div id="dw-nen"><img src="/anh/dem-nai.webp" alt="" id="dw-nen-anh"></div>
  <div class="dw-top"><h2>💧 Deepwork</h2><button id="dw-nut-dong">✕</button></div>
  <div class="dw-phu" id="dw-phu">Sẵn sàng tập trung xử đẹp task này</div>
  <div class="dw-vong"><svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="46"
    fill="none" stroke="#ffffff22" stroke-width="4"/></svg>
    <div style="position:absolute;inset:0;display:flex;flex-direction:column;
      align-items:center;justify-content:center">
      <div style="font-size:1.6rem;font-weight:300">00:00</div>
      <div style="font-size:.62rem;letter-spacing:.14em">SẴN SÀNG</div></div>
  </div>
  <div class="dw-hom-nay"><span class="giot-so">14 phiên · 4.8h hôm nay</span></div>

  <div id="dw-chon" class="xacnhan">
    <div class="dw-chon-dau">
      <div class="dw-chon-nhan">Đích đến của phiên</div>
      <button class="dw-doi-viec" id="dw-doi-viec">Đổi việc khác</button>
    </div>
    <div class="dw-ds" id="dw-ds"></div>
    <div class="dw-uoc" id="dw-uoc">
      <label for="dw-uoc-o">Thời gian dự kiến</label>
      <input id="dw-uoc-o" value="45">
      <span class="dw-uoc-phu">không bắt buộc</span>
    </div>
    <div class="dw-nen-chon"><span class="nhan">Nền</span>
      <div class="ds" id="dw-nen-ds"></div></div>
    <button class="dw-nut" id="dw-batdau">▶  Bắt đầu ngay</button>
  </div>
</div>

<script>
const THE_TASK = {THE_TASK!r};
const THE_NHIP = {THE_NHIP!r};
const DOI      = {DOI!r};
document.getElementById('dw-nen-ds').innerHTML =
  Array.from({{length:5}}, () => '<button class="nen-o ve"><svg viewBox="0 0 24 24">'
    + '<path d="M2 19 9 8l4.2 6.4L16 11l6 8Z"/></svg></button>').join('');

function dat(che){{
  const chon = document.getElementById('dw-chon');
  const ds   = document.getElementById('dw-ds');
  if (che === 'ds'){{
    chon.classList.remove('xacnhan');
    ds.innerHTML = '<div class="dw-nhom">Task<span class="so">7</span></div>'
      + THE_TASK.repeat(7)
      + '<div class="dw-nhom">🔁 Việc cố định<span class="so">5</span></div>'
      + THE_NHIP.repeat(5);
  }} else {{
    chon.classList.add('xacnhan');
    ds.innerHTML = (che === 'xn-nhip' ? THE_NHIP : THE_TASK) + DOI;
  }}
  soi();
}}

function soi(){{
  const g = s => document.querySelector(s)?.getBoundingClientRect();
  const dw = g('#dw'), chon = g('#dw-chon'), dsB = g('.dw-ds'),
        uoc = g('.dw-uoc'), nen = g('.dw-nen-chon'), nut = g('#dw-batdau'),
        the = g('#dw-ds .dw-muc');
  const el = document.getElementById('dw');
  const tran = el.scrollHeight - el.clientHeight;
  const khoiTrong = the && dsB ? Math.round(dsB.bottom - the.bottom) : 0;
  const duoiMep = nut ? Math.round(dw.bottom - nut.bottom) : 0;
  document.getElementById('bao').textContent = [
    `khung        ${{innerWidth}}×${{innerHeight}}`,
    `#dw-chon     ${{Math.round(chon.height)}}px`,
    `.dw-ds       ${{Math.round(dsB.height)}}px`,
    `khí chết     ${{khoiTrong}}px  (dưới thẻ cuối, trong .dw-ds)`,
    `ô dự kiến    ${{uoc ? Math.round(uoc.height) : '—'}}px`,
    `hàng nền     ${{Math.round(nen.height)}}px`,
    `nút          ${{Math.round(nut.height)}}px`,
    `nút → mép    ${{duoiMep}}px`,
    `màn tràn     ${{tran}}px`,
    tran > 1 ? '❌ MÀN TRÀN — nút Bắt đầu tụt khỏi mép'
      : (khoiTrong > 40 ? `❌ KHÍ CHẾT ${{khoiTrong}}px giữa thẻ và ô dự kiến`
      : (duoiMep < 0 ? '❌ NÚT LỌT NGOÀI MÉP' : '✅ vừa khít, không khí chết')),
  ].join('\\n');
}}
addEventListener('resize', soi);
dat('xn-task');
</script></body></html>'''

out = GOC / 'public' / 'thu-manxacnhan.html'
out.write_text(trang)
print(f'✓ {out}  ({len(trang)/1024:.0f} KB)')
print('  mở http://localhost:8080/thu-manxacnhan.html · dọn: rm public/thu-manxacnhan.html')
