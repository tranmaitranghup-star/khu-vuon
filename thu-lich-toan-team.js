/* THỬ: LỊCH TRÌNH CẢ TEAM — chế độ thứ hai của nấc Toàn team (TRI-72)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"tôi làm vận hành và ceo làm điều hành đang cần xem được lịch
   trình của toàn bộ mọi người (không cần task)... phòng sản phẩm add 1 sự kiện
   họp là tôi sẽ ko biết vì ko có tôi tham gia"*.

   Bảy ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · CỜ GÁC HAI LỚP. Công tắc chỉ hiện với người mang `la_dieu_hanh`, nhưng
       một cái nút ẩn không phải một hàng rào: ai gõ `dbCheDo('lich')` từ bàn
       phím vẫn đặt được biến. `vhCheDo` phải hỏi lại cờ, không chỉ hỏi chế độ —
       người không cờ thì nó trả về 'ranh' bất kể `DB_CHE_DO` mang gì.
       (Hàm này qua ba tên: `dbXemLich` → `dbXemTuan` → `vhCheDo` 03/09, khi ba
       bảng rời khối Lịch trình sang màn Vận hành. Luật chưa đổi lần nào.)

     · CỘT CHƯA LÊN MÁY CHỦ. Tệp SQL chạy lúc nào cũng được, nên `ME` có thể
       không mang trường ấy. `undefined === true` phải đọc ra false, không ngã.

     · RIÊNG TƯ HẸN 1-1. Dữ liệu về máy có đủ tên mọi buổi, kể cả hẹn riêng giữa
       hai người khác. In tên ra là phơi lịch riêng của cả team — chỗ này chỉ
       được hiện chữ "Bận". Nhưng buổi mình CÓ PHẦN trong đó thì phải hiện tên,
       nếu không người điều hành mất luôn lịch của chính mình.

     · MỘT BUỔI, NHIỀU HÀNG. Buổi cả công ty phải nằm ở hàng của mọi người —
       đó là cả mục đích của bảng. Quét theo người rồi hỏi từng buổi thì dễ ra
       một hàng thiếu mà không dấu hiệu nào báo.

     · ĐẾM BUỔI, KHÔNG ĐẾM DÒNG. Một buổi bảy người nằm ở bảy hàng; cộng cả bảy
       là báo bảy cuộc họp cho một cuộc — con số ở dòng tóm tắt sai gấp bảy lần
       mà trông vẫn hợp lý.

     · BA TRẠNG THÁI, KHÔNG HAI. Không có dòng trả lời ≠ từ chối. Và `chua` là
       một phép trừ, nên nó phải chặn sàn ở 0: một dòng tick của người đã rời
       nhóm nhận là đủ để nó âm.

     · DẢI LÀ MỘT TUẦN. Chế độ này bày bảy cột nên `tlMoc` phải trả về thứ Hai
       đến Chủ nhật; trả một ngày thì sáu cột trống mà không ai đoán được vì sao.

   Chạy:  node production/tinh-thuc-app/thu-lich-toan-team.js
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

/* ── MÁY CHẠY THẬT ──────────────────────────────────────────────────────────
   Nạp MÃ THẬT của cả chuỗi hàm. Bịa ra đúng ba thứ: ngày hôm nay (ghim lại thì
   bài thử mới nói cùng một điều ở mọi ngày chạy), bảng người, và một `document`
   đủ dùng cho một ô chứa — `dbVeLich` chỉ đọc `getElementById` rồi ghi
   `innerHTML`, không đụng gì khác của DOM. */
const KHOI_LICH = catKhoi('const LC_TEN_THU =', '/* Luật lặp có nổ vào ngày này không');
const KHOI_DB   = catKhoi("let DB_CHE_DO = '", '/* Bản đồ người → cờ bận');
const HANG_SO   = catKhoi('const LCR_TU = 8*60', 'let LC_RANH_LUOT');

