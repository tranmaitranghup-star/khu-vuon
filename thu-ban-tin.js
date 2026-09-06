/* THỬ: BẢNG TIN chung toàn ROVA (TRI-96)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy đặt đề bài 04/09: một chỗ đăng thông báo và luật mới có hiệu lực theo
   KHOẢNG NGÀY, cả đội đọc chung.

   Bài thử cắt thẳng khối gốc từ `index.html` nên nó chấm đúng mã đang chạy,
   không chấm một bản chép tay.

   Bốn chỗ đáng canh nhất — cả bốn đều hỏng LẶNG nếu sai:

   ① LUẬT HIỆN TIN KHÔNG DÙNG TRẠNG THÁI. Tracy bỏ nút "Đã đọc" giữa phiên, mà
      luật cũ dựa vào nó để quyết tin nào mở tin nào thu. Nay ba tin đầu mở,
      phần còn lại thu một dòng. Sai luật này thì màn Hôm nay dài ra mãi theo
      số tin, và không lỗi nào bật lên.

   ② NGÀY TRÊN DÒNG THU GỌN chỉ hiện khi nó nói được một điều. Hiện luôn thì
      tên tin bị cắt trên điện thoại; không hiện bao giờ thì tin sát hạn trôi
      qua mắt.

   ③ TIN "TOÀN CÔNG TY" PHẢI LỌT MỌI BỘ LỌC PHÒNG. Giấu nó đi là trả lời sai
      câu người ta đang hỏi — "cái gì đang áp cho Sản phẩm".

   ④ ✎ CHỈ MỌC TRÊN TIN MÌNH SỬA ĐƯỢC. Đây là bản sao của policy máy chủ ở phía
      màn hình; lệch nhau thì người ta bấm vào một cánh cửa khoá.

   Chạy:  node production/tinh-thuc-app/thu-ban-tin.js
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

/* ── Cọc ────────────────────────────────────────────────────────────────────
   `document` giả chỉ cần bốn ô mà `btVe` chạm tới. Trả CÙNG MỘT vật cho cùng
   một id, không thì mỗi lượt đọc lại ra một ô trắng và bài thử chấm hư không. */
const COC = `
const KHO = {};
const document = { getElementById: (id) => (KHO[id] = KHO[id] || (() => {
  const L = new Set();
  return {innerHTML:'', textContent:'', style:{}, value:'',
          classList:{toggle:(c,b)=>{b?L.add(c):L.delete(c)}, contains:c=>L.has(c)}};
})()) };
let ME = null, DOI = [], CHUC_NANG = [], HOM_NAY = '2026-09-04';
let SB_LOI = null, SB_LOI_1 = null, SB_LAN = 0, GHI = [];
const homNay = () => HOM_NAY;
const chuSach = (s) => String(s ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
const lcTenKhoi = (id) => (CHUC_NANG.find(c => c.id === id) || {}).ten || 'khối đã gỡ';
const toast = (m) => GHI.push(m);
const hopHoiMo = () => {}, hopHoiDong = () => {};
const sb = { from: () => ({
  select: () => ({ order: () => ({ order: async () => {
    SB_LAN++;
    if (SB_LOI) return {error: SB_LOI};
    if (SB_LOI_1 && SB_LAN === 1) return {error: SB_LOI_1};
    return {error: null, data: DU};
  } }) }),
}) };
let DU = [];
`;

const M = new Function(COC + NGUON + `
  return {
    btConHan, btKhoang, btGonHan, btLaMoi, btHop, btSuaDuoc, btLead,
    btConMayNgay, btConLaiChu, btTheTag, btNgayGon, btVe, btTai,
    btDoiLoc, btDoiCu, btBung, btLinkSach, btLinkChu, btNoiHtml, btChamMoi,
    ktbNac,
    dat: (o) => {
      if ('me'   in o) ME = o.me;
      if ('doi'  in o) DOI = o.doi;
      if ('cn'   in o) CHUC_NANG = o.cn;
      if ('ds'   in o) { BT_DS = o.ds; DU = o.ds; }
      if ('hn'   in o) HOM_NAY = o.hn;
      if ('loi'  in o) SB_LOI = o.loi;
      SB_LOI_1 = o.loi1 || null; SB_LAN = 0;
      BT_LOC = 'loc' in o ? o.loc : 0;
      BT_CU  = 'cu'  in o ? o.cu  : false;
      BT_BUNG = new Set();
      if ('coBanTin' in o) CO_BAN_TIN = o.coBanTin;
      if ('coLink'   in o) CO_BT_LINK = o.coLink;
      /* Từ 05/09 bảng tin là MỘT NẤC của kênh thông báo, không còn là cả màn.
         Mặc định của bộ thử là nấc Thông báo, vì đây là bài thử của nó. */
      KTB_NAC = 'nac' in o ? o.nac : 'thongbao';
      VD_DS = o.vd || [];
      if ('coVanDe' in o) CO_VAN_DE = o.coVanDe;
    },
    o: (id) => KHO[id] || {innerHTML:'', textContent:'', style:{}},
    ghi: () => GHI, coBanTin: () => CO_BAN_TIN, coLink: () => CO_BT_LINK,
    cham: () => KHO['nut-bt'] && KHO['nut-bt'].classList.contains('co-cham')
  };
`)();

