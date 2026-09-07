/* THỬ: CHUYỂN GIAO PIC DỰ ÁN — ô chọn trong form Sửa + nút ở khối Thành viên
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 31/08: *"làm tính năng đổi pic cho tôi"* → *"oke cứ như cam kết đi"* ·
   *"hỏi Pic cũ xem là ở lại làm thành viên hay rời hẳn dự án"* → sau khi nhìn
   bản đầu trên sóng: *"tên mục chỉ cần để là PIC: xong cho họ chọn pic là được"*
   · *"bảng thành viên của dự án cho thêm nút Chuyển giao PIC"*.

   ⚠️ HAI CA ĐẦU LÀ CA ĐÃ HỎNG THẬT, ngày 31/08. Bản đầu bắt ô PIC phải có ĐỦ ba
   điều mới mọc: form mở từ trong hồ sơ · sổ trao đã nạp kèm hồ sơ · người xem là
   PIC. Hai điều đầu là điều kiện ẩn: mở form bằng nút ✎ trên thẻ ngoài lưới, hoặc
   hồ sơ nạp từ trước khi máy chủ có sáu cột, là ô im lặng biến mất — không nút,
   không dòng nhắc, không lỗi console. Tracy tải lại mấy lần vẫn không thấy gì.
   Nay ô chỉ còn MỘT điều kiện: là PIC. Hai ca kia thành hai bài thử dưới đây.

   Bài thử CẮT KHỐI GỐC ra khỏi `public/index.html` rồi chạy trên dữ liệu giả —
   không chép tay một dòng logic nào sang đây.

   Chạy:  node production/tinh-thuc-app/thu-trao-pic.js
   Soi bản khác:
     git show HEAD:public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-trao-pic.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error(`Không thấy khối: ${dau}`);
  return SRC.slice(i, j);
}
const NGUON = [
  /* Cửa lọc ô chọn người — LẤY NGUYÊN VĂN TỪ `index.html`, không chép lại vào
     cọc bên dưới. Chép lại là ngày cờ đổi tên thì bài thử vẫn xanh trên một
     bản sao đã chết. `COC` chạy trước `NGUON` nên `DOI` đã có mặt lúc gọi. */
  catKhoi("const DOI_CHON = () =>", ";"),
  catKhoi("function duMoSua(id){", "function duNutTrangThai(d){"),
  catKhoi("const CB_LOAI = {", "/* Dòng \"Chờ bạn\" đang mở hộp."),
  catKhoi("function cbPicMo(d){", "/* ── BẤM MỘT DÒNG \"CHỜ BẠN\""),
].join('\n');

/* ── Cọc: đủ để khối trên chạy, không hơn ───────────────────────────────────
   (Cọc nằm trong một chuỗi mẫu — TUYỆT ĐỐI không dùng dấu huyền trong khối chú
   thích này, một dấu là cả tệp gãy cú pháp.) */
const COC = `
let DUAN_HS = MOI.DUAN_HS || null;
let DUAN_MO = MOI.DUAN_MO || null;
let DUAN    = MOI.DUAN || [];
let DU_SUA_ID = null;
let CB_DANG = null;
const ME  = MOI.ME  || {id:'u1'};
const DOI = MOI.DOI || [];
const CHUC_NANG = MOI.CHUC_NANG || [];
const chuSach = t => String(t == null ? '' : t)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const duTenNguoi = id => (DOI.find(n => n.id === id) || {}).ten || '—';
const toast = t => { GHI.toast.push(t); };
const hopHoiMo = (html, doc) => { GHI.hop.push({html, doc:!!doc}); DOM.datHtml(html); };
const hopHoiDong = () => { GHI.dong++; };
const nutCho = (el, chu, fn) => fn();
const cbBaoLau = luc => luc ? 'hom nay' : '';
const moHoSoDuAn = async id => { GHI.moHoSo.push(id); };
const taiDuAn    = async () => { GHI.taiDuAn++; };
const taiHomNay  = async () => { GHI.taiHomNay++; };
const sb = {
  from: () => ({select: () => ({eq: () => ({maybeSingle: async () => MOI.picTraVe || {data:null, error:null}})})}),
  rpc: async (ten, tham) => { GHI.rpc.push({ten, tham}); return MOI.rpcTraVe || {}; }
};
const document = DOM.tai;
const duGiaTri = id => { const o = DOM.tai.getElementById(id); return o ? o.value : ''; };
`;

