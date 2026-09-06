/* THỬ: MÀN SỔ GHI CHÚ — bốn nhóm CHỦ THỂ, sửa tại chỗ
   ─────────────────────────────────────────────────────────────────────────────
   Tracy chốt 01/09 (chiều), đảo trục của bản sáng: sổ hết chia theo NƠI SINH RA
   mẩu, nay chia theo THỨ MẨU THUỘC VỀ — Cam kết · Sự kiện định kỳ · Việc cố
   định · Sự kiện 1 lần (+ Tự do). Một chủ thể một dòng; mở ra là các gạch đầu
   dòng, sửa được tại chỗ.

   Sáu ca đáng giá nhất — cả sáu đều hỏng theo kiểu "vẫn ra một danh sách trông
   hợp lý", tức thử tay KHÔNG lộ ra:

     · NHÓM PHẢI LÀ KHOÁ XẾP CHÍNH. Xếp "đang làm" trước nhóm thì năm nhóm trộn
       vào nhau và tiêu đề dải ở cột trái mọc lại mấy lần cho cùng một tên. Bản
       đầu của làn GN2 đúng như vậy, và mắt đọc mã không thấy — bộ thử thấy.

     · CHỮ SINH ĐÔI. Cửa ra phiên ghi CÙNG một câu vào `phien_deepwork.ghi_chu`
       lẫn `task.ghi_chu_chot`. Gom thì giấu một bản, nhưng SỬA bản còn lại mà
       không sửa bản bị giấu là hai bên lệch nhau, phép so trùng hết ăn, và câu
       CŨ MỌC LẠI thành gạch thứ hai ở lượt mở sổ sau.

     · BA BẢNG CHO CẢ ĐỘI ĐỌC. Quên một `.eq('nguoi_id', ME.id)` là sổ bày ghi
       chú của mười một người khác, và KHÔNG có lỗi nào báo ra. Lỗi riêng tư,
       không phải lỗi hiển thị.

     · MỖI GẠCH VỀ ĐÚNG BẢNG ĐẺ RA NÓ. Sáu loại mẩu, sáu bảng, sáu bộ khoá khác
       nhau. Ghi nhầm bảng thì chữ vẫn "lưu thành công" và biến mất khỏi chỗ
       người ta sẽ đi tìm nó.

     · PHIÊN ĐANG CHẠY là dòng SỐNG, người ta còn viết thêm. Bày nó trong sổ là
       bày một câu viết dở.

     · GIỜ CHỮ ĐỔI PHẢI THẮNG GIỜ MƯỢN, NHƯNG KHÔNG ĐƯỢC ĐÒI. Hai cột
       `ghi_chu_luc` (01/09) chỉ có sau khi máy chủ chạy tệp SQL. Đọc hụt thì
       phải rơi êm về giờ mượn; ĐÒI cho bằng được là app trắng màn ở đúng những
       máy chủ chưa chạy tệp.

     · MỘT NGUỒN HỎNG KHÔNG ĐƯỢC KÉO CẢ SỔ THEO. Máy chủ thiếu một bảng thì phần
       còn lại vẫn phải bày ra, kèm một dòng nói thiếu gì.

   Chạy:  node production/tinh-thuc-app/thu-so-ghi-chu.js
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
const NGUON = catKhoi('let GN_DS   = [];', 'const MOC_LE = {');

/* Bỏ CHÚ THÍCH trước khi soi mã. Không bỏ thì phép kiểm bắt vào chính lời cảnh
   báo mình viết ra — ví dụ chú thích "⛔ KHÔNG bày `doc_cam_ket`" làm ca "không
   hỏi doc_cam_ket" đỏ. Đó là phép kiểm soi cái bóng của chính nó. */
const boChu = t => t.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/^\s*\/\/.*$/gm, ' ');
const SRC_SACH   = boChu(SRC);
const NGUON_SACH = boChu(NGUON);

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Kho giả: mỗi tên bảng một mảng, cộng một sổ ghi lại MỌI câu hỏi đã gửi — sổ
   ấy là thứ chứng minh được các phép lọc quyền có thật hay không. */