/* ── Khung chấm ──────────────────────────────────────────────────────────── */
let dat = 0, hong = 0;
function ok(ten, dieu, them){
  if (dieu) { dat++; return; }
  hong++; console.log('  ❌ ' + ten + (them ? '\n       ' + them : ''));
}
function bang(ten, a, b){ ok(ten, a === b, 'ra   : ' + JSON.stringify(a) + '\n       đợi  : ' + JSON.stringify(b)); }

const CN = [
  {id:1, ten:'CEO'}, {id:2, ten:'Vận hành'}, {id:3, ten:'Sản phẩm'},
  {id:4, ten:'Kinh doanh'}, {id:5, ten:'Tài chính'}, {id:6, ten:'Trải nghiệm khách hàng'}
];
const DOI = [{id:'u-tracy', ten:'Tracy'}, {id:'u-andy', ten:'Andy'}, {id:'u-ha', ten:'Hafi'}];
const TRACY = {id:'u-tracy', ten:'Tracy', la_lead:true,  la_quan_tri:true};
const HAFI  = {id:'u-ha',    ten:'Hafi',  la_lead:true,  la_quan_tri:false};
const NV    = {id:'u-nv',    ten:'Andrew',la_lead:false, la_quan_tri:false};

let n = 0;
const tin = (o) => Object.assign({
  id: 't' + (++n), tieu_de: 'Tin ' + n, noi_dung: '', chuc_nang_ids: [],
  toan_cong_ty: false, tu_ngay: '2026-09-01', den_ngay: null,
  nguoi_dang: 'u-tracy', tao_luc: '2026-08-30T02:00:00Z'
}, o);

const NEN = {me: TRACY, doi: DOI, cn: CN, hn: '2026-09-04', ds: [], loi: null, coBanTin: true};

console.log('\n▶ BẢNG TIN — thu-ban-tin.js\n');

/* ═══ 1. Còn hiệu lực hay đã hết hạn ═══ */
M.dat(NEN);
ok('không có hạn thì luôn còn hiệu lực',   M.btConHan(tin({den_ngay:null})));
ok('hạn đúng hôm nay thì VẪN còn',         M.btConHan(tin({den_ngay:'2026-09-04'})));
ok('hạn hôm qua thì hết',                 !M.btConHan(tin({den_ngay:'2026-09-03'})));
ok('chưa tới ngày bắt đầu vẫn tính là còn hiệu lực',
   M.btConHan(tin({tu_ngay:'2026-09-07', den_ngay:'2026-09-20'})));

/* ═══ 2. Khoảng hiệu lực trên thẻ mở ═══ */
bang('có hạn, đã bắt đầu → kèm số ngày còn lại',
  M.btKhoang(tin({tu_ngay:'2026-09-03', den_ngay:'2026-09-10'})),
  '3/9 → 10/9 · <b>còn 6 ngày</b>');
bang('sát hạn (≤2 ngày) thì tô vàng',
  M.btKhoang(tin({tu_ngay:'2026-09-01', den_ngay:'2026-09-05'})),
  '1/9 → 5/9 · <b class="gap">còn 1 ngày</b>');
bang('hạn rơi đúng hôm nay',
  M.btKhoang(tin({tu_ngay:'2026-09-01', den_ngay:'2026-09-04'})),
  '1/9 → 4/9 · <b class="gap">hết hôm nay</b>');
