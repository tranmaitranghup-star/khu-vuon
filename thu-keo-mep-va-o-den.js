/* THỬ: sửa giờ ngay trên lưới — ô "đến" trong cửa Thông tin việc, và kéo mép khối
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 29/08: *"task họp này ban đầu tôi hoạch định 2.5h nhưng bây giờ 3h rồi
   chưa xong … làm cách nào để ấn vào timeline mà chỉnh sửa được giờ thực tế"* →
   chốt GHI ĐÈ (một cặp giờ cho mỗi việc) + kéo mép khối.

   Bài thử CẮT ĐÚNG CÁC KHỐI GỐC ra khỏi public/index.html rồi chạy trên dữ liệu
   giả — không chép tay một dòng logic nào sang đây.

   Ca đáng giá nhất là ca cuối: kéo xong thì ĐỌC LẠI bằng chính tlgKhoangTask —
   thứ vẽ khối lên lưới — để chắc khối không tự co về độ dài cũ.

   Chạy:  node production/tinh-thuc-app/thu-keo-mep-va-o-den.js

   Soi bản CŨ (để chắc bài thử thật sự bắt được lỗi):
     git show HEAD:public/index.html > /tmp/cu.html
     THU_FILE=/tmp/cu.html node production/tinh-thuc-app/thu-keo-mep-va-o-den.js
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
const NGUON = [
  catKhoi('function phutDeadline(s){',   '/* ── ĐÃ QUÁ GIỜ HẸN CHƯA'),
  catKhoi('function gioTuO(v){',         '/* ══════ NHẶT "TRONG BAO LÂU"'),
  catKhoi('function gioCong(chu, phut){','/* Phải bằng ĐÚNG con số ở Supabase'),
  catKhoi('function manhGio(gio, phut, den){', 'async function ghiTaskMoi('),
  catKhoi('function tlCua(idNd){',       '/* Lúc LƯU mới gỡ chữ'),
  catKhoi('function tvKhoangGio(){',     '/* Dòng phụ: việc này SẼ nằm ở đâu'),
  catKhoi('const tlgHHMM = p =>',        '/* Chạm một ô giờ.'),
  catKhoi('function tlgKhoangTask(t){',  '/* Hai khối cùng khung giờ'),
  catKhoi('let TLG_KEO = null;',         '/* Cuộn tới GIỜ HIỆN TẠI'),
].join('\n');

/* ── Coc: du de cac khoi tren chay, khong hon ─────────────────────────────── */
const COC = [
  'const CO_GIO_SE = true;',
  'let TL_NHAT = {};',
  'let O = {};',                       // id -> gia tri o nhap
  'let TASK = {};',                    // viec dang mo trong cua
  'const tvTim = () => TASK;',
  'let TV_ID = 1;',
  /* `querySelector` trả null: các khối cắt ở đây chỉ TÍNH giờ, phần chạm DOM
     của chúng là nhánh vẽ lại màn — không có màn nào để vẽ trong bài thử. */
  'const document = {getElementById: id => (id in O ? {value: O[id]} : null),'
  + ' querySelector: () => null, querySelectorAll: () => []};',
].join('\n');

const chay = new Function(COC + '\n' + NGUON + `
  return {manhGio, tvKhoangGio, tlgKhoangTask, tlgKeoChay, tlgHHMM,
          datO: (o, t) => { O = o; TASK = t || {}; },
          datKeo: k => { TLG_KEO = k; return k; }};`)();

/* ── Khung cham diem ───────────────────────────────────────────────────────── */
let dat = 0, truot = 0;
const bang = (ten, thay, mong) => {
  const a = JSON.stringify(thay), b = JSON.stringify(mong);
  if (a === b){ dat++; console.log('  ✔ ' + ten); }
  else { truot++; console.log('  ✘ ' + ten + '\n      mong : ' + b + '\n      thay : ' + a); }
};

/* ══ 1. manhGio — gio ket thuc nguoi tu dat thi no la chu ══════════════════ */
console.log('\n① manhGio — tham so thu ba');
bang('khong co "den" → van cong thoi luong nhu cu',
     chay.manhGio('09:30', 150), {deadline:'09:30', gio_start:'09:30', gio_end:'12h'});
bang('co "den" → dung thang, khong tinh lai',
     chay.manhGio('09:30', 180, '12:30'), {deadline:'09:30', gio_start:'09:30', gio_end:'12:30'});
bang('khong gio, khong thoi luong → ba o trong',
     chay.manhGio('', 0), {deadline:'', gio_start:'', gio_end:''});

/* ══ 2. tvKhoangGio — cap gio trong cua Thong tin viec ════════════════════ */
console.log('\n② tvKhoangGio — o "den" lam chu thoi luong');
chay.datO({'tv-gio':'09:30', 'tv-den':'12:30', 'tv-nd':''}, {thoi_luong_du_kien:150});
bang('9h30 → 12h30 : thoi luong = hieu hai dau (180), KHONG phai 150 cu',
     chay.tvKhoangGio(), {gio:'9h30', den:'12h30', phut:180, loi:''});

