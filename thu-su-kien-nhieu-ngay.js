/* THỬ: SỰ KIỆN CẢ NGÀY TRẢI NHIỀU NGÀY
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"tôi không add được sự kiện kéo dài nhiều ngày như gg calendar"*
   → duyệt Ⓐ (sự kiện cả ngày, dải ngang) kèm phương án ② (kéo thả dải). TRI-69.

   Chín ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · DẢI BẮT ĐẦU TỪ TUẦN TRƯỚC BIẾN MẤT. Đây là ca tệ nhất của cả tính năng và
       cũng là ca dễ viết hụt nhất. Hỏi "ngày này có dải nào BẮT ĐẦU không" thì
       một chuyến đi khai từ thứ Sáu tuần trước không có mặt ở thứ Hai tuần này —
       im lặng, không lỗi, chỉ là bốn ngày công tác không hiện ra ở đâu cả.

     · LỆCH MỘT NGÀY Ở ĐÚNG Ô CUỐI. Lịch Google lưu ngày kết thúc theo lối
       *exclusive* — 12→15/09 lưu thành 16/09. Chép lối ấy vào một bảng mà mọi
       cột ngày khác đều là ngày thật thì dải dài thừa hoặc thiếu đúng một ô, và
       chỉ ở ô cuối, chỗ mắt ít soi nhất.

     · BUỔI CẢ NGÀY LỌT VÀO LƯỚI GIỜ. Nó không có giờ, nên lọt vào là một khối
       mọc ở 0h00 dài 60 phút — một cuộc hẹn không ai đặt.

     · ĐI CÔNG TÁC LÀM CẢ ĐỘI HẾT RẢNH. Bảng giờ rảnh đọc cùng một nguồn với
       lưới. Để dải lọt vào đó thì bốn ngày công tác che kín mọi khe trống, và
       tính năng gợi ý giờ họp thôi trả lời được gì.

     · GỬI CỘT CHƯA CÓ LÀ HỎNG CẢ CÂU. `ca_ngay`/`so_ngay` chỉ vào gói khi cờ
       `CO_NHIEU_NGAY` bật — không phải một trường bị bỏ qua, mà cả cú lưu hỏng.

     · KHOÁ CHẠY THEO CHỖ MỚI. Ghi ngoại lệ bằng ngày ĐÃ DỜI thay vì ngày gốc thì
       lượt gốc mọc lại ở chỗ cũ ngay lượt vẽ sau.

     · KÉO MỘT BUỔI MÀ ĐỔI NGÀY CẢ CHUỖI. Với chuỗi lặp, ngày do luật lặp quyết;
       sửa nó sau lưng người kéo là dời buổi của mọi người khác.

     · DẢI LỘN NGƯỢC. Kéo mép phải qua bên trái mép trái thì dải có độ dài âm —
       không có nghĩa nào trên lịch, và máy chủ nhận nó bằng một ràng buộc.

     · KÉO XONG CỬA BUỔI TỰ MỞ. Trình duyệt bắn `click` sau `pointerup`; không
       nuốt thì vừa dời một chuyến đi là bị hỏi luôn về nó.

   Chạy:  node production/tinh-thuc-app/thu-su-kien-nhieu-ngay.js
*/
const fs = require('fs');
const path = require('path');
const GOC = __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(GOC, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(GOC, 'nang-cap-su-kien-nhieu-ngay.sql'), 'utf8');

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

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* MÃ THẬT, không chép bản thứ hai: năm hàm cắt thẳng từ app rồi chạy trong một
   phạm vi có sẵn `ME`. Bản chép thì lệch dần, rồi bài thử xanh trong khi app đỏ. */
