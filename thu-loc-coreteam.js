/* THỬ: MỤC "CORETEAM" TRONG Ô LỌC MÀN LỊCH TRÌNH (TRI-84)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"nút lọc phòng ban này ở chế độ xem lịch trình của ceo và vận
   hành thiếu mất nút chọn coreteam rồi"*.

   Ô lọc vốn đọc thẳng bảng `chuc_nang` — sáu khối, sinh từ máy chủ. Coreteam
   KHÔNG nằm trong đó vì nó không phải một khối: nó cắt ngang theo cờ `la_lead`
   (Tracy 31/08). Nên mục ấy phải thêm tay, mang một mã riêng.

   Ba ca đáng giá nhất:
     · Mã của Coreteam phải ÂM. Mã khối do máy chủ sinh luôn dương, nên số âm là
       thứ duy nhất chắc chắn không đụng một khối nào, kể cả khi kho dựng lại.
     · `Number(v) || 0` phải GIỮ được -1. Đây là chỗ dễ hỏng nhất: viết
       `Number(v) > 0 ? … : 0` là mục mới im lặng rơi về "Mọi khối".
     · Một nguồn luật cho CẢ HAI bảng tuần. Hai bảng chép hai bản của cùng phép
       lọc thì lệch nhau không lỗi nào bật lên — chỉ là hai tập người khác nhau
       cho cùng một ô lọc.

   Chạy:  node production/tinh-thuc-app/thu-loc-coreteam.js
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

const NGUON_BIEN  = catKhoi("let DB_CHE_DO = 'chung';", '/* Người đang đăng nhập có xem được');
const NGUON_THANH = catKhoi('function dbThanhCheDo(){', 'function dbCheDo(ma){');
const NGUON_LOC   = catKhoi('function dbLocKhoi(v){', '/* Nhãn của một buổi trong bảng lịch trình.');

/* Bảy người: 5 lead (trong đó một người KHÔNG có cột `la_lead` — máy chủ chưa
   chạy tệp SQL) và 2 người thường. Hai người mang HAI khối, đúng luật mảng từ
   03/09. */
const DOI_THU = [
  {id:1, ten:'Tracy',  la_lead:true,      chuc_nang_ids:[1]},
  {id:2, ten:'John',   la_lead:true,      chuc_nang_ids:[2,5]},
  {id:3, ten:'Sydney', la_lead:true,      chuc_nang_ids:[6]},
  {id:4, ten:'Hafi',   la_lead:true,      chuc_nang_ids:[4]},
  {id:5, ten:'Andy',                      chuc_nang_ids:[3]},   /* cột chưa có */
  {id:6, ten:'Justin', la_lead:false,     chuc_nang_ids:[4]},
  {id:7, ten:'Vicky',  la_lead:false,     chuc_nang_ids:[2]}
];

const CHUC_NANG_THU = [
  {id:1, ten:'CEO'}, {id:2, ten:'Vận hành'}, {id:3, ten:'Sản phẩm'},
  {id:4, ten:'Kinh doanh'}, {id:5, ten:'Tài chính'},
  {id:6, ten:'Trải nghiệm khách hàng'}
];

const COC = `
let ME = {id: 1, la_dieu_hanh: true};
const CHUC_NANG = ${JSON.stringify(CHUC_NANG_THU)};
const laDieuHanh = () => !!(ME && ME.la_dieu_hanh === true);
const chuSach = s => String(s == null ? '' : s)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
let VE = 0;
/* HAI TÊN CHO CÙNG MỘT CÚ VẼ LẠI. Ô lọc gọi veTimeline khi nó còn nằm trong
   màn Hôm nay; từ 03/09 ba bảng ấy dọn sang màn Vận hành và nó gọi veVanHanh.
   Cọc cả hai để bài thử không phải đoán ô lọc đang đứng ở màn nào.
   KHÔNG DẤU HUYỀN quanh tên hàm ở đây: cả khối này nằm trong một chuỗi mẫu,
   một dấu huyền là đóng chuỗi ngay tại chỗ — đúng cái bẫy thu-cu-phap.js canh. */
function veTimeline(){ VE++; }
function veVanHanh(){ VE++; }
`;

const chay = new Function(COC + NGUON_BIEN + NGUON_THANH + NGUON_LOC + `
  return {
    dbThanhCheDo, dbLocKhoi, dbLocNguoi, dbLocBuoi, dbLoiTrong,
    doc:  () => ({DB_KHOI, DB_CHE_DO, DB_CORE, VE}),
    dat:  (k, v) => { if (k === 'DB_KHOI') DB_KHOI = v; else DB_CHE_DO = v; },
    dieu: c => { ME.la_dieu_hanh = c; }
  };
`)();

