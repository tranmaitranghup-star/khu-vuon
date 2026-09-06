/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ DẢI PHIÊN THU NHỎ
   Chạy:  node thu-thu-nho-phien.js   (đứng ở thư mục làn hoặc tinh-thuc-app)

   Lỗ đã vá: đang chạy phiên deep work thì không vào được phần còn lại của app.
   `#dw` là lớp phủ `inset:0`, và lúc chạy thì nút ✕ bị ẩn cả bằng JS lẫn CSS;
   phiên lại sống trên máy chủ theo `nguoi_id` nên `dwKhoiPhuc` dựng lại đúng
   lớp phủ ấy ở mọi tab và mọi máy. Cách duy nhất để dùng app là kết thúc phiên.

   Bảy luật bộ thử này canh:
     ① thu nhỏ    → `#dw` mất `hien` nhưng GIỮ `chay` (không dựng lại bố cục)
     ② thu nhỏ    → dải hiện, `body.co-dai` bật để hai nút tròn nhường chỗ
     ③ mở lại     → lớp phủ về, dải tắt, `co-dai` tắt
     ④ hết phiên  → dải tự tắt và cờ trong localStorage bị xoá, kể cả khi
                    người gọi chỉ đặt `dwPhien = null` rồi gọi `dwVeDai()`
     ⑤ phiên mới  → KHÔNG thừa hưởng dạng thu nhỏ của phiên trước (so theo ID)
     ⑥ mã nguồn   → mọi chỗ đặt `dwPhien = null` đều gọi `dwVeDai()` ngay sau.
                    Đây là luật chống sót: thêm một đường kết thúc phiên mà
                    quên dòng ấy thì dải kẹt lại một mình trên màn hình.
     ⑦ mã nguồn   → khối `#dw-dai` nằm NGOÀI `#dw`. Nằm trong là nó `display:none`
                    theo lớp phủ đúng vào lúc cần hiện.
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');

let loi = 0, dat = 0;
const ok  = (t) => { dat++; console.log('  ✅ ' + t); };
const hong = (t, them) => { loi++; console.log('  ❌ ' + t + (them ? '\n     ' + them : '')); };
const la = (dieu, t, them) => dieu ? ok(t) : hong(t, them);

/* ── PHẦN 1 · luật đọc thẳng trên mã nguồn ────────────────────────────────── */
console.log('\nLuật trên mã nguồn');

const dongs = s.split('\n');
const sot = [];
dongs.forEach((d, i) => {
  if (!/\bdwPhien\s*=\s*null/.test(d)) return;
  if (d.trimStart().startsWith('let ')) return;          // dòng khai báo
  const sau = (dongs[i + 1] || '') + (dongs[i + 2] || '');
  if (!/dwVeDai\(\)/.test(sau)) sot.push(i + 1);
});
la(sot.length === 0, 'mọi chỗ `dwPhien = null` đều gọi `dwVeDai()` ngay sau',
   sot.length ? 'thiếu ở dòng: ' + sot.join(', ') : '');

const iDw   = s.indexOf('<div id="dw"');
const iDai  = s.indexOf('<div id="dw-dai"');
const iTab  = s.indexOf('<nav class="tabbar"');
la(iDai > 0 && iTab > 0 && iDai < iTab, 'khối `#dw-dai` có mặt, đứng trước thanh tab');
/* Đếm thật độ sâu thẻ để tìm chỗ `#dw` đóng lại — một ngưỡng khoảng cách bịa
   ra sẽ đúng hôm nay và sai vào ngày ai đó thêm mã vào giữa. */
const dongCua = (tu) => {
  let sau = 0;
  const re = /<div\b|<\/div>/g;
  re.lastIndex = tu;
  for (let m; (m = re.exec(s)); ){
    sau += m[0][1] === '/' ? -1 : 1;
    if (sau === 0) return re.lastIndex;
  }
  return -1;
};
la(iDw > 0 && iDai > dongCua(iDw), 'khối `#dw-dai` nằm ngoài lớp phủ `#dw`');

