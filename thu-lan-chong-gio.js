/* THỬ: KHỐI TRÙNG GIỜ PHẢI CHIA CỘT, KHÔNG ĐÈ LÊN NHAU (TRI-129)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09, kèm ảnh nấc Ngày: *"ở view ngày nếu mà có các việc/sự kiện trùng
   giờ nhau thì phải chia thành các cột như view tuần chứ sao để đè lên nhau
   vậy"*.

   Chẩn ra KHÔNG PHẢI thiếu mã chia cột — `tlgXepLan` vẫn chạy cho cả hai nấc, và
   nấc Tuần hỏng y hệt, chỉ vì cột hẹp nên không ai để ý. Gốc là khối được NỚI
   CHIỀU CAO ở hai chỗ (`veKhoi` sàn 0,58 giờ · `.tlg-viec{min-height:24px}`) mà
   phép chia làn thì dò chồng theo GIỜ THẬT. Hai việc 15 phút nối đuôi nhau đọc
   ra là "không chồng", cùng một làn, cùng bề ngang 100%, và khối sau phủ lên
   khối trước.

   Nên bài này KHÔNG hỏi `lan`/`tongLan` bằng đâu. Nó đo cái người dùng thật sự
   nhìn thấy: dựng lưới thật, đọc `style` của từng khối, quy ra HÌNH CHỮ NHẬT
   bằng pixel, rồi hỏi có hai hình nào chồng lên nhau không. Đo `tongLan` là đo
   lại đúng cái đại lượng đã nói dối một lần rồi.

   ⚠️ CA ④ CANH CHIỀU NGƯỢC LẠI. Một cái sàn quá rộng thì chữa hết đè nhưng chia
   đôi bề ngang cả những khối cách nhau cả tiếng — hỏng theo kiểu khó thấy hơn.

   ⚠️ CA ⑤ canh một cái bẫy của chính chỗ gọi: `cot.forEach(tlgXepLan)` trao
   CHỈ SỐ cột vào chỗ `sanPhut`, nên bảy cột chạy bảy luật khác nhau và cột đầu
   thì y như chưa sửa. Nó không làm lưới trông sai ngay, nên chỉ có máy bắt được.

   Bài thử CẮT KHỐI GỐC ra khỏi `public/index.html` rồi chạy trên dữ liệu giả —
   không chép tay một dòng logic nào sang đây.

   Chạy:  node production/tinh-thuc-app/thu-lan-chong-gio.js
   Soi bản cũ:
     git show HEAD:production/tinh-thuc-app/public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-lan-chong-gio.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

/* Cắt một hàm top-level: từ `function ten(` tới dấu } đứng một mình ở cột 0. */
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

const NGUON = [
  catDong('const tlgHHMM = p =>'),
  catDong('const mauSuKien'), catDong('const mauViec'),
  /* Hai hằng sàn đi kèm hàm — cắt cả dòng khai, vì chính chúng là thứ đang thử. */
  catDong('const TLG_SAN_NGAY'),
  catHam('phutDeadline'), catHam('tlgLucVN'), catHam('tlgKhoangTask'),
  catHam('tlgXepLan'), catHam('tlgKhoiPhien'), catHam('tlgThanLuoi'),
].join('\n');

const COC = `
let TLG_VIEC = {};
let TLG_KHO_MO = false;
const TLG_THU = ['T2','T3','T4','T5','T6','T7','CN'];
const chuSach = t => String(t == null ? '' : t)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const homNay = () => '2026-09-05';
const laCN = () => false;
const lcCuaNgay = () => (MOI.buoi || []);
const lcCuaNgayVe = g => lcCuaNgay(g);
const daTre = () => false;
const LC_HIEN = [];
const lcDaiCuaKhung = () => [];
const tlgDaiChuaGio = () => '';
const tlgDaiCaNgay = () => '';
const tlgDaiKho = () => '';
const tlTenPhien = (p) => 'Phien ' + p.id;
const dwDongDuoc = () => true;
let dwPhien = null;
`;

const chay = new Function('MOI', COC + '\n' + NGUON + `
  return tlgThanLuoi(MOI.ngays, MOI.phien || [], MOI.tasks || [], [], [], null,
                     MOI.nac || 'ngay');
`);

/* ── đọc hình chữ nhật thật của từng khối ────────────────────────────────
   `veKhoi` phát ra đúng một khuôn `style`; đọc lại chính nó thay vì tính lại
   theo trí nhớ. Vạch nối (`.tlg-dw-noi`) không khai `width` nên tự rơi ra
   ngoài — đúng ý, một sợi chỉ 2px không giành chỗ với ai.                   */
