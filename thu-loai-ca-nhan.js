/* THỬ: LOẠI CÁ NHÂN cho việc và sự kiện  (TRI-100 · làn CNH · 04/09/2026)
   ─────────────────────────────────────────────────────────────────────────────
   Tracy 04/09: *"Loại việc và sự kiện tôi muốn phát triển thêm loại Cá nhân
   (với loại việc và sự kiện này thì không được tính vào dashboard của ROVA và
   giữ riêng tư cho mọi người)"* — duyệt phương án A: khoá thật ở tầng quyền của
   máy chủ, không che ở màn hình.

   Bài thử soi PHẦN APP, cộng một lượt đọc tệp SQL để bắt cảnh hai bên trôi lệch.
   Bộ tự kiểm 9 mục của phần máy chủ nằm ngay trong nang-cap-loai-ca-nhan.sql.

   Bốn ca đáng giá nhất — cả bốn đều là cách hỏng IM LẶNG, không lỗi nào báo:

     ① Cờ riêng tư phải trả lời TRƯỚC trong loaiCua / khoaNhom / giaTriO. Hỏi
        ngược thứ tự thì việc cá nhân rơi hết về "phát sinh", nhãn 🔒 không bao
        giờ hiện, và người ta tưởng mình chưa đánh dấu.

     ② LUẬT KHÔNG GIỮ NGẦM đi CẢ HAI CHIỀU. Chọn "Việc cá nhân" phải xoá cam kết
        và nhãn cố định; chọn một cam kết phải HẠ cờ riêng tư xuống false, chứ
        không bỏ trường. Bỏ trường là cột cũ nằm lại: việc hiện dưới tên một cam
        kết của đội trong khi máy chủ vẫn giấu nó khỏi cả đội — một con số của
        đội thiếu đi mà không ai tra ra vì sao.

     ③ Hai dòng cuối LC_NHOM cùng pham_vi = 'ca_nhan'. Vòng tìm trong
        lcNhomCuaLich luôn dừng ở dòng ĐẦU, nên thiếu vế cờ riêng tư thì mở SỬA
        một sự kiện cá nhân ra sẽ thấy ô chọn nhảy về "Mời người cụ thể", và bấm
        Lưu là gỡ mất cờ riêng tư.

     ④ Máy chủ chưa chạy tệp SQL thì dòng "Cá nhân" KHÔNG được bày ra — nhưng
        VẪN phải bày nếu thứ đang chọn chính là nó (cảnh lùi bản máy chủ). Giấu
        lúc ấy là ô chọn rơi về một giá trị khác mà người ta không thấy, rồi bấm
        Lưu là công khai một việc riêng.

   Chạy:  node production/tinh-thuc-app/thu-loai-ca-nhan.js
*/
const fs   = require('fs');
const path = require('path');
const THU_MUC = __dirname;
const SRC = fs.readFileSync(process.env.THU_FILE
  || path.join(THU_MUC, 'public/index.html'), 'utf8');
const SQL  = fs.readFileSync(path.join(THU_MUC, 'nang-cap-loai-ca-nhan.sql'), 'utf8');
const SQL2 = fs.readFileSync(path.join(THU_MUC, 'nang-cap-loai-su-kien.sql'), 'utf8');
const SQL3 = fs.readFileSync(path.join(THU_MUC, 'nang-cap-moi-vao-su-kien-ca-nhan.sql'), 'utf8');
const SQL4 = fs.readFileSync(path.join(THU_MUC, 'nang-cap-quyen-khach.sql'), 'utf8');

function catKhoi(dau, cuoi){
  const i = SRC.indexOf(dau), j = SRC.indexOf(cuoi, i);
  if (i < 0 || j < 0) throw new Error('Khong thay khoi: ' + dau);
  return SRC.slice(i, j);
}

/* ══ CỐC ① — khuôn LOẠI VIỆC ══════════════════════════════════════════════ */
const NGUON_VIEC = catKhoi("const O_CO_DINH  = '_cd';", 'function napTieuDiem(');

const COC_VIEC = `
let CO_LOAI_VIEC = true, CO_RIENG_TU = true, LUONG = [];
const chuSach = s => String(s ?? '');
const luongDangGieo = () => LUONG;
`;

const viec = new Function(COC_VIEC + NGUON_VIEC + `
  return { manhLoai, loaiCua, loaiCuaMa, khoaNhom, giaTriO, tenLoai, nhanLoai,
           optCamKet, O_CO_DINH, O_CA_NHAN, TEN_LOAI,
           dat: o => { CO_LOAI_VIEC = o.CO_LOAI_VIEC !== false;
                       CO_RIENG_TU  = o.CO_RIENG_TU  !== false;
                       LUONG = o.LUONG || []; } };
`)();

/* ══ CỐC ② — khuôn NHÓM NHẬN SỰ KIỆN ══════════════════════════════════════ */
const NGUON_LICH = catKhoi('const LC_NHOM = [', '/* Luật lặp có nổ vào ngày này không');

const COC_LICH = `
let CO_RIENG_TU = true, CO_LOAI_SK = true, LUONG = [];
let CHUC_NANG = [{id:'k1', ten:'Kinh doanh'}], DOI = [], ME = {id:'toi'};
const chuSach = s => String(s ?? '');
const O_CA_NHAN = '_cn';
const TEN_LOAI  = {cn: 'Việc cá nhân'};
const luongDangGieo = () => LUONG;
const timO      = ma => LUONG.find(o => o.ma === ma) || null;
const soCamKet  = ma => (LUONG.findIndex(o => o.ma === ma) + 1);
let LC_LOAI_O = '';
const document = {getElementById: id => id === 'lc-loai' ? {value: LC_LOAI_O} : null};
`;

const lich = new Function(COC_LICH + NGUON_LICH + `
  return { LC_NHOM, lcOptNhom, lcOptLoai, lcLoaiCua, lcLoaiDangKhai, lcNhanLoai,
           lcNhomCuaLich, lcNhanPhamVi, lcChoToi, O_CA_NHAN,
           dat: o => { CO_RIENG_TU = o.CO_RIENG_TU !== false;
                       CO_LOAI_SK  = o.CO_LOAI_SK  !== false;
                       LUONG = o.LUONG || [];
                       LC_LOAI_O = o.O || '';
                       DOI = o.DOI || [];
                       ME  = o.ME  !== undefined ? o.ME : {id:'toi'}; } };
`)();

let dat = 0, truot = 0;
function la(ten, dieu, them){
  if (dieu){ dat++; console.log('  ✅ ' + ten); }
  else { truot++; console.log('  ❌ ' + ten + (them ? '\n       → ' + them : '')); }
}

/* ══════════════════════════════════════════════════════════════════════════ */

console.log('\n① Ô CHỌN LOẠI VIỆC dịch sang ba cột — luật KHÔNG GIỮ NGẦM hai chiều');
{
  viec.dat({});
  const cn = viec.manhLoai(viec.O_CA_NHAN);
  la('chọn Việc cá nhân: bật cờ riêng tư',  cn.rieng_tu === true, JSON.stringify(cn));
  la('chọn Việc cá nhân: bỏ cam kết',       cn.tieu_diem_ma === null, JSON.stringify(cn));
  la('chọn Việc cá nhân: bỏ nhãn cố định',  cn.loai_viec === null, JSON.stringify(cn));

  const ck = viec.manhLoai('ck-01');
  la('chọn một cam kết: HẠ cờ riêng tư xuống false', ck.rieng_tu === false, JSON.stringify(ck));
  la('rieng_tu = false KHÁC bỏ trống',      'rieng_tu' in ck, JSON.stringify(ck));

  const cd = viec.manhLoai(viec.O_CO_DINH);
  la('chọn Việc cố định: cũng hạ cờ riêng tư', cd.rieng_tu === false, JSON.stringify(cd));

  const ps = viec.manhLoai('');
  la('chọn Việc phát sinh: cả ba cùng rỗng',
     ps.tieu_diem_ma === null && ps.loai_viec === null && ps.rieng_tu === false,
     JSON.stringify(ps));
}