function dungChay(KHO, opt = {}){
  const COC = `
  let TIEU_DIEM = ${JSON.stringify(opt.TIEU_DIEM || [])};
  let CO_GC_BUOI = ${opt.CO_GC_BUOI === false ? 'false' : 'true'};
  let CO_DOC_SK = ${opt.CO_DOC_SK === false ? 'false' : 'true'};
  let CO_LICH = ${opt.CO_LICH === false ? 'false' : 'true'};
  let CO_VIEC_BUOI = ${opt.CO_VIEC_BUOI === false ? 'false' : 'true'};
  let CO_GC_NHIP = ${opt.CO_GC_NHIP === false ? 'false' : 'true'};
  const ME = {id: 'toi'};
  const KHO = ${JSON.stringify(KHO)};
  const LOI = ${JSON.stringify(opt.LOI || {})};
  const SO_HOI = [];
  const SO_GHI = [];
  const TOAST = [];
  let DOM = {};
  const toast = m => TOAST.push(m);
  const chuSach = t => String(t == null ? '' : t)
    .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;');
  const chuNhay = t => String(t == null ? '' : t).replace(/'/g, "\\\\'");
  const chuCoLink = t => String(t == null ? '' : t);
  const d2s = d => d.toISOString().slice(0,10);
  const homNay = () => '2026-09-01';
  const thuHai = ds => { const d = new Date(ds + 'T00:00:00Z');
    d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 6) % 7)); return d2s(d); };
  const ngayDep = x => String(x).slice(8) + '/' + String(x).slice(5,7);
  const document = {getElementById: id => DOM[id] || null};
  const window = {innerWidth: 1280};
  const confirm = () => true;
  const setTimeout = () => 0;
  const lcMoBuoi = () => {}; const moTab = () => {}; const IC = {sua:'<svg/>'};
  function cau(ten){
    const g = {_ten: ten, _loc: {}};
    const tra = async () => {
      SO_HOI.push({bang: ten, loc: g._loc});
      if (LOI[ten]) return {data: null, error: {message: LOI[ten]}};
      let ds = (KHO[ten] || []).slice();
      for (const [k, v] of Object.entries(g._loc))
        if (k !== '_neq' && k !== '_not') ds = ds.filter(x => x[k] === v);
      return {data: ds, error: null};
    };
    const api = {
      select(){ return api; },
      eq(k, v){ g._loc[k] = v; return api; },
      neq(){ return api; }, not(){ return api; }, order(){ return api; },
      limit(){ return tra(); },
      then(r, e){ return tra().then(r, e); },
      update(o){ SO_GHI.push({bang: ten, phep: 'update', o, loc: {}}); return api2(ten); },
      upsert(o, c){ SO_GHI.push({bang: ten, phep: 'upsert', o, onConflict: c && c.onConflict, loc: {}}); return api2(ten); },
      insert(o){ SO_GHI.push({bang: ten, phep: 'insert', o, loc: {}}); return api2(ten); },
      delete(){ SO_GHI.push({bang: ten, phep: 'delete', loc: {}}); return api2(ten); }
    };
    function api2(t){
      const k = {eq(a,b){ const l = SO_GHI[SO_GHI.length-1]; (l.loc = l.loc || {})[a] = b; return k; },
                 select(){ return k; }, limit(){ return xong(); },
                 then(r, e){ return xong().then(r, e); }};
      const xong = async () => LOI[t]
        ? {data:null, error:{message: LOI[t]}}
        : {data: [{id: 99, noi_dung: '—', tao_luc: '2026-09-01T12:00:00Z'}], error: null};
      return k;
    }
    return api;
  }
  const sb = {from: cau};
  ${NGUON}
  `;
  return new Function(COC + `
    return { gnGom, gnLocDs, gnKhiNao, gnVe, gnVeDoc, gnVeMau, gnThemDuoc,
      gnLuuMau, gnXoaMau, gnThemY, gnDatThe, gnMoi,
      dat: o => { if (o.DS) GN_DS = o.DS; if (o.CHON !== undefined) GN_CHON = o.CHON;
                  if (o.LOC) GN_LOC = o.LOC; if (o.TIM !== undefined) GN_TIM = o.TIM;
                  if (o.SUA !== undefined) GN_SUA = o.SUA;
                  if (o.XOA !== undefined) GN_XOA = o.XOA;
                  if (o.DOM) DOM = o.DOM; },
      doc: () => ({SO_HOI, SO_GHI, TOAST, GN_HONG, GN_DS, GN_CHON, GN_NHOM}) };`)();
}

const RONG = {ghi_chu:[], task:[], phien_deepwork:[], lich_chung:[],
              ghi_chu_buoi:[], doc_su_kien:[], nhip:[]};
const TUAN_NAY = '2026-08-31';        // thứ Hai của 2026-09-01
const oDOM = () => ({'gn-chip':{innerHTML:''}, 'gn-ds':{innerHTML:''},
                     'gn-doc':{innerHTML:''}, 'gn-hong':{innerHTML:''},
                     'gn-o':{value:'', focus(){}, select(){}}});
const timCT = (ds, khoa) => ds.find(c => c.khoa === khoa);

