/* THỬ: BẢN NHÁP VÀ MỘT NÚT LƯU CHO CẢ CỬA SỰ KIỆN
   ─────────────────────────────────────────────────────────────────────────────
   Tracy chốt 01/09: *"nút lưu của tôi có nghĩa là bất cứ chỉnh sửa gì thì phải
   bấm lưu, hoặc nếu bấm X hay bấm ra ngoài màn hình thì sửa đổi chưa được lưu,
   chứ ý tôi ko phải là lưu riêng từng note đâu"*.

   Đây là cú lật mô hình, không phải một nút thêm vào. Trước đó hai ô ghi chú tự
   ghi lúc rời ô và lúc đóng cửa, mỗi ô một nút Lưu riêng. Nay: KHÔNG ô nào tự
   ghi · chữ gõ, link gắn, link bỏ đều nằm trong `LC_NHAP` · MỘT nút Lưu cho cả
   cửa · đóng cửa là bỏ bản nháp.

   Sáu ca đáng giá nhất — đều là chỗ thử tay từng bước KHÔNG lộ ra:

     · VẼ LẠI GIỮA CHỪNG KHÔNG ĐƯỢC NUỐT CHỮ ĐANG GÕ. Cửa này vẽ lại sau mỗi cú
       bấm hướng. Vẽ từ kho thì gõ dở nửa câu rồi bấm "Hoàn thành" là mất chữ;
       dựng lại bản nháp ở đó cũng mất y như vậy. Chỉ dựng lại khi SANG BUỔI KHÁC.

     · GẮN LINK KHÔNG ĐƯỢC RA MÁY CHỦ. Cả điểm của cú chốt này: bấm ✕ bỏ một link
       rồi đổi ý đóng cửa thì link ấy phải còn nguyên dưới máy chủ.

     · CHỈ GỬI Ô NÀO ĐỔI THẬT. Gõ một ô rồi bấm Lưu thì ô kia không được tốn một
       lượt ghi — và hai ô nằm ở hai bảng khác nhau, khoá khác nhau.

     · GHI HỎNG THÌ KHO KHÔNG ĐƯỢC ĐỔI THEO. Nay mọi lượt ghi đều do một cú bấm
       nên không còn hai lượt chồng nhau; đổi lại, vá kho trước rồi ghi hỏng là
       kho nói một đằng máy chủ một nẻo mà chẳng còn lượt nào sửa lại.

     · NÚT LƯU PHẢI ĐÓNG CỬA, VÀ CHỈ KHI GHI ĐẠT. Chỗ dễ nói dối nhất trong cụm.
       Từ 02/09 lời báo "đã lưu" không còn nằm trên mặt nút nữa mà chính là cú
       ĐÓNG — nên ghi hỏng mà vẫn đóng là nuốt mất đoạn vừa gõ đúng vào lúc người
       ta tin chắc nhất là nó đã được lưu.

     · ĐÓNG CỬA LÚC CÒN THỨ CHƯA LƯU PHẢI HỎI. Tracy chốt đóng là bỏ; nhưng bỏ
       mà không hỏi thì một cú chạm nhầm ra nền là mất cả đoạn vừa gõ.

   Chạy:  node production/tinh-thuc-app/thu-thong-bao-buoi.js
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

const NGUON = catKhoi('const KHI = {', '/* ── CỬA GHI CHÚ RIÊNG CỦA MỘT BUỔI')
            + catKhoi('/* ĐÓNG CỬA LÀ BỎ THAY ĐỔI', '/* Lùi một ngày, trả về chuỗi');

/* `hrefLink` và `nhanLinkGon` lấy NGUYÊN VĂN từ app, không chép tay một bản
   thứ hai: một bản chép tay thì đo chính nó chứ không đo mã đang chạy. */
const AN_TOAN = catKhoi('function hrefLink(u){', '/* Khối ô nhập link')
              + catKhoi('function nhanLinkGon(u){', '/* `stopPropagation` không phải');

const COC = `
let LC_HIEN = null, LC_BUOI = null, LC_NHAP = null, LC_KHO = {a: 1};
let CO_TB_BUOI = true, CO_GC_BUOI = true, LOI = null;
let GOI = [], TOAST = [], DOM = {}, HOP = [];
const ME = {id: 'toi'};
const chuSach = t => String(t == null ? '' : t)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const chuCoLink = t => chuSach(t);
const toast = m => TOAST.push(m);
const document = {getElementById: id => DOM[id] || null};
const hopHoiMo = h => HOP.push(h);
const hopHoiDong = () => HOP.push('DONG');
/* Bản giả của \`nutCho\` giữ đúng hai điều \`lcLuuRoiDong\` phụ thuộc vào: nó CHỜ
   việc xong, và TRẢ LẠI đúng thứ việc ấy trả. Thiếu vế sau thì phép đo "ghi hỏng
   thì không đóng cửa" chỉ đo chính bản giả. */
const nutCho = async (nut, chu, viec) => {
  const cu = nut.innerHTML; nut.innerHTML = chu;
  try { return await viec(); } finally { nut.innerHTML = cu; }
};
const sb = { from: (bang) => ({ upsert: async (o, opt) => { GOI.push({bang, o, opt});
    await new Promise(r => setTimeout(r, 0));
    return {error: LOI}; } }) };
` + AN_TOAN;

