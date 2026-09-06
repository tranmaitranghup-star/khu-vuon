/* THỬ: MÀN TEAM — cơ cấu tổ chức, nhân sự và quyền  (TRI-124 · làn TMS · 05/09/2026)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 05/09: *"nhân sự thì sẽ có thể thường xuyên thay đổi nên tôi muốn trên
   app có tính năng sắp xếp cơ cấu tổ chức, dành cho tôi và Andy"* — đổi tên ·
   thêm tài khoản · đặt phòng ban và quyền hạn, cộng bốn ô cá nhân.

   Bài thử CHẠY THẬT khối mã của màn trong một cốc, không chỉ so chuỗi. Bộ tự
   kiểm 9 mục của phần máy chủ nằm trong chính nang-cap-co-cau-to-chuc.sql.

   Năm ca đáng giá nhất — cả năm đều là cách hỏng IM LẶNG:

     ① NGƯỜI MỚI KHÔNG ĐƯỢC THÀNH LEAD. Cột `la_lead` trên máy chủ mặc định
        `true` cho tới 05/09 vì nó được khai hai lần ở hai tệp với hai mặc định
        ngược nhau. Tracy đã nói nhiều lần rằng năm người vào sau là nhân sự;
        điều ấy vẫn tái diễn được vì lỗi nằm ở một cái mặc định, không ở trí
        nhớ ai. App phải ghi THẲNG `false`, đừng tin vào mặc định.

     ② KHÔNG TỰ GỠ QUYỀN CỦA CHÍNH MÌNH. Ô tick bị khoá nên không đọc được giá
        trị — đọc bừa là gửi lên một `false` vô tình, và người ấy tự khoá mình
        ra ngoài. Lối chữa lúc ấy chỉ còn là mở Supabase.

     ③ CẦU BẮC QUA KHOẢNG CHỜ. Mã lên sóng ngay khi đẩy, tệp SQL thì Tracy chạy
        tay sau đó. Giữa hai mốc ấy bốn cột mới chưa có, và gửi một cột chưa tồn
        tại là cả lượt ghi ngã ở chỗ người dùng không đọc được lý do.

     ④ KHÔNG QUYỀN THÌ KHÔNG CHIP NÀO. Một chip mà ai cũng đeo thì thôi mang
        tin, và nó xoá mất đúng thứ màn này sinh ra để cho thấy.

     ⑤ EMAIL PHẢI HẠ CHỮ THƯỜNG. `la_thanh_vien()` so chuỗi phân biệt hoa
        thường ở tầng máy chủ; app có `.toLowerCase()` bù ở tầng JS nhưng RLS
        thì không — một chữ hoa lọt vào là người ấy đọc được đúng không dòng nào.

   Chạy:  node production/tinh-thuc-app/thu-co-cau-to-chuc.js
*/
const fs   = require('fs');
const path = require('path');
const THU_MUC = __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(THU_MUC, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(THU_MUC, 'nang-cap-co-cau-to-chuc.sql'), 'utf8');
/* Bản BỎ CHÚ THÍCH. Câu "cố ý KHÔNG chạy update …" nằm trong một dòng `--` giải
   thích, nên soi trên bản đầy đủ là bài thử khớp vào chính lời giải thích rồi
   báo đỏ. Mọi ca hỏi "tệp này KHÔNG có gì" phải soi bản này. */
const SQL_MA = SQL.split('\n').filter(d => !d.trim().startsWith('--')).join('\n');

function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ══ CỐC — dựng đủ thứ khối mã cần, không hơn ═════════════════════════════ */
const NGUON = catKhoi('let TM_VIEW  =', 'function moTab(ten, vuaNap){');