(async function chayThu(){

/* ── ① BỐN NHÓM + TỰ DO, VÀ NHÓM LÀ KHOÁ XẾP CHÍNH ────────────────────── */
console.log('\n① Bốn nhóm chủ thể — và nhóm là khoá xếp CHÍNH');
{
  const c = dungChay({...RONG,
    ghi_chu: [{id:1, noi_dung:'ý rời', tao_luc:'2026-09-01T09:00:00Z'}],
    nhip: [{id:100, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:TUAN_NAY}],
    lich_chung: [
      {id:5, ten:'Họp tuần', lap:'tuan',  dang_dung:true, ngay_bat_dau:'2026-08-01'},
      {id:6, ten:'Offsite',  lap:'khong', dang_dung:true, ngay_bat_dau:'2026-08-20'}]
  }, {TIEU_DIEM: [{ma:'O1', ten:'Cam kết A', xong:false}]});
  const ds = await c.gnGom();
  const ten = c.doc().GN_NHOM.map(x => x[0]);

  la('năm nhóm đúng tên và đúng thứ tự Tracy kê',
     JSON.stringify(ten) === JSON.stringify(['camket','dinhky','codinh','motlan','tudo']),
     JSON.stringify(ten));
  la('mỗi nhóm có chủ thể của nó', new Set(ds.map(x => x.nhom)).size === 5);
  /* Mỗi nhóm phải là ĐÚNG MỘT dải liền. Gộp các dòng liên tiếp cùng nhóm lại
     thành danh sách "dải"; nhóm nào hiện hai lần trong danh sách ấy là nó đã bị
     cắt làm đôi, và tiêu đề dải ở cột trái sẽ mọc lại hai lần cho cùng một tên. */
  const dai = ds.map(x => x.nhom).filter((n, i, a) => a[i-1] !== n);
  la('NHÓM xếp trước — mỗi nhóm đúng MỘT dải liền',
     dai.length === new Set(dai).size, dai.join(' · '));
  la('thứ tự dải đúng thứ tự GN_NHOM',
     JSON.stringify(dai) === JSON.stringify(ten.filter(k => dai.includes(k))), dai.join(' · '));
  la('Cam kết đứng dải đầu, Tự do dải cuối',
     ds[0].nhom === 'camket' && ds[ds.length-1].nhom === 'tudo');
  la('Tự do gom về MỘT dòng, không phải mỗi mẩu một dòng',
     ds.filter(x => x.nhom === 'tudo').length === 1);
  la('lịch lặp → Sự kiện định kỳ · lịch một buổi → Sự kiện 1 lần',
     timCT(ds,'lc:5').nhom === 'dinhky' && timCT(ds,'lc:6').nhom === 'motlan');
}

/* ── ② CHỦ THỂ TRỐNG VẪN CÓ MẶT, VÀ ĐANG LÀM LÊN TRÊN ─────────────────── */
console.log('\n② Chủ thể trống vẫn bày — đang làm lên trên');
{
  const c = dungChay({...RONG,
    nhip: [{id:100, nguoi_id:'toi', ten:'Việc tuần này', viec_id:7, tuan_bat_dau:TUAN_NAY},
           {id:101, nguoi_id:'toi', ten:'Việc tuần cũ',  viec_id:8, tuan_bat_dau:'2026-07-06'}],
    lich_chung: [{id:9, ten:'Chuỗi đã ngưng', lap:'tuan', dang_dung:false}]
  }, {TIEU_DIEM: [{ma:'O1', ten:'Đang chạy', xong:false},
                  {ma:'O2', ten:'Đã xong',   xong:true}]});
  const ds = await c.gnGom();
  const ck = ds.filter(x => x.nhom === 'camket');

  la('cam kết CHƯA có chữ nào vẫn có mặt', ck.length === 2);
  la('cam kết chưa xong đứng trên cam kết đã xong',
     ck[0].khoa === 'ck:O1' && ck[1].khoa === 'ck:O2');
  la('việc cố định có nhịp tuần này = đang làm', timCT(ds,'vc:7').dangLam === true);
  la('việc cố định chỉ có nhịp tuần cũ = không đang làm', timCT(ds,'vc:8').dangLam === false);
  la('việc tuần này đứng trên việc tuần cũ',
     ds.findIndex(x => x.khoa === 'vc:7') < ds.findIndex(x => x.khoa === 'vc:8'));
  la('lịch ĐÃ NGƯNG mà không có chữ thì KHÔNG bày', !timCT(ds,'lc:9'));
}

/* ── ③ TREO ĐÚNG CHỦ THỂ ──────────────────────────────────────────────── */
console.log('\n③ Mỗi mẩu về đúng chủ thể của nó');
{
  const c = dungChay({...RONG,
    ghi_chu: [
      {id:1, noi_dung:'neo cam kết', tieu_diem_ma:'O1', tao_luc:'2026-09-01T09:00:00Z'},
      {id:2, noi_dung:'gõ trong phiên nhịp', phien_id:10, tao_luc:'2026-09-01T09:00:00Z'},
      {id:3, noi_dung:'không neo đâu', tao_luc:'2026-09-01T09:00:00Z'}],
    task: [{id:20, nguoi_id:'toi', lich_id:5, noi_dung:'Soạn slide',
            ghi_chu_chot:'xong slide', xong_luc:'2026-09-01T08:00:00Z'}],
    phien_deepwork: [
      {id:10, nguoi_id:'toi', nhip_id:100, ghi_chu:'phiên nhịp xong',
       ket_qua:'song', ket_thuc:'2026-09-01T07:00:00Z'},
      {id:11, nguoi_id:'toi', task_id:20, ghi_chu:'phiên của buổi', ket_qua:'song',
       ket_thuc:'2026-09-01T06:00:00Z', task:{noi_dung:'Soạn slide', lich_id:5}}],
    nhip: [{id:100, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:TUAN_NAY}],
    lich_chung: [{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]
  }, {TIEU_DIEM: [{ma:'O1', ten:'Cam kết A', xong:false}]});
  const ds = await c.gnGom();

  la('mẩu neo cam kết → đúng cam kết ấy',
     timCT(ds,'ck:O1').mau.some(m => m.chu === 'neo cam kết'));
  la('mẩu gõ trong phiên NHỊP → việc cố định, không rơi về Tự do',
     timCT(ds,'vc:7').mau.some(m => m.chu === 'gõ trong phiên nhịp'));
  la('mẩu cuối phiên nhịp → cùng việc cố định ấy',
     timCT(ds,'vc:7').mau.some(m => m.chu === 'phiên nhịp xong'));
  la('việc gắn buổi → chuỗi sự kiện, không rơi về Tự do',
     timCT(ds,'lc:5').mau.some(m => m.chu === 'xong slide'));
  la('phiên trên việc gắn buổi → cùng chuỗi ấy',
     timCT(ds,'lc:5').mau.some(m => m.chu === 'phiên của buổi'));
  la('mẩu không neo gì → Tự do',
     timCT(ds,'td:0').mau.some(m => m.chu === 'không neo đâu'));
  la('mẩu của việc cố định KHÔNG lặp lại tên việc ở hàng meta',
     timCT(ds,'vc:7').mau.every(m => !m.ten));
}

/* ── ④ NHỊP KHÔNG CÓ viec_id — gộp theo TÊN đã chuẩn hoá ──────────────── */
console.log('\n④ Nhịp chưa trỏ danh mục thì gộp theo tên, không vỡ thành nhiều dòng');
{
  const c = dungChay({...RONG,
    nhip: [{id:1, nguoi_id:'toi', ten:'Gọi khách', tuan_bat_dau:TUAN_NAY},
           {id:2, nguoi_id:'toi', ten:' gọi KHÁCH ', tuan_bat_dau:'2026-08-24'}],
    phien_deepwork: [
      {id:10, nguoi_id:'toi', nhip_id:1, ghi_chu:'tuần này', ket_qua:'song', ket_thuc:'2026-09-01T07:00:00Z'},
      {id:11, nguoi_id:'toi', nhip_id:2, ghi_chu:'tuần trước', ket_qua:'song', ket_thuc:'2026-08-25T07:00:00Z'}]
  });
  const ds = await c.gnGom();
  const vcd = ds.filter(x => x.nhom === 'codinh');
  la('hai tuần cùng một việc gom về MỘT dòng', vcd.length === 1, vcd.map(x=>x.ten).join(' · '));
  la('cả hai mẩu nằm dưới dòng ấy', vcd[0] && vcd[0].mau.length === 2);
}

/* ── ⑤ QUYỀN RIÊNG TƯ — ba bảng cả đội đọc phải lọc chủ tay ───────────── */
console.log('\n⑤ Ba bảng cho cả đội đọc — phải lọc chủ tay');
{
  const c = dungChay({...RONG,
    lich_chung: [{id:5, ten:'Buổi của người khác', lap:'tuan', dang_dung:true,
                  tao_boi:'nguoi_khac', ghi_chu:'ô chung của họ', sua_luc:'2026-09-01T09:00:00Z'},
                 {id:6, ten:'Buổi của mình', lap:'tuan', dang_dung:true,
                  tao_boi:'toi', ghi_chu:'ô chung của mình', sua_luc:'2026-09-01T09:00:00Z'}]
  });
  const ds = await c.gnGom();
  const hoi = c.doc().SO_HOI;
  const loc = b => hoi.filter(h => h.bang === b).some(h => h.loc.nguoi_id === 'toi');

  la('task lọc nguoi_id', loc('task'));
  la('phien_deepwork lọc nguoi_id', loc('phien_deepwork'));
  la('nhip lọc nguoi_id', loc('nhip'));
  la('lich_chung KHÔNG lọc nguoi_id (bảng ấy không có cột đó)',
     !hoi.filter(h => h.bang === 'lich_chung').some(h => h.loc.nguoi_id));
  /* ⚠️ ĐẢO CHIỀU 01/09. Hai ca ở đây từng canh "ô chung của người khác không
     vào sổ, của mình thì vào". Tracy gỡ hẳn ô chung của cả chuỗi khỏi app
     (*"xóa hết ghi chú chung của cả chuỗi đi tôi đã bảo thừa rồi mà"*), nên nay
     canh điều NGƯỢC LẠI: không chữ nào từ `lich_chung.ghi_chu` được vào sổ, kể
     cả của chính mình. Đổi chứ không nới cho xanh — ca này đỏ được nếu ai đó vô
     tình cắm lại nguồn ấy. */
  la('chữ từ `lich_chung.ghi_chu` KHÔNG còn vào sổ, kể cả của chính mình',
     !timCT(ds,'lc:5').mau.length && !timCT(ds,'lc:6').mau.length);
  la('…và không gạch nào còn mang loại `chung`',
     !ds.some(ct => ct.mau.some(m => m.loai === 'chung')));
  /* Hai chuỗi ấy VẪN là chủ thể của sổ — câu hỏi `lich_chung` không gỡ theo, vì
     nó còn nuôi tên dòng, nhóm định kỳ hay một lần, và thứ tự. */
  la('nhưng hai chuỗi vẫn còn là chủ thể trên cột trái',
     !!timCT(ds,'lc:5') && !!timCT(ds,'lc:6'));
  la('ba bảng riêng tư KHÔNG lọc lại nguoi_id (hàng rào quyền đã lọc)',
     !['ghi_chu','ghi_chu_buoi','doc_su_kien'].some(b => loc(b)));
}

/* ── ⑥ PHIÊN ĐANG CHẠY — dòng sống, chưa bày ─────────────────────────── */
console.log('\n⑥ Phiên đang chạy là dòng SỐNG — chưa bày trong sổ');
{
  const c = dungChay({...RONG,
    ghi_chu: [{id:1, noi_dung:'đang viết dở', phien_id:10, tao_luc:'2026-09-01T09:00:00Z'}],
    phien_deepwork: [{id:10, nguoi_id:'toi', task_id:20, ghi_chu:'chưa xong đâu',
                      ket_qua:'dang_chay', bat_dau:'2026-09-01T08:00:00Z',
                      task:{noi_dung:'Việc X'}}]
  });
  const ds = await c.gnGom();
  const het = ds.flatMap(x => x.mau).map(m => m.chu);
  la('mẩu gõ trong phiên đang chạy KHÔNG bày', !het.includes('đang viết dở'), het.join(' · '));
  la('ô cuối phiên của phiên đang chạy KHÔNG bày', !het.includes('chưa xong đâu'));
}

/* ── ⑦ CHỮ SINH ĐÔI — giấu một bản, nhưng SỬA thì ghi cả hai ─────────── */
console.log('\n⑦ Chữ sinh đôi giữa cuối phiên và ghi chú chốt của việc');
{
  const KHO_DOI = {...RONG,
    task: [{id:20, nguoi_id:'toi', tieu_diem_ma:'O1', noi_dung:'Việc X',
            ghi_chu_chot:'chốt xong', xong_luc:'2026-09-01T08:00:00Z'}],
    phien_deepwork: [{id:10, nguoi_id:'toi', task_id:20, ghi_chu:'chốt xong',
                      ket_qua:'song', ket_thuc:'2026-09-01T08:00:00Z',
                      task:{noi_dung:'Việc X', tieu_diem_ma:'O1'}}]};
  const c = dungChay(KHO_DOI, {TIEU_DIEM:[{ma:'O1', ten:'Cam kết A', xong:false}]});
  const ds = await c.gnGom();
  const mau = timCT(ds,'ck:O1').mau;

  la('trùng nguyên văn → chỉ MỘT gạch', mau.length === 1, mau.map(m=>m.chu).join(' · '));
  la('gạch giữ lại là bản CUỐI PHIÊN (nó có giờ)', mau[0].loai === 'cua');
  la('gạch ấy mang cờ sinhDoi trỏ về việc', mau[0].sinhDoi === 20);

  c.dat({DS: ds, CHON: 'ck:O1', SUA: mau[0].k,
         DOM: {...oDOM(), 'gn-o': {value:'chữ đã sửa', focus(){}, select(){}}}});
  await c.gnLuuMau();
  const ghi = c.doc().SO_GHI;
  la('lưu → ghi phien_deepwork.ghi_chu',
     ghi.some(g => g.bang === 'phien_deepwork' && g.o.ghi_chu === 'chữ đã sửa'));
  la('VÀ ghi luôn task.ghi_chu_chot — không thì câu cũ mọc lại',
     ghi.some(g => g.bang === 'task' && g.o.ghi_chu_chot === 'chữ đã sửa'),
     JSON.stringify(ghi.map(g => g.bang)));
  la('bản của việc ghi đúng id của nó',
     ghi.some(g => g.bang === 'task' && g.loc && g.loc.id === 20));
}
{
  const c = dungChay({...RONG,
    task: [{id:20, nguoi_id:'toi', tieu_diem_ma:'O1', noi_dung:'Việc X',
            ghi_chu_chot:'câu của việc', xong_luc:'2026-09-01T08:00:00Z'}],
    phien_deepwork: [{id:10, nguoi_id:'toi', task_id:20, ghi_chu:'câu của phiên',
                      ket_qua:'song', ket_thuc:'2026-09-01T08:00:00Z',
                      task:{noi_dung:'Việc X', tieu_diem_ma:'O1'}}]
  }, {TIEU_DIEM:[{ma:'O1', ten:'Cam kết A', xong:false}]});
  const mau = timCT(await c.gnGom(),'ck:O1').mau;
  la('chữ KHÁC nhau thì giữ đủ hai gạch, không gộp nhầm', mau.length === 2);
  la('và không gạch nào bị gắn cờ sinh đôi oan', mau.every(m => !m.sinhDoi));
}

/* ── ⑧ MỖI GẠCH GHI VỀ ĐÚNG BẢNG ĐẺ RA NÓ ────────────────────────────── */
console.log('\n⑧ Sáu loại mẩu, sáu bảng — ghi nhầm là chữ biến mất khỏi cửa gốc');
async function ghiThu(KHO, opt, khoaCT, chonLoai, chu){
  const c = dungChay(KHO, opt);
  const ds = await c.gnGom();
  const m = timCT(ds, khoaCT).mau.find(x => x.loai === chonLoai);
  if (!m) return {thieu: true};
  c.dat({DS: ds, CHON: khoaCT, SUA: m.k,
         DOM: {...oDOM(), 'gn-o': {value: chu, focus(){}, select(){}}}});
  await c.gnLuuMau();
  return {ghi: c.doc().SO_GHI, toast: c.doc().TOAST, m};
}
{
  const r = await ghiThu({...RONG,
    ghi_chu:[{id:1, noi_dung:'ý rời', tao_luc:'2026-09-01T09:00:00Z'}]},
    {}, 'td:0', 'y', 'sửa ý rời');
  la('mẩu tự do → ghi_chu.noi_dung',
     r.ghi.some(g => g.bang === 'ghi_chu' && g.phep === 'update'
                  && g.o.noi_dung === 'sửa ý rời' && g.loc.id === 1));
}
{
  const r = await ghiThu({...RONG,
    ghi_chu_buoi:[{lich_id:5, ngay_goc:'2026-08-14', noi_dung:'buổi 14',
                   sua_luc:'2026-08-14T09:00:00Z'}],
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]},
    {}, 'lc:5', 'buoi', 'sửa buổi 14');
  const g = r.ghi.find(x => x.bang === 'ghi_chu_buoi');
  la('mẩu của buổi → ghi_chu_buoi.noi_dung', !!g && g.o.noi_dung === 'sửa buổi 14');
  la('và mang ĐỦ BA khoá (lich_id · ngay_goc · nguoi_id)',
     !!g && g.loc.lich_id === 5 && g.loc.ngay_goc === '2026-08-14' && g.loc.nguoi_id === 'toi',
     g && JSON.stringify(g.loc));
}
{
  const r = await ghiThu({...RONG,
    doc_su_kien:[{lich_id:5, noi_dung:'tổng cũ', sua_luc:'2026-09-01T09:00:00Z'}],
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]},
    {}, 'lc:5', 'tong', 'tổng mới');
  const g = r.ghi.find(x => x.bang === 'doc_su_kien');
  la('ô tổng của chuỗi → doc_su_kien, bằng UPSERT không UPDATE',
     !!g && g.phep === 'upsert' && g.o.noi_dung === 'tổng mới');
  la('khai onConflict đúng bộ khoá', !!g && g.onConflict === 'lich_id,nguoi_id');
  la('mang đúng nguoi_id của mình', !!g && g.o.nguoi_id === 'toi');
}
{
  /* ⚠️ ĐẢO CHIỀU 01/09 cùng lẽ với mục ⑤: sổ từng là chỗ CUỐI CÙNG còn sửa được
     `lich_chung.ghi_chu` sau khi ô ấy rời cửa sự kiện — một lối đi mồ côi. Nay
     canh rằng lối ấy đã đóng: gõ vào một gạch loại `chung` thì KHÔNG được đẻ ra
     câu ghi nào chạm `lich_chung`. */
  const r = await ghiThu({...RONG,
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true, tao_boi:'toi',
                 ghi_chu:'ô chung cũ', sua_luc:'2026-09-01T09:00:00Z'}]},
    {}, 'lc:5', 'chung', 'ô chung mới');
  /* `ghiThu` trả `{thieu:true}` khi sổ không đẻ ra gạch loại ấy nữa. Đó là câu
     trả lời MẠNH HƠN cái tôi định đo: không phải "gõ vào thì không ghi đi đâu"
     mà là "không còn chỗ nào để gõ vào". */
  la('sổ không còn đẻ ra gạch loại `chung` để mà sửa', r.thieu === true,
     JSON.stringify(r.ghi ? r.ghi.map(g => g.bang) : r));
  la('…nên cũng không có câu ghi nào chạm `lich_chung`',
     !(r.ghi || []).some(g => g.bang === 'lich_chung'),
     'sổ là chỗ cuối cùng còn sửa được trường đã rút khỏi app');
}
{
  const r = await ghiThu({...RONG,
    task:[{id:20, nguoi_id:'toi', noi_dung:'Việc X', ghi_chu_chot:'chốt cũ',
           xong_luc:'2026-09-01T09:00:00Z'}]},
    {}, 'td:0', 'viec', 'chốt mới');
  la('ghi chú chốt của việc → task.ghi_chu_chot',
     r.ghi.some(g => g.bang === 'task' && g.o.ghi_chu_chot === 'chốt mới' && g.loc.id === 20));
}
{
  const r = await ghiThu({...RONG,
    ghi_chu:[{id:1, noi_dung:'ý rời', tao_luc:'2026-09-01T09:00:00Z'}]},
    {}, 'td:0', 'y', '   ');
  la('mẩu tự do XOÁ SẠCH chữ thì CHẶN, không gửi lên máy chủ',
     !r.ghi.some(g => g.bang === 'ghi_chu' && g.phep === 'update'));
  la('và nói ra phải làm gì', r.toast.some(t => /xoá/i.test(t)), r.toast.join(' | '));
}
{
  const r = await ghiThu({...RONG,
    doc_su_kien:[{lich_id:5, noi_dung:'tổng cũ', sua_luc:'2026-09-01T09:00:00Z'}],
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]},
    {}, 'lc:5', 'tong', '');
  la('nhưng ô TỔNG xoá sạch chữ vẫn lưu được — cột ấy cho phép rỗng',
     r.ghi.some(g => g.bang === 'doc_su_kien' && g.o.noi_dung === ''));
}

