/* THỬ: PHIÊN QUÊN TẮT VÀO KHỐI "CHỜ BẠN"                          (TRI-162)
   ─────────────────────────────────────────────────────────────────────────────
   Andy 07/09 làm thật 09:12–12:12, nhịp tim đập đều tới phút cuối, nhưng không
   bấm ⏹. Lượt dọn khép phiên thành `heo`, mọi khung nhìn đếm giờ lọc
   `ket_qua = 'song'`, nên cả buổi hiện ra thành 0 giờ.
   Tracy: *"đừng để héo luôn"* · *"ai đi kiểm tra từng người được, họ tự thôi"*.

   Chín chỗ đáng canh bằng máy — đều là chỗ hỏng IM LẶNG, màn hình vẫn trông đúng:

     · KHOÁ `CB_LOAI` PHẢI CÓ. Chú thích của chính khung nhìn đã cảnh báo: khai
       một loại mới ở máy chủ mà quên khoá ở app thì ô đếm cộng một dòng còn
       danh sách không bày nó. Một dòng chờ vô hình.

     · SỐ PHÚT GỢI Ý LẤY THEO NHỊP TIM, không theo quãng đã trôi tới bây giờ.
       Đây là ô nằm ngay cạnh nút xanh đầu tiên: điền to hơn sự thật là mời
       người ta bấm một cái để nhận giờ mình không làm.

     · CỬA SỔ NHÌN LẠI PHẢI KHỚP giữa nhánh khung nhìn và mục vá dữ liệu cũ.
       Lệch nhau thì có phiên được đánh cờ mà không dòng nào đọc tới.

     · NHÁNH MỚI LỌC THEO NGƯỜI ĐĂNG NHẬP. Thiếu một dòng ấy là bày phiên của
       người khác vào ô chờ của mình.

     · PHIÊN NGƯỜI TỰ BỎ ĐỨNG NGOÀI. `dwHuy` cũng ghi `heo`; mời khai lại thứ
       người ta chủ ý bỏ là quấy. Cờ `bo_roi` là chỗ phân biệt.

     · DÒNG PHẢI RỤNG NGAY sau khi khai xong, không đợi nhịp soát 5 phút.

     · NHỊP SOÁT ĐỨNG IM KHI TAB Ở NỀN, và hai đường soát không hỏi dồn nhau.

     · DROP VIEW CUỐN THEO BA THỨ — security_invoker, grant, cò chặn ghi. Bỏ
       sót một cái là một lỗ im lặng.

     · TRẦN 180 PHÚT PHẢI KHỚP giữa SQL và mã app.

   Chạy:  node production/lan-app/QK/thu-quen-khai.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(__dirname, 'nang-cap-phien-quen-khai.sql'), 'utf8');

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
  return SRC.slice(i, j + cuoi.length);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── MÁY CHẠY THẬT ────────────────────────────────────────────────────────
   Nạp mã THẬT của `dwSuaPhien` cùng ba hàm đo nó gọi tới. Dựng giả đúng phần
   không đo được ở đây: lớp mạng, hộp thoại, và mấy hàm định dạng chữ. */
function may(p, DW_MAY){
  return new Function('P', 'DW_MAY', `
    const DW_SAN_PHUT = 5, DW_TRAN_PHUT = 180, DW_IM_LANG_PHUT = 5;
    let dwPhien = null, hopHtml = '', loi = '';
    const toast = t => { loi = t; };
    const hopHoiMo = h => { hopHtml = h; };
    const sb = {from: () => ({select: () => ({eq: () => ({
      limit: async () => ({data: [P], error: null})})})})};
    const tlTenPhien = () => 'Việc thử';
    const hm        = d => String(d.getHours()).padStart(2,'0') + ':'
                         + String(d.getMinutes()).padStart(2,'0');
    const d2s       = d => d.toISOString().slice(0,10);
    const ngayDep   = s => s;
    const gioChu    = m => m + ' phút';
    ${catHam('chuSach')}
    ${catHam('phutPhien')}
    ${catHam('dwDongDuoc')}
    ${catHam('dwImLangPhut')}
    ${catHam('dwSuaPhien')}
    return {dwSuaPhien, soi: () => ({html: hopHtml, loi})};
  `)(p, DW_MAY);
}

/* Số điền sẵn trong ô nhập của hộp vừa mở. */
function phutTrongO(html){
  const m = html.match(/id="sp-phut"[^>]*value="(-?\d+)"/);
  return m ? Number(m[1]) : null;
}

