/* THỬ: LỊCH CHUNG — chế độ thứ ba của nấc Toàn team (TRI-77)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"tôi cần 1 lịch trình chung — ví dụ hôm nay 9h30 có phòng sản
   phẩm và sales đều họp thì lịch sẽ hiện các lịch này và hiện những người tham
   gia, những người đã confirm, để tôi nắm được nhịp họp các phòng ban"*. Cộng
   hai câu chốt cùng ngày: *"bỏ icon chỗ tên người đi chỉ cần màu xanh hiểu là
   confirm rồi mà"* và *"cần thêm 1 trạng thái là đã hoàn thành, ai đã hoàn
   thành lịch đó thì màu xanh cả khối"*.

   Tám ca đáng giá nhất — đều là chỗ thử tay từng bước KHÔNG lộ ra:

     · MỘT BUỔI MỘT DÒNG. Bảng kia rải một buổi xuống từng người dự; bảng này
       phải làm ngược lại. Gom nhầm chiều thì một cuộc họp bảy người ra bảy
       dòng — trông vẫn hợp lý, và con số ở đầu bảng sai gấp bảy lần.

     · TRÙNG GIỜ GOM MỘT MỐC. Đây là câu Tracy hỏi. Ba buổi 09:30 phải nằm dưới
       đúng MỘT con số giờ; tách ra là mất hẳn thứ khiến bảng này đáng dựng.

     · BỐN NẤC, VÀ THỨ TỰ HỎI. Người đã dự xong thì ô tham dự của họ cũng đang
       `true` — hỏi 'nhan' trước thì không bao giờ chạm tới nấc cuối, và nấc mới
       lặng lẽ không bao giờ hiện.

     · ĐÃ XONG NẰM TRONG ĐÃ NHẬN. Tách hai con số ra là bảng tự mâu thuẫn: một
       người vừa được đếm ở cột nhận vừa biến khỏi nó tuỳ chỗ đọc.

     · KHÔNG ĐỌC ĐƯỢC ≠ KHÔNG AI XONG. Máy chủ chưa có cột `task.lich_id`, hoặc
       truy vấn hỏng — trả sổ rỗng là khẳng định "không ai xong cả", một câu
       sai và sai đúng về phía làm người điều hành yên tâm nhầm.

     · HẸN RIÊNG BỊ ẨN NHƯNG PHẢI ĐƯỢC ĐẾM. Giấu im lặng thì ngày ấy trông
       trống trơn, mà nó không trống.

     · THẺ TÊN KHÔNG CÓ DẤU. Ba cái dấu đã đi; nếu lớp màu cũng trượt thì bảng
       mất sạch nghĩa mà vẫn dựng ra HTML trông bình thường.

     · BUỔI ĐÃ DỜI THEO NGÀY DIỄN RA. Cùng cái bẫy đã cắn bảng kia (TRI-79):
       khoá gom phải là ngày của CỘT, không phải ngày gốc của luật lặp.

   Chạy:  node production/tinh-thuc-app/thu-lich-chung.js
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

/* Cắt đúng MỘT dòng buổi ra khỏi bảng. Đo trên cả bảng là đo nhầm: hàng chú
   giải đầu màn dựng bằng CHÍNH những thẻ ấy, nên một ca "dòng này không có
   thẻ X" sẽ trượt vì một cái thẻ nằm ở chỗ khác hẳn. */
