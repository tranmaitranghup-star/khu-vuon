/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ MÀN DỌN — cửa MỞ ngày (🧹 Dọn việc hôm qua) và cửa ĐÓNG ngày
   (🌾 Nghi thức hoàn tất). Hai chế độ chạy trên cùng một bộ máy.
   Chạy:  node thu-man-don.js        (đứng ở thư mục production/tinh-thuc-app)
   Mọi dòng phải ✅. Không cần đăng nhập, không đụng máy chủ thật — mọi lệnh
   gửi lên Supabase đều bị bắt lại trong bộ nhớ rồi đem ra soi.

   Nó tự LÁT các khối logic ra khỏi public/index.html, nên sửa app xong chạy
   lại là biết ngay có gãy chỗ nào không. Nếu đổi tên hàm hay đổi mốc lát thì
   sửa mảng MOC bên dưới.

   VIẾT LẠI 13/08. Bản trước đo một màn Dọn đã không còn tồn tại: nó gọi
   `donHanhDong(id, hanhDong)` hai tham số (nay một), gọi `donThayTask` (cửa
   "Thay bằng việc khác" đã gỡ 12/08), và chờ các trạng thái `Nghen`/`Miss` đã
   đổi tên thành `Blocked`/bỏ hẳn. Nó còn chết ngay dòng đầu vì ô ghi chú thành
   khối soạn được (`richKhai`) hôm 13/08. Một bộ thử chết nằm trong kho hại hơn
   không có: lần sau chạy ra ❌ thì không ai biết đâu là lỗi thật.
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const MOC = [
  ['const TT_NHAN = {',                      '\n/* Trạng thái CÒN MỞ'],
  ['function oNgay(id, nhan, them, giaTri){', '\nfunction moLich('],
  ['function chuSach(s){',                   '\n'],
  ['function tenViecGoNghen(chu){',          '\n\n'],
  ['const DON_TT = [',                       '\nfunction moTab(']
];
const nguon = MOC.map(([a, b]) => {
  const i = s.indexOf(a);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + a);
  return s.slice(i, s.indexOf(b, i));
}).join('\n');

/* DOM giả: các lát mã trên chỉ tính, phần chạm màn của chúng là nhánh vẽ lại.
   Không có màn nào ở đây nên trả rỗng — TRỪ chính màn `#don`: `kiemDon` đọc
   `classList` của nó để mở/đóng, nên nó cần một cái vỏ ghi lại được. */
const manDon = {classList: {tap: new Set(),
  add(c){ this.tap.add(c); }, remove(c){ this.tap.delete(c); },
  contains(c){ return this.tap.has(c); }}};
const document = {getElementById: id => id === 'don' ? manDon : null,
                  querySelector: () => null,
                  querySelectorAll: () => [], addEventListener: () => {},
                  removeEventListener: () => {}};
let ME = {id: 'toi'};
let DON_TAM = {}, NO_CU = [];
let GHI = [];            // mọi lệnh gửi lên máy chủ bị bắt lại ở đây
/* Ngày hôm nay ĐỔI ĐƯỢC giữa các ca: mặc định của cửa tối là ngày làm kế tiếp,
   nên phải thử được cả ca "tối thứ Bảy → nhảy qua Chủ nhật". 13/08/2026 là thứ
   Năm, 15/08 là thứ Bảy. */
let HOM_NAY = '2026-08-13';
const homNay = () => HOM_NAY;
/* Ba tiện ích ngày của app, nằm ngoài lát mã nên phải khai lại ở đây — bản thật,
   không phải bản giả: `donNgayMoi` tính mặc định bằng chúng. */
