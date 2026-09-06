/* THỬ: GIỜ RẢNH CỦA NHÓM — ba khung gợi ý trong cửa Sự kiện (TRI-57)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"mọi người cần nhìn thấy lịch của team xem còn trống những
   khoảng thời gian nào không có sự kiện hoặc lịch hẹn khác để họ dễ setup cuộc
   hẹn"* → chốt ba khung gợi ý, không dựng lưới người-theo-hàng.

   Sáu ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · BUỔI CỦA NGƯỜI NGOÀI NHÓM. Máy chủ trả về lịch của CẢ đội, nên nếu quên
       lọc theo tập người dự thì mọi buổi của mọi người đều làm nhóm bận — gợi ý
       trống trơn mà không ai đoán được vì sao.

     · KHE PHẢI ĐỦ DÀI. Kẽ hở 30 phút giữa hai buổi vẫn là một kẽ hở; nhận nó
       cho một buổi 60 phút là hẹn người ta vào một chỗ không vừa.

     · GIỜ ĐÃ TRÔI QUA của hôm nay. Gợi ý 08:00 lúc 15h là một dòng chữ vô dụng,
       và nó chiếm mất một trong ba chỗ.

     · CHỦ NHẬT. `lcHopNgay` đã nghỉ CN cho chuỗi lặp hằng ngày, nên một ngày
       Chủ nhật trông RỖNG — tức rảnh cả ngày, và nó luôn thắng mọi ngày khác.

     · MỘT DÒNG MỖI NGÀY. Ba khe sớm nhất trong cùng một buổi sáng là ba dòng nói
       cùng một điều; ba lựa chọn mà chọn cái nào cũng thế thì không phải lựa chọn.
       Nên một dòng là một NGÀY, và mọi khung trống của ngày ấy nằm trong dòng đó
       (Tracy chốt 03/09, TRI-76). Ngày kín đặc thì bỏ qua, lấy ngày kế tiếp.

     · LỚP RIÊNG TƯ. Dữ liệu để dựng thanh bận có sẵn cả TÊN buổi và ghi chú.
       In tên ra là phơi lịch riêng của cả đội — mã chỉ được đụng tới giờ.

   Chạy:  node production/tinh-thuc-app/thu-gio-ranh.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

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

/* ── MÁY CHẠY THẬT ──────────────────────────────────────────────────────────
   Nạp MÃ THẬT của cả chuỗi hàm, không dựng bản giả nào ngoài `homNay` — ngày
   hôm nay phải ghim lại thì bài thử mới nói cùng một điều ở mọi ngày chạy.
   `DOI` là bảng người, thứ duy nhất bài thử phải bịa ra. */
const HANG_SO = catKhoi('const LCR_TU = 8*60', 'let LC_RANH_LUOT');
function may(NAY, DOI){
  return new Function('NAY', 'DOI', `
    const homNay = () => NAY;
    let LC_HIEN = null, LC_VIEC = {};
    const ME = {id: 'u1', la_lead: true};
    /* CỌC CHO THỨ MÃ THẬT MỚI GỌI TỚI mà bài này không đo. lcCuaNgayTu dựng
       TRỌN một khối lịch — màu, quyền kéo, cờ riêng tư — rồi mới trả ra, trong
       khi bảng giờ rảnh chỉ đọc hai số tu/den của khối ấy. Không có cọc thì hàm
       ngã ngay dòng dựng, và sáu khối dưới im lặng biến mất.
       Không dấu huyền quanh tên hàm ở đây — cả khối nằm trong một chuỗi mẫu. */
    const mauSuKien = l => '';
    const lcDuocSua = l => true;
    ${HANG_SO}
    ${catHam('lcHopBuoc')}
    ${catHam('lcNgayDich')}
    ${catHam('lcHopNgay')}
    ${catHam('lcLuot')}
    ${catHam('lcNguoiCuaLich')}
    ${catHam('lcCuaNgayTu')}
    ${catHam('lcRanhTim')}
    return lcRanhTim;`)(NAY, DOI);
}
const DOI5 = [{id:'u1',ten:'Tracy',la_lead:true},  {id:'u2',ten:'Trang',la_lead:true},
              {id:'u3',ten:'Hùng', la_lead:true},  {id:'u4',ten:'Saam', la_lead:false}];
