/* THỬ: VẤN ĐỀ LIÊN PHÒNG BAN — nấc Vấn đề của kênh thông báo (TRI-112)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09: *"mình có kênh thông báo ấy, các vấn đề và thông báo đều đưa lên
   kênh đó đi"* · *"lead tự giao chứ nhỉ, người ghi vấn đề có thể chưa biết giao
   cho ai đâu"* · *"ô giao cho ai thì cho quyền phòng ban xử lý, phòng ghi vấn
   đề, vận hành và điều hành được quyền edit"*.

   Bài thử cắt thẳng khối gốc từ `index.html` nên nó chấm đúng mã đang chạy,
   không chấm một bản chép tay.

   Sáu chỗ đáng canh nhất — cả sáu đều hỏng LẶNG nếu sai:

   ① THỨ TỰ QUÁ HẠN → MỨC → MỚI NHẤT. Sai thứ tự thì một vấn đề quá hạn nằm
      giữa bảng, và cả tính năng đồng hồ 24 giờ mất tác dụng mà không ai biết.

   ② CHƯA GIAO ĐÍCH DANH THÌ AI TRONG PHÒNG XỬ LÝ CŨNG NHẬN ĐƯỢC — và người
      ngoài phòng thì KHÔNG. Đây là bản sao của policy `sua_van_de` ở phía màn
      hình; lệch nhau là người ta bấm vào một cánh cửa khoá.

   ③ NÚT ĐÓNG CHỈ MỌC CHO NGƯỜI NÊU. Máy chủ có cò chặn thật, nhưng bày nút cho
      người không đóng được là hứa một việc rồi từ chối.

   ④ BỐN NHÓM SỬA ĐƯỢC ⇢. Thiếu một nhóm thì đúng người cần giao lại không thấy
      lối vào; thừa một nhóm thì bấm vào bị máy chủ đuổi.

   ⑤ GIAO CHO AI ĐỂ TRỐNG VẪN GHI ĐƯỢC, nhưng THIẾU PHÒNG XỬ LÝ thì không. Đây
      là chỗ Tracy đổi luật giữa phiên — dựng lại ràng buộc cũ là chặn đúng
      người đang bực.

   ⑥ Ô TICK KHÁCH: chưa tick thì KHÔNG có ô số điện thoại nào trong khung.

   Chạy:  node production/tinh-thuc-app/thu-van-de.js
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
const NGUON = catKhoi('let BT_DS   = [];', 'function moTab(ten, vuaNap){');

/* Cắt một vùng để SOI BẰNG VĂN BẢN (khác `catKhoi`, thứ cắt mã để chạy). Mốc
   cuối dò từ SAU mốc đầu — luật làn CV, 05/09: dò từ đầu tệp thì một bản chép
   sớm của mốc cuối làm vùng rơi về rỗng, mà vùng rỗng vừa đỏ oan vừa XANH oan
   (mọi `!x.includes(...)` trên chuỗi rỗng đều đúng). Mốc long ra thì trả cờ để
   gọi thành một ca đỏ CÓ TÊN, không ném lỗi — ném là mất cả bài. */
function vung(dau, cuoi){
  const i = SRC.indexOf(dau);
  if (i < 0) return {than:'', hong:'không thấy mốc đầu: ' + dau};
  const j = SRC.indexOf(cuoi, i + dau.length);
  if (j < 0) return {than:'', hong:'không thấy mốc cuối: ' + cuoi};
  return {than: SRC.slice(i, j), hong: ''};
}

/* ── Cọc ────────────────────────────────────────────────────────────────────
   Trả CÙNG MỘT vật cho cùng một id, không thì mỗi lượt đọc lại ra một ô trắng
   và bài thử chấm hư không. */
const COC = `
const KHO = {};
const document = { getElementById: (id) => (KHO[id] = KHO[id] || (() => {
  const L = new Set();
  return {innerHTML:'', textContent:'', style:{}, value:'', checked:false,
          classList:{toggle:(c,b)=>{b?L.add(c):L.delete(c)}, contains:c=>L.has(c),
                     add:c=>L.add(c), remove:c=>L.delete(c)}};
})()) };
let ME = null, DOI = [], CHUC_NANG = [], HOM_NAY = '2026-09-05';
let GHI = [], DAY = [], SB_LOI = null;
const homNay = () => HOM_NAY;
const d2s = d => d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0')
               + '-' + String(d.getDate()).padStart(2,'0');
/* Hộp hỏi dùng chung nằm NGOÀI lát cắt (hopHoiMo ở tận dòng 18615), nên cọc
   lại đúng hai hàm ấy và giữ chuỗi HTML để chấm bộ nút.
   ⛔ KHÔNG dùng dấu huyền trong khối này: cả khối COC là MỘT chuỗi mẫu, một
   dấu huyền lạc vào là cắt đôi nó và Node ngã ở dòng đầu tiên. */
let HOP = null;
const hopHoiMo = (html) => { HOP = html; };
const hopHoiDong = () => { HOP = null; };
const window = {};
const chuSach = (s) => String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
const lcTenKhoi = (id) => (CHUC_NANG.find(c => c.id === id) || {}).ten || 'khối đã gỡ';
const toast = (m) => GHI.push(m);
const setTimeout = () => {};
/* select() trả một vật vừa CHỜ ĐƯỢC vừa nối được .eq().order() — vì mã thật
   dùng cả hai lối: đếm bình luận thì await select(...) thẳng, còn lấy mạch bàn
   luận của một vấn đề thì select(...).eq(...).order(...). */
const sb = { from: (bang) => ({
  select: () => {
    const kq = () => bang === 'van_de_binh_luan'
        ? (SB_LOI_BL ? {error: SB_LOI_BL} : {error: null, data: BL_DU})
        : (SB_LOI    ? {error: SB_LOI}    : {error: null, data: VD_DU});
    const day = { order: async () => kq(), eq: () => day,
                  in: async () => ({error:null, data: []}),
                  then: (f, r) => Promise.resolve(kq()).then(f, r) };
    return day;
  },
  insert: async (g) => { DAY.push({bang, loai:'insert', g}); return {error: SB_LOI_GHI}; },
  upsert: async (g) => { DAY.push({bang, loai:'upsert', g}); return {error: null}; },
  update: (g) => ({ eq: async (c, v) => { DAY.push({bang, loai:'update', g, id:v});
                                          return {error: SB_LOI_GHI}; } })
}) };
let VD_DU = [], BL_DU = [], SB_LOI_GHI = null, SB_LOI_BL = null;
`;

