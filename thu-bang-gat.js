/* THỬ: MÀN BẢNG ĐO — ĐẾM MỌI VIỆC DONE · BỘ CHỌN KHOẢNG · BIỂU ĐỒ GIỜ ↔ QUẢ
   ─────────────────────────────────────────────────────────────────────────────
   Tracy giao 03/09, hai lượt:
     ① *"chỉ cần cứ đo lường task done đi đã"*
     ② *"thêm biểu đồ đo thời lượng deep work so sánh với số quả của từng người;
        view thì bổ sung 7 ngày gần nhất · tuần này · tháng này; bảng này có cả
        7 người luôn nhé"*

   Bài này canh sáu điều:
   ① con số lớn của bảng gặt đọc `so_qua` — mọi việc Done, không đòi phiên deepwork;
   ② dòng phụ «N có giờ deep work» TỰ IM khi máy chủ chưa chạy tệp SQL — cột
      không tồn tại thì không được in số 0, vì 0 là một lời nói dối;
   ③ bốn nấc khoảng tính đúng ngày bắt đầu, và `taiDoi` phải nạp nấc RỘNG NHẤT;
   ④ dòng phụ của bảng Giờ tập trung chỉ còn «N lần chăm» — vế mẫu số đã bỏ
      03/09, xem chú thích tại chỗ;
   ⑤ biểu đồ có ĐỦ MỌI NGƯỜI trong `DOI`, kể cả người không giờ không quả;
   ⑥ hai dải chuẩn hoá theo hai ĐỈNH RIÊNG — không dùng chung một trục.

   Bài thử CẮT KHỐI GỐC ra khỏi `public/index.html` rồi chạy trên dữ liệu giả —
   không chép tay một dòng logic nào sang đây.

   Chạy:  node production/tinh-thuc-app/thu-bang-gat.js
   Soi bản cũ:
     git show origin/main:public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-bang-gat.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

function catHam(ten){
  const i = SRC.indexOf('\nfunction ' + ten + '(');
  if (i < 0) throw new Error('Không thấy hàm: ' + ten);
  const j = SRC.indexOf('\n}\n', i);
  if (j < 0) throw new Error('Không thấy chỗ đóng hàm: ' + ten);
  return SRC.slice(i + 1, j + 3);
}
function catDong(dau){
  const i = SRC.indexOf(dau);
  if (i < 0) throw new Error('Không thấy dòng: ' + dau);
  return SRC.slice(i, SRC.indexOf('\n', i));
}

/* HÔM NAY ĐÓNG BĂNG: thứ Năm 17/09/2026. Chọn ngày này để bốn nấc ra bốn mốc
   KHÁC NHAU — hôm nay 17/09 · 7 ngày 11/09 · tuần này 14/09 (thứ Hai) · tháng
   này 01/09. Ngày nào bốn mốc trùng nhau thì ca ③ không kiểm được gì cả. */
const HOM_NAY = '2026-09-17';

let RUOT = {};      // id khối → innerHTML lần vẽ gần nhất
let BE_NGANG = 700;      // bề ngang thẻ giả — `veSoSanh` đo nó để chọn khung vẽ
const oGia = id => ({ set innerHTML(v){ RUOT[id] = v; },
                      set textContent(v){ RUOT[id] = v; },
                      get clientWidth(){ return id === 'ss-bd' ? BE_NGANG : 0; },
                      classList:{toggle(){}}, dataset:{} });

const san = {
  /* BẢY người — đúng con số Tracy nói. Người thứ 7 cố ý không có giờ, không có
     quả: ca ⑤ canh nó vẫn có mặt trên biểu đồ. */
  DOI: ['Tracy','Andy','Justin','John','Sydney','Mai','Khoa']
         .map((ten,i) => ({id:'u'+(i+1), ten})),
  ME: {id:'u1'},
  homNay: () => HOM_NAY,
  chuSach: x => String(x),
  document: { getElementById: oGia, querySelectorAll: () => [] },
  /* Bề ngang màn giả — `veSoSanh` chọn cỡ khung vẽ theo nó. Đặt được từ bài thử
     để chấm cả hai lối: màn rộng (khung 560) và điện thoại (khung 380). */
  window: { innerWidth: 1200 },
};

