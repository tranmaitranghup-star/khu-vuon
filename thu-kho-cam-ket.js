/* THỬ: bảng cam kết có bày nhóm KHO khi cam kết chỉ có việc chưa hẹn ngày?
   ─────────────────────────────────────────────────────────────────────────────
   Chiều 17/08 Tracy báo cam kết 2 và 3 trắng trơn: báo "Chưa có task nào cho cam
   kết này" trong khi việc còn nguyên trong kho. Gốc là `so_task` sáng cùng ngày
   thu hẹp còn đếm việc ĐÃ HẸN NGÀY, mà `veBangCamKet` lại mượn chính con số ấy
   làm công tắc bật/tắt cả danh sách.

   Bài thử này CẮT ĐÚNG BA KHỐI GỐC ra khỏi `public/index.html` (NHOM_TASK ·
   veNhomTask · veBangCamKet) rồi chạy chúng trên dữ liệu giả — không chép tay
   một dòng logic nào sang đây. Chép tay thì bài thử sẽ xanh cả khi file gốc đã
   hỏng, và đó là loại bài thử tệ hơn không có.

   Chạy:  node production/tinh-thuc-app/thu-kho-cam-ket.js

   Soi một bản KHÁC (để chắc bài thử thật sự bắt được lỗi, chứ không phải xanh
   với mọi bản mã — bài thử xanh cả khi file gốc hỏng thì tệ hơn không có):
     git show HEAD:public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-kho-cam-ket.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

/* Cắt từ `<tên>` tới ngay trước `<tên kế tiếp>` — bám vào tên khối chứ không bám
   số dòng, để bài thử không mục ngay lần sửa sau. */
function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error(`Không thấy khối: ${dau}`);
  return SRC.slice(i, j);
}
const NGUON = [
  catKhoi('const NHOM_TASK = [', '/* Nhóm nào đang THU'),
  catKhoi('function veNhomTask(ma, ds){', '/* ── MỘT BẢNG CAM KẾT'),
  catKhoi('function veBangCamKet(o, hopKho){', '/* ══════ 📓 DÒNG GHI CHÚ'),
].join('\n');

/* ── Cọc: đủ để ba khối trên chạy, không hơn ────────────────────────────────── */
const CỌC = `
const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];
const MO_CHUA_NGHEN = t => TT_MO.includes(t.trang_thai) && t.trang_thai !== 'Blocked';
const homNay = () => '2026-08-17';
const coLamDo = v => v.some(t => t.trang_thai === 'Chua_xong');
const IC = {sua:'✎'};
let CK_THU = {}, THEM_MO = null, TASK_CK = {};
/* Từ 27/08 veBangCamKet hỏi vuonCaDoi để quyết có bày nút "Trả cam kết này về
   kho" hay không — nút ấy chỉ có nghĩa trên vườn của chính mình. Thiếu cọc này
   thì bài thử đổ bằng ReferenceError ngay ca đầu, trước khi soi được gì.
   Để false vì mọi ca dưới đây đều là vườn của chính mình.
   (Cọc nằm trong một chuỗi mẫu — TUYỆT ĐỐI không dùng dấu huyền trong khối chú
   thích này, một dấu là cả tệp gãy cú pháp.) */
let vuonCaDoi = false;
const soCamKet = ma => ma;
const chuSach = s => s;
const veTieuChi = () => '';
const veHanHat = () => ' · hạn';
const veCoDoiHan = () => '';
const oNgay = () => '<o-ngay>';
const gioChu = p => (p/60).toFixed(1)+'h';
const veDongTaskCK = t => '<dong>'+t.noi_dung+'</dong>';
`;
/* `TASK_CK` và `CK_THU` sống TRONG phạm vi của `new Function`, không với tới từ
   ngoài được — nên trả kèm hai cái tay nắm để bài thử nạp dữ liệu và dọn trạng
   thái gập/xổ giữa các ca. */
const chay = new Function(CỌC + NGUON + `
  return {veBangCamKet, veNhomTask,
          nap: (ma, ds) => { TASK_CK = {[ma]: ds}; CK_THU = {}; }};`)();

/* ── Ba ca, đúng ba cam kết trên ảnh Tracy gửi ──────────────────────────────── */
const KHO_5 = [
  {id:1, noi_dung:'Thiết kế Funnel Economics', trang_thai:'Chua_lam', ngay:null},
  {id:2, noi_dung:'Thiết kế Customer Journey', trang_thai:'Chua_lam', ngay:null},
  {id:3, noi_dung:'Build Funnel Back-end',     trang_thai:'Chua_lam', ngay:null},
  {id:4, noi_dung:'Thiết kế Creative',         trang_thai:'Chua_lam', ngay:null},
  {id:5, noi_dung:'Chạy Traffic',              trang_thai:'Chua_lam', ngay:null},
];
const CA = [
  {ten:'Cam kết 1 — có việc hẹn ngày + có kho (ca vẫn chạy được trước khi chữa)',
   ma:'CK1', so_task:6, so_xong:5, so_kho:5, tong_phut:348,
   ds:[{id:9, noi_dung:'Build Funnel Front-end', trang_thai:'Doing', ngay:'2026-08-17'}, ...KHO_5],
   doi:{kho:true, chuTrong:false, vach:true}},

  {ten:'Cam kết 2 — CHỈ có việc trong kho  ⬅ đúng ca Tracy báo hỏng',
   ma:'CK2', so_task:0, so_xong:0, so_kho:5, tong_phut:0,
   ds:KHO_5,
   doi:{kho:true, chuTrong:false, vach:false}},

  {ten:'Cam kết chỉ có việc NGHẼN chưa hẹn ngày (ngoài cả so_task lẫn so_kho)',
   ma:'CK4', so_task:0, so_xong:0, so_kho:0, tong_phut:0,
   ds:[{id:20, noi_dung:'Chờ bên thiết kế trả bài', trang_thai:'Blocked', ngay:null}],
   doi:{kho:false, chuTrong:false, vach:false}},

  {ten:'Cam kết TRỐNG THẬT — vẫn phải báo "chưa có task nào"',
   ma:'CK5', so_task:0, so_xong:0, so_kho:0, tong_phut:0,
   ds:[],
   doi:{kho:false, chuTrong:true, vach:false}},
];