function nut(html, ten){
  const i = html.indexOf(ten);
  if (i < 0) return '';
  const dau = html.lastIndexOf('<button', i);
  const cuoi = html.indexOf('</button>', i);
  return dau < 0 || cuoi < 0 ? '' : html.slice(dau, cuoi + 9);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── MÁY CHẠY THẬT ──────────────────────────────────────────────────────────
   Nạp MÃ THẬT của cả chuỗi hàm, y lối bài thử TRI-72 đã đi. Bịa ra đúng bốn
   thứ: ngày hôm nay (ghim lại thì bài thử nói cùng một điều ở mọi ngày chạy),
   bảng người, mảng tên thứ, và một `document` đủ cho một ô chứa. */
const KHOI_LICH = catKhoi('const LC_TEN_THU =', '/* Luật lặp có nổ vào ngày này không');
/* Mốc cắt phải là DÒNG KHAI, không phải giá trị của nó. Dòng này từng đọc
   'ranh' và bài thử chết đứng từ hôm màn Vận hành đổi chế độ mặc định sang
   'chung' — cả tệp ngã ngay lúc khởi động, nên mọi ca bên trong im lặng biến
   mất mà không một dòng đỏ nào bật lên. */
const KHOI_DB   = catKhoi("let DB_CHE_DO = '", '/* Bản đồ người → cờ bận');
const HANG_SO   = catKhoi('const LCR_TU = 8*60', 'let LC_RANH_LUOT');
const NHAN_NAC  = catKhoi('const DB_NHAN_NAC =', '/* Mọi buổi của một dải');

function may(NAY, DOI, CHUC_NANG, ME, khoi){
  return new Function('NAY','DOI','CHUC_NANG','ME','KHOI', `
    const homNay = () => NAY;
    let LC_HIEN = null, LC_VIEC = {};
    const TQ_THU = ['Chủ nhật','Thứ hai','Thứ ba','Thứ tư','Thứ năm','Thứ sáu','Thứ bảy'];
    const chuSach = s => String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
    const tlgHHMM = p => String(Math.floor(p/60)).padStart(2,'0')+':'+String(p%60).padStart(2,'0');
    /* CỌC CHO THỨ MÃ THẬT GỌI TỚI mà bài này không đo. Màu sự kiện, quyền sửa
       và sổ gập/mở của khối ngày đều là chuyện của màn hình, không phải của
       phép gom buổi — nhưng thiếu chúng thì hàm ngã trước khi đo được gì.
       Không dấu huyền quanh tên hàm trong khối này: nó nằm trong một chuỗi mẫu. */
    const mauSuKien = l => '';
    const mauViec   = t => '';
    const lcDuocSua = l => true;
    let THE_THU = {};
    let GHI = '';
    const document = {getElementById: () => ({set innerHTML(v){ GHI = v; }, get innerHTML(){ return GHI; }})};
    ${HANG_SO}
    ${KHOI_LICH}
    ${catHam('dbLoiTrong')}
    ${catHam('dbLocBuoi')}
    ${catHam('dbLocNguoi')}
    ${catHam('lcNgayDich')}
    ${catHam('lcHopBuoc')}
    ${catHam('lcHopNgay')}
    ${catHam('lcLuot')}
    ${catHam('lcCuaNgayTu')}
    ${KHOI_DB}
    DB_CHE_DO = 'chung'; DB_KHOI = KHOI;
    ${catHam('dbThanhCheDo')}
    ${catHam('dbTenBuoi')}
    ${catHam('dbBayNgay')}
    ${catHam('dbLocNguoi')}
    ${catHam('dbLocBuoi')}
    ${catHam('dbLoiTrong')}
    ${catKhoi('const dbNhanBuoi', '/* Bảy ngày của một tuần')}
    ${catHam('dbBuoiCuaLuot')}
    ${catHam('dbNacCuaNguoi')}
    ${NHAN_NAC}
    ${catHam('dbBuoiCuaDai')}
    ${catHam('dbVeChung')}
    return {vhCheDo, laDieuHanh, dbNacCuaNguoi, dbBuoiCuaDai, dbBuoiCuaLuot,
            ve: (d, tu, den, ai, xong) => { dbVeChung('x', d, tu, den, ai, xong); return GHI; }};`
  )(NAY, DOI, CHUC_NANG, ME, khoi || 0);
}

const NAY = '2026-09-03';                       /* thứ Năm */
const CN  = [{id:1,ten:'Vận hành'},{id:2,ten:'Sản phẩm'},{id:3,ten:'Kinh doanh'}];
const DOI5 = [
  {id:'u1', ten:'Tracy',  la_lead:true, chuc_nang_id:1, chuc_nang_ids:[1], thu_tu:1, la_dieu_hanh:true},
  {id:'u2', ten:'Andy',   la_lead:true, chuc_nang_id:1, chuc_nang_ids:[1], thu_tu:2, la_dieu_hanh:true},
  {id:'u3', ten:'Peter',  la_lead:true, chuc_nang_id:2, chuc_nang_ids:[2], thu_tu:3},
  {id:'u4', ten:'Hafi',   la_lead:true, chuc_nang_id:2, chuc_nang_ids:[2], thu_tu:4},
  {id:'u5', ten:'Sydney', la_lead:true, chuc_nang_id:3, chuc_nang_ids:[3], thu_tu:5}
];
const TRACY = DOI5[0], PETER = DOI5[2];
const AI = DOI5.map(x => x.id);

/* Ba buổi cùng mở lúc 09:30 hôm nay, ba phạm vi khác nhau — đúng tình huống
   Tracy nêu. Buổi Sản phẩm cả hai người đã dự xong.

   BUỔI THỨ TƯ là một buổi MỜI ĐÍCH DANH lúc 11:00, thêm hồi 04/09. Từ hôm ấy
   nó HIỆN ở "Mọi khối" — nó là việc của công ty, chỉ khác ở chỗ người nhận là
   mấy cái tên chứ không phải một khối. Ba ca đếm số dòng ở mục ① và một ca đếm
   ★ ở mục ⑥ vẫn chờ con số ba suốt từ đó, tức bốn ca đỏ nằm im trong một tệp
   vốn đã không chạy nổi — chép lại đây vì đó là hai lớp hỏng chồng lên nhau:
   tệp chết thì không ai đọc con số, và con số sai thì không ai tin tệp. */
function daiBonBuoi(){
  return {
    ds: [
      {id:1, ten:'Check in coreteam', pham_vi:'cong_ty', tao_boi:'u1', lap:'khong',
       ngay_bat_dau:NAY, gio_bat_dau:9*60+30, so_phut:30, dang_dung:true},
      {id:2, ten:'Sprint review sản phẩm', pham_vi:'khoi', chuc_nang_ids:[2],
       tao_boi:'u3', lap:'khong', ngay_bat_dau:NAY, gio_bat_dau:9*60+30, so_phut:60, dang_dung:true},
      {id:3, ten:'Chốt số kinh doanh', pham_vi:'khoi', chuc_nang_ids:[3],
       tao_boi:'u5', lap:'khong', ngay_bat_dau:NAY, gio_bat_dau:9*60+30, so_phut:45, dang_dung:true},
      {id:4, ten:'Check in Peter Hafi', pham_vi:'ca_nhan', nguoi_ids:['u4'],
       tao_boi:'u3', lap:'khong', ngay_bat_dau:NAY, gio_bat_dau:11*60, so_phut:45, dang_dung:true}
    ],
    huy:{}, doi:{}, doiToi:{},
    tick: {
      ['1|'+NAY]: {nhan:2, ai:{u1:true, u2:true, u3:false}},
      ['2|'+NAY]: {nhan:2, ai:{u3:true, u4:true}},
      ['3|'+NAY]: {nhan:1, ai:{u5:true}}
    },
    gc:{}, tb:{}
  };
}
const XONG = {['2|'+NAY]: new Set(['u3','u4']), ['1|'+NAY]: new Set(['u1'])};

/* ── ① MỘT BUỔI MỘT DÒNG, VÀ TRÙNG GIỜ GOM MỘT MỐC ─────────────────────── */
{
  console.log('① Một buổi một dòng · các buổi trùng giờ gom về một mốc');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  /* Đếm theo TIỀN TỐ, không theo chuỗi khít: từ TRI-85 dòng buổi còn đeo thêm
     ` xong` (đúng kế hoạch) hoặc ` bong` (bóng ở ngày cũ). Khít chuỗi thì bài
     thử trượt vì một thay đổi hợp lệ, và cái trượt ấy nói sai chỗ. */
  const soDong = (html.match(/class="dbc-b[ "]/g) || []).length;
  la('bốn buổi ra đúng bốn dòng, không nhân theo người', soDong === 4, 'đếm được ' + soDong);
  const soMoc = (html.match(/class="dbc-nhom"/g) || []).length;
  la('ba buổi 09:30 gom một mốc, buổi 11:00 mốc riêng → hai mốc',
     soMoc === 2, 'đếm được ' + soMoc);
  la('mốc ấy hiện đúng một lần chữ 09:30',
     (html.match(/>09:30</g) || []).length === 1);
  la('giờ kết thúc trả về từng dòng',
     /→ 10:00/.test(html) && /→ 10:30/.test(html) && /→ 10:15/.test(html),
     'ba buổi cùng mở 09:30 nhưng đóng ba lúc');
  la('đầu bảng đếm 4 buổi', /<b>4<\/b> buổi tuần này/.test(html));
  la('và báo có mốc giờ trùng', /<b>1<\/b> mốc giờ có hai buổi trở lên/.test(html));
}