let sai = 0, tong = 0;
function la(ten, that, mong){
  tong++;
  const a = JSON.stringify(that), b = JSON.stringify(mong);
  if (a === b) return;
  sai++;
  console.log(`  ✕ ${ten}\n      ra:  ${a}\n      chờ: ${b}`);
}
function dung(ten, dk){ la(ten, !!dk, true); }

console.log('\n① Mã riêng của Coreteam');
dung('DB_CORE là số âm — không đụng mã khối nào', chay.doc().DB_CORE < 0);
dung('không trùng mã khối nào đang có',
     !CHUC_NANG_THU.some(c => c.id === chay.doc().DB_CORE));

console.log('\n② Ô lọc bày đủ mục');
chay.dat('DB_CHE_DO', 'lich');
let html = chay.dbThanhCheDo();
dung('có mục Coreteam', html.includes('>Coreteam</option>'));
dung('có đủ sáu khối',
     CHUC_NANG_THU.every(c => html.includes(`>${c.ten}</option>`)));
dung('Coreteam đứng ngay sau "Mọi khối"',
     html.indexOf('>Coreteam<') > html.indexOf('>Mọi khối<') &&
     html.indexOf('>Coreteam<') < html.indexOf('>CEO<'));
dung('mang đúng mã -1', html.includes('value="-1"'));

console.log('\n③ Ô lọc vẫn ẩn ở bảng Giờ rảnh');
chay.dat('DB_CHE_DO', 'ranh');
dung('không có ô lọc', !chay.dbThanhCheDo().includes('db-loc'));
chay.dat('DB_CHE_DO', 'chung');
dung('bảng Lịch chung thì có', chay.dbThanhCheDo().includes('db-loc'));

console.log('\n④ Người thường không thấy thanh nào');
chay.dieu(false);
la('thanh rỗng', chay.dbThanhCheDo(), '');
chay.dieu(true);

console.log('\n⑤ `Number(v) || 0` giữ được -1');
chay.dbLocKhoi('-1');
la('chọn Coreteam giữ nguyên -1', chay.doc().DB_KHOI, -1);
dung('có vẽ lại dải', chay.doc().VE > 0);
chay.dbLocKhoi('0');
la('chọn Mọi khối về 0', chay.doc().DB_KHOI, 0);
chay.dbLocKhoi('4');
la('chọn một khối giữ mã khối', chay.doc().DB_KHOI, 4);

console.log('\n⑥ Phép lọc người');
chay.dbLocKhoi('0');
la('Mọi khối giữ cả bảy', DOI_THU.filter(chay.dbLocNguoi).map(x => x.ten),
   ['Tracy','John','Sydney','Hafi','Andy','Justin','Vicky']);

chay.dbLocKhoi('-1');
la('Coreteam lấy đúng người mang cờ lead',
   DOI_THU.filter(chay.dbLocNguoi).map(x => x.ten),
   ['Tracy','John','Sydney','Hafi','Andy']);
dung('người chưa có cột `la_lead` vẫn được tính là lead',
     DOI_THU.filter(chay.dbLocNguoi).some(x => x.ten === 'Andy'));
dung('người mang cờ false rơi ra',
     !DOI_THU.filter(chay.dbLocNguoi).some(x => x.ten === 'Justin'));

chay.dbLocKhoi('2');
la('một khối lấy đúng người mang khối ấy trong MẢNG',
   DOI_THU.filter(chay.dbLocNguoi).map(x => x.ten), ['John','Vicky']);
chay.dbLocKhoi('5');
la('khối thứ hai của một người cũng tính',
   DOI_THU.filter(chay.dbLocNguoi).map(x => x.ten), ['John']);

console.log('\n⑦ Câu báo rỗng nói đúng thứ vừa lọc');
chay.dbLocKhoi('-1');
dung('lọc Coreteam thì nhắc cờ lead', /lead/.test(chay.dbLoiTrong()));
chay.dbLocKhoi('3');
la('lọc một khối thì giữ câu cũ', chay.dbLoiTrong(), 'Khối này chưa có ai trong team.');

console.log('\n⑧ Một nguồn luật, không hai bản chép');
const than = catKhoi('function dbVeLich(khu, d, tu, den, ai){', 'async function dbTaiXong(')
           + catKhoi('function dbVeChung(khu, d, tu, den, ai, xong){', 'async function lcGhiThamDu(');
la('không còn chỗ nào chép lại phép lọc khối',
   (than.match(/includes\(DB_KHOI\)/g) || []).length, 0);
/* BỐN bảng từ 05/09 (TRI-119): quãng cắt trên chạy từ `dbVeChung` tới
   `lcGhiThamDu`, và cả `dbVeGio` (lưới giờ 7 ngày) lẫn `dbVeThang` nằm gọn
   trong đó. Mỗi bảng mới cũng phải đi qua đúng cửa lọc ấy chứ không được chép
   lại phép lọc của riêng nó — đó là cả điều ca này canh. */