function may(NAY, DOI, CHUC_NANG, ME, cheDo, khoi){
  const ra = new Function('NAY','DOI','CHUC_NANG','ME','CHE_DO','KHOI', `
    const homNay = () => NAY;
    let LC_HIEN = null, LC_VIEC = {};
    const chuSach = s => String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
    const tlgHHMM = p => String(Math.floor(p/60)).padStart(2,'0')+':'+String(p%60).padStart(2,'0');
    /* CỌC CHO THỨ MÃ THẬT GỌI TỚI mà bài này không đo: màu sự kiện, quyền sửa,
       và sổ gập/mở của khối ngày. Thiếu chúng thì hàm ngã trước khi đo được gì.
       Không dấu huyền quanh tên hàm ở đây — cả khối nằm trong một chuỗi mẫu. */
    const mauSuKien = l => '';
    const mauViec   = t => '';
    const lcDuocSua = l => true;
    let THE_THU = {};
    let GHI = '';
    const document = {getElementById: () => ({set innerHTML(v){ GHI = v; }, get innerHTML(){ return GHI; }})};
    ${HANG_SO}
    ${KHOI_LICH}
    ${catHam('dbLoiTrong')}
    ${catHam('dbLocNguoi')}
    ${catHam('lcNgayDich')}
    ${catHam('lcHopBuoc')}
    ${catHam('lcHopNgay')}
    ${catHam('lcLuot')}
    ${catHam('lcCuaNgayTu')}
    ${KHOI_DB}
    DB_CHE_DO = CHE_DO; DB_KHOI = KHOI;
    ${catHam('dbThanhCheDo')}
    ${catHam('dbTenBuoi')}
    ${catHam('dbBayNgay')}
    ${catHam('dbBuoiCuaLuot')}
    ${catHam('dbLichCuaDai')}
    ${catHam('dbVeLich')}
    return {vhCheDo, laDieuHanh, dbThanhCheDo, dbTenBuoi, dbBayNgay, dbLichCuaDai,
            ve: (d, tu, den, ai) => { dbVeLich('x', d, tu, den, ai); return GHI; }};`
  )(NAY, DOI, CHUC_NANG, ME, cheDo || 'lich', khoi || 0);
  return ra;
}

const CN = [{id:1,ten:'Vận hành'},{id:2,ten:'Sản phẩm'},{id:3,ten:'Kinh doanh'}];
/* `chuc_nang_ids` LÀ TRƯỜNG THẬT từ TRI-78 (một người thuộc nhiều khối); app
   chuẩn hoá nó ngay lúc nạp `DOI`, và cả `lcNguoiCuaLich` lẫn bộ lọc khối đều
   đọc mảng. Giữ `chuc_nang_id` bên cạnh vì `lcNguoiCuaLich` còn đọc nó cho
   nhánh phạm vi 'khoi'. Thiếu mảng thì hai ca dưới đỏ — và chúng đã đỏ trên
   `origin/main` từ lúc TRI-78 lên mà không ai chạy lại bài thử này. */
const DOI4 = [
  {id:'u1', ten:'Tracy', la_lead:true, chuc_nang_id:1, chuc_nang_ids:[1], thu_tu:1, la_dieu_hanh:true},
  {id:'u2', ten:'Andy',  la_lead:true, chuc_nang_id:1, chuc_nang_ids:[1], thu_tu:2, la_dieu_hanh:true},
  {id:'u3', ten:'Peter', la_lead:true, chuc_nang_id:2, chuc_nang_ids:[2], thu_tu:3},
  {id:'u4', ten:'Hafi',  la_lead:true, chuc_nang_id:2, chuc_nang_ids:[2], thu_tu:4}
];
const TRACY = DOI4[0], PETER = DOI4[2];
const AI    = DOI4.map(x => x.id);

