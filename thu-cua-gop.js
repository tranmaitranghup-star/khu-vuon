/* THỬ: CỬA GỘP — một cửa thêm được cả VIỆC lẫn SỰ KIỆN
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"hiện tại khi ấn vào timeline thì xổ ra thêm việc, tôi đang muốn
   có thể thêm việc hoặc thêm sự kiện"* · *"mục đích tôi muốn khi user 1 chạm vào
   timeline thì ra luôn cửa sổ để điền thay vì chọn thêm sk/task nữa rồi mới điền
   được thông tin"* · *"cả sự kiện và việc cần làm đều dùng nút thêm đi"* · *"việc
   cần làm và sự kiện đều cho chọn màu đi"*.

   Bài thử CẮT KHỐI GỐC (`let VC_LOAI` → hết `vcLuu`) ra khỏi `public/index.html`
   rồi chạy trên màn giả — không chép tay một dòng logic nào sang đây. Chép tay
   thì bài thử xanh cả khi file gốc đã hỏng, và đó là loại bài thử tệ hơn không có.

   SÁU CHỖ NÓ GÁC, cả sáu đều là lỗi IM LẶNG nếu vỡ:
     ① Đổi loại mà XOÁ thứ vừa gõ — cả lý do cửa gộp lại là để không phải gõ lại.
     ② `vcDong` để khoang sự kiện nằm lại → ba ô ẩn `lc-ten`/`lc-gio`/`lc-tu`
        trùng tên với form trong `#lc-cua`, và đường SỬA một chuỗi lặp sẽ đọc
        nhầm sang ô của cửa đã đóng. Hỏng câm, lộ ra rất muộn.
     ③ Nút Thêm đi nhầm đường: loại sự kiện mà rơi vào `ghiTaskMoi` là đẻ ra một
        task mang tên buổi họp.
     ④ Cửa đóng khi lưu HỎNG → mất trắng thứ vừa khai.
     ⑤ Dải màu hỏi nhầm cờ: `CO_MAU` là cột của `task`, `CO_MAU_LICH` là cột của
        `lich_chung`. Hai bảng, hai tệp SQL, chạy lệch nhau được.
     ⑥ Gửi cột `mau` xuống máy chủ chưa có cột ấy → CẢ CÂU LỆNH hỏng, việc không
        ghi được gì, chứ không phải một trường bị bỏ qua.

   Chạy:  node production/tinh-thuc-app/thu-cua-gop.js
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
const KHOI = catKhoi("let VC_LOAI = 'viec';", '/* ══════ MỘT NGUYÊN LÝ, MỘT CHỖ THI HÀNH');
/* `lcChonKhe` nằm xa khối trên nhưng phải soi chung: nó là chỗ DUY NHẤT cú bấm
   một khe giờ rảnh đổ vào hai ô ngày-giờ, và cửa gộp giữ hai ô ấy ở chỗ khác. */
const KHOI_KHE = catKhoi('function lcChonKhe(', '/* ══ DẢI BẬN CẢ ĐỘI');

/* `lcOLoi` sinh ra hai dòng của ô chọn lối hằng tháng. Cắt THẬT chứ không tiêm
   một bản giả: khoang sự kiện gọi nó ngay lúc dựng khung, nên một bản chép sẽ
   trôi khỏi bản gốc mà bài thử này vẫn xanh. */
/* Mốc cuối theo hàm ĐỨNG NGAY SAU, không theo một dòng chú thích: chú thích
   bị viết lại là mốc mất, còn tên hàm kế thì đổi hiếm hơn nhiều. */
const LCOLOI = catKhoi('function lcOLoi(dang){', '\nfunction lcMoTuyChinh(');
/* Khung sự kiện gọi `lcLuatMoi` để dựng luật lặp trắng. Cắt mã thật, đừng
   bịa một luật giả — bài thử so từng ô của khung, mà ô nào bày ra là do
   chính luật ấy quyết. */
const LCLUATMOI = catKhoi('function lcLuatMoi(){', '\nfunction lcOLoi(');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Màn giả: mỗi ô là một object đủ những mặt mã gốc có chạm tới. `classList`
   nhận cả dạng hai tham số `toggle(ten, ep)` vì mã gốc dùng đúng dạng ấy. */
