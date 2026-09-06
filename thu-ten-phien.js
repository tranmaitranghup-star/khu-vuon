#!/usr/bin/env node
/* Bản thử NHÃN TÊN VIỆC trên dòng phiên của dải Timeline (làn T, 17/08).
 *
 * Vì sao đáng một bản thử riêng: `tlLay` nạp task bằng `.gte('ngay',tu)
 * .lte('ngay',den)`, mà việc đã về kho có `ngay IS NULL` nên không phép so sánh
 * nào cho nó lọt. Dòng phiên lại tra tên từ đúng tập ấy, không thấy thì kết
 * luận "task đã xoá" — nói sai về một việc còn nguyên trong kho. Mà đường về
 * kho là đường thường ngày, có cả ca ÉP BUỘC ở màn Dọn (hoãn quá ba lần thì ô
 * ngày bị khoá).
 *
 * Con mắt KHÔNG bắt được lỗi này: nhãn "task đã xoá" trông y hệt một nhãn đúng,
 * và chỉ người biết việc ấy còn sống mới thấy sai. Nên phải đo bằng máy.
 *
 *     node thu-ten-phien.js
 */
const fs = require('fs'), path = require('path'), vm = require('vm');

const src = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf8');
const ham = ten => {
  const m = src.match(new RegExp('(?:async )?function ' + ten + '\\(.*?\\n\\}', 's'));
  if (!m) { console.error('không thấy hàm ' + ten); process.exit(1); }
  return m[0];
};

/* ── Kho giả: chuỗi lọc GHI LẠI mình đã lọc gì ──────────────────────────────
   Khác kho giả của các bản thử trước — ở đây phép lọc CHÍNH LÀ thứ đang thử.
   `tlLay` gọi hai lối khác nhau lên cùng bảng `task`: lối theo dải ngày
   (`gte`/`lte`) và lối phụ theo `id` (`in`). Kho giả phải trả khác nhau cho hai
   lối, nếu không thì bản thử tự cho mình đáp án. */
let KHO, DA_HOI;
function chuoi(bang){
  const loc = {bang, in: null, gte: null, lte: null, is: undefined};
  const api = {};
  ['select','eq','not','neq','limit','order'].forEach(m => api[m] = () => api);
  api.in  = (cot, ds) => { if (cot === 'id') loc.in = ds; return api; };
  api.gte = (cot, v)  => { if (cot === 'ngay') loc.gte = v; return api; };
  api.lte = (cot, v)  => { if (cot === 'ngay') loc.lte = v; return api; };
  api.is  = (cot, v)  => { if (cot === 'ngay') loc.is  = v; return api; };
  api.then = res => {
    DA_HOI.push(loc);
    let rows = KHO[bang] || [];
    if (bang === 'task'){
      if (loc.in)  rows = rows.filter(t => loc.in.includes(t.id));
      if (loc.gte) rows = rows.filter(t => t.ngay && t.ngay >= loc.gte && t.ngay <= loc.lte);
      if (loc.is === null) rows = rows.filter(t => !t.ngay);
    }
    res({data: rows, error: null, count: rows.length});
  };
  return api;
}
const sb = {from: bang => chuoi(bang)};

const boi = {console, Date, JSON, Set, Math, sb, ME: {id: 'u1'},
  toast: () => {}, TRAN_MAY_CHU: 1000,
  COT_TASK: 'id,nguoi_id,ngay,noi_dung',
  TL_KHUNG: 'tuan', TL_KHO: {}, TK_TASKS: [], NHIP: [],
  dauNgayVN: d => d + 'T00:00:00', cuoiNgayVN: d => d + 'T23:59:59'};
boi.globalThis = boi;
vm.createContext(boi);
/* ⚠️ `var TL_PHU` chứ không phải `let` như trong app. Trong `vm`, một khai báo
   `let` ở tầng ngoài cùng rơi vào một PHẠM VI TỪ VỰNG riêng của ngữ cảnh, không
   thành thuộc tính của đối tượng hộp cát — nên `boi.TL_PHU = {}` bên ngoài đặt
   một thuộc tính bị chính cái `let` che mất, và bản thử tưởng mình dọn được
   nhưng không. Chính lần chạy đầu đã lòi ra: hai mục ở ④ và ⑤ "đạt" trong khi
   chúng chưa hề dọn được gì. `var` thì mới lên đúng hộp cát. */
vm.runInContext(
  ['var TL_PHU = {};', ham('kiemCat'), ham('tlLay'), ham('tlTenPhien')].join('\n\n'), boi);

let dat = 0, truot = 0;
const ok = (ten, that, mong) => {
  const d = JSON.stringify(that) === JSON.stringify(mong);
  d ? dat++ : truot++;
  console.log(`${d ? '  ✓' : '  ✗'} ${ten}` + (d ? '' :
    `\n      mong: ${JSON.stringify(mong)}\n      thật: ${JSON.stringify(that)}`));
};

