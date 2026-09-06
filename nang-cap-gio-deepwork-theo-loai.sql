-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: khung nhìn `gio_deepwork_theo_loai`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- GIỜ DEEPWORK TÁCH BA LOẠI VIỆC, VÀ MỞ KHO VIỆC CHO CẢ ĐỘI
--                                                    (Tracy chốt 2026-08-17)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
-- Chạy lại nhiều lần không sao (idempotent). Chạy SAU 'schema.sql',
-- 'va-sau-dot-soi-08-08.sql' và 'nang-cap-tran-180-phut.sql'.
--
-- ─── VÌ SAO CÓ FILE NÀY ────────────────────────────────────────────────────
--
-- Màn Cả ROVA đang chỉ đo 5 việc cố định (💎 / 🪨 / 💩). Không một con số
-- deepwork nào. Tracy giao: tách giờ deepwork của từng người thành BA LOẠI —
-- việc cố định · cam kết · việc phát sinh.
--
-- Ba loại này RỜI NHAU VÀ PHỦ HẾT, không phải do quy ước mà do ràng buộc
-- `mot_phien_mot_viec` (nang-cap-deepwork-tu-do.sql:34) đã ép sẵn: mỗi phiên
-- phục vụ đúng MỘT thứ, hoặc một task hoặc một nhịp.
--     nhip_id có          → việc cố định
--     task.tieu_diem_ma có → cam kết
--     task.tieu_diem_ma rỗng → việc phát sinh
--
-- ─── VÌ SAO PHẢI MỞ KHO TRƯỚC ──────────────────────────────────────────────
--
-- Nhãn loại việc phải lấy từ bảng `task`. Nhưng policy `doc_task` (dựng ngày
-- 08/08, va-sau-dot-soi-08-08.sql:53-58) giấu việc còn trong kho (`ngay is
-- null`) khỏi mọi người trừ chủ nó. Mà khung nhìn ở dự án này BẮT BUỘC bật
-- `security_invoker = on` nên chạy bằng quyền NGƯỜI GỌI, tức chịu đúng policy
-- ấy. Hệ quả nếu để nguyên: xem hàng của người khác thì mọi phiên gắn việc
-- trong kho tra không ra loại, rơi vào một ô "không rõ".
--
-- Ô "không rõ" ấy là thứ đáng sợ hơn cả sai số, vì lý do DUY NHẤT khiến một
-- phiên không rõ loại chính là việc ấy đang nằm trong kho. Bày nó ra là đi
-- thông báo cho cả đội rằng người kia có việc chưa hẹn ngày và tốn bao nhiêu
-- phút vào đó. Nặng hơn nữa là LỘ BẰNG PHÉP TRỪ: `gio_deepwork_theo_ngay`
-- (nang-cap-tran-180-phut.sql:94) không chạm `task` nên đã đưa cho cả đội TỔNG
-- phút mỗi người mỗi ngày; có thêm một khung nhìn chia theo loại thì
-- *tổng − các ô nhìn thấy = phút đổ vào việc còn trong kho*.
--
-- ⚠️ VÀ ĐÂY LÀ CHỖ PHẢI NÓI THẲNG: hàng rào của Postgres chặn theo DÒNG, không
-- theo CỘT. Dự án đã học bài này một lần rồi và phải tách hẳn một bảng riêng
-- (nang-cap-doc-rieng-tu.sql:31-33). Nên KHÔNG có cách mở hé để lấy mỗi cái
-- nhãn — mở là mở nguyên dòng, tức cả NỘI DUNG việc chưa chín.
--
-- Tracy đã nghe mặt trái đó và vẫn chọn mở: *"ừ cứ công khai kho việc đi có gì
-- đâu"* (17/08). Kèm theo là hướng đi thay thế, làm sau: *"tôi sẽ cho mọi người
-- có những cam kết private thì task của cam kết đó cũng vậy"* — tức ranh giới
-- riêng tư thật sự sẽ chạy theo CAM KẾT, không chạy theo chuyện đã hẹn ngày
-- hay chưa. Ranh giới ấy hợp lý hơn hẳn ranh giới cũ.
--
-- ⛔ ĐIỀU PHẢI BIẾT KHI DỰNG TÍNH NĂNG CAM KẾT RIÊNG TƯ SAU NÀY — đừng dò lại,
-- và đừng đọc lướt vì nó KHÔNG hỏng theo kiểu bạn đoán.
-- Nếu tính năng đó chặn ở tầng RLS của `task`, khung nhìn dưới đây **không mất
-- dòng nào** (`left join` giữ lại) và **không sinh ô "không rõ loại" nào**
-- (nhánh `else` dán thẳng 'phat_sinh'). Thứ xảy ra là **ÂM THẦM DÁN SAI NHÃN**:
-- phút của một cam kết kín bị đếm sang ô "việc phát sinh" — cùng một phiên,
-- chủ thấy 'cam_ket' còn đồng đội thấy 'phat_sinh'.
-- ⚠️ Tổng phút và tổng số phiên KHÔNG đổi một đơn vị, nên MỤC 4 VÀ MỤC 5 CỦA
-- BỘ TỰ KIỂM VẪN BÁO ✅. Chúng canh phần dư, không canh nhãn. Bảng "cả đội đổ
-- giờ vào đâu" sẽ nói dối mà không một dấu hiệu nào hiện lên.
-- KHÔNG chữa được bằng cách sửa khung nhìn này; phải chuyển sang ghi nhãn loại
-- việc lên chính `phien_deepwork` (một cột, app điền lúc mở phiên, lấp một lượt
-- cho dữ liệu cũ). Đường ấy đã soi xong, ghi ở `DA-SOI-TRONG-MA.md` mục
-- "Phiên deep work gắn vào việc còn trong KHO".
--
-- 🛡 MỘT ĐIỀU KHUNG NHÌN NÀY CỐ Ý KHÔNG LÀM: nó KHÔNG trả ra `tieu_diem_ma`,
-- chỉ trả ra một trong ba nhãn. Nhờ vậy khi cam kết riêng tư ra đời, phiên của
-- một cam kết kín vẫn đếm đúng vào ô "cam kết" mà không hé lộ cam kết nào.
--
-- ⚠️ TRẦN 180 PHÚT NAY NẰM Ở BẢY CHỖ. Khung nhìn này là chỗ thứ bảy, sau
-- `vuon_cay` · `cham_theo_ngay` · `gio_deepwork_theo_ngay` ·
-- `gio_deepwork_theo_gio` · `nhip_thoi_gian` (nang-cap-tran-180-phut.sql) và
-- hằng `DW_TRAN_PHUT` bên app. Sửa một chỗ mà quên chỗ khác thì người ngồi
-- 3 tiếng thấy app đếm 3 tiếng còn bảng này ghi 2 tiếng, và không dòng tự kiểm
-- nào kêu lên. Mục 3 của bộ tự kiểm dưới đây canh đúng chuyện đó.
-- ═══════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
-- ⏸ ĐO TRƯỚC KHI MỞ — chạy RIÊNG khối này trước, đọc số, rồi mới chạy cả file
--
-- Mở kho có HAI hệ quả nhìn thấy được ngay trên màn hình, đã soi trong mã ngày
-- 17/08. Ba câu dưới đây cho biết chúng lớn cỡ nào TRÊN DỮ LIỆU THẬT của đội —
-- đoán thì không đoán được, mà chạy rồi mới biết thì đã muộn.
--
-- ① Đồng đội sẽ ĐỌC ĐƯỢC việc chưa hẹn ngày của nhau, ngay trong app.
--    Chỗ bày ra là màn Cam kết cả ROVA: `moTaskDoi` (index.html:11967) hỏi task
--    của người khác theo (người · cam kết) và KHÔNG lọc `ngay`. Đường vẽ đã có
--    sẵn, kể cả cái nhãn `kho` (index.html:12050) — nghĩa là mở policy xong là
--    nó hiện, không cần sửa một dòng mã nào. Bày ra cả `noi_dung` lẫn
--    `ghi_chu_chot`.
--
-- ② MỌI PHẦN TRĂM DONE CỦA CẢ ĐỘI SẼ TỤT XUỐNG, dù không ai làm gì sai.
--    `tien_do_o` (nang-cap-output-cam-ket.sql:167-176) đếm `so_task`/`so_xong`
--    bằng truy vấn con trên `task` và bật `security_invoker`, nên HÔM NAY nó
--    đang đếm THIẾU phần kho của người khác. Mở kho là mẫu số phình ra: ô
--    "Done %" ở chế độ Cả ROVA (index.html:10481) tụt, và vạch tiến độ từng cam
--    kết của từng người (index.html:11897-11923) ngắn lại.
--    ⚠️ Người trong đội sẽ thấy số của mình xấu đi sau một đêm mà không hiểu vì
--    sao. Đây là thứ nên báo cho 12 người TRƯỚC khi chạy, không phải sau.
--
-- ③ Số 🍎 trong bảng vinh danh CÓ THỂ đổi — `vuon_cay` join `task`, và app hỏi
--    nó không lọc người. Chỉ đổi nếu tồn tại việc đã Done mà chưa hẹn ngày.
--    Câu (c) dưới đây trả lời. (Bảng 💧 giờ deepwork KHÔNG đổi — `cham_theo_ngay`
--    chỉ đọc `phien_deepwork`.)
--
-- (a) Mỗi người đang giữ bao nhiêu việc trong kho — đây là lượng chữ sắp mở ra:
--     select n.ten, count(*) as viec_trong_kho
--       from task t join nguoi n on n.id = t.nguoi_id
--      where t.ngay is null group by 1 order by 2 desc;
--
-- (b) Done % sẽ tụt bao nhiêu điểm — chạy TRƯỚC để có số mà so:
--     select round(100.0 * count(*) filter (where trang_thai = 'Done')
--                  / nullif(count(*), 0))                       as pct_hom_nay,
--            round(100.0 * count(*) filter (where trang_thai = 'Done')
--                  / nullif(count(*) filter (where ngay is not null), 0)) as pct_neu_van_kin
--       from task;
--
-- (c) Có việc nào đã Done mà chưa hẹn ngày không (0 nghĩa là 🍎 không đổi):
--     select count(*) from task where ngay is null and trang_thai = 'Done';
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Mở kho việc cho cả đội ──────────────────────────────────────────────
-- Trả `doc_task` về đúng hình dạng gốc ở schema.sql:271, tức bỏ vế soi chủ mà
-- đợt soi 08/08 thêm vào. Cả đội đọc được mọi việc của nhau, kể cả việc chưa
-- hẹn ngày.
--
-- KHÔNG đụng policy GHI. `ghi_task` vẫn chỉ cho mỗi người sửa việc của chính
-- mình — mở đọc không phải mở ghi.
drop policy if exists doc_task on task;
create policy doc_task on task for select
  using (la_thanh_vien());

