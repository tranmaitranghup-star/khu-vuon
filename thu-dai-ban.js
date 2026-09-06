/* THỬ: DẢI BẬN CẢ ĐỘI — nấc Đội và khối mở-ra-được trong cửa Sự kiện (TRI-59)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"khi 1 người muốn tạo cuộc hẹn chung mà ko trao đổi được thì họ
   có thể nhìn được lịch của toàn bộ mọi người hoặc hẹn 1-1 thì có thể biết lịch
   rảnh để nhắn tin hẹn"*.

   Sáu ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · Ô 30 PHÚT LÀ ĐƠN VỊ. Một buổi 09:15–09:45 nằm gọn trong một ô; tô đúng
       một ô là đúng ý *"chạm vào là tô cả ô"*, tô hai ô là ăn lẹm sang nửa giờ
       người ta còn rảnh.

     · MÉP KHUNG GIỜ LÀM VIỆC. Buổi 07:00–09:00 chỉ được tô hai ô đầu; đếm cả
       phần trước 08:00 là chỉ số ô âm và bảng vẽ lệch một hàng.

     · NGƯỜI ĐÃ TẮT. Cú chạm vào một cái tên phải đổi phép tính giờ chung.
       Không đổi thì nút bấm được mà chẳng làm gì — hỏng lặng lẽ.

     · NGƯỜI NGOÀI DANH SÁCH. Máy chủ trả lịch của CẢ đội; ai không nằm trong
       `ai` mà vẫn đẩy được ô bận vào bản đồ là một người vô hình làm cả nhóm
       bận.

     · BẢNG VÀ CÂU CHỮ PHẢI NÓI MỘT ĐIỀU. Dòng *"Cả đội rảnh: …"* đọc từ chính
       các ô đang tô. Hai phép tính chạy song song thì sớm muộn lệch nhau, và
       lúc ấy không biết tin cái nào.

     · LỚP RIÊNG TƯ. Dữ liệu có sẵn cả tên buổi lẫn ghi chú. In ra là phơi lịch
       riêng của cả đội — mã chỉ được đụng tới giờ.

   Chạy:  node production/tinh-thuc-app/thu-dai-ban.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

function catHam(ten){
  let dau = SRC.indexOf('function ' + ten + '(');
  if (dau < 0) throw new Error('Khong thay ham: ' + ten);
  if (SRC.slice(dau - 6, dau) === 'async ') dau -= 6;
  let i = SRC.indexOf('{', dau), sau = 0;
  for (let j = i; j < SRC.length; j++){
    if (SRC[j] === '{') sau++;
    else if (SRC[j] === '}'){ sau--; if (!sau) return SRC.slice(dau, j+1); }
  }
  throw new Error('Ham khong dong ngoac: ' + ten);
}
function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── MÁY CHẠY THẬT ────────────────────────────────────────────────────────
   Nạp MÃ THẬT, không dựng bản giả nào ngoài `DOI` và `homNay` — hai thứ duy
   nhất bài thử phải ghim lại thì mới nói cùng một điều ở mọi ngày chạy. */
const HANG_SO = catKhoi('const LCR_TU = 8*60', 'let LC_RANH_LUOT')
              + catKhoi('const DB_O = 30', 'let DB_TAT');
