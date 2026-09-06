/* THỬ: Ô LỌC LOẠI VIỆC Ở BẢNG VIỆC HÔM NAY (TRI-110)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09: *"bảng việc hôm nay cho tôi bộ lọc loại việc"*, rồi chốt chỗ
   đứng: *"B, để lên góc trên bên phải"*. Cùng ngày đổi tiếp sang tick nhiều:
   *"đổi lọc ko f chọn 1 mà có thể tick hết hoặc bỏ tick hết ý, ví dụ muốn hiện
   hết việc trừ việc cá nhân này"* — và *"khi mà lọc thì độ cao của bảng bị thay
   đổi theo bộ lọc"*, chốt phương án A (ghim chiều cao).

   Những đường hỏng bài này canh:
     · Việc thuộc CAM KẾT không được đếm vào "phát sinh". `loaiCua` trả 'ps' cho
       nó — hỏi thẳng hàm ấy là ô lọc bày một tập khác hẳn tập mắt đang thấy.
       Đó là lý do có `loaiBay`.
     · Lọc phải ăn CẢ BA mục. Lọc sau khi tách thì con số đếm ở đầu mỗi mục đếm
       một tập còn danh sách bày một tập khác.
     · Giữ tập ĐANG ẨN, không giữ tập đang hiện — loại việc mới sinh ra phải mặc
       nhiên hiện, không rơi vào im lặng.
     · Bỏ tick hết là ĐƯỢC PHÉP, và bảng trống lúc ấy phải tự nói ra bằng chữ.
     · Loại đang bị ẩn ở lại trong menu kể cả khi còn 0 việc; gỡ nó giữa chừng là
       mất luôn đường bỏ ẩn.
     · Ghim chiều cao phải XOÁ trước khi đo, không thì con số tự nhân lên mãi.

   Chạy:  node thu-loc-loai-viec.js
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

const NGUON_LOAI = catKhoi("const O_CO_DINH  = '_cd';", '/* Ô chọn trả về BA hạng giá trị');
/* Mốc cắt là TÊN HÀM, không phải dòng chú thích mở đầu: chú thích ấy có một
   bản song sinh bên khối CSS (luật `.hn-loc`), và nó đứng trước trong file —
   cắt theo chú thích là bài thử nuốt nhầm mấy trăm dòng CSS rồi ngã ở dấu
   chấm đầu tiên. */
const NGUON_LOC  = catKhoi('const locHien = () =>', '/* Khoảng chênh Dự kiến ↔ Thực tế');
/* Tập mặc định rút thẳng từ mã, không chép lại: bài thử hỏi "mở app ra thấy gì"
   thì phải hỏi đúng con số mã đang dùng, không phải con số bài thử tự nhớ. */
const NGUON_MD   = SRC.match(/const LOC_MAC_DINH = \[[^\]]*\];/)[0];

/* ── DOM giả: đúng những nút mà mã với tới ───────────────────────────────── */
function oGia(id){
  const o = {id, innerHTML:'', value:'', textContent:'', hidden:false,
    style:{}, offsetHeight:0, _lop:new Set(), _thuoc:{}};
  o.classList = {toggle:(t,c)=>{ c ? o._lop.add(t) : o._lop.delete(t); }};
  o.setAttribute = (k,v) => { o._thuoc[k] = v; };
  return o;
}
function dungDom(){
  const kho = {};
  ['ds-task','hn-loc','hn-loc-nen','hn-loc-chu','hn-loc-chip']
    .forEach(id => kho[id] = oGia(id));
  /* Khu danh sách phải có chiều cao THẬT thì bài ghim mới đo được gì. Con số
     nào cũng được, miễn khác 0 — mã chỉ nhận số lớn hơn 0. */
  kho['ds-task'].offsetHeight = 640;
  return {kho, getElementById: id => kho[id] || null};
}