/* ── ② BỐN NẤC, VÀ THỨ TỰ HỎI ──────────────────────────────────────────── */
{
  console.log('\n② Bốn nấc trạng thái · "đã dự xong" thắng "đã nhận"');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const b = {dap:{u1:true, u2:false}, dsXong:new Set(['u1'])};
  la('người vừa nhận vừa đã xong → nấc "xong"', m.dbNacCuaNguoi(b,'u1') === 'xong',
     'hỏi "nhan" trước thì nấc cuối không bao giờ chạm tới');
  la('người từ chối → "choi"', m.dbNacCuaNguoi(b,'u2') === 'choi');
  la('người chưa trả lời → "chua"', m.dbNacCuaNguoi(b,'u3') === 'chua');
  la('không có sổ xong → lùi về "nhan"',
     m.dbNacCuaNguoi({dap:{u1:true}, dsXong:null},'u1') === 'nhan');

  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('thẻ Tracy ở buổi coreteam mang lớp xong', /dbc-ng xong"[^>]*Tracy/.test(html)
     || /class="dbc-ng xong"[^>]*>(<b[^>]*>★<\/b>)?Tracy/.test(html), html.slice(0,0));
  la('có ít nhất một thẻ mỗi nấc',
     /dbc-ng xong/.test(html) && /dbc-ng nhan/.test(html)
     && /dbc-ng choi/.test(html) && /dbc-ng chua/.test(html));
}