/* Bốn việc, bốn số phận khác nhau — cộng một phiên việc cố định làm đối chứng. */
function dungKho(){
  DA_HOI = [];
  boi.TL_KHO = {}; boi.TL_PHU = {};
  boi.TK_TASKS = [];
  boi.NHIP = [{id: 70, ten: 'Họp giao ban'}];
  KHO = {
    task: [
      {id: 1, ngay: '2026-08-17', noi_dung: 'việc nằm trong dải'},
      {id: 2, ngay: null,         noi_dung: 'việc đã về KHO'},
      {id: 3, ngay: '2026-09-30', noi_dung: 'việc bị dời sang ngày khác'},
      // id 4 KHÔNG có trong kho — task bị xoá hẳn
    ],
    phien_deepwork: [
      {id: 91, task_id: 1,    nhip_id: null, bat_dau: '2026-08-17T02:00:00Z'},
      {id: 92, task_id: 2,    nhip_id: null, bat_dau: '2026-08-17T03:00:00Z'},
      {id: 93, task_id: 3,    nhip_id: null, bat_dau: '2026-08-18T03:00:00Z'},
      {id: 94, task_id: 4,    nhip_id: null, bat_dau: '2026-08-19T03:00:00Z'},
      {id: 95, task_id: null, nhip_id: 70,   bat_dau: '2026-08-20T03:00:00Z'},
    ],
  };
}
const phien = n => KHO.phien_deepwork.find(p => p.id === n);

(async () => {

console.log('\n① Bốn ca nhãn — kho · trong dải · ngày khác · xoá hẳn');
dungKho();
let kq = await boi.tlLay('2026-08-17', '2026-08-23');
ok('dải nạp đúng 1 việc theo ngày', kq.tasks.map(t => t.id), [1]);
ok('truy vấn phụ vớt về 2 việc ngoài dải', Object.keys(kq.phu).map(Number).sort(), [2,3]);
ok('id 4 không có thật → không nằm trong bản tra', kq.phu[4], undefined);
ok('việc trong dải  → tên trần',
   boi.tlTenPhien(phien(91), kq.tasks), 'việc nằm trong dải');
ok('việc TRONG KHO  → 🧺 + tên thật (ĐÂY LÀ LỖI ĐANG VÁ)',
   boi.tlTenPhien(phien(92), kq.tasks), '🧺 việc đã về KHO');
ok('việc dời ngày   → tên trần, không dấu',
   boi.tlTenPhien(phien(93), kq.tasks), 'việc bị dời sang ngày khác');
ok('việc XOÁ HẲN    → giữ nhãn cũ',
   boi.tlTenPhien(phien(94), kq.tasks), 'task đã xoá');
ok('phiên việc cố định → không đổi',
   boi.tlTenPhien(phien(95), kq.tasks), '🔁 Họp giao ban');

console.log('\n② Không có id thiếu thì KHÔNG gọi truy vấn phụ');
dungKho();
KHO.phien_deepwork = [phien(91)];          // chỉ phiên gắn việc nằm trong dải
await boi.tlLay('2026-08-17', '2026-08-23');
ok('hỏi bảng task đúng 1 lần', DA_HOI.filter(l => l.bang === 'task').length, 1);
ok('lần ấy là lối theo dải ngày, không phải lối theo id',
   DA_HOI.filter(l => l.bang === 'task').map(l => !!l.in), [false]);

console.log('\n③ Truy vấn phụ chỉ hỏi ĐÚNG những id còn thiếu, mỗi id một lần');
dungKho();
KHO.phien_deepwork.push({id: 96, task_id: 2, nhip_id: null, bat_dau: '2026-08-21T03:00:00Z'});
await boi.tlLay('2026-08-17', '2026-08-23');
ok('danh sách id hỏi thêm', DA_HOI.find(l => l.in).in.sort(), [2,3,4]);
ok('id 2 lặp ở hai phiên vẫn chỉ hỏi một lần',
   DA_HOI.find(l => l.in).in.filter(x => x === 2).length, 1);
ok('không hỏi id 1 (đã có trong dải)', DA_HOI.find(l => l.in).in.includes(1), false);

console.log('\n④ Lấy lại từ đệm thì TL_PHU vẫn đúng dải (không rỗng, không của dải cũ)');
dungKho();
await boi.tlLay('2026-08-17', '2026-08-23');
const soLanHoi = DA_HOI.length;
boi.TL_PHU = {};                            // giả bộ một dải khác vừa vẽ xong
kq = await boi.tlLay('2026-08-17', '2026-08-23');
ok('không hỏi máy chủ thêm lần nào', DA_HOI.length, soLanHoi);
ok('TL_PHU được trỏ lại đúng bản tra của dải',
   boi.tlTenPhien(phien(92), kq.tasks), '🧺 việc đã về KHO');

console.log('\n⑤ Cửa lùi TK_TASKS vẫn ăn khi không cầm dải nào (hộp sửa phiên)');
dungKho();
await boi.tlLay('2026-08-17', '2026-08-23');
ok('hộp sửa phiên đọc việc trong kho qua TL_PHU',
   boi.tlTenPhien(phien(92), null), '🧺 việc đã về KHO');
boi.TL_PHU = {};
boi.TK_TASKS = [{id: 2, ngay: null, noi_dung: 'việc đã về KHO'}];
ok('TL_PHU rỗng thì TK_TASKS đỡ, vẫn ra 🧺',
   boi.tlTenPhien(phien(92), null), '🧺 việc đã về KHO');
boi.TK_TASKS = [];
ok('không cửa nào có thì mới là "task đã xoá"',
   boi.tlTenPhien(phien(92), null), 'task đã xoá');

console.log(`\n${truot ? '✗' : '✓'} ${dat}/${dat + truot} đạt` +
            (truot ? ` — ${truot} TRƯỢT` : ''));
process.exit(truot ? 1 : 0);

})();
