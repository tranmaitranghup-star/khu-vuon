/* THỬ: VIỆC ĐẺ TỪ SỰ KIỆN KHÔNG ĐƯỢC MỌC SANG LUỐNG NGƯỜI KHÁC
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 07/09: bấm 💧 trên một sự kiện mình KHÔNG host thì hiện hai câu báo lỗi
   chồng nhau — *"Hạt O79 là luống của người khác"* và *"Máy chủ chưa có cột
   việc của sự kiện"* — và không vào được deep work.

   HAI CÒ ĐÚNG KHI ĐỨNG RIÊNG, GHÉP LẠI THÌ ĐÁ NHAU. `cham_theo_su_kien_cha`
   kéo cam kết của sự kiện xuống việc vừa đẻ; cam kết ấy là luống của HOST.
   `kiem_task_dung_luong` chặn mọi việc bám vào hạt người khác. Cả hai đều là cò
   BEFORE trên `task`, Postgres chạy chúng theo thứ tự TÊN — `tg_…` trước
   `trg_…` — nên cò một nhét hạt của host vào, cò hai chặn đúng cái nó vừa nhét.
   Khách mời không có đường lách.

   Bốn ca dưới đây là bốn chỗ mà bấm thử từng bước KHÔNG lộ ra:

     · CÂU LẤP DỮ LIỆU CŨ NGUY HƠN CÒ. Cò chỉ hỏng lúc đẻ việc mới; một câu
       `update task set tieu_diem_ma = …` không soi chủ thì gán nhầm hàng loạt
       dòng đã có, và từ đó cò hai KHOÁ CỨNG mọi cú ghi lên chúng — chủ của
       chúng không tick xong được, không deep work được, mà màn hình không nói
       vì sao. Nên ca ③ quét MỌI tệp SQL, không chỉ tệp vừa sửa.

     · CÂU BÁO LỖI NÓI DỐI CÒN TỆ HƠN KHÔNG BÁO. Câu "máy chủ chưa có cột" từng
       đứng thẳng ở hai chỗ gọi `lcDeViec`, nên nó đè lên lý do thật và chỉ tay
       sang một tệp SQL không liên quan. Người đọc đi chạy tệp ấy, không được gì.

     · CÒ CHẶN LUỐNG CHÉO KHÔNG ĐƯỢC GỠ. Cách "sửa" nhanh nhất cho lỗi này là gỡ
       `trg_kiem_task_dung_luong` — và đó là mở lại đúng đường đè chéo mà
       `va-luong-cheo-nhau.sql` đã đóng 08/08.

   Chạy:  node production/tinh-thuc-app/thu-luong-cua-buoi.js
*/
const fs = require('fs');
const path = require('path');
const GOC = process.env.THU_GOC || __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(GOC, 'public/index.html'), 'utf8');
const doc = t => fs.readFileSync(path.join(GOC, t), 'utf8');

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* Bỏ dòng chú thích rồi cắt theo dấu chấm phẩy — một phần tử là một câu lệnh.
   Phải bỏ chú thích TRƯỚC khi cắt: quá nửa số câu `update task` trong thư mục
   này nằm trong khối chú thích của mục "hai cách dọn, chọn một", và đếm cả
   chúng là bắt các tệp ấy đỏ vì thứ chưa từng chạy. */
const cauLenh = sql => sql
  .split('\n').filter(d => !/^\s*--/.test(d)).join('\n')
  .split(';');

/* ── ① CÒ THỪA HƯỞNG SOI CHỦ HẠT ────────────────────────────────────────── */
console.log('\n① Cò thừa hưởng chỉ kéo cam kết xuống khi hạt là luống của chính chủ việc');
{
  const va = doc('va-viec-cua-buoi-luong-nguoi-khac.sql');
  const ham = va.slice(va.indexOf('function cham_theo_su_kien_cha()'));
  la('hàm đọc chủ của HẠT, không chỉ đọc dòng sự kiện',
     /select\s+nguoi_id\s+into\s+chu_hat\s+from\s+tieu_diem/.test(ham),
     'chủ sự kiện và chủ hạt là hai người khác nhau — phải hỏi bảng `tieu_diem`');
  la('chỉ gán cam kết khi `chu_hat = new.nguoi_id`',
     /if\s+chu_hat\s*=\s*new\.nguoi_id\s+then\s+new\.tieu_diem_ma\s*:=/.test(ham),
     'thiếu vế này thì khách mời nhận hạt của host rồi bị cò kia chặn ngay');
  la('vẫn giữ luật cũ: người dùng đã chọn tay thì không đè',
     /if\s+new\.tieu_diem_ma\s+is\s+null\s+and/.test(ham),
     'đây là mặc định, không phải lệnh');
  la('việc riêng tư vẫn không mang cam kết',
     /if\s+new\.rieng_tu\s+then\s+new\.tieu_diem_ma\s*:=\s*null/.test(ham),
     'vế này có từ bản gốc — sửa hàm mà đánh rơi nó là mở lại một lỗ khác');
}

