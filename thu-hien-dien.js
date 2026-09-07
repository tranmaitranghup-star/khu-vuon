/* THỬ: HÀNG HIỆN DIỆN — ai đang deepwork ở đầu trang (TRI-88)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 03/09: *"tôi cần cả team cùng nhìn được ai đang deepwork… nếu mà ai đang
   deepwork thì tên người đó có viền xanh dương đậm lên"*.

   Bảy ca đáng giá — đều là chỗ thử tay KHÔNG lộ ra, vì màn hình trông vẫn đúng:

     · THỨ TỰ CHIP ĐỨNG YÊN. Xếp người đang làm lên đầu thì hàng nhảy chỗ mỗi
       lần có ai vào phiên. Mắt mất chỗ quen — thứ khó gọi tên nhất mà cũng khó
       chịu nhất. Ca này chốt luật ấy lại bằng máy.

     · ĐỒNG HỒ NGƯỜI TẠM DỪNG PHẢI ĐỨNG. Máy chủ đã chốt số ở `tam_dung_luc`;
       cộng thêm quãng đã trôi là đếm cả giờ nghỉ thành giờ làm.

     · PHÚT ĐO BẰNG HIỆU HAI MỐC. Một máy sai giờ không được làm sai con số —
       đây là lý do không tính thẳng từ `bat_dau`.

     · LỚP RIÊNG TƯ. `doc_task` giấu việc trong kho khỏi đồng đội còn
       `doc_deepwork` mở trần. Một cái tên việc lọt vào chip là lộ đúng thứ hàng
       rào kia đang giấu — ca này canh cả mã lẫn câu truy vấn.

     · MÁY CHỦ CHƯA CHẠY SQL THÌ HÀNG BIẾN MẤT HẲN, không để lại một dải trống
       ở đầu trang.

     · HẸN GIỜ PHẢI TỰ TẮT khi không còn ai đang làm. Một hẹn giờ chạy suốt ngày
       để vẽ lại thứ không đổi là thứ không ai thấy mà máy vẫn trả tiền.

     · TÊN NGƯỜI PHẢI QUA `chuSach`. Tên lấy từ máy chủ, ghép thẳng vào HTML là
       một lỗ chèn mã.

   Chạy:  node production/lan-app/HD/thu-hien-dien.js
*/
const fs = require('fs');
const path = require('path');
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(__dirname, 'public/index.html'), 'utf8');
const SQL = fs.readFileSync(path.join(__dirname, 'nang-cap-hien-dien-deepwork.sql'), 'utf8');

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
  return SRC.slice(i, j + cuoi.length);
}

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ── MÁY CHẠY THẬT ────────────────────────────────────────────────────────
   Nạp mã THẬT của bốn hàm. Chỉ ba thứ dựng giả: cái hộp DOM để đọc lại kết
   quả, `DOI`/`ME` vốn đến từ máy chủ, và hai hàm hẹn giờ để đếm được chúng có
   bị bỏ quên hay không. */
function may(DOI, ME){
  return new Function('DOI', 'ME', `
    let HD_DS = [], HD_LUC = 0, HD_HEN = null, HD_DONG = null;
    let HD_SAN = false, HD_TAT = false;
    let SO_HEN = 0, SO_XOA = 0;
    const setInterval  = () => { SO_HEN++; return {id: SO_HEN}; };
    const clearInterval = () => { SO_XOA++; };
    const hop = {innerHTML: '', hidden: false};
    const document = {getElementById: id => id === 'hn-hiendien' ? hop : null};
    ${catKhoi("const CAP = {QUAN_TRI", "const laMember = ()  => capCua(ME) === CAP.MEMBER;")}
    ${catKhoi('const DOI_DO = () =>', ';')}
    ${catHam('chuSach')}
    ${catHam('hdVe')}
    return {
      hdVe, hop,
      dat: o => {
        if ('DS'  in o) HD_DS  = o.DS;
        if ('LUC' in o) HD_LUC = o.LUC;
        if ('SAN' in o) HD_SAN = o.SAN;
        if ('TAT' in o) HD_TAT = o.TAT;
      },
      soi: () => ({dong: HD_DONG, hen: SO_HEN, xoa: SO_XOA}),
    };`)(DOI, ME);
}

