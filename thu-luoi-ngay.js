/* THỬ: LƯỚI NGÀY — hai khung nhìn "7 ngày" và "Tháng" (TRI-119)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09: *"bổ sung thêm cả view 7 ngày + view tháng để tôi còn check lịch
   cố định toàn bộ rova cho dễ"*, và ngay sau đó: *"hiện hết cho tôi nhé"*.

   Những ca đáng giá nhất — đều là chỗ thử tay từng bước KHÔNG lộ ra:

     · DẢI CỦA LƯỚI THÁNG mở bằng thứ Hai và đóng bằng Chủ nhật. Cắt đúng ngày
       1 và ngày cuối thì lưới vẫn dựng ra, trông vẫn như một cuốn lịch — chỉ
       là mọi cột lệch khỏi tên thứ trên đầu nó, và không gì báo.

     · BƯỚC THÁNG TỪ NGÀY 31. Neo ở 31/01 mà cộng một tháng thì tháng Hai không
       có ngày 31, và trình duyệt lặng lẽ đẩy sang 02/03 — nhảy hai tháng trong
       một cú bấm.

     · TRẦN SỐ NGÀY. Trần cũ là 14, dựng cho hai bảng tuần. Lưới tháng dài tới
       42 ô, và trần cũ cắt cụt trong im lặng: mũ đủ bảy cột, thân thiếu quá
       nửa, không một dòng lỗi nào.

     · HIỆN HẾT BUỔI. Ô ngày không có trần; năm buổi một ngày phải ra năm thẻ.

     · CON SỐ TÓM TẮT chỉ đếm ngày THUỘC tháng đang xem. Ngày mượn của tháng
       bên cạnh vẫn vẽ cho lưới vuông vắn, nhưng cộng chúng vào là câu "37 buổi
       tháng này" nói về một dải không ai hỏi.

     · BÓNG Ở NGÀY CŨ không mang con số đã nhận — ô tham dự của nó chính là ô
       của buổi thật, đếm ở cả hai chỗ là đếm một câu trả lời hai lần.

   Chạy:  node production/tinh-thuc-app/thu-luoi-ngay.js
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
function catDong(dau){
  const i = SRC.indexOf(dau);
  if (i < 0) throw new Error('Khong thay dong: ' + dau);
  return SRC.slice(i, SRC.indexOf('\n', i));
}

/* Cắt đúng MỘT ô ngày ra khỏi lưới — đo trên cả lưới là đo nhầm, vì hàng chú
   giải cuối màn dựng bằng chính những mảnh ấy. */