const buoi = (o) => Object.assign({id: o.id || ('l'+Math.random().toString(36).slice(2,7)),
  ten:'Buổi', pham_vi:'cong_ty', nguoi_ids:[], chuc_nang_ids:[], tao_boi:'u3',
  lap:'khong', thu:[], ngay_bat_dau:'2026-09-03', ngay_ket_thuc:null,
  gio_bat_dau:9*60, so_phut:60}, o);
const dai = (ds, them) => Object.assign({ds, huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}}, them);

/* Thứ Năm 03/09/2026. Tuần của nó: T2 31/08 → CN 06/09. */
const NAY = '2026-09-03';

/* ── ① CỜ GÁC HAI LỚP ───────────────────────────────────────────────────── */
console.log('\n① Chế độ lịch trình chỉ mở cho người mang cờ điều hành');
{
  const co    = may(NAY, DOI4, CN, TRACY, 'lich');
  const khong = may(NAY, DOI4, CN, PETER, 'lich');   // đã đặt biến, nhưng không cờ
  la('người có cờ: vhCheDo() giữ nguyên chế độ đã chọn', co.vhCheDo() === 'lich');
  la('người KHÔNG cờ: vhCheDo() lùi về "ranh" dù DB_CHE_DO đã là "lich"',
     khong.vhCheDo() === 'ranh',
     'một cái nút ẩn không phải hàng rào — vhCheDo phải hỏi lại cờ');
  la('người KHÔNG cờ không thấy công tắc', khong.dbThanhCheDo() === '');
  /* NĂM nút từ 05/09 (TRI-119). Nút giữa đổi tên "Lịch trình" → "Từng người"
     hồi 03/09: cái tên cũ và tên chế độ "Lịch chung" chỉ khác nhau một chữ, mà
     chúng nằm cạnh nhau trong cùng một dải công tắc. Nay "Lịch chung" cũng đi
     nốt, thành "Danh sách" — đứng cạnh "7 ngày" và "Tháng" thì cái tên phải nói
     CÁCH BÀY, không nói lại thứ cả ba cùng bày. */
  const thanh = co.dbThanhCheDo();
  la('người có cờ thấy đủ năm nút', /Giờ rảnh/.test(thanh)
                                 && /Từng người/.test(thanh)
                                 && /Danh sách/.test(thanh)
                                 && /7 ngày/.test(thanh)
                                 && /Tháng/.test(thanh),
     thanh.slice(0, 300));
  la('tên nút cũ "Lịch chung" đã đi hẳn', !/>Lịch chung</.test(thanh),
     'ba nút cuối đều là lịch chung — giữ tên ấy cho một nút là nói lại thứ cả ba cùng bày');
  la('tên nút cũ "Lịch trình" đã đi hẳn', !/>Lịch trình</.test(thanh),
     'để lại thì hai nút cạnh nhau chỉ khác một chữ');
}