const RE = /top:calc\(([\d.]+) \* var\(--tlg-h\)\);height:calc\(([\d.]+) \* var\(--tlg-h\) - 2px\);\s*left:([\d.]+)%;width:calc\(([\d.]+)% - 3px\)"\s*data-tu="(\d+)" data-den="(\d+)"/g;

function khoiCua(html, H){
  const ds = [];
  let m;
  RE.lastIndex = 0;
  while ((m = RE.exec(html))){
    const [, t, h, trai, rong, tu, den] = m;
    ds.push({
      top:  +t * H,
      /* `min-height:24px` của CSS là một phần của hình khối, không phải trang
         trí — bỏ nó ra khỏi phép đo là đo một cái lưới không tồn tại. */
      day:  +t * H + Math.max(+h * H - 2, 24),
      trai: +trai, rong: +rong,
      tu: +tu, den: +den
    });
  }
  return ds;
}

const gio = p => String(Math.floor(p/60)).padStart(2,'0') + ':' + String(p%60).padStart(2,'0');

/* Hai khối đè nhau khi chồng cả chiều dọc lẫn chiều ngang. Nới 0,5px và 0,01%
   để một mép chạm mép không bị kêu oan. */
function capDe(ds){
  const de = [];
  for (let a = 0; a < ds.length; a++) for (let b = a+1; b < ds.length; b++){
    const A = ds[a], B = ds[b];
    if (A.top < B.day - 0.5 && B.top < A.day - 0.5
     && A.trai < B.trai + B.rong - 0.01 && B.trai < A.trai + A.rong - 0.01)
      de.push(`${gio(A.tu)}–${gio(A.den)} × ${gio(B.tu)}–${gio(B.den)}`);
  }
  return de;
}

/* ── dữ liệu giả ─────────────────────────────────────────────────────────── */
const NGAY = '2026-09-05';
const viec = (id, tu, den) => ({id, noi_dung:'Viec ' + id, ngay:NGAY,
  gio_start:tu, gio_end:den, trang_thai:'Doing', mau:''});
const buoi = (id, tu, den) => ({lich:id, ngay:NGAY, ten:'Buoi ' + id, mau:'',
  chot:true, tu, den, doi:false, lap:'', sua:true, khoi:false, nhan:0, toi:null,
  viec:null, xong:false});

/* Đúng bốn khối trong ảnh Tracy gửi: hai việc 15 phút nối đuôi nhau, một việc
   15 phút chạm mép một cuộc họp một tiếng. Không cặp nào chồng giờ THẬT. */
const ANH = () => ({
  ngays:[NGAY],
  tasks:[viec(1,'15:30','15:45'), viec(2,'15:45','16:00'), viec(3,'16:45','17:00')],
  buoi:[buoi(9, 17*60, 18*60)]
});

const KQ = [];
const ok = (ten, dat, chiTiet) => { KQ.push({ten, dat, chiTiet}); };

/* ── 1 · nấc NGÀY, đúng cảnh trong ảnh ──────────────────────────────────── */
{
  const h = chay(ANH());
  [['màn hẹp', 52], ['màn rộng', 64]].forEach(([ten, H]) => {
    const ds = khoiCua(h, H);
    const de = capDe(ds);
    ok(`① nấc Ngày ${ten}: đủ bốn khối`, ds.length === 4, ds.length + ' khối');
    ok(`① nấc Ngày ${ten}: không khối nào đè khối nào`, de.length === 0, de.join(' · '));
  });
  ok('① nấc Ngày: hai việc nối đuôi được chia hai cột',
     /width:calc\(50% - 3px\)/.test(h) && /left:50%/.test(h));
  ok('① nấc Ngày: giờ THẬT của khối không bị nới theo sàn',
     /data-tu="930" data-den="945"/.test(h) && /data-tu="1005" data-den="1020"/.test(h));
}

/* ── 2 · nấc TUẦN mắc cùng bệnh, chữa cùng lúc ──────────────────────────── */
{
  const h = chay({...ANH(), nac:'tuan'});
  [['màn hẹp', 38], ['màn vừa', 46], ['màn rộng', 58]].forEach(([ten, H]) => {
    const de = capDe(khoiCua(h, H));
    ok(`② nấc Tuần ${ten}: không khối nào đè khối nào`, de.length === 0, de.join(' · '));
  });
}

