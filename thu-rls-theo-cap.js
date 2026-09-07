/* THỬ: HÀNG RÀO RLS THEO CẤP — bốn tệp SQL của TRI-144  (07/09)
   ─────────────────────────────────────────────────────────────────────────────
   BÀI NÀY CANH GÌ, VÀ CANH ĐƯỢC TỚI ĐÂU. Bằng chứng THẬT cho hàng rào nằm ở máy
   chủ: hàm `thu_hang_rao_cap()` đóng vai từng người rồi ĐẾM THẬT. Bài này không
   thay được nó và không định thay — nó canh phần mà máy chủ không canh nổi:
   **tệp `.sql` trong kho có còn nói đúng thứ đã chạy không**, và **có ai lặng lẽ
   sửa một vế đi không**. Máy chủ chỉ biết trạng thái hôm nay; kho mã mới là thứ
   phiên sau đọc rồi chạy lại.

   VÌ SAO NHỮNG CA NÀY ĐÁNG GIÁ — mỗi ca dưới đây canh một chỗ mà nếu hỏng thì
   MÀN HÌNH VẪN TRÔNG ĐÚNG Y NHƯ CŨ:

     · VẾ CHẶN NULL. `la_thanh_vien_du_an(null, …)` trả TRUE. Bỏ vế
       `muc_tieu_id is not null` khỏi `doc_tieudiem` là mọi cam kết không gắn dự
       án (54/64 dòng ngày ban hành) hở lại cho mọi Member — mà giao diện đã tự
       lọc rồi nên không ai thấy gì khác.

     · `la_thanh_vien_du_an` PHẢI GIỮ `security definer`. Nó đọc chính hai bảng
       mà policy của nó đang gác. Đổi sang invoker là đệ quy vô hạn — hỏng to và
       hỏng ngay, nhưng người "dọn" chữ definer đi thì không biết mình vừa làm gì.

     · `thu_hang_rao_cap` PHẢI GIỮ `security invoker`. Đổi sang definer thì bài
       thử ấy chạy bằng quyền chủ bảng và mọi con số hoá ra 100% — một bảng toàn
       ✅ chứng minh một hàng rào không tồn tại. Đây là ✅ oan nguy nhất trong cả
       loạt việc.

     · RANH GIỚI BẢNG ĐO. `ket_qua_ngay` có một vế `exists` đứng trên `nhip`, nên
       siết `doc_nhip` là dải 💎🪨💩 của người ngoài khối biến mất khỏi bảng đo của
       Member. Tracy chốt bảng đo mở cho MỌI cấp. Ca ⑦ chặn đúng đường ấy.

   🪤 MỌI CA ĐỀU DÒ TRÊN BẢN ĐÃ GỠ CHÚ THÍCH. Bốn tệp này giải thích rất dài về
   `nhip`, `so_ngay`, `task`, `la_lead` — dò cả tệp là phạt đúng những đoạn văn
   ghi lại bài học. Cùng bài học đã chép ở ca ⑨ của `thu-loai-ca-nhan.js` và ở
   làn HGD; đây là lần thứ tư nó tái diễn nên lần này gỡ chú thích ngay từ đầu.
   ───────────────────────────────────────────────────────────────────────────── */
const fs = require('fs'), path = require('path');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}
const doc = (t) => fs.readFileSync(path.join(__dirname, t), 'utf8');

/* Gỡ chú thích SQL: khối `/* … *​/` trước, rồi `--` tới cuối dòng — nhưng chỉ khi
   dấu `--` KHÔNG nằm trong một chuỗi nháy đơn, vì thân `comment on …` của mấy tệp
   này có nhắc tên bảng và tên hàm. */