const CHAY = new Function('ME', `
/* Thêm 04/09 (TRI-104): hai hàm suy màu, cờ riêng tư thắng màu sơn tay.
   Chép ĐÚNG bản trong app chứ không dựng bản giả trả về chuỗi rỗng — bản giả
   thì mọi ca dưới đây chạy qua một nhánh không tồn tại ngoài đời. */
const mauSuKien = l => (l && l.rieng_tu) ? 'tim'  : ((l && l.mau) || '');
const mauViec   = t => (t && t.rieng_tu) ? 'hong' : ((t && t.mau) || '');
  ${catHam('lcNgayDich')}
  ${catHam('lcNgayGon')}
  ${catHam('lcSoNgayGiua')}
  ${catHam('lcHopBuoc')}
  ${catHam('lcHopNgay')}
  ${catHam('lcLuotDai')}
  ${/* `lcDaiCuaKhung` hỏi quyền sửa qua hàm này từ 04/09 — nạp mã thật, cùng lẽ
       với dòng chú thích "MÃ THẬT, không chép bản thứ hai" ngay trên. */''}
  ${catHam('lcDuocSua')}
  ${catHam('lcDaiCuaKhung')}
  return {lcDaiCuaKhung, lcSoNgayGiua, lcNgayDich, lcHopNgay};
`)(null);

const TUAN = ['2026-09-07','2026-09-08','2026-09-09','2026-09-10',
              '2026-09-11','2026-09-12','2026-09-13'];   // T2 → CN
const khoDs = ds => ({ds, huy: {}, tick: {}, doi: {}, doiToi: {}});

/* ── ① DẢI BẮT ĐẦU TRƯỚC KHUNG VẪN PHẢI HIỆN ────────────────────────────── */
console.log('\n① Chuyến đi khai từ tuần trước vẫn đang chạy trong tuần này');
{
  const l = {id: 1, ten: 'Công tác Đà Nẵng', ca_ngay: true, so_ngay: 5,
             lap: 'khong', ngay_bat_dau: '2026-09-04', ngay_ket_thuc: null,
             pham_vi: 'ca_nhan', mau: ''};
  const ra = CHAY.lcDaiCuaKhung(khoDs([l]), TUAN, false);
  la('dải bắt đầu 04/09 dài 5 ngày CÓ mặt trong tuần 07→13/09', ra.length === 1,
     'quét từ mép trái trở đi là bỏ sót mọi dải đang chạy dở — im lặng, không lỗi');
  la('nó giữ nguyên ngày đầu thật 04/09, không bị kéo về mép',
     ra.length === 1 && ra[0].tuNgay === '2026-09-04',
     'kẹp vào khung ngay từ đây thì cú kéo sau đó kéo nhầm về chính cái mép');
  la('ngày cuối là 08/09 — đếm CẢ ngày đầu',
     ra.length === 1 && ra[0].denNgay === '2026-09-08',
     '5 ngày từ 04/09 là 04·05·06·07·08, không phải tới 09/09');
}

/* ── ② LỆCH MỘT NGÀY Ở Ô CUỐI ───────────────────────────────────────────── */
console.log('\n② Số ngày đếm cả hai đầu — không chép lối exclusive của Google');
{
  la('12→15/09 là 4 ngày', CHAY.lcSoNgayGiua('2026-09-12','2026-09-15') === 4);
  la('một ngày duy nhất là 1, không phải 0', CHAY.lcSoNgayGiua('2026-09-12','2026-09-12') === 1);
  la('vắt qua cuối tháng vẫn đúng', CHAY.lcSoNgayGiua('2026-08-30','2026-09-02') === 4,
     'trừ tay theo số ngày trong tháng là sai đúng chỗ này');
  la('vắt qua 29/02 năm nhuận vẫn đúng', CHAY.lcSoNgayGiua('2028-02-28','2028-03-01') === 3);
  const l = {id: 2, ten: 'Hội thảo', ca_ngay: true, so_ngay: 1, lap: 'khong',
             ngay_bat_dau: '2026-09-09', ngay_ket_thuc: null, pham_vi: 'ca_nhan', mau: ''};
  const ra = CHAY.lcDaiCuaKhung(khoDs([l]), TUAN, false);
  la('dải MỘT ngày bắt đầu và kết thúc cùng ngày',
     ra.length === 1 && ra[0].tuNgay === ra[0].denNgay && ra[0].tuNgay === '2026-09-09');
}

