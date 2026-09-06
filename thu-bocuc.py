#!/usr/bin/env python3
"""Sinh trang soi BỐ CỤC màn đang chạy của deepwork.

Chạy:  python3 thu-bocuc.py [số-bước]     rồi mở http://localhost:8080/thu-bocuc.html
Dọn :  rm public/thu-bocuc.html

VÌ SAO CÓ FILE NÀY. Màn đang chạy chỉ hiện ra sau khi đăng nhập và bấm vào một
phiên thật, nên muốn soi bố cục thì phải ngồi chờ. Trang này dựng lại đúng màn
ấy bằng dữ liệu giả, và quan trọng hơn: nó **nhúng nguyên khối CSS thật** rút
thẳng từ `index.html`, nên không bao giờ soi nhầm một bản CSS đã cũ.

VÌ SAO KHÔNG ĐỂ SẴN FILE HTML. Khối CSS nặng 174 KB; để sẵn trong `public/` là
bản phát hành gánh thêm chừng ấy cho một trang không ai dùng. Sinh ra lúc cần,
xoá đi lúc xong.

Trang tự đo và tự phán: nó lấy khung của cụm trên · vòng đồng hồ · khối chữ
dưới rồi báo có khối nào đè khối nào không. Đây là lỗi Tracy soi ra 13/08 trên
màn 595×750 — cả hai đứa con của cột khung cảnh đều khai `flex:none` nên khi
cộng lại quá chỗ thì phần thừa tràn xuống, dòng đo và cái chuông nằm lọt trong
vòng đồng hồ.

CÁC CA CẦN SOI LẠI mỗi lần đụng vào bố cục màn chạy:
  · 595×750 (khổ Tracy báo lỗi) · 375×812 điện thoại · 1440×820 máy tính
  · 390×600 màn thấp nhất — ở đây vòng chạm sàn 132px, quy trình cuộn trong
  · quy trình 2 · 6 · 15 bước
  · mẫu Cảnh vẽ: bỏ lớp `nen-anh` khỏi `#dw`, vòng phải về cỡ hai dòng chữ
"""

import re
import os
import sys

THU_MUC = os.path.dirname(os.path.abspath(__file__))
NGUON = os.path.join(THU_MUC, 'public', 'index.html')
DICH = os.path.join(THU_MUC, 'public', 'thu-bocuc.html')


def main():
    so_buoc = int(sys.argv[1]) if len(sys.argv) > 1 else 6
    h = open(NGUON, encoding='utf-8').read()
    css = '\n'.join(m.group(1) for m in re.finditer(r'<style>(.*?)</style>', h, re.S))

    buoc = ''.join(
        f'<label class="qtp-dong xong"><input type="checkbox" checked>'
        f'<span>Bước {i} của quy trình</span></label>'
        for i in range(1, so_buoc + 1))

    open(DICH, 'w', encoding='utf-8').write(TRANG.replace('{{CSS}}', css)
                                            .replace('{{BUOC}}', buoc)
                                            .replace('{{N}}', str(so_buoc)))
    print(f'✓ public/thu-bocuc.html — {so_buoc} bước, CSS {len(css):,} ký tự')
    print('  mở  http://localhost:8080/thu-bocuc.html')
    print('  dọn rm public/thu-bocuc.html')


