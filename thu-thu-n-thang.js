/* THỬ: SỰ KIỆN HẰNG THÁNG THEO «THỨ N CỦA THÁNG»  (TRI-58)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"sao lặp hàng tuần, tháng mất hàng t2-cn của tôi rồi vì có thể
   2 buổi 1 tuần/tháng mà"* → chốt phương án Ⓒ, khuôn RRULE FREQ=MONTHLY BYDAY.

   Sáu ca đáng giá nhất — đều là chỗ mà thử tay từng bước KHÔNG lộ ra, vì muốn
   thấy chúng phải mở app vào đúng một tháng có hình dạng riêng:

     · TUẦN CUỐI KHÔNG PHẢI TUẦN THỨ NĂM. Tháng nào cũng có tuần cuối, còn lần
       xuất hiện thứ năm của một thứ thì tháng có tháng không. Lẫn hai thứ này
       thì một chuỗi "thứ Sáu cuối tháng" im lặng bỏ qua chín tháng mỗi năm —
       và bỏ qua thì không có tiếng kêu nào, chỉ là một buổi không bao giờ tới.

     · THÁNG 28 NGÀY LÀ CHỖ HAI VẾ TRỎ CÙNG MỘT NGÀY. Khai cả tuần 4 lẫn tuần
       cuối vào tháng Hai thường thì đó là một ngày duy nhất. Hàm phải trả một
       câu có/không, không được đếm hai lần thành hai buổi chồng lên nhau.

     · LỐI CŨ PHẢI CÒN NGUYÊN. Mọi chuỗi hằng tháng đã khai đều đi lối
       `ngay_thang`. Máy chủ chưa chạy tệp nâng cấp thì cột mới về `undefined`
       — và đúng lúc ấy hàm phải rơi về lối cũ, không phải rơi về "không có
       buổi nào".

     · MỘT THỨ, HAI TUẦN = HAI BUỔI MỖI THÁNG. Đây là chính điều Tracy hỏi.

     · KHÔNG KHỚP THỨ THÌ DỪNG NGAY, kể cả khi số tuần khớp.

     · NHÃN PHẢI ĐỌC RA ĐƯỢC. `-1` là quy ước của máy chủ; người đọc thẻ lịch
       thấy chữ "cuối", không thấy con số âm.

   Chạy:  node production/tinh-thuc-app/thu-thu-n-thang.js
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

/* Cắt hàm THẬT từ mã, không chép một bản thứ hai vào bài thử: một bản chép là
   một bản sẽ trôi khỏi bản gốc mà không ai hay. */
/* `lcHopBuoc` đứng NGAY TRÊN `lcHopNgay` và được nó gọi tới, nên phải cắt
   cùng — một khối cắt bỏ sót hàm mình gọi thì ngã ngay lượt chạy đầu. */
const MA = catKhoi('function lcHopBuoc(l, d){', '\n/* GIỜ THẬT CỦA MỘT LƯỢT');
const LC_TEN_THU = ['CN','T2','T3','T4','T5','T6','T7'];
const {lcHopNgay, lcNhanLap} = new Function('LC_TEN_THU',
  MA + '\nreturn {lcHopNgay, lcNhanLap};')(LC_TEN_THU);

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}
/* Mọi ngày trong một tháng mà luật này nổ ra. Đây là thứ người khai thật sự
   hỏi — "tháng này tôi có mấy buổi, vào hôm nào" — nên bài thử hỏi đúng câu ấy
   thay vì soi từng ngày một. */
function noRa(l, nam, thang){
  const het = new Date(nam, thang, 0).getDate();
  const ra = [];
  for (let n = 1; n <= het; n++){
    const g = `${nam}-${String(thang).padStart(2,'0')}-${String(n).padStart(2,'0')}`;
    if (lcHopNgay(l, g)) ra.push(n);
  }
  return ra;
}
const NEN = {lap: 'thang', ngay_bat_dau: '2020-01-01', ngay_ket_thuc: null};