const M = new Function(COC + NGUON + `
  return {
    vdDaDong, vdQuaHan, vdCuaToi, vdSuaDuoc, vdToiNhan, vdToiDong, vdTrongKhoi,
    vdVanHanh, vdXep, vdHop, vdChuanSdt, vdDongHo, vdLap, vdDemDoi,
    vdVe, vdTai, vdVeCua, vdMoCua, vdLuu, vdNhan, vdDongVanDe, vdMoGiao,
    vdLuuGiao, vdChonKhoi, vdBungThem, vdTickKhach, vdDoiLoc, vdDoiXong,
    ktbNac, ktbVeNac, btChamMoi,
    vdToiXuLy, vdToiBo, vdNutNac, vdLucBl, vdTaiBl, vdMoChiTiet, vdVeChiTiet,
    vdGuiBl, vdDatNac, vdChoBenKhac, vdHoiKhongLam, vdCoTin, vdDongCua,
    dat: (o) => {
      if ('me'  in o) ME = o.me;
      if ('doi' in o) DOI = o.doi;
      if ('cn'  in o) CHUC_NANG = o.cn;
      if ('ds'  in o) { VD_DS = o.ds; VD_DU = o.ds; }
      if ('bl'  in o) { VD_BL = o.bl; BL_DU = o.bl; } else { VD_BL = []; BL_DU = []; }
      if ('dem' in o) VD_BL_DEM = o.dem; else VD_BL_DEM = {};
      VD_CT = 'ct' in o ? o.ct : null;
      SB_LOI_BL = o.loiBl || null; HOP = null;
      SB_LOI = o.loi || null; SB_LOI_GHI = o.loiGhi || null;
      GHI = []; DAY = [];
      KTB_NAC = 'nac' in o ? o.nac : 'vande';
      VD_LOC = 'loc' in o ? o.loc : 0;
      VD_XONG = 'xong' in o ? o.xong : false;
      VD_KHOI = 'khoi' in o ? o.khoi : 0;
      VD_KHOI_NEU = 'khoiNeu' in o ? o.khoiNeu : 0;
      VD_CO_KHACH = 'coKhach' in o ? o.coKhach : false;
      VD_MO_THEM = false; VD_GIAO = null; VD_KHACH = {};
      CO_VAN_DE = 'coVanDe' in o ? o.coVanDe : true;
      CO_BAN_TIN = false; BT_DS = [];
    },
    o: (id) => KHO[id] || {innerHTML:'', textContent:'', style:{}},
    ghi: () => GHI, day: () => DAY, coVanDe: () => CO_VAN_DE,
    hop: () => HOP, boThat: () => window.vdBoThat && window.vdBoThat(),
    ct: () => VD_CT, bl: () => VD_BL, dem: () => VD_BL_DEM,
    cham: () => KHO['nut-bt'] && KHO['nut-bt'].classList.contains('co-cham')
  };
`)();