const NGUOI = () => ([
  {id:'a', ten:'Andy',  ho_ten:'', email:'nguoi-05@vidu.com',  vai:'CEO',
   chuc_nang_ids:[1,4], la_lead:true, la_dieu_hanh:true,  la_quan_tri:true,
   thu_tu:1, leader_id:null, ngay_nghi:null, ngay_sinh:null, so_dien_thoai:''},
  {id:'t', ten:'Tracy', ho_ten:'Trần Mai Trang', email:'nguoi-17@vidu.com', vai:'Vận hành',
   chuc_nang_ids:[2,4], la_lead:true, la_dieu_hanh:true,  la_quan_tri:true,
   thu_tu:2, leader_id:'a', ngay_nghi:null, ngay_sinh:'1990-03-18', so_dien_thoai:'0912'},
  {id:'p', ten:'Peter', ho_ten:'', email:'nguoi-15@vidu.com', vai:'Lead Sales',
   chuc_nang_ids:[4], la_lead:true, la_dieu_hanh:false, la_quan_tri:false,
   thu_tu:3, leader_id:'a', ngay_nghi:null, ngay_sinh:null, so_dien_thoai:''},
  {id:'n', ten:'Andrew', ho_ten:'Trương Văn Tiến', email:'nguoi-04@vidu.com', vai:'Nhân sự',
   chuc_nang_ids:[], la_lead:false, la_dieu_hanh:false, la_quan_tri:false,
   thu_tu:4, leader_id:null, ngay_nghi:null, ngay_sinh:null, so_dien_thoai:''},
  {id:'x', ten:'Xưa',   ho_ten:'', email:'nguoi-20@vidu.com',   vai:'',
   chuc_nang_ids:[3], la_lead:false, la_dieu_hanh:false, la_quan_tri:false,
   thu_tu:5, leader_id:null, ngay_nghi:'2026-08-01', ngay_sinh:null, so_dien_thoai:''}
]);

function coc(opt = {}){
  const o = {};                       // ô DOM giả, tra theo id
  const oO = id => (o[id] ||= {id, value:'', checked:false, textContent:'',
                              innerHTML:'', classList:{
                                _s:new Set(),
                                add(c){this._s.add(c);}, remove(c){this._s.delete(c);},
                                toggle(c,v){ v===undefined ? (this._s.has(c)?this._s.delete(c):this._s.add(c))
                                                           : (v?this._s.add(c):this._s.delete(c)); },
                                contains(c){return this._s.has(c);}}});
  const ghi = [];                     // mọi lượt gọi máy chủ
  const nhac = [];                    // mọi câu toast
  const kb = {
    document:{ getElementById:oO, querySelectorAll:()=>[] },
    CHUC_NANG:[{id:1,ten:'Ban điều hành'},{id:2,ten:'Vận hành'},{id:3,ten:'Sản phẩm'},
               {id:4,ten:'Kinh doanh'},{id:5,ten:'Tài chính'},{id:6,ten:'Trải nghiệm KH'}],
    DOI:[], ME:opt.me || null,
    HINH_BUT:'<svg></svg>',
    chuSach:s=>String(s??'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;'),
    homNay:()=>'2026-09-05',
    toast:m=>nhac.push(m),
    hopHoiMo:()=>{}, hopHoiDong:()=>{},
    sb:{ from(){ return {
      select(){ return {order:async()=>({data:opt.ds || NGUOI(), error:null})}; },
      update(g){ ghi.push({loai:'update', g}); return {eq:async()=>({error:opt.loi||null})}; },
      insert:async g=>{ ghi.push({loai:'insert', g}); return {error:opt.loi||null}; }
    }; } },
    ghi, nhac, o
  };
  kb.globalThis = kb;
  const vm = require('vm');
  vm.createContext(kb);
  vm.runInContext(NGUON, kb);
  /* `let` ở đầu một script vm nằm trong NGĂN KHAI BÁO của script, không thành
     thuộc tính của đối tượng ngữ cảnh — gán thẳng từ ngoài là đặt ra một thuộc
     tính KHÁC mà mã bên trong không bao giờ đọc tới, và bài thử đỏ vì cốc của
     chính nó chứ không vì mã app. Phải gán bằng một câu lệnh chạy TRONG cùng
     ngữ cảnh. Hàm khai bằng `function` thì ngược lại: chúng CÓ thành thuộc
     tính, nên gọi thẳng `k.tmChips(...)` vẫn chạy. */
  kb.dat = (ten, val) => { kb.__tmp = val; vm.runInContext(ten + ' = __tmp', kb); };
  kb.doc = ten => vm.runInContext(ten, kb);
  return kb;
}

/* ══════════════════════════════════════════════════════════════════════════ */

