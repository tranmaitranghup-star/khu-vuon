/* THỬ: GHI CHÚ RIÊNG CỦA TỪNG NGƯỜI CHO TỪNG BUỔI
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 01/09: *"note của từng thành viên tham gia là ô khác và chỉ có họ xem
   được thôi, khác nhau của từng buổi"* — và *"Host 1 ô chung là được"*, nên ô
   của host vẫn là `lich_chung.ghi_chu` cũ, chỉ đổi cách bày.

   Bốn ca đáng giá nhất — đều là chỗ thử tay từng bước KHÔNG lộ ra:

     · GHI HAI LƯỢT CHỒNG NHAU. Cú `blur` và cú đóng cửa đều gọi `lcGcLuu`, và
       cú sau có thể khởi hành trước khi cú trước về. Nếu cập nhật bản nhớ SAU
       lượt mạng thì lượt hai vẫn thấy chữ cũ và ghi thêm một lần nữa. Chữa
       bằng cách đặt chữ mới vào bản nhớ NGAY, trước khi gọi máy chủ.

     · GHI HỎNG PHẢI TRẢ LẠI CHỮ CŨ. Cập nhật lạc quan mà không có đường lùi thì
       bản nhớ nói một đằng máy chủ một nẻo, và lần mở cửa sau bày ra chữ chưa
       bao giờ được lưu — người dùng tin là đã lưu.

     · BẢNG CHƯA CÓ TRÊN MÁY CHỦ. Đây là BẢNG, không phải cột: thả một câu hỏi
       bảng chưa tồn tại thì `kiemCat` dựng cả dải lịch thành màn báo lỗi, cho
       thứ chỉ là một ô ghi chú chưa dựng. Phải hỏi cờ TRƯỚC.

     · CHỮ NGƯỜI DÙNG GÕ PHẢI ĐƯỢC BỌC. Ghi chú và tên sự kiện là chữ tự do; đổ
       thẳng vào chuỗi HTML là mở cửa cho một dấu ngoặc kép phá vỡ thẻ.

   Chạy:  node production/tinh-thuc-app/thu-ghi-chu-buoi.js
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

const NGUON = catKhoi('async function lcNoteMo(){', '/* ĐÓNG CỬA LÀ BỎ THAY ĐỔI');

const COC = `
let LC_HIEN = null, LC_BUOI = null, CO_GC_BUOI = true, LOI = null, LC_NHAP = null;
let LC_VIEC = {}, DATA = [], DOI = true, LUU_DAT = true;
let GOI = [], TOAST = [], DOM = {};
const ME = {id: 'toi'};
const chuSach = t => String(t == null ? '' : t)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const chuCoLink = t => chuSach(t);
const toast = m => TOAST.push(m);
const document = {getElementById: id => DOM[id] || null};
/* Ba bản giả của những thứ cửa này TỰA VÀO chứ không sở hữu. \`lcLuuCua\` trả
   true/false đúng như bản thật, vì phép đo "ghi hỏng thì không đóng cửa" đứng
   hay đổ hoàn toàn nhờ vế ấy. */
const lcNhapDoi = () => ({tb: false, gc: DOI, co: DOI});
const lcVeNutLuu = () => { GOI.push('veNutLuu'); };
const lcLuuCua = async () => { GOI.push('luuCua'); return LUU_DAT; };
const sb = { from: (bang) => ({ select: () => {
    const q = {eq: () => q, order: async () => {
      GOI.push({bang});
      await new Promise(r => setTimeout(r, 0));
      return {data: DATA, error: LOI};
    }};
    return q; } }) };
