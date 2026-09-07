/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ: MÃ MÁY + NHỊP TIM — chùm lỗi "phiên treo giả"
   Chạy:  node thu-phien-treo.js   (đứng ở thư mục production/tinh-thuc-app)

   John báo qua Tracy 14/08: bật phiên deep work rồi để đó, Chrome cho tab ngủ,
   quay lại phải F5 và mất màn deepwork; phiên hiện trong dải lịch thành khối
   "⏳ treo"; bấm vào khai số phút thì bị chặn bằng câu "đang bật ở thiết bị
   khác" — trên chính cái máy vừa mở phiên. F5 lần nữa thì phiên chạy tiếp ở
   38:12, tức là nó CHƯA BAO GIỜ MẤT.

   Gốc bệnh: app không lưu MÁY NÀO giữ phiên và không có dấu hiệu máy ấy còn
   sống, nên mọi câu hỏi "phiên này có ai đang dùng không?" chỉ còn cách ĐOÁN.
   Hai cột `may_ma` + `nhip_cuoi` cho nó khả năng ĐO. Bộ thử này canh phần đo.

   Bốn luật đang canh:
     · phiên mở trên CHÍNH máy này  → luôn tự đóng / khai lại được
     · phiên máy khác, nhịp còn đập → CẤM đụng vào (kể cả nút xoá)
     · phiên máy khác đã im lặng    → đoạt lại được
     · máy chủ chưa chạy SQL        → rơi về đúng nết cũ, không màn nào hỏng
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const MOC = [
  ['const DW_SAN_PHUT',                 '\n'],
  ['const DW_KHOA_MAY',                 '\n/* ══════════ LÀN A · NỀN MÀN DEEPWORK'],
  ['async function dwLuuPhut(id){',     '\nasync function dwXoaPhien('],
  ['async function dwXoaThat(id){',     '\n/* ═══']
];
const nguon = MOC.map(([a, b]) => {
  const i = s.indexOf(a);
  if (i < 0) throw new Error('Không tìm thấy mốc lát: ' + a);
  const j = s.indexOf(b, i);
  if (j < 0) throw new Error('Không tìm thấy mốc đóng của: ' + a);
  return s.slice(i, j);
}).join('\n')
/* `const` khai bên trong eval chỉ sống trong phạm vi của eval — hàm thì lọt ra
   (khai bằng `function`), hằng số thì không. Bộ thử cần đọc thẳng mấy con số
   THẬT trong mã chứ không chép tay sang đây, chép tay là ngày nào đó mã đổi
   ngưỡng mà bộ thử vẫn xanh. Nên đẩy chúng ra global ngay sau khi lát. */
  + '\n;[["DW_MAY",DW_MAY],["DW_SAN_PHUT",DW_SAN_PHUT],["DW_TRAN_PHUT",DW_TRAN_PHUT],'
  + '["DW_IM_LANG_PHUT",DW_IM_LANG_PHUT],["DW_NHIP_GIAY",DW_NHIP_GIAY]]'
  + '.forEach(([k,v]) => { global[k] = v });';

/* ── Bộ nhớ, DOM và máy chủ giả ───────────────────────────────────────────── */
const KHO = {};
global.localStorage = {
  getItem: k => (k in KHO ? KHO[k] : null),
  setItem: (k, v) => { KHO[k] = String(v) },
  removeItem: k => { delete KHO[k] }
};
const O_PHUT = {value:'30'};
global.document = {getElementById: id => (id === 'sp-phut' ? O_PHUT : null)};

let GHI = [], NOI = [];
let PHIEN_TRA = null;        // dòng phiên mà câu đọc trả về
let LOI_INSERT = null;       // đặt mã lỗi để thử cửa lùi khi máy chủ chưa có cột
let dwPhien = null;
const ME = {id:'toi'};
const toast = m => NOI.push(String(m));
const noiCuoi = () => NOI[NOI.length - 1] || '';
const hopHoiDong = () => {};
const taiTaskList = async () => {};
/* Hai cửa sửa phiên (`dwLuuPhutCua` · `dwHuy`) gọi thêm `taiHanhTrinh()` từ
   28/08, khi khối Hành trình deep work dời sang màn Bảng đo và có đường tải
   riêng. Bộ thử này chỉ soi thứ được ghi lên máy chủ, nên giả lập rỗng là đủ. */
const taiHanhTrinh = async () => {};
/* Từ 07/09 (làn QK) hai cửa ấy gọi thêm `cbTaiLai()`: phiên vừa khai xong thì
   dòng mời khai trong khối Chờ bạn phải rụng ngay. Đếm số lần gọi để ca cuối
   tệp này canh được rằng đường ấy không bị gỡ mất. */
