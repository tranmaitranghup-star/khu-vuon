/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ: ĐƯỜNG LUI CỦA MÀN BA CỬA  (dwKetThuc ↔ dwLuiPhien)
   Chạy:  node thu-lui-phien.js     (đứng ở thư mục production/tinh-thuc-app)

   Tracy báo 17/08: *"ở phiên deep work nếu lỡ ấn nhầm nút kết thúc phiên thì mở
   ra trang như này nhưng thiếu nút quay trở lại rồi"*. Nút đã có; bộ thử này
   canh phần khó thấy bằng mắt — cái GIÁ của cú lui.

   Bốn luật đang canh:
     · lui về là đồng hồ chạy tiếp, KHÔNG mất phút nào và KHÔNG cộng oan phút nào
     · bấm nhầm lúc đang ⏸ thì lui về vẫn ⏸ (quãng đứng nhìn ba cửa là nghỉ,
       không phải làm) — đây là chỗ dễ hỏng nhất, mắt không bắt được
     · phiên TỰ kết thúc ở trần 180 phút thì không bày nút lui
     · lui đi lui lại không đẻ thêm bộ đếm, và không câu nào chạm máy chủ

   Mã lát thẳng từ `public/index.html` — không chép tay, để mã đổi thì thử đổi theo.
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');

const MOC = [
  ['const DW_SAN_PHUT',              '\n'],                          // hai ngưỡng thật
  ['function dwLamMs(){',            '\nasync function dwChay(){'],  // + dwPhutDaChay
  ['async function dwKetThuc(tuDong){', '\n/* ── NẮN SỐ PHÚT']       // + dwLuiPhien
];
const nguon = MOC.map(([a, b]) => {
  const i = s.indexOf(a);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + a);
  const j = s.indexOf(b, i);
  if (j < 0) throw new Error('Không tìm thấy mốc đóng của: ' + a);
  return s.slice(i, j);
}).join('\n')
  /* `const`/`let` khai bên trong eval chỉ sống trong phạm vi của eval — hàm thì
     lọt ra, hằng thì không. Đẩy thứ cần đọc ra global ngay sau khi lát, đúng lối
     `thu-phien-treo.js` đã chạy. `dwTamTruocCua` cũng khai bằng `let` trong khối
     lát, nên phải có cửa sổ nhòm vào chứ không đọc thẳng được. */
  + '\n;global.DW_SAN_PHUT = DW_SAN_PHUT; global.DW_TRAN_PHUT = DW_TRAN_PHUT;'
  + '\n;global.nhomTamTruoc = () => dwTamTruocCua;';

/* ── Đồng hồ giả: mọi mốc thời gian trong bộ thử do tay tôi đẩy ────────────── */
let GIO = 1_700_000_000_000;
const troi = ms => { GIO += ms };                      // để thời gian trôi đi
const Date_that = Date;
global.Date = class extends Date_that {
  constructor(...a){ return a.length ? new Date_that(...a) : new Date_that(GIO) }
  static now(){ return GIO }
};

/* ── Bộ đếm giả: đếm luôn số lần bật/dọn để bắt ca "hai bộ đếm cùng chạy" ──── */
let demBat = 0, demDon = 0, henSong = 0;
const setInterval = () => { demBat++; henSong++; return 900 + demBat };
const clearInterval = h => { if (h) { demDon++; henSong-- } };

/* ── localStorage, DOM, và những hàm hàng xóm bị thay bằng bù nhìn ─────────── */
const KHO = {};
global.localStorage = {
  getItem: k => (k in KHO ? KHO[k] : null),
  setItem: (k, v) => { KHO[k] = String(v) },
  removeItem: k => { delete KHO[k] }
};
const nghiDaLuu = () => (KHO['dw_nghi'] ? JSON.parse(KHO['dw_nghi']) : null);

const O = {};                                          // kho thẻ giả, tạo theo yêu cầu
const theGia = id => ({
  id, textContent: '', innerHTML: '', disabled: false, value: '',
  style: {display: ''},
  classList: {
    _: new Set(),
    add(...c){ c.forEach(x => this._.add(x)) },
    remove(...c){ c.forEach(x => this._.delete(x)) },
    contains(c){ return this._.has(c) }
  }
});
global.document = { getElementById: id => (O[id] || (O[id] = theGia(id))) };