function dungChay(opt = {}){
  const COC = `
  let CO_LICH      = ${opt.CO_LICH === false ? 'false' : 'true'};
  let CO_MAU       = ${opt.CO_MAU === false ? 'false' : 'true'};
  let CO_MAU_LICH  = ${opt.CO_MAU_LICH === false ? 'false' : 'true'};
  let CO_TUAN_THANG = ${opt.CO_TUAN_THANG === false ? 'false' : 'true'};
  let LC_SUA = 'con-sot-lai', LC_THU = [], LC_MOI = ['ai-do'], LC_MAU = 'cu';
  ${LCLUATMOI}
  ${LCOLOI}
  const LC_NHOM = [{ma:'cong_ty',ten:'Cả công ty',pv:'cong_ty'},
                   {ma:'ca_nhan',ten:'Mời người cụ thể',pv:'ca_nhan'}];
  /* CỌC cho hai bộ dòng của ô Đối tượng và ô Loại — khoang sự kiện dựng chúng
     từ 04/09 (TRI-102). Không ca nào ở đây soi tới từng dòng option; thứ các
     khối dưới đọc là cái THẺ bọc ngoài (lc-pv, lc-phut, lc-ranh-o) và số lượt
     vẽ. Cắt hàm thật vào thì kéo theo hai cờ máy chủ (CO_RIENG_TU, CO_LOAI_SK)
     và cả sổ cam kết đang gieo, mà không ca nào ở đây hỏi tới chúng.
     Không dấu huyền quanh tên hàm — cả khối nằm trong một chuỗi mẫu. */
  const lcOptNhom = ma => '';
  const lcOptLoai = ma => '';
  /* Ô LOẠI SỰ KIỆN (04/09, TRI-102) — khoang sự kiện dựng xong là gọi lcDoiLoai
     ngay, và chính nó mới là đường dẫn tới danh sách mời. Cắt THẬT hai hàm này
     chứ không tiêm bản giả, đúng lẽ đã áp cho lcOLoi: khối ③ đo "danh sách mời
     vẽ đúng một lượt", mà một bản chép tay thì trôi khỏi bản gốc trong im lặng
     rồi bài thử vẫn xanh. Ba ô lcDoiLoai đụng tới (lc-pv-hang, lc-dai, lc-loai)
     đều không có trong màn giả nên nó thoát ở từng dòng — chỉ vcVeMau và lcVeMoi
     chạy thật, đúng hai thứ các khối dưới đang đếm. */
  const O_CA_NHAN = '_cn';
  ${catKhoi('function lcLoaiDangKhai(){', '\nconst lcIdKhoi')}
  ${catKhoi('function lcDoiLoai(boQuaRanh){', '\nfunction lcVeMoi(')}
  let LC_TUAN = [];
  const ME = {id:'toi'};
  const TOAST = [], SO = {mau:[], ghiTask:[], gio:[], lcLuu:0, veMoi:0, ranh:0};
  let LC_LUU_TRA = ${opt.lcLuuTra === false ? 'false' : 'true'};
  const toast = m => TOAST.push(String(m));
  const chuSach = t => String(t == null ? '' : t);
  const homNay  = () => '2026-09-01';
  const ngayDep = x => String(x).slice(8) + '/' + String(x).slice(5,7);
  const gioTuO  = v => v ? (+String(v).split(':')[0]) + 'h' + String(v).split(':')[1] : '';
  const setTimeout = () => 0;

  function oGia(id){
    return {id, value:'', textContent:'', placeholder:'', innerHTML:'', hidden:false,
      dataset:{}, _lop:new Set(),
      classList:{ toggle(t, ep){ const c = this._c;
        if (ep === undefined) c.has(t) ? c.delete(t) : c.add(t); else ep ? c.add(t) : c.delete(t); },
        add(t){ this._c.add(t); }, remove(t){ this._c.delete(t); }, contains(t){ return this._c.has(t); } },
      setAttribute(){}, focus(){}};
  }
  const DOM = {};
  for (const id of ['viec-cua','vc-ten','vc-nd','vc-od','vc-han','vc-han-nut','vc-gio',
                    'vc-the-viec','vc-the-sk','vc-rieng-viec','vc-rieng-sk','vc-chan',
                    'vc-diden','vc-dai','lc-ten','lc-gio','lc-tu']){
    DOM[id] = oGia(id); DOM[id].classList._c = DOM[id]._lop;
  }
  const document = {getElementById: id => DOM[id] || null,
                    querySelector: () => null, querySelectorAll: () => []};

  /* Ba o an cua khoang su kien chi SONG khi khoang ay duoc dung — dung nhu
     trong app, noi chung nam trong innerHTML cua khoang. Man gia bat chuoc
     dieu do de ca 2 kiem duoc that. */
  let KHOANG_SONG = false;
  const goc = document.getElementById;
  document.getElementById = id =>
    (['lc-ten','lc-gio','lc-tu'].includes(id) && !KHOANG_SONG) ? null : (DOM[id] || null);

  const nhanNgay   = () => {};
  const gioDat     = (id, v) => SO.gio.push({id, v});
  const tlgHHMM = p => String(Math.floor(p/60)).padStart(2,'0') + ':' + String(p%60).padStart(2,'0');
  const lcVeRanh = () => { SO.ranh++; SO.ranhTu = (DOM['lc-tu'] || {}).value; };
  const gioDong    = () => {};
  const tlNhatXong = () => {};
  const nhatThoiLuong = () => {};
  const tenBoThoiLuong = (id, goc) => goc;
  const tlCua      = () => null;
  /* CỌC CHO THỨ MÃ THẬT MỚI GỌI TỚI: vcVeMau nay hỏi thêm ô Loại để dán câu
     khoá "việc cá nhân luôn màu hồng" lên dải màu. Bài này không đo câu khoá ấy
     — và trong màn giả, ô Loại luôn để trống nên hàm thật cũng trả về false ở
     mọi ca dưới đây, tức cọc nói đúng y nguyên điều hàm thật nói.
     Không dấu huyền quanh tên hàm ở đây — cả khối nằm trong một chuỗi mẫu. */
  const loaiOLa    = id => false;
  const veDaiMau   = (o, dang, ham, co, tep) => SO.mau.push({o, co, tep});
  const lcVeMoi    = () => { SO.veMoi++; };
  const lcLuu      = async () => { SO.lcLuu++;
    SO.lcLuuThay = {ten: (DOM['lc-ten']||{}).value, gio: (DOM['lc-gio']||{}).value,
                    tu: (DOM['lc-tu']||{}).value, mau: LC_MAU, sua: LC_SUA};
    return LC_LUU_TRA; };
  const ghiTaskMoi = async o => { SO.ghiTask.push(o); return {error:null, dong:{id:'t1'}}; };
  const baoLoiTask = e => String(e);
  const loiBaoTaskMoi = () => 'ok';
  const vaoDeepTuLuoi = () => {};
  const taiHomNay = async () => {};
  const lamMoiCuaToi = async () => {};

  `;
  const DUOI = `
  const _veSK = vcVeSuKien;
  vcVeSuKien = function(){ const truoc = DOM['vc-rieng-sk'].dataset.day;
    _veSK(); if (DOM['vc-rieng-sk'].dataset.day === '1' && truoc !== '1') KHOANG_SONG = true; };
  const _dong = vcDong;
  vcDong = function(){ _dong(); KHOANG_SONG = false; };
  return {DOM, TOAST, SO, api:{vcMo, vcDong, vcDoiLoai, vcLuu, vcLuuSuKien, vcChonMau, vcVeSuKien},
          api2:{lcChonKhe, vcRanhLai},
          doc: () => ({VC_LOAI, VC_MAU, LC_SUA, LC_THU, LC_MOI, LC_MAU, KHOANG_SONG})};
  `;
  return new Function(COC + KHOI_KHE + '\n' + KHOI.replace(/\bfunction vcVeSuKien\b/, 'var vcVeSuKien = function vcVeSuKien')
                                 .replace(/\bfunction vcDong\b/, 'var vcDong = function vcDong')
                          + DUOI)();
}

