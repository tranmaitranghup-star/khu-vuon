/* ═══ THỬ NGUỘI: CỬA TẠO CAM KẾT TRONG MÀN HỒ SƠ DỰ ÁN (27/08) ═══════════════
   Chạy:  node thu-gieo-cam-ket.js

   Cắt đúng mấy hàm cần ra khỏi `public/index.html` rồi chạy thẳng bằng node —
   không trình duyệt, không máy chủ, không tài khoản. Canh bốn thứ dễ vỡ nhất
   của cụm này:

     ① BẢY NẤC của `duNacCk` (sáu cho tới 29/08, rồi Tracy thêm `tam-dung`),
        và nhất là THỨ TỰ nhánh: hai nhánh sổ giao nhận phải đứng TRƯỚC nhánh
        so hạn, nếu không một cam kết vừa giao mà đã quá hạn sẽ hiện là "Quá
        hạn" thay vì "Chờ nhận việc".
        ⚠️ MỌI cọc nuôi hàm này phải khai cột `luong` — `undefined == null` là
        đúng trong JavaScript, nên cọc quên nó sẽ thấy TOÀN BỘ cam kết ra
        `tam-dung`, im lặng và sai. Ba ca ở mục ① và một ca ở mục ③ đã đỏ đúng
        vì thế suốt từ 29/08.
     ② BỘ LỌC QUYỀN của nút gieo (`duDuocGieo`) — bày nút cho người không bấm
        được là hứa thứ giao diện không giữ được.
     ③ Ô XẾP MILESTONE bị KHOÁ khi cam kết còn nằm kho chờ trả lời: trigger
        `kiem_giao_cam_ket` khoá đề bài, mà chính sách RLS thì để câu update
        chạm 0 dòng KHÔNG BÁO LỖI — nên giao diện phải tự khoá. Từ 29/08 ô ấy
        chỉ còn ở cột *Chưa xếp milestone*, nên phải gọi `duVeCkThe` với tham
        số thứ ba mới nhìn thấy nó.
     ④ Ô ĐẾM `cb-dem` của khối "Chờ bạn" phải khớp SỐ DÒNG BÀY RA. Trước 27/08
        app chưa biết hai loại `cho-nhan` và `bi-tu-choi`, nên dòng biến mất
        khỏi danh sách trong khi ô đếm vẫn cộng chúng vào.

   Không chạm máy chủ nên nó KHÔNG canh được: hai đường ghi của `duGieoGhi`,
   ba lời gọi RPC, và trần chỗ ngồi. Những thứ ấy phải thử tay sau khi chạy
   `nang-cap-giao-cam-ket.sql`. */
/* Thử NGUỘI cụm cửa gieo cam kết trong màn hồ sơ dự án — cắt đúng mấy hàm cần
   ra khỏi index.html rồi chạy, không cần trình duyệt, không cần máy chủ. */
const fs = require('fs');
const s = fs.readFileSync(__dirname + '/public/index.html', 'utf8');
const MOC = [
  ['function chuSach(s){',            '\n'],
  ['/* Sáu nấc trạng thái của một cam kết', '\n/* ── CÁCH NHÌN 1'],
  ['function duVeCot(m, ds, dsMoc, laChu){', '\nfunction duVeCkThe('],
  /* `duVeCot` gọi tới nó để biết mốc nào có việc nào. */
  ['const duViecCuaMoc = mocId =>', '\nlet DU_MOC_SUA'],
  ['function duDuocGieo(){',          '\n\n'],
  ['function duVeCkThe(o, dsMoc, chuaXep){',   '\n\n/* Ghi thẳng, không mở cửa nào'],
  ['function cbBaoLau(luc){',         '\n\n'],
  ['const CB_LOAI = {',               '\n\n/* Dòng "Chờ bạn" đang mở hộp'],
  ['function veChoBan(kq){',          '\nfunction choBanMo(']
];
const nguon = MOC.map(([a,b]) => { const i = s.indexOf(a);
  if (i < 0) throw new Error('không thấy mốc: ' + a);
  return s.slice(i, s.indexOf(b, i)); }).join('\n');