/* DOM giả: chỉ đủ cho `duPicVe` — một ô chọn và một vùng đổi ruột. Ô chọn đọc
   thẳng từ HTML mà `hopHoiMo` vừa nhận, nên bài thử soi ĐÚNG thứ người dùng
   thấy chứ không soi một bản dựng lại bằng tay. */
function lamDOM(){
  const kho = {};
  /* Ô giả có `innerHTML` là SETTER, không phải một thuộc tính trơn: mã thật vẽ
     ô "ở lại hay rời" bằng cách gán innerHTML cho vùng `#dutr-ruot`, nên ô nào
     sinh ra theo đường ấy cũng phải tồn tại với bài thử. Bản đầu để innerHTML
     trơn nên ca ghi-từ-form ngã ở chỗ không tìm thấy `dutr-olai`. */
  function themO(id){
    if (kho[id]) return;
    let ruot = '';
    kho[id] = {value:'', disabled:false,
      get innerHTML(){ return ruot; },
      set innerHTML(h){ ruot = h; D.quet(h); }};
  }
  const D = {
    html: '',
    quet(h){
      for (const m of String(h).matchAll(/id="([a-z0-9-]+)"/g)) themO(m[1]);
      const s2 = /<select[^>]*id="dutr-olai"[\s\S]*?<\/select>/.exec(String(h));
      if (s2 && kho['dutr-olai'] && !kho['dutr-olai'].value) kho['dutr-olai'].value = '1';
    },
    datHtml(h){
      D.html = h;
      D.quet(h);
      // ô chọn PIC: lấy option đang selected làm giá trị ban đầu
      const sel = /<select[^>]*id="dus-pic"[\s\S]*?<\/select>/.exec(h);
      if (sel && kho['dus-pic']){
        const ch = /<option value="([^"]+)"\s+selected/.exec(sel[0]);
        kho['dus-pic'].value = ch ? ch[1] : '';
      }
      const sel2 = /<select[^>]*id="dutr-olai"[\s\S]*?<\/select>/.exec(h);
      if (sel2 && kho['dutr-olai'] && !kho['dutr-olai'].value) kho['dutr-olai'].value = '1';
    },
    tai: {getElementById: id => kho[id] || null}
  };
  D.o = id => kho[id];
  D.co = id => !!kho[id];
  return D;
}

const KQ = [];
const CHO = [];
function chay(ten, MOI, kiem){
  const GHI = {toast:[], hop:[], rpc:[], moHoSo:[], taiDuAn:0, taiHomNay:0, dong:0};
  const DOM = lamDOM();
  const r = {ten, dat:true, vi:null};
  KQ.push(r);
  let API;
  try {
    API = new Function('MOI','GHI','DOM', `${COC}\n${NGUON}\n
      return {duMoSua, duPicNap, duPicVe, duPicChon, duTraoMo, duTraoGhi, duRutTrao,
              CB_LOAI, cbPicMo, cbPicTuChoiMo, cbPicTraLaiMo,
              doc: () => DU_SUA_ID, datSo: p => { DU_SUA_PIC = p; },
              datChu: c => { DU_SUA_CHU = c; }};`)(MOI, GHI, DOM);
  } catch (e) { r.dat = false; r.vi = 'ngã lúc nạp: ' + e.message; return; }
  try {
    const vi = kiem(API, GHI, DOM);
    if (vi && typeof vi.then === 'function')
      CHO.push(vi.then(v => { r.dat = !v; r.vi = v; },
                       e => { r.dat = false; r.vi = 'ngã lúc chạy: ' + e.message; }));
    else { r.dat = !vi; r.vi = vi; }
  } catch (e) { r.dat = false; r.vi = 'ngã lúc chạy: ' + e.message; }
}

const DOI3 = [{id:'u1', ten:'Tracy'}, {id:'u2', ten:'Andy'}, {id:'u3', ten:'Hafi'}];
const duAn  = t => Object.assign({id:7, ten:'Dự án A', nguoi_id:'u1', ket_qua:'x', han:'2026-09-06'}, t || {});
const soPic = t => Object.assign({id:7, pic_moi_id:null, pic_moi_boi:null, pic_moi_luc:null,
  pic_cu_o_lai:null, pic_tu_choi_luc:null, pic_tu_choi_ly_do:null}, t || {});