const NGUON = [
  catDong('const d2s = d =>'),
  catDong('function thuHai(ds){'),   // một dòng — catHam sẽ nuốt quá tay
  catDong('const laCN = g =>'),
  catDong('const gioChu = p =>'),
  catDong('let DO_KHOANG ='),
  catHam('doTuNgay'),
  catDong('const DO_NHAN ='),
  catDong('const DO_CAU  ='),
  catDong('const doTrong ='),
  catHam('veBangGat'),
  catHam('veBangCham'),
  catHam('veSoSanh'),
].join('\n');

const api = new Function(...Object.keys(san), NGUON +
  '\nreturn {veBangGat, veBangCham, veSoSanh, doTuNgay, doTrong,' +
  ' dat:k=>{DO_KHOANG=k}, DO_NHAN};')(...Object.values(san));

let dat = 0, hong = 0;
const ok = (ten, dieu, them) => {
  if (dieu){ dat++; console.log('  ✅', ten); }
  else { hong++; console.log('  ❌', ten, them ? '\n       ' + them : ''); }
};

/* ═══ ③ Bốn nấc khoảng ═════════════════════════════════════════════════════ */
console.log('\n▸ Bốn nấc khoảng (hôm nay = thứ Năm 17/09/2026)');
ok('Hôm nay  → 17/09', api.doTuNgay('homnay') === '2026-09-17', api.doTuNgay('homnay'));
ok('7 ngày   → 11/09 (trượt, kể cả hôm nay)', api.doTuNgay('bay') === '2026-09-11', api.doTuNgay('bay'));
ok('Tuần này → 14/09 (thứ Hai)', api.doTuNgay('tuan') === '2026-09-14', api.doTuNgay('tuan'));
ok('Tháng này→ 01/09', api.doTuNgay('thang') === '2026-09-01', api.doTuNgay('thang'));
/* Chính phép `taiDoi` dùng để chọn khoảng nạp. Đầu tháng thì «7 ngày trượt»
   lùi xa hơn mùng 1, nên KHÔNG được đóng cứng là mùng 1. */
ok('taiDoi nạp nấc RỘNG NHẤT trong bốn nấc',
   ['homnay','bay','tuan','thang'].map(api.doTuNgay).sort()[0] === '2026-09-01');

/* ═══ ① ② Bảng gặt ═════════════════════════════════════════════════════════ */
console.log('\n▸ Bảng gặt — máy chủ đã có cột so_qua_dw');
api.dat('bay');
api.veBangGat([
  {nguoi_id:'u1', ngay:'2026-09-17', so_qua:4, so_qua_dw:1},
  {nguoi_id:'u1', ngay:'2026-09-16', so_qua:3, so_qua_dw:2},
  {nguoi_id:'u2', ngay:'2026-09-17', so_qua:2, so_qua_dw:2},
]);
let R = RUOT['bang-gat'];
ok('Con số lớn đọc so_qua cộng cả khoảng (4+3 = 7), không đọc so_qua_dw',
   /🍎 7/.test(R) && !/🍎 3/.test(R), R.slice(0,300));
ok('Dòng phụ bày phần có giờ (1+2 = 3)', /3 có giờ deep work/.test(R));
ok('Câu quán quân mang nhãn của nấc đang chọn',
   /🏆 7 ngày qua <b>Tracy<\/b> gặt được nhiều nhất — 7 quả/.test(R), R.slice(0,220));
ok('Người chưa xong việc nào hiện gạch ngang, không hiện 🍎 0',
   /—<\/span>/.test(R) && !/🍎 0/.test(R));
ok('Đủ bảy người trên bảng',
   ['Tracy','Andy','Justin','John','Sydney','Mai','Khoa'].every(t => R.includes(t)));
/* Tiêu đề khối phải đi theo nấc: để nguyên "trong ngày" trong khi bộ chọn ở
   "Tháng này" là hai câu ngược nhau cách nhau 40 điểm ảnh, và người đọc tin cái
   tiêu đề vì nó to hơn. */
ok('Tiêu đề khối đổi theo nấc (7 ngày)',
   RUOT['gat-tieu-de'] === 'Kết quả · 7 ngày qua', RUOT['gat-tieu-de']);