/* ── ⑨ XOÁ: chỉ mẩu tự do ────────────────────────────────────────────── */
console.log('\n⑨ Xoá — chỉ mẩu mình tự gõ, bốn loại kia là chữ của thứ khác');
{
  const c = dungChay({...RONG,
    ghi_chu:[{id:1, noi_dung:'ý rời', tao_luc:'2026-09-01T09:00:00Z'}],
    task:[{id:20, nguoi_id:'toi', noi_dung:'Việc X', ghi_chu_chot:'chốt',
           xong_luc:'2026-09-01T08:00:00Z'}]});
  const ds = await c.gnGom();
  const td = timCT(ds,'td:0');
  const mY = td.mau.find(m => m.loai === 'y');
  const mV = td.mau.find(m => m.loai === 'viec');

  la('mẩu tự do mang cờ xoá được', mY.xoa === true);
  la('mẩu của việc thì KHÔNG', mV.xoa === false);
  c.dat({DS: ds, CHON: 'td:0', DOM: oDOM()});
  await c.gnXoaMau(mV.k);
  la('gọi xoá lên mẩu của việc thì không có lượt xoá nào gửi đi',
     !c.doc().SO_GHI.some(g => g.phep === 'delete'));
  await c.gnXoaMau(mY.k);
  const g = c.doc().SO_GHI.find(x => x.phep === 'delete');
  la('xoá mẩu tự do thì đi đúng bảng ghi_chu, đúng id',
     !!g && g.bang === 'ghi_chu' && g.loc.id === 1);
}