const hoSo  = () => ({duan:duAn(), moc:[], camket:[], viec:[], pic:soPic()});

// ══ HAI CA ĐÃ HỎNG THẬT NGÀY 31/08 ═════════════════════════════════════════
chay('① mở form bằng nút ✎ NGOÀI LƯỚI vẫn thấy ô PIC (ca hỏng 31/08)',
  {DOI:DOI3, ME:{id:'u1'}, DUAN:[duAn()], DUAN_HS:null, DUAN_MO:null},
  (A, G, DOM) => { A.duMoSua(7);
    return /id="dus-pic"/.test(DOM.html) ? null
      : 'ô PIC vắng mặt khi form mở từ thẻ ngoài lưới — đúng lỗi Tracy gặp'; });

chay('② sổ trao CHƯA nạp thì ô PIC vẫn phải có (ca hỏng 31/08)',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7,
   DUAN_HS:{duan:duAn(), moc:[], camket:[], viec:[], pic:null}},
  (A, G, DOM) => { A.duMoSua();
    return /id="dus-pic"/.test(DOM.html) ? null
      : 'ô PIC treo vào sổ trao — máy chủ chậm một nhịp là nó biến mất'; });

// ══ QUYỀN ══════════════════════════════════════════════════════════════════
chay('③ người KHÔNG phải PIC không thấy ô PIC',
  {DOI:DOI3, ME:{id:'u2'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua();
    return /id="dus-pic"/.test(DOM.html) ? 'thành viên thường vẫn thấy ô chọn PIC' : null; });

chay('③ ô chọn liệt kê cả đội, đánh dấu PIC hiện tại và ghi rõ "bạn"',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua();
    const h = DOM.html;
    if (!/value="u2"/.test(h) || !/value="u3"/.test(h)) return 'thiếu người trong ô chọn';
    if (!/value="u1"\s+selected/.test(h)) return 'không đánh dấu PIC hiện tại';
    if (!/— bạn/.test(h))                 return 'không nói rõ dòng nào là mình';
    return null; });

// ══ BA HÌNH CỦA VÙNG DƯỚI Ô CHỌN ═══════════════════════════════════════════
chay('④ chọn đúng mình thì vùng dưới rỗng, không mời bấm gì',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua(); A.datChu('u1'); A.datSo(soPic());
    A.duPicChon();
    return DOM.o('dutr-ruot').innerHTML === '' ? null : 'bày nút trong khi chưa chọn ai khác'; });

chay('⑤ chọn người khác thì hỏi ở lại hay rời, rồi mới cho bấm',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua(); A.datChu('u1'); A.datSo(soPic());
    DOM.o('dus-pic').value = 'u2';
    A.duPicChon();
    const h = DOM.o('dutr-ruot').innerHTML;
    if (!/Ở lại làm thành viên/.test(h) || !/Rời hẳn dự án/.test(h))
      return 'thiếu câu hỏi PIC cũ ở lại hay rời — Tracy chốt 31/08';
    if (!/Chuyển giao PIC/.test(h))  return 'thiếu nút bấm';
    if (!/Andy/.test(h))             return 'không nhắc lại tên người sắp nhận';
    if (!/vẫn là PIC/.test(h))       return 'không nói rõ vai chưa đổi ngay';
    return null; });

chay('⑥ đang treo lời chuyển giao thì KHOÁ ô chọn, bày nút rút lại',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua(); A.datChu('u1');
    A.datSo(soPic({pic_moi_id:'u2', pic_moi_luc:'2026-08-31T09:00:00Z'}));
    A.duPicVe();
    if (!DOM.o('dus-pic').disabled) return 'ô chọn vẫn mở khi đã treo một lời — máy chủ chỉ cho treo một';
    const h = DOM.o('dutr-ruot').innerHTML;
    if (!/Andy/.test(h))     return 'không nói đang chờ ai';
    if (!/Rút lại/.test(h))  return 'thiếu lối ra — lời chuyển giao thành dòng chết';
    return null; });