/* ── Khung chấm ──────────────────────────────────────────────────────────── */
let dat = 0, hong = 0;
function ok(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { hong++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}
function bang(ten, thuc, mong){
  ok(ten, thuc === mong, 'ra ' + JSON.stringify(thuc) + ' · mong ' + JSON.stringify(mong));
}

/* ── Người và khối ───────────────────────────────────────────────────────── */
const CN = [{id:1,ten:'CEO'},{id:2,ten:'Vận hành'},{id:3,ten:'Sản phẩm'},
            {id:4,ten:'Kinh doanh'},{id:5,ten:'Tài chính'},
            {id:6,ten:'Trải nghiệm khách hàng'}];
const TRACY = {id:'u-tracy', ten:'Tracy', chuc_nang_ids:[1], la_quan_tri:true, la_lead:true};
const HAFI  = {id:'u-hafi',  ten:'Hafi',  chuc_nang_ids:[3], la_lead:true};
const NGOC  = {id:'u-ngoc',  ten:'Ngọc',  chuc_nang_ids:[6]};
const ANDY  = {id:'u-andy',  ten:'Andy',  chuc_nang_ids:[2]};   // Vận hành
const KHACH = {id:'u-khach', ten:'Khách', chuc_nang_ids:[5]};   // ngoài mọi cuộc
const DOI   = [TRACY, HAFI, NGOC, ANDY, KHACH];
const NEN   = {doi: DOI, cn: CN, ds: []};

const GIO = 36e5;
let n = 0;
const vd = (o) => Object.assign({
  id: ++n, tieu_de: 'Vấn đề ' + n, mo_ta: '',
  nguoi_neu_id: 'u-ngoc', chuc_nang_neu: 6,
  chuc_nang_nhan: 3, nguoi_nhan_id: null,
  khach_sdt: null, muc: 2, trang_thai: 'moi', loai_lap: '',
  han_tra_loi: new Date(Date.now() + 4 * GIO).toISOString(),
  nhan_luc: null, dong_luc: null,
  tao_luc: new Date(Date.now() - GIO).toISOString()
}, o);

const TRE  = () => vd({han_tra_loi: new Date(Date.now() - 4 * GIO).toISOString()});

(async () => {
console.log('\n▶ VẤN ĐỀ LIÊN PHÒNG — thu-van-de.js\n');

/* ═══ 1. Quá hạn, và đồng hồ dừng khi có người nhận ═══ */
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('chưa ai nhận và đã qua hạn → quá hạn',  M.vdQuaHan(TRE()));
ok('còn hạn thì không quá hạn',             !M.vdQuaHan(vd({})));
ok('ĐÃ NHẬN thì thôi quá hạn, dù hạn đã trôi qua',
   !M.vdQuaHan(vd({han_tra_loi: new Date(Date.now() - 9 * GIO).toISOString(),
                   nhan_luc: new Date().toISOString()})));
ok('đã đóng thì cũng thôi quá hạn',
   !M.vdQuaHan(vd({han_tra_loi: new Date(Date.now() - 9 * GIO).toISOString(),
                   trang_thai: 'xong'})));

/* ═══ 2. Thứ tự: quá hạn → mức → mới nhất ═══ */
const A = TRE();                                   // quá hạn, mức vừa
const B = vd({muc: 1});                            // còn hạn, nghiêm trọng
const C = vd({muc: 3});                            // còn hạn, nhẹ
const xep = M.vdXep([C, B, A]).map(v => v.id);
bang('quá hạn đứng đầu bảng bất kể mức',  xep[0], A.id);
bang('rồi tới mức nghiêm trọng',          xep[1], B.id);
bang('rồi mới tới mức nhẹ',               xep[2], C.id);

/* ═══ 3. Chưa giao đích danh: người TRONG phòng xử lý nhận được ═══
   Đây là chỗ Tracy đổi luật giữa phiên. Vấn đề "giao cho phòng Sản phẩm":
   Hafi (Sản phẩm) nhận được, Ngọc (Trải nghiệm khách hàng) thì không. */
const CHUA_GIAO = vd({chuc_nang_nhan: 3, nguoi_nhan_id: null});
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('người trong phòng xử lý nhận được vấn đề chưa giao', M.vdToiNhan(CHUA_GIAO));
M.dat(Object.assign({}, NEN, {me: NGOC}));
ok('người NGOÀI phòng xử lý thì không',                  !M.vdToiNhan(CHUA_GIAO));

const DA_GIAO = vd({chuc_nang_nhan: 3, nguoi_nhan_id: 'u-hafi'});
M.dat(Object.assign({}, NEN, {me: ANDY}));
ok('đã giao đích danh rồi thì người khác trong phòng thôi nhận được',
   !M.vdToiNhan(vd({chuc_nang_nhan: 2, nguoi_nhan_id: 'u-hafi'})));
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('đúng người được giao thì nhận được', M.vdToiNhan(DA_GIAO));

/* ═══ 4. Nút Đóng chỉ mọc cho NGƯỜI NÊU, và chỉ khi đã có người nhận ═══ */
const DANG_CHAY = vd({nguoi_neu_id:'u-ngoc', nhan_luc: new Date().toISOString(),
                      trang_thai:'da_nhan'});
M.dat(Object.assign({}, NEN, {me: NGOC}));
ok('người nêu đóng được vấn đề đã có người nhận', M.vdToiDong(DANG_CHAY));
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('người xử lý KHÔNG đóng được',                !M.vdToiDong(DANG_CHAY));
M.dat(Object.assign({}, NEN, {me: TRACY}));
ok('quản trị cũng không mọc nút Đóng — chỉ người nêu',
   !M.vdToiDong(DANG_CHAY));
M.dat(Object.assign({}, NEN, {me: NGOC}));
ok('chưa ai nhận thì chưa có gì để đóng', !M.vdToiDong(vd({nguoi_neu_id:'u-ngoc'})));

/* ═══ 5. Bốn nhóm sửa được ⇢ — bản sao policy `sua_van_de` ═══
   Vấn đề: Trải nghiệm khách hàng (6) ghi → Sản phẩm (3) xử lý. */
const V = vd({chuc_nang_neu: 6, chuc_nang_nhan: 3,
              nguoi_neu_id: 'u-ngoc', nguoi_nhan_id: null});
const suaDuoc = (ai) => { M.dat(Object.assign({}, NEN, {me: ai})); return M.vdSuaDuoc(V); };
ok('① phòng XỬ LÝ sửa được',      suaDuoc(HAFI));
ok('② phòng GHI sửa được',        suaDuoc(NGOC));
ok('③ Vận hành sửa được',         suaDuoc(ANDY));
ok('④ điều hành sửa được',        suaDuoc(Object.assign({}, KHACH, {la_dieu_hanh:true})));
ok('   quản trị cũng sửa được',   suaDuoc(TRACY));
ok('người ngoài cả bốn nhóm thì KHÔNG', !suaDuoc(KHACH));

/* Khối Vận hành tra theo TÊN chứ không ghim số — máy chủ dựng lại có thể đánh
   số khác. Đổi id của khối Vận hành mà quyền vẫn đúng thì phép tra là đúng. */
M.dat({doi: DOI, cn: [{id:9,ten:'Vận hành'}], ds: [], me: {id:'x', ten:'X', chuc_nang_ids:[9]}});
ok('Vận hành tra theo tên, không ghim số', M.vdVanHanh());

/* ═══ 6. Đồng hồ nói gì ═══ */
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('chưa giao đích danh thì đồng hồ gọi tên PHÒNG, không gọi "ai đó"',
   /Nêu /.test(M.vdDongHo(vd({}))));
ok('đã nhận thì đồng hồ thôi đếm ngược',
   !/Còn |Quá hạn/.test(M.vdDongHo(vd({nguoi_nhan_id:'u-hafi',
      nhan_luc: new Date().toISOString(), trang_thai:'da_nhan'}))));
ok('quá hạn thì nói thẳng là quá hạn', /Quá hạn/.test(M.vdDongHo(TRE())));
ok('sát hạn ≤4 giờ thì đeo màu cảnh báo',
   /class="gap"/.test(M.vdDongHo(vd({han_tra_loi:
      new Date(Date.now() + 2 * GIO).toISOString()}))));
ok('còn nhiều giờ thì KHÔNG đeo màu — một màu lúc nào cũng sáng thì thôi làm tín hiệu',
   !/class="gap"/.test(M.vdDongHo(vd({han_tra_loi:
      new Date(Date.now() + 20 * GIO).toISOString()}))));

/* ═══ 7. Luật lặp ba lần trong 90 ngày ═══ */
const lap = (i, ngay) => vd({loai_lap:'loc-crm',
  tao_luc: new Date(Date.now() - ngay * 864e5).toISOString()});
M.dat(Object.assign({}, NEN, {me: HAFI, ds: [lap(1,1), lap(2,2)]}));
bang('hai lần thì chưa gợi ý gì', M.vdLap().length, 0);
M.dat(Object.assign({}, NEN, {me: HAFI, ds: [lap(1,1), lap(2,2), lap(3,3)]}));
bang('đủ ba lần trong 90 ngày thì gợi ý sửa quy trình', M.vdLap().length, 1);
M.dat(Object.assign({}, NEN, {me: HAFI, ds: [lap(1,1), lap(2,2), lap(3,120)]}));
bang('lần thứ ba nằm ngoài 90 ngày thì không tính', M.vdLap().length, 0);
M.dat(Object.assign({}, NEN, {me: HAFI,
  ds: [vd({loai_lap:''}), vd({loai_lap:''}), vd({loai_lap:''})]}));
bang('vấn đề không có nhãn gom thì không bị gom nhầm', M.vdLap().length, 0);

/* ═══ 8. Chuẩn hoá số điện thoại về 84xxx ═══ */
bang('số 0 đầu thành 84',      M.vdChuanSdt('0912345678'), '84912345678');
bang('+84 thành 84',           M.vdChuanSdt('+84912345678'), '84912345678');
bang('có khoảng trắng cũng được', M.vdChuanSdt('0912 345 678'), '84912345678');
bang('đã đúng dạng thì để yên', M.vdChuanSdt('84912345678'), '84912345678');
bang('ô trống trả về chuỗi rỗng', M.vdChuanSdt(''), '');

/* ═══ 9. Cửa ghi — hai ô bắt buộc, không phải ba ═══ */
M.dat(Object.assign({}, NEN, {me: NGOC}));
M.vdMoCua();
let h = M.o('vd-than').innerHTML;
ok('nhãn là "Tên vấn đề", không phải "Vấn đề là gì"',  /Tên vấn đề/.test(h));
ok('nhãn là "Phòng xử lý", không phải "Phòng gỡ được"', /Phòng xử lý/.test(h));
ok('ô Giao cho ai KHÔNG mang dấu sao bắt buộc',
   /Giao cho ai<\/p>/.test(h), h.slice(0, 200));
ok('bộ chọn người nói rõ bỏ trống thì ai giao',
   /để lead phòng xử lý giao/.test(h));
ok('chưa tick khách thì KHÔNG có ô số điện thoại nào', !/vd-khach/.test(h));
ok('ô tick khách có mặt', /vd-co-khach/.test(h));

M.vdTickKhach({checked:true});
ok('tick rồi thì ô số điện thoại xổ ra', /vd-khach/.test(M.o('vd-than').innerHTML));

/* ═══ 10. Lưu — giao cho ai để trống vẫn được, thiếu phòng xử lý thì không ═══ */
M.dat(Object.assign({}, NEN, {me: NGOC}));
M.vdMoCua();
M.o('vd-ten').value = 'Lọc khách trong CRM ra sai số';
await M.vdLuu();
bang('thiếu phòng xử lý thì không ghi gì lên máy chủ', M.day().length, 0);
ok('và nói rõ thiếu gì', /Chưa chọn phòng xử lý/.test(M.ghi().join(' ')));

M.dat(Object.assign({}, NEN, {me: NGOC}));
M.vdMoCua();
M.o('vd-ten').value = 'Lọc khách trong CRM ra sai số';
M.vdChonKhoi(3);
await M.vdLuu();
bang('đủ tên và phòng xử lý là ghi được, dù chưa giao cho ai', M.day().length, 1);
bang('và ô người nhận đi lên là rỗng, không phải chuỗi trống',
  M.day()[0].g.nguoi_nhan_id, null);
bang('phòng xử lý đi đúng', M.day()[0].g.chuc_nang_nhan, 3);
bang('phòng ghi máy tự điền vì Ngọc chỉ ngồi một phòng',
  M.day()[0].g.chuc_nang_neu, 6);
bang('người nêu là chính mình', M.day()[0].g.nguoi_neu_id, 'u-ngoc');

/* ═══ 11. Nhận — chưa giao thì cú bấm ghi luôn tên người bấm ═══ */
M.dat(Object.assign({}, NEN, {me: HAFI, ds: [vd({id: 77, chuc_nang_nhan: 3,
                                                 nguoi_nhan_id: null})]}));
await M.vdNhan(77);
const g = M.day()[0].g;
ok('bấm Nhận thì dừng đồng hồ', !!g.nhan_luc);
bang('và chuyển trạng thái', g.trang_thai, 'da_nhan');
bang('và ghi luôn tên người bấm vào ô người nhận', g.nguoi_nhan_id, 'u-hafi');

M.dat(Object.assign({}, NEN, {me: HAFI, ds: [vd({id: 78, chuc_nang_nhan: 3,
                                                 nguoi_nhan_id: 'u-hafi'})]}));
await M.vdNhan(78);
ok('đã có tên sẵn thì cú Nhận không ghi đè ô ấy',
   !('nguoi_nhan_id' in M.day()[0].g));

/* ═══ 12. Cửa lùi — máy chủ chưa có bảng thì nấc tự rút ═══
   Mã lên sóng ngay khi đẩy, tệp SQL thì Tracy chạy tay sau đó. Cầu phải bắc
   qua khoảng chờ ấy, không thì cả app gãy trong lúc chờ một câu lệnh. */
M.dat(Object.assign({}, NEN, {me: NGOC, loi: {message: 'relation "van_de" does not exist'}}));
await M.vdTai();
ok('máy chủ chưa có bảng → cờ hạ xuống', !M.coVanDe());
bang('và khối tự ẩn thay vì bày một khung hỏng', M.o('vd-the').style.display, 'none');
M.vdMoCua();
ok('bấm Ghi vấn đề lúc ấy thì nói rõ phải chạy tệp nào',
   /nang-cap-van-de-lien-phong\.sql/.test(M.ghi().join(' ')));

/* ═══ 12b. Cầu bắc qua khoảng chờ tệp SQL THỨ HAI ═══
   Bảng đã có (nhát 1 chạy rồi) nhưng cột chưa nới — câu máy chủ trả về là một
   lỗi not-null. Nó phải chỉ đúng TỆP CÒN LẠI, không phải tệp đã chạy. */
M.dat(Object.assign({}, NEN, {me: NGOC, loiGhi: {message:
  'null value in column "nguoi_nhan_id" of relation "van_de" violates not-null constraint'}}));
M.vdMoCua();
M.o('vd-ten').value = 'Thử';
M.vdChonKhoi(3);
await M.vdLuu();
ok('lỗi not-null chỉ đúng tệp CÒN PHẢI CHẠY',
   /nang-cap-van-de-giao-sau\.sql/.test(M.ghi().join(' ')), M.ghi().join(' '));
ok('và KHÔNG chỉ nhầm sang tệp đã chạy rồi',
   !/nang-cap-van-de-lien-phong\.sql/.test(M.ghi().join(' ')));

/* ═══ 13. Hai nấc ═══ */
M.dat(Object.assign({}, NEN, {me: NGOC, ds: [vd({})], nac: 'vande'}));
M.vdVe();
bang('nấc Vấn đề đang mở → khối vấn đề hiện', M.o('vd-the').style.display, '');
M.ktbNac('thongbao');
bang('bấm sang Thông báo thì khối vấn đề ẩn', M.o('vd-the').style.display, 'none');

/* ═══ 14. Mức nói bằng VẠCH, quá hạn nói bằng NỀN ═══
   Từ làn VDL danh sách đi hình bảng việc: mức 1 thôi đeo viên chữ "Nghiêm
   trọng", nó thành ba vạch đỏ 13px đầu dòng. Ô vạch vẫn giữ chỗ ở MỌI dòng để
   lưới thẳng hàng — nên ca dưới kiểm lớp `m1`, không kiểm sự có mặt của `vd-uu`. */
M.dat(Object.assign({}, NEN, {me: NGOC, ds: [vd({muc: 1})]}));
M.vdVe();
h = M.o('vd-ds').innerHTML;
ok('mức nghiêm trọng bày vạch đỏ', /vd-uu m1/.test(h));
ok('và thôi đeo viên chữ Nghiêm trọng', !/Nghiêm trọng/.test(h));
M.dat(Object.assign({}, NEN, {me: NGOC, ds: [vd({muc: 2})]}));
M.vdVe();
h = M.o('vd-ds').innerHTML;
ok('mức vừa KHÔNG bày vạch nào', !/vd-uu m1/.test(h));
ok('nhưng ô vạch vẫn giữ chỗ để lưới thẳng hàng', /vd-uu/.test(h));
M.dat(Object.assign({}, NEN, {me: NGOC, ds: [TRE()]}));
M.vdVe();
h = M.o('vd-ds').innerHTML;
ok('dòng quá hạn đeo nền pha đậm', /vd-hang tre/.test(h));
ok('và vòng trạng thái của nó đi màu quá hạn', /vd-tt tre/.test(h));

/* ═══ 14b. GOM THEO NHÓM TRẠNG THÁI ═══
   Mỗi vấn đề rơi vào ĐÚNG một nhóm, và *quá hạn nhận* phải đứng trước *mới*:
   xét đúng thì một vấn đề quá hạn vẫn mang trạng thái `moi`, nên thứ tự xét là
   thứ giữ nó khỏi bị chôn giữa những việc còn thời gian. */
const DA_NHAN = new Date(Date.now() - 36e5).toISOString();
M.dat({...NEN, me: NGOC, ds: [TRE(), vd({id: 91}),
       vd({id: 92, trang_thai: 'dang_xu_ly', nhan_luc: DA_NHAN}),
       vd({id: 93, trang_thai: 'cho_ben_khac', nhan_luc: DA_NHAN})], dem: {}});
M.vdVe();
h = M.o('vd-ds').innerHTML;
ok('bốn nhóm cùng hiện, mỗi nhóm một đầu mục',
   ['Quá hạn nhận', 'Mới', 'Đang xử lý', 'Chờ bên khác'].every(t => h.includes(t)));
ok('quá hạn đứng TRƯỚC nhóm Mới',
   h.indexOf('Quá hạn nhận') < h.indexOf('>Mới'));
ok('mỗi dòng vào đúng một nhóm', (h.match(/vd-hang/g) || []).length === 4);
M.dat({...NEN, me: NGOC, ds: [vd({id: 94})], dem: {}});
M.vdVe();
h = M.o('vd-ds').innerHTML;
ok('nhóm rỗng KHÔNG bày đầu mục mang số 0', !h.includes('Quá hạn nhận'));
ok('mã VD- hiện trên dòng để hai người gọi tên nhau', /VD-94/.test(h));

/* ═══ 15. KHOÁ `CB_LOAI` PHẢI KHỚP NHÃN TRONG KHUNG NHÌN `cho_ban` ═══
   Đây là ca đắt nhất của cả bài. Chú thích của chính khung nhìn cảnh báo: khai
   một loại mới ở máy chủ mà quên khoá tương ứng trong `CB_LOAI` thì ô đếm cộng
   một dòng còn danh sách KHÔNG bày nó — một dòng chờ vô hình, không lỗi nào bật
   lên. Nên soi CHÉO hai tệp thay vì tin vào trí nhớ người sửa.

   Nguồn nhãn là tệp SQL nào dựng lại khung nhìn GẦN NHẤT, không phải tệp đầu
   tiên: `cho_ban` đã bị dựng lại ba lần, và mỗi lần số nhánh một khác. */
const SQL_VIEW = ['nang-cap-van-de-cho-ban.sql', 'nang-cap-trao-pic-du-an.sql']
  .map(t => path.join(__dirname, t)).find(t => fs.existsSync(t));
ok('tìm được tệp SQL dựng khung nhìn cho_ban', !!SQL_VIEW);
if (SQL_VIEW){
  const sql = fs.readFileSync(SQL_VIEW, 'utf8');
  const than = sql.slice(sql.indexOf('create view cho_ban as'));
  const nhan = [...new Set([...than.matchAll(/'([a-z-]+)'::text/g)].map(m => m[1]))];
  /* Mốc cuối dò TỪ SAU mốc đầu — bẫy TRI-132, xem DANG-LAM.md. */
  const khai = SRC.slice(SRC.indexOf('const CB_LOAI = {'),
                         SRC.indexOf('let CB_DANG', SRC.indexOf('const CB_LOAI = {')));
  ok('khung nhìn khai đủ bảy loại', nhan.length === 7,
     'thấy ' + nhan.length + ': ' + nhan.join(', '));
  const thieu = nhan.filter(k => !khai.includes("'" + k + "'"));
  ok('MỌI loại khung nhìn trả về đều có khoá trong CB_LOAI', thieu.length === 0,
     'thiếu khoá cho: ' + thieu.join(', ') + ' → ô đếm cộng dòng mà danh sách không bày');
  ok('và loại van-de nằm trong số đó', nhan.includes('van-de'));
}

/* ═══ 16. HÀNG NẤC TRẠNG THÁI — ai thấy nút nào (làn VD4) ═══
   Ba nấc `dang_xu_ly` · `cho_ben_khac` · `khong_lam` tới trước làn này vẫn CHẾT:
   máy chủ nhận, mà app không có lối nào đặt chúng. Hàng nút trong cửa chi tiết
   là lối ấy — nên nó là bản sao của cò `chan_sua_cot_van_de` ở phía màn hình, và
   lệch nhau là người ta bấm vào một cánh cửa khoá. */
console.log('\n── 16. Hàng nấc trạng thái ──');
const nutTen  = (v, me) => { M.dat({...NEN, me, ds:[v]}); return M.vdNutNac(v).map(x => x.chu).join('|'); };
const nutKieu = (v, me) => { M.dat({...NEN, me, ds:[v]}); return M.vdNutNac(v).map(x => x.chu + ':' + x.kieu).join('|'); };
const LUC = () => new Date().toISOString();

const DANHAN = vd({nguoi_nhan_id:'u-hafi', nhan_luc:LUC(), trang_thai:'da_nhan'});
bang('người cầm thấy hai nấc tiến', nutTen(DANHAN, HAFI), 'Đang xử lý|Chờ bên khác');
bang('và Đang xử lý là nút đặc duy nhất', nutKieu(DANHAN, HAFI),
     'Đang xử lý:chinh|Chờ bên khác:chim');

const DANGXL = vd({nguoi_nhan_id:'u-hafi', nhan_luc:LUC(), trang_thai:'dang_xu_ly'});
bang('đang ở nấc nào thì KHÔNG bày lại nấc đó', nutTen(DANGXL, HAFI), 'Chờ bên khác');
ok('lúc ấy hàng không có nút đặc nào — chờ bên khác không phải bước tiến',
   !nutKieu(DANGXL, HAFI).includes(':chinh'));

bang('người NÊU thấy đóng và lối ra', nutTen(DANHAN, NGOC), 'Đóng vấn đề|Không làm');
bang('đóng thì đặc, không làm thì đỏ VIỀN', nutKieu(DANHAN, NGOC),
     'Đóng vấn đề:chinh|Không làm:pha');

/* Chưa ai nhận thì người nêu chưa đóng được — người xử lý phải báo xong trước.
   Lối ra vẫn mở: một vấn đề nêu nhầm không phải chờ ai nhận rồi mới bỏ được. */
bang('chưa ai nhận: người nêu chỉ còn lối ra', nutTen(vd({}), NGOC), 'Không làm');

/* Vừa nêu vừa cầm là ca DUY NHẤT hai nút đặc đứng cạnh nhau được, nếu luật màu
   khai cứng theo tên nút. Bước tiếp thật của người ấy là Đóng. */
const CATHAI = vd({nguoi_neu_id:'u-hafi', chuc_nang_neu:3, nguoi_nhan_id:'u-hafi',
                   nhan_luc:LUC(), trang_thai:'da_nhan'});
bang('vừa nêu vừa cầm: đúng MỘT nút đặc',
     nutKieu(CATHAI, HAFI).split('|').filter(x => x.endsWith(':chinh')).length, 1);
ok('và nút đặc ấy là Đóng vấn đề, không phải Đang xử lý',
   nutKieu(CATHAI, HAFI).includes('Đóng vấn đề:chinh'));

bang('người ngoài cuộc không thấy nút nào', nutTen(DANHAN, ANDY), '');
bang('vấn đề đã đóng thì hàng nút trống',
     nutTen(vd({trang_thai:'xong', nhan_luc:LUC(), dong_luc:LUC()}), NGOC), '');
bang('quản trị bỏ được vấn đề người khác nêu', nutTen(DANHAN, TRACY), 'Không làm');

/* ═══ 17. CỬA CHI TIẾT — một cửa, ba ruột ═══ */
console.log('\n── 17. Cửa chi tiết ──');
const CT = vd({tieu_de:'Khách không mở được video bài 4',
               mo_ta:'Chị Hoa thử hai máy vẫn quay vòng.',
               muc:1, loai_lap:'video khoá học', khach_sdt:'84912345678',
               nguoi_nhan_id:'u-hafi', nhan_luc:LUC(), trang_thai:'da_nhan'});
const BL = [
  {id:1, van_de_id:CT.id, nguoi_id:'u-hafi', noi_dung:'Video còn trên máy chủ.',
   tao_luc:LUC()},
  {id:2, van_de_id:CT.id, nguoi_id:'u-ngoc', noi_dung:'Chị ấy dùng 4G.',
   tao_luc:LUC()}
];
M.dat({...NEN, me:HAFI, ds:[CT], bl:BL, ct:CT.id});
M.vdVeChiTiet();
let than = M.o('vd-than').innerHTML;
ok('tiêu đề vấn đề nằm trong cửa', than.includes('Khách không mở được video bài 4'));
ok('mô tả nằm trong cửa', than.includes('Chị Hoa thử hai máy'));
ok('nhãn Nghiêm trọng chỉ mọc ở mức 1', /bt-tag nghiem/.test(than));
ok('nhãn gom vấn đề lặp hiện trong dải lý lịch', than.includes('video khoá học'));
ok('cả hai câu bàn luận đều bày ra',
   than.includes('Video còn trên máy chủ.') && than.includes('Chị ấy dùng 4G.'));
ok('mạch bàn luận đếm đúng số lượt', than.includes('Bàn luận · 2'));
ok('có ô soạn để viết tiếp', than.includes('id="vd-bl-o"'));
/* Máy chủ khoá theo chủ (`sua_van_de_bl`) và cố ý không có policy xoá — giao
   diện chỉ việc không bày nút, kể cả trên câu của chính mình. */
ok('KHÔNG có nút sửa hay xoá bình luận nào', !/vdSuaBl|vdXoaBl/.test(than));

const TRONG = vd({});
M.dat({...NEN, me:ANDY, ds:[TRONG], ct:TRONG.id});
M.vdVeChiTiet();
than = M.o('vd-than').innerHTML;
ok('chưa ai bàn thì có một dòng mời mở lời', than.includes('Chưa ai nói gì'));
ok('và người ngoài cuộc vẫn viết được — vấn đề là chuyện chung',
   than.includes('id="vd-bl-o"'));

/* Cửa vẽ lại mỗi khi có tin thời gian thực. Nuốt mất câu đang gõ dở đúng lúc
   người bên kia vừa gửi một câu là mất trắng công người ta — cùng lối
   `btVeCuaGiuNhap`. */
M.dat({...NEN, me:HAFI, ds:[CT], bl:BL, ct:CT.id});
M.vdVeChiTiet();
M.o('vd-bl-o').value = 'đang gõ dở';
M.vdVeChiTiet();
bang('câu đang gõ dở SỐNG SÓT qua một lượt vẽ lại',
     M.o('vd-bl-o').value, 'đang gõ dở');

/* ═══ 18. DÒNG DANH SÁCH MỞ RA CỬA, VÀ KHÔNG MỌC THÊM NÚT NÀO ═══
   Tracy bác một hàng lôm côm sáng 05/09. Cả dòng bấm được là lối vào rẻ nhất —
   nhưng ba nút bên trong phải CHẶN cú bấm nổi lên, không thì bấm Nhận cũng bung
   luôn cửa chi tiết. */
console.log('\n── 18. Dòng danh sách ──');
M.dat({...NEN, me:HAFI, ds:[vd({chuc_nang_nhan:3})], dem:{}});
M.vdVe();
let ds = M.o('vd-ds').innerHTML;
ok('cả dòng mở được cửa chi tiết', /onclick="vdMoChiTiet\(/.test(ds));
/* Từ làn VDL dòng KHÔNG mang nút nào — nên cũng không còn cú bấm nào phải chặn.
   Đây là ca canh chiều ngược: thêm lại một nút vào dòng mà quên chặn cú bấm nổi
   lên thì bấm Nhận sẽ bung luôn cửa chi tiết. */
ok('dòng thôi mang nút Nhận', !/vdNhan\(/.test(ds));
ok('dòng thôi mang glyph giao lại ⇢', !/vdMoGiao\(/.test(ds));
M.dat({...NEN, me:NGOC, ds:[vd({nhan_luc:LUC(), nguoi_nhan_id:'u-hafi',
                                trang_thai:'da_nhan'})], dem:{}});
M.vdVe();
ok('người nêu cũng không thấy nút Đóng trong dòng',
   !/vdDongVanDe\(/.test(M.o('vd-ds').innerHTML));

/* Ba lối ấy phải còn nguyên ở CỬA CHI TIẾT, không thì bỏ nút khỏi dòng là khoá
   luôn đường làm việc. Ca này là nửa còn lại của hai ca trên. */
M.dat({...NEN, me:HAFI, ds:[vd({id:70, chuc_nang_nhan:3})], ct:70, bl:[]});
M.vdVeChiTiet();
h = M.o('vd-than').innerHTML;
ok('cửa chi tiết vẫn có lối Nhận', /vdNhan\(70\)/.test(h));
ok('và có lối Giao cho ai', /vdMoGiao\(70\)/.test(h));
ok('lối Giao cho ai luôn đi nền chìm, không giành chỗ nút đặc',
   /class="chim" onclick="vdMoGiao\(70\)/.test(h));

const MOT = vd({});
M.dat({...NEN, me:HAFI, ds:[MOT], dem:{[MOT.id]: 3}});
M.vdVe();
ok('số lượt bàn rời khỏi dòng, về cửa chi tiết',
   !M.o('vd-ds').innerHTML.includes('lượt bàn'));

/* ═══ 19. GHI THẲNG, KHÔNG NHÁP — và hai nấc có điều kiện ═══ */
console.log('\n── 19. Ghi bàn luận và đổi nấc ──');
M.dat({...NEN, me:HAFI, ds:[CT], bl:[], ct:CT.id});
M.vdVeChiTiet();
M.o('vd-bl-o').value = '   ';
await M.vdGuiBl();
bang('ô trống thì không gửi gì lên máy chủ', M.day().length, 0);
ok('và nói ra một câu', M.ghi().join('|').includes('Chưa có gì để gửi'));

M.dat({...NEN, me:HAFI, ds:[CT], bl:[], ct:CT.id});
M.vdVeChiTiet();
M.o('vd-bl-o').value = 'Đã kiểm tra, video còn nguyên.';
await M.vdGuiBl();
const goiBl = M.day().find(x => x.bang === 'van_de_binh_luan' && x.loai === 'insert');
ok('có gửi lên bảng bàn luận', !!goiBl);
if (goiBl){
  bang('gắn đúng vấn đề', goiBl.g.van_de_id, CT.id);
  bang('ghi dưới tên chính mình', goiBl.g.nguoi_id, 'u-hafi');
  bang('nội dung đã cắt khoảng trắng hai đầu',
       goiBl.g.noi_dung, 'Đã kiểm tra, video còn nguyên.');
}
bang('gửi xong thì ô soạn trắng lại', M.o('vd-bl-o').value, '');

/* `dang_xu_ly` đi thẳng, không điều kiện gì. */
M.dat({...NEN, me:HAFI, ds:[DANHAN], ct:DANHAN.id});
await M.vdDatNac(DANHAN.id, 'dang_xu_ly');
const goiNac = M.day().find(x => x.bang === 'van_de' && x.loai === 'update');
ok('đặt được nấc Đang xử lý', !!goiNac && goiNac.g.trang_thai === 'dang_xu_ly');

/* `cho_ben_khac` KHÔNG đi được khi ô soạn trống — đặc tả đòi "phải nêu chờ ai",
   mà bảng `van_de` không có cột nào chứa điều đó. */
M.dat({...NEN, me:HAFI, ds:[DANHAN], bl:[], ct:DANHAN.id});
M.vdVeChiTiet();
M.o('vd-bl-o').value = '';
await M.vdChoBenKhac(DANHAN.id);
bang('ô trống: KHÔNG đổi nấc, KHÔNG ghi gì', M.day().length, 0);
ok('và nhắc đúng điều đang thiếu — chờ AI',
   M.ghi().join('|').includes('chờ ai'));

M.dat({...NEN, me:HAFI, ds:[DANHAN], bl:[], ct:DANHAN.id});
M.vdVeChiTiet();
M.o('vd-bl-o').value = 'Chờ bên phát video trả lời, họ hẹn trong ngày.';
await M.vdChoBenKhac(DANHAN.id);
const dayCBK = M.day();
ok('viết rồi thì MỘT cú bấm làm cả hai việc',
   dayCBK.some(x => x.bang === 'van_de_binh_luan' && x.loai === 'insert')
   && dayCBK.some(x => x.bang === 'van_de' && x.loai === 'update'
                       && x.g.trang_thai === 'cho_ben_khac'));
/* THỨ TỰ: ghi câu TRƯỚC, đổi nấc SAU. Ngược lại thì nấc đổi rồi mà câu hỏng là
   vấn đề đứng ở "chờ bên khác" mà không ai biết chờ ai — đúng cái luật này sinh
   ra để chặn. */
bang('và ghi câu TRƯỚC, đổi nấc SAU',
     dayCBK.findIndex(x => x.bang === 'van_de_binh_luan')
       < dayCBK.findIndex(x => x.bang === 'van_de'), true);

/* Câu ghi hỏng thì DỪNG HẲN, không đổi nấc — nếu không thì đúng cái hỏng trên. */
M.dat({...NEN, me:HAFI, ds:[DANHAN], bl:[], ct:DANHAN.id, loiGhi:{message:'mạng rơi'}});
M.vdVeChiTiet();
M.o('vd-bl-o').value = 'Chờ bên kia.';
await M.vdChoBenKhac(DANHAN.id);
ok('ghi câu hỏng thì KHÔNG đổi nấc',
   !M.day().some(x => x.bang === 'van_de' && x.loai === 'update'));

/* ═══ 20. LỐI RA `khong_lam` — hộp hỏi giữ xanh, phá đỏ viền ═══ */
console.log('\n── 20. Lối ra Không làm ──');
M.dat({...NEN, me:NGOC, ds:[DANHAN], ct:DANHAN.id});
M.vdHoiKhongLam(DANHAN.id);
const hop = M.hop() || '';
ok('bấm Không làm thì hỏi lại một lượt', !!hop);
ok('nút giữ lại đi nền phụ, nút phá đi lớp `chinh` (đỏ viền)',
   /class="phu"/.test(hop) && /class="chinh"/.test(hop));
ok('hộp nói rõ vấn đề vẫn nằm lại trong sổ', /không đường nào xoá/.test(hop));
await M.boThat();
ok('gật rồi mới đặt nấc khong_lam',
   M.day().some(x => x.bang === 'van_de' && x.g.trang_thai === 'khong_lam'));

/* ═══ 21. GIỜ TRONG NGÀY CỦA MỘT CÂU BÀN LUẬN ═══
   Ngày phải lấy theo giờ ĐỊA PHƯƠNG. Cắt mười ký tự đầu chuỗi ISO là lấy ngày
   giờ quốc tế — một câu viết lúc 5 giờ sáng ở Việt Nam rơi sang ngày hôm trước,
   và mạch bàn luận đọc ra sai thứ tự ngày. */
console.log('\n── 21. Giờ của một câu ──');
const sang5h = new Date(); sang5h.setHours(5, 7, 0, 0);
M.dat({...NEN, me:HAFI, ds:[]});
ok('câu viết 5 giờ sáng hôm nay vẫn đọc là “hôm nay”',
   M.vdLucBl(sang5h.toISOString()).startsWith('hôm nay'));
ok('và kèm giờ phút', /\d\d:\d\d$/.test(M.vdLucBl(sang5h.toISOString())));
bang('không có mốc thời gian thì trả chuỗi rỗng', M.vdLucBl(null), '');

/* ═══ 22. REALTIME — hai bảng mới phải đi ĐƯỜNG RIÊNG ═══
   `rtTaiLai` hoãn lại chừng nào còn một cửa sổ nổi đang mở (`rtBanRon`). Đúng
   cho một bảng lịch, nhưng ở đây cái cửa đang mở CHÍNH LÀ thứ cần đổi. Đưa hai
   bảng vào `RT_BANG` là mạch bàn luận chỉ tự đổi sau khi đóng cửa lại. */
console.log('\n── 22. Realtime đi đường riêng ──');
const RTB = vung('const RT_BANG', 'function rtBanRon');
ok('cắt được vùng RT_BANG', !RTB.hong, RTB.hong);
ok('hai bảng vấn đề KHÔNG nằm trong RT_BANG',
   !!RTB.than && !/van_de/.test(RTB.than),
   'có van_de trong RT_BANG → mạch bàn luận đứng im khi cửa mở');
const KENH = vung('function rtMoKenh', 'RT_KENH = k;');
ok('cắt được vùng rtMoKenh', !KENH.hong, KENH.hong);
ok('mà có người nghe riêng vdCoTin cho cả hai bảng',
   /'van_de',\s*'van_de_binh_luan'/.test(KENH.than) && /vdCoTin/.test(KENH.than));

/* Và đầu bên kia: tệp SQL phải kê ĐÚNG hai bảng ấy vào publication. Sửa một đầu
   là nghe một bảng câm, hoặc phát tin cho một bên không ai nghe. */
const SQL_RT = path.join(__dirname, 'nang-cap-realtime-van-de.sql');
ok('có tệp SQL bật realtime cho lớp vấn đề', fs.existsSync(SQL_RT));
if (fs.existsSync(SQL_RT)){
  const q = fs.readFileSync(SQL_RT, 'utf8');
  ok('tệp kê đủ hai bảng vào publication',
     /array\['van_de',\s*'van_de_binh_luan'\]/.test(q));
  ok('và chạy lại vô hại — tự soi trước khi thêm',
     /pg_publication_tables/.test(q) && /if not exists/.test(q));
}

/* ═══ 23. MỘT CỬA, KHÔNG PHẢI HAI ═══
   Dòng ở khối Chờ bạn mở ra ĐÚNG cái cửa mà một dòng ở nấc Vấn đề mở ra — luật
   *một cửa một mặc định* Tracy ra 05/09. Chỗ này nằm ngoài lát cắt nên soi bằng
   văn bản mã, không gọi hàm. */
console.log('\n── 23. Một cửa từ hai lối vào ──');
const CBMO = vung('async function cbMoVanDe', 'let CB_DANG');
ok('cắt được vùng cbMoVanDe', !CBMO.hong, CBMO.hong);
ok('khối Chờ bạn mở thẳng cửa chi tiết',
   /vdMoChiTiet\(Number\(d\.khoa\)\)/.test(CBMO.than));
/* `moTab` gọi `vdTai()` mà KHÔNG chờ, nên `VD_DS` lúc ấy còn là danh sách lượt
   trước — vấn đề vừa được giao có thể chưa có trong đó, và cửa mở ra rỗng. */
ok('và tải danh sách TRƯỚC khi mở, không tin vào lượt nạp của moTab',
   /await vdTai\(\);[\s\S]*vdMoChiTiet/.test(CBMO.than));

/* Đóng cửa phải dọn TRẮNG cả trạng thái cửa chi tiết, không chỉ giấu đi —
   `getElementById` trả phần tử ĐẦU TIÊN trong cây, nên một khung bỏ lại đầy ô
   là cái bẫy câm cho mọi cửa mở sau nó (luật 12 Mục 7 `CAU-TRUC-APP.md`). */
M.dat({...NEN, me:HAFI, ds:[CT], bl:BL, ct:CT.id});
M.vdVeChiTiet();
M.vdDongCua();
bang('đóng cửa thì quên luôn vấn đề đang mở', M.ct(), null);
bang('và quên luôn mạch bàn luận đã tải', M.bl().length, 0);

console.log('\n' + (hong ? '❌ ' + hong + ' ca đỏ · ' : '✅ ') + dat + '/' + (dat + hong) + ' ca đạt\n');
  process.exit(hong ? 1 : 0);
})();