/* ── ⑨ BUỔI ĐÃ DỜI NẰM Ở CỘT NGÀY NÓ DIỄN RA (TRI-79) ────────────────────────
   Sổ tra của `dbLichCuaDai` từng khoá theo NGÀY GỐC (`o.ngay`) trong khi
   `dbVeLich` đọc bằng ngày của CỘT (`g`). Hai cái ấy chỉ khác nhau đúng ở buổi
   đã dời — nên buổi gốc thứ Hai dời sang thứ Năm hiện ở cột thứ Hai rồi mất
   khỏi thứ Năm. Không ca thử nào của đợt trước chạm buổi dời, nên nó lên sóng
   êm. Ca này khoá lại chỗ ấy.                                               */
{
  console.log('\n⑨ Buổi đã dời nằm ở cột ngày nó DIỄN RA, không ở ngày gốc');
  const m = may('2026-09-03', DOI4, CN, TRACY, 'lich', 0);
  const d = {
    ds: [{id: 9, ten: 'Họp toàn công ty', pham_vi: 'cong_ty', tao_boi: 'u1',
          lap: 'khong', ngay_bat_dau: '2026-08-31', gio_bat_dau: 9*60, so_phut: 60,
          dang_dung: true}],
    huy: {},
    /* Dời buổi gốc 31/08 sang 03/09 — hai sổ tra, đúng như `lcLay` dựng. */
    doi:    {'9|2026-08-31': {lich_id: 9, ngay_goc: '2026-08-31', kieu: 'doi',
                              ngay_moi: '2026-09-03', gio_moi: 14*60}},
    doiToi: {'9|2026-09-03': ['2026-08-31']},
    tick: {'9|2026-08-31': {nhan: 1, ai: {u1: true}}}, gc: {}, tb: {}
  };
  const html = m.ve(d, '2026-08-31', '2026-09-06', ['u1','u2','u3','u4']);
  /* Bảng là một lưới phẳng: mỗi hàng người là một ô tên rồi bảy ô ngày liền
     nhau. Đếm ô để biết buổi rơi vào cột thứ mấy — đọc thẳng chỗ nó đứng, chứ
     không hỏi "có mặt trong HTML không" (câu ấy cả hai bên đều trả lời có). */
  const oTracy = html.split('<span class="dbl-ten">')[1] || '';
  const cot = oTracy.split('<span class="dbl-o').slice(1, 8);
  const coBuoi = cot.map(c => /Họp toàn công ty/.test(c));
  la('buổi hiện ở cột thứ Năm 03/09 (cột thứ 4)', coBuoi[3] === true,
     'các cột có buổi: ' + JSON.stringify(coBuoi));
  la('và KHÔNG còn ở cột thứ Hai 31/08 (ngày gốc)', coBuoi[0] === false);
  la('cả tuần chỉ có đúng một chỗ hiện nó', coBuoi.filter(Boolean).length === 1);
  la('vẫn đeo dấu ⇢ đã dời', /⇢/.test(oTracy));
}

/* ── ⑩ THÔI DẤU ✓ ✕ · TRÊN Ô BUỔI (Tracy chốt 03/09) ─────────────────────────
   *"khung này cũng bỏ icon đi giữ lại ngôi sao thể hiện ai host thôi"*. Màu nét
   dọc bên trái mang trọn nghĩa; ★ ⇢ ✎ ở lại vì chúng nói ba chuyện khác, và
   với hai cái sau thì ô buổi là kênh DUY NHẤT.                              */
{
  console.log('\n⑩ Ô buổi thôi mang dấu trạng thái, giữ ★ người tạo');
  const m = may('2026-09-03', DOI4, CN, TRACY, 'lich', 0);
  const d = {
    ds: [{id: 1, ten: 'Coreteam tuần', pham_vi: 'cong_ty', tao_boi: 'u1',
          lap: 'khong', ngay_bat_dau: '2026-09-03', gio_bat_dau: 9*60, so_phut: 60,
          dang_dung: true}],
    huy: {}, doi: {}, doiToi: {},
    tick: {'1|2026-09-03': {nhan: 1, ai: {u1: true, u3: false}}}, gc: {},
    tb: {'1|2026-09-03': {truoc: {chu: 'chuẩn bị'}, sau: {chu: ''}}}
  };
  const html = m.ve(d, '2026-08-31', '2026-09-06', ['u1','u2','u3','u4']);
  la('không còn dấu ✓ trong bảng', !/✓/.test(html));
  la('không còn dấu ✕ trong bảng', !/✕/.test(html));
  la('không còn lớp dbl-dau', !/dbl-dau/.test(html));
  la('★ người tạo vẫn còn', /dbl-chu/.test(html) && /★/.test(html));
  la('✎ có ghi chú vẫn còn', /✎/.test(html));
  la('màu vẫn nói đủ ba trạng thái',
     /dbl-b nhan/.test(html) && /dbl-b choi/.test(html) && /dbl-b chua/.test(html));
  la('chú giải bày mẫu MÀU, không bày dấu', /dbl-vach nhan/.test(html)
     && /dbl-vach choi/.test(html) && /dbl-vach chua/.test(html));
}

