/* THỬ: KÉO KHỐI SỰ KIỆN TRÊN LƯỚI LỊCH TRÌNH
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 02/09: *"trong bảng timeline tôi thấy khối sự kiện chưa kéo được, cho nó
   kéo được giống khối task đi"* → duyệt phương án B: kéo xong thì hỏi phạm vi
   *Sự kiện này · Tất cả sự kiện*, đúng khuôn Lịch Google.

   Sáu ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · GHI NHẦM BẢNG. `tlgKeoTha` là cửa ra chung cho cả việc lẫn sự kiện. Nhánh
       rẽ đứng sai chỗ thì một cú kéo sự kiện chạy tiếp xuống `tlgLuuKhoang` và
       ghi vào bảng `task` bằng một mã lịch — câu lệnh chạy trót lọt, không lỗi,
       chỉ là dữ liệu sai. Đây là ca tệ nhất của cả tính năng.

     · MỘT BUỔI HOÁ HAI. Buổi dời đi mà không rời cột cũ thì trên lưới có hai
       khối của cùng một cuộc họp, và không gì trên màn hình nói cái nào đúng.

     · BUỔI DỜI QUA MỐC TUẦN BIẾN MẤT. Khoá của lượt là NGÀY GỐC. Hỏi ngoại lệ
       đúng dải đang xem thì buổi thứ Hai 31/08 dời sang thứ Ba 01/09 không có
       dòng nào đọc được — nó rơi khỏi lịch, im lặng.

     · KHOÁ CHẠY THEO CHỖ MỚI. Ghi ngoại lệ bằng ngày ĐÃ DỜI thay vì ngày gốc thì
       lượt gốc mọc lại ở chỗ cũ ngay lượt vẽ sau — lời cảnh báo viết sẵn trên
       bảng `lich_chung_ngoai_le` từ ngày dựng nó.

     · GỬI CỘT CHƯA CÓ LÀ HỎNG CẢ CÂU. `so_phut_moi` chỉ được vào gói khi cờ
       `CO_DOI_PHUT` bật — không phải một trường bị bỏ qua, mà cả cú dời hỏng.

     · TAY NẮM MỌC CHO NGƯỜI KHÔNG ĐƯỢC SỬA. Máy chủ sẽ từ chối, nhưng người dùng
       chỉ biết sau khi đã kéo xong — bày ra một thao tác rồi nuốt lời.

   Chạy:  node production/tinh-thuc-app/thu-keo-su-kien.js
*/
const fs = require('fs');
const path = require('path');
const GOC = __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(GOC, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(GOC, 'nang-cap-doi-buoi-rieng.sql'), 'utf8');

function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j);
}
/* Lấy TRỌN một hàm theo tên, đếm ngoặc nhọn. Nhờ nó mà khối ⑤ chạy MÃ THẬT chứ
   không chép một bản thứ hai vào bài thử — bản chép thì lệch dần rồi bài thử
   xanh trong khi app đỏ. */