const DOI7 = [
  {id:'u1', ten:'Andy'},   {id:'u2', ten:'Tracy'}, {id:'u3', ten:'Peter'},
  {id:'u4', ten:'Hafi'},   {id:'u5', ten:'Sydney'},{id:'u6', ten:'Justin'},
  {id:'u7', ten:'John'},
];
/* ⚠️ ME PHẢI MANG CẤP, không chỉ mang id (07/09). Từ bản ba cấp, `hdVe` giấu cả
   hàng với Member — mà một `ME` không cờ nào đọc ra ĐÚNG LÀ Member, nên bỏ cờ
   ở đây là mọi ca dưới cùng thấy một cái hộp rỗng và trượt vì một lý do không
   liên quan gì tới thứ chúng định đo. Tracy là quản trị, đúng người đang nhìn
   hàng này. Ca riêng cho Member nằm ở `thu-ba-cap.js`. */
const ME = {id:'u2', ten:'Tracy', la_lead:true, la_quan_tri:true};
const NAY = Date.now();
const ten = h => [...h.matchAll(/>([^<]*?)(?:<span|<\/span)/g)];

console.log('\n═══ HÀNG HIỆN DIỆN (TRI-88) ═══\n');

/* ① Ai đang làm thì đeo `lam`, ai không thì không đeo gì cả */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY, DS:[{nguoi_id:'u1', phut:47, dang_nghi:false}]});
  m.hdVe();
  const h = m.hop.innerHTML;
  la('người đang làm đeo lớp `lam`', /class="hd-ai lam"[^>]*>Andy/.test(h), h.slice(0,120));
  la('người không có phiên chỉ có lớp gốc',
     /class="hd-ai"[^>]*>Peter/.test(h), h.slice(0,200));
  la('hàng hiện ra, không bị ẩn', m.hop.hidden === false);
  la('đủ cả bảy người, không chỉ người đang làm',
     (h.match(/class="hd-ai/g) || []).length === 7);
}

/* ② Thứ tự chip KHÔNG xáo theo ai đang làm */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY, DS:[{nguoi_id:'u7', phut:5, dang_nghi:false},
                                {nguoi_id:'u6', phut:9, dang_nghi:false}]});
  m.hdVe();
  const thu = [...m.hop.innerHTML.matchAll(/>([A-Za-z]+)</g)].map(x => x[1]);
  la('thứ tự giữ nguyên theo DOI dù hai người cuối đang làm',
     JSON.stringify(thu) === JSON.stringify(DOI7.map(n => n.ten)),
     JSON.stringify(thu));
}

/* ③ Người tạm dừng: lớp `nghi`, KHÔNG lớp `lam`, và đồng hồ đứng */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY - 5*60000, DS:[{nguoi_id:'u1', phut:30, dang_nghi:true}]});
  m.hdVe();
  const h = m.hop.innerHTML;
  la('người tạm dừng đeo `nghi`', /class="hd-ai nghi"[^>]*>Andy/.test(h));
  la('người tạm dừng KHÔNG đeo `lam`', !/hd-ai nghi lam|hd-ai lam nghi/.test(h));
}

/* ④ CHỈ CÁI TÊN — Tracy 03/09: *"ko cần thời gian đâu chỉ cần viền xanh lên thôi"*.
       Ca này canh cả chip lẫn dòng chú thích khi rê chuột: một con số nấp trong
       `title` vẫn là con số, chỉ khác là trên điện thoại không ai chạm tới nó. */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY - 7*60000, DS:[{nguoi_id:'u1', phut:95, dang_nghi:false}]});
  m.hdVe();
  const h = m.hop.innerHTML;
  la('chip không in ra con số nào', !/\d/.test(h.replace(/hd-ai|toi/g,'')), h.slice(0,160));
  la('không còn lớp `hd-phut`', !h.includes('hd-phut'));
  la('dòng rê chuột cũng không mang số phút',
     /title="Andy — đang deepwork"/.test(h), h.match(/title="[^"]*"/)?.[0]);
  la('câu hỏi thôi xin cột `phut` cho nhẹ đường truyền',
     SRC.includes("select('nguoi_id,dang_nghi')"));
}

/* ⑤ Chính mình đeo `toi` — để mắt nhặt ra tên mình mà không phải đọc */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY, DS:[]});
  m.hdVe();
  la('chính mình đeo lớp `toi`', /class="hd-ai toi"[^>]*>Tracy/.test(m.hop.innerHTML));
  la('người khác không đeo `toi`',
     (m.hop.innerHTML.match(/toi/g) || []).length === 1);
}

