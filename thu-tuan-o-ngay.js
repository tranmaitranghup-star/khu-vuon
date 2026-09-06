/* THỬ: NẤC TUẦN TRÊN ĐIỆN THOẠI = BẢY Ô NGÀY (làn TW, 29/08)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy đưa ảnh TickTick: *"view tuần ở điện thoại hơi khó nhìn, có khi sửa sao
   chép giống tick tick view tuần đi"* → chọn bố cục **một cột** và **có ô tick**.

   Bài thử CẮT ĐÚNG CÁC KHỐI GỐC ra khỏi public/index.html rồi chạy trên DOM giả
   — không chép tay một dòng logic nào sang đây.

   Bốn ca đáng giá nhất:
     · BỐN ĐÍCH CHẠM trong một ô phải tách bạch. Thiếu một `stopPropagation` là
       tick một việc lại bật cửa Thông tin, hoặc chạm chip lại xếp việc vào ngày.
     · Ô TICK phải ghi đúng hai chiều: tick → 'Done', bỏ tick → 'Chua_lam'.
       Ghi sai chiều thì bỏ tick một việc lại đánh dấu nó xong lần nữa.
     · KHÔNG CẮT TRẦN số việc (khác nấc Tháng): ngày nào dài thì hiện đủ, vì đây
       chính là nấc người ta mở ra để xem tuần mình có gì.
     · VIỆC XONG LÙI MÀU, KHÔNG GẠCH CHỮ (luật 10, CAU-TRUC-APP.md Mục 7).

   Chạy:  node production/tinh-thuc-app/thu-tuan-o-ngay.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j);
}
const NGUON = [
  catKhoi('const gioChu = p =>',            '/* ── THỜI LƯỢNG DỰ KIẾN'),
  catKhoi('const d2s = d =>',               '/* ── LUẬT NGHỈ CN'),
  catKhoi('function ngayDep(ds){',          '/* Mỗi lời nhắn một dòng riêng'),
  catKhoi('function phutDeadline(s){',      '/* ── ĐÃ QUÁ GIỜ HẸN CHƯA'),
  catKhoi('function gioTuO(v){',            '/* ══════ NHẶT "TRONG BAO LÂU"'),
  catKhoi('const tlgHHMM = p =>',           '/* Chạm một ô giờ.'),
  catKhoi('function tlgKhoangTask(t){',     '/* Hai khối cùng khung giờ'),
  catKhoi('function tlGomNgay(phien, tasks){', 'const TL_THU ='),
  catKhoi('const TL_THU =',                 '/* Chip số cam kết'),
  catKhoi('function tlwThanTuan(moc, phien, tasks){', '/* Tick ngay trên lịch'),
  catKhoi('async function tlTick(id, xong){', '/* `tlThanNgay` — GỠ 29/08'),
].join('\n');

/* ── Cọc: đủ để các khối trên chạy, không hơn ─────────────────────────────── */
const COC = `
/* Thêm 04/09 (TRI-104): hai hàm suy màu, cờ riêng tư thắng màu sơn tay.
   Chép ĐÚNG bản trong app chứ không dựng bản giả trả về chuỗi rỗng — bản giả
   thì mọi ca dưới đây chạy qua một nhánh không tồn tại ngoài đời. */
/* Thêm 04/09 (TRI-104): lượt VẼ đi qua lcCuaNgayVe — cùng lcCuaNgay cộng cái
   nút tắt lịch cá nhân. Bài này không thử cái nút ấy, nên cho nó luôn BẬT.
   KHÔNG dùng dấu huyền ngược ở đây: cả khối là một chuỗi mẫu. */
let TL_HIEN_RIENG = true;
const lcCuaNgayVe = g => lcCuaNgay(g).filter(o => TL_HIEN_RIENG || !o.rieng);
const mauSuKien = l => (l && l.rieng_tu) ? 'tim'  : ((l && l.mau) || '');
const mauViec   = t => (t && t.rieng_tu) ? 'hong' : ((t && t.mau) || '');
const CO_GIO_SE = true;
let GHI = [];        /* [id, trang_thai] mỗi lần doiTrangThai được gọi */
let VE_LAI = 0;      /* số lần lamMoiCuaToi được gọi */
const chuSach = s => String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
function phutPhien(p){ return Number(p.phut || 0); }
async function doiTrangThai(id, tt){ GHI.push([id, tt]); }
async function lamMoiCuaToi(){ VE_LAI++; }
/* daTre sinh sau bài thử này: nó chỉ quyết một lớp CSS 'tre', không đổi con số
   nào mà các ca dưới đo. Cọc trả false để mọi ca đứng ở nhánh thường.
   KHÔNG dùng dấu huyền quanh tên hàm ở đây: cả khối COC là một chuỗi mẫu, một
   dấu huyền lạc vào là đóng chuỗi giữa chừng. Cùng họ với bẫy đã ghi 31/08. */
const daTre = () => false;
/* Dải buổi CẢ NGÀY: đường vẽ riêng, sinh sau bài thử này. Cọc rỗng — các ca
   dưới đo khối trên lưới giờ, không đo dải cả ngày. */
const LC_HIEN = [];
const lcDaiCuaKhung = () => [];
const lcCuaNgay = () => [];
`;