/* ── ⑩ THÊM Ý — chỉ ở nơi có chỗ đậu thật ────────────────────────────── */
console.log('\n⑩ Thêm ý — chỉ hiện ở nơi lược đồ có chỗ đậu');
{
  const c = dungChay({...RONG,
    nhip:[{id:100, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:TUAN_NAY}],
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]},
    {TIEU_DIEM:[{ma:'O1', ten:'Cam kết A', xong:false}]});
  const ds = await c.gnGom();
  c.dat({DS: ds, DOM: oDOM()});

  la('cam kết thêm ý được', c.gnThemDuoc(timCT(ds,'ck:O1')) === true);
  la('tự do thêm ý được', c.gnThemDuoc(timCT(ds,'td:0')) === true);
  la('sự kiện chưa có ô tổng thì thêm được', c.gnThemDuoc(timCT(ds,'lc:5')) === true);
  /* Trước 01/09 ca này khẳng định việc cố định KHÔNG BAO GIỜ thêm ý được —
     `ghi_chu` không có cột nối về nhịp. `nang-cap-gio-chu-doi-va-neo-nhip.sql`
     dọn đúng món ấy, nên câu khẳng định phải đổi theo, không phải giữ lại rồi
     nới cho nó xanh. Hai mặt còn lại (máy chủ chưa chạy tệp · việc chưa có nhịp
     nào để neo) nằm ở mục ⑩b. */
  la('việc cố định nay THÊM ĐƯỢC — có cột nhip_id và có nhịp để neo',
     c.gnThemDuoc(timCT(ds,'vc:7')) === true);

  c.dat({CHON: 'ck:O1'});
  await c.gnThemY();
  const g1 = c.doc().SO_GHI.find(x => x.phep === 'insert');
  la('thêm ý cho cam kết → insert ghi_chu CÓ tieu_diem_ma',
     !!g1 && g1.bang === 'ghi_chu' && g1.o.tieu_diem_ma === 'O1');

  const c2 = dungChay({...RONG}, {});
  const ds2 = await c2.gnGom();
  c2.dat({DS: ds2, CHON: 'td:0', DOM: oDOM()});
  await c2.gnThemY();
  const g2 = c2.doc().SO_GHI.find(x => x.phep === 'insert');
  la('thêm ý ở Tự do → insert ghi_chu KHÔNG neo gì',
     !!g2 && !g2.o.tieu_diem_ma && !g2.o.task_id && !g2.o.phien_id);

  const c3 = dungChay({...RONG,
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]}, {});
  const ds3 = await c3.gnGom();
  c3.dat({DS: ds3, CHON: 'lc:5', DOM: oDOM()});
  await c3.gnThemY();
  const g3 = c3.doc().SO_GHI.find(x => x.phep === 'upsert');
  la('thêm ý ở sự kiện → upsert doc_su_kien', !!g3 && g3.bang === 'doc_su_kien');
}