chay('⑦ bị từ chối thì bày lý do, giữ nút rút lại',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duMoSua(); A.datChu('u1');
    A.datSo(soPic({pic_moi_id:'u3', pic_moi_luc:'2026-08-31T09:00:00Z',
      pic_tu_choi_luc:'2026-08-31T10:00:00Z', pic_tu_choi_ly_do:'Đang gánh hai dự án'}));
    A.duPicVe();
    const h = DOM.o('dutr-ruot').innerHTML;
    if (!/Hafi/.test(h))                 return 'không nói ai từ chối';
    if (!/Đang gánh hai dự án/.test(h))  return 'nuốt mất lý do vừa bị ép khai';
    if (!/Rút lại/.test(h))              return 'thiếu lối ra';
    return null; });

// ══ HỘP TỪ KHỐI THÀNH VIÊN ═════════════════════════════════════════════════
chay('⑧ nút ở khối Thành viên mở hộp đủ hai ô, không có mình trong danh sách',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo()},
  (A, G, DOM) => { A.duTraoMo();
    const h = G.hop[G.hop.length - 1].html;
    if (/value="u1"/.test(h))        return 'PIC hiện tại nằm trong danh sách người nhận';
    if (!/id="dutr-ai"/.test(h))     return 'thiếu ô chọn người';
    if (!/id="dutr-olai"/.test(h))   return 'thiếu ô ở lại hay rời';
    if (!/onclick="duMoSua\(\)"/.test(h))
      return 'nút Hủy đóng trắng — bấm nhầm là mất cả form sửa';
    return null; });

chay('⑧ nút Chuyển giao PIC có mặt trong khối Thành viên của hồ sơ',
  {DOI:DOI3},
  () => /Chuyển giao PIC<\/button>/.test(SRC) && /id="dh-nguoi"/.test(SRC) ? null
      : 'khối Thành viên chưa có nút Chuyển giao PIC — Tracy chốt 31/08');

// ══ ĐƯỜNG GHI ══════════════════════════════════════════════════════════════
/* ⚠️ CA NÀY GÁC MỘT LỖI NGƯỢC HẲN NGHĨA. Ô chọn trả CHUỖI '0' hoặc '1'; gửi
   thẳng xuống máy chủ thì '0' vẫn là đúng, tức PIC cũ khai *rời hẳn* mà máy chủ
   đọc ra *ở lại*. Dòng vẫn ghi, hộp vẫn đóng, toast vẫn xanh. */
chay('⑨ ghi từ FORM: đọc dus-pic, p_o_lai là boolean, neo đúng dự án',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo(), rpcTraVe:{}},
  async (A, G, DOM) => { A.duMoSua(); A.datChu('u1'); A.datSo(soPic());
    DOM.o('dus-pic').value = 'u2'; A.duPicChon();
    DOM.o('dutr-olai').value = '0';
    await A.duTraoGhi();
    const g = G.rpc.find(x => x.ten === 'trao_pic_du_an');
    if (!g) return 'không gọi trao_pic_du_an';
    if (g.tham.p_muc_tieu_id !== 7) return 'gửi sai mã dự án';
    if (g.tham.p_pic_moi !== 'u2')  return 'không đọc được ô chọn của form';
    if (typeof g.tham.p_o_lai !== 'boolean')
      return 'p_o_lai kiểu ' + typeof g.tham.p_o_lai + ' — chuỗi "0" là truthy, đúng thành sai';
    if (g.tham.p_o_lai !== false)   return 'chọn "Rời hẳn dự án" mà gửi đi thành ở lại';
    return null; });

chay('⑨ ghi từ HỘP: đọc dutr-ai chứ không lẫn với ô của form',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo(), rpcTraVe:{}},
  async (A, G, DOM) => { A.duTraoMo();
    DOM.o('dutr-ai').value = 'u3';
    await A.duTraoGhi();
    const g = G.rpc.find(x => x.ten === 'trao_pic_du_an');
    return g && g.tham.p_pic_moi === 'u3' ? null : 'không đọc được ô chọn của hộp'; });