`;

const chay = new Function(COC + NGUON + `
  return { lcNoteMo, lcNoteDeep, lcNoteGhi, lcNoteDong,
    dat: c => { if (c.LC_HIEN !== undefined) LC_HIEN = c.LC_HIEN;
                if (c.LC_BUOI !== undefined) LC_BUOI = c.LC_BUOI;
                if (c.CO_GC_BUOI !== undefined) CO_GC_BUOI = c.CO_GC_BUOI;
                if (c.LC_NHAP !== undefined) LC_NHAP = c.LC_NHAP;
                if (c.LC_VIEC !== undefined) LC_VIEC = c.LC_VIEC;
                if (c.DATA !== undefined) DATA = c.DATA;
                if (c.DOI !== undefined) DOI = c.DOI;
                if (c.LUU_DAT !== undefined) LUU_DAT = c.LUU_DAT;
                if (c.LOI !== undefined) LOI = c.LOI;
                if (c.DOM !== undefined) DOM = c.DOM;
                if (c.reset){ GOI = []; TOAST = []; } },
    doc: () => ({GOI, TOAST, LC_BUOI, LC_NHAP, DOM}) };
`)();

/* Bản giả của bốn thẻ trong cửa. `hien` giữ nguyên tên lớp của app để phép đo
   nói đúng thứ người dùng thấy: cửa có nổi lên hay không. */
const cuaGia = () => {
  const c = {lop: new Set()};
  c.classList = {add: x => c.lop.add(x), remove: x => c.lop.delete(x),
                 contains: x => c.lop.has(x)};
  return c;
};
const oGia  = () => ({value: '', hidden: false, scrollTop: 0, scrollHeight: 99,
                      selectionStart: 0, selectionEnd: 0, focus(){ this.daFocus = true; }});
const nutGia = () => ({hidden: false});
const khuGia = () => ({innerHTML: ''});
const dungDOM = () => ({'lcb-note': cuaGia(), 'lcb-note-o': oGia(),
                        'lcb-note-ghi': nutGia(), 'lcb-note-dw': khuGia()});
const nghi = () => new Promise(r => setTimeout(r, 5));

(async function chayThu(){

/* ── ① CỬA GHI CHÚ RIÊNG ───────────────────────────────────────────────── */
console.log('\n① Cửa ghi chú riêng — mở ra đúng chữ, và cửa lùi khi bảng chưa lên máy chủ');
{
  let dom = dungDOM();
  chay.dat({reset: true, CO_GC_BUOI: false, LC_HIEN: {gc: {}}, LC_VIEC: {},
    LC_BUOI: {id: 7, ngay: '2026-09-04'},
    LC_NHAP: {id: 7, ngay: '2026-09-04', gc: ''}, DOM: dom});
  await chay.lcNoteMo();
  la('bảng chưa có → nói ĐÚNG tên tệp phải chạy',
    dom['lcb-note-dw'].innerHTML.includes('nang-cap-ghi-chu-buoi.sql'));
  la('…và GIẤU hẳn ô gõ lẫn nút Ghi',
    dom['lcb-note-o'].hidden === true && dom['lcb-note-ghi'].hidden === true,
    'bày ô gõ được mà gõ xong mất chữ là kiểu hỏng tệ nhất');
  la('cửa vẫn mở ra để nói câu ấy, không im lặng không phản ứng',
    dom['lcb-note'].classList.contains('hien'));

  dom = dungDOM();
  chay.dat({CO_GC_BUOI: true, DOM: dom,
    LC_HIEN: {gc: {'7|2026-09-04': 'chữ dưới máy chủ'}},
    LC_NHAP: {id: 7, ngay: '2026-09-04', gc: 'nhớ hỏi về ngân sách'}});
  await chay.lcNoteMo();
  la('bảng đã có → ô gõ hiện ra', dom['lcb-note-o'].hidden === false);
  la('đổ ra chữ ĐANG GÕ của bản nháp, không phải chữ dưới máy chủ',
    dom['lcb-note-o'].value === 'nhớ hỏi về ngân sách',
    'vẽ từ kho thì mỗi lượt mở lại xoá sạch đoạn chưa lưu');
  la('cửa nổi lên', dom['lcb-note'].classList.contains('hien'));

  /* Không có buổi nào đang mở thì không có gì để ghi chú vào — cửa này sống
     bám vào cửa sự kiện, không đứng một mình. */
  chay.dat({LC_BUOI: null});
  const domRong = dungDOM();
  chay.dat({DOM: domRong});
  await chay.lcNoteMo();
  la('không có buổi nào đang mở → không mở cửa',
    !domRong['lcb-note'].classList.contains('hien'));
}

/* ── ② TỔNG HỢP VỚI GHI CHÚ CỦA PHIÊN DEEPWORK ─────────────────────────── */
console.log('\n② Chữ viết trong phiên deepwork của chính buổi ấy hiện chung một chỗ');
{
  const dom = dungDOM();
  chay.dat({reset: true, CO_GC_BUOI: true, LOI: null, DOM: dom,
    LC_BUOI: {id: 7, ngay: '2026-09-04'},
    LC_NHAP: {id: 7, ngay: '2026-09-04', gc: ''},
    LC_VIEC: {'7|2026-09-04': {id: 'task-1'}},
    DATA: [{noi_dung: 'ý thứ nhất'}, {noi_dung: 'ý thứ hai'}]});
  await chay.lcNoteDeep();
  la('bày ra chữ đã viết trong phiên, dưới một nhãn nói rõ nó từ đâu',
    dom['lcb-note-dw'].innerHTML.includes('ý thứ nhất')
    && dom['lcb-note-dw'].innerHTML.includes('phiên deepwork'));
  la('nhiều dòng thì nối theo thứ tự, không bỏ dòng nào',
    /ý thứ nhất[\s\S]*ý thứ hai/.test(dom['lcb-note-dw'].innerHTML));

  chay.dat({DATA: []});
  await chay.lcNoteDeep();
  la('không có gì viết trong phiên → không để lại một nhãn rỗng',
    dom['lcb-note-dw'].innerHTML === '',
    'một nhãn không có nội dung vẫn chiếm chỗ để báo rằng không có gì');

  chay.dat({LC_VIEC: {}, DATA: [{noi_dung: 'ý lạc'}]});
  dom['lcb-note-dw'].innerHTML = '';
  await chay.lcNoteDeep();
  la('buổi chưa đẻ ra việc nào → không hỏi máy chủ, không vẽ gì',
    dom['lcb-note-dw'].innerHTML === '');

  /* ⚠️ CA ĐÁNG GIÁ NHẤT MỤC NÀY — bẫy ① trong `DANG-LAM`: đọc lại biến toàn cục
     SAU `await`. Mở buổi A, đóng, mở buổi B: lượt hỏi của A về sau và nếu nó
     không kiểm lại mình còn đúng buổi không thì ghi chú của A hiện trong cửa
     của B, mà không một dấu hiệu nào báo. */
  chay.dat({LC_VIEC: {'7|2026-09-04': {id: 'task-1'}}, DATA: [{noi_dung: 'ý của buổi A'}]});
  dom['lcb-note-dw'].innerHTML = '';
  const dangBay = chay.lcNoteDeep();
  chay.dat({LC_BUOI: {id: 9, ngay: '2026-09-11'}});   // người dùng sang buổi khác
  await dangBay;
  la('sang buổi khác giữa chừng → lượt hỏi cũ KHÔNG vẽ vào cửa đang mở',
    dom['lcb-note-dw'].innerHTML === '',
    'lượt về sau ghi đè lượt về trước, bất kể lượt nào được gọi trước');

  chay.dat({LC_BUOI: {id: 7, ngay: '2026-09-04'}, LOI: {message: 'bảng chưa có'}});
  dom['lcb-note-dw'].innerHTML = '';
  chay.dat({reset: true});
  await chay.lcNoteDeep();
  la('hỏi hỏng → im lặng, không ném lỗi lên đầu ô đang gõ',
    dom['lcb-note-dw'].innerHTML === '' && chay.doc().TOAST.length === 0,
    'đây là phần thêm cho dễ nhìn, không phải việc người ta mở cửa ra để làm');
}

/* ── ③ GHI VÀ ĐÓNG ─────────────────────────────────────────────────────── */
console.log('\n③ Nút Ghi đi qua nút Lưu của cả cửa, và chỉ đóng khi ghi ĐẠT');
{
  const dom = dungDOM();
  dom['lcb-note'].classList.add('hien');
  chay.dat({reset: true, DOM: dom, LOI: null, DOI: true, LUU_DAT: false,
    LC_BUOI: {id: 7, ngay: '2026-09-04'},
    LC_NHAP: {id: 7, ngay: '2026-09-04', gc: 'đoạn vừa gõ'}});
  const kq = await chay.lcNoteGhi();
  la('ghi HỎNG → trả về false', kq === false);
  la('…và cửa KHÔNG đóng, người ta còn chỗ bấm lại',
    dom['lcb-note'].classList.contains('hien'),
    'quay về sau lưng người ta với một tờ giấy trắng là mất chữ');
  la('…và tuyệt đối không khoe "Đã lưu"',
    !chay.doc().TOAST.some(t => /Đã lưu/.test(t)));

  chay.dat({LUU_DAT: true, reset: true});
  await chay.lcNoteGhi();
  la('ghi ĐẠT → đóng cửa ghi chú', !dom['lcb-note'].classList.contains('hien'));
  la('…đi qua nút Lưu của cả cửa, không tự gọi thẳng xuống máy chủ',
    chay.doc().GOI.includes('luuCua'),
    'một cửa hai đường ghi thì sớm muộn hai đường lệch nhau');
  la('…và nói một câu cho biết đã lưu',
    chay.doc().TOAST.some(t => /Đã lưu/.test(t)));

  chay.dat({DOI: false, reset: true});
  dom['lcb-note'].classList.add('hien');
  await chay.lcNoteGhi();
  la('không có gì đổi → vẫn đóng, nhưng KHÔNG khoe đã lưu một thứ không ai lưu',
    !dom['lcb-note'].classList.contains('hien') && chay.doc().TOAST.length === 0);

  dom['lcb-note'].classList.add('hien');
  chay.dat({reset: true, LC_NHAP: {id: 7, ngay: '2026-09-04', gc: 'đoạn chưa lưu'}});
  chay.lcNoteDong();
  la('đóng cửa KHÔNG mất chữ — bản nháp còn nguyên',
    chay.doc().LC_NHAP.gc === 'đoạn chưa lưu',
    'ở đây ✕ chỉ là gấp sổ lại, cửa sự kiện vẫn đang cầm bản nháp');
  la('…và nhắc nút Lưu của cửa sự kiện đổi nhãn',
    chay.doc().GOI.includes('veNutLuu'));
}

/* ── ④ CHỖ ĐỨNG TRONG CỬA SỰ KIỆN ──────────────────────────────────────── */
console.log('\n④ Ô thứ ba rời khỏi thân cửa, thành nút cạnh 💧');
{
  la('thân cửa sự kiện thôi dựng ô ghi chú thứ ba',
    !/\$\{lcOGhiChu\(/.test(SRC),
    'ba ô soạn xếp dọc đứng chắn ngang đường đọc của cửa');
  la('nút ghi chú đứng CHUNG cụm với 💧, đúng góc dưới bên phải',
    /class="lcb-cuoi"[\s\S]{0,400}lcNoteMo\(\)[\s\S]{0,400}nut-giot/.test(SRC));
  la('nút ấy KHÔNG tắt theo ngày như 💧 — ghi chú cho buổi tuần sau là việc hợp lẽ',
    !/lcNoteMo\(\)"[^>]*disabled/.test(SRC));
  /* Tracy 03/09: *"dùng icon ghi chú như trong phiên deep work ấy"*. Hai lối vào
     cùng một loại sổ thì phải mang cùng một hình, nếu không người ta học hai
     lần cho một việc. */
  la('nút mang ĐÚNG icon 📝 của nút ghi chú trong phiên deepwork',
    /lcNoteMo\(\)">📝<\/button>/.test(SRC)
    && /id="dw-nut-note"[\s\S]{0,200}>📝</.test(SRC));
  la('nút chỉ có hình thì phải nói ra nó làm gì — có cả nhãn cho máy đọc lẫn title',
    /aria-label="Ghi chú của riêng bạn cho buổi này"[\s\S]{0,120}title="Ghi chú của riêng bạn"/.test(SRC),
    'một cái nút chỉ có hình mà không có nhãn thì máy đọc màn hình đọc ra con số');
  la('và nó tròn đúng cỡ 💧 đứng cạnh — hai nút icon lệch cỡ thì đọc ra là lệch bậc',
    SRC.includes('.lcb-cuoi .nut-but{width:40px;height:40px'));
  la('chữ của phiên deepwork đi qua bộ bọc, không nhét thẳng vào thẻ',
    SRC.includes('<div class="lcb-tb-doc">${chuCoLink(chu)}</div>'));
  la('đóng hẳn cửa sự kiện thì cửa ghi chú đi theo, không ở lại một mình',
    /function lcDongHan\(\)\{[\s\S]{0,400}lcb-note/.test(SRC));
  la('ô gõ của cửa này cao bằng ô của phiên deepwork — Tracy muốn hai cửa giống nhau',
    SRC.includes('#lcb-note-o{min-height:150px'));
  la('cửa nổi TRÊN cửa sự kiện, khai bằng một luật chứ không nhờ thứ tự trong file',
    SRC.includes('#lcb-note{z-index:71}'));
}

/* ── ⑥ Ô CHUNG CỦA CẢ CHUỖI PHẢI BIẾN MẤT ─────────────────────────────── */
console.log('\n⑥ Ô chung cả chuỗi — Tracy gỡ 01/09, nhưng dữ liệu cũ phải ở lại');
{
  la('cửa sự kiện thôi bày khối `.lcb-bao`',
     !SRC.includes('class="lcb-bao"'));
  la('form khai lịch thôi có ô `lc-gc`',
     !SRC.includes("id=\"lc-gc\""));
  la('và `lcLuu` thôi gửi trường `ghi_chu`',
     !/ten, ghi_chu:/.test(SRC),
     'còn gửi thì mỗi lần sửa sự kiện là ghi đè chữ cũ');
  /* ⚠️ Đây là phép kiểm ĐÁNG GIÁ NHẤT mục này. Gỡ một ô khỏi giao diện mà tiện
     tay gửi chuỗi rỗng xuống cột là XOÁ SẠCH chữ cũ của mọi sự kiện đã khai —
     mà chữ ấy vẫn đang hiện trong màn Sổ ghi chú, nguồn ⑥ của nó. */
  la('KHÔNG gửi chuỗi rỗng xuống cột — cột ở lại, chữ cũ ở lại',
     !/ghi_chu:\s*''/.test(SRC) && !/ghi_chu:\s*""/.test(SRC),
     'gửi rỗng là xoá sạch chữ cũ của mọi sự kiện đã khai');
  la('CSS của khối ấy cũng dọn theo', !SRC.includes('.lcb-bao{'));
}

/* ── ⑦ ĐƯỜNG LẤY DỮ LIỆU ───────────────────────────────────────────────── */
console.log('\n⑦ Lấy ghi chú đi chung chuyến, và hỏi cờ TRƯỚC');
{
  la('có cờ dò bảng riêng', SRC.includes('let CO_GC_BUOI   = false;'));
  la('câu dò nằm trong chùm của doCotGio',
     SRC.includes("sb.from('ghi_chu_buoi').select('lich_id').limit(1)")
     && SRC.includes('CO_GC_BUOI  = !rgb.error;'));
  la('lcLay hỏi cờ TRƯỚC khi thả câu, không thả rồi bắt lỗi',
     /CO_GC_BUOI\s*\n?\s*\?\s*sb\.from\('ghi_chu_buoi'\)/.test(SRC),
     'thả câu vào bảng chưa có là kiemCat dựng cả dải lịch thành màn báo lỗi');
  /* ⚠️ NỚI LẦN HAI 01/09. Phép này canh ĐƯỜNG ĐỌC trong `lcLay`: hàng rào quyền
     `doc_gc_buoi` chỉ trả về dòng của chính mình, nên lọc thêm ở máy khách là
     viết một luật thứ hai nói cùng điều — mà hai luật nói cùng chuyện thì sớm
     muộn lệch nhau.
     Bản trước quét cả file rồi chặn ở `sb.from(` kế tiếp, và nó đỏ ngay khi màn
     Sổ ghi chú gộp lên `main` một câu `update(...).eq('nguoi_id')` — câu ấy nhắm
     ĐÚNG MỘT DÒNG để sửa, hoàn toàn chính đáng, chẳng liên quan gì tới đường
     đọc. Nay chỉ soi trong lòng `lcLay`. Bài học lặp lại lần thứ ba trong cụm
     này: đo Ý ở đúng phạm vi, đừng quét cả file rồi đoán. */
  /* Mốc cuối dò TỪ SAU mốc đầu. Dò từ đầu tệp thì ngày ai đó chép chú thích ấy
     vào một hàm đứng trên, vùng này thành RỖNG mà không một tiếng nào — bẫy
     TRI-132, xem DANG-LAM.md. */
  const D_LCLAY = 'async function lcLay(tu, den){';
  const KHOI_LCLAY = SRC.slice(SRC.indexOf(D_LCLAY),
                               SRC.indexOf('/* Các buổi của MỘT ngày', SRC.indexOf(D_LCLAY)));
  la('Đường ĐỌC không lọc nguoi_id ở máy khách — hàng rào quyền đã lọc',
     KHOI_LCLAY.includes("sb.from('ghi_chu_buoi')")
     && !/eq\('nguoi_id'/.test(KHOI_LCLAY),
     'hai luật nói cùng một chuyện thì sớm muộn lệch nhau');
  /* ⚠️ NỚI 01/09 (làn SK3): cửa lùi nay mang thêm khoá `tb` cho ghi chú của
     host. Ghim cả dấu `}` đóng là ghim luôn cái danh sách ấy không được dài ra.
     Đo rằng khoá `gc` CÓ MẶT trong cửa lùi, không đo nó đứng cuối. */
  la('cửa lùi lúc chưa có lịch cũng mang khoá gc',
     /return \{ds: \[\], huy: \{\}, tick: \{\}, gc: \{\}/.test(SRC),
     "thiếu thì cửa ghi chú đọc LC_HIEN.gc trên object không có khoá ấy");
  la('gom theo đúng cặp khoá của một lượt',
     SRC.includes("gc[g.lich_id+'|'+g.ngay_goc] = g.noi_dung || '';"));
}

/* ── ⑧ TỆP SQL ─────────────────────────────────────────────────────────── */
console.log('\n⑧ Tệp nâng cấp — hàng rào quyền là thứ duy nhất giữ ô này riêng tư');
{
  const q = fs.readFileSync(path.join(__dirname, 'nang-cap-ghi-chu-buoi.sql'), 'utf8');
  la('bảng dựng theo lối chạy lại được', q.includes('create table if not exists ghi_chu_buoi'));
  la('khoá chính đúng bộ ba lượt+người',
     q.includes('primary key (lich_id, ngay_goc, nguoi_id)'));
  la('xoá sự kiện thì ghi chú đi theo', q.includes('references lich_chung (id) on delete cascade'));
  la('hàng rào quyền BẬT', q.includes('alter table ghi_chu_buoi enable row level security'));
  la('ĐỌC chỉ chủ dòng — lead cũng không',
     /create policy doc_gc_buoi[\s\S]{0,120}using \(nguoi_id = nguoi_id_dang_nhap\(\)\)/.test(q)
     && !/doc_gc_buoi[\s\S]{0,120}la_lead/.test(q),
     'một cửa hậu cho lead thì ô này thôi là chỗ ghi thật');
  la('GHI chặn cả cú sang tên người khác',
     /create policy ghi_gc_buoi[\s\S]{0,200}with check \(nguoi_id = nguoi_id_dang_nhap\(\)\)/.test(q));
  la('chính sách dựng lại được (drop trước add)',
     q.includes('drop policy if exists doc_gc_buoi') && q.includes('drop policy if exists ghi_gc_buoi'));
  la('có chỉ mục theo người, sẵn cho sổ ghi chú ở nhát 3',
     q.includes('gcbuoi_theo_nguoi'));
  la('có bộ tự kiểm ở cuối tệp', q.includes('TỰ KIỂM'));
}

console.log(`\n${truot ? '❌' : '✅'} ${dat} ca đạt${truot ? ', ' + truot + ' ca trượt' : ''}.\n`);
process.exit(truot ? 1 : 0);
})();