console.log('\n① KHOANG CHUNG KHÔNG BỊ ĐỤNG KHI ĐỔI LOẠI');
{
  const t = dungChay();
  t.api.vcMo();
  t.DOM['vc-nd'].value  = 'Họp rà soát tuần';
  t.DOM['vc-han'].value = '2026-09-02';
  t.DOM['vc-gio'].value = '15:00';
  t.api.vcDoiLoai('sk');
  la('Đổi sang Sự kiện — tên giữ nguyên',  t.DOM['vc-nd'].value === 'Họp rà soát tuần');
  la('Đổi sang Sự kiện — ngày giữ nguyên', t.DOM['vc-han'].value === '2026-09-02');
  la('Đổi sang Sự kiện — giờ giữ nguyên',  t.DOM['vc-gio'].value === '15:00');
  la('Ô tên đổi lời mời, KHÔNG nêu ví dụ',
     t.DOM['vc-nd'].placeholder === 'Tên sự kiện',
     'đang là: ' + t.DOM['vc-nd'].placeholder);
  la('Ô ngày đổi nhãn Deadline → Ngày (sự kiện bắt buộc có ngày)',
     t.DOM['vc-han-nut'].dataset.macDinh === 'Ngày');
  t.api.vcDoiLoai('viec');
  la('Quay lại Việc — tên vẫn còn', t.DOM['vc-nd'].value === 'Họp rà soát tuần');
  la('Quay lại Việc — nhãn ngày về Deadline',
     t.DOM['vc-han-nut'].dataset.macDinh === 'Deadline');
}

