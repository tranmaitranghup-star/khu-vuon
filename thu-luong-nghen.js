/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ NGUYÊN LÝ NGHẼN — BỐN CỬA, MỘT LUẬT
   Chạy:  node thu-luong-nghen.js    (đứng ở thư mục production/tinh-thuc-app)

   Tracy chốt 12/08: *"có 1 nguyên lý thôi là có việc nghẽn thì phải có việc gỡ
   nghẽn"*. Có BỐN cửa đặt được `Blocked`, và trước hôm ấy chúng nói bốn thứ
   tiếng khác nhau. Bộ thử này canh cho chúng không lệch lần nữa:

     ① cửa ra phiên deepwork  (phiên task và phiên việc cố định)
     ② cửa Thông tin việc `#tv-cua` (ô chọn trạng thái trong cửa sửa một việc)
     ③ form sửa ở bảng Cam kết
     ④ màn Dọn / nghi thức hoàn tất  → nằm ở `thu-man-don.js`, không lặp ở đây

   HAI thứ mỗi cửa phải làm giống hệt nhau: đẻ một việc gỡ, và đặt tên nó bằng
   `tenViecGoNghen`. Thứ thứ ba — hẹn ngày theo ô Deadline (13/08), bỏ trống thì
   hôm nay — nay chỉ còn đúng ở cửa ① và ③: cửa ② bỏ ô hẹn ngày riêng từ 31/08
   và luôn để `datNghen` lấy hôm nay.

   Không cần đăng nhập, không đụng máy chủ thật: mọi lệnh gửi lên Supabase bị
   bắt lại trong bộ nhớ rồi đem ra soi. DOM chỉ giả tới mức bốn cửa ấy đụng tới.
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const MOC = [
  ['function oNgay(id, nhan, them, giaTri){',    '\nfunction moLich('],
  /* Mốc đầu đổi từ `const GIO_PHUT` sang `const GIO_NAC`: hằng số cũ đã bị gỡ
     khi ô giờ chuyển sang bánh xe máy + cột mốc 15 phút. Nay lùi thêm một bậc
     nữa, tới `GIO_CAM_UNG` — `oGio` nằm TRÊN `GIO_NAC`, nên lát từ hằng số ấy
     là bỏ sót đúng cái hàm mà mục "Ô GIỜ" ở dưới đang hỏi. */
  ['const GIO_CAM_UNG = matchMedia(',            '\n/* Số thứ tự cam kết'],
  ['function chuSach(s){',                       '\n'],
  ['function phutDeadline(s){',                  '\n\n/* ── ĐÃ QUÁ GIỜ HẸN CHƯA'],
  /* Cặp giờ của một việc — `gioTask` đọc `gio_start`/`gio_end` và tự lùi về
     `deadline` cho việc gõ từ trước 25/08. Cả hai form sửa đều nạp ô giờ qua
     nó, nên cắt thật thay vì dựng cọc: một bản giả ở đây là bỏ mất đúng đường
     lui mà bộ thử vẫn đang chạy trên (`CO_GIO_SE` tắt). */
  ['function gioTask(t){',                       '\n/* Phải bằng ĐÚNG con số ở Supabase'],
  /* CỬA ② DỜI NHÀ 31/08. Form sửa nội tuyến của bảng Hôm nay gỡ hẳn hôm ấy
     (Tracy: *"bỏ nguyên bảng tôi vừa gửi đi, sử dụng chung bảng thông tin
     việc"*), mang theo cả bốn hàm `veFormSua` · `moSua` · `huySua` · `luuSua`.
     Bộ thử vẫn lát `veFormSua` nên nó CHẾT NGAY LÚC NẠP từ hôm ấy tới nay — mà
     chết thì cả ba cửa im lặng biến mất, nguy hơn hẳn một ca đỏ. Cửa ② nay là
     `#tv-cua`, và đường ghi của nó là `tvLuu`. */
  ['function tvTim(id){',                        '\n/* Ô chọn trạng thái — BÀY ĐỦ'],
  ['function tvKhoangGio(){',                    '\n/* Dòng phụ: việc này SẼ nằm ở đâu'],
  ['async function tvLuu(){',                    '\n/* Nút 💧 ở cửa Thông tin việc'],
  ['function tenViecGoNghen(chu){',              '\n\n'],
  ['async function datNghen(t, chu, han){',      '\n\n'],
  ['/* Ô chọn trạng thái của form bảng cam kết', '\n/* ══════ Ô GHI CHÚ SOẠN ĐƯỢC'],
  ['function veFormSuaTaskCK(t){',               '\n/* Mở và đóng form CHỈ vẽ lại'],
  ['async function luuSuaTaskCK(id){',           '\n\n/* Đặt hạn cho một việc đang nằm trong kho'],
  ['const DW_CUA_GOI_Y = {',                     '\n/* Hạn của việc gỡ nghẽn'],
  ['let DW_HAN_GO',                              '\nasync function dwXacNhanCua'],
  ['async function dwXacNhanCua(){',             '\n/* imLang = true'],
  ['async function dwHuy(lyDo, imLang){',        '\nconst dwBo =']
];
const nguon = MOC.map(([a, b]) => {
  const i = s.indexOf(a);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + a);
  return s.slice(i, s.indexOf(b, i));
}).join('\n');