/* ── ③ ĐÃ XONG NẰM TRONG ĐÃ NHẬN ───────────────────────────────────────── */
{
  console.log('\n③ Đã dự xong vẫn được đếm là đã nhận · "cả buổi đã xong"');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('buổi Sản phẩm: cả hai người đã xong → "cả buổi đã xong"',
     /cả buổi đã xong/.test(html));
  la('và mẫu số vẫn là 2/2, không tụt xuống 0/2', /<b>2\/2<\/b>/.test(html));
  la('buổi coreteam: 1 trên 2 người xong → "1 đã dự xong"', /1 đã dự xong/.test(html));
  la('mẫu số coreteam là 2/5 (nhận trên tập người nhận lời mời)',
     /<b>2\/5<\/b>/.test(html), html.match(/<b>\d+\/\d+<\/b>/g).join(' '));
}

/* ── ④ KHÔNG ĐỌC ĐƯỢC ≠ KHÔNG AI XONG ──────────────────────────────────── */
{
  console.log('\n④ Chưa đọc được trạng thái xong thì NÓI THẬT, không bày ba nấc');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, null);
  la('nói thẳng là chưa đọc được', /chưa đọc được trạng thái đã dự xong/.test(html));
  /* Lời báo ấy là thứ DUY NHẤT còn lại của hàng cũ sau khi Tracy gỡ chú giải
     05/09 — nó không dịch nghĩa màu, nó thú nhận một chỗ chưa đọc được. */
  la('không thẻ tên nào mang nấc "đã dự xong"', !/dbc-ng xong/.test(html));
  la('không dòng nào báo "đã dự xong"', !/đã dự xong<\/em>/.test(html)
     && !/cả buổi đã xong/.test(html));
  la('ba nấc còn lại vẫn đủ trên thẻ tên',
     /dbc-ng nhan/.test(html) && /dbc-ng chua/.test(html));
}

