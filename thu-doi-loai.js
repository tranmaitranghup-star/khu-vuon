/* THỬ: ĐỔI LOẠI VIỆC ↔ SỰ KIỆN
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09: *"ở cửa sổ việc tôi muốn có nút chuyển nó thành sự kiện và ngược
   lại để đề phòng là mọi người chọn nhầm lúc tạo sự kiện/việc"*.

   Luật cốt lõi của cả hai chiều là MỘT CÂU: **không bỏ dòng việc đi bao giờ.**
   `phien_deepwork.task_id` khai `on delete cascade`, nên xoá một dòng việc là
   xoá luôn mọi phiên deep work gắn vào nó và cái cây nó đã trồng. Cả hai chiều
   vì thế chỉ NỐI hoặc CẮT hai cột `lich_id`/`lich_ngay`, không dựng lại gì.

   Bài thử canh đúng câu ấy, cộng bốn chỗ nó dễ tuột:
     · cờ `TV_SANG_SK` sống sót qua một cửa đã đóng → sự kiện sau lôi nhầm việc;
     · nhánh insert quên `.select('id')` → có sự kiện mà không có gì để nối;
     · nối SAU `lcDongCua` → đọc phải một cờ vừa bị dọn;
     · hai ô giờ đặt ngược thứ tự → độ dài buổi về lại 60 phút.

   Chạy:  node production/tinh-thuc-app/thu-doi-loai.js
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
/* Cắt nguyên một hàm ra khỏi mã, từ dòng khai tới dấu `}` đứng ở cột 0. Lấy mã
   THẬT chứ không chép tay một bản thứ hai: bản chép là bản sẽ trôi khỏi bản gốc
   mà bài thử vẫn xanh. */
function layHam(ten){
  const m = SRC.match(new RegExp('^(?:async )?function ' + ten + '\\(', 'm'));
  if (!m) throw new Error('Khong thay ham: ' + ten);
  const i = m.index;
  const j = SRC.indexOf('\n}\n', i);
  if (j < 0) throw new Error('Khong thay duoi ham: ' + ten);
  return SRC.slice(i, j + 3);
}

/* ── ① HAI NÚT ĐỨNG ĐÚNG HAI CỬA ─────────────────────────────────────────── */
console.log('\n① Hai nút — mỗi cửa một chiều, và chúng gọi đúng hàm');
la('cửa Thông tin việc có nút gọi tvSangSuKien',
   /nutCho\(this,'',tvSangSuKien\)/.test(SRC));
la('cửa buổi có nút gọi lcSangViec',
   /nutCho\(this,'',lcSangViec\)/.test(SRC));