api.dat('thang'); api.veBangGat([]);
ok('Nấc Tháng này → tiêu đề nói tháng này',
   RUOT['gat-tieu-de'] === 'Kết quả · Tháng này', RUOT['gat-tieu-de']);
api.dat('homnay'); api.veBangGat([]);
ok('Nấc Hôm nay giữ nguyên chữ cũ «Kết quả trong ngày»',
   RUOT['gat-tieu-de'] === 'Kết quả trong ngày', RUOT['gat-tieu-de']);
api.dat('bay');

console.log('\n▸ Bảng gặt — việc xong không có một phút deep work nào');
api.veBangGat([{nguoi_id:'u3', ngay:'2026-09-17', so_qua:6, so_qua_dw:0}]);
R = RUOT['bang-gat'];
ok('Justin 6 việc xong / 0 giờ vẫn đứng đầu bảng',
   /🍎 6/.test(R) && R.indexOf('Justin') < R.indexOf('Tracy'));
ok('Nói thẳng «0 có giờ deep work», không giấu', /0 có giờ deep work/.test(R));

console.log('\n▸ Bảng gặt — máy chủ chưa chạy nang-cap-do-viec-done.sql');
api.veBangGat([{nguoi_id:'u1', ngay:'2026-09-17', so_qua:4}]);
R = RUOT['bang-gat'];
ok('Con số lớn vẫn đúng (4)', /🍎 4/.test(R));
ok('Dòng phụ TỰ IM, không bịa ra «0 có giờ»', !/có giờ/.test(R), R.slice(0,300));

/* ═══ ④ ĐÃ GỠ — bốn ca chấm điểm một hàm chết ═══════════════════════════════
   Chúng đo `doSoNgayLam`, hàm tính mẫu số cho dòng phụ «x/y ngày làm có ra
   vườn». Tracy bỏ vế ấy hôm 03/09 (xem ca ngay dưới), nên hàm mất chỗ gọi cuối
   cùng và nằm lại hai ngày — được bốn ca này canh gác đều đặn trong lúc chẳng
   ai được lợi gì. Hàm gỡ khỏi app 05/09 (TRI-121), bốn ca đi theo.
   Luật chúng canh — *mẫu số phải đi theo khoảng đang chọn, không viết cứng* —
   vẫn đúng, và sẽ được canh lại ở đúng chỗ nếu một dòng phụ như thế trở lại. */
/* ⚠️ CA NÀY ĐÃ ĐỔI LUẬT — 03/09, cùng ngày và trong cùng đợt sửa.
   Bản cũ canh "tử số không vượt mẫu số" trên dòng phụ «x/y ngày làm có ra
   vườn». Chiều 03/09 Tracy chốt bỏ hẳn vế ấy: bảng Giờ tập trung đổi từ bảy
   con số xếp dọc thành bảy thanh ngang, và dòng phụ chỉ còn «N lần chăm»
   (commit 09bcc79 — *"Dòng phụ bỏ vế x/y ngày làm có ra vườn"*). Không còn
   phân số trên màn thì không còn gì để vượt, và ca cũ chờ mãi một mẫu chuỗi
   đã bị gỡ.
   Nay ca ghim đúng cái luật hiện hành, cả hai vế: dòng phụ CÓ số lần chăm, và
   KHÔNG được có phân số nào quay lại. Vế phủ định mới là vế đáng giữ — nó bắt
   được ngày ai đó gắn lại một mẫu số mà không đo lại nó theo khoảng. */
api.dat('thang');
api.veBangCham(Array.from({length:14}, (_,i) => ({
  nguoi_id:'u1', ngay:`2026-09-${String(i+1).padStart(2,'0')}`, phut:60, so_lan_cham:1})));
R = RUOT['bang-cham'];
ok('Dòng phụ đếm đúng số lần chăm (14 ngày × 1 lần)', /14 lần chăm/.test(R),
   (/[^>]*lần chăm/.exec(R) || ['không thấy dòng phụ'])[0]);
ok('Dòng phụ KHÔNG còn vế mẫu số «ngày làm» — Tracy bỏ 03/09',
   !/ngày làm/.test(R), (/\d+\/\d+ ngày làm/.exec(R) || [''])[0]);
