/* THỬ: MÀU CHO SỰ KIỆN, ĐẶT Ở CẤP CHUỖI
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 01/09: *"sự kiện ở timeline tôi muốn thêm tính năng đổi màu cho họ và
   có thể đổi màu các sự kiện trong chuỗi định kỳ luôn"* → chốt ① *cả chuỗi trước*.

   Bốn ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra:

     · HÀNG RÀO ĐỘ ĐẶC HIỆU. `.m-*` là 0,1,0 còn `.tlg-viec.lich` là 0,2,0. Giữ
       cả hai lớp mà không loại trừ thì luật `.lich` THẮNG: người dùng chọn màu,
       bấm Lưu, máy chủ nhận đúng, mà khối trên lưới vẫn xanh tím — hỏng lặng lẽ,
       không một tiếng kêu. Ba nấc phải có đủ ba hàng rào.

     · NÉT CHỮ ĐẬM Ở NẤC THÁNG phải đứng NGOÀI cuộc nhường. Nó nói "đây là buổi
       cố định", đúng bất kể khối mang màu gì. Gộp vào luật màu là sơn tay xong
       thì chữ mảnh đi.

     · CỜ DÒ CỘT PHẢI RIÊNG. `task.mau` và `lich_chung.mau` là hai tệp SQL, chạy
       ở hai lúc. Dùng chung một cờ thì máy chủ đã chạy tệp này chưa chạy tệp kia
       sẽ bày một dải màu bấm được mà lưu xuống là lỗi.

     · GỬI CỘT CHƯA CÓ LÀ HỎNG CẢ CÂU. Không phải một trường bị bỏ qua — sự kiện
       sẽ không lưu được gì cả. Nên `mau` chỉ được vào gói khi cờ bật.

   Chạy:  node production/tinh-thuc-app/thu-mau-su-kien.js
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

/* Đọc MAU_VIEC THẬT từ mã, không chép một bản thứ hai vào bài thử. Bảng màu đổi
   theo thiết kế (làn MB rút nó còn sáu ô ngày 01/09, vì 'cam' và 'xtim' nay trùng
   khít hai họ hệ thống) — một bài thử ghim cứng con số thì đỏ vì lý do chính đáng,
   và một phép kiểm như thế thì lần sau người ta thôi tin nó.
   Khai ở NGOÀI mọi khối: khối ④ đếm ô, khối ⑦ đối chiếu với ràng buộc SQL. */