let NOI = [], hopMo = 0, demNhanChay = 0, demTamVe = 0, demVe = 0, demDongHop = 0;
const toast          = m => NOI.push(String(m));
const hopHoiMo       = () => { hopMo++ };
const dwDongHopGhi   = () => { demDongHop++ };
const dwVeTomTatCua  = () => {};
const dwVeNhanChay   = () => { demNhanChay++ };
const dwTamDungVe    = () => { demTamVe++ };
const dwVe           = () => { demVe++ };

/* ── Trạng thái phiên: đúng những biến mà hai hàm kia đọc và ghi ───────────── */
let dwPhien = null, dwNhip = null, dwHen = null, dwBatDauLuc = 0, dwKetThucLuc = null;
let dwDangCua = false, dwCuaChon = null, dwTamLuc = 0, dwNghiMs = 0, DW_HAN_GO = '';
const DW_KHOA_NGHI = 'dw_nghi';
const TASKS = [{id: 7, noi_dung: 'Kick off tuần'}];

eval(nguon);

/* Dựng lại một phiên đang chạy được `phut` phút, chưa nghỉ lần nào. */
function moPhien(phut){
  Object.keys(O).forEach(k => delete O[k]);
  NOI = []; hopMo = 0; demNhanChay = 0; demTamVe = 0; demVe = 0; demDongHop = 0;
  demBat = 0; demDon = 0; henSong = 0;
  delete KHO['dw_nghi'];
  dwBatDauLuc = GIO;
  dwPhien = {id: 'p1', task_id: 7, bat_dau: new Date(GIO).toISOString()};
  dwNhip = null; dwKetThucLuc = null; dwDangCua = false; dwCuaChon = null;
  dwTamLuc = 0; dwNghiMs = 0; DW_HAN_GO = '';
  dwHen = setInterval(dwVe, 1000);
  troi(phut * 60000);
}
/* Bấm ⏸ — chép đúng phần ruột của `dwTamDung` không đụng máy chủ. */
function bamTam(){
  dwTamLuc = GIO; clearInterval(dwHen); dwHen = null;
  localStorage.setItem(DW_KHOA_NGHI, JSON.stringify({id: dwPhien.id, nghi: dwNghiMs, tam: dwTamLuc}));
}
const dw     = () => document.getElementById('dw');
const nutLui = () => document.getElementById('dw-cua-lui');

/* ── Chấm ────────────────────────────────────────────────────────────────── */
let dat = 0, truot = 0;
const chấm = (ten, dung, them) => {
  if (dung) { dat++; console.log('  ✅ ' + ten) }
  else { truot++; console.log('  ❌ ' + ten + (them ? '  → ' + them : '')) }
};

