/* THỬ: KÉO VIỆC TỪ NGOÀI VÀO LƯỚI, VÀ KÉO NGƯỢC RA
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 01/09: *"tôi muốn kéo được việc từ mục chưa xếp giờ xuống timeline và
   kéo từ kho vào timeline"* · *"cho cả kéo ngược được ko, cần á, kéo việc về
   lại kho ấy"*. Chốt phương án A: kéo-từ-khay chỉ bật ở máy tính.

   Bài thử CẮT ĐÚNG CÁC KHỐI GỐC ra khỏi public/index.html rồi chạy trên DOM giả.

   Năm ca đáng giá nhất:
     · Dò vùng thả phải dùng khung THẬT, không `elementFromPoint` — khối đang
       bay nằm ngay dưới ngón nên `elementFromPoint` luôn trả về chính nó.
     · Hai đích ngược mang HAI nghĩa: hàng chưa xếp giờ gỡ GIỜ giữ ngày, khay
       gỡ cả NGÀY. Lẫn hai cái là mất một dữ kiện người ta chưa định bỏ.
     · Cảm ứng: ngón đi TRƯỚC khi giữ đủ 350ms là cú vuốt để cuộn, phải buông.
     · Kéo từ khay KHÔNG được bật trên màn hẹp (phương án A).
     · Sau khi kéo, cú `click` bắn theo sau không được cầm việc lên lần nữa.

   Chạy:  node production/tinh-thuc-app/thu-keo-vao-luoi.js
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
const NGUON = catKhoi('/* ══ VÙNG THẢ NGOÀI LƯỚI',
                      '/* Ghi cặp giờ vừa kéo. Đi qua `manhGio`')
            + catKhoi('function manhGio(gio, phut, den){', 'async function ghiTaskMoi(');

/* ── DOM giả: đủ để dò khung, không hơn ───────────────────────────────────── */
const COC = `
const TLG_NGUONG = 5, TLG_GIU = 350;
let TLG_VUA_KEO = 0, TL_CAM = null, TLG_KHO_MO = false;
const CO_GIO_SE = true;
let GHI = null, HOI = null, VE_KHO = 0, LAM_MOI = 0, TOAST = [];
let CAY_TOI = [];
let MAN_RONG = true;
function matchMedia(){ return {matches: MAN_RONG}; }
function chuSach(s){ return String(s == null ? '' : s); }
function gioChu(p){ return p + ' phút'; }
function gioCong(g, p){ return g; }
function htChup(){ return {}; }
function htNhan(){ return null; }
let TT_VIEC = 'Chua_lam';
function htTimTask(id){ return {id, noi_dung: 'Việc ' + id, trang_thai: TT_VIEC}; }
function tvTim(id){ return {id, noi_dung: 'Việc ' + id}; }
function toast(s){ TOAST.push(s); }
function confirm(s){ HOI = s; return HOI_TRA; }
let HOI_TRA = true;
async function lamMoiCuaToi(){ LAM_MOI++; }
async function tlkTraVeKho(id, them){ VE_KHO = id; VE_KHO_THEM = them || null; }
let VE_KHO_THEM = null;
async function tlgThaVao(ngay, phut){ GHI = {ngay, phut, id: TL_CAM && TL_CAM.id}; }
function tlgVeLaiKho(){}
function tlkCam(id){ TL_CAM = {id, ten: 'Việc ' + id}; }
const sb = { from: () => ({ update(o){ GHI = o; return {
      eq: async () => ({error: null}) }; } }) };
const requestAnimationFrame = () => 1, cancelAnimationFrame = () => {};
const scrollBy = () => {}, innerHeight = 800;
const addEventListener = () => {}, removeEventListener = () => {};

function khungGia(x, y, w, h){ return {getBoundingClientRect: () => ({left:x, top:y, right:x+w, bottom:y+h, width:w, height:h}),
  classList:{ds:new Set(), toggle(c,b){ b ? this.ds.add(c) : this.ds.delete(c); },
             add(c){this.ds.add(c)}, remove(c){this.ds.delete(c)},
             contains(c){return this.ds.has(c)}}}; }
let DOM = {};
const document = {
  body: {classList:{add(){}, remove(){}}, appendChild(){}, style:{}},
  createElement: () => ({className:'', style:{}, remove(){}, textContent:''}),
  querySelector: s => DOM[s] || null,
  querySelectorAll: s => DOM[s + '[]'] || []
};
const getComputedStyle = () => ({getPropertyValue: () => '46'});
`;