/* ── ① MỘT THỨ, HAI TUẦN — chính câu hỏi của Tracy ─────────────────────── */
console.log('\n① Thứ Ba tuần 1 và tuần 3 — phải ra ĐÚNG hai buổi mỗi tháng');
{
  const l = {...NEN, thu: [2], tuan_thang: [1, 3]};
  for (const [nam, thang] of [[2026,9],[2026,10],[2026,11],[2027,2]]){
    const ra = noRa(l, nam, thang);
    const dungThu = ra.every(n => new Date(nam, thang-1, n).getDay() === 2);
    la(`${thang}/${nam} ra hai buổi, cả hai đều là thứ Ba — [${ra}]`,
       ra.length === 2 && dungThu, `ra ${ra.length} buổi: [${ra}]`);
    /* Buổi đầu phải nằm trong tuần lễ đầu (ngày 1–7), buổi sau trong 15–21 —
       đó mới là nghĩa "lần xuất hiện thứ nhất" và "thứ ba". */
    la(`   rơi đúng lần 1 (ngày 1–7) và lần 3 (ngày 15–21)`,
       ra[0] <= 7 && ra[1] >= 15 && ra[1] <= 21, `[${ra}]`);
  }
}

/* ── ② TUẦN CUỐI, không phải tuần thứ năm ──────────────────────────────── */
console.log('\n② Thứ Sáu tuần cuối — tháng NÀO CŨNG phải có đúng một buổi');
{
  const l = {...NEN, thu: [5], tuan_thang: [-1]};
  for (let thang = 1; thang <= 12; thang++){
    const ra = noRa(l, 2026, thang);
    const het = new Date(2026, thang, 0).getDate();
    la(`${thang}/2026 — một buổi, và không còn thứ Sáu nào sau nó`,
       ra.length === 1 && ra[0] + 7 > het, `ra [${ra}], tháng có ${het} ngày`);
  }
  /* Đối chứng: khai "5" (lần thứ năm) là thứ mà tháng có tháng không — vì thế
     ràng buộc SQL không nhận nó, và hàm cũng không được coi nó là tuần cuối. */
  const nam5 = {...NEN, thu: [5], tuan_thang: [5]};
  la('khai lần thứ 5 KHÔNG được hiểu thành tuần cuối',
     noRa(nam5, 2026, 2).length === 0, 'tháng 2/2026 vẫn nổ ra buổi');
}

/* ── ③ TUẦN 4 VÀ TUẦN CUỐI: khi nào là một ngày, khi nào là hai ────────── */
console.log('\n③ Tuần 4 + tuần cuối — trùng hay tách, và không bao giờ hoá hai buổi');
{
  /* ⚠️ Bài thử này lúc viết ra đã tự sai, và cái sai ấy đáng giữ lại: tôi đoán
     "tháng 31 ngày thì hai vế tách nhau". KHÔNG PHẢI. Hai vế tách nhau khi và
     chỉ khi thứ ấy xuất hiện NĂM lần trong tháng — tức lần đầu của nó rơi vào
     ngày ≤ (số ngày trong tháng − 28). Tháng 3/2026 có 31 ngày mà thứ Tư đầu
     tiên là ngày 4, nên chỉ có bốn thứ Tư: tuần 4 và tuần cuối cùng trỏ ngày 25.
     Độ dài tháng một mình không quyết định gì cả. */
  const l = {...NEN, thu: [3], tuan_thang: [4, -1]};
  la('tháng 2/2027 (28 ngày, bốn thứ Tư) — ĐÚNG một buổi',
     noRa(l, 2027, 2).length === 1, `[${noRa(l, 2027, 2)}]`);
  la('tháng 3/2026 (31 ngày, vẫn chỉ bốn thứ Tư) — ĐÚNG một buổi',
     JSON.stringify(noRa(l, 2026, 3)) === '[25]', `[${noRa(l, 2026, 3)}]`);
  /* Tháng 3/2026 có NĂM thứ Hai: 2·9·16·23·30. Đây mới là hình dạng tách. */
  const l2 = {...NEN, thu: [1], tuan_thang: [4, -1]};
  const ra2 = noRa(l2, 2026, 3);
  la('cùng tháng ấy, thứ Hai xuất hiện năm lần — ra hai buổi 23 và 30',
     JSON.stringify(ra2) === '[23,30]', `[${ra2}]`);
  /* Quét cả năm: dù trùng hay tách, không tháng nào được vượt quá hai buổi, và
     không tháng nào được để lọt một ngày trùng lặp. */
  let quaHai = 0, trungLap = 0;
  for (let t = 1; t <= 12; t++) for (let d = 0; d <= 6; d++){
    const ra = noRa({...NEN, thu: [d], tuan_thang: [4, -1]}, 2026, t);
    if (ra.length > 2) quaHai++;
    if (new Set(ra).size !== ra.length) trungLap++;
  }
  la('quét 84 cặp tháng×thứ của năm 2026 — không cặp nào quá hai buổi',
     quaHai === 0, `${quaHai} cặp vượt`);
  la('… và không cặp nào đếm một ngày hai lần', trungLap === 0);
}

