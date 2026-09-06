/* THỬ: KÉO DỜI CẢ KHỐI VIỆC — và nấc Ngày dựng trên chính lưới Tuần
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 29/08: *"tôi muốn phần timeline có thể di chuyển cả task đi thay vì chỉ
   nới được khung thời gian"* · *"view ngày chưa có tính năng nới và di chuyển"*.
   Ba câu chốt ở bước duyệt: kéo ngang ĐỔI LUÔN NGÀY · nấc Ngày đi đường B (dựng
   lại bằng chính lưới Tuần) · trên cảm ứng phải GIỮ 250ms mới dời được khối.

   Bài thử CẮT ĐÚNG CÁC KHỐI GỐC ra khỏi public/index.html rồi chạy trên DOM giả
   — không chép tay một dòng logic nào sang đây.

   Ba ca đáng giá nhất:
     · CHẠM khác KÉO: nhả tay mà chưa qua ngưỡng thì KHÔNG được đặt dấu
       `TLG_VUA_KEO`, nếu không thì cửa Thông tin việc bị bịt trên mọi khối.
     · Vuốt để cuộn trên điện thoại KHÔNG được thành một việc bị dời đi.
     · Dời khối phải GIỮ NGUYÊN thời lượng — kẹp riêng từng đầu là kéo tới đáy
       thì việc tự co ngắn lại mà không ai bảo nó co.

   Chạy:  node production/tinh-thuc-app/thu-keo-doi-khoi.js
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
const NGUON = [
  catKhoi('function phutDeadline(s){',   '/* ── ĐÃ QUÁ GIỜ HẸN CHƯA'),
  catKhoi('function gioTuO(v){',         '/* ══════ NHẶT "TRONG BAO LÂU"'),
  catKhoi('function gioCong(chu, phut){','/* Phải bằng ĐÚNG con số ở Supabase'),
  catKhoi('function manhGio(gio, phut, den){', 'async function ghiTaskMoi('),
  catKhoi('const tlgHHMM = p =>',        '/* Chạm một ô giờ.'),
  catKhoi('function tlgKhoangTask(t){',  '/* Hai khối cùng khung giờ'),
  catKhoi('let TLG_KEO = null;',         '/* Cuộn tới GIỜ HIỆN TẠI'),
].join('\n');

/* ── Coc: du de cac khoi tren chay, khong hon ─────────────────────────────── */
const COC = `
const CO_GIO_SE = true;
let GHI = null;      /* cau ghi cuoi cung gui xuong may chu */
let VE_LAI = 0;      /* so lan goi lamMoiCuaToi */
const addEventListener = () => {}, removeEventListener = () => {};
const getComputedStyle = () => ({getPropertyValue: () => '38px'});
const toast = () => {};
const ngayDep = g => g;
const gioChu = p => p + "'";
const lamMoiCuaToi = async () => { VE_LAI++; };
const sb = {from: () => ({update(p){ GHI = p; return {eq: async () => ({error:null})}; }})};
/* DOM giả: các khối cắt ở đây tính lại giờ khi thả một khối, và trên đường đi
   chúng hỏi màn xem cú thả rơi vào hàng Cả ngày hay vào lưới. Không có màn
   nào ở đây, nên trả rỗng — mọi ca đo con số giờ, không đo chỗ rơi. */
const document = {querySelector: () => null, querySelectorAll: () => [],
                  getElementById: () => null};
/* htChup chụp trạng thái trước khi sửa để nút Hoàn tác có chỗ quay về. Nó
   sinh sau bài thử này và không dự phần vào con số giờ nào; trả null là
   đúng nghĩa 'không có gì để hoàn tác', đúng nhánh mà hàm thật trả khi
   không tìm thấy việc. */
const htChup = () => null;
const htTimTask = () => null;
const htNhan = () => {};
const htGhiNhat = () => {};
`;

const chay = new Function(COC + '\n' + NGUON + `
  return {manhGio, tlgHHMM, tlgKhoangTask,
          tlgKeoMo, tlgKeoChay, tlgKeoTha,
          datKeo: k => { TLG_KEO = k; return k; },
          layKeo: () => TLG_KEO,
          dauKeo: () => TLG_VUA_KEO,
          xoaDauKeo: () => { TLG_VUA_KEO = 0; },
          layGhi: () => GHI, xoaGhi: () => { GHI = null; VE_LAI = 0; },
          layVeLai: () => VE_LAI};`)();

/* ── Khung cham diem ───────────────────────────────────────────────────────── */
let dat = 0, truot = 0;
const bang = (ten, thay, mong) => {
  const a = JSON.stringify(thay), b = JSON.stringify(mong);
  if (a === b){ dat++; console.log('  ✔ ' + ten); }
  else { truot++; console.log('  ✘ ' + ten + '\n      mong : ' + b + '\n      thay : ' + a); }
};

/* ── DOM gia: mot luoi, N cot, moi cot rong 100px ─────────────────────────── */
const NGAYS = ['2026-08-24','2026-08-25','2026-08-26','2026-08-27',
               '2026-08-28','2026-08-29','2026-08-30'];
