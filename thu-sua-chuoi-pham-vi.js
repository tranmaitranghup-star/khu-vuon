/* THỬ: CỬA SỬA HỎI PHẠM VI TRƯỚC KHI GHI (TRI-143)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 07/09:

     *"nếu mà tôi ấn vào cửa sổ chỉnh sửa và chỉnh sửa giờ thì nó sửa luôn cả
      chuỗi, chỗ này bạn bổ sung cho tôi cửa sổ hỏi là toàn bộ sự kiện hay chỉ
      sự kiện này"*

   Bài thử canh sáu chỗ mà mã dễ trôi khỏi nhất, cả sáu đều hỏng trong im lặng:

     ① nấc hỏi có đứng TRƯỚC lượt ghi không — đứng sau là đã ghi mất rồi;
     ② ngày gốc có sống sót cú đóng cửa buổi không — `lcDongHan` xoá `LC_BUOI`;
     ③ ba cờ có chết theo cửa không — sót lại là lượt khai sau hiểu nhầm mình;
     ④ nhánh "Sự kiện này" có ghi vào ngoại lệ, và có chừa cột `ngay` ra không;
     ⑤ đổi thêm thứ ngoài giờ thì có DỪNG lại nói ra không, hay ghi nửa vời;
     ⑥ phép so mục đổi khác có báo oan không — chạy thật, không chỉ soi chuỗi.

   Chạy:  node production/tinh-thuc-app/thu-sua-chuoi-pham-vi.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}
function ham(ten){
  const d = SRC.split('\n');
  let tu = -1;
  for (let i = 0; i < d.length; i++){
    if (new RegExp('^(?:async\\s+)?function\\s+' + ten + '\\s*\\(').test(d[i])) tu = i;
    else if (tu >= 0 && d[i] === '}') return d.slice(tu, i + 1).join('\n');
  }
  return '';
}
/* SO THỨ TỰ THÌ BỎ CHÚ THÍCH TRƯỚC ĐÃ — làn TV 05/09 đỏ oan đúng chỗ này: một
   lời nhắc trong chú thích mang tên hàm, và máy đọc thấy nó đứng trước lệnh gọi
   thật. Bỏ cả hai lối chú thích, giữ nguyên số ký tự thì không cần. */
const trui = m => m.replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*\/\/.*$/gm, '');