const chay = new Function(COC + NGUON + `
  return { tlgDichNgoai, tlgSangDich, tlgGoGio, tlgVeKho, tlgThMo, tlgThDo,
           tlgThCham, tlgThThoi, khungGia,
           doc: () => ({GHI, HOI, VE_KHO, VE_KHO_THEM, LAM_MOI, TOAST, TL_CAM, TLG_TH,
                        TLG_KHO_MO}),
           dat: o => { if ('DOM' in o) DOM = o.DOM;
                       if ('CAY_TOI' in o) CAY_TOI = o.CAY_TOI;
                       if ('MAN_RONG' in o) MAN_RONG = o.MAN_RONG;
                       if ('HOI_TRA' in o) HOI_TRA = o.HOI_TRA;
                       if ('TT_VIEC' in o) TT_VIEC = o.TT_VIEC;
                       if ('TL_CAM' in o) TL_CAM = o.TL_CAM;
                       if ('TLG_VUA_KEO' in o) TLG_VUA_KEO = o.TLG_VUA_KEO;
                       /* Dọn sạch dấu vết lượt trước, nếu không thì ca sau
                          đọc phải kết quả của ca trước và im lặng đạt. */
                       GHI = null; HOI = null; VE_KHO = 0; VE_KHO_THEM = null; LAM_MOI = 0; TOAST = []; } };
`)();

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