/* ── ⑤ BUỔI MỜI ĐÍCH DANH: HIỆN Ở "MỌI KHỐI", GIẤU KHI LỌC MỘT NHÓM ────────
   Luật này đổi hai lần trong hai ngày, nên ghi rõ nó đang là gì:
     · 03/09 — giấu mọi lúc, vì bảng trả lời *"nhịp họp các phòng ban"*.
     · 04/09 — Tracy: *"nếu lọc là mọi khối thì tôi muốn hiện cả lịch hẹn riêng
       luôn — ý là tất cả các lịch luôn ý"*. Nên nay chỉ giấu khi đang lọc MỘT
       nhóm, và lúc ấy vẫn đếm để dòng cuối ngày nói ra số bị giấu.
   Mục này viết theo luật 03/09 và trượt im từ hôm sau — trong một tệp vốn đã
   không khởi động nổi, nên không ai thấy nó đỏ. */
{
  console.log('\n⑤ Buổi mời đích danh: hiện ở "Mọi khối", giấu khi lọc một nhóm');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('ở "Mọi khối" nó hiện tên thật', /Check in Peter Hafi/.test(html));
  la('nhãn đọc đúng tên trong ô chọn', /Mời người cụ thể/.test(html));
  la('không còn chữ "Hẹn riêng" — tên tôi tự đặt, Tracy bỏ 05/09',
     !/Hẹn riêng/.test(html));
  la('và không dựng dòng "còn thứ bị giấu"', !/dbc-an/.test(html));

  /* Lọc khối Sản phẩm: buổi ấy không khai cho khối nào nên nó rơi — nhưng phải
     nói ra, kèm đường mở lại. Giấu im lặng thì người điều hành tưởng giờ ấy
     trống. */
  const m2 = may(NAY, DOI5, CN, TRACY, 2);
  const h2 = m2.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('lọc một nhóm: buổi mời đích danh rơi khỏi bảng', !/Check in Peter Hafi/.test(h2));
  la('và số bị giấu được nói ra', /\+ 1 buổi mời người cụ thể/.test(h2));
  la('kèm đường mở lại', /chọn <b>Mọi khối<\/b> để xem/.test(h2));
}

/* ── ⑤b LỊCH CÁ NHÂN KHÔNG THUỘC MÀN NÀY (Tracy chốt 05/09) ────────────────
   *"trong bảng vận hành chỉ hiện lịch của rova thôi chứ"* · *"bạn cần phân
   biệt hẹn riêng với lịch cá nhân"*. Hai cột, hai câu hỏi: `rieng_tu` là ô
   Loại (*chuyện gì*), `pham_vi` là ô Đối tượng (*ai nhận*). Bài này ghim đúng
   chỗ hai cột ấy từng bị gộp làm một. */
{
  console.log('\n⑤b Lịch cá nhân rơi ở MỌI chế độ lọc, và không được đếm');
  const canh = () => {
    const d = daiBonBuoi();
    d.ds.push({id:5, ten:'Tennis', pham_vi:'ca_nhan', rieng_tu:true, nguoi_ids:['u2'],
               tao_boi:'u1', lap:'khong', ngay_bat_dau:NAY,
               gio_bat_dau:21*60, so_phut:120, dang_dung:true});
    return d;
  };
  const html = may(NAY, DOI5, CN, TRACY, 0).ve(canh(), '2026-08-31', '2026-09-06', AI, XONG);
  la('ở "Mọi khối" lịch cá nhân không lọt vào HTML', !/Tennis/.test(html));
  la('và không lọt ra dưới dạng "Bận"', !/>Bận</.test(html));
  la('nó KHÔNG được đếm — không dòng nào mời mở nó ra', !/dbc-an/.test(html));
  la('đầu bảng vẫn đếm 4 buổi, tennis đứng ngoài',
     /<b>4<\/b> buổi tuần này/.test(html));
  la('buổi mời đích danh vẫn ở lại — nó là việc của công ty',
     /Check in Peter Hafi/.test(html));

  const h2 = may(NAY, DOI5, CN, TRACY, 2).ve(canh(), '2026-08-31', '2026-09-06', AI, XONG);
  la('lọc một nhóm: lịch cá nhân vẫn không hiện', !/Tennis/.test(h2));
  la('và số bị giấu đếm ĐÚNG 1 — tennis không cộng vào',
     /\+ 1 buổi mời người cụ thể/.test(h2),
     (h2.match(/\+ \d+ buổi mời người cụ thể/) || ['(không thấy dòng)'])[0]);
}