const PHUT = 60000;
function phienHeo(daiPhut, nhipSauPhut){
  const bd = new Date(Date.now() - 8*60*PHUT);
  return {
    id: 523, ket_qua: 'heo', bat_dau: bd.toISOString(),
    ket_thuc: new Date(bd.getTime() + daiPhut*PHUT).toISOString(),
    nhip_cuoi: nhipSauPhut === null ? null
             : new Date(bd.getTime() + nhipSauPhut*PHUT).toISOString(),
    nghi_ms: 0, may_ma: 'may-nay', task_id: 523,
  };
}

(async () => {

/* ① Khoá CB_LOAI — thiếu nó là một dòng chờ vô hình */
{
  console.log('\n① Khoá phien-quen-khai trong CB_LOAI');
  const khoi = catKhoi('const CB_LOAI = {', '\n};');
  la('khoá `phien-quen-khai` đã khai', khoi.includes("'phien-quen-khai'"));
  la('bấm vào mở hộp khai phút, và ép `khoa` sang số (khung nhìn trả text)',
     /'phien-quen-khai'[\s\S]{0,200}dwSuaPhien\(Number\(d\.khoa\)\)/.test(khoi));
  const dong = khoi.slice(khoi.indexOf("'phien-quen-khai'"));
  la('tên việc và khung giờ đều đi qua `chuSach` — hai chuỗi này đến từ máy chủ',
     (dong.match(/chuSach\(d\.(ten|ai)\)/g) || []).length >= 2);
  la('dòng phụ nói THÔNG TIN, không nhắc người ta phải bấm gì (mũi tên › đã nói)',
     !/phu:[\s\S]{0,120}(Chạm|Bấm|Nhấn|Mở)/.test(dong));
}

/* ② Số phút gợi ý — chỗ dễ biến rác thành giờ thật nhất */
{
  console.log('\n② Số phút gợi ý cho phiên bỏ rơi');

  const m1 = may(phienHeo(180, 78), 'may-nay');
  await m1.dwSuaPhien(523);
  la('bỏ máy đi lúc phút 78: ô điền 78, KHÔNG điền 180 theo mốc trần',
     phutTrongO(m1.soi().html) === 78, 'điền ' + phutTrongO(m1.soi().html));

  const m2 = may(phienHeo(180, 180), 'may-nay');
  await m2.dwSuaPhien(523);
  la('ngồi tới phút cuối (ca Andy): ô điền 180',
     phutTrongO(m2.soi().html) === 180, 'điền ' + phutTrongO(m2.soi().html));

  const m3 = may(phienHeo(180, 2), 'may-nay');
  await m3.dwSuaPhien(523);
  la('nhịp tắt sau 2 phút: ô kéo lên sàn 5, không để số máy chủ từ chối',
     phutTrongO(m3.soi().html) === 5, 'điền ' + phutTrongO(m3.soi().html));

  const m4 = may(phienHeo(180, null), 'may-nay');
  await m4.dwSuaPhien(523);
  la('máy chủ chưa có cột nhịp tim: rơi về nết cũ (30), không bịa số đo',
     phutTrongO(m4.soi().html) === 30, 'điền ' + phutTrongO(m4.soi().html));

  const m5 = may(phienHeo(180, 90), 'may-nay');
  await m5.dwSuaPhien(523);
  la('hộp nói đúng rằng phiên này chưa cộng phút nào vào vườn',
     /chưa cộng phút nào/.test(m5.soi().html));
}

/* ③ Nạp lại khối Chờ bạn */
{
  console.log('\n③ Đường nạp lại khối Chờ bạn');
  const f = catHam('cbTaiLai');
  la('có hàm `cbTaiLai`, hỏi thẳng khung nhìn `cho_ban`',
     f.includes("from('cho_ban')"));
  la('đặt mốc `CB_LUC` TRƯỚC khi hỏi — hai đường soát không hỏi dồn nhau',
     f.indexOf('CB_LUC = Date.now()') < f.indexOf("from('cho_ban')"));
  la('lỗi thì im lặng giữ nguyên khối đang có, không làm gãy màn Hôm nay',
     /if \(kq\.error\) return;/.test(f));
  la('quay lại app thì soát một lượt (dây bảo hiểm ở visibilitychange)',
     /visibilityState === 'visible' && ME && Date\.now\(\) - CB_LUC > \d+\) cbTaiLai\(\)/.test(SRC));
  la('nhịp soát đứng im khi tab ở nền',
     /setInterval\(\(\) => \{\s*if \(document\.visibilityState === 'visible'[\s\S]{0,120}cbTaiLai\(\);\s*\}, \d+\);/.test(SRC));
  la('khai xong thì dòng rụng ngay, không đợi nhịp soát',
     (SRC.match(/taiTaskList\(\), taiHanhTrinh\(\), cbTaiLai\(\)/g) || []).length === 2);
  la('`phien_deepwork` vẫn cố ý VẮNG trong RT_BANG — nhịp tim 60 giây không được kéo theo một lượt tải lại nặng',
     !!SRC.match(/const RT_BANG = \[([^\]]+)\]/)
     && !SRC.match(/const RT_BANG = \[([^\]]+)\]/)[1].includes('phien_deepwork'));
}