const ket = {};
new Function('ket', COC + NGUON + '\nObject.assign(ket, {tlwThanTuan, tlTick, GHI: () => GHI, VE_LAI: () => VE_LAI});')(ket);

/* ── Dữ liệu: tuần 25/08 (T2) → 31/08 (CN) ────────────────────────────────── */
const MOC = {tu:'2026-08-25', den:'2026-08-31'};
const TASKS = [
  {id:1, noi_dung:'Họp giao ban ROVA',  ngay:'2026-08-25', gio_start:'09:00', gio_end:'10:00', trang_thai:'Chua_lam'},
  {id:2, noi_dung:'Duyệt bảng giá',     ngay:'2026-08-25', trang_thai:'Done'},
  {id:3, noi_dung:'Gọi Lâm Saa SFVN',   ngay:'2026-08-26', gio_start:'11:00', gio_end:'11:30', trang_thai:'Doing'},
  {id:4, noi_dung:'Việc <script> & "x"',ngay:'2026-08-26', trang_thai:'Chua_lam'},
  /* Sáu việc trong một ngày — nấc Tháng cắt còn ba, nấc này phải hiện đủ sáu. */
  ...[1,2,3,4,5,6].map(n => ({id:100+n, noi_dung:'Việc số '+n, ngay:'2026-08-29', trang_thai:'Chua_lam'})),
  {id:9, noi_dung:'Việc đã huỷ',        ngay:'2026-08-27', trang_thai:'Da_huy'},
];
const PHIEN = [{id:7, bat_dau:'2026-08-25T09:00:00', phut:150, ket_qua:'song'}];

const html = ket.tlwThanTuan(MOC, PHIEN, TASKS);

/* ── Kiểm ───────────────────────────────────────────────────────────────── */
let hong = 0;
const ok = (dieu, ten) => {
  console.log((dieu ? '  ✓ ' : '  ✗ ') + ten);
  if (!dieu) hong++;
};
const dem = (chuoi, mau) => chuoi.split(mau).length - 1;

/* ── CẮT VÙNG: mốc cuối phải dò TỪ SAU mốc đầu ───────────────────────────────
   Bẫy đã cắn 05/09 (TRI-132). Mười hai chỗ trong bài này từng cắt bằng
   `SRC.slice(SRC.indexOf(A), SRC.indexOf(B))` — mốc cuối dò từ ĐẦU TỆP, không
   phải từ sau mốc đầu. Hàm `catKhoi` ngay trên đã làm đúng (`indexOf(cuoi, i)`)
   từ đầu; mười hai chỗ viết thẳng trong thân bài thì không.

   Khi commit 7cf576e (TRI-119, 05/09) thêm bản THỨ HAI của chú thích
   `/* Vạch "bây giờ" chỉ vẽ khi` vào một hàm đứng TRƯỚC `veKhoi`, `indexOf` trả
   về bản sớm, mốc cuối rơi trước mốc đầu, và `slice` trả về CHUỖI RỖNG. Vùng
   rỗng hỏng theo CẢ HAI đường cùng lúc — đó là chỗ độc của nó:
     · 5 ca ĐỎ OAN  — mọi `includes` trên chuỗi rỗng đều sai;
     · 1 ca XANH OAN — `!khoiPhien.includes('checkbox')` trên chuỗi rỗng luôn đúng.
   Mã app không sai một dòng nào; cắt đúng vùng thì cả sáu ca đều đạt.

   Hai luật của hàm này:
   ① Dò mốc cuối từ sau mốc đầu, nên một bản sao đứng trước không cướp được chỗ.
   ② Mốc long ra thì KÊU THÀNH MỘT CA ĐỎ CÓ TÊN — không ném lỗi, vì ném là giết
      cả bài và kho này xếp bài chết nguy hơn ca đỏ; cũng không lặng lẽ trả rác,
      vì rác thì vừa đỏ oan vừa xanh oan như trên. */