function dungLuoi(soCot, tu, den, iCot = 0){
  const el = {style:{}, dataset:{tu:String(tu), den:String(den)},
              classList:{tap:new Set(), add(c){this.tap.add(c)}, remove(c){this.tap.delete(c)}},
              querySelector: () => ({textContent:''})};
  const cots = NGAYS.slice(0, soCot).map((g,i) => ({
    dataset:{ngay:g},
    getBoundingClientRect: () => ({left: 100*i, right: 100*(i+1)}),
    appendChild(x){ this.nhan = x; }
  }));
  const luoi = {dataset:{gioDau:'7'}, querySelectorAll: () => cots};
  el.closest = sel => sel === '.tlg' ? luoi : sel === '.tlg-cot' ? cots[iCot] : el;
  return {el, cots, luoi};
}
const chuot = (x, y) => ({clientX:x, clientY:y, button:0, pointerType:'mouse',
                          currentTarget:null, preventDefault(){}, stopPropagation(){}});

/* ══ ① tlgKeoChay che do 'than' — doi cho, GIU NGUYEN do dai ═══════════════ */
console.log('\n① Dời cả khối — thời lượng không được đổi theo');
const doi = (dy, tu=570, den=720, dx=0, xGoc=0) => {
  const {el, cots} = dungLuoi(1, tu, den);
  const k = chay.datKeo({el, id:1, mep:'than', chay:true, cao:38, gd:7, tu, den,
                         batX:xGoc, batY:0, moi:null, cots, ngay:'', ngayMoi:'',
                         daDoiCot:false, hen:null});
  chay.tlgKeoChay({clientX:xGoc+dx, clientY:dy});
  return k.moi;
};
bang('kéo xuống đúng 1 giờ (38px) → cả hai đầu +60, dài vẫn 150′',
     doi(38), {tu:630, den:780});
bang('kéo lên 1 giờ → cả hai đầu −60',            doi(-38), {tu:510, den:660});
bang('kéo 10px → nấc gần nhất là 15 phút',        doi(10),  {tu:585, den:735});
bang('kéo 4px → chưa tới nửa nấc, khối đứng yên', doi(4),   {tu:570, den:720});
bang('kéo lên quá nửa đêm → chặn ở 0h, dài vẫn 150′',
     doi(-999), {tu:0, den:150});
bang('kéo xuống quá đáy → chặn ở 24h, dài vẫn 150′ (KHÔNG tự co lại)',
     doi(999), {tu:1290, den:1440});

/* ══ ② Keo ngang → doi NGAY (Tracy chot: co) ══════════════════════════════ */
console.log('\n② Kéo ngang sang cột khác → đổi ngày');
function keoNgang(xDen, soCot = 7){
  const {el, cots} = dungLuoi(soCot, 570, 720);
  const k = chay.datKeo({el, id:1, mep:'than', chay:true, cao:38, gd:7, tu:570, den:720,
                         batX:50, batY:0, moi:null, cots,
                         ngay:NGAYS[0], ngayMoi:NGAYS[0], daDoiCot:false, hen:null});
  chay.tlgKeoChay({clientX:xDen, clientY:0});
  return {k, cots, el};
}
let r = keoNgang(250);
bang('ngón sang cột thứ ba → việc thuộc về ngày của cột ấy', r.k.ngayMoi, NGAYS[2]);
bang('khối được dời hẳn sang cột mới trong cây trang',  r.cots[2].nhan === r.el, true);
bang('và trải kín bề ngang cột mới (thoát cụm chia làn)',
     [r.el.style.left, r.el.style.width], ['0','calc(100% - 3px)']);
bang('có đánh dấu đã đổi cột, để lúc thả còn biết phải vẽ lại', r.k.daDoiCot, true);
r = keoNgang(50);
bang('ngón đứng yên trong cột cũ → không đổi ngày, không dời cây trang',
     [r.k.ngayMoi, r.k.daDoiCot], [NGAYS[0], false]);
r = keoNgang(250, 1);
bang('NẤC NGÀY (một cột) → kéo ngang không đổi được gì',
     [r.k.ngayMoi, r.k.daDoiCot], [NGAYS[0], false]);

/* ══ ③ tlgKeoMo — ba duong vao che do keo ═════════════════════════════════ */
console.log('\n③ Ba đường vào chế độ kéo');
function moKeo(mep, pointerType){
  const {el} = dungLuoi(7, 570, 720);
  const e = {clientX:50, clientY:0, button:0, pointerType, currentTarget:el,
             preventDefault(){ e.daChan = true; }, stopPropagation(){ e.daDung = true; }};
  chay.tlgKeoMo(e, 1, mep);
  const k = chay.layKeo();
  return {e, k};
}
let m = moKeo('duoi', 'mouse');
bang('tay nắm mép → vào chế độ kéo NGAY',        m.k.chay, true);
bang('tay nắm mép → chặn bôi đen + chặn rơi xuống thân khối',
     [!!m.e.daChan, !!m.e.daDung], [true, true]);