let ME = {id:'toi', so_cam_ket_toi_da:3};
let DUAN_HS = null;
/* DOM giả: chỉ ba ô mà `veChoBan` đụng tới. */
const O = {};
const o1 = id => (O[id] = O[id] || {id, textContent:'', innerHTML:'', style:{}});
global.document = {getElementById: o1};
const moHoSoDuAn = () => {}, cbKyNhan = () => {}, cbNhanMo = () => {}, cbTraLaiMo = () => {};
const homNay = () => '2026-08-27';
const duTenNguoi = id => ({toi:'Tracy', andy:'Andy'})[id] || '—';
const duNgayChu = d => d.slice(8,10) + '/' + d.slice(5,7);
eval(nguon + '\nglobalThis.DU_NAC_CHU = DU_NAC_CHU;'
           + '\nglobalThis.duKhoaDeBai = duKhoaDeBai;'
           + '\nglobalThis.CB_LOAI = CB_LOAI;');

let hong = 0;
const kiem = (ten, dat, them) => { console.log((dat?'✅ ':'❌ ')+ten+(dat||!them?'':'\n      → '+them)); if(!dat) hong++; };

const duan = {id:7, nguoi_id:'toi', nguoi_ganh:['toi','andy'], trang_thai:'dang-chay'};
const moc  = [{id:11, ten:'Bản mẫu chạy được', ngay:'2026-09-10', da_dat:false}];

// ── ① BẢY NẤC, và hai nhánh sổ giao nhận ĐỨNG TRƯỚC nhánh so hạn ───────────
/* NẤC THỨ BẢY `tam-dung` thêm 29/08. Tracy: *"cam kết mà ở trong kho thì trạng
   thái phải đổi thành tạm dừng chứ nhỉ"*. Nó đọc cột `luong`: luống rỗng nghĩa
   là cam kết đang nằm kho, không ai đang làm nó.
   Từ hôm ấy MỌI cọc phải khai `luong`, và ba ca dưới đây thiếu nó nên đỏ suốt
   — không phải vì hàm sai, mà vì cọc đứng yên trong lúc hàm đi tiếp. `luong:1`
   nghĩa là "đã vào một luống", tức đang chạy thật. */
console.log('\n── Bảy nấc trạng thái ──');
kiem('Giao rồi chưa trả lời → cho-nhan',
     duNacCk({giao_luc:'2026-08-20', han:'2026-09-01', luong:1}) === 'cho-nhan');
kiem('Giao rồi, hạn ĐÃ QUA mà chưa trả lời → vẫn cho-nhan, KHÔNG phải Quá hạn',
     duNacCk({giao_luc:'2026-08-20', han:'2026-08-01', luong:1}) === 'cho-nhan',
     'ra: ' + duNacCk({giao_luc:'2026-08-20', han:'2026-08-01', luong:1}));
kiem('Đã từ chối → tu-choi',
     duNacCk({giao_luc:'2026-08-20', tu_choi_luc:'2026-08-21', han:'2026-08-01', luong:1}) === 'tu-choi');
kiem('Đã nhận việc rồi thì về nấc thường (quá hạn → nghen)',
     duNacCk({giao_luc:'2026-08-20', nhan_viec_luc:'2026-08-21', han:'2026-08-01', luong:1}) === 'nghen',
     'ra: ' + duNacCk({giao_luc:'2026-08-20', nhan_viec_luc:'2026-08-21', han:'2026-08-01', luong:1}));
kiem('Cam kết TỰ VIẾT không có ba cột giao nhận → chạy y bản cũ',
     duNacCk({han:'2026-08-01', luong:1}) === 'nghen' && duNacCk({luong:1}) === 'lam',
     duNacCk({han:'2026-08-01', luong:1}) + ' · ' + duNacCk({luong:1}));
