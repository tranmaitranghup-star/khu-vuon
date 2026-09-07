/* THỬ: BA CẤP DÙNG APP — Quản trị · Lead · Member  (TRI-139, 07/09)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy chốt 07/09: *"bây giờ cần bạn phân cấp 3 level dùng app"* — Quản trị
   (Andy, Tracy) · Lead (John, Justin, Hafi, Peter, Sydney) · Member (Ham,
   Andrew, Javis, ZemC, Vicky, Hương Giang). BA giới hạn áp cho cấp Member — cam
   kết Cả ROVA · Dự án · Việc cố định. Bảng đo và hàng deep work KHÔNG cắt theo
   cấp: ai ĐỨNG TRONG bảng là chuyện của cờ `ngoai_bang_do`, mục ⑦.

   VÌ SAO NHỮNG CA NÀY ĐÁNG GIÁ — chúng đều là chỗ thử tay KHÔNG lộ ra, vì màn
   hình của người thử (một quản trị) trông vẫn đúng y như cũ:

     · THỨ TỰ HỎI CỜ. Quản trị mang CẢ HAI cờ. Hỏi `la_lead` trước là Tracy và
       Andy đọc ra "Lead" — mà một quản trị đọc nhầm thành Lead thì không mất
       quyền gì cả, nên không ai phát hiện, cho tới ngày ai đó thêm một giới hạn
       cho cấp Lead.

     · HAI ĐƯỜNG BẬT PHẠM VI CẢ ĐỘI. Nút trên màn Cam kết, và `cbKyNhan` gán
       thẳng vào cờ. Bịt một đường thì đường kia vẫn mở, im lặng.

     · MEMBER CHƯA ĐƯỢC XẾP KHỐI. `nhomTheoKhoi` có một lối rơi về "Toàn team"
       khi danh sách khối rỗng — với Member thì lối ấy lột sạch giới hạn ③, mà
       màn trông vẫn hoàn toàn bình thường.

     · AI ĐỨNG TRONG BẢNG ≠ AI ĐƯỢC XEM BẢNG. Gộp hai câu hỏi ấy vào một chỗ là
       hoặc chặn nhầm năm Member khỏi Bảng đo, hoặc để lại một dòng 0 quả mang
       tên người không tham gia cuộc đo. Mục ⑤ và ⑦ canh hai đầu của luật này.

     · ĐĂNG VẤN ĐỀ KHÔNG BỊ CẮT. Tracy chốt cùng ngày: *"đăng vấn đề thì cho
       toàn bộ 12 người"*. Một đợt siết sau rất dễ quét nhầm nó.
   ───────────────────────────────────────────────────────────────────────────── */
const fs = require('fs'), path = require('path'), vm = require('vm');
const SRC = fs.readFileSync(path.join(__dirname, 'public/index.html'), 'utf8');

function catHam(ten){
  let dau = SRC.indexOf('function ' + ten + '(');
  if (dau < 0) throw new Error('Khong thay ham: ' + ten);
  if (SRC.slice(dau - 6, dau) === 'async ') dau -= 6;
  let i = SRC.indexOf('{', dau), sau = 0;
  for (let j = i; j < SRC.length; j++){
    if (SRC[j] === '{') sau++;
    else if (SRC[j] === '}'){ sau--; if (!sau) return SRC.slice(dau, j + 1); }
  }
  throw new Error('Ham khong dong ngoac: ' + ten);
}
function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j + cuoi.length);
}
const BA_CAP = catKhoi('const CAP = {QUAN_TRI',
                       'const laMember = ()  => capCua(ME) === CAP.MEMBER;');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

const KHOI = [{id:1,ten:'CEO'}, {id:2,ten:'Vận hành'}, {id:3,ten:'Sản phẩm'},
              {id:4,ten:'Kinh doanh'}, {id:5,ten:'Tài chính'},
              {id:6,ten:'Trải nghiệm khách hàng'}];
/* Đúng ba cấp thật trên máy chủ, soi 07/09. Quản trị mang CẢ HAI cờ — đó chính
   là thứ ca ① canh, nên đừng "dọn" nó cho gọn. */