/* ── ① NẤC HỎI ĐỨNG TRƯỚC LƯỢT GHI ───────────────────────────────────────── */
console.log('\n① lcLuu — hỏi trước, ghi sau');
{
  const luu = trui(ham('lcLuu'));
  const iHoi = luu.indexOf('lcHoiSuaChuoi');
  const iGhi = luu.indexOf(".from('lich_chung').update(dong)");
  la('lcLuu có gọi nấc hỏi', iHoi > 0,
     'không có nấc hỏi thì mọi cú Lưu vẫn viết lại luật lặp như trước 07/09');
  la('nấc hỏi đứng TRƯỚC lượt update', iHoi > 0 && iGhi > 0 && iHoi < iGhi,
     'hỏi sau khi ghi là hỏi một câu đã hết nghĩa');
  la('hỏi xong thì THOÁT, không ghi tiếp', /lcHoiSuaChuoi\(\);[\s\S]{0,80}return false;/.test(luu),
     'thiếu return là hộp hiện lên trong khi câu ghi vẫn chạy — sửa cả chuỗi sau lưng người hỏi');

  la('chỉ hỏi khi đang SỬA', /const goc = LC_SUA \?/.test(luu),
     'nhánh thêm mới không có chuỗi nào để hỏi');
  la('chỉ hỏi khi chuỗi CÓ lặp', /goc\.lap !== 'khong'/.test(luu),
     "sự kiện không lặp thì \"buổi này\" và \"cả chuỗi\" là một chuyện — hỏi là hỏi thừa");
  la('chỉ hỏi khi biết mở từ buổi nào', /&& LC_SUA_NGAY/.test(luu),
     'không có ngày gốc thì không ghi ngoại lệ cho lượt nào được');
  la('chỉ hỏi khi thật sự có gì đổi', /&& dangDoi\)\{/.test(luu),
     'bấm Lưu mà không đổi gì thì không có hai nghĩa nào để hỏi');
  la('hộp hai nấc chỉ hỏi về GIỜ, ba nấc thì hỏi cả mục khác',
     /const dangDoi = gioDoi \|\| \(CO_CAT_CHUOI && mucKhac\.length/.test(luu),
     'nấc giữa ghi được cả tên, nên khi nó có mặt thì đổi tên cũng có hai nghĩa');
  la('cờ phạm vi đọc MỘT lần rồi xoá', /const daChon = LC_SUA_PHAM; LC_SUA_PHAM = null;/.test(luu),
     'để cờ nằm lại là lượt Lưu sau bỏ qua nấc hỏi mà không ai bấm gì');
}

/* ── ② NGÀY GỐC SỐNG SÓT CÚ ĐÓNG CỬA BUỔI ────────────────────────────────── */
console.log('\n② lcSuaChuoi — giữ ngày gốc qua cú đóng cửa buổi');
{
  const sua = trui(ham('lcSuaChuoi'));
  const iDoc = sua.indexOf('LC_BUOI');
  const iDong = sua.indexOf('lcDongHan()');
  const iForm = sua.indexOf('lcMoForm(id,');
  const iDat = sua.indexOf('LC_SUA_NGAY = ngayGoc');
  la('đọc LC_BUOI TRƯỚC lcDongHan', iDoc > 0 && iDong > 0 && iDoc < iDong,
     'lcDongHan xoá LC_BUOI — đọc sau là đọc null, và nhánh "Sự kiện này" mất chỗ ghi');
  la('đặt LC_SUA_NGAY SAU lcMoForm', iDat > 0 && iForm > 0 && iDat > iForm,
     'lcMoForm dọn cờ này về null — đặt trước là đặt rồi bị xoá ngay');
  la('chỉ nhận ngày khi đúng chuỗi đang mở', /LC_BUOI\.id === id/.test(sua),
     'cửa buổi của một chuỗi khác còn mở thì ngày ấy không phải của chuỗi này');
}

/* ── ③ BA CỜ CHẾT THEO CỬA ───────────────────────────────────────────────── */
console.log('\n③ Ba cờ phải trắng khi cửa mở và khi cửa đóng');
for (const [ten, ham_] of [['lcMoForm', ham('lcMoForm')], ['lcDongCua', ham('lcDongCua')]])
  la(ten + ' dọn cả ba cờ',
     /LC_SUA_NGAY = null/.test(ham_) && /LC_SUA_CHO = null/.test(ham_)
       && /LC_SUA_PHAM = null/.test(ham_),
     'một cờ sót lại đổi nghĩa lượt khai kế tiếp, và không chữ nào báo');

/* ── ④ HỘP HAI NẤC, VÀ ĐƯỜNG GHI CỦA NẤC ĐẦU ─────────────────────────────── */
console.log('\n④ Hộp hỏi và nhánh "Sự kiện này"');
{
  const hop = ham('lcHoiSuaChuoi'), theo = trui(ham('lcSuaTheo'));
  la('hộp có nấc "Sự kiện này"', /`buoi`, `Sự kiện này`/.test(hop));
  la('hộp có nấc "Tất cả sự kiện"', /`tat_ca`, `Tất cả sự kiện`/.test(hop));
  la('nấc đầu tiên còn đứng lại mang dấu chọn sẵn', /i \? '' : ' checked'/.test(hop),
     'ba nấc mà không nấc nào chọn sẵn thì bấm Lưu ngay là ghi một thứ chẳng ai chọn');
  la('nút Lưu xanh đặc, nút Hủy là nút phụ',
     /class="ok"[^>]*lcSuaTheo/.test(hop) && /class="phu" onclick="lcThoiSua\(\)"/.test(hop),
     'giữ lại thì xanh đặc, bỏ đi thì nút phụ — luật nút hộp thoại');

  la('nhánh "Sự kiện này" đi qua lcLuuDoi', /lcLuuDoi\('buoi'/.test(theo),
     'ghi thẳng vào lich_chung là đổi cả chuỗi, đúng thứ nấc này hứa sẽ không làm');
  la('nhánh "Sự kiện này" chừa cột ngày ra', /ngay: null/.test(theo),
     'ngày của một chuỗi định kỳ do luật lặp quyết — cửa sửa không có ô nào nói ngày đích');
  la('nhánh "Tất cả" gọi lại lcLuu với cờ đặt sẵn',
     /LC_SUA_PHAM = 'tat_ca'/.test(theo) && /return lcLuu\(\)/.test(theo),
     'đường ghi cũ phải chạy y như trước 07/09, kể cả lượt lcTheoChuoi kéo việc đi theo');
  la('đọc LC_SUA_CHO trước khi lcDongCua dọn nó',
     theo.indexOf('const moi =') > 0 && theo.indexOf('const moi =') < theo.indexOf('lcDongCua()'),
     'lcDongCua dọn sạch cờ của cửa — đọc sau là đọc null');
}

/* ── ⑤ ĐỔI THÊM THỨ NGOÀI GIỜ THÌ DỪNG LẠI, KHÔNG GHI NỬA VỜI ────────────── */
console.log('\n⑤ Đổi thêm thứ ngoài giờ — nói ra, không ghi nửa vời');
{
  const theo = trui(ham('lcSuaTheo'));
  const iKhac = theo.indexOf('k.khac.length');
  const iGhi  = theo.indexOf('lcLuuDoi');
  la('vế k.khac đứng TRƯỚC lượt ghi', iKhac > 0 && iGhi > 0 && iKhac < iGhi,
     'đứng sau là đã ghi giờ xuống ngoại lệ rồi mới báo — đúng nghĩa nửa vời');
  la('có toast nói ra mục nào áp cho cả chuỗi',
     /toast\([^;]*k\.khac\.join/.test(theo),
     'Tracy chốt 07/09: nói thẳng rồi để người ta chọn lại, không im lặng ghi nửa vời');
  la('nói xong thì THOÁT', /k\.khac\.join[\s\S]{0,200}?return false;/.test(theo));
  /* CẮT ĐÚNG KHỐI RỒI HÃY SOI. Bản đầu của phép kiểm này dò `hopHoiDong` trong
     300 ký tự sau vế `k.khac.length` và đỏ oan ngay lượt chạy đầu: cú đóng hộp
     của nhánh KẾ TIẾP nằm gọn trong tầm ấy. Cùng họ với bẫy đã ghi ở làn TV —
     một mẫu dò quét quá xa thì nó đang trả lời một câu hỏi khác câu ta đặt. */
  const khoiKhac = (() => {
    const i = theo.indexOf('k.khac.length');
    const j = theo.indexOf('return false;', i);
    return i > 0 && j > 0 ? theo.slice(i, j) : '';
  })();
  la('KHÔNG đóng hộp ở nhánh này', !!khoiKhac && !/hopHoiDong/.test(khoiKhac),
     'đóng hộp là bắt người ta bấm Lưu lại từ đầu chỉ để đổi một cái nấc');
}

/* ── ⑥ PHÉP SO MỤC ĐỔI KHÁC — CHẠY THẬT ──────────────────────────────────── */
console.log('\n⑥ lcMucChung — chạy thật, canh báo oan');
{
  const i = SRC.indexOf('const LC_MUC_CHUNG = [');
  const j = SRC.indexOf('\n/* Chữ dưới nấc đầu', i);
  if (i < 0 || j < 0) throw new Error('không tìm thấy mốc cắt LC_MUC_CHUNG');
  const {lcMucChung} = new Function(SRC.slice(i, j) + '\nreturn {lcMucChung};')();

  /* Một dòng như kho trả về, và bản `dong` như lcLuu dựng ra khi KHÔNG ai đổi
     gì ngoài giờ. Hai vế cố ý lệch nhau ở đúng những chỗ hai đường vẫn lệch:
     kho trả null cho ô text bỏ trống, form trả chuỗi rỗng; mảng khác thứ tự. */
  const goc = {ten: 'Họp tuần', ghi_chu: '', mau: null, pham_vi: 'khoi',
               chuc_nang_ids: [2, 1], nguoi_ids: [], tieu_diem_ma: null, rieng_tu: false,
               da_chot: true, ca_ngay: false, so_ngay: 1, lap: 'tuan', thu: [1, 3],
               tuan_thang: [], ngay_thang: null, bo_cn: true, buoc: 1, so_lan: null,
               ngay_bat_dau: '2026-09-01', ngay_ket_thuc: null,
               khach_sua: false, khach_moi: true, khach_xem_ds: true,
               gio_bat_dau: 510, so_phut: 60};
  const nhu = () => ({ten: 'Họp tuần', ghi_chu: '', mau: null, pham_vi: 'khoi',
               chuc_nang_ids: [1, 2], nguoi_ids: [], tieu_diem_ma: null, rieng_tu: false,
               da_chot: true, ca_ngay: false, so_ngay: 1, lap: 'tuan', thu: [3, 1],
               tuan_thang: [], ngay_thang: null, bo_cn: true, buoc: 1, so_lan: null,
               ngay_bat_dau: '2026-09-01', ngay_ket_thuc: null,
               khach_sua: false, khach_moi: true, khach_xem_ds: true,
               gio_bat_dau: 600, so_phut: 90});

  la('đổi mỗi giờ thì KHÔNG mục nào bị kể tên',
     lcMucChung(goc, nhu()).length === 0,
     'báo oan ở đây là chối luôn nhánh "Sự kiện này" — người ta không dùng được tính năng');
  la('mảng khác thứ tự không tính là đổi',
     lcMucChung(goc, {...nhu(), thu: [3, 1], chuc_nang_ids: [2, 1]}).length === 0,
     'thứ tự phần tử trong smallint[] không mang nghĩa gì');
  la('ô text bỏ trống: null của kho bằng chuỗi rỗng của form',
     lcMucChung({...goc, ghi_chu: null}, nhu()).length === 0);

  la('đổi tên thì kể tên', lcMucChung(goc, {...nhu(), ten: 'Họp team'}).includes('tên'));
  la('đổi mô tả thì kể mô tả',
     lcMucChung(goc, {...nhu(), ghi_chu: 'mang laptop'}).includes('mô tả'));
  la('đổi thứ thì kể nhịp lặp', lcMucChung(goc, {...nhu(), thu: [1, 4]}).includes('nhịp lặp'));
  la('đổi người mời thì kể người mời',
     lcMucChung(goc, {...nhu(), nguoi_ids: ['a1']}).includes('người mời'));
  la('đổi quyền khách thì kể quyền của khách',
     lcMucChung(goc, {...nhu(), khach_moi: false}).includes('quyền của khách'));

  la('cột máy chủ chưa có thì KHÔNG bị kể tên',
     (() => { const d = nhu(); delete d.mau; delete d.tuan_thang;
              return lcMucChung({...goc, mau: 'xanh', tuan_thang: [2]}, d).length === 0; })(),
     'cờ dò cột tắt thì lcLuu không gửi cột ấy — kể tên nó ra là báo oan');
  la('mỗi tên chỉ kể MỘT lần',
     lcMucChung(goc, {...nhu(), lap: 'thang', thu: [], ngay_thang: 5}).filter(x => x === 'nhịp lặp').length === 1,
     'nhịp lặp là tám cột nhưng người khai chỉ nhìn thấy một ô');
}


/* ── ⑦ GIỜ NỀN — CỬA SỬA BÀY GIỜ THẬT CỦA BUỔI (TRI-145) ─────────────────── */
console.log('\n⑦ Giờ nền — cửa sửa nói giờ của buổi bạn đang đứng');
{
  const form = trui(ham('lcMoForm')), sua = trui(ham('lcSuaChuoi')), luu = trui(ham('lcLuu'));

  la('lcMoForm nhận lượt cụ thể', /function lcMoForm\(id, luot\)/.test(form),
     'không có lượt thì form chỉ biết giờ của luật, đúng chỗ hở mà nhát này chữa');
  la('giờ nền lấy từ lượt, ngã về luật khi không có',
     /const gioNen\s*=\s*luot \? luot\.tu/.test(form)
       && /const phutNen\s*=\s*luot \? luot\.phut/.test(form),
     'nút ＋ Sự kiện gọi không kèm lượt — nhánh ngã về phải còn nguyên');
  la('cả ba ô giờ cùng đọc một mốc',
     /id="lc-phut" value="\$\{phutNen\}"/.test(form)
       && /const gioDau = tlgHHMM\(gioNen\)/.test(form)
       && /lcGioCong\(gioDau, phutNen\)/.test(form),
     'ô phút ẩn lệch khỏi hai ô giờ là độ dài buổi tự đổi lúc lưu, không ai báo');
  /* THỨ TỰ, không chỉ SỰ CÓ MẶT: khối dọn đứng đầu hàm, phép đặt đứng sau. Đảo
     lại thì `LC_SUA_GIO` luôn null, `gioDoi` luôn false, và cửa sửa thôi hỏi
     phạm vi — hỏng im lặng mà mọi phép kiểm soi-chuỗi vẫn xanh. */
  la('lcMoForm dọn LC_SUA_GIO TRƯỚC khi đặt lại',
     form.indexOf('LC_SUA_GIO = null') > 0
       && form.indexOf('LC_SUA_GIO = null') < form.indexOf('LC_SUA_GIO = l ?'),
     'đặt rồi mới dọn là dọn mất thứ vừa đặt, và không chữ nào báo');
  la('NGÀY không đi theo lượt', !/luot\.ngay/.test(form),
     'ô ngày của một chuỗi lặp là NGÀY MỞ CHUỖI — nhét ngày buổi vào đó là viết lại luật');

  la('lcSuaChuoi bung lượt TRƯỚC khi đóng cửa buổi',
     sua.indexOf('lcLuot(l, ngayGoc)') > 0
       && sua.indexOf('lcLuot(l, ngayGoc)') < sua.indexOf('lcDongHan()'),
     'lcDongHan xoá LC_BUOI, mà ngày gốc là thứ lcLuot cần để tra ngoại lệ');
  la('lượt truyền xuống form', /lcMoForm\(id, luot\)/.test(sua));

  /* CA NẶNG NHẤT CỦA NHÁT NÀY. Form bày 10h của một buổi đã dời riêng; ghi
     thẳng con số ấy lên luật là kéo cả chuỗi về giờ của một buổi, chỉ vì có
     người mở cửa ra sửa cái tên. Hỏng im lặng, và hỏng cho cả team. */
  const iGiu = luu.indexOf('dong.gio_bat_dau = goc.gio_bat_dau');
  const iGhi = luu.indexOf(".from('lich_chung').update(dong)");
  la('giờ không đổi thì luật giữ giờ CỦA LUẬT', iGiu > 0,
     'thiếu vế này là mở cửa sửa một buổi đã dời riêng rồi bấm Lưu = kéo cả chuỗi theo nó');
  la('vế giữ giờ đứng TRƯỚC lượt ghi', iGiu > 0 && iGhi > 0 && iGiu < iGhi);
  la('vế giữ giờ mang cả độ dài', /dong\.so_phut\s+= goc\.so_phut/.test(luu),
     'giữ giờ đầu mà thả độ dài là buổi dài ra đúng bằng chênh lệch, không ai báo');
  la('gioDoi so với thứ đang bày, không so với luật',
     /dong\.gio_bat_dau !== LC_SUA_GIO\.tu/.test(luu)
       && !/dong\.gio_bat_dau !== goc\.gio_bat_dau/.test(luu),
     'so với luật là hỏi phạm vi cho một người chẳng động vào ô giờ nào');
}


/* ── ⑧ NẤC THỨ BA — CHIA CHUỖI TỪ ĐÂY TRỞ ĐI (TRI-146) ───────────────────── */
console.log('\n⑧ Nấc "Sự kiện này và các sự kiện tiếp theo"');
{
  const hop = ham('lcHoiSuaChuoi'), theo = trui(ham('lcSuaTheo'));
  const luu = trui(ham('lcLuu')), doi = trui(ham('lcLuuDoi')), keo = ham('lcKeoTha');
  const cat = trui(ham('lcCatChuoi'));

  la('hộp sửa có nấc giữa, gác sau cờ máy chủ',
     /CO_CAT_CHUOI[\s\S]{0,120}`tu_day`, `Sự kiện này và các sự kiện tiếp theo`/.test(hop),
     'bày một nấc mà máy chủ chưa có hàm thì bấm vào là hỏng — tệ hơn hẳn không bày');
  la('hộp kéo có nấc giữa, gác sau cùng cờ ấy',
     /CO_CAT_CHUOI[\s\S]{0,160}value="tu_day"/.test(keo));
  la('nấc ĐẦU chỉ hiện khi lượt này có đổi giờ', /if \(k\.gioDoi\)/.test(hop),
     'nấc ấy chỉ ghi được giờ — bày ra ở một lượt không đổi giờ là bày một lựa chọn rỗng nghĩa');
  la('nấc CUỐI luôn có mặt', !/if \([^)]*\)\s*\n?\s*nac\.push\(\[`tat_ca`/.test(hop),
     'mọi lượt phải còn ít nhất một nấc bấm được');
  la('lcSuaTheo ngã về nấc luôn có mặt', /: 'tat_ca'/.test(theo),
     "ngã về 'buoi' là ghi một nấc có thể không có trên màn");

  la('nhánh tu_day của cửa sửa đi qua lcCatChuoi',
     /daChon === 'tu_day' && LC_SUA && LC_SUA_NGAY[\s\S]{0,120}lcCatChuoi\(/.test(luu));
  la('ngày chia = ngày mở chuỗi thì rơi xuống sửa cả chuỗi',
     /* Chịu được cả hai hình dạng: một dòng như trước 07/09, và khối ngoặc từ
        khi nhánh ấy dựng thêm cú cho ngăn hoàn tác (TRI-161). Bài này canh LUẬT
        — rơi xuống sửa cả chuỗi — chứ không canh cách gõ. */
     /r\.catRong\)[\s\S]{0,200}r = await sb\.from\('lich_chung'\)\.update/.test(luu),
     'chia thật ở ca ấy là đẻ một chuỗi cũ không còn buổi nào, và phạm ràng buộc khoảng ngày');
  la('việc đi theo id MỚI sau khi chia',
     /const idViec = \(daChon === 'tu_day' && r\.data\) \? r\.data : daSua/.test(luu),
     'gọi bằng id cũ là dời việc của nửa TRƯỚC — đúng nửa không ai đụng tới');
  la('toast nói ra rằng vừa chia chuỗi', /Đã tách chuỗi từ/.test(luu),
     'chia một chuỗi làm hai nặng hơn hẳn sửa nó — người bấm phải đọc được mình vừa làm điều ấy');

  la('lcLuuDoi có nhánh tu_day', /pham === 'tu_day'/.test(doi));
  la('nhánh ấy đứng TRƯỚC hai nhánh cũ để rơi xuống được',
     doi.indexOf("pham === 'tu_day'") < doi.indexOf("pham === 'buoi'"),
     "rơi xuống nhánh tat_ca là cách tránh chép lại câu ghi ấy lần thứ hai");
  la('kéo xong thì việc đi theo id mới', /lcTheoChuoi\(idMoi \|\| moi\.lich/.test(doi));

  la('lcCatChuoi dịch 0 thành "không có gì để chia"',
     /r\.data === 0 \? \{catRong: true\}/.test(cat));
  la('cờ dò gọi hàm với lich rỗng, không chạm gì',
     /sb\.rpc\('cat_chuoi_lich', \{p_lich_id: null/.test(SRC),
     'một lượt dò phải rẻ và phải vô hại');
  la('cờ dò đi chung chuyến với bộ dò cột', /CO_CAT_CHUOI\s*= !rcc\.error/.test(SRC),
     'một vòng mạng riêng chỉ để hỏi một câu là một vòng thừa ở mọi lượt mở app');
}

/* ── ⑨ TỆP SQL — SOI CHÍNH NÓ, KHÔNG SOI TRÍ NHỚ VỀ NÓ ───────────────────── */
console.log('\n⑨ nang-cap-cat-chuoi-lich.sql');
{
  const p = path.join(__dirname, 'nang-cap-cat-chuoi-lich.sql');
  /* BỎ CHÚ THÍCH TRƯỚC ĐÃ, cùng họ với bẫy "so thứ tự" ở đầu tệp này. Phép
     kiểm `la_lead` đỏ oan ngay lượt đầu vì đầu tệp SQL có một dòng chú thích
     DẶN đừng chép vế `la_lead()` — máy đọc thấy tên nó và tưởng nó nằm trong
     hàm. Một tệp viết càng kỹ thì càng nhiều tên hàm nằm trong chú thích. */
  const sql = (fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '')
                .replace(/^\s*--.*$/gm, '');
  la('tệp có mặt', !!sql);
  la('hàm chạy bằng quyền định nghĩa', /security definer/.test(sql),
     'ba trong năm bảng giữ dòng của người khác — máy khách không với tới');
  la('hàm TỰ KIỂM quyền, không dựa vào RLS',
     /raise exception 'Chỉ người tạo sự kiện/.test(sql),
     'security definer mà không tự kiểm quyền là một cánh cửa mở');
  /* CẮT ĐÚNG THÂN HÀM RỒI HÃY SOI — lần thứ ba trong hai làn cùng một bài học.
     Trui chú thích vẫn chưa đủ: bộ TỰ KIỂM cuối tệp có một câu
     `not like '%la_lead()%'`, tức chính nó nhắc tên thứ nó đang canh. Soi cả
     tệp là đọc thấy tên ấy và kết luận ngược hẳn. */
  const than = (() => {
    const i = sql.indexOf('create or replace function cat_chuoi_lich');
    const j = sql.indexOf('end $$;', i);
    return i >= 0 && j > 0 ? sql.slice(i, j) : '';
  })();
  la('quyền KHÔNG nới cho lead', !!than && !/la_lead\(\)/.test(than),
     'bảy người đang bật cờ lead — một vế la_lead() ở đây là đi vòng qua hàng rào quyền host, đúng lỗ hổng đã phải vá ở doi_gio_viec_theo_chuoi');
  for (const [bang, vi] of [
        ['lich_chung_ngoai_le', 'buổi đã huỷ riêng và đã dời riêng'],
        ['lich_chung_tham_du',  'ô tick của cả team'],
        ['ghi_chu_buoi',        'ghi chú của cả team'],
        ['thong_bao_buoi',      'nội dung host đăng'],
        ['task',                'việc đã đẻ']])
    la('chuyển ' + bang + ' sang chuỗi mới',
       new RegExp('update ' + bang + ' set lich_id').test(sql), 'bỏ sót là mất ' + vi);
  la('doc_su_kien cố ý KHÔNG đi theo', !/update doc_su_kien/.test(sql),
     'chuỗi mới mang nội dung mới — chép dấu "đã đọc" sang là nói dối về thứ chưa ai nhìn');
  la('danh sách cột lấy từ danh mục, không gõ tay',
     /information_schema\.columns[\s\S]{0,200}table_name\s*=\s*'lich_chung'/.test(sql),
     'bảng này đã nhận thêm cột hơn mười lần trong hai tuần — một danh sách gõ tay là mỗi cột mới một trường âm thầm rơi về mặc định');
  la('ca biên ngày chia = ngày mở chuỗi trả 0', /return 0;/.test(sql));
  la('lượt dò trả null và không chạm gì',
     /p_lich_id is null then return null/.test(sql));
  la('bộ tự kiểm nằm CUỐI tệp',
     sql.lastIndexOf('kiem as (') > sql.lastIndexOf('create or replace function'),
     'Supabase chỉ bày kết quả câu lệnh cuối — tự kiểm ở giữa là Tracy phải chạy lượt nữa');
  la('dòng chưa đạt nổi lên đầu', /order by dat, so/.test(sql));
}

console.log(truot ? `\n❌ ${truot} ca trượt, ${dat} ca đạt.` : `\n✅ ${dat} ca đạt.`);
process.exit(truot ? 1 : 0);