const TASK_THU = [
  {id:1, noi_dung:'Tổng kết cuối tuần', ngay:'2026-09-05', trang_thai:'Chua_lam', loai_viec:'co_dinh'},
  {id:2, noi_dung:'Chốt hợp đồng SFVN', ngay:'2026-09-05', trang_thai:'Chua_lam', tieu_diem_ma:'HH'},
  {id:3, noi_dung:'Tennis',             ngay:'2026-09-05', trang_thai:'Chua_lam', rieng_tu:true},
  {id:4, noi_dung:'Đọc master plan',    ngay:'2026-09-05', trang_thai:'Chua_xong', rieng_tu:true},
  {id:5, noi_dung:'Trả lời học viên',   ngay:'2026-09-04', trang_thai:'Chua_lam'},              // nợ, phát sinh
  {id:6, noi_dung:'Gọi cho Lâm Saa',    ngay:'2026-09-05', trang_thai:'Done', tieu_diem_ma:'HH'} // xong, cam kết
];

const COC = `
let TASKS = ${JSON.stringify(TASK_THU)};
const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];
const THE_THU = {};
const homNay = () => '2026-09-05';
const sxTheoGio = ds => ds;
const timO = ma => ma ? {ma, ten:'Hàng hoá phái sinh', luong:1} : null;
const veDongTask = t => '<div class="task-dong" data-id="' + t.id + '"></div>';
const CO_LOAI_VIEC = true, CO_RIENG_TU = true;
${NGUON_MD}
let LOC_AN = new Set(LOC_MAC_DINH), DS_CAO = 0, LOC_MO = false;
${NGUON_LOAI}
${NGUON_LOC}
`;

let dat = 0, hong = 0;
const ok  = (c, m) => { c ? (dat++, console.log('  ✅ ' + m)) : (hong++, console.log('  ❌ ' + m)); };
const muc = m => console.log('\n' + m);

/* `kich` là mấy dòng chạy THÊM sau khi dựng xong — chỗ để gọi `locBat`,
   `locTatCa`, `locMo` rồi soi kết quả, thay vì chỉ đặt sẵn trạng thái. */
function chay(an, tasks, kich){
  const document = dungDom();
  const f = new Function('document', COC
    + (tasks !== undefined ? `\nTASKS = ${JSON.stringify(tasks)};` : '')
    /* Không truyền `an` = để nguyên tập mặc định, tức đúng cảnh mở app ra. */
    + (an === undefined ? '' : `\nLOC_AN = new Set(${JSON.stringify(an)});`)
    + `\nveTasks();`
    + `\n${kich || ''}`
    + `\nreturn {ht: document.getElementById('ds-task').innerHTML,`
    + `  cao: document.getElementById('ds-task').style.minHeight,`
    + `  nho: DS_CAO,`
    + `  menu: document.getElementById('hn-loc').innerHTML,`
    + `  mo: !document.getElementById('hn-loc').hidden,`
    + `  nen: !document.getElementById('hn-loc-nen').hidden,`
    + `  chu: document.getElementById('hn-loc-chu').textContent,`
    + `  lop: [...document.getElementById('hn-loc-chip')._lop],`
    + `  an: document.getElementById('hn-loc-chip').style.display,`
    + `  con: [...LOC_AN]};`);
  return f(document);
}
const demDong = ht => (ht.match(/class="task-dong"/g) || []).length;
/* Dòng công tắc "Mọi loại việc" — cắt đúng nó ra để hỏi về ba mặt của nó. */
const congTac = menu => menu.slice(0, menu.indexOf('hn-loc-vach'));

muc('⓪ MỞ APP RA — mặc định trừ việc cá nhân (Tracy chốt 05/09)');
{
  const r = chay();
  ok(demDong(r.ht) === 4, 'bốn việc ROVA, hai việc cá nhân nằm ngoài ngay từ lượt vẽ đầu');
  ok(!/Tennis|master plan/.test(r.ht), 'không sót việc cá nhân nào');
  ok(r.chu === 'Trừ Việc cá nhân', 'chip nói thẳng loại đang bị bỏ — không ai phải đoán');
  ok(!r.lop.includes('dang'), 'chip KHÔNG đeo màu: đây là chỗ nghỉ, không phải một lựa chọn lạ');
  ok(/mot-phan/.test(congTac(r.menu)), 'công tắc đầu menu mang mặt gạch ngang');
  ok(r.nho === 640 && !r.cao, 'chiều cao mốc đo ở chính chỗ nghỉ, và chưa ghim gì');
}