la('nút ở cửa buổi chỉ dựng trong nhánh laHost',
   / laHost\n\s*\? `<button[\s\S]{0,600}?lcSangViec[\s\S]{0,400}?\n\s*: '';/.test(SRC),
   'nút đổi loại phải nằm trong cùng nhánh quyền với bút sửa và thùng rác');
la('nút đổi loại KHÔNG mang lớp .pha',
   !/nut-hinh pha[^>]*aria-label="Chuyển thành/.test(SRC),
   'đỏ dành cho thao tác không lùi được; đổi loại thì lùi được');

/* ── ② CỜ ĐỔI LOẠI PHẢI CHẾT THEO CỬA ────────────────────────────────────── */
console.log('\n② Cờ TV_SANG_SK — sống sót một cửa đã đóng là sự kiện sau lôi nhầm việc');
la('lcDongCua dọn cờ', /function lcDongCua\(\)\{[\s\S]{0,400}?TV_SANG_SK = null;/.test(SRC));
la('vcLuuSuKien dọn cờ', /TV_SANG_SK = null;/.test(layHam('vcLuuSuKien')),
   'cửa gộp đi thẳng vào lcLuu, không qua lcMoForm — nó phải tự dọn');

/* ── ③ ĐƯỜNG NỐI TRONG lcLuu ─────────────────────────────────────────────── */
console.log('\n③ lcLuu — có id để nối, và nối trước khi cửa đóng');
const LUU = layHam('lcLuu');
la('nhánh THÊM MỚI lấy id về', /insert\(\{\.\.\.dong[^)]*\}\)\.select\('id'\)/.test(LUU),
   "thiếu .select('id') thì có sự kiện mà không có gì để nối việc vào");
la('nối việc TRƯỚC lcDongCua',
   LUU.indexOf('lcNoiViecCu') > 0 && LUU.indexOf('lcNoiViecCu') < LUU.indexOf('lcDongCua();'),
   'lcDongCua dọn cờ, đọc sau là đọc null');
la('chỉ nối ở nhánh THÊM MỚI', /daSua \? null : TV_SANG_SK/.test(LUU),
   'nhánh SỬA đã có LC_SUA trong tay, nối thêm là ghi đè một dòng việc đang sống');

/* ── ④ tvSangSuKien — lưu trước, và hai ô giờ đúng thứ tự ────────────────── */
console.log('\n④ tvSangSuKien — không vứt thứ vừa gõ, không mất độ dài buổi');
const SANG = layHam('tvSangSuKien');
la('chặn việc chưa có ngày', /tv-ngay[\s\S]{0,200}?Sự kiện phải có ngày/.test(SANG));
la('gọi tvLuu trước khi mở cửa kia',
   SANG.indexOf('await tvLuu()') > 0 && SANG.indexOf('await tvLuu()') < SANG.indexOf('lcMoForm(0)'));
la('đặt giờ ĐẦU trước giờ CUỐI',
   SANG.indexOf("gioDat('lc-gio',") < SANG.indexOf("gioDat('lc-gio-den',"),
   'gioDat móc vào lcDongBoPhut — đảo thứ tự là độ dài buổi về lại 60 phút');
la('KHÔNG ép ô Loại — cửa mở ra như mọi lối khai sự kiện khác',
   !/lc-loai/.test(SANG),
   'Tracy 05/09: "sự kiện thường đi — app dùng chính cho công ty mà". Một lối vào '
   + 'mang mặc định riêng là cùng một biểu mẫu có hai bộ mặt tuỳ đường đi tới');

/* ── ⑤ KHÔNG CHIỀU NÀO ĐƯỢC BỎ DÒNG VIỆC ĐI ──────────────────────────────── */
console.log('\n⑤ Luật một câu: không chiều nào xoá một dòng việc');
const LAM = layHam('lcSangViecLam');
la('chiều sự kiện → việc không có câu xoá nào',
   !/from\('task'\)[\s\S]{0,80}?\.delete\(/.test(LAM),
   "phien_deepwork.task_id khai on delete cascade — xoá việc là mất giờ đã cày");
la('chiều sự kiện → việc chỉ cắt hai cột',
   /update\(\{lich_id: null, lich_ngay: null\}\)/.test(LAM));
la('dòng lịch được NGƯNG chứ không xoá',
   /update\(\{dang_dung: false/.test(LAM) && !/from\('lich_chung'\)[\s\S]{0,60}?\.delete\(/.test(LAM),
   'xoá là đứt luôn ô tick tham dự của mọi buổi đã qua');
la('hỏi máy chủ tìm việc cũ, không tin bản tra trong máy',
   /from\('task'\)[\s\S]{0,200}?\.eq\('lich_id', id\)/.test(LAM),
   'LC_VIEC chỉ giữ việc của dải đang vẽ — đọc hụt là đẻ ra dòng việc thứ hai');

/* ── ⑥ CHẶN SỰ KIỆN ĐỊNH KỲ ──────────────────────────────────────────────── */
console.log('\n⑥ lcSangViec — một luật lặp không rút về một việc được');
const HOI = layHam('lcSangViec');
la('chặn khi lap khác "khong"', /l\.lap !== 'khong'/.test(HOI));
la('hỏi lại quyền dù nút đã gác', /lcDuocSua\(l\)/.test(HOI),
   'một hàm không nên tin cái nút gọi nó');
la('chặn ĐỨNG TRƯỚC hộp xác nhận',
   HOI.indexOf("l.lap !== 'khong'") < HOI.indexOf('hopHoiMo('),
   'hỏi rồi mới chặn là bắt người ta bấm Chuyển để nhận về một câu từ chối');

/* ── ⑦ lcNoiViecCu — CHẠY THẬT, so từng cột ghi xuống ────────────────────── */
console.log('\n⑦ lcNoiViecCu chạy thật — dòng việc phải mang đúng bộ cột của một việc-của-buổi');
{
  const ghi = [];
  const moiTruong = {
    tlgHHMM: p => String(Math.floor(p/60)).padStart(2,'0') + ':' + String(p%60).padStart(2,'0'),
    lcGioCong: (hhmm, phut) => {
      const [h, m] = hhmm.split(':').map(Number);
      const t = (h*60 + m + phut) % 1440;
      return String(Math.floor(t/60)).padStart(2,'0') + ':' + String(t%60).padStart(2,'0');
    },
    CO_GIO_SE: true, CO_MAU: true, LC_VIEC: {}, tlQuenKho(){}, toast(c){ ghi.push('toast:' + c); },
    baoLoiTask: e => e.message,
    sb: {from: () => ({update(p){ ghi.push(p); return {eq: async () => ({error: null})}; }})}
  };
  const chay = new Function(...Object.keys(moiTruong),
    layHam('lcNoiViecCu') + '\nreturn lcNoiViecCu;')(...Object.values(moiTruong));

  const dong = {ten: 'Họp tuần', gio_bat_dau: 9*60 + 30, so_phut: 45,
                ngay_bat_dau: '2026-09-10', mau: 'xanh', rieng_tu: false};
  chay(77, 501, dong).then(() => {
    const p = ghi.find(x => typeof x === 'object');
    la('nối đúng buổi', !!p && p.lich_id === 501 && p.lich_ngay === '2026-09-10');
    la('ngày việc theo ngày mở chuỗi', !!p && p.ngay === '2026-09-10');
    la('giờ ghi song song cả deadline lẫn gio_start',
       !!p && p.deadline === '09:30' && p.gio_start === '09:30',
       'việc đẻ từ lịch mà deadline rỗng là loại việc mọi màn đọc hụt — TRI-63');
    la('giờ kết thúc cộng đúng thời lượng', !!p && p.gio_end === '10:15');
    la('thời lượng theo sự kiện', !!p && p.thoi_luong_du_kien === 45);
    la('màu mượn của sự kiện', !!p && p.mau === 'xanh');

    ghi.length = 0;
    chay(77, 501, {...dong, rieng_tu: true, mau: null}).then(() => {
      const q = ghi.find(x => typeof x === 'object');
      la('buổi riêng thì việc của nó màu hồng', !!q && q.mau === 'hong',
         "ghi 'tim' vào việc cá nhân là cất một giá trị màn hình không bao giờ bày");

      ghi.length = 0;
      chay(77, null, dong).then(() => {
        la('thiếu id sự kiện thì NÓI RA, không im lặng',
           ghi.some(x => typeof x === 'string' && /chưa nối vào/.test(x)),
           'im lặng ở đây là một việc nằm lạc khỏi buổi của nó, không dấu vết nào');
        xong();
      });
    });
  });
}

function xong(){
  console.log(truot ? `\n❌ ${truot} ca trượt, ${dat} ca đạt.` : `\n✅ ${dat} ca đạt.`);
  process.exit(truot ? 1 : 0);
}