function may(NAY, DOI){
  return new Function('NAY', 'DOI', `
/* Thêm 04/09 (TRI-104): hai hàm suy màu, cờ riêng tư thắng màu sơn tay.
   Chép ĐÚNG bản trong app chứ không dựng bản giả trả về chuỗi rỗng — bản giả
   thì mọi ca dưới đây chạy qua một nhánh không tồn tại ngoài đời. */
const mauSuKien = l => (l && l.rieng_tu) ? 'tim'  : ((l && l.mau) || '');
const mauViec   = t => (t && t.rieng_tu) ? 'hong' : ((t && t.mau) || '');
    const homNay = () => NAY;
    let LC_HIEN = null, LC_VIEC = {}, DB_TAT = new Set(), DB_BOI = null, DB_CHU = '';
    const ME = {id: 'u1', la_lead: true};
    ${HANG_SO}
    ${catHam('lcHopNgay')}
    ${catHam('lcLuot')}
    ${catHam('lcNguoiCuaLich')}
    ${/* Từ 04/09 `lcCuaNgayTu` hỏi quyền sửa qua hàm này thay vì chép tay câu
         luật vào chỗ dựng khối. Nạp MÃ THẬT chứ không stub: nếu mai luật quyền
         đổi lần nữa thì bài thử này phải chạy trên luật mới, không chạy trên
         một bản giả đứng yên. */''}
    ${catHam('lcDuocSua')}
    ${catHam('lcCuaNgayTu')}
    /* Phép lọc lịch cá nhân (05/09) — khai riêng một chỗ cho cả ba bảng của màn
       Vận hành, nên bảng Giờ rảnh cũng phải mang nó theo khi cắt ra chạy. */
    ${catKhoi('const dbBoRiengTu', '/* Bản đồ người → cờ bận')}
    ${catHam('dbBanCuaNgay')}
    ${catHam('dbRanhChung')}
    return {dbBanCuaNgay, dbRanhChung, DB_SO_O, LCR_TU, LCR_DEN, DB_O};`)(NAY, DOI);
}

/* ⚠️ KHUNG GIỜ LÀM VIỆC ĐỌC TỪ MÃ, KHÔNG GHIM SỐ Ở ĐÂY. Nó đã đổi một lần —
   `LCR_DEN` từ 18:00 lên 23:00 — và chín ca trong tệp này đỏ theo suốt từ đó
   (TRI-80): mã đúng, bài thử lỗi thời, và một bộ đo đỏ sẵn là một bộ không còn
   ai nhìn. Mọi con số phụ thuộc khung giờ nay tính ra từ `LCR_TU`/`LCR_DEN`,
   nên lần nới tiếp theo bài thử tự đi theo. */
const {LCR_TU: G_TU, LCR_DEN: G_DEN, DB_O: G_O} = may('2026-01-01', []);
const gio = p => String(Math.floor(p/60)).padStart(2,'0')+':'+String(p%60).padStart(2,'0');
const KHUNG = gio(G_TU) + '–' + gio(G_DEN);
const SO_O  = (G_DEN - G_TU) / G_O;
const TRON  = JSON.stringify([[G_TU, G_DEN]]);   /* rảnh trọn khung */
const DOI5 = [{id:'u1',ten:'Tracy',la_lead:true}, {id:'u2',ten:'Trang',la_lead:true},
              {id:'u3',ten:'Hùng', la_lead:true}, {id:'u4',ten:'Saam', la_lead:false}];
const AI   = DOI5.map(x => x.id);
const NAY  = '2026-09-03';                       // thứ Năm
const buoi = (o) => Object.assign({id: 'l'+Math.random().toString(36).slice(2,7),
  ten: 'Họp kín — TÊN KHÔNG ĐƯỢC RA MÀN HÌNH', pham_vi: 'ca_nhan', nguoi_ids: [],
  chuc_nang_ids: [], tao_boi: 'u9', lap: 'khong', ngay_bat_dau: NAY, ngay_ket_thuc: null,
  thu: []}, o);
const dai  = (ds) => ({ds, huy: {}, doi: {}, doiToi: {}, tick: {}});

/* ── ⓪ LỊCH CÁ NHÂN KHÔNG TÔ BẬN — đánh đổi Tracy chốt 05/09 ─────────────
   Phương án A: màn Vận hành chỉ bày lịch ROVA, và bảng này đi theo cả màn. Hệ
   quả nằm ngay trong cái tên: một buổi khai Loại là *Sự kiện cá nhân* không tô
   ô nào, nên bảng báo giờ ấy RẢNH và người khác đặt được buổi đè lên. Tracy đã
   nghe đánh đổi này rồi mới chốt.
   Ca dưới ghim nó lại. Ai thấy "lỗi" và định chữa thì đọc dòng trên trước —
   muốn cả hai (giấu tên nhưng vẫn tô bận) thì đó là một thay đổi khác, và nó
   phải bắt đầu bằng một câu hỏi cho Tracy, không phải bằng một dòng mã. */
