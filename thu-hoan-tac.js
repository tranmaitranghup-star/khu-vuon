/* THỬ: ĐƯỜNG LUI — ngăn hoàn tác cho dịch chuyển lịch và chỉnh sửa việc
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 07/09: *"các thao tác dịch chuyển lịch và chỉnh sửa nó không có nút
   hoàn tác khi mà thao tác xong"*. TRI-156 mở ngăn ra cho tám cửa nữa, và để
   làm được thế thì lõi phải đổi ba chỗ — đây là bài canh ba chỗ ấy.

   Bài thử CẮT ĐÚNG KHỐI LÕI ra khỏi public/index.html rồi chạy trên máy chủ giả.

   Những ca đáng giá nhất, mỗi ca canh một lời hứa dễ gãy trong im lặng:
     · Chụp ĐÚNG những cột `patch` sắp đụng, không hơn — chụp thừa một cột là cú
       lùi đi ghi đè thứ người khác vừa đổi từ máy của họ.
     · Chụp hụt thì KHÔNG hứa. Một nút bấm vào mà lùi không hết còn tệ hơn không
       có nút, vì người ta bấm xong là thôi không đi tìm nữa.
     · Cú nhiều dòng giữ giá trị cũ RIÊNG của từng dòng — hai mươi việc kéo về
       hôm nay vốn nằm ở hai mươi ngày khác nhau.
     · Lùi hụt một phần thì chỉ phần chưa lùi trở về ngăn, và câu thông báo đếm
       đúng phần còn sót.
     · `deadline` không nhận `null` (schema: not null default '') — trả null vào
       đó là máy chủ từ chối cả câu, tức bấm Hoàn tác xong không có gì đổi.

   Chạy:  node production/tinh-thuc-app/thu-hoan-tac.js
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
/* Lấy TRỌN một hàm theo tên, đếm ngoặc nhọn — cùng khuôn `thu-keo-su-kien.js`
   dùng, và cùng lý do: chạy MÃ THẬT chứ không chép một bản thứ hai vào bài thử. */
function catHam(ten){
  let dau = SRC.indexOf('function ' + ten + '(');
  if (dau < 0) throw new Error('Khong thay ham: ' + ten);
  if (SRC.slice(dau - 6, dau) === 'async ') dau -= 6;
  let i = SRC.indexOf('{', dau), sau = 0;
  for (let j = i; j < SRC.length; j++){
    if (SRC[j] === '{') sau++;
    else if (SRC[j] === '}'){ sau--; if (!sau) return SRC.slice(dau, j+1); }
  }
  throw new Error('Ham khong dong ngoac: ' + ten);
}
const NGUON = catKhoi("const HT_COT  = ['ngay'", 'function tlkBoXuong(){')
  /* Cụm lịch (TRI-157) — cách lùi riêng của cú kéo dời sự kiện. Cắt thật, không
     chép: bản chép lệch dần rồi bài thử xanh trong khi app đỏ. */
  + catHam('lcLuot') + '\n' + catHam('lcChupBuoi') + '\n' + catHam('lcChupDoi')
  /* Cửa sửa sự kiện và cú chia chuỗi (TRI-161). */
  + '\n' + catHam('lcChupSua') + '\n' + catHam('lcChupTruocChia')
  + '\n' + catHam('lcCoNoiChuoi') + '\n' + catHam('lcCuChia');

/* ── Máy chủ giả kiểu PostgREST ─────────────────────────────────────────────
   Đủ ba lối mà lõi đụng tới: `select().eq().single()` · `select().in()` ·
   `update().eq()`. Mỗi lượt đọc lấy một câu trả lời đã xếp sẵn trong `TRA_DOC`,
   mỗi lượt ghi lấy một câu trong `TRA_GHI` — hết thì mặc định là ghi trót lọt. */