/* ── ⑩b DÂY NEO THỨ TƯ VÀ GIỜ CHỮ ĐỔI (nang-cap-gio-chu-doi-va-neo-nhip) ── */
console.log('\n⑩b Dây neo nhip_id và cột ghi_chu_luc — hai món SQL vừa dọn');
{
  const c = dungChay({...RONG,
    ghi_chu:[{id:1, noi_dung:'ý cho việc cố định', nhip_id:100,
              tao_luc:'2026-09-01T09:00:00Z'}],
    nhip:[{id:100, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:TUAN_NAY}]});
  const ds = await c.gnGom();
  la('ý neo THẲNG vào nhịp → việc cố định, không cần đi vòng qua một phiên',
     timCT(ds,'vc:7').mau.some(m => m.chu === 'ý cho việc cố định'));
}
{
  const c = dungChay({...RONG,
    task:[{id:20, nguoi_id:'toi', noi_dung:'Việc X', ghi_chu_chot:'chốt',
           xong_luc:'2026-08-01T08:00:00Z', ghi_chu_luc:'2026-08-30T08:00:00Z'}],
    phien_deepwork:[{id:10, nguoi_id:'toi', task_id:21, ghi_chu:'cuối phiên',
                     ket_qua:'song', ket_thuc:'2026-08-02T08:00:00Z',
                     ghi_chu_luc:'2026-08-29T08:00:00Z', task:{noi_dung:'Việc Y'}}]});
  const mau = timCT(await c.gnGom(),'td:0').mau;
  const mV = mau.find(m => m.loai === 'viec'), mC = mau.find(m => m.loai === 'cua');
  la('ghi chú chốt của việc lấy ghi_chu_luc, KHÔNG lấy xong_luc',
     mV.luc === '2026-08-30T08:00:00Z', mV.luc);
  la('mẩu cuối phiên lấy ghi_chu_luc, KHÔNG lấy ket_thuc',
     mC.luc === '2026-08-29T08:00:00Z', mC.luc);
  la('và giờ mới đẩy hai mẩu ấy lên trên theo đúng lúc CHỮ đổi',
     mau[0].loai === 'viec');
}
{
  const c = dungChay({...RONG,
    task:[{id:20, nguoi_id:'toi', noi_dung:'Việc X', ghi_chu_chot:'chốt',
           xong_luc:'2026-08-01T08:00:00Z'}]});
  const mV = timCT(await c.gnGom(),'td:0').mau[0];
  la('máy chủ CHƯA chạy tệp SQL → rơi về giờ mượn, không vỡ',
     mV.luc === '2026-08-01T08:00:00Z', mV.luc);
}
{
  const KHO_NHIP = {...RONG,
    nhip:[{id:100, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:'2026-08-10'},
          {id:101, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:TUAN_NAY},
          {id:102, nguoi_id:'toi', ten:'Gọi khách', viec_id:7, tuan_bat_dau:'2026-08-17'}]};
  const c = dungChay(KHO_NHIP);
  const ds = await c.gnGom();
  const vc = timCT(ds,'vc:7');
  la('chỗ đậu cho ý mới là nhịp TUẦN GẦN NHẤT, không phải nhịp gặp đầu tiên',
     vc.nhipMoi === 101, String(vc.nhipMoi));
  la('có cột nhip_id thì việc cố định thêm ý được', c.gnThemDuoc(vc) === true);

  c.dat({DS: ds, CHON: 'vc:7', DOM: oDOM()});
  await c.gnThemY();
  const g = c.doc().SO_GHI.find(x => x.phep === 'insert');
  la('thêm ý ở việc cố định → insert ghi_chu mang đúng nhip_id',
     !!g && g.bang === 'ghi_chu' && g.o.nhip_id === 101);

  const c2 = dungChay(KHO_NHIP, {CO_GC_NHIP: false});
  la('máy chủ CHƯA có cột thì KHÔNG hiện nút — ghi cột chưa tồn tại là lỗi 204',
     c2.gnThemDuoc(timCT(await c2.gnGom(),'vc:7')) === false);
}
{
  const c = dungChay({...RONG,
    phien_deepwork:[{id:10, nguoi_id:'toi', nhip_id:100, ghi_chu:'phiên nhịp',
                     ket_qua:'song', ket_thuc:'2026-09-01T07:00:00Z'}],
    nhip:[]});
  const ds = await c.gnGom();
  la('việc cố định KHÔNG có dòng nhịp nào thì không có chỗ neo → không hiện nút',
     ds.filter(x => x.nhom === 'codinh').every(x => c.gnThemDuoc(x) === false));
}