/* Một dòng `lich_chung` tối thiểu: giờ tính bằng PHÚT kể từ 0h. */
const buoi = (o) => Object.assign({id: 'l'+Math.random().toString(36).slice(2,7),
  ten: 'Buổi kín', pham_vi: 'ca_nhan', nguoi_ids: [], chuc_nang_ids: [], tao_boi: 'u9',
  lap: 'khong', thu: [], ngay_bat_dau: '2026-01-01', ngay_ket_thuc: null}, o);
const dai = (ds) => ({ds, huy: {}, doi: {}, doiToi: {}, tick: {}});

/* Thứ Năm 03/09/2026 · Chủ nhật là 06/09. */
const NAY = '2026-09-03';
/* Mốc dò của mọi khối TRỪ khối ③: một ngày KHÔNG phải hôm nay, để cái sàn
   "bỏ giờ đã trôi qua" không xen vào và phép so đứng yên ở mọi giờ chạy.
   Trước 03/09 mọi khối đều dò từ NAY, nên bài thử xanh lúc nửa đêm và đỏ từ
   8h sáng — một bài thử tự đỏ theo giờ chạy còn tệ hơn không có bài thử. */
const MAI = '2026-09-04';

/* ── ① BUỔI CỦA NGƯỜI NGOÀI NHÓM KHÔNG LÀM NHÓM BẬN ─────────────────────── */
console.log('\n① Chỉ buổi chạm người trong nhóm mới làm nhóm bận');
{
  const f = may(NAY, DOI5);
  const ngoai = buoi({nguoi_ids: ['u4'], tao_boi: 'u4', lap: 'ngay',
                      gio_bat_dau: 8*60, so_phut: 10*60});   // Saam kín cả ngày
  const k = f(dai([ngoai]), ['u1','u2'], 60, MAI);
  /* Một dòng là một NGÀY, khung trống của ngày ấy nằm trong `khung` — hình dạng
     đổi 03/09 (TRI-76), trước đó mỗi dòng là một khe rời với `tu`/`den` phẳng. */
  la('nhóm u1+u2 vẫn rảnh 08:00 dù u4 kín cả ngày',
     k.length === 3 && k[0].khung[0].tu === 8*60,
     'quên lọc theo tập người dự thì mọi buổi của mọi người đều làm nhóm bận: ' + JSON.stringify(k[0]));

  const trong = f(dai([Object.assign({}, ngoai, {nguoi_ids: ['u2']})]), ['u1','u2'], 60, MAI);
  la('cùng buổi ấy, nếu chạm u2 thì ngày đó hết khe',
     trong.every(x => x.ngay !== NAY), JSON.stringify(trong));
}

/* ── ② KHE PHẢI ĐỦ DÀI ──────────────────────────────────────────────────── */
console.log('\n② Kẽ hở ngắn hơn buổi thì không phải một khe');
{
  const f = may(NAY, DOI5);
  /* Kín 08:00–09:00 và 09:30–23:00 → chỉ còn đúng một kẽ 30 phút.
     Buổi sau phải chạy tới 23:00 chứ không tới 18:00 như bản đầu của bài này:
     ngày làm việc nới thành 08:00–23:00 hôm 03/09 (TRI-76), nên dừng ở 18h là
     để hở một khoảng năm tiếng và cả khối này không còn đo cái nó định đo. */
  const ds = [buoi({nguoi_ids:['u2'], lap:'ngay', gio_bat_dau:8*60,      so_phut:60}),
              buoi({nguoi_ids:['u2'], lap:'ngay', gio_bat_dau:9*60+30,   so_phut:13*60+30})];
  la('buổi 60 phút không nhận kẽ 30 phút',
     f(dai(ds), ['u1','u2'], 60, MAI).length === 0);
  la('buổi 30 phút thì nhận, đúng 09:00',
     (k => k.length && k[0].khung[0].tu === 9*60)(f(dai(ds), ['u1','u2'], 30, MAI)));
}

