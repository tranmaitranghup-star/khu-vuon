/* THỬ: ĐỔI GIỜ CHUỖI SỰ KIỆN THÌ VIỆC ĐÃ ĐẺ ĐI THEO (TRI-107)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09, bác lại lời tự khai trong mã rằng chỗ hở này là cố ý:

     *"Chỉ là giữ ở vận hành để nắm được sự thay đổi lịch trình thôi, chứ task là
      mang nghĩa thứ cần phải làm; nếu đã thay đổi sự kiện rồi thì task đó phải
      thay đổi theo chứ."*

   Bài thử canh bốn điều mà mã dễ trôi khỏi nhất, cả bốn đều hỏng trong im lặng:
   hai cửa đổi giờ có gọi đường mới không, luật "còn sạch" có còn nguyên không,
   buổi đã dời riêng có được chừa ra không, và ngày có bị kéo theo nhầm không.

   Chạy:  node production/tinh-thuc-app/thu-viec-theo-chuoi.js
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
function ham(ten){
  const d = SRC.split('\n');
  let tu = -1;
  for (let i = 0; i < d.length; i++){
    if (new RegExp('^(?:async\\s+)?function\\s+' + ten + '\\s*\\(').test(d[i])) tu = i;
    else if (tu >= 0 && d[i] === '}') return d.slice(tu, i + 1).join('\n');
  }
  return '';
}

console.log('\n① Hai cửa đổi giờ đều phải dẫn việc đi theo');
{
  const doi = ham('lcLuuDoi'), luu = ham('lcLuu');
  la('`lcLuuDoi` có nhánh gọi `lcTheoChuoi`', /lcTheoChuoi\s*\(/.test(doi),
     'Kéo đổi giờ với phạm vi *Tất cả sự kiện* mà không gọi thì việc của những lượt khác giữ giờ cũ.');
  la('`lcLuuDoi` vẫn giữ `lcTheoViec` cho buổi lẻ', /lcTheoViec\s*\(/.test(doi),
     'Phạm vi *Sự kiện này* đi lối riêng vì một buổi lẻ có thể dời sang hẳn ngày khác.');
  la('`lcLuu` gọi `lcTheoChuoi` ở nhánh sửa', /lcTheoChuoi\s*\(/.test(luu),
     'Đổi giờ bằng cửa Lưu cũng là đổi cả chuỗi — không chỉ cú kéo trên timeline.');
  /* So thứ tự thì phải BỎ CHÚ THÍCH TRƯỚC. Lượt đầu bài thử này đỏ oan vì chính
     lời nhắc *"Đọc `LC_SUA` TRƯỚC `lcDongCua()`"* nằm ngay trên đoạn mã — máy
     đọc thấy tên hàm trong chú thích và tưởng lệnh gọi đứng trước. Một phép kiểm
     đỏ vì lý do chính đáng thì lần sau người ta thôi tin nó. */
  const luuSach = luu.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '');
  la('`lcLuu` đọc `LC_SUA` trước khi đóng cửa',
     luuSach.indexOf('const daSua = LC_SUA') > -1
     && luuSach.indexOf('const daSua = LC_SUA') < luuSach.indexOf('lcDongCua()'),
     '`lcDongCua()` trả `LC_SUA` về null; đọc sau đó là đọc một cờ đã tắt.');
}

console.log('\n② Luật "còn sạch" giữ nguyên — Tracy chốt 05/09, nới phạm vi chứ không nới luật');
{
  const c = ham('lcTheoChuoi');
  la('hàm tồn tại', !!c);
  la('chỉ lấy việc còn `Chua_lam`', /'Chua_lam'/.test(c),
     'Thiếu vế này là ghi đè giờ lên cả việc đang làm dở và việc đã xong.');
  la('loại việc đã có phiên deep work', /phien_deepwork/.test(c),
     'Việc đã chạy phiên là việc người ta đã cầm trong tay; ghi đè giờ của nó là sửa lại một chuyện đã xảy ra.');
  la('chỉ chạm việc của chính mình', /nguoi_id.*ME\.id/.test(c),
     '`ghi_task` chỉ cho mỗi người sửa việc của mình — câu thiếu vế này sẽ đổ giữa chừng.');
}