const d2s = d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
const rvCong = (ds, n) => { const d = new Date(ds+'T00:00:00'); d.setDate(d.getDate()+n); return d2s(d); };
const rvChuNgay = g => g.slice(8,10)+'/'+g.slice(5,7);
const laCN = g => new Date(g+'T00:00:00').getDay() === 0;
/* Việc của hôm nay mà `htGomViec` gom vào danh sách nghi thức. */
const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];
let TASKS = [], DA_CHOT_QUA = false;
const timO = ma => ma ? {ma, ten: 'Cam kết ' + ma} : null;
const toast = m => GHI.push({loai: 'toast', m});
/* Phiên deepwork đi theo trạng thái việc (TRI-126): mọi cửa ghi trạng thái nay
   gọi hàm này để khép phiên đang chạy cho đúng việc ấy. Bản thật chạm máy chủ
   và màn 💧 — ở đây chỉ cần bắt lại lần gọi, để phép thử soi được nếu cần. */
const dwTheoTrangThai = async (id, tt) => { GHI.push({loai:'dw-theo-tt', id, tt}); };
/* Ô ghi chú là khối soạn được từ 13/08 — ba hàm dưới đụng DOM thật, ở đây chỉ
   cần chúng không ném lỗi. `chuSoanDuoc` trả lại nguyên văn để phép thử còn
   soi được chữ điền sẵn. */
/* `boCuPhapLink` ra đời 13/08 ở một nhánh khác (mốc 1ae8c28): nó gỡ cú pháp
   [tên](địa chỉ) khỏi TÊN việc gỡ nghẽn. Ở đây chỉ cần nó không ném lỗi —
   hành vi thật của nó không thuộc phạm vi bộ thử này. */
const boCuPhapLink = s => String(s ?? '').trim();
const richKhai = () => {}, richPhim = () => {}, richDan = () => {}, richLuu = () => {};
const chuSoanDuoc = v => String(v == null ? '' : v);
const sb = {
  from: bang => ({
    insert: rows => { GHI.push({loai:'insert', bang, rows}); return Promise.resolve({error:null}); },
    update: patch => ({ eq: (_c, id) => { GHI.push({loai:'update', bang, id, patch}); return Promise.resolve({error:null}); } })
  })
};
/* `DON_KIEU` khai bằng `let` BÊN TRONG khối vừa lát, nên nó nằm trong phạm vi
   của eval — gán từ ngoài không tới được nó. Nối thêm một cái cần gạt để phép
   thử đổi được chế độ sáng/tối. */
eval(nguon + `
  globalThis.__datDonKieu = v => { DON_KIEU = v; };
  globalThis.__ht = {
    mo:     () => htMo(),
    gom:    () => htGomViec(),
    kiem:   () => kiemDon(),
    daDon:  () => HT_DA_DON,
    guong:  v  => { HT_GUONG = v; }
  };`);
const datDonKieu = v => globalThis.__datDonKieu(v);
const ht = () => globalThis.__ht;
veDon = () => {};        // bản thật đụng DOM, ở đây không cần

let hong = 0;
function kiem(ten, dat, them){
  console.log((dat ? '✅ ' : '❌ ') + ten + (dat || !them ? '' : '\n      → ' + them));
  if (!dat) hong++;
}
const viec = (them = {}) => Object.assign({
  id: 7, noi_dung: 'Gọi 40 khách list A', tieu_diem_ma: 'L1', trang_thai: 'Chua_lam',
  so_ngay_delay: 2, so_lan_hoan: 0, het_cua_hen_ngay: false, da_chot: false, ghi_chu_chot: ''
}, them);

console.log('\n── VẼ MÀN ──');
DON_TAM = {7: {tt: 'Chua_xong'}};
let h = veDonDong(viec());
/* Từ 16/08 ô ngày ĐIỀN SẴN hôm nay (`donNgayHen` trả `tam.ngay ?? homNay()`),
   nên "về kho" thôi là chuyện bỏ trống một ô — nó thành một NÚT tường minh
   đứng cạnh ô ngày. Bộ thử này còn đòi hình dạng trước 16/08 nên đỏ oan; sửa
   theo bản đang chạy 28/08, và giữ nguyên độ phủ bằng cách soi CẢ HAI nhánh. */