let SO_CB = 0;
const cbTaiLai = async () => { SO_CB++; };
const gioChu = p => `${p}′`;
const baoLoiPhien = e => '⚠️ ' + (e && e.message || 'lỗi');

/* Chuỗi giả kiểu PostgREST: mọi mắt xích trả lại chính mình, await ở bất kỳ
   đâu cũng ra {data, error}. */
const chuoi = kq => {
  const o = { eq: () => o, select: () => o, limit: () => o, order: () => o,
              then: (t, x) => Promise.resolve(kq()).then(t, x) };
  return o;
};
const sb = {
  from: bang => ({
    select: () => chuoi(() => ({data: PHIEN_TRA ? [PHIEN_TRA] : [], error: null})),
    insert: rows => {
      GHI.push({loai:'insert', bang, rows});
      /* Máy chủ chưa chạy nang-cap-may-va-nhip-tim.sql chỉ đá gói CÓ hai cột
         mới; gói cũ vẫn nhận bình thường — đúng như PostgREST cư xử. */
      if (LOI_INSERT && ('may_ma' in rows))
        return chuoi(() => ({data:null, error:{code:LOI_INSERT}}));
      return chuoi(() => ({data:[{id:99, ...rows}], error:null}));
    },
    update: patch => {
      const rec = {loai:'update', bang, patch};
      GHI.push(rec);
      const o = { eq: (c, v) => { rec[c] = v; return o },
                  then: (t, x) => Promise.resolve({data:[{id:rec.id}], error:null}).then(t, x) };
      return o;
    },
    delete: () => {
      const rec = {loai:'delete', bang};
      const o = { eq: (c, v) => { rec[c] = v; if (!GHI.includes(rec)) GHI.push(rec); return o },
                  then: (t, x) => Promise.resolve({data:[{id:rec.id}], error:null}).then(t, x) };
      return o;
    }
  })
};
eval(nguon);

let hong = 0;
function kiem(ten, dat, them){
  console.log((dat ? '✅ ' : '❌ ') + ten + (dat || !them ? '' : '\n      → ' + them));
  if (!dat) hong++;
}
const truoc  = p => new Date(Date.now() - p*60000).toISOString();
const coGhi  = loai => GHI.some(g => g.loai === loai);
const datRa  = p => { GHI = []; NOI = []; PHIEN_TRA = p; };