/* ── ② CỘT CHƯA LÊN MÁY CHỦ ─────────────────────────────────────────────── */
console.log('\n② Chưa chạy tệp SQL thì tắt lặng, không ngã');
{
  const cu = may(NAY, [{id:'u1',ten:'Tracy',thu_tu:1}], CN, {id:'u1',ten:'Tracy'}, 'lich');
  la('ME không có trường la_dieu_hanh → laDieuHanh() false',
     cu.laDieuHanh() === false, 'undefined === true phải đọc ra false');
  la('và công tắc không hiện', cu.dbThanhCheDo() === '');
}

/* ── ③ BUỔI MỜI ĐÍCH DANH HIỆN TÊN THẬT · LỊCH CÁ NHÂN KHÔNG HIỆN ─────────
   HAI LẦN ĐỔI LUẬT, ba ca ở đây trượt im từ lần đầu:
     · Tới 03/09 — buổi 1-1 của người khác chỉ hiện chữ "Bận", theo lối Lịch
       Google dựng cho người chỉ có quyền xem-rảnh-bận.
     · 04/09 — chữ ấy gỡ hẳn. Tracy: cả màn này đã đứng sau cờ điều hành mà chỉ
       hai người mang, nên lớp che không che ai — nó chỉ giấu thông tin khỏi
       đúng hai người mở màn ra để xếp lịch cho cả team.
     · 05/09 — thứ PHẢI biến mất khỏi màn là **lịch cá nhân** (cột `rieng_tu`,
       ô Loại), không phải buổi mời đích danh (ô Đối tượng). Buổi 1-1 vẫn là
       việc của ROVA.
   ⚠️ Cờ điều hành vẫn là thứ DUY NHẤT đứng giữa: bật nó cho người thứ ba là mở
   luôn tên mọi buổi mời đích danh của cả team cho họ. */
console.log('\n③ Buổi mời đích danh hiện tên thật · lịch cá nhân không lên màn');
{
  const f = may(NAY, DOI4, CN, TRACY, 'lich');
  const rieng = buoi({ten:'Nói chuyện lương', pham_vi:'ca_nhan',
                      nguoi_ids:['u3','u4'], tao_boi:'u3'});
  la('buổi 1-1 giữa hai người khác → hiện tên thật',
     f.dbTenBuoi(rieng, {ten: rieng.ten}) === 'Nói chuyện lương',
     'chữ "Bận" đã gỡ 04/09 — màn này chỉ hai người có cờ mở được');

  const cuaToi = buoi({ten:'Nói chuyện lương', pham_vi:'ca_nhan',
                       nguoi_ids:['u1','u3'], tao_boi:'u3'});
  la('buổi 1-1 mà mình được mời → cũng tên thật',
     f.dbTenBuoi(cuaToi, {ten: cuaToi.ten}) === 'Nói chuyện lương');

  const chung = buoi({ten:'Họp sản phẩm', pham_vi:'khoi', chuc_nang_ids:[2]});
  la('buổi của khối khác → hiện tên, không giấu',
     f.dbTenBuoi(chung, {ten: chung.ten}) === 'Họp sản phẩm',
     'đây đúng là thứ Tracy mở bảng này ra để thấy');

  const html = f.ve(dai([rieng]), NAY, NAY, AI);
  la('và nó có mặt trong bảng Từng người', /Nói chuyện lương/.test(html));

  /* Lịch cá nhân thì ngược lại — cùng một buổi ấy, thêm cờ `rieng_tu`. */
  const caNhan = buoi({ten:'Tennis', pham_vi:'ca_nhan', rieng_tu:true,
                       nguoi_ids:['u3','u4'], tao_boi:'u3'});
  const h2 = f.ve(dai([caNhan]), NAY, NAY, AI);
  la('lịch cá nhân không lọt vào bảng Từng người', !/Tennis/.test(h2),
     'màn Vận hành chỉ bày lịch ROVA — Tracy chốt 05/09');
}

