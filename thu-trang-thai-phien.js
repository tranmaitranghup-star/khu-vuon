/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ TRẠNG THÁI QUANH MỘT PHIÊN DEEPWORK
   Chạy:  node thu-trang-thai-phien.js   (đứng ở thư mục production/tinh-thuc-app)

   Tracy chỉ ra 13/08: *"họ chọn deep work thì chuyển sang phần deep work, sau
   phiên đó task sẽ được họ đổi trạng thái thì phần hiển thị hôm nay hoặc các
   nơi khác mà task đó hiện lên cũng phải được đổi trạng thái theo chứ"*.

   Hai lỗ đã vá, bộ thử này canh cho chúng không mở lại:
     ① VÀO phiên mà không đánh dấu gì — bảng Cam kết và danh sách việc của đội
        vẫn thấy `Chua_lam` trong khi người ta đang cắm đầu làm.
     ② RA phiên chỉ gọi `taiHomNay()` — màn Vườn giữ nguyên trạng thái cũ tới
        khi bấm sang tab khác rồi bấm về.

   Luật đầy đủ đang canh:
     · vào phiên      → task sang `Doing`, nhớ trạng thái cũ trong localStorage
     · bỏ dở (3 lối)  → trả về ĐÚNG trạng thái cũ, xoá dấu
     · ba cửa ra      → ghi đè Done · Chua_xong · Blocked, chỉ xoá dấu
     · mọi đường ra   → tải lại cả màn Vườn nếu nó đang mở
     · việc cố định   → không có task nên không dính gì
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const MOC = [
  /* Cụm mã máy + nhịp tim (14/08): `dwChay` nay mở phiên qua `dwMoPhienMoi`,
     nên khối này phải được lát vào TRƯỚC, không thì eval báo hàm không tồn tại.
     Lát mã THẬT chứ không giả lập — như vậy canh luôn được cửa lùi cho ngày
     máy chủ chưa chạy `nang-cap-may-va-nhip-tim.sql`. */
  ['const DW_KHOA_MAY',                      '\n/* ══════════ LÀN A · NỀN MÀN DEEPWORK'],
  ['const DW_KHOA_TTCU',                     '\n/* Chế độ 🔒 Tập trung sâu'],
  ['async function dwChay(){',               '\n\n/* Bấm 💧 trên một việc cố định'],
  ['async function dwHuySom(){',             '\n\n/* ═══'],
  ['async function dwHuy(lyDo, imLang){',    '\nconst dwBo ='],
  /* Hàng rào chiều ngược (TRI-126, 05/09): `dwChay` nay hỏi máy chủ trạng thái
     việc rồi từ chối nếu nó đã đóng. Lát MÃ THẬT chứ không dựng cọc — luật ở
     đây là một câu điều kiện thuần, cọc chỉ chép lại nó ra chỗ thứ hai. */
  ['function dwViecDaDong(t){',              '\n/* imLang = true khi đã có hộp']
];
const nguon = MOC.map(([a, b]) => {
  const i = s.indexOf(a);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + a);
  return s.slice(i, s.indexOf(b, i));
}).join('\n');

/* ── DOM và bộ nhớ giả ────────────────────────────────────────────────────── */
const KHO = {};
global.localStorage = {
  getItem: k => (k in KHO ? KHO[k] : null),
  setItem: (k, v) => { KHO[k] = String(v) },
  removeItem: k => { delete KHO[k] }
};
const MAN = {};
const the = id => (MAN[id] = MAN[id] || {
  id, hien: false, style: {}, textContent: '',
  classList: {
    add(...c){ c.forEach(x => { if (x === 'hien') MAN[id].hien = true }) },
    remove(...c){ c.forEach(x => { if (x === 'hien') MAN[id].hien = false }) },
    contains: c => c === 'hien' ? MAN[id].hien : false
  }
});
global.document = {getElementById: the};

