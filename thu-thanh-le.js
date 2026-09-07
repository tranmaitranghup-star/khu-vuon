/* THỬ: THANH LỀ GIỮ NGUYÊN HÌNH KHI ĐỔI MÀN — TRI-137
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 06/09, kèm hai ảnh chụp: *"khi ấn vào mục thông tin thì lề vẫn giữ như
   ảnh 2 ý"*. Sang màn Kênh thông báo, thanh lề rụng mất cụm ba nút giữa (Việc
   hôm nay · Lịch trình · Nghi thức hoàn tất) cùng hai vạch chia — còn 6 biểu
   tượng trong khi màn Hôm nay có 9. Một thanh điều hướng đổi hình theo màn bắt
   mắt dò lại từ đầu ở mỗi lần chuyển.

   Cách chữa: màn không có cụm mốc riêng thì MƯỢN cụm của Hôm nay. Nghe như một
   dòng sửa, thật ra là BA chỗ phải khớp nhau — và bốn ca dưới đây đều hỏng theo
   kiểu "vẫn ra một thanh lề trông hợp lý", tức bấm tay không lộ ra:

     · `tat` LÀ `display:none`, KHÔNG PHẢI BÔI MỜ. `soiThanhLe` đo bằng
       `offsetParent`, mà `offsetParent` rỗng cho MỌI khối của một màn đang đóng.
       Bày cụm mượn rồi để phép đo ấy chạy nguyên là cả cụm ăn `tat` và biến mất
       lần nữa — đúng cái vừa chữa, chỉ chậm hơn một khung hình.

     · HAI NÚT CÙNG SÁNG. Ở màn Kênh thông báo, nút phải sáng là nút Kênh. Nếu
       `soiThanhLe` vẫn chấm một mốc là "đang đọc tới đây" thì có hai nút sáng và
       người dùng không biết mình đang ở đâu.

     · MỐC TỰ ẨN PHẢI ẨN Ở CẢ HAI BÊN. *Chờ bạn* giấu mình khi không ai chờ. Đo
       kiểu khác nhau ở hai màn là nó hiện bên này mất bên kia — thanh lề lại đổi
       hình, tức là chữa hụt.

     · NÚT VỪA BẤM ĐÃ BỊ THAY. `moTab` gọi `veThanhLe`, hàm ấy ghi lại
       `innerHTML` của cụm mốc. Chuyền cái nút cũ sang lượt sau là bôi `khoe` lên
       một phần tử đã rời khỏi trang — không lỗi, không ai thấy.

   Chạy:  node production/tinh-thuc-app/thu-thanh-le.js
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
const boChu = t => t.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/^\s*\/\/.*$/gm, ' ');

/* Khối thanh lề: từ bảng mốc tới hết `soiThanhLe`, ngay trước banner BẢNG TIN.
   ⚠️ Phải CẮT BỎ dòng mở banner (`/* ═══`) ở đuôi. Để nó lại là khối mang một
   chú thích chưa đóng, và cái `*​/` đầu tiên của mã ghép thêm bên dưới sẽ đóng nó
   — nuốt luôn mấy dòng nằm giữa, rồi báo một lỗi cú pháp trỏ vào chỗ chẳng liên
   quan. Vấp đúng một lần lúc dựng bài thử này. */
