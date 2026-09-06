/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ: PHIÊN DEEPWORK ĐI THEO TRẠNG THÁI VIỆC  (TRI-126)
   Chạy:  node thu-phien-theo-viec.js   (đứng ở thư mục production/tinh-thuc-app)

   Tracy 05/09: *"xong mà tôi tick done ở bảng hôm nay hoặc các chỗ khác mà
   không tick done ở cửa sổ deep work thì deep work vẫn tiếp tục chạy"* — và
   ngay sau đó: *"các task done rồi thì phải chặn cửa deep work của task đó
   chứ nhỉ"*.

   Hai chiều, hai lỗ, bộ thử này canh cả hai:
     ① ĐÓNG VIỆC → phiên phải tự đóng sổ. Cửa suy từ nấc: Done→xong ·
        Chua_xong→chua-xong · Blocked→nghen · Da_huy/Da_chuyen→chua-xong.
     ② VIỆC ĐÃ ĐÓNG → không còn cửa vào phiên (`dwViecDaDong`).

   Luật đang canh:
     · đúng việc ấy mới dừng — việc khác tick xong thì phiên không dính
     · nấc CÒN MỞ (Chua_lam · Doing) không dừng phiên
     · dưới sàn 5 phút thì ghi `heo`, không ghi `song` (máy chủ cũng từ chối)
     · quá trần 180 phút thì kẹp đúng ở trần
     · câu ghi mang `.eq('ket_qua','dang_chay')` — chốt chặn hai máy
     · đang đứng ở màn ba cửa thì KHÔNG chen ngang `dwXacNhanCua`
     · phiên việc cố định (không `task_id`) không dính gì
     · MÃ NGUỒN: mọi cửa ghi trạng thái việc đều gọi `dwTheoTrangThai`
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');

/* Lát MÃ THẬT của cả cụm — hai hằng bảng tra, hàm khép phiên, hai hàm hàng rào. */
const iDau = s.indexOf('const DW_CUA_THEO_TT');
const iCuoi = s.indexOf('\n/* imLang = true khi đã có hộp', iDau);
if (iDau < 0 || iCuoi < 0) throw new Error('Không tìm thấy cụm dwTheoTrangThai trong mã');
const nguon = s.slice(iDau, iCuoi);

/* ── Bộ nhớ, DOM và máy chủ giả ──────────────────────────────────────────── */
const KHO = {};
global.localStorage = {
  getItem: k => (k in KHO ? KHO[k] : null),
  setItem: (k, v) => { KHO[k] = String(v) },
  removeItem: k => { delete KHO[k] }
};
const LOP = new Set(['hien', 'chay']);
global.document = {getElementById: () => ({
  classList: {add: (...c) => c.forEach(x => LOP.add(x)),
              remove: (...c) => c.forEach(x => LOP.delete(x)),
              contains: c => LOP.has(c)},
  style: {}, textContent: '', innerHTML: ''
})};

let GHI = [];
const toast = m => GHI.push({loai:'toast', m});
/* Chuỗi giả kiểu PostgREST: mọi mắt xích trả lại chính mình, await thì ra
   {data,error}. Ghi lại ĐỦ các cột `.eq` đã nối, vì chốt chặn hai máy nằm
   đúng ở cái `.eq('ket_qua','dang_chay')` thứ hai. */
let DA_DONG_O_MAY_KHAC = false;
const sb = {from: bang => ({
  update: patch => {
    const g = {loai:'update', bang, patch, eq:{}};
    GHI.push(g);
    const o = {
      eq: (c, v) => { g.eq[c] = v; return o },
      select: () => o,
      then: (t, x) => Promise.resolve(
        {data: DA_DONG_O_MAY_KHAC ? [] : [{id: 1}], error: null}).then(t, x)
    };
    return o;
  }
})};

const TT_MO = ['Chua_lam','Doing','Chua_xong','Blocked'];   // nấc còn mở, y bản thật
const DW_SAN_PHUT = 5, DW_TRAN_PHUT = 180;
const DW_KHOA_NGHI = 'dw_nghi';
const gioChu = p => p + ' phút';
let LAM_MS = 30 * 60000;                       // quãng làm giả định, đổi theo từng ca
const dwLamMs = () => LAM_MS;
let dwPhien = null, dwNhip = null, dwCuaChon = null, dwDangCua = false;
let dwHen = null, dwTamLuc = 0, dwNghiMs = 0, dwBatDauLuc = 0, DW_HAN_GO = '';
let DA_TAI = 0;
const dwVeDai = () => {}, dwQuenTTCu = () => {}, dwDongHopGhi = () => {};
const dwTaiLaiMan = async () => { DA_TAI++ };