/* ── ④ MỘT BUỔI NẰM Ở NHIỀU HÀNG ────────────────────────────────────────── */
console.log('\n④ Buổi cả công ty nằm ở hàng của mọi người');
{
  const f = may(NAY, DOI4, CN, TRACY, 'lich');
  const so = f.dbLichCuaDai(dai([buoi({id:9, ten:'Họp tuần'})]), [NAY], AI);
  la('đủ bốn hàng có buổi', AI.every(id => (so.get(id+'|'+NAY) || []).length === 1),
     [...so.keys()].join(' · '));

  const khoi = f.dbLichCuaDai(dai([buoi({id:8, pham_vi:'khoi', chuc_nang_ids:[2]})]), [NAY], AI);
  la('buổi của khối Sản phẩm chỉ vào hàng u3·u4',
     !khoi.has('u1|'+NAY) && !khoi.has('u2|'+NAY)
     && khoi.has('u3|'+NAY) && khoi.has('u4|'+NAY));
}

/* ── ⑤ ĐẾM BUỔI, KHÔNG ĐẾM DÒNG ─────────────────────────────────────────── */
console.log('\n⑤ Dòng tóm tắt đếm buổi, không đếm dòng trong bảng');
{
  const f = may(NAY, DOI4, CN, TRACY, 'lich');
  const html = f.ve(dai([buoi({id:7, ten:'Họp tuần'})]), NAY, NAY, AI);
  la('một buổi bốn người vẫn báo "1 buổi"', /<b>1<\/b> buổi/.test(html),
     'cộng cả bốn hàng là báo bốn cuộc họp cho một cuộc: '
     + (html.match(/<b>\d+<\/b> buổi/) || ['(không thấy)'])[0]);
}

/* ── ⑥ BA TRẠNG THÁI TRẢ LỜI ────────────────────────────────────────────── */
console.log('\n⑥ Ba trạng thái: đã nhận · từ chối · chưa trả lời');
{
  const f = may(NAY, DOI4, CN, TRACY, 'lich');
  const d = dai([buoi({id:5, ten:'Họp tuần'})],
                {tick: {['5|'+NAY]: {nhan:1, toi:true, ai:{u1:true, u3:false}}}});
  const b = (f.dbLichCuaDai(d, [NAY], AI).get('u1|'+NAY) || [])[0];
  la('đếm đúng 1 nhận · 1 từ chối · 2 chưa',
     b && b.nhan === 1 && b.choi === 1 && b.chua === 2,
     JSON.stringify(b && {nhan:b.nhan, choi:b.choi, chua:b.chua, tong:b.tong}));

  const html = f.ve(d, NAY, NAY, AI);
  la('hàng u1 mang lớp "nhan"',  /class="dbl-b nhan"/.test(html));
  la('hàng u3 mang lớp "choi"',  /class="dbl-b choi"/.test(html));
  la('hai hàng còn lại "chua"', (html.match(/class="dbl-b chua"/g) || []).length === 2);

  /* Dòng tick của một người đã rời tập nhận: phép trừ không được ra số âm. */
  const thua = dai([buoi({id:4, pham_vi:'khoi', chuc_nang_ids:[2]})],
                   {tick: {['4|'+NAY]: {nhan:3, toi:null, ai:{u3:true,u4:true,u9:true}}}});
  const b2 = (f.dbLichCuaDai(thua, [NAY], AI).get('u3|'+NAY) || [])[0];
  la('chưa-trả-lời chặn sàn ở 0, không âm', b2 && b2.chua === 0, JSON.stringify(b2 && b2.chua));
}

