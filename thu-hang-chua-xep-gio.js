/* THỬ: HÀNG "CHƯA XẾP GIỜ" THEO CỘT + CẦM VIỆC ĐÃ CÓ NGÀY
   ─────────────────────────────────────────────────────────────────────────────
   Tracy chốt 01/09 (phương án D, dựng theo TickTick sau khi soi tám app):
   việc đã hẹn NGÀY mà chưa hẹn GIỜ đứng trong đúng cột ngày của nó, chiều cao
   hàng do tay kéo, và việc chưa có NGÀY dọn ra khay trượt ngoài lưới.

   Bài thử CẮT ĐÚNG CÁC KHỐI GỐC ra khỏi public/index.html rồi chạy trên DOM giả
   — không chép tay một dòng logic nào sang đây.

   Bốn ca đáng giá nhất:
     · Việc của thứ Năm phải nằm ở CỘT thứ Năm, không phải một dòng trải ngang.
     · Hàng thấp thì cắt bớt và "+N" phải đếm ĐÚNG phần bị cắt; kéo cao ra thì
       số thanh bày ra phải tăng theo — nếu không thì cái kéo chỉ là trang trí.
     · `tlkCam` phải cầm được việc CHỈ có trong `TLG_VIEC` (hàng cả ngày), không
       riêng việc trong `TL_KHO_DS` — đây đúng là lỗ đã đóng hôm nay.
     · Cầm việc từ KHAY thì khay phải tự đóng, vì cú chạm sau phải rơi vào ô giờ
       mà khay đang phủ lên.

   Chạy:  node production/tinh-thuc-app/thu-hang-chua-xep-gio.js
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
const NGUON = [
  /* Dừng TRƯỚC `tlgCnSangThanh`: bài thử cần thay nó bằng một cái cọc đếm
     lượt gọi, mà cắt cả khối thì bản thật đè lên cọc và ca ấy im lặng trượt. */
  catKhoi('const TLG_CN_KHOA =',   '/* Bật/tắt dấu "đang cầm" trên các thanh'),
  catKhoi('function tlgDaiCaNgay(', 'function tlgThanTuan('),
  catKhoi('function tlgDaiKho(kho){', '/* ══════ CỬA SỔ THÔNG TIN VIỆC'),
  catKhoi('function tlkCam(id){',  '/* Bật/tắt lớp mời chạm trên bảy ô ngày'),
].join('\n');

/* ── Coc: du de cac khoi tren chay, khong hon ─────────────────────────────── */
const COC = `
/* Thêm 04/09 (TRI-104): hai hàm suy màu, cờ riêng tư thắng màu sơn tay.
   Chép ĐÚNG bản trong app chứ không dựng bản giả trả về chuỗi rỗng — bản giả
   thì mọi ca dưới đây chạy qua một nhánh không tồn tại ngoài đời. */
const mauSuKien = l => (l && l.rieng_tu) ? 'tim'  : ((l && l.mau) || '');
const mauViec   = t => (t && t.rieng_tu) ? 'hong' : ((t && t.mau) || '');
let KHO_LS = {};
const localStorage = {
  getItem: k => (k in KHO_LS ? KHO_LS[k] : null),
  setItem: (k, v) => { KHO_LS[k] = String(v); }
};
let VE_LAI_KHO = 0, VE_TIMELINE = 0, SANG_THANH = 0;
const document = { querySelector: () => null, querySelectorAll: () => [] };
/* Cua so man don: cong tac nay sinh sau bai thu. Mac dinh true dung nhu ma
   that khai, de cac ca duoi dung o nhanh thuong. */
let TL_SK_MO = true;
let MAN_RONG = true;                     /* true = tu 720px tro len */
function matchMedia(q){ return { matches: MAN_RONG }; }
const addEventListener = () => {}, removeEventListener = () => {};
function chuSach(s){ return String(s == null ? '' : s); }
function tlgVeLaiKho(){ VE_LAI_KHO++; }
function veTimeline(){ VE_TIMELINE++; }
function tlgCnSangThanh(){ SANG_THANH++; }
function tlkVeKhay(){}
function tlkSangOngay(){}
function tlkKeoOngayVaoTam(){}
function tlkBoXuong(){ TL_CAM = null; }
let TL_CAM = null, TL_THEM = null, TL_KHUNG = 'tuan';
let TL_DU_MO = false, TL_CK_MO = false, TLG_KHO_MO = false;
let TL_KHO_DS = [], TLG_VIEC = {};
`;