console.log('\n⓪ Buổi khai Loại "Sự kiện cá nhân" không tô ô nào');
{
  const {dbBanCuaNgay} = may(NAY, DOI5);
  const o = (ds) => dbBanCuaNgay(dai(ds), NAY, AI).get('u2')
                      .map((x, i) => x ? i : -1).filter(i => i >= 0);
  la('buổi thường 09:00–10:00 vẫn tô hai ô',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60, so_phut:60})])) === '[2,3]');
  la('cùng buổi ấy mà mang cờ rieng_tu thì không tô ô nào',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60, so_phut:60,
                             rieng_tu:true})])) === '[]',
     'lịch cá nhân lọt vào bảng giờ rảnh của cả team');
}

/* ── ① Ô 30 PHÚT LÀ ĐƠN VỊ ─────────────────────────────────────────────── */
console.log('\n① Buổi chạm vào ô nào thì tô cả ô đó');
{
  const {dbBanCuaNgay, DB_SO_O} = may(NAY, DOI5);
  /* KHÔNG so `DB_SO_O` với chính công thức sinh ra nó — thế là bài thử tự
     chứng minh mình. Hỏi thứ THẬT SỰ phải đúng: số ô là một số nguyên dương,
     và ô cuối phải đóng đúng vào `LCR_DEN`. Khung nào không chia hết cho một ô
     (ví dụ nới tới 22:45) sẽ ra số ô lẻ, và bảng vẽ ra một hàng cụt mà không
     một dấu hiệu nào báo. */
  la('bảng ' + KHUNG + ' ra ' + DB_SO_O + ' ô, số nguyên dương',
     Number.isInteger(DB_SO_O) && DB_SO_O > 0, String(DB_SO_O));
  la('ô cuối đóng đúng vào giờ tan ' + gio(G_DEN),
     G_TU + DB_SO_O * G_O === G_DEN,
     'khung không chia hết cho một ô ' + G_O + ' phút thì bảng có một hàng cụt');

  const o = (ds) => dbBanCuaNgay(dai(ds), NAY, AI).get('u2')
                      .map((x, i) => x ? i : -1).filter(i => i >= 0);
  la('buổi 09:00–10:00 tô đúng hai ô',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60, so_phut:60})])) === '[2,3]');
  la('buổi 09:05–09:25 nằm gọn trong MỘT ô thì chỉ tô ô ấy',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60+5, so_phut:20})])) === '[2]',
     'tô thêm ô kế là ăn lẹm sang nửa giờ người ta còn rảnh');
  la('buổi 09:15–09:45 vắt qua mốc 09:30 thì tô cả hai ô nó chạm',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60+15, so_phut:30})])) === '[2,3]');
  la('buổi 09:45–10:15 vắt qua mốc 10:00 cũng vậy',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60+45, so_phut:30})])) === '[3,4]');
  la('buổi bắt đầu trước giờ làm chỉ tô phần nằm trong khung',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:7*60, so_phut:120})])) === '[0,1]',
     'đếm cả phần trước 08:00 là chỉ số ô âm và bảng vẽ lệch một hàng');
  /* Buổi mở trước giờ tan một tiếng rồi kéo dài ba tiếng — neo vào `G_DEN` chứ
     không neo vào một giờ cụ thể, để nó luôn thật sự vượt khung dù khung nới
     tới đâu. Hai ô cuối là hai ô nó chạm bên trong khung. */
  la('buổi kéo quá giờ tan cũng chỉ tô tới ô cuối',
     JSON.stringify(o([buoi({nguoi_ids:['u2'], gio_bat_dau:G_DEN-60, so_phut:180})]))
       === JSON.stringify([SO_O-2, SO_O-1]));
}