/* ── DOM giả: đủ cho những ô và nút mà bốn cửa đụng tới ────────────────────── */
const NUT = {};
const nut = id => (NUT[id] = NUT[id] || {
  id, textContent: '', innerHTML: '', value: '', title: '',
  disabled: false, dataset: {}, style: {},
  classList: {list: new Set(),
    add(...c){ c.forEach(x => this.list.add(x)) },
    remove(...c){ c.forEach(x => this.list.delete(x)) },
    toggle(c, v){ v ? this.list.add(c) : this.list.delete(c) }},
  focus(){}
});
const datO = (id, v) => { nut(id).value = v; };
global.document = {
  getElementById: nut,
  querySelector: sel => sel === '#dw-cua-han-hang > span'
    ? (NUT.__nhac = NUT.__nhac || {textContent: ''}) : null
};

let GHI = [], ME = {id: 'toi'}, TASKS = [], TASK_CK = {};
let dwPhien = null, dwNhip = null, dwCuaChon = null, dwDangCua = false;
let dwKetThucLuc = '2026-08-13T20:00:00.000Z', dwBatDauLuc = Date.now();
let dwHen = null, dwTamLuc = 0, dwNghiMs = 0, DW_CHU = '';
/* `SUA_ID` và `NGHEN_CHO` đi cùng form sửa nội tuyến, gỡ hẳn 31/08 — không còn
   dòng nào trong app hỏi tới chúng. `SUA_TCK` thì vẫn sống: bảng Cam kết giữ
   nguyên form của nó. */
let SUA_TCK = null;
const DW_KHOA_NGHI = 'k';
global.localStorage = {removeItem(){}, getItem(){ return null }, setItem(){}};
const homNay = () => '2026-08-13';
const toast = m => GHI.push({loai: 'toast', m});
const timO = ma => ma ? {ma, qua: '🍎'} : null;
const gioChu = p => p + ' phút';
/* Cụm phiên deepwork mà `dwTheoTrangThai` cần (TRI-126) — từ 05/09 `datNghen`
   khép luôn phiên đang chạy cho việc vừa bị chặn, nên khối lát ở đây kéo theo
   ba thứ này. 30 phút là quãng làm giả định: trên sàn 5 phút, nên phiên đi
   đường LƯU chứ không đường huỷ — đúng nhánh cần soi. */
const DW_SAN_PHUT = 5, DW_TRAN_PHUT = 180;
const dwLamMs = () => 30 * 60000;
const gioRo = p => p + ' phút';
const phutTuChu = v => v ? 45 : null;
const oChonTT = () => '';
const veOGhiChu = id => '<div id="' + id + '"></div>';
const gcDinh = () => ({goi: '', nhan: ''});
/* `boCuPhapLink` ra đời 13/08 ở một nhánh khác (mốc 1ae8c28): nó gỡ cú pháp
   [tên](địa chỉ) khỏi TÊN việc gỡ nghẽn. Ở đây chỉ cần nó không ném lỗi —
   hành vi thật của nó không thuộc phạm vi bộ thử này. */