/* ── ③ GIỜ ĐÃ TRÔI QUA CỦA HÔM NAY ──────────────────────────────────────── */
console.log('\n③ Hôm nay không gợi ý một giờ đã trôi qua');
{
  const f = may(NAY, DOI5);
  /* Khối DUY NHẤT dò từ chính hôm nay — cái sàn "bỏ giờ đã trôi qua" chỉ hạ
     xuống ở ngày `homNay()`, nên dò từ MAI là lọc ra một mảng rỗng rồi tuyên bố
     mọi phần tử của nó đều đạt. Khối này xanh suốt từ 03/09 vì đúng lẽ ấy. */
  const k = f(dai([]), ['u1','u2'], 60, NAY);
  const bay = new Date();
  const homNayCo = k.filter(x => x.ngay === NAY);
  la('khe của hôm nay không sớm hơn giờ hiện tại',
     homNayCo.every(n => n.khung.every(x => x.tu >= bay.getHours()*60 + bay.getMinutes())),
     'gợi ý 08:00 lúc 15h chiếm mất một trong ba chỗ mà không dùng được: ' + JSON.stringify(homNayCo));
}

/* ── ④ CHỦ NHẬT ĐỨNG NGOÀI ──────────────────────────────────────────────── */
console.log('\n④ Không gợi ý vào Chủ nhật');
{
  const f = may(NAY, DOI5);
  const k = f(dai([]), ['u1','u2'], 60, NAY);
  la('không khe nào rơi vào Chủ nhật',
     k.every(x => new Date(x.ngay+'T00:00:00').getDay() !== 0),
     'ngày rỗng nhất trong tuần luôn thắng, nên thiếu vế này là ba gợi ý dồn vào CN: '
       + JSON.stringify(k.map(x => x.ngay)));
}

/* ── ⑤ BA NGÀY GẦN NHẤT, MỖI NGÀY LIỆT KÊ MỌI KHUNG ─────────────────────────
   LUẬT ĐỔI 03/09 (TRI-76), ba ca cũ ở đây viết theo bản đầu. Tracy: *"3 dòng là
   3 ngày gần nhất, mỗi ngày cùng trống những khung nào thì liệt kê ra chứ ko chỉ
   đề xuất 1 khung"* — nên đơn vị của một dòng thôi là một KHE, nay là một NGÀY,
   và luật "chỉ một ngày có khe thì lấp bằng khe thứ hai của ngày ấy" không còn
   chỗ đứng: mọi khung của ngày ấy vốn đã nằm sẵn trong dòng của nó.
   Cùng lần đổi ấy nghỉ trưa 12:00–13:30 vào thuật toán như một khoảng bận cố
   định, nên một ngày trống trơn KHÔNG còn là một khung dài mà là hai. */
console.log('\n⑤ Ba ngày gần nhất, mỗi ngày bày đủ khung của ngày ấy');
{
  const f = may(NAY, DOI5);
  const k = f(dai([]), ['u1','u2'], 60, MAI);
  la('đúng ba ngày', k.length === 3, JSON.stringify(k));
  la('ba ngày khác nhau', new Set(k.map(x => x.ngay)).size === 3,
     'ba khe cùng một buổi sáng là ba dòng nói cùng một điều: ' + JSON.stringify(k));
  la('ba ngày xếp tăng dần', k.every((x, i) => !i || x.ngay > k[i-1].ngay),
     JSON.stringify(k.map(x => x.ngay)));
  la('ngày trống trơn tách làm hai khung quanh nghỉ trưa',
     k[0].khung.length === 2 && k[0].khung[0].den === 12*60 && k[0].khung[1].tu === 13*60+30,
     'nghỉ trưa đi vào thuật toán như một khoảng bận, không phải một nhánh riêng: '
       + JSON.stringify(k[0].khung));
  la('các khung trong cùng một ngày không đè lên nhau',
     k.every(n => n.khung.every((x, i) => !i || x.tu >= n.khung[i-1].den)), JSON.stringify(k));

  /* Ngày kín đặc thì BỎ QUA và lấy ngày kế tiếp — một dòng "kín cả ngày" chiếm
     chỗ mà không chọn được gì. Kín ĐÚNG 04/09 (`lap:'khong'`) và kín trọn ngày
     làm việc 08:00–23:00, vì hở tới 23h là ngày ấy vẫn còn khung. */
  const kin = buoi({nguoi_ids:['u2'], lap:'khong', ngay_bat_dau:MAI,
                    gio_bat_dau:8*60, so_phut:15*60});
  const k2 = f(dai([kin]), ['u1','u2'], 60, MAI);
  la('ngày kín đặc rơi khỏi danh sách, ngày kế tiếp lấp vào',
     k2.length === 3 && !k2.some(x => x.ngay === MAI), JSON.stringify(k2.map(x => x.ngay)));
}

