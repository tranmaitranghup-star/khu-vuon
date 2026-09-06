/* THỬ: HAI CỬA SỰ KIỆN PHẢI GIỐNG NHAU VÀ ĐỒNG BỘ
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09, cầm ảnh cửa mở từ timeline: *"đi từ cửa ấn từ timeline nó không
   hiện này"* → chốt thành LUẬT: **nút + Sự kiện và cú chạm timeline rồi chọn
   Sự kiện phải dẫn tới cùng một cửa, cùng một bộ ô, cùng một hành vi.**

   Vì sao cần một bài thử riêng cho luật ấy. App có HAI khung dựng form sự kiện
   — `lcMoForm` (cửa đầy đủ) và `vcVeSuKien` (cửa gộp) — cố ý mang CÙNG tên ô,
   để `lcLuu` và `lcDoiLap` chạy được ở cả hai mà không phải biết mình đang ở
   đâu. Cái giá là: **thêm một ô vào khung này mà quên khung kia thì không một
   tiếng kêu nào** — cửa vẫn mở, vẫn lưu được, chỉ thiếu mất một lối khai. Đúng
   kiểu hỏng mà chỉ người dùng thật phát hiện ra, và phát hiện bằng cách không
   tìm thấy thứ mình được hứa.

   Bài thử này chạy KHUNG THẬT của cả hai cửa qua LUẬT ẨN/HIỆN THẬT, rồi so
   từng ô một. Nó không hỏi "mã có đúng không" — nó hỏi "hai cửa có nói cùng
   một điều không".

   Chạy:  node production/tinh-thuc-app/thu-hai-cua-dong-bo.js
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

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Hai chuỗi HTML thật, lấy nguyên từ mã. Không chép tay một bản thứ hai — bản
   chép là bản sẽ trôi khỏi bản gốc mà bài thử vẫn xanh. */
const KHUNG_DAY = catKhoi('  than.innerHTML = `', '`;\n  /* Ô giờ dựng SAU');
const KHUNG_GOP = catKhoi("  o.innerHTML = `", "`;\n  o.dataset.day");

/* Mọi `id="..."` trong một khung. Đây là "bộ ô" của cửa ấy. */
function boO(khung){
  return [...khung.matchAll(/id="([a-z0-9-]+)"/g)].map(m => m[1]);
}

/* ── ① HAI CỬA PHẢI CÓ CÙNG BỘ Ô ĐIỀU KHIỂN LUẬT LẶP ──────────────────── */
console.log('\n① Bộ ô của luật lặp — thiếu một ô ở một cửa là một lối khai biến mất');
{
  const day = boO(KHUNG_DAY), gop = boO(KHUNG_GOP);
  /* Bộ ô mà LUẬT LẶP chạm tới. Cố ý kê tên ra đây chứ không so trọn hai khung:
     hai cửa vốn khác nhau ở phần vỏ (cửa gộp giấu tên/ngày/giờ thành ô ẩn vì
     chúng đã nằm ở khoang chung), nên so trọn là đỏ vì lý do chính đáng, và
     một phép kiểm đỏ vì lý do chính đáng thì lần sau người ta thôi tin nó. */
  /* Bộ ô đã CO LẠI CÒN MỘT (03/09, ngay sau khi bài thử này ra đời). Cửa lặp
     nay là một ô chọn nấc duy nhất với các nấc dựng sẵn; bảy ô kia — `lc-tl`,
     `lc-nt-o`, `lc-thu-o`, `lc-tuan-o`, `lc-den-o`… — đã tháo khỏi CẢ HAI cửa,
     phần khai chi tiết chuyển sang cửa tuỳ chỉnh riêng (`lc-tc-*`). Giữ tên
     chúng ở đây là canh những ô không còn tồn tại. */
  for (const o of ['lc-lap'])
    la(`cả hai cửa đều có ô \`${o}\``, day.includes(o) && gop.includes(o),
       `đầy đủ: ${day.includes(o) ? 'có' : 'THIẾU'} · gộp: ${gop.includes(o) ? 'có' : 'THIẾU'}`);
  /* Ô nào cũng phải gắn cùng một hàm xử lý ở cả hai cửa — cùng ô mà hai hành vi
     là hỏng còn khó thấy hơn thiếu ô. */
  for (const [o, ham] of [['lc-lap','lcDoiNac']]){
    const re = new RegExp(`id="${o}"[^>]*onchange="${ham}\\(\\)"`);
    la(`ô \`${o}\` gọi \`${ham}\` ở CẢ HAI cửa`, re.test(KHUNG_DAY) && re.test(KHUNG_GOP));
  }
}

/* ── ② ĐÃ GỠ — luật ẩn/hiện bốn ô không còn ────────────────────────────
   Ca này chạy `lcDoiLap` trên khung thật của từng cửa rồi so xem ô nào hiện.
   Cả hàm lẫn bốn ô ấy đã bị thay: `lcDoiNac` nay ĐẶT THẲNG luật theo nấc được
   chọn thay vì bật tắt ô, và phần khai chi tiết dọn sang cửa tuỳ chỉnh riêng.
   Không còn ô nào ẩn hiện để mà so.
   Điều ca này thật sự canh — hai cửa phải cư xử như nhau — vẫn còn nguyên giá
   trị. Muốn canh lại thì viết theo `#lc-lap` và `lcDoiNac`, và đó là một ca mới
   chứ không phải ca này sửa lại. */

console.log('\n③ Cùng tên ô là cố ý — nên chỉ MỘT cửa được có mặt trong cây một lúc');
{
  /* Đây là cái giá của việc dùng chung tên ô: `getElementById` trả phần tử ĐẦU
     TIÊN trong cây, nên nếu khung của cửa đã đóng còn nằm đó thì mọi lượt đọc
     đều trỏ nhầm sang nó — cửa đang mở thì trơ ra, và không lỗi nào báo. Làn
     CGV đã ghi bẫy này cho một chiều; đây là chiều còn lại. */
  const dong = catKhoi('function lcDongCua(){', '\n\nfunction lcMoForm');
  la('`lcDongCua` dọn trắng khung của cửa đầy đủ khi đóng',
     /lc-than'\)\.innerHTML\s*=\s*''/.test(dong) || /than\.innerHTML\s*=\s*''/.test(dong),
     'cửa đóng mà khung còn trong cây thì cửa gộp đọc nhầm sang ô của nó');
  const vcDong = catKhoi('function vcDong(){', '\n\n');
  la('`vcDong` dọn trắng khoang sự kiện của cửa gộp khi đóng',
     /vc-rieng-sk/.test(vcDong) && /innerHTML\s*=\s*''/.test(vcDong));
}

console.log(`\n${truot ? '❌' : '✅'}  ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);