/* ── ⑥ THẺ TÊN KHÔNG CÓ DẤU, CÓ ★ NGƯỜI TẠO ────────────────────────────── */
{
  console.log('\n⑥ Thẻ tên bỏ dấu ✓ ✕ · — giữ ★ người tạo');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const html = m.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('không còn dấu ✓', !/✓/.test(html));
  la('không còn dấu ✕', !/✕/.test(html));
  la('★ người tạo vẫn còn', /★/.test(html));
  /* Đếm ★ TRONG THẺ TÊN, không đếm mọi ★ trong trang: hàng chú giải cũng có
     một cái, và một phép đếm gộp thì sửa chú giải là bài thử đỏ oan. */
  la('★ chỉ đeo cho đúng người tạo, mỗi buổi một cái',
     (html.match(/<b title="Người tạo sự kiện">★<\/b>/g) || []).length === 4,
     'bốn buổi, bốn người tạo');
  la('tên người hiện đủ chữ', /Sydney/.test(html) && /Hafi/.test(html));
  /* CHÚ GIẢI GỠ 05/09, NHƯNG NGHĨA KHÔNG ĐƯỢC MẤT THEO. Tracy bỏ hai hàng dịch
     nghĩa màu (*"xóa luôn chú thích đi k cần đâu"*) — hợp lý, vì bảng này chỉ
     hai người mở và họ đọc nó mỗi ngày. Chỗ duy nhất còn nói tên bốn nấc bằng
     chữ là `title` của từng thẻ tên; mất nốt nó thì màu thành thứ tiếng không
     có từ điển. Ca này đứng gác đúng chỗ ấy. */
  la('tên bốn nấc vẫn đọc được — nay ở `title` của thẻ tên',
     /chưa trả lời/.test(html) && /đã nhận lời/.test(html)
     && /đã dự xong/.test(html) && /đã từ chối/.test(html));
  la('và không còn hàng chú giải nào trong bảng',
     !/dbc-tt-cg/.test(html) && !/★ người tạo/.test(html),
     'Tracy gỡ 05/09 — bày lại là dựng một hàng chữ không ai đọc nữa');
}