const boCuPhapLink = s => String(s ?? '').trim();
const richKhai = () => {}, richDoc = () => DW_CHU;
const taiHomNay = async () => {}, taiVuon = async () => {}, veTasks = () => {},
      veDsLuong = () => {}, taiTieuDiem = async () => {};
/* Từ 26/08 mọi cửa sửa dữ liệu của màn Của tôi gọi `lamMoiCuaToi()` chứ không
   gọi `taiVuon()` một mình. Bộ thử này chỉ soi thứ được GHI LÊN máy chủ, không
   soi chuyện vẽ lại màn, nên giả lập rỗng là đủ. */
const lamMoiCuaToi = async () => {}, taiTaskList = async () => {};
/* `luuSua` gọi `timTask()` từ làn ô GIỜ (25/08) để lấy thời lượng dự kiến của
   việc đang sửa. Giả lập chép đúng hình dạng bản thật (`public/index.html`
   quanh dòng 6228): dò lần lượt các kho task đang có trong bộ nhớ. Bộ thử này
   chỉ dựng `TASKS` và `TASK_CK`, nên hai kho ấy là đủ. */
/* `manhGio` (làn ô GIỜ, 25/08) gói giờ thành mảnh để ghi lên máy chủ. Bản thật
   thêm `gio_start`/`gio_end` khi máy chủ đã có hai cột ấy; ở đây để `CO_GIO_SE`
   tắt, đúng đường lui khi máy chủ chưa chạy `nang-cap-gio-start-end.sql` — và
   cũng đúng thứ bộ thử này soi, vì mọi phép kiểm giờ của nó đọc cột `deadline`.
   Bản thật nhận thêm tham số thứ ba (`den` — giờ kết thúc người ta tự đặt ở cửa
   Thông tin việc); cọc bỏ qua nó vì nó chỉ có tiếng nói khi `CO_GIO_SE` bật. */
const CO_GIO_SE = false;
const manhGio = (gio, phut) => ({deadline: gio || ''});
const timTask = id => (TASKS || []).find(t => t.id === id)
  || Object.values(TASK_CK || {}).flat().find(t => t.id === id)
  || null;
const baoLoiTask = e => e.message;
/* Ba hàm dưới ra đời 13/08 cùng luật "vào phiên thì đánh dấu Doing" — cửa ra
   gọi tới chúng để xoá dấu và tải lại màn. Hành vi thật của chúng có bộ thử
   riêng: `thu-trang-thai-phien.js`. */
const dwQuenTTCu = () => {}, dwNhoTTCu = () => {}, dwLayTTCu = () => null;
const dwTaiLaiMan = async () => {}, dwTraTTCu = async () => {};
/* Dải thu nhỏ của phiên — thuần giao diện, bật tắt theo trạng thái thật của
   phiên. Mọi đường ra khỏi phiên đều gọi nó, nên thiếu cọc là hai cửa ra ngã
   trước khi ghi được dòng nào. */
const dwVeDai = () => {};
const dwDongHopGhi = () => {};   // bản thật chỉ gấp hai tấm dw-them/dw-note — thuần giao diện
/* ── CỌC CHO CỬA ② (cửa Thông tin việc) ───────────────────────────────────
   `TV_ID` phải khai NGOÀI eval thì phép thử mới trỏ được nó vào việc đang sửa;
   `let` bên trong một khối eval chỉ sống trong khối ấy. Bốn kho mà `tvTim` dò
   qua để trống hết, nên nó rơi xuống cửa lùi cuối là `timTask` — tức đúng mảng
   `TASKS` mà phép thử dựng. Ô màu và dòng phụ là chuyện vẽ, không phải chuyện
   ghi, nên chỉ cần chúng đừng ném lỗi. */
