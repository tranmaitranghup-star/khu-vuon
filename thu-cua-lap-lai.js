/* Bộ thử cho CỬA LẶP LẠI TUỲ CHỈNH (TRI-66). Cắt khối luật lặp ra khỏi
   index.html rồi chạy khô với một `document` giả — không trình duyệt, không
   máy chủ. Chạy: node thu-cua-lap-lai.js */
const fs = require('fs');
const html = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
function vung(tu, den){
  const i = html.indexOf(tu), j = html.indexOf(den, i);
  if (i < 0 || j < 0) throw new Error('không tìm thấy mốc cắt: ' + tu.slice(0, 40));
  return html.slice(i, j);
}
const nen = `
  const LC_TEN_THU = ['CN','T2','T3','T4','T5','T6','T7'];
  const d2s = d => \`\${d.getFullYear()}-\${String(d.getMonth()+1).padStart(2,'0')}-\${String(d.getDate()).padStart(2,'0')}\`;
  const homNay = () => O_NGAY.value;
  const chuSach = x => String(x);
  const lcVeRanh = () => {};
  let CO_TUAN_THANG = true, CO_BUOC_LAP = true;
  let LC_THU = [], LC_TUAN = [];
  const O_NGAY = {value: '2026-09-03'};
  const O_LAP  = {innerHTML: ''};
  const O_THAN = {innerHTML: ''};
  const O_THU  = {innerHTML: '', hidden: false};
  const document = {getElementById: id =>
    id === 'lc-tu' ? O_NGAY : id === 'lc-lap' ? O_LAP :
    id === 'lc-tc-than' ? O_THAN : id === 'lc-thu-o' ? O_THU :
    id === 'lc-tc-cua' ? {classList: {add(){}, remove(){}}} : null};
`;
const ma = nen
  + vung('/* BƯỚC NHẢY —', '/* GIỜ THẬT CỦA MỘT LƯỢT')
  + vung('const LC_THU_DAI', '/* ── MỜI NGƯỜI ĐÍCH DANH')
  + `\nreturn {O_NGAY, O_LAP, O_THAN, O_THU,
      dat: (t, u) => { LC_THU = t; LC_TUAN = u; },
      lcLuatMoi, lcLuatTu, lcDongTu, lcChotHan, lcNacDs, lcNacCua, lcNhanDay,
      veNac: L => { LC_LUAT = L; lcVeNac(); return O_LAP.innerHTML; },
      veThu: L => { LC_LUAT = L; lcVeNac(); return O_THU; },
      batThu: t => { lcBatThu(t); return {lap: O_LAP.innerHTML, thu: LC_THU.slice(),
                                          an: O_THU.hidden, nut: O_THU.innerHTML}; },
      veTc:  L => { LC_TC = L; LC_TC_THU = LC_THU.slice(); LC_TC_TUAN = LC_TUAN.slice();
                    lcVeTc(); return O_THAN.innerHTML; },
      moTc:  L => { LC_LUAT = L; lcMoTuyChinh(); return LC_TC; },
      lcSauLuot, lcVeSauLuot,
      co:    (tt, bl) => { CO_TUAN_THANG = tt; CO_BUOC_LAP = bl; }};`;
const A = new Function(ma)();

let dat = 0, truot = 0;
function ok(ten, dieu, them){
  console.log((dieu ? '  ✅ ' : '  ❌ ') + ten);
  if (!dieu && them) console.log('     ' + them);
  dieu ? dat++ : truot++;
}

console.log('\n═══ NẤC SINH THEO NGÀY ĐANG CHỌN ═══');
let ds = A.lcNacDs('2026-09-03').map(x => x[1]);
ok('03/09/2026 là thứ Năm đầu tiên → ba nấc gọi đúng tên',
   ds.includes('Hằng tuần vào thứ Năm') && ds.includes('Hằng tháng vào ngày 3')
   && ds.includes('Hằng tháng vào thứ Năm đầu tiên'), ds.join(' | '));