const chay = new Function(COC + NGUON + `
  return { tlgDaiCaNgay, tlgDaiChuaGio, tlgDaiKho, tlkCam, tlgCnCao, tlgCnDat, tlgCnNoi,
           doc: () => ({ TL_CAM, TLG_KHO_MO, VE_LAI_KHO, VE_TIMELINE, SANG_THANH, KHO_LS }),
           dat: o => { if ('MAN_RONG' in o) MAN_RONG = o.MAN_RONG;
                       if ('TL_KHO_DS' in o) TL_KHO_DS = o.TL_KHO_DS;
                       if ('TLG_VIEC' in o) TLG_VIEC = o.TLG_VIEC;
                       if ('TLG_KHO_MO' in o) TLG_KHO_MO = o.TLG_KHO_MO;
                       if ('TL_CAM' in o) TL_CAM = o.TL_CAM;
                       if ('TL_KHUNG' in o) TL_KHUNG = o.TL_KHUNG; },
           datCao: px => { KHO_LS['tlg-cn-cao'] = String(px); } };
`)();

/* ── Dữ liệu mẫu ──────────────────────────────────────────────────────────── */
const NGAYS = ['2026-09-01','2026-09-02','2026-09-03','2026-09-04',
               '2026-09-05','2026-09-06','2026-09-07'];