console.log('\n② CỬA LÙI — máy chủ chưa chạy tệp SQL thì không gửi cột');
{
  viec.dat({CO_RIENG_TU: false});
  const cn = viec.manhLoai(viec.O_CA_NHAN);
  la('không gửi trường rieng_tu chút nào', !('rieng_tu' in cn), JSON.stringify(cn));
  la('vẫn gửi hai trường cũ như hôm qua',
     cn.tieu_diem_ma === null && cn.loai_viec === null, JSON.stringify(cn));
  viec.dat({});
}

console.log('\n③ CỜ RIÊNG TƯ TRẢ LỜI TRƯỚC ở cả ba hàm tra');
{
  viec.dat({});
  la('loaiCua: cờ riêng tư thắng nhãn cố định',
     viec.loaiCua({rieng_tu: true, loai_viec: 'co_dinh'}) === 'cn');
  la('loaiCua: không cờ thì y như cũ',
     viec.loaiCua({loai_viec: 'co_dinh'}) === 'cd' && viec.loaiCua({}) === 'ps');
  la('khoaNhom: việc riêng tư có ô gom riêng',
     viec.khoaNhom({rieng_tu: true, tieu_diem_ma: 'ck-01'}) === viec.O_CA_NHAN);
  la('giaTriO: ô chọn đứng đúng dòng Việc cá nhân',
     viec.giaTriO({rieng_tu: true}) === viec.O_CA_NHAN);
  la('giaTriO: việc thường vẫn đứng đúng cam kết',
     viec.giaTriO({tieu_diem_ma: 'ck-01'}) === 'ck-01');
  la('loaiCuaMa dịch đủ ba nhánh',
     viec.loaiCuaMa(viec.O_CO_DINH) === 'cd' &&
     viec.loaiCuaMa(viec.O_CA_NHAN) === 'cn' &&
     viec.loaiCuaMa('') === 'ps');
  la('có tên và ký hiệu cho loại mới',
     viec.TEN_LOAI.cn === 'Việc cá nhân' && viec.nhanLoai('cn', true, true).includes('🔒'),
     viec.nhanLoai('cn', true, true));
}

console.log('\n④ Ô CHỌN bày dòng Cá nhân — và cửa lùi khi máy chủ lùi bản');
{
  viec.dat({LUONG: [{ma:'ck-01', ten:'Cam kết một', luong:1}]});
  const co = viec.optCamKet('');
  la('có cờ: dòng Việc cá nhân có mặt', co.includes('value="_cn"'), co);
  la('chữ trơn, KHÔNG kèm biểu tượng trong bảng chọn gốc',
     co.includes('>Việc cá nhân<') && !/value="_cn"[^>]*>[^<]*🔒/.test(co));

  la('có cờ: dòng ấy bấm được', !/value="_cn"[^>]*disabled/.test(co));

  viec.dat({CO_RIENG_TU: false, LUONG: []});
  const khong = viec.optCamKet('');
  la('chưa có cờ: dòng ấy VẪN có mặt, không biến mất',
     khong.includes('value="_cn"'), khong);
  la('nhưng bấm không được', /value="_cn"[^>]*disabled/.test(khong));
  la('và nó nói ra tên tệp cần chạy', khong.includes('nang-cap-loai-ca-nhan.sql'));
  const dangChon = viec.optCamKet('_cn');
  la('đang chọn chính nó thì vẫn bấm được',
     !/value="_cn"[^>]*disabled/.test(dangChon) &&
     /value="_cn" selected/.test(dangChon), dangChon);
  viec.dat({});
}

console.log('\n⑤ SỰ KIỆN — ô nhóm nhận trở lại BẢY dòng, thôi gánh câu "loại gì"');
{
  lich.dat({});
  la('không dòng nào trong LC_NHOM mang cờ rieng nữa',
     !lich.LC_NHOM.some(n => n.rieng), JSON.stringify(lich.LC_NHOM.map(n => n.ma)));
  la('vẫn đủ bảy nhóm nhận', lich.LC_NHOM.length === 7);
  la('ô nhóm nhận bày đúng bảy dòng',
     (lich.lcOptNhom('cong_ty').match(/<option /g) || []).length === 7);

  /* Bẫy cũ đã hết đường tái diễn: chỉ còn MỘT dòng pham_vi ca_nhan. */
  const sk = {rieng_tu: true, pham_vi: 'ca_nhan', chuc_nang_ids: [], nguoi_ids: ['toi']};
  la('sự kiện cá nhân vẫn về đúng dòng Mời người cụ thể ở ô nhóm nhận',
     lich.lcNhomCuaLich(sk)?.ma === 'ca_nhan');
  la('sự kiện cá nhân của tôi vẫn hiện trên lịch của tôi',
     lich.lcChoToi({...sk, tao_boi: 'toi'}) === true);
}

console.log('\n⑤b SỰ KIỆN CÁ NHÂN MỜI ĐƯỢC NGƯỜI (Tracy đổi nghĩa 04/09)');
{
  /* "Cá nhân" THÔI nghĩa là *chỉ mình tôi*; nó nghĩa là NGOÀI CÔNG VIỆC —
     không góp số vào bảng nào của team, và chỉ người trong cuộc nhìn thấy.
     Danh sách người trong cuộc nay dài hơn một. */
  lich.dat({DOI: [{id:'toi', ten:'Tôi'}, {id:'andy', ten:'Andy'}]});
  const sk = {rieng_tu: true, pham_vi: 'ca_nhan', chuc_nang_ids: [],
              nguoi_ids: ['toi','andy'], tao_boi: 'toi'};

  la('khách mời đọc được buổi — vế đầu của lcChoToi',
     lich.lcChoToi({...sk, tao_boi: 'nguoi-khac'}) === true);
  la('người ngoài thì không',
     lich.lcChoToi({...sk, nguoi_ids:['andy'], tao_boi:'andy'}) === false);

  la('nhãn phạm vi nay KÊ TÊN người dự, không nói "chỉ mình tôi"',
     lich.lcNhanPhamVi(sk).includes('Andy')
     && !lich.lcNhanPhamVi(sk).includes('chỉ mình tôi'), lich.lcNhanPhamVi(sk));

  /* Cùng một cờ trong kho, hai cái tên trên màn: dòng VIỆC đọc là "Việc cá
     nhân", buổi lịch đọc là "Cá nhân". Mượn chung một hằng là một chỗ sai. */
  la('nhãn loại của BUỔI nói "Cá nhân", không phải "Việc cá nhân"',
     lich.lcNhanLoai({rieng_tu:true}).includes('Cá nhân')
     && !lich.lcNhanLoai({rieng_tu:true}).includes('Việc cá nhân'),
     lich.lcNhanLoai({rieng_tu:true}));
  lich.dat({});
}