function catVung(ten, dau, cuoi){
  const i = SRC.indexOf(dau);
  if (i < 0){
    ok(false, `mốc ĐẦU của vùng «${ten}» không còn trong app: ${JSON.stringify(dau)}`);
    return '';
  }
  const j = SRC.indexOf(cuoi, i + dau.length);
  if (j < 0){
    ok(false, `mốc CUỐI của vùng «${ten}» không còn SAU mốc đầu: ${JSON.stringify(cuoi)}`);
    return '';
  }
  return SRC.slice(i, j);
}

/* Cắt một vùng CON bên trong vùng vừa cắt. Cùng hai luật trên. Vùng cha rỗng
   thì im lặng trả về rỗng — nó đã kêu một tiếng rồi, kêu tiếp chỉ là tiếng vọng. */
function catCon(vung, ten, dau, cuoi){
  if (!vung) return '';
  const i = vung.indexOf(dau);
  if (i < 0){
    ok(false, `mốc ĐẦU của vùng «${ten}» không còn: ${JSON.stringify(dau)}`);
    return '';
  }
  if (cuoi === undefined) return vung.slice(i);
  const j = vung.indexOf(cuoi, i + dau.length);
  if (j < 0){
    ok(false, `mốc CUỐI của vùng «${ten}» không còn SAU mốc đầu: ${JSON.stringify(cuoi)}`);
    return '';
  }
  return vung.slice(i, j);
}