console.log('\n① NGƯỜI MỚI KHÔNG ĐƯỢC THÀNH LEAD — ghi thẳng false, đừng tin mặc định');
{
  const k = coc({me:{id:'t', ten:'Tracy', la_quan_tri:true}});
  k.dat('TM_DS', NGUOI()); k.dat('TM_COT', new Set(Object.keys(NGUOI()[0]))); k.dat('TM_SUA', null); k.dat('TM_KHOI', [4]);
  k.o['tm-ten']   = {value:'Javis'};
  k.o['tm-email'] = {value:'nguoi-11@vidu.com'};
  ['tm-hoten','tm-sinh','tm-dt','tm-vai'].forEach(i => k.o[i] = {value:''});
  return_ = k.tmLuu();
  return_.then(() => {
    const g = k.ghi[0]?.g || {};
    la('lượt ghi là INSERT', k.ghi[0]?.loai === 'insert');
    la('la_lead ghi THẲNG false, không bỏ trống cho máy chủ đoán',
       g.la_lead === false, 'nhận được ' + JSON.stringify(g.la_lead));
    la('la_dieu_hanh và la_quan_tri cũng thẳng false',
       g.la_dieu_hanh === false && g.la_quan_tri === false);
    la('⑤ email hạ chữ thường trước khi gửi',
       g.email === 'nguoi-11@vidu.com', 'nhận được ' + g.email);
    la('thu_tu nối tiếp người cuối, không đè ai', g.thu_tu === 6, 'nhận được ' + g.thu_tu);
    la('khối đang chọn đi theo', JSON.stringify(g.chuc_nang_ids) === '[4]');
    ke2();
  });
}

function ke2(){
console.log('\n② KHÔNG TỰ GỠ QUYỀN QUẢN TRỊ CỦA CHÍNH MÌNH');
{
  const me = {id:'t', ten:'Tracy', la_quan_tri:true};
  const k = coc({me});
  k.dat('TM_DS', NGUOI());
  k.dat('TM_COT', new Set(Object.keys(NGUOI()[0])));
  k.dat('TM_SUA', k.doc('TM_DS').find(n => n.id === 't'));
  k.dat('TM_KHOI', [2,4]);
  k.o['tm-ten']   = {value:'Tracy'};
  k.o['tm-email'] = {value:'nguoi-17@vidu.com'};
  ['tm-hoten','tm-sinh','tm-dt','tm-vai','tm-cap'].forEach(i => k.o[i] = {value:''});
  /* Ô tick bị `disabled` nên trình duyệt vẫn trả `checked=false` nếu ai đó dựng
     lại DOM — đây đúng là cảnh phải chặn. */
  k.o['tm-lead'] = {checked:true}; k.o['tm-dh'] = {checked:true};
  k.o['tm-qt']   = {checked:false};
  k.tmLuu().then(() => {
    const g = k.ghi[0]?.g || {};
    la('sửa dòng của CHÍNH MÌNH thì la_quan_tri giữ nguyên bản cũ',
       g.la_quan_tri === true, 'nhận được ' + JSON.stringify(g.la_quan_tri));
    la('hai cờ kia vẫn đọc từ ô tick như thường',
       g.la_lead === true && g.la_dieu_hanh === true);
    ke2b();
  });
}
}

function ke2b(){
{
  const k = coc({me:{id:'t', ten:'Tracy', la_quan_tri:true}});
  k.dat('TM_DS', NGUOI());
  k.dat('TM_COT', new Set(Object.keys(NGUOI()[0])));
  k.dat('TM_SUA', k.doc('TM_DS').find(n => n.id === 'p'));   // sửa NGƯỜI KHÁC
  k.dat('TM_KHOI', [4]);
  k.o['tm-ten']   = {value:'Peter'};
  k.o['tm-email'] = {value:'nguoi-15@vidu.com'};
  ['tm-hoten','tm-sinh','tm-dt','tm-vai','tm-cap'].forEach(i => k.o[i] = {value:''});
  k.o['tm-lead'] = {checked:false}; k.o['tm-dh'] = {checked:false}; k.o['tm-qt'] = {checked:true};
  k.tmLuu().then(() => {
    const g = k.ghi[0]?.g || {};
    la('sửa người KHÁC thì ba cờ đều đọc từ ô tick — không khoá nhầm',
       g.la_quan_tri === true && g.la_lead === false);
    ke3();
  });
}
}