/* ⑥ LỚP RIÊNG TƯ — không một chữ nào về việc đang làm */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY, DS:[{nguoi_id:'u1', phut:47, dang_nghi:false,
                                 task_id: 999, ghi_chu: 'Việc bí mật'}]});
  m.hdVe();
  const h = m.hop.innerHTML;
  la('chip không in ra nội dung việc dù dữ liệu có mang theo',
     !h.includes('Việc bí mật') && !h.includes('999'), h.slice(0,200));

  const cau = SRC.match(/from\('ai_dang_lam'\)\s*\.select\('([^']+)'\)/);
  /* Canh CÁI LUẬT, không canh con số cột: danh sách cột đã đổi một lần (bỏ
     `phut` khi Tracy nói chỉ cần viền) và một ca ghim cứng chuỗi ấy đỏ theo
     ngay, dù mã đúng. Luật thật là: không xin cột nào chỉ về VIỆC. */
  la('câu hỏi không xin cột nào chỉ về việc đang làm',
     !!cau && !/task|ghi_chu|nhip_id|cam_ket/.test(cau[1]), cau && cau[1]);
  la('khung nhìn trong SQL không trả cột task_id',
     !/^\s*p\.task_id/m.test(SQL));
}

/* ⑦ Máy chủ chưa chạy SQL → hàng biến mất hẳn, không để dải trống */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, TAT:true, LUC:NAY, DS:[]});
  m.hdVe();
  la('khung nhìn chưa có thì hàng bị ẩn hẳn', m.hop.hidden === true);

  const m2 = may(DOI7, ME);
  m2.dat({SAN:false});
  m2.hdVe();
  la('chưa hỏi được lần nào thì cũng ẩn, không vẽ hàng rỗng', m2.hop.hidden === true);
}

/* ⑧ KHÔNG CÒN HẸN GIỜ NÀO. Cái hẹn giờ 30 giây sinh ra chỉ để đẩy con số phút
       nhích lên; bỏ số thì nó thành một vòng lặp vẽ lại thứ không đổi, chạy suốt
       ngày mà không ai thấy. Ca này canh cho nó đừng lặng lẽ quay lại. */
{
  const m = may(DOI7, ME);
  m.dat({SAN:true, LUC:NAY, DS:[{nguoi_id:'u1', phut:3, dang_nghi:false}]});
  m.hdVe(); m.hdVe(); m.hdVe();
  la('vẽ ba lượt mà không đẻ hẹn giờ nào', m.soi().hen === 0);
  la('mã không còn setInterval trong cụm hd', !/hdNhip|HD_DONG/.test(SRC));
}

/* ⑨ Tên người phải qua chuSach */
{
  const m = may([{id:'u1', ten:'<img src=x onerror=alert(1)>'}],
                {id:'u1', la_lead:true, la_quan_tri:true});
  m.dat({SAN:true, LUC:NAY, DS:[]});
  m.hdVe();
  la('tên có thẻ HTML bị vô hiệu hoá',
     !m.hop.innerHTML.includes('<img'), m.hop.innerHTML.slice(0,140));
}

/* ⑩ Đường realtime: nghe riêng, cố ý KHÔNG đi chung RT_BANG */
{
  const rt = SRC.match(/const RT_BANG = \[([^\]]+)\]/);
  la('`phien_deepwork` cố ý VẮNG trong RT_BANG (nhịp tim 60 giây không được kéo theo một lượt tải lại nặng)',
     !!rt && !rt[1].includes('phien_deepwork'), rt && rt[1]);
  la('có người nghe riêng cho bảng ấy, trỏ vào hdCoTin',
     /table: 'phien_deepwork'\}, hdCoTin\)/.test(SRC));
  la('hdTai chạy song song trong mảng khởi động, không nối thêm một lượt chờ',
     SRC.includes('[taiHomNay(), lamMoiCuaToi(), hdTai()]'));
}

/* ⑪ Tệp SQL: hàng rào quyền và ngưỡng sống */
{
  la('khung nhìn chạy bằng quyền người hỏi (security_invoker)',
     /with \(security_invoker = true\)/.test(SQL));
  la('có ngưỡng im lặng 5 phút, khớp DW_IM_LANG_PHUT trong mã',
     /interval '5 minutes'/.test(SQL) && /DW_IM_LANG_PHUT = 5/.test(SRC));
  la('bảng được kê vào publication supabase_realtime',
     /add table public\.phien_deepwork/.test(SQL));
}

console.log(`\n═══ ${dat} đạt · ${truot} trượt ═══\n`);
process.exit(truot ? 1 : 0);