/* Thanh ngang đo theo ĐỈNH của chính khoảng đang xem. Một người duy nhất có
   giờ thì người ấy ăn trọn chỗ dành cho thanh, sáu người kia về 0 — không
   phải chia cho một chỉ tiêu đặt cứng nào. */
ok('Thanh của người dẫn đầu ăn trọn chỗ, sáu người kia về 0',
   (R.match(/\* 1\.000\)/g)||[]).length === 1
   && (R.match(/\* 0\.000\)/g)||[]).length === 6,
   (R.match(/\* [\d.]+\)/g)||[]).join(' · '));

/* ═══ ⑤ ⑥ Biểu đồ điểm rải: deep work ↔ việc hoàn thành ════════════════════
   Tracy 03/09 lượt 3: *"2 biểu đồ đó gộp làm 1 để so sánh tương quan đc k"*.
   Gộp hai dải thanh vào MỘT trục là biểu đồ hai-trục — tỉ lệ giữa hai thanh khi
   ấy do người vẽ đặt ra chứ không do dữ liệu. Điểm rải gộp được mà không phạm:
   mỗi trục vẫn là thang của riêng một đại lượng, và nó đọc ra TƯƠNG QUAN — thứ
   Tracy hỏi — chứ không chỉ đọc ra hai con số cạnh nhau. */
console.log('\n▸ Biểu đồ điểm rải');
api.dat('bay');
api.veSoSanh(
  [{nguoi_id:'u1', ngay:'2026-09-17', so_qua:10},
   {nguoi_id:'u2', ngay:'2026-09-17', so_qua:5}],
  [{nguoi_id:'u1', ngay:'2026-09-17', phut:120, so_lan_cham:2},
   {nguoi_id:'u2', ngay:'2026-09-17', phut:600, so_lan_cham:6}]
);
R = RUOT['ss-bd'];
ok('Đủ BẢY người trên biểu đồ, kể cả người không giờ không việc',
   ['Tracy','Andy','Justin','John','Sydney','Mai','Khoa'].every(t => R.includes(t)));
ok('Đúng bảy chấm — không thừa, không thiếu',
   (R.match(/<circle /g)||[]).length === 7, String((R.match(/<circle /g)||[]).length));
ok('Là MỘT biểu đồ, không phải hai', (R.match(/<svg /g)||[]).length === 1);
ok('Hai nhãn trục đúng chữ Tracy chốt',
   /">Deep work<\/text>/.test(R) && /">Việc hoàn thành<\/text>/.test(R));
ok('Chữ cũ «Giờ sâu» và «Việc xong» đã đi hết',
   !/Giờ sâu/.test(R) && !/Việc xong/.test(R));
/* Chấm của tôi mang màu nhấn, sáu người kia màu nền — dạng NHẤN MỘT, không phải
   bảy màu khác nhau. */
ok('Chấm của tôi màu nhấn, sáu người kia cùng một màu',
   (R.match(/fill="#cf7b28"/g)||[]).length === 1
   && (R.match(/fill="#1f9a90"/g)||[]).length === 6);
ok('Mỗi chấm có câu chú khi rê chuột', (R.match(/<title>/g)||[]).length === 7);
ok('Không sinh ra toạ độ hỏng', !/NaN|Infinity/.test(R));
/* Trục ngang đo phút mà viết ra giờ, nên nấc chia phải là bội của giờ. Nấc thập
   phân cho ra 3,3h · 6,7h · 13,3h — đúng về số mà không đọc được thành thang. */
{ const nhan = [...R.matchAll(/text-anchor="middle">([^<]+)<\/text>/g)].map(m=>m[1]);
  ok('Nhãn trục ngang là bội của giờ, gốc trục là số 0 trần',
     nhan[0] === '0' && nhan.slice(1).every(t => /^\d+h$/.test(t)), nhan.join(' · ')); }
/* Không còn khối chữ giảng giải nào — Tracy 03/09: *"ko cần giải thích đâu
   loạn lắm"*. */
ok('Không còn đoạn chữ giảng giải trong khối',
   !/thang riêng|không nói ai làm tốt|phép chia của hai cột/.test(R));

console.log('\n▸ Biểu đồ — khoảng chưa có gì');
api.veSoSanh([], []);
ok('Nói ra khoảng nào đang trống, không để một khung rỗng',
   /7 ngày qua chưa có gì để đo/.test(RUOT['ss-bd']), RUOT['ss-bd']);