/* Ca ghim nấc mới, cả hai chiều — và ghim luôn VỊ TRÍ của nhánh: nó đứng SAU
   hai nhánh xong (cam kết đã đóng đọc lên là *Đã ký nhận*, không phải *Tạm
   dừng*) và TRƯỚC nhánh so hạn (việc đã gác lại thì không có lời hứa nào đang
   trượt). */
kiem('Luống rỗng → tam-dung, kể cả khi hạn đã qua',
     duNacCk({han:'2026-08-01'}) === 'tam-dung' && duNacCk({}) === 'tam-dung',
     duNacCk({han:'2026-08-01'}) + ' · ' + duNacCk({}));
kiem('…nhưng đã ký nhận thì vẫn là xong, không phải tạm dừng',
     duNacCk({da_nhan_luc:'2026-08-26'}) === 'xong');
kiem('Từ điển chữ khai đủ bảy nấc',
     ['xong','tu-tick','nghen','cho-nhan','tu-choi','tam-dung','lam'].every(k => DU_NAC_CHU[k]),
     JSON.stringify(DU_NAC_CHU));

// ── ② NÚT GIEO — bộ lọc quyền ──────────────────────────────────────────────
console.log('\n── Nút gieo và bộ lọc quyền ──');
DUAN_HS = {duan, moc, camket:[], viec:[]};
kiem('Có tên trong nguoi_ganh → bày nút', duDuocGieo() === true);
let h = duVeCot(moc[0], [], moc, true);
/* Chữ trên nút đổi 27/08 theo luật "một việc — một chữ": app gọi hành động
   tạo cam kết là "Nhận cam kết" ở cả hai đường đã có, còn "gieo" chỉ sống
   trong tên mã. Nút cột nay là một LỜI MỜI trung tính, và nút gật trong cửa
   mới là chỗ nói rõ nhận hay giao.

   ⚠️ BA CA DƯỚI ĐÂY GHIM LUẬT 29/08, không phải luật 27/08 nữa. Đáy cột đổi
   hai lần trong cùng một ngày, cả hai đều do Tracy soi giao diện:
     · *"chỉ dùng 1 nút + Cam kết thôi xong mở ra hộp thì mới ra 2 đường là add
       mới hay là chọn có sẵn"* — hai nút viền đứt xếp chồng gộp thành MỘT, và
       việc chọn đường lùi vào trong một hộp ngã ba. Nên chữ ngắn lại còn
       "+ Cam kết", và lời gọi đi qua hộp ngã ba chứ không thẳng tới cửa gieo.
     · *"2 ô này nhìn giao diện thiết kế ko đồng bộ tí nào ý ... cho 2 ô có
       kích thước bằng nhau"* — nút ấy và nút "Hoàn thành" cạnh nó về chung
       cặp `nut-nho` + `nut-vien`/`nut-xanh` đang dùng ở đáy mọi cửa sổ app,
       nên lớp riêng `du-cot-them` rời khỏi nút này.
   Ca cũ ghim cả lớp lẫn chữ lẫn tên hàm của bản 27/08, nên cả ba cùng đỏ. */
kiem('Nút mang đúng khuôn nút app, chữ gọn một vế',
     h.includes('class="nut-nho nut-vien"') && h.includes('>+ Cam kết<'),
     h.slice(h.indexOf('du-cot-nut'), h.indexOf('du-cot-nut') + 220));
kiem('Chữ "gieo" KHÔNG rò ra màn — nó chỉ là tên mã',
     !/[Gg]ieo cam kết/.test(h));
/* Hộp ngã ba KHÔNG ghi gì và không giữ trạng thái gì — nó chỉ cầm `mocId` đủ
   lâu để chuyển tiếp sang `duGieoMo` hoặc `duChonMo`. Nên `mocId` phải đi
   nguyên vẹn qua nó, và đó là thứ hai ca này đo. */
