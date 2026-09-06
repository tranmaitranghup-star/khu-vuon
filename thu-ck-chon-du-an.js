/* THỬ: cửa NGƯỢC — xếp một cam kết có sẵn vào dự án, từ menu ⋯ của thẻ
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 29/08: *"ở các cam kết có nút chọn trỏ về dự án nhưng hãy chỉ hiện những
   dự án đang chạy"* · *"cam kết đó để giải nghẽn cũng được mà"* · *"để trong
   menu đi"*.

   Bài thử CẮT BỐN KHỐI GỐC ra khỏi `public/index.html` (bảng trạng thái nhận
   cam kết · oChonDuAn · veBangCamKet · cụm ckDuAn*) rồi chạy chúng trên dữ liệu
   giả — không chép tay một dòng logic nào sang đây. Chép tay thì bài thử sẽ xanh
   cả khi file gốc đã hỏng, và đó là loại bài thử tệ hơn không có.

   Ba chỗ nó gác, đều là lỗi IM LẶNG nếu vỡ:
     ① dự án còn trong kho lọt vào ô chọn — xếp lời hứa vào một cuộc chưa mở;
     ② cam kết đang thuộc dự án đã đóng bị ô chọn âm thầm gỡ ra khi bấm Lưu;
     ③ đổi dự án mà `moc_id` ở lại — con trỏ chỉ sang milestone của nhà hàng xóm.

   Chạy:  node production/tinh-thuc-app/thu-ck-chon-du-an.js

   Soi một bản KHÁC (để chắc bài thử thật sự bắt được lỗi):
     git show HEAD:public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-ck-chon-du-an.js
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
  catKhoi('const DUAN_TT_NHAN = [', 'async function napDuAnChoGieo(){'),
  catKhoi('function oChonDuAn(id, chon, themDs){', 'function moTab(ten, vuaNap){'),
  catKhoi('function veBangCamKet(o, hopKho){', 'function ckThaoTac(ma, viec){'),
  catKhoi('let CK_DUAN_MO = null;', '/* ══════ 📓 DÒNG GHI CHÚ'),
].join('\n');

/* ── Cọc: đủ để bốn khối trên chạy, không hơn ────────────────────────────────
   (Cọc nằm trong một chuỗi mẫu — TUYỆT ĐỐI không dùng dấu huyền trong khối chú
   thích này, một dấu là cả tệp gãy cú pháp.) */
const CỌC = `
let DUAN_CHON = MOI.DUAN_CHON || [];
let TIEU_DIEM = MOI.TIEU_DIEM || [];
let vuonCaDoi = !!MOI.vuonCaDoi;
const ME = {id: 'toi'};
const sb = MOI.sb;
const document = MOI.document;
const toast = m => { MOI.log.push(['toast', m]); };
const hopHoiMo = h => { MOI.hop = h; };
const hopHoiDong = () => { MOI.hop = null; MOI.soLanDong = (MOI.soLanDong || 0) + 1; };
const baoLoiLuong = e => (e && e.message) || 'loi';
const taiHomNay = async () => { MOI.log.push(['taiHomNay']); };
const taiVuon = async () => { MOI.log.push(['taiVuon']); };
const canVeLaiVuon = () => true;
const nutCho = async (n, chu, viec) => viec();
const chuSach = s => String(s == null ? '' : s);

/* Cọc riêng cho veBangCamKet — cùng bộ với thu-kho-cam-ket.js */
const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];
const MO_CHUA_NGHEN = t => TT_MO.includes(t.trang_thai) && t.trang_thai !== 'Blocked';
const homNay = () => '2026-08-29';
const coLamDo = v => v.some(t => t.trang_thai === 'Chua_xong');
const IC = {sua: 'x'};
let CK_THU = {}, THEM_MO = null, TASK_CK = {};
const soCamKet = ma => ma;
const veTieuChi = () => '';
const veHanHat = () => ' hạn';
const veCoDoiHan = () => '';
const oNgay = () => '<o-ngay>';
const gioChu = p => (p/60).toFixed(1)+'h';
const veDongTaskCK = t => '<dong>'+t.noi_dung+'</dong>';
const tranCamKet = () => 3;
const luongDangGieo = () => [];
`;

function dungApp(MOI){
  MOI.log = MOI.log || [];
  const boc = new Function('MOI', CỌC + '\n' + NGUON + '\n'
    + 'return {oChonDuAn, veBangCamKet, ckDuAnMo, ckDuAnGhi, DUAN_TT_NHAN, DUAN_TT_CHU};');
  return boc(MOI);
}

/* Máy chủ giả: một chuỗi gọi kiểu PostgREST, ghi lại đã gửi gì. */
function sbGia(ketQua, log){
  return {
    from(bang){
      const g = {bang, ban: null, cot: null, eq: {}};
      log.push(['from', bang, g]);
      const b = {
        update(v){ g.ban = v; return b; },
        select(c){ g.cot = c; return b; },
        eq(k, v){ g.eq[k] = v; return b; },
        maybeSingle(){ return Promise.resolve({data: ketQua.mucTieu ?? null}); },
        then(ok){ return Promise.resolve(ketQua.update).then(ok); }
      };
      return b;
    },
    rpc(){ throw new Error('cửa ngược KHÔNG được gọi RPC'); }
  };
}