/* ── BA CA THẺ KHO (thêm 29/08) ──────────────────────────────────────────────
   Từ 29/08 cam kết nằm kho dùng CHÍNH `veBangCamKet`, chỉ khác tham số thứ hai.
   Ba ca dưới soi đúng chỗ thẻ kho được phép lệch khỏi thẻ đang chạy: BỘ NÚT.

   Vì sao đáng thử: nút "Hoàn thành cam kết" lọt xuống thẻ kho là mời người ta
   nộp output cho một việc chưa bắt đầu — hỏng về NGHĨA chứ không về hình, nên
   mắt nhìn ảnh chụp không bắt được. */
const CA_KHO = [
  {ten:'Kho · tự viết, vườn còn chỗ → chỉ có nút Đưa vào vườn',
   hop:{duocGiao:false, biTuChoi:false, aiGiao:null, daDay:false, phu:'Tự viết'},
   co:'Đưa vào vườn', khong:['Hoàn thành cam kết', 'Nhận việc này']},

  {ten:'Kho · tự viết, vườn ĐÃ ĐẦY → nút Đưa vào vườn bị mờ',
   hop:{duocGiao:false, biTuChoi:false, aiGiao:null, daDay:true, phu:'Tự viết'},
   co:'disabled', khong:['Hoàn thành cam kết']},

  {ten:'Kho · người khác giao, chưa trả lời → Nhận/Từ chối, KHÔNG có mục Sửa',
   hop:{duocGiao:true, biTuChoi:false, aiGiao:{ten:'Andy'}, daDay:false,
        phu:'Andy giao · Chờ nhận việc'},
   co:'Nhận việc này', khong:['Hoàn thành cam kết', '<option value="sua">']},

  {ten:'Kho · đã từ chối → ngõ cụt, không một nút nào',
   hop:{duocGiao:true, biTuChoi:true, aiGiao:{ten:'Andy'}, daDay:false,
        phu:'Andy giao · Đã từ chối'},
   co:'Đang chờ Andy', khong:['Hoàn thành cam kết', 'Đưa vào vườn', 'Nhận việc này']},
];

let rot = 0;
for (const c of CA_KHO){
  chay.nap('KHO1', []);
  const h = chay.veBangCamKet({ma:'KHO1', ten:c.ten, luong:null, so_task:0,
    so_xong:0, so_kho:0, tong_phut:0}, c.hop);
  const thieu = c.co && !h.includes(c.co) ? [`thiếu "${c.co}"`] : [];
  const thua  = c.khong.filter(k => h.includes(k)).map(k => `còn "${k}"`);
  /* Ô số phải mang lớp `kho`, không phải `l null` — lớp không tồn tại thì ô mất
     nền và con số trắng biến mất trên nền trắng. */
  const oSo = h.includes('class="o-so kho"') ? [] : ['ô số không mang lớp kho'];
  const loi = [...thieu, ...thua, ...oSo];
  if (loi.length) rot++;
  console.log(`\n${loi.length ? '❌' : '✅'} ${c.ten}`);
  if (loi.length) console.log('   ⬅ ' + loi.join(' · '));
}

for (const c of CA){
  chay.nap(c.ma, c.ds);
  const h = chay.veBangCamKet({ma:c.ma, ten:c.ten, luong:1, so_task:c.so_task,
    so_xong:c.so_xong, so_kho:c.so_kho, tong_phut:c.tong_phut});

  const co = {
    kho:      h.includes('>Kho<'),
    chuTrong: h.includes('Chưa có task nào'),
    vach:     h.includes('ck-vach'),
  };
  const soDong = (h.match(/<dong>/g) || []).length;
  const dongSo = (h.match(/class="ck-so">([^<]*)</) || [,'(không có)'])[1];
  const ok = ['kho','chuTrong','vach'].every(k => co[k] === c.doi[k]);
  if (!ok) rot++;

  console.log(`\n${ok ? '✅' : '❌'} ${c.ten}`);
  console.log(`   nhóm Kho: ${co.kho ? 'CÓ' : 'không'}${co.kho===c.doi.kho?'':`  ⬅ đợi ${c.doi.kho?'CÓ':'không'}`}`);
  console.log(`   báo "chưa có task": ${co.chuTrong ? 'CÓ' : 'không'}${co.chuTrong===c.doi.chuTrong?'':`  ⬅ đợi ${c.doi.chuTrong?'CÓ':'không'}`}`);
  console.log(`   thanh tiến độ: ${co.vach ? 'CÓ' : 'không'}${co.vach===c.doi.vach?'':`  ⬅ đợi ${c.doi.vach?'CÓ':'không'}`}`);
  console.log(`   dòng số: "${dongSo}"`);
  console.log(`   số dòng việc bày ra: ${soDong} / ${c.ds.length} trong danh sách`);
}
const TONG = CA.length + CA_KHO.length;
console.log(`\n${rot ? `❌ ${rot}/${TONG} ca RỚT` : `✅ cả ${TONG} ca ĐẠT`}`);
process.exit(rot ? 1 : 0);
