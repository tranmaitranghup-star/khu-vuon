/* THỬ: HAI NẤC DỰ KIẾN · ĐÃ CHỐT CỦA MỘT SỰ KIỆN
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09 (TRI-71): *"ở sự kiện tôi cần thêm 1 tính năng là nút dự kiến/đã
   chốt lịch, nếu mà sự kiện đó dự kiến thì có thêm 1 đường nét đứt bao quanh vì
   chúng tôi hay hoạch định lịch nhưng chưa chốt"*.

   Năm ca đáng giá nhất — đều là chỗ mà bấm thử từng bước KHÔNG lộ ra:

     · CHIỀU RƠI KHI MÁY CHỦ CHƯA CÓ CỘT. Hai chỗ đọc `da_chot` đều phải hỏi
       `!== false`. Hỏi `=== true` thì trên đúng những máy chủ chưa chạy tệp
       SQL, cột về `undefined` và CẢ LỊCH hoá nét đứt cùng một lúc. Máy dựng
       chạy tệp rồi thì không bao giờ gặp — người dùng gặp ngay lượt đầu.

     · MẶC ĐỊNH BÊN SQL PHẢI LÀ `true`, và `not null`. Mặc định `false` thì chạy
       tệp xong mọi sự kiện đã khai từ trước đều hoá dự kiến, mà không ai đi sửa
       tay được vài chục dòng. `null` được phép thì đẻ ra nấc thứ ba "chưa biết"
       và mỗi chỗ đọc lại tự quyết nó nghĩa là gì.

     · NÉT ĐỨT VẼ BẰNG `outline`, KHÔNG BẰNG `border`. `.tlt-viec` và `.tlw-viec`
       khai `border:0` CÓ CHỦ Ý: ô Tháng cao 104px bày tới năm khối, thêm 2px mỗi
       khối là hàng cuối tràn khỏi ô. Dùng `border` thì hỏng theo kiểu tràn bố
       cục ở đúng những ngày dày lịch — thứ một bản chụp màn hình ngày thưa không
       bắt được.

     · BA NẤC LỊCH PHẢI ĐỦ CẢ BA. Thiếu một nấc thì cùng một sự kiện đọc ra hai
       nghĩa khác nhau ở hai màn, và người ta tin cái màn đang mở.

     · ĐƯỜNG TỰ ĐẺ VIỆC KHOÁ, BA LỐI CHẠM TAY KHÔNG KHOÁ. Chặn nhầm trong
       `lcDeViec` là chối cả thao tác người ta vừa chạm rõ ràng vào một buổi.

   Chạy:  node production/tinh-thuc-app/thu-chot-su-kien.js
*/
const fs = require('fs');
const path = require('path');
const GOC = process.env.THU_GOC || __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(GOC, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(GOC, 'nang-cap-chot-su-kien.sql'), 'utf8');

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

/* ── ① CHIỀU RƠI: `!== false`, KHÔNG PHẢI `=== true` ────────────────────── */
console.log('\n① Chiều rơi khi máy chủ chưa có cột — sai chiều là cả lịch hoá nét đứt');
{
  const luoi = catKhoi('function lcCuaNgayTu(', '\n}');
  la('lcCuaNgayTu đọc `chot: l.da_chot !== false`',
     /chot:\s*l\.da_chot\s*!==\s*false/.test(luoi),
     'thiếu, hoặc đang hỏi `=== true` — cột chưa có thì về undefined');
  la('lcCuaNgayTu KHÔNG hỏi `da_chot === true`',
     !/da_chot\s*===\s*true/.test(luoi),
     'một sự kiện thiếu cột phải đọc ra là ĐÃ CHỐT');

  const form = catKhoi('function lcMoForm(', '\n}');
  la('lcMoForm đặt LC_CHOT theo `!== false`',
     /LC_CHOT\s*=\s*l\s*\?\s*l\.da_chot\s*!==\s*false\s*:\s*true/.test(form),
     'mở một sự kiện cũ ra phải thấy "Đã chốt", không phải "Dự kiến"');
  la('Sự kiện MỚI mặc định đã chốt',
     /:\s*true;/.test(form.slice(form.indexOf('LC_CHOT ='))),
     'mặc định dự kiến thì cả lịch đầy nét đứt cho tới khi có người đi tắt từng cái');
}