bang('chưa bắt đầu thì KHÔNG đếm ngược',
  M.btKhoang(tin({tu_ngay:'2026-09-07', den_ngay:'2026-09-12'})), '7/9 → 12/9');
bang('không hạn thì nói thẳng là chưa có hạn',
  M.btKhoang(tin({tu_ngay:'2026-09-07', den_ngay:null})), 'từ 7/9 · chưa có hạn');

/* ═══ 3. Ngày trên dòng thu gọn — bẫy ② ═══ */
bang('còn dài ngày thì KHÔNG hiện ngày, nhường bề ngang cho tên tin',
  M.btGonHan(tin({tu_ngay:'2026-09-01', den_ngay:'2026-09-25'})), '');
bang('không hạn cũng không hiện gì',
  M.btGonHan(tin({tu_ngay:'2026-09-01', den_ngay:null})), '');
bang('chưa tới ngày hiệu lực thì hiện ngày bắt đầu',
  M.btGonHan(tin({tu_ngay:'2026-09-07'})), '<span class="bt-gon-han">từ 7/9</span>');
bang('sát hạn thì hiện và tô vàng',
  M.btGonHan(tin({tu_ngay:'2026-09-01', den_ngay:'2026-09-06'})),
  '<span class="bt-gon-han gap">còn 2 ngày</span>');

/* ═══ 4. Nhãn "Mới" suy từ ngày đăng, không từ ai đã xem ═══ */
ok('đăng cách đây 1 giờ là tin mới',
   M.btLaMoi(tin({tao_luc: new Date(Date.now() - 36e5).toISOString()})));
ok('đăng cách đây 3 ngày thì thôi mới',
  !M.btLaMoi(tin({tao_luc: new Date(Date.now() - 3*864e5).toISOString()})));
ok('không có ngày đăng thì không phải tin mới', !M.btLaMoi(tin({tao_luc:null})));

/* ═══ 5. Lọc phòng ban — bẫy ③ ═══ */
M.dat(Object.assign({}, NEN, {loc: 0}));
ok('lọc Tất cả thì mọi tin lọt', M.btHop(tin({chuc_nang_ids:[5]})));
M.dat(Object.assign({}, NEN, {loc: 3}));
ok('đúng phòng thì lọt',                 M.btHop(tin({chuc_nang_ids:[3]})));
ok('một tin gắn NHIỀU phòng vẫn lọt',    M.btHop(tin({chuc_nang_ids:[3,6]})));
ok('tin Toàn công ty lọt MỌI bộ lọc',    M.btHop(tin({chuc_nang_ids:[], toan_cong_ty:true})));
ok('phòng khác thì bị loại',            !M.btHop(tin({chuc_nang_ids:[5]})));

/* ═══ 6. Ba mức quyền — bẫy ④ ═══ */
M.dat(Object.assign({}, NEN, {me: TRACY}));
ok('quản trị được đăng',                  M.btLead());
ok('quản trị sửa được tin của người khác', M.btSuaDuoc(tin({nguoi_dang:'u-ha'})));
M.dat(Object.assign({}, NEN, {me: HAFI}));
ok('lead thường được đăng',               M.btLead());
ok('lead sửa được tin của chính mình',    M.btSuaDuoc(tin({nguoi_dang:'u-ha'})));
ok('lead KHÔNG sửa được tin người khác', !M.btSuaDuoc(tin({nguoi_dang:'u-tracy'})));
M.dat(Object.assign({}, NEN, {me: NV}));
ok('nhân sự thường không đăng được',     !M.btLead());
ok('nhân sự thường không sửa được gì',   !M.btSuaDuoc(tin({nguoi_dang:'u-tracy'})));

/* ═══ 7. Luật hiện tin — đổi 04/09 khi bảng tin ra MÀN RIÊNG ═══
   Tracy: *"nó bị choán hết mục hôm nay khi mà nhiều thông báo"*. Trên màn riêng
   không còn gì để tiết kiệm chiều cao, nên tin đang hiệu lực mở HẾT. `BT_MO` đã
   bỏ — nếu ai đó dựng lại một con số như thế, mấy ca dưới đây đỏ ngay. */