/* ── ④ LỐI CŨ «NGÀY MÙNG N» còn nguyên ─────────────────────────────────── */
console.log('\n④ Lối cũ — kể cả khi máy chủ chưa có cột mới');
{
  const cu = {...NEN, ngay_thang: 3, thu: [], tuan_thang: []};
  la('ngày mùng 3 nổ đúng một buổi vào ngày 3',
     JSON.stringify(noRa(cu, 2026, 9)) === '[3]');
  /* Cột chưa có trên máy chủ thì về `undefined`, KHÔNG phải mảng rỗng. Hàm
     phải rơi về lối cũ chứ không rơi về "không buổi nào". */
  const chuaCo = {...NEN, ngay_thang: 3};
  la('cột `tuan_thang` chưa có (undefined) vẫn chạy lối cũ',
     JSON.stringify(noRa(chuaCo, 2026, 9)) === '[3]');
  /* Ngày 31 vào tháng Hai thì tháng đó KHÔNG có buổi — luật cũ, không được đổi. */
  const ngay31 = {...NEN, ngay_thang: 31, tuan_thang: []};
  la('ngày 31 vào tháng Hai thì tháng đó không có buổi',
     noRa(ngay31, 2026, 2).length === 0);
}

/* ── ⑤ KHÔNG KHỚP THỨ THÌ DỪNG, dù số tuần có khớp ────────────────────── */
console.log('\n⑤ Hàng rào thứ, và hàng rào quãng ngày');
{
  const l = {...NEN, thu: [2], tuan_thang: [1]};
  la('thứ Hai đầu tháng KHÔNG nổ khi luật khai thứ Ba',
     !lcHopNgay(l, '2026-09-07') || new Date('2026-09-07T00:00:00').getDay() === 2);
  const ra = noRa(l, 2026, 9);
  la('cả tháng chỉ có đúng một ngày khớp', ra.length === 1, `[${ra}]`);
  /* Quãng ngày vẫn phải gác trước mọi luật lặp. */
  const hep = {...NEN, thu: [2], tuan_thang: [1,2,3,4,-1],
               ngay_bat_dau: '2026-09-10', ngay_ket_thuc: '2026-09-20'};
  const raH = noRa(hep, 2026, 9);
  la('ngoài quãng ngày thì không buổi nào lọt',
     raH.every(n => n >= 10 && n <= 20), `[${raH}]`);
}

/* ── ⑥ NHÃN ĐỌC RA ĐƯỢC ────────────────────────────────────────────────── */
console.log('\n⑥ Nhãn trên thẻ lịch — không để lộ con số -1 ra ngoài');
{
  const n1 = lcNhanLap({lap:'thang', thu:[2], tuan_thang:[1,3]});
  la('«T3 tuần 1 · 3 hằng tháng»', n1 === 'T3 tuần 1 · 3 hằng tháng', n1);
  const n2 = lcNhanLap({lap:'thang', thu:[5], tuan_thang:[-1]});
  la('«T6 tuần cuối hằng tháng»', n2 === 'T6 tuần cuối hằng tháng', n2);
  const n3 = lcNhanLap({lap:'thang', thu:[5], tuan_thang:[-1,2]});
  la('tuần cuối xếp SAU cùng, không xếp trước theo số âm',
     n3 === 'T6 tuần 2 · cuối hằng tháng', n3);
  const n4 = lcNhanLap({lap:'thang', ngay_thang: 3, tuan_thang: []});
  la('lối cũ vẫn đọc «ngày 3 hằng tháng»', n4 === 'ngày 3 hằng tháng', n4);
  la('không nhãn nào để lọt chữ "-1"', ![n1,n2,n3,n4].some(x => x.includes('-1')));
}

