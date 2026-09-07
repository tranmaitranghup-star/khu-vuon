#!/usr/bin/env node
/* Bản thử LUỒNG GHI của sổ ghi chú phiên (làn R, 16/08) — không cần đăng nhập.
 *
 * Cùng mẹo với `thu-luong-nghen.js`: rút NGUYÊN hàm từ `public/index.html` rồi
 * chạy chúng trên một kho giả, nên không bao giờ soi nhầm bản cũ. Soi đúng thứ
 * mắt không nhìn ra được: một phiên đẻ mấy dòng, dòng nào bị viết đè, dòng thừa
 * có được dọn không, và lưu hỏng thì cửa sổ có đóng mất chữ không.
 *
 *     node thu-so-phien.js
 */
const fs = require('fs'), path = require('path'), vm = require('vm');

const src = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf8');
const ham = ten => {
  const m = src.match(new RegExp('(?:async )?function ' + ten + '\\(.*?\\n\\}', 's'));
  if (!m) { console.error('không thấy hàm ' + ten); process.exit(1); }
  return m[0];
};

// ── Kho giả ────────────────────────────────────────────────────────────────
let LOG, BANG, TU_CHOI, idTiep;
function lamMoi(rows = [], task = []){
  LOG = []; TU_CHOI = null; idTiep = 100;
  BANG = {ghi_chu: rows.map(r => ({...r})), task: task.map(r => ({...r}))};
}
const ketQua = (data, error) => Promise.resolve({data, error});

function sb_from(bang){
  const loc = {};
  const api = {
    select(){ return api; },
    eq(c, v){ loc[c] = v; return api; },
    in(c, v){ loc[c + '_in'] = v; return api; },
    order(){
      LOG.push(['select', bang, {...loc}]);
      return ketQua(BANG[bang].filter(r => r.phien_id === loc.phien_id), null);
    },
    limit(){ LOG.push(['select1', bang, {...loc}]); return ketQua([], null); },
    insert(row){
      api._row = row;
      return {select(){
        if (TU_CHOI) { LOG.push(['insert-HỎNG', bang]); return ketQua(null, TU_CHOI); }
        const moi = {id: idTiep++, ...row};
        BANG[bang].push(moi);
        LOG.push(['insert', bang, row.noi_dung]);
        return ketQua([moi], null);
      }};
    },
    update(patch){
      return {eq(c, v){
        if (TU_CHOI) { LOG.push(['update-HỎNG', bang]); return ketQua(null, TU_CHOI); }
        const d = BANG[bang].find(r => r[c] === v);
        if (d) Object.assign(d, patch);
        LOG.push(['update', bang, v, patch.noi_dung]);
        return ketQua([d], null);
      }};
    },
    delete(){
      return {in(c, ids){
        BANG[bang] = BANG[bang].filter(r => !ids.includes(r[c]));
        LOG.push(['delete', bang, ids]);
        return ketQua([], null);
      }};
    },
  };
  return api;
}

// ── Màn hình giả: đúng hai nút bấm mà mã thật chạm tới ─────────────────────
const NUT = {
  'dw-note': {classList: new Set(),
    _cl: null,
    get classes(){ return this._cl; }},
};
function taoO(){
  const o = {value: '', selectionStart: 0, selectionEnd: 0, scrollTop: 0, scrollHeight: 999,
             focus(){ o._focus = true; }};
  return o;
}
let O_NOTE, CUA_NOTE, TOAST;
function taoMan(){
  O_NOTE = taoO();
  const cl = new Set();
  CUA_NOTE = {classList: {
    add: c => cl.add(c), remove: c => cl.delete(c), contains: c => cl.has(c),
    toggle: (c, b) => b ? cl.add(c) : cl.delete(c)}, _cl: cl};
  TOAST = [];
}

const boi = {
  console,
  setTimeout: (f) => f(),          // chạy ngay, khỏi chờ
  Date,
  ME: {id: 'u1'},
  TASKS: [{id: 7, tieu_diem_ma: 'O5'}],
  TASK_CK: {},
  dwTaskChon: null,
  dwPhien: null,
  toast: m => TOAST.push(m),
  /* Xem lời khai cùng nội dung ở `thu-luong-nghen.js` — bài này hỏi về bản doc
     của phiên, không hỏi về đường lui (07/09, TRI-156). */
  htChupTheo: async () => null,
  htNhan: () => undefined,
  sb: {from: sb_from},
  document: {getElementById: id => id === 'dw-note' ? CUA_NOTE
                              : id === 'dw-note-o' ? O_NOTE
                              : O_KHAC[id] !== undefined ? O_KHAC[id]
                              : {classList: {remove(){}, add(){}, contains: () => false},
                                 innerHTML: '', value: ''}},
  baoLoiTask: e => '⚠️ ' + (e?.message || ''),
  taiHomNay: () => {},
  dwThemVeDs: () => { VE_LAI++; },
  homNay: () => '2026-08-16',
};
let O_KHAC = {}, VE_LAI = 0;
boi.globalThis = boi;
vm.createContext(boi);
vm.runInContext([
  'let GC_DOC = null, GC_DOC_PHIEN = null, GC_DOC_THUA = [];',
  ham('timTaskGC'), ham('baoLoiGhiChu'), ham('dwNoteMo'), ham('dwNoteLuu'),
  ham('dwDongHopGhi'),
  'let DW_VIEC_PHIEN = [], DW_THE_SUA = null;',
  ham('dwNhanTheDi'), ham('dwTheLuu'),
].join('\n\n'), boi);

