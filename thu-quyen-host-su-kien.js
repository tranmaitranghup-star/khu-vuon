/* THỬ: CHỈ HOST MỚI ĐỔI ĐƯỢC THÔNG TIN VÀ THỜI GIAN CỦA MỘT SỰ KIỆN
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 04/09 (TRI-98): *"với các sự kiện thì chỉ có host mới có thể thay đổi
   thông tin và thời gian"*.

   VÌ SAO CẦN BÀI THỬ, chứ không chỉ bấm thử một lượt: mọi máy trong đội hôm nay
   đều đang bật cờ `la_lead`, nên NGƯỜI THỬ LÚC NÀO CŨNG LÀ LEAD. Mở app ra bấm
   thì luật cũ và luật mới cho ra cùng một màn hình đối với chính người đang bấm
   — chỉ khác nhau ở màn của người khác, thứ không ai nhìn thấy. Đây là hình
   dạng lỗi mà thử tay không bắt được, nên phải soi thẳng vào mã.

   Bốn ca đáng giá nhất:

     · BỐN CỬA, KHÔNG PHẢI MỘT. Người ta đổi được một sự kiện qua bốn lối: nút
       ✏️ trong cửa buổi · nút 🗑 · kéo khối trên lưới giờ · kéo dải cả ngày.
       Siết ba lối mà quên một là siết hụt — và lối còn hở thường là lối kéo,
       vì nó không có nút nào để nhìn thấy mà quên.

     · MẶT HÌNH KHÔNG PHẢI HÀNG RÀO. Giấu cái nút chỉ ngăn người ta bấm nhầm.
       Hàng rào thật là ba chính sách RLS, và chúng phải hết nhắc `la_lead`.

     · QUYỀN ĐỌC KHÔNG ĐƯỢC SIẾT THEO. Cả đội vẫn phải thấy mọi lịch để tránh
       trùng giờ, và lead vẫn đọc được bảng điểm danh có tên. Siết nhầm sang
       quyền nhìn là hỏng một thứ Tracy không yêu cầu đổi.

     · MỘT CÂU, MỘT CHỖ. Luật này từng nằm chép tay ở bốn chỗ trong `index.html`;
       chép tay thì lần đổi sau chỉ sửa được ba. Nay cả bốn gọi `lcDuocSua`.

   Chạy:  node production/tinh-thuc-app/thu-quyen-host-su-kien.js
*/
const fs = require('fs');
const path = require('path');
const GOC = process.env.THU_GOC || __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(GOC, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(GOC, 'nang-cap-quyen-host-su-kien.sql'), 'utf8');

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

/* ── ① MỘT CÂU DUY NHẤT, Ở ĐÚNG MỘT CHỖ ─────────────────────────────────── */
console.log('\n① Luật nằm ở đúng một chỗ — `lcDuocSua`');
{
  const ham = catKhoi('function lcDuocSua(l){', '\n}');
  la('lcDuocSua chỉ hỏi `tao_boi === ME.id`',
     /return\s*!!\(ME\s*&&\s*l\s*&&\s*l\.tao_boi\s*===\s*ME\.id\);/.test(ham),
     'còn vế nào khác là còn một đường vòng qua luật');
  la('lcDuocSua KHÔNG còn nhắc `la_lead`',
     !/la_lead/.test(ham),
     'cả 7 người trong đội đều bật cờ này — còn nó thì luật không siết được gì');
}