console.log('\n② KHOANG RIÊNG ẨN/HIỆN ĐÚNG, HÀNG CHÂN CHỈ THUỘC VỀ VIỆC');
{
  const t = dungChay();
  t.api.vcMo();
  la('Mở cửa → bày khoang Việc', t.DOM['vc-rieng-viec'].hidden === false
     && t.DOM['vc-rieng-sk'].hidden === true);
  la('Mở cửa → hàng chân (💧 và dòng "đi đâu") có mặt', t.DOM['vc-chan'].hidden === false);
  t.api.vcDoiLoai('sk');
  la('Sang Sự kiện → giấu khoang Việc, bày khoang Sự kiện',
     t.DOM['vc-rieng-viec'].hidden === true && t.DOM['vc-rieng-sk'].hidden === false);
  la('Sang Sự kiện → GIẤU hàng chân (sự kiện không có đường về kho, không vào deepwork)',
     t.DOM['vc-chan'].hidden === true);
}

console.log('\n③ ĐÓNG CỬA PHẢI DỌN KHOANG SỰ KIỆN — nếu không, ba ô trùng tên với cửa SỬA');
{
  const t = dungChay();
  t.api.vcMo(); t.api.vcDoiLoai('sk');
  la('Dựng khoang sự kiện → ba ô ẩn lc-ten/lc-gio/lc-tu có mặt', t.doc().KHOANG_SONG === true);
  /* HÀNG Ô TICK THỨ và ô luật lặp đã nhường chỗ cho MỘT ô nấc, nên hai lượt vẽ
     cũ đếm ở đây (lcVeThu · lcDoiLap) không còn hàm nào để mà đếm — cả ba tên ấy
     đã bị gỡ khỏi mã thật. Còn lại đúng một mốc đo được, và nó là mốc đáng đo:
     danh sách mời, qua chuỗi vcVeSuKien → lcDoiLoai → lcVeMoi chạy thật. */
  la('Dựng khoang → vẽ danh sách mời đúng một lượt', t.SO.veMoi === 1,
     'đã vẽ ' + t.SO.veMoi + ' lần');
  t.api.vcDoiLoai('viec'); t.api.vcDoiLoai('sk');
  la('Chạm qua chạm lại KHÔNG dựng lại (không xoá thứ vừa khai)',
     t.SO.veMoi === 1, 'đã vẽ lại ' + t.SO.veMoi + ' lần');
  t.api.vcDong();
  la('Đóng cửa → khoang sự kiện bị dọn sạch', t.DOM['vc-rieng-sk'].innerHTML === '');
  la('Đóng cửa → bỏ dấu đã-dựng để lượt sau dựng lại',
     t.DOM['vc-rieng-sk'].dataset.day === undefined);
  la('Đóng cửa → loại về mặc định Việc', t.doc().VC_LOAI === 'viec');
  la('Đóng cửa → quên màu đã chọn', t.doc().VC_MAU === null);
}