chay.datO({'tv-gio':'09:30', 'tv-den':'09:00', 'tv-nd':''}, {});
bang('ket thuc TRUOC luc bat dau → bao loi, khong ghi',
     chay.tvKhoangGio().loi, 'Giờ kết thúc phải sau giờ bắt đầu.');

chay.datO({'tv-gio':'09:30', 'tv-den':'09:30', 'tv-nd':''}, {});
bang('hai dau bang nhau → cung la loi (khoi day 0 phut)',
     chay.tvKhoangGio().loi, 'Giờ kết thúc phải sau giờ bắt đầu.');

chay.datO({'tv-gio':'', 'tv-den':'12:30', 'tv-nd':''}, {});
bang('co "den" ma khong co gio bat dau → bao loi',
     chay.tvKhoangGio().loi, 'Chọn giờ bắt đầu trước, rồi mới tới giờ kết thúc.');

chay.datO({'tv-gio':'09:30', 'tv-den':'', 'tv-nd':''}, {thoi_luong_du_kien:150});
bang('o "den" TRONG → giu khuon cu, doc thoi luong cua viec',
     chay.tvKhoangGio(), {gio:'9h30', den:'', loi:'', phut:150});

/* ══ 3. tlgKeoChay — nac 15 phut, san 15 phut, khong vuot bien ════════════ */
console.log('\n③ tlgKeoChay — keo mep khoi');
const gia = () => ({style:{}, querySelector: () => ({textContent:''}),
                    classList:{add(){}, remove(){}}});
const keo = (mep, dy, tu=570, den=720) => {          // 9h30 → 12h, luoi 38px/gio
  const k = chay.datKeo({el:gia(), id:1, mep, cao:38, gd:7, tu, den, moi:null,
                         chay:true, batX:0, batY:0, cots:[], ngay:'', ngayMoi:''});
  chay.tlgKeoChay({clientX: 0, clientY: dy});
  return k.moi;
};
bang('keo mep duoi xuong dung 1 gio (38px) → +60 phut', keo('duoi', 38),  {tu:570, den:780});
bang('keo xuong 10px → nac gan nhat la 15 phut',        keo('duoi', 10),  {tu:570, den:735});
bang('keo xuong 4px → chua toi nua nac, khoi dung yen', keo('duoi', 4),   {tu:570, den:720});
bang('keo mep duoi len qua da → san 15 phut',           keo('duoi', -999),{tu:570, den:585});
bang('keo mep tren xuong qua da → van chua 15 phut',    keo('tren', 999), {tu:705, den:720});
bang('keo mep tren len qua nua dem → chan o 0h',        keo('tren', -999, 30, 720), {tu:0, den:720});

/* ══ 4. Vong tron: keo → ghi → ve lai. Khoi co tu co ve cu khong? ═════════ */
console.log('\n④ Vong tron — keo xong doc lai bang chinh cai ve khoi len luoi');
const m = keo('duoi', 19);                                   // 9h30 → 12h30
const phut = m.den - m.tu;
const ghi = {thoi_luong_du_kien: phut,
             ...chay.manhGio(chay.tlgHHMM(m.tu), phut, chay.tlgHHMM(m.den))};
bang('cau ghi mang du CA BA: gio dau, gio cuoi, thoi luong moi',
     ghi, {thoi_luong_du_kien:180, deadline:'09:30', gio_start:'09:30', gio_end:'12:30'});
bang('doc lai tu chinh cau vua ghi → dung khoang vua keo (9h30–12h30)',
     chay.tlgKhoangTask(ghi), {tu:570, den:750});

/* Ca nay la ly do co dong ...(k.den ? {thoi_luong_du_kien: k.phut} : ...) trong
   tvLuu va dong thoi_luong_du_kien trong tlgLuuKhoang: bo quen no thi lan luu
   sau tinh lai gio_end tu thoi luong CU va khoi tu co ve. */
const quenThoiLuong = {thoi_luong_du_kien: 150,
                       ...chay.manhGio('09:30', 150, '12:30')};
bang('BAY: ghi gio cuoi ma quen thoi luong → lan sau tinh lai, khoi co ve 2h30',
     chay.tlgKhoangTask({...quenThoiLuong, gio_end: ''}), {tu:570, den:720});

/* ══ 5. ĐÃ GỠ — ô GÕ SỐ không còn tồn tại ═════════════════════════════════
   Ca này canh `gioNan`, hàm nắn chuỗi người gõ ("930" → "09:30"). Đường gõ số
   sống đúng một buổi sáng: dựng 29/08, và chiều cùng ngày Tracy chốt *"bỏ hẳn
   gõ đi"*. Ô giờ nay là bánh xe gốc của máy trên màn cảm ứng, cột mốc 15 phút
   trên máy tính — không còn chuỗi tự do nào để mà nắn.
   Gỡ ca chứ không nới nó: một bài thử gác cơ chế đã chết là chỗ trú cho hồi
   quy thật, vì nó cứ xanh mãi mà chẳng canh gì. */

console.log('\n' + (truot ? '✘ ' + truot + ' ca truot' : '✔ ca nao cung dat')
            + ' · ' + dat + '/' + (dat+truot) + '\n');
process.exit(truot ? 1 : 0);