eval(nguon);

let hong = 0;
const kiem = (ten, dat, them) => {
  console.log((dat ? '  ✅ ' : '  ❌ ') + ten + (dat || !them ? '' : '\n       → ' + them));
  if (!dat) hong++;
};
const BAT_DAU = '2026-09-05T08:00:00.000Z';
const dat = (o = {}) => {
  GHI = []; DA_TAI = 0; LOP.add('hien'); LOP.add('chay');
  DA_DONG_O_MAY_KHAC = !!o.mayKhac;
  LAM_MS = (o.phut != null ? o.phut : 30) * 60000;
  dwDangCua = !!o.dangCua; dwTamLuc = 0; dwNghiMs = 0;
  KHO[DW_KHOA_NGHI] = '{"id":1}';
  dwPhien = o.nhip ? {id:1, nhip_id:3, bat_dau:BAT_DAU}
                   : {id:1, task_id:7, bat_dau:BAT_DAU};
};
const cauGhi = () => GHI.find(g => g.loai === 'update' && g.bang === 'phien_deepwork');
const loiBao = () => GHI.filter(g => g.loai === 'toast').map(g => g.m).join(' | ');

(async () => {
  console.log('\n── ĐÓNG VIỆC THÌ PHIÊN ĐÓNG SỔ THEO ──');
  for (const [tt, cua] of [['Done','xong'], ['Chua_xong','chua-xong'],
                           ['Blocked','nghen'], ['Da_huy','chua-xong'],
                           ['Da_chuyen','chua-xong']]){
    dat();
    await dwTheoTrangThai(7, tt);
    const g = cauGhi();
    kiem(`${tt} → phiên ghi 'song', cửa '${cua}'`,
         !!g && g.patch.ket_qua === 'song' && g.patch.cua === cua, JSON.stringify(g));
    kiem(`${tt} → phiên rời tay, lớp phủ 💧 đóng lại`,
         dwPhien === null && !LOP.has('hien') && !LOP.has('chay'));
  }

  console.log('\n── ĐÚNG VIỆC ẤY MỚI DỪNG ──');
  dat();
  await dwTheoTrangThai(8, 'Done');
  kiem('Tick xong một việc KHÁC → phiên chạy tiếp, không ghi gì',
       !!dwPhien && !cauGhi(), JSON.stringify(GHI));
  dat();
  await dwTheoTrangThai([5, 7, 9], 'Da_huy');
  kiem('Xoá sự kiện đóng một MẢNG việc, phiên nằm trong đó → vẫn dừng',
       dwPhien === null && !!cauGhi());
  dat();
  await dwTheoTrangThai([5, 9], 'Da_huy');
  kiem('Mảng không chứa việc của phiên → không đụng', !!dwPhien && !cauGhi());

  console.log('\n── NẤC CÒN MỞ THÌ KHÔNG ĐỤNG PHIÊN ──');
  for (const tt of ['Chua_lam', 'Doing']){
    dat();
    await dwTheoTrangThai(7, tt);
    kiem(`${tt} là nấc mở → đồng hồ chạy tiếp`, !!dwPhien && !cauGhi());
  }

  console.log('\n── SÀN 5 PHÚT VÀ TRẦN 180 PHÚT ──');
  dat({phut: 3});
  await dwTheoTrangThai(7, 'Done');
  const gSan = cauGhi();
  kiem('Dưới sàn → ghi `heo`, không ghi `song`',
       !!gSan && gSan.patch.ket_qua === 'heo' && !gSan.patch.cua, JSON.stringify(gSan));
  kiem('Dưới sàn → nói thẳng là không vào vườn', /không vào vườn/.test(loiBao()), loiBao());
  dat({phut: 300});
  await dwTheoTrangThai(7, 'Done');
  const phutGhi = (new Date(cauGhi().patch.ket_thuc) - new Date(BAT_DAU)) / 60000;
  kiem('Trên trần → kẹp đúng ở 180 phút, không ghi cả quãng treo',
       phutGhi === DW_TRAN_PHUT, phutGhi + ' phút');
  dat({phut: 45});
  await dwTheoTrangThai(7, 'Done');
  kiem('Bình thường → giờ kết thúc = giờ bắt đầu + phút làm thật',
       (new Date(cauGhi().patch.ket_thuc) - new Date(BAT_DAU)) / 60000 === 45);

  console.log('\n── CHỐT CHẶN HAI MÁY ──');
  dat();
  await dwTheoTrangThai(7, 'Done');
  kiem("Câu ghi mang .eq('ket_qua','dang_chay')", cauGhi().eq.ket_qua === 'dang_chay',
       JSON.stringify(cauGhi().eq));
  dat({mayKhac: true});
  await dwTheoTrangThai(7, 'Done');
  kiem('Máy khác đóng trước → nói ra, không nhận vơ số phút',
       /nơi khác/.test(loiBao()) && !/vào vườn/.test(loiBao()), loiBao());

  console.log('\n── KHÔNG CHEN NGANG BA CỬA RA ──');
  dat({dangCua: true});
  await dwTheoTrangThai(7, 'Done');
  kiem('Đang đứng ở màn ba cửa → để `dwXacNhanCua` tự lo, không ghi chồng',
       !!dwPhien && !cauGhi(), JSON.stringify(GHI));

  console.log('\n── PHIÊN VIỆC CỐ ĐỊNH KHÔNG DÍNH GÌ ──');
  dat({nhip: true});
  await dwTheoTrangThai(7, 'Done');
  kiem('Phiên nhịp không có `task_id` → không có gì để theo', !!dwPhien && !cauGhi());

  console.log('\n── HÀNG RÀO CHIỀU NGƯỢC: VIỆC ĐÃ ĐÓNG ──');
  for (const tt of ['Done', 'Da_huy', 'Da_chuyen'])
    kiem(`${tt} → cửa vào phiên đóng lại`, dwViecDaDong({trang_thai: tt}));
  for (const tt of ['Chua_lam', 'Doing', 'Chua_xong', 'Blocked'])
    kiem(`${tt} → vẫn vào phiên được`, !dwViecDaDong({trang_thai: tt}));
  kiem('Không tìm thấy việc thì không chặn oan', !dwViecDaDong(null) && !dwViecDaDong(undefined));
  GHI = [];
  kiem('Chặn thì nói ra một câu, và trả về true',
       dwChanViecDong({trang_thai:'Done'}) === true && loiBao().includes('đã đóng'), loiBao());

  /* ── LUẬT MÃ NGUỒN: chống sót một cửa ─────────────────────────────────────
     Đây là luật đáng giá nhất của bộ này. Mã có tám chỗ đóng một việc; thêm
     cửa thứ chín mà quên gọi `dwTheoTrangThai` thì lỗi cũ mở lại y nguyên, và
     không ca chạy nào ở trên bắt được — vì cửa mới có ai thử đâu. */
  console.log('\n── MỌI CỬA GHI TRẠNG THÁI ĐỀU PHẢI GỌI ──');
  const than = ten => {
    const i = s.indexOf(ten);
    if (i < 0) return null;
    const j = s.indexOf('\n}\n', i);
    return j < 0 ? null : s.slice(i, j);
  };
  for (const ten of ['async function doiTrangThai(id, tt){',
                     'async function duTickViec(id, xong){',
                     'async function tvLuu(',
                     'async function luuSuaTaskCK(id){',
                     'async function donLuu(id, patch, conMoi, ngayCon){',
                     'async function datNghen(',
                     'async function duLuuDong(',
                     'async function lcDonViec(lichId, tu, den){']){
    const t = than(ten);
    kiem(`${ten.replace(/^async function /, '').replace(/\(.*/, '')} gọi dwTheoTrangThai`,
         !!t && t.includes('dwTheoTrangThai('), t ? 'thân hàm không có lời gọi' : 'không tìm thấy hàm');
  }

  console.log(hong ? `\n❌ ${hong} mục chưa đạt\n` : '\n✅ Tất cả đều đạt\n');
  process.exit(hong ? 1 : 0);
})();