let TV_ID = null, TV_MAU = null, TLG_VIEC = {}, TL_KHO_DS = [];
const CO_MAU = false;
const tvDong = () => {};
/* Hình cái sọt rác dùng chung cho mọi nút Xoá — thuần hình vẽ, cọc rỗng là đủ. */
const HINH_RAC = '';
/* Ô chọn loại trả về ba hạng giá trị và cả ba đi xuống hai cột. Bộ thử này chỉ
   hỏi cột `tieu_diem_ma` — việc gỡ nghẽn có thừa hưởng cam kết của cha không —
   nên cọc dừng ở đó, không dựng lại cả nhánh việc cố định và cờ cá nhân. */
const manhLoai = v => ({tieu_diem_ma: v || null});
/* `oGio` hỏi thiết bị ngay lúc nạp để chọn giữa bánh xe gốc và cột mốc 15 phút.
   Node không có `matchMedia`; trả `false` là đi đường MÁY TÍNH — đúng đường mà
   mục "Ô GIỜ" dưới đây đang soi (input ẩn, không còn `type="time"`). */
global.matchMedia = () => ({matches: false});
/* Chuỗi giả kiểu PostgREST (nâng 14/08 theo code thật): builder của Supabase
   cho nối `.eq().eq().select('id')…` tuỳ ý rồi await ở bất kỳ mắt xích nào —
   chốt chặn hai máy trong `dwXacNhanCua`/`dwHuy` dùng đúng kiểu đó. Mọi mắt
   xích trả lại chính mình; await thì ra {data, error}. Câu GHI trả data [{id}]
   (khớp ≥1 dòng: mình là máy đóng ĐẦU TIÊN, không rẽ nhánh "máy khác đóng
   rồi" — rẽ vào đó là mọi hiệu ứng bộ thử đang canh đều bị bỏ qua); câu ĐỌC
   (`select` đứng đầu chuỗi) trả [] như mock cũ. */
const chuoi = kq => {
  const o = { eq: () => o, select: () => o, limit: () => o,
              then: (t, x) => Promise.resolve(kq()).then(t, x) };
  return o;
};
const sb = {
  from: bang => ({
    insert: rows => { GHI.push({loai:'insert', bang, rows}); return chuoi(() => ({error:null})); },
    update: patch => ({ eq: (_c, id) => { GHI.push({loai:'update', bang, id, patch});
                                          return chuoi(() => ({data:[{id}], error:null})); } }),
    select: () => chuoi(() => ({data: [], error:null}))
  })
};
/* `DW_HAN_GO` khai bằng `let` trong khối vừa lát nên nó nằm trong phạm vi của
   eval — nối thêm hai cái cần gạt để phép thử đọc và đặt được nó. */
eval(nguon + '\nglobalThis.__hanGo = () => DW_HAN_GO;'
           + '\nglobalThis.__datHanGo = v => { DW_HAN_GO = v; };');
const hanGo = () => globalThis.__hanGo();

let hong = 0;
function kiem(ten, dat, them){
  console.log((dat ? '✅ ' : '❌ ') + ten + (dat || !them ? '' : '\n      → ' + them));
  if (!dat) hong++;
}
/* Bốn cửa gửi hàng theo hai kiểu: `datNghen` insert MỘT object, còn `donLuu`
   insert cả MẢNG. Chuẩn hoá ở đây để phép thử không phải nhớ cửa nào kiểu nào. */
const conTu = () => {
  const g = GHI.find(x => x.loai === 'insert' && x.bang === 'task');
  if (!g) return null;
  return Array.isArray(g.rows) ? g.rows[0] : g.rows;
};

/* ══════ CỬA ① — RA KHỎI PHIÊN DEEPWORK ═══════════════════════════════════ */
console.log('\n── CỬA ①: phiên deepwork · vẽ màn ──');
dwChonCua('nghen');
const hang = NUT['dw-cua-han-hang'];
kiem('Cửa Nghẽn hiện hàng Deadline',
     hang.style.display === 'flex' && hang.innerHTML.includes('dw-cua-han'));