/* ── ② BẢNG VÀ CÂU CHỮ NÓI MỘT ĐIỀU ─────────────────────────────────────── */
console.log('\n② Khoảng rảnh đọc từ chính các ô đang tô');
{
  const {dbBanCuaNgay, dbRanhChung} = may(NAY, DOI5);
  const map = dbBanCuaNgay(dai([]), NAY, AI);
  la('lịch trống thì rảnh trọn khung ' + KHUNG,
     JSON.stringify(dbRanhChung(map, AI)) === TRON);

  const m2 = dbBanCuaNgay(dai([buoi({nguoi_ids:['u2'], gio_bat_dau:9*60+5, so_phut:20})]), NAY, AI);
  la('một ô bận cắt ngày làm hai, mép rơi đúng vào mốc nửa giờ',
     JSON.stringify(dbRanhChung(m2, ['u1','u2']))
       === JSON.stringify([[G_TU, 9*60], [9*60+30, G_DEN]]),
     JSON.stringify(dbRanhChung(m2, ['u1','u2'])));

  /* Bận đúng bằng cả khung, tính ra từ khung — "mười tiếng" chỉ còn kín cả
     ngày khi khung vẫn là 08:00–18:00. */
  const m3 = dbBanCuaNgay(dai([buoi({nguoi_ids:['u2'],
    gio_bat_dau:G_TU, so_phut:G_DEN-G_TU})]), NAY, AI);
  la('kín cả khung thì không còn khoảng nào',
     JSON.stringify(dbRanhChung(m3, ['u1','u2'])) === '[]');
}

/* ── ③ AI LÀM AI BẬN ────────────────────────────────────────────────────── */
console.log('\n③ Chỉ người trong danh sách mới vào bản đồ, và mới làm nhóm bận');
{
  const {dbBanCuaNgay, dbRanhChung} = may(NAY, DOI5);
  const d = dai([buoi({nguoi_ids:['u9'], tao_boi:'u9', gio_bat_dau:9*60, so_phut:60})]);
  const map = dbBanCuaNgay(d, NAY, AI);
  la('người ngoài danh sách không lọt vào bản đồ',
     [...map.keys()].every(k => AI.includes(k)) && map.size === AI.length,
     [...map.keys()].join(','));
  la('buổi của người ngoài không làm nhóm bận',
     JSON.stringify(dbRanhChung(map, AI)) === TRON);

  const d2 = dai([buoi({nguoi_ids:['u3'], gio_bat_dau:10*60+30, so_phut:120})]);
  const m2 = dbBanCuaNgay(d2, NAY, AI);
  la('tắt đúng người đang bận thì khung mở lại trọn ngày',
     JSON.stringify(dbRanhChung(m2, AI.filter(x => x !== 'u3'))) === TRON,
     'cú chạm vào một cái tên phải đổi phép tính, nếu không nút bấm được mà chẳng làm gì');
  la('còn giữ người ấy thì ngày bị chia làm hai',
     JSON.stringify(dbRanhChung(m2, AI)) === JSON.stringify([[G_TU, 630], [750, G_DEN]]),
     JSON.stringify(dbRanhChung(m2, AI)));
}

/* ── ④ PHẠM VI NHÓM VẪN CHẠY ĐÚNG ───────────────────────────────────────── */
console.log('\n④ Buổi của cả công ty làm mọi người bận, buổi coreteam chỉ chạm lead');
{
  const {dbBanCuaNgay, dbRanhChung} = may(NAY, DOI5);
  const m1 = dbBanCuaNgay(dai([buoi({pham_vi:'cong_ty', tao_boi:'u1',
                                     gio_bat_dau:8*60, so_phut:60})]), NAY, AI);
  la('cả công ty: mọi người cùng bận đúng hai ô đầu',
     AI.every(id => m1.get(id)[0] && m1.get(id)[1] && !m1.get(id)[2]));

  const m2 = dbBanCuaNgay(dai([buoi({pham_vi:'coreteam', tao_boi:'u1',
                                     gio_bat_dau:8*60, so_phut:60})]), NAY, AI);
  la('coreteam: người không mang cờ lead vẫn rảnh',
     m2.get('u4').every(x => !x) && m2.get('u3')[0] && m2.get('u3')[1]);
}