function oNgay(html, thu){
  const moc = html.split('<span class="dbg-o');
  return moc[thu] ? '<span class="dbg-o' + moc[thu] : '';
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── MÁY CHẠY THẬT ────────────────────────────────────────────────────────── */
const KHOI_LICH = catKhoi('const LC_TEN_THU =', '/* Luật lặp có nổ vào ngày này không');
const KHOI_DB   = catKhoi("let DB_CHE_DO = '", '/* Bản đồ người → cờ bận');
const HANG_SO   = catKhoi('const LCR_TU = 8*60', 'let LC_RANH_LUOT');
const NHAN_NAC  = catKhoi('const DB_NHAN_NAC =', '/* Mọi buổi của một dải');
const D2S       = catDong('const d2s = d =>');
/* Trần xem trước — `vhXaQua` đọc nó. Cắt từ mã thật chứ không chép số 60
   vào đây: chép là bài thử vẫn xanh nguyên sau ngày ai đó nới trần. */
const TRAN      = catDong('const TL_TRAN_TOI =');

function may(NAY, DOI, CHUC_NANG, ME, khoi, che, neo){
  return new Function('NAY','DOI','CHUC_NANG','ME','KHOI','CHE','NEO', `
    const homNay = () => NAY;
    let LC_HIEN = null, LC_VIEC = {};
    const TQ_THU = ['Chủ nhật','Thứ hai','Thứ ba','Thứ tư','Thứ năm','Thứ sáu','Thứ bảy'];
    const chuSach = s => String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
    const tlgHHMM = p => String(Math.floor(p/60)).padStart(2,'0')+':'+String(p%60).padStart(2,'0');
    const mauSuKien = l => '';
    const mauViec   = t => '';
    const lcDuocSua = l => true;
    let THE_THU = {};
    let GHI = '';
    const document = {getElementById: () => ({set innerHTML(v){ GHI = v; }, get innerHTML(){ return GHI; }})};
    ${D2S}
    ${TRAN}
    ${catHam('thuHai')}
    ${HANG_SO}
    ${KHOI_LICH}
    ${catHam('lcNgayDich')}
    ${catHam('lcHopBuoc')}
    ${catHam('lcHopNgay')}
    ${catHam('lcLuot')}
    ${catHam('lcCuaNgayTu')}
    ${KHOI_DB}
    DB_CHE_DO = CHE; DB_KHOI = KHOI; VH_NGAY = NEO || '';
    ${catHam('dbLocNguoi')}
    ${catHam('dbLocBuoi')}
    ${catHam('dbLoiTrong')}
    ${catHam('dbTenBuoi')}
    ${catHam('dbBayNgay')}
    ${catKhoi('const dbNhanBuoi', '/* Bảy ngày của một tuần')}
    ${catHam('dbBuoiCuaLuot')}
    ${catHam('dbNacCuaNguoi')}
    ${NHAN_NAC}
    ${catHam('dbBuoiCuaDai')}
    ${catHam('dbTheThang')}
    ${catHam('dbVeThang')}
    ${catHam('tlgXepLan')}
    ${catDong('const TLG_THU =')}
    ${catHam('dbKhoiGio')}
    ${catHam('dbVeGio')}
    return {vhCheDo, vhMoc, vhLuoiThang, vhNgaySauBuoc, vhXaQua, dbBayNgay,
            ve: (d, tu, den, ai, xong, kieu) => {
              (kieu === 'tuan' ? dbVeGio : dbVeThang)('x', d, tu, den, ai, xong);
              return GHI; }};`
  )(NAY, DOI, CHUC_NANG, ME, khoi || 0, che || 'thang', neo || '');
}

const NAY = '2026-09-03';                       /* thứ Năm */
const CN  = [{id:1,ten:'Vận hành'},{id:2,ten:'Sản phẩm'},{id:3,ten:'Kinh doanh'}];
const DOI5 = [
  {id:'u1', ten:'Tracy',  la_lead:true, chuc_nang_ids:[1], thu_tu:1, la_dieu_hanh:true},
  {id:'u2', ten:'Andy',   la_lead:true, chuc_nang_ids:[1], thu_tu:2, la_dieu_hanh:true},
  {id:'u3', ten:'Peter',  la_lead:true, chuc_nang_ids:[2], thu_tu:3},
  {id:'u4', ten:'Hafi',   la_lead:true, chuc_nang_ids:[2], thu_tu:4},
  {id:'u5', ten:'Sydney', la_lead:true, chuc_nang_ids:[3], thu_tu:5}
];
const TRACY = DOI5[0];
const AI = DOI5.map(x => x.id);
const buoi = (id, ten, ngay, gio, pv, them) => Object.assign(
  {id, ten, pham_vi: pv || 'cong_ty', tao_boi:'u1', lap:'khong',
   ngay_bat_dau: ngay, gio_bat_dau: gio, so_phut: 60, dang_dung: true}, them || {});

/* ── ① DẢI CỦA LƯỚI THÁNG ────────────────────────────────────────────────── */
{
  console.log('① Dải lưới tháng mở bằng thứ Hai, đóng bằng Chủ nhật');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  const t9 = m.vhLuoiThang('2026-09-03');
  la('tháng 9/2026 → 31/08 (T2) đến 04/10 (CN)',
     t9.tu === '2026-08-31' && t9.den === '2026-10-04', JSON.stringify(t9));
  la('và nó tự khai đúng tháng đang xem', t9.thang === 9 && t9.nam === 2026);
  /* 01/06/2026 rơi đúng thứ Hai — lưới không được mượn thêm một hàng của tháng
     Năm chỉ vì cách tính lười. */
  const t6 = m.vhLuoiThang('2026-06-15');
  la('tháng mở đúng thứ Hai thì không mượn hàng thừa', t6.tu === '2026-06-01', t6.tu);
  /* Tháng Hai năm nhuận: 29 ngày, và lưới vẫn phải ôm trọn cả ngày 1 lẫn 29. */
  const t2 = m.vhLuoiThang('2028-02-10');
  la('tháng 2 năm nhuận vẫn ôm trọn cả ngày 1 lẫn ngày 29',
     t2.tu <= '2028-02-01' && t2.den >= '2028-02-29', JSON.stringify(t2));
  const dem = (t2.den && t2.tu)
    ? Math.round((new Date(t2.den) - new Date(t2.tu)) / 86400000) + 1 : 0;
  la('dải luôn chia hết cho 7', dem % 7 === 0, 'đếm được ' + dem + ' ngày');
  la('vhMoc ở chế độ tháng trả đúng dải ấy',
     m.vhMoc().tu === '2026-08-31' && m.vhMoc().den === '2026-10-04');
}

/* ── ② BƯỚC THEO THÁNG, KHÔNG CỘNG NGÀY ──────────────────────────────────── */
{
  console.log('\n② Bước tháng · bước tuần · bước ngày');
  const d2s = d => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
  /* Cái bẫy chính: neo ở 31/01 mà cộng một tháng thì tháng Hai không có ngày
     31, và trình duyệt đẩy tiếp sang tháng Ba. */
  const m31 = may(NAY, DOI5, CN, TRACY, 0, 'thang', '2026-01-31');
  la('tháng: 31/01 bước tới → 01/02, không trượt sang tháng Ba',
     d2s(m31.vhNgaySauBuoc(1)) === '2026-02-01', d2s(m31.vhNgaySauBuoc(1)));
  const mt = may(NAY, DOI5, CN, TRACY, 0, 'thang', '2026-09-03');
  la('tháng: bước lùi về đúng 01/08', d2s(mt.vhNgaySauBuoc(-1)) === '2026-08-01');
  const mw = may(NAY, DOI5, CN, TRACY, 0, 'chung', '2026-09-03');
  la('tuần: vẫn bước bảy ngày', d2s(mw.vhNgaySauBuoc(1)) === '2026-09-10');
  const mr = may(NAY, DOI5, CN, TRACY, 0, 'ranh', '2026-09-03');
  la('giờ rảnh: vẫn bước một ngày', d2s(mr.vhNgaySauBuoc(1)) === '2026-09-04');
  /* Nút › phải tắt đúng khi CHÂN TIẾP THEO bị trần chặn, không phải khi chỗ
     đang đứng bị chặn — nút sáng mà bấm không đi là một nút chết câm. */
  /* Trần là 60 ngày kể từ hôm nay (03/09), nên đứng ở tháng 11 mà bước tiếp là
     tới 01/12 — 89 ngày, quá trần. Đứng ở tháng 10 thì chân tiếp theo là 01/11,
     mới 59 ngày, vẫn đi được: nút phải còn sáng ở đó. */
  const mxa = may(NAY, DOI5, CN, TRACY, 0, 'thang', '2026-11-01');
  la('chế độ tháng: bước tới vượt trần 60 ngày thì nút › tắt sẵn', mxa.vhXaQua() === true);
  la('tháng cuối cùng còn đi được thì nút vẫn mở',
     may(NAY, DOI5, CN, TRACY, 0, 'thang', '2026-10-01').vhXaQua() === false);
  la('còn ở tháng 9 thì nút › vẫn mở', mt.vhXaQua() === false);
}

/* ── ③ TRẦN SỐ NGÀY CỦA MỘT DẢI ──────────────────────────────────────────── */
{
  console.log('\n③ Trần số ngày đủ cho một lưới tháng');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  la('dải 35 ngày trả đủ 35', m.dbBayNgay('2026-08-31','2026-10-04').length === 35,
     'đếm được ' + m.dbBayNgay('2026-08-31','2026-10-04').length);
  la('dải 42 ngày trả đủ 42', m.dbBayNgay('2026-08-31','2026-10-11').length === 42);
  la('vẫn còn trần: dải 60 ngày dừng ở 42',
     m.dbBayNgay('2026-08-31','2026-10-29').length === 42);
}

/* ── ④ LƯỚI THÁNG DỰNG ĐÚNG HÌNH ─────────────────────────────────────────── */
{
  console.log('\n④ Lưới tháng: bảy mũ thứ, 35 ô ngày, ngày mượn làm nhạt');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  const d = {ds: [buoi(1,'Kick off đầu tuần','2026-09-07',9*60+30)],
             huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-10-04', AI, {}, 'thang');
  la('đúng bảy ô mũ', (html.match(/class="dbg-mu/g) || []).length === 7,
     'đếm được ' + (html.match(/class="dbg-mu/g) || []).length);
  la('mũ đề tên thứ, mở đầu bằng T2', html.indexOf('>T2<') < html.indexOf('>T3<'));
  la('đúng 35 ô ngày', (html.match(/class="dbg-o/g) || []).length === 35,
     'đếm được ' + (html.match(/class="dbg-o/g) || []).length);
  la('ngày mượn của tháng bên cạnh được làm nhạt',
     (html.match(/dbg-o[^"]*ngoai/g) || []).length === 5,
     'đếm được ' + (html.match(/dbg-o[^"]*ngoai/g) || []).length + ' — chờ 1 của tháng 8 và 4 của tháng 10');
  la('ô hôm nay được đánh dấu', /dbg-o nay|dbg-o[^"]* nay/.test(html));
  la('ngày 1 mang thêm số tháng của nó', /dbg-ngay">1\/9</.test(html)
                                      && /dbg-ngay">1\/10</.test(html));
  la('các ngày khác chỉ mang số ngày', /dbg-ngay">7</.test(html));
  la('buổi nằm đúng ô ngày 07/09', /dbg-ngay">7<[\s\S]{0,400}Kick off đầu tuần/.test(html));
}

/* ── ⑤ HIỆN HẾT BUỔI, KHÔNG CẮT BỚT ──────────────────────────────────────── */
{
  console.log('\n⑤ Một ngày năm buổi thì ra đủ năm thẻ');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  const ds = [];
  for (let i = 0; i < 5; i++) ds.push(buoi(i+1, 'Buổi số ' + (i+1), '2026-09-07', 8*60 + i*60));
  const html = m.ve({ds, huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}},
                    '2026-08-31', '2026-10-04', AI, {}, 'thang');
  const o = oNgay(html, 8);                       /* ô thứ 8 của lưới = 07/09 */
  la('ô ngày ấy mang đủ năm thẻ', (o.match(/class="dbg-b/g) || []).length === 5,
     'đếm được ' + (o.match(/class="dbg-b/g) || []).length);
  la('không dòng "còn N nữa" nào', !/còn \d+ nữa|\+\d+ buổi/.test(html));
  la('thẻ xếp theo giờ tăng dần', o.indexOf('Buổi số 1') < o.indexOf('Buổi số 5'));
}

/* ── ⑥ LƯỚI GIỜ BẢY NGÀY ─────────────────────────────────────────────────── */
{
  console.log('\n⑥ Lưới 7 ngày: trục giờ, khối đặt đúng chỗ, cao theo thời lượng');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'tuan');
  const d = {ds: [buoi(1,'Check in coreteam', NAY, 9*60+30, 'coreteam', {so_phut:180})],
             huy:{}, doi:{}, doiToi:{},
             tick: {['1|'+NAY]: {nhan:2, ai:{u1:true, u2:true}}}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('có máng giờ, mở ở 7h', /dbt-nhan-gio">7h</.test(html), 'dải mặc định 7h–22h');
  la('và chạy tới 21h', /dbt-nhan-gio">21h</.test(html));
  la('bảy cột ngày', (html.match(/class="dbt-cot/g) || []).length === 7,
     'đếm được ' + (html.match(/class="dbt-cot/g) || []).length);
  la('hàng đầu đề thứ và ngày', /dbt-ten-ngay[^>]*>T2<b>31\/08<\/b>/.test(html),
     (html.match(/dbt-ten-ngay[^<]*<[^<]*<\/b>/) || [''])[0]);
  la('cột hôm nay được tô', /dbt-cot hom/.test(html) && /dbt-ten-ngay hom/.test(html));
  /* 09:30 với dải mở ở 7h → cách đỉnh lưới 2,5 giờ; dài 180 phút → cao 3 giờ.
     Ghim CẢ HAI con số: sai chỗ đứng và sai chiều cao là hai lỗi khác nhau, mà
     mắt nhìn một lưới thưa thì cái nào cũng "trông cũng hợp lý". */
  la('khối đặt đúng 2,5 giờ tính từ đỉnh lưới', /top:calc\(2\.5 \* var\(--tlg-h\)\)/.test(html),
     (html.match(/top:calc\([^)]*\)/) || [''])[0]);
  la('và cao đúng ba giờ', /height:calc\(3 \* var\(--tlg-h\) - 2px\)/.test(html),
     (html.match(/height:calc\([^)]*\)[^"]*/) || [''])[0]);
  la('khối bấm được, mở đúng buổi', /onclick="lcMoBuoi\(1, '2026-09-03'\)/.test(html));
  /* Ba nấc cỡ khối quyết định bày được mấy dòng chữ. Khối ba giờ mang `cao` để
     tên được bốn dòng — trên cột hẹp 90px thì một tên như "[Mr. Trung] Đào tạo
     nội bộ" cần đúng ngần ấy, và cắt ở dòng hai là bỏ mất nửa sau. */
  la('khối ba giờ mang nấc "cao"', /class="dbt-k[^"]* cao"/.test(html),
     (html.match(/class="dbt-k[^"]*"/) || [''])[0]);
  la('khối mang tên nhóm nhận và con số đã nhận',
     /dbt-phu">Coreteam<em[^>]*>2\/5<\/em>/.test(html),
     (html.match(/dbt-phu"[\s\S]{0,60}/) || [''])[0]);
  /* Nấc này CHỈ ĐỌC: không ô nào mời chạm để thêm việc, không tay nắm nới mép.
     Một cửa hứa mà không mở được còn tệ hơn không có cửa. */
  la('không ô giờ nào bấm được', !/dbt-o[^>]*onclick/.test(html));
  la('không mượn tên lớp của timeline — bộ kéo–thả không bắt nhầm',
     !/class="tlg-cot/.test(html) && !/data-ngay=/.test(html));
  la('tuần có hôm nay thì có vạch giờ hiện tại', /dbt-baygio/.test(html));
  la('tuần khác thì không có vạch ấy',
     !/dbt-baygio/.test(m.ve(d, '2026-09-07', '2026-09-13', AI, {}, 'tuan')));
}

/* ── ⑥b DẢI GIỜ TỰ CO, VÀ HAI BUỔI TRÙNG GIỜ CHIA BỀ NGANG ───────────────── */
{
  console.log('\n⑥b Dải giờ tự co · buổi trùng giờ chia đôi cột');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'tuan');
  /* Một buổi 6:00 kéo đỉnh lưới lên trước 7h; một buổi kết thúc 23:00 kéo đáy
     xuống. Trải cứng 0h–24h thì hai phần ba lưới là khoảng trống giấc ngủ. */
  const som = {ds: [buoi(1,'Chạy bộ sớm', NAY, 6*60, 'cong_ty', {so_phut:60}),
                    buoi(2,'Trực khuya', NAY, 22*60, 'cong_ty', {so_phut:60})],
               huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const h2 = m.ve(som, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('buổi 6h kéo đỉnh lưới lên 6h', /dbt-nhan-gio">6h</.test(h2));
  la('buổi tới 23h kéo đáy lưới xuống', /dbt-nhan-gio">22h</.test(h2));
  la('và khối 6h nằm sát đỉnh', /top:calc\(0 \* var\(--tlg-h\)\)/.test(h2));

  /* Ba buổi cùng 09:30 — đúng cảnh Tracy nêu khi dựng bảng Danh sách. Ở lưới
     giờ chúng phải đứng CẠNH nhau chia đều bề ngang, không đè lên nhau. */
  const ba = {ds: [buoi(1,'Coreteam', NAY, 9*60+30,'cong_ty',{so_phut:60}),
                   buoi(2,'Sản phẩm', NAY, 9*60+30,'khoi',{so_phut:60,chuc_nang_ids:[2]}),
                   buoi(3,'Kinh doanh', NAY, 9*60+30,'khoi',{so_phut:60,chuc_nang_ids:[3]})],
              huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const h3 = m.ve(ba, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  const rong = [...h3.matchAll(/width:calc\(([\d.]+)% - 3px\)/g)].map(x => Number(x[1]));
  la('ba buổi trùng giờ, mỗi cái một phần ba bề ngang',
     rong.length === 3 && rong.every(x => Math.abs(x - 100/3) < 0.01), JSON.stringify(rong));
  const trai = [...h3.matchAll(/left:([\d.]+)%/g)].map(x => Number(x[1]));
  la('và ba chỗ đứng khác nhau, không chồng lên nhau',
     new Set(trai).size === 3, JSON.stringify(trai));
  /* Buổi rời rạc trong cùng ngày KHÔNG bị kéo vào cụm: `tlgXepLan` tái dùng làn
     đã trống, nên hai buổi không chạm nhau vẫn được trọn bề ngang. */
  const roi = {ds: [buoi(1,'Sáng', NAY, 9*60,'cong_ty',{so_phut:60}),
                    buoi(2,'Chiều', NAY, 15*60,'cong_ty',{so_phut:60})],
               huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const h4 = m.ve(roi, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('hai buổi không chạm nhau thì mỗi cái vẫn trọn bề ngang',
     [...h4.matchAll(/width:calc\(([\d.]+)% - 3px\)/g)].every(x => Number(x[1]) === 100));
}

/* ── ⑦ CON SỐ TÓM TẮT CHỈ ĐẾM NGÀY TRONG THÁNG ───────────────────────────── */
{
  console.log('\n⑦ Tóm tắt tháng bỏ qua ngày mượn của tháng bên cạnh');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  const d = {ds: [buoi(1,'Buổi tháng Tám','2026-08-31',9*60),
                  buoi(2,'Buổi tháng Chín','2026-09-07',9*60)],
             huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-10-04', AI, {}, 'thang');
  la('dòng tóm tắt đếm 1 buổi, không phải 2', /<b>1<\/b> buổi tháng này/.test(html),
     (html.match(/dbg-tom[\s\S]{0,140}/) || [''])[0]);
  la('nhưng buổi 31/08 vẫn được VẼ ra trong ô của nó',
     /Buổi tháng Tám/.test(html), 'ngày mượn vẫn phải bày, chỉ không đếm');
}

/* ── ⑧ BÓNG Ở NGÀY CŨ ────────────────────────────────────────────────────── */
{
  console.log('\n⑧ Buổi đã dời: bóng ở ngày cũ, không mang con số');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'tuan');
  const d = {ds: [buoi(1,'Họp tổng kết', '2026-09-01', 9*60)],
             huy:{},
             doi: {['1|2026-09-01']: {ngay_moi:'2026-09-03', gio_moi:null}},
             doiToi: {'1|2026-09-03': ['2026-09-01']},
             tick: {['1|2026-09-01']: {nhan:3, ai:{u1:true,u2:true,u3:true}}}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('có đúng một khối bóng', (html.match(/class="dbt-k bong/g) || []).length === 1,
     'đếm được ' + (html.match(/class="dbt-k bong/g) || []).length);
  la('bóng nói nó dời đi đâu', /dbt-phu">dời sang/.test(html));
  const bong = (html.match(/<button[^>]*dbt-k bong[\s\S]*?<\/button>/) || [''])[0];
  la('và bóng KHÔNG mang con số đã nhận', !/<em/.test(bong));
  la('buổi thật hiện ở ngày mới', /Họp tổng kết[\s\S]*Họp tổng kết/.test(html)
     || (html.match(/Họp tổng kết/g) || []).length === 2);
}

/* ── ⑨ CHẠM MỘT THẺ MỞ ĐÚNG BUỔI ẤY ──────────────────────────────────────── */
{
  console.log('\n⑨ Chạm thẻ mở đúng buổi, bằng NGÀY GỐC của luật lặp');
  const m = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  /* Lịch lặp hằng tuần: ngày gốc là 07/09, và mọi lượt sau đều mang khoá ấy —
     truyền ngày của Ô thì cửa buổi tra không ra và trả về "không tìm thấy". */
  const d = {ds: [buoi(1,'Kick off đầu tuần','2026-09-07',9*60+30,'cong_ty',
                       {lap:'tuan', thu:[1]})],
             huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-10-04', AI, {}, 'thang');
  la('mọi thẻ đều bấm được', /onclick="lcMoBuoi\(1, '/.test(html));
  la('lượt 14/09 mang ngày gốc của chính nó', /lcMoBuoi\(1, '2026-09-14'\)/.test(html),
     'luật lặp sinh mỗi lượt một ngày gốc riêng');
  la('lịch lặp ra đủ bốn lượt trong tháng',
     (html.match(/onclick="lcMoBuoi\(1, /g) || []).length === 4,
     'đếm được ' + (html.match(/onclick="lcMoBuoi\(1, /g) || []).length);
}

/* ── ⑩ HẸN MỜI ĐÍCH DANH BỊ ẨN KHI LỌC MỘT KHỐI ─────────────────────────── */
{
  console.log('\n⑩ Lọc một khối: hẹn mời đích danh bị ẩn nhưng phải được đếm');
  const m = may(NAY, DOI5, CN, TRACY, 2, 'tuan');     /* lọc khối Sản phẩm */
  const d = {ds: [buoi(1,'Check in Peter Hafi', NAY, 11*60, 'ca_nhan', {nguoi_ids:['u4']}),
                  buoi(2,'Sprint review', NAY, 9*60, 'khoi', {chuc_nang_ids:[2]})],
             huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const html = m.ve(d, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('buổi của khối vẫn ở lại', /Sprint review/.test(html));
  la('hẹn mời đích danh bị giấu', !/Check in Peter Hafi/.test(html));
  la('nhưng lưới nói ra có một buổi bị giấu', /dbg-an[^>]*>\+1 buổi mời người cụ thể/.test(html),
     'giấu im lặng thì tuần ấy trông trống hơn thực tế');
}

/* ── ⑪ NÉT ĐỨT = CHƯA CHỐT, MỘT DẤU MỘT NGHĨA ───────────────────────────────
   Luật gốc 03/09 (TRI-71): *"deepwork bỏ nét đứt đi, nét đứt mang ý nghĩa là dự
   kiến"*. Tracy nhắc lại 05/09 khi bản đầu của hai lưới này mượn nét đứt cho
   "đã dời": *"dời đi thì màu xám nét liền còn dự kiến thì nét đứt, đã thống
   nhất r mà"*. Ca này ghim cả hai vế, và ghim luôn ở tầng CSS — vì cách hỏng
   dễ nhất là ai đó thêm một `border-style:dashed` cho một nghĩa thứ ba. */
{
  console.log('\n⑪ Nét đứt chỉ nói "chưa chốt" · đã dời thì xám nét liền');
  const mt = may(NAY, DOI5, CN, TRACY, 0, 'tuan');
  const dk = {ds: [buoi(1,'Họp còn dự kiến', NAY, 9*60, 'cong_ty', {da_chot:false}),
                   buoi(2,'Họp đã chốt',     NAY, 14*60,'cong_ty', {da_chot:true})],
              huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const h = mt.ve(dk, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('buổi còn dự kiến mang dấu `chua-chot`', /class="dbt-k[^"]*chua-chot/.test(h),
     (h.match(/class="dbt-k[^"]*"/g) || []).join(' | '));
  la('và chỉ MỘT trong hai buổi mang nó',
     (h.match(/class="dbt-k[^"]*chua-chot/g) || []).length === 1);

  /* Đã dự xong thì thôi mang dấu — *"uầy đã dự xong thì làm gì còn dự kiến
     nữa?"* (Tracy 03/09). Host là u1, và sổ `xong` nói u1 đã xong. */
  const hx = mt.ve(dk, '2026-08-31', '2026-09-06', AI,
                   {['1|'+NAY]: new Set(['u1'])}, 'tuan');
  la('buổi đã dự xong thì thôi mang dấu, dù cột chốt vẫn false',
     !/class="dbt-k[^"]*chua-chot/.test(hx),
     (hx.match(/class="dbt-k[^"]*"/g) || []).join(' | '));

  const doiDi = {ds: [buoi(1,'Họp tổng kết', '2026-09-01', 9*60, 'cong_ty', {da_chot:false})],
                 huy:{},
                 doi: {'1|2026-09-01': {ngay_moi:'2026-09-03', gio_moi:null}},
                 doiToi: {'1|2026-09-03': ['2026-09-01']},
                 tick:{}, gc:{}, tb:{}};
  const hd = mt.ve(doiDi, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  const bong = (hd.match(/<button[^>]*dbt-k bong[^"]*"/) || [''])[0];
  la('bóng của buổi đã dời KHÔNG mang dấu chưa chốt', !/chua-chot/.test(bong), bong);

  /* Lưới tháng đi cùng một luật — hai bảng nói hai thứ tiếng là chỗ người đọc
     phải học hai lần cho một dấu. */
  const mm = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  const hm = mm.ve(dk, '2026-08-31', '2026-10-04', AI, {}, 'thang');
  la('lưới tháng cũng đánh dấu buổi còn dự kiến', /class="dbg-b[^"]*chua-chot/.test(hm));

  /* Tầng CSS: hai lưới mới không được dùng `dashed` cho bất cứ nghĩa nào khác,
     và "đã dời" phải là XÁM nét liền. */
  /* Mốc đầu kèm luôn khai báo đầu tiên: `.dbt{` trơ có BA bản, và hai bản kia
     nằm gọn trong hai `@media` bên trong chính vùng này — nay nói rõ lấy bản
     gốc thay vì trông vào việc nó tình cờ đứng trước. Mốc cuối dò TỪ SAU mốc
     đầu (bẫy TRI-132, xem DANG-LAM.md). */
  const D_DBT = '.dbt{--tlg-h:38px';
  const css = SRC.slice(SRC.indexOf(D_DBT), SRC.indexOf('.db-trong{', SRC.indexOf(D_DBT)));
  la('không lớp nào của hai lưới mượn nét đứt cho nghĩa khác',
     !/dashed/.test(css.replace(/\.db[tg]-[a-z-]*\.?chua-chot\{[^}]*\}/g, '')
                       .replace(/\.dbg-cg-dk\{[^}]*\}/g, '')),
     'nét đứt chỉ được nói "chưa chốt"');
  la('"đã dời" tô xám bằng nét LIỀN',
     /\.dbt-k\.bong\{border-left-color:var\(--dim2\)/.test(css)
     && /\.dbg-b\.bong\{border-left-color:var\(--dim2\)/.test(css));
  la('dấu chưa chốt vẽ bằng `outline`, không giành `border` với màu trạng thái',
     /\.dbt-k\.chua-chot\{outline:1px dashed/.test(css));
}

/* ── ⑫ KHÔNG HÀNG CHÚ GIẢI, TRỪ LỜI THÚ THẬT ────────────────────────────────
   Tracy 05/09, cầm ảnh bảng Lịch chung: *"xóa luôn chú thích đi k cần đâu"*.
   Hai lưới này đứng cùng màn với bảng ấy nên đi cùng luật. Nghĩa của mấy cái
   dấu không mất theo — nó nằm trong `title` của từng khối. */
{
  console.log('\n⑫ Không hàng chú giải · giữ lời báo khi chưa đọc được sổ việc xong');
  const mt = may(NAY, DOI5, CN, TRACY, 0, 'tuan');
  const d = {ds: [buoi(1,'Check in coreteam', NAY, 9*60+30, 'coreteam', {so_phut:180})],
             huy:{}, doi:{}, doiToi:{}, tick:{}, gc:{}, tb:{}};
  const h = mt.ve(d, '2026-08-31', '2026-09-06', AI, {}, 'tuan');
  la('lưới 7 ngày không còn hàng chú giải', !/dbg-cg-ten|dbg-cg-dk/.test(h)
     && !/có ghi chú · khối/.test(h), (h.match(/dbg-cg[\s\S]{0,120}/) || [''])[0]);
  /* Nghĩa phải còn chỗ để tra: mất `title` thì màu và nét thành thứ tiếng
     không có từ điển. */
  la('nhưng mỗi khối vẫn kể đủ chuyện trong `title`',
     /title="[^"]*Check in coreteam[^"]*09:30–12:30[^"]*Coreteam[^"]*đã nhận/.test(h));
  const mm = may(NAY, DOI5, CN, TRACY, 0, 'thang');
  la('lưới tháng cũng vậy',
     !/dbg-cg-ten|dbg-cg-dk/.test(mm.ve(d, '2026-08-31', '2026-10-04', AI, {}, 'thang')));
  /* Lời thú thật thì Ở LẠI: `xong` là null nghĩa là CHƯA ĐỌC ĐƯỢC sổ việc đã
     xong, không phải "không ai xong cả". Thiếu dòng này thì lưới bày mọi buổi
     như thể chưa ai dự xong, và câu sai ấy sai đúng về phía làm người điều hành
     yên tâm nhầm. */
  const hn = mt.ve(d, '2026-08-31', '2026-09-06', AI, null, 'tuan');
  la('chưa đọc được sổ việc xong thì vẫn nói thẳng ra',
     /dbg-hong">chưa đọc được trạng thái đã dự xong/.test(hn));
  la('đọc được rồi thì không còn dòng nào',
     !/dbg-hong/.test(h));
}

console.log(truot ? `\n❌ ${dat} ca đạt, ${truot} ca trượt.` : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
