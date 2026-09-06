/* THỬ: GHI XUỐNG BẢNG `task` THÌ PHẢI CÓ ĐƯỜNG VỀ BẢNG HÔM NAY
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09, thử trên máy Andy: *"chỉnh lịch hôm nay ở timeline thì task ở
   bảng hôm nay không thay đổi"* (TRI-106).

   Bệnh gốc: bảng việc hôm nay vẽ bởi `veTasks()`, đọc mảng `TASKS`, và cả tệp
   chỉ có ĐÚNG MỘT chỗ nạp `TASKS` — bên trong `taiHomNay()`. Sáu cửa sửa dữ
   liệu gọi `lamMoiCuaToi()`, hàm khi ấy chỉ nuôi màn Của tôi. Ba cửa trong số
   đó còn mang sẵn chú thích viết ĐÚNG điều cần làm rồi gọi nhầm ngay dòng dưới.
   Không một tiếng kêu nào; chỉ người dùng thật phát hiện ra, bằng cách nhìn một
   dòng việc đứng yên sau khi vừa sửa giờ cho nó.

   ╔═ HAI LUẬT, KHÔNG PHẢI MỘT (nới ra ở TRI-108) ══════════════════════════════╗
   ║ Bản đầu của bài thử hỏi một câu chung cho mọi lượt ghi: *có đường về bảng  ║
   ║ Hôm nay không?* — và nhận `veTasks` là một câu trả lời hợp lệ. Nó bỏ lọt   ║
   ║ đúng nhóm nặng nhất: cửa ĐẺ RA việc mới.                                  ║
   ║                                                                            ║
   ║ **ĐẺ** một việc thì `veTasks()` KHÔNG cứu được. Việc vừa sinh không có     ║
   ║ đường nào lọt vào `TASKS` — chỗ nạp mảng ấy chỉ có một, trong `taiHomNay`  ║
   ║ — nên vẽ lại là vẽ lại đúng mảng cũ. Phải NẠP LẠI.                        ║
   ║ **SỬA** một việc đã nằm trên bảng thì vá vật trong bộ nhớ rồi `veTasks()`  ║
   ║ là đủ, và rẻ hơn hẳn một lượt hỏi máy chủ.                                ║
   ╚════════════════════════════════════════════════════════════════════════════╝

   Hai bộ hàm dưới đây TÍNH TỪ MÃ, không kê tay:
     · NẠP LẠI = `taiHomNay` + mọi hàm gọi thẳng nó (`lamMoiCuaToi`,
       `dwTaiLaiMan`, `donDong`, `htThoat`…). Thêm một cửa nạp mới thì bài thử
       tự biết, không phải ai nhớ sửa danh sách ở đây.
     · VẼ LẠI  = `veTasks` + mọi hàm gọi thẳng nó (`doiTrangThai`…).

   Và một hàm ghi xuống `task` mà TỰ LO được lượt vẽ thì che luôn cho cửa gọi
   nó — nên chỉ những chuỗi thật sự đứt mới bị kêu tên.

   ⚠️ HAI GIỚI HẠN, ghi ra để đừng ai tin quá tay:
   ① Đọc mã TĨNH nên không thấy nhánh. `lcTraLoi` gọi `vaoDeepTuLuoi` (một cửa
     nạp lại) trong ĐÚNG MỘT nhánh `kieu === 'deep'`, mà bài thử chỉ thấy có
     lời gọi ấy trong thân hàm là cho qua cả hàm. Ba nhánh còn lại của nó được
     che bởi `lcVeLai`, không phải bởi phép kiểm này.
   ② Cạnh gọi dò bằng `tên(` sau khi đã cắt các thuộc tính `onclick="…"`. Tên
     cửa nằm trong một chuỗi HTML kiểu khác — tham số dạng `` `datHanKho(...)` ``
     — vẫn bị đếm là một lời gọi thật; đó là lý do vài hàm VẼ có mặt trong
     `MIEN_TRU` dưới đây.

   Chạy:  node production/tinh-thuc-app/thu-lam-moi-homnay.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Cắt mã thành từng hàm. Mọi hàm cấp cao nhất của tệp này đều mở bằng
   `function ten(` ở cột 0 và đóng bằng `}` ở cột 0 — không dựa vào việc đếm
   ngoặc, thứ sẽ vấp phải mọi dấu ngoặc nằm trong chuỗi và trong chú thích. */
