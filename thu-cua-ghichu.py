#!/usr/bin/env python3
"""Bản thử CỬA SỔ GHI CHÚ của cam kết — không cần đăng nhập.

Cùng mẹo với `thu-bocuc.py` / `thu-danhmuc.py`: rút NGUYÊN khối <style> và
NGUYÊN thẻ `#ck-cua` từ `public/index.html`, nên không soi nhầm bản cũ.

    python3 thu-cua-ghichu.py
    → http://localhost:8080/thu-cua-ghichu.html
    dọn: rm public/thu-cua-ghichu.html
"""
import re, pathlib

GOC = pathlib.Path(__file__).parent
src = (GOC / 'public' / 'index.html').read_text()
style = '\n'.join(m.group(1) for m in re.finditer(r'<style>(.*?)</style>', src, re.S))

a = src.index('<div class="cua-noi-nen"')
b = src.index('<!-- hộp hỏi kiểu Forest', a)
cua = src[a:b].strip()

MAU = [
    ('Đào sâu lại về nguyên nhân cốt lõi để tạo giải pháp cốt lõi',
     '📕 Cuối phiên · 12:29 · 12/8 · Tổng hợp giải pháp hoàn chỉnh cho đường ống…'),
    ('chờ push lên app để check',
     '📋 Ghi chú của việc · 09:01 · 12/8 · Nâng cấp tính năng ghi chú'),
    ('Đang đọc dở kiến tạo giải pháp V2',
     '📕 Cuối phiên · 16:35 · 11/8 · Hoàn thành công thức tính điểm ngày'),
    ('Ai đề xuất giải pháp thì người đó chịu trách nhiệm chạy thử trước',
     '📝 Ý trong phiên · 10:12 · 11/8'),
    ('Bảng đo phải nói được câu "tuần này khá hơn tuần trước ở chỗ nào"',
     '📕 Cuối phiên · 18:40 · 10/8 · Dựng bảng đo tuần'),
]

than = ''.join(f'{c}\n— {g}\n\n' for c, g in MAU).strip()

# Rút NGUYÊN hàm đóng cửa sổ ra ngoài f-string — biểu thức trong f-string không
# chứa được dấu gạch chéo ngược, mà regex thì đầy.
HAM_DONG = re.search(r'function ckCuaDong\(\)\{.*?\n\}', src, re.S).group(0)
THAN_MOT_MAU_CAT = '</div>\n'

loc = ''.join(f'<button class="gc-the{" chon" if i==0 else ""}">{t}</button>'
              for i, t in enumerate(
                  ['Tất cả','Triết lý','Nguyên lý','Framework','Tính năng',
                   'Câu hỏi','chưa xếp','✎ bộ thẻ']))

trang = f'''<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>Thử cửa sổ ghi chú</title>
<style>{style}</style>
<style>
body{{padding:14px;max-width:520px;margin:0 auto}}
#gat{{display:flex;gap:6px;margin-bottom:12px}}
#gat button{{font-size:11px;padding:6px 10px;border-radius:7px;background:#2a3a44;color:#cfe}}
#do{{margin-top:12px;font:11px/1.5 ui-monospace,monospace;color:var(--dim);white-space:pre-wrap}}
</style></head><body>

<div id="gat">
  <button onclick="mo()">Mở cửa sổ</button>
  <button onclick="ckCuaDong();do2()">Đóng</button>
  <button onclick="itMau()">Chỉ 1 mẩu</button>
</div>

<!-- thẻ cam kết giả, để thấy nó KHÔNG bị đẩy dài ra nữa -->
<div class="ck-the">
  <div class="ck-dau"><span class="o-so l5">5</span>
    <b>Tính năng Cam kết → Task V2 được nâng cấp hoàn chỉnh</b></div>
  <div class="ck-note" id="ck-note-O5"></div>
  <div class="ck-so">3/7 task xong · 4h20 tập trung</div>
</div>

{cua}
<div id="do"></div>

<script>
const THAN_DAY = `{than}`;
const THAN_IT  = `{than.split(THAN_MOT_MAU_CAT)[0]}</div>`;
const LOC = '';
let CK_NOTE_MO = null, CK_NOTE_SUA=null, CK_NOTE_XOA=null, CK_NOTE_THE=null, CK_BOTHE_TAO=null;

/* hàm THẬT, rút từ public/index.html */
{HAM_DONG}

function ve(than){{
  CK_NOTE_MO = 'O5';
  document.getElementById('ck-cua-ten').textContent =
    'Tính năng Cam kết → Task V2 được nâng cấp hoàn chỉnh';
  document.getElementById('ck-cua-than').innerHTML =
    '<textarea class="ck-doc" id="ck-doc-o">' + than + '</textarea>'
    + '<div class="ck-doc-chan"><span>Vừa trích thêm 5 mẩu mới</span>'
    + '<button class="nut-nho nut-xanh">Lưu</button></div>';
  document.getElementById('ck-cua').classList.add('hien');
  do2();
}}
const mo    = () => ve(THAN_DAY);
const itMau = () => ve(THAN_IT);

function do2(){{
  const n = document.getElementById('ck-cua');
  const w = n.querySelector('.ck-cua');
  const t = n.querySelector('.ck-cua-than');
  const mo_ = n.classList.contains('hien');
  document.getElementById('do').textContent = [
    `khung        ${{innerWidth}}×${{innerHeight}}`,
    `cửa sổ       ${{mo_ ? 'MỞ' : 'đóng'}}`,
    mo_ ? `cỡ cửa sổ    ${{Math.round(w.getBoundingClientRect().width)}}×${{Math.round(w.getBoundingClientRect().height)}}` : '',
    mo_ ? `thân cuộn    ${{t.scrollHeight - t.clientHeight}}px` : '',
    mo_ ? `tràn cửa sổ  ${{Math.round(w.getBoundingClientRect().bottom - innerHeight)}}px (âm = còn trong màn)` : '',
    `trang cuộn   ${{document.documentElement.scrollHeight - document.documentElement.clientHeight}}px`,
  ].filter(Boolean).join('\\n');
}}
addEventListener('resize', do2);
mo();
</script></body></html>'''

out = GOC / 'public' / 'thu-cua-ghichu.html'
out.write_text(trang)
print(f'✓ {out}  ({len(trang)/1024:.0f} KB)')
print('  http://localhost:8080/thu-cua-ghichu.html · dọn: rm public/thu-cua-ghichu.html')