m = moKeo('than', 'mouse');
bang('thân khối + chuột → CHƯA kéo, đợi qua ngưỡng 5px', m.k.chay, false);
bang('thân khối → KHÔNG chặn gì cả (còn phải chạm mở cửa, còn phải vuốt cuộn)',
     [!!m.e.daChan, !!m.e.daDung], [false, false]);
bang('thân khối + chuột → không hẹn giờ giữ',    m.k.hen, null);
m = moKeo('than', 'touch');
bang('thân khối + cảm ứng → chưa kéo, và có hẹn 250ms', 
     [m.k.chay, m.k.hen != null], [false, true]);
clearTimeout(m.k.hen);

/* Nguong 5px: di it hon thi khong vao che do keo, va khong sinh ra `moi` */
m = moKeo('than', 'mouse');
chay.tlgKeoChay(chuot(52, 3));
bang('nhích 2px ngang 3px dọc → vẫn chưa phải cú kéo', [m.k.chay, m.k.moi], [false, null]);
chay.tlgKeoChay(chuot(50, 40));
bang('đi quá ngưỡng → mới bước vào chế độ kéo',  m.k.chay, true);

/* Vuot de cuon: ngon di TRUOC khi giu du 250ms → bo han cu keo */
m = moKeo('than', 'touch');
chay.tlgKeoChay(chuot(50, 60));
bang('CẢM ỨNG: vuốt trước khi giữ đủ 250ms → buông hẳn, không dời việc nào',
     [chay.layKeo(), m.k.chay, m.k.moi], [null, false, null]);

/* ══ ④ tlgKeoTha — cham khac keo, va cau ghi ═════════════════════════════ */
console.log('\n④ Thả tay — chạm khác kéo');
(async () => {
  const dungKeo = (o) => {
    const {el, cots} = dungLuoi(7, 570, 720);
    return chay.datKeo({el, id:9, mep:'than', chay:true, cao:38, gd:7, tu:570, den:720,
                        batX:50, batY:0, moi:null, cots, ngay:NGAYS[0], ngayMoi:NGAYS[0],
                        daDoiCot:false, hen:null, ...o});
  };
  chay.xoaDauKeo();
  dungKeo({chay:false});
  await chay.tlgKeoTha();
  bang('CHẠM (chưa vào chế độ kéo) → không đặt dấu, cửa Thông tin việc vẫn mở được',
       chay.dauKeo(), 0);

  chay.xoaGhi(); chay.xoaDauKeo();
  dungKeo({moi:{tu:570, den:720}});
  await chay.tlgKeoTha();
  bang('kéo qua kéo lại về đúng chỗ cũ → đặt dấu, nhưng KHÔNG hỏi máy chủ',
       [chay.dauKeo() > 0, chay.layGhi(), chay.layVeLai()], [true, null, 0]);

  chay.xoaGhi();
  dungKeo({moi:{tu:570, den:720}, daDoiCot:true});
  await chay.tlgKeoTha();
  bang('đã nhấc sang cột khác rồi quay về → không ghi, nhưng phải VẼ LẠI',
       [chay.layGhi(), chay.layVeLai()], [null, 1]);

  console.log('\n⑤ Câu ghi gửi xuống máy chủ');
  chay.xoaGhi();
  dungKeo({moi:{tu:630, den:780}});
  await chay.tlgKeoTha();
  bang('dời 1 giờ trong cùng ngày → đủ ba trường giờ, KHÔNG đụng cột ngày',
       chay.layGhi(),
       {thoi_luong_du_kien:150, deadline:'10:30', gio_start:'10:30', gio_end:'13:00'});

  chay.xoaGhi();
  dungKeo({moi:{tu:630, den:780}, ngayMoi:NGAYS[3]});
  await chay.tlgKeoTha();
  bang('dời sang ngày khác → `ngay` đi kèm trong CÙNG một câu ghi',
       chay.layGhi(),
       {thoi_luong_du_kien:150, deadline:'10:30', gio_start:'10:30', gio_end:'13:00',
        ngay:NGAYS[3]});
  bang('ghi xong thì vẽ lại đúng một lượt', chay.layVeLai(), 1);

  bang('đọc lại bằng chính cái vẽ khối lên lưới → đúng khoảng vừa dời',
       chay.tlgKhoangTask(chay.layGhi()), {tu:630, den:780});
  /* BAY that su cua che do DOI CHO: gui gio moi ma bo quen `thoi_luong_du_kien`.
     Lan luu sau doc thoi luong CU roi tinh lai `gio_end` theo no. */
  bang('BẪY: dời mà quên gửi thời lượng → lần sau tính lại theo số cũ (2 giờ)',
       chay.tlgKhoangTask({deadline:'10:30', gio_start:'10:30', gio_end:'',
                           thoi_luong_du_kien:120}),
       {tu:630, den:750});

  console.log('\n' + (truot ? '✘ ' + truot + ' ca trượt' : '✔ ca nào cũng đạt')
              + ' · ' + dat + '/' + (dat+truot) + '\n');
  process.exit(truot ? 1 : 0);
})();