(async () => {

console.log('\n① BẤM NHẦM LÚC ĐANG CHẠY — màn ba cửa mở ra có đường lui');
moPhien(40);
const lamTruoc = dwLamMs();
await dwKetThuc();
chấm('vào đúng màn ba cửa', dwDangCua === true && dw().classList.contains('cua')
     && !dw().classList.contains('chay'));
chấm('đồng hồ dừng lại (không còn bộ đếm nào sống)', dwHen === null && henSong === 0);
chấm('nút lui HIỆN', nutLui().style.display === '');
chấm('nút chính khoá lại, chờ chọn một cửa',
     document.getElementById('dw-cua-luu').disabled === true);
chấm('có cất mặt ⏸ lại (lúc này là 0 — đang chạy)', nhomTamTruoc() === 0);

console.log('\n② LUI VỀ — đồng hồ chạy tiếp, số phút liền mạch');
troi(25000);                                   // 25 giây đứng nhìn ba cửa
dwLuiPhien();
chấm('cờ màn cửa hạ xuống', dwDangCua === false && dwCuaChon === null && DW_HAN_GO === '');
chấm('mốc kết thúc bị xoá — không còn dấu nào của cú bấm nhầm', dwKetThucLuc === null);
chấm('bố cục về lại lúc chạy', dw().classList.contains('chay') && !dw().classList.contains('cua')
     && document.getElementById('dw-cua').style.display === 'none'
     && document.getElementById('dw-dang').style.display === '');
chấm('đúng MỘT bộ đếm sống lại', henSong === 1 && dwHen !== null);
chấm('mặt màn là ĐANG CHẠY, không phải ⏸', demNhanChay === 1 && demTamVe === 0);
chấm('localStorage khai đang chạy', nghiDaLuu() && nghiDaLuu().tam === 0 && nghiDaLuu().id === 'p1');
chấm('KHÔNG mất phút nào, cũng KHÔNG cộng oan: 25 giây nhìn ba cửa vẫn tính là làm',
     dwLamMs() === lamTruoc + 25000, `${dwLamMs()} ≠ ${lamTruoc + 25000}`);
chấm('có nói cho người ta biết mình đang ở đâu', NOI.some(t => t.includes('Về lại phiên')));

console.log('\n③ BẤM NHẦM LÚC ĐANG ⏸ — lui về vẫn ⏸, không cộng oan phút nghỉ');
moPhien(40);
bamTam();
const mocTam = dwTamLuc, lamKhiTam = dwLamMs();
troi(3 * 60000);                               // nghỉ 3 phút rồi mới bấm nhầm
await dwKetThuc();
chấm('cất được mốc ⏸ trước khi xoá', nhomTamTruoc() === mocTam);
chấm('trong lúc ở màn ba cửa thì `dwTamLuc` đã bị xoá (nết cũ, không đụng)', dwTamLuc === 0);
troi(90000);                                   // đứng ở màn ba cửa thêm 1,5 phút
dwLuiPhien();
chấm('lui về đúng mặt ⏸, không phải mặt chạy', demTamVe === 1 && demNhanChay === 0);
chấm('không bật bộ đếm nào — đang nghỉ thì đồng hồ phải đứng', dwHen === null && henSong === 0);
chấm('mốc ⏸ trả lại nguyên vẹn', dwTamLuc === mocTam);
chấm('localStorage khai đang ⏸', nghiDaLuu() && nghiDaLuu().tam === mocTam);
chấm('4,5 phút nghỉ + đứng nhìn KHÔNG thành phút làm', dwLamMs() === lamKhiTam,
     `${dwLamMs()} ≠ ${lamKhiTam}`);

console.log('\n④ KHÔNG RÒ SANG LẦN SAU — ⏸ rồi lui, chạy tiếp rồi lui lần nữa');
dwNghiMs += GIO - dwTamLuc; dwTamLuc = 0;      // ruột của `dwTiepTuc`
dwHen = setInterval(dwVe, 1000);
demTamVe = 0; demNhanChay = 0;
troi(6 * 60000);
await dwKetThuc();
dwLuiPhien();
chấm('lần này về mặt CHẠY, không dính mặt ⏸ của lần trước',
     demNhanChay === 1 && demTamVe === 0 && dwTamLuc === 0);
chấm('cửa sổ nhòm: `dwTamTruocCua` đã dọn về 0', nhomTamTruoc() === 0);
chấm('vẫn đúng một bộ đếm sống sau bốn lượt bật/dọn', henSong === 1 && demBat === demDon + 1);

console.log('\n⑤ PHIÊN TỰ KẾT THÚC (trần 180 phút) — không bày nút lui');
moPhien(180);
await dwKetThuc(true);
chấm('nút lui bị ẩn', nutLui().style.display === 'none');
chấm('vẫn vào màn ba cửa như thường', dwDangCua === true);

console.log('\n⑥ HAI CỬA CHẶN — gọi nhầm `dwLuiPhien` thì không xảy ra gì');
moPhien(40);
const truocKhiGoi = {hen: dwHen, song: henSong};
dwLuiPhien();                                  // đang chạy, chưa vào màn cửa
chấm('đang chạy mà gọi lui: không đụng gì',
     dwHen === truocKhiGoi.hen && henSong === truocKhiGoi.song && demNhanChay === 0);
dwPhien = null; dwDangCua = true;
dwLuiPhien();                                  // không còn phiên
chấm('không còn phiên mà gọi lui: không đụng gì', demNhanChay === 0 && henSong === truocKhiGoi.song);

console.log('\n⑦ ĐƯỜNG CŨ KHÔNG HỎNG — phiên dưới 5 phút vẫn hỏi trước');
moPhien(3);
await dwKetThuc();
chấm('hộp hỏi bật lên, KHÔNG vào màn ba cửa', hopMo === 1 && dwDangCua === false);
chấm('đồng hồ vẫn chạy nguyên', henSong === 1);

console.log(`\n${truot ? '❌' : '✅'}  ${dat}/${dat + truot} đạt` + (truot ? ` · ${truot} trượt` : ''));
process.exit(truot ? 1 : 0);

})();