(async () => {
  console.log('\n── AI ĐƯỢC ĐỤNG VÀO PHIÊN CHƯA ĐÓNG ──');
  kiem('Phiên mở trên CHÍNH máy này → đóng lại được ngay, không phải chờ ai',
    dwDongDuoc({ket_qua:'dang_chay', may_ma:DW_MAY, nhip_cuoi:truoc(0)}) === true);
  kiem('Máy khác mà nhịp vừa đập → cấm đụng, phiên đang chạy thật',
    dwDongDuoc({ket_qua:'dang_chay', may_ma:'may-khac', nhip_cuoi:truoc(1)}) === false);
  kiem('Máy khác đã im lặng quá ngưỡng → coi như đi khỏi, đoạt lại được',
    dwDongDuoc({ket_qua:'dang_chay', may_ma:'may-khac',
                nhip_cuoi:truoc(DW_IM_LANG_PHUT + 1)}) === true);
  kiem('Phiên đang ⏸ thì im lặng KHÔNG tính là bỏ rơi — nó đứng yên có chủ ý',
    dwDongDuoc({ket_qua:'dang_chay', may_ma:'may-khac',
                nhip_cuoi:truoc(90), tam_dung_luc:truoc(90)}) === false);
  kiem('Máy chủ chưa chạy SQL (chưa có hai cột) → rơi về nết cũ, không đoạt bừa',
    dwDongDuoc({ket_qua:'dang_chay'}) === false);
  kiem('Phiên đã chốt thì không thuộc diện này',
    dwDongDuoc({ket_qua:'song', may_ma:DW_MAY}) === false);

  console.log('\n── DẢI LỊCH THÔI BỊA GIỜ KẾT THÚC ──');
  const bd38 = new Date(Date.now() - 38*60000);
  const kt38 = dwGioKet({bat_dau: bd38.toISOString()});
  kiem('Phiên chưa đóng vẽ tới BÂY GIỜ, không cộng đại 30 phút',
    Math.abs(kt38 - Date.now()) < 3000
      && Math.abs(kt38 - (bd38.getTime() + 30*60000)) > 60000,
    `lệch bây giờ ${Math.round((kt38 - Date.now())/1000)}s`);
  const bdCu = new Date(Date.now() - 10*3600*1000);
  kiem('Phiên bỏ quên từ lâu bị kẹp ở trần, không kéo vệt che hết dải lịch',
    Math.round((dwGioKet({bat_dau: bdCu.toISOString()}) - bdCu)/60000) === DW_TRAN_PHUT);
  kiem('Phiên đã có giờ kết thúc thì giữ nguyên, không nắn',
    dwGioKet({bat_dau: bdCu.toISOString(),
              ket_thuc: new Date(bdCu.getTime() + 25*60000).toISOString()}).getTime()
      === bdCu.getTime() + 25*60000);

  console.log('\n── CỬA LÙI KHI MÁY CHỦ CHƯA CHẠY SQL ──');
  datRa(null); LOI_INSERT = null;
  await dwMoPhienMoi({task_id:7});
  kiem('Mặc định gửi kèm mã máy và nhịp tim',
    GHI[0].rows.may_ma === DW_MAY && !!GHI[0].rows.nhip_cuoi);
  datRa(null); LOI_INSERT = 'PGRST204';
  const rLui = await dwMoPhienMoi({task_id:7});
  kiem('Máy chủ đá gói mới → tự gửi lại gói cũ, phiên vẫn mở được',
    GHI.length === 2 && !('may_ma' in GHI[1].rows) && !rLui.error,
    JSON.stringify(GHI.map(g => Object.keys(g.rows))));
  LOI_INSERT = null;

  console.log('\n── KHAI SỐ PHÚT CHO PHIÊN CHƯA ĐÓNG ──');
  O_PHUT.value = '30';
  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay', may_ma:'may-khac', nhip_cuoi:truoc(1)});
  await dwLuuPhut(5);
  kiem('Phiên đang chạy thật ở máy khác → chặn, không ghi một chữ nào', !coGhi('update'));
  kiem('… và câu báo nêu con số đo được thay vì bịa ra một cái máy',
    /lên tiếng/.test(noiCuoi()), noiCuoi());

  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay', may_ma:DW_MAY, nhip_cuoi:truoc(1)});
  await dwLuuPhut(5);
  kiem('Phiên của CHÍNH máy này → cho khai (đúng chỗ John bị chặn oan)',
    GHI.some(g => g.loai === 'update' && g.patch.ket_qua === 'song'),
    noiCuoi());

  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay', may_ma:'may-khac',
         nhip_cuoi:truoc(DW_IM_LANG_PHUT + 4)});
  await dwLuuPhut(5);
  kiem('Máy giữ phiên đã im lặng lâu → cho khai, khỏi chờ đủ trần 180 phút',
    coGhi('update'), noiCuoi());

  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay'});
  await dwLuuPhut(5);
  kiem('Chưa chạy SQL và phiên còn trẻ → vẫn chặn theo trần như bản cũ',
    !coGhi('update'), noiCuoi());

  O_PHUT.value = '120';
  datRa({id:5, bat_dau:truoc(40), ket_qua:'heo'});
  await dwLuuPhut(5);
  kiem('Khai dài hơn quãng đã trôi → rào cũ vẫn còn nguyên', !coGhi('update'), noiCuoi());
  O_PHUT.value = '30';

  console.log('\n── DÒNG MỜI KHAI PHẢI RỤNG NGAY SAU KHI KHAI ── (07/09, QK)');
  SO_CB = 0;
  datRa({id:5, bat_dau:truoc(40), ket_qua:'heo', ket_thuc:truoc(10)});
  await dwLuuPhut(5);
  kiem('Khai xong thì khối Chờ bạn được soát lại, không đợi nhịp 5 phút',
    coGhi('update') && SO_CB === 1, `ghi:${coGhi('update')} · soát:${SO_CB}`);

  console.log('\n── NÚT 🗑 KHÔNG ĐƯỢC XOÁ PHIÊN ĐANG SỐNG ──');
  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay', may_ma:'may-khac', nhip_cuoi:truoc(1)});
  await dwXoaThat(5);
  kiem('Phiên đang chạy thật ở máy khác → KHÔNG xoá (chỗ nguy hiểm nhất của lỗi)',
    !coGhi('delete'), noiCuoi());
  datRa({id:5, bat_dau:truoc(40), ket_qua:'dang_chay', may_ma:DW_MAY, nhip_cuoi:truoc(1)});
  await dwXoaThat(5);
  kiem('Phiên của chính máy này thì vẫn xoá được bình thường', coGhi('delete'));
  datRa({id:5, bat_dau:truoc(40), ket_qua:'song', ket_thuc:truoc(5)});
  await dwXoaThat(5);
  kiem('Phiên đã chốt thì xoá được như trước', coGhi('delete'));

  console.log(hong ? `\n❌ ${hong} mục chưa đạt\n` : '\n✅ Tất cả đều đạt\n');
  process.exit(hong ? 1 : 0);
})();