const COC = `
let TL_KHO_DS = [], TL_KHO = {}, TK_TASKS = [];
let TRA_DOC = [], TRA_GHI = [], DA_DOC = [], DA_GHI = [], TOAST = [], LAM_MOI = 0;
let TV_TIM = null;
function tvTim(id){ return TV_TIM; }
/* Cụm lịch: những gì lcChupDoi đụng tới mà nằm ngoài lát cắt. THEO_VIEC và
   THEO_CHUOI ghi lại lời gọi để bài thử soi xem cú lùi có kéo việc về bằng giá
   trị CŨ hay không — đó mới là nửa dễ quên của đường lui. */
let THEO_VIEC = [], THEO_CHUOI = [], VE_TIMELINE = 0;
let CO_NOI_CHUOI = null, DA_RPC = [], TRA_RPC = [];
async function lcTheoViec(lichId, goc, luot){ THEO_VIEC.push({lichId, goc, luot}); }
async function lcTheoChuoi(lichId, tu, den, phut){ THEO_CHUOI.push({lichId, tu, den, phut}); }
async function veTimeline(){ VE_TIMELINE++; }
function ngayDep(g){ return g; }
let LC_HIEN = null;
function toast(m, nut){ TOAST.push({m, nut}); }
async function lamMoiCuaToi(){ LAM_MOI++; }
const addEventListener = () => {};
const sb = {
  /* rpc đứng ở cấp sb, KHÔNG trong đối tượng mà from trả về — mã thật gọi
     sb.rpc(...) thẳng, không qua from.
     ⚠️ Lần thứ hai trong một phiên: cọc này nằm TRONG một chuỗi mẫu, nên một
     dấu huyền quanh tên hàm ở đây đóng chuỗi ngay tại chỗ. */
  rpc(ten, tham){ DA_RPC.push({ten, tham});
                  return Promise.resolve(TRA_RPC.shift() || {data: null, error: null}); },
  from: (bang) => ({
  select(cot){
    const nut = {
      eq(c, v){ DA_DOC.push({bang, cot, id: v}); return nut; },
      in(c, ds){ DA_DOC.push({bang, cot, ids: ds}); return Promise.resolve(TRA_DOC.shift()); },
      single: async () => TRA_DOC.shift(),
      maybeSingle: async () => TRA_DOC.shift() || {data: null, error: null}
    };
    return nut;
  },
  update(o){
    return {eq: async (c, id) => { DA_GHI.push({bang, phep: 'update', id, patch: o});
                                   return TRA_GHI.shift() || {error: null}; }};
  },
  upsert(dong, opt){ DA_GHI.push({bang, phep: 'upsert', dong, opt});
                     return Promise.resolve(TRA_GHI.shift() || {error: null}); },
  /* Ghi MỘT lần lúc gọi delete, không ghi ở mỗi eq — câu thật xâu hai eq
     (lich_id rồi ngay_goc), nên đếm theo eq là một cú xoá hoá ra hai.
     ⚠️ Cọc này nằm TRONG một chuỗi mẫu: đừng đặt dấu huyền quanh tên hàm ở đây,
     nó đóng chuỗi ngay tại chỗ. Cùng cái bẫy đã cắn ba lần trong index.html. */
  delete(){ const dieu = [];
            const nut = {eq(c, v){ dieu.push(c + '=' + v); return nut; },
                         then(f){ return Promise.resolve(TRA_GHI.shift() || {error: null}).then(f); }};
            DA_GHI.push({bang, phep: 'delete', dieu});
            return nut; }
})};
`;

const boi = {};
require('vm').createContext(boi);
boi.globalThis = boi;
require('vm').runInContext(COC + NGUON, boi);
const chay = ma => require('vm').runInContext(ma, boi);

let so = 0, hong = 0;
function ok(ten, thay, mong){
  so++;
  const a = JSON.stringify(thay), b = JSON.stringify(mong);
  if (a === b) console.log('✅ ' + ten);
  else { hong++; console.log('❌ ' + ten + '\n   mong : ' + b + '\n   thấy : ' + a); }
}
function dungLai(){ chay('TRA_DOC=[]; TRA_GHI=[]; DA_DOC=[]; DA_GHI=[]; TOAST=[]; LAM_MOI=0; '
  + 'HT_NGAN=[]; TV_TIM=null; TL_KHO_DS=[]; TK_TASKS=[]; '
  + 'THEO_VIEC=[]; THEO_CHUOI=[]; VE_TIMELINE=0; LC_HIEN=null; '
  + 'CO_NOI_CHUOI=null; DA_RPC=[]; TRA_RPC=[];'); }