comment on policy doc_task on task is
  'Cả đội đọc mọi việc của nhau, kể cả việc còn trong kho (ngay rỗng). Tracy chốt 17/08 sau khi cân với đường giữ kín: hàng rào Postgres chặn theo dòng chứ không theo cột nên không mở hé được, mà số giờ deepwork tách theo loại thì cần đọc được nhãn cam kết của mọi việc. Ranh giới riêng tư thật sự sẽ chuyển sang chạy theo CAM KẾT (tính năng cam kết riêng tư, làm sau).';


-- ─── 2. Việc trong kho ra khỏi mẫu số của Done % ────────────────────────────
-- (Tracy chốt 17/08 khi nghe hệ quả ② của mục 1)
--
-- Việc chưa hẹn ngày là việc CHƯA NHẬN LÀM. Đếm nó vào mẫu số "đã xong được
-- bao nhiêu phần" vốn đã sai nghĩa — mở kho chỉ làm cái sai ấy lộ ra và lộ
-- đồng loạt cho cả 12 người cùng một lúc.
--
-- ⚠️ VÀ NÓ ĐANG VÁ MỘT CHỖ LỆCH CÓ SẴN, không chỉ là chống đỡ cho mục 1. Vì
-- `tien_do_o` chạy bằng quyền người gọi, HÔM NAY hai người đọc cùng một khung
-- nhìn ra hai cách tính khác nhau: dòng của CHÍNH MÌNH thì đếm được cả kho của
-- mình nên mẫu số to; dòng của đồng đội thì kho bị policy giấu nên mẫu số nhỏ.
-- Tức mỗi người đang tự thấy Done % của mình THẤP HƠN mặt bằng, một cách có hệ
-- thống, và không ai biết. Thêm mệnh đề `ngay is not null` là cả 12 dòng về
-- chung một thước — bất kể kho mở hay kín.
--
-- CỐ Ý KHÔNG đụng `so_kho`: cột ấy sinh ra để đếm kho, giữ nguyên `ngay is null`.
-- CỐ Ý KHÔNG đụng ba cột cây và `tong_phut`: chúng đếm phiên deepwork thật, không
-- liên quan tới chuyện hẹn ngày.
--
-- ⚠️ PHẢI `drop` + `create`, KHÔNG được `create or replace`. Bản ĐANG SỐNG có
--    **28 cột** và `bo_the` đứng ở **vị trí 14**, tức chen giữa chứ không nằm
--    cuối; `create or replace` chỉ cho thêm cột vào CUỐI nên sẽ ném `42P16`
--    (`cannot change name of view column "bo_the" to "output_chu"`). SQL Editor
--    gói cả file trong một giao dịch, nên một câu hỏng là CUỘN NGƯỢC TẤT CẢ:
--    kho không mở, khung nhìn mới không dựng, bảng tự kiểm không in dòng nào.
--
-- ⛔ THÂN DƯỚI ĐÂY CHÉP TỪ `nang-cap-ghi-chu.sql:100-142` (14/08) — bản MỚI
--    NHẤT. Đừng chép từ `nang-cap-output-cam-ket.sql`: bản đó là 11/08, đã bị
--    thay HAI đời (12/08 thêm `han_goc`·`so_lan_doi_han`·`ngay_troi` ·
--    14/08 thêm `bo_the`). Bản nháp đầu của chính file này đã chép nhầm đúng
--    bản cũ ấy và suýt mang lỗi 42P16 lên máy chủ thật.
--    👉 Lần sau chạm `tien_do_o`, tìm bản sống bằng MÁY chứ đừng nhớ:
--       grep -l "create.*view tien_do_o" *.sql | xargs ls -t | head -1
--
-- Chỉ thêm ĐÚNG HAI dòng `and t.ngay is not null`, vào `so_task` và `so_xong`.
-- CỐ Ý KHÔNG đụng `so_kho` (cột ấy sinh ra để đếm kho, và danh sách trạng thái
-- của nó đã bỏ `Blocked` từ 12/08 — giữ nguyên, đừng "sửa" lại).
-- CỐ Ý KHÔNG đụng ba cột cây và `tong_phut`: chúng đếm phiên deepwork thật.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,

  -- Bộ thẻ ghi chú (14/08) — app đọc để dựng chip lọc và chip xếp.
  o.bo_the,

  -- Năm cột output (11/08) — app đọc thẳng từ đây, không hỏi bảng thô lần nữa.
  o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,

  -- Ba cột cờ dời hạn (12/08, việc 53). Máy chủ ghi, app chỉ đọc.
  o.han_goc, o.so_lan_doi_han, o.ngay_troi,

  -- Ba cột cũ, giữ nguyên: đếm CÂY (task đã có phiên deepwork thật).
  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  -- Hai cột đếm TASK, viết bằng truy vấn con vô hướng — KHÔNG thêm `left join`
  -- thứ hai vào `task`, vì nó sẽ nhân chéo với `vuon_cay` đang join sẵn ở dưới
  -- và làm ba cột cây phía trên phồng lên sai bét.
  -- 🆕 17/08: thêm `t.ngay is not null` — việc chưa hẹn ngày là việc CHƯA NHẬN
  -- LÀM nên không vào mẫu số Done %.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null)                                    as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null
       and t.trang_thai = 'Done')                                 as so_xong,
  -- Ô "còn mở" khớp ĐÚNG nhóm Kho mà bảng cam kết vẽ — cố ý KHÔNG đếm
  -- `Blocked` (nó có nhóm 🚧 riêng luôn xổ; lý lẽ đầy đủ ở
  -- `nang-cap-hien-co-va-sua-phien.sql` mục 2). GIỮ NGUYÊN, không đụng.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Confirm','Doing','Chua_xong'))
                                                                  as so_kho

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
         o.bo_the,
         o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
         o.han_goc, o.so_lan_doi_han, o.ngay_troi;

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm task ĐÃ HẸN NGÀY — việc còn trong kho là việc chưa nhận làm nên không vào mẫu số Done % (Tracy chốt 17/08); so_kho đếm riêng phần kho, không đếm Blocked; output_* và da_nhan_* là phần thu hoạch khi đóng cam kết; han_goc, so_lan_doi_han, ngay_troi là cờ dời hạn; bo_the là bộ thẻ ghi chú.';