const NAM = [1,2,3,4,5].map(i => tin({tieu_de:'Tin số ' + i, chuc_nang_ids:[2]}));
M.dat(Object.assign({}, NEN, {me: TRACY, ds: NAM}));
M.btVe();
let h = M.o('bt-ds').innerHTML;
bang('năm tin đang hiệu lực thì mở HẾT năm', (h.match(/class="bt-tin"/g) || []).length, 5);
bang('và không tin nào bị thu một dòng',     (h.match(/class="bt-gon"/g) || []).length, 0);
ok('khối hiện ra ở nấc Thông báo', M.o('bt-the').style.display === '');
bang('nhãn mục nói đang xem gì', M.o('bt-muc').textContent, 'Đang có hiệu lực');

/* Tin CŨ thì ngược lại: thu hết, chạm mới bung — chúng là chỗ tra lại. */
const CU5 = [1,2,3].map(i => tin({tieu_de:'Cũ ' + i, den_ngay:'2026-08-2' + i}));
M.dat(Object.assign({}, NEN, {me: TRACY, ds: CU5}));
M.btDoiCu();
h = M.o('bt-ds').innerHTML;
bang('tin cũ thu hết thành dòng', (h.match(/class="bt-gon"/g) || []).length, 3);
bang('nhãn mục đổi theo', M.o('bt-muc').textContent, 'Tin cũ');
M.btBung(CU5[1].id);
bang('chạm một tin cũ thì nó bung ra',
  (M.o('bt-ds').innerHTML.match(/class="bt-tin"/g) || []).length, 1);

/* ═══ 8. Hai nấc của kênh thông báo — luật đổi 05/09 ═══
   Luật CŨ "chưa tin nào và mình không đăng được thì khối biến mất hẳn" ĐÃ BỎ.
   Nó đúng hồi bảng tin còn là một khối trên màn Hôm nay; nay nó là một NẤC
   người ta chủ động bấm vào, và một nấc trắng trơn tệ hơn một dòng chữ.
   Thứ quyết định khối hiện hay ẩn nay là NẤC ĐANG MỞ. */
M.dat(Object.assign({}, NEN, {me: NV, ds: []}));
M.btVe();
bang('không tin + không phải lead → khối VẪN hiện, có lời giải thích',
  M.o('bt-the').style.display, '');
ok('và lời ấy không xui người không đăng được đi bấm nút',
   !/Bấm ＋ Tin mới/.test(M.o('bt-ds').innerHTML));
M.dat(Object.assign({}, NEN, {me: TRACY, ds: []}));
M.btVe();
bang('không tin nhưng là lead → khối hiện, có chỗ đăng',
  M.o('bt-the').style.display, '');
ok('lời trong khối rỗng chỉ đường cho lead',
   /Bấm ＋ Tin mới/.test(M.o('bt-ds').innerHTML));

/* Nấc Vấn đề đang mở thì khối bảng tin phải ẩn — nếu không thì hai khối chồng
   nhau và ta dựng lại đúng bệnh Tracy đã bác 04/09. */
M.dat(Object.assign({}, NEN, {me: TRACY, ds: [tin({})], nac: 'vande'}));
M.btVe();
bang('đang ở nấc Vấn đề thì khối bảng tin ẩn', M.o('bt-the').style.display, 'none');
M.ktbNac('thongbao');
bang('bấm sang nấc Thông báo thì nó hiện lại', M.o('bt-the').style.display, '');

/* Chấm trên nút loa nay suy từ HAI nguồn. Vế bảng tin phải còn nguyên tác dụng
   kể cả khi máy chủ chưa có bảng vấn đề — một bảng chưa dựng không được làm
   tắt chấm của bảng kia. */
const MOI = () => tin({tao_luc: new Date(Date.now() - 36e5).toISOString()});
M.dat(Object.assign({}, NEN, {me: TRACY, ds: [MOI()], coVanDe: false}));
M.btVe();
ok('tin mới vẫn thắp chấm dù chưa có bảng vấn đề', M.cham());

/* Và chiều ngược lại: một vấn đề giao cho mình mà mình chưa nhận cũng thắp
   chấm, kể cả khi không có tin nào. Hai vế của một phép HOẶC — hỏng một vế là
   nửa tính năng tắt lặng lẽ. */
M.dat(Object.assign({}, NEN, {me: TRACY, ds: [], coVanDe: true, vd: [
  {id: 1, tieu_de: 'V', nguoi_neu_id: 'u-hafi', nguoi_nhan_id: 'u-tracy',
   chuc_nang_neu: 2, chuc_nang_nhan: 3, muc: 2, trang_thai: 'moi',
   nhan_luc: null, han_tra_loi: new Date(Date.now() + 36e5).toISOString(),
   tao_luc: new Date().toISOString()}
]}));
M.btVe();
ok('vấn đề giao cho mình chưa nhận cũng thắp chấm, dù không có tin nào', M.cham());