/* ── 3 · việc CHỒNG GIỜ THẬT vẫn chia cột như cũ (không hồi quy) ────────── */
{
  const h = chay({ngays:[NGAY],
    tasks:[viec(1,'09:00','11:00'), viec(2,'10:00','12:00')]});
  ok('③ chồng giờ thật: chia đúng hai cột',
     /width:calc\(50% - 3px\)/.test(h) && /left:50%/.test(h));
  ok('③ chồng giờ thật: không cặp nào đè', capDe(khoiCua(h, 64)).length === 0);
}

/* ── 4 · CHIỀU NGƯỢC LẠI: cách xa nhau thì ĐỪNG chia ────────────────────── */
{
  /* 15:00–15:15 rồi 16:30–17:00 — mắt thấy rõ hai khối rời nhau. Sàn rộng tay
     là chia đôi bề ngang cả những cặp thế này, hỏng theo kiểu khó thấy hơn. */
  const h = chay({ngays:[NGAY],
    tasks:[viec(1,'15:00','15:15'), viec(2,'16:30','17:00')]});
  ok('④ cách xa nhau: cả hai giữ trọn bề ngang',
     !/width:calc\(50% - 3px\)/.test(h),
     (h.match(/width:calc\([\d.]+% - 3px\)/g) || []).join(' · '));
}

/* ── 5 · BẪY forEach ở chỗ gọi ──────────────────────────────────────────── */
{
  /* Dò DẤU CHẤM PHẨY, không dò riêng lời gọi: chính khối chú thích cảnh báo ở
     chỗ gọi cũng viết ra `cot.forEach(tlgXepLan)` để kể lại cái bẫy, nên một
     mẫu trần sẽ bắt oan đúng dòng đang bảo vệ mình. */
  ok('⑤ chỗ gọi KHÔNG trao chỉ số cột vào chỗ sàn',
     !/cot\.forEach\(tlgXepLan\)\s*;/.test(SRC));
  ok('⑤ chỗ gọi truyền sàn theo nấc',
     /cot\.forEach\(ds => tlgXepLan\(ds, san\)\)/.test(SRC)
     && /const san = laNgay \? TLG_SAN_NGAY : TLG_SAN_TUAN;/.test(SRC));
}

/* ── 6 · TÁI DÙNG LÀN vẫn còn (luật cũ, đừng đánh mất) ──────────────────── */
{
  /* Một việc dài 9h–17h cộng ba việc ngắn rải rác. Bản đầu của `tlgXepLan` cho
     mỗi khối một làn mới, nên bốn việc chẳng cái nào chạm nhau vẫn co lại còn
     một phần tư bề ngang. Sàn mới không được lôi luật ấy đi theo. */
  const h = chay({ngays:[NGAY], tasks:[
    viec(1,'09:00','17:00'), viec(2,'09:30','09:45'),
    viec(3,'12:00','12:15'), viec(4,'15:00','15:15')]});
  ok('⑥ tái dùng làn: bốn khối chỉ chia HAI cột, không phải bốn',
     /width:calc\(50% - 3px\)/.test(h) && !/width:calc\(25% - 3px\)/.test(h),
     (h.match(/width:calc\([\d.]+% - 3px\)/g) || []).join(' · '));
}

/* ── 7 · lưới Bảng đội gọi một tham số → giữ nguyên hành vi cũ ──────────── */
{
  ok('⑦ lưới Bảng đội vẫn gọi `tlgXepLan` một tham số',
     /ngays\.map\(g => tlgXepLan\(/.test(SRC));
  const f = new Function(catHam('tlgXepLan') + `
    const ds = [{tu:900, den:915}, {tu:915, den:930}];
    tlgXepLan(ds);
    return ds.map(k => k.tongLan).join(',');
  `);
  ok('⑦ bỏ trống sàn thì chạy y như trước (hai khối nối đuôi = một làn)',
     f() === '1,1', f());
}

/* ── bảng điểm ──────────────────────────────────────────────────────────── */
let dat = 0;
KQ.forEach(k => {
  if (k.dat) dat++;
  console.log((k.dat ? '  ✅ ' : '  ❌ ') + k.ten + (k.chiTiet ? '   → ' + k.chiTiet : ''));
});
console.log(`\n${dat}/${KQ.length} đạt`);
process.exit(dat === KQ.length ? 0 : 1);