const chay = new Function(COC + NGUON + `
  return { lcOThongBao, KHI, KHI_MA, lcDungNhap, lcNhapDoi, lcNhapChu, lcVeNutLuu, lcLuuCua,
    lcNoO, noRa: () => LC_NO,
    tbGhi, gcGhi, lcLuuRoiDong, tbThemLink, tbBoLink, tbHoiLink,
    lcDongBuoi, lcDongHan, lcHoiBoNhap, hrefLink,
    dat: c => { if (c.LC_HIEN !== undefined) LC_HIEN = c.LC_HIEN;
                if (c.LC_NO !== undefined) LC_NO = c.LC_NO;
                if (c.LC_NHAP !== undefined) LC_NHAP = c.LC_NHAP;
                if (c.LC_BUOI !== undefined) LC_BUOI = c.LC_BUOI;
                if (c.CO_TB_BUOI !== undefined) CO_TB_BUOI = c.CO_TB_BUOI;
                if (c.CO_GC_BUOI !== undefined) CO_GC_BUOI = c.CO_GC_BUOI;
                if (c.LOI !== undefined) LOI = c.LOI;
                if (c.DOM !== undefined) DOM = c.DOM;
                if (c.LC_KHO !== undefined) LC_KHO = c.LC_KHO;
                if (c.reset){ GOI = []; TOAST = []; HOP = []; } },
    doc: () => ({GOI, TOAST, LC_HIEN, LC_NHAP, LC_BUOI, DOM, LC_KHO, HOP}) };
`)();

const oGia  = v => ({value: v});
/* `textContent` chứ không chỉ `disabled`: từ 02/09 tín hiệu "còn thứ chưa lưu"
   nằm ở NHÃN, không ở màu xám (Tracy bỏ nút xám). Bản giả phải mang đúng cái
   trường mà `lcVeNutLuu` đang viết vào, nếu không nó đo một thứ không ai đổi. */
const nutGia = () => ({innerHTML: 'Lưu', textContent: '', isConnected: true, disabled: true});
const KHOA  = '7|2026-09-01';
/* Hình ĐỐI XỨNG từ 01/09: hai ô, mỗi ô một đoạn chữ và một dãy link riêng. */
const kho = (chu, links, gc, truoc, linksTruoc) => ({
  ds: [{id: 7, tao_boi: 'toi'}],
  tb: {[KHOA]: {truoc: {chu: truoc || '', links: linksTruoc || []},
                sau:   {chu,              links: links || []}}},
  gc: {[KHOA]: gc || ''}
});