/* ── ③ CHUỖI LẶP BUNG RA NHIỀU DẢI, MỖI DẢI GIỮ ĐỦ SỐ NGÀY ──────────────── */
console.log('\n③ Luật lặp — độ dài tương đối, không phải một ngày cuối tuyệt đối');
{
  const l = {id: 3, ten: 'Trực cuối tuần', ca_ngay: true, so_ngay: 2, lap: 'tuan',
             thu: [6], buoc: 1, ngay_bat_dau: '2026-08-01', ngay_ket_thuc: null,
             pham_vi: 'ca_nhan', mau: ''};
  const ra = CHAY.lcDaiCuaKhung(khoDs([l]), TUAN, false);
  la('thứ Bảy 12/09 nổ ra một dải', ra.some(o => o.tuNgay === '2026-09-12'));
  la('dải ấy dài 2 ngày, sang Chủ nhật 13/09',
     ra.some(o => o.tuNgay === '2026-09-12' && o.denNgay === '2026-09-13'));
  la('thứ Bảy 05/09 của tuần TRƯỚC không lọt vào khung',
     !ra.some(o => o.tuNgay === '2026-09-05'),
     'dải 05→06/09 kết thúc trước mép trái 07/09 — nó không có mặt trong tuần này');
}

/* ── ④ HUỶ VÀ DỜI RIÊNG MỘT LƯỢT ────────────────────────────────────────── */
console.log('\n④ Ngoại lệ của một lượt — huỷ, dời ngày, đổi số ngày');
{
  const l = {id: 4, ten: 'Nghỉ lễ', ca_ngay: true, so_ngay: 3, lap: 'tuan',
             thu: [1], buoc: 1, ngay_bat_dau: '2026-08-01', ngay_ket_thuc: null,
             pham_vi: 'ca_nhan', mau: ''};
  const huy = khoDs([l]); huy.huy['4|2026-09-07'] = true;
  la('lượt đã huỷ không hiện', !CHAY.lcDaiCuaKhung(huy, TUAN, false)
       .some(o => o.ngay === '2026-09-07'));
  const doi = khoDs([l]);
  doi.doi['4|2026-09-07'] = {ngay_moi: '2026-09-09', so_ngay_moi: 2};
  const ra = CHAY.lcDaiCuaKhung(doi, TUAN, false);
  const o = ra.find(x => x.ngay === '2026-09-07');
  la('lượt đã dời bày ở chỗ MỚI', o && o.tuNgay === '2026-09-09');
  la('nó mang độ dài riêng, không mang độ dài của chuỗi',
     o && o.soNgay === 2 && o.denNgay === '2026-09-10',
     'so_ngay_moi rỗng mới giữ theo chuỗi; có thì nó thắng');
  la('khoá vẫn là NGÀY GỐC, không phải ngày đã dời', o && o.ngay === '2026-09-07',
     'khoá chạy theo chỗ mới thì lượt gốc mọc lại ở chỗ cũ ngay lượt vẽ sau');
  la('nó tự khai là một lượt đã dời', o && o.doi === true);
}