let GHI = [], DA_TAI = [];
let ME = {id:'toi'}, TASKS = [], dwPhien = null, dwNhip = null, dwNhipChon = null;
let dwTaskChon = null, dwHen = null, dwTamLuc = 0, dwNghiMs = 0, dwDangCua = false;
const DW_KHOA_NGHI = 'dw_nghi';
const toast = m => GHI.push({loai:'toast', m});
const timO = ma => ma ? {ma, ten:'Cam kết '+ma, luong:1} : null;
const chuSach = v => String(v ?? '');
const dwGhiUocLuong = async () => true;
const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];   // nấc còn mở, y bản thật
const dwVaoPhien = p => { dwPhien = p };            // bản thật dựng màn, ở đây không cần
const taiHomNay = async () => { DA_TAI.push('homnay') };
const taiVuon   = async () => { DA_TAI.push('vuon') };
/* `dwTaiLaiMan` gọi `lamMoiCuaToi()` từ 26/08 thay cho `taiVuon()` thẳng — bản
   thật của nó chạy `taiVuon()` và `taiTaskList()` chung một chuyến. Giả lập giữ
   đúng hình dạng ấy, để phép thử vẫn soi được đúng điều nó sinh ra để soi: màn
   Của tôi đang mở thì bảng cam kết phải được nạp lại, không ôm số cũ. */
const taiTaskList  = async () => { DA_TAI.push('tasklist') };
const lamMoiCuaToi = async () => { await Promise.all([taiVuon(), taiTaskList()]) };
/* `veTasks` là cọc câm, KHÔNG ghi vào DA_TAI. Từ TRI-108, `dwChay` vẽ lại bảng
   việc ngay tại chỗ sau khi tự tay sửa `trang_thai` trong bộ nhớ — vì màn 💧
   thu nhỏ được, và lối ấy trả người ta về bảng việc mà không đi qua một lượt
   nạp nào. Đó là VẼ LẠI chứ không phải TẢI LẠI, nên nó không được lẫn vào
   DA_TAI — mấy ca "màn nào cũng phải đổi theo" đếm đúng số lượt hỏi máy chủ. */
const veTasks = () => {};
/* `veDsChon` vẽ lại danh sách chọn của màn 💧 — cọc câm, cùng lẽ với `veTasks`:
   hàng rào TRI-126 gọi nó để gỡ dấu chọn khỏi một việc vừa hoá ra đã đóng. */
const veDsChon = () => {};
/* Dải thu nhỏ (`dw-dai`) là thuần giao diện: nó chỉ bật/tắt theo trạng thái thật
   của phiên. Mọi đường ra khỏi phiên đều gọi nó để dải không kẹt lại một mình —
   nên thiếu cọc là ngã ngay ở lối bỏ dở, trước khi đo được gì. */
const dwVeDai = () => {};
const dwDongHopGhi = () => {};   // bản thật chỉ gấp hai tấm dw-them/dw-note — thuần giao diện
/* Chuỗi giả kiểu PostgREST (nâng 14/08 theo code thật): builder của Supabase
   cho nối `.eq().eq().select('id')…` tuỳ ý rồi await ở bất kỳ mắt xích nào —
   chốt chặn hai máy trong `dwChay`/`dwHuySom`/`dwHuy` dùng đúng kiểu đó. Mọi
   mắt xích trả lại chính mình; await thì ra {data, error}. Câu GHI trả data
   [{id}] (khớp ≥1 dòng: mình là máy đóng ĐẦU TIÊN, không rẽ nhánh "máy khác
   đóng rồi" — rẽ vào đó là bỏ qua hết hiệu ứng bộ thử đang canh); câu ĐỌC
   (`select` đứng đầu chuỗi) trả [] — `dwChay` phải nghe "KHÔNG còn phiên
   dang_chay nào" thì mới chịu mở phiên mới cho phép thử. */