const docGia = giaTri => ({
  getElementById: id => (id === 'ck-duan-o' ? {value: giaTri} : null)
});

const DA = [], HONG = [];
function kt(ten, dieu, chiTiet){
  (dieu ? DA : HONG).push(ten + (chiTiet ? ' — ' + chiTiet : ''));
  console.log((dieu ? '✅ ' : '❌ ') + ten + (chiTiet ? '\n   ' + chiTiet : ''));
}

/* Bốn dự án phủ đủ bốn nấc, để soi cả cái được bày lẫn cái bị loại. */
const DUAN4 = [
  {id: 7, ten: 'ROVA vận hành', trang_thai: 'dang-chay'},
  {id: 8, ten: 'CRM khách hàng', trang_thai: 'nghen'},
];
const DA_DONG = {id: 21, ten: 'Ra mắt app', trang_thai: 'hoan-thanh'};

/* ══ NHÓM A — bảng trạng thái nhận cam kết ══════════════════════════════════ */
{
  const a = dungApp({});
  kt('Chỉ dự án ĐANG CHẠY và ĐANG NGHẼN được nhận cam kết',
     a.DUAN_TT_NHAN.includes('dang-chay') && a.DUAN_TT_NHAN.includes('nghen')
       && !a.DUAN_TT_NHAN.includes('kho'),
     'DUAN_TT_NHAN = ' + JSON.stringify(a.DUAN_TT_NHAN));
}

/* ══ NHÓM B — ô chọn ═══════════════════════════════════════════════════════ */
{
  const a = dungApp({DUAN_CHON: []});
  kt('Chưa được mời dự án nào → ô chọn KHÔNG bày ra (để hộp nói lý do thay)',
     a.oChonDuAn('ck-duan-o', null, []) === '');
}
{
  const a = dungApp({DUAN_CHON: DUAN4});
  const h = a.oChonDuAn('ck-duan-o', null, []);
  kt('Cam kết lẻ → mục "Không thuộc dự án nào" đứng sẵn',
     /<option value=""\s+selected>/.test(h));
  kt('Dự án đang nghẽn có chú "(đang nghẽn)", dự án đang chạy thì không chú gì',
     h.includes('CRM khách hàng (đang nghẽn)') && h.includes('>ROVA vận hành</option>'));
}
{
  const a = dungApp({DUAN_CHON: DUAN4});
  const h = a.oChonDuAn('ck-duan-o', 8, []);
  kt('Truyền dự án đang thuộc → đúng option ấy đứng sẵn',
     /<option value="8" selected>/.test(h) && !/<option value="7" selected>/.test(h));
}
{
  const a = dungApp({DUAN_CHON: DUAN4});
  const h = a.oChonDuAn('ck-duan-o', 21, [DA_DONG]);
  kt('Dự án ĐÃ ĐÓNG vẫn được bày và đứng sẵn — không âm thầm gỡ cam kết ra',
     /<option value="21" selected>/.test(h) && h.includes('Ra mắt app (đã hoàn thành)'));
}

/* ══ NHÓM C — mục trong menu ⋯ của thẻ ═════════════════════════════════════ */
const CK = (them) => Object.assign({
  ma: 'CK1', ten: 'Chốt hợp đồng SFVN', luong: 1, tieu_chi_xong: 'ký xong',
  han: '2026-09-05', so_task: 0, so_xong: 0, so_kho: 0, tong_phut: 0
}, them || {});
{
  const a = dungApp({});
  const h = a.veBangCamKet(CK(), null);
  kt('Cam kết đang lẻ → menu có mục "Xếp vào dự án"',
     h.includes('<option value="duan">Xếp vào dự án</option>'));
}
{
  const a = dungApp({});
  const h = a.veBangCamKet(CK({muc_tieu_id: 7}), null);
  kt('Cam kết đã thuộc một dự án → chữ đổi thành "Đổi dự án"',
     h.includes('<option value="duan">Đổi dự án</option>'));
}
{
  const a = dungApp({});
  const h = a.veBangCamKet(CK(), {duocGiao: true, biTuChoi: false});
  kt('Cam kết người khác giao mà chưa trả lời → KHÔNG có mục dự án (máy chủ khoá đề bài)',
     !h.includes('value="duan"') && !h.includes('value="sua"'));
}
{
  const a = dungApp({vuonCaDoi: true});
  const h = a.veBangCamKet(CK(), null);
  kt('Xem vườn cả đội → KHÔNG có mục dự án (dòng của người khác, RLS chặn ghi)',
     !h.includes('value="duan"'));
}

