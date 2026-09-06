/* THỬ: MẢNG DEEP WORK NẰM TRONG KHỐI VIỆC (nấc Ngày)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 31/08, bốn lượt: *"đừng chia ra 2 khối như này bị rối"* → gộp còn một
   khối · mảng đậm hơn một nấc, cùng tông với việc, viền nét liền xám nhạt ·
   *"tôi muốn deepwork vẫn chạy đúng dòng thời gian ở trục bên trái"* → mảng bám
   trục giờ, không phải một dải ghi tổng số phút · ca lệch giờ chọn đường N1:
   khối việc đứng yên, mảng rơi đúng giờ thật, nối bằng một vạch mảnh.

   ⚠️ HAI CA PHẢI GIỮ NGUYÊN ĐƯỜNG CŨ (ca 4 và 5 dưới đây): phiên không gắn việc,
   và phiên của việc chưa hẹn giờ. Với chúng `tlgKhoiPhien` vẫn phải sinh ra một
   khối — nó là cửa DUY NHẤT còn sống để sửa một phiên ghi sai (`dwSuaPhien`).
   Gộp hết là mất cửa ấy mà không một tiếng kêu nào.

   Bài thử CẮT KHỐI GỐC ra khỏi `public/index.html` rồi chạy trên dữ liệu giả —
   không chép tay một dòng logic nào sang đây.

   Chạy:  node production/tinh-thuc-app/thu-mang-deepwork.js
   Soi bản cũ:
     git show HEAD:production/tinh-thuc-app/public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-mang-deepwork.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

/* Cắt một hàm top-level: từ `function ten(` tới dấu } đứng một mình ở cột 0. */
function catHam(ten){
  const i = SRC.indexOf('\nfunction ' + ten + '(');
  if (i < 0) throw new Error('Không thấy hàm: ' + ten);
  const j = SRC.indexOf('\n}\n', i);
  if (j < 0) throw new Error('Không thấy chỗ đóng hàm: ' + ten);
  return SRC.slice(i + 1, j + 3);
}
function catDong(dau){
  const i = SRC.indexOf(dau);
  if (i < 0) throw new Error('Không thấy dòng: ' + dau);
  return SRC.slice(i, SRC.indexOf('\n', i));
}

const NGUON = [
  catDong('const tlgHHMM = p =>'),
  /* Màu của thứ cá nhân (Tracy chốt 04/09): sự kiện tím · việc hồng, SUY RA lúc
     vẽ chứ không cất vào kho. Cắt hàm THẬT chứ không dựng cọc — chúng quyết cái
     lớp CSS mà quá nửa số ca dưới đây đang soi, nên một bản giả trả chuỗi rỗng
     là biến bài thử thành thứ tự nói chuyện với chính nó. Mốc cắt dừng ở tên,
     không ôm khoảng trắng canh cột phía sau: chỗ ấy đổi theo lần dọn kế bên. */
  catDong('const mauSuKien'), catDong('const mauViec'),
  /* Hai hằng SÀN của phép chia làn (TRI-129). Chúng đứng ở chỗ GỌI `tlgXepLan`
     bên trong `tlgThanLuoi`, không nằm trong thân hàm — quên cắt là cả bài chết
     ngay lượt vẽ đầu tiên, và một bài chết thì mọi ca của nó im lặng biến mất. */
  catDong('const TLG_SAN_NGAY'),
  catHam('phutDeadline'), catHam('tlgLucVN'), catHam('tlgKhoangTask'),
  catHam('tlgXepLan'), catHam('tlgKhoiPhien'), catHam('tlgThanLuoi'),
].join('\n');