const chuoi = kq => {
  const o = { eq: () => o, select: () => o, limit: () => o,
              then: (t, x) => Promise.resolve(kq()).then(t, x) };
  return o;
};
const sb = {
  from: bang => ({
    select: () => chuoi(() => ({data: [], error: null})),
    insert: rows => { GHI.push({loai:'insert', bang, rows});
                      return chuoi(() => ({data:[{id:99, task_id:rows.task_id}], error:null})); },
    update: patch => ({ eq: (_c, id) => { GHI.push({loai:'update', bang, id, patch});
                                          return chuoi(() => ({data:[{id}], error:null})); } }),
    delete: () => ({ eq: (_c, id) => { GHI.push({loai:'delete', bang, id});
                                       return chuoi(() => ({data:[{id}], error:null})); } })
  })
};
eval(nguon);

let hong = 0;
function kiem(ten, dat, them){
  console.log((dat ? '✅ ' : '❌ ') + ten + (dat || !them ? '' : '\n      → ' + them));
  if (!dat) hong++;
}
const viec = tt => ({id:7, nguoi_id:'toi', noi_dung:'Gọi 40 khách list A',
                     tieu_diem_ma:'L1', trang_thai: tt, thoi_luong_du_kien: 45});
const dat = tt => { GHI = []; DA_TAI = []; TASKS = [viec(tt)]; dwTaskChon = 7;
                    dwPhien = null; dwNhip = null; dwNhipChon = null;
                    localStorage.removeItem('dw_tt_cu'); };
const capNhat = () => GHI.filter(g => g.loai === 'update' && g.bang === 'task').map(g => g.patch);