TRANG = '''<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Soi bố cục màn đang chạy</title>
<style>{{CSS}}</style>
<style>
/* chỉ của phép soi: vạch mép từng khối để thấy chỗ đè nhau */
.soi #dw-canh-khu{outline:1px dashed rgba(255,90,90,.85);outline-offset:-1px}
.soi .tren{outline:1px dashed rgba(95,214,184,.9)}
.soi .dw-vong3{outline:1px dashed rgba(255,200,60,.9)}
.soi #dw-dang{outline:1px dashed rgba(120,170,255,.95)}
#bao{position:fixed;left:6px;top:6px;z-index:99;font:11px/1.55 system-ui;
  background:rgba(0,0,0,.78);color:#eef7f5;padding:6px 9px;border-radius:7px;
  white-space:pre}
</style></head><body class="soi">
<div id="dw" class="hien chay nen-anh co-nai" style="display:flex">
  <div id="dw-nen"><picture>
    <source type="image/webp" media="(min-aspect-ratio: 1/1)" srcset="/anh/dem-nai-ngang.webp">
    <img src="/anh/dem-nai.webp" alt=""></picture>
    <div id="dw-vuon"></div><div id="dw-nai" aria-hidden="true"></div>
  </div>
  <div id="dw-den" aria-hidden="true"></div>
  <div id="dw-canh-khu">
    <div class="tren">
      <div class="dw-task-dang">Check UNC tài chính hàng ngày</div>
      <div class="dw-o-dang"><span style="color:var(--dim2)">🔁 việc cố định</span></div>
      <div id="dw-qt-phien">
        <div class="qtp-dau">Quy trình <span class="qtp-dem du">{{N}}/{{N}}</span></div>
        {{BUOC}}
      </div>
    </div>
    <div class="dw-vong3" id="dw-vong3">
      <svg viewBox="0 0 240 240" aria-hidden="true">
        <circle class="ray r1" cx="120" cy="120" r="104" pathLength="100"/>
        <circle class="chay v1" cx="120" cy="120" r="104" pathLength="100"
                style="stroke-dasharray:18 100"/>
        <circle class="ray r2 an" cx="120" cy="120" r="87" pathLength="100"/>
        <circle class="chay v2 an" cx="120" cy="120" r="87" pathLength="100"/>
        <circle class="ray r3 an" cx="120" cy="120" r="71" pathLength="100"/>
        <circle class="chay v3 an" cx="120" cy="120" r="71" pathLength="100"/>
      </svg>
      <div class="giua">
        <div class="dw-dongho-lon">00:15</div>
        <div class="dw-nhan-lon">đang tập trung</div>
      </div>
    </div>
  </div>
  <div id="dw-dang">
    <div class="dw-do">14 phiên · 4.1h hôm nay</div>
    <div class="dw-chuong-khu">
      <button class="dw-chuong-nut"><span class="bieu"><svg viewBox="0 0 24 24">
        <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
        <path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg></span></button>
      <div class="dw-chuong-ds"></div>
    </div>
    <div class="dw-hang"><button class="dw-ketthuc">Kết thúc phiên</button></div>
    <div class="dw-canh">Huỷ (15)</div>
  </div>
</div>
<div id="bao"></div>
<script>
function khung(el){ const r = el.getBoundingClientRect();
  return [Math.round(r.top), Math.round(r.bottom)]; }
function soi(){
  const T = khung(document.querySelector('.tren')),
        V = khung(document.querySelector('.dw-vong3')),
        D = khung(document.getElementById('dw-dang')),
        K = khung(document.getElementById('dw-canh-khu')),
        q = document.getElementById('dw-qt-phien');
  const cuon = q.scrollHeight - q.clientHeight;
  const de = [];
  if (V[1] > D[0])   de.push('❌ VÒNG đè KHỐI CHỮ ' + (V[1] - D[0]) + 'px');
  if (T[1] > V[0])   de.push('❌ CỤM TRÊN đè VÒNG ' + (T[1] - V[0]) + 'px');
  if (K[1] > D[0]+1) de.push('❌ KHUNG CẢNH tràn ' + (K[1] - D[0]) + 'px');
  document.getElementById('bao').textContent =
      `khung ${innerWidth}×${innerHeight}\\n`
    + `cụm trên   ${T[0]} → ${T[1]}  (cao ${T[1]-T[0]})\\n`
    + `vòng       ${V[0]} → ${V[1]}  (cao ${V[1]-V[0]})\\n`
    + `khối chữ   ${D[0]} → ${D[1]}\\n`
    + `quy trình  cao ${q.clientHeight}, ${cuon > 4 ? 'CÒN CUỘN '+cuon+'px' : 'hiện đủ'}\\n`
    + (de.length ? de.join('\\n') : '✅ không khối nào đè khối nào');
}
soi(); addEventListener('resize', soi);
</script></body></html>'''


if __name__ == '__main__':
    main()