function ke3(){
console.log('\n③ CẦU BẮC QUA KHOẢNG CHỜ — máy chủ chưa có bốn cột mới');
{
  const cu = NGUOI().map(n => {
    const c = {...n};
    ['ho_ten','ngay_sinh','so_dien_thoai','ngay_nghi'].forEach(x => delete c[x]);
    return c;
  });
  const k = coc({me:{id:'t', ten:'Tracy', la_quan_tri:true}, ds:cu});
  k.dat('TM_DS', cu); k.dat('TM_COT', new Set(Object.keys(cu[0]))); k.dat('TM_SUA', null); k.dat('TM_KHOI', []);
  k.o['tm-ten']   = {value:'Ham'};
  k.o['tm-email'] = {value:'nguoi-09@vidu.com'};
  k.o['tm-hoten'] = {value:'Nguyễn Xuân Đại'};
  k.o['tm-sinh']  = {value:'1995-01-01'};
  k.o['tm-dt']    = {value:'0999'};
  k.o['tm-vai']   = {value:'Nhân sự'};
  k.tmLuu().then(() => {
    const g = k.ghi[0]?.g || {};
    la('bốn cột chưa có thì KHÔNG gửi lên — cả lượt ghi vẫn chạy',
       !('ho_ten' in g) && !('ngay_sinh' in g) && !('so_dien_thoai' in g),
       'gửi lên: ' + Object.keys(g).join(','));
    la('cột cũ vẫn đi bình thường', g.ten === 'Ham' && g.vai === 'Nhân sự');
    la('máy chủ CÓ cột thì chúng đi theo',
       (() => { const k2 = coc({me:{id:'t'}});
                k2.dat('TM_COT', new Set(Object.keys(NGUOI()[0])));
                return k2.tmLoc({ho_ten:'x', ten:'y'}).ho_ten === 'x'; })());
    ke4();
  });
}
}

function ke4(){
console.log('\n④ KHÔNG QUYỀN THÌ KHÔNG CHIP NÀO');
{
  const k = coc({me:{id:'t'}});
  const ds = NGUOI();
  la('người không quyền: chuỗi chip RỖNG, không có chip Thành viên',
     k.tmChips(ds.find(n => n.id === 'n')) === '',
     'nhận được: ' + k.tmChips(ds.find(n => n.id === 'n')));
  la('lead thường đúng một chip', k.tmChips(ds.find(n=>n.id==='p')) === '<span class="tm-q">Lead</span>');
  la('quản trị đủ ba chip, và chip Quản trị đi nền đặc',
     /tm-q qt">Quản trị/.test(k.tmChips(ds.find(n=>n.id==='t')))
     && (k.tmChips(ds.find(n=>n.id==='t')).match(/tm-q/g)||[]).length === 3);
}

console.log('\n⑥ HAI VIEW ĐẾM HAI KIỂU, VÀ CHÚNG PHẢI KHÔNG TRÙNG NHAU');
{
  const k = coc({me:{id:'t', ten:'Tracy'}});
  k.dat('TM_DS', NGUOI());
  k.dat('TM_VIEW', 'nhansu'); k.veTeam();
  const nsHtml = k.o['tm-khu'].innerHTML, nsDo = k.o['tm-do'].textContent;
  la('view Nhân sự: 4 người đang làm, mỗi người ĐÚNG một dòng',
     (nsHtml.match(/class="tm-ns"/g) || []).length === 4,
     'đếm được ' + (nsHtml.match(/class="tm-ns"/g)||[]).length);
  la('dòng đo của nó nói người · lead · quản trị',
     nsDo === '4 người · 3 lead · 2 quản trị', 'nhận được: ' + nsDo);
  la('người đã nghỉ KHÔNG nằm trong danh sách chính', !/>Xưa</.test(nsHtml.split('tm-nghi-nut')[0]));

  k.dat('TM_VIEW', 'phongban'); k.veTeam();
  const pbHtml = k.o['tm-khu'].innerHTML, pbDo = k.o['tm-do'].textContent;
  la('view Phòng ban: người ngồi hai khối hiện HAI lần — hình thật của cơ cấu',
     (pbHtml.match(/>Tracy</g) || []).length === 2,
     'Tracy hiện ' + (pbHtml.match(/>Tracy</g)||[]).length + ' lần');
  la('dòng đo của nó đếm CHỖ NGỒI, khác con số người',
     pbDo === '6 khối · 5 chỗ ngồi · 1 người chưa xếp khối', 'nhận được: ' + pbDo);
  la('khối chưa ai ngồi vẫn hiện, chỉ lùi màu',
     /tm-khoi-the trong/.test(pbHtml) && /Chưa ai ngồi khối này/.test(pbHtml));
  la('người chưa xếp khối gom thành một khối riêng ở cuối',
     pbHtml.lastIndexOf('Chưa xếp khối') > pbHtml.indexOf('Trải nghiệm KH'));
}

console.log('\n⑦ CHẶN Ở CỬA VÀO — thiếu ô bắt buộc thì KHÔNG gọi máy chủ');
{
  const k = coc({me:{id:'t'}});
  k.dat('TM_DS', NGUOI()); k.dat('TM_COT', new Set(Object.keys(NGUOI()[0]))); k.dat('TM_SUA', null); k.dat('TM_KHOI', []);
  k.o['tm-ten'] = {value:'  '}; k.o['tm-email'] = {value:'nguoi-03@vidu.com'};
  ['tm-hoten','tm-sinh','tm-dt','tm-vai'].forEach(i => k.o[i] = {value:''});
  k.tmLuu().then(() => {
    la('thiếu tên: không lượt ghi nào, và có nói ra', k.ghi.length === 0 && k.nhac.length === 1);
    const k2 = coc({me:{id:'t'}});
    k2.dat('TM_DS', NGUOI()); k2.dat('TM_COT', new Set(Object.keys(NGUOI()[0]))); k2.dat('TM_SUA', null); k2.dat('TM_KHOI', []);
    k2.o['tm-ten'] = {value:'Ai đó'}; k2.o['tm-email'] = {value:'   '};
    ['tm-hoten','tm-sinh','tm-dt','tm-vai'].forEach(i => k2.o[i] = {value:''});
    k2.tmLuu().then(() => {
      la('thiếu email: cũng không gọi máy chủ', k2.ghi.length === 0);
      ke8();
    });
  });
}
}