-- ─── 3. gio_deepwork_theo_loai ──────────────────────────────────────────────
-- Gộp theo (người × ngày giờ Việt Nam × loại việc).
--
-- Ba lựa chọn đã cân, ghi ra để đời sau khỏi đoán:
--
-- ① CÙNG BỘ LỌC PHIÊN với `gio_deepwork_theo_ngay` (`ket_qua = 'song'` và
--    `ket_thuc is not null`), KHÔNG mượn `cham_theo_ngay` — khung nhìn đó loại
--    phiên gắn nhịp, dùng nó thì tổng hai bên lệch nhau đúng bằng phần việc cố
--    định, và phần lệch ấy lại đọc ra được như một vùng bị giấu.
--
-- ② `left join` chứ không `join`. Khoá ngoại `task_id` là `on delete cascade`
--    nên xoá việc là phiên đi theo, tức về lý thuyết không có dòng mồ côi. Vẫn
--    dùng `left join` để nếu ngày nào đó có dòng lệch thì nó rơi vào 'phat_sinh'
--    chứ không BIẾN MẤT khỏi tổng — mất dòng mới là thứ đẻ ra phần dư.
--
-- ③ Trả nhãn, không trả mã cam kết. Xem khối 🛡 ở đầu file.
create or replace view gio_deepwork_theo_loai as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  case
    when p.nhip_id is not null        then 'co_dinh'
    when t.tieu_diem_ma is not null   then 'cam_ket'
    else                                   'phat_sinh'
  end                                               as loai,
  count(*)                                          as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