console.log('\n⑥ Ô LOẠI SỰ KIỆN — ba hạng, và giá trị đọc ra từ chính dòng');
{
  const LUONG = [{ma:'ck-01', ten:'Cam kết một', luong:1},
                 {ma:'ck-02', ten:'Cam kết hai', luong:2}];
  lich.dat({LUONG});
  const o = lich.lcOptLoai('');
  la('bày đủ: thường + cá nhân + hai cam kết',
     (o.match(/<option /g) || []).length === 4, o);
  la('mặc định đứng ở dòng Sự kiện thường', /<option value="" selected/.test(o));
  la('dùng lại đúng mã _cn của bên việc — không đặt hằng thứ hai',
     o.includes('value="_cn"'));
  la('không dòng nào bị tắt khi máy chủ đủ cột', !/disabled/.test(o));

  la('lcLoaiCua: sự kiện mới là rỗng', lich.lcLoaiCua(null) === '');
  la('lcLoaiCua: cờ riêng tư thắng cam kết',
     lich.lcLoaiCua({rieng_tu: true, tieu_diem_ma: 'ck-01'}) === lich.O_CA_NHAN);
  la('lcLoaiCua: buổi gắn cam kết trả về đúng mã',
     lich.lcLoaiCua({tieu_diem_ma: 'ck-02'}) === 'ck-02');
  la('lcLoaiCua: buổi thường trả về rỗng', lich.lcLoaiCua({}) === '');
  la('ô mở SỬA đứng đúng dòng cam kết',
     /value="ck-02" selected/.test(lich.lcOptLoai('ck-02')));
}

console.log('\n⑥b Ô LOẠI — hai cờ máy chủ gác hai dòng KHÁC NHAU');
{
  const LUONG = [{ma:'ck-01', ten:'Cam kết một', luong:1}];
  /* Hai cột vào bằng HAI tệp, nên phải tắt được rời nhau. Dùng chung một cờ là
     máy chủ chạy tệp trước mà chưa chạy tệp sau sẽ bày ra một ô lưu là lỗi. */
  lich.dat({LUONG, CO_RIENG_TU: false});
  const a = lich.lcOptLoai('');
  la('thiếu cột rieng_tu: dòng Cá nhân mờ, kèm tên tệp',
     /value="_cn"[^>]*disabled/.test(a) && a.includes('nang-cap-loai-ca-nhan.sql'), a);
  la('… nhưng dòng cam kết vẫn bấm được', !/value="ck-01"[^>]*disabled/.test(a));

  lich.dat({LUONG, CO_LOAI_SK: false});
  const b = lich.lcOptLoai('');
  la('thiếu cột tieu_diem_ma: dòng cam kết mờ, kèm tên tệp',
     /value="ck-01"[^>]*disabled/.test(b) && b.includes('nang-cap-loai-su-kien.sql'), b);
  la('… nhưng dòng Cá nhân vẫn bấm được', !/value="_cn"[^>]*disabled/.test(b));
  la('đang đứng ở một cam kết thì dòng ấy vẫn chọn được — cửa lùi khi lùi bản',
     !/value="ck-01"[^>]*disabled/.test(lich.lcOptLoai('ck-01')));
  lich.dat({});
}

console.log('\n⑥c NHÃN LOẠI trên cửa buổi — chỉ nói khi có gì để nói');
{
  const LUONG = [{ma:'ck-01', ten:'Cam kết một', luong:1}];
  lich.dat({LUONG});
  la('buổi thường: không in gì cả', lich.lcNhanLoai({}) === '');
  la('buổi riêng: dấu khoá và tên loại',
     lich.lcNhanLoai({rieng_tu: true}).includes('🔒'));
  la('buổi gắn cam kết: ô số cộng tên cam kết',
     lich.lcNhanLoai({tieu_diem_ma: 'ck-01'}).includes('Cam kết một'));
  la('cam kết của người khác chưa nạp thì im lặng bỏ qua, không ngã',
     lich.lcNhanLoai({tieu_diem_ma: 'ck-cua-nguoi-khac'}) === '');
}

console.log('\n⑦ TỆP SQL — hai hàng rào phải cùng có mặt');
{
  la('cột rieng_tu thêm cho cả ba bảng',
     ['task','lich_chung','phien_deepwork'].every(b =>
       new RegExp('alter table ' + b + '\\s+add column if not exists rieng_tu').test(SQL)));

  la('doc_task soi cờ riêng tư',
     /create policy doc_task[\s\S]{0,400}?rieng_tu/.test(SQL));
  la('doc_lich thôi là la_thanh_vien() trần',
     /create policy doc_lich on lich_chung[\s\S]{0,200}?rieng_tu/.test(SQL));
  la('doc_deepwork soi cờ riêng tư',
     /create policy doc_deepwork[\s\S]{0,200}?rieng_tu/.test(SQL));

  /* Hàng rào ②. Chỉ ba khung nhìn này, và ĐÚNG ba: thêm một cái nữa là số của
     chính chủ trên màn RIÊNG của họ cũng bị trừ đi — trái điều Tracy chốt. */
  for (const v of ['gio_deepwork_theo_loai','cham_theo_ngay','gat_theo_ngay'])
    la('khung nhìn ' + v + ' đã lọc dòng riêng tư',
       new RegExp('create or replace view ' + v + ' as[\\s\\S]{0,1200}?not \\w+\\.rieng_tu').test(SQL));

  for (const v of ['vuon_cay','gio_deepwork_theo_ngay','dem_task_theo_o','tien_do_o'])
    la('khung nhìn ' + v + ' KHÔNG bị đụng tới — nó là màn của riêng mình',
       !new RegExp('create or replace view ' + v + ' as').test(SQL));

  la('ba khung nhìn ấy được đặt lại cờ quyền NGƯỜI GỌI',
     (SQL.match(/set \(security_invoker = on\)/g) || []).length === 3);
  la('sự kiện riêng tư bị buộc phải là ca_nhan',
     /check \(not rieng_tu or pham_vi = 'ca_nhan'\)/.test(SQL));
  /* BỐN cò, thành hai cặp. Mỗi cặp có một vế xuôi (lúc dòng con ra đời) và một
     vế ngược (lúc cờ của dòng cha đổi). Thiếu vế ngược thì cờ chỉ đúng ở khoảnh
     khắc tạo, rồi trôi lệch trong im lặng. */
  la('bốn cò giữ ba cờ khớp nhau — đủ cả vế xuôi lẫn vế ngược',
     ['tg_cham_rieng_tu_phien','tg_cham_rieng_tu_theo_viec',
      'tg_cham_rieng_tu_viec_cua_buoi','tg_cham_rieng_tu_theo_su_kien']
       .every(t => SQL.includes('create trigger ' + t)));
  la('có câu lấp cho dữ liệu đã có, và VIỆC được kéo trước PHIÊN',
     SQL.indexOf('update task t\n   set rieng_tu = l.rieng_tu') <
     SQL.indexOf('update phien_deepwork p\n   set rieng_tu = t.rieng_tu'));
  la('bộ tự kiểm canh cả hai chiều lệch cờ',
     SQL.includes('không dòng phiên nào lệch cờ') &&
     SQL.includes('không việc nào lệch cờ'));
  la('có bộ tự kiểm ở cuối tệp', /TỰ KIỂM/.test(SQL) && /as t\(so, muc, dat\)/.test(SQL));
}