function ke8(){
console.log('\n⑧ CHO NGHỈ, KHÔNG XOÁ');
{
  const k = coc({me:{id:'t', ten:'Tracy', la_quan_tri:true}});
  k.dat('TM_DS', NGUOI()); k.dat('TM_COT', new Set(Object.keys(NGUOI()[0])));
  k.dat('TM_SUA', k.doc('TM_DS').find(n => n.id === 'p'));
  k.tmChoNghi().then(() => {
    la('cho nghỉ là một lượt UPDATE điền ngay_nghi, không phải xoá',
       k.ghi[0]?.loai === 'update' && k.ghi[0]?.g.ngay_nghi === '2026-09-05');
    la('app KHÔNG có đường nào gọi .delete() trên bảng nguoi',
       !/from\('nguoi'\)[\s\S]{0,80}\.delete\(/.test(SRC));
    la('nhận lại được: cùng cột ấy về null',
       (() => { const k2 = coc({me:{id:'t'}});
                k2.dat('TM_DS', NGUOI()); k2.dat('TM_COT', new Set(Object.keys(NGUOI()[0])));
                k2.dat('TM_SUA', k2.doc('TM_DS').find(n => n.id === 'x'));
                k2.tmMoLaiNghi();
                return k2.ghi[0]?.g.ngay_nghi === null; })());
    ke9();
  });
}
}

function ke9(){
console.log('\n⑨ HAI CHỖ NHỎ DỄ CẮN NGƯỜI');
{
  const k = coc({me:{id:'t'}});
  la('tmNgay cắt thẳng từ chuỗi ISO, không dựng Date (múi giờ lệch một ngày)',
     k.tmNgay('2026-08-01') === '01/08/2026' && k.tmNgay(null) === '');
  k.dat('TM_DS', NGUOI()); k.dat('TM_KHOI', []);
  const ruot = k.tmRuot(k.doc('TM_DS').find(n => n.id === 't'));
  la('ô chọn cấp trên KHÔNG bày chính người đang sửa — một vòng lặp không lối ra',
     !/value="t"/.test(ruot), 'ruột có value="t"');
  la('và cũng không bày người đã nghỉ', !/value="x"/.test(ruot));
  la('sửa CHÍNH MÌNH thì ô tick Quản trị bị khoá',
     /id="tm-qt"[^>]*disabled/.test(k.tmRuot(k.doc('TM_DS').find(n => n.id === 't'))));
  la('sửa người khác thì không khoá',
     !/id="tm-qt"[^>]*disabled/.test(k.tmRuot(k.doc('TM_DS').find(n => n.id === 'p'))));
  la('cửa THÊM không bày ô quyền nào cả — người mới vào không mang quyền',
     !/id="tm-qt"/.test(k.tmRuot(null)) && !/id="tm-lead"/.test(k.tmRuot(null)));
  la('cửa THÊM đánh dấu * đúng hai ô bắt buộc',
     (k.tmRuot(null).match(/ \*<\/label>/g) || []).length === 2);
}

console.log('\n⑩ NỐI VÀO APP — ba mối, thiếu mối nào cũng là màn câm');
{
  la('bảng NUT_LE có nút Team mang cờ chiQuanTri',
     /id:'nut-tm'[^}]*chiQuanTri:true/.test(SRC));
  la('veThanhLe giấu nút ấy với người không phải quản trị',
     /chiQuanTri\) b\.style\.display = ME\?\.la_quan_tri/.test(SRC));
  la('moTab nạp lại màn mỗi lần mở', /if \(ten==='team'\) tmTai\(\);/.test(SRC));
  la('màn và cửa đều có mặt trong trang',
     /id="man-team"/.test(SRC) && /id="tm-cua"/.test(SRC));
  la('hình biểu tượng team khác hình nguoi (một người)',
     /team:\s+svg\(/.test(SRC) && (SRC.match(/circle cx="9\.6"/g)||[]).length === 1);
}

console.log('\n⑪ TỆP SQL — bốn hàng rào, và một cái mặc định phải lật');
{
  la('bốn cột mới',
     ['ho_ten','ngay_sinh','so_dien_thoai','ngay_nghi'].every(c =>
       new RegExp('add column if not exists ' + c).test(SQL)));
  /* Ca quan trọng nhất cả tệp: không lật thì người thứ tám vào app tự thành lead. */
  la('① mặc định la_lead lật xuống false',
     /alter column la_lead set default false/.test(SQL));
  la('CỐ Ý không chạy update hạ cờ của bảy người đang có',
     !/update nguoi set la_lead\s*=\s*false/.test(SQL_MA));
  la('hai policy ghi, cả hai gác bằng la_quan_tri_dang_nhap()',
     /create policy them_nguoi on nguoi for insert/.test(SQL)
     && /create policy sua_nguoi on nguoi for update/.test(SQL)
     && (SQL.match(/la_quan_tri_dang_nhap\(\)/g) || []).length >= 3);
  la('④ KHÔNG có policy xoá — thiếu nó chính là hàng rào',
     !/create policy [a-z_]* on nguoi for delete/.test(SQL_MA));
  la('② cò giữ hai cột của chính mình khỏi tay chính mình',
     /new\.la_quan_tri := old\.la_quan_tri/.test(SQL)
     && /new\.ngay_nghi\s+:= old\.ngay_nghi/.test(SQL));
  la('③ cò chặn team trống quản trị, chạy ở tầng CÂU LỆNH',
     /for each statement execute function chan_trong_quan_tri/.test(SQL));
  la('cả hai cò chừa đường cho SQL Editor — lối chữa cháy cuối cùng',
     (SQL.match(/if email_dang_nhap\(\) = ''/g) || []).length === 2);
  la('la_thanh_vien nay soi cả ngay_nghi — đóng cửa vào ở mọi bảng cùng lúc',
     /create or replace function la_thanh_vien\(\)[\s\S]{0,400}ngay_nghi is null/.test(SQL));
  la('bộ tự kiểm đứng CUỐI, dòng chưa đạt nổi lên đầu',
     SQL.indexOf('SỐ LIỆU THAM KHẢO') < SQL.indexOf('as t(so, muc, dat)')
     && /order by dat, so;/.test(SQL));
}

console.log('\n' + (truot ? `❌ ${truot} ca TRƯỢT · ${dat} đạt` : `✅ ${dat} ca đạt.`) + '\n');
process.exit(truot ? 1 : 0);
}
