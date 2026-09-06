/* THỬ: NHÃN LOẠI VIỆC RỜI KHỎI `task`
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 01/09: *"vá đi"* — sau khi đo được 6 phiên đang bị xếp nhầm vào nhóm
   "phát sinh" trên dải Giờ deepwork của cả đội (John 4 · Sydney 1 · Andy 1).

   Bài thử này soi PHẦN APP. Phần máy chủ có bộ tự kiểm 11 mục nằm ngay trong
   `nang-cap-loai-phien.sql`, chạy sau khi commit.

   Ba ca đáng giá nhất:
     · Cột mới phải đi kèm lúc mở phiên, và mang đúng giá trị của việc.
     · CỬA LÙI phải bọc cả cột mới — gói lùi còn nó thì cú lùi ngã đúng lỗi vừa
       lùi khỏi, và mở phiên hỏng hẳn trên máy chủ chưa chạy tệp SQL.
     · Việc không có cam kết phải ghi `false`, KHÔNG phải bỏ trống: bỏ trống là
       một câu khác hẳn — "chưa biết" — và trigger bên máy chủ sẽ đi điền lại.

   Ba ca thêm 01/09, khi loại "việc cố định" vào ô chọn cam kết:
     · LUẬT KHÔNG GIỮ NGẦM — chọn một cam kết phải XOÁ nhãn cố định. Giữ lại là
       đẻ ra một giá trị người dùng không nhìn thấy và không sửa được.
     · Máy chủ chưa có cột `task.loai_viec` thì không gửi trường nào, y hệt lối
       `CO_MAU` và `CO_GIO_SE` đã đi — gửi một cột chưa tồn tại là hỏng CẢ câu.
     · Hai loại phải rơi vào HAI khoá gom nhóm khác nhau, không thì kho vẫn xếp
       chúng chung một đầu mục như trước.

   Chạy:  node production/tinh-thuc-app/thu-loai-phien.js
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
const NGUON = catKhoi('async function dwMoPhienMoi(goi){',
                      '/* ══════════ LÀN A · NỀN MÀN DEEPWORK');
/* Khuôn loại việc (01/09) — cùng một bài thử vì nó nuôi đúng cột mới mà
   `dwMoPhienMoi` đang mang xuống. */
const NGUON_LOAI = catKhoi("const O_CO_DINH  = '_cd';", 'function optCamKet(maChon){');

const COC = `
let GOI = [], LOI_LAN_DAU = null, DW_NHIP_LUC = 0, CO_LOAI_VIEC = true;
/* Thêm 04/09 (TRI-100): manhLoai nay đọc thêm cờ này. Cốc thiếu nó thì bài thử
   ngã ở ReferenceError chứ không ngã ở một ca sai — đọc lỗi ra sẽ tưởng hỏng ở
   đâu khác. Loại CÁ NHÂN có bài thử riêng: thu-loai-ca-nhan.js.
   KHÔNG dùng dấu huyền ngược quanh tên hàm trong khối này: cả COC là một chuỗi
   mẫu, nên một dấu ấy là đóng chuỗi ngay giữa câu chú thích. */
let CO_RIENG_TU = true;
const ME = {id: 'toi'}, DW_MAY = 'may-1';
const Date_ = Date;
const sb = { from: () => ({ insert(o){ GOI.push(o); return { select: async () => (
      GOI.length === 1 && LOI_LAN_DAU ? {error: LOI_LAN_DAU} : {error: null, data: [{id: 1}]}) }; } }) };
`;

const chay = new Function(COC + NGUON_LOAI + NGUON + `
  return { dwMoPhienMoi, manhLoai, loaiCua, khoaNhom, giaTriO, tenLoai,
           O_CO_DINH, O_CA_NHAN,
           doc: () => ({GOI}),
           dat: o => { GOI = []; LOI_LAN_DAU = o.LOI_LAN_DAU || null;
                       CO_LOAI_VIEC = o.CO_LOAI_VIEC !== false;
                       CO_RIENG_TU  = o.CO_RIENG_TU  !== false; } };
`)();

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