/* ── ⑦ BUỔI ĐÃ DỜI THEO NGÀY DIỄN RA (cùng bẫy TRI-79) ─────────────────── */
{
  console.log('\n⑦ Buổi đã dời gom vào ngày nó DIỄN RA, không ngày gốc');
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const d = {
    ds: [{id:9, ten:'Họp toàn công ty', pham_vi:'cong_ty', tao_boi:'u1', lap:'khong',
          ngay_bat_dau:'2026-08-31', gio_bat_dau:9*60, so_phut:60, dang_dung:true}],
    huy:{},
    doi:    {'9|2026-08-31': {lich_id:9, ngay_goc:'2026-08-31', kieu:'doi',
                              ngay_moi:'2026-09-03', gio_moi:14*60}},
    doiToi: {'9|2026-09-03': ['2026-08-31']},
    tick: {'9|2026-08-31': {nhan:1, ai:{u1:true}}}, gc:{}, tb:{}
  };
  const so = m.dbBuoiCuaDai(d, ['2026-08-31','2026-09-03'], AI, null);
  const cu9 = so.get('2026-08-31').ds, moi9 = so.get('2026-09-03').ds;
  /* TỪ TRI-85 NGÀY CŨ KHÔNG CÒN TRỐNG — nó giữ một BÓNG (Tracy chốt 03/09:
     *"lịch A bị dời lịch thì sẽ hiện ở cả ngày rời cũ lẫn ngày mới"*). Đây là
     chỗ ngược hẳn luật cũ, nên nếu ai gỡ cờ `bong` của `lcCuaNgayTu` thì bài
     thử phải kêu ngay — chứ không phải lặng lẽ về lại hành vi trước. */
  la('ngày gốc 31/08 giữ đúng một bóng', cu9.length === 1 && cu9[0].bong === true,
     'đếm được ' + cu9.length);
  la('bóng ấy chỉ đúng ngày nó đã dời tới', cu9[0] && cu9[0].ngayMoi === '2026-09-03');
  la('bóng đứng ở KHUNG GIỜ GỐC 09:00, không phải giờ mới 14:00',
     cu9[0] && cu9[0].tu === 9*60, 'đọc được ' + (cu9[0] && cu9[0].tu));
  la('ngày diễn ra 03/09 có đúng một buổi, và nó KHÔNG phải bóng',
     moi9.length === 1 && !moi9[0].bong);
  const html = m.ve(d, '2026-08-31', '2026-09-06', AI, null);
  la('bảng dựng khối cho CẢ HAI ngày',
     /Thứ năm 03\/09/.test(html) && /Thứ hai 31\/08/.test(html));
  la('dòng bóng đeo class riêng', /class="dbc-b bong"/.test(html));
  la('bóng nói rõ dời sang ngày nào', /dời sang T5 03\/09/.test(html));
  const khoiMoi = html.split('Thứ năm 03/09')[1] || '';
  la('khung giờ MỚI không mang một chữ nào về chuyện đã dời',
     !/⇢/.test(html) && !/dời/.test(khoiMoi),
     'Tracy chốt: *"ở khung giờ mới thì ko cần ghi lịch sử cũ đâu"*');
  la('dòng đầu ngày cũ ghi 0 buổi và đếm riêng 1 dời đi',
     /0 buổi · <em class="doi">1 dời đi<\/em>/.test(html));
  la('bóng không lọt vào con số tổng của tuần', /<b>1<\/b> buổi tuần này/.test(html));
  la('nhưng số buổi đã dời đi được nói ra', /<b>1<\/b> buổi đã dời đi/.test(html));
  la('ngày trống vẫn không dựng khối rỗng',
     (html.match(/class="dbc-ngay/g) || []).length === 2);
}

/* ── ⑨ TRẠNG THÁI CỦA BUỔI THEO Ô TICK CỦA HOST (TRI-85) ───────────────────
   Tracy 03/09: *"trạng thái của lịch thì thay đổi theo host tick là hoàn thành
   hay chưa"*. Ba chỗ dễ trượt, và cả ba đều dựng ra HTML trông bình thường:
   hỏi nhầm sang số đông người dự thay vì hỏi host · gắn nhãn cho buổi CHƯA
   diễn ra · và khẳng định "chưa xong" khi thật ra chưa đọc được sổ việc. */
{
  console.log('\n⑨ Trạng thái buổi theo ô tick của người chủ trì');
  const QUA = '2026-09-01', SAU = '2026-09-05';        /* NAY = 2026-09-03 */
  const m = may(NAY, DOI5, CN, TRACY, 0);
  const d = {
    ds: [
      {id:1, ten:'Họp đã chốt', pham_vi:'cong_ty', tao_boi:'u1', lap:'khong',
       ngay_bat_dau:QUA, gio_bat_dau:9*60, so_phut:60, dang_dung:true},
      {id:2, ten:'Họp chưa xong', pham_vi:'cong_ty', tao_boi:'u1', lap:'khong',
       ngay_bat_dau:QUA, gio_bat_dau:14*60, so_phut:60, dang_dung:true},
      {id:3, ten:'Họp tuần sau', pham_vi:'cong_ty', tao_boi:'u1', lap:'khong',
       ngay_bat_dau:SAU, gio_bat_dau:9*60, so_phut:60, dang_dung:true}
    ],
    huy:{}, doi:{}, doiToi:{},
    tick: {['1|'+QUA]: {nhan:2, ai:{u1:true, u2:true}},
           ['2|'+QUA]: {nhan:2, ai:{u1:true, u2:true}},
           ['3|'+SAU]: {nhan:1, ai:{u1:true}}},
    gc:{}, tb:{}
  };
  /* Buổi 1: host u1 đã xong. Buổi 2: u2 xong nhưng HOST THÌ CHƯA — đây đúng là
     ca phân biệt "hỏi host" với "hỏi số đông". */
  const XG = {['1|'+QUA]: new Set(['u1','u2']), ['2|'+QUA]: new Set(['u2'])};
  const html = m.ve(d, QUA, '2026-09-06', AI, XG);

  la('buổi host đã tick → tên buổi tô xanh', /class="dbc-b xong"/.test(html));
  la('và nó KHÔNG đeo thêm thẻ chữ nào',
     !/dbc-tt/.test(nut(html, 'Họp đã chốt')),
     'Tracy chốt: *"bỏ chữ đúng kế hoạch đi"*');
  la('buổi host chưa tick → thẻ "chưa xong", dù người khác đã xong',
     /class="dbc-tt chua">chưa xong</.test(nut(html, 'Họp chưa xong')),
     'hỏi số đông thay vì hỏi host là trượt ở đúng đây');
  la('và dòng ấy KHÔNG được tô xanh',
     !/class="dbc-b xong"/.test(nut(html, 'Họp chưa xong')));
  la('chỉ MỘT dòng được tô xanh, không phải cả hai',
     (html.match(/class="dbc-b xong"/g) || []).length === 1);
  const sau = nut(html, 'Họp tuần sau');
  la('buổi tuần sau chưa có nhãn nào — không tô xanh, không thẻ',
     !!sau && !/dbc-b xong/.test(sau) && !/dbc-tt/.test(sau),
     'gắn nhãn cho buổi chưa diễn ra là nói trước một điều chưa biết');
  la('dòng đầu ngày đếm đúng một xong một chưa',
     /2 buổi · <em class="dung">1 đúng kế hoạch<\/em> · <em class="chua">1 chưa xong<\/em>/.test(html));
  la('KHÔNG dựng hàng chú giải cho trạng thái buổi (Tracy gỡ 05/09)',
     !/dbc-tt-cg/.test(html) && !/theo ô tick của người chủ trì/.test(html));

  /* CHƯA ĐỌC ĐƯỢC ≠ CHƯA AI CHỐT. Cùng cái bẫy bài thử ④ đã canh cho nấc "đã
     dự xong", nay lặp lại một tầng trên: sổ về `null` thì phải im, không được
     dán "chưa xong" lên mọi buổi đã qua — nó sai đúng về phía làm người điều
     hành tưởng cả đội bỏ bê. */
  const h2 = m.ve(d, QUA, '2026-09-06', AI, null);
  la('sổ việc chưa đọc được → không dán nhãn nào lên buổi đã qua',
     !/class="dbc-tt"/.test(h2) && !/class="dbc-b xong"/.test(h2));
  la('và lúc ấy vẫn nói thẳng là chưa đọc được',
     /chưa đọc được trạng thái đã dự xong/.test(h2));
  la('dòng đầu ngày lúc ấy chỉ còn con số tổng',
     /class="dbc-dem">2 buổi<\/span>/.test(h2));
}

/* ── ⑧ CỜ GÁC VÀ LỌC KHỐI ──────────────────────────────────────────────── */
{
  console.log('\n⑧ Cờ điều hành · lọc khối');
  la('người có cờ ở chế độ chung → vhCheDo() giữ "chung"',
     may(NAY, DOI5, CN, TRACY, 0).vhCheDo() === 'chung');
  la('người KHÔNG cờ → lùi về "ranh", dù biến chế độ đã bị đặt',
     may(NAY, DOI5, CN, PETER, 0).vhCheDo() === 'ranh',
     'một cái nút ẩn không phải hàng rào');
  la('ME thiếu trường la_dieu_hanh → không ngã, trả false',
     may(NAY, DOI5, CN, {id:'u9', ten:'X'}, 0).laDieuHanh() === false);

  const m2 = may(NAY, DOI5, CN, TRACY, 2);      /* lọc khối Sản phẩm */
  const html = m2.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG);
  la('lọc Sản phẩm: giữ buổi Sprint review', /Sprint review sản phẩm/.test(html));
  la('lọc Sản phẩm: bỏ buổi Kinh doanh', !/Chốt số kinh doanh/.test(html));
  la('buổi cả công ty vẫn ở lại — mọi khối đều phải thấy',
     /Check in coreteam/.test(html),
     'lọc theo phạm vi buổi thì buổi cả công ty rơi khỏi mọi khối');
  const m3 = may(NAY, DOI5, CN, TRACY, 9);      /* khối không có ai */
  la('khối chưa có ai → nói thẳng, không bày bảng rỗng',
     /chưa có ai trong team/.test(m3.ve(daiBonBuoi(), '2026-08-31', '2026-09-06', AI, XONG)));
}

console.log(truot ? `\n❌ ${dat} ca đạt, ${truot} ca trượt.` : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