/* ═══ 9. Nút Tin mới và dấu ✎ theo quyền ═══ */
const HAI = [tin({nguoi_dang:'u-tracy'}), tin({nguoi_dang:'u-ha'})];
M.dat(Object.assign({}, NEN, {me: HAFI, ds: HAI}));
M.btVe();
h = M.o('bt-ds').innerHTML;
bang('lead thường: ✎ mọc trên ĐÚNG MỘT tin của mình',
  (h.match(/class="bt-sua"/g) || []).length, 1);
bang('nút Tin mới hiện với lead', M.o('bt-nut-moi').style.display, '');
M.dat(Object.assign({}, NEN, {me: TRACY, ds: HAI}));
M.btVe();
bang('quản trị: ✎ mọc trên CẢ HAI tin',
  (M.o('bt-ds').innerHTML.match(/class="bt-sua"/g) || []).length, 2);
M.dat(Object.assign({}, NEN, {me: NV, ds: HAI}));
M.btVe();
bang('nhân sự thường: không nút Tin mới', M.o('bt-nut-moi').style.display, 'none');
bang('nhân sự thường: không dấu ✎ nào',
  (M.o('bt-ds').innerHTML.match(/class="bt-sua"/g) || []).length, 0);
ok('nhân sự thường VẪN đọc được cả hai tin',
  (M.o('bt-ds').innerHTML.match(/class="bt-tin"/g) || []).length === 2);

/* ═══ 10. Tin hết hạn rơi xuống Tin cũ ═══ */
const TRON = [tin({tieu_de:'Đang chạy'}), tin({tieu_de:'Đã hết', den_ngay:'2026-08-20'})];
M.dat(Object.assign({}, NEN, {me: TRACY, ds: TRON}));
M.btVe();
ok('tin hết hạn không nằm trong danh sách đang chạy',
   !/Đã hết/.test(M.o('bt-ds').innerHTML));
bang('nút Tin cũ đếm đúng', M.o('bt-nut-cu').textContent, 'Tin cũ (1)');
M.btDoiCu();
ok('bấm Tin cũ thì thấy tin hết hạn', /Đã hết/.test(M.o('bt-ds').innerHTML));
ok('và không còn thấy tin đang chạy', !/Đang chạy/.test(M.o('bt-ds').innerHTML));
bang('nút đổi chiều để quay lại', M.o('bt-nut-cu').textContent, '← Tin đang chạy');

/* ═══ 11. Dải lọc dựng đủ bảy nút ═══ */
M.dat(Object.assign({}, NEN, {me: TRACY, ds: NAM}));
M.btVe();
const loc = M.o('bt-loc').innerHTML;
bang('bảy nút: Tất cả + sáu khối', (loc.match(/<button/g) || []).length, 7);
ok('mặc định Tất cả đang sáng', /class="chay" onclick="btDoiLoc\(0\)"/.test(loc));
M.btDoiLoc(3);
ok('bấm một phòng thì phòng ấy sáng',
   /class="chay" onclick="btDoiLoc\(3\)"/.test(M.o('bt-loc').innerHTML));
ok('lọc phòng không có tin nào thì nói rõ tên phòng',
   /Không có tin nào cho Sản phẩm/.test(M.o('bt-ds').innerHTML));

/* ═══ 12. LINK — rào http/https, và chỉ http/https ═══
   Người đăng dán được bất cứ chuỗi gì vào ô Link. Một `javascript:` nằm trong
   href là mã của người này chạy trong phiên đăng nhập của người kia. */
bang('https lọt',  M.btLinkSach('https://docs.google.com/a'), 'https://docs.google.com/a');
bang('http lọt',   M.btLinkSach('http://a.vn'), 'http://a.vn');
bang('javascript: BỊ CHẶN',        M.btLinkSach('javascript:alert(1)'), '');
bang('JaVaScRiPt: cũng bị chặn',   M.btLinkSach('JaVaScRiPt:alert(1)'), '');
bang('data: bị chặn',              M.btLinkSach('data:text/html,<script>'), '');
bang('chuỗi trống thì thôi',       M.btLinkSach(''), '');
bang('chữ hiện trên link là tên miền, bỏ www',
  M.btLinkChu('https://www.docs.google.com/spreadsheets/d/1a2b3c4d5e6f7g8h'), 'docs.google.com');