/* ── ⑤ BUỔI CẢ NGÀY KHÔNG ĐƯỢC LỌT VÀO LƯỚI GIỜ, CŨNG KHÔNG LÀM AI BẬN ─── */
console.log('\n⑤ Hai đường phải cùng loại nó ra — lưới giờ và bảng giờ rảnh');
{
  const CN = catHam('lcCuaNgayTu');
  la('lcCuaNgayTu loại buổi cả ngày ra', /if \(l\.ca_ngay\) return;/.test(CN),
     'lọt vào là một khối mọc ở 0h00 dài 60 phút — một cuộc hẹn không ai đặt');
  la('nó đứng TRƯỚC vòng bung lượt',
     CN.indexOf('if (l.ca_ngay) return;') < CN.indexOf('gocs.forEach'),
     'đứng sau thì lượt vẫn được dựng rồi mới bỏ — đúng kết quả, sai chỗ, và chỗ đó dễ bị gỡ');
  la('bảng giờ rảnh đọc CÙNG hàm ấy nên tự sạch theo',
     /lcCuaNgayTu\(d, g, false\)/.test(catHam('lcRanhTim')),
     'hai luật nói cùng một chuyện thì sớm muộn trôi lệch khỏi nhau');
}

/* ── ⑥ GỬI CỘT CHƯA CÓ LÀ HỎNG CẢ CÂU ───────────────────────────────────── */
console.log('\n⑥ Cờ dò cột gác đường ghi');
{
  const LUU = catHam('lcLuu');
  la('hai cột mới chỉ đi khi CO_NHIEU_NGAY bật',
     /if \(CO_NHIEU_NGAY\)\{ dong\.ca_ngay = caNgay; dong\.so_ngay = soNgay; \}/.test(LUU),
     'gửi một cột chưa tồn tại là CẢ câu lệnh hỏng, không phải một trường bị bỏ qua');
  la('gửi CẢ HAI kể cả khi ô tick tắt', /dong\.ca_ngay = caNgay/.test(LUU),
     'bỏ trường đi thì cột cũ nằm lại và bỏ tick không có tác dụng gì');
  la('cờ khai ở doCotGio', /CO_NHIEU_NGAY = !rcn\.error/.test(SRC));
  la('câu hỏi dò cột đi CHUNG chuyến với mười ba câu kia',
     /sb\.from\('lich_chung'\)\.select\('ca_ngay'\)\.limit\(1\)/.test(SRC));
  la('ô tick chỉ bày khi máy chủ đã có cột',
     /const caNgayDuoc = CO_NHIEU_NGAY;/.test(catHam('lcMoForm')),
     'bày một ô tick lưu xuống là lỗi thì tệ hơn hẳn không có ô nào');
  la('lỗi máy chủ được dịch thành việc phải làm',
     /ca_ngay\|so_ngay/.test(LUU) && /nang-cap-su-kien-nhieu-ngay\.sql/.test(LUU));
}