kiem('Dùng đúng ô lịch oNgay nhãn Deadline', hang.innerHTML.includes('>Deadline<'));
kiem('Nhắc "mặc định thì sẽ là hôm nay"', hang.innerHTML.includes('mặc định thì sẽ là hôm nay'));
kiem('Nút cửa: "🚧 Ghi nghẽn & tạo task con"',
     NUT['dw-cua-luu'].textContent === '🚧 Ghi nghẽn & tạo task con');

dwCuaHan('2026-08-15');
kiem('Chọn hạn → nút nói ra ngày nó sắp hẹn',
     NUT['dw-cua-luu'].textContent === '🚧 Ghi nghẽn & tạo task con — hạn 15/08',
     NUT['dw-cua-luu'].textContent);
kiem('Chữ nhắc đổi thành "hạn của việc gỡ"', NUT.__nhac.textContent === 'hạn của việc gỡ');

dwChonCua('chua-xong');
kiem('Đổi sang cửa khác → hàng ẩn và ngày đã chọn rụng theo',
     hang.style.display === 'none' && hanGo() === '' && hang.innerHTML === '');
kiem('Cửa Chưa xong giữ nhãn nút cũ', NUT['dw-cua-luu'].textContent === '🔄 Lưu tiến độ');
dwChonCua('xong');
kiem('Cửa Xong giữ nhãn nút cũ', NUT['dw-cua-luu'].textContent === '✅ Đạt đích — đóng việc này');