/* ── ② BỐN CỬA ĐỔI SỰ KIỆN ĐỀU ĐI QUA HÀM ẤY ────────────────────────────── */
console.log('\n② Bốn lối đổi một sự kiện đều gọi cùng một hàm');
{
  const luoi = catKhoi('function lcCuaNgayTu(', '\nfunction lcLuotDai');
  la('khối giờ trên lưới: `sua: lcDuocSua(l)`',
     /sua:\s*lcDuocSua\(l\)/.test(luoi),
     'tay nắm kéo–giãn của khối giờ đang đọc một câu chép tay khác');

  const dai = catKhoi('function lcDaiCuaKhung(', '\nfunction lcRanhNhom');
  la('dải cả ngày: `sua: lcDuocSua(l)`',
     /sua:\s*lcDuocSua\(l\)/.test(dai),
     'lối kéo dải cả ngày là lối dễ quên nhất — không có nút nào để nhìn thấy');

  const cua = catKhoi('function lcMoBuoi(', '\n/* ── GHI CHÚ CỦA HOST');
  la('cửa buổi: `laHost = lcDuocSua(l)`',
     /const\s+laHost\s*=\s*lcDuocSua\(l\);/.test(cua),
     'laHost tự khai lại luật thì hai nơi sẽ trôi khác nhau');
  la('hàng nút ✏️ · 🗑 dựng theo `laHost`, không theo `laChu`',
     /innerHTML\s*=\s*laHost\s*\n?\s*\?\s*`<button class="nut-hinh" aria-label="Sửa cả chuỗi"/.test(cua),
     'lead sẽ vẫn thấy bút và thùng rác trên sự kiện của người khác');
  la('nút 🗑 Xoá đi cùng nút ✏️ trong đúng một nhánh quyền',
     /laHost[\s\S]{0,600}aria-label="Xoá sự kiện"/.test(cua),
     'xoá là một cách đổi sự kiện của người khác, chỉ bằng đường khác');
}

/* ── ③ KHÔNG CÒN CHỖ NÀO CHÉP TAY LUẬT SỬA ──────────────────────────────── */
console.log('\n③ Không còn bản chép tay nào của luật cũ');
{
  const chepTay = [...SRC.matchAll(/tao_boi === ME\.id \|\| ME\.la_lead !== false/g)];
  la('chỉ còn ĐÚNG MỘT chỗ ghép `tao_boi` với `la_lead`',
     chepTay.length === 1,
     'đếm được ' + chepTay.length + ' — mỗi bản chép là một chỗ lần sau quên sửa');

  /* Chỗ duy nhất còn lại là bảng điểm danh, và nó ở lại CÓ CHỦ Ý: đó là quyền
     ĐỌC. Neo phép kiểm vào `diemDanh` để nếu ai đó dùng lại `laChu` cho một cú
     GHI thì bài thử này đỏ lên, thay vì đếm số cho qua chuyện.
     ⚠️ ĐẾM TRÊN BẢN ĐÃ GỠ CHÚ THÍCH. Bản đầu đếm thẳng trên mã và đỏ oan: chú
     thích quanh đó nhắc tên `laChu` bốn lần để giải thích vì sao nó ở lại, và
     mỗi lần nhắc bị tính là một lần dùng. Một phép kiểm đọc cả lời giải thích
     về chính nó thì càng viết rõ càng đỏ — đúng chiều ngược với cái mình muốn. */
  const cua = catKhoi('function lcMoBuoi(', '\n/* ── GHI CHÚ CỦA HOST')
                .replace(/\/\*[\s\S]*?\*\//g, '');
  const dungLaChu = [...cua.matchAll(/\blaChu\b/g)].length;
  la('trong cửa buổi, `laChu` chỉ còn dùng cho bảng điểm danh',
     /const\s+diemDanh\s*=\s*laChu\s*&&/.test(cua) && dungLaChu === 2,
     'đếm được ' + dungLaChu + ' lần dùng `laChu` trong mã (đúng phải là 2: '
     + 'một chỗ khai, một chỗ dùng cho bảng điểm danh)');
}

/* ── ④ QUYỀN ĐỌC KHÔNG BỊ SIẾT THEO ─────────────────────────────────────── */
console.log('\n④ Siết quyền SỬA, không siết quyền NHÌN');
{
  const choToi = catKhoi('function lcChoToi(l){', '\n}');
  la('lcChoToi vẫn để nhóm coreteam lọc theo cờ lead',
     /pham_vi === 'coreteam'\) return !!\(ME && ME\.la_lead !== false\)/.test(choToi),
     'đây là ai NHẬN được sự kiện, không phải ai sửa được nó');

  const cua = catKhoi('function lcMoBuoi(', '\n/* ── GHI CHÚ CỦA HOST');
  la('bảng điểm danh có tên vẫn mở cho lead',
     /const\s+laChu\s*=\s*!!\(ME && \(l\.tao_boi === ME\.id \|\| ME\.la_lead !== false\)\)/.test(cua),
     'Tracy siết quyền sửa, không siết quyền đọc ai vắng ai có');
}

/* ── ⑤ HÀNG RÀO THẬT — BA CHÍNH SÁCH Ở MÁY CHỦ ──────────────────────────── */
console.log('\n⑤ Hàng rào máy chủ: ba chính sách, hết nhắc la_lead');
{
  const than = SQL.slice(SQL.indexOf('begin;'), SQL.indexOf('commit;'));
  la('tệp SQL dựng lại cả ba chính sách ghi',
     /create policy sua_lich/.test(than)
     && /create policy xoa_lich/.test(than)
     && /create policy ghi_lich_ngoai/.test(than),
     'thiếu chính sách nào là còn một đường ghi chưa siết');
  la('không chính sách nào trong tệp còn gọi `la_lead()`',
     !/la_lead\(\)/.test(than),
     'còn một lần gọi là còn cửa cho mọi người mang cờ lead');
  la('sua_lich giữ CẢ HAI vế using và with check',
     /create policy sua_lich[\s\S]*?using[\s\S]*?with check/.test(than),
     'thiếu `with check` thì host đổi được `tao_boi` sang tên người khác');
  la('ghi_lich_ngoai soi ngược về `tao_boi` của dòng lịch cha',
     /ghi_lich_ngoai[\s\S]*?l\.tao_boi = nguoi_id_dang_nhap\(\)/.test(than),
     'cú kéo một buổi sang chỗ khác ghi xuống bảng này, không ghi vào lich_chung');
  la('quyền TẠO không bị đụng tới trong tệp này',
     !/create policy them_lich/.test(than) && !/drop policy if exists them_lich/.test(than),
     'ai cũng phải còn tạo được sự kiện của mình — Tracy không yêu cầu đổi chỗ đó');
  la('tệp có phần TỰ KIỂM để dán vào Supabase là biết chạy được chưa',
     /TỰ KIỂM/.test(SQL) && /as t\(so, muc, dat\)/.test(SQL),
     'không có nó thì chạy xong không ai biết nó đã ăn hay chưa');
}

console.log(`\n${truot ? '❌' : '✅'}  ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);