// ── Máy chấm ───────────────────────────────────────────────────────────────
let dat = 0, truot = 0;
const ok = (ten, that, mong) => {
  const d = JSON.stringify(that) === JSON.stringify(mong);
  d ? dat++ : truot++;
  console.log(`${d ? '  ✓' : '  ✗'} ${ten}` + (d ? '' :
    `\n      mong: ${JSON.stringify(mong)}\n      thật: ${JSON.stringify(that)}`));
};
const dem = loai => LOG.filter(l => l[0] === loai).length;
const dong = () => BANG.ghi_chu.filter(r => r.phien_id === 9);

(async () => {

console.log('\n① Phiên trắng: mở sổ → gõ → Ghi');
lamMoi(); taoMan();
boi.dwPhien = {id: 9, task_id: 7};
vm.runInContext('GC_DOC = null; GC_DOC_PHIEN = null; GC_DOC_THUA = [];', boi);
await boi.dwNoteMo();
ok('cửa sổ mở', CUA_NOTE.classList.contains('hien'), true);
ok('ô gõ trống', O_NOTE.value, '');
O_NOTE.value = 'Ý thứ nhất.';
await boi.dwNoteLuu();
ok('đẻ đúng 1 dòng', dong().length, 1);
ok('có dây neo cam kết', dong()[0].tieu_diem_ma, 'O5');
ok('cửa sổ tự đóng', CUA_NOTE.classList.contains('hien'), false);

console.log('\n② Mở lại → thấy chữ cũ → viết tiếp xuống dưới (KHÔNG đẻ dòng mới)');
await boi.dwNoteMo();
ok('ô gõ có nguyên chữ cũ', O_NOTE.value, 'Ý thứ nhất.');
ok('con trỏ ở cuối', O_NOTE.selectionStart, 'Ý thứ nhất.'.length);
O_NOTE.value = 'Ý thứ nhất.\n\nÝ thứ hai, viết tiếp.';
await boi.dwNoteLuu();
ok('vẫn ĐÚNG 1 dòng (viết đè, không đẻ thêm)', dong().length, 1);
ok('nội dung là cả bản doc', dong()[0].noi_dung, 'Ý thứ nhất.\n\nÝ thứ hai, viết tiếp.');
ok('có 1 lệnh update', dem('update'), 1);
ok('không có lệnh insert nào ở nhát này', dem('insert'), 1);   // 1 = của nhát ①

console.log('\n③ Bấm Ghi mà không đổi gì → không gọi máy chủ lần nữa');
const truocLog = LOG.length;
await boi.dwNoteMo();
await boi.dwNoteLuu();
ok('không thêm lệnh ghi nào', LOG.slice(truocLog).filter(l => /insert|update/.test(l[0])).length, 0);
ok('cửa sổ vẫn đóng lại', CUA_NOTE.classList.contains('hien'), false);

console.log('\n④ Phiên nếp CŨ (3 mẩu rời) → gộp về một dòng, dọn 2 dòng thừa');
lamMoi([
  {id: 1, phien_id: 9, noi_dung: 'mẩu một', nguoi_id: 'u1'},
  {id: 2, phien_id: 9, noi_dung: 'mẩu hai', nguoi_id: 'u1'},
  {id: 3, phien_id: 9, noi_dung: 'mẩu ba', nguoi_id: 'u1'},
  {id: 4, phien_id: 8, noi_dung: 'của phiên KHÁC', nguoi_id: 'u1'},
]);
taoMan();
vm.runInContext('GC_DOC = null; GC_DOC_PHIEN = null; GC_DOC_THUA = [];', boi);
await boi.dwNoteMo();
ok('ô gõ nối đủ 3 mẩu', O_NOTE.value, 'mẩu một\nmẩu hai\nmẩu ba');
O_NOTE.value += '\nmẩu bốn vừa gõ';
await boi.dwNoteLuu();
ok('phiên 9 còn đúng 1 dòng', dong().length, 1);
ok('giữ dòng ĐẦU (id 1)', dong()[0].id, 1);
ok('dòng ấy ôm cả 4 mẩu', dong()[0].noi_dung, 'mẩu một\nmẩu hai\nmẩu ba\nmẩu bốn vừa gõ');
ok('phiên khác KHÔNG bị đụng', BANG.ghi_chu.filter(r => r.phien_id === 8).length, 1);

console.log('\n⑤ Lưu HỎNG → cửa sổ ở lại, chữ còn nguyên, dòng thừa chưa bị dọn');
lamMoi([
  {id: 1, phien_id: 9, noi_dung: 'mẩu một', nguoi_id: 'u1'},
  {id: 2, phien_id: 9, noi_dung: 'mẩu hai', nguoi_id: 'u1'},
]);
taoMan();
vm.runInContext('GC_DOC = null; GC_DOC_PHIEN = null; GC_DOC_THUA = [];', boi);
await boi.dwNoteMo();
O_NOTE.value = 'mẩu một\nmẩu hai\nviết thêm rồi mạng rớt';
TU_CHOI = {code: '42P01', message: 'relation "ghi_chu" does not exist'};
await boi.dwNoteMo();                      // bấm ✕ để đóng
ok('cửa sổ KHÔNG đóng', CUA_NOTE.classList.contains('hien'), true);
ok('chữ còn nguyên', O_NOTE.value, 'mẩu một\nmẩu hai\nviết thêm rồi mạng rớt');
ok('2 dòng thừa CHƯA bị dọn', BANG.ghi_chu.filter(r => r.phien_id === 9).length, 2);
ok('báo đúng tên file SQL phải chạy', /nang-cap-ghi-chu\.sql/.test(TOAST.at(-1)), true);

console.log('\n⑥ Ra khỏi phiên (bấm ⏹) → lưu ngầm, không toast');
lamMoi(); taoMan();
vm.runInContext('GC_DOC = null; GC_DOC_PHIEN = null; GC_DOC_THUA = [];', boi);
await boi.dwNoteMo();
O_NOTE.value = 'chữ chưa kịp bấm Ghi';
boi.dwDongHopGhi();
await new Promise(r => setImmediate(r));
ok('vẫn ghi xuống', dong().length, 1);
ok('đúng chữ đang gõ dở', dong()[0].noi_dung, 'chữ chưa kịp bấm Ghi');
ok('không toast nào', TOAST.length, 0);

console.log('\n⑦ Cửa sổ ĐANG ĐÓNG mà ra khỏi phiên → không ghi gì (chữ trong ô là của phiên cũ)');
lamMoi(); taoMan();
vm.runInContext('GC_DOC = null; GC_DOC_PHIEN = null; GC_DOC_THUA = [];', boi);
O_NOTE.value = 'chữ sót của phiên trước';
boi.dwDongHopGhi();
await new Promise(r => setImmediate(r));
ok('không dòng nào ra đời', BANG.ghi_chu.length, 0);

console.log('\n⑧ Sửa một thẻ việc trong khay (tên + ngày)');
lamMoi([], [{id: 501, noi_dung: 'kkk', ngay: null},
            {id: 502, noi_dung: 'mua', ngay: '2026-08-17'}]);
taoMan(); TOAST = [];
vm.runInContext('DW_VIEC_PHIEN = [{id:501,noi_dung:"kkk",ngay:null},' +
                '{id:502,noi_dung:"mua",ngay:"2026-08-17"}]; DW_THE_SUA = 501;', boi);

O_KHAC = {'dw-the-o-501': {value: '   '}, 'dw-the-ngay-501': {value: ''}};
await boi.dwTheLuu(501);
ok('xoá trắng tên thì KHÔNG ghi', BANG.task.find(t => t.id === 501).noi_dung, 'kkk');
ok('và nói ra, không im lặng', /không để trống/.test(TOAST.at(-1)), true);

O_KHAC = {'dw-the-o-501': {value: 'mua sách cho con'}, 'dw-the-ngay-501': {value: '2026-08-18'}};
await boi.dwTheLuu(501);
ok('ghi đúng tên mới', BANG.task.find(t => t.id === 501).noi_dung, 'mua sách cho con');
ok('ghi đúng ngày mới', BANG.task.find(t => t.id === 501).ngay, '2026-08-18');
ok('khay trong RAM đi theo',
   vm.runInContext('DW_VIEC_PHIEN[0].noi_dung + "|" + DW_VIEC_PHIEN[0].ngay', boi),
   'mua sách cho con|2026-08-18');
ok('gấp mặt sửa lại', vm.runInContext('DW_THE_SUA', boi), null);
ok('KHÔNG đụng thẻ còn lại', BANG.task.find(t => t.id === 502).noi_dung, 'mua');

vm.runInContext('DW_THE_SUA = 502;', boi);
O_KHAC = {'dw-the-o-502': {value: 'mua'}, 'dw-the-ngay-502': {value: ''}};
await boi.dwTheLuu(502);
ok('bỏ trống ngày = trả việc về kho', BANG.task.find(t => t.id === 502).ngay, null);
ok('lời báo nói đúng chỗ việc vừa đi', /về 🧺 kho/.test(TOAST.at(-1)), true);

console.log(`\n${truot ? '❌' : '✅'} ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);

})();