/* Cọc: đủ để khối trên chạy, không hơn. */
const COC = `
let TLG_VIEC = {};
let TLG_KHO_MO = false;
const TLG_THU = ['T2','T3','T4','T5','T6','T7','CN'];
const chuSach = t => String(t == null ? '' : t)
  .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
const homNay = () => '2026-08-31';
const laCN = () => false;
const lcCuaNgay = () => (MOI.buoi || []);
/* Lượt VẼ đi qua một cửa riêng từ 04/09: cùng danh sách buổi, cộng cái nút tắt
   lịch cá nhân. Cọc bỏ qua cái nút ấy — nó là một lựa chọn XEM của từng máy,
   còn bài này hỏi mảng deep work rơi vào khối nào. */
const lcCuaNgayVe = g => lcCuaNgay(g);
const daTre = () => false;
const LC_HIEN = [];
const lcDaiCuaKhung = () => [];
const tlgDaiChuaGio = () => '';
const tlgDaiCaNgay = () => '';
const tlgDaiKho = () => '';
const tlTenPhien = (p) => 'Phien ' + p.id;
const dwDongDuoc = () => true;
let dwPhien = null;
`;

const chay = new Function('MOI', COC + '\n' + NGUON + `
  return tlgThanLuoi(MOI.ngays, MOI.phien, MOI.tasks, [], [], null, MOI.nac || 'ngay');
`);

/* ── dữ liệu giả ─────────────────────────────────────────────────────────── */
const NGAY = '2026-08-31';
const iso = (h, m) => `${NGAY}T${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:00+07:00`;
const viec = (id, gio, them) => ({id, noi_dung:'Viec ' + id, ngay:NGAY, gio_start:gio,
  trang_thai:'Doing', mau:'', ...them});
const phien = (id, taskId, h, m, phut) => ({id, task_id:taskId, bat_dau:iso(h,m),
  phut, ket_qua:'song'});

const dem = (html, re) => (html.match(re) || []).length;
const KQ = [];
const ok = (ten, dat, chiTiet) => { KQ.push({ten, dat, chiTiet}); };

/* ── 1 · phiên chạy ĐÚNG giờ hẹn → một khối, mảng nằm trong ─────────────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(1,'14:45')], phien:[phien(11,1,14,45,45)]});
  ok('① chồng giờ: không còn khối phiên đứng riêng', !/tlg-viec phien/.test(h));
  ok('① chồng giờ: đúng MỘT khối việc', dem(h, /class="tlg-viec(?! phien)/g) === 1,
     dem(h, /class="tlg-viec/g) + ' khối');
  /* ⚠️ BA CA NÀY ĐẢO CHIỀU 05/09 (TRI-130). Trước đó chúng đòi một MẢNG TÔ nằm
     trong khối, có cửa chạm riêng mở `dwSuaPhien`. Tracy: *"thôi bỏ hẳn ô deep
     work đi chỉ cần ghi số phút deep work là được"*. Nay chỉ còn một con số, và
     cửa sửa phiên chạy TRONG khung giờ đã hẹn đi theo cái ô ấy — chạm khối là
     mở cửa Thông tin việc. Phiên chạy LỆCH giờ hẹn không mất gì: nó vẫn là khối
     rời của riêng nó, ca ② và ⑫ canh chỗ đó. */
  ok('① số phút deep work có mặt', /class="tlg-dw-so">💧 45p</.test(h));
  ok('① không còn mảng tô trong thân khối', !/class="tlg-dw"/.test(h));
  ok('① con số không nuốt cú chạm của khối việc', !/tlg-dw-so[^>]*onclick/.test(h));
}

