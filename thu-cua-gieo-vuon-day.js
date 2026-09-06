/* ═══════════════════════════════════════════════════════════════════════════
   BỘ THỬ CỬA TẠO CAM KẾT KHI VƯỜN ĐÃ ĐẦY  (27/08)
   Chạy:  node thu-cua-gieo-vuon-day.js   (đứng ở thư mục production/tinh-thuc-app)

   Canh đúng ba chỗ vừa vá sau đợt soi 27/08:

   ① CỬA GIEO TRONG MILESTONE khi vườn hết chỗ. Bản đầu cố ý không gửi `luong`
      để cam kết "rơi vào kho" — nhưng ràng buộc `luong_rong_chi_khi_cho_nhan`
      chỉ mở kho cho dòng CÓ LỜI GIAO đang chờ trả lời, nên dòng tự viết bị đá
      về bằng lỗi 23514 và người dùng ăn một câu lỗi Postgres tiếng Anh. Nay
      chặn ở cửa. Bộ thử canh cả ca mạng hỏng — nó KHÁC ca vườn đầy.

   ② Ô ĐẾM "CHỜ BẠN" phải đếm số dòng THẬT SỰ VẼ RA. Một `loai` mới ở máy chủ
      mà app chưa biết thì khối này từng bật lên với một con số và danh sách
      trống rỗng, không cách nào làm con số về 0.

   ③ MẪU SỐ CỦA CỘT MILESTONE bỏ thẻ luống rỗng, khớp cách khung nhìn
      `danh_muc_du_an` đếm — nếu không, hai con số cạnh nhau nói hai chuyện
      khác nhau về cùng một dự án.

   Không cần đăng nhập, không đụng máy chủ thật.
   ═══════════════════════════════════════════════════════════════════════════ */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const lat = (a, b) => { const i = s.indexOf(a); if (i < 0) throw new Error('không thấy: '+a);
                        return s.slice(i, s.indexOf(b, i)); };
const nguon = [
  lat('async function duChoTrong(){', '\nasync function duGieoGhi'),
  lat('async function duGieoGhi(){',  '\n/* ── CÁCH NHÌN 2'),
  lat('function veChoBan(kq){',       '\nfunction choBanMo('),
  lat('function duNacCk(o){',         '\nconst DU_NAC_CHU'),
  lat('function duVeCot(m, ds, dsMoc, laChu){', '\n/* ⚠️ BỘ LỌC QUYỀN'),
  /* Cắt mã thật chứ không cọc: hàm này quyết việc nào thuộc mốc nào, đúng
     thứ mấy ca dưới đang đo. Nó là một `const` mũi tên nên mốc cắt lấy từ
     dòng khai tới dòng khai kế tiếp. */
  lat('const duViecCuaMoc = mocId =>', '\nlet DU_MOC_SUA'),
].join('\n');

const O = {};
const the = id => (O[id] = O[id] || {id, textContent:'', innerHTML:'', value:'', style:{},
  classList:{add(){}, remove(){}, contains(){ return false }}, focus(){}});
global.document = {getElementById: the};

let GHI = [], TOAST = [], LOI_MANG = false, DANG = [];
const ME = {id:'toi', so_cam_ket_toi_da:3};
const LOAI = {1:{qua:'🍎',mau:'#a',ten:'Cây táo'},2:{qua:'🍊',mau:'#b',ten:'Cây cam'},
              3:{qua:'🍇',mau:'#c',ten:'Giàn nho'}};
const TRAN_MAC_DINH=3, TRAN_TOI_DA=5;
const tranCamKet = ng => { const v=Number(ng&&ng.so_cam_ket_toi_da); return v>=1&&v<=TRAN_TOI_DA?v:TRAN_MAC_DINH; };
const oCamKet = ng => Array.from({length:tranCamKet(ng)},(_,i)=>i+1);
const homNay = () => '2026-08-27';
const toast = m => { TOAST.push(m); };
const chuSach = x => String(x??'');
const duTenNguoi = id => 'Andy';
const duNgayChu = d => d;
const duVeCkThe = () => '<ck>';
const baoLoiLuong = e => '⚠️ ' + (e.message||'');
const duGiaTri = id => the(id).value;
const docOTieuChi = id => the(id).value;
const veOTieuChi = () => '';
const duGieoDong = () => { GHI.push({loai:'dong-cua'}); };
const moHoSoDuAn = async () => {};
const lamMoiCuaToi = async () => { GHI.push({loai:'lam-moi'}); };
const duTickMoc = ()=>{}, duMocMo = ()=>{}, duXepMoc = ()=>{};
const duDuocGieo = () => true;
/* `viec: []` là bắt buộc từ khi `duViecCuaMoc` đọc `DUAN_HS.viec` — thiếu
   khoá ấy thì hồ sơ dự án giả không còn giống hồ sơ thật, và bài thử ngã ở
   một chỗ chẳng liên quan gì tới điều nó đang canh. */
let DUAN_HS = {duan:{id:7, nguoi_id:'toi', nguoi_ganh:['toi'], trang_thai:'dang-chay'},
               viec: []};
let DUAN_MO = 7, DU_GIEO_MOC = null;
const chuoi = kq => { const o = {eq:()=>o, select:()=>o, not:()=>o, gte:()=>o,
  then:(t,x)=>Promise.resolve(kq()).then(t,x)}; return o; };
const sb = {
  from: bang => ({
    select: () => chuoi(() => LOI_MANG ? {data:null, error:{message:'mạng hỏng'}}
                                       : {data: DANG.map(l=>({luong:l})), error:null}),
    insert: rows => { GHI.push({loai:'insert', rows}); return chuoi(()=>({error:null})); }
  }),
  rpc: () => chuoi(()=>({error:null}))
};
const CB_LOAI = {'loi-moi':{hinh:'a',chu:()=>'x',phu:()=>'y',mo:()=>{}},
                 'ky-nhan':{hinh:'b',chu:()=>'x',phu:()=>'y',mo:()=>{}}};