/* ── ② VẾT CŨ ĐƯỢC DỌN, VÀ TỆP CŨ KHÔNG DỰNG LẠI NÓ ─────────────────────── */
console.log('\n② Vết cũ được dọn, và chạy lại tệp cũ không dựng lại nó');
{
  const va = doc('va-viec-cua-buoi-luong-nguoi-khac.sql');
  const donDep = cauLenh(va).find(c => /update\s+task/.test(c));
  la('có câu gỡ việc của sự kiện ra khỏi luống người khác',
     !!donDep && /set\s+tieu_diem_ma\s*=\s*null/.test(donDep),
     'không dọn thì các dòng cũ vẫn đóng băng dù cò đã sửa');
  la('câu dọn CHỈ đụng việc đẻ từ sự kiện',
     !!donDep && /lich_id\s+is\s+not\s+null/.test(donDep),
     'việc thường nằm sai luống là chuyện Tracy tự quyết — xem va-luong-cheo-nhau mục 5');

  const cu = cauLenh(doc('nang-cap-loai-su-kien.sql'))
    .find(c => /update\s+task/.test(c) && /set\s+tieu_diem_ma/.test(c));
  la('câu lấp của `nang-cap-loai-su-kien.sql` nay soi chủ hạt',
     !!cu && /o\.nguoi_id\s*=\s*t\.nguoi_id/.test(cu),
     'chạy lại tệp ấy là dựng lại đúng vết vừa dọn — và đụng dòng lệch chủ thì cò ném lỗi, cuộn ngược cả tệp');
}

/* ── ③ QUÉT CẢ THƯ MỤC: KHÔNG CÂU SQL NÀO GÁN HẠT MÀ KHÔNG SOI CHỦ ──────── */
console.log('\n③ Mọi câu ghi `task.tieu_diem_ma` trong thư mục đều soi chủ');
{
  /* CHỈ ĐỌC MỆNH ĐỀ `set`, cắt trước `from`/`where`. Quét cả câu thì đỏ OAN:
     `lan_toa_du_an_xuong_task` ghi `muc_tieu_id` và chỉ NHẮC `tieu_diem_ma`
     trong mệnh đề lọc — đó là câu đúng, và một ca đỏ oan thì tệ hơn không kiểm,
     nó dạy người đọc thôi tin cả bảng. */
  const menhDeSet = c => {
    const i = c.search(/\bset\b/i);
    if (i < 0) return '';
    const con = c.slice(i);
    const j = con.search(/\b(from|where)\b/i);
    return j < 0 ? con : con.slice(0, j);
  };
  const hong = [];
  for (const t of fs.readdirSync(GOC).filter(f => f.endsWith('.sql'))){
    for (const c of cauLenh(doc(t))){
      if (!/update\s+task\b/i.test(c)) continue;
      const set = menhDeSet(c.slice(c.search(/update\s+task\b/i)));
      if (!/\btieu_diem_ma\s*=/i.test(set)) continue;
      if (/tieu_diem_ma\s*=\s*null/i.test(set)) continue;   // gỡ ra thì luôn an toàn
      if (!/nguoi_id/.test(c)) hong.push(t);
    }
  }
  la('không tệp nào gán cam kết cho việc mà bỏ qua chủ hạt',
     hong.length === 0,
     'tệp đang hở: ' + [...new Set(hong)].join(', '));
}

/* ── ④ CÂU BÁO LỖI KHÔNG NÓI DỐI ────────────────────────────────────────── */
console.log('\n④ Không đẻ được việc cho buổi thì nói đúng lý do, hoặc im');
{
  la('câu "máy chủ chưa có cột việc của sự kiện" chỉ còn ĐÚNG MỘT chỗ phát ra',
     SRC.split('Máy chủ chưa có cột việc của sự kiện').length - 1 === 1,
     'nó nằm rải ở nhiều chỗ gọi thì mỗi chỗ lại nói dối một kiểu');

  const helper = SRC.slice(SRC.indexOf('function lcBaoKhongDeDuoc()'));
  la('chỗ phát ra ấy là `lcBaoKhongDeDuoc`, và nó hỏi `CO_VIEC_BUOI` trước',
     /function lcBaoKhongDeDuoc\(\)\s*\{\s*if\s*\(!CO_VIEC_BUOI\)/.test(helper),
     'thiếu vế hỏi thì nó lại đè lên lý do thật của `lcDeViec`');

  const goi = [...SRC.matchAll(/if \(!t\) return void ([a-zA-Z]+)\(/g)].map(m => m[1]);
  /* ĐẾM MỞ, không chốt cứng con số: mỗi cửa mới đi qua `lcDeViec` lại thêm một
     chỗ gọi (07/09 thêm `lcDoiLoai` là chỗ thứ ba). Chốt "đúng hai" là bài thử
     đỏ mỗi lần app mọc thêm một cửa hợp lệ — mà một ca đỏ vì lý do đó dạy người
     đọc sửa con số cho xanh, chứ không dạy họ soi. Thứ đáng canh là KHÔNG chỗ
     nào tự dựng câu báo lỗi riêng. */
  la('mọi chỗ gọi `lcDeViec` đều đi qua helper ấy',
     goi.length >= 2 && goi.every(x => x === 'lcBaoKhongDeDuoc'),
     'đang gọi: ' + goi.join(', '));
}

/* ── ⑤ CÒ CHẶN LUỐNG CHÉO KHÔNG ĐƯỢC GỠ ─────────────────────────────────── */
console.log('\n⑤ Cò chặn luống chéo vẫn còn sống');
{
  const cheo = doc('va-luong-cheo-nhau.sql');
  la('`trg_kiem_task_dung_luong` vẫn được dựng',
     /create trigger trg_kiem_task_dung_luong/.test(cheo),
     'gỡ nó là mở lại đường đè chéo đã đóng 08/08 — sửa cò thừa hưởng, đừng gỡ cò chặn');
  la('hàm chặn vẫn cho việc KHÔNG cam kết đi qua',
     /if\s+new\.tieu_diem_ma\s+is\s+null\s+then\s+return\s+new/.test(cheo),
     'việc của khách mời nay là việc phát sinh — nó phải lọt qua cửa này');
}

console.log(`\n${truot ? '❌' : '✅'}  ${dat} đạt · ${truot} trượt\n`);
process.exit(truot ? 1 : 0);