(async () => {
  console.log('\n── VÀO PHIÊN ──');
  dat('Chua_lam');
  await dwChay();
  kiem('Bấm ▶ → task sang Doing ngay, không đợi ai chọn tay',
       capNhat().some(p => p.trang_thai === 'Doing'), JSON.stringify(capNhat()));
  kiem('Nhớ trạng thái cũ để còn đường lui', dwLayTTCu(7) === 'Chua_lam', dwLayTTCu(7));
  kiem('Kho trong máy cũng đổi theo, khỏi đợi lần tải sau', TASKS[0].trang_thai === 'Doing');

  dat('Chua_xong');
  await dwChay();
  kiem('Việc đang làm dở vào phiên → vẫn nhớ đúng là Chua_xong', dwLayTTCu(7) === 'Chua_xong');

  dat('Doing');
  await dwChay();
  kiem('Việc đã ở Doing sẵn → không ghi thừa một lượt lên máy chủ',
       !capNhat().some(p => p.trang_thai === 'Doing'));

  console.log('\n── BỎ DỞ: PHẢI TRẢ VỀ ĐÚNG CHỖ CŨ ──');
  dat('Chua_xong');
  await dwChay();
  GHI = []; DA_TAI = [];
  await dwHuy('thử', true);
  kiem('Bỏ cuộc → trả việc về Chua_xong, không nâng thành Chua_lam',
       capNhat().some(p => p.trang_thai === 'Chua_xong'), JSON.stringify(capNhat()));
  kiem('Xoá dấu sau khi trả', dwLayTTCu(7) === null);

  dat('Chua_lam');
  await dwChay();
  GHI = []; DA_TAI = [];
  await dwHuySom();
  kiem('Huỷ sớm (xoá hẳn phiên) → cũng trả việc về Chua_lam',
       capNhat().some(p => p.trang_thai === 'Chua_lam')
         && GHI.some(g => g.loai === 'delete'), JSON.stringify(capNhat()));

  /* Tên màn đổi HAI LẦN trong ba ngày: `man-vuon` → `man-toi` (26/08, gom sáu
     tab xuống bốn) → và màn ấy tan hẳn vào `man-homnay` (28/08, làn AN3). Giả
     lập bám theo lần cuối. Trước mỗi lần sửa, bài thử này bật cờ `.hien` lên
     một cái tên không còn ai hỏi tới, nên nhánh "màn đang mở" không bao giờ
     chạy và bài thử đỏ trong khi app hoàn toàn đúng. */
  console.log('\n── MÀN NÀO CŨNG PHẢI ĐỔI THEO ──');
  dat('Chua_lam');
  await dwChay();
  the('man-homnay').classList.remove('hien');
  GHI = []; DA_TAI = [];
  await dwHuy('thử', true);
  kiem('Màn Hôm nay đang đóng → chỉ tải lại dữ liệu Hôm nay',
       DA_TAI.join() === 'homnay', DA_TAI.join());

  dat('Chua_lam');
  await dwChay();
  the('man-homnay').classList.add('hien');
  GHI = []; DA_TAI = [];
  await dwHuy('thử', true);
  kiem('Màn Hôm nay đang mở → tải lại CẢ HAI, không để bảng cam kết ôm số cũ',
       DA_TAI.includes('homnay') && DA_TAI.includes('vuon'), DA_TAI.join());

  /* ── HÀNG RÀO: VIỆC ĐÃ ĐÓNG THÌ KHÔNG MỞ ĐƯỢC PHIÊN (TRI-126) ────────────
     Tracy 05/09: *"các task done rồi thì phải chặn cửa deep work của task đó
     chứ nhỉ"*. Lỗ cũ nằm ở chỗ `veDsChon` lọc `TT_MO` nhưng chế độ xác nhận
     tìm thẳng trong `TASKS`, nên nút 🌱 vẫn đưa vào được — rồi câu
     `update({trang_thai:'Doing'})` kéo một việc đã ra quả ngược về đang làm.
     `sb` giả trả `[]` cho mọi câu đọc, nên hàng rào rơi về bản trong máy —
     đúng đường đi khi máy chủ không nói gì khác. */
  console.log('\n── VIỆC ĐÃ ĐÓNG THÌ KHÔNG CÓ CỬA VÀO ──');
  for (const tt of ['Done', 'Da_huy', 'Da_chuyen']){
    dat(tt);
    await dwChay();
    kiem(`Việc ${tt} → không mở phiên, không ghi gì lên máy chủ`,
         !dwPhien && GHI.every(g => g.loai === 'toast'), JSON.stringify(GHI));
    kiem(`Việc ${tt} → KHÔNG bị kéo ngược về Doing`,
         !capNhat().some(p => p.trang_thai === 'Doing'), JSON.stringify(capNhat()));
  }
  dat('Blocked');
  await dwChay();
  kiem('Việc đang nghẽn VẪN vào phiên được — nghẽn là nấc mở, không phải nấc đóng',
       !!dwPhien, JSON.stringify(GHI));

  console.log('\n── VIỆC CỐ ĐỊNH KHÔNG DÍNH GÌ ──');
  dat('Chua_lam');
  GHI = []; DA_TAI = [];
  await dwHuy('thử', true);          // không có phiên → thoát sớm
  kiem('Không có phiên nào thì không đụng máy chủ', GHI.length === 0);
  localStorage.setItem('dw_tt_cu', JSON.stringify({id:7, tt:'Chua_lam'}));
  GHI = [];
  await dwTraTTCu({id:9, nhip_id:3});   // phiên việc cố định: không có task_id
  kiem('Phiên việc cố định → không sửa task nào, chỉ xoá dấu',
       !capNhat().length && dwLayTTCu(7) === null);

  /* ⚠️ CẦU TẠM 27/08 — dấu cũ nằm trong trình duyệt từng người, .sql không với
     tới. Ai vào phiên TRƯỚC lúc đổi tên rồi bỏ dở SAU đó sẽ gửi chữ `Confirm`
     lên, ràng buộc `check` mới đá về, việc kẹt ở `Doing`.
     Bỏ mục thử này cùng lúc bỏ `DW_TTCU_CU`, sau vài tuần. */
  console.log('\n── DẤU CŨ CÒN TRONG TRÌNH DUYỆT ──');
  dat('Chua_lam');
  localStorage.setItem('dw_tt_cu', JSON.stringify({id:7, tt:'Confirm'}));
  kiem('Dấu cũ ghi chữ Confirm → đọc ra thành Chua_lam, không đá ràng buộc mới',
       dwLayTTCu(7) === 'Chua_lam', dwLayTTCu(7));

  console.log(hong ? `\n❌ ${hong} mục chưa đạt\n` : '\n✅ Tất cả đều đạt\n');
  process.exit(hong ? 1 : 0);
})();