console.log('\nBẢY Ô NGÀY');
ok(dem(html, 'class="tlw-o') === 7, 'đúng bảy ô, không sáu không tám');
ok(/tlw-thu">T2<\/span><span class="tlw-so">25</.test(html), 'ô đầu là T2 25 — thứ đứng trước số, đúng lối TickTick');
ok(/tlw-thu">CN<\/span><span class="tlw-so">31</.test(html), 'ô cuối là CN 31');
ok(html.indexOf('>25<') < html.indexOf('>31<'), 'bảy ngày xếp tăng dần');

console.log('\nVIỆC RƠI ĐÚNG Ô');
const oNgay = g => {
  const i = html.indexOf(`tlkDat('${g}')`);
  const j = html.indexOf('tlkDat(', i + 10);
  return html.slice(i, j < 0 ? html.length : j);
};
ok(oNgay('2026-08-25').includes('Họp giao ban ROVA'), 'việc thứ Hai nằm trong ô thứ Hai');
ok(!oNgay('2026-08-26').includes('Họp giao ban ROVA'), 'và không lọt sang ô thứ Ba');
ok(dem(oNgay('2026-08-29'), 'tlw-viec') === 6, 'ngày sáu việc hiện đủ sáu — KHÔNG cắt trần như nấc Tháng');
ok(!html.includes('Việc đã huỷ'), 'việc đã huỷ không hiện');
ok(oNgay('2026-08-31').includes('class="tlw-ds"></div>'), 'ngày trống để TRẮNG, không một chữ nào');

console.log('\nBỐN ĐÍCH CHẠM TÁCH BẠCH');
const chip = html.slice(html.indexOf('<div class="tlw-viec'), html.indexOf('</div>', html.indexOf('<div class="tlw-viec')));
ok(/tlw-dau" onclick="event\.stopPropagation\(\);TL_NGAY=/.test(html), 'đầu ô: chặn nổi bọt rồi sang nấc Ngày');
ok(/class="tlw-o[^"]*" onclick="tlkDat\('2026-08-25'\)/.test(html), 'thân ô: gọi tlkDat với đúng ngày của nó');
ok(/onclick="event\.stopPropagation\(\);tvMo\(1\)"/.test(html), 'chip việc: chặn nổi bọt rồi mở cửa Thông tin');
ok(/type="checkbox"[\s\S]{0,120}onclick="event\.stopPropagation\(\)"/.test(html),
   'ô tick: chặn nổi bọt — thiếu dòng này thì tick một việc lại bật cửa Thông tin');

console.log('\nÔ TICK');
ok(/type="checkbox" checked[\s\S]{0,200}Duyệt bảng giá/.test(html), 'việc Done hiện ô đã tick sẵn');
ok(!/type="checkbox" checked[\s\S]{0,200}Họp giao ban/.test(html), 'việc chưa xong thì ô trống');
ok(html.includes('tlTick(1, this.checked)'), 'ô tick gọi tlTick với id của chính việc đó');

console.log('\nÔ TICK GHI ĐÚNG HAI CHIỀU');
(async () => {
  await ket.tlTick(1, true);
  await ket.tlTick(2, false);
  const ghi = ket.GHI();
  ok(JSON.stringify(ghi[0]) === '[1,"Done"]',      'tick → ghi Done');
  ok(JSON.stringify(ghi[1]) === '[2,"Chua_lam"]',  'bỏ tick → ghi Chua_lam, KHÔNG ghi Done lần nữa');
  ok(ket.VE_LAI() === 2, 'mỗi lần tick đều vẽ lại lịch — không thì dấu tick nhảy về chỗ cũ');

  console.log('\nMÀU VÀ GIỜ');
  ok(/tlw-viec xong/.test(html), 'việc xong mang lớp .xong');
  ok(/tlw-viec[^"]*s-Doing/.test(html), 'việc đang làm mang lớp trạng thái');
  ok(html.includes('<span class="gio">09:00</span>'), 'việc có hẹn giờ hiện giờ bắt đầu');
  ok(!/Duyệt bảng giá[\s\S]{0,80}<span class="gio">/.test(html), 'việc không hẹn giờ thì không hiện giờ');
  ok(html.includes('<i class="tlw-dw">2.5h</i>'), 'ngày có phiên deepwork hiện số giờ');

  console.log('\nCHỮ AN TOÀN');
  ok(html.includes('Việc &lt;script> &amp; &quot;x&quot;'),
     'tên việc: "<" và dấu nháy kép được thoát (">" thì không, và đó là đúng — xem chú thích chuSach)');
  ok(!/<script>/.test(html), 'không một thẻ script nào lọt vào HTML sinh ra');

  console.log('\nLUẬT TRÌNH BÀY (soi thẳng khối kiểu dáng trong index.html)');
  const css = catVung('kiểu dáng .tlw', '.tlw{', '/* ── KHO VIỆC');
  ok(!css.includes('line-through'), 'việc xong LÙI MÀU, không gạch chữ (luật 10)');
  ok(/\.tlw\{[^}]*grid-template-columns:1fr/.test(css), 'một cột dọc — bố cục B Tracy chọn');
  ok(css.includes('.tlw-viec input[type=checkbox]'), 'ô tick đi theo luật gốc, không tự khai cỡ màu (luật ô tick một kiểu)');

  /* Tracy nhắc giữa lúc làm: *"ê chỉ sao chép ở điện thoại thôi nhé chứ view
     tuần ở máy tính giữ nguyên đó"*. Bốn ca dưới khoá câu ấy lại trong mã, để
     một phiên sau dọn dẹp `veTimeline` không lỡ tay gỡ mất bản máy tính. */
  console.log('\nNGƯỠNG 720px — MÁY TÍNH GIỮ NGUYÊN LƯỚI GIỜ');
  const veTL = catVung('veTimeline', 'async function veTimeline(){',
                       '/* ── Nhãn điều hướng');
  const iTuan = veTL.indexOf("if (TL_KHUNG === 'tuan')");
  const iNguong = veTL.indexOf('window.innerWidth < 720');
  const iLuoi = veTL.indexOf('tlgThanTuan(');
  ok(iNguong > iTuan && iNguong > 0, 'nhánh nấc Tuần có rẽ theo bề ngang màn ở 720px');
  ok(veTL.indexOf('tlwThanTuan(') > iNguong, 'dưới 720px mới vẽ bảy ô ngày');
  ok(iLuoi > iNguong, 'lưới giờ `tlgThanTuan` VẪN được gọi — đó là đường của máy tính');
  ok(veTL.includes('tlgThanNgay('), 'nấc Ngày vẫn là lưới giờ ở mọi bề ngang màn');

  /* Tracy chốt tiếp: *"nút tick bổ sung ở cả chế độ ngày và tuần trên máy tính
     nữa"*. Khối trên lưới giờ do `veKhoi` sinh, nằm sâu trong `tlgThanLuoi` nên
     soi thẳng mã nguồn rẻ hơn dựng đủ cọc để chạy nó. */
  console.log('\nÔ TICK TRÊN LƯỚI GIỜ (nấc Ngày + nấc Tuần máy tính)');
  const veKhoi = catVung('veKhoi', '  const veKhoi = k => {',
                         '/* Vạch "bây giờ" chỉ vẽ khi');
  const khoiViec  = catCon(veKhoi, 'veKhoi › khối VIỆC',  'const nam = k.id');
  const khoiPhien = catCon(veKhoi, 'veKhoi › khối PHIÊN', 'if (k.phien)', 'const nam = k.id');
  ok(khoiViec.includes('<input type="checkbox"'), 'khối việc có ô tick');
  ok(khoiViec.includes('tlTick(${k.id}, this.checked)'), 'ô tick gọi tlTick với id của việc đó');
  ok(/onpointerdown="event\.stopPropagation\(\)"/.test(khoiViec),
     'ô tick chặn pointerdown — thiếu nó thì chạm tick lại KHỞI ĐỘNG một cú kéo khối');
  ok(/onclick="event\.stopPropagation\(\)"/.test(khoiViec),
     'ô tick chặn click — thiếu nó thì tick xong lại bật cửa Thông tin việc');
  ok(!khoiPhien.includes('checkbox'),
     'khối PHIÊN deep work KHÔNG có ô tick — giờ của nó do máy chủ đóng dấu, không phải việc để tick');
  ok(khoiViec.includes('class="tlg-nd"') && khoiPhien.includes('class="tlg-nd"'),
     'cả hai loại khối đều bọc nội dung trong .tlg-nd, nên tên và giờ vẫn xếp chồng như cũ');

  const cssG = catVung('kiểu dáng ô tick trên lưới giờ', '.tlg-viec > input[type=checkbox]', '.tlg-hang{');
  const cssG2 = catVung('kiểu dáng .tlg-viec', '.tlg-viec{position:absolute', '.tlg-viec:not([onclick])');
  ok(/z-index:3/.test(cssG), 'ô tick nổi trên tay nắm kéo (z-index 3 > 2)');
  ok(cssG.includes('.tlg-viec.ti > input[type=checkbox]{display:none}'),
     'giữ chắn cho khối dưới nửa giờ (nay là mã chết vì veKhoi kẹp sàn 0.58 giờ)');
  ok(/Math\.max\(cao\(k\.den\) - t, 0\.58\)/.test(SRC),
     'sàn 0.58 giờ vẫn còn — nếu ai gỡ nó thì luật .ti ở trên mới bắt đầu có việc');
  ok(!/tlg-viec\.chat|' chat'/.test(SRC),
     'không còn ngưỡng chiều cao nào giấu ô tick — lớp .tlg-viec.chat đã gỡ hẳn');
  ok(/min-height:24px/.test(cssG2),
     'sàn khối 24px — đúng ngưỡng vùng chạm WCAG 2.5.8, và đủ cho ô tick 16px');
  ok(/\.tlg-viec, \.tlw-viec\{--o-tick:16px\}/.test(SRC),
     'cụm lịch thu ô tick bằng MỘT dòng biến, không khai lại cỡ/màu (luật ô tick một kiểu, 27/08)');
  ok(/width:var\(--o-tick,22px\);height:var\(--o-tick,22px\)/.test(SRC),
     'luật gốc input[type=checkbox] nhận biến, mặc định vẫn 22px cho phần còn lại của app');
  ok(/border-radius:calc\(var\(--o-tick,22px\) \* \.32\)/.test(SRC),
     'bo góc tính theo tỉ lệ nên tự đúng ở mọi cỡ, không phải canh tay');
  ok(!/\.nac-ngay .tlg-viec > input\[type=checkbox\]\{[^}]*display:block/.test(cssG),
     'ô tick KHÔNG còn khoá riêng cho nấc Ngày — Tracy đã mở sang cả nấc Tuần');

  /* Tracy chốt 29/08: *"kho việc cho lên dưới chữ cam kết luôn"*. Đây là lần đổi
     chỗ thứ ba của cái kho, nên khoá thứ tự lại bằng một ca thử thay vì bằng trí
     nhớ của phiên sau. */
  console.log('\nCHỖ ĐỨNG CỦA KHO VIỆC');
  const tmpl = catVung('khuôn lưới giờ', '  return `<div class="tlg${laNgay',
                       '/* Kho việc: một DẢI GẤP');
  const kCamKet = tmpl.indexOf('tlgDaiCaNgay(');
  const kKho    = tmpl.indexOf('tlgDaiKho(');
  const kLuoi   = tmpl.indexOf('<div class="tlg-than">');
  ok(kCamKet < kKho, 'kho việc đứng SAU dải Dự án · Cam kết');
  ok(kKho < kLuoi,   'và TRƯỚC lưới giờ — không còn nằm dưới đáy vùng cuộn 24 giờ');

  /* Hai lỗi Tracy bắt được khi dùng thật, 29/08. */
  console.log('\nHAI LỖI TRACY BÁO');
  /* Mốc đầu phải kèm dòng `.tlg-nam` bên trong: `@media (hover:none){` có HAI
     bản, và bản sớm là một luật MỘT DÒNG về `.tlg-ca` ở tít trên. Lấy phải bản
     ấy thì vùng phình từ 585 lên 40.486 ký tự. Ca phủ định dưới đây vẫn xanh —
     nhưng sẽ ĐỎ OAN vào ngày ai đó thêm một `padding-top:5px` chính đáng ở bất
     kỳ đâu trong 600 dòng nằm giữa. (TRI-132) */
  const mediaCU = catVung('@media (hover:none) của tay nắm kéo',
                          '@media (hover:none){\n  .tlg-nam{height:14px}',
                          '/* Đang kéo: nổi lên trên');
  ok(!/padding-top:5px/.test(mediaCU),
     'luật chữ-né-vạch KHÔNG nằm trong @media (hover:none) — chồng nhau xảy ra ở mọi thiết bị');
  ok(/\.tlg-nd\{[^}]*padding-top:5px\}/s.test(SRC),
     'chữ né vạch tay nắm bằng một luật CHUNG: vạch ở y 2–5px, chữ vốn bắt đầu ở y=3px');
  const cuon = catVung('tlgCuonToiGio', 'function tlgCuonToiGio(){', 'function tlgGapKho(){');
  ok((cuon.match(/than\.scrollTop = TLG_CUON/g) || []).length === 2,
     'cả hai nhánh lui của tlgCuonToiGio đều trả lại chỗ đứng, không để nguyên số 0 của phần tử vừa sinh');
  const veTL2 = catVung('đầu veTimeline', 'async function veTimeline(){', 'const moc = tlMoc();');
  ok(/TLG_CUON = thanCu\.scrollTop/.test(veTL2),
     'veTimeline đo chỗ đứng NGAY TRƯỚC khi thay innerHTML — sau đó thì phần tử giữ nó đã mất');

  /* Ca này khoá đúng chỗ vết gạch sống sót qua BA lần vá: một luật trong
     `@media (min-width:720px)` bật lại dòng giờ cho mọi khối, cùng độ đặc hiệu
     với luật ẩn nhưng đứng sau nên nó thắng. Dưới 720px khối media không áp —
     nên điện thoại sạch còn máy tính dính, đúng như Tracy tả. */
  /* Ca sót thứ hai: khối KHÔNG thấp nhưng tên hai dòng, cụm chữ cao hơn khối. */
  console.log('\nSỐ DÒNG TÊN RÀNG THEO CHIỀU CAO KHỐI');
  ok(/\(h < 1\.35 \? ' vua' : ''\)/.test(SRC),
     'veKhoi gán .vua cho khối chưa đủ cao để chứa hai dòng tên cộng dòng giờ');
  ok(/\.tlg-viec\.vua \.ten\{-webkit-line-clamp:1\}/.test(SRC),
     'khối .vua chỉ một dòng tên — 2 dòng + giờ + đệm là 50px, quá khổ khối một giờ (46px trên máy tính)');

  console.log('\nLUẬT ẨN GIỜ Ở KHỐI THẤP — CÒN SỐNG TRÊN MÁY TÍNH');
  /* Mốc cuối cũ `.tlg-than{max-height:min(70vh` đã BIẾN MẤT khỏi app. `indexOf`
     trả về −1, và `slice(i, −1)` ôm 1,83 TRIỆU ký tự — gần trọn tệp. Ba ca dưới
     đây vì thế thôi soi trong khối 720px mà quét cả app, rồi xanh vì lẽ đó chứ
     không vì luật còn đúng. (TRI-132) */
  const media720 = catVung('@media (min-width:720px)', '  .tlg{--tlg-h:46px',
                           '/* ══════ MÀN RỘNG');
  ok(/\.tlg-viec \.gio\{display:block\}/.test(media720),
     'từ 720px vẫn bật dòng giờ cho khối thường');
  ok(/\.tlg-viec\.nho \.gio\{display:none\}/.test(media720),
     'NHƯNG khối thấp vẫn ẩn — thiếu dòng này thì máy tính xén ngang dòng giờ, điện thoại thì không');
  ok(media720.indexOf('.tlg-viec .gio{display:block}') < media720.indexOf('.tlg-viec.nho .gio{display:none}'),
     'luật ẩn đứng SAU luật bật — cùng độ đặc hiệu (0,2,0) thì thứ tự quyết định');

  console.log('\nCHỮ CẮT THEO DÒNG, KHÔNG THEO PIXEL');
  const cssTen2 = catVung('.tlg-viec .ten', '\n.tlg-viec .ten{display:block', '.tlg-viec .gio{display:none');
  ok(/-webkit-line-clamp:2/.test(cssTen2),
     'tên việc cắt ở ranh giới DÒNG — mép cắt theo pixel để lộ nửa thân dòng cuối, đọc ra thành vệt gạch');
  ok(!/word-break:break-word;max-height/.test(cssTen2),
     'trần theo pixel đã gỡ: nó không liên quan gì tới chiều cao một dòng chữ');
  ok(/\.tlg-viec\.nho \.ten\{-webkit-line-clamp:1\}/.test(SRC),
     'khối thấp chỉ một dòng tên');
  ok(/\.tlg\.nac-ngay \.tlg-viec\.nho \.gio\{display:none\}/.test(SRC),
     'nấc Ngày trả lại luật ẩn giờ ở khối thấp — luật .nac-ngay (0,3,0) từng đè mất luật .nho (0,2,0)');

  console.log('\nCHỮ CẮT THẲNG, KHÔNG MẶT NẠ');
  const cssTen = catVung('.tlg-viec .ten', '\n.tlg-viec .ten{display:block', '.tlg-viec .gio{display:none');
  ok(!/mask-image/.test(cssTen),
     'mặt nạ mờ dần đã gỡ — mọi ngưỡng tính theo 100% đều rơi vào dòng cuối ở một số dòng nào đó, tức chỉ dời chỗ vết gạch');
  ok(/max-height:calc\(100% - 7px\)/.test(cssTen),
     'vẫn giữ trần chiều cao: chữ cắt thẳng khi tràn, đúng luật nấc Tháng đã chốt');

  console.log(hong ? `\n✗ ${hong} ca hỏng\n` : '\n✓ Tất cả ca đều qua\n');
  process.exit(hong ? 1 : 0);
})();