/* ④ Tệp SQL — cờ bo_roi và hàm dọn */
{
  console.log('\n④ Cờ bo_roi và lượt dọn');
  la('cột `bo_roi` khai được chạy lại nhiều lần',
     /add column if not exists bo_roi boolean not null default false/.test(SQL));
  la('hàm dọn đặt cờ khi khép hộ',
     /update phien_deepwork[\s\S]{0,200}bo_roi\s*=\s*true[\s\S]{0,200}where ket_qua = 'dang_chay'/.test(SQL));
  la('hàm dọn vẫn kẹp `ket_thuc` ở trần, không ghi `now()` trơn',
     /least\(bat_dau \+ interval '180 minutes', now\(\)\)/.test(SQL));
  la('vá dữ liệu cũ chỉ chạm phiên KHÔNG khai cửa nào (người tự bỏ thì đứng ngoài)',
     /set bo_roi = true[\s\S]{0,300}cua is null/.test(SQL));
}

/* ⑤ Tệp SQL — nhánh thứ tám */
{
  console.log('\n⑤ Nhánh thứ tám của cho_ban');
  const nhanh = SQL.slice(SQL.indexOf("'phien-quen-khai'::text"));
  la('nhánh lọc theo người đăng nhập — không bày phiên người khác',
     /p\.nguoi_id = nguoi_id_dang_nhap\(\)/.test(nhanh));
  la('gom CẢ phiên còn treo quá trần lẫn phiên đã bị dọn — dòng có mặt ngay khi vượt trần',
     /p\.ket_qua = 'dang_chay' or \(p\.ket_qua = 'heo' and p\.bo_roi\)/.test(nhanh));
  /* MỌI lần nhắc tới 'heo' trong nhánh này phải đi kèm cờ. Viết dạng "không có
     lần nào thiếu cờ" chứ không dạng "có một lần đủ cờ": một câu `or ket_qua =
     'heo'` lọt thêm vào sau này thì cách viết sau vẫn xanh. */
  la('phiên héo KHÔNG mang cờ thì đứng ngoài (người tự bỏ)',
     /\(p\.ket_qua = 'heo' and p\.bo_roi\)/.test(nhanh)
     && !/ket_qua = 'heo'(?! and p\.bo_roi)/.test(nhanh));
  la('mốc trần trong SQL khớp `DW_TRAN_PHUT` của app',
     /interval '180 minutes'/.test(nhanh) && /DW_TRAN_PHUT = 180/.test(SRC));
  la('khung giờ hiện ra lấy theo nhịp tim, không lấy mốc trần',
     /coalesce\(p\.nhip_cuoi, p\.bat_dau \+ interval '180 minutes'\)/.test(nhanh));
  const cuaSo = SQL.match(/interval '7 days'/g) || [];
  la('cửa sổ nhìn lại 7 ngày khớp giữa mục vá dữ liệu cũ và nhánh khung nhìn',
     cuaSo.length >= 2, cuaSo.length + ' chỗ');
}

/* ⑥ Tệp SQL — ba thứ drop view cuốn đi */
{
  console.log('\n⑥ Dựng lại thứ drop view cuốn theo');
  la('security_invoker bật lại', /alter view cho_ban set \(security_invoker = on\)/.test(SQL));
  la('quyền đọc trao lại', /grant select on cho_ban to authenticated/.test(SQL));
  la('cò chặn ghi dựng lại', /create trigger trg_chan_ghi_cho_ban/.test(SQL));
  la('chú thích khung nhìn đã kê đủ TÁM loại',
     /Tám loại/.test(SQL) && /phien-quen-khai \(/.test(SQL));
  const soUnion = (SQL.match(/^union all$/gm) || []).length;
  la('thân khung nhìn có đúng 7 lần `union all` (tám nhánh)', soUnion === 7, soUnion + ' lần');
  la('bộ tự kiểm nằm CUỐI tệp — Supabase chỉ bày kết quả câu lệnh cuối',
     SQL.lastIndexOf('order by dat, so') > SQL.lastIndexOf('commit;'));
}

console.log(`\n═══ ${dat} đạt · ${truot} trượt ═══\n`);
process.exit(truot ? 1 : 0);

})();