/* ── ② SQL: MẶC ĐỊNH true, KHÔNG CHO RỖNG ───────────────────────────────── */
console.log('\n② Tệp SQL — mặc định phải giữ nguyên mọi sự kiện đã khai');
{
  la('cột `da_chot` là boolean, not null, default true',
     /add column if not exists da_chot boolean not null default true/.test(SQL),
     'thiếu `default true` là mọi lịch cũ hoá dự kiến ngay lúc chạy tệp');
  la('không có `default false` ở đâu trong tệp',
     !/default\s+false/.test(SQL),
     'một dòng sót là đảo ngược cả ý đồ');
  la('tệp chạy lại được nhiều lần (`if not exists`)',
     /if not exists/.test(SQL),
     'mọi tệp nâng cấp trong app đều theo luật này');
  la('có bộ tự kiểm ở cuối',
     /information_schema\.columns/.test(SQL) && /da_chot is not true/.test(SQL),
     'không có cách nào biết tệp đã ăn hay chưa');
}

/* ── ③ NÉT ĐỨT: `outline`, KHÔNG ĐỘI KHỔ HỘP ────────────────────────────── */
console.log('\n③ Nét đứt vẽ bằng outline — border là đội 2px mỗi khối ở nấc Tháng');
{
  const i = SRC.indexOf('.tlg-viec.lich.chua-chot');
  la('có luật CSS cho .chua-chot', i > 0, 'không thấy trong khối <style>');
  const luat = i > 0 ? SRC.slice(i, SRC.indexOf('}', i) + 1) : '';
  la('luật dùng `outline` và `dashed`',
     /outline:\s*1px dashed/.test(luat), 'nét đứt là thứ Tracy yêu cầu');
  la('có `outline-offset` âm — nét nằm trong mép, không ăn sang khối cạnh',
     /outline-offset:\s*-/.test(luat), luat.slice(0, 120));
  la('luật KHÔNG đụng `border` hay `box-shadow`',
     !/border|box-shadow/.test(luat),
     '.tlt-viec và .tlw-viec khai border:0 có chủ ý — đọc chú thích ở chúng');
  /* Ba nấc phải nằm CHUNG một luật: tách ra ba chỗ là ba đường để trôi lệch. */
  for (const lop of ['tlg', 'tlt', 'tlw'])
    la(`nấc ${lop} có trong luật nét đứt`,
       luat.includes(`.${lop}-viec.lich.chua-chot`) ||
       SRC.slice(i - 200, i).includes(`.${lop}-viec.lich.chua-chot`),
       'thiếu một nấc là cùng sự kiện đọc ra hai nghĩa ở hai màn');
}

/* ── ④ SÁU CHỖ VẼ KHỐI ĐỀU GẮN LỚP ──────────────────────────────────────── */
/* SÁU, KHÔNG PHẢI BA — và con số đổi vì một lỗi thật, không vì nới luật.
   Một sự kiện lên lịch bằng HAI đường vẽ tách rời: buổi có giờ đi qua
   `lcCuaNgay`, còn sự kiện CẢ NGÀY trải nhiều ngày đi qua `lcDaiCuaKhung` (làn
   ND, 03/09). Bài thử này viết cùng ngày nhưng chỉ biết đường thứ nhất, nên nó
   xanh suốt trong khi RW38 — một sự kiện cả ngày còn dự kiến — nằm trên cả ba
   nấc lịch mà không một nét đứt nào (Tracy báo 04/09, TRI-82).
   Ba nấc × hai đường = sáu. Dựng thêm một đường vẽ nữa cho lịch thì con số này
   phải lên theo, và đó chính là việc nó có mặt ở đây để nhắc. */