(async function chayThu(){

console.log('\n① Dò vùng thả bằng khung thật');
{
  chay.dat({DOM: {'.tlg-ad': chay.khungGia(100, 200, 600, 80),
                  '.tlg-kho-nut': chay.khungGia(100, 120, 600, 40)}});
  la('giữa hàng chưa xếp giờ → "hang"', chay.tlgDichNgoai(300, 240) === 'hang');
  la('giữa nút kho → "kho"',            chay.tlgDichNgoai(300, 140) === 'kho');
  la('trên lưới, ngoài cả hai → null',  chay.tlgDichNgoai(300, 500) === null);
  la('mép phải hàng vẫn tính là ngoài', chay.tlgDichNgoai(701, 240) === null);
  la('không có toạ độ thì không đoán bừa', chay.tlgDichNgoai(null, null) === null);
}

console.log('\n② Hai đích ngược mang hai nghĩa khác nhau');
{
  chay.dat({CAY_TOI: []});
  await chay.tlgGoGio(7);
  const g = chay.doc().GHI;
  la('gỡ giờ: ba cột giờ về rỗng', g.gio_start === '' && g.gio_end === '' && g.deadline === '',
     JSON.stringify(g));
  la('gỡ giờ KHÔNG đụng cột ngày', !('ngay' in g), JSON.stringify(g));
  la('có vẽ lại sau khi gỡ', chay.doc().LAM_MOI > 0);

  chay.dat({CAY_TOI: []});
  await chay.tlgVeKho(9);
  la('về kho: đi qua đúng cửa `tlkTraVeKho`', chay.doc().VE_KHO === 9);
  la('việc chưa có phiên thì KHÔNG hỏi gì', chay.doc().HOI === null);
}

console.log('\n③ Về kho khi đã có deep work = GHI NHẬN LÀM DỞ, không phải hỏi han');
{
  chay.dat({CAY_TOI: [{task_id: 9, phut: 90}], TT_VIEC: 'Chua_lam'});
  await chay.tlgVeKho(9);
  la('KHÔNG hỏi lại gì cả', chay.doc().HOI === null, chay.doc().HOI);
  la('vẫn về kho', chay.doc().VE_KHO === 9);
  la('ghi nhận là Chưa xong', chay.doc().VE_KHO_THEM
     && chay.doc().VE_KHO_THEM.trang_thai === 'Chua_xong',
     JSON.stringify(chay.doc().VE_KHO_THEM));
  la('nói rõ giờ deepwork vẫn giữ',
     chay.doc().TOAST.some(t => /90 phút/.test(t) && /giữ nguyên/.test(t)),
     JSON.stringify(chay.doc().TOAST));

  chay.dat({CAY_TOI: [], TT_VIEC: 'Chua_lam'});
  await chay.tlgVeKho(9);
  la('chưa từng chạy phiên thì KHÔNG dán nhãn làm dở', chay.doc().VE_KHO_THEM === null);
  la('và cũng không báo gì thêm', chay.doc().TOAST.length === 0);

  chay.dat({CAY_TOI: [{task_id: 9, phut: 30}], TT_VIEC: 'Done'});
  await chay.tlgVeKho(9);
  la('việc ĐÃ XONG thì không tự mở lại thành làm dở', chay.doc().VE_KHO_THEM === null);

  chay.dat({CAY_TOI: [{task_id: 9, phut: 30}], TT_VIEC: 'Blocked'});
  await chay.tlgVeKho(9);
  la('việc đang NGHẼN cũng không bị đè nhãn', chay.doc().VE_KHO_THEM === null);

  chay.dat({CAY_TOI: [{task_id: 9, phut: 45}], TT_VIEC: 'Doing'});
  await chay.tlgVeKho(9);
  la('việc đang làm thì có dán nhãn làm dở',
     chay.doc().VE_KHO_THEM && chay.doc().VE_KHO_THEM.trang_thai === 'Chua_xong');
}

console.log('\n④ Kéo từ khay chỉ bật ở máy tính (phương án A)');
{
  chay.dat({MAN_RONG: false});
  chay.tlgThMo({pointerType:'touch', clientX:10, clientY:10}, 5, 'kho');
  la('màn hẹp: kéo từ khay KHÔNG mở', chay.doc().TLG_TH == null);
  chay.tlgThThoi();
  chay.tlgThMo({pointerType:'touch', clientX:10, clientY:10}, 5, 'hang');
  la('màn hẹp: kéo từ hàng VẪN mở', chay.doc().TLG_TH != null);
  chay.tlgThThoi();
  chay.dat({MAN_RONG: true});
  chay.tlgThMo({pointerType:'mouse', button:0, clientX:10, clientY:10}, 5, 'kho');
  la('máy tính: kéo từ khay mở được', chay.doc().TLG_TH != null);
  chay.tlgThThoi();
  chay.tlgThMo({pointerType:'mouse', button:2, clientX:10, clientY:10}, 5, 'hang');
  la('chuột phải thì bỏ qua', chay.doc().TLG_TH == null);
  chay.tlgThThoi();
}

console.log('\n⑤ Dò ô giờ dưới ngón — nấc 15 phút');
{
  const cot = chay.khungGia(200, 300, 100, 460);
  cot.dataset = {ngay: '2026-09-03'};
  cot.querySelectorAll = () => [];
  const luoi = {dataset:{gioDau:'7'}, querySelectorAll: () => [cot]};
  chay.dat({DOM: {'.tlg': luoi}});
  chay.tlgThMo({pointerType:'mouse', button:0, clientX:0, clientY:0}, 5, 'hang');
  chay.tlgThDo(250, 300);                 // đúng mép trên cột = 7h00
  la('mép trên cột = 7:00', chay.doc().TLG_TH.phut === 420, 'ra ' + chay.doc().TLG_TH.phut);
  la('nhận đúng ngày của cột', chay.doc().TLG_TH.ngay === '2026-09-03');
  chay.tlgThDo(250, 300 + 46);            // xuống một giờ = 8h00
  la('xuống 46px = 8:00', chay.doc().TLG_TH.phut === 480, 'ra ' + chay.doc().TLG_TH.phut);
  chay.tlgThDo(250, 300 + 46 + 20);       // 8h26 → làm tròn về 8h30
  la('làm tròn về nấc 15 phút', chay.doc().TLG_TH.phut === 510, 'ra ' + chay.doc().TLG_TH.phut);
  chay.tlgThDo(900, 400);                 // ra ngoài mọi cột
  la('ra ngoài lưới thì không nhắm ô nào', chay.doc().TLG_TH.phut === null);
  chay.tlgThThoi();
}

console.log('\n⑥ Cú click bắn theo sau cú kéo không được cầm việc lần nữa');
{
  chay.dat({TL_CAM: null, TLG_VUA_KEO: Date.now()});
  chay.tlgThCham(11);
  la('vừa kéo xong: click bị bỏ qua', chay.doc().TL_CAM === null);
  chay.dat({TL_CAM: null, TLG_VUA_KEO: Date.now() - 900});
  chay.tlgThCham(11);
  la('chạm bình thường: vẫn cầm được', chay.doc().TL_CAM && chay.doc().TL_CAM.id === 11);
}

console.log('\n' + (truot ? '❌ ' + truot + ' ca trượt, ' : '✅ ') + dat + ' ca đạt.');
process.exit(truot ? 1 : 0);
})();