/* ── 2 · phiên LỆCH giờ hẹn → mảng rời + vạch nối (đường N1) ────────────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(2,'9:00')], phien:[phien(22,2,11,20,45)]});
  ok('② lệch giờ: không còn khối phiên đứng riêng', !/tlg-viec phien/.test(h));
  ok('② lệch giờ: có mảng rời mang màu việc', /class="tlg-viec tlg-dw/.test(h));
  ok('② lệch giờ: mảng rời KHÔNG mang tên việc', !/tlg-dw[^>]*>[^<]*Viec 2/.test(h));
  ok('② lệch giờ: có vạch nối', /class="tlg-dw-noi"/.test(h));
  ok('② lệch giờ: khối việc KHÔNG bị nới ra ôm phiên (vẫn 1 giờ)',
     /data-tu="540" data-den="600"/.test(h), (h.match(/data-tu="\d+" data-den="\d+"/g)||[]).join(' · '));
  ok('② mảng rời đứng đúng 11:20–12:05', /data-tu="680" data-den="725"/.test(h));
}

/* ── 3 · phiên chạy TRƯỚC giờ hẹn ───────────────────────────────────────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(3,'9:00')], phien:[phien(33,3,7,0,45)]});
  ok('③ chạy trước giờ hẹn: vẫn ra mảng rời + vạch nối',
     /class="tlg-viec tlg-dw/.test(h) && /class="tlg-dw-noi"/.test(h));
  ok('③ chạy trước giờ hẹn: lưới nới lên tới 7h', /data-gio-dau="7"/.test(h));
}

/* ── 4 · phiên KHÔNG gắn việc → giữ khối phiên (cửa sửa còn sống) ───────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(4,'14:45')], phien:[phien(44,null,10,0,30)]});
  ok('④ phiên không gắn việc: GIỮ khối phiên', /tlg-viec phien/.test(h));
  ok('④ phiên không gắn việc: vẫn mở được cửa sửa', /dwSuaPhien\(44\)/.test(h));
}

/* ── 5 · việc CHƯA hẹn giờ → giữ khối phiên ─────────────────────────────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(5, null)], phien:[phien(55,5,10,0,30)]});
  ok('⑤ việc chưa hẹn giờ: GIỮ khối phiên', /tlg-viec phien/.test(h));
  ok('⑤ việc chưa hẹn giờ: không đẻ mảng nào', !/tlg-dw/.test(h));
}

/* ── 6 · một việc nhiều phiên → nhiều mảng, đúng nhịp ───────────────────── */
{
  const h = chay({ngays:[NGAY], tasks:[viec(6,'16:00',{thoi_luong_du_kien:120})],
                  phien:[phien(61,6,16,10,30), phien(62,6,17,15,25)]});
  /* ⚠️ ĐẢO CHIỀU 05/09 cùng ca ①. Hai phiên nay CỘNG thành một con số. Tracy,
     khi được hỏi một việc nhiều phiên thì ghi thế nào: *"chỉ cần tính tổng thời
     gian deep work là được"*. Hai con số đứng theo giờ thì hai phiên cách nhau
     mươi phút lại chồng lên nhau — đúng cái bệnh vừa chữa ở khối việc. */
  ok('⑥ nhiều phiên: cộng thành MỘT con số tổng', /class="tlg-dw-so">💧 55p</.test(h),
     (h.match(/tlg-dw-so">[^<]*/g) || []).join(' · '));
  ok('⑥ nhiều phiên: vẫn đúng một khối việc', dem(h, /class="tlg-viec(?! phien)/g) === 1);
  ok('⑥ nhiều phiên: đúng MỘT con số, không phải hai',
     dem(h, /class="tlg-dw-so"/g) === 1, dem(h, /class="tlg-dw-so"/g) + ' con số');
}

/* ── 7 · nấc TUẦN không đổi hành vi ─────────────────────────────────────── */
{
  const h = chay({nac:'tuan', ngays:[NGAY], tasks:[viec(7,'14:45')],
                  phien:[phien(71,7,14,45,45)]});
  ok('⑦ nấc Tuần: không có mảng deep work nào', !/tlg-dw/.test(h));
  ok('⑦ nấc Tuần: không có khối phiên nào', !/tlg-viec phien/.test(h));
}

/* ── 8 · mảng bị KẸP trong thân khối, không thò ra ngoài ────────────────── */
{
  /* Việc hẹn 30 phút (14:45–15:15) nhưng phiên chạy 90 phút từ 14:45.
     ⚠️ CA NÀY ĐỔI CÂU HỎI 05/09. Nó vốn canh phép KẸP mảng tô trong thân khối —
     mảng 1.5 giờ trong một khối 0.5 giờ mà không kẹp là thò ra rồi bị xén. Bỏ ô
     thì phép kẹp không còn chỗ bám. Điều còn lại đáng canh: con số vẫn phải nói
     ĐỦ 90 phút, đừng cắt nó theo khổ khối — thời gian đã bỏ ra là thời gian đã
     bỏ ra, khối hẹp không làm nó ngắn đi. */
  const h = chay({ngays:[NGAY], tasks:[viec(8,'14:45',{thoi_luong_du_kien:30})],
                  phien:[phien(81,8,14,45,90)]});
  ok('⑧ phiên dài hơn khối: con số vẫn nói đủ 90 phút',
     /class="tlg-dw-so">💧 90p</.test(h),
     (h.match(/tlg-dw-so">[^<]*/g) || []).join(' · ') || 'không thấy con số');
}

/* ── 9 · phiên ngắn vẫn phải ghi ra số ──────────────────────────────────── */
{
  /* ⚠️ CA NÀY ĐẢO CHIỀU 05/09. Bản cũ đòi mảng 15 phút phải BỎ chữ, vì một mảng
     tô cao 0.25 giờ thì chữ bị xén ngang thân — hỏng chứ không phải rút gọn.
     Bỏ ô thì lý lẽ ấy hết hiệu lực: con số nay đứng ở góc dưới vùng chữ, khổ
     của nó không dính gì tới độ dài phiên. Giấu nó đi mới là mất thông tin.
     Chỗ duy nhất còn giấu là khối `.ti` — canh ở ca ⑩ bằng luật CSS. */
  const h = chay({ngays:[NGAY], tasks:[viec(9,'14:00',{thoi_luong_du_kien:180})],
                  phien:[phien(91,9,14,10,15)]});
  ok('⑨ phiên 15 phút vẫn ghi ra số', /class="tlg-dw-so">💧 15p</.test(h),
     (h.match(/tlg-dw-so">[^<]*/g) || []).join(' · ') || 'không thấy con số');
}

/* ── 10 · luật CSS đi kèm phải còn nguyên ───────────────────────────────── */
{
  ok('⑩ chữ việc nổi trên mảng (.tlg-nd có z-index)',
     /\.tlg-nd\{[\s\S]{0,400}?z-index:2/.test(SRC));
  /* ⚠️ CA NÀY ĐẢO CHIỀU HAI LẦN TRONG MỘT NGÀY (05/09, TRI-130). Bản đầu đòi
     mảng PHẢI có viền nét liền — dựng hồi nét đứt còn nghĩa "dự kiến". Sáng
     05/09 Tracy bỏ viền, chiều bỏ luôn cả cái ô. Nay chỗ cần canh là con số. */
  ok('⑩ con số neo vào vùng chữ, góc dưới-phải',
     /\.tlg-dw-so\{[^}]*position:absolute[^}]*right:0[^}]*bottom:0/.test(SRC));
  /* Khối `.ti` giấu cả tên lẫn giờ vì không đủ chỗ cho một dòng nào; con số đi
     theo đúng luật ấy, không tự đặt ngưỡng riêng. */
  ok('⑩ khối .ti giấu con số, cùng luật với tên và giờ',
     /\.tlg-viec\.ti \.tlg-dw-so\{display:none\}/.test(SRC));
  /* Con số KHÔNG được nuốt cú chạm: khối việc mở cửa Thông tin việc, và một
     nhãn chữ đứng đè lên đó mà ăn mất cú chạm là dựng ra một vùng chết ở góc. */
  ok('⑩ con số không ăn cú chạm của khối', /\.tlg-dw-so\{[^}]*pointer-events:none/.test(SRC));
  /* Tên biến đổi từ `--pastel` sang `--n3` khi bảng màu chip dọn lại; công thức
     (40% trên nền thẻ, 68% pha màu đậm ở bản sáng) giữ nguyên. Hai dòng này đỏ
     suốt từ đợt ấy vì gác theo TÊN CŨ, không phải vì mảng đổi màu. */
  ok('⑩ mảng lấy chính pastel của việc, đậm hơn một nấc',
     /\.tlg-dw\{[\s\S]{0,400}?color-mix\(in srgb, var\(--n3\) 40%, var\(--card\)/.test(SRC));
  /* Bản sáng phải pha với màu ĐẬM CÙNG HỌ (`--dam`), không phải một màu xám
     trung tính — đó chính là chỗ bản đầu đi lệch khỏi bản mẫu Tracy đã duyệt. */
  ok('⑩ nền sáng: pha với màu đậm cùng họ, đúng bản mẫu',
     /\[data-theme="sang"\] \.tlg-dw\{[\s\S]{0,120}?var\(--n3\) 68%, var\(--dam\)/.test(SRC));
  /* ⚠️ CA NÀY ĐẢO CHIỀU 03/09. Bản cũ đòi `--dam` khoá theo TRẠNG THÁI
     (`.xong`→`--tt-xong`, `.s-Doing`→`--tt-lam`). Luật ấy đúng khi bảng màu chỉ
     có ba trạng thái, và gãy ngay lúc nó nở ra: một khối cam ĐÃ XONG pha pastel
     cam với xanh lá thành một mảng OLIVE nằm giữa khối cam. Tracy 03/09, kèm
     ảnh: *"khối tổng đó màu gì thì màu deepwork theo như vậy nhưng màu đậm hơn
     thôi"*. Nay `--dam` đi theo HỌ CỦA CHÍNH KHỐI — một dòng `var(--d3)` phủ cả
     mười hai họ đang có lẫn họ thêm về sau. Nửa sau của ca là chốt chặn: khai
     lại `--dam` theo trạng thái là gọi con olive ấy quay về. */
  ok('⑩ màu đậm đi theo HỌ của khối, không khoá theo trạng thái',
     /\.tlg-viec\{--dam:var\(--d3\)\}/.test(SRC)
     && !/\.tlg-viec\.s-Doing\{--dam:/.test(SRC)
     && !/\.tlg-viec\.xong\{--dam:/.test(SRC));
  /* Hai họ phải khai riêng vì luật xanh tím và luật xong cố ý chỉ kéo `--n*` và
     `--k`, để `--d*` nằm lại ở họ lá (ô tick bản tối đọc `--d3`). Ở đúng hai họ
     ấy `--d3` không cùng họ với `--n3`, nên gộp chúng vào dòng chung là mảng
     lạc màu trở lại — mà lối chữa "kéo `--d3` lên trên cho gọn" thì đụng ô tick. */
  ok('⑩ hai họ tự khai riêng: xanh tím khi chưa xong · lá khi đã xong',
     /\.tlg-viec:not\(\.co-mau\):not\(\.lich\):not\(\.phien\)\{--dam:var\(--xtd3\)\}/.test(SRC)
     && /\.tlg-viec\.xong:not\(\.co-mau\):not\(\.lich\):not\(\.phien\)\{--dam:var\(--lad3\)\}/.test(SRC));
  /* ⚠️ CA NÀY ĐÃ ĐẢO CHIỀU 03/09 (làn DK, TRI-71). Trước đó nó đòi khối phiên
     PHẢI có nét đứt; nay nó đòi khối phiên KHÔNG được có. Tracy: *"deepwork bỏ
     nét đứt đi, nét đứt mang ý nghĩa là dự kiến"* — nét đứt nay chỉ nói một
     điều, "chưa chốt", mà một phiên đã chạy thì không bao giờ chưa chốt.
     Ca này chưa chạy lần nào kể từ lúc đảo, vì cả bài ngã ngay ở lượt nạp suốt
     từ đó; 05/09 dựng lại cọc thì nó chạy lần đầu và xanh.
     Phép kiểm ĐỦ cho luật này nằm ở `thu-chot-su-kien.js` khối ⑨ — nó quét cả
     khối kiểu dáng, không chỉ một luật. */
  ok('⑩ khối phiên KHÔNG còn nét đứt — dấu ấy nay chỉ nói "chưa chốt"',
     !/\.tlg-viec\.phien\{[^}]*border-style/.test(SRC));
}

/* ── 11 · KHỐI SỰ KIỆN cũng nuốt mảng deep work (Tracy chốt 03/09) ──────── */
const buoi = (id, tu, den, viecId) => ({lich:id, ngay:NGAY, ten:'Buoi ' + id, mau:'',
  chot:true, tu, den, doi:false, lap:'', sua:true, khoi:false, nhan:0, toi:null,
  viec: viecId ? {id:viecId, noi_dung:'Viec cua buoi', trang_thai:'Doing'} : null,
  xong:false});
{
  /* Buổi 15:00–16:00 đã đẻ việc 200; việc ấy chưa tự khai giờ nên không có khối
     riêng. Phiên chạy đúng trong khung buổi. */
  const h = chay({ngays:[NGAY], tasks:[], buoi:[buoi(501, 900, 960, 200)],
                  phien:[phien(201, 200, 15, 0, 45)]});
  ok('⑪ buổi: không còn khối phiên đứng riêng', !/tlg-viec phien/.test(h),
     dem(h, /tlg-viec phien/g) + ' khối phiên');
  ok('⑪ buổi: số phút deep work nằm TRONG khối sự kiện',
     /class="tlg-viec lich[\s\S]{0,2000}?class="tlg-dw-so"/.test(h));
  ok('⑪ buổi: ghi đúng số phút', /class="tlg-dw-so">💧 45p</.test(h));
  ok('⑪ buổi: vẫn đúng MỘT khối sự kiện', dem(h, /class="tlg-viec lich/g) === 1,
     dem(h, /class="tlg-viec lich/g) + ' khối');
}

/* ── 12 · phiên LỆCH giờ buổi → mảng rời mượn pastel của buổi ───────────── */
{
  const h = chay({ngays:[NGAY], tasks:[], buoi:[buoi(502, 900, 960, 210)],
                  phien:[phien(211, 210, 11, 20, 45)]});
  ok('⑫ lệch giờ buổi: không còn khối phiên đứng riêng', !/tlg-viec phien/.test(h));
  ok('⑫ lệch giờ buổi: mảng rời mang lớp `lich` để mượn màu buổi',
     /class="tlg-viec tlg-dw lich/.test(h));
  ok('⑫ lệch giờ buổi: mảng rời KHÔNG bị vẽ thành một buổi thứ hai',
     dem(h, /class="tlg-viec lich/g) === 1, dem(h, /class="tlg-viec lich/g) + ' khối buổi');
  ok('⑫ lệch giờ buổi: có vạch nối', /class="tlg-dw-noi"/.test(h));
}

/* ── 13 · việc TỰ KHAI GIỜ thì khối của chính nó mới là chỗ đúng ────────── */
{
  /* Buổi 15:00 đẻ việc 220, mà việc 220 lại tự hẹn 9:00. Con số phải chui vào
     khối VIỆC, không vào khối buổi — buổi chỉ đỡ lời khi việc không có khối. */
  const t = viec(220, '9:00');
  const h = chay({ngays:[NGAY], tasks:[t], buoi:[buoi(503, 900, 960, 220)],
                  phien:[phien(221, 220, 9, 10, 30)]});
  ok('⑬ việc tự khai giờ: con số nằm trong khối VIỆC, không trong khối buổi',
     /class="tlg-viec(?! phien)(?! lich)[\s\S]{0,2000}?class="tlg-dw-so"/.test(h));
  ok('⑬ việc tự khai giờ: khối buổi KHÔNG mọc con số nào',
     !/class="tlg-viec lich[^"]*"[\s\S]{0,2000}?class="tlg-dw-so"/.test(h));
}

/* ── bảng điểm ──────────────────────────────────────────────────────────── */
let dat = 0;
KQ.forEach(k => {
  if (k.dat) dat++;
  console.log((k.dat ? '  ✅ ' : '  ❌ ') + k.ten + (k.chiTiet ? '   → ' + k.chiTiet : ''));
});
console.log(`\n${dat}/${KQ.length} đạt`);
process.exit(dat === KQ.length ? 0 : 1);