ok('03/09 KHÔNG phải thứ Năm cuối tháng → không có nấc "cuối cùng"',
   !ds.some(c => c.includes('cuối cùng')), ds.join(' | '));
ds = A.lcNacDs('2026-09-24').map(x => x[1]);
ok('24/09/2026 là thứ Năm cuối tháng → có thêm nấc "cuối cùng"',
   ds.includes('Hằng tháng vào thứ Năm cuối cùng'), ds.join(' | '));

console.log('\n═══ LUẬT CÓ TRÙNG MỘT NẤC SẴN KHÔNG ═══');
const L = (o) => Object.assign(A.lcLuatMoi(), o);
A.dat([4], [1]);
ok('thứ Năm tuần 1 hằng tháng → nấc thangT',
   A.lcNacCua(L({lap:'thang', loi:'thu'}), '2026-09-03') === 'thangT');
ok('cùng luật ấy mà bước 2 → không nấc nào, phải bày thành câu chữ',
   A.lcNacCua(L({lap:'thang', loi:'thu', buoc:2}), '2026-09-03') === null);
ok('cùng luật ấy mà dừng sau 12 lần → không nấc nào',
   A.lcNacCua(L({lap:'thang', loi:'thu', kt:'lan', so_lan:12}), '2026-09-03') === null);
A.dat([1,2,3,4,5,6], []);
ok('T2 tới T7 → nấc t2t7',
   A.lcNacCua(L({lap:'tuan'}), '2026-09-03') === 't2t7');
A.dat([1,2,3,4,5], []);
ok('T2 tới T6 (thiếu T7) → không nấc nào, bày thành câu chữ',
   A.lcNacCua(L({lap:'tuan'}), '2026-09-03') === null);
A.dat([4], []);
ok('mỗi thứ Năm → nấc tuan',
   A.lcNacCua(L({lap:'tuan'}), '2026-09-03') === 'tuan');
ok('ngày 3 hằng tháng → nấc thangN',
   A.lcNacCua(L({lap:'thang', loi:'ngay', ngay_thang:3}), '2026-09-03') === 'thangN');
ok('ngày 20 hằng tháng, sự kiện ngày 3 → không nấc nào',
   A.lcNacCua(L({lap:'thang', loi:'ngay', ngay_thang:20}), '2026-09-03') === null);

console.log('\n═══ Ô CHỌN Ở FORM ═══');
A.dat([4], [1]);
let h = A.veNac(L({lap:'thang', loi:'thu', buoc:3}));
ok('luật tuỳ chỉnh bày bằng CHÍNH CÂU CHỮ của nó, không phải chữ "Tuỳ chỉnh" trơn',
   h.includes('T5 tuần 1 mỗi 3 tháng') && h.includes('selected'), h);
ok('mục "Tuỳ chỉnh…" luôn ở cuối', h.trimEnd().endsWith('Tuỳ chỉnh…</option>'), h);