const LE0   = catKhoi('const MOC_LE = {', '   BẢNG TIN — TRI-96, Tracy đặt đề bài');
const LE    = LE0.slice(0, LE0.lastIndexOf('/* ═'));
const MOTAB = boChu(catKhoi('function moTab(ten, vuaNap){', '\nfunction ').split('\n').slice(0, 80).join('\n'));

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu) { dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── Sân khấu giả: đủ để khối trên chạy thật, không phải đọc mã đoán ─────────
   Không dùng thư viện DOM nào: khối này chỉ đụng vào bảy thứ (getElementById,
   querySelector(All), classList, style, innerHTML, appendChild,
   getBoundingClientRect) nên dựng tay rẻ hơn và không kéo thêm phụ thuộc. */
function taoCls(){
  const s = new Set();
  return { add:c=>s.add(c), remove:c=>s.delete(c), contains:c=>s.has(c),
    toggle:(c,on)=>{ if (on === undefined) return s.has(c) ? s.delete(c) : s.add(c);
                     return on ? s.add(c) : s.delete(c); },
    _co:c=>s.has(c) };
}
function taoEl(id){
  const el = { id, parentNode:null, classList:taoCls(), style:{display:''},
    offsetParent:{}, _top:9999, _cuon:0, innerHTML:'',
    appendChild(c){ c.parentNode = el; },
    getBoundingClientRect(){ return {top: el._top}; },
    scrollIntoView(){ el._cuon++; } };
  return el;
}

let NUT_MOC = [];
const KHO = {};
['thanh-le','avatar','nut-bt','nut-vh','nut-so','nut-tm','nut-ban',
 'hn-hang2','the-lich','cb-the','nut-chot'].forEach(id => KHO[id] = taoEl(id));

/* `#le-moc` cần một `innerHTML` BIẾT NGHE: `veThanhLe` dựng cụm mốc bằng chuỗi
   HTML, nên đây là chỗ duy nhất phải "hiểu" HTML. Bóc `data-di` là đủ — đó cũng
   chính là thứ `querySelector` của app tra. */
const om = taoEl('le-moc');
Object.defineProperty(om, 'innerHTML', {
  get(){ return om._html || ''; },
  set(v){
    om._html = v;
    om._vach = (v.match(/le-vach/g) || []).length;
    om._lam  = [...v.matchAll(/onclick="([^"]*)"/g)].map(m => m[1]);
    NUT_MOC  = [...v.matchAll(/data-di="([^"]+)"/g)].map(m => {
      const b = taoEl('nut@' + m[1]); b.dataset = {di: m[1]}; return b;
    });
  }
});
KHO['le-moc'] = om;

const GOI = { moTab: [], rAF: [] };
globalThis.document = {
  body: { classList: taoCls() },
  documentElement: { scrollHeight: 5000 },
  getElementById: id => KHO[id] || null,
  querySelector: sel => {
    const m = sel.match(/data-di="([^"]+)"/);
    return m ? (NUT_MOC.find(b => b.dataset.di === m[1]) || null) : null;
  },
  querySelectorAll: () => NUT_MOC
};
globalThis.IC = {tick:'',lich:'',cua:'',nguoi:'',loa:'',vanhanh:'',so:'',team:'',
                 vongNgay:'',camket:'',doi:'',duan:'',kho:''};
globalThis.ME = { la_quan_tri: true };
globalThis.matchMedia = () => ({ matches: true });
globalThis.addEventListener = () => {};
globalThis.requestAnimationFrame = f => GOI.rAF.push(f);
globalThis.innerHeight = 800;
globalThis.scrollY = 0;
globalThis.htMo = () => { GOI.htMo = (GOI.htMo || 0) + 1; };

const app = new Function(LE + `
  return {
    veThanhLe, leNhay, soiThanhLe,
    /* Mô phỏng đúng hai dòng moTab đặt trước khi gọi veThanhLe. Ca ① dưới
       kiểm rằng moTab thật cũng đặt đúng như vậy.
       (Chú thích này nằm TRONG một chuỗi mẫu, nên không được mang dấu huyền
        ngược — nó đóng chuỗi ngay tại đó.) */
    doiMan(man){ MAN_MOC = MOC_LE[man] ? man : 'homnay'; MAN_DANG = man;
                 document.body.classList.toggle('co-moc', !!MAN_MOC); veThanhLe(); },
    xem(){ return {MAN_MOC, MAN_DANG}; }
  };
`)();
globalThis.moTab = ten => { GOI.moTab.push(ten); app.doiMan(ten); };

const nutMoc  = id => NUT_MOC.find(b => b.dataset.di === id);
const dsMoc   = () => NUT_MOC.map(b => b.dataset.di);
const sang    = () => NUT_MOC.filter(b => b.classList._co('chon')).map(b => b.dataset.di);
const daTat   = () => NUT_MOC.filter(b => b.classList._co('tat')).map(b => b.dataset.di);

console.log('\n① `moTab` lùi cụm mốc về Hôm nay thay vì tắt hẳn');
la('màn không có cụm riêng thì mượn cụm `homnay`, không nhận chuỗi rỗng',
   /MAN_MOC\s*=\s*MOC_LE\[ten\]\s*\?\s*ten\s*:\s*'homnay'/.test(MOTAB),
   'còn `: \'\'` thì `co-moc` tắt và cả cụm mốc biến mất — đúng lỗi Tracy chụp 06/09');
la('`MAN_DANG` vẫn ghi tên màn THẬT, không ghi theo cụm mượn',
   /MAN_DANG\s*=\s*ten;/.test(MOTAB),
   'hai biến mà bằng nhau thì không hàm nào biết mình đang mượn');