la(/#dw-dai\{[^}]*position:fixed/.test(s), 'dải neo `position:fixed`, không trôi theo trang');
la(/\['dw-dongho','dw-dongho2','dw-dai-gio'\]/.test(s), 'đồng hồ của dải ăn cùng nhịp với đồng hồ màn phiên');
la(/if \(DW_THU\) return;/.test(s), 'thu nhỏ thì `dwVe` ngủ phần vẽ nặng (cây · nai · vòng giờ)');
/* HÀNG NÚT MÀN CHẠY xếp lại 05/09 (Tracy: nút chữ lệch trái 27px vì bên phải
   nặng hơn). Cũ:  ⏸ [Kết thúc phiên] ⏹ ⌄  ·  nay:  ⌄ ⏸ [Kết thúc phiên] ___ ⏹

   Ca này từng ghim đúng MỘT con số — `#dw-nut-thu{order:2}` — và con số ấy nay
   thuộc về nút BỎ CUỘC, nên ca đỏ trong khi hàng nút vẫn đúng. Ghim cả bốn nấc
   thì nó nói được điều nó định nói: bốn thứ trên hàng đều có chỗ đứng khai rõ,
   và thứ tự giữa chúng là thứ tự Tracy chốt. Ô trống `::before` đứng giữa nút
   chữ và nút bỏ cuộc — nó là thứ kéo nút Kết thúc về đúng tâm hàng. */
{
  const nac = t => (s.match(new RegExp('#dw\\.chay ' + t + '\\{[^}]*order:(-?\\d+)')) || [])[1];
  const thu  = nac('#dw-nut-thu'), tam = nac('#dw-nut-tam');
  const trong = nac('\\.dw-dieu-khien\\.hien::before'), dung = nac('#dw-nut-dung');
  la(thu === '-2' && tam === '-1' && trong === '1' && dung === '2',
     'hàng nút màn chạy xếp đúng: ⌄ ⏸ [Kết thúc] ␣ ⏹',
     `thu ${thu} · tạm ${tam} · ô trống ${trong} · dừng ${dung}`);
}

/* ── PHẦN 2 · chạy thật cụm hàm, lát ra từ mã ─────────────────────────────── */
console.log('\nHành vi khi chạy');

const lat = (tu, den) => {
  const i = s.indexOf(tu);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + tu);
  const j = s.indexOf(den, i);
  if (j < 0) throw new Error('Không tìm thấy mốc kết: ' + den);
  return s.slice(i, j);
};
/* Lát cả dòng khai tên khoá localStorage từ mã THẬT: đổi tên khoá trong app mà
   bộ thử vẫn xanh là bộ thử đang canh một thứ không còn tồn tại. */
const nguon = lat('const DW_KHOA_THU', '\n')
            + '\n' + lat('/* ══ THU NHỎ PHIÊN', 'function dwTamToggle()');

/* DOM giả — chỉ đủ những gì cụm hàm chạm tới. */
const lop = () => {
  const t = new Set();
  return {
    add:    (...x) => x.forEach(v => t.add(v)),
    remove: (...x) => x.forEach(v => t.delete(v)),
    toggle: (v, b) => (b === undefined ? (t.has(v) ? t.delete(v) : t.add(v)) : (b ? t.add(v) : t.delete(v))),
    contains: v => t.has(v)
  };
};
const nut = (id) => ({id, classList: lop(), textContent: '', innerHTML: '', title: ''});
const O = {
  'dw':          nut('dw'),
  'dw-dai':      nut('dw-dai'),
  'dw-task':     nut('dw-task'),
  'dw-dai-viec': nut('dw-dai-viec'),
  'dw-dai-tam':  nut('dw-dai-tam')
};
const kho = {};
global.document = {
  getElementById: id => O[id] || null,
  body: {classList: lop()}
};
global.localStorage = {
  getItem: k => (k in kho ? kho[k] : null),
  setItem: (k, v) => { kho[k] = String(v); },
  removeItem: k => { delete kho[k]; }
};
global.DW_HINH_TAM  = '<svg id="tam"></svg>';
global.DW_HINH_CHAY = '<svg id="chay"></svg>';
let dwPhien = null, dwTamLuc = 0, DW_THU = false, veLai = 0;
global.dwVe = () => { veLai++; };