kiem('Nút mở hộp ngã ba, mang đúng id milestone của cột', h.includes('duNgaBaMo(11)'));
kiem('Cột "chưa xếp" mở hộp với milestone RỖNG',
     duVeCot(null, [], moc, true).includes('duNgaBaMo(null)'));

DUAN_HS = {duan:{...duan, nguoi_ganh:['andy']}, moc, camket:[], viec:[]};
kiem('KHÔNG có tên trong dự án → không bày nút', duDuocGieo() === false);
/* Đo bằng LỜI GỌI chứ không bằng lớp CSS: lớp `du-cot-them` đã rời nút này
   29/08, nên ca cũ xanh cả khi nút vẫn nằm đó — một ca xanh vì đo nhầm thứ
   không còn tồn tại thì tệ ngang một ca đỏ oan. */
kiem('…và cột vẽ ra cũng sạch nút', !duVeCot(moc[0], [], moc, true).includes('duNgaBaMo'));

DUAN_HS = {duan:{...duan, nguoi_ganh:[]}, moc, camket:[], viec:[]};
kiem('Dự án cũ chưa có nguoi_ganh → lùi về PIC, PIC vẫn gieo được', duDuocGieo() === true);

DUAN_HS = {duan:{...duan, trang_thai:'hoan-thanh'}, moc, camket:[], viec:[]};
kiem('Dự án đã hoàn thành thì thôi nhận cam kết mới', duDuocGieo() === false);

// ── ③ THẺ CAM KẾT ở hai nấc mới ────────────────────────────────────────────
/* ⚠️ THAM SỐ THỨ BA `chuaXep` LÀ BẮT BUỘC từ 29/08. Tracy: *"cam kết nó được
   xếp trong milestone rồi thì cần gì phải có tag bên trong cam kết nữa"* — ô
   chọn milestone nay CHỈ hiện ở cột *Chưa xếp milestone*. Ba ca dưới gọi
   `duVeCkThe(o, moc)` thiếu tham số ấy nên thẻ vẽ ra không có ô nào, và cả ca
   "khoá" lẫn ca "không khoá" đều đo nhầm: một cái đỏ, một cái xanh vì rỗng.
   Số ô khoá cũng từ HAI xuống MỘT cùng hôm ấy — ô Ngày bắt đầu bỏ hẳn khỏi
   thẻ (Tracy: *"dd/mm/yy bạn để trong cam kết làm gì đó?"*), chỉ còn ô chọn
   milestone chịu khoá. */
console.log('\n── Thẻ cam kết ở hai nấc mới ──');
DUAN_HS = {duan, moc, camket:[], viec:[]};
const cho = duVeCkThe({ma:'O9', ten:'Bản mẫu', nguoi_id:'andy', luong:1,
                       giao_luc:'2026-08-25', han:'2026-09-01'}, moc, true);
kiem('Ký hiệu tròn dùng đúng lớp .kh cho-nhan', cho.includes('class="kh cho-nhan"'));
kiem('Chip đọc ra "Chờ nhận việc"', cho.includes('>Chờ nhận việc<'));
kiem('Ô xếp milestone KHOÁ khi còn chờ trả lời',
     (cho.match(/disabled/g) || []).length === 1, 'số ô khoá: ' + (cho.match(/disabled/g)||[]).length);
/* Ở cột đã có milestone thì không còn ô nào để mà khoá — đó chính là luật
   29/08, và ca này ghim nó thay vì để nó lặng lẽ đúng. */
kiem('Ở cột đã xếp milestone thì thẻ không mang ô chọn nào',
     !duVeCkThe({ma:'O9', ten:'Bản mẫu', nguoi_id:'andy', luong:1,
                 giao_luc:'2026-08-25', han:'2026-09-01'}, moc).includes('du-ck-xep'));
const tuc = duVeCkThe({ma:'O9', ten:'Bản mẫu', nguoi_id:'andy', luong:1,
                       giao_luc:'2026-08-25', tu_choi_luc:'2026-08-26',
                       tu_choi_ly_do:'Tháng này tôi kín lịch'}, moc, true);