muc('① Bỏ lọc tay — bảng bày đủ mọi việc, công tắc đủ tick');
{
  const r = chay([]);
  ok(demDong(r.ht) === 6, 'sáu việc đều có mặt');
  ok(r.chu === 'Mọi loại việc', 'chip đọc là “Mọi loại việc”');
  ok(r.lop.includes('dang'), 'chip ĐEO màu — hiện đủ mọi loại nay là khác mặc định');
  ok(/checked/.test(congTac(r.menu)) && !/mot-phan/.test(r.menu),
     'công tắc đầu menu tick đủ, không phải mặt gạch ngang');
}

muc('② VÍ DỤ CỦA TRACY: hiện hết, trừ việc cá nhân');
{
  const r = chay(['cn']);
  ok(demDong(r.ht) === 4, 'còn bốn việc — hai việc cá nhân rời đi');
  ok(!/Tennis|master plan/.test(JSON.stringify(r.ht)), 'không sót việc cá nhân nào');
  ok(r.chu === 'Trừ Việc cá nhân', 'chip gọi thẳng tên loại bị bỏ');
  ok(!r.lop.includes('dang'), 'nay trùng tập mặc định nên chip không đeo màu');
  ok(/mot-phan/.test(congTac(r.menu)), 'công tắc mang mặt gạch ngang — ẩn một phần');
}

muc('③ Ẩn nhiều loại — lọc ăn cả ba mục, chip nói bằng con số');
{
  const r = chay(['cn','cd']);
  ok(demDong(r.ht) === 3, 'còn ba việc: hai cam kết và một phát sinh');
  ok(/Đã xong · 1/.test(r.ht),        'mục Đã xong lọc theo cùng bộ lọc');
  ok(/Còn nợ từ hôm trước · 1/.test(r.ht), 'mục Còn nợ cũng vậy');
  ok(r.chu === '2 loại việc', 'chip đếm số loại còn hiện');
}
{
  const r = chay(['cn','cd','ps']);
  ok(r.chu === 'Cam kết', 'còn đúng một loại thì chip gọi tên nó, không nói “1 loại việc”');
}

muc('④ BẪY CHÍNH: việc thuộc cam kết không rơi vào “phát sinh”');
{
  const r = chay([]);
  ok(/Cam kết<\/span><span class="so">2/.test(r.menu), 'cam kết đếm 2 (một đang làm, một đã xong)');
  ok(/Việc phát sinh<\/span><span class="so">1/.test(r.menu), 'phát sinh đếm 1, không nuốt hai việc cam kết');
  ok(/cố định<\/span><span class="so">1/.test(r.menu) && /cá nhân<\/span><span class="so">2/.test(r.menu),
     'hai loại còn lại đếm đúng');
  ok(/Mọi loại việc<\/span><span class="so">6/.test(r.menu), 'công tắc đếm tổng');
}

muc('⑤ Bỏ tick hết — được phép, và bảng trống tự nói ra');
{
  const r = chay(['ck','cd','ps','cn']);
  ok(demDong(r.ht) === 0, 'không việc nào ở lại');
  ok(/Đang ẩn mọi loại việc/.test(r.ht), 'bảng nói rõ vì sao trống, không trống câm');
  ok(r.chu === 'Ẩn mọi loại', 'chip nói đúng cảnh ấy');
  ok(!/checked/.test(congTac(r.menu)) && !/mot-phan/.test(congTac(r.menu)),
     'công tắc về mặt trống — không tick, không gạch');
}

muc('⑥ Công tắc “Mọi loại việc” — tick hết / bỏ tick hết');
{
  const r = chay(['cn'], undefined, 'locTatCa();');
  ok(r.con.length === 0 && demDong(r.ht) === 6, 'đang ẩn một phần → một nhát mở lại tất cả');
}
{
  const r = chay([], undefined, 'locTatCa();');
  ok(r.con.length === 4 && demDong(r.ht) === 0, 'đang hiện đủ → một nhát ẩn hết');
}
{
  const r = chay(['ck','cd','ps','cn'], undefined, 'locTatCa();');
  ok(r.con.length === 0, 'đang ẩn hết → nhát nữa cũng là mở lại tất cả, không kẹt');
}