const MV    = catKhoi('const MAU_VIEC = [', '];') + '];';
const SO_O  = (MV.match(/\['/g) || []).length;
const KHOA  = [...MV.matchAll(/\['([a-z]+)'/g)].map(m => m[1]);

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── ① CSS: BA HÀNG RÀO ĐỘ ĐẶC HIỆU ─────────────────────────────────────── */
console.log('\n① Hàng rào :not(.co-mau) — thiếu một cái là màu không ăn ở nấc đó');
{
  for (const lop of ['tlg', 'tlt', 'tlw'])
    la(`.${lop}-viec.lich có :not(.co-mau)`,
       SRC.includes(`.${lop}-viec.lich:not(.co-mau){`),
       `không thấy trong khối <style>`);
  /* Luật màu CŨ không được còn sót lại ở dạng trần — sót là nó thắng lại. */
  for (const lop of ['tlg', 'tlt', 'tlw'])
    la(`.${lop}-viec.lich TRẦN không còn đặt --n1`,
       !new RegExp(`\\.${lop}-viec\\.lich\\{--n1`).test(SRC));
  la('nét chữ đậm nấc Tháng đứng ngoài cuộc nhường',
     SRC.includes('.tlt-viec.lich{font-weight:600}'),
     'sơn tay xong thì chữ mảnh đi');
}

/* ── ② ĐƯỜNG MANG MÀU RA KHỎI BẢN GHI LỊCH ──────────────────────────────── */
console.log('\n② lcCuaNgay mang màu của chuỗi ra — thiếu thì ba nhánh vẽ không thấy gì');
{
  const NG = catKhoi('function lcCuaNgay(g){', '/* ══ GIỜ RẢNH CỦA NHÓM');
  /* `lcLuot` phải là MÃ THẬT, không phải một cái giả (làn KS, 02/09). Từ khi sự
     kiện kéo được, `lcCuaNgay` đọc giờ qua nó, và một cái giả trả giờ cứng sẽ
     làm khối ② xanh trong khi màu vẫn có thể đã gãy ở đường thật. `ME` thì đúng
     là giả được — khối này chỉ hỏi về màu, và `ME` chỉ quyết cờ `sua`.
     `lcDuocSua` cũng vậy, và vì cùng một lẽ: từ 04/09 `lcCuaNgayTu` hỏi quyền
     sửa qua nó, nhưng cờ ấy không chạm gì tới màu. Trả `false` là câu đúng khi
     `ME` đang là null — không đăng nhập thì không sửa được gì. */
  const LUOT = catKhoi('function lcLuot(l, goc, d){', '/* ── Lấy dữ liệu cho một dải');
  const chay = new Function(`
    let LC_HIEN = null, LC_VIEC = {};
    const ME = null;
    const lcChoToi = () => true;
    const lcHopNgay = () => true;
    const lcDuocSua = () => false;
    ${LUOT}
    ${NG}
    return { lcCuaNgay, dat: d => { LC_HIEN = d; } };`)();

  const lich = (mau) => ({id: 7, ten: 'Đào tạo nội bộ', gio_bat_dau: 870,
                          so_phut: 150, pham_vi: 'coreteam', mau});
  chay.dat({ds: [lich('ngoc')], huy: {}, tick: {}});
  const a = chay.lcCuaNgay('2026-09-04')[0];
  la('buổi bung ra mang màu của chuỗi', a.mau === 'ngoc', JSON.stringify(a));

  chay.dat({ds: [lich(null)], huy: {}, tick: {}});
  const b = chay.lcCuaNgay('2026-09-04')[0];
  la('chuỗi chưa sơn thì mau là chuỗi rỗng, không phải null', b.mau === '',
     'chuỗi rỗng để nhánh vẽ chỉ cần một phép kiểm, không phải hai');
}

/* ── ③ BA NHÁNH VẼ PHÁT ĐỦ HAI LỚP ──────────────────────────────────────── */
console.log('\n③ Ba nhánh vẽ phát `co-mau m-<tên>` — và chỉ khi có màu');
{
  /* Đọc thẳng chuỗi khuôn trong mã: ba nhánh đều mở bằng `-viec lich${`. */
  const nhanh = [
    ['nấc Ngày/Tuần lưới giờ', 'tlg-viec lich${\n        k.mau'],
    ['nấc Tháng',              'tlt-viec lich${\n        o2.mau'],
    ['nấc Tuần danh sách',     'tlw-viec lich${\n        o2.mau']
  ];
  for (const [ten, mau] of nhanh)
    la(`${ten} đọc trường mau`, SRC.includes(mau));

  /* Chạy thật phép ghép lớp, đúng khuôn ba nhánh đang dùng. */
  const lop = m => `tlg-viec lich${m ? ' co-mau m-' + m : ''}`;
  la('có màu  → phát cả co-mau lẫn m-<tên>', lop('hong') === 'tlg-viec lich co-mau m-hong');
  la('không màu → không phát lớp nào thừa', lop('') === 'tlg-viec lich');

  /* Đếm phải neo vào chuỗi `-viec lich${` — nếu không nó vơ luôn nhánh vẽ VIỆC
     THƯỜNG trong `veKhoi`, chỗ cũng ghép `' co-mau m-' + k.mau` từ 29/08. */
  const soLan = (SRC.match(
    /-viec lich\$\{\s*\n\s*(k|o2)\.mau \? ' co-mau m-' \+ \1\.mau : ''\}/g) || []).length;
  la('đủ ba nhánh SỰ KIỆN, không sót nấc nào', soLan === 3, 'đếm được ' + soLan);
}

/* ── ④ DẢI MÀU DÙNG CHUNG ───────────────────────────────────────────────── */
console.log('\n④ veDaiMau — một dải cho hai cửa, và cờ dò cột phải RIÊNG');
{
  const DM = catKhoi('function veDaiMau(oId, dang, ham, coCot, tep, khoa){',
                     '/* Cặp giờ đang gõ trong cửa');
  const O = {};
  const chay = new Function(`
    ${MV}
    /* Thêm 04/09 (TRI-104): dải màu nay KHOÁ lại khi món đang khai là cá nhân.
       Chỉ cần hằng này — loaiOLa và hai câu khoá nằm SẴN trong khối cắt ra, khai
       lại là ngã ở "already been declared". */
    const O_CA_NHAN = '_cn';
    /* Thêm 04/09 (TRI-105): ô màu nay là một ô VUÔNG cạnh tên, nên lcChonMau
       còn sơn lại chính nó. Bản giả là đủ — bài này chấm dải màu, không chấm
       cái ô vuông; ô vuông có ca riêng trong thu-loai-ca-nhan.js. */
    const lcVeOMau = () => {};
    let TV_MAU = null, LC_MAU = null, CO_MAU = true, CO_MAU_LICH = true;
    const document = {getElementById: id => (globalThis.__O[id] ||= {innerHTML: ''})};
    ${DM}
    return { veDaiMau, dat: (a, b) => { CO_MAU = a; CO_MAU_LICH = b; },
             tv: () => tvVeMau(), lc: () => lcVeMau(),
             chonLc: k => lcChonMau(k), doc: () => LC_MAU };`)();
  globalThis.__O = O;

  chay.lc();
  const h = O['lc-dai'].innerHTML;
  la(`dải sự kiện vẽ đủ ${SO_O} ô — đúng bằng số mục của MAU_VIEC`,
     (h.match(/class="tv-o m-/g) || []).length === SO_O,
     'đếm được ' + (h.match(/class="tv-o m-/g) || []).length);
  la('cộng một ô "không màu", và nó đang được chọn', h.includes('tv-o khong') && h.includes('khong dang'));
  la('cú bấm gọi ĐÚNG hàm của cửa lịch',
     /onclick="lcChonMau\('[a-z]+'\)/.test(h) && !h.includes('tvChonMau'));

  const khoaDau = KHOA[0];
  chay.chonLc(khoaDau); chay.lc();
  la(`chọn xong thì ô ấy mang dấu đang chọn (thử với '${khoaDau}')`,
     O['lc-dai'].innerHTML.includes(`m-${khoaDau} dang`));
  la('và biến giữ đúng tên màu', chay.doc() === khoaDau);

  /* Máy chủ đã chạy tệp màu VIỆC nhưng CHƯA chạy tệp màu SỰ KIỆN. */
  chay.dat(true, false);
  chay.lc(); chay.tv();
  la('cột lịch chưa có → nói ra ĐÚNG tên tệp phải chạy',
     O['lc-dai'].innerHTML.includes('nang-cap-mau-su-kien.sql'));
  la('và KHÔNG bày ô màu nào bấm được',
     !O['lc-dai'].innerHTML.includes('class="tv-o m-'));
  la('cùng lúc, dải của cửa VIỆC vẫn chạy — hai cờ độc lập thật',
     (O['tv-dai'].innerHTML.match(/class="tv-o m-/g) || []).length === SO_O,
     'dùng chung một cờ là hai cửa cùng tắt');
}

/* ── ⑤ ĐƯỜNG GHI ────────────────────────────────────────────────────────── */
console.log('\n⑤ Gói ghi xuống máy chủ — cột chưa có thì tuyệt đối không gửi');
{
  la('lcLuu chỉ thêm mau khi cờ bật',
     SRC.includes('if (CO_MAU_LICH) dong.mau = LC_MAU || null;'));
  la('không màu gửi null, không gửi chuỗi rỗng',
     SRC.includes('LC_MAU || null'),
     "chuỗi rỗng không lọt ràng buộc `lich_mau_hop_le`");
  /* Luật cũ giữ nguyên, thêm một vế TRƯỚC nó (04/09, TRI-104): buổi RIÊNG thì
     việc của nó là việc cá nhân, mà việc cá nhân màu hồng. Ghi 'tim' vào đó là
     cất một giá trị màn hình không bao giờ bày ra. */
  la('việc của buổi mượn màu của sự kiện, thôi đóng đinh tim',
     SRC.includes("(l.mau || 'tim')") && !SRC.includes("dong.mau = 'tim'"));
  la('trừ buổi riêng — việc của nó màu hồng, không phải tím',
     SRC.includes("dong.mau = l.rieng_tu ? 'hong' : (l.mau || 'tim')"));
  la('form nạp lại đúng màu đang có khi mở sửa',
     SRC.includes('LC_MAU = l && l.mau ? l.mau : null;'));
}

/* ── ⑥ CỜ DÒ CỘT ────────────────────────────────────────────────────────── */
console.log('\n⑥ Cờ dò cột đi chung một chuyến, không thêm lượt mạng nào');
{
  la('có khai CO_MAU_LICH riêng', SRC.includes('let CO_MAU_LICH  = false;'));
  la('câu dò nằm trong đúng chùm Promise.all của doCotGio',
     SRC.includes("sb.from('lich_chung').select('mau').limit(1)"));
  /* Kiểm rằng `rml` ĐƯỢC BUỘC và ĐƯỢC ĐỌC, chứ không ghim cứng cả mảng: chùm
     này còn dài thêm mỗi khi có một cột hay bảng mới cần dò (nhát 2 thêm ô thứ
     sáu cho `ghi_chu_buoi`), và một phép kiểm đổ vì lý do chính đáng thì lần
     sau người ta thôi tin nó. */
  la('rml được buộc trong chùm và được đọc đúng chỗ',
     /const \[[^\]]*\brml\b[^\]]*\] = await Promise\.all\(\[/.test(SRC)
     && SRC.includes('CO_MAU_LICH = !rml.error;'));
}

/* ── ⑦ TỆP SQL ──────────────────────────────────────────────────────────── */
console.log('\n⑦ Tệp nâng cấp — và bài học từ ràng buộc không vá lại được');
{
  const q = fs.readFileSync(path.join(__dirname, 'nang-cap-mau-su-kien.sql'), 'utf8');
  la('thêm cột theo lối chạy lại được', q.includes('add column if not exists mau text'));
  la('ràng buộc lich_chung.mau: DROP rồi ADD, không bọc if not exists',
     q.includes('drop constraint if exists lich_mau_hop_le')
     && q.includes('add constraint lich_mau_hop_le')
     && !/if not exists \(select 1 from pg_constraint/.test(q),
     'bọc if-not-exists là lần sau thêm màu thì chạy lại KHÔNG vá được — đúng lỗi đang sống ở nang-cap-mau-khoi-viec.sql');
  /* ⚠️ BẤT BIẾN ĐÁNG GIÁ NHẤT CỦA CẢ BÀI THỬ NÀY. Bảng chọn mời chọn một màu mà
     ràng buộc máy chủ không nhận thì Postgres trả lỗi cho CẢ CÂU LỆNH — người
     dùng mất luôn mọi thứ vừa sửa trong lần Lưu ấy, không phải mất mỗi màu.
     Đúng lỗi này đang sống trên `task.mau` từ 01/09 ('ngoc' bị chặn), và nó
     sống được vì không có phép kiểm nào canh. Đây là phép kiểm ấy, cho `lich_chung.mau`. */
  /* Cắt tới dấu chấm phẩy đầu tiên, cùng lý do đã chép ở khối ⑧: soi trên cả
     đuôi tệp thì bộ tự kiểm kê lại tên màu và ca này không bao giờ đỏ được. */
  const _s7 = q.split('add constraint lich_mau_hop_le')[1] || '';
  const cau7 = _s7.slice(0, _s7.indexOf(';') + 1 || undefined);
  const thieu = KHOA.filter(t => !new RegExp(`'${t}'`).test(cau7));
  la(`ràng buộc lich_chung.mau: nhận đủ ${KHOA.length} màu mà bảng chọn đang mời`,
     thieu.length === 0,
     'máy chủ sẽ chặn: ' + thieu.join(', ') + ' — chọn màu ấy rồi Lưu là mất cả câu lệnh');
  /* Chép từ khối ⑧: màu đã RÚT khỏi bảng chọn vẫn phải hợp lệ. Siết ràng buộc
     xuống đúng bảng chọn thì `add constraint` ngã ngay — Postgres soát cả dữ
     liệu đang có — và sự kiện nào đã lỡ sơn màu cũ cũng hết sửa được.
     ⚠️ Chỉ kê 'cam' và 'xtim'. Khác `task.mau`, cột này sinh ra ngày 01/09 với
     danh sách tám tên MỚI, chưa bao giờ nhận 'do' hay 'xam' — đòi hai tên ấy ở
     đây là bắt tệp kê một thứ chưa từng có dòng nào mang. */
  const roi7 = ['cam','xtim'].filter(t => !new RegExp(`'${t}'`).test(cau7));
  la('ràng buộc lich_chung.mau: vẫn nhận hai màu đã rút khỏi bảng chọn',
     roi7.length === 0,
     'siết xuống đúng bảng chọn là bắt dữ liệu cũ thành sai: ' + roi7.join(', '));
  la('tệp nâng cấp lich_chung.mau có bộ tự kiểm ở cuối', q.includes('TỰ KIỂM'));
}

/* ⚠️ NHÃN PHẢI MANG TÊN CỘT. Hai khối dưới đây soi cùng một bất biến trên hai
   bảng, nên nhãn trần in ra hai dòng chữ y hệt — một đỏ một xanh — và người
   đọc log phải đếm thứ tự khối mới biết cái đỏ thuộc bảng nào. Log là thứ đọc
   lúc đang vội. (Phiên bên cạnh chỉ ra, sau khi thử phá tệp sự kiện.) */
/* ── ⑧ TỆP SQL THỨ HAI — cùng bất biến ấy, cho `task.mau` (làn MB, 01/09) ──
   Phép kiểm ở khối ⑦ canh `lich_chung.mau`. Nhưng lỗi THẬT đang sống lại nằm ở
   `task.mau`: dải màu mời chọn 'ngoc' từ 01/09 mà ràng buộc dựng 29/08 không
   nhận nó, nên chọn Ngọc rồi Lưu là mất cả câu lệnh. Nó sống được vì không có
   phép kiểm nào canh — đây là phép kiểm ấy, và từ nay hai bảng đều có. */
console.log('\n⑧ Ràng buộc màu của `task` — bảng chọn mời gì thì máy chủ phải nhận nấy');
{
  const q = fs.readFileSync(path.join(__dirname, 'nang-cap-mau-task-them-ngoc.sql'), 'utf8');
  la('ràng buộc task.mau: DROP rồi ADD, không bọc if not exists',
     q.includes('drop constraint if exists task_mau_hop_le')
     && q.includes('add constraint task_mau_hop_le')
     && !/if not exists \(select 1 from pg_constraint/.test(q),
     'bọc if-not-exists là chính cái bẫy đã để lỗi này sống — xem nang-cap-mau-khoi-viec.sql');
  /* ⚠️ CẮT ĐÚNG CÂU `add constraint`, tới dấu chấm phẩy ĐẦU TIÊN — đừng lấy cả
     phần đuôi tệp. Bộ tự kiểm ở cuối cũng kê lại đủ mười tên, nên nếu soi trên
     cả đuôi thì gỡ một tên khỏi chính câu ràng buộc mà bài thử vẫn xanh. Đã thử
     phá để chắc: bỏ 'ngoc' khỏi câu ràng buộc thì ca này phải đỏ. */
  const _sau = q.split('add constraint task_mau_hop_le')[1] || '';
  const sauAdd = _sau.slice(0, _sau.indexOf(';') + 1 || undefined);
  const thieu = KHOA.filter(t => !new RegExp(`'${t}'`).test(sauAdd));
  la(`ràng buộc task.mau: nhận đủ ${KHOA.length} màu mà bảng chọn đang mời`,
     thieu.length === 0,
     'máy chủ sẽ chặn: ' + thieu.join(', ') + ' — chọn màu ấy rồi Lưu là mất cả câu lệnh');
  /* Bốn màu đã rút khỏi bảng chọn vẫn phải HỢP LỆ: việc nào đã lỡ sơn chúng thì
     lần sửa kế tiếp của chính việc ấy sẽ ngã nếu ràng buộc siết xuống sáu tên. */
  const roi = ['do','xam','cam','xtim'].filter(t => !new RegExp(`'${t}'`).test(sauAdd));
  la('ràng buộc task.mau: vẫn nhận bốn màu đã rút khỏi bảng chọn',
     roi.length === 0,
     'siết xuống đúng bảng chọn là bắt dữ liệu cũ thành sai: ' + roi.join(', '));
  la('có hàng rào đọc tên màu lạ trước khi thay ràng buộc',
     q.includes('raise exception'),
     'thiếu nó thì add constraint ngã với một câu báo không nói được tên nào sai');
  la('tệp nâng cấp task.mau có bộ tự kiểm ở cuối', q.includes('TỰ KIỂM'));
}

console.log(`\n${truot ? '❌' : '✅'} ${dat} ca đạt${truot ? ', ' + truot + ' ca trượt' : ''}.\n`);
process.exit(truot ? 1 : 0);