/* ═══ 13. Địa chỉ gõ trong NỘI DUNG cũng bấm được ═══ */
h = M.btNoiHtml('Xem tại https://rova.vn/bien-ban nhé.');
ok('địa chỉ trong nội dung thành link', /<a class="bt-link" href="https:\/\/rova\.vn\/bien-ban"/.test(h));
ok('dấu chấm cuối câu KHÔNG bị nuốt vào link', /bien-ban<\/a> nhé\./.test(h));
h = M.btNoiHtml('<img src=x onerror=alert(1)> và https://a.vn?x=1&y=2');
ok('thẻ HTML trong nội dung bị rào', /&lt;img/.test(h) && !/<img/.test(h));
ok('địa chỉ có tham số vẫn thành link', /href="https:\/\/a\.vn\?x=1&amp;y=2"/.test(h));

/* ═══ 14. Chấm trên biểu tượng loa ═══
   Cái giá của việc dời bảng tin ra màn riêng: nó thôi đập vào mắt. Chấm này là
   thứ bù lại, nên nó sai là cả tính năng mất tác dụng mà không ai biết. */
M.dat(Object.assign({}, NEN, {me: TRACY,
  ds: [tin({tao_luc: new Date(Date.now() - 36e5).toISOString()})]}));
M.btVe();
ok('có tin đăng trong 24 giờ → loa đeo chấm', M.cham());
M.dat(Object.assign({}, NEN, {me: TRACY, ds: [tin({tao_luc:'2026-08-01T02:00:00Z'})]}));
M.btVe();
ok('tin cũ ngày thì thôi chấm', !M.cham());
M.dat(Object.assign({}, NEN, {me: TRACY, ds: [tin({den_ngay:'2026-08-20',
  tao_luc: new Date(Date.now() - 36e5).toISOString()})]}));
M.btVe();
ok('tin vừa đăng mà ĐÃ HẾT HẠN thì không chấm', !M.cham());

/* ═══ 15. Cửa lùi khi máy chủ chưa chạy tệp SQL ═══ */
(async () => {
  M.dat(Object.assign({}, NEN, {me: TRACY, ds: [],
    loi: {message: 'relation "public.ban_tin" does not exist'}}));
  await M.btTai();
  ok('máy chủ chưa có bảng → khối tự biến mất, không chặn màn Hôm nay',
     M.o('bt-the').style.display === 'none');
  ok('và cờ hạ xuống để thôi hỏi lại mỗi lượt', M.coBanTin() === false);

  /* Thiếu RIÊNG cột `link` thì KHÔNG được bỏ cả bảng tin — mất một tính năng
     còn hơn mất cả màn. Đây là chỗ dễ làm sai nhất của mọi cửa lùi theo cột. */
  M.dat(Object.assign({}, NEN, {me: TRACY, coBanTin: true, coLink: true,
    ds: [tin({tieu_de:'Vẫn phải thấy tôi'}), tin({})],
    loi: null, loi1: {message: 'column ban_tin.link does not exist'}}));
  await M.btTai();
  ok('thiếu cột link → hạ cờ link, KHÔNG hạ cờ bảng tin',
     M.coLink() === false && M.coBanTin() === true);
  ok('và hai tin vẫn hiện đủ',
     (M.o('bt-ds').innerHTML.match(/class="bt-tin"/g) || []).length === 2);

  /* ═══ 16. Chữ trong tin được rào, không chui thẳng vào HTML ═══ */
  M.dat(Object.assign({}, NEN, {me: TRACY, coBanTin: true,
    ds: [tin({tieu_de: '<img src=x onerror=alert(1)>'})]}));
  M.btVe();
  ok('tiêu đề có thẻ HTML thì bị rào lại',
     /&lt;img/.test(M.o('bt-ds').innerHTML) && !/<img/.test(M.o('bt-ds').innerHTML));

  console.log('\n' + (hong ? '❌ ' + hong + ' ca đỏ · ' : '✅ ') + dat + '/' + (dat + hong) + ' ca đạt\n');
  process.exit(hong ? 1 : 0);
})();
