/* THỬ: CẢ TỆP CÒN CHẠY ĐƯỢC KHÔNG — soát cú pháp mọi khối <script> trong app
   ─────────────────────────────────────────────────────────────────────────────
   VÌ SAO CÓ BÀI NÀY. Ngày 03/09 một chú thích `<!-- … -->` nằm giữa một chuỗi
   mẫu mang một cặp DẤU HUYỀN quanh tên một tệp .sql. Dấu huyền đóng chuỗi ngay
   tại đó, khối <script> 20 nghìn dòng chết theo, và app lên sóng ở trạng thái
   màn trắng. Nó lọt qua CẢ HAI hàng rào đang có:

     · Bộ thử node không bắt được, vì mọi bài thử đều `catHam`/`catKhoi` rồi
       `new Function` từng LÁT CẮT — lát cắt nào không chứa chỗ hỏng thì vẫn
       xanh, và cả bộ vẫn xanh trong khi app đã chết.
     · Người soát cũng không thấy: chỗ hỏng nằm trong một chú thích, tức đúng
       cái nơi mắt lướt qua.

   Đây là lần THỨ BA cùng một lỗi (làn SG 01/09 · làn RA 03/09 · làn CGV 03/09).
   Một cái bẫy cắn ba lần thì nó không còn là chuyện nhớ hay quên nữa — phải có
   máy canh. Bài này là cái máy ấy: nó không hỏi mã LÀM ĐÚNG không, chỉ hỏi mã
   CÒN ĐỌC ĐƯỢC không. Rẻ, và chặn đúng loại hỏng đắt nhất.

   Chạy:  node production/tinh-thuc-app/thu-cu-phap.js
*/
const fs = require('fs');
const path = require('path');
const vm = require('vm');
const DUONG = process.env.THU_FILE || path.join(__dirname, 'public/index.html');
const SRC = fs.readFileSync(DUONG, 'utf8');
const DONG = SRC.split('\n');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Cắt theo THẺ ĐỨNG ĐẦU DÒNG, không bằng biểu thức chính quy quét cả tệp: chữ
   "<script>" còn xuất hiện bên trong vài chú thích, và một phép quét thô sẽ
   nhận nhầm chúng rồi báo đỏ ở chỗ chẳng có gì sai. */
function catKhoiScript(){
  const ra = [];
  let dau = -1;
  DONG.forEach((d, i) => {
    if (dau < 0){
      if (/^<script(\s|>)/.test(d) && !/\bsrc=/.test(d)) dau = i;
    } else if (/^<\/script>/.test(d)){
      ra.push({tu: dau + 2, ma: DONG.slice(dau + 1, i).join('\n')});   // tu: số dòng 1-based
      dau = -1;
    }
  });
  if (dau >= 0) ra.push({tu: dau + 2, ma: DONG.slice(dau + 1).join('\n'), ho: true});
  return ra;
}

console.log('\n① Mọi khối <script> trong app phải đọc được');
{
  const khoi = catKhoiScript();
  la('tìm thấy đúng hai khối mã trong trang', khoi.length === 2,
     'thấy ' + khoi.length + ' — thẻ <script> đổi chỗ thì sửa phép cắt, đừng bỏ bài thử');
  la('không khối nào thiếu thẻ đóng', khoi.every(k => !k.ho));

  khoi.forEach((k, i) => {
    let loi = null;
    try { new vm.Script(k.ma, {filename: 'khoi' + (i+1)}); }
    catch (e) { loi = e; }
    /* Số dòng của lỗi tính theo khối, cộng lại thành số dòng trong tệp để người
       đọc nhảy thẳng tới chỗ hỏng, không phải đi đếm. */
    const chi = loi && loi.stack
      ? (m => m ? ' — dòng ' + (k.tu + (+m[1]) - 1) + ' của tệp: ' + DONG[k.tu + (+m[1]) - 2].trim().slice(0,70) : '')
        (/khoi\d+:(\d+)/.exec(loi.stack)) : '';
    la('khối mã bắt đầu ở dòng ' + k.tu + ' đọc được', !loi,
       loi ? loi.message + chi : '');
  });
}