/* ── ⑤ LỚP RIÊNG TƯ ─────────────────────────────────────────────────────── */
console.log('\n⑤ Chỉ giờ ra màn hình, tên buổi thì không');
{
  const VE = catHam('dbVe');
  la('không đọc tên buổi, không đọc ghi chú',
     !/l\.ten|o\.ten|noi_dung/.test(VE),
     'dữ liệu có sẵn cả tên; in ra là phơi lịch riêng của cả đội');
  la('lấy lịch của CẢ ĐỘI, không lọc "của tôi"', /lcCuaNgayTu\(d, g, false\)/.test(catHam('dbBanCuaNgay')),
     'để `true` là dải chỉ bày lịch của chính người đang xem');
  la('tên người đi qua chuSach', /chuSach\(duTenNguoi\(id\)\)/.test(VE));
  la('cái tên ở đầu cột là nút bật/tắt', /onclick="dbBat\('\$\{id\}'\)"/.test(VE));
  la('ô bận nối tiếp ô bận thì bỏ vạch ngang giữa hai ô',
     /noi = ban && i > 0 && co\[i-1\]/.test(VE),
     'thiếu thì một buổi hai tiếng đọc ra thành bốn ô rời');
  la('mỗi đầu giờ có một nhãn giờ, nửa giờ thì bỏ trống',
     /dauGio[\s\S]{0,120}?db-gio[\s\S]{0,120}?<span class="db-gio"><\/span>/.test(VE));
  la('số cột chạy theo số người', /repeat\(\$\{ai\.length\}/.test(VE));
  la('không có khe thì không bày nút sao chép', /\$\{khe\.length \? '<button/.test(VE));
}

/* ── ⑥ HAI CỬA VÀO ──────────────────────────────────────────────────────── */
console.log('\n⑥ Màn Vận hành, và khối mở-ra-được trong cửa Sự kiện');
{
  /* ⚠️ ĐỔI ĐỊA CHỈ 03/09 (TRI-92). Bốn ca đầu mục này trước gác NẤC "Toàn team"
     trong khối Lịch trình; ba bảng ấy nay là MÀN VẬN HÀNH, vẽ bởi `veVanHanh`.
     Luật được gác không đổi một điều nào — chỉ đổi chỗ nó phải đúng. */
  la('nấc Toàn team KHÔNG còn trong bộ chọn nấc',
     /\['ngay','Ngày'\],\['tuan','Tuần'\],\['thang','Tháng'\]\]/.test(SRC)
     && !/'doi','Toàn team'/.test(SRC),
     'để lại là hai cửa cho một phòng — nấc cũ và màn mới sẽ trôi lệch nhau');

  /* CỬA VÀO PHẢI CÓ ĐỦ BA MẢNH, thiếu một là nút biến mất CÂM: cái thẻ trong
     `.dau-phai`, dòng khai trong `NUT_LE` (thứ dời nó sang thanh lề và đổ hình
     vào), và nhánh nạp trong `moTab`. Chính `.dau-phai` bị `body.co-le` giấu
     đi, nên quên khai trong `NUT_LE` là nút không hiện ở đâu cả — không lỗi,
     không cảnh báo. Cảnh báo ấy đã nằm sẵn trong mã từ 01/09; ca này biến nó
     thành một hàng rào. */
  la('thẻ nút Vận hành có trong .dau-phai',
     /<button class="nut-le" id="nut-vh" onclick="moTab\('vanhanh'\)"/.test(SRC));
  /* Hỏi TỪNG TRƯỜNG, không khớp cả dòng một cục: bản đầu của ca này viết một
     mẫu ôm trọn `{id … man}` rồi đỏ oan ngay khi thêm trường `ten` vào cuối —
     một ca gác cấu trúc mà lại ngã vì thứ tự chữ. */
  const dongVH = /\{\s*id:'nut-vh'[^}]*\}/.exec(SRC);
  la('NUT_LE khai nút Vận hành, kèm hình · mã màn · tên',
     !!dongVH && /hinh:'vanhanh'/.test(dongVH[0]) && /man:'vanhanh'/.test(dongVH[0])
     && /ten:'[^']+'/.test(dongVH[0]),
     'thiếu dòng này thì veThanhLe không dời nút sang thanh lề — nút biến mất câm');
  la('moTab có nhánh nạp cho màn Vận hành',
     /if \(ten==='vanhanh'\) veVanHanh\(\);/.test(catHam('moTab')));
  la('màn Vận hành có ô chứa vh-khu trong HTML',
     /<div id="vh-khu"><\/div>/.test(SRC),
     'thiếu ô này thì veVanHanh quay ra ở dòng đầu, bấm nút mà không mở gì');

  const VH = catHam('veVanHanh');
  /* Luật cần giữ là THỨ TỰ, không phải khoảng cách: ô chứa phải vào cây trước
     khi hàm vẽ tìm nó theo id. Bản trước đo bằng "cách nhau dưới 200 ký tự" —
     một phép đo thay thế, và nó đỏ oan ngay khi có thêm một nhánh vẽ chen vào
     giữa (03/09, lúc thêm chế độ Lịch chung). Nay hỏi thẳng thứ tự. */
  const iThan = VH.indexOf('dbThanDoi()');
  const veKhu = ["dbVe('db-khu'", "dbVeLich('db-khu'", "dbVeChung('db-khu'"]
    .map(t => VH.indexOf(t)).filter(i => i >= 0);
  la('màn Vận hành dựng ô chứa TRƯỚC mọi lối vẽ vào ô ấy',
     iThan >= 0 && veKhu.length === 3 && veKhu.every(i => i > iThan),
     'dbVe tìm ô theo id, ô phải vào cây trước — thấy ' + veKhu.length + '/3 lối vẽ');
  const iDau = VH.indexOf('vhDauDai(');
  la('màn Vận hành đi qua vhDauDai trước khi vẽ bảng',
     iDau >= 0 && iThan >= 0 && iDau <= iThan,
     'hàng điều hướng và ô chứa dựng cùng một lượt gán, hàng đứng trước');

  /* BẪY `lcMoBuoi`: mọi dòng buổi ở hai bảng tuần gọi `lcMoBuoi(lich, ngay)`,
     mà hàm ấy tra buổi trong `LC_HIEN.ds`. Màn Vận hành đọc dải của RIÊNG nó,
     nên nếu nó giữ một bản riêng thay vì đổ vào `LC_HIEN` thì bảng vẽ đúng mà
     chạm vào một dòng ra thẳng câu "không tìm thấy sự kiện này" — câm và rất
     khó lần, vì hai thứ ấy trông không liên quan gì tới nhau. */
  la('veVanHanh đổ dải vừa đọc vào LC_HIEN trước khi vẽ',
     VH.indexOf('LC_HIEN = await lcLay(') >= 0
     && VH.indexOf('LC_HIEN = await lcLay(') < iThan,
     'lcMoBuoi tra buổi trong LC_HIEN.ds — giữ bản riêng là chạm vào dòng nào cũng báo không thấy');

  /* MỘT LỐI VẼ LẠI, KHÔNG HAI. Hơn hai chục chỗ gọi `veTimeline()` sau mỗi cú
     sửa một buổi, kể cả tin đẩy từ máy chủ, và không chỗ nào biết người dùng
     đang ở màn nào. `veTimeline` phải tự rẽ — bỏ cái rẽ ấy thì sửa một buổi
     trên màn Vận hành xong bảng đứng yên, mà không một dấu hiệu nào báo. */
  const VT = catHam('veTimeline');
  la('veTimeline rẽ sang màn Vận hành khi đang đứng ở đó',
     /if \(dangOVanHanh\(\)\) return void await veVanHanh\(\);/.test(VT)
     && VT.indexOf('dangOVanHanh()') < VT.indexOf("getElementById('tk-timeline')"),
     'phải rẽ TRƯỚC khi động vào khối Lịch trình của màn Hôm nay');
  la('veTimeline KHÔNG còn nhánh vẽ cho nấc Đội', !/TL_KHUNG === 'doi'/.test(VT));

  const MO = catHam('lcMoDai');
  la('bấm lần nữa thì đóng lại', /if \(!o\.hidden\)\{ o\.hidden = true/.test(MO));
  la('dò lại ô sau khi chờ, cửa có thể đã đóng',
     /await lcLay[\s\S]{0,120}?if \(!document\.getElementById\('lc-db'\)\) return;/.test(MO),
     'bẫy ① của sổ làn: đọc lại DOM sau await');
  la('dưới hai người thì không mở', /if \(ai\.length < 2\) return;/.test(MO));
  la('đổi nhóm dự trong lúc dải đang mở thì dải vẽ lại',
     /const dai = document\.getElementById\('lc-db'\);[\s\S]{0,140}?dbVe\('lc-db'/.test(catHam('lcVeRanh')),
     'để nguyên là dải bày một tập người đã cũ ngay dưới một danh sách vừa đổi');

  /* CỬA THỨ BA. Cửa gộp dựng lại khoang sự kiện bằng chuỗi mẫu RIÊNG của nó,
     nên mọi thứ cửa Sự kiện cũ có mà nó quên chép thì im lặng biến mất — đã
     hỏng đúng vậy một lần với chính khối giờ rảnh (03/09). Hai ca dưới gác cả
     hai cửa cùng lúc, để lần sau thêm gì vào một bên là bên kia kêu ngay. */
  const SK = catHam('vcVeSuKien'), FORM = catHam('lcMoForm');
  for (const [ten, ham] of [['cửa gộp', SK], ['cửa Sự kiện', FORM]]){
    la(ten + ' có nút mở lịch toàn team',
       /class="db-mo" onclick="lcMoDai\(this\)">Xem lịch toàn team</.test(ham));
    la(ten + ' có ô chứa lc-db cho lcMoDai vẽ vào',
       /<div id="lc-db" hidden><\/div>/.test(ham),
       'thiếu ô này thì lcMoDai quay ra ở dòng đầu, nút bấm được mà không mở gì');
  }

  /* CỠ BẢNG KHI NẰM TRONG CỬA. Ô 24px nhân 20 nấc nửa tiếng là 480px — nó nuốt
     trọn cửa khai sự kiện (Tracy 03/09). Thu bằng chiều cao ô, và phải BỎ trần
     cuộn cùng lúc: giữ trần thì bảng vừa thấp vừa vẫn cuộn, tức tự cắt mất phần
     nó vừa tiết kiệm được. */
  la('bảng trong cửa hạ chiều cao ô', /#lc-db \.db-o\{height:12px\}/.test(SRC));
  la('bảng trong cửa bỏ trần cuộn', /#lc-db \.db-mang\{max-height:none\}/.test(SRC),
     'còn trần thì cả ngày 8h-18h vẫn nằm sau một cú cuộn lồng trong cửa đang cuộn');
  la('nấc Toàn team KHÔNG bị thu theo', /\.db-o\{height:24px/.test(SRC),
     'ở đó bảng có cả màn cho riêng nó, thu là phí chỗ');
}

console.log(`\n${truot ? '❌' : '✅'} ${dat} ca đạt${truot ? ', ' + truot + ' ca trượt' : ''}.\n`);
process.exit(truot ? 1 : 0);
