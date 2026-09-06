/* Bộ thử cho luật lặp có BƯỚC NHẢY (TRI-66). Cắt ba hàm ra khỏi index.html rồi
   chạy khô — không dựng DOM, không cần máy chủ. Chạy: node thu-lap-buoc.js */
const fs = require('fs');
const html = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
function cat(ten, den){
  const i = html.indexOf('function ' + ten + '(');
  const j = html.indexOf('\n' + den, i);
  if (i < 0 || j < 0) throw new Error('không tìm thấy mốc cắt: ' + ten);
  return html.slice(i, j);
}
const ma = "const LC_TEN_THU = ['CN','T2','T3','T4','T5','T6','T7'];\n"
  + "const d2s = d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;\n"
  + cat('lcHopBuoc', 'function lcHopNgay')
  + cat('lcHopNgay', 'function lcNhanLap')
  + cat('lcNhanLap', '/* GIỜ THẬT CỦA MỘT LƯỢT')
  + cat('lcNgaySauNLuot', '/* NGÀY KẾT THÚC SUY RA');
const {lcHopNgay, lcNhanLap, lcNgaySauNLuot} =
  new Function(ma + '\nreturn {lcHopNgay, lcNhanLap, lcNgaySauNLuot};')();

const hai = n => String(n).padStart(2,'0');
function bung(l, soLuot = 6){
  const ra = [], b = new Date(l.ngay_bat_dau + 'T00:00:00');
  for (let i = 0; i < 2600 && ra.length < soLuot; i++){
    const d = new Date(b); d.setDate(d.getDate() + i);
    const g = d.getFullYear() + '-' + hai(d.getMonth()+1) + '-' + hai(d.getDate());
    if (l.ngay_ket_thuc && g > l.ngay_ket_thuc) break;
    if (lcHopNgay(l, g)) ra.push(hai(d.getDate()) + '/' + hai(d.getMonth()+1) + '/' + d.getFullYear());
  }
  return ra;
}

let dat = 0, truot = 0;
function ca(ten, l, cho, choNhan){
  const co = bung(l).join(' ');
  const nhan = lcNhanLap(l);
  const ok = co === cho && (!choNhan || nhan === choNhan);
  console.log((ok ? '  ✅ ' : '  ❌ ') + ten);
  console.log('     đọc ra: ' + lcNhanLap(l));
  if (!ok){
    if (co !== cho){ console.log('     chờ : ' + cho); console.log('     ra  : ' + co); }
    if (choNhan && nhan !== choNhan) console.log('     chờ chữ: ' + choNhan);
  }
  ok ? dat++ : truot++;
}

const goc = {lap:'thang', thu:[], tuan_thang:[], bo_cn:true, buoc:1, ngay_bat_dau:'2026-09-03'};
const L = o => Object.assign({}, goc, o);

console.log('\n═══ BƯỚC 1 — mọi chuỗi đang chạy phải giữ nguyên hành vi ═══');
ca('ngày 3 hằng tháng', L({ngay_thang:3}),
   '03/09/2026 03/10/2026 03/11/2026 03/12/2026 03/01/2027 03/02/2027');
ca('T5 tuần 1 hằng tháng', L({thu:[4], tuan_thang:[1]}),
   '03/09/2026 01/10/2026 05/11/2026 03/12/2026 07/01/2027 04/02/2027');
ca('T5 tuần cuối hằng tháng', L({thu:[4], tuan_thang:[-1], ngay_bat_dau:'2026-09-24'}),
   '24/09/2026 29/10/2026 26/11/2026 31/12/2026 28/01/2027 25/02/2027');
ca('ngày 31 — tháng thiếu phải trống', L({ngay_thang:31, ngay_bat_dau:'2026-01-31'}),
   '31/01/2026 31/03/2026 31/05/2026 31/07/2026 31/08/2026 31/10/2026');
ca('hằng tuần T2 · T4', L({lap:'tuan', thu:[1,3]}),
   '07/09/2026 09/09/2026 14/09/2026 16/09/2026 21/09/2026 23/09/2026');
ca('hằng ngày trừ CN', L({lap:'ngay', bo_cn:true}),
   '03/09/2026 04/09/2026 05/09/2026 07/09/2026 08/09/2026 09/09/2026',
   'hằng ngày, trừ CN');

console.log('\n═══ BƯỚC NHẢY — cái TRI-66 thêm vào ═══');
ca('ngày 5 mỗi 3 tháng — họp quý', L({ngay_thang:5, buoc:3, ngay_bat_dau:'2026-09-05'}),
   '05/09/2026 05/12/2026 05/03/2027 05/06/2027 05/09/2027 05/12/2027');
ca('T5 tuần 1 mỗi 2 tháng', L({thu:[4], tuan_thang:[1], buoc:2}),
   '03/09/2026 05/11/2026 07/01/2027 04/03/2027 06/05/2027 01/07/2027');