kiem('Chưa xong + ngày điền sẵn hôm nay → có nút 📦 về kho đứng cạnh',
     h.includes('📦 về kho') && h.includes('ngày sẽ làm'));
DON_TAM = {7: {tt: 'Chua_xong', ngay: ''}};
kiem('Xoá trắng ô ngày → nút chính đổi thành "Lưu và về kho"',
     veDonDong(viec()).includes('📦 Lưu và về kho'));
DON_TAM = {7: {tt: 'Chua_xong'}};
kiem('Chưa xong có ô "có người đang chờ"', h.includes('Có người đang chờ'));
kiem('Không còn hỏi "mai làm gì"', !h.includes('Mai làm gì'));
kiem('Không còn nút Chia nhỏ', !h.includes('Chia nhỏ') && !h.includes('✂️'));

DON_TAM = {7: {tt: 'Chua_xong', ngay: '2026-08-14'}};
h = veDonDong(viec());
kiem('Chọn 14/08 → nút đổi thành "Lưu và hẹn 14/08"', h.includes('▶️ Lưu và hẹn 14/08'));

DON_TAM = {7: {tt: 'Chua_xong'}};
h = veDonDong(viec({so_lan_hoan: 3, het_cua_hen_ngay: true}));
kiem('Hoãn 3 lần → mất ô chọn ngày, nút chỉ còn Về kho',
     !h.includes('type="date"') && h.includes('📦 Lưu và về kho'));
kiem('Hoãn 3 lần → có nói rõ vì sao', h.includes('chỉ về kho được'));

DON_TAM = {};
h = veDonDong(viec({trang_thai: 'Blocked', da_chot: true, ghi_chu_chot: 'chờ sếp duyệt giá'}));
kiem('Nghẽn hỏi lại sáng sau → ô điền sẵn câu đã trả lời', h.includes('chờ sếp duyệt giá'));
kiem('Cửa Nghẽn → nút "Lưu và tạo việc gỡ chặn"', h.includes('Lưu và tạo việc gỡ chặn'));

console.log('\n── Ô DEADLINE CHO VIỆC GỠ NGHẼN (13/08) ──');
DON_TAM = {7: {tt: 'Blocked'}};
h = veDonDong(viec());
kiem('Cửa Nghẽn có ô Deadline', h.includes('don-hango-7') && h.includes('>Deadline<'));
kiem('Ô để trống → nhắc đúng ngày mặc định (13/08)', h.includes('mặc định thì sẽ là 13/08'));

DON_TAM = {7: {tt: 'Blocked', han_go: '2026-08-15'}};
h = veDonDong(viec());
kiem('Chọn 15/08 → ô hiện 15/08', h.includes('>15/08<'));
kiem('Nút đổi chữ theo hạn', h.includes('Lưu và tạo việc gỡ — hạn 15/08'));

DON_TAM = {7: {tt: 'Chua_xong'}};
kiem('Cửa Chưa xong KHÔNG có ô Deadline', !veDonDong(viec()).includes('don-hango-7'));
DON_TAM = {7: {tt: 'Done'}};
kiem('Cửa Xong KHÔNG có ô Deadline', !veDonDong(viec()).includes('don-hango-7'));
DON_TAM = {7: {tt: 'Da_huy'}};
kiem('Cửa Dừng KHÔNG có ô Deadline', !veDonDong(viec()).includes('don-hango-7'));

console.log('\n── CHỮ TRÊN MÀN ──');
datDonKieu('sang');
kiem('Buổi sáng hỏi bằng cụm danh từ "Kết quả hôm qua"',
     veDonDong(viec()).includes('Kết quả hôm qua'));
datDonKieu('toi');
kiem('Buổi tối hỏi "Kết quả hôm nay"', veDonDong(viec()).includes('Kết quả hôm nay'));
datDonKieu('sang');