/* ── ⑪ HÀNG META HAI MẢNH — Tracy bỏ nhãn chỗ ghi ────────────────────── */
console.log('\n⑪ Hàng meta hai mảnh — ngày · việc hoặc buổi nào');
{
  const c = dungChay({...RONG,
    task:[{id:20, nguoi_id:'toi', tieu_diem_ma:'O1', noi_dung:'Dựng bảng khách',
           ghi_chu_chot:'chốt xong', xong_luc:'2026-08-19T08:00:00Z'}],
    ghi_chu_buoi:[{lich_id:5, ngay_goc:'2026-08-14', noi_dung:'buổi 14',
                   sua_luc:'2026-08-16T09:00:00Z'}],
    lich_chung:[{id:5, ten:'Họp tuần', lap:'tuan', dang_dung:true}]},
    {TIEU_DIEM:[{ma:'O1', ten:'Cam kết A', xong:false}]});
  const ds = await c.gnGom();
  c.dat({DS: ds, CHON: 'ck:O1', DOM: oDOM()});
  c.gnVeDoc();
  const html = c.doc().GN_DS && oDOM() && (() => {
    const d = {...oDOM()}; c.dat({DOM: d}); c.gnVeDoc(); return d['gn-doc'].innerHTML; })();

  la('hàng meta có NGÀY', /19\/8/.test(html), html.slice(0, 200));
  la('hàng meta có TÊN VIỆC', /Dựng bảng khách/.test(html));
  la('KHÔNG còn nhãn chỗ ghi (Trong phiên · Cuối phiên · Ghi chú của việc)',
     !/Trong phiên|Cuối phiên|Ghi chú của việc/.test(html));

  const mb = timCT(ds,'lc:5').mau.find(m => m.loai === 'buoi');
  la('mẩu của buổi mang NGÀY BUỔI, không mang giờ gõ', mb.ngay === '2026-08-14');
  la('và không kèm thêm tên để khỏi nói ngày hai lần', !mb.ten);
}