/* ── ⑦ KÉO DẢI — khoá, phạm vi, và hai mép ──────────────────────────────── */
console.log('\n⑦ Kéo dải: ghi xuống đúng bảng, đúng khoá, đúng phạm vi');
{
  const TH = catHam('lcDaiLuuDoi');
  la('nhánh một lượt ghi vào lich_chung_ngoai_le',
     /from\('lich_chung_ngoai_le'\)\.upsert/.test(TH));
  la('khoá là NGÀY GỐC', /ngay_goc: moi\.goc/.test(TH),
     'ghi bằng ngày đã dời thì lượt gốc mọc lại ở chỗ cũ');
  la('upsert theo đúng cặp khoá, không đẻ thêm dòng',
     /onConflict: 'lich_id,ngay_goc'/.test(TH));
  la('nhánh cả chuỗi chỉ đổi NGÀY khi chuỗi KHÔNG lặp',
     /if \(l && l\.lap === 'khong' && moi\.tu\)/.test(TH),
     'chuỗi lặp thì ngày do luật lặp quyết — sửa ở đây là dời buổi của mọi người khác');
  la('chuỗi không lặp thì bỏ luôn nấc hỏi phạm vi',
     /if \(l\.lap === 'khong'\) return void await lcDaiLuuDoi\('tat_ca'/.test(catHam('lcDaiThaXong')),
     'hai nghĩa là một thì hỏi là bắt người ta chọn giữa hai thứ giống hệt nhau');
  la('dòng ngoại lệ luôn có ít nhất một thứ làm chứng',
     /if \(!dong\.ngay_moi && dong\.so_ngay_moi == null\) dong\.ngay_moi = moi\.tu;/.test(TH),
     'ràng buộc ngoaile_doi_du_tham_so chặn một dòng không khai gì cả');
}

/* ── ⑧ HAI MÉP KHÔNG ĐƯỢC LÀM DẢI LỘN NGƯỢC ─────────────────────────────── */
console.log('\n⑧ Hình học cú kéo — luôn còn ít nhất một ngày');
{
  const CH = catHam('lcDaiKeoChay');
  la('mép phải không lùi qua mép trái', /Math\.max\(k\.d, 1 - soNgay\)/.test(CH));
  la('mép trái không vượt qua mép phải', /Math\.min\(k\.d, soNgay - 1\)/.test(CH));
  la('kéo thân giữ nguyên số ngày',
     /k\.tuMoi\s*=\s*lcNgayDich\(k\.tu,\s*k\.d\);[\s\S]{0,80}k\.denMoi\s*=\s*lcNgayDich\(k\.den,\s*k\.d\)/.test(CH),
     'dời một chuyến đi bốn ngày thì nó vẫn là chuyến đi bốn ngày');
  la('ngày đọc từ data-tu/data-den, KHÔNG từ số cột',
     /tu: nut\.dataset\.tu, den: nut\.dataset\.den/.test(catHam('lcDaiKeoMo')),
     'dải cắt ở mép trái thì cột 1 của nó không phải ngày nó bắt đầu');
  la('bề ngang cột đọc từ gridTemplateColumns, không chia đều',
     /gridTemplateColumns/.test(catHam('lcDaiKeoMo')),
     'cột nhãn giờ không rộng bằng cột ngày — chia đều là lệch dần về bên phải');
}

/* ── ⑨ CÚ KÉO KHÔNG ĐƯỢC KÉO THEO MỘT CÚ MỞ CỬA ─────────────────────────── */
console.log('\n⑨ Thả tay xong thì cửa buổi KHÔNG được tự mở');
{
  const TH = catHam('lcDaiKeoTha');
  la('cú click sau khi kéo bị nuốt',
     /addEventListener\('click',[\s\S]{0,160}\{capture: true, once: true\}\)/.test(TH),
     'không nuốt thì vừa dời một chuyến đi là bị hỏi luôn về nó');
  la('kéo chưa quá ngưỡng thì vẫn là một cú chạm', /if \(!k\.chay \|\|/.test(TH),
     'chặn cả cú chạm là mất đường mở cửa buổi');
  la('thả về đúng chỗ cũ cũng không ghi gì',
     /k\.tuMoi === k\.tu && k\.denMoi === k\.den/.test(TH),
     'ghi một thay đổi rỗng là đẻ ra một dòng ngoại lệ không khai gì');
}

/* ── ⑨b TÊN LỚP CỦA TAY NẮM KHÔNG ĐƯỢC TRÙNG MỘT LỚP TRẦN ĐÃ CÓ CHỦ ─────── */
/* Bản đầu (03/09) đặt tên hai tay nắm ngang là `trai`/`phai`. Nhưng `.trai` đã
   có chủ từ trước: đó là MỘT LUỐNG trong màn Khu Vườn — viền gỗ 6px, box-shadow
   gỗ, nền cỏ. Selector của tay nắm đè được `width`·`height`·`inset` nhưng không
   đè `border`·`padding`·`background`, nên tay nắm trái phình thành 40×40 và vẽ
   ra một cái luống cỏ tí hon đè lên đầu dải; tên sự kiện bị đẩy khuất. Tay nắm
   PHẢI thì bình thường, vì `.phai` không có ai giành — nên lỗi trông như "dải
   hỏng một bên", thứ rất khó truy ngược. Tracy báo 04/09 (TRI-82).
   Bài này gác đúng cái nguyên nhân, không gác cái triệu chứng. */
console.log('\n⑨b Tay nắm dải mang tên riêng, không đụng lớp trần nào của app');
{
  const hangSk = SRC.slice(SRC.indexOf('const hangSk'),
                           SRC.indexOf('const nhom', SRC.indexOf('const hangSk')));
  la('tay nắm dùng tên `mep-trai`/`mep-phai`',
     /tlg-nam mep-trai/.test(hangSk) && /tlg-nam mep-phai/.test(hangSk),
     'tên trần `trai` đụng lớp luống của màn Khu Vườn');
  la('không còn tên trần `trai`/`phai` trên tay nắm',
     !/class="tlg-nam (trai|phai)"/.test(SRC),
     'còn một chỗ là còn một cái luống mọc trên lưới lịch');
  /* Và tên mới phải THẬT SỰ chưa có ai dùng — bài thử này vô nghĩa nếu lần sau
     lại chọn trúng một tên trần khác đang nằm sẵn trong khối kiểu dáng. */
  for (const t of ['mep-trai', 'mep-phai'])
    la(`\`.${t}\` không bị một luật trần nào giành`,
       !new RegExp('(^|[^-a-zA-Z0-9_.])\\.' + t + '\\s*[,{]', 'm').test(SRC),
       'một lớp trần dùng chung thì sớm muộn có người vấp lại');
}

/* ── ⑨c CỬA BUỔI PHẢI NÓI ĐÚNG ĐỘ DÀI, KHÔNG BỊA RA MỘT KHUNG GIỜ ───────── */
/* Cửa buổi vốn bày `gio_bat_dau`–`gio_ket_thuc` cho mọi sự kiện. Với một sự kiện
   CẢ NGÀY thì hai cột ấy chỉ là con số còn sót từ lúc tạo dòng (ràng buộc máy
   chủ đòi chúng có giá trị), nên RW38 — chuyến hai ngày — mở lên đọc thấy
   *"Thứ 6, 11/9 · 08:30–09:30"*: sai độ dài, và bịa ra một khung giờ không ai
   khai (Tracy đưa ảnh 04/09, TRI-82).

   Bài này KHÔNG grep chuỗi mã: nó CẮT ĐÚNG đoạn dựng dòng đầu cửa buổi rồi chạy
   thật với bốn bộ dữ liệu. Grep thì mã đổi cách viết là bài chết lặng, còn chạy
   thật thì đổi kiểu gì cũng phải ra đúng câu. */
console.log('\n⑨c Cửa buổi: sự kiện cả ngày nói khoảng NGÀY, buổi có giờ vẫn nói GIỜ');
{
  const i = SRC.indexOf('function lcMoBuoi(id, ngay){');
  const than = SRC.slice(i, SRC.indexOf('\nasync function lcDeViec(', i));
  const a = than.indexOf('<div class="lcb-dong">');
  const mau = '`' + than.slice(a, than.indexOf('</div>', a) + 6) + '`';

  const ngayDep = g => { const d = new Date(g + 'T00:00:00');
    return ['Chủ nhật','Thứ 2','Thứ 3','Thứ 4','Thứ 5','Thứ 6','Thứ 7'][d.getDay()]
           + `, ${d.getDate()}/${d.getMonth() + 1}`; };
  const tlgHHMM = p => String(Math.floor(p/60)).padStart(2,'0') + ':' + String(p%60).padStart(2,'0');
  /* Chạy chính đoạn template ấy; bốn biến nó đọc được truyền vào từ ngoài. */
  const ve = (l, luot, soNgay, hetNgay, den) =>
    eval(mau).replace(/<[^>]+>/g, '');

  const caNgay2 = ve({ca_ngay: true,  da_chot: false}, {ngay:'2026-09-11', tu:510, doi:false}, 2, '2026-09-12', 570);
  la('dải hai ngày bày CẢ HAI đầu ngày', /11\/9 – Thứ 7, 12\/9/.test(caNgay2), caNgay2);
  la('và nói "cả ngày" thay cho một khung giờ',
     /cả ngày/.test(caNgay2) && !/08:30/.test(caNgay2),
     'con số giờ của một sự kiện cả ngày là rác còn sót trong cột, không phải dữ kiện');
  la('nấc "còn dự kiến" vẫn đi kèm', /còn dự kiến/.test(caNgay2), caNgay2);

  const caNgay1 = ve({ca_ngay: true, da_chot: true}, {ngay:'2026-09-11', tu:510, doi:false}, 1, '2026-09-11', 570);
  la('dải MỘT ngày không bày ngày cuối trùng ngày đầu', !/–/.test(caNgay1), caNgay1);
  la('nhưng vẫn nói "cả ngày"', /cả ngày/.test(caNgay1), caNgay1);

  const coGio = ve({ca_ngay: false, da_chot: false}, {ngay:'2026-09-11', tu:510, doi:false}, 1, null, 570);
  la('buổi CÓ GIỜ không đổi gì — vẫn bày khung giờ như trước',
     /08:30–09:30/.test(coGio) && !/cả ngày/.test(coGio), coGio);

  const daDoi = ve({ca_ngay: true, da_chot: true}, {ngay:'2026-09-12', tu:510, doi:true}, 3, '2026-09-14', 570);
  la('dải đã dời riêng: đọc ngày MỚI và vẫn treo lời nhắc đã dời',
     /12\/9 – Thứ 2, 14\/9/.test(daDoi) && /đã dời riêng/.test(daDoi), daDoi);

  /* Số ngày phải đọc qua `lcLuotDai` — kéo mép một buổi ghi `so_ngay_moi` của
     riêng lượt ấy, đọc thẳng `l.so_ngay` là cửa nói độ dài của CẢ CHUỖI. */
  la('số ngày đọc qua `lcLuotDai`, không đọc thẳng `l.so_ngay`',
     /soNgay\s*=\s*l\.ca_ngay\s*\?\s*lcLuotDai\(/.test(than),
     'đọc cột gốc thì một buổi đã kéo mép sẽ bày sai độ dài');
}

/* ── ⑩ TỆP SQL PHẢI TỰ ĐỦ ───────────────────────────────────────────────── */
console.log('\n⑩ Tệp nâng cấp — ràng buộc và bộ tự kiểm');
{
  la('thêm cả hai cột', /add column if not exists ca_ngay/.test(SQL)
     && /add column if not exists so_ngay/.test(SQL));
  la('buổi có giờ vẫn bị giữ trong một ngày',
     /check \(ca_ngay or so_ngay = 1\)/.test(SQL),
     'mở cột ra trước khi bốn chỗ kẹp 24h biết tính sang hôm sau là dữ liệu nói một đằng lưới vẽ một nẻo');
  la('ràng buộc dựng lại bằng drop rồi add, không bọc if not exists',
     /drop constraint if exists lich_ca_ngay_khop;[\s\S]{0,120}add  constraint lich_ca_ngay_khop/.test(SQL),
     'bọc thì lần sau nới thêm một trường, chạy lại tệp KHÔNG vá được gì');
  la('bốn trường thay nhau làm chứng cho một dòng đã dời',
     /num_nonnulls\(ngay_moi, gio_moi, so_phut_moi, so_ngay_moi\) >= 1/.test(SQL),
     'thiếu so_ngay_moi thì một cú nới mép thuần tuý bị chặn');
  la('tệp tự đủ — mang theo cả cột của nang-cap-doi-buoi-rieng',
     /add column if not exists so_phut_moi/.test(SQL),
     'chạy tệp này mà vẫn phải chạy tệp kia trước là một thứ tự không ai nhớ');
  la('có bộ tự kiểm chạy được ngay sau khi dán',
     /TỰ KIỂM/.test(SQL) && /raise exception/.test(SQL));
}

console.log(truot ? `\n❌ ${dat} ca đạt, ${truot} ca trượt.`
                  : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