const TRACY  = {id:'t', ten:'Tracy',       la_lead:true,  la_quan_tri:true,  chuc_nang_ids:[2,5,4]};
const PETER  = {id:'p', ten:'Peter',       la_lead:true,  la_quan_tri:false, chuc_nang_ids:[3,6]};
const GIANG  = {id:'g', ten:'Hương Giang', la_lead:false, la_quan_tri:false, chuc_nang_ids:[2]};
const TRONG  = {id:'x', ten:'Chưa xếp',    la_lead:false, la_quan_tri:false, chuc_nang_ids:[]};

/* Máy chạy THẬT bốn hàm ngắn. `taiVuon` dựng giả để đếm xem cờ có đổi không —
   đó là toàn bộ thứ ca ② cần biết. */
function may(ME){
  const kb = {ME, CHUC_NANG: KHOI, DOI: [TRACY, PETER, GIANG],
              vuonCaDoi: false, SO_TAI: 0, o: {}};
  kb.document = {getElementById: id => (kb.o[id] ||= {id, style:{display:''},
                   classList:{_s:new Set(), toggle(c,v){ v ? this._s.add(c) : this._s.delete(c); },
                              contains(c){ return this._s.has(c); }}})};
  kb.taiVuon = () => { kb.SO_TAI++; };
  kb.globalThis = kb;
  vm.createContext(kb);
  vm.runInContext([BA_CAP, catKhoi('const DOI_DO = () =>', ';'),
                   catKhoi('const DOI_CHON = () =>', ';'),
                   catKhoi('const VCD_TAM_NHIN =', ';'),
                   catHam('khoiDuocNhin'), catHam('capNhatDaiDoi'),
                   catHam('ckDoiPhamVi'), catHam('nhomTheoKhoi')].join('\n'), kb);
  kb.dat = (ten, val) => { kb.__tmp = val; vm.runInContext(ten + ' = __tmp', kb); };
  kb.doc = ten => vm.runInContext(ten, kb);
  return kb;
}

console.log('\n═══ BA CẤP DÙNG APP (TRI-139) ═══');

/* ── ① Thứ tự hỏi cờ ─────────────────────────────────────────────────────── */
console.log('\n① Cấp đọc đúng, kể cả khi một người mang hai cờ');
{
  const k = may(TRACY);
  la('quản trị mang cả hai cờ vẫn đọc ra Quản trị, không ra Lead',
     k.doc('capCua')(TRACY) === 'Quản trị', 'nhận được: ' + k.doc('capCua')(TRACY));
  la('lead đọc ra Lead',   k.doc('capCua')(PETER) === 'Lead');
  la('không cờ nào đọc ra Member', k.doc('capCua')(GIANG) === 'Member');
  la('không có người thì không có cấp', k.doc('capCua')(null) === null);
  la('quản trị KHÔNG phải Member', k.doc('laMember')() === false);
  la('câu hỏi `la_quan_tri` đứng TRƯỚC `la_lead` trong chính mã',
     SRC.indexOf('n.la_quan_tri      ? CAP.QUAN_TRI') < SRC.indexOf('n.la_lead          ? CAP.LEAD'),
     'đảo hai dòng là Tracy và Andy đọc ra Lead — và không ai mất quyền gì để mà phát hiện');
}

/* ── ② Giới hạn ① — cam kết Cả ROVA ──────────────────────────────────────── */
console.log('\n② Member không sang được phạm vi Cả ROVA');
{
  const m = may(GIANG);
  m.doc('ckDoiPhamVi')(true);
  la('Member bấm Cả ROVA: cờ không đổi', m.doc('vuonCaDoi') === false);
  la('và không tốn một chuyến hỏi máy chủ nào', m.SO_TAI === 0);

  const l = may(PETER);
  l.doc('ckDoiPhamVi')(true);
  la('Lead vẫn sang được, và có hỏi máy chủ',
     l.doc('vuonCaDoi') === true && l.SO_TAI === 1);

  m.doc('capNhatDaiDoi')();
  la('dải hai nút phạm vi bị giấu CẢ CỤM với Member',
     m.o['ck-pv'].style.display === 'none',
     'giấu mỗi nút "Cả ROVA" thì còn lại một bộ chọn không chọn được gì');
  l.doc('capNhatDaiDoi')();
  la('Lead vẫn thấy dải ấy', l.o['ck-pv'].style.display === '');

  /* Đường thứ hai: `cbKyNhan` gán THẲNG vào cờ, không đi qua `ckDoiPhamVi`. */
  const ky = catHam('cbKyNhan');
  la('đường ký nhận cũng hỏi cấp trước khi bật cờ',
     /if \(!vuonCaDoi && !laMember\(\)\)/.test(ky),
     'đây là đường thứ hai vào phạm vi cả đội — bịt một đường không đủ');
  la('và không còn chỗ nào khác gán `vuonCaDoi = true`',
     (SRC.match(/vuonCaDoi = true/g) || []).length === 1,
     'mọc thêm một chỗ gán là mọc thêm một đường vòng');
}