chay('⑨ sửa từ NGOÀI LƯỚI thì ghi vẫn neo đúng dự án, và làm mới lưới',
  {DOI:DOI3, ME:{id:'u1'}, DUAN:[duAn({id:12})], DUAN_HS:null, DUAN_MO:null, rpcTraVe:{}},
  async (A, G, DOM) => { A.duMoSua(12); A.datChu('u1'); A.datSo(soPic());
    DOM.o('dus-pic').value = 'u2'; A.duPicChon();
    await A.duTraoGhi();
    const g = G.rpc.find(x => x.ten === 'trao_pic_du_an');
    if (!g || g.tham.p_muc_tieu_id !== 12) return 'neo vào hồ sơ đang mở thay vì dòng đang sửa';
    if (!G.taiDuAn) return 'không làm mới lưới danh mục sau khi ghi';
    return null; });

chay('⑨ rút lại neo đúng dự án đang sửa',
  {DOI:DOI3, ME:{id:'u1'}, DUAN_MO:7, DUAN_HS:hoSo(), rpcTraVe:{}},
  async (A, G) => { A.duMoSua();
    await A.duRutTrao();
    const g = G.rpc.find(x => x.ten === 'rut_lai_trao_pic');
    return g && g.tham.p_muc_tieu_id === 7 ? null : 'rút nhầm dự án'; });

// ══ KHỐI CHỜ BẠN ═══════════════════════════════════════════════════════════
chay('⑩ CB_LOAI đủ SÁU khoá, khớp sáu nhánh của cho_ban',
  {DOI:DOI3},
  (A) => { const can = ['loi-moi','ky-nhan','cho-nhan','bi-tu-choi','cho-nhan-pic','pic-tu-choi'];
    const thieu = can.filter(k => !A.CB_LOAI[k]);
    return thieu.length ? 'thiếu khoá: ' + thieu.join(', ') + ' — ô đếm cộng dòng mà danh sách bỏ qua' : null; });

chay('⑩ người nhận vai không bị hỏi thay PIC cũ',
  {DOI:DOI3, ME:{id:'u2'}},
  (A, G) => { A.cbPicMo({loai:'cho-nhan-pic', khoa:'7', ten:'Dự án A', ai:'Tracy', luc:'x'});
    const h = G.hop[G.hop.length - 1].html;
    if (/Rời hẳn dự án/.test(h))
      return 'hỏi người nhận về chỗ đứng của PIC cũ — câu ấy PIC cũ đã khai lúc chuyển giao';
    if (!/Nhận vai này/.test(h) || !/Từ chối/.test(h)) return 'thiếu một trong hai lối';
    return null; });

chay('⑩ cửa từ chối bắt khai lý do',
  {DOI:DOI3, ME:{id:'u2'}},
  (A, G) => { A.cbPicMo({loai:'cho-nhan-pic', khoa:'7', ten:'Dự án A', ai:'Tracy', luc:'x'});
    A.cbPicTuChoiMo();
    const h = G.hop[G.hop.length - 1].html;
    if (!/cb-pic-ly-do/.test(h)) return 'cửa từ chối thiếu ô lý do';
    if (!/bắt buộc/.test(h))     return 'không nói lý do là bắt buộc';
    return null; });

chay('⑩ hộp bị trả lại nói rõ mình vẫn là PIC, và có lối ra',
  {DOI:DOI3, ME:{id:'u1'}},
  (A, G) => { A.cbPicTraLaiMo({loai:'pic-tu-choi', khoa:'7', ten:'Dự án A', ai:'Hafi', luc:'x'});
    const h = G.hop[G.hop.length - 1].html.replace(/\s+/g,' ');
    if (!/vẫn đang là PIC/.test(h)) return 'không trấn an rằng vai chưa đổi';
    if (!/Rút lại/.test(h))        return 'thiếu lối ra';
    if (!/Giữ lại/.test(h))        return 'không có đường lui';
    return null; });

Promise.all(CHO).then(() => {
  let do_ = 0;
  for (const r of KQ){
    if (!r.dat) do_++;
    console.log(`${r.dat ? '✅' : '❌'} ${r.ten}${r.dat ? '' : '\n     → ' + r.vi}`);
  }
  console.log(`\n${KQ.length - do_}/${KQ.length} đạt`);
  process.exit(do_ ? 1 : 0);
});