muc('⑦ Tick từng loại — bật rồi tắt trở về chỗ cũ');
{
  const r = chay([], undefined, "locBat('cd');");
  ok(r.con.join() === 'cd' && demDong(r.ht) === 5, 'tick bỏ một loại thì loại ấy rời bảng');
}
{
  const r = chay(['cd'], undefined, "locBat('cd');");
  ok(r.con.length === 0 && demDong(r.ht) === 6, 'tick lại thì nó quay về');
}

muc('⑧ Loại đang ẩn ở lại trong menu dù còn 0 việc');
{
  const r = chay(['cd'], TASK_THU.filter(t => !t.loai_viec));
  ok(/Việc cố định<\/span><span class="so">0/.test(r.menu),
     'loại bị ẩn vẫn có dòng của nó, bày thẳng con số 0 — không thì mất đường bỏ ẩn');
}
{
  const r = chay(['ck','ps','cn'], TASK_THU.filter(t => !t.loai_viec));
  ok(/<b>Việc cố định<\/b>/.test(r.ht),
     'còn đúng một loại mà loại ấy rỗng thì câu giải thích gọi tên nó');
}
{
  const r = chay(['ck','cn'], TASK_THU.filter(t => !t.loai_viec && !t.rieng_tu && t.tieu_diem_ma));
  ok(/các loại đang chọn/.test(r.ht), 'còn vài loại cùng rỗng thì nói chung, không kể tên');
}

muc('⑨ Bảng chưa có việc nào — ô lọc lui đi');
{
  ok(chay(undefined, []).an === 'none', 'ô lọc ẩn khi chưa có việc và bộ lọc còn ở chỗ nghỉ');
  ok(chay([], []).an === '', 'nhưng ở lại khi người ta đã tự đổi bộ lọc — còn đường về');
}

muc('⑩ GHIM CHIỀU CAO — bảng không đổi cao theo bộ lọc');
{
  const r = chay();
  ok(r.nho === 640, 'lượt ở chỗ nghỉ thì NHỚ chiều cao thật');
  ok(!r.cao, 'và không ghim gì cả — để nó tự co giãn theo việc');
}
{
  const r = chay(undefined, undefined, "locBat('cd');");
  ok(r.cao === '640px', 'vừa rời chỗ nghỉ là ghim đúng chiều cao vừa nhớ');
}
{
  const r = chay(undefined, undefined, "locBat('cd'); locBat('ps'); locBat('cd');");
  ok(r.cao === '640px', 'ba nhát tick liên tiếp vẫn đúng một con số — không cộng dồn');
}
{
  const r = chay(undefined, undefined, "locBat('cd'); locBat('cd');");
  ok(!r.cao && r.nho === 640, 'về lại chỗ nghỉ thì gỡ ghim, và đo lại số mới');
}
{
  const r = chay([], undefined, "locBat('cn');");
  ok(!r.cao && r.nho === 640, 'bỏ tick tay rồi tick lại đúng tập mặc định cũng là về chỗ nghỉ');
}
{
  /* Cảnh xấu nhất: chưa từng có lượt nào ở chỗ nghỉ để mà đo — lượt vẽ đầu tiên
     đã đứng ngoài tập mặc định rồi. Không có số thì đừng ghim bừa. */
  const r = chay(['cn','cd'], undefined, '');
  ok(!r.cao, 'chưa đo được lần nào thì không ghim, thay vì ghim số 0');
}

muc('⑪ Menu tick — mở, đóng, và không tự gập giữa chừng');
{
  const r = chay([]);
  ok(!r.mo && !r.nen, 'menu đóng sẵn lúc vẽ bảng');
}
{
  const r = chay([], undefined, 'locMo();');
  ok(r.mo && r.nen, 'bấm chip thì menu và tấm bắt-chạm-ngoài cùng hiện');
}
{
  const r = chay([], undefined, "locMo(); locBat('cn');");
  ok(r.mo, 'tick một loại thì menu Ở LẠI — còn tick tiếp loại khác');
}
{
  const r = chay([], undefined, 'locMo(); locDong();');
  ok(!r.mo && !r.nen, 'chạm ra ngoài thì cả hai cùng tắt');
}

console.log(`\n${hong ? '❌' : '✅'} ${dat} ca đạt${hong ? `, ${hong} ca hỏng` : ''}.`);
process.exit(hong ? 1 : 0);