console.log('\n④ NÚT THÊM ĐI ĐÚNG ĐƯỜNG');
{
  const t = dungChay();
  t.api.vcMo();
  t.DOM['vc-nd'].value = 'gọi khách A';
  t.api.vcLuu();
  la('Loại Việc → đi đường ghi task', t.SO.ghiTask.length === 1 && t.SO.lcLuu === 0);

  const u = dungChay();
  u.api.vcMo(); u.api.vcDoiLoai('sk');
  u.DOM['vc-nd'].value  = 'Giao ban đầu tuần';
  u.DOM['vc-han'].value = '2026-09-02';
  u.DOM['vc-gio'].value = '08:30';
  return_ = u.api.vcLuu();
  la('Loại Sự kiện → KHÔNG đẻ ra task', u.SO.ghiTask.length === 0);
}

console.log('\n⑤ NHÁNH SỰ KIỆN: chép đúng ba ô, chặn khi thiếu ngày, đóng cửa đúng lúc');
(async () => {
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.DOM['vc-nd'].value  = 'Giao ban đầu tuần';
    t.DOM['vc-han'].value = '2026-09-02';
    t.DOM['vc-gio'].value = '08:30';
    t.api.vcChonMau('luc');
    await t.api.vcLuuSuKien();
    la('Chép tên sang ô lc-ten',  t.SO.lcLuuThay && t.SO.lcLuuThay.ten === 'Giao ban đầu tuần');
    la('Chép giờ sang ô lc-gio nguyên dạng HH:MM (lcLuu tách bằng dấu hai chấm)',
       t.SO.lcLuuThay && t.SO.lcLuuThay.gio === '08:30');
    la('Chép ngày sang ô lc-tu',  t.SO.lcLuuThay && t.SO.lcLuuThay.tu === '2026-09-02');
    la('Màu ở dải dùng chung đi vào LC_MAU', t.SO.lcLuuThay && t.SO.lcLuuThay.mau === 'luc');
    la('LC_SUA về null → INSERT chứ không UPDATE đè lên một chuỗi đang có',
       t.SO.lcLuuThay && t.SO.lcLuuThay.sua === null);
    la('Lưu được → đóng cửa', t.DOM['vc-rieng-sk'].innerHTML === '');
  }
  {
    const t = dungChay({lcLuuTra:false});
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.DOM['vc-nd'].value = 'Họp'; t.DOM['vc-han'].value = '2026-09-02';
    await t.api.vcLuuSuKien();
    la('Lưu HỎNG → cửa Ở LẠI, không mất thứ vừa khai',
       t.DOM['vc-rieng-sk'].innerHTML !== '');
  }
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.DOM['vc-nd'].value = 'Họp';          // cố ý bỏ trống ngày
    await t.api.vcLuuSuKien();
    la('Thiếu ngày → chặn tại chỗ, KHÔNG gọi lcLuu', t.SO.lcLuu === 0);
    la('Thiếu ngày → nói ra lý do', t.TOAST.some(m => /ngày/i.test(m)));
  }
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.DOM['vc-nd'].value = '   ';
    await t.api.vcLuuSuKien();
    la('Tên rỗng → chặn, KHÔNG gọi lcLuu', t.SO.lcLuu === 0);
  }

  console.log('\n⑥ DẢI MÀU HỎI ĐÚNG CỜ CỦA TỪNG LOẠI');
  {
    const t = dungChay({CO_MAU:true, CO_MAU_LICH:false});
    t.api.vcMo();
    const a = t.SO.mau[t.SO.mau.length-1];
    la('Loại Việc → hỏi cờ cột màu của task, và trỏ đúng tệp SQL của nó',
       a.co === true && /mau-khoi-viec/.test(a.tep));
    t.api.vcDoiLoai('sk');
    const b = t.SO.mau[t.SO.mau.length-1];
    la('Loại Sự kiện → hỏi cờ RIÊNG của lich_chung, không mượn cờ của task',
       b.co === false && /mau-su-kien/.test(b.tep),
       'co=' + b.co + ' tep=' + b.tep);
  }
  {
    const t = dungChay({CO_LICH:false});
    t.api.vcMo();
    la('Máy chủ chưa có bảng lịch → giấu hẳn thẻ Sự kiện', t.DOM['vc-the-sk'].hidden === true);
    t.api.vcDoiLoai('sk');
    la('...và chạm vào cũng không đổi loại', t.doc().VC_LOAI === 'viec');
    la('...kèm câu nói rõ phải chạy tệp nào',
       t.TOAST.some(m => /nang-cap-lich-chung\.sql/.test(m)));
  }

  console.log('\n⑦ MÀU CỦA VIỆC ĐI XUỐNG MÁY CHỦ ĐÚNG LUẬT CỜ');
  {
    const t = dungChay({CO_MAU:true});
    t.api.vcMo(); t.DOM['vc-nd'].value = 'gọi khách A'; t.api.vcChonMau('lam');
    await t.api.vcLuu();
    la('Có cột màu → gửi màu kèm việc mới', t.SO.ghiTask[0].mau === 'lam');
  }
  {
    const t = dungChay({CO_MAU:false});
    t.api.vcMo(); t.DOM['vc-nd'].value = 'gọi khách A'; t.api.vcChonMau('lam');
    await t.api.vcLuu();
    la('Chưa có cột màu → vẫn ghi được việc (không gửi cột không tồn tại)',
       t.SO.ghiTask.length === 1);
  }

  console.log('\n⑧ KHỐI GIỜ RẢNH PHẢI CÓ MẶT TRONG CỬA GỘP, KHÔNG CHỈ TRONG CỬA SỰ KIỆN CŨ');
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    const html = t.DOM['vc-rieng-sk'].innerHTML;
    la('Khoang sự kiện có ô lc-ranh-o — thiếu nó là lcVeRanh lặng lẽ quay ra',
       /id="lc-ranh-o"/.test(html));
    la('...kèm hai ô con lcr-tieu và lcr-ds mà lcVeRanh đòi',
       /id="lcr-tieu"/.test(html) && /id="lcr-ds"/.test(html));
    la('Ô chọn phạm vi và ô số phút đều dò lại khi đổi',
       /id="lc-pv"[^>]*vcRanhLai\(\)/.test(html) && /id="lc-phut"[^>]*vcRanhLai\(\)/.test(html));
    la('Chạm sang Sự kiện là dò một lượt ngay, không đợi người ta chạm thêm', t.SO.ranh >= 1);
  }
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.DOM['vc-han'].value = '2026-09-10';
    const truoc = t.SO.ranh;
    t.api2.vcRanhLai();
    la('Dò lại thì chép ngày từ ô CHUNG sang ô lc-tu mà lcVeRanh đọc',
       t.SO.ranhTu === '2026-09-10', 'lcVeRanh đọc được: ' + t.SO.ranhTu);
    la('...và có gọi lcVeRanh thật', t.SO.ranh === truoc + 1);
  }
  {
    const t = dungChay();
    t.api.vcMo();                       // đang ở loại Việc
    const truoc = t.SO.ranh;
    t.api2.vcRanhLai();
    la('Đang ở loại Việc thì KHÔNG dò giờ rảnh — việc không mời ai',
       t.SO.ranh === truoc);
  }

  console.log('\n⑨ BẤM MỘT KHE GIỜ RẢNH PHẢI ĐỔI ĐÚNG HAI Ô NGƯỜI TA ĐANG NHÌN');
  {
    const t = dungChay();
    t.api.vcMo(); t.api.vcDoiLoai('sk');
    t.api2.lcChonKhe('2026-09-08', 570, null);      // 570 phút = 09:30
    la('Cửa gộp đang mở → ô ngày CHUNG đổi theo khe vừa bấm',
       t.DOM['vc-han'].value === '2026-09-08',
       'vc-han = ' + t.DOM['vc-han'].value);
    la('...và ô giờ CHUNG cũng đổi theo',
       t.SO.gio.some(g => g.id === 'vc-gio' && g.v === '09:30'),
       JSON.stringify(t.SO.gio));
    la('...ô ẩn lc-tu vẫn đổi như cũ, để cửa Sự kiện cũ không gãy',
       t.DOM['lc-tu'].value === '2026-09-08');
  }
  {
    const t = dungChay();
    t.api2.lcChonKhe('2026-09-08', 570, null);      // cửa gộp ĐÓNG
    la('Cửa gộp đóng → KHÔNG đụng vào ô chung của nó',
       t.DOM['vc-han'].value === '' && !t.SO.gio.some(g => g.id === 'vc-gio'));
  }

  console.log(truot ? `\n❌ ${truot} ca TRƯỢT / ${dat + truot}` : `\n✅ cả ${dat} ca ĐẠT`);
  process.exit(truot ? 1 : 0);
})();