kiem('Nấc từ chối bày LÝ DO ra cho người giao đọc', tuc.includes('Tháng này tôi kín lịch'));
kiem('Ký hiệu tròn dùng .kh tu-choi', tuc.includes('class="kh tu-choi"'));
const thuong = duVeCkThe({ma:'O1', ten:'Tự viết', nguoi_id:'toi', luong:1,
                          han:'2026-09-01'}, moc, true);
kiem('Cam kết tự viết bày ô chọn ra và KHÔNG khoá',
     thuong.includes('du-ck-xep') && !thuong.includes('disabled'));
kiem('Cam kết tự viết đang chạy vẫn ra .kh lam như cũ', thuong.includes('class="kh lam"'),
     (/class="kh [a-z-]+"/.exec(thuong) || [''])[0]);
/* Cùng cam kết ấy trả về kho (luống rỗng) thì thẻ đọc lên là *Tạm dừng* —
   nấc Tracy chốt 29/08, và là thứ trước đó rơi xuống nhánh cuối rồi hiện ra
   *Đang chạy* trong khi không ai đang làm nó. */
const kho1 = duVeCkThe({ma:'O1', ten:'Tự viết', nguoi_id:'toi', han:'2026-09-01'}, moc, true);
kiem('Trả về kho thì thẻ đọc lên là Tạm dừng, không phải Đang chạy',
     kho1.includes('class="kh tam-dung"') && kho1.includes('>Tạm dừng<'),
     (/class="kh [a-z-]+"/.exec(kho1) || [''])[0]);

// ── ④ KHỐI "CHỜ BẠN" — bốn loại, và Ô ĐẾM phải khớp SỐ DÒNG BÀY RA ─────────
console.log('\n── Khối "Chờ bạn" nhận đủ bốn loại ──');
kiem('Từ điển CB_LOAI khai đủ bốn loại',
     ['loi-moi','ky-nhan','cho-nhan','bi-tu-choi'].every(k => CB_LOAI[k]),
     'đang có: ' + Object.keys(CB_LOAI).join(' · '));

const bon = [
  {loai:'loi-moi',   khoa:7,    ten:'Bản mẫu chạy được', ai:'Tracy', luc:'2026-08-25'},
  {loai:'ky-nhan',   khoa:'O3', ten:'Trang bán hàng',    ai:'Andy',  luc:'2026-08-26'},
  {loai:'cho-nhan',  khoa:'O9', ten:'Hồ sơ rủi ro',      ai:'Tracy', luc:'2026-08-25'},
  {loai:'bi-tu-choi',khoa:'O8', ten:'Kịch bản — lý do: kín lịch', ai:'Andy', luc:'2026-08-26'}
];
veChoBan({data: bon, error: null});
const soDong = (O['cb-ds'].innerHTML.match(/class="cb-dong"/g) || []).length;
kiem('Bốn dòng đều VẼ RA, không dòng nào rơi', soDong === 4, 'vẽ ra ' + soDong + ' dòng');
kiem('Ô đếm cb-dem khớp đúng số dòng bày ra',
     String(O['cb-dem'].textContent) === String(soDong),
     'đếm ' + O['cb-dem'].textContent + ' mà bày ' + soDong);
kiem('Dòng chờ nhận nói rõ ai giao và chờ gì',
     O['cb-ds'].innerHTML.includes('giao cho bạn cam kết')
     && O['cb-ds'].innerHTML.includes('nhận việc hoặc từ chối'));
kiem('Dòng bị trả lại nói rõ đó là cam kết MÌNH giao',
     O['cb-ds'].innerHTML.includes('trả lại cam kết bạn giao'));
kiem('Không dòng nào để lọt chữ "undefined" ra màn',
     !O['cb-ds'].innerHTML.includes('undefined'));

console.log(hong ? `\n❌ ${hong} mục chưa đạt` : '\n✅ tất cả đều đạt');
process.exit(hong ? 1 : 0);