console.log('\n⑧ TỆP SQL THỨ HAI — cột cam kết của sự kiện (TRI-102)');
{
  la('cột tieu_diem_ma thêm cho lich_chung',
     /alter table lich_chung add column if not exists tieu_diem_ma/.test(SQL2));
  la('xoá cam kết thì để lại buổi, không xoá theo',
     /on delete set null/.test(SQL2) && !/references tieu_diem[\s\S]{0,60}cascade/.test(SQL2));
  la('sự kiện cá nhân không mang cam kết được',
     /check \(not rieng_tu or tieu_diem_ma is null\)/.test(SQL2));

  /* Cò thừa hưởng ĐỔI TÊN chứ không sửa ruột tại chỗ: tên cũ nói nó chỉ lo cờ
     riêng tư, mà từ nay nó lo hai cột. Tên nói thiếu việc mình làm là chỗ phiên
     sau đọc lướt rồi hiểu sai — nên tệp phải GỠ hẳn cò cũ, không để hai cò cùng
     chạy trên một bảng. */
  la('cò cũ bị gỡ hẳn, không để hai cò cùng chạy',
     SQL2.includes('drop trigger if exists tg_cham_rieng_tu_viec_cua_buoi on task')
     && SQL2.includes('drop function if exists cham_rieng_tu_viec_cua_buoi()'));
  la('cò mới mang cả hai cột', SQL2.includes('create trigger tg_cham_theo_su_kien_cha'));

  /* Phân biệt CÓ CHỦ Ý, và bài thử canh nó vì nó dễ bị "dọn cho nhất quán":
     rieng_tu là một LỜI HỨA nên đồng bộ mãi; tieu_diem_ma là một MẶC ĐỊNH nên
     chỉ thừa hưởng lúc ra đời. */
  la('cam kết chỉ điền khi việc CHƯA có cam kết nào',
     /if new\.tieu_diem_ma is null then new\.tieu_diem_ma := cha\.tieu_diem_ma/.test(SQL2));
  la('cờ riêng tư thì NÂNG theo cha, không hạ ở cò này',
     /if cha\.rieng_tu then new\.rieng_tu := true/.test(SQL2));
  la('việc riêng tư thì bỏ luôn cam kết',
     /if new\.rieng_tu then new\.tieu_diem_ma := null/.test(SQL2));

  la('câu lấp KHÔNG đụng việc người ta đã tự xếp',
     /update task t[\s\S]{0,300}?t\.tieu_diem_ma is null/.test(SQL2));
  la('bộ tự kiểm đứng CUỐI tệp, sau bảng số liệu — luật rút ra 04/09',
     SQL2.indexOf('SỐ LIỆU THAM KHẢO') < SQL2.indexOf('as t(so, muc, dat)'));
  la('và dòng chưa đạt nổi lên đầu', /order by dat, so;/.test(SQL2));
}

console.log('\n⑧b TỆP SQL THỨ BA — nới quyền đọc cho khách mời (TRI-103)');
{
  la('doc_lich nay soi cả nguoi_ids', /create policy doc_lich[\s\S]{0,400}?nguoi_ids/.test(SQL3));
  la('và vẫn giữ hai vế cũ', /create policy doc_lich[\s\S]{0,400}?rieng_tu[\s\S]{0,200}?tao_boi/.test(SQL3));
  /* `any(<mảng>)` chứ không `any(<truy vấn con>)` — hai thứ trùng tên mà khác
     hẳn nhau, và cái bẫy ấy đã cắn hôm 03/09 lúc chuc_nang_ids đổi sang mảng. */
  la('so với MẢNG, không so với một truy vấn con',
     /= any\(nguoi_ids\)/.test(SQL3));

  la('KHÔNG nới lây sang quyền đọc việc và phiên',
     !/create policy doc_task/.test(SQL3) && !/create policy doc_deepwork/.test(SQL3));
  la('KHÔNG nới lây sang ràng buộc "riêng thì phải là ca_nhan"',
     !/drop constraint[\s\S]{0,80}lich_rieng_tu_la_ca_nhan/.test(SQL3));
  la('bộ tự kiểm đứng CUỐI tệp, sau bảng số liệu',
     SQL3.indexOf('SỐ LIỆU THAM KHẢO') < SQL3.indexOf('as t(so, muc, dat)'));
}