la('cả bốn bảng cùng gọi `dbLocNguoi`',
   (than.match(/\.filter\(dbLocNguoi\)/g) || []).length, 4);
la('không còn câu báo rỗng chép cứng',
   (than.match(/Khối này chưa có ai/g) || []).length, 0);

console.log('\n⑨ Bảng Lịch chung lọc theo NHÓM NHẬN của buổi');
/* Đúng cảnh trong ảnh Tracy gửi 03/09: một buổi khai cho khối Trải nghiệm
   khách hàng, có mời thêm Sydney · Peter · Andy. Nó ở lại khi đang lọc
   Coreteam chỉ vì Andy mang cờ lead — đó là lỗi phải chữa. */
const BUOI = {
  tnkh:   {pham_vi:'khoi',     chuc_nang_ids:[6], moi:[3,2,5]},
  core:   {pham_vi:'coreteam', chuc_nang_ids:[],  moi:[1,2,3,4,5]},
  congTy: {pham_vi:'cong_ty',  chuc_nang_ids:[],  moi:[1,2,3,4,5,6,7]},
  vanHanh:{pham_vi:'khoi',     chuc_nang_ids:[2], moi:[2,7]},
  hen:    {pham_vi:'ca_nhan',  chuc_nang_ids:[],  moi:[1,5]}
};
const coCua = () => new Set(DOI_THU.filter(chay.dbLocNguoi).map(x => x.id));
const conLai = () => {
  const co = coCua();
  return Object.keys(BUOI).filter(k => chay.dbLocBuoi(BUOI[k], BUOI[k].moi, co));
};

chay.dbLocKhoi('0');
la('Mọi khối giữ đủ năm buổi', conLai(),
   ['tnkh','core','congTy','vanHanh','hen']);

chay.dbLocKhoi('-1');
la('lọc Coreteam: chỉ buổi coreteam và cả công ty ở lại',
   conLai(), ['core','congTy']);
dung('buổi khối Trải nghiệm khách hàng RƠI dù Andy mang cờ lead có dự',
     !conLai().includes('tnkh'));

chay.dbLocKhoi('2');
la('lọc Vận hành: giữ buổi Vận hành + Coreteam + Cả công ty',
   conLai(), ['core','congTy','vanHanh']);

/* BUỔI MỜI ĐÍCH DANH RƠI Ở MỌI Ô LỌC NHÓM, kể cả ô của khối mà người dự
   thuộc về (luật đổi 04/09; ca cũ ở đây chờ điều ngược lại và đã trượt từ
   hôm ấy). Tracy: *"nếu bộ lọc là coreteam thì chỉ hiện những lịch nào của
   coreteam thôi chứ"*. Buổi ấy không khai cho khối nào cả, nên hỏi "có ai
   trong đó thuộc khối đang lọc không" là hỏi sai câu: hai người hay hẹn nhau
   nhất đều là lead, nên câu ấy để lọt mọi cuộc hẹn của họ vào ô Coreteam. */
dung('lọc Vận hành: buổi mời đích danh rơi', !conLai().includes('hen'));

chay.dbLocKhoi('1');
dung('lọc CEO: buổi mời đích danh vẫn rơi, dù Tracy thuộc khối CEO có dự',
     !conLai().includes('hen'));

chay.dbLocKhoi('0');
dung('và ở "Mọi khối" thì nó trở lại — nó là việc của công ty, chỉ mời riêng',
     conLai().includes('hen'));

console.log('\n⑩ `dbBuoiCuaDai` đi qua đúng một cửa lọc');
const dai = catKhoi('function dbBuoiCuaDai(d, ngays, ai, xong){', 'function dbVeChung(');
la('gọi `dbLocBuoi`', (dai.match(/dbLocBuoi\(/g) || []).length, 1);
la('không còn chép tay phép lọc theo người dự',
   (dai.match(/b\.moi\.some/g) || []).length, 0);
/* HAI CỬA LỌC, HAI CÂU HỎI KHÁC NHAU (05/09). Lịch cá nhân hỏi cột `rieng_tu`
   — ô Loại của cửa khai, tức *buổi này là chuyện gì*; nhóm nhận hỏi `pham_vi`
   — ô Đối tượng, tức *ai nhận*. Ca này ghim đúng chỗ ấy: hàm phải gọi
   `dbBoRiengTu`, và không được lọc lịch cá nhân bằng `pham_vi` nữa. */
dung('lịch cá nhân lọc qua `dbBoRiengTu`', dai.includes('dbBoRiengTu(l)'));
la('chỉ còn MỘT chỗ hỏi `pham_vi`, và nó hỏi cho ô lọc nhóm',
   (dai.match(/pham_vi/g) || []).length, 1);

console.log(`\n${sai ? '❌' : '✅'} ${tong - sai}/${tong} ca đạt\n`);
process.exit(sai ? 1 : 0);