left join task t on t.id = p.task_id
where p.ket_qua = 'song' and p.ket_thuc is not null
group by p.nguoi_id,
         (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date,
         3;

comment on view gio_deepwork_theo_loai is
  'Phút và số phiên deepwork gộp theo (người × ngày giờ Việt Nam × loại việc). Ba loại rời nhau và phủ hết nhờ ràng buộc mot_phien_mot_viec: co_dinh (phiên gắn nhịp) · cam_ket (việc có mã cam kết) · phat_sinh (việc không có). Cùng bộ lọc phiên và cùng trần 180 phút với gio_deepwork_theo_ngay nên tổng hai bên khớp nhau — đó là bất biến, mục 4 bộ tự kiểm canh nó. CỐ Ý không trả tieu_diem_ma, chỉ trả nhãn, để tính năng cam kết riêng tư sau này không phải sửa khung nhìn. Nuôi dải Giờ deepwork ở màn Cả ROVA.';


-- ─── 4. Bật quyền người gọi ────────────────────────────────────────────────
-- BẮT BUỘC, không thương lượng. Thiếu dòng này thì khung nhìn chạy bằng quyền
-- NGƯỜI TẠO, tức vượt mặt RLS và mọi tài khoản đăng nhập đọc được số của cả đội.
-- `create or replace` có thể giữ được thiết lập cũ, nhưng cứ đặt lại cho chắc;
-- sau `drop view` thì chắc chắn mất. Đặt cho CẢ HAI khung nhìn file này chạm.
alter view gio_deepwork_theo_loai set (security_invoker = on);
alter view tien_do_o               set (security_invoker = on);


-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ KIỂM — chín dòng phải ĐÚNG hết
--
-- Dòng 1–3 soi ĐỊNH NGHĨA đang sống trong máy chủ. Dòng 4–5 đo trên DỮ LIỆU
-- THẬT, vì định nghĩa đúng mà số vẫn lệch là chuyện đã xảy ra ở dự án này.
-- Dòng 6–9 canh mục 2 (`tien_do_o`) — nhất là dòng 8 và 9: sau `drop view` mà
-- chép thiếu một cột thì app KHÔNG báo lỗi, nó lặng lẽ mất một ô số.
--
-- ⚠️ BỐN DÒNG NÀY KHÔNG CANH ĐƯỢC ĐIỀU GÌ, nói ra để đừng ai tin nhầm: chạy bộ
-- tự kiểm bằng SQL Editor là chạy dưới vai `postgres`, thấy hết mọi dòng. Nó
-- KHÔNG dựng lại được cảnh một thành viên bị hàng rào che mất dữ liệu. Muốn
-- kiểm chuyện đó thì phải đăng nhập bằng một tài khoản thật khác rồi mở app.
-- ═══════════════════════════════════════════════════════════════════════════
with kt as (
select * from (values

  /* ⚠️ Phải soi CẢ HAI vế. Bản đầu chỉ hỏi "đã bỏ vế soi chủ chưa" — một policy
     viết nhầm thành `using (true)` cũng qua dòng ấy với dấu ✅, mà `using (true)`
     là mở bảng `task` cho cả vai chưa đăng nhập. Tinh thần của file này là MỞ
     RA, nên đây đúng là chỗ dễ trượt tay nhất. Thêm `schemaname` vì `pg_policies`
     không tự lọc schema. */
  (1, 'Kho mở, nhưng doc_task VẪN soi tư cách thành viên',
   exists (select 1 from pg_policies
             where schemaname = 'public' and tablename = 'task'
               and policyname = 'doc_task'
               and qual ilike     '%la_thanh_vien%'
               and qual not ilike '%nguoi_id_dang_nhap%')),

  (2, 'gio_deepwork_theo_loai bật security_invoker (không vượt mặt RLS)',
   (select count(*) from pg_class
      where relname = 'gio_deepwork_theo_loai'
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  (3, 'Khung nhìn kẹp trần 180 phút',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) like '%180%'),

  /* ⚠️ DÒNG QUAN TRỌNG NHẤT. Nếu khung nhìn mới bỏ sót phiên nào — vì bộ lọc
     lệch, vì join làm rơi dòng, hay vì một hàng rào đọc nào đó che mất — thì
     tổng của nó THẤP HƠN `gio_deepwork_theo_ngay`, và đúng phần chênh ấy là
     thứ người trong đội trừ ra được để suy ngược. Bất biến này phải giữ mãi.

     Vì sao cho lệch tới 2 phút mỗi cặp (người, ngày) mà không đòi bằng 0:
     hai bên đều `round()` nhưng gộp theo hai mức khác nhau — bên kia làm tròn
     MỘT lần cho cả ngày, bên này làm tròn tới BA lần rồi cộng lại, nên sai số
     làm tròn tối đa 1,5 phút. Đây là sai số làm tròn, KHÔNG phải dòng bị mất;
     đừng ai "sửa" nó thành 0 rồi tưởng bắt được lỗi. */
  (4, 'Tổng phút khớp gio_deepwork_theo_ngay (không phiên nào rơi ra ngoài)',
   not exists (
     select 1
     from (select nguoi_id, ngay, sum(phut) as p
             from gio_deepwork_theo_loai group by 1, 2) a
     full join (select nguoi_id, ngay, phut as p
             from gio_deepwork_theo_ngay) b using (nguoi_id, ngay)
     where abs(coalesce(a.p, 0) - coalesce(b.p, 0)) > 2)),

  (5, 'Số phiên khớp tuyệt đối (đây không phải phép làm tròn nên phải bằng 0)',
   (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_loai)
   = (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_ngay)),

  (6, 'tien_do_o: việc trong kho đã ra khỏi mẫu số Done %',
   pg_get_viewdef('tien_do_o'::regclass) ilike '%ngay IS NOT NULL%'),

  (7, 'tien_do_o vẫn bật security_invoker',
   (select count(*) from pg_class
      where relname = 'tien_do_o'
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  /* Đếm cột là cách rẻ nhất bắt lỗi chép thiếu. App đọc `tien_do_o` ở bốn chỗ
     (index.html:4733 · 4773 · 10357 · 11897) và mỗi cột thiếu là một ô số biến
     mất mà KHÔNG có lỗi nào hiện lên — đúng loại hỏng ngầm khó truy nhất. */
  (8, 'tien_do_o còn đủ 28 cột (chép thiếu là app mất ô số trong im lặng)',
   (select count(*) from information_schema.columns
      where table_schema = 'public' and table_name = 'tien_do_o') = 28),

  /* Đếm cột thôi chưa đủ — mất một cột mà thừa một cột khác vẫn ra 28. Soi
     đích danh `bo_the` vì app dùng CHÍNH NÓ làm phép dò tính năng
     (`'bo_the' in TIEU_DIEM[0]`, index.html:11642): thiếu nó thì app không báo
     lỗi, nó lặng lẽ rơi sang nhánh cắt cụt — chip lọc thẻ chết, nhắc dời hạn
     hiện dấu gạch. Đúng loại hỏng ngầm khó truy nhất. */
  (9, 'tien_do_o còn cột bo_the (app dùng nó làm phép dò tính năng)',
   exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'tien_do_o'
               and column_name = 'bo_the'))

) as t(thu_tu, muc, dat))
select thu_tu, case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua, muc
from kt order by thu_tu;


-- ── SỐ LIỆU THAM KHẢO — không có đúng/sai ──────────────────────────────────
-- Chạy riêng nếu muốn nhìn:
--
-- ① Cả đội tuần này đổ giờ vào đâu:
--    select loai, sum(phut) as phut, sum(so_phien) as phien
--      from gio_deepwork_theo_loai
--     where ngay >= date_trunc('week', hom_nay())::date
--     group by 1 order by 2 desc;
--
-- ② Bao nhiêu phiên đang gắn vào việc còn trong kho — con số này chính là thứ
--    đã đẻ ra cả cuộc bàn ngày 17/08:
--    select count(*) from phien_deepwork p
--      join task t on t.id = p.task_id where t.ngay is null;
--
-- ── ĐƯỜNG LÙI, nếu sau này muốn đóng kho lại ───────────────────────────────
--    drop policy if exists doc_task on task;
--    create policy doc_task on task for select
--      using (la_thanh_vien()
--             and (ngay is not null or nguoi_id = nguoi_id_dang_nhap()));
--    ⚠️ Đóng lại thì ô "không rõ loại" và phép trừ quay lại — đọc khối ⛔ ở
--    đầu file trước khi chạy đường lùi này.