console.log('\n② Đứng ở màn Kênh thông báo, cụm mốc vẫn đủ nút');
app.doiMan('bangtin');
la('cụm mốc bày đủ ba nút của Hôm nay', dsMoc().join(',') === 'hn-hang2,the-lich,nut-chot,cb-the',
   'đang bày: ' + dsMoc().join(',') || '(rỗng)');
/* Hai vạch: một cái `veThanhLe` luôn chèn ở đầu cụm (tách cụm mốc khỏi nút Kênh
   phía trên), một cái khai trong bảng `MOC_LE.homnay` giữa *Nghi thức hoàn tất*
   và *Chờ bạn*. Đúng hai cái Tracy thấy trong ảnh 2. */
la('hai vạch chia vẫn còn', om._vach === 2, 'đếm được ' + om._vach + ' vạch, phải là 2');
la('nút Kênh thông báo sáng', KHO['nut-bt'].classList._co('chon'));
la('`co-moc` bật để CSS `#le-moc{display:contents}` ăn', document.body.classList.contains('co-moc'));

console.log('\n③ Cụm mượn không bị `soiThanhLe` xoá đi (nhớ: `tat` = display:none)');
KHO['cb-the'].style.display = '';           // có người đang chờ
app.soiThanhLe();
la('không nút mốc nào ăn lớp `tat`', daTat().length === 0, 'bị tắt: ' + daTat().join(','));
la('không mốc nào tự nhận "đang đọc tới đây"', sang().length === 0, 'đang sáng: ' + sang().join(','));

console.log('\n④ Mốc tự ẩn thì ẩn ở CẢ hai màn — thanh lề mới thật sự đứng yên');
KHO['cb-the'].style.display = 'none';       // không ai chờ
app.soiThanhLe();
const tatOMuon = daTat().join(',');
KHO['cb-the'].offsetParent = null;          // cùng trạng thái, đo ở màn chủ
app.doiMan('homnay');
app.soiThanhLe();
la('*Chờ bạn* rỗng thì tắt ở màn mượn y như ở màn chủ',
   tatOMuon === 'cb-the' && daTat().includes('cb-the'),
   'màn mượn tắt [' + tatOMuon + '] · màn chủ tắt [' + daTat().join(',') + ']');

console.log('\n⑤ Ở đúng màn chủ, phép đo "đang đọc tới đâu" vẫn chạy như cũ');
KHO['hn-hang2']._top = -10;                 // đã cuộn qua
KHO['the-lich']._top = 5000;                // còn dưới xa
app.soiThanhLe();
la('mốc đã cuộn qua thì sáng lên', sang().join(',') === 'hn-hang2', 'đang sáng: ' + sang().join(','));

console.log('\n⑥ Bấm mốc từ màn khác: mở màn chủ TRƯỚC rồi mới cuộn');
app.doiMan('bangtin');
GOI.moTab.length = 0; GOI.rAF.length = 0;
KHO['hn-hang2']._cuon = 0;
app.leNhay('hn-hang2', nutMoc('hn-hang2'));
la('gọi `moTab` về đúng màn chủ', GOI.moTab.join(',') === 'homnay', 'đã gọi: ' + GOI.moTab.join(','));
la('CHƯA cuộn ngay trong lượt ấy', KHO['hn-hang2']._cuon === 0,
   'cuộn lúc màn còn đóng thì `scrollIntoView` không đi đâu cả');
GOI.rAF.forEach(f => f());
la('cuộn ở khung hình sau, khi màn đã mở', KHO['hn-hang2']._cuon === 1);
la('`khoe` bôi lên nút MỚI, không lên nút đã bị `veThanhLe` thay',
   nutMoc('hn-hang2').classList._co('khoe'),
   'nút cũ đã rời khỏi trang — bôi lên nó thì không ai thấy');

console.log('\n⑦ Bấm mốc khi đang ở đúng màn chủ: cuộn thẳng, không nạp lại màn');
app.doiMan('homnay');
GOI.moTab.length = 0; GOI.rAF.length = 0;
KHO['the-lich']._cuon = 0;
app.leNhay('the-lich', nutMoc('the-lich'));
la('không gọi `moTab`', GOI.moTab.length === 0, 'đã gọi: ' + GOI.moTab.join(','));
la('cuộn ngay trong lượt ấy', KHO['the-lich']._cuon === 1);

console.log(truot ? `\n❌ ${dat} ca đạt, ${truot} ca trượt.` : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