function goChuThich(sql){
  sql = sql.replace(/\/\*[\s\S]*?\*\//g, ' ');
  return sql.split('\n').map(d => {
    let trong = false;
    for (let i = 0; i < d.length; i++){
      if (d[i] === "'") trong = !trong;
      else if (!trong && d[i] === '-' && d[i+1] === '-') return d.slice(0, i);
    }
    return d;
  }).join('\n');
}

const NHAT = {
  '⓪ nền'          : 'nang-cap-cap-dang-nhap.sql',
  '① cam kết'      : 'nang-cap-rls-cam-ket.sql',
  '② dự án'        : 'nang-cap-rls-du-an.sql',
  '③ việc cố định' : 'nang-cap-rls-viec-co-dinh.sql',
  '④ bịt cửa tra cứu' : 'nang-cap-bit-cua-tra-cuu-du-an.sql',
};
const MA = {};   // tệp → mã đã gỡ chú thích
for (const [nhan, tep] of Object.entries(NHAT)) MA[tep] = goChuThich(doc(tep));
const MOI = Object.values(MA).join('\n');   // mã của cả bốn nhát


/* ── ① BỐN NHÁT CÓ MẶT, VÀ TỰ KHAI THỨ TỰ CHẠY ─────────────────────────── */
console.log('\n① Bốn tệp nhát');
{
  for (const [nhan, tep] of Object.entries(NHAT))
    la(`nhát ${nhan} — ${tep}`, fs.existsSync(path.join(__dirname, tep)));

  /* Chạy sai thứ tự là lỗi "function does not exist" — rõ ràng, không im lặng.
     Nhưng người chạy đáng được biết TRƯỚC, không phải sau khi ném lỗi. */
  for (const tep of ['nang-cap-rls-cam-ket.sql', 'nang-cap-rls-du-an.sql',
                     'nang-cap-rls-viec-co-dinh.sql'])
    la(`${tep} khai rõ nó phải chạy sau nhát trước`,
       /CHẠY SAU/.test(doc(tep)),
       'ba tệp sau đều gọi la_member() do nhát ⓪ dựng');
}


/* ── ② HAI HÀM NỀN ─────────────────────────────────────────────────────── */
console.log('\n② Hàm nền — cap_dang_nhap · la_member');
{
  const nen = MA['nang-cap-cap-dang-nhap.sql'];

  /* 🪤 CẮT ĐÚNG THÂN HÀM, giữa hai dấu `$$` — đừng cắt "từ tên hàm này tới tên
     hàm sau". Lối cắt rộng ấy nuốt luôn câu `comment on function` đứng giữa, mà
     câu ấy là một CHUỖI nên bộ gỡ chú thích cố ý giữ nguyên. Ca "không hỏi
     ngay_nghi" đỏ oan ngay lần chạy đầu vì đúng chuyện này: nó phạt chính dòng
     ghi lại lý do KHÔNG hỏi ngay_nghi. Lần thứ tư trong kho này — trước đó ở ca
     ⑨ `thu-loai-ca-nhan.js` và ở làn HGD. */
  function thanHam(sql, ten){
    const dau = sql.indexOf('function ' + ten);
    const mo  = sql.indexOf('$$', dau);
    const dong = sql.indexOf('$$', mo + 2);
    return sql.slice(mo + 2, dong);
  }
  const than = thanHam(nen, 'cap_dang_nhap');

  la('cap_dang_nhap() hỏi la_quan_tri TRƯỚC la_lead',
     than.indexOf('la_quan_tri') > -1 &&
     than.indexOf('la_lead') > -1 &&
     than.indexOf('la_quan_tri') < than.indexOf('la_lead'),
     'quản trị mang CẢ HAI cờ; hỏi ngược là Tracy và Andy đọc ra "Lead" — một cái '
   + 'sai không làm ai mất quyền gì, nên nó sống tới ngày có giới hạn cho cấp Lead');

  la('cap_dang_nhap() KHÔNG hỏi ngay_nghi',
     !/ngay_nghi/.test(than),
     'đã nghỉ là câu hỏi KHÁC câu hỏi cấp — la_thanh_vien() lo việc đó. Trộn hai '
   + 'câu vào một hàm thì ngày mai không tách ra được nữa');

  la('la_member() ngả về phía chặt khi không biết người hỏi là ai',
     /coalesce\s*\(\s*cap_dang_nhap\(\)\s*=\s*'member'\s*,\s*true\s*\)/
       .test(thanHam(nen, 'la_member')),
     'coalesce(…, false) là người lạ được đối xử như Lead ở bất cứ policy nào '
   + 'quên kèm la_thanh_vien() — và một ngày nào đó sẽ có một policy quên');
}


/* ── ③ CỔNG GÁC KHUNG NHÌN: ép boolean, không so chuỗi ─────────────────── */
console.log('\n③ Cổng gác khung nhìn');
{
  const nen  = MA['nang-cap-cap-dang-nhap.sql'];
  const dau  = nen.indexOf('function kiem_khung_nhin_thieu_quyen');
  const mo   = nen.indexOf('$$', dau);

  /* 🪤 HAI VÙNG, ĐỪNG GỘP. Một hàm Postgres có ĐẦU (chữ ký, `language`,
     `security …`, `set search_path`) và THÂN (giữa hai dấu `$$`) — hai thứ hỏi
     hai câu khác nhau, và gộp chúng lại thì mỗi ca đều dò rộng hơn cần.
       · dò `security invoker` mà nhìn vào THÂN  → đỏ oan (nó nằm ở ĐẦU)
       · dò `'security_invoker=on'` mà nhìn cả ĐẦU lẫn câu `comment on` phía sau
         → cũng đỏ oan, vì câu chú thích ấy nhắc nguyên văn chuỗi để kể lại bẫy
     Cả hai lối đều đã vấp trong chính lượt viết bài này. */
  const dauHam = nen.slice(dau, mo);                          // chữ ký
  const than   = nen.slice(mo + 2, nen.indexOf('$$', mo + 2)); // thân

  la('đọc tuỳ chọn rồi ÉP VỀ BOOLEAN',
     /split_part\([\s\S]{0,40}\)::boolean/.test(than));

  la('KHÔNG còn so chuỗi với "security_invoker=on"',
     !/'security_invoker=on'/.test(than),
     'Postgres cất lại ĐÚNG CHỮ người ta gõ: `with (… = true)` cất thành '
   + '"security_invoker=true" và `set (… = on)` cất thành "security_invoker=on". '
   + 'Bản so chuỗi kêu oan ai_dang_lam suốt từ 03/09 tới 07/09');

  la('cổng gác tự nó chạy bằng quyền người hỏi',
     /security invoker/.test(dauHam),
     'một cổng gác chạy bằng quyền người tạo thì chính nó là thứ đầu tiên phạm '
   + 'luật nó canh');

  la('KHÔNG đụng vào chính khung nhìn ai_dang_lam',
     !/\bai_dang_lam\b/.test(MOI.replace(/'[^']*'/g, "''")),
     'nó đang đúng; dựng lại một khung nhìn đang chạy chỉ để "cho chắc" là rước '
   + 'rủi ro không đổi lấy gì — `drop view` còn làm rơi cờ trong im lặng');
}


/* ── ④ NĂM POLICY ĐỌC ĐỀU HỎI CẤP ──────────────────────────────────────── */
console.log('\n④ Năm policy đọc');
{
  const CAN = {
    doc_tieudiem : 'nang-cap-rls-cam-ket.sql',
    doc_muctieu  : 'nang-cap-rls-du-an.sql',
    doc_thanhvien: 'nang-cap-rls-du-an.sql',
    doc_moc      : 'nang-cap-rls-du-an.sql',
    doc_viec     : 'nang-cap-rls-viec-co-dinh.sql',
  };
  for (const [ten, tep] of Object.entries(CAN)){
    const m = MA[tep].match(new RegExp(`create policy ${ten}[\\s\\S]*?\\n\\);`));
    la(`${ten} có hỏi cấp`, !!m && /la_member\(\)/.test(m[0]),
       'không gọi la_member() thì policy vẫn mở cho cả 12 người');
    if (m) la(`${ten} vẫn để Lead và Quản trị đi trọn bảng`,
              /not\s+la_member\(\)/.test(m[0]),
              'thiếu vế `not la_member()` là siết luôn cả Lead — hỏng nặng hơn siết thiếu');
  }
}


/* ── ⑤ VẾ CHẶN NULL — chỗ dễ "dọn" nhất trong cả loạt việc ─────────────── */
console.log('\n⑤ Vế chặn null của doc_tieudiem');
{
  const ck = MA['nang-cap-rls-cam-ket.sql'];
  const pol = (ck.match(/create policy doc_tieudiem[\s\S]*?\n\);/) || [''])[0];

  la('doc_tieudiem giữ vế muc_tieu_id is not null',
     /muc_tieu_id\s+is\s+not\s+null/i.test(pol),
     'la_thanh_vien_du_an(null, …) trả TRUE ngay dòng đầu thân hàm. Bỏ vế này là '
   + 'mọi cam kết không gắn dự án hở lại cho mọi Member — 54/64 dòng ngày ban hành');

  la('và vế ấy đứng TRƯỚC lời gọi hàm, không sau',
     pol.search(/muc_tieu_id\s+is\s+not\s+null/i) < pol.search(/la_thanh_vien_du_an/),
     'đứng sau thì vẫn đúng về logic nhưng đọc ra như một điều kiện phụ — mà nó '
   + 'là điều kiện CHÍNH giữ cho lời gọi kia không trả TRUE oan');

  /* Ba policy của nhát ② cố ý KHÔNG có vế này, vì hai cột kia khai `not null`
     tận nơi. Ca dưới canh chiều NGƯỢC LẠI: đừng "đồng nhất hoá" chúng, vì làm
     thế là dạy người đọc rằng vế ấy chỉ là một thói quen. */
  const da = MA['nang-cap-rls-du-an.sql'];
  la('ba policy dự án cố ý KHÔNG chép vế chặn null',
     !/muc_tieu_id\s+is\s+not\s+null/i.test(da),
     'thanh_vien_du_an.muc_tieu_id và moc_du_an.muc_tieu_id đều khai NOT NULL. '
   + 'Thêm vế thừa cho "đồng nhất" là ngày ai đó dọn cả bốn cho gọn, cái duy nhất '
   + 'LOAD-BEARING đi theo');
}


/* ── ⑥ HAI HÀM ĐƯỢC DÙNG LẠI, VÀ NẾT NGƯỢC NHAU CỦA CHÚNG ──────────────── */
console.log('\n⑥ Dùng lại hàm có sẵn, không viết hàm thứ hai');
{
  const da = MA['nang-cap-rls-du-an.sql'], vcd = MA['nang-cap-rls-viec-co-dinh.sql'];

  la('nhát ② đi qua la_thanh_vien_du_an(), không tự chép phép so',
     (da.match(/la_thanh_vien_du_an/g) || []).length >= 3 &&
     !/from\s+thanh_vien_du_an\s+v/.test(da),
     'chép lại điều kiện vào policy là đẻ bản thứ hai của một luật, rồi ngày đổi '
   + 'luật thì sót một bản');

  la('nhát ③ đi qua la_nguoi_cua_khoi(), không tự so mảng',
     /la_nguoi_cua_khoi\s*\(\s*chuc_nang_id\s*\)/.test(vcd) &&
     !/chuc_nang_ids\s*&&/.test(vcd) && !/=\s*any\s*\(\s*n\.chuc_nang_ids/.test(vcd));

  /* 🪤 Hai hàm này có NẾT NGƯỢC NHAU khi gặp null, và cả hai tệp phải nói ra
     điều đó — vì người đọc rất dễ suy từ hàm này sang hàm kia. */
  la('nhát ① nói rõ la_thanh_vien_du_an(null,…) trả TRUE',
     /la_thanh_vien_du_an\(null/.test(doc('nang-cap-rls-cam-ket.sql')));
  la('nhát ③ nói rõ la_nguoi_cua_khoi trả FALSE khi null — nết ngược lại',
     /Ngược với `la_thanh_vien_du_an\(\)`/.test(doc('nang-cap-rls-viec-co-dinh.sql')),
     'suy nết hàm này từ hàm kia là chỗ sinh ra bẫy tiếp theo');
}


/* ── ⑦ RANH GIỚI — hai chỗ CẤM siết, và chúng phải còn nguyên ──────────── */
console.log('\n⑦ Ranh giới Tracy chốt 07/09');
{
  /* Không tệp nào của làn này được dựng lại policy đọc của bốn bảng dưới. Dò
     trên mã đã gỡ chú thích — bốn tệp này nhắc tên chúng rất nhiều trong phần
     giải thích. */
  const CAM = {
    'doc_nhip'   : 'ket_qua_ngay có vế `exists` đứng trên nhip — siết là dải 💎🪨💩 của người '
                 + 'ngoài khối biến mất khỏi BẢNG ĐO của Member (G-01.aq)',
    'doc_songay' : 'so_ngay đi vào ket_qua_ngay qua cross join — cùng hậu quả (G-01.aq)',
    'doc_task'   : 'gat_theo_ngay và vuon_cay đều đọc task, và chúng nuôi BẢNG ĐO (G-01.ap)',
    'doc_van_de' : 'Tracy chốt *"đăng vấn đề thì cho toàn bộ 12 người"*',
  };
  for (const [pol, vi] of Object.entries(CAM))
    la(`không nhát nào siết ${pol}`,
       !new RegExp(`create policy ${pol}\\b`).test(MOI), vi);

  la('không nhát nào bật force row level security',
     !/force\s+row\s+level\s+security/i.test(MOI),
     'nó làm CHỦ BẢNG cũng bị policy soi, chạm mọi thao tác bảo trì kể cả sửa tay '
   + 'trong Table Editor. Việc riêng, nhánh riêng, nghiệm thu riêng');

  la('không nhát nào dựng lại một khung nhìn',
     !/create\s+(or\s+replace\s+)?view/i.test(MOI),
     'mọi khung nhìn liên quan đã bật security_invoker nên tự thừa hưởng. Dựng lại '
   + 'là rước rủi ro không đổi lấy gì — riêng tien_do_o có TÁM bản chồng nhau trong kho');
}


/* ── ⑧ BÀI THỬ TRÊN MÁY CHỦ PHẢI GIỮ ĐÚNG NẾT CỦA NÓ ───────────────────── */
console.log('\n⑧ thu_hang_rao_cap — bài thử phải tự nó đáng tin');
{
  /* Lấy bản MỚI NHẤT: ba tệp cùng `create or replace` hàm này, nhát ③ là bản chót. */
  const vcd = MA['nang-cap-rls-viec-co-dinh.sql'];
  /* Bó vùng ở `commit;` — lấy tới cuối tệp là nuốt luôn bộ TỰ KIỂM, mà bộ ấy
     nhắc lại đủ mọi tên bảng và tên cột. Ca nào cũng sẽ xanh, kể cả khi thứ nó
     canh đã biến mất khỏi thân hàm. */
  const than = vcd.slice(vcd.indexOf('function thu_hang_rao_cap'),
                         vcd.indexOf('\ncommit;', vcd.indexOf('function thu_hang_rao_cap')));

  la('khai security INVOKER, không phải definer',
     /security invoker/.test(than) && !/security definer/.test(than),
     '⚠️ ĐÂY LÀ CA QUAN TRỌNG NHẤT BÀI NÀY. Definer thì bài thử chạy bằng quyền chủ '
   + 'bảng, mọi con số hoá ra 100%, và bảng tự kiểm toàn ✅ — một bảng xanh chứng '
   + 'minh một hàng rào không tồn tại');

  la('có đổi vai thật bằng set_config(role, authenticated)',
     /set_config\(\s*'role'\s*,\s*'authenticated'\s*,\s*true\s*\)/.test(than));

  la('trả về cột chay_bang để phơi vai thật đang đếm',
     /chay_bang\s+text/.test(than) && /current_user\s+into\s+vai/.test(than),
     'không có cột ấy thì lượt đổi vai hỏng cũng không ai biết, và mọi con số vẫn '
   + 'trông như một kết quả');

  la('trả vai lại NGAY trong vòng lặp, không đợi tới cuối',
     /reset role/.test(than),
     '`for r in select …` lấy dòng một cách lười — còn đội vai authenticated lúc nó '
   + 'với sang bảng nguoi là một lối hỏng rất khó thấy');

  la('KHÔNG mở hàm chẩn đoán này ra API công khai',
     /revoke execute on function thu_hang_rao_cap\(\) from public/.test(than),
     'nó không phải cửa của app; để nguyên quyền mặc định của PUBLIC là mọc thêm '
   + 'một lối gọi trong API');

  la('nó cũng ĐO hai chỗ còn hở, không chỉ đo chỗ đã siết',
     /'nhip'/.test(than) && /'task'/.test(than) && /'ket_qua_ngay'/.test(than),
     'một con số nhìn thấy được thì không ai quên nó, còn một dòng ghi chú thì có');
}


/* ── ⑨ SỔ SQL PHẢI DÒ ĐƯỢC BỐN NHÁT NÀY ────────────────────────────────── */
console.log('\n⑨ SO-SQL.sql');
{
  const so = doc('SO-SQL.sql');

  la('khối ① có dò hai tệp DỰNG thứ mới',
     /'nang-cap-cap-dang-nhap\.sql','func','cap_dang_nhap'/.test(so) &&
     /'nang-cap-rls-cam-ket\.sql','func','thu_hang_rao_cap'/.test(so));

  /* Hai tệp còn lại chỉ VIẾT LẠI policy đã có, nên sự tồn tại của `doc_muctieu`
     không nói tệp nào đã chạy — phải hỏi theo NỘI DUNG, đúng lối của `sua_lich`. */
  la('khối ② hỏi theo NỘI DUNG cho hai tệp không dựng gì mới',
     /nhát ② — dự án có hàng rào chưa/.test(so) &&
     /nhát ③ — kho việc cố định có hàng rào chưa/.test(so));

  la('và sổ cũng dò cả RANH GIỚI, không chỉ dò hàng rào',
     /ranh giới: bảng đo KHÔNG được cắt theo cấp/.test(so),
     'một dòng dò nói "đã siết chưa" thì không bắt được lỗi ĐI QUÁ TAY');

  /* Luật của làn SOD: dò theo tên HÀM, không theo tên TỆP. */
  for (const ham of ['cap_dang_nhap', 'thu_hang_rao_cap'])
    la(`tên hàm "${ham}" có thật trong một tệp .sql`,
       fs.readdirSync(__dirname).filter(f => f.endsWith('.sql'))
         .some(f => new RegExp(`create or replace function ${ham}\\b`).test(doc(f))),
       'trong kho này tên tệp và tên hàm không phải lúc nào cũng trùng — án lệ làn SOD');
}

/* ── ⑩ TỆP ④: BỊT CỬA TRA CỨU (TRI-148) ────────────────────────────────── */
console.log('\n⑩ Bịt cửa tra cứu ai-gánh-dự-án-nào');
{
  const bit = MA['nang-cap-bit-cua-tra-cuu-du-an.sql'];

  /* Cả sức mạnh của lượt vá này nằm ở MỘT chỗ: cửa ngoài không nhận tham số
     người. Thêm tham số ấy lại là dựng lại đúng cái máy tra cứu vừa bịt — và
     dựng lại một cách trông rất hợp lý, vì "cho linh hoạt". */
  la('cửa ngoài toi_o_du_an nhận ĐÚNG MỘT tham số',
     /create or replace function toi_o_du_an\s*\(\s*p_muc_tieu_id bigint\s*\)/.test(bit),
     'thêm một tham số người vào đây là dựng lại đúng cái cửa tra cứu vừa bịt. '
   + 'Nó an toàn theo CẤU TẠO, không nhờ một câu kiểm nào — đừng đổi cấu tạo ấy');

  la('và nó luôn hỏi về chính người đang đăng nhập',
     (bit.match(/nguoi_id_dang_nhap\(\)/g) || []).length >= 2 &&
     /la_thanh_vien\(\)/.test(bit));

  la('nó trả FALSE khi truyền null — ngược nết hàm cũ',
     /p_muc_tieu_id is not null/.test(bit),
     'hàm cũ trả TRUE khi null; nếu cửa mới cũng thế thì vế chặn null trong '
   + 'doc_tieudiem lại thành lớp duy nhất, và cả hai cùng hở là hở thật');

  /* 🪤 SOI TỪNG KHỐI POLICY MỘT, đừng dò một mẫu vắt từ `create policy` tới tên
     hàm cũ. Mẫu vắt ngang ấy đỏ oan ngay lần chạy đầu: nó nối từ policy đầu tiên
     tới câu `revoke execute on function la_thanh_vien_du_an` nằm mãi phía dưới —
     mà câu revoke chính là thứ ta MUỐN có. Lần thứ ba trong hai ngày cùng một
     lối hỏng: bẫy regex bắc cầu của làn PRL, hai lượt đỏ oan lúc viết bài này. */
  /* Mốc kết thúc là dấu `;` chứ KHÔNG phải một dòng `);`. Ba trong bốn policy
     viết gọn trên một dòng (`using ( … );`) nên không có dòng `);` nào — mẫu cũ
     chỉ bắt được MỘT khối, và ba khối kia lọt lưới trong im lặng. Thân một
     policy không chứa dấu `;` nào nên phép cắt lười này an toàn. */
  const khoiPolicy = bit.match(/create policy [\s\S]*?;/g) || [];
  la('bốn policy đã đổi sang cửa mới, và không khối nào còn gọi hàm cũ',
     khoiPolicy.length === 4 &&
     khoiPolicy.every(k => /toi_o_du_an\(/.test(k) && !/la_thanh_vien_du_an/.test(k)),
     'còn policy nào gọi hàm cũ là nó ném "permission denied" ngay lượt select đầu, '
   + 'vì mục ③ vừa rút quyền của vai authenticated');

  la('rút quyền của CẢ public, anon và authenticated',
     ['public','anon','authenticated'].every(v =>
        new RegExp(`revoke execute on function la_thanh_vien_du_an\\(bigint, uuid\\) from ${v}`).test(bit)),
     'rút của PUBLIC là thứ làm PostgREST thôi bày hàm ra; rút thêm hai vai kia để '
   + 'một lượt cấp thẳng sau này không lặng lẽ mở lại cửa');

  la('KHÔNG drop hàm cũ',
     !/drop function[\s\S]{0,80}la_thanh_vien_du_an/.test(bit),
     'bốn hàm definer gọi nó bằng TÊN trong thân plpgsql, mà thân plpgsql chỉ là một '
   + 'chuỗi — Postgres không ghi nhận phụ thuộc, nên drop chạy trót lọt rồi bốn hàm '
   + 'kia gãy lúc CHẠY');

  /* Chạy lại một tệp cũ SAU tệp này là dựng lại policy gọi hàm đã mất quyền.
     Hỏng to và hỏng ngay — nhưng người chạy đáng được cảnh báo TRƯỚC. */
  for (const tep of ['nang-cap-rls-cam-ket.sql', 'nang-cap-rls-du-an.sql'])
    la(`${tep} có nhãn ⛔ đã bị thay thế`,
       /⛔ HAI PHẦN CỦA TỆP NÀY ĐÃ BỊ THAY THẾ/.test(doc(tep)),
       'chạy lại nó một mình là mọi lượt select của thành viên ném permission denied');

  /* Bẫy này `SO-SQL.sql` đã kê tên từ 28/08 mà tệp ④ vẫn vấp lại lúc viết:
     `pg_get_function_identity_arguments()` in ra CẢ TÊN THAM SỐ, nên so nó với
     một chuỗi chỉ có kiểu là ❌ oan trong khi hàm hoàn toàn đúng. Ca này chặn
     lần thứ ba. */
  la('bộ tự kiểm hỏi chữ ký bằng DANH MỤC, không bằng chuỗi máy chủ in ra',
     !/pg_get_function_identity_arguments/.test(bit) &&
     /proargtypes\[0\]\s*=\s*'bigint'::regtype/.test(bit),
     'Postgres không trả lại nguyên văn chữ bạn gõ — nó phân tích rồi in lại. '
   + 'Mọi phép so CHUỖI trên thứ nó in ra đều là một quả bom hẹn giờ');

  const so = doc('SO-SQL.sql');
  la('sổ SQL dò được cửa đã bịt hay chưa',
     /cửa tra cứu ai-gánh-dự-án-nào đã bịt chưa/.test(so) &&
     /has_function_privilege/.test(so),
     'hỏi bằng DANH MỤC QUYỀN, không bằng chuỗi — quyền đến từ PUBLIC thì mẫu chuỗi '
   + 'nào cũng không thấy');
}

console.log(truot ? `\n❌ ${truot} ca TRƯỢT · ${dat} đạt\n` : `\n✅ Đủ cả ${dat} phép kiểm\n`);
process.exit(truot ? 1 : 0);