/* ── ③ Giới hạn ② — màn Dự án ────────────────────────────────────────────── */
console.log('\n③ Member chỉ thấy dự án có tên mình');
{
  const ve = catHam('duVeLuoi');
  la('lưới lọc theo cấp', /if \(laMember\(\)\)/.test(ve));
  la('"có tên mình" tính CẢ PIC lẫn người được mời gánh',
     /d\.nguoi_id === ME\.id \|\| \(d\.nguoi_ganh \|\| \[\]\)\.includes\(ME\.id\)/.test(ve),
     'chỉ tính PIC thì người được mời mất luôn dự án mình đang làm');
  la('lọc ở LƯỚI, không lọc ở `taiDuAn`',
     !/laMember\(\)/.test(catHam('taiDuAn')),
     'cắt từ nguồn là ô lọc PIC, ô lọc phòng ban và màn hồ sơ cùng hụt theo');
}

/* ── ④ Giới hạn ③ — màn Việc cố định ─────────────────────────────────────── */
console.log('\n④ Member chỉ thấy khối chức năng của mình');
{
  const m = may(GIANG), l = may(PETER), q = may(TRACY);
  la('Member thấy đúng khối của mình',
     JSON.stringify(m.doc('khoiDuocNhin')().map(c => c.id)) === '[2]');
  la('Lead vẫn thấy cả sáu khối',    l.doc('khoiDuocNhin')().length === 6);
  la('Quản trị vẫn thấy cả sáu khối', q.doc('khoiDuocNhin')().length === 6);

  const t = may(TRONG);
  const nhom = t.doc('nhomTheoKhoi')();
  la('Member chưa được xếp khối KHÔNG rơi về cả đội',
     nhom.length === 1 && nhom[0].nguoi.length === 1 && nhom[0].nguoi[0].id === 'x',
     'nhận được ' + nhom[0].nguoi.length + ' người — lối rơi cũ lột sạch giới hạn này trong im lặng');

  la('công tắc tầm nhìn đã vặn sang "theo-cap"',
     /const VCD_TAM_NHIN = 'theo-cap';/.test(SRC));
  la('tiêu đề lưới nói đúng thứ bên dưới nó',
     /Khối chức năng của tôi/.test(catHam('veRova')),
     'để nguyên chữ "Cả công ty" là cái nhãn nói dối');
}