console.log('\n═══ HÀNG BẢY NÚT THỨ Ở FORM ═══');
A.dat([1,5], []);
let ot = A.veThu(L({lap:'tuan'}));
ok('hằng tuần → hàng nút hiện, đủ bảy nút',
   !ot.hidden && (ot.innerHTML.match(/lcBatThu\(/g) || []).length === 7, ot.innerHTML);
ok('… và chỉ hai thứ đang bật được tô đặc',
   (ot.innerHTML.match(/lc-thu-nut chon/g) || []).length === 2, ot.innerHTML);
ok('… thứ Hai đứng đầu hàng, Chủ nhật đứng cuối',
   ot.innerHTML.indexOf('>T2<') < ot.innerHTML.indexOf('>CN<'), ot.innerHTML);
A.dat([4], [1]);
ok('hằng tháng theo thứ → hàng nút vẫn hiện, vì luật ấy cũng hỏi tới thứ',
   !A.veThu(L({lap:'thang', loi:'thu'})).hidden);
ot = A.veThu(L({lap:'ngay'}));
ok('hằng ngày → hàng nút ẩn và dọn trắng', ot.hidden && ot.innerHTML === '');
ot = A.veThu(L({lap:'khong'}));
ok('không lặp lại → hàng nút ẩn', ot.hidden);

A.dat([1,2,3,4,5], []);
A.veThu(L({lap:'tuan'}));
let r = A.batThu(6);
ok('bật nốt T7 → ô chọn tự nhảy về nấc "Mỗi ngày trong tuần (T2–T7)"',
   r.thu.join(',') === '1,2,3,4,5,6' && r.lap.includes('(T2–T7)') &&
   /value="t2t7" selected/.test(r.lap), r.lap);
r = A.batThu(3);
ok('bỏ T4 → rời nấc, ô chọn bày nguyên câu chữ của luật mới',
   r.thu.join(',') === '1,2,4,5,6' && r.lap.includes('mỗi T2 · T3 · T5 · T6 · T7'), r.lap);
A.dat([2], []);
A.veThu(L({lap:'tuan'}));
r = A.batThu(2);
ok('bỏ nốt thứ cuối cùng → giữ lại, vì luật rỗng không nổ buổi nào',
   r.thu.join(',') === '2', JSON.stringify(r.thu));

console.log('\n═══ RUỘT CỬA TUỲ CHỈNH ═══');
h = A.veTc(L({lap:'thang', loi:'thu'}));
ok('hằng tháng theo thứ → có bảy nút thứ và năm nút tuần',
   (h.match(/lcTcBatThu\(/g) || []).length === 7 &&
   (h.match(/lcTcBatTuan\(/g) || []).length === 5);
ok('… và không có ô "Ngày trong tháng"', !h.includes("'ngay_thang'"));
h = A.veTc(L({lap:'thang', loi:'ngay', ngay_thang:5}));
ok('hằng tháng theo ngày → có ô Ngày, không có nút thứ',
   h.includes("'ngay_thang'") && !h.includes('lcTcBatThu('));
h = A.veTc(L({lap:'ngay'}));
ok('hằng ngày → có ô tick Bỏ Chủ nhật', h.includes("'bo_cn'"));
h = A.veTc(L({lap:'tuan'}));
ok('hằng tuần → bảy nút thứ, không có nút tuần',
   h.includes('lcTcBatThu(') && !h.includes('lcTcBatTuan('));
ok('ba nấc kết thúc luôn có mặt', (h.match(/name="lc-tc-kt"/g) || []).length === 3);
ok('câu chữ đọc-ra đứng cuối cửa', h.includes('lc-tc-doc'));

console.log('\n═══ SÁU BUỔI KẾ TIẾP ═══');
const ng = d => String(d.getDate()).padStart(2,'0') + '/' + String(d.getMonth()+1).padStart(2,'0');
A.dat([4], [1]);
let luot = A.lcSauLuot(A.lcDongTu(L({lap:'thang', loi:'thu'}), '2026-09-03'), 6);
ok('thứ Năm đầu tiên hằng tháng → sáu ngày đúng',
   luot.map(ng).join(' ') === '03/09 01/10 05/11 03/12 07/01 04/02', luot.map(ng).join(' '));
luot = A.lcSauLuot(A.lcDongTu(L({lap:'thang', loi:'ngay', ngay_thang:31}), '2026-01-31'), 6);
ok('ngày 31 → tháng thiếu bị BỎ QUA, đúng thứ mắt cần thấy',
   luot.map(ng).join(' ') === '31/01 31/03 31/05 31/07 31/08 31/10', luot.map(ng).join(' '));
luot = A.lcSauLuot(A.lcChotHan(A.lcDongTu(
     L({lap:'thang', loi:'ngay', ngay_thang:1, kt:'lan', so_lan:3}), '2026-09-01')), 6);
ok('dừng sau 3 lần → chỉ ba chip', luot.length === 3, luot.map(ng).join(' '));
let hh = A.lcVeSauLuot(A.lcChotHan(A.lcDongTu(
     L({lap:'thang', loi:'ngay', ngay_thang:1, kt:'lan', so_lan:3}), '2026-09-01')));
ok('… và nói ra rằng chuỗi dừng ở đây', hh.includes('chuỗi dừng ở đây'));
A.dat([], []);
ok('luật không nổ buổi nào → nói thẳng, không bày hàng chip rỗng',
   A.lcVeSauLuot(A.lcDongTu(L({lap:'tuan'}), '2026-09-01')).includes('không nổ buổi nào'));
A.dat([4], [1]);
hh = A.lcVeSauLuot(A.lcDongTu(L({lap:'thang', loi:'thu', buoc:6}), '2026-09-03'));
ok('lượt sang năm khác → chip mang thêm năm', hh.includes('/2027'), hh);

console.log('\n═══ MÁY CHỦ CHƯA CHẠY TỆP NÂNG CẤP ═══');
/* Cờ phải gác CẢ đường bày, không riêng đường ghi: một ô gõ được mà lưu xuống
   không tới đâu là một lời hứa suông — chuỗi chạy sai nhịp mà không tiếng kêu. */
A.co(true, false);
A.dat([4], [1]);
h = A.veTc(L({lap:'thang', loi:'thu', buoc:2, kt:'lan', so_lan:12}));
ok('cờ tắt → không bày ô bước nhảy', !h.includes("'buoc'"), h.slice(0, 300));
ok('cờ tắt → không bày nấc "Sau N lần"', (h.match(/name="lc-tc-kt"/g) || []).length === 2);
ok('cờ tắt → nói ra tên tệp phải chạy', h.includes('nang-cap-lap-buoc-va-so-lan.sql'));
let tc = A.moTc(L({lap:'thang', loi:'thu', buoc:2, kt:'lan', so_lan:12}));
ok('cờ tắt → mở cửa là kéo bản nháp về bước 1, bỏ nấc số lần',
   tc.buoc === 1 && tc.kt === 'khong', JSON.stringify(tc));
A.co(true, true);
h = A.veTc(L({lap:'thang', loi:'thu', buoc:2, kt:'lan', so_lan:12}));
ok('cờ bật lại → ba nấc kết thúc trở lại đủ', (h.match(/name="lc-tc-kt"/g) || []).length === 3);

console.log('\n═══ DỰNG DÒNG GHI XUỐNG MÁY CHỦ ═══');
A.dat([4], [1]);
let d = A.lcDongTu(L({lap:'thang', loi:'thu', buoc:2}), '2026-09-03');
ok('nhánh theo thứ: ngay_thang phải null', d.ngay_thang === null && d.tuan_thang.length === 1);
d = A.lcDongTu(L({lap:'tuan'}), '2026-09-03');
ok('nhánh hằng tuần: tuan_thang phải rỗng', d.tuan_thang.length === 0 && d.ngay_thang === null);
d = A.lcDongTu(L({lap:'khong'}), '2026-09-03');
ok('không lặp: thu rỗng, bước về 1, không hạn',
   !d.thu.length && d.buoc === 1 && d.ngay_ket_thuc === null && d.so_lan === null);
d = A.lcChotHan(A.lcDongTu(L({lap:'thang', loi:'ngay', ngay_thang:1, kt:'lan', so_lan:3}), '2026-09-01'));
ok('dừng sau 3 lần → ngày kết thúc suy ra là 01/11/2026',
   d.ngay_ket_thuc === '2026-11-01' && d.so_lan === 3, JSON.stringify(d));
A.dat([], []);
d = A.lcChotHan(A.lcDongTu(L({lap:'tuan', kt:'lan', so_lan:5}), '2026-09-01'));
ok('khai thiếu thứ → suy không ra ngày, bỏ cả số lần về null',
   d.ngay_ket_thuc === null && d.so_lan === null, JSON.stringify(d));

console.log('\n' + (truot ? '❌ ' + truot + ' ca trượt · ' : '✅ ') + dat + ' ca đạt\n');
process.exit(truot ? 1 : 0);