function cacHam(){
  const d = SRC.split('\n'), ra = [];
  let ten = null, tu = 0;
  d.forEach((dong, i) => {
    const m = dong.match(/^(?:async\s+)?function\s+([A-Za-z0-9_]+)\s*\(/);
    if (m){ ten = m[1]; tu = i; return; }
    if (ten && dong === '}'){ ra.push({ten, than: d.slice(tu, i + 1).join('\n')}); ten = null; }
  });
  return ra;
}
const HAM = cacHam();

/* Bỏ các thuộc tính `onclick="…"` trước khi dò cạnh gọi: một hàm VẼ in ra chuỗi
   `onclick="lcTickXong(1)"` thì nó đang dựng một cái nút, không phải đang gọi
   hàm ấy. Đếm nhầm chỗ này là mọi hàm vẽ đều thành cửa ghi. */
const boChuoiNut = s => s.replace(/on[a-z]+="[^"]*"/g, ' ').replace(/on[a-z]+='[^']*'/g, ' ');
const goi = (h, ten) => ten !== h.ten && new RegExp('\\b' + ten + '\\s*\\(').test(boChuoiNut(h.than));

/* ĐẺ ra việc mới, và SỬA việc đã có: hai lượt ghi khác nhau, hai đòi hỏi khác
   nhau. Đọc thì không tính. */
const DE  = /\.from\('task'\)\s*\n?\s*\.(insert|upsert)/;
const SUA = /\.from\('task'\)\s*\n?\s*\.(update|delete)/;

/* Hai bộ cửa hợp lệ, tính từ mã — xem đầu tệp. */
const NAP_LAI = new Set(['taiHomNay', ...HAM.filter(h => goi(h, 'taiHomNay')).map(h => h.ten)]);
const VE_LAI  = new Set(['veTasks',   ...HAM.filter(h => goi(h, 'veTasks')).map(h => h.ten)]);
const coNap = h => [...NAP_LAI].some(t => goi(h, t));
const coVe  = h => [...VE_LAI ].some(t => goi(h, t));

/* Hàm ghi thẳng mà KHÔNG tự lo lượt vẽ. Đây là hạt giống của mọi chuỗi đứt:
   cửa nào gọi tới một trong những hàm này thì gánh nợ thay nó. Hàm ghi thẳng
   mà tự lo được thì không có tên ở đây, và che luôn cho cửa gọi nó. */
const DE_HONG  = HAM.filter(h => DE.test(h.than)  && !coNap(h)).map(h => h.ten);
const SUA_HONG = HAM.filter(h => SUA.test(h.than) && !coNap(h) && !coVe(h)).map(h => h.ten);

/* MIỄN TRỪ — hàm ghi xuống `task` nhưng KHÔNG tự làm mới, kèm lý do. Thêm tên
   vào đây thì phải viết lý do; một danh sách miễn trừ không có lý do là một
   danh sách sẽ dài mãi. Miễn trừ chỉ tắt tiếng cho CHÍNH hàm ấy — nó vẫn
   truyền nợ sang cửa gọi nó, đúng như lý do "cửa gọi nó lo lượt vẽ" đã hứa. */
const MIEN_TRU = {
  /* ── Hàm phụ trợ: không phải cửa người dùng bấm ────────────────────────── */
  lcTheoViec:  'phụ trợ, chỉ gọi từ lcLuuDoi — cửa ấy đã làm mới ngay sau',
  lcTheoChuoi: 'phụ trợ, gọi từ lcLuuDoi và lcLuu — cả hai cửa đã làm mới ngay sau',
  lcDonViec:   'phụ trợ, dọn việc của buổi vừa xoá; cửa gọi nó lo lượt vẽ',
  ghiTaskMoi:  'phụ trợ dùng chung của themTask, vcLuu, dwThemLuu',
  datNghen:    'phụ trợ, trả true/false cho cửa gọi rồi cửa ấy tự quyết',
  lcDeViec:    'phụ trợ, đẻ việc cho một buổi; bốn cửa gọi nó lo lượt vẽ',
  /* Nối một việc CÓ SẴN vào sự kiện vừa tạo. Một chỗ gọi duy nhất — `lcLuu`,
     dòng ngay sau nó là `lcDongCua()` rồi `await lamMoiCuaToi()`. Bắt nó tự
     gọi thêm một lượt nữa là hỏi máy chủ hai lần cho cùng một cú bấm. */
  lcNoiViecCu: 'phụ trợ, chỉ gọi từ lcLuu — cửa ấy đã làm mới ngay sau',
  dwTraTTCu:   'phụ trợ, trả trạng thái cũ khi huỷ phiên',
  donLuu:      'phụ trợ của donHanhDong',
  duLuuDong:   'không cửa nào gọi — mã chờ dọn',

  /* ── Soi một lượt ở TRI-108: cửa THẬT, nhưng nằm ở màn khác ─────────────
     Bảng Hôm nay chỉ sống trong `man-homnay`. Rời khỏi đó là nó bị gỡ `hien`,
     tức không còn gì trên mặt kính để mà cũ; và đường quay lại duy nhất là
     `moTab('homnay')`, thứ nạp `taiHomNay()` mỗi lượt. Nên cửa nằm ở màn khác
     KHÔNG cần trả thêm một lượt truy vấn nào — đó cũng là lý do TRI-106 cố ý
     dừng phạm vi ở nhóm lịch thay vì vá cả loạt mười ba cửa. */
  duTickViec:   'màn Dự án (hồ sơ); moTab("homnay") nạp lại bảng lúc quay về',
  gnLuuMau:     'màn Ghi chú; moTab("homnay") nạp lại bảng lúc quay về',
  ckNoteLuuSua: 'cửa nổi của màn Cam kết; đã vá vật trong TASKS qua timTaskGC, '
              + 'và moTab("homnay") nạp lại lúc quay về',
  donHanhDong:  'màn Dọn phủ kín màn Hôm nay, và CẢ BA đường đóng nó '
              + '(donDong · htThoat · nút Đóng của htGuong) đều gọi taiHomNay()',

  /* ── Hàm VẼ, lọt lưới vì giới hạn ② ở đầu tệp ──────────────────────────── */
  veDongTaskCK: 'hàm vẽ — "datHanKho(…)" nằm trong một chuỗi HTML truyền cho '
              + 'oNgay(), không phải một lời gọi thật',
};

console.log('\n① Cửa ĐẺ ra việc mới phải NẠP LẠI bảng Hôm nay, không chỉ vẽ lại');
{
  const thieu = [];
  for (const h of HAM){
    const de = DE_HONG.includes(h.ten) || DE_HONG.some(t => goi(h, t));
    if (de && !coNap(h) && !MIEN_TRU[h.ten]) thieu.push(h.ten);
  }
  la('không cửa nào đẻ việc rồi bỏ mặc bảng Hôm nay',
     thieu.length === 0,
     thieu.length ? 'Đẻ mà không nạp lại: ' + thieu.join(', ')
       + '\n         Việc vừa sinh KHÔNG có đường nào vào `TASKS` — `veTasks()` sẽ vẽ lại đúng mảng cũ.'
       + '\n         Thêm `await taiHomNay()` (hoặc `lamMoiCuaToi()`), hoặc kê tên vào MIEN_TRU kèm lý do.' : '');
}

console.log('\n② Cửa SỬA việc phải ít nhất vẽ lại bảng');
{
  const thieu = [];
  for (const h of HAM){
    const sua = SUA_HONG.includes(h.ten) || SUA_HONG.some(t => goi(h, t));
    if (sua && !coNap(h) && !coVe(h) && !MIEN_TRU[h.ten]) thieu.push(h.ten);
  }
  la('không hàm nào sửa việc mà bỏ quên bảng Hôm nay',
     thieu.length === 0,
     thieu.length ? 'Thiếu đường về: ' + thieu.join(', ')
       + '\n         Vá vật trong `TASKS` rồi gọi `veTasks()`, hoặc `lamMoiCuaToi()`,'
       + '\n         hoặc kê tên vào MIEN_TRU kèm lý do.' : '');
}

console.log('\n③ `lamMoiCuaToi` phải thật sự kéo theo bảng Hôm nay');
{
  const h = HAM.find(x => x.ten === 'lamMoiCuaToi');
  la('hàm tồn tại', !!h);
  if (h){
    la('có gọi `taiHomNay`', /taiHomNay\s*\(/.test(h.than),
       'Đây chính là chỗ hỏng của TRI-106: hàm chỉ nuôi màn Của tôi, mà sáu cửa lại dùng nó để làm mới bảng Hôm nay.');
    la('chỉ tải khi màn Hôm nay đang hiện', /man-homnay/.test(h.than),
       'Thiếu phép soi này thì mọi chỗ gọi đều trả tiền cho một lượt truy vấn không ai nhìn.');
  }
}

console.log('\n④ `TASKS` vẫn chỉ có một chỗ nạp — nền của cả ba phép kiểm trên');
{
  const soCho = (SRC.match(/^\s*TASKS\s*=\s/gm) || []).length;
  la('đúng một chỗ gán `TASKS`', soCho === 1,
     'Đếm được ' + soCho + '. Có chỗ nạp thứ hai thì hai chỗ sớm muộn lệch nhau, và phép kiểm ① không còn đủ.');
}

console.log('\n⑤ Danh sách miễn trừ không được mọc thêm tên chết');
{
  const chet = Object.keys(MIEN_TRU).filter(t => !HAM.some(h => h.ten === t));
  la('mọi tên trong MIEN_TRU vẫn còn trong mã', chet.length === 0,
     chet.length ? 'Không còn hàm nào tên: ' + chet.join(', ')
       + '\n         Hàm đã đổi tên hoặc bị xoá — gỡ dòng miễn trừ ra, đừng để nó che một chỗ không tồn tại.' : '');
}

console.log('\n' + (truot ? `❌ ${truot} chỗ chưa đạt (${dat} đạt)` : `✅ Đủ cả ${dat} phép kiểm`));
process.exit(truot ? 1 : 0);