console.log('\n④ Sáu chỗ dựng khối sự kiện đều phát lớp `chua-chot`');
{
  const dem = (SRC.match(/chot\s*\?\s*''\s*:\s*' chua-chot'/g) || []).length;
  la('đủ sáu chỗ phát lớp', dem === 6,
     `đếm được ${dem} — phải là 6 (tlg · tlt · tlw, mỗi nấc hai đường: buổi có giờ và dải cả ngày)`);
  const tip = (SRC.match(/chot\s*\?\s*''\s*:\s*'[^']*dự kiến'/g) || []).length;
  la('cả sáu khối nói ra trong dòng chú thích khi rê chuột',
     tip === 6, `đếm được ${tip} — phải là 6`);
  /* Nguồn của lớp: chỗ vẽ chỉ gắn được `chua-chot` nếu hàm gom dữ liệu có trả
     trường `chot` ra. Đây đúng là mảnh đã thiếu, nên nó phải có bài gác riêng —
     đếm chỗ vẽ thôi thì một hàm gom quên trả trường vẫn xanh, vì `undefined`
     rơi vào nhánh "chưa chốt" hay "đã chốt" đều lặng lẽ. */
  const gom = catKhoi('function lcDaiCuaKhung', '\nfunction ');
  la('`lcDaiCuaKhung` trả trường `chot` cho dải cả ngày',
     /chot:\s*l\.da_chot\s*!==\s*false/.test(gom),
     'thiếu trường này thì ba chỗ vẽ dải không có gì để gắn lớp');
  la('và nó hỏi `!== false` như hàm song sinh, không hỏi `=== true`',
     !/chot:\s*l\.da_chot\s*===\s*true/.test(gom),
     'máy chủ chưa chạy tệp SQL thì cột về undefined — phải đọc ra là ĐÃ chốt');
}

/* ── ④b DẢI CẢ NGÀY LÀ LỚP THỨ TƯ TRONG LUẬT NÉT ĐỨT ────────────────────── */
/* Dải ngang trên lưới không mang `.lich` mà mang bộ lớp riêng `.tlg-ca.sk`, nên
   nó không thừa hưởng gì từ ba chuỗi `.tl*-viec.lich.chua-chot`. Phải kê tên. */
console.log('\n④b Luật nét đứt phủ cả dải cả ngày trên lưới');
{
  const i = SRC.indexOf('.tlg-ca.sk.chua-chot');
  la('luật CSS có kê `.tlg-ca.sk.chua-chot`', i > 0,
     'thiếu dòng này thì dải cả ngày dự kiến trông y hệt dải đã chốt');
  if (i > 0){
    const luat = SRC.slice(i, SRC.indexOf('}', i) + 1);
    la('và nó nằm CHUNG luật với ba nấc kia, không tách ra một chỗ thứ hai',
       /\.tlg-viec\.lich\.chua-chot/.test(SRC.slice(Math.max(0, i - 400), i)),
       'tách ra là mở đường cho hai công thức nét đứt trôi lệch khỏi nhau');
    la('vẫn vẽ bằng `outline`, không đụng `border`',
       /outline:\s*1px dashed/.test(luat) && !/border/.test(luat),
       '`.tlg-ca` đã dùng `border-left` mang màu chuỗi — giành nhau là mất màu ấy');
  }
}

/* ── ⑤ CỜ DÒ CỘT VÀ ĐƯỜNG GHI ───────────────────────────────────────────── */
console.log('\n⑤ Cờ dò cột — gửi một cột chưa tồn tại là hỏng CẢ câu lệnh');
{
  la('cờ CO_CHOT_LICH được khai',
     /let CO_CHOT_LICH\s*=\s*false/.test(SRC), 'thiếu khai báo');
  la('doCotGio có hỏi cột `da_chot`',
     /from\('lich_chung'\)\.select\('da_chot'\)/.test(SRC), 'thiếu câu dò');
  la('cờ được gán từ kết quả câu dò',
     /CO_CHOT_LICH\s*=\s*!\w+\.error/.test(SRC), 'khai cờ mà không ai bật nó');

  const luu = catKhoi('async function lcLuu(', '\n}');
  la('lcLuu chỉ gửi `da_chot` khi cờ bật',
     /if \(CO_CHOT_LICH\) dong\.da_chot = LC_CHOT;/.test(luu),
     'gửi cột chưa có là sự kiện không lưu được gì cả');
  la('lcLuu đọc BIẾN LC_CHOT, không đọc DOM',
     !/getElementById\(['"]lc-chot/.test(luu),
     'cửa nào bày lại khoang sự kiện mà thiếu hàng nút này sẽ ngã');
  la('lỗi thiếu cột được dịch thành việc phải làm',
     /da_chot/.test(luu) && luu.includes('nang-cap-chot-su-kien.sql'),
     '"column ... does not exist" không nói cho ai biết phải làm gì');
}

/* ── ⑥ ĐƯỜNG TỰ ĐẺ VIỆC ─────────────────────────────────────────────────── */
console.log('\n⑥ Sự kiện còn dự kiến không tự đẻ việc — nhưng ba lối chạm tay vẫn chạy');
{
  const de = catKhoi('async function lcDeVieckHomNay(', '\n}');
  la('lượt tự đẻ đầu ngày lọc theo `o.chot`',
     /filter\(o => !o\.viec && o\.chot\)/.test(de),
     'đẻ việc cho thứ có thể không xảy ra là làm bẩn màn Việc hôm nay');

  const cua = catKhoi('async function lcDeViec(', '\n}');
  la('lcDeViec KHÔNG tự chặn theo trạng thái chốt',
     !/da_chot|\.chot\b/.test(cua),
     'chặn ở đây là chối cả thao tác người ta vừa chạm rõ ràng vào một buổi');
}

/* ── ⑦ HAI NÚT VÀ CỬA BUỔI ──────────────────────────────────────────────── */
console.log('\n⑦ Hàng hai nút, và cửa buổi tự nói trạng thái của mình');
{
  const ve = catKhoi('function lcVeChot(', '\n}');
  la('chưa chạy tệp SQL thì hàng nút nói ra tên tệp',
     ve.includes('nang-cap-chot-su-kien.sql') && /if \(!CO_CHOT_LICH\)/.test(ve),
     'bày một nút bấm vào là lỗi thì tệ hơn hẳn không bày');
  la('hai nấc mang đúng nhãn Tracy dùng',
     ve.includes("'Đã chốt'") && ve.includes("'Dự kiến'"), 'nhãn phải đúng lời Tracy');
  la('nút mượn lại `.lc-thu-nut`, không dựng hình thứ hai',
     ve.includes('lc-thu-nut'), 'cùng là một ô bật/tắt trong một hàng');
  la('nấc đang chọn tô đặc bằng lớp `chon`',
     /LC_CHOT === v \? ' chon' : ''/.test(ve), 'luật "giữ thì tô đặc" của bộ nút app');
  la('có `aria-pressed` cho người đọc màn hình',
     ve.includes('aria-pressed'), 'hai nút trạng thái mà không nói ra mình đang bật hay tắt');

  la('form có chỗ cho hàng nút', SRC.includes(`id="lc-chot"`), 'thiếu ô trong lcMoForm');
  la('nhãn là CỤM DANH TỪ, không phải câu hỏi',
     SRC.includes('Trạng thái lịch — cả chuỗi'), 'luật 3b của CLAUDE.md');

  const buoi = catKhoi('function lcMoBuoi(', '\n}');
  la('cửa buổi nói ra khi chuỗi còn dự kiến',
     /l\.da_chot === false/.test(buoi) && buoi.includes('còn dự kiến'),
     'mở cửa buổi ra là mất cái lưới khỏi tầm mắt, nên nó phải tự nói lấy');
}

/* ── ⑧ CHẠY THẬT HAI HÀM, TRÊN MỘT MÀN GIẢ ─────────────────────────────────
   Bảy khối trên đều là phép soi CHỮ trong mã — chúng bắt được "quên viết", không
   bắt được "viết rồi mà chạy ra sai". Khối này cắt đúng hai hàm ra, cho chúng một
   `document` giả, rồi đọc thứ chúng dựng lên. Đây là chỗ duy nhất trong bài thử
   nhìn thấy hành vi thật.
   ⚠️ Thân hàm dựng bằng phép NỐI CHUỖI, không bằng chuỗi mẫu: `lcVeChot` bên
   trong có `${...}` của riêng nó, bọc nó vào một chuỗi mẫu là chuỗi ngoài ăn mất
   chúng ngay lúc bài thử chạy. */
console.log('\n⑧ Chạy thật lcVeChot và lcDatChot trên một màn giả');
{
  const iA = SRC.indexOf('function lcVeChot(');
  const iB = SRC.indexOf('function lcDatChot(', iA);
  const MA = SRC.slice(iA, SRC.indexOf('\n', iB));

  function chay(coCot, banDau){
    const o = {innerHTML: ''};
    const than = 'let LC_CHOT = banDau;\n' + MA + '\nlcVeChot();\n'
      + 'return {html: () => o.innerHTML, bam: v => { lcDatChot(v); return LC_CHOT; }};';
    return new Function('document', 'CO_CHOT_LICH', 'banDau', 'o', than)(
      {getElementById: id => id === 'lc-chot' ? o : null}, coCot, banDau, o);
  }
  const dem = h => (h.match(/<button/g) || []).length;
  const chon = h => [...h.matchAll(/<button[^>]*>([^<]*)<\/button>/g)]
                    .filter(m => /class="[^"]*\bchon\b/.test(m[0])).map(m => m[1]);

  const chuaCot = chay(false, true).html();
  la('máy chủ chưa có cột → không dựng nút nào',
     dem(chuaCot) === 0, `dựng ${dem(chuaCot)} nút`);
  la('máy chủ chưa có cột → nói ra tên tệp',
     chuaCot.includes('nang-cap-chot-su-kien.sql'), chuaCot.slice(0, 90));

  const a = chay(true, true);
  la('có cột → đúng hai nút', dem(a.html()) === 2, `dựng ${dem(a.html())} nút`);
  la('mở ra ở nấc Đã chốt thì Đã chốt tô đặc',
     JSON.stringify(chon(a.html())) === '["Đã chốt"]', chon(a.html()).join(' · '));

  const b = chay(true, false);
  la('mở ra ở nấc Dự kiến thì Dự kiến tô đặc',
     JSON.stringify(chon(b.html())) === '["Dự kiến"]', chon(b.html()).join(' · '));

  /* Bấm rồi đọc lại — hai vế phải khớp: biến đổi, VÀ hàng nút vẽ lại theo. Một
     trong hai mà quên thì màn hình và thứ sắp ghi xuống nói hai chuyện khác nhau. */
  const c = chay(true, true);
  la('bấm Dự kiến → biến đổi theo', c.bam(false) === false, 'LC_CHOT không đổi');
  la('bấm Dự kiến → hàng nút vẽ lại theo',
     JSON.stringify(chon(c.html())) === '["Dự kiến"]', chon(c.html()).join(' · '));
  la('bấm ngược lại Đã chốt cũng ăn',
     c.bam(true) === true && JSON.stringify(chon(c.html())) === '["Đã chốt"]',
     chon(c.html()).join(' · '));
  /* Đúng MỘT nấc được tô đặc ở mọi lúc — hai nấc cùng đặc thì không đọc ra được
     thứ nào sắp ghi xuống. */
  la('không lúc nào có hai nấc cùng tô đặc',
     [a, b, c].every(x => chon(x.html()).length === 1), 'hai nút cùng mang lớp chon');
}

/* ── ⑨ MỘT DẤU, MỘT NGHĨA — nét đứt chỉ được nói "chưa chốt" ────────────────
   Tracy 03/09, ngay sau khi tôi báo nét đứt đang mang hai nghĩa: *"deepwork bỏ
   nét đứt đi, nét đứt mang ý nghĩa là dự kiến"*.

   Đây là luật của cả BẢNG DẤU, không phải của một luật CSS — nên phép kiểm phải
   quét cả khối kiểu dáng chứ không chỉ nhìn một dòng. Ai mượn nét đứt cho một
   nghĩa thứ hai trên khối lịch, ở bất kỳ nấc nào, sẽ đỏ ngay tại đây kèm tên
   luật mình vừa viết. Đó đúng là kiểu hỏng mà đọc mã không thấy: hai luật đứng
   cách nhau hai trăm dòng, mỗi luật đọc riêng đều có lý. */
console.log('\n⑨ Nét đứt trên khối lưới chỉ được mang MỘT nghĩa');
{
  const KIEU = catKhoi('<style>', '</style>');
  /* Cắt theo từng luật: mọi thứ từ sau dấu } trước đó tới dấu } của luật này.
     Chú thích /* *​/ gỡ trước, không thì một chữ "dashed" trong lời giải thích
     cũng bị tính là một luật. */
  const sach = KIEU.replace(/\/\*[\s\S]*?\*\//g, '');
  const luat = sach.split('}').map(x => x + '}')
                   .filter(x => /\bdashed\b/.test(x));
  const tren = luat.filter(x => /\.(tlg|tlt|tlw)-viec/.test(x.split('{')[0]));
  la('đúng MỘT luật vẽ nét đứt lên khối lưới',
     tren.length === 1,
     tren.length + ' luật: ' + tren.map(x => x.split('{')[0].trim()).join(' ⟂ '));
  la('và luật ấy là luật `.chua-chot`',
     tren.length === 1 && tren[0].includes('.chua-chot'),
     tren[0] ? tren[0].split('{')[0].trim() : '(không có luật nào)');

  /* Khối phiên deep work đã trả nét đứt lại — kiểm THẲNG, vì đây là thứ Tracy
     yêu cầu bằng lời chứ không phải hệ quả suy ra. */
  la('.tlg-viec.phien không còn đặt border-style',
     !/\.tlg-viec\.phien\{[^}]*border-style/.test(sach),
     'khối phiên vẫn đang vẽ nét viền của riêng nó');
  la('.tlg-viec.phien không còn đặt border-color',
     !/\.tlg-viec\.phien\{[^}]*border-color/.test(sach),
     'gỡ nét đứt mà để lại màu viền là một nét liền mọc lên thay chỗ');

  /* Nhưng CHỖ ĐẶT viền thì phải còn: gỡ hẳn `border` khỏi lát mặc định là mọi
     khối hụt 2px và lệch khỏi lưới giờ. Lý lẽ "phiên cần chỗ đặt nét" hết hiệu
     lực hôm nay, lý lẽ khổ hộp thì không. */
  la('lát mặc định .tlg-viec vẫn giữ `border:1px solid transparent`',
     /border:1px solid transparent/.test(sach),
     'gỡ là mọi khối hụt 2px và lệch khỏi lưới giờ');
}

/* ── ⑩ MỘT KHỐI, MỘT VIỀN — và hai chuỗi :not() phải khớp nhau ──────────────
   Tracy 03/09: *"để mỗi nét đứt thôi"*. Sự kiện vừa chưa-ai-trả-lời vừa
   còn-dự-kiến rơi vào hai luật cùng lúc; nét đứt ở lại, viền liền nhường chỗ.

   Ca đắt nhất ở đây KHÔNG phải "có tắt viền không" — mà là **hai chuỗi `:not()`
   có còn khớp nhau không**. Luật tắt viền phải chép đúng chuỗi của luật *chưa
   trả lời* thì mới thắng độ đặc hiệu. Luật kia tự dặn ai thêm trạng thái mới
   thì thêm tên vào chuỗi của nó — thêm ở đó mà quên ở đây là cái vòng mọc lại,
   không một tiếng kêu, và chỉ ở đúng trạng thái mới thêm. */
console.log('\n⑩ Sự kiện dự kiến chỉ đeo MỘT viền — và hai chuỗi :not() khớp nhau');
{
  const sach = catKhoi('<style>', '</style>').replace(/\/\*[\s\S]*?\*\//g, '');
  const chuoi = sel => (sel.match(/:not\([^)]*\)/g) || []).join('');

  /* Luật *chưa trả lời* — lấy bản nấc Ngày làm mẫu cho cả ba, vì cả ba chép
     chung một chuỗi. */
  /* `{3,}` chứ không `+`: ngay trên trong tệp còn `.tlg-viec.lich:not(.co-mau)`
     — luật họ màu, một `:not()` duy nhất — và một dấu `+` tham lam sẽ vớ đúng
     nó rồi báo hai chuỗi lệch nhau ở một chỗ không liên quan gì. */
  const kia = sach.match(/\.tlg-viec\.lich(:not\([^)]*\)){3,}(?=,|\{)/);
  la('luật *chưa trả lời* còn đó', !!kia, 'nó là thứ luật này đang nhường chỗ');

  /* `{3,}` ở đây cũng vậy, và nó vừa cứu một lần thật: từ 03/09 luật NÉT ĐỨT
     mang `:not(.xong)` — một `:not()` duy nhất — và một dấu `+` tham lam vớ đúng
     nó rồi báo hai chuỗi lệch nhau. Cả hai mốc cắt phải đòi chuỗi DÀI. */
  const nay = sach.match(/\.tlg-viec\.lich\.chua-chot(:not\([^)]*\)){3,}(?=,|\{)/);
  la('có luật tắt viền cho khối dự kiến', !!nay,
     'thiếu là khối dự kiến đeo hai vòng đồng tâm');

  la('hai chuỗi :not() khớp từng chữ',
     !!kia && !!nay && chuoi(kia[0]) === chuoi(nay[0]),
     `chưa trả lời: ${kia ? chuoi(kia[0]) : '—'}\n       → dự kiến:     ${nay ? chuoi(nay[0]) : '—'}`);

  /* Tắt ĐÚNG cái vòng, không tắt nền: nền trắng là thứ nói "chưa ai trả lời",
     một chiều độc lập với chuyện đã chốt lịch hay chưa. */
  const than = nay ? sach.slice(sach.indexOf(nay[0]), sach.indexOf('}', sach.indexOf(nay[0])) + 1) : '';
  const than2 = than.slice(than.indexOf('{'));
  la('luật ấy chỉ tắt `box-shadow`, không đụng nền hay màu chữ',
     /box-shadow:\s*none/.test(than2) && !/background|(^|;)\s*color:/.test(than2),
     than2.slice(0, 100));

  /* Bản sáng có luật riêng, độ đặc hiệu cao hơn — thiếu vế này thì nền sáng
     vẫn còn vòng, mà máy dựng hay xem bản tối nên rất dễ lọt. */
  la('có phủ cả bản sáng',
     /:root\[data-theme="sang"\] \.tlg-viec\.lich\.chua-chot:not/.test(sach),
     'bản sáng có luật viền riêng, độ đặc hiệu cao hơn bản tối');
}

/* ── ⑪ ĐÃ DỰ XONG THÌ THÔI DỰ KIẾN ─────────────────────────────────────────
   Tracy 03/09: *"uầy đã dự xong thì làm gì còn dự kiến nữa? sự kiện mà done rồi
   thì auto đổi thành đã chốt và nét liền"*.

   Hai đường nói cùng một điều, và bài thử gác CẢ HAI vì chúng hỏng độc lập nhau:
     · HÌNH — luật nét đứt loại trừ `.xong`. Đúng cả khi cột chưa kịp đổi, cả khi
       người bấm không có quyền ghi `lich_chung`, cả khi việc của buổi được đánh
       dấu Done từ một cửa khác.
     · DỮ LIỆU — cột `da_chot` tự nâng lên ở CẢ HAI cửa đánh dấu xong. Thiếu một
       cửa thì lỗi chỉ hiện ở đúng một lối bấm, thứ thử tay rất dễ đi trượt.

   Và MỘT CHIỀU: gỡ đánh dấu xong thì chuỗi vẫn đã chốt. Bỏ tick nói *buổi này
   chưa xong*, không nói *lịch này chưa chốt*. */
console.log('\n⑪ Buổi đã dự xong thì thôi mang nét đứt, và chuỗi tự thành đã chốt');
{
  const sach = catKhoi('<style>', '</style>').replace(/\/\*[\s\S]*?\*\//g, '');
  for (const lop of ['tlg', 'tlt', 'tlw'])
    la(`nấc ${lop}: luật nét đứt loại trừ .xong`,
       sach.includes(`.${lop}-viec.lich.chua-chot:not(.xong)`),
       'khối đã dự xong mà còn nét đứt là hình tự nói ngược mình');

  const ham = catKhoi('async function lcChotViDaXong(', '\n}');
  la('chỉ gửi khi máy chủ có cột', /if \(!CO_CHOT_LICH/.test(ham),
     'gửi một cột chưa tồn tại là hỏng cả câu lệnh');
  la('không gửi lại khi chuỗi đã chốt sẵn', /da_chot !== false/.test(ham),
     'mỗi lần tick xong lại bắn một lượt ghi thừa');
  la('hỏi quyền trước khi ghi `lich_chung`', /lcDuocSua\(l\)/.test(ham),
     'người dự thường sẽ bị hàng rào sua_lich chối');
  la('hỏng thì im lặng, không cướp lấy cú tick',
     /if \(error\) return;/.test(ham) && !/toast/.test(ham),
     'kêu một câu lỗi về cột họ không biết mình đang đổi là làm hỏng thao tác đang đúng');
  la('vá kho trong máy sau khi ghi', /l\.da_chot = true;/.test(ham),
     'không vá thì mở cửa Sự kiện ngay sau đó vẫn thấy nấc cũ');

  /* HAI cửa đánh dấu xong đều phải gọi. Đếm chỗ gọi thay vì soi từng hàm: thêm
     một cửa thứ ba mà quên gọi thì con số này lệch ngay. */
  const tick = catKhoi('async function lcTickXong(', '\n}');
  la('cửa ① ô tick trên khối có gọi', /if \(xong\) await lcChotViDaXong\(id\)/.test(tick),
     'tick xong trên lưới mà chuỗi vẫn dự kiến');
  const traLoi = catKhoi('async function lcTraLoi(', '\n}');
  la('cửa ② nút Hoàn thành trong cửa buổi có gọi',
     /kieu === 'xong'\) await lcChotViDaXong\(id\)/.test(traLoi),
     'bấm Hoàn thành mà chuỗi vẫn dự kiến');
  la('lời TỪ CHỐI không kéo theo chốt lịch',
     !/'khong'\) await lcChotViDaXong/.test(traLoi),
     'từ chối đi họp không nói gì về chuyện lịch đã chốt hay chưa');

  /* MỘT CHIỀU: đường tự động chỉ được nâng lên, không được hạ xuống. Hạ nấc là
     đặc quyền của hai cái nút trong cửa Sự kiện.
     ⚠️ Phép kiểm này phải soi ĐÚNG câu ghi xuống `lich_chung`, đừng quét cả tệp
     tìm chuỗi `da_chot: false` — bản đầu làm thế và đỏ oan: màn *khép lời cuối
     ngày* (`htMo`) đắp một trường **cùng tên** lên đối tượng TASK của nó, không
     dính gì tới cột của `lich_chung`. Tên trùng, hai thế giới. */
  const cauGhi = [...SRC.matchAll(/from\('lich_chung'\)\s*\.update\(([^)]*)\)/g)].map(m => m[1]);
  la('có đúng một câu ghi tự động xuống `lich_chung` ngoài cửa Sự kiện',
     cauGhi.filter(x => /da_chot/.test(x)).length === 1,
     'đếm được ' + cauGhi.filter(x => /da_chot/.test(x)).length);
  la('câu ấy chỉ NÂNG lên true, không hạ xuống false',
     cauGhi.every(x => !/da_chot:\s*false/.test(x)),
     'một đường tự động hạ nấc là xoá lựa chọn người dùng vừa khai');
}

console.log(`\n${truot ? '❌' : '✅'}  ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);