/* Cụm hàm đọc và ghi các biến trên, nên phải chạy trong CÙNG phạm vi này. */
eval(nguon);

O['dw-task'].textContent = 'Nâng cấp màn Dọn buổi sáng';
dwPhien = {id: 101};
O['dw'].classList.add('hien', 'chay');

dwThuNho();
la(!O['dw'].classList.contains('hien'), '① thu nhỏ thì lớp phủ ẩn đi');
la(O['dw'].classList.contains('chay'),  '① thu nhỏ vẫn GIỮ `chay` — mở lại không phải dựng lại bố cục');
la(O['dw-dai'].classList.contains('hien'), '② dải hiện ra');
la(document.body.classList.contains('co-dai'), '② `body.co-dai` bật để hai nút tròn nhường chỗ');
la(O['dw-dai-viec'].textContent === 'Nâng cấp màn Dọn buổi sáng', '② dải mang đúng tên việc');
la(kho['dw-thu-nho'] === '101', '② cờ thu nhỏ nhớ theo ID phiên');

dwTamLuc = Date.now(); dwVeDaiTam();
la(O['dw-dai'].classList.contains('nghi'), '⏸ trên dải: chấm đứng yên, nút đổi sang ▶');
la(O['dw-dai-tam'].innerHTML === '<svg id="chay"></svg>', '⏸ nút dải vẽ đúng hình chạy tiếp');
dwTamLuc = 0; dwVeDaiTam();
la(!O['dw-dai'].classList.contains('nghi'), '▶ chạy tiếp: dải trở lại nhịp thở');

veLai = 0;
dwMoLai();
la(O['dw'].classList.contains('hien'), '③ mở lại thì lớp phủ về');
la(!O['dw-dai'].classList.contains('hien'), '③ dải tắt');
la(!document.body.classList.contains('co-dai'), '③ `co-dai` tắt, nút tròn về chỗ cũ');
la(veLai === 1, '③ mở lại đánh thức đồng hồ ngay, không đợi giây kế tiếp');
la(!('dw-thu-nho' in kho), '③ cờ thu nhỏ được dọn');

/* ④ Phiên rời RAM: người gọi chỉ đặt `dwPhien = null` rồi gọi `dwVeDai()`. */
dwThuNho();
dwPhien = null;
dwVeDai();
la(!O['dw-dai'].classList.contains('hien'), '④ hết phiên thì dải tự tắt');
la(!document.body.classList.contains('co-dai'), '④ hết phiên thì `co-dai` tắt theo');
la(DW_THU === false, '④ cờ trong RAM tự về false');
la(!('dw-thu-nho' in kho), '④ cờ trong localStorage được dọn');

/* ⑤ Phiên MỚI không thừa hưởng dạng thu nhỏ của phiên trước. */
dwPhien = {id: 101};
dwThuNho();                       // phiên 101 đang thu nhỏ
dwPhien = {id: 202};              // đóng 101, mở 202
let thuTheoId = false;
try { thuTheoId = localStorage.getItem('dw-thu-nho') === String(dwPhien.id); } catch(e){}
la(thuTheoId === false, '⑤ phiên mới mở ra ở màn đầy, không thừa hưởng của phiên trước');

console.log('\n' + (loi ? `❌ ${loi} luật hỏng, ${dat} luật đạt` : `✅ trọn bộ ${dat} luật đạt`));
process.exit(loi ? 1 : 0);