/* ── ② CÁI BẪY ĐÃ CẮN BA LẦN, GỌI THẲNG TÊN NÓ ──────────────────────────── */
console.log('\n② Không dấu huyền trong chú thích <!-- --> nằm giữa một chuỗi mẫu');
{
  /* Quét từng chú thích HTML nằm trong mã. Chú thích trong một chuỗi mẫu là
     chuyện thường và đúng — chỉ DẤU HUYỀN trong đó mới là thứ giết cả khối. */
  const xau = [];
  catKhoiScript().forEach(k => {
    const d0 = k.tu;
    for (const m of k.ma.matchAll(/<!--[\s\S]*?-->/g)){
      if (m[0].includes('`'))
        xau.push('dòng ' + (d0 + k.ma.slice(0, m.index).split('\n').length - 1)
                 + ': ' + m[0].split('\n').find(l => l.includes('`')).trim().slice(0, 70));
    }
  });
  la('không chú thích nào trong mã mang dấu huyền', xau.length === 0,
     xau.join('\n       → '));
}

/* ── ③ MỘT CHỮ CHO MỘT THỨ: "team", KHÔNG "đội" ─────────────────────────── */
console.log('\n③ Chữ hiện ra màn hình gọi tập thể là "team"');
{
  /* Tracy 03/09: *"bạn dùng từ cả đội, cả nhóm... loạn hết lên, thống nhất
     dùng từ Toàn team"*. Ba chữ cho một thứ thì người đọc phải tự đoán chúng
     có phải một thứ không — và đoán là chỗ hiểu sai bắt đầu.
     Quét CHỮ HIỆN RA MÀN, không quét chú thích: chú thích viết cho người sửa
     mã, ở đó "đội" vẫn đọc tự nhiên và bắt nó đổi theo là làm phiền vô ích.
     Phải BỎ CHÚ THÍCH BẰNG MÁY TRẠNG THÁI chứ không bằng "dòng nào mở đầu
     bằng dấu chú thích": bản đầu làm vậy và báo đỏ năm chỗ hoàn toàn lành —
     dòng GIỮA một khối chú thích không mang dấu nào ở đầu, và chú thích cuối
     dòng thì đứng sau mã. Giữ nguyên ký tự xuống dòng để số dòng còn đúng. */
  const boChuThich = (v) => {
    let ra = '', i = 0, trong = null;
    while (i < v.length){
      if (trong){
        const het = trong === 'khoi' ? '*/' : trong === 'html' ? '-->' : '\n';
        if (v.startsWith(het, i)){ trong = null; i += het.length; if (het === '\n') ra += '\n'; continue; }
        if (v[i] === '\n') ra += '\n';
        i++; continue;
      }
      if (v.startsWith('/*', i)){ trong = 'khoi'; i += 2; continue; }
      if (v.startsWith('<!--', i)){ trong = 'html'; i += 4; continue; }
      /* Cái gác `:` là để `https://` không bị đọc thành mở chú thích. */
      if (v.startsWith('//', i) && v[i-1] !== ':'){ trong = 'dong'; i += 2; continue; }
      ra += v[i]; i++;
    }
    return ra;
  };
  const xau = [];
  boChuThich(SRC).split('\n').forEach((d, i) => {
    if (/đội|Đội|ĐỘI/.test(d)) xau.push('dòng ' + (i + 1) + ': ' + d.trim().slice(0, 80));
  });
  la('không chữ nào hiện ra màn còn gọi là "đội"', xau.length === 0,
     xau.join('\n       → '));
}

console.log(`\n${truot ? '❌' : '✅'} ${dat} ca đạt${truot ? ', ' + truot + ' ca trượt' : ''}.\n`);
process.exit(truot ? 1 : 0);