console.log('\n③ Hai thứ KHÔNG được kéo theo');
{
  const c = ham('lcTheoChuoi');
  la('chừa buổi đã dời riêng ra', /lich_chung_ngoai_le[\s\S]*?'doi'/.test(c),
     'Buổi mang dòng `kieu=doi` là buổi người ta cố ý kéo lệch khỏi chuỗi. Kéo nó về hàng là xoá một quyết định cũ.');
  la('không mang cột `ngay` trong patch', !/patch\s*=\s*\{[^}]*\bngay\s*:/.test(c),
     'Với chuỗi định kỳ, ngày do luật lặp quyết. Đổi ngày ở đây là viết lại luật sau lưng người kéo.');
}

console.log('\n④ Đường máy chủ — việc của CẢ ĐỘI đi theo (TRI-109)');
{
  const c = ham('lcTheoChuoi');
  la('thử hàm máy chủ TRƯỚC đường máy khách',
     c.indexOf("rpc('doi_gio_viec_theo_chuoi'") > -1
     && c.indexOf("rpc('doi_gio_viec_theo_chuoi'") < c.indexOf("from('task')"),
     'Chạy đường máy khách trước là đã ghi một lượt rồi mới hỏi máy chủ ghi lại.');
  la('chưa chạy tệp SQL thì rơi về đường cũ', /PGRST202/.test(c),
     'Thiếu vế này thì một dự án chưa nâng cấp mất hẳn tính năng thay vì chạy như hôm qua.');
  la('lỗi KHÁC thì nói ra, không im', /toast\(/.test(c.split('PGRST202')[1] || ''),
     'Lỗi quyền hay ràng buộc mà lặng lẽ chạy tiếp là giấu đúng thứ người dùng cần biết.');

  const sql = fs.readFileSync(path.join(__dirname, 'nang-cap-doi-gio-viec-ca-doi.sql'), 'utf8');
  la('hàm chạy bằng quyền định nghĩa', /security definer/.test(sql));
  la('hàm TỰ KIỂM quyền sửa sự kiện', /la_lead\(\)[\s\S]{0,120}tao_boi/.test(sql),
     'Một hàm security definer không tự kiểm quyền là một cánh cửa mở — RLS không chặn hộ nó.');
  la('người đăng nhập gọi được', /grant execute on function doi_gio_viec_theo_chuoi/.test(sql));
  la('vẫn chừa buổi đã dời riêng', /lich_chung_ngoai_le[\s\S]{0,200}'doi'/.test(sql));
  la('vẫn chừa việc đã có phiên deep work', /phien_deepwork/.test(sql));
  la('không đụng chính sách ghi của `task`', !/create policy[\s\S]{0,80}on task/.test(sql),
     'Lời giải là một hàm khoanh đúng cột, KHÔNG phải nới policy — RLS chặn theo dòng chứ không theo cột.');
}

console.log('\n⑤ Sổ tay phải nói đúng — dòng cũ ghi đây là chỗ hở cố ý');
{
  const so = fs.readFileSync(path.join(__dirname, 'DANG-LAM.md'), 'utf8');
  const dong = so.split('\n').find(d => d.includes('Tất cả sự kiện* không mang việc đã đẻ')) || '';
  la('mục ⏳ không còn gọi đây là "cố ý"', !dong || !/—\s*cố ý,/.test(dong),
     'Người đọc sau sẽ tin lời khai ấy và bỏ qua, đúng như đã xảy ra một lần.');
}

console.log('\n' + (truot ? `❌ ${truot} chỗ chưa đạt (${dat} đạt)` : `✅ Đủ cả ${dat} phép kiểm`));
process.exit(truot ? 1 : 0);