eval(nguon);

let hong = 0;
const kiem = (ten, dat, them) => { console.log((dat?'✅ ':'❌ ')+ten+(dat||!them?'':'\n      → '+them)); if(!dat) hong++; };

(async () => {
  const nap = () => { the('du-gieo-ten').value='Xong bản báo cáo';
                      the('du-gieo-xong').value='có file pdf';
                      the('du-gieo-han').value='2026-09-05';
                      the('du-gieo-batdau').value='';
                      the('du-gieo-ai').value=''; };

  console.log('\n── CỬA TẠO CAM KẾT TRONG MILESTONE ──');
  DANG=[1,2,3]; LOI_MANG=false; GHI=[]; TOAST=[]; nap();
  await duGieoGhi();
  kiem('Vườn đủ 3 chỗ → KHÔNG ghi dòng nào (trước đây ăn lỗi 23514)',
       !GHI.some(g=>g.loai==='insert'), JSON.stringify(GHI));
  kiem('…và nói thẳng vườn đã đủ chỗ',
       /đang đủ 3 chỗ/.test(TOAST.join('|')), TOAST.join('|'));
  kiem('…cửa KHÔNG đóng, chữ vừa gõ còn nguyên',
       !GHI.some(g=>g.loai==='dong-cua'), JSON.stringify(GHI));

  DANG=[1,3]; LOI_MANG=false; GHI=[]; TOAST=[]; nap();
  await duGieoGhi();
  const dong = (GHI.find(g=>g.loai==='insert')||{}).rows;
  kiem('Còn chỗ → ghi đúng một dòng', !!dong, JSON.stringify(GHI));
  kiem('…vào luống trống nhỏ nhất, kèm bộ áo cây của luống ấy',
       dong && dong.luong===2 && dong.thu_tu===2 && dong.qua==='🍊' && dong.ten_loai==='Cây cam',
       JSON.stringify(dong));
  kiem('…toast nói "Đã nhận cam kết", không hứa gì về kho',
       TOAST.join('|')==='Đã nhận cam kết.', TOAST.join('|'));
  kiem('…rồi mới đóng cửa và làm mới màn Của tôi',
       GHI.some(g=>g.loai==='dong-cua') && GHI.some(g=>g.loai==='lam-moi'), JSON.stringify(GHI));

  DANG=[]; LOI_MANG=true; GHI=[]; TOAST=[]; nap();
  await duGieoGhi();
  kiem('Mạng hỏng → KHÔNG ghi, và KHÔNG nói bừa là vườn đầy',
       !GHI.some(g=>g.loai==='insert') && /Chưa hỏi được máy chủ/.test(TOAST.join('|')),
       TOAST.join('|'));

  console.log('\n── Ô ĐẾM "CHỜ BẠN" ──');
  veChoBan({data:[{loai:'loi-moi',ten:'A',ai:'x',luc:null,khoa:1},
                  {loai:'cho-nhan',ten:'B',ai:'y',luc:null,khoa:2},
                  {loai:'ky-nhan',ten:'C',ai:'z',luc:null,khoa:3}], error:null});
  kiem('Loại app chưa biết → không đếm, không để lại dòng ma',
       the('cb-dem').textContent === 2 && CHO_BAN.length === 2,
       'đếm=' + the('cb-dem').textContent + ' · vẽ=' + CHO_BAN.length);
  kiem('…và chỉ số dòng vẫn khớp mảng choBanMo đọc',
       CHO_BAN[1] && CHO_BAN[1].loai === 'ky-nhan', JSON.stringify(CHO_BAN.map(d=>d.loai)));

  console.log('\n── MẪU SỐ CỦA CỘT MILESTONE ──');
  const ds = [{ma:'a',luong:1,da_nhan_luc:'x'},{ma:'b',luong:2,da_nhan_luc:null},
              {ma:'c',luong:null,giao_luc:'g',nhan_viec_luc:null},
              {ma:'d',luong:null,giao_luc:'g',tu_choi_luc:'t'}];
  const html = duVeCot({id:1,ten:'M1',ngay:'2026-09-01',da_dat:false}, ds, [], true);
  kiem('Cột đếm 1/2, bỏ thẻ chờ nhận và thẻ bị từ chối khỏi mẫu số',
       /* Canh CON SỐ, không canh câu chữ: đuôi "đã ký nhận" đã bị cắt khỏi nhãn,
          mà mẫu số 1/2 — điều ca này thật sự đo — vẫn đúng nguyên. */
       /1\/2 cam kết/.test(html), (html.match(/\d+\/\d+ cam kết[^<]*/)||['(không có)'])[0]);
  kiem('…nhưng vẫn BÀY đủ bốn thẻ', (html.match(/<ck>/g)||[]).length === 4,
       (html.match(/<ck>/g)||[]).length + ' thẻ');
  console.log('\n── NẤC CỦA THẺ CÓ LUỐNG RỖNG ──');
  kiem('Dòng chờ nhận → "cho-nhan", không rơi về "lam"', duNacCk(ds[2])==='cho-nhan', duNacCk(ds[2]));
  kiem('Dòng bị từ chối → "tu-choi", không rơi về "lam"', duNacCk(ds[3])==='tu-choi', duNacCk(ds[3]));

  console.log(hong ? `\n❌ ${hong} mục chưa đạt` : '\n✅ cả bộ ĐẠT');
  process.exit(hong ? 1 : 0);
})();