/* ⚠️ LƯỢT ĐẦU CÁCH NGÀY BẮT ĐẦU 11 NGÀY, và đó là đúng. Chuỗi khai từ thứ Năm
   03/09; tuần chứa nó (31/08–06/09) là tuần 0, mà T2 và T4 của tuần ấy đã qua
   trước ngày bắt đầu. Tuần 1 rơi vào nhịp lẻ nên bỏ. Nên buổi đầu tiên là T2
   tuần 2. Lịch Google cũng đếm từ tuần chứa ngày bắt đầu. Ai sửa hàm này mà
   thấy con số 14/09 lạ thì đọc lại đoạn này trước khi "vá". */
ca('mỗi 2 tuần vào T2 · T4', L({lap:'tuan', thu:[1,3], buoc:2}),
   '14/09/2026 16/09/2026 28/09/2026 30/09/2026 12/10/2026 14/10/2026');
/* Ranh giới tuần đếm từ THỨ HAI: chuỗi khai T2 và CN, bắt đầu đúng thứ Hai
   07/09 thì Chủ nhật 13/09 phải nằm CÙNG tuần ấy, không bị đẩy sang tuần sau. */
ca('mỗi 2 tuần vào T2 · CN — ranh giới tuần', L({lap:'tuan', thu:[1,0], buoc:2, ngay_bat_dau:'2026-09-07'}),
   '07/09/2026 13/09/2026 21/09/2026 27/09/2026 05/10/2026 11/10/2026');
ca('mỗi 3 ngày', L({lap:'ngay', bo_cn:false, buoc:3}),
   '03/09/2026 06/09/2026 09/09/2026 12/09/2026 15/09/2026 18/09/2026');
/* Luật Nghỉ CN CẮT lượt, không DỜI nó: 13/09 rơi vào Chủ nhật thì lượt ấy mất
   hẳn, nhịp ba ngày vẫn đếm tiếp từ chỗ cũ nên lượt sau là 16/09 chứ không phải
   14/09. Dời là tự ý đặt một buổi vào ngày chưa ai hẹn — cùng lẽ với luật "tháng
   thiếu thì tháng đó trống" ở nhánh hằng tháng. */
ca('mỗi 3 ngày, vẫn trừ CN', L({lap:'ngay', bo_cn:true, buoc:3, ngay_bat_dau:'2026-09-01'}),
   '01/09/2026 04/09/2026 07/09/2026 10/09/2026 16/09/2026 19/09/2026',
   'mỗi 3 ngày, trừ CN');

console.log('\n═══ SỐ LẦN — ngày kết thúc suy ra, nhãn nói đúng ý định ═══');
ca('ngày 1 hằng tháng, dừng sau 3 lần', L({ngay_thang:1, so_lan:3, ngay_bat_dau:'2026-09-01',
   ngay_ket_thuc:'2026-11-01'}), '01/09/2026 01/10/2026 01/11/2026');

/* NGÀY CỦA LƯỢT THỨ N — kiểm CHÉO, không so với một ngày tôi tính tay: bung
   chuỗi ra n lượt rồi lấy lượt cuối, và đòi `lcNgaySauNLuot` trả đúng ngày ấy.
   Hai đường đi khác nhau tới cùng một con số; tôi tính nhầm thì cả hai cùng
   nhầm cũng không xảy ra, vì một bên đếm còn một bên bung. */
console.log('\n═══ NGÀY KẾT THÚC SUY RA TỪ SỐ LẦN ═══');
function caN(ten, l, n){
  const bungRa = bung(l, n);
  const [d, m, y] = bungRa[bungRa.length - 1].split('/');
  const cho = y + '-' + m + '-' + d;
  const co  = lcNgaySauNLuot(l, n);
  const ok  = co === cho && bungRa.length === n;
  console.log((ok ? '  ✅ ' : '  ❌ ') + ten + ' → lượt thứ ' + n + ': ' + co);
  if (!ok) console.log('     chờ ' + cho + ' (bung ra ' + bungRa.length + '/' + n + ' lượt)');
  ok ? dat++ : truot++;
}
caN('ngày 1 hằng tháng', L({ngay_thang:1, ngay_bat_dau:'2026-09-01'}), 3);
caN('T5 tuần 1 hằng tháng', L({thu:[4], tuan_thang:[1]}), 12);
caN('mỗi 2 tuần vào T2', L({lap:'tuan', thu:[1], buoc:2, ngay_bat_dau:'2026-09-07'}), 5);
caN('ngày 31 — tháng thiếu không tính là một lần',
    L({ngay_thang:31, ngay_bat_dau:'2026-01-31'}), 6);
caN('mỗi 6 tháng — nửa năm một lần', L({ngay_thang:15, buoc:6, ngay_bat_dau:'2026-09-15'}), 4);

console.log('\n' + (truot ? '❌ ' + truot + ' ca trượt · ' : '✅ ') + dat + ' ca đạt\n');
process.exit(truot ? 1 : 0);