function catHam(ten){
  let dau = SRC.indexOf('function ' + ten + '(');
  if (dau < 0) throw new Error('Khong thay ham: ' + ten);
  /* Nuốt cả tiền tố `async` nếu có. Thiếu nó thì hàm lấy ra vẫn đúng cú pháp cho
     tới khi gặp `await` bên trong — lúc ấy mới ngã, và ngã ở một chỗ chẳng liên
     quan gì tới nguyên nhân. */
  if (SRC.slice(dau - 6, dau) === 'async ') dau -= 6;
  let i = SRC.indexOf('{', dau), sau = 0;
  for (let j = i; j < SRC.length; j++){
    if (SRC[j] === '{') sau++;
    else if (SRC[j] === '}'){ sau--; if (!sau) return SRC.slice(dau, j+1); }
  }
  throw new Error('Ham khong dong ngoac: ' + ten);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── ① CỬA RA CHUNG PHẢI RẼ ĐÚNG BẢNG ───────────────────────────────────── */
console.log('\n① tlgKeoTha rẽ sang đường của lịch — sai chỗ là sự kiện ghi vào bảng task');
{
  const TH = catHam('tlgKeoTha');
  const iRe  = TH.indexOf('lcKeoTha(');
  const iViec = TH.indexOf('tlgLuuKhoang(');
  la('có nhánh rẽ sang lcKeoTha', iRe > 0, 'sự kiện sẽ chạy tiếp xuống đường của việc');
  la('nhánh rẽ đứng TRƯỚC tlgLuuKhoang', iRe > 0 && iViec > 0 && iRe < iViec,
     'đứng sau thì mã lịch được ghi vào bảng task — chạy trót lọt, dữ liệu sai');
  la('nhánh rẽ có return, không rơi tiếp', /if\s*\(k\.lich\)\s*return/.test(TH),
     'thiếu return là ghi cả hai bảng');
  la('hai đích ngoài lưới không nhận sự kiện',
     /const dich = k\.lich \? null : tlgDichNgoai/.test(TH),
     'thả sự kiện lên kho là gỡ giờ của nó — một buổi không giờ thì không là buổi');
  la('vùng thả không sáng lên khi đang kéo sự kiện',
     /if \(!k\.lich\) tlgSangDich\(tlgDichNgoai/.test(catHam('tlgKeoChay')),
     'sáng vùng rồi thả xuống không làm gì là hứa một điều rồi nuốt lời');
}

/* ── ② DANH TÍNH SỰ KIỆN ĐI RIÊNG, KHÔNG MƯỢN `id` ──────────────────────── */
console.log('\n② tlgKeoMo — mã lịch không được lọt vào chỗ của mã việc');
{
  const MO = catHam('tlgKeoMo');
  la('chữ ký nhận thêm lich, lichNgay',
     /function tlgKeoMo\(e, id, mep, lich, lichNgay\)/.test(MO));
  la('TLG_KEO cất cả hai', /lich: lich \|\| 0/.test(MO) && /lichNgay: lichNgay \|\| ''/.test(MO));
  const VE = catKhoi('    if (k.lich){', '/* KHỐI PHIÊN');
  la('ba cửa kéo của khối sự kiện đều gửi id = 0',
     (VE.match(/tlgKeoMo\(event,0,'(tren|duoi|than)',/g) || []).length === 3,
     'một mã lịch lọt vào chỗ `id` sẽ ghi nhầm bảng mà không một tiếng kêu');
  la('gửi kèm NGÀY GỐC của lượt', (VE.match(/,\$\{k\.lich\},'\$\{k\.ngay\}'\)/g) || []).length === 3);
}

/* ── ③ TAY NẮM CHỈ MỌC CHO NGƯỜI ĐƯỢC SỬA ───────────────────────────────── */
console.log('\n③ Quyền — bày một thao tác mà máy chủ từ chối là nuốt lời');
{
  const VE = catKhoi('    if (k.lich){', '/* KHỐI PHIÊN');
  la('hai tay nắm gác sau k.sua', /const namL = k\.sua/.test(VE));
  la('thân khối cũng gác sau k.sua', /k\.sua \? `\\n\s+onpointerdown="tlgKeoMo\(event,0,'than'/.test(VE));
  /* LUẬT ĐỔI 04/09 — Tracy: *"với các sự kiện thì chỉ có host mới có
     thể thay đổi thông tin và thời gian"*. Vế `la_lead` của bản cũ mở cửa cho
     bất kỳ ai đeo cờ lead sửa lịch của mọi người, mà cả bảy người trong đội đều
     đang bật cờ ấy — nên trên thực tế luật cũ là ai cũng sửa được lịch của ai.
     Luật nay nằm ở ĐÚNG MỘT CHỖ (`lcDuocSua`), ba chỗ chép tay đã gom về đó,
     nên ca này soi cả hai đầu: nơi gọi, và câu luật. Hàng rào thật vẫn ở máy
     chủ — `nang-cap-quyen-host-su-kien.sql`, chính sách `sua_lich` chỉ `tao_boi`. */
  la('lcCuaNgay phát ra cờ sua, và luật ấy chỉ có một bản',
     /sua: lcDuocSua\(l\)/.test(catHam('lcCuaNgayTu'))
       && /return !!\(ME && l && l\.tao_boi === ME\.id\)/.test(catHam('lcDuocSua')),
     'phải đọc đúng luật ghi `sua_lich` của máy chủ: CHỈ host, không nới cho lead');
  la('lcMoBuoi chặn cú click bắn theo sau cú kéo',
     /TLG_VUA_KEO < 400/.test(catHam('lcMoBuoi')),
     'thiếu thì thả tay xong là cửa buổi bật ra, chen ngang thao tác vừa xong');
}

/* ── ④ GHI XUỐNG ĐÂU ────────────────────────────────────────────────────── */
console.log('\n④ lcLuuDoi — khoá là NGÀY GỐC, và cột chưa có thì không gửi');
{
  const LD = catHam('lcLuuDoi');
  la('ngoại lệ khoá bằng ngay_goc, không bằng ngày đã dời',
     /ngay_goc: moi\.goc/.test(LD),
     'khoá chạy theo chỗ mới thì lượt gốc mọc lại ở chỗ cũ ngay lượt vẽ sau');
  la('upsert đúng cặp khoá', /onConflict: 'lich_id,ngay_goc'/.test(LD),
     'dời lần thứ hai phải ghi đè dòng cũ, không đẻ thêm dòng');
  la('so_phut_moi chỉ vào gói khi cờ bật', /if \(CO_DOI_PHUT\) dong\.so_phut_moi = phut/.test(LD),
     'gửi cột chưa tồn tại là hỏng CẢ câu, không phải bỏ qua một trường');
  la('chưa có cột thì nói ra, không im lặng nuốt', /nang-cap-doi-buoi-rieng\.sql/.test(LD));
  la('phạm vi Tất cả chỉ đổi ngày khi sự kiện KHÔNG lặp',
     /if \(moi\.ngay && l && l\.lap === 'khong'\)/.test(LD),
     'đổi ngày cả chuỗi là viết lại luật lặp sau lưng người kéo');
  la('sự kiện không lặp thì không hỏi phạm vi',
     /if \(l\.lap === 'khong'\) return void await lcLuuDoi\('tat_ca', moi\)/.test(catHam('lcKeoTha')),
     'ba phạm vi giống hệt nhau thì bày ra là bắt đọc để rồi chọn gì cũng thế');
  la('bỏ giữa chừng thì vẽ lại', /await veTimeline\(\)/.test(catHam('lcThoiKeo')),
     'khối đang nằm ở chỗ ngón tay thả, một chỗ máy chủ chưa từng biết');
  la('ghi hỏng cũng vẽ lại', /if \(r\.error\)\{[\s\S]*?await veTimeline\(\)/.test(LD));
}

/* ── ⑤ CHẠY THẬT: MỘT BUỔI DỜI ĐI PHẢI RỜI CỘT CŨ ───────────────────────── */
console.log('\n⑤ lcCuaNgay chạy thật — bốn ca dời buổi');
{
  const nap = new Function('CTX', `
    with (CTX) {
      /* CỌC CHO THỨ MÃ THẬT MỚI GỌI TỚI mà khối này không đo: màu của chuỗi, và
         quyền kéo một buổi. lcCuaNgayTu dựng TRỌN một khối lịch rồi mới trả ra,
         nên thiếu hai cái tên này là hàm ngã trước khi bốn ca dời buổi đo được
         gì. Quyền kéo có khối ③ ngay trên gác, và nó gác bằng cách soi mã.
         Không dấu huyền quanh tên hàm ở đây — cả khối nằm trong một chuỗi mẫu. */
      const mauSuKien = l => '';
      const lcDuocSua = l => true;
      ${catHam('lcHopBuoc')}
      ${catHam('lcChoToi')}
      ${catHam('lcHopNgay')}
      ${catHam('lcLuot')}
      ${catHam('lcCuaNgayTu')}
      ${catHam('lcCuaNgay')}
      return lcCuaNgay;
    }`);
  /* Chuỗi họp mỗi thứ Hai, 09:00, 60 phút. Thứ Hai 31/08 và 07/09 năm 2026. */
  const chuoi = {id: 7, ten: 'Họp tuần', lap: 'tuan', thu: [1], gio_bat_dau: 540,
                 so_phut: 60, ngay_bat_dau: '2026-08-01', ngay_ket_thuc: null,
                 pham_vi: 'cong_ty', tao_boi: 'u1', mau: null};
  const chay = (doiDs) => {
    const doi = {}, doiToi = {};
    doiDs.forEach(n => {
      doi[n.lich_id+'|'+n.ngay_goc] = n;
      const d = n.ngay_moi || n.ngay_goc;
      (doiToi[n.lich_id+'|'+d] || (doiToi[n.lich_id+'|'+d] = [])).push(n.ngay_goc);
    });
    const CTX = {LC_HIEN: {ds: [chuoi], huy: {}, doi, doiToi, tick: {}},
                 LC_VIEC: {}, ME: {id: 'u1', la_lead: true}};
    const f = nap(CTX);
    return g => f(g);
  };

  { const f = chay([]);
    la('chưa dời: buổi đứng ở thứ Hai 31/08, 09:00',
       f('2026-08-31').length === 1 && f('2026-08-31')[0].tu === 540);
    la('chưa dời: thứ Ba 01/09 trống', f('2026-09-01').length === 0); }

  { /* Dời buổi 31/08 sang 01/09 lúc 14:00, dài 90 phút. */
    const f = chay([{lich_id: 7, ngay_goc: '2026-08-31', kieu: 'doi',
                     ngay_moi: '2026-09-01', gio_moi: 840, so_phut_moi: 90}]);
    la('đã dời: cột cũ 31/08 rỗng — một buổi không hoá hai',
       f('2026-08-31').length === 0,
       'thiếu nhánh này là hai khối cùng một cuộc họp đứng hai giờ khác nhau');
    const o = f('2026-09-01');
    la('đã dời: hiện ở cột mới 01/09', o.length === 1);
    la('đã dời: mang giờ mới 14:00–15:30', o[0] && o[0].tu === 840 && o[0].den === 930);
    la('đã dời: KHOÁ vẫn là ngày gốc 31/08', o[0] && o[0].ngay === '2026-08-31',
       'ô tick, ghi chú và việc đã đẻ đều neo vào khoá này');
    la('đã dời: có cờ doi để cửa buổi nói ra', o[0] && o[0].doi === true);
    la('buổi thứ Hai kế tiếp 07/09 không bị đụng',
       f('2026-09-07').length === 1 && f('2026-09-07')[0].tu === 540,
       'ngoại lệ chỉ chạm ĐÚNG một lượt, không chạm luật lặp'); }

  { /* Chỉ đổi giờ, không đổi ngày. */
    const f = chay([{lich_id: 7, ngay_goc: '2026-08-31', kieu: 'doi',
                     ngay_moi: null, gio_moi: 600, so_phut_moi: null}]);
    const o = f('2026-08-31');
    la('chỉ đổi giờ: ở nguyên cột cũ, giờ mới 10:00', o.length === 1 && o[0].tu === 600);
    la('chỉ đổi giờ: độ dài giữ theo luật lặp', o[0] && o[0].den === 660,
       'so_phut_moi rỗng nghĩa là giữ nguyên, không phải bằng 0'); }

  { /* Ngoại lệ MỒ CÔI: luật lặp đổi sau khi có người dời — 02/09 là thứ Tư,
       không còn lượt nào sinh ra ở đó. */
    const f = chay([{lich_id: 7, ngay_goc: '2026-09-02', kieu: 'doi',
                     ngay_moi: '2026-09-03', gio_moi: 600, so_phut_moi: null}]);
    la('ngoại lệ mồ côi không dựng lại một buổi đã không còn trong luật',
       f('2026-09-03').length === 0,
       'bày nó ra là một cuộc họp mọc lại từ một dòng cũ'); }
}

/* ── ⑥ CỬA SỔ HỎI NGOẠI LỆ PHẢI NỚI RA HAI BÊN ──────────────────────────── */
console.log('\n⑥ lcLay — buổi dời qua mốc tuần không được biến mất');
{
  const LY = catHam('lcLay');
  la('cửa sổ ngoại lệ nới ±31 ngày',
     /lcNgayDich\(tu, -31\)/.test(LY) && /lcNgayDich\(den, 31\)/.test(LY),
     'hỏi đúng dải đang xem thì buổi dời từ tuần trước sang không dòng nào đọc được');
  la('đọc thêm ngay_moi, gio_moi', /'lich_id,ngay_goc,kieu,ngay_moi,gio_moi'/.test(LY));
  la('so_phut_moi chỉ hỏi khi cờ bật', /CO_DOI_PHUT \? ',so_phut_moi' : ''/.test(LY),
     'hỏi một cột chưa có là cả dải lịch thành màn báo lỗi');
  la('dựng đủ hai sổ tra doi và doiToi', /const doi = \{\}, doiToi = \{\}/.test(LY));
  la('lcLay trả cả hai sổ ra ngoài', /\{ds: rl\.data \|\| \[\], huy, doi, doiToi, tick/.test(LY));
  la('lcNgayDich đi qua Date, không cộng chuỗi',
     /d\.setDate\(d\.getDate\(\) \+ n\)/.test(catHam('lcNgayDich')),
     'cuối tháng và năm nhuận là chỗ phép cộng tay sai mà không kêu');
}

/* ── ⑦ MỘT CỬA DUY NHẤT ĐỌC GIỜ CỦA MỘT LƯỢT ────────────────────────────── */
console.log('\n⑦ Không chỗ nào còn đọc thẳng l.gio_bat_dau của một lượt');
{
  for (const [ten, ham] of [['lcMoBuoi', catHam('lcMoBuoi')],
                            ['lcDeViec', catHam('lcDeViec')]]){
    la(ten + ' đi qua lcLuot', /lcLuot\(l, /.test(ham));
    la(ten + ' không còn đọc thẳng l.gio_bat_dau', !/l\.gio_bat_dau/.test(ham),
       'cửa nói một giờ mà lưới bày giờ khác thì người dùng tin cửa, rồi lỡ buổi');
  }
  /* lcCuaNgay tách khỏi vòng trên vì nó có ĐÚNG MỘT ngoại lệ có chủ ý, thêm
     03/09 (TRI-85, Tracy: *"lịch A bị dời lịch thì sẽ hiện ở cả ngày rời cũ lẫn
     ngày mới"*). Cái BÓNG ở ngày cũ phải đứng đúng khung giờ nó LẼ RA chiếm, mà
     giờ ấy chỉ có luật lặp mới biết — `luot.tu` lúc đó đã là giờ sau khi dời.
     Nên ca này không cấm nữa, mà ĐẾM: đúng một lần đọc, và nằm đúng ở nhánh
     bóng. Mọc thêm một lần đọc thứ hai ở đâu đó là ca này đỏ lại. */
  {
    const ham = catHam('lcCuaNgayTu');
    la('lcCuaNgay đi qua lcLuot', /lcLuot\(l, /.test(ham));
    la('lcCuaNgay chỉ đọc thẳng l.gio_bat_dau ở đúng nhánh BÓNG',
       (ham.match(/l\.gio_bat_dau/g) || []).length === 1
         && /const g0 = Number\(l\.gio_bat_dau\) \|\| 0/.test(ham),
       'cửa nói một giờ mà lưới bày giờ khác thì người dùng tin cửa, rồi lỡ buổi');
  }
  la('lcDeViec đặt việc vào NGÀY buổi thật sự diễn ra',
     /ngay: luot\.ngay/.test(catHam('lcDeViec')));
  la('lcDeViec vẫn khoá lich_ngay bằng ngày gốc',
     /lich_ngay: ngay\}/.test(catHam('lcDeViec')),
     'khoá đi theo chỗ mới là mọi bảng phụ mất đường tra nhau');
  la('lcDeVieckHomNay gửi ngày gốc của lượt, không gửi hôm nay',
     /lcDeViec\(o\.lich, o\.ngay\)/.test(catHam('lcDeVieckHomNay')));
}

/* ── ⑧ VIỆC ĐÃ ĐẺ ĐI THEO, NHƯNG CHỈ KHI CÒN SẠCH ───────────────────────── */
console.log('\n⑧ lcTheoViec — không ghi đè một việc người ta đã cầm trong tay');
{
  const TV = catHam('lcTheoViec');
  la('chỉ đụng việc còn Chua_lam', /v\.trang_thai !== 'Chua_lam'/.test(TV));
  la('và chưa có phiên deep work nào', /phien_deepwork/.test(TV),
     'việc đã chạy phiên là chuyện đã xảy ra — ghi đè giờ của nó là sửa lại quá khứ');
  la('dọn bản tra sau khi ghi', /delete LC_VIEC/.test(TV) && /tlQuenKho\(\)/.test(TV));
}

/* ── ⑨ TỆP SQL ──────────────────────────────────────────────────────────── */
console.log('\n⑨ nang-cap-doi-buoi-rieng.sql');
{
  la('thêm cột so_phut_moi, chạy lại vô hại',
     /add column if not exists so_phut_moi smallint/.test(SQL));
  la('NỚI luật ngoaile_doi_du_tham_so cho độ dài làm chứng được',
     /kieu <> 'doi'[\s\S]{0,120}so_phut_moi is not null/.test(SQL),
     'thêm cột mà không nới thì cú kéo MÉP thuần tuý bị máy chủ chặn');
  la('drop rồi add, không bọc if not exists',
     /drop constraint if exists ngoaile_doi_du_tham_so/.test(SQL),
     'bọc thì lần sau nới thêm một trường, chạy lại tệp này không vá được gì');
  la('có dấu vết riêng ở đầu tệp cho SO-SQL.sql',
     /Dấu vết riêng[\s\S]{0,120}so_phut_moi/.test(SQL));
  la('có bộ tự kiểm ở cuối', /TỰ KIỂM/.test(SQL));
}

/* ── ⑩ CHẠY THẬT: SOI ĐÚNG GÓI GỬI LÊN MÁY CHỦ ──────────────────────────── */
/* Gói trong một hàm async vì `lcLuuDoi` là hàm async thật — gọi mà không chờ thì
   mọi phép kiểm dưới đây chạy trước lúc gói được dựng, và tất cả đều xanh vì
   chúng soi một mảng còn rỗng. Đúng kiểu bài thử tự nói dối. */
(async () => {
console.log('\n⑩ lcLuuDoi chạy thật — bốn gói, soi từng trường');
{
  const ghi = [];
  const sbGia = {from(bang){ return {
    upsert(dong, opt){ ghi.push({bang, phep: 'upsert', dong, opt}); return Promise.resolve({error: null}); },
    update(patch){ ghi.push({bang, phep: 'update', patch});
      return {eq: () => Promise.resolve({error: null})}; },
    select(){ return {eq: () => ({limit: () => Promise.resolve({data: [], error: null})})}; }
  };}};
  const chuoi = {id: 7, ten: 'Họp tuần', lap: 'tuan', gio_bat_dau: 540, so_phut: 60,
                 ngay_bat_dau: '2026-08-01', ngay_ket_thuc: null};
  const le    = {id: 9, ten: 'Gặp đối tác', lap: 'khong', gio_bat_dau: 600, so_phut: 60,
                 ngay_bat_dau: '2026-09-01', ngay_ket_thuc: null};
  const nap = (coCot) => {
    const CTX = {sb: sbGia, ME: {id: 'u1'}, CO_DOI_PHUT: coCot, CO_VIEC_BUOI: false,
                 LC_HIEN: {ds: [chuoi, le]}, LC_VIEC: {}, LC_KEO: null,
                 hopHoiDong(){}, toast(c){ CTX.chu = c; }, tlQuenKho(){},
                 veTimeline: async () => {}, lamMoiCuaToi: async () => {},
                 ngayDep: g => g, tlgHHMM: p => String(p),
                 tlgVN: null, chu: ''};
    /* lcTheoChuoi là đường MÁY CHỦ kéo việc của CẢ ĐỘI đi theo giờ mới của một
       chuỗi (TRI-109, 05/09) — mã thật gọi nó ở nhánh phạm vi Tất cả. Cắt thật
       chứ không tiêm bản giả: với CO_VIEC_BUOI tắt nó quay ra ngay dòng đầu,
       đúng như lcTheoViec ngay trên, nên bốn ca dưới vẫn soi được đúng cái gói
       gửi lên máy chủ mà không phải bịa ra một hàm thứ hai. */
    CTX.f = new Function('CTX', `with (CTX) {
      ${catHam('lcTheoViec')}
      ${catHam('lcTheoChuoi')}
      ${catHam('lcLuuDoi')}
      return lcLuuDoi; }`)(CTX);
    return CTX;
  };

  { const C = nap(true);
    ghi.length = 0;
    await C.f('buoi', {lich: 7, goc: '2026-08-31', tu: 960, den: 1050, ngay: null});
    const g = ghi[0] || {};
    la('① Sự kiện này → ghi vào lich_chung_ngoai_le', g.bang === 'lich_chung_ngoai_le');
    la('① khoá là NGÀY GỐC, không phải ngày đã dời', g.dong && g.dong.ngay_goc === '2026-08-31',
       JSON.stringify(g.dong));
    la('① kieu = doi', g.dong && g.dong.kieu === 'doi');
    la('① mang đủ giờ và độ dài', g.dong && g.dong.gio_moi === 960 && g.dong.so_phut_moi === 90);
    la('① không đổi ngày thì ngay_moi rỗng', g.dong && g.dong.ngay_moi === null,
       'gửi một ngày bằng ngày gốc là ghi một sự thay đổi không có');
    la('① KHÔNG chạm bảng lich_chung', !ghi.some(x => x.bang === 'lich_chung'),
       'phạm vi một buổi mà chạm dòng chuỗi là dời cả chuỗi'); }

  { const C = nap(false);          // máy chủ chưa chạy nang-cap-doi-buoi-rieng.sql
    ghi.length = 0;
    await C.f('buoi', {lich: 7, goc: '2026-08-31', tu: 960, den: 1050, ngay: null});
    const g = ghi[0] || {};
    la('② chưa chạy SQL → không gửi so_phut_moi',
       g.dong && !('so_phut_moi' in g.dong),
       'gửi cột chưa tồn tại là hỏng CẢ câu, cú dời không lưu được gì');
    la('② vẫn gửi được giờ mới', g.dong && g.dong.gio_moi === 960); }

  { const C = nap(true);
    ghi.length = 0;
    await C.f('tat_ca', {lich: 7, goc: '2026-08-31', tu: 960, den: 1050, ngay: '2026-09-03'});
    const g = ghi[0] || {};
    la('③ Tất cả → cập nhật dòng chuỗi lich_chung', g.bang === 'lich_chung' && g.phep === 'update');
    la('③ đổi giờ và độ dài của cả chuỗi',
       g.patch && g.patch.gio_bat_dau === 960 && g.patch.so_phut === 90);
    la('③ chuỗi ĐỊNH KỲ thì ngày KHÔNG đi theo',
       g.patch && !('ngay_bat_dau' in g.patch),
       'kéo một buổi sang thứ Năm mà cả chuỗi chuyển sang thứ Năm là điều không ai xin'); }

  { const C = nap(true);
    ghi.length = 0;
    await C.f('tat_ca', {lich: 9, goc: '2026-09-01', tu: 780, den: 840, ngay: '2026-09-03'});
    const g = ghi[0] || {};
    la('④ sự kiện KHÔNG lặp thì ngày ĐI THEO', g.patch && g.patch.ngay_bat_dau === '2026-09-03',
       'ở đó "tất cả" và "buổi này" là một chuyện'); }
}

console.log('\n──────────────────────────────');
console.log(`${dat} đạt · ${truot} trượt`);
process.exit(truot ? 1 : 0);
})();