/* ══ NHÓM D — lúc ghi ══════════════════════════════════════════════════════ */
(async () => {
  {
    const log = [];
    const MOI = {TIEU_DIEM: [CK({muc_tieu_id: 7, moc_id: 55})], log,
      sb: sbGia({update: {data: [{ma: 'CK1'}], error: null}}, log),
      document: docGia('9')};
    const a = dungApp(MOI);
    await a.ckDuAnGhi('CK1');
    const goi = log.find(x => x[0] === 'from' && x[1] === 'tieu_diem');
    const g = goi && goi[2];
    kt('Đổi dự án → gửi muc_tieu_id mới KÈM moc_id rỗng (milestone thuộc dự án cũ)',
       !!g && g.ban.muc_tieu_id === 9 && g.ban.moc_id === null,
       'gửi đi: ' + JSON.stringify(g && g.ban));
    kt('Ghi có .select("ma") — không có nó thì RLS chặn xong vẫn trả 204 không lỗi',
       !!g && g.cot === 'ma' && g.eq.ma === 'CK1' && g.eq.nguoi_id === 'toi');
    kt('Ghi xong mới đóng hộp, rồi vẽ lại cả hai màn',
       MOI.soLanDong === 1
         && log.some(x => x[0] === 'taiHomNay') && log.some(x => x[0] === 'taiVuon'));
  }
  {
    const log = [];
    const MOI = {TIEU_DIEM: [CK({muc_tieu_id: 7})], log,
      sb: sbGia({update: {data: [{ma: 'CK1'}], error: null}}, log),
      document: docGia('')};
    const a = dungApp(MOI);
    await a.ckDuAnGhi('CK1');
    const g = (log.find(x => x[0] === 'from') || [])[2];
    kt('Chọn "Không thuộc dự án nào" → gỡ khỏi dự án, báo đúng chữ',
       !!g && g.ban.muc_tieu_id === null
         && log.some(x => x[0] === 'toast' && /gỡ/.test(x[1])));
  }
  {
    const log = [];
    const MOI = {TIEU_DIEM: [CK({muc_tieu_id: 7})], log,
      sb: sbGia({update: {data: [], error: null}}, log), document: docGia('7')};
    const a = dungApp(MOI);
    await a.ckDuAnGhi('CK1');
    kt('Chọn lại đúng dự án đang thuộc → KHÔNG đi một vòng máy chủ',
       !log.some(x => x[0] === 'from') && MOI.soLanDong === 1);
  }
  {
    const log = [];
    const MOI = {TIEU_DIEM: [CK()], log,
      sb: sbGia({update: {data: [], error: null}}, log), document: docGia('9')};
    const a = dungApp(MOI);
    await a.ckDuAnGhi('CK1');
    kt('Máy chủ nhận 0 dòng (RLS chặn) → báo hỏng, KHÔNG báo thành công, hộp Ở LẠI',
       log.some(x => x[0] === 'toast' && /không nhận/.test(x[1]))
         && !log.some(x => x[0] === 'toast' && /Đã xếp/.test(x[1]))
         && !MOI.soLanDong);
  }

  /* ══ NHÓM E — lúc mở cửa ═════════════════════════════════════════════════ */
  {
    const log = [];
    const MOI = {DUAN_CHON: DUAN4, TIEU_DIEM: [CK({muc_tieu_id: 21})], log,
      sb: sbGia({mucTieu: DA_DONG}, log), document: docGia('')};
    const a = dungApp(MOI);
    await a.ckDuAnMo('CK1');
    kt('Mở cửa với cam kết thuộc dự án ĐÃ ĐÓNG → hộp hỏi riêng tên nó rồi bày ra',
       /<option value="21" selected>/.test(MOI.hop || '')
         && /Ra mắt app \(đã hoàn thành\)/.test(MOI.hop || ''));
  }
  {
    const MOI = {DUAN_CHON: [], TIEU_DIEM: [CK()], sb: sbGia({}, []), document: docGia('')};
    const a = dungApp(MOI);
    await a.ckDuAnMo('CK1');
    kt('Chưa có dự án nào đang chạy → hộp nói nhờ PIC mời, không bày nút Lưu rỗng',
       /nhờ PIC mời/.test(MOI.hop || '') && !/ck-duan-o/.test(MOI.hop || ''));
  }
  {
    const MOI = {DUAN_CHON: DUAN4, TIEU_DIEM: [CK({muc_tieu_id: 7, moc_id: 55})],
      sb: sbGia({}, []), document: docGia('')};
    const a = dungApp(MOI);
    await a.ckDuAnMo('CK1');
    kt('Cam kết đang nằm milestone → hộp báo trước rằng đổi dự án là rời milestone',
       /milestone/.test(MOI.hop || ''));
  }

  console.log('\n' + (HONG.length
    ? `❌ ${HONG.length}/${DA.length + HONG.length} ca HỎNG:\n   - ` + HONG.join('\n   - ')
    : `✅ cả ${DA.length} ca ĐẠT`));
  process.exit(HONG.length ? 1 : 0);
})();