/* ── ⑥ LỚP RIÊNG TƯ VÀ LUẬT ẨN/HIỆN ─────────────────────────────────────── */
console.log('\n⑥ Chỉ giờ ra màn hình, tên buổi thì không');
{
  const VE = catHam('lcVeRanh');
  la('không in tên buổi, không in ghi chú',
     !/\.ten|\bo\.ten|noi_dung/.test(VE),
     'dữ liệu có sẵn cả tên; in ra là phơi lịch riêng của cả đội — RFC 5545 VFREEBUSY chỉ truyền giờ');
  la('khối ẩn khi nhóm dưới hai người', /nguoi\.length < 2\)\{ o\.hidden = true/.test(VE),
     'một mình thì không có ai để mà so giờ');
  la('chốt số lượt TRƯỚC await, so lại SAU',
     /const luot = \+\+LC_RANH_LUOT;[\s\S]*?await lcLay[\s\S]*?if \(luot !== LC_RANH_LUOT\) return;/.test(VE),
     'bẫy ① của sổ làn: hai lượt chồng nhau thì lượt về sau ghi đè lượt về trước');
  la('dò lại ô sau khi chờ, cửa có thể đã đóng',
     /if \(!khoi \|\| !tieu \|\| !ds\) return;/.test(VE));

  const CHON = catHam('lcChonKhe');
  la('bấm một khe thì điền cả ngày lẫn giờ', /lc-tu[\s\S]*?gioDat\('lc-gio'/.test(CHON));
  la('bấm một khe thì KHÔNG dò lại', !/lcVeRanh\(\)/.test(CHON),
     'dò lại làm ba dòng trượt đi một nấc ngay dưới ngón tay và dòng vừa bấm biến mất');

  la('mời hoặc bỏ người thì tính lại', /lcVeRanh\(\);\n\}/.test(catHam('lcVeMoi')),
     'ba đường đổi người dự đều đi qua lcVeMoi — móc ở đó thì không sót đường nào');
  la('nhóm dự hỏi lcNguoiCuaLich, không tự cộng tay',
     /lcNguoiCuaLich\(\{pham_vi: n\.pv/.test(catHam('lcRanhNhom')),
     'luật "ai thuộc buổi này" phải đúng một bản');
  la('dò trên dải 14 ngày riêng, không dùng dải đang vẽ',
     /await lcLay\(tu, lcNgayDich\(tu, LCR_NGAY - 1\)\)/.test(VE),
     'LC_HIEN chỉ giữ dải đang vẽ — xem nấc Ngày thì nó có đúng một ngày');
  la('lcLuot nhận dải làm tham số', /function lcLuot\(l, goc, d\)/.test(SRC),
     'đọc LC_HIEN trong đó là tra sổ dời của một quãng ngày khác');
}

console.log(`\n${truot ? '❌' : '✅'} ${dat} ca đạt${truot ? ', ' + truot + ' ca trượt' : ''}.\n`);
process.exit(truot ? 1 : 0);