/* ═══ ⑦ Hai lỗi Tracy bắt được trên máy thật 03/09 ═════════════════════════
   *"bảng bị to quá mà bị lỗi chèn chữ nhau"*. Cả hai đều không có lỗi nào báo —
   chúng chỉ hiện ra thành một cái bảng đọc không được. */
console.log('\n▸ Khung vẽ bám ĐÚNG bề ngang thẻ, mọi cỡ tỉ lệ đều bằng 1');
/* Đây là phép canh gốc cho cả họ lỗi "chữ to/teo": chữ trong SVG chỉ giữ nguyên
   cỡ khi bề ngang khung vẽ ĐÚNG BẰNG bề ngang hiện ra. Lệch bao nhiêu thì chữ
   phóng/teo đúng bấy nhiêu lần. */
const soVe = (w) => { BE_NGANG = w;
  api.veSoSanh([{nguoi_id:'u1', ngay:'2026-09-17', so_qua:28}],
               [{nguoi_id:'u1', ngay:'2026-09-17', phut:400, so_lan_cham:4}]);
  return +/viewBox="0 0 (\d+) /.exec(RUOT['ss-bd'])[1]; };
for (const w of [330, 375, 520, 700]){
  ok(`Thẻ ${w}px → khung ${w}, tỉ lệ 1`, soVe(w) === w, String(soVe(w)));
}
/* Kẹp hai đầu: khung không teo dưới mức đọc được, cũng không giãn tới mức bảy
   cái tên trôi xa nhau. */
ok('Thẻ hẹp bất thường vẫn không teo dưới 280', soVe(120) === 280, String(soVe(120)));
ok('Thẻ rộng bất thường vẫn không giãn quá 760', soVe(1900) === 760, String(soVe(1900)));
ok('Không còn chặn trần max-width (nó đẻ ra mảng trống trong thẻ)',
   !/max-width/.test(RUOT['ss-bd']));
BE_NGANG = 700;

console.log('\n▸ Nhãn tên không chồng lên nhau');
/* Ca đúng như Tracy gặp: bốn người chưa có giờ, chưa xong việc nào — cả bốn rơi
   đúng gốc toạ độ. Đây không phải ca hiếm: đầu tuần thì đa số cả team ở đó. */
api.veSoSanh([{nguoi_id:'u1', ngay:'2026-09-17', so_qua:28},
              {nguoi_id:'u2', ngay:'2026-09-17', so_qua:18},
              {nguoi_id:'u3', ngay:'2026-09-17', so_qua:17}],
             [{nguoi_id:'u1', ngay:'2026-09-17', phut:400, so_lan_cham:4},
              {nguoi_id:'u2', ngay:'2026-09-17', phut:240, so_lan_cham:3},
              {nguoi_id:'u3', ngay:'2026-09-17', phut:160, so_lan_cham:2}]);
R = RUOT['ss-bd'];
{ /* Dựng lại ô chữ nhật của từng nhãn từ chính chuỗi vừa sinh ra, rồi soát từng
     cặp. Đây là phép soát THẲNG trên kết quả, không phải soát lại phép tính. */
  const nhan = [...R.matchAll(/<text class="ss-nhan[^"]*" x="([\d.]+)" y="([\d.]+)" text-anchor="(\w+)">([^<]+)</g)]
    .map(m => { const x=+m[1], y=+m[2], w=m[4].length*6.2+4;
                /* Ô chữ dựng từ SỐ ĐO CHỮ, không chép hằng số của hàm đặt nhãn —
                   chép sang thì bài thử chỉ chạy lại chính phép tính ấy và
                   không kiểm gì cả. Chữ 11px: phần trên ~8, phần dưới ~3; cộng
                   mỗi bên 1 cho khoảng hở tối thiểu 2px. */
                return {ten:m[4], x1: m[3]==='start'?x:x-w, x2: m[3]==='start'?x+w:x,
                        y1:y-9, y2:y+4}; });
  ok('Bảy người đều có nhãn', nhan.length === 7, String(nhan.length));
  let dung = [];
  for (let i=0;i<nhan.length;i++) for (let j=i+1;j<nhan.length;j++){
    const a=nhan[i], b=nhan[j];
    if (!(a.x2<b.x1 || b.x2<a.x1 || a.y2<b.y1 || b.y2<a.y1)) dung.push(a.ten+'↔'+b.ten);
  }
  ok('Không cặp nhãn nào đè lên nhau', !dung.length, dung.join(' · '));
  ok('Bốn người ở gốc toạ độ vẫn đọc được tên',
     ['John','Sydney','Mai','Khoa'].every(t => nhan.some(n => n.ten === t))); }
/* Nhãn phải nằm trong LÒNG LƯỚI, không chỉ trong khung vẽ: lật sang trái quá
   mép lưới là đè lên hàng số của trục dọc. Mép trái lưới là P — đọc ra từ chính
   vạch lưới dọc đầu tiên trong chuỗi vừa sinh, không chép hằng số. */
{ const P = Math.min(...[...R.matchAll(/<line class="ss-luoi-vach" x1="([\d.]+)" y1="[\d.]+" x2="([\d.]+)"/g)]
                        .map(m => +m[1]));
  const D = Math.max(...[...R.matchAll(/<line class="ss-luoi-vach" x1="[\d.]+" y1="([\d.]+)"/g)].map(m => +m[1]));
  const nhan = [...R.matchAll(/<text class="ss-nhan[^"]*" x="([\d.]+)" y="([\d.]+)" text-anchor="(\w+)">([^<]+)</g)]
    .map(m => { const x=+m[1], w=m[4].length*6.2+4;
                return {ten:m[4], trai: m[3]==='start'?x:x-w, day:+m[2]+4}; });
  const tran = nhan.filter(n => n.trai < P - 0.5);
  ok('Không nhãn nào lấn sang vùng số của trục dọc',
     !tran.length, tran.map(n=>n.ten).join(' · '));
  const duoi = nhan.filter(n => n.day > D + 0.5);
  ok('Không nhãn nào tụt xuống dưới trục ngang',
     !duoi.length, duoi.map(n=>n.ten).join(' · ')); }

/* Khung bản hẹp chật hơn hẳn, nên phép đặt nhãn dễ hết chỗ ở đó trước. Chấm
   cả bảy nhãn ngay trên khung hẹp, với đúng bộ số Tracy vừa chạy. */
console.log('\n▸ Bản hẹp — nhãn vẫn đủ chỗ');
BE_NGANG = 340;
api.veSoSanh([{nguoi_id:'u1', ngay:'2026-09-17', so_qua:28},
              {nguoi_id:'u2', ngay:'2026-09-17', so_qua:18},
              {nguoi_id:'u3', ngay:'2026-09-17', so_qua:17},
              {nguoi_id:'u5', ngay:'2026-09-17', so_qua:1}],
             [{nguoi_id:'u1', ngay:'2026-09-17', phut:410, so_lan_cham:5},
              {nguoi_id:'u2', ngay:'2026-09-17', phut:245, so_lan_cham:3},
              {nguoi_id:'u3', ngay:'2026-09-17', phut:160, so_lan_cham:2}]);
R = RUOT['ss-bd'];
{ const nhan = [...R.matchAll(/<text class="ss-nhan[^"]*"[^>]*>([^<]+)</g)].map(m=>m[1]);
  ok('Bản hẹp: bảy người vẫn đủ nhãn', nhan.length === 7, nhan.join(' · '));
  const P = Math.min(...[...R.matchAll(/<line class="ss-luoi-vach" x1="([\d.]+)"/g)].map(m=>+m[1]));
  const o = [...R.matchAll(/<text class="ss-nhan[^"]*" x="([\d.]+)" y="[\d.]+" text-anchor="(\w+)">([^<]+)</g)]
    .map(m => ({ten:m[3], trai: m[2]==='start' ? +m[1] : +m[1]-(m[3].length*6.2+4)}));
  const tran = o.filter(n => n.trai < P - 0.5);
  ok('Bản hẹp: không nhãn nào lấn vùng số trục dọc', !tran.length, tran.map(n=>n.ten).join(' · ')); }
BE_NGANG = 700;

console.log(`\n${hong ? '❌' : '✅'}  ${dat} đạt · ${hong} hỏng\n`);
process.exit(hong ? 1 : 0);