(async () => {
  console.log('\n── CỬA ①: phiên deepwork · ghi xuống máy chủ ──');
  const chayDW = async (han, nhip) => {
    GHI = []; globalThis.__datHanGo(''); dwNhip = nhip || null;
    dwPhien = {id: 9, task_id: nhip ? null : 7, bat_dau: '2026-08-13T19:00:00.000Z'};
    TASKS = [{id: 7, nguoi_id: 'toi', tieu_diem_ma: 'L1', noi_dung: 'Chốt kịch bản'}];
    DW_CHU = 'Xin chị Hà duyệt ngân sách';
    dwChonCua('nghen');
    if (han) dwCuaHan(han);
    await dwXacNhanCua();
    return conTu();
  };

  let con = await chayDW('2026-08-15');
  kiem('PHIÊN TASK — có hạn → việc gỡ hẹn 15/08', con && con.ngay === '2026-08-15', JSON.stringify(con));
  kiem('PHIÊN TASK — tên đúng khuôn "🚧 Gỡ nghẽn: "', con && con.noi_dung.startsWith('🚧 Gỡ nghẽn: '));
  kiem('PHIÊN TASK — con nối vào cha bằng task_cha', con && con.task_cha === 7);
  con = await chayDW(null);
  kiem('PHIÊN TASK — bỏ trống ô → hẹn hôm nay như trước', con && con.ngay === '2026-08-13', JSON.stringify(con));

  con = await chayDW('2026-08-16', {id: 3, ten: 'Trực page'});
  kiem('VIỆC CỐ ĐỊNH — có hạn → việc gỡ hẹn 16/08', con && con.ngay === '2026-08-16', JSON.stringify(con));
  con = await chayDW(null, {id: 3, ten: 'Trực page'});
  kiem('VIỆC CỐ ĐỊNH — bỏ trống → hẹn hôm nay', con && con.ngay === '2026-08-13', JSON.stringify(con));

  console.log('\n── CỬA ①: ngày phải rụng theo phiên ──');
  await chayDW('2026-08-15');
  kiem('Đóng phiên xong → ngày rụng, không sót sang phiên sau', hanGo() === '');
  globalThis.__datHanGo('2026-08-15');
  dwPhien = {id: 10}; await dwHuy('thử');
  kiem('Huỷ phiên → ngày cũng rụng', hanGo() === '');

  /* ══════ CỬA ② — CỬA THÔNG TIN VIỆC (`#tv-cua`) ════════════════════════
     Cửa này DỜI NHÀ 31/08: form sửa nội tuyến của bảng Hôm nay gỡ hẳn, cả app
     còn đúng MỘT cửa sửa một việc, và nó nhận nốt hai thứ form cũ giữ riêng —
     ô Ghi chú và nhánh đặt Nghẽn.

     ⚠️ MỘT LUẬT ĐỔI THEO, đừng chữa ngược: ô hẹn ngày riêng cho việc gỡ KHÔNG
     còn ở cửa này. `tvLuu` gọi `datNghen(..., '')` để nó tự lấy hôm nay (Tracy
     chốt 31/08 — bớt một ô ở đúng phút người ta đang bực vì bị chặn). Nên cặp
     ca "có hạn / bỏ trống" của cửa ② đã theo cái ô ấy mà đi; hai cửa còn giữ ô
     hạn là cửa ① và cửa ③, và cả hai vẫn được canh đủ ở trên và ở dưới. */
  console.log('\n── CỬA ②: cửa Thông tin việc ──');
  const tHomNay = {id: 7, nguoi_id: 'toi', noi_dung: 'Gọi 40 khách list A',
                   tieu_diem_ma: 'L1', deadline: '', thoi_luong_du_kien: null,
                   ngay: '2026-08-13', trang_thai: 'Chua_lam'};

  console.log('\n── Ô GIỜ: bảng bấm một chạm (14/08, mốc b3570c4) ──');
  kiem('Ô giờ là nút mở bảng bấm; giá trị nằm ở input ẨN, hết bánh xe của máy',
       oGio('x', '').includes('type="hidden"') && oGio('x', '').includes('gioMo')
         && !oGio('x', '').includes('type="time"'));
  kiem('Dịch máy → người: 16:30 thành 16h30', gioTuO('16:30') === '16h30');
  kiem('Giờ tròn bỏ hẳn số 0 cho gọn: 16:00 thành 16h', gioTuO('16:00') === '16h');
  kiem('Dịch người → máy: 16h30 · 16h · 16:30 · 9g đều đọc được',
       oTuGio('16h30') === '16:30' && oTuGio('16h') === '16:00'
         && oTuGio('16:30') === '16:30' && oTuGio('9g') === '09:00');
  kiem('Chữ cũ không đọc được thì trả rỗng, không đoán bừa',
       oTuGio('chiều nay') === '' && oTuGio('') === '' && oTuGio('99h') === '');
  kiem('Ô nạp sẵn giờ cũ của việc thì hiện ra đúng giờ ấy',
       oGio('x', '16h30').includes('>16h30<') && oGio('x', '').includes('>Giờ<'));

  /* Đặt cửa vào đúng tư thế người ta hay gặp: một việc đang mở, mọi ô đã có
     chữ, rồi đổi ô trạng thái. `chu` là thứ gõ vào ô Ghi chú — chính là thứ
     đang chặn, và cũng chính là tên việc gỡ. */
  const chayTV = async (ttMoi, chu, ttCu) => {
    GHI = []; TV_ID = 7;
    TASKS = [Object.assign({}, tHomNay, {trang_thai: ttCu || 'Chua_lam'})];
    datO('tv-nd', 'Gọi 40 khách list A'); datO('tv-od', 'L1');
    datO('tv-ngay', '2026-08-13'); datO('tv-gio', ''); datO('tv-den', '');
    datO('tv-tt', ttMoi);
    DW_CHU = chu === undefined ? 'Xin chị Hà duyệt ngân sách' : chu;
    return await tvLuu();       // richDoc đọc ra DW_CHU
  };
  const capNhat = () => GHI.filter(g => g.loai === 'update' && g.bang === 'task');

  await chayTV('Blocked');
  con = conTu();
  kiem('Chọn Nghẽn → đẻ việc gỡ, hẹn HÔM NAY (cửa này hết ô hạn từ 31/08)',
       con && con.ngay === '2026-08-13', JSON.stringify(con));
  kiem('Tên đúng khuôn "🚧 Gỡ nghẽn: "', con && con.noi_dung.startsWith('🚧 Gỡ nghẽn: '));
  kiem('Việc gỡ nối vào cha và thừa hưởng cam kết của cha (không mồ côi)',
       con && con.task_cha === 7 && con.tieu_diem_ma === 'L1', JSON.stringify(con));
  /* Thứ tự hai lượt ghi là CỐ Ý, không phải tình cờ: lượt đầu chở tên · ngày ·
     giờ nhưng KHÔNG chở `trang_thai`, để nếu bước sau hỏng thì không ai bị bỏ
     lại với một việc mang dấu Nghẽn mà chẳng có việc nào đi gỡ nó. */
  kiem('Lượt ghi ĐẦU cố ý không mang trang_thai; dấu Nghẽn chỉ đóng sau khi việc gỡ đã có',
       capNhat().length === 2 && !('trang_thai' in capNhat()[0].patch)
         && capNhat()[1].patch.trang_thai === 'Blocked',
       JSON.stringify(capNhat().map(g => g.patch)));

  const chan = await chayTV('Blocked', '   ');
  kiem('Không khai thứ đang chặn → không đẻ việc gỡ, và KHÔNG đóng dấu Nghẽn lên việc',
       !conTu() && !capNhat().some(g => g.patch.trang_thai === 'Blocked'));
  kiem('Bị chặn thì tvLuu trả FALSE — cửa mở nguyên, chữ vừa gõ còn đó', chan === false);

  await chayTV('Blocked', undefined, 'Blocked');
  kiem('Việc ĐÃ Nghẽn sẵn → không đẻ thêm việc gỡ thứ hai cho cùng một cái chặn',
       !conTu(), JSON.stringify(conTu()));

  /* Đường THƯỜNG (không đổi sang Nghẽn) — giờ ghi xuống cột `deadline`. */
  GHI = []; TV_ID = 7;
  TASKS = [Object.assign({}, tHomNay)];
  datO('tv-nd', 'Gọi 40 khách list A'); datO('tv-od', 'L1'); datO('tv-tt', 'Chua_lam');
  datO('tv-ngay', '2026-08-14'); datO('tv-gio', '16:30'); datO('tv-den', '');
  await tvLuu();
  let cha = (capNhat()[0] || {}).patch || {};
  kiem('Sửa thường: giờ ghi xuống kiểu chữ "16h30", không phải "16:30"',
       cha.deadline === '16h30' && cha.ngay === '2026-08-14', JSON.stringify(cha));

  GHI = []; datO('tv-gio', '');
  await tvLuu();
  cha = (capNhat()[0] || {}).patch || {};
  kiem('Xoá trống ô giờ → gửi chuỗi rỗng, cột không nhận null (ràng buộc not null)',
       cha.deadline === '', JSON.stringify(cha));

  GHI = []; datO('tv-ngay', '');
  await tvLuu();
  cha = (capNhat()[0] || {}).patch || {};
  kiem('Xoá trống ô ngày → gửi null, việc rời lưới về 🧺 kho — một luật cho cả bốn cửa',
       cha.ngay === null, JSON.stringify(cha));

  /* ══════ CỬA ③ — FORM SỬA Ở BẢNG CAM KẾT ═══════════════════════════════ */
  console.log('\n── CỬA ③: form sửa bảng Cam kết ──');
  const tCK = {id: 8, noi_dung: 'Dựng báo cáo tuần', deadline: '', thoi_luong_du_kien: null,
               ngay: '2026-08-13', trang_thai: 'Chua_lam'};
  const fCK = veFormSuaTaskCK(tCK);
  kiem('Form có sẵn hàng Deadline nhưng ĐANG ẨN',
       fCK.includes('tck-hango-hang') && fCK.includes('display:none'));
  kiem('Ô chọn trạng thái gọi tckDoiTT (biết cả trạng thái cũ)',
       fCK.includes("tckDoiTT('Chua_lam', this.value)"));
  kiem('Đã bỏ ô Deadline giờ và ô Dự kiến khỏi form',
       !fCK.includes('16h30') && !fCK.includes('Dự kiến'));
  kiem('Trạng thái và ô ghi chú nằm CÙNG một hàng',
       /<div class="tt-va-gc">[\s\S]*?tck-tt[\s\S]*?tck-gc[\s\S]*?<\/div>/.test(fCK));
  kiem('Cụm ngày-giờ đứng RIÊNG một hàng, trạng thái xuống hàng dưới',
       fCK.includes('data-mac-dinh="Deadline"') && fCK.includes('class="sua-luc" id="tck-ngay-o"')
         && !fCK.includes('id="tck-hang-ngay"'));

  tckDoiTT('Chua_lam', 'Blocked');
  kiem('Chọn Nghẽn → hàng Deadline hiện ra', NUT['tck-hango-hang'].style.display === 'flex');
  kiem('Chọn Nghẽn → cụm NGÀY-GIỜ ẩn đi',
       NUT['tck-ngay-o'].style.display === 'none');
  tckDoiTT('Chua_lam', 'Chua_xong');
  kiem('Chọn trạng thái khác → ẩn lại', NUT['tck-hango-hang'].style.display === 'none');
  kiem('Bỏ Nghẽn ra → cụm ngày-giờ về chỗ cũ, giá trị cũ còn nguyên',
       NUT['tck-ngay-o'].style.display === '');
  tckDoiTT('Blocked', 'Blocked');
  kiem('Việc ĐÃ Nghẽn sẵn → không hỏi hạn (lưu lại không đẻ thêm việc gỡ)',
       NUT['tck-hango-hang'].style.display === 'none');

  const chayCK = async (han, ttCu) => {
    GHI = []; SUA_TCK = 8;
    TASK_CK = {L1: [{id: 8, nguoi_id: 'toi', tieu_diem_ma: 'L1', trang_thai: ttCu || 'Chua_lam'}]};
    datO('tck-nd', 'Dựng báo cáo tuần'); datO('tck-ngay', '2026-08-13');
    datO('tck-gio', ''); datO('tck-tt', 'Blocked'); datO('tck-hango', han || '');
    DW_CHU = 'Chờ chị Hà gửi số liệu';
    await luuSuaTaskCK(8);
    return conTu();
  };
  con = await chayCK('2026-08-15');
  kiem('Có hạn → việc gỡ hẹn 15/08', con && con.ngay === '2026-08-15', JSON.stringify(con));
  kiem('Việc gỡ thừa hưởng cam kết của cha (không mồ côi)', con && con.tieu_diem_ma === 'L1');
  con = await chayCK(null);
  kiem('Bỏ trống → hẹn hôm nay', con && con.ngay === '2026-08-13', JSON.stringify(con));
  con = await chayCK('2026-08-15', 'Blocked');
  kiem('Việc đã Nghẽn từ trước → KHÔNG đẻ thêm việc gỡ nữa', !con, JSON.stringify(con));

  /* ══════ MỘT LUẬT CHO CẢ BỐN CỬA ═══════════════════════════════════════ */
  console.log('\n── MỘT LUẬT, BỐN CỬA ──');
  kiem('Tên việc gỡ chỉ có MỘT chỗ sinh ra (tenViecGoNghen)',
       (s.match(/'🚧 Gỡ nghẽn: '/g) || []).length === 1);
  kiem('Tên dài quá 90 ký tự thì cắt và đóng dấu ba chấm',
       tenViecGoNghen('x'.repeat(120)) === '🚧 Gỡ nghẽn: ' + 'x'.repeat(90) + '…');
  GHI = [];
  kiem('Không gõ tên việc gỡ → datNghen chặn, không ghi gì xuống máy chủ',
       !(await datNghen({id: 1}, '   ', '2026-08-15')) && !GHI.some(g => g.loai !== 'toast'));

  console.log(hong ? `\n❌ ${hong} mục chưa đạt\n` : '\n✅ Tất cả đều đạt\n');
  process.exit(hong ? 1 : 0);
})();