(async function chayThu(){

console.log('\n── ① Bày ra đúng dáng cho đúng người ────────────────────────');
{
  chay.dat({reset: true, CO_TB_BUOI: false, LC_HIEN: kho('', []), LC_NHAP: null});
  la('Bảng chưa có: HOST được nói tên tệp SQL phải chạy',
    chay.lcOThongBao(7, '2026-09-01', true, 'truoc').includes('nang-cap-thong-bao-buoi.sql'));
  la('…và nói ĐÚNG MỘT LẦN, ở ô đầu — hai ô cùng một bảng',
    chay.lcOThongBao(7, '2026-09-01', true, 'sau') === '',
    'bày hai lần cùng một câu nhắc là bắt đọc hai lần một tin');
  la('Bảng chưa có: NGƯỜI DỰ không thấy gì — họ không có việc gì với tệp SQL',
    chay.lcOThongBao(7, '2026-09-01', false, 'truoc') === ''
    && chay.lcOThongBao(7, '2026-09-01', false, 'sau') === '');

  chay.dat({CO_TB_BUOI: true});
  la('Buổi trống + người dự: không bày một ô rỗng có nhãn',
    chay.lcOThongBao(7, '2026-09-01', false, 'sau') === '');
  /* ⚠️ ĐỔI 03/09: ô trống KHÔNG còn bày ô gõ sẵn (Tracy: *"lúc đầu chỉ hiện 1
     ô là Thêm thông tin trước sự kiện"*). Muốn đo dáng NỞ thì phải mở nó ra
     trước — đúng thứ tự người dùng đi qua. */
  chay.dat({LC_NO: {truoc: false, sau: false}});
  const hostGon = chay.lcOThongBao(7, '2026-09-01', true, 'sau');
  la('Buổi trống + host: một DÒNG MỜI, không phải một ô gõ bày sẵn',
    hostGon.includes('lcb-them') && !hostGon.includes('<textarea'),
    'hai ô soạn trống chắn ngang đường đọc của cửa sự kiện');
  la('Dòng mời nói đúng câu Tracy đặt',
    hostGon.includes('Thêm thông tin sau sự kiện'));
  la('Dòng mời là một cái NÚT — bấm được bằng phím, đọc được bằng máy đọc',
    hostGon.includes('<button type="button" class="lcb-them"'),
    'một thẻ div có onclick thì bàn phím không tới được');
  chay.dat({LC_NO: {truoc: false, sau: true}});
  const hostTrong = chay.lcOThongBao(7, '2026-09-01', true, 'sau');
  la('Mở dòng mời ra rồi: có ô gõ, vì đây là chỗ họ sắp viết',
    hostTrong.includes('<textarea id="lcb-tb-sau"'));
  la('Mở ô này KHÔNG mở ô kia — hai ô hai cờ riêng',
    chay.lcOThongBao(7, '2026-09-01', true, 'truoc').includes('lcb-them'));
  /* Nhãn rút gọn 01/09 (làn CK, Tracy): *"Ghi chú cho người tham gia sau cuộc
     họp"* nói ba thứ trong một dòng — loại chữ · gửi cho ai · lúc nào — trong
     khi cả cửa này vốn đã là của người tham gia. Nay chỉ còn loại chữ, cộng cái
     MỐC in đậm, vì mốc là thứ duy nhất phân biệt hai ô đứng cách nhau nửa cửa. */
  la('Nhãn nói ô này là chữ gì, và in đậm MỐC — thứ duy nhất phân biệt hai ô',
    hostTrong.includes('Thông tin <b>sau sự kiện</b>'));
  la('Nhãn thôi nói "cho ai" — cả cửa đã là của người tham gia rồi',
    !hostTrong.includes('cho người tham gia'));
  la('Bỏ hẳn dòng "cả đội đọc được" (Tracy 01/09)',
    !hostTrong.includes('cả đội đọc được'));
  la('Gõ chữ chỉ vào BẢN NHÁP — không còn `onblur` tự ghi',
    hostTrong.includes("oninput=\"lcNhapChu('sau'") && !hostTrong.includes('onblur'),
    'tự ghi lúc rời ô là đúng thứ Tracy bỏ đi');
  la('Không còn nút Lưu riêng cho ô này — cả cửa dùng chung MỘT nút',
    !hostTrong.includes('>Lưu<'));
  la('Vẫn còn nút Gắn link, và nó khai rõ ô nào',
    hostTrong.includes("tbHoiLink('sau')"));

  chay.dat({LC_HIEN: kho('Chốt ba việc.', [{ten: 'Biên bản', url: 'https://a.com/x'}])});
  const duCo = chay.lcOThongBao(7, '2026-09-01', false, 'sau');
  la('Người dự: đọc được biên bản host viết',
    duCo.includes('Chốt ba việc.') && duCo.includes('lcb-tb-doc'));
  la('Người dự: KHÔNG có ô gõ', !duCo.includes('<textarea'));
  la('Người dự: KHÔNG có nút bỏ link — đọc được không có nghĩa là sửa được',
    !duCo.includes('tbBoLink'));
  la('Người dự: thấy TÊN link chứ không phải địa chỉ trần',
    duCo.includes('>Biên bản</a>'));
  /* Nhãn vẽ ở HAI chỗ — bản người dự và bản host — và trước 02/09 chỉ bản host
     có phép đo. Thử phá bằng cách đổi nhãn ở riêng bản người dự thì bảng vẫn
     xanh trọn: chỗ đông người đọc nhất lại là chỗ không ai canh. */
  la('Người dự: nhãn cũng mang đúng chữ và mốc in đậm, không phải bản riêng của host',
    duCo.includes('Thông tin <b>sau sự kiện</b>'));
  la('Host: có nút bỏ từng link, đúng ô và đúng chỉ số',
    chay.lcOThongBao(7, '2026-09-01', true, 'sau').includes("tbBoLink('sau', 0)"));
}

console.log('\n── ①b Hai ô của host — trước và sau cuộc họp ───────────────');
{
  chay.dat({reset: true, CO_TB_BUOI: true, LC_NHAP: null,
    LC_HIEN: kho('chốt ba việc', [{ten: 'Biên bản', url: 'https://a'}],
                 '', 'mang theo số liệu T8', [{ten: 'agenda', url: 'https://b'}])});
  const t = chay.lcOThongBao(7, '2026-09-01', true, 'truoc');
  const u = chay.lcOThongBao(7, '2026-09-01', true, 'sau');
  la('Ô TRƯỚC mang đúng nhãn Tracy đặt, mốc in đậm',
    t.includes('Thông tin <b>trước sự kiện</b>'));
  la('Ô SAU mang đúng nhãn Tracy đặt, mốc in đậm',
    u.includes('Thông tin <b>sau sự kiện</b>'));
  /* Mốc đi vào bảng `KHI` thành mảnh `dam` RIÊNG, không nhét `<b>` vào chuỗi
     nhãn: bảng ấy là dữ liệu, để chữ thuần thì sau có ai mượn `nhan` cho
     `title=` hay cho aria cũng không lòi một cái thẻ ra giữa câu. */
  la('Phần chữ của nhãn là chữ THUẦN — không thẻ nào nằm sẵn trong dữ liệu',
    !chay.KHI.truoc.nhan.includes('<') && !chay.KHI.sau.nhan.includes('<')
    && !chay.KHI.truoc.dam.includes('<') && !chay.KHI.sau.dam.includes('<'));
  la('Hai ô đọc HAI cột khác nhau, không chung một chữ',
    t.includes('mang theo số liệu T8') && !t.includes('chốt ba việc')
    && u.includes('chốt ba việc') && !u.includes('mang theo số liệu T8'));
  la('Hai ô gõ vào HAI mảnh khác nhau của bản nháp',
    t.includes("lcNhapChu('truoc'") && u.includes("lcNhapChu('sau'"));
  la('Hai ô có id riêng — không thì một cái ghi đè cái kia lúc đọc lại',
    t.includes('id="lcb-tb-truoc"') && u.includes('id="lcb-tb-sau"'));
  /* Tracy 01/09: *"ô trước cuộc họp cũng cho gắn link luôn nhé"* — hai ô nay
     đối xứng hoàn toàn, nhưng phải là HAI DÃY RIÊNG. Một dãy dùng chung thì mở
     buổi ra đọc chuẩn bị phải lọc qua đường dẫn của một buổi chưa diễn ra. */
  la('CẢ HAI ô đều gắn link được, và mỗi nút khai đúng ô của nó',
    t.includes("tbHoiLink('truoc')") && u.includes("tbHoiLink('sau')"));
  la('Hai dãy link RIÊNG — không cái nào thấy link của cái kia',
    t.includes('agenda') && !t.includes('Biên bản')
    && u.includes('Biên bản') && !u.includes('agenda'));

  /* ⚠️ HAI LỚP NÚT ĐÃ BỊ GÁN NGƯỢC HAI LẦN — 27/08 ở hộp "Đưa cam kết về kho",
     rồi 01/09 ở chính hộp này (Tracy cầm ảnh chụp chỉ ra: "Hủy" ra khối tô đặc
     còn "Gắn link" ra đỏ viền, tức hộp sinh ra để nhận link lại mời người ta
     hủy). Hai lần cùng một lỗi thì nó không còn là chuyện nhớ hay quên — neo
     lại bằng một phép đo. Luật ba vai ở khối chú thích CSS `.hoi-nut`. */
  chay.dat({reset: true, LC_BUOI: {id: 7, ngay: '2026-09-01'}});
  chay.lcDungNhap(7, '2026-09-01');
  chay.tbHoiLink('truoc');
  const hopLk = chay.doc().HOP[0] || '';
  la('Hộp gắn link mở được — nếu không thì ba phép đo dưới đây đạt một cách rỗng',
    hopLk.includes('Gắn link') && hopLk.includes('Hủy'));
  la('Nút GẮN là việc muốn người ta chọn (`.giu`), nút HỦY là việc phụ (`.phu`)',
    /class="giu"[^>]*>Gắn link</.test(hopLk)
    && /class="phu"[^>]*>Hủy</.test(hopLk));
  la('KHÔNG nút nào trong hộp gắn link mang lớp `.chinh` — đây không phải việc phá',
    !hopLk.includes('class="chinh"'));
  /* Trả bản nháp về rỗng: `lcOThongBao` đọc bản nháp trước kho, nên để nó lại
     là mục đo ngay dưới đọc phải một bản nháp trống thay vì chữ của kho. */
  chay.dat({LC_NHAP: null});

  /* Người dự: ô nào có chữ thì hiện ô ấy, ô rỗng thì im. */
  chay.dat({LC_HIEN: kho('', [], '', 'chuẩn bị trước nhé')});
  la('Người dự: ô trước có chữ thì hiện, ô sau rỗng thì im',
    chay.lcOThongBao(7, '2026-09-01', false, 'truoc').includes('chuẩn bị trước nhé')
    && chay.lcOThongBao(7, '2026-09-01', false, 'sau') === '');

  la('Ô TRƯỚC đứng TRÊN hàng trả lời, ô SAU đứng dưới — đọc buổi bàn gì rồi mới trả lời',
    SRC.indexOf("lcOThongBao(id, ngay, laHost, 'truoc')") < SRC.indexOf('class="lcb-hai"')
    && SRC.indexOf('class="lcb-hai"') < SRC.indexOf("lcOThongBao(id, ngay, laHost, 'sau')"));
}

console.log('\n── ② Chữ người dùng gõ không phá vỡ được thẻ ───────────────');
{
  chay.dat({reset: true, LC_NHAP: null,
    LC_HIEN: kho('</textarea><img src=x onerror=alert(1)>',
      [{ten: '"><b>bậy', url: 'javascript:alert(1)'}])});
  const ra = chay.lcOThongBao(7, '2026-09-01', true, 'sau');
  la('Chữ trong ô gõ được bọc — không đóng sớm được thẻ textarea',
    !ra.includes('</textarea><img'));
  la('Tên link được bọc — dấu ngoặc kép không thoát ra khỏi thuộc tính',
    !ra.includes('"><b>bậy'));
  la('Địa chỉ `javascript:` bị bọc thành địa chỉ vô hại, không vào thẳng href',
    chay.hrefLink('javascript:alert(1)') === 'https://javascript:alert(1)');
  la('Địa chỉ thật thì giữ nguyên', chay.hrefLink('https://a.com/x') === 'https://a.com/x');
  la('Thiếu lược đồ thì thêm https://', chay.hrefLink('a.com/x') === 'https://a.com/x');
}

console.log('\n── ③ Bản nháp — thứ đang gõ phải sống qua một lượt vẽ lại ──');
{
  chay.dat({reset: true, LC_HIEN: kho('dưới máy chủ', [], 'riêng dưới máy chủ')});
  chay.lcDungNhap(7, '2026-09-01');
  la('Dựng bản nháp thì CHÉP từ kho, không trỏ vào kho',
    chay.doc().LC_NHAP.tb.sau.chu === 'dưới máy chủ'
    && chay.doc().LC_NHAP.gc === 'riêng dưới máy chủ');
  la('Vừa dựng xong thì chưa có gì đổi', chay.lcNhapDoi().co === false);

  chay.lcNhapChu('sau', 'đang gõ dở');
  la('Gõ một phím KHÔNG ra máy chủ', chay.doc().GOI.length === 0);
  la('…nhưng bản nháp biết là đã đổi', chay.lcNhapDoi().tb === true);
  la('…và ô kia thì chưa đổi gì', chay.lcNhapDoi().gc === false);
  la('Bản nháp là BẢN CHÉP — gõ vào nó không đụng kho',
    chay.doc().LC_HIEN.tb[KHOA].sau.chu === 'dưới máy chủ');

  const ra = chay.lcOThongBao(7, '2026-09-01', true, 'sau');
  la('Vẽ lại giữa chừng thì đổ ra chữ ĐANG GÕ, không phải chữ dưới máy chủ',
    ra.includes('đang gõ dở') && !ra.includes('dưới máy chủ'));

  la('Chỉ khác khoảng trắng hai đầu thì KHÔNG tính là đổi',
    (chay.lcNhapChu('sau', '  dưới máy chủ  '), chay.lcNhapDoi().co) === false);
}

console.log('\n── ④ Gắn link và bỏ link — không một lượt mạng nào ─────────');
{
  chay.dat({reset: true, LC_HIEN: kho('', [{ten: 'A', url: 'https://a'},
    {ten: 'B', url: 'https://b'}, {ten: 'C', url: 'https://c'}])});
  chay.lcDungNhap(7, '2026-09-01');
  chay.dat({DOM: {'tb-link-ten': oGia('Biên bản'), 'tb-link-url': oGia('https://doc/1')}});
  chay.tbThemLink('sau');
  la('Gắn link KHÔNG ra máy chủ — chỉ vào bản nháp', chay.doc().GOI.length === 0);
  la('Link mới nối vào cuối, có tên và địa chỉ',
    chay.doc().LC_NHAP.tb.sau.links[3].ten === 'Biên bản');
  la('Gắn xong thì đóng hộp', chay.doc().HOP.includes('DONG'));
  la('Kho vẫn nguyên ba link — chưa ai bấm Lưu',
    chay.doc().LC_HIEN.tb[KHOA].sau.links.length === 3);

  /* ⚠️ Ca đáng giá nhất của mục này từ 01/09: gắn vào ô SAU không được rơi sang
     ô TRƯỚC. Hai dãy nằm cạnh nhau trong cùng một bản nháp nên một tham số
     truyền nhầm là chúng trộn vào nhau mà chẳng có lỗi nào. */
  la('Gắn vào ô SAU thì ô TRƯỚC không dính gì',
    chay.doc().LC_NHAP.tb.truoc.links.length === 0);

  chay.dat({DOM: {'tb-link-ten': oGia('Agenda'), 'tb-link-url': oGia('https://ag')}});
  chay.tbThemLink('truoc');
  la('Gắn vào ô TRƯỚC thì vào đúng dãy của nó',
    chay.doc().LC_NHAP.tb.truoc.links.length === 1
    && chay.doc().LC_NHAP.tb.sau.links.length === 4);

  chay.tbBoLink('sau', 1);
  la('Bỏ link theo chỉ số: rơi đúng cái giữa của ĐÚNG ô',
    chay.doc().LC_NHAP.tb.sau.links.map(k => k.ten).join('') === 'ACBiên bản'
    && chay.doc().LC_NHAP.tb.truoc.links.length === 1);
  la('Bỏ link cũng KHÔNG ra máy chủ', chay.doc().GOI.length === 0);
  la('Kho VẪN nguyên — đổi ý đóng cửa thì link ấy còn nguyên dưới máy chủ',
    chay.doc().LC_HIEN.tb[KHOA].sau.links.length === 3,
    'đây là cả điểm của cú chốt 01/09');

  chay.dat({DOM: {'tb-link-ten': oGia('Chỉ có tên'), 'tb-link-url': oGia('')}});
  const truocDo = chay.doc().LC_NHAP.tb.sau.links.length;
  chay.tbThemLink('sau');
  la('Thiếu địa chỉ: nhắc một câu, không gắn gì',
    chay.doc().LC_NHAP.tb.sau.links.length === truocDo
    && chay.doc().TOAST.some(t => t.includes('địa chỉ')));

  chay.dat({DOM: {'tb-link-ten': oGia(''), 'tb-link-url': oGia('https://docs.google.com/abc/xyz')}});
  chay.tbThemLink('sau');
  const cuoi = chay.doc().LC_NHAP.tb.sau.links.slice(-1)[0];
  la('Bỏ trống tên: lấy tên miền rút gọn làm nhãn, không bắt gõ hai lần',
    cuoi.ten === 'docs.google.com/…', cuoi.ten);
}

console.log('\n── ⑤ Một cú bấm Lưu cho cả cửa ─────────────────────────────');
{
  chay.dat({reset: true, LOI: null, LC_KHO: {a: 1}, DOM: {},
    LC_HIEN: kho('chữ cũ', [], 'riêng cũ')});
  chay.lcDungNhap(7, '2026-09-01');
  la('Không có gì đổi thì bấm Lưu cũng KHÔNG tốn lượt ghi nào',
    await chay.lcLuuCua() === true && chay.doc().GOI.length === 0);

  chay.lcNhapChu('truoc', 'dặn trước');
  la('Gõ ô TRƯỚC cũng làm nút Lưu bật — hai ô cùng một dòng máy chủ',
    chay.lcNhapDoi().tb === true);
  chay.dat({DOM: {'tb-link-ten': oGia('Agenda'), 'tb-link-url': oGia('https://ag')}});
  chay.tbThemLink('truoc');
  /* Đọc bằng `?.` chứ không đọc thẳng: thiếu một cột thì phép này phải báo ❌
     rồi cho bộ chạy tiếp, không được ngã và kéo theo bốn mục sau. Đã thử phá
     đúng chỗ ấy — bản đầu ngã thật. */
  const daLuu = await chay.lcLuuCua();
  const cau = chay.doc().GOI[0] || {o: {}};
  la('Lưu thì gửi ĐỦ BỐN cột trong một câu',
    daLuu === true
    && cau.o.noi_dung_truoc === 'dặn trước'
    && cau.o.links_truoc?.length === 1
    && cau.o.noi_dung === 'chữ cũ'
    && Array.isArray(cau.o.links),
    'cột gửi đi: ' + JSON.stringify(Object.keys(cau.o)));
  la('Kho vá đủ cả hai mảnh',
    chay.doc().LC_HIEN.tb[KHOA].truoc.chu === 'dặn trước'
    && chay.doc().LC_HIEN.tb[KHOA].truoc.links.length === 1);

  chay.dat({reset: true, LC_HIEN: kho('chữ cũ', [], 'riêng cũ')});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcNhapChu('sau', 'chữ mới');
  la('Chỉ ô trên đổi → gửi ĐÚNG MỘT câu, và đúng bảng ấy',
    await chay.lcLuuCua() === true && chay.doc().GOI.length === 1
    && chay.doc().GOI[0].bang === 'thong_bao_buoi');
  la('Gửi đúng cặp khoá của một LƯỢT, và đóng dấu `tao_boi`',
    chay.doc().GOI[0].opt.onConflict === 'lich_id,ngay_goc'
    && chay.doc().GOI[0].o.tao_boi === 'toi');
  la('Kho được vá theo, nên vẽ lại không lùi về chữ cũ',
    chay.doc().LC_HIEN.tb[KHOA].sau.chu === 'chữ mới');
  la('Bản chụp dải lịch bị dọn', Object.keys(chay.doc().LC_KHO).length === 0);
  la('Lưu xong thì bản nháp thôi báo "còn thứ chưa lưu"', chay.lcNhapDoi().co === false);

  chay.dat({reset: true, LC_HIEN: kho('chữ cũ', [], 'riêng cũ')});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcNhapChu('sau', 'trên mới');
  chay.lcNhapChu('gc', 'dưới mới');
  await chay.lcLuuCua();
  la('Cả hai ô đổi → hai câu, mỗi câu một bảng, một khoá riêng',
    chay.doc().GOI.length === 2
    && chay.doc().GOI[1].bang === 'ghi_chu_buoi'
    && chay.doc().GOI[1].opt.onConflict === 'lich_id,ngay_goc,nguoi_id',
    JSON.stringify(chay.doc().GOI.map(g => g.bang)));
  la('Ghi chú riêng đóng dấu `nguoi_id`, không phải `tao_boi`',
    chay.doc().GOI[1].o.nguoi_id === 'toi');

  chay.dat({reset: true, LOI: {message: 'mất mạng'}, LC_HIEN: kho('chữ cũ', [], 'riêng cũ')});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcNhapChu('sau', 'chữ mới');
  la('Ghi hỏng → trả về HỎNG', await chay.lcLuuCua() === false);
  la('Ghi hỏng → KHO KHÔNG được đổi theo',
    chay.doc().LC_HIEN.tb[KHOA].sau.chu === 'chữ cũ',
    'vá kho trước rồi ghi hỏng là kho nói một đằng máy chủ một nẻo');
  la('Ghi hỏng → bản nháp GIỮ chữ vừa gõ, không nuốt công người ta',
    chay.doc().LC_NHAP.tb.sau.chu === 'chữ mới');
  la('Ghi hỏng → nói ra, và nói rõ ô nào',
    chay.doc().TOAST.some(t => t.includes('người tham gia')));

  chay.dat({reset: true, LOI: {message: 'x'}, LC_HIEN: kho('a', [], 'b')});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcNhapChu('gc', 'chỉ ô dưới đổi');
  await chay.lcLuuCua();
  la('Ô trên không đổi thì hỏng ở ô dưới cũng không kéo nó vào cuộc',
    chay.doc().GOI.length === 1 && chay.doc().GOI[0].bang === 'ghi_chu_buoi');
}

console.log('\n── ⑥ Nút Lưu — đóng cửa, và chỉ khi ghi ĐẠT ────────────────');
{
  const cua = {classList: {remove(){ cua.daDong = true; }}};
  chay.dat({reset: true, LOI: null, LC_HIEN: kho('cũ', [], ''),
    LC_BUOI: {id: 7, ngay: '2026-09-01'}, DOM: {'lcb-cua': cua}});
  chay.lcDungNhap(7, '2026-09-01');
  const n = nutGia();
  chay.dat({DOM: {'lcb-cua': cua, 'lcb-luu': n}});
  chay.lcVeNutLuu();
  /* ⚠️ HAI CA NÀY ĐO LẠI 03/09. Chúng còn chấm theo luật nút-xám mà Tracy bỏ
     từ 02/09, nên ca dưới đỏ suốt còn ca trên XANH RỖNG — nó chỉ đọc lại
     `disabled:true` mà chính bản giả đặt sẵn, không ai từng ghi vào đó. Nay đo
     đúng thứ `lcVeNutLuu` viết ra: cái NHÃN. */
  la('Chưa có gì đổi → nút nói "Đóng". Đây là đèn báo duy nhất của cửa này',
    n.textContent === 'Đóng');
  chay.lcNhapChu('sau', 'vừa gõ');
  la('Gõ một phím → nút đổi sang "Lưu" ngay, không đợi rời ô',
    n.textContent === 'Lưu');

  /* GHI HỎNG ĐO TRƯỚC. Ca đạt dọn sạch bản nháp nên phải chạy sau, không thì ca
     này không còn gì để lưu và nó ĐẠT một cách rỗng. */
  chay.dat({LOI: {message: 'máy chủ chối'}});
  await chay.lcLuuRoiDong(nutGia());
  la('Ghi HỎNG → cửa KHÔNG đóng, người ta còn chỗ bấm lại',
    cua.daDong !== true);
  la('…và bản nháp còn nguyên đoạn vừa gõ, không bị nuốt',
    chay.doc().LC_NHAP && chay.doc().LC_NHAP.tb.sau.chu === 'vừa gõ');
  la('…và tuyệt đối không khoe "Đã lưu"',
    !chay.doc().TOAST.some(t => String(t).includes('Đã lưu')));

  chay.dat({reset: true, LOI: null});
  await chay.lcLuuRoiDong(nutGia());
  la('Ghi ĐẠT → cửa đóng luôn, không bắt bấm thêm một cú đóng',
    cua.daDong === true);
  la('…đóng thì dọn cả bản nháp lẫn buổi đang mở',
    chay.doc().LC_NHAP === null && chay.doc().LC_BUOI === null);
  la('…hộp hỏi (nếu đang mở) cũng đóng theo — một cú bấm không để lại lớp cửa nào',
    chay.doc().HOP.includes('DONG'));
  la('…lời báo đã lưu nói bằng toast, vì mặt nút đã đi theo cửa',
    chay.doc().TOAST.some(t => String(t).includes('Đã lưu')));
  la('…và đúng MỘT lượt ghi xuống, đúng bảng của ô vừa gõ',
    chay.doc().GOI.length === 1 && chay.doc().GOI[0].bang === 'thong_bao_buoi');

  /* Đường đi từ hộp hỏi: người ta bấm Lưu ở đó lúc bản nháp đã trùng kho (vừa
     gõ vào rồi xoá đi chẳng hạn). `lcLuuCua` trả `true` mà không gửi gì — cửa
     vẫn phải đóng, chứ không đứng im như thể cú bấm rơi vào khoảng không. */
  cua.daDong = false;
  chay.dat({reset: true, LC_HIEN: kho('cũ', [], ''), LC_BUOI: {id: 7, ngay: '2026-09-01'}});
  chay.lcDungNhap(7, '2026-09-01');
  await chay.lcLuuRoiDong(nutGia());
  la('Không có gì đổi mà vẫn bấm Lưu → không tốn lượt ghi nào, nhưng cửa vẫn đóng',
    chay.doc().GOI.length === 0 && cua.daDong === true);
}

console.log('\n── ⑦ Đóng cửa — bỏ bản nháp, nhưng phải hỏi trước ──────────');
{
  const cua = {classList: {remove(){ cua.daDong = true; }}};
  chay.dat({reset: true, LC_HIEN: kho('cũ', [], ''), LC_BUOI: {id: 7, ngay: '2026-09-01'},
    DOM: {'lcb-cua': cua}});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcDongBuoi();
  la('Không có gì chưa lưu → đóng thẳng, không cản đường',
    cua.daDong === true && chay.doc().HOP.length === 0);
  la('Đóng thì dọn cả bản nháp lẫn buổi đang mở',
    chay.doc().LC_NHAP === null && chay.doc().LC_BUOI === null);

  cua.daDong = false;
  chay.dat({reset: true, LC_BUOI: {id: 7, ngay: '2026-09-01'}});
  chay.lcDungNhap(7, '2026-09-01');
  chay.lcNhapChu('sau', 'đoạn vừa gõ');
  chay.lcDongBuoi();
  la('CÒN thứ chưa lưu → hỏi một câu, KHÔNG đóng ngay',
    cua.daDong !== true && chay.doc().HOP.length === 1);
  la('Câu hỏi nói thẳng cái sắp mất', chay.doc().HOP[0].includes('chưa được lưu'));
  /* Tracy chốt 01/09: hộp này rút còn ĐÚNG MỘT CÂU. Bản cũ có tiêu đề hỏi rồi
     thêm hai dòng nói lại đúng điều tiêu đề vừa nói. Đo luôn cả cái KHÔNG có,
     vì phép đo chỉ nhìn cái có mặt thì một dòng giải thích lẻn về lúc nào cũng
     được mà không ai hay. */
  la('Hỏi bằng MỘT câu, không kèm dòng giải thích nào',
    chay.doc().HOP[0].includes('Thao tác chỉnh sửa chưa được lưu. Lưu trước nhé')
    && !chay.doc().HOP[0].includes('<p>'));
  /* Tracy chốt 02/09: việc BỎ leo lên nút ✕ góc trên phải, chân hộp thành nút
     LƯU. Đo cả cái KHÔNG còn — vai `.chinh` mà lẻn về là hộp lại mời người ta
     bỏ chữ đi một lần nữa, đúng cái vừa sửa. */
  la('Chân hộp cho đường ĐI TIẾP: Lưu tô đặc, Quay lại mặt trắng',
    /class="giu"[^>]*>Lưu</.test(chay.doc().HOP[0])
    && /class="phu"[^>]*>Quay lại</.test(chay.doc().HOP[0]));
  la('Không còn vai `.chinh` nào ở hộp này — không lối nào mời bỏ chữ đi nữa',
    !chay.doc().HOP[0].includes('class="chinh"'));
  la('✕ góc trên phải mới là đường BỎ, và nó gọi `lcDongHan` chứ không chỉ đóng hộp',
    /class="hoi-x"[\s\S]*?lcDongHan\(\)/.test(chay.doc().HOP[0]));
  la('✕ nói ra nó làm gì, không để người đọc đoán',
    chay.doc().HOP[0].includes('Đóng, không lưu'));
  la('Bản nháp còn nguyên trong lúc đang hỏi — chưa ai đồng ý bỏ',
    chay.doc().LC_NHAP.tb.sau.chu === 'đoạn vừa gõ');

  chay.lcDongHan();
  la('Bấm ✕ thì mới thật sự đóng, và KHÔNG ghi gì xuống',
    cua.daDong === true && chay.doc().LC_NHAP === null && chay.doc().GOI.length === 0);
}

console.log('\n── ⑧ Đường lấy dữ liệu và tệp SQL ──────────────────────────');
{
  la('Có cờ dò bảng riêng', SRC.includes('let CO_TB_BUOI   = false;'));
  la('Câu dò nằm trong chùm của doCotGio',
    SRC.includes("sb.from('thong_bao_buoi').select('lich_id').limit(1)")
    && SRC.includes('CO_TB_BUOI  = !rtb.error;'));
  la('lcLay hỏi cờ TRƯỚC khi thả câu, không thả rồi bắt lỗi',
    /CO_TB_BUOI\s*\n?\s*\?\s*sb\.from\('thong_bao_buoi'\)/.test(SRC),
    'thả câu vào bảng chưa có là kiemCat dựng cả dải lịch thành màn báo lỗi');
  la('Cửa lùi lúc chưa có lịch cũng mang khoá tb',
    /return \{ds: \[\], huy: \{\}, tick: \{\}, gc: \{\}, tb: \{\}\}/.test(SRC));
  la('Dòng việc đã GỠ khỏi cửa (Tracy 01/09)',
    !SRC.includes('class="lcb-viec"') && !SRC.includes('chưa ghi giờ nào'));

  const q = fs.readFileSync(path.join(__dirname, 'nang-cap-thong-bao-buoi.sql'), 'utf8');
  la('Bảng dựng theo lối chạy lại được',
    q.includes('create table if not exists thong_bao_buoi'));
  la('Khoá chính đúng cặp của một LƯỢT — không có `nguoi_id`',
    q.includes('primary key (lich_id, ngay_goc)'));
  la('Có cột `links` kiểu jsonb, mặc định mảng rỗng',
    /links\s+jsonb\s+not null default '\[\]'::jsonb/.test(q));
  la('Có cột `tao_boi` cho màn Sổ ghi chú lọc', /tao_boi\s+uuid/.test(q));
  la('Cột `noi_dung_truoc` thêm theo lối CHẠY LẠI ĐƯỢC — ai đã chạy bản đầu vẫn dùng đúng tệp này',
    /add column if not exists noi_dung_truoc text not null default ''/.test(q),
    'thêm bằng một tệp thứ hai là bắt Tracy chạy hai lần cho một việc');
  la('Ô trước có DÃY LINK RIÊNG, cũng thêm theo lối chạy lại được',
    /add column if not exists links_truoc jsonb not null default '\[\]'::jsonb/.test(q),
    'dùng chung một dãy thì đọc chuẩn bị phải lọc qua link của buổi chưa diễn ra');
  la('ĐỌC cả đội, GHI chỉ người tạo sự kiện',
    q.includes('using (la_thanh_vien())')
    && /ghi_tb_buoi[\s\S]{0,400}l\.tao_boi = nguoi_id_dang_nhap\(\)/.test(q));
  la('`with check` chặn cú gán tên người khác',
    /with check \(\s*tao_boi = nguoi_id_dang_nhap\(\)/.test(q));
  la('Xoá sự kiện thì ghi chú đi theo, không để lại dòng mồ côi',
    q.includes('on delete cascade'));
  la('Có bộ tự kiểm ở cuối tệp', q.includes('TỰ KIỂM'));
}

console.log('\n══════════════════════════════════════════════════════════');
console.log(`  ${dat} đạt · ${truot} trượt`);
console.log('══════════════════════════════════════════════════════════\n');
process.exit(truot ? 1 : 0);
})();