(async () => {

console.log('\n── ① htChupTheo: chụp đúng cột patch sắp đụng ──');
dungLai();
chay("TRA_DOC=[{data:{ngay:'2026-09-01', so_lan_hoan:3}, error:null}]");
await chay("(async()=>{ globalThis.R = await htChupTheo(7, {ngay:'2026-09-07', so_lan_hoan:0}, 'x'); })()");
ok('select hỏi ĐÚNG hai cột của patch, không hơn', chay('DA_DOC[0].cot'), 'ngay,so_lan_hoan');
ok('bản chụp giữ giá trị CŨ của cả hai cột',
   chay('R.dong[0].truoc'), {ngay: '2026-09-01', so_lan_hoan: 3});
ok('một khuôn cho mọi cú: {moTa, dong:[…]}', chay('[!!R.moTa, R.dong.length]'), [true, 1]);

console.log('\n── ② Chụp hụt thì KHÔNG hứa ──');
dungLai();
chay("TRA_DOC=[{data:null, error:{message:'rớt mạng'}}]");
await chay("(async()=>{ globalThis.R = await htChupTheo(7, {ngay:'x'}, 'x'); })()");
ok('select hỏng → trả null', chay('R'), null);
await chay("(async()=>{ globalThis.R = await htChupTheo(7, {}, 'x'); })()");
ok('patch rỗng → trả null, không hỏi máy chủ', [chay('R'), chay('DA_DOC.length')], [null, 1]);
ok('không hứa thì cũng không có nút', chay('htNhan(null)'), undefined);
ok('… và ngăn vẫn rỗng', chay('HT_NGAN.length'), 0);

console.log('\n── ③ deadline không nhận null (schema: not null default "") ──');
dungLai();
chay("TRA_DOC=[{data:{deadline:null, ngay:'2026-09-01'}, error:null}]");
await chay("(async()=>{ globalThis.R = await htChupTheo(7, {deadline:'', ngay:'x'}, 'x'); })()");
ok('null của deadline thành chuỗi rỗng', chay('R.dong[0].truoc.deadline'), '');
ok('cột khác vẫn được giữ null nguyên nghĩa nếu vốn null', chay('R.dong[0].truoc.ngay'), '2026-09-01');

console.log('\n── ④ htChupNhieu: mỗi dòng giữ giá trị cũ RIÊNG của nó ──');
dungLai();
chay("TRA_DOC=[{data:[{id:1,ngay:'2026-08-30'},{id:2,ngay:'2026-09-02'}], error:null}]");
await chay("(async()=>{ globalThis.R = await htChupNhieu([1,2], {ngay:'2026-09-07'}, '2 việc'); })()");
ok('select kèm cột id để biết dòng nào của ai', chay('DA_DOC[0].cot'), 'id,ngay');
ok('hai dòng, hai ngày cũ khác nhau',
   chay('R.dong.map(d => d.id + "@" + d.truoc.ngay)'), ['1@2026-08-30', '2@2026-09-02']);

console.log('\n── ⑤ htChupNhieu: hụt một phần vẫn hứa, trắng tay thì không ──');
dungLai();
chay("TRA_DOC=[{data:[{id:1,ngay:'2026-08-30'}], error:null}]");
await chay("(async()=>{ globalThis.R = await htChupNhieu([1,2,3], {ngay:'x'}, 'x'); })()");
ok('xin 3 chụp được 1 → vẫn hứa đúng 1 dòng', chay('R.dong.length'), 1);
chay("TRA_DOC=[{data:[], error:null}]");
await chay("(async()=>{ globalThis.R = await htChupNhieu([1,2], {ngay:'x'}, 'x'); })()");
ok('chụp trắng tay → null, không hứa', chay('R'), null);

console.log('\n── ⑥ hoanTac: lùi từng dòng bằng giá trị riêng của dòng ấy ──');
dungLai();
chay("HT_NGAN=[{moTa:'2 việc về hôm nay', dong:[{id:1,truoc:{ngay:'2026-08-30'}},{id:2,truoc:{ngay:'2026-09-02'}}]}]");
await chay('hoanTac()');
ok('hai câu ghi, mỗi câu một giá trị',
   chay('DA_GHI.map(g => g.id + "→" + g.patch.ngay)'), ['1→2026-08-30', '2→2026-09-02']);
ok('ngăn rỗng sau khi lùi trót lọt', chay('HT_NGAN.length'), 0);
ok('vẽ lại màn đúng một lượt', chay('LAM_MOI'), 1);
ok('nói ra cái vừa lùi', chay('TOAST[0].m'), '↩️ Đã hoàn tác: 2 việc về hôm nay');

console.log('\n── ⑦ hoanTac: lùi hụt một phần ──');
dungLai();
chay("TRA_GHI=[{error:null},{error:{message:'rớt mạng'}}]");
chay("HT_NGAN=[{moTa:'2 việc', dong:[{id:1,truoc:{ngay:'a'}},{id:2,truoc:{ngay:'b'}}]}]");
await chay('hoanTac()');
ok('chỉ phần CHƯA lùi trở về ngăn', chay('HT_NGAN[0].dong.map(d => d.id)'), [2]);
ok('câu báo đếm đúng phần còn sót', chay('TOAST[0].m'), '⚠️ Chưa hoàn tác được 1/2 việc: rớt mạng');
ok('có dòng đã lùi thì vẫn vẽ lại màn', chay('LAM_MOI'), 1);

console.log('\n── ⑧ hoanTac: hỏng sạch thì đừng vẽ lại màn ──');
dungLai();
chay("TRA_GHI=[{error:{message:'rớt mạng'}}]");
chay("HT_NGAN=[{moTa:'1 việc', dong:[{id:1,truoc:{ngay:'a'}}]}]");
await chay('hoanTac()');
ok('cú ấy nằm nguyên trong ngăn, bấm lại được', chay('HT_NGAN[0].dong.length'), 1);
ok('máy chủ y nguyên → không tải lại làm gì', chay('LAM_MOI'), 0);
dungLai();
await chay('hoanTac()');
ok('ngăn rỗng → nói ra, không ghi gì', [chay('TOAST[0].m'), chay('DA_GHI.length')],
   ['Không còn gì để hoàn tác.', 0]);

console.log('\n── ⑨ Ngăn nhớ mười cú, cú cũ nhất rụng trước ──');
dungLai();
chay("for (let i=1; i<=12; i++) htNhan({moTa:'cú '+i, dong:[{id:i, truoc:{ngay:'a'}}]});");
ok('trần 10', chay('HT_NGAN.length'), 10);
ok('cú cũ nhất còn lại là cú thứ 3', chay('HT_NGAN[0].moTa'), 'cú 3');
ok('bấm một cái là lùi cú MỚI nhất', chay('HT_NGAN[HT_NGAN.length-1].moTa'), 'cú 12');

console.log('\n── ⑩ htTimTask hỏi tvTim khi ba kho dải lịch không có ──');
dungLai();
chay("TV_TIM = {id: 9, noi_dung: 'Việc ở tab Cam kết'};");
ok('không có trong kho dải lịch thì hỏi tiếp tvTim',
   chay('(htTimTask(9) || {}).noi_dung'), 'Việc ở tab Cam kết');
chay("TL_KHO_DS = [{id: 9, noi_dung: 'Bản của dải lịch'}];");
ok('có trong kho dải lịch thì lấy bản ĐANG VẼ trên màn, không hỏi tvTim',
   chay('htTimTask(9).noi_dung'), 'Bản của dải lịch');

console.log('\n── ⑪ htChup cũ (kéo-thả) vẫn ra đúng khuôn mới ──');
dungLai();
chay("TL_KHO_DS = [{id: 4, ngay: '2026-09-01', deadline: null, gio_start: '09:00'}];");
ok('chụp từ bản trong máy, không hỏi máy chủ một lượt nào',
   [chay("(htChup(4,'x') || {}).dong.length"), chay('DA_DOC.length')], [1, 0]);
ok('deadline null cũng được vá ở đây', chay("htChup(4,'x').dong[0].truoc.deadline"), '');
ok('không tìm thấy dòng việc → không hứa', chay("htChup(999,'x')"), null);

console.log('\n── ⑫ Cú mang CÁCH LÙI RIÊNG (TRI-157) ──');
dungLai();
chay("globalThis.DA_LUI = 0; HT_NGAN=[{moTa:'giờ của «Họp tuần»', lam: async () => { DA_LUI++; }}];");
await chay('hoanTac()');
ok('gọi cách lùi của chính cú ấy, không ghi thẳng vào bảng task',
   [chay('DA_LUI'), chay('DA_GHI.length')], [1, 0]);
ok('vẽ lại CẢ lưới lịch lẫn bảng Hôm nay', [chay('VE_TIMELINE'), chay('LAM_MOI')], [1, 1]);
ok('nói ra cái vừa lùi', chay('TOAST[0].m'), '↩️ Đã hoàn tác: giờ của «Họp tuần»');

dungLai();
chay("HT_NGAN=[{moTa:'x', lam: async () => ({error:{message:'rớt mạng'}})}];");
await chay('hoanTac()');
ok('lùi hỏng → cú trở về ngăn, bấm lại được', chay('HT_NGAN.length'), 1);
ok('… và không vẽ lại gì', [chay('VE_TIMELINE'), chay('LAM_MOI')], [0, 0]);

console.log('\n── ⑬ lcChupBuoi: buổi CHƯA từng dời riêng → lùi là XOÁ dòng ──');
dungLai();
chay("TRA_DOC=[{data:null, error:null}]");
await chay("(async()=>{ globalThis.LUI = await lcChupBuoi(7, '2026-09-01'); })()");
await chay('LUI()');
ok('xoá đúng dòng ngoại lệ vừa đẻ',
   chay("DA_GHI.map(g => g.bang + ':' + g.phep)"), ['lich_chung_ngoai_le:delete']);

console.log('\n── ⑭ lcChupBuoi: buổi ĐÃ dời riêng từ trước → lùi về LẦN DỜI TRƯỚC ──');
dungLai();
chay("TRA_DOC=[{data:{lich_id:7, ngay_goc:'2026-09-01', kieu:'doi', gio_moi:600, so_phut_moi:45}, error:null}]");
await chay("(async()=>{ globalThis.LUI = await lcChupBuoi(7, '2026-09-01'); })()");
await chay('LUI()');
ok('trả lại dòng cũ, KHÔNG xoá — lùi đúng một cú, không lùi luôn quyết định cũ',
   chay("DA_GHI[0].phep + ':' + DA_GHI[0].dong.gio_moi"), 'upsert:600');

console.log('\n── ⑮ lcChupDoi: nhánh «từ đây trở đi» KHÔNG hứa ──');
dungLai();
chay("globalThis.L = {id:7, ten:'Họp tuần', lap:'tuan', gio_bat_dau:540, so_phut:60};");
await chay("(async()=>{ globalThis.R = await lcChupDoi('tu_day', {lich:7, goc:'2026-09-01'}, L); })()");
ok('trả null, và không hỏi máy chủ một lượt nào', [chay('R'), chay('DA_DOC.length')], [null, 0]);
await chay("(async()=>{ globalThis.R = await lcChupDoi('buoi', {lich:7, goc:'x'}, null); })()");
ok('không tìm thấy sự kiện → cũng không hứa', chay('R'), null);

console.log('\n── ⑯ lcChupDoi «buổi này»: lùi kéo việc về bằng giá trị CŨ ──');
dungLai();
chay("globalThis.L = {id:7, ten:'Họp tuần', lap:'tuan', gio_bat_dau:540, so_phut:60};");
chay("TRA_DOC=[{data:null, error:null}]");
await chay("(async()=>{ globalThis.R = await lcChupDoi('buoi', {lich:7, goc:'2026-09-01'}, L); })()");
ok('mô tả nói rõ buổi nào của sự kiện nào', chay('R.moTa'), 'buổi 2026-09-01 của «Họp tuần»');
await chay('R.lam()');
ok('một buổi lẻ đi đường lcTheoViec, không đụng cả chuỗi',
   [chay('THEO_VIEC.length'), chay('THEO_CHUOI.length')], [1, 0]);
ok('việc về đúng GIỜ CŨ của buổi ấy, chụp trước cú kéo',
   chay('THEO_VIEC[0].luot'), {ngay: '2026-09-01', tu: 540, den: 600, phut: 60});

console.log('\n── ⑰ lcChupDoi «tất cả» trên chuỗi định kỳ ──');
dungLai();
chay("globalThis.L = {id:7, ten:'Họp tuần', lap:'tuan', gio_bat_dau:540, so_phut:60};");
chay("TRA_DOC=[{data:{gio_bat_dau:540, so_phut:60, ngay_bat_dau:'2026-08-01', ngay_ket_thuc:null}, error:null}]");
await chay("(async()=>{ globalThis.R = await lcChupDoi('tat_ca', {lich:7, goc:'2026-09-01'}, L); })()");
ok('chụp đúng bốn cột mà nhánh ấy ghi', chay('DA_DOC[0].cot'),
   'gio_bat_dau,so_phut,ngay_bat_dau,ngay_ket_thuc');
await chay('R.lam()');
ok('trả bốn cột cũ về dòng chuỗi',
   chay("[DA_GHI[0].bang, DA_GHI[0].patch.gio_bat_dau, DA_GHI[0].patch.so_phut]"),
   ['lich_chung', 540, 60]);
ok('sua_luc đặt MỚI, không trả về mốc cũ — cú lùi cũng là một lần sửa',
   chay("typeof DA_GHI[0].patch.sua_luc === 'string' && DA_GHI[0].patch.sua_luc.length > 10"), true);
ok('cả chuỗi thì đi đường lcTheoChuoi, kéo việc của CẢ ĐỘI về giờ cũ',
   chay('THEO_CHUOI[0]'), {lichId: 7, tu: 540, den: 600, phut: 60});
ok('… và không gọi lẻ từng buổi', chay('THEO_VIEC.length'), 0);

console.log('\n── ⑱ lcChupSua: cửa sửa sự kiện (TRI-161) ──');
dungLai();
chay("globalThis.L = {id:7, ten:'Họp tuần'};");
chay("TRA_DOC=[{data:{ten:'Họp tuần', gio_bat_dau:540, so_phut:60, lap:'tuan'}, error:null}]");
await chay("(async()=>{ globalThis.R = await lcChupSua(7, {ten:'Họp team', gio_bat_dau:600, so_phut:90, lap:'tuan'}, L); })()");
ok('chụp ĐÚNG những cột biểu mẫu sắp ghi', chay('DA_DOC[0].cot'),
   'ten,gio_bat_dau,so_phut,lap');
await chay('R.lam()');
ok('trả cả bốn cột cũ về dòng sự kiện',
   chay("[DA_GHI[0].bang, DA_GHI[0].patch.ten, DA_GHI[0].patch.gio_bat_dau]"),
   ['lich_chung', 'Họp tuần', 540]);
ok('sua_luc đặt mới, không trả về mốc cũ',
   chay("typeof DA_GHI[0].patch.sua_luc === 'string'"), true);
ok('việc đã đẻ về theo GIỜ CŨ', chay('THEO_CHUOI[0]'), {lichId: 7, tu: 540, den: 600, phut: 60});

dungLai();
chay("globalThis.L = {id:7, ten:'Họp tuần'};");
chay("TRA_DOC=[{data:{ten:'Họp team'}, error:null}]");
await chay("(async()=>{ globalThis.R = await lcChupSua(7, {ten:'Họp team'}, L); })()");
await chay('R.lam()');
ok('bản chụp thiếu cột giờ → BỎ lượt kéo việc, không tính giờ từ undefined',
   chay('THEO_CHUOI.length'), 0);
await chay("(async()=>{ globalThis.R = await lcChupSua(7, {}, L); })()");
ok('không có cột nào để ghi → không hứa', chay('R'), null);

console.log('\n── ⑲ Chia chuỗi: chưa chạy tệp SQL thì NÚT VẮNG MẶT ──');
dungLai();
chay("TRA_RPC=[{data:null, error:{code:'PGRST202', message:'function noi_chuoi_lich does not exist'}}]");
await chay("(async()=>{ globalThis.R = await lcCuChia(7, 9, {ngay_ket_thuc:'2026-08-31', ten:'Họp tuần'}); })()");
ok('không hứa', chay('R'), null);
ok('dò bằng LƯỢT GỌI RỖNG, không thêm câu hỏi nào',
   chay("[DA_RPC.length, DA_RPC[0].ten, DA_RPC[0].tham.p_lich_cu]"), [1, 'noi_chuoi_lich', null]);
await chay("(async()=>{ globalThis.R = await lcCuChia(7, 9, {ngay_ket_thuc:'x', ten:'y'}); })()");
ok('nhớ luôn là chưa có — không dò lại ở mọi cú chia sau', chay('DA_RPC.length'), 1);

console.log('\n── ⑳ Chia chuỗi: đã chạy SQL thì lùi bằng noi_chuoi_lich ──');
dungLai();
chay("TRA_RPC=[{data:null, error:null}]");                    // lượt dò trót lọt
chay("TRA_DOC=[{data:{sua_luc:'2026-09-07T10:00:00Z'}, error:null}]");
await chay("(async()=>{ globalThis.R = await lcCuChia(7, 9, {ngay_ket_thuc:'2026-08-31', ten:'Họp tuần'}); })()");
ok('mô tả nói rõ đây là cú chia chuỗi', chay('R.moTa'), 'cú chia chuỗi «Họp tuần»');
ok('có hỏi dấu sửa của NỬA SAU để làm hàng rào', chay('DA_DOC[0].cot'), 'sua_luc');
await chay('R.lam()');
ok('lùi bằng noi_chuoi_lich, đủ bốn tham số',
   chay('DA_RPC[DA_RPC.length-1].tham'),
   {p_lich_cu: 7, p_lich_moi: 9, p_ngay_ket_thuc_cu: '2026-08-31',
    p_sua_luc: '2026-09-07T10:00:00Z'});

console.log('\n── ㉑ lcChupTruocChia: điểm dừng cũ phải chụp TRƯỚC cú chia ──');
dungLai();
chay("TRA_DOC=[{data:{ngay_ket_thuc:null, ten:'Họp tuần'}, error:null}]");
await chay("(async()=>{ globalThis.R = await lcChupTruocChia(7); })()");
ok('đọc đúng hai thứ cần cho cú lùi', chay('DA_DOC[0].cot'), 'ngay_ket_thuc,ten');
ok('chuỗi vô hạn thì điểm dừng cũ là null, giữ nguyên null', chay('R.ngay_ket_thuc'), null);
dungLai();
chay("TRA_DOC=[{data:null, error:{message:'rớt mạng'}}]");
await chay("(async()=>{ globalThis.R = await lcChupTruocChia(7); })()");
ok('đọc hỏng → không hứa', chay('R'), null);

console.log('\n── ㉒ Tệp nang-cap-noi-chuoi-lich.sql ──');
/* Bộ tự kiểm nằm CUỐI tệp SQL chỉ chạy khi Tracy chạy tệp. Mấy ca dưới đây soi
   chính văn bản tệp, nên chúng bắt được một lần sửa hỏng NGAY trong bộ thử —
   trước lúc tệp được gửi đi. */
{
  const SQL = fs.readFileSync(path.join(__dirname, 'nang-cap-noi-chuoi-lich.sql'), 'utf8');
  const iChuyen = SQL.indexOf('update lich_chung_ngoai_le set lich_id = p_lich_cu');
  const iXoa    = SQL.indexOf('delete from lich_chung where id = p_lich_moi');
  ok('THỨ TỰ: câu xoá nửa sau đứng SAU câu chuyển bảng con — đảo lại là cascade cuốn mất dữ liệu',
     iChuyen > 0 && iXoa > iChuyen, true);
  ok('tự kiểm quyền host, và KHÔNG nới cho lead',
     /v_cu\.tao_boi = v_toi/.test(SQL) && !/la_lead\(\)/.test(SQL.split('-- ─── TỰ KIỂM')[0]), true);
  ok('có hàng rào sua_luc — nửa sau bị sửa tiếp thì từ chối nối',
     /p_sua_luc is not null and v_moi\.sua_luc is distinct from p_sua_luc/.test(SQL), true);
  ok('lượt dò rẻ và vô hại', /if p_lich_cu is null then return null; end if;/.test(SQL), true);
  ok('người đăng nhập gọi được', /grant execute on function noi_chuoi_lich/.test(SQL), true);
  ok('bộ tự kiểm đứng CUỐI tệp — Supabase chỉ bày kết quả câu lệnh cuối',
     SQL.lastIndexOf('-- ─── TỰ KIỂM') > SQL.lastIndexOf('create or replace function'), true);
  ok('ba bảng con tới sau bảng lịch đều hỏi danh mục trước khi chạm',
     (SQL.match(/to_regclass\('public\./g) || []).length, 3);
}

console.log('\n' + (hong ? `❌ ${hong}/${so} ca chưa đạt` : `✅ ${so}/${so} đạt`));
process.exit(hong ? 1 : 0);
})();