/* ── ⑦ LỌC KHỐI VÀ DẢI TUẦN ─────────────────────────────────────────────── */
console.log('\n⑦ Lọc khối · bảy cột ngày');
{
  const loc  = may(NAY, DOI4, CN, TRACY, 'lich', 2);       // chỉ khối Sản phẩm
  const html = loc.ve(dai([buoi({id:3})]), NAY, NAY, AI);
  la('lọc khối Sản phẩm thì chỉ còn Peter và Hafi',
     /Peter/.test(html) && /Hafi/.test(html) && !/>Tracy</.test(html));

  const trong = may(NAY, DOI4, CN, TRACY, 'lich', 3).ve(dai([]), NAY, NAY, AI);
  la('khối chưa có ai → nói thẳng, không bày bảng rỗng',
     /chưa có ai trong team/.test(trong));

  const f = may(NAY, DOI4, CN, TRACY, 'lich');
  la('dbBayNgay trả đúng bảy ngày', f.dbBayNgay('2026-08-31','2026-09-06').length === 7);
  la('và bắt đầu từ thứ Hai', f.dbBayNgay('2026-08-31','2026-09-06')[0] === '2026-08-31');

  const h7 = f.ve(dai([]), '2026-08-31', '2026-09-06', AI);
  la('bảng dựng đủ bảy cột ngày', (h7.match(/class="dbl-mu/g) || []).length === 8,
     'một ô góc + bảy ô ngày');
  la('cột hôm nay được đánh dấu', /class="dbl-mu nay"/.test(h7));
}

/* ── ⑧ MỐC DẢI CỦA MÀN — vhMoc phải trả về một TUẦN ─────────────────────── */
/* ⚠️ ĐỔI ĐỊA CHỈ 03/09 (TRI-92), KHÔNG ĐỔI LUẬT. Trước đó ba bảng này là nấc
   thứ tư của khối Lịch trình, nên phép tính dải nằm ở `tlMoc` và đọc `TL_NGAY`.
   Nay chúng là màn Vận hành với con trỏ ngày riêng, nên phép tính là `vhMoc`
   đọc `VH_NGAY`. Ba ca dưới hỏi y hệt ba câu cũ — một tuần · một ngày · người
   không cờ — chỉ trỏ vào hàm mới. */
console.log('\n⑧ vhMoc: màn Vận hành ở chế độ lịch đọc cả tuần');
{
  const f = new Function('NAY','ME','CHE_DO', `
    const homNay = () => NAY;
    /* Cùng phép tính với d2s thật, viết bằng phép NỐI chuỗi: bản gốc dùng
       chuỗi mẫu, mà khối này chính nó nằm trong một chuỗi mẫu — một dấu đô-la
       kèm ngoặc nhọn ở đây sẽ được nội suy ngay lúc dựng bài thử. Cùng họ bẫy
       với luật dấu huyền ở thu-cu-phap.js ca ②.
       Cũng KHÔNG dùng toISOString().slice(0,10): nó đọc theo giờ UTC nên ở múi
       giờ VN lùi một ngày, và phép tính thứ Hai lệch theo. */
    const d2s = d => d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0')
                                     + '-' + String(d.getDate()).padStart(2,'0');
    ${catHam('thuHai')}
    ${KHOI_DB}
    VH_NGAY = NAY; DB_CHE_DO = CHE_DO;
    return vhMoc;`);
  const tuan = f(NAY, TRACY, 'lich')();
  la('chế độ lịch → T2 31/08 đến CN 06/09',
     tuan.tu === '2026-08-31' && tuan.den === '2026-09-06', JSON.stringify(tuan));
  const ngay = f(NAY, TRACY, 'ranh')();
  la('chế độ giờ rảnh → vẫn đúng một ngày',
     ngay.tu === NAY && ngay.den === NAY, JSON.stringify(ngay));
  const nguoiThuong = f(NAY, PETER, 'lich')();
  la('người không cờ → một ngày, dù biến chế độ đã bị đặt',
     nguoiThuong.tu === NAY && nguoiThuong.den === NAY, JSON.stringify(nguoiThuong));
}

console.log(truot ? `\n❌ ${dat} ca đạt, ${truot} ca trượt.` : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