(async () => {
  console.log('\n── GỬI LÊN MÁY CHỦ ──');
  const chay = async tam => {
    GHI = []; NO_CU = [viec()]; DON_TAM = {7: tam};
    await donHanhDong(7);
    return {
      con: (GHI.find(g => g.loai === 'insert') || {}).rows || [],
      cha: (GHI.find(g => g.loai === 'update') || {}).patch || null,
      thu: GHI
    };
  };

  let r = await chay({tt: 'Chua_xong', ngay: '2026-08-14'});
  kiem('Chưa xong + có ngày → hẹn đúng ngày, cộng một lần hoãn, xoá chot_luc',
       r.cha && r.cha.trang_thai === 'Chua_xong' && r.cha.ngay === '2026-08-14'
         && r.cha.so_lan_hoan === 1 && r.cha.chot_luc === null, JSON.stringify(r.cha));

  /* `ngay: ''` chứ không bỏ trống khoá: từ 16/08 ô ngày điền sẵn hôm nay, nên
     "về kho" là một cú bấm tường minh (`donNgay(id, '')`), không phải chuyện
     không đụng vào ô. */
  r = await chay({tt: 'Chua_xong', ngay: ''});
  kiem('Chưa xong + bấm về kho → ngay = null, vẫn cộng một lần hoãn',
       r.cha && r.cha.ngay === null && r.cha.so_lan_hoan === 1, JSON.stringify(r.cha));

  r = await chay({tt: 'Chua_xong'});
  kiem('Chưa xong + không đụng ô ngày → hẹn HÔM NAY, không lẳng lặng về kho',
       r.cha && r.cha.ngay === homNay(), JSON.stringify(r.cha));

  r = await chay({tt: 'Chua_xong', co_nguoi_cho: true});
  kiem('Tick "có người đang chờ" → đẻ việc báo lại, hẹn HÔM NAY',
       r.con[0] && r.con[0].noi_dung.startsWith('Báo lại người đang chờ')
         && r.con[0].ngay === '2026-08-13' && r.con[0].task_cha === 7);

  r = await chay({tt: 'Done', ghi_chu: 'đã chốt hợp đồng'});
  kiem('Xong → Done, có xong_luc, giữ nguyên output vừa gõ',
       r.cha && r.cha.trang_thai === 'Done' && !!r.cha.xong_luc
         && r.cha.ghi_chu_chot === 'đã chốt hợp đồng');

  r = await chay({tt: 'Da_huy', ghi_chu: 'khách đổi ý'});
  kiem('Dừng → Da_huy, có lý do, có chot_luc',
       r.cha && r.cha.trang_thai === 'Da_huy' && r.cha.ghi_chu_chot === 'khách đổi ý'
         && !!r.cha.chot_luc);

  r = await chay({tt: 'Blocked', ghi_chu: ''});
  kiem('Nghẽn không gõ tên việc gỡ → giữ lại, không gửi gì lên máy chủ',
       !r.thu.some(g => g.loai === 'insert' || g.loai === 'update')
         && r.thu.some(g => g.loai === 'toast'));

  r = await chay({tt: 'Blocked', ghi_chu: 'Xin chị Hà duyệt ngân sách'});
  kiem('Nghẽn → đẻ việc gỡ cho HÔM NAY, cha VẪN SỐNG ở ô Blocked',
       r.con[0] && r.con[0].ngay === '2026-08-13'
         && r.cha && r.cha.trang_thai === 'Blocked' && !!r.cha.chot_luc);
  kiem('Tên việc gỡ đúng khuôn dùng chung "🚧 Gỡ nghẽn: "',
       r.con[0] && r.con[0].noi_dung.startsWith('🚧 Gỡ nghẽn: '));
  kiem('Con tạo TRƯỚC, cha đóng SAU (trigger kiem_da_chuyen bắt thứ tự này)',
       r.thu.findIndex(g => g.loai === 'insert') < r.thu.findIndex(g => g.loai === 'update'));

  r = await chay({tt: 'Blocked', ghi_chu: 'Xin chị Hà duyệt ngân sách', han_go: '2026-08-15'});
  kiem('Nghẽn + chọn hạn → việc gỡ hẹn ĐÚNG 15/08', r.con[0] && r.con[0].ngay === '2026-08-15',
       JSON.stringify(r.con));

  r = await chay({tt: 'Blocked', ghi_chu: 'Chờ duyệt', han_go: '2026-08-15', co_nguoi_cho: true});
  const goNghen = r.con.find(c => c.noi_dung.startsWith('🚧'));
  const baoLai  = r.con.find(c => c.noi_dung.startsWith('Báo lại'));
  kiem('Hai con khác hạn nhau: việc gỡ 15/08, việc báo lại vẫn hôm nay',
       goNghen && baoLai && goNghen.ngay === '2026-08-15' && baoLai.ngay === '2026-08-13',
       JSON.stringify(r.con));

  /* ══ NGÀY MẶC ĐỊNH THEO CHẾ ĐỘ (Tracy chốt 06/09) ══════════════════════════
     Cửa sáng hẹn HÔM NAY, cửa tối hẹn NGÀY LÀM KẾ TIẾP. Ba chỗ phải cùng một
     luật: ô ngày điền sẵn, chữ trên nút Lưu, và thứ chạy xuống máy chủ. */
  console.log('\n── NGÀY MẶC ĐỊNH THEO CHẾ ĐỘ (06/09) ──');

  datDonKieu('toi');
  /* Phải chọn sẵn một cửa: phần ô ngày chỉ vẽ ra khi đã có trạng thái. */
  DON_TAM = {7: {tt: 'Chua_xong'}}; NO_CU = [];
  let ht2 = veDonDong(viec());
  kiem('Cửa tối: ô ngày điền sẵn NGÀY MAI (14/08), không phải hôm nay',
       ht2.includes('>14/08<') && !ht2.includes('>13/08<'), ht2.match(/>\d\d\/\d\d</g));
  kiem('Cửa tối: nút Lưu nói đúng ngày mai', ht2.includes('▶️ Lưu và hẹn 14/08'));

  DON_TAM = {7: {tt: 'Blocked'}};
  kiem('Cửa tối: hạn việc gỡ để trống → nhắc 14/08',
       veDonDong(viec()).includes('mặc định thì sẽ là 14/08'));

  /* Tối thứ Bảy: mai là Chủ nhật, mà cả app coi Chủ nhật là ngày nghỉ (`laCN`
     bỏ nó khỏi mẫu số và khỏi phép chấm) — nên bước tiếp sang thứ Hai. */
  HOM_NAY = '2026-08-15';
  DON_TAM = {7: {tt: 'Chua_xong'}};
  ht2 = veDonDong(viec());
  kiem('Cửa tối thứ Bảy: nhảy qua Chủ nhật, hẹn thứ Hai 17/08',
       ht2.includes('>17/08<') && ht2.includes('▶️ Lưu và hẹn 17/08'), ht2.match(/>\d\d\/\d\d</g));
  HOM_NAY = '2026-08-13';

  r = await chay({tt: 'Chua_xong'});
  kiem('Cửa tối: thứ chạy xuống máy chủ cũng là 14/08, không lệch với nút',
       r.cha && r.cha.ngay === '2026-08-14', JSON.stringify(r.cha));

  r = await chay({tt: 'Chua_xong', co_nguoi_cho: true});
  kiem('Cửa tối: việc báo lại người đang chờ cũng hẹn 14/08',
       r.con[0] && r.con[0].ngay === '2026-08-14', JSON.stringify(r.con));

  r = await chay({tt: 'Blocked', ghi_chu: 'Xin chị Hà duyệt ngân sách'});
  kiem('Cửa tối: việc gỡ nghẽn để trống hạn → hẹn 14/08',
       r.con[0] && r.con[0].ngay === '2026-08-14', JSON.stringify(r.con));

  datDonKieu('sang');
  r = await chay({tt: 'Chua_xong'});
  kiem('Cửa sáng KHÔNG đổi: vẫn hẹn hôm nay 13/08',
       r.cha && r.cha.ngay === '2026-08-13', JSON.stringify(r.cha));

  /* ══ LƯU MỘT VIỆC KHÔNG ĐƯỢC ĐÓNG CỬA SỔ (Tracy 06/09) ════════════════════
     `kiemDon` chạy ở cuối `taiHomNay`, và từ đợt kênh tin máy chủ 03/09 thì
     mỗi cú lưu tự gọi nó về. Nó phải KHÔNG chạm màn khi nghi thức đang mở. */
  console.log('\n── LƯU MỘT VIỆC KHÔNG ĐÓNG CỬA SỔ (06/09) ──');

  TASKS = [viec({id: 11, noi_dung: 'Việc A của hôm nay', ngay: '2026-08-13'}),
           viec({id: 12, noi_dung: 'Việc B của hôm nay', ngay: '2026-08-13'}),
           viec({id: 13, noi_dung: 'Việc đã xong',  ngay: '2026-08-13', trang_thai: 'Done'}),
           viec({id: 14, noi_dung: 'Việc của mai',  ngay: '2026-08-14'})];
  NO_CU = [];
  ht().mo();
  kiem('Mở nghi thức: gom việc hôm nay còn mở, bỏ việc đã xong và việc của mai',
       NO_CU.length === 2 && NO_CU.every(t => [11, 12].includes(t.id)),
       NO_CU.map(t => t.id).join(','));
  kiem('Mở nghi thức: màn hiện lên', manDon.classList.contains('hien'));

  /* Lưu việc 11 xong thì `taiHomNay` dựng lại `NO_CU` từ nợ cũ — ở đây là rỗng
     — rồi gọi `kiemDon`. Bản cũ đóng màn ngay tại đây. */
  DON_TAM = {11: {tt: 'Chua_xong', ngay: '2026-08-14'}};
  await donHanhDong(11);
  kiem('Đã lưu một việc → nó vào sổ đã dọn', ht().daDon().has(11));
  NO_CU = [];                                    // taiHomNay: nợ cũ rỗng
  ht().kiem();
  kiem('Sau cú lưu, cửa nghi thức VẪN MỞ', manDon.classList.contains('hien'));
  kiem('Sau cú lưu, việc chưa dọn được bày lại (còn việc B)',
       NO_CU.length === 1 && NO_CU[0].id === 12, NO_CU.map(t => t.id).join(','));
  kiem('Việc đã trả lời KHÔNG hỏi lại lần hai', !NO_CU.some(t => t.id === 11));

  /* Việc 11 vừa được hẹn lại sang mai nên TASKS thật cũng đổi — kể cả khi nó
     còn nằm ở hôm nay với trạng thái mở, sổ đã dọn vẫn phải giữ nó ngoài. */
  TASKS = TASKS.map(t => t.id === 11 ? Object.assign({}, t, {trang_thai: 'Chua_xong'}) : t);
  NO_CU = [];
  ht().kiem();
  kiem('Việc mở lại ở hôm nay vẫn không quay về danh sách nghi thức',
       NO_CU.length === 1 && NO_CU[0].id === 12, NO_CU.map(t => t.id).join(','));

  /* Tấm gương cuối ngày đang hiện thì một lượt tải lại không được vẽ đè lên. */
  ht().guong(true);
  NO_CU = [];
  ht().kiem();
  kiem('Tấm gương đang hiện → lượt tải lại không dựng lại danh sách',
       NO_CU.length === 0, NO_CU.map(t => t.id).join(','));
  ht().guong(false);

  /* Màn SÁNG giữ nguyên nết cũ: hết nợ cũ thì đóng. */
  datDonKieu('sang');
  NO_CU = [];
  ht().kiem();
  kiem('Màn sáng hết nợ cũ → vẫn đóng như cũ', !manDon.classList.contains('hien'));

  console.log(hong ? `\n❌ ${hong} mục chưa đạt\n` : '\n✅ Tất cả đều đạt\n');
  process.exit(hong ? 1 : 0);
})();