(async function chayThu(){

console.log('\n① Mở phiên gắn việc CÓ cam kết');
{
  chay.dat({});
  await chay.dwMoPhienMoi({task_id: 5, co_cam_ket: true, viec_co_dinh: false});
  const g = chay.doc().GOI[0];
  la('gói đầu mang co_cam_ket = true', g.co_cam_ket === true, JSON.stringify(g));
  la('gói đầu mang viec_co_dinh = false', g.viec_co_dinh === false, JSON.stringify(g));
  la('vẫn mang đủ task_id và người', g.task_id === 5 && g.nguoi_id === 'toi');
  la('vẫn mang may_ma và nhịp', !!g.may_ma && !!g.nhip_cuoi);
}

console.log('\n② Việc KHÔNG cam kết ghi false, không bỏ trống');
{
  chay.dat({});
  await chay.dwMoPhienMoi({task_id: 6, co_cam_ket: false, viec_co_dinh: false});
  const g = chay.doc().GOI[0];
  la('ghi đúng false', g.co_cam_ket === false, JSON.stringify(g));
  la('false KHÁC bỏ trống', 'co_cam_ket' in g);
  la('viec_co_dinh cũng ghi false, không bỏ trống',
     g.viec_co_dinh === false && 'viec_co_dinh' in g, JSON.stringify(g));
}

console.log('\n③ Phiên nhịp (không gắn việc) thì không dựng cột thừa');
{
  chay.dat({});
  await chay.dwMoPhienMoi({nhip_id: 3});
  const g = chay.doc().GOI[0];
  la('không có co_cam_ket trong gói', !('co_cam_ket' in g), JSON.stringify(g));
  la('không có viec_co_dinh trong gói', !('viec_co_dinh' in g), JSON.stringify(g));
  la('vẫn mang nhip_id', g.nhip_id === 3);
}

console.log('\n④ CỬA LÙI khi máy chủ chưa chạy tệp SQL');
{
  for (const ma of ['PGRST204', '42703']){
    chay.dat({LOI_LAN_DAU: {code: ma}});
    await chay.dwMoPhienMoi({task_id: 7, co_cam_ket: true, viec_co_dinh: true});
    const [g1, g2] = chay.doc().GOI;
    la(`lỗi ${ma}: có gửi lại lần hai`, !!g2, 'chỉ gửi ' + chay.doc().GOI.length + ' lần');
    la(`lỗi ${ma}: gói lùi KHÔNG còn co_cam_ket`, g2 && !('co_cam_ket' in g2),
       JSON.stringify(g2));
    la(`lỗi ${ma}: gói lùi KHÔNG còn viec_co_dinh`, g2 && !('viec_co_dinh' in g2),
       JSON.stringify(g2));
    la(`lỗi ${ma}: gói lùi cũng bỏ may_ma và nhịp`,
       g2 && !('may_ma' in g2) && !('nhip_cuoi' in g2), JSON.stringify(g2));
    la(`lỗi ${ma}: gói lùi vẫn đủ task_id`, g2 && g2.task_id === 7);
  }
}

console.log('\n⑤ Lỗi KHÁC thì không lùi — lùi là nuốt mất lỗi thật');
{
  chay.dat({LOI_LAN_DAU: {code: '23505'}});
  await chay.dwMoPhienMoi({task_id: 8, co_cam_ket: true, viec_co_dinh: false});
  la('chỉ gửi đúng một lần', chay.doc().GOI.length === 1);
}

console.log('\n⑥ LUẬT KHÔNG GIỮ NGẦM — ô chọn dịch sang hai cột');
{
  chay.dat({});
  const cd = chay.manhLoai(chay.O_CO_DINH);
  la('chọn Việc cố định: bỏ cam kết, khai loai_viec',
     cd.tieu_diem_ma === null && cd.loai_viec === 'co_dinh', JSON.stringify(cd));

  const ck = chay.manhLoai('ck-01');
  la('chọn một cam kết: XOÁ loai_viec, không giữ ngầm',
     ck.tieu_diem_ma === 'ck-01' && ck.loai_viec === null, JSON.stringify(ck));
  la('loai_viec = null KHÁC bỏ trống', 'loai_viec' in ck);

  const ps = chay.manhLoai('');
  la('chọn Việc phát sinh: cả hai cùng rỗng',
     ps.tieu_diem_ma === null && ps.loai_viec === null, JSON.stringify(ps));
}

console.log('\n⑦ Máy chủ CHƯA có cột thì không gửi trường nào');
{
  chay.dat({CO_LOAI_VIEC: false});
  const a = chay.manhLoai(chay.O_CO_DINH), b = chay.manhLoai('ck-01');
  la('không kèm loai_viec khi chưa có cột',
     !('loai_viec' in a) && !('loai_viec' in b), JSON.stringify([a, b]));
  la('vẫn ghi đúng cam kết như cũ', b.tieu_diem_ma === 'ck-01');
  chay.dat({});
}

console.log('\n⑧ Đọc ngược: nhãn, khoá gom nhóm, giá trị đang đứng của ô');
{
  const cd = {id: 1, loai_viec: 'co_dinh', tieu_diem_ma: null};
  const ps = {id: 2, loai_viec: null,      tieu_diem_ma: null};
  const ck = {id: 3, loai_viec: null,      tieu_diem_ma: 'ck-01'};

  la('việc khai cố định đọc ra loại cd', chay.loaiCua(cd) === 'cd');
  la('việc không khai gì đọc ra loại ps', chay.loaiCua(ps) === 'ps');
  la('tên hiện ra đúng chữ', chay.tenLoai('cd') === 'Việc cố định'
                          && chay.tenLoai('ps') === 'Việc phát sinh');
  la('chữ thường dùng ở dòng meta', chay.tenLoai('cd', false) === 'việc cố định');

  la('hai loại rơi vào HAI nhóm khác nhau',
     chay.khoaNhom(cd) !== chay.khoaNhom(ps),
     chay.khoaNhom(cd) + ' vs ' + chay.khoaNhom(ps));
  la('có cam kết thì gom theo cam kết', chay.khoaNhom(ck) === 'ck-01');

  la('ô chọn đứng đúng dòng Việc cố định', chay.giaTriO(cd) === chay.O_CO_DINH);
  la('ô chọn đứng đúng dòng Việc phát sinh', chay.giaTriO(ps) === '');
  la('ô chọn đứng đúng cam kết', chay.giaTriO(ck) === 'ck-01');
}

console.log('\n' + (truot ? '❌ ' + truot + ' ca trượt, ' : '✅ ') + dat + ' ca đạt.');
process.exit(truot ? 1 : 0);
})();