/* ── ⑫ MỘT NGUỒN HỎNG KHÔNG KÉO CẢ SỔ THEO ──────────────────────────── */
console.log('\n⑫ Một nguồn hỏng — nói ra, và phần còn lại vẫn bày');
{
  const c = dungChay({...RONG,
    ghi_chu:[{id:1, noi_dung:'ý rời', tao_luc:'2026-09-01T09:00:00Z'}]},
    {LOI: {task: 'relation "task" does not exist'}});
  const ds = await c.gnGom();
  la('nguồn hỏng được kêu tên', c.doc().GN_HONG.some(x => /việc/i.test(x)),
     JSON.stringify(c.doc().GN_HONG));
  la('phần còn lại vẫn ra', timCT(ds,'td:0').mau.length === 1);
}
{
  const c = dungChay({...RONG}, {CO_DOC_SK: false, CO_GC_BUOI: false, CO_LICH: false});
  await c.gnGom();
  const hoi = c.doc().SO_HOI.map(h => h.bang);
  la('máy chủ chưa có bảng thì KHÔNG hỏi nó',
     !hoi.includes('doc_su_kien') && !hoi.includes('ghi_chu_buoi') && !hoi.includes('lich_chung'),
     hoi.join(' · '));
}

/* ── ⑬ HAI LUẬT SOI THẲNG VÀO MÃ ─────────────────────────────────────── */
console.log('\n⑬ Luật soi thẳng vào mã');
{
  la('⛔ KHÔNG bày doc_cam_ket trong sổ — nó là bình chứa đã gom sẵn mọi mẩu',
     !/from\(['"]doc_cam_ket['"]\)/.test(NGUON_SACH));
  la('⛔ KHÔNG dùng lại ckNoteTai làm nguồn (nó có tác dụng phụ GHI)',
     !/ckNoteTai/.test(NGUON_SACH));
  la('⛔ KHÔNG khai #man-ghichu id trơn trong CSS (màn sẽ không bao giờ ẩn)',
     !/#man-ghichu\s*\{/.test(SRC_SACH));
  la('bố cục hai cột khai trên .gn-hai, không trên id màn',
     /\.gn-hai\s*\{[^}]*grid/.test(SRC_SACH));
  la('dưới 720px thu về một cột', /\.gn-hai\s*\{\s*display:grid;grid-template-columns:1fr/.test(SRC_SACH));
  la('ô soạn khai width:100% — thiếu nó là textarea co về 20 cột',
     /\.gn-doc textarea\{[^}]*width:100%/.test(SRC_SACH));
  la('dòng cột trái KHÔNG đeo viên nhóm (tiêu đề dải đã nói rồi)',
     !/gn-c[^`]*gn-ngu/.test(NGUON_SACH));
  la('embed lich_id của task khoá sau cờ CO_VIEC_BUOI',
     /CO_VIEC_BUOI\s*\?\s*',lich_id'/.test(NGUON_SACH));
}

console.log(`\n${truot ? '❌ ' + truot + ' ca TRƯỢT · ' : '✅ '}${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
})();