/* ── ⑦ MÃ VÀ TỆP SQL PHẢI KHỚP NHAU ────────────────────────────────────── */
console.log('\n⑦ Giao diện, đường ghi, và ràng buộc máy chủ nói cùng một luật');
{
  la('có cờ dò cột riêng `CO_TUAN_THANG`',
     SRC.includes('let CO_TUAN_THANG') && SRC.includes('CO_TUAN_THANG = !rtt.error'));
  la('đường ghi chỉ gửi `tuan_thang` khi cờ bật',
     SRC.includes('if (CO_TUAN_THANG) dong.tuan_thang'));
  /* HAI CA ĐÃ GỠ — chúng đếm `id="lc-tl"` và `id="lc-tuan-o"` phải có mặt ở cả
     hai khung form. Cửa lặp nay chỉ còn MỘT ô chọn nấc (`#lc-lap`) với các nấc
     dựng sẵn, `lcDoiNac` đặt thẳng luật; hai ô kia đã tháo khỏi cả hai khung nên
     phép đếm trả 0 ở mọi lượt. Điều hai ca ấy thật sự canh — hai cửa phải khai
     được cùng một thứ — nay do `thu-hai-cua-dong-bo.js` gác, đúng chỗ hơn. */
  la('hàng tuần dùng LẠI nút `lc-thu-nut`, không dựng lớp thứ hai',
     SRC.includes('.lc-tuan .lc-thu-nut{'));
  const sql = fs.readFileSync(path.join(__dirname, 'nang-cap-lich-thu-n-thang.sql'), 'utf8');
  la('tệp SQL nhận đúng bộ giá trị 1·2·3·4·-1',
     sql.includes('array[1,2,3,4,-1]::smallint[]'));
  la('tệp SQL nới ràng buộc `lich_lap_du_tham_so`',
     sql.includes('drop constraint if exists lich_lap_du_tham_so') &&
     sql.includes('add constraint lich_lap_du_tham_so'));
  la('tệp SQL giữ nguyên cột `ngay_thang` — không dòng nào gỡ nó',
     !/drop\s+column[^\n]*ngay_thang/i.test(sql));
  /* 🪤 Bẫy đã cắn thật 03/09: trình chạy SQL của Supabase bọc CẢ TỆP trong một
     transaction, nên một cú `rollback` ở tầng ngoài cùng — dù chỉ định huỷ một
     dòng thử — cuốn ngược luôn `alter table add column` phía trên. Tệp chạy
     xong mà cột không hề được tạo, và câu báo lỗi trỏ vào chỗ nó LỘ RA chứ
     không trỏ vào chỗ nó hỏng. Phép kiểm này bỏ qua chữ trong chú thích, vì
     chính bài học ấy được kể lại bằng chữ ngay trong tệp. */
  const cauSql = sql.split('\n').filter(d => !d.trimStart().startsWith('--')).join('\n');
  la('tệp SQL KHÔNG có `rollback` ở tầng ngoài cùng',
     !/^\s*(rollback|begin)\s*;/im.test(cauSql),
     'một cú rollback ở đây cuốn ngược cả `alter table` phía trên');
  la('phép thử ghi bọc trong khối `do $$` — transaction con, dọn được dấu vết',
     /do\s+\$\$/.test(cauSql) && cauSql.includes("delete from lich_chung where ten ="));
  /* Bộ nút giao diện và ràng buộc máy chủ phải kê cùng một bộ số. Lệch nhau là
     bày ra một nút bấm được mà lưu xuống thì máy chủ chặn. */
  const nut = catKhoi('const LC_TUAN_NUT = [', '];');
  const so  = [...nut.matchAll(/\[(-?\d+),/g)].map(m => Number(m[1])).sort((a,b)=>a-b);
  la('năm nút giao diện khớp đúng năm giá trị máy chủ nhận',
     JSON.stringify(so) === JSON.stringify([-1,1,2,3,4]), `[${so}]`);
}

/* ── ⑧ ĐÃ GỠ — khuôn form bốn ô không còn tồn tại ────────────────────────
   Ca này canh `lcDoiLoi` bật tắt bốn ô `lc-thu-o` · `lc-tuan-o` · `lc-nt-o`
   theo nhánh lặp đang chọn. Cửa sự kiện đã được dựng lại: nay chỉ còn MỘT ô
   chọn nấc (`#lc-lap`) với các nấc dựng sẵn — hằng ngày · hằng tuần · T2–T6 ·
   ngày N hằng tháng · thứ N tuần thứ k · thứ N cuối tháng — và `lcDoiNac` đặt
   thẳng luật thay vì ẩn hiện ô. Không còn ô nào để mà bật tắt.
   Gỡ ca chứ không nới, cùng lẽ với ca ⑤ của `thu-keo-mep-va-o-den`: một bài thử
   gác khuôn đã tháo thì cứ xanh mãi mà chẳng canh gì. Luật ẩn/hiện của cửa MỚI
   nếu cần canh thì là một ca mới, viết theo `#lc-lap`. */


console.log(`\n${truot ? '❌' : '✅'}  ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);