const viec = (id, ngay, ten, mau) => ({id, ngay, noi_dung: ten, mau, trang_thai: 'Chua_lam'});

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu) { dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

console.log('\n① Việc nằm đúng CỘT ngày của nó');
{
  const ds = [viec(1,'2026-09-04','Duyệt kịch bản','ngoc'), viec(2,'2026-09-01','Phân luồng','xtim')];
  const h = chay.tlgDaiChuaGio(NGAYS, ds);
  const oCot = h.split('<div class="tlg-ad-o">').slice(1);
  la('có đủ bảy ô cột', oCot.length === 7, 'đếm được ' + oCot.length);
  la('việc 04/09 nằm ở ô thứ tư', /Duyệt kịch bản/.test(oCot[3]));
  la('việc 01/09 nằm ở ô thứ nhất', /Phân luồng/.test(oCot[0]));
  la('ô thứ tư KHÔNG chứa việc của ngày khác', !/Phân luồng/.test(oCot[3]));
  la('có tay nắm kéo', h.includes('tlgCnKeoMo'));
  la('nhãn máng đọc là "chưa xếp giờ"', /chưa<br>xếp<br>giờ/.test(h) && !/cả<br>ngày/.test(h));
  la('KHÔNG còn nút xổ kiểu cũ', !h.includes('tlCnDoi'));
}

console.log('\n② Trần theo CHIỀU CAO, và "+N" đếm đúng phần bị cắt');
{
  const ds = [1,2,3,4,5].map(i => viec(i, '2026-09-01', 'Việc ' + i, 'cam'));
  chay.datCao(78); chay.tlgCnDat(78, true);
  const thap = chay.tlgDaiChuaGio(NGAYS, ds);
  const soThap = (thap.match(/tlg-ad-thanh/g) || []).length;
  const nThap  = (thap.match(/>\+(\d+)</) || [])[1];
  la('hàng 78px bày 2 thanh', soThap === 2, 'bày ' + soThap);
  la('nút cộng đếm đúng 3 việc còn lại', nThap === '3', 'đọc ra +' + nThap);
  la('tổng thanh + số cộng = tổng việc', soThap + Number(nThap) === 5);

  chay.tlgCnDat(200, true);
  const cao = chay.tlgDaiChuaGio(NGAYS, ds);
  const soCao = (cao.match(/tlg-ad-thanh/g) || []).length;
  la('kéo lên 200px thì bày hết 5 thanh', soCao === 5, 'bày ' + soCao);
  la('hết cắt thì không còn nút cộng', !/>\+\d+</.test(cao));
  la('chiều cao đã nhớ lại', chay.doc().KHO_LS['tlg-cn-cao'] === '200');
}

console.log('\n③ Màn hẹp: thanh mỏng hơn nên hàng chứa được nhiều hơn');
{
  const ds = [1,2,3,4,5].map(i => viec(i, '2026-09-01', 'Việc ' + i, 'cam'));
  chay.tlgCnDat(78, true);
  chay.dat({MAN_RONG: false});
  const hep = chay.tlgDaiChuaGio(NGAYS, ds);
  const soHep = (hep.match(/tlg-ad-thanh/g) || []).length;
  la('cùng 78px, màn hẹp bày hết 5 thanh', soHep === 5, 'bày ' + soHep);
  la('nên không còn nút cộng', !/>\+\d+</.test(hep));
  chay.dat({MAN_RONG: true});
}

console.log('\n③b Hàng CO theo số việc, không chiếm chỗ thừa');
{
  const mot = [viec(1, '2026-09-01', 'Một việc thôi', 'cam')];
  chay.tlgCnDat(220, true);
  const h = chay.tlgDaiChuaGio(NGAYS, mot);
  const cao = +(h.match(/--tlg-ad-cao:(\d+)px/) || [])[1];
  la('một việc thì hàng chỉ cao 33px dù trần 220', cao === 33, 'cao ' + cao);
  la('trần vẫn giữ nguyên để lần sau kéo tiếp', chay.tlgCnCao() === 220);
  chay.tlgCnDat(78, true);
}

console.log('\n④ Chiều cao bị kẹp trong khoảng cho phép');
{
  chay.tlgCnDat(9999, false);  la('trần trên 220px', chay.tlgCnCao() === 220, 'ra ' + chay.tlgCnCao());
  chay.tlgCnDat(-50, false);   la('sàn 22px', chay.tlgCnCao() === 22, 'ra ' + chay.tlgCnCao());
  chay.tlgCnDat(78, true);
}

console.log('\n⑤ Cầm việc CHỈ có trong hàng cả ngày (lỗ đã đóng hôm nay)');
{
  const t = viec(77, '2026-09-02', 'Gọi khách Bybit', 'vang');
  chay.dat({TL_KHO_DS: [], TLG_VIEC: {77: t}, TL_CAM: null, TL_KHUNG: 'tuan'});
  chay.tlkCam(77);
  la('cầm được việc không có trong kho', chay.doc().TL_CAM && chay.doc().TL_CAM.id === 77,
     'TL_CAM = ' + JSON.stringify(chay.doc().TL_CAM));
  la('có bật lại dấu đang cầm trên thanh', chay.doc().SANG_THANH > 0);
  const truoc = chay.doc().TL_CAM;
  chay.tlkCam(77);
  la('chạm lại đúng việc ấy = bỏ xuống', chay.doc().TL_CAM === null, 'còn ' + JSON.stringify(truoc));
}

console.log('\n⑥ Cầm việc TỪ KHAY thì khay tự đóng');
{
  const k = viec(88, null, 'Đọc chương 4 Traction', 'tim');
  chay.dat({TL_KHO_DS: [k], TLG_VIEC: {}, TL_CAM: null, TLG_KHO_MO: true, TL_KHUNG: 'tuan'});
  chay.tlkCam(88);
  la('khay đóng lại sau khi cầm', chay.doc().TLG_KHO_MO === false);
  la('vẫn đang cầm đúng việc ấy', chay.doc().TL_CAM && chay.doc().TL_CAM.id === 88);
}

console.log('\n⑦ Khay "Sắp xếp việc" — nút, nền mờ, và lời nhắc');
{
  chay.dat({TLG_KHO_MO: false, TL_CAM: null});
  const dong = chay.tlgDaiKho([viec(9, null, 'Sắp ảnh cưới', 'hong')]);
  la('khay đóng thì chỉ có một nút', dong.includes('tlg-kho-nut') && !dong.includes('tlg-khay-nen'));
  /* Canh CON SỐ, không canh chữ trên nút: nhãn đã đi từ "Sắp xếp việc" sang
     "🧺 Kho việc", và một bài thử gác câu chữ thì đỏ mỗi lần ai đó sửa lời. */
  la('nút mang số việc trong kho', /tlg-kho-nut[^>]*>[^<]*<b>1<\/b>/.test(dong), dong.slice(0, 90));
  chay.dat({TLG_KHO_MO: true});
  const mo = chay.tlgDaiKho([viec(9, null, 'Sắp ảnh cưới', 'hong')]);
  la('khay mở thì có nền mờ đóng được', mo.includes('tlg-khay-nen') && mo.includes('tlgGapKho'));
  la('có lời nhắc chạm ô giờ', mo.includes('chạm một ô giờ'));
  la('kho rỗng thì nói ra, không để trống trơn',
     chay.tlgDaiKho([]).includes('Không có việc nào chờ xếp lịch'));
}

console.log('\n⑧ Dấu "đang cầm" quét đúng thanh nào');
{
  const KHOI = catKhoi('function tlgCnSangThanh(){', 'function tlgGapKho(){');
  const the = [
    {dataset:{id:'5'}, cls:{}, classList:{toggle(c,b){ this._o.cls[c] = b; }}},
    {dataset:{id:'6'}, cls:{}, classList:{toggle(c,b){ this._o.cls[c] = b; }}}
  ];
  the.forEach(o => { o.classList._o = o; });
  const goi = new Function('document','TL_CAM', KHOI + ';tlgCnSangThanh();');
  goi({querySelectorAll: () => the}, {id: 6});
  la('thanh đang cầm được đánh dấu', the[1].cls.cam === true);
  la('thanh khác thì gỡ dấu', the[0].cls.cam === false);
}

console.log('\n⑨ Hàng chưa xếp giờ rỗng thì KHÔNG chiếm chỗ');
{
  la('không việc nào thì không vẽ hàng', !chay.tlgDaiChuaGio(NGAYS, []).includes('tlg-ad-luoi'));
  la('nhưng vẫn vẽ khi có dự án',
     chay.tlgDaiCaNgay(NGAYS, [], [{id:1, ten:'Dự án A', ngay_bat_dau:'2026-09-01', han:'2026-09-05',
                                    trang_thai:'dang-chay'}]).includes('tlg-nhom du'));
}

console.log('\n' + (truot ? '❌ ' + truot + ' ca trượt, ' : '✅ ') + dat + ' ca đạt.');
process.exit(truot ? 1 : 0);