/* ── ⑤ BA THỨ MEMBER VẪN XEM ĐƯỢC — ca canh chiều NGƯỢC LẠI ──────────────── */
console.log('\n⑤ Bảng đo và hàng deep work KHÔNG bị cắt theo cấp');
{
  /* 🪤 CA NÀY SINH RA TỪ MỘT LẦN HIỂU SAI, 07/09. Bản đầu chặn Member khỏi tab
     Bảng đo và giấu hàng deep work, vì đọc câu Tracy *"không cho tài khoản này
     vào dashboard… bảng deep work"* thành "chặn XEM". Tracy nói lại: *"ý là bỏ
     tên Hương Giang ra khỏi đó chứ có phải bảo là để Hương Giang không thấy mấy
     cái bảng đó đâu"*. Ai ĐỨNG TRONG bảng và ai ĐƯỢC XEM bảng là hai câu hỏi
     khác nhau; cái trước đi theo cờ `ngoai_bang_do` ở mục ⑦.
     Ca này canh chiều NGƯỢC: cấp không được bò lại vào hai chỗ ấy. */
  la('`moTab` không đá Member khỏi tab nào',
     !/laMember\(\)/.test(catHam('moTab')),
     'Member xem Bảng đo như mọi người — thứ đổi là ai có TÊN trong đó');
  la('`hdVe` không hỏi cấp',
     !/laMember\(\)/.test(catHam('hdVe')),
     'hàng deep work vẫn hiện đủ với mọi cấp');
  la('không hàm nào giấu viên thuốc trên thanh tab theo cấp',
     !/data-man="doi"[\s\S]{0,160}laMember\(\)/.test(SRC));
  /* Đếm theo TẬP HÀM, không theo số lần: một hàm gọi hai lượt (như `veRova`, sửa
     cả tiêu đề lẫn dòng phụ) vẫn là MỘT chỗ luật ăn. Kê tên ra để lần sau ai
     thêm một hàm mới thì ca này đỏ và người ấy phải nói ra mình vừa thêm giới
     hạn gì — đó mới là thứ cần chặn, không phải con số. */
  const AN_O = ['ckDoiPhamVi','capNhatDaiDoi','cbKyNhan','duVeLuoi',
                'khoiDuocNhin','nhomTheoKhoi','veRova'];
  /* Gán mỗi lượt gọi cho hàm bắt đầu GẦN NHẤT phía trước. Đừng dùng một regex
     bắc cầu từ `function` tới `laMember()`: nó vắt qua giữa nhiều hàm và đổ tội
     cho hàm sai — thử lần đầu ra bốn cái tên chẳng liên quan. */
  const laMa = SRC.replace(/\/\*[\s\S]*?\*\//g, ' ');
  const dau  = [...laMa.matchAll(/\bfunction ([a-zA-Z_$][\w$]*)\s*\(/g)]
                 .map(m => ({i: m.index, ten: m[1]}));
  const thua = [...laMa.matchAll(/laMember\(\)/g)].map(m => {
    let t = null;
    for (const d of dau){ if (d.i < m.index) t = d.ten; else break; }
    return t;
  }).filter(t => t && !AN_O.includes(t));
  la('cấp chỉ ăn ở đúng bảy hàm đã kê, không mọc thêm chỗ nào',
     AN_O.every(h => /laMember\(\)/.test(catHam(h))) && thua.length === 0,
     thua.length ? 'mọc thêm ở: ' + [...new Set(thua)].join(', ')
                 : 'một hàm đã kê thôi gọi `laMember()` — giới hạn ấy vừa biến mất');

  la('màn Team vẫn chỉ quản trị mở được',
     /if \(chiQuanTri\) b\.style\.display = ME\?\.la_quan_tri \? '' : 'none';/.test(SRC),
     'điều này đúng từ 05/09, không phải thứ ba cấp thêm vào — canh nó không bị nới ra');
}

/* ── ⑥ Thứ KHÔNG được cắt ────────────────────────────────────────────────── */
console.log('\n⑥ Đăng vấn đề vẫn mở cho cả 12 người');
{
  /* Tracy chốt 07/09: *"đăng vấn đề thì cho toàn bộ 12 người"*. Nút này không
     gác gì, và ca dưới canh nó CỨ THẾ — để đợt siết sau không quét nhầm. */
  const nut = SRC.slice(SRC.indexOf('id="vd-nut-moi"') - 200,
                        SRC.indexOf('id="vd-nut-moi"') + 200);
  la('nút Ghi vấn đề không đeo điều kiện cấp nào', !/laMember|la_quan_tri|la_lead/.test(nut));
  la('và không chỗ nào trong mã giấu nó đi',
     !/vd-nut-moi[\s\S]{0,200}(laMember|display)/.test(SRC),
     'nếu ngày nào đó phải gác, hãy sửa ca này CÙNG LÚC — đừng để nó đỏ rồi tắt đi');

  la('lớp giao diện tự khai nó không phải hàng rào',
     /ĐÂY LÀ LỚP GIAO DIỆN, KHÔNG PHẢI HÀNG RÀO/.test(SRC),
     'đọc mã này thành "Member không đọc được dữ liệu" là hiểu sai mức bảo vệ');

  /* Ca này ĐỔI CHIỀU ngày 07/09 sau khi siết RLS (TRI-144). Bản cũ đòi mã tự
     khai "RLS chưa được siết theo cấp" — một lời khai ĐÚNG lúc viết ra và SAI
     ngay hôm sau, mà không gì báo. Đó là loại chú thích nguy hiểm nhất: nó
     không mục đi trong im lặng, nó nói ngược lại sự thật và vẫn được tin.
     Nay ca đòi hai điều ngược lại — mã phải khai hàng rào ĐÃ có, và phải kê
     tên hai chỗ còn hở kèm mã câu hỏi, để người sửa sau không lặng lẽ siết
     chúng rồi làm lệch bảng đo. */
  la('mã khai đúng rằng hàng rào máy chủ ĐÃ được siết',
     /ĐÃ ĐƯỢC SIẾT theo cấp/.test(SRC) && !/chưa được siết theo cấp/.test(SRC),
     'siết RLS xong mà lời khai còn nói "chưa siết" thì phiên sau đọc ra một mức '
   + 'bảo vệ sai — và sẽ đi siết lại thứ đã siết, hoặc tưởng không có gì bảo vệ');

  la('và kê đúng hai chỗ còn hở kèm mã câu hỏi',
     /G-01\.ap/.test(SRC) && /G-01\.aq/.test(SRC),
     'hai chỗ ấy hở CÓ CHỦ Ý vì bảng đo mở cho mọi cấp; không kê tên ra thì '
   + 'người sau hoặc tưởng đã kín, hoặc lặng lẽ siết và làm lệch bảng đo');
}

/* ── ⑦ AI ĐỨNG TRONG BẢNG ĐO — một câu hỏi KHÁC hẳn câu hỏi cấp ─────────── */
console.log('\n⑦ Cờ ngoai_bang_do — ai được ĐẾM, không phải ai được XEM');
{
  const k = may(TRACY);
  k.dat('DOI', [TRACY, PETER, GIANG, {...GIANG, id:'h', ten:'Trợ lý 2', ngoai_bang_do:true}]);
  const con = k.doc('DOI_DO')().map(n => n.ten);
  la('người mang cờ bị gỡ khỏi bảng đo',
     !con.includes('Trợ lý 2'), 'còn lại: ' + con.join(', '));
  la('Member KHÔNG mang cờ vẫn đứng đủ trong bảng',
     con.includes('Hương Giang'),
     'cấp nói ai được XEM, cờ này nói ai được ĐẾM — suy cờ ra từ cấp là mọi Member '
   + 'biến khỏi bảng đo, kể cả người đang deepwork thật');
  la('không cờ thì mặc nhiên đứng trong bảng', con.length === 3);

  /* Mọi chỗ đổ cả team ra màn phải cùng đi qua một cửa. Đếm bằng máy: thiếu một
     chỗ thì tên người ấy vẫn hiện ở đúng chỗ bị bỏ quên, và không ai thấy.

     ⚠️ DANH SÁCH NÀY DÀI RA THEO APP, và lần dài ra đầu tiên đã chứng minh vì
     sao phải đếm bằng máy: bản 07/09 sáng nối năm chỗ, tới chiều mới lộ ra khối
     💧 Giờ deep work và trọn màn Việc cố định cũng đổ cả team ra màn mà không ai
     nhớ. Thêm một khối bày cả team thì thêm tên hàm vào đây, đừng chỉ sửa mã. */
  const cua = ['hdVe', 'taiDoi', 'veBangGat', 'veBangCham', 'veSoSanh',
               'rvdVe', 'nhomTheoKhoi', 'veRova', 'rvVeSo'];
  const sot = cua.filter(h => !/DOI_DO\(\)/.test(catHam(h)));
  la('mọi chỗ đổ cả team ra màn đều đi qua `DOI_DO()`',
     sot.length === 0, sot.length ? 'còn đọc thẳng DOI: ' + sot.join(', ') : '');

  /* Bốn ô số của màn Việc cố định là bản tóm tắt của chính cái lưới ngay trên
     nó. Hai bên đếm hai danh sách khác nhau là hai con số cãi nhau trên cùng
     một màn — mà mắt không có cách nào biết bên nào đúng. */
  la('lưới nhịp và bốn ô số của nó đếm cùng một danh sách',
     !/\bDOI\.(length|filter|forEach|map|reduce)\b/.test(catHam('rvVeSo'))
  && !/\bDOI\.(length|filter|forEach|map|reduce)\b/.test(catHam('nhomTheoKhoi')),
     'còn sót một lượt đọc thẳng `DOI` trong `rvVeSo` hoặc `nhomTheoKhoi`');

  /* ⚠️ SOI PHẦN MÃ, KHÔNG SOI CHÚ THÍCH — cùng bài học đã chép ở ca ⑨ của
     `thu-loai-ca-nhan.js`. Khối chú thích ngay trên `DOI_DO` có nhắc tên bạn ấy
     để kể lại vì sao có cờ này; dò thẳng trên cả tệp là báo đỏ đúng đoạn văn
     giải thích, tức phạt người đã ghi lại lý do. */
  const maSach = SRC.replace(/\/\*[\s\S]*?\*\//g, '');
  la('cờ đi theo MỘT CỜ, không ghim tên người vào mã',
     !/Hương Giang/.test(maSach),
     'ghim tên là ngày người ấy đổi tên thì bảng lặng lẽ nhận lại một dòng');

  const sql = fs.readFileSync(path.join(__dirname, 'nang-cap-ngoai-bang-do.sql'), 'utf8');
  la('cột mặc định false — ra ngoài bảng là việc phải KHAI',
     /ngoai_bang_do boolean not null default false/.test(sql),
     'mặc định true thì người mới lặng lẽ biến mất khỏi bảng');
  la('khai theo EMAIL, không theo tên hiển thị',
     /where email = 'nguoi-13@vidu\.com'/.test(sql),
     'tên sửa được ở màn Team, sửa xong là câu update trượt trong im lặng');

  /* ── Năm member chưa onboard, tạm đứng ngoài bảng (Tracy chốt 07/09 chiều) ──
     Cùng một cờ, hai lý do khác nhau: Hương Giang đứng ngoài vĩnh viễn, năm
     người này đứng ngoài tới khi onboard. Cột không phân biệt được hai lý do
     ấy, nên tệp SQL là chỗ duy nhất ghi lý do — và ca này canh cho nó còn ghi. */
  const sqlTam = fs.readFileSync(
    path.join(__dirname, 'nang-cap-tam-an-5-member-chua-onboard.sql'), 'utf8');
  const nam5 = ['nguoi-14@vidu.com', 'nguoi-11@vidu.com',
                'nguoi-16@vidu.com', 'nguoi-09@vidu.com',
                'nguoi-04@vidu.com'];
  la('đủ năm email trong câu khai',
     nam5.every(e => sqlTam.includes(e)),
     'thiếu email nào thì người ấy còn tên trong bảng: '
   + nam5.filter(e => !sqlTam.includes(e)).join(', '));
  la('không đụng tài khoản — chỉ đặt cờ, không xoá, không cho nghỉ',
     !/\bdelete\s+from\s+nguoi\b/i.test(sqlTam) && !/\bngay_nghi\s*=/i.test(sqlTam),
     'Tracy chốt *"chỉ là ẩn tên đi chứ vẫn giữ acc của họ đã đăng ký"*');
  la('câu GỠ nằm sẵn trong tệp, đã chú thích lại chờ ngày onboard',
     /--\s*update nguoi set ngoai_bang_do = false/.test(sqlTam),
     'ẩn tạm mà không để sẵn đường gỡ thì vài hôm nữa lại phải dò lại từ đầu');
}

/* ── ⑧ AI HIỆN TRONG Ô CHỌN NGƯỜI — câu hỏi thứ BA, cột thứ ba ──────────── */
console.log('\n⑧ Cờ ngoai_o_chon — ai được CHỌN, không phải ai được ĐẾM');
{
  const k = may(TRACY);
  /* Dựng đúng cảnh thật: Hương Giang đứng ngoài CẢ HAI (bảng đo và ô chọn),
     còn một member chưa onboard đứng ngoài MỖI bảng đo. Đó là cảnh mà một cờ
     dùng chung sẽ làm hỏng, nên nó phải nằm trong bài thử. */
  const GIANG2 = {...GIANG, ngoai_bang_do:true, ngoai_o_chon:true};
  const MEM    = {id:'m', ten:'Javis', la_lead:false, la_quan_tri:false,
                  chuc_nang_ids:[4], ngoai_bang_do:true};
  k.dat('DOI', [TRACY, PETER, GIANG2, MEM]);

  const chon = k.doc('DOI_CHON')().map(n => n.ten);
  const do_  = k.doc('DOI_DO')().map(n => n.ten);
  la('người mang cờ ô chọn bị gỡ khỏi ô chọn',
     !chon.includes('Hương Giang'), 'còn lại: ' + chon.join(', '));
  la('MEMBER CHƯA ONBOARD VẪN CHỌN ĐƯỢC — hai cờ không lây sang nhau',
     chon.includes('Javis'),
     'đây là ca hỏng nếu ai đó gộp hai cờ làm một: Tracy giữ năm người ấy lại '
   + 'đúng để còn mời và còn giao việc');
  la('mà họ vẫn đứng ngoài bảng đo', !do_.includes('Javis'));
  la('không cờ thì mặc nhiên chọn được', chon.length === 3);

  /* Sáu ô chọn phải cùng đi qua một cửa. Đếm bằng máy, cùng lý lẽ với mục ⑦. */
  const oChon = ['lcDsMoi', 'veHoSoDuAn', 'duTraoMo', 'duMoMoi', 'vdOptNguoi'];
  const sot2  = oChon.filter(h => !/DOI_CHON\(\)/.test(catHam(h)));
  la('mọi ô chọn người đều đi qua `DOI_CHON()`',
     sot2.length === 0, sot2.length ? 'còn đọc thẳng DOI: ' + sot2.join(', ') : '');
  la('ô chọn PIC của cam kết cũng vậy',
     /DOI_CHON\(\)\.map\(n => `<option value="\$\{n\.id\}"/.test(SRC),
     'select #dus-pic còn đổ thẳng từ DOI');

  /* ⛔ RANH GIỚI: chỗ TRA TÊN không được lọc. Lọc nhầm thì việc bạn ấy từng
     nhận hiện ra mang tên "—" — một dòng mất tên khó hiểu hơn một dòng có tên
     không mong đợi. Bốn hàm này phải còn đọc thẳng `DOI`. */
  const traTen = [
    ['nguoiTrongDoi', /const nguoiTrongDoi = ngId => DOI\.find/],
    ['duTenNguoi',    /const duTenNguoi = id => \(DOI\.find/],
    ['btTenNguoi',    /const btTenNguoi= \(id\) => \(DOI\.find/],
    ['capTrenCua',    /const ai = DOI\.find\(n => n\.id === nguoiId\)/]];
  const locNham = traTen.filter(([, re]) => !re.test(SRC)).map(([t]) => t);
  la('bốn chỗ TRA TÊN vẫn đọc cả team, không lọc theo cờ ô chọn',
     locNham.length === 0,
     locNham.length ? 'không còn đọc thẳng DOI: ' + locNham.join(', ')
                    + ' — việc bạn ấy từng nhận sẽ hiện tên "—"' : '');

  const sqlOC = fs.readFileSync(path.join(__dirname, 'nang-cap-ngoai-o-chon.sql'), 'utf8');
  la('cột mặc định false — ra ngoài ô chọn là việc phải KHAI',
     /ngoai_o_chon boolean not null default false/.test(sqlOC));
  la('khai theo EMAIL, và đúng một người',
     /where email = 'nguoi-13@vidu\.com'/.test(sqlOC));
  la('câu cho hiện lại để sẵn, đã chú thích lại',
     /--\s*update nguoi set ngoai_o_chon = false/.test(sqlOC));
}

console.log(truot ? `\n❌ ${truot} ca TRƯỢT · ${dat} đạt\n` : `\n✅ Đủ cả ${dat} phép kiểm\n`);
process.exit(truot ? 1 : 0);