console.log('\n⑨ MẪU SO CHUỖI trong bộ tự kiểm không được chứa TỪ KHOÁ SQL');
{
  /* Bài học 04/09, và nó sẽ tái diễn với mọi tệp SQL sau này. Postgres không
     cất lại nguyên văn câu mình gõ — nó phân tích rồi IN LẠI, và lúc in thì từ
     khoá viết HOA, ngoặc được thêm vào, khoảng cách đổi. Chỉ TÊN CỘT và chuỗi
     trong nháy là trả lại y nguyên. Nên một mẫu `like` chứa từ khoá thì ra ❌
     oan — mà ❌ oan còn tệ hơn không kiểm: nó dạy người đọc thôi tin cái bảng.
     Ca này quét CẢ HAI tệp, và mọi tệp thêm vào danh sách sau này. */
  const TU_KHOA = ['is null','is not null',' and ',' or ',' not ','check (','select ','exists'];
  /* Quét MÃ CHẠY, không quét chú thích: chính chú thích của tệp thứ hai chép
     lại nguyên cái mẫu hỏng để dạy người sau, và một máy soát bắt lỗi ở dòng
     giải thích về lỗi ấy thì nó đang soi sai chỗ. */
  const boChuThich = t => t.replace(/\/\*[\s\S]*?\*\//g, '')
                           .split('\n').filter(l => !l.trim().startsWith('--')).join('\n');
  for (const [ten, src] of [['nang-cap-loai-ca-nhan.sql', boChuThich(SQL)],
                            ['nang-cap-loai-su-kien.sql', boChuThich(SQL2)],
                            ['nang-cap-moi-vao-su-kien-ca-nhan.sql', boChuThich(SQL3)],
                            ['nang-cap-quyen-khach.sql', boChuThich(SQL4)]]){
    const mau = [...src.matchAll(/i?like\s+'%([^']*)%'/g)].map(m => m[1]);
    const xau = mau.filter(m => TU_KHOA.some(k => m.toLowerCase().includes(k)));
    la(`${ten}: ${mau.length} mẫu so, không mẫu nào chứa từ khoá`,
       xau.length === 0, xau.join(' · '));
  }
}

console.log('\n⑩ MÀU RIÊNG, và cái nút tắt lịch cá nhân (TRI-104)');
{
  /* Đọc thẳng mã nguồn, không dựng cốc: ba thứ này rải ở bốn chỗ khác nhau
     (phễu sự kiện · phễu việc · năm chỗ vẽ · thanh công cụ), mà cái hỏng đáng
     sợ nhất của chúng là BỎ SÓT MỘT CHỖ — thứ một cốc chạy đúng một hàm không
     bắt được. */
  const mauSuKien = l => (l && l.rieng_tu) ? 'tim'  : ((l && l.mau) || '');
  const mauViec   = t => (t && t.rieng_tu) ? 'hong' : ((t && t.mau) || '');

  la('sự kiện cá nhân ra màu tím', mauSuKien({rieng_tu:true}) === 'tim');
  la('việc cá nhân ra màu hồng',   mauViec({rieng_tu:true})   === 'hong');
  la('cờ riêng tư THẮNG màu sơn tay — màu là tín hiệu, không phải sở thích',
     mauSuKien({rieng_tu:true, mau:'luc'}) === 'tim'
     && mauViec({rieng_tu:true, mau:'luc'}) === 'hong');
  la('món thường vẫn giữ đúng màu đã sơn',
     mauSuKien({mau:'luc'}) === 'luc' && mauViec({mau:'vang'}) === 'vang');
  la('món thường chưa sơn thì rỗng, không bịa một màu',
     mauSuKien({}) === '' && mauViec({}) === '');

  /* KHÔNG chỗ vẽ nào được đọc thẳng `t.mau` nữa — sót một chỗ là một nấc lịch
     bày sai màu, và nó sai lặng lẽ vì bốn nấc kia đúng. */
  la('không chỗ vẽ nào còn đọc thẳng t.mau',
     !/lopMau = t\.mau \?/.test(SRC), 'còn ' + (SRC.match(/lopMau = t\.mau \?/g)||[]).length + ' chỗ');
  la('phễu sự kiện suy màu ở cả ba lối đẻ khối',
     (SRC.match(/mau: mauSuKien\(l\)/g) || []).length === 3);
  la('và mang theo cờ để lượt vẽ lọc được',
     (SRC.match(/rieng: !!l\.rieng_tu/g) || []).length === 3);

  la('có nút bật tắt trên thanh công cụ lịch', SRC.includes('onclick="tlBatRieng()"'));
  /* Tracy 04/09: *"làm đồng bộ với nút sự kiện đi và đừng gạch"*. Nút MANG LUÔN
     lớp của nút Sự kiện nên hình dạng không có bản thứ hai để trôi lệch. */
  la('nút ấy mượn nguyên hình nút Sự kiện, không dựng hình thứ hai',
     /class="lich-nut-lc lich-nut-rieng m-tim/.test(SRC));
  la('màu lấy qua lớp m-tim, không gõ thẳng mã màu vào luật nút',
     /\.lich-nut-rieng\.bat\{background:var\(--n1\)/.test(SRC));
  /* ⛔ Luật 10 Mục 7 CAU-TRUC-APP.md — việc xong LÙI MÀU, không gạch. Tôi đã đọc
     luật ấy rồi vẫn vi phạm ở bản đầu, nên từ nay để máy canh: cả app không
     được có một nét gạch chữ nào. */
  la('⛔ không một nét gạch chữ nào trong toàn bộ CSS',
     !/text-decoration:\s*line-through/.test(SRC));

  /* Tracy 04/09: *"cửa sổ sự kiện cho dãn khoảng cách các khối ra... sát nhau
     quá"*, rồi 05/09 hai lần nữa về cùng khối ấy: *"khoi nay van sat nhau qua,
     cho khoang cach lon hon di"* và *"sao van sat the"*. Con số đi 9 → 14 →
     20 → 26px trong ba ngày.

     ⚠️ ĐỌC RA CON SỐ, ĐỪNG GHIM NÓ. Ca cũ ghim thẳng `gap:14px` vào cả hai
     dòng, nên lần Tracy nới thứ ba nó đỏ — mà thứ đỏ ấy không phải cái đáng
     đỏ. Cái đáng canh là hai điều khác: (a) hở của cửa này không được tụt
     xuống dưới 14px của luật 11 Mục 7, và (b) HAI CỬA PHẢI BẰNG NHAU. */
  const gLcThan  = +(SRC.match(/\.lc-than\{display:flex;flex-direction:column;gap:(\d+)px\}/) || [])[1];
  const gVcRieng = +(SRC.match(/\.vc-rieng\{display:flex;flex-direction:column;gap:(\d+)px\}/) || [])[1];
  la('cửa Sự kiện hở giữa các khối ít nhất bằng luật 11 (14px)',
     gLcThan >= 14, 'đang là ' + gLcThan + 'px');
  /* Ca này đã bắt được một lỗi thật (TRI-120, vá 05/09): hai lần nới hôm ấy chỉ
     đụng `.lc-than`, `.vc-rieng` ở lại 14px, nên cùng một biểu mẫu thở hai nhịp
     tuỳ người ta mở bằng nút "+ Sự kiện" hay bằng cách chạm lưới giờ. Giữ nó SO
     HAI CỬA thay vì ghim con số chính là lý do nó bắt được. */
  la('khoang sự kiện trong cửa gộp hở ĐÚNG BẰNG cửa Sự kiện',
     gVcRieng === gLcThan,
     `cửa Sự kiện ${gLcThan}px · cửa gộp ${gVcRieng}px — mã app đang lệch, xem chú thích`);
  /* 🪤 LUẬT MỘT LỚP THUA LUẬT MỘT LỚP ĐỨNG SAU NÓ. `.lc-nhom-xa{margin-top:22px}`
     khai trước `.lc-nhom{margin:7px 0}` nên bị ghi đè sạch: khối Quyền của khách
     Tracy xin tách xa hôm 05/09 không xa hơn một pixel nào, và không có gì báo —
     CSS không lỗi, không cảnh báo, chỉ lặng lẽ không có tác dụng (TRI-121).
     Ca này canh HÌNH DẠNG của luật, không canh con số: hễ nó quay về một lớp là
     đỏ, dù con số vẫn nguyên. */
  la('luật nhóm-xa viết HAI lớp để thắng `.lc-nhom` bất kể thứ tự',
     /\.lc-nhom\.lc-nhom-xa\{margin-top:\d+px\}/.test(SRC)
     && !/(^|\})\.lc-nhom-xa\{/.test(SRC),
     'một lớp thì `.lc-nhom` đứng sau sẽ ghi đè, và lề trên về lại 7px');
  la('nhớ theo MÁY qua localStorage, không theo tài khoản',
     SRC.includes('tt_hien_lich_rieng') && /localStorage\.setItem\(TL_KHOA_RIENG/.test(SRC));
  la('mặc định là BẬT — không giấu sẵn lịch của chính mình mà không nói',
     /localStorage\.getItem\(TL_KHOA_RIENG\) !== '0'/.test(SRC));

  /* Ba lối vẽ đi qua bản có cái nút; hai lối KHÔNG được đi qua nó. */
  /* Bốn chỗ: một dòng khai hàm, cộng ĐÚNG ba lối vẽ (lưới Tuần/Ngày · nấc
     Tháng · ô ngày điện thoại). Đếm cả dòng khai để con số nói được là hàm ấy
     còn sống — xoá hàm mà quên xoá chỗ gọi thì số cũng lệch. */
  la('ba nấc vẽ đi qua lcCuaNgayVe, cộng một dòng khai hàm',
     (SRC.match(/lcCuaNgayVe\(g\)/g) || []).length === 4,
     (SRC.match(/lcCuaNgayVe\(g\)/g) || []).length + ' chỗ');
  la('⛔ lượt ĐẺ VIỆC vẫn đi lcCuaNgay — nút xem không được đổi dữ liệu',
     /const chua = lcCuaNgay\(hn\)/.test(SRC));
  la('⛔ công cụ tìm giờ rảnh vẫn đi lcCuaNgayTu — tắt hiển thị không làm mình rảnh hơn',
     !/lcCuaNgayVe/.test(SRC.slice(SRC.indexOf('function lcRanhTim('),
                                   SRC.indexOf('function lcRanhTim(') + 1500)));
  la('nút ấy che CẢ việc của buổi riêng, không chỉ khối sự kiện',
     /if \(!TL_HIEN_RIENG && t\.rieng_tu\)/.test(SRC));

  la('dải chọn màu KHOÁ lại khi món đang khai là cá nhân',
     SRC.includes('KHOA_MAU_VIEC') && SRC.includes('KHOA_MAU_SK')
     && /function veDaiMau\(oId, dang, ham, coCot, tep, khoa\)/.test(SRC));
}

console.log('\n⑪ CỬA SỰ KIỆN XẾP THEO LỊCH GOOGLE (TRI-105)');
{
  /* Hai hàm giờ chạy thật, không đọc mã: chúng là phép tính, và một phép tính
     sai thì mọi buổi khai từ nay dài sai. */
  const tinh = new Function(catKhoi('function lcGioCong(hhmm, phut){',
                                    '/* Ô `lc-phut` nay ẩn')
    + 'return {lcGioCong, lcPhutTu};')();
  la('cộng giờ thường', tinh.lcGioCong('09:30', 180) === '12:30');
  la('vắt qua nửa đêm thì quấn lại trong ngày', tinh.lcGioCong('23:00', 120) === '01:00');
  la('phút lẻ không làm tròn sai', tinh.lcGioCong('08:05', 25) === '08:30');
  la('đọc giờ ra phút', tinh.lcPhutTu('12:30') === 750 && tinh.lcPhutTu('') === null);

  /* THỨ TỰ MẮT ĐỌC — đúng thứ tự Tracy kê: tên · thời gian · cả-ngày+lặp ·
     dải ngăn · chi tiết. Kiểm bằng vị trí trong chuỗi mẫu, vì cái hỏng đáng sợ
     nhất của một bố cục là một khối trôi lên trước khối lẽ ra đứng trên nó. */
  /* ⚠️ TÌM TRONG ĐÚNG KHUÔN CỬA SỰ KIỆN, không tìm cả tệp. Cửa GỘP dựng lại
     gần hết bộ `id` ấy (`lc-lap` · `lc-chot` · `lc-loai` · `lc-pv`…) và nó nằm
     TRƯỚC trong tệp, nên `indexOf` trên cả tệp vớ phải bản của cửa kia — ba ca
     dưới đây đỏ oan đúng vì thế lúc mới viết. Một mốc tìm quá rộng thì nó không
     đo cái mình định đo, và cái sai ấy nhìn y như một lỗi thật. */
  /* Mốc cuối dò TỪ SAU mốc đầu — bẫy TRI-132, xem DANG-LAM.md. */
  const KHUON = SRC.slice(SRC.indexOf('function lcMoForm('),
                          SRC.indexOf('function lcLuatMoi(', SRC.indexOf('function lcMoForm(')));
  const i = t => KHUON.indexOf(t);
  la('tên đứng đầu, và là chữ to nhất',
     i('lc-ten-to') < i('class="lc-hang lc-tg"') && /\.lc-ten-to\{[^}]*font-size:1\./.test(SRC));
  la('ô màu đứng ngay cạnh tên, không còn ở đáy cửa',
     i('lc-o-mau') < i('id="lc-ten"'));
  la('hàng thời gian trước hàng Cả ngày + lặp',
     i('class="lc-hang lc-tg"') < i('id="lc-ca-ngay"'));
  la('ô Cả ngày và ô lặp CÙNG một hàng',
     i('id="lc-ca-ngay"') < i('id="lc-lap"')
     && !KHUON.slice(i('id="lc-ca-ngay"'), i('id="lc-lap"')).includes('</div>'));
  la('dải ngăn Chi tiết sự kiện đứng sau hai hàng ấy',
     i('id="lc-lap"') < i('lc-muc">Chi tiết sự kiện'));
  la('và mọi thứ còn lại nằm sau dải ngăn',
     i('lc-muc">Chi tiết sự kiện') < i('id="lc-chot"')
     && i('id="lc-chot"') < i('id="lc-loai"')
     && i('id="lc-loai"') < i('id="lc-moi-hang"')
     && i('id="lc-moi-hang"') < i('id="lc-ghi-chu"'));

  /* ⚠️ CA QUAN TRỌNG NHẤT của mục này (Tracy 04/09: *"nguyên tắc là phải xếp
     cùng nhóm nội dung ở gần nhau chứ"*): thứ trả lời cùng một câu thì nằm
     trọn trong MỘT `.lc-nhom`, không có khối lạ chen vào giữa.

     ⚠️ NHÓM ĐÃ ĐƯỢC CHIA LẠI 05/09, nên ba ca dưới đây viết theo bản 04/09
     đều đỏ. Tracy soi cửa lần nữa và chốt ba việc:
       · *"trang thai lich va loai su kien de chung 1 hang"* — ô Loại rời khỏi
         nhóm AI, về đứng cạnh cần gạt Trạng thái lịch thành nhóm "buổi này là
         gì". Mỗi ô đeo nhãn riêng.
       · *"Coreteam va nut moi nguoi cho vao 1 hang, ben tren 2 o do ghi la
         Nguoi tham gia"* — nhóm AI nay là ô Đối tượng + nút Mời trên cùng một
         hàng, danh sách tên và khối Giờ cùng rảnh rơi xuống dưới.
       · *"Quyen cua khach tach nhom xa hon nua"* — khối Quyền RA KHỎI nhóm AI,
         thành một nhóm riêng đeo thêm lớp `lc-nhom-xa` để cách nhóm trên rộng
         hơn hẳn. Nó trả lời câu "họ được làm gì", khác câu "ai có mặt".
     Nên nhóm AI nay gồm BA thứ chứ không bốn, và cả cửa có BỐN nhóm chứ không
     ba. Ca cũ "chia đúng BA nhóm" thì lại XANH suốt, vì mẫu so `class="lc-nhom"`
     có dấu nháy đóng nên không đếm nổi nhóm Quyền (`class="lc-nhom lc-nhom-xa"`)
     — xanh vì đếm sót đúng bằng số nhóm mới thêm. Nay đếm bằng thẻ mở. */
  /* Cắt từ ô ĐẦU tới ô CUỐI của nhóm, không cắt tới khối kế tiếp: giữa ô cuối
     nhóm và khối sau có đúng một thẻ mở `lc-nhom` của nhóm sau, và tính cả nó
     vào là ca này đỏ oan — đã đỏ oan đúng vậy lúc mới viết. */
  const CUM = KHUON.slice(KHUON.indexOf('id="lc-pv"'), KHUON.indexOf('id="lc-ranh-o"'));
  la('nhóm AI liền một mạch: Đối tượng · Mời thêm người · Giờ cùng rảnh',
     i('id="lc-ai-nhan"') < i('id="lc-pv"')
     && CUM.includes('id="lc-moi-hang"')
     && (CUM.match(/class="lc-nhom/g) || []).length === 0,
     'có khối lạ chen vào giữa nhóm');
  la('cả cửa chia đúng BỐN nhóm', (KHUON.match(/class="lc-nhom/g) || []).length === 4,
     'đếm được ' + (KHUON.match(/class="lc-nhom/g) || []).length);
  la('Trạng thái lịch và Loại sự kiện CÙNG một hàng',
     i('id="lc-chot"') < i('id="lc-loai"')
     && !KHUON.slice(i('id="lc-chot"'), i('id="lc-loai"')).includes('<div class="lc-hang'));
  la('Đối tượng và nút Mời thêm người CÙNG một hàng',
     !CUM.includes('<div class="lc-hang'));
  /* Khối Quyền đứng RIÊNG và cách xa — `lc-nhom-xa` là cái tạo ra quãng ấy. */
  la('Quyền của khách ở nhóm riêng, cách nhóm trên rộng hơn hẳn',
     KHUON.slice(i('id="lc-ranh-o"'), i('id="lc-quyen"')).includes('class="lc-nhom lc-nhom-xa"')
     && /\.lc-nhom-xa\{margin-top:\d+px\}/.test(SRC));

  la('ô "Dài … phút" thôi bày ra màn, nhưng vẫn sống dưới dạng ô ẩn',
     /<input type="hidden" id="lc-phut"/.test(SRC)
     && !/id="lc-phut" min="5"/.test(KHUON));

  la('ghi_chu trở lại đường ghi', /ghi_chu: \(document\.getElementById\('lc-ghi-chu'\)/.test(SRC));
  la('ba cột quyền chỉ gửi khi máy chủ đã có', /if \(CO_QUYEN_KHACH\)\{/.test(SRC));
  la('khối quyền im lặng biến mất khi chưa có cột',
     /o\.hidden = !CO_QUYEN_KHACH/.test(SRC));
  la('mặc định chép của Lịch Google — sửa TẮT, hai ô kia BẬT',
     /moi: !l \|\| l\.khach_moi\s+!== false/.test(SRC)
     && /sua: !!\(l && l\.khach_sua\)/.test(SRC));
}

console.log('\n⑪c MỘT THANG CHO CẢ CỬA — đo được, không ước lượng (Tracy 04/09)');
{
  /* Tracy: *"mấy ô không đều nhau nhìn lởm chởm quá · cỡ chữ to nhỏ lộn xộn"*.
     Đo bản trước khi sửa: BẢY cỡ chữ và các ô cùng hàng lệch tới 23px chiều
     cao. Ba ca dưới canh cho nó không trôi về đó lần nữa. */
  /* ⚠️ MỐC CẮT KHÔNG ĐƯỢC ÔM CON SỐ. Mốc cuối từng là `'HỞ 14px GIỮA CÁC
     KHỐI'` và nó chết ngay hôm 05/09 khi Tracy nới hở lên 20 rồi 26 — tiêu đề
     khối đổi theo, `indexOf` trả -1, và `slice(a, -1)` cắt ra gần trọn phần
     đuôi tệp. Ba ca dưới khi ấy soi cả app chứ không soi một khối CSS: ca đếm
     bậc chữ liệt kê năm mươi cỡ chữ của mọi màn. Một mốc cắt sai thì nó không
     đo cái mình định đo, mà cái sai ấy nhìn y như một lỗi thật. */
  const KHOI = SRC.slice(SRC.indexOf('MỘT THANG CHO CẢ CỬA SỰ KIỆN'),
                         SRC.indexOf('GIỮA CÁC KHỐI', SRC.indexOf('MỘT THANG CHO CẢ CỬA SỰ KIỆN')));
  /* ĐỌC RA con số, không viết cứng nó: Tracy chỉnh chiều cao và hở hai lần
     trong một buổi chiều, mà một ca thử viết cứng con số thì mỗi lần chỉnh là
     một ca đỏ oan — và đỏ oan dạy người ta thôi tin cả bảng. Thứ đáng canh là
     "mọi ô lấy CHUNG một biến", không phải "biến ấy đang bằng bao nhiêu". */
  la('năm biến hình khối khai ở MỘT chỗ, không gõ tay rải rác',
     /--o-cao:\d+px;--o-bo:\d+px;--o-to:\d+px;--o-mau:\d+px;--o-mau-ho:\d+px/.test(KHOI));
  /* `--o-bo-to` GỠ 05/09 (TRI-121) — nó mất người dùng cuối khi ô màu tách khỏi
     cỡ ô Tên và có thang riêng 30px/9px (Tracy: *"o mau kia cho be lai nua di"*).
     Cùng lượt ấy, hai con số của ô màu thôi gõ tay: `--o-mau` và `--o-mau-ho`
     nay nuôi CẢ BA chỗ từng chép tay cùng một giá trị — bề ngang ô màu, hở của
     hàng Tên, và lề trái của dải màu bung ra. Chỗ thứ ba là chỗ đã trôi hai lần
     (36px cho thời ô 26px, rồi 42px cho thời ô 30px) vì nó ở xa nơi nó phụ
     thuộc; nay nó đọc `calc(var(--o-mau) + var(--o-mau-ho))`. */
  la('mọi ô của thang chung đều đi qua biến, không ô nào gõ thẳng con số',
     ['--o-cao','--o-bo','--o-to','--o-mau'].every(v => KHOI.includes('var(' + v + ')')),
     ['--o-cao','--o-bo','--o-to','--o-mau']
       .map(v => v + (KHOI.includes('var(' + v + ')') ? ' ✓' : ' ✗')).join(' · '));
  /* HAI CA DƯỚI ĐO TRÊN CẢ TỆP, không trên `KHOI`. Hàng Tên và dải màu bung ra
     khai TRƯỚC khối thang — chúng thuộc về chỗ chúng vẽ, không thuộc về chỗ
     khai biến — nên soi chúng trong lát cắt là soi một chỗ chúng không có mặt,
     và ca sẽ đỏ vì lý do không dính gì tới điều nó hỏi. */
  la('hở hàng Tên đọc `--o-mau-ho`, không gõ tay',
     /\.lc-ten-hang\{gap:var\(--o-mau-ho\)/.test(SRC));
  /* Ô màu có thang RIÊNG — ngoại lệ có chủ ý, ghim lại để nó đừng lặng lẽ
     quay về bám cỡ ô Tên lần nữa. Nay đo qua BIẾN: con số nằm một chỗ, và lề
     của dải màu tự đi theo nó. */
  la('ô màu có thang riêng, không đi theo cỡ ô Tên',
     /\.lc-than \.lc-o-mau\{width:var\(--o-mau\);height:var\(--o-mau\);border-radius:\d+px\}/.test(KHOI));
  la('lề dải màu ĐỌC hai biến ấy, không gõ tay tổng của chúng',
     /#lc-mau-hop\{padding:[^}]*calc\(var\(--o-mau\) \+ var\(--o-mau-ho\)\)\}/.test(SRC),
     'một con số gõ tay ở đây đã trôi hai lần rồi');
  la('thang này phủ CẢ HAI cửa — cửa Sự kiện và khoang sự kiện của cửa gộp',
     /\.lc-than, \.vc-rieng\{--o-cao/.test(KHOI) && KHOI.includes('.vc-rieng select'));
  /* NĂM bậc chữ, và ca này canh cho bậc thứ SÁU không lẻn vào.
     Bốn cho tới 04/09; bậc thứ năm là quyết định của Tracy 05/09: *"dung viet
     hoa, co chu be thoi"* — nhãn ô (`.tv-nhan`) tách khỏi tiêu đề mục
     (`.lc-muc`) và hạ xuống một nấc, vì chữ hoa toàn phần cộng giãn chữ là
     hình của một tiêu đề, nó hô to ngang với thứ nó đặt tên.
     Hai bậc cuối đều là NGOẠI LỆ CÓ CHỦ Ý, và đều ghim tên chỗ dùng để bậc
     mới không lẻn vào dưới danh nghĩa một trong hai:
       1,05rem — tên sự kiện, thứ duy nhất được to hơn;
       0,86rem — mọi ô nhập · ô chọn · nút · nhãn cạnh ô tick;
       0,72rem — tiêu đề mục;
       0,7rem  — nhãn ô;
       0,79rem — khối Quyền của khách (Tracy 04/09 *"cho nhỏ đi"*: ba công tắc
                 ít khi đụng tới). */
  const co = [...new Set((KHOI.match(/font-size:[^;}]+/g) || []))];
  la('đúng năm bậc chữ, hai bậc cuối là nhãn ô và khối Quyền',
     co.length === 5
     && /\.vc-rieng \.tv-nhan\{text-transform:none;[^}]*font-size:/.test(KHOI)
     && /\.lc-quyen-hang \.lc-so\{font-size:/.test(KHOI), co.join(' · '));
  la('bọc trong .lc-than, không sửa lớp gốc dùng chung',
     !/^\s*\.o-ngay\{/m.test(KHOI) && !/^\s*\.nut-nho\{/m.test(KHOI));
  la('hàng thời gian gói thành cụm, để lúc hẹp gãy đúng chỗ',
     /\.lc-cum\{[^}]*flex-wrap:nowrap/.test(SRC)
     && (SRC.match(/class="lc-cum"/g) || []).length === 2);
  la('cặp nhãn + ô của một mục thở gần nhau hơn hai mục cách nhau',
     /\.lc-o-muc\{[^}]*gap:6px/.test(SRC));
  /* HAI nhịp hở, không một. Một khoảng cách duy nhất thì không dựng được nhóm
     nào — mắt không có cách nào đọc ra bốn ô thuộc về nhau còn ô thứ năm thì
     không. Trong nhóm 8px · giữa hai nhóm 8+14=22px, gần gấp ba. */
  /* Canh TỈ LỆ, không canh con số: hở trong nhóm phải NHỎ HƠN HẲN hở giữa hai
     nhóm, và đó mới là thứ dựng ra nhóm. Con số thì Tracy còn chỉnh tiếp. */
  const gTrong = +(SRC.match(/\.lc-nhom\{display:flex;flex-direction:column;gap:(\d+)px/) || [])[1];
  const gLe    = +(SRC.match(/\.lc-nhom\{[^}]*margin:(\d+)px 0\}/) || [])[1];
  const gCha   = +(SRC.match(/\.lc-than\{display:flex;flex-direction:column;gap:(\d+)px\}/) || [])[1];
  la('trong một nhóm thì sát, giữa hai nhóm thì xa ít nhất gấp đôi',
     gTrong > 0 && gCha > 0 && (gCha + 2 * gLe) >= gTrong * 2,
     `trong ${gTrong}px · giữa ${gCha + 2 * gLe}px`);
  la('ô ngày khai bề ngang cứng — bề ngang nội tại của trình duyệt làm tràn hàng',
     /input\[type=date\]\{width:126px/.test(SRC));
  la('nút một dòng vẫn có đệm ngang, không cắt cụt chữ',
     /\.lc-thu-nut\{padding-left:14px/.test(SRC));
  /* ⚠️ Luật ô ngày phải ĐẶC HIỆU HƠN `.lc-so input[type=date]{width:auto}`.
     Bản đầu khai một lớp và bị luật hai lớp kia ghi đè — khai 114px mà đo ra
     152px. Con số viết ra không ăn, mà nhìn thì tưởng trình duyệt bướng. */
  la('luật ô ngày đủ đặc hiệu để thắng luật cũ',
     /\.lc-than label\.lc-so input\[type=date\]\{width:/.test(SRC));

  /* NGÀY KẾT THÚC là ô nhập THẬT cho cả buổi có giờ (Tracy 04/09) — bản trước
     tôi bày nó thành chữ trơn suy ra, viện cớ kho chặn ở 10 giờ. Số đó SAI:
     ràng buộc thật là `so_phut between 5 and 1440`, tức 24 giờ; 600 chỉ là max
     của ô nhập cũ, một giới hạn giao diện tôi đọc nhầm thành luật của kho. */
  const KH = SRC.slice(SRC.indexOf('function lcMoForm('),
                       SRC.indexOf('function lcLuatMoi(', SRC.indexOf('function lcMoForm(')));
  la('ngày kết thúc là ô nhập thật, không còn là chữ suy ra',
     !SRC.includes('lc-den-suy') && /id="lc-den-ngay"/.test(KH));
  la('trần một buổi tính theo kho là 1440 phút, không phải 600',
     /phut > 1440/.test(SRC) && !/Math\.min\(600/.test(SRC));
  la('quá trần thì NÓI RA, không lặng lẽ ghìm',
     /toast\('Một buổi có giờ dài nhất 24 tiếng/.test(SRC));
  la('độ dài tính theo CẢ ngày lẫn giờ ở hai đầu',
     /lcSoNgayCach\(tu, den\) \* 1440/.test(SRC));

  /* Cửa GỘP đi cùng thang và cùng nhóm (Tracy 04/09 *"sửa cả cửa sổ này nữa"*). */
  /* Mốc cuối là dòng ĐÓNG của chính hàm ấy, không phải tên hàm kế tiếp:
     `vcChonMau` nằm TRƯỚC `vcVeSuKien` trong tệp, nên lấy nó làm mốc cuối là
     cắt ra một chuỗi RỖNG — và một chuỗi rỗng thì ca nào cũng đỏ, nhìn y như
     một lỗi thật. Cùng cái bẫy mốc-tìm-sai đã cắn ở mục ⑪. */
  const GOP = SRC.slice(SRC.indexOf('function vcVeSuKien('),
                        SRC.indexOf("o.dataset.day = '1'", SRC.indexOf('function vcVeSuKien(')));
  /* BA nhóm, không hai. Cùng đợt 05/09 (*"áp cho CẢ HAI cửa khai sự kiện"*):
     ô Loại sự kiện rời khỏi hàng của ô Đối tượng, ra một nhóm riêng có nhãn —
     cùng lẽ với cửa Sự kiện, nơi nó về đứng cạnh cần gạt Trạng thái lịch. Cửa
     gộp không có cần gạt ấy nên ô Loại đứng một mình.
     Ba nhóm: buổi này là gì · ai có mặt · dài bao lâu và lặp thế nào. */
  la('cửa gộp cũng chia nhóm', (GOP.match(/class="lc-nhom/g) || []).length === 3,
     'đếm được ' + (GOP.match(/class="lc-nhom/g) || []).length);
  la('và nhóm AI của nó cũng liền một mạch',
     GOP.indexOf('id="lc-ai-nhan"') < GOP.indexOf('id="lc-pv"')
     && GOP.indexOf('id="lc-pv"') < GOP.indexOf('id="lc-moi-hang"')
     && GOP.indexOf('id="lc-moi-hang"') < GOP.indexOf('id="lc-ranh-o"'));
  la('ô Dài của cửa gộp nới trần lên đúng con số của kho',
     /id="lc-phut" min="5" max="1440"/.test(GOP));
}

console.log('\n⑪b TỆP SQL THỨ TƯ — quyền của khách');
{
  la('ba cột khach_* thêm cho lich_chung',
     ['khach_sua','khach_moi','khach_xem_ds'].every(c =>
       new RegExp('add column if not exists ' + c).test(SQL4)));
  la('sua_lich nới đúng một vế, đòi CẢ cờ lẫn có tên trong danh sách',
     /khach_sua and nguoi_id_dang_nhap\(\) = any\(nguoi_ids\)/.test(SQL4));
  /* Cho khách sửa là cho họ chạy update trên dòng ấy, mà RLS theo DÒNG chứ
     không theo CỘT — nên hai cột cấm phải có cò giữ, không có cách nào khác. */
  la('cò giữ rieng_tu và tao_boi khỏi tay khách',
     /new\.rieng_tu := old\.rieng_tu/.test(SQL4) && /new\.tao_boi\s+:= old\.tao_boi/.test(SQL4));
  la('⛔ xoa_lich KHÔNG bị nới theo', !/create policy xoa_lich/.test(SQL4));
  la('bộ tự kiểm đứng cuối, dòng chưa đạt nổi lên đầu',
     SQL4.indexOf('SỐ LIỆU THAM KHẢO') < SQL4.indexOf('as t(so, muc, dat)')
     && /order by dat, so;/.test(SQL4));
}

console.log('\n' + (truot ? `❌ ${truot} ca TRƯỢT · ${dat} đạt` : `✅ ${dat} ca đạt.`) + '\n');
process.exit(truot ? 1 : 0);
