#!/usr/bin/env node
/* Bản thử PHÉP LỌC "phiên còn đang chạy" của `ckNoteTai` (làn R, 16/08).
 *
 * Vì sao đáng một bản thử riêng: từ 16/08 mỗi phiên chỉ có MỘT dòng `ghi_chu`,
 * và nó là dòng SỐNG — còn được viết thêm tới lúc kết phiên. Mà phần trích đánh
 * dấu "đã lấy" theo khoá `y:<id>` trong `doc_da_gop`, lấy một lần rồi thôi. Mở
 * bản doc cam kết giữa lúc còn làm là khoá luôn dòng ấy ở trạng thái viết dở, và
 * mọi chữ viết sau đó vĩnh viễn không tới được cam kết. Mắt không nhìn ra lỗi
 * này — nó chỉ hiện ra vài ngày sau, dưới dạng "sao ghi chú thiếu".
 *
 *     node thu-trich-doc.js
 */
const fs = require('fs'), path = require('path'), vm = require('vm');

const src = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf8');
const ham = ten => {
  const m = src.match(new RegExp('(?:async )?function ' + ten + '\\(.*?\\n\\}', 's'));
  if (!m) { console.error('không thấy hàm ' + ten); process.exit(1); }
  return m[0];
};

// ── Kho giả: mỗi bảng trả một mớ dòng, bất kể lọc gì ───────────────────────
let KHO, DA_GHI;
function chuoi(rows){
  const api = {};
  ['select','eq','not','neq','limit','order','in','gte','lte'].forEach(m => api[m] = () => api);
  api.then = res => res({data: rows, error: null});
  return api;
}
const sb = {from: bang => {
  const api = chuoi(KHO[bang] || []);
  api.upsert = row => { DA_GHI.push(row); return chuoi([]); };
  return api;
}};

const boi = {console, Date, ME: {id: 'u1'}, sb,
  toast: () => {}, CK_NOTE_DS: {}, CK_DOC: {}};
boi.globalThis = boi;
vm.createContext(boi);
vm.runInContext([ham('ckLuc'), ham('docMotMau'), ham('baoLoiDoc'), ham('ckNoteTai')].join('\n\n'), boi);

let dat = 0, truot = 0;
const ok = (ten, that, mong) => {
  const d = JSON.stringify(that) === JSON.stringify(mong);
  d ? dat++ : truot++;
  console.log(`${d ? '  ✓' : '  ✗'} ${ten}` + (d ? '' :
    `\n      mong: ${JSON.stringify(mong)}\n      thật: ${JSON.stringify(that)}`));
};

function dungKho({dangChay}){
  DA_GHI = [];
  KHO = {
    ghi_chu: [
      {id: 11, phien_id: 9, noi_dung: 'sổ của phiên ĐANG CHẠY, viết dở',
       tieu_diem_ma: 'O5', tao_luc: '2026-08-16T09:00:00Z'},
      {id: 12, phien_id: 8, noi_dung: 'sổ của phiên đã đóng',
       tieu_diem_ma: 'O5', tao_luc: '2026-08-15T09:00:00Z'},
      {id: 13, phien_id: null, noi_dung: 'mẩu không thuộc phiên nào',
       tieu_diem_ma: 'O5', tao_luc: '2026-08-14T09:00:00Z'},
    ],
    task: [], phien_deepwork: [],
    doc_cam_ket: [{doc_ghi_chu: '', doc_da_gop: []}],
  };
  KHO.phien_deepwork = dangChay ? [{id: 9}] : [];
}

(async () => {

console.log('\n① Phiên 9 CÒN ĐANG CHẠY → sổ của nó phải đứng ngoài bản doc');
dungKho({dangChay: true});
await boi.ckNoteTai('O5');
const chu1 = boi.CK_DOC.O5.chu;
ok('sổ phiên đang chạy KHÔNG bị trích', /viết dở/.test(chu1), false);
ok('sổ phiên đã đóng thì có', /sổ của phiên đã đóng/.test(chu1), true);
ok('mẩu ngoài phiên vẫn có', /không thuộc phiên nào/.test(chu1), true);
ok('chưa khoá nhầm dòng 11 vào doc_da_gop',
   DA_GHI.at(-1).doc_da_gop.includes('y:11'), false);

console.log('\n② Phiên 9 đã đóng → lần mở sau trích trọn bản doc, ĐÚNG MỘT KHỐI');
const docCu = DA_GHI.at(-1);          // giữ lại TRƯỚC khi dựng kho mới
dungKho({dangChay: false});
KHO.doc_cam_ket = [{doc_ghi_chu: docCu.doc_ghi_chu, doc_da_gop: docCu.doc_da_gop}];
KHO.ghi_chu[0].noi_dung = 'sổ của phiên ĐANG CHẠY, viết dở\n\nrồi viết thêm sau đó\n\nvà thêm nữa';
await boi.ckNoteTai('O5');
const chu2 = boi.CK_DOC.O5.chu;
ok('nay đã vào doc', /viết dở/.test(chu2), true);
ok('mang theo CẢ phần viết thêm sau', /và thêm nữa/.test(chu2), true);
ok('vào đúng MỘT khối, không cắt vụn',
   chu2.split(/\n\s*\n/).filter(k => /viết dở|viết thêm sau|thêm nữa/.test(k)).length, 3);
ok('lần này mới khoá y:11', DA_GHI.at(-1).doc_da_gop.includes('y:11'), true);
ok('không trích lại hai mẩu cũ',
   (chu2.match(/sổ của phiên đã đóng/g) || []).length, 1);

console.log(`\n${truot ? '❌' : '✅'} ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);

})();
