-- ═══════════════════════════════════════════════════════════════════════════
-- SỔ SQL — TỆP NÀO ĐÃ CHẠY TRÊN MÁY CHỦ. Dựng 28/08/2026.
--
-- VÌ SAO KHÔNG PHẢI MỘT CÁI SỔ CHÉP TAY
-- Nợ cũ: 43 tệp `.sql` mà không chỗ nào ghi tệp nào đã chạy. Mỗi lần vá lại
-- phải mò từ đầu, và nguy cơ chạy nhầm thứ tự vẫn nguyên (án lệ 28/08: ba tệp
-- còn kẹp trần 120 phút trong khi app chạy 180 — chạy nhầm là hạ trần trong
-- im lặng).
--
-- Một cái sổ chép tay sẽ rữa đúng như mọi tài liệu khác trong kho này: người
-- chạy tệp và người sửa sổ không phải lúc nào cũng là một, và sổ sai còn tệ hơn
-- không có sổ vì nó được tin. Nên sổ ở đây là một **MÁY DÒ**: mỗi tệp nâng cấp
-- để lại một dấu vết RIÊNG trên máy chủ — một bảng, một cột, một bẫy, một hàm —
-- và câu hỏi dưới đây đọc thẳng danh mục của Postgres. Nó không thể lỗi thời.
--
-- CÁCH DÙNG: dán trọn file, chạy. Chỉ ĐỌC, không sửa gì. An toàn tuyệt đối.
--
-- ⚠️ HAI BẪY ĐÃ TRÁNH SẴN TRONG FILE NÀY, đừng "dọn" chúng lại:
--   · KHÔNG viết `'public.x'::regclass` cạnh một mệnh đề `case` bảo vệ nó. Đó là
--     một hằng, và Postgres gấp hằng ngay lúc LẬP KẾ HOẠCH — ném lỗi kể cả khi
--     nhánh ấy không bao giờ chạy. Dùng `to_regclass('public.x')`: nó là một lời
--     gọi hàm, trả `null` khi không có, và `pg_get_viewdef(null)` cũng ra `null`.
--   · KHÔNG viết `select 1 from mot_bang_co_the_chua_co`. Bảng không tồn tại là
--     lỗi lúc PHÂN TÍCH CÂU, `case` không đỡ được. Hỏi danh mục, đừng hỏi bảng.
--
-- ⚠️ Dò bằng thứ CÓ CẤU TRÚC (danh mục hệ thống), không bằng chuỗi máy chủ in
-- ra. Án lệ 28/08: một dòng tự kiểm so `pg_get_function_identity_arguments()`
-- với một chuỗi chỉ có kiểu, trong khi hàm ấy in ra cả tên tham số — đỏ oan
-- trong khi hàm hoàn toàn đúng. Khối ② dưới đây là chỗ DUY NHẤT buộc phải đọc
-- nội dung, và nó tự khai điều đó.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── ① TỆP CÓ DẤU VẾT RIÊNG ───────────────────────────────────────────────
-- Mỗi dòng: tệp · dấu vết nó để lại · đã chạy hay chưa.
--
-- ⚠️ LUẬT CHỌN DẤU VẾT: chỉ lấy thứ ĐÚNG MỘT TỆP dựng ra. Soát 01/09 bắt được
-- một dòng phạm luật — `nang-cap-danh-muc-viec-co-dinh.sql` lấy bảng
-- `chuc_nang` làm dấu vết, mà `nang-cap-lich-chung.sql` cũng
-- `create table if not exists chuc_nang`; chạy lich-chung một mình là dòng kia
-- sáng '✅ ĐÃ CHẠY' oan. Nay đổi sang trigger `nhip_dong_dau_tr`, thứ chỉ tệp
-- ấy dựng. Thêm dòng mới thì `grep -l` dấu vết ấy khắp thư mục trước: ra hai
-- tên tệp là dấu vết hỏng, đưa xuống khối ② hỏi theo NỘI DUNG.
--
-- ⚠️ KHÔNG ĐẾM SỐ TỆP TRONG TIÊU ĐỀ NỮA (soát 03/09). Tiêu đề ghi "44 TỆP"
-- trong khi bảng đã có 46 dòng — con số ấy là một cái sổ chép tay nhét vào giữa
-- một cái máy dò, và nó rữa đúng như tệp này cảnh báo ở đầu. Muốn biết bao
-- nhiêu thì đếm chính kết quả trả về.
--
-- CÁC TỆP CỐ Ý không có dòng ở khối này — kê theo BA LÝ DO, không kê theo số
-- lượng (một con số ở đây là một cái sổ chép tay nữa, và nó sẽ rữa đúng như con
-- số trong tiêu đề đã rữa).
--
-- ① Chỉ dựng lại một thứ mà tệp khác cũng dựng, nên sự tồn tại của thứ ấy không
--    nói tệp NÀO đã chạy: `nang-cap-mau-task-them-ngoc` ·
--    `nang-cap-doi-ten-trang-thai-task` · `nang-cap-co-doi-han-va-trang-thai` ·
--    `nang-cap-bo-tran-moc` · `nang-cap-cam-ket-ca-doi` ·
--    `nang-cap-gio-deepwork-theo-loai`.
--
-- ② KHÔNG DỰNG GÌ ĐỂ MÀ DÒ — không phải dấu vết hỏng, mà là không có dấu vết:
--    `nang-cap-realtime-lich` (chỉ kê bốn bảng vào một publication) ·
--    `va-nhan-du-tu-viec-da-xong` (một lượt `insert` bù dữ liệu cũ vào
--    `lich_chung_tham_du`, không đụng cấu trúc) · `go-cot-ghi-chu-chung`
--    (hai câu `select` để NHÌN trước khi gỡ cột `lich_chung.ghi_chu`; câu
--    `alter` thật vẫn đang nằm trong chú thích, chưa ai chạy).
--    ⚠️ Tệp thứ ba là một lời nhắc riêng: dấu vết của một tệp GỠ thứ gì đó là
--    sự VẮNG MẶT, mà khối này chỉ hỏi được "có tồn tại không". Ngày nào câu
--    `alter` ấy được mở ra chạy thì phải hỏi nó ở khối ②, không phải ở đây.
--
-- ③ Dấu vết từng sạch rồi hỏng về sau (dưới đây), một lối sẽ tái diễn:
-- `nang-cap-doc-ghi-chu` từng có dấu vết riêng sạch (`tieu_diem.doc_da_gop`),
-- nhưng `nang-cap-doc-rieng-tu` sau đó DỜI hai cột ấy sang bảng `doc_cam_ket`
-- rồi gỡ bản gốc. Dò 03/09: cả `tieu_diem.doc_ghi_chu` lẫn `tieu_diem.doc_da_gop`
-- đều đã biến mất, nên dòng cũ báo '⬜ CHƯA' cho một tệp đã chạy từ lâu.
-- **Bài học: một dấu vết đúng lúc chọn vẫn hỏng được về sau, khi tệp khác GỠ
-- chính thứ mình lấy làm dấu.** Và không sửa được bằng cách trỏ sang cột mới —
-- cột mới thuộc tệp KHÁC — nên phải xuống khối ② hỏi theo chuỗi.
--
-- Cùng lối hỏng ấy theo chiều NGƯỢC LẠI, và nó vừa xảy ra 05/09:
-- `nang-cap-co-cau-to-chuc` dựng hai thứ đáng làm dấu — cột `nguoi.ngay_nghi`
-- và cò `tg_chan_tu_go_quyen`. Chọn cột. KHÔNG chọn cò, vì
-- `nang-cap-tu-sua-ho-so` ra đời sau có một câu tự kiểm DÒ cái cò ấy, nên
-- `grep -l tg_chan_tu_go_quyen` nay ra HAI tên tệp. Cò vẫn do đúng một tệp
-- dựng, nhưng phép soát của chính sổ này thì không phân biệt được dựng với
-- dò. **Một dấu vết hỏng được chỉ vì tệp SAU ĐÓ nhắc tới nó** — nên khi hai
-- ứng viên cùng sạch, chọn cái ít có khả năng bị tệp khác nhắc lại.
with dau_vet(tep, loai, ten) as (values
  ('nang-cap-ban-tin.sql','table','ban_tin'),
  ('nang-cap-ban-tin-link.sql','col','ban_tin.link'),
  ('nang-cap-cam-ket-5-cua-ceo.sql','col','nguoi.so_cam_ket_toi_da'),
  ('nang-cap-cam-ket-va-muc-tieu.sql','table','muc_tieu'),
  ('nang-cap-checklist.sql','table','muc_viec'),
  ('nang-cap-cho-ban.sql','col','thanh_vien_du_an.da_xem_luc'),
  ('nang-cap-chot-chan-phien.sql','col','phien_deepwork.nghi_ms'),
  ('nang-cap-chot-su-kien.sql','col','lich_chung.da_chot'),
  ('nang-cap-chuong-tinh-thuc.sql','table','tieng_chuong'),
  ('nang-cap-co-cau-to-chuc.sql','col','nguoi.ngay_nghi'),
  ('nang-cap-cong-gac-khung-nhin.sql','func','kiem_khung_nhin_thieu_quyen'),
  ('nang-cap-danh-muc-viec-co-dinh.sql','trig','nhip_dong_dau_tr'),
  ('nang-cap-deepwork-tu-do.sql','col','phien_deepwork.cua'),
  ('nang-cap-do-viec-done.sql','col','gat_theo_ngay.so_qua_dw'),
  ('nang-cap-doc-rieng-tu.sql','table','doc_cam_ket'),
  ('nang-cap-doc-su-kien.sql','table','doc_su_kien'),
  ('nang-cap-doi-buoi-rieng.sql','col','lich_chung_ngoai_le.so_phut_moi'),
  ('nang-cap-doi-gio-viec-ca-doi.sql','func','doi_gio_viec_theo_chuoi'),
  ('nang-cap-don-phien-bo-roi.sql','func','don_phien_bo_roi'),
  ('nang-cap-du-kien-viec-co-dinh.sql','trig','nhip_ke_thua_du_kien'),
  ('nang-cap-ghi-chu.sql','table','ghi_chu'),
  ('nang-cap-ghi-chu-buoi.sql','table','ghi_chu_buoi'),
  ('nang-cap-giao-cam-ket.sql','col','nguoi.so_cam_ket_kho_toi_da'),
  ('nang-cap-giai-doan-va-moc.sql','col','moc_du_an.ngay_bat_dau'),
  ('nang-cap-gio-chu-doi-va-neo-nhip.sql','index','ghi_chu_theo_nhip'),
  ('nang-cap-gio-start-end.sql','col','nhip.gio_end'),
  ('nang-cap-hien-co-va-sua-phien.sql','col','phien_deepwork.khai_tay'),
  ('nang-cap-hien-dien-deepwork.sql','view','ai_dang_lam'),
  ('nang-cap-khu-vuon.sql','col','tieu_diem.luong'),
  ('nang-cap-lap-buoc-va-so-lan.sql','col','lich_chung.so_lan'),
  ('nang-cap-lich-chung.sql','table','lich_chung'),
  ('nang-cap-lich-dieu-hanh.sql','col','nguoi.la_dieu_hanh'),
  ('nang-cap-lich-thu-n-thang.sql','col','lich_chung.tuan_thang'),
  ('nang-cap-loai-phien.sql','func','dat_co_cam_ket'),
  ('nang-cap-loai-viec-co-dinh.sql','col','task.loai_viec'),
  ('nang-cap-luat-nghen.sql','func','kiem_nghen_co_viec_go'),
  ('nang-cap-luong-rieng-tung-nguoi.sql','col','tieu_diem.han'),
  ('nang-cap-mang-du-an.sql','table','cum_trang_thai_task'),
  ('nang-cap-mau-khoi-viec.sql','col','task.mau'),
  ('nang-cap-mau-su-kien.sql','col','lich_chung.mau'),
  ('nang-cap-may-va-nhip-tim.sql','col','phien_deepwork.may_ma'),
  ('nang-cap-moc-cam-ket.sql','col','tieu_diem.moc_id'),
  ('nang-cap-nghi-thuc-hoan-tat.sql','col','nop_ngay.moi_mai'),
  ('nang-cap-nhieu-khoi.sql','col','nguoi.chuc_nang_ids'),
  ('nang-cap-nhom-nhan-lich.sql','col','lich_chung.chuc_nang_ids'),
  ('nang-cap-output-cam-ket.sql','trig','trg_kiem_output_cam_ket'),
  ('nang-cap-phan-cap-nghiem-thu.sql','col','nguoi.leader_id'),
  ('nang-cap-su-kien-ca-nhan.sql','col','lich_chung.nguoi_ids'),
  ('nang-cap-su-kien-nhieu-ngay.sql','col','lich_chung.ca_ngay'),
  ('nang-cap-thong-bao-buoi.sql','table','thong_bao_buoi'),
  ('nang-cap-thoi-luong-du-kien.sql','col','task.thoi_luong_du_kien'),
  ('nang-cap-trao-pic-du-an.sql','col','muc_tieu.pic_moi_luc'),
  ('nang-cap-tu-sua-ho-so.sql','trig','tg_chan_tu_sua_co_cau'),
  ('nang-cap-van-de-giao-sau.sql','func','la_nguoi_cua_khoi'),
  ('nang-cap-van-de-lien-phong.sql','table','van_de'),
  ('nang-cap-viec-cua-buoi.sql','col','task.lich_id'),
  ('nang-cap-xep-cam-ket-co-san.sql','func','xep_cam_ket_vao_du_an'),
  ('schema.sql','table','danh_muc_nhip'),
  ('va-chot-chan-truoc-khi-mo-doi.sql','trig','trg_kiem_phien_dung_chu'),
  ('va-luat-3b.sql','col','task.chot_luc'),
  ('va-luong-cheo-nhau.sql','trig','trg_kiem_task_dung_luong'),
  ('va-luong-don-rut-gon.sql','col','task.so_lan_hoan')
)
select
  case when co then '✅ ĐÃ CHẠY' else '⬜ CHƯA' end as trang_thai,
  tep,
  loai || ' ' || ten                                as dau_vet
from (
  select tep, loai, ten,
    case loai
      when 'table' then exists (select 1 from information_schema.tables
                                 where table_schema='public' and table_name=ten
                                   and table_type='BASE TABLE')
      when 'col'   then exists (select 1 from information_schema.columns
                                 where table_schema='public'
                                   and table_name=split_part(ten,'.',1)
                                   and column_name=split_part(ten,'.',2))
      /* Khung nhìn KHÔNG lọt vào nhánh 'table' ở trên: nhánh ấy đòi
         `table_type='BASE TABLE'`, mà khung nhìn là 'VIEW'. Thiếu nhánh này
         thì một tệp chỉ dựng khung nhìn sẽ mãi báo '⬜ CHƯA' dù đã chạy —
         một dòng ⬜ oan, cùng họ với ❌ oan mà tệp này đã cảnh báo ở trên. */
      when 'view'  then exists (select 1 from information_schema.views
                                 where table_schema='public' and table_name=ten)
      when 'index' then exists (select 1 from pg_indexes
                                 where schemaname='public' and indexname=ten)
      when 'trig'  then exists (select 1 from pg_trigger
                                 where tgname=ten and not tgisinternal)
      when 'func'  then exists (select 1 from pg_proc p
                                 join pg_namespace n on n.oid=p.pronamespace
                                where n.nspname='public' and p.proname=ten)
      when 'view'  then exists (select 1 from information_schema.views
                                 where table_schema='public' and table_name=ten)
    end as co
  from dau_vet
) x
order by co, tep;


-- ─── ② TỆP KHÔNG PHÂN BIỆT ĐƯỢC BẰNG CẤU TRÚC, CỘNG MỘT CÂU HỎI ĐỜI ────────
-- Sáu tệp này chỉ dựng lại KHUNG NHÌN mà tệp khác cũng dựng. Khung nhìn bị
-- `create or replace` viết đè, nên sự tồn tại của nó không nói tệp NÀO đã chạy —
-- chỉ nói "một trong số đó đã chạy".
--
-- Nên ở đây đổi câu hỏi: thay vì "tệp nào chạy rồi", hỏi **"máy chủ có đang
-- mang thứ app cần không"**. Đó mới là câu có ích, và trả lời được.
--
-- ⚠️ Ba dòng đầu phải đọc NỘI DUNG khung nhìn — cách yếu hơn hẳn khối ①. Chúng
-- chỉ tìm số "180" trong định nghĩa, nên một lần đổi cách viết là hỏng phép dò.
-- Đọc kết quả với đúng mức tin cậy ấy.
select 'trần phiên 180 phút — cham_theo_ngay' as thu,
       case when to_regclass('public.cham_theo_ngay') is null then '⬜ khung nhìn chưa có'
            when pg_get_viewdef(to_regclass('public.cham_theo_ngay')) like '%180%'
            then '✅ đang là 180' else '🔴 CÒN 120 — chạy nang-cap-tran-180-phut.sql' end as tra_loi
union all
select 'trần phiên 180 phút — gio_deepwork_theo_ngay',
       case when to_regclass('public.gio_deepwork_theo_ngay') is null then '⬜ khung nhìn chưa có'
            when pg_get_viewdef(to_regclass('public.gio_deepwork_theo_ngay')) like '%180%'
            then '✅ đang là 180' else '🔴 CÒN 120 — chạy nang-cap-tran-180-phut.sql' end
union all
select 'trần phiên 180 phút — vuon_cay',
       case when to_regclass('public.vuon_cay') is null then '⬜ khung nhìn chưa có'
            when pg_get_viewdef(to_regclass('public.vuon_cay')) like '%180%'
            then '✅ đang là 180' else '🔴 CÒN 120 — chạy nang-cap-tran-180-phut.sql' end
union all
select 'ô GIỜ VÀNG có chạy được không (gio_deepwork_theo_gio)',
       case when to_regclass('public.gio_deepwork_theo_gio') is null
            then '🔴 CHƯA CÓ — đây là lý do ô Giờ vàng hiện dấu —. Chạy nang-cap-tran-180-phut.sql (nó chứa sẵn khung nhìn này), KHÔNG cần nang-cap-gio-vang.sql'
            else '✅ có' end
union all
select 'đếm ô ở máy chủ (tien_do_o · dem_task_theo_o)',
       case when to_regclass('public.tien_do_o') is not null
             and to_regclass('public.dem_task_theo_o') is not null
            then '✅ có' else '⬜ thiếu — xem nang-cap-dem-o-may-chu.sql' end
union all
select 'bảng cụm trạng thái task (cum_trang_thai_task)',
       case when to_regclass('public.cum_trang_thai_task') is null
            then '⬜ chưa có — xem nang-cap-mang-du-an.sql' else '✅ có' end
union all
select 'chính sách đọc task sau đợt soi 08/08 (doc_task)',
       case when exists (select 1 from pg_policies
                          where tablename='task' and policyname='doc_task')
            then '✅ có' else '⬜ thiếu — xem va-sau-dot-soi-08-08.sql' end
union all
-- Hỏi theo NỘI DUNG chính sách, không hỏi theo sự tồn tại của nó: `sua_lich` có
-- mặt từ `nang-cap-su-kien-ca-nhan.sql`, nên "có sua_lich" chỉ nói tệp CŨ đã
-- chạy. Thứ đúng MỘT tệp dựng ra là một `sua_lich` KHÔNG còn nhắc `la_lead`.
select 'sự kiện: chỉ host mới sửa được (sua_lich)',
       case when not exists (select 1 from pg_policies
                              where tablename='lich_chung' and policyname='sua_lich')
            then '⬜ chưa có sua_lich — xem nang-cap-su-kien-ca-nhan.sql'
            when exists (select 1 from pg_policies
                          where tablename='lich_chung' and policyname='sua_lich'
                            and (coalesce(qual,'') || coalesce(with_check,'')) like '%la_lead%')
            then '🔴 CÒN MỞ CHO LEAD — chạy nang-cap-quyen-host-su-kien.sql'
            else '✅ chỉ host' end
union all
-- 🔴 Dòng quan trọng nhất khối này: một lỗi ĐANG SỐNG tính tới 01/09. Bảng chọn
-- màu việc mời khoá 'ngoc' còn ràng buộc dựng hôm 29/08 không kê nó, nên sơn
-- Ngọc là máy chủ trả 400 cho CẢ CÂU — mất luôn tên · ngày · giờ vừa sửa trong
-- cùng lượt. Chạy lại `nang-cap-mau-khoi-viec.sql` KHÔNG vá được (nó bọc
-- `if not exists`); phải chạy tệp vá.
select 'màu việc: ràng buộc có nhận ''ngoc'' chưa (task_mau_hop_le)',
       case when not exists (select 1 from pg_constraint where conname='task_mau_hop_le')
            then '⬜ chưa có ràng buộc nào — chạy nang-cap-mau-khoi-viec.sql trước'
            when (select pg_get_constraintdef(oid) from pg_constraint
                   where conname='task_mau_hop_le') like '%ngoc%'
            then '✅ đã vá' else '🔴 CÒN CHẶN — chạy nang-cap-mau-task-them-ngoc.sql' end
union all
-- Một phép hỏi trả lời cho HAI tệp cùng lúc, vì chúng nối đuôi nhau trên đúng
-- một ràng buộc: `nang-cap-co-doi-han-va-trang-thai.sql` dựng nó với 'Confirm',
-- rồi `nang-cap-doi-ten-trang-thai-task.sql` thay 'Confirm' bằng 'Chua_lam'.
select 'tên trạng thái task đang là đời nào (task_trang_thai_hop_le)',
       case when not exists (select 1 from pg_constraint where conname='task_trang_thai_hop_le')
            then '⬜ chưa có — cả hai tệp đều chưa chạy'
            when (select pg_get_constraintdef(oid) from pg_constraint
                   where conname='task_trang_thai_hop_le') like '%Chua_lam%'
            then '✅ đời mới — nang-cap-doi-ten-trang-thai-task.sql đã chạy'
            else '🟡 còn ''Confirm'' — mới chạy nang-cap-co-doi-han-va-trang-thai.sql, còn thiếu nang-cap-doi-ten-trang-thai-task.sql' end
union all
-- Dò bằng thứ ĐÃ MẤT, không phải thứ đã có: tệp này chỉ GỠ trần 7 mốc. Phải
-- soát kèm `cum_trang_thai_task` — nếu cả mảng dự án chưa dựng thì trigger vắng
-- mặt vì chưa ai tạo nó, không phải vì đã gỡ.
select 'trần 7 mốc mỗi dự án đã bỏ chưa (trg_kiem_so_moc)',
       case when to_regclass('public.cum_trang_thai_task') is null
            then '⬜ mảng dự án chưa dựng — chưa hỏi được'
            when exists (select 1 from pg_trigger where tgname='trg_kiem_so_moc' and not tgisinternal)
            then '🔴 CÒN TRẦN — chạy nang-cap-bo-tran-moc.sql'
            else '✅ đã bỏ' end
union all
-- Khung nhìn này do HAI tệp cùng dựng (`nang-cap-cam-ket-ca-doi.sql` mục 1 và
-- `nang-cap-cam-ket-5-cua-ceo.sql` mục 5b), nên nó chỉ nói "một trong hai đã
-- chạy" — đúng giới hạn của cả khối này.
select 'đếm cam kết đã đóng (dem_cam_ket_da_dong)',
       case when to_regclass('public.dem_cam_ket_da_dong') is null
            then '⬜ thiếu — xem nang-cap-cam-ket-ca-doi.sql' else '✅ có' end
union all
-- Cũng hai tệp cùng dựng: `nang-cap-gio-deepwork-theo-loai.sql` đẻ ra khung nhìn
-- này, `nang-cap-loai-phien.sql` `create or replace` lại nó. Dòng này ở khối ①
-- tới 01/09 và đã sáng oan y như ca `chuc_nang`; nay hỏi theo lối khối ②.
select 'giờ deepwork tách theo loại (gio_deepwork_theo_loai)',
       case when to_regclass('public.gio_deepwork_theo_loai') is null
            then '⬜ thiếu — xem nang-cap-gio-deepwork-theo-loai.sql' else '✅ có' end
union all
-- ⚠️ Khung nhìn ấy CÓ từ 28/08, nên dòng trên không còn là câu hỏi thật. Câu hỏi
-- thật: nó đang mang mấy nhánh nhãn. Ba tệp lần lượt `create or replace` nó, mỗi
-- tệp thêm một nguồn — `nhip_id` (gốc) · `co_cam_ket` (nang-cap-loai-phien) ·
-- `viec_co_dinh` (nang-cap-loai-viec-co-dinh). Ai chép lại định nghĩa từ một bản
-- cũ là mất nhánh sau mà KHÔNG lỗi nào bật lên: dải đo vẫn chạy, chỉ là giờ họp
-- định kỳ lặng lẽ rơi về nhóm "phát sinh" như trước. Đây là chỗ bắt được điều đó.
select 'khung nhìn ấy đã có đủ BA nhánh nhãn chưa',
       case when to_regclass('public.gio_deepwork_theo_loai') is null
            then '⬜ chưa có khung nhìn'
            when pg_get_viewdef('public.gio_deepwork_theo_loai'::regclass) not like '%co_cam_ket%'
            then '❌ ĐỜI CŨ NHẤT — thiếu cả co_cam_ket, chạy nang-cap-loai-phien.sql rồi nang-cap-loai-viec-co-dinh.sql'
            when pg_get_viewdef('public.gio_deepwork_theo_loai'::regclass) not like '%viec_co_dinh%'
            then '❌ THIẾU NHÁNH BA — chạy nang-cap-loai-viec-co-dinh.sql'
            else '✅ đủ ba nhánh' end
union all
-- `nang-cap-mang-du-an.sql` được nhắc là phải chạy LẠI, vì nó đổi câu chữ bốn
-- `raise exception`. Sự tồn tại của bảng `cum_trang_thai_task` (khối ①) chỉ nói
-- tệp ấy đã chạy MỘT lần, không nói lần chạy ấy mang câu chữ đời nào — nên phải
-- đọc thân hàm. `nang-cap-bo-tran-moc.sql` cũng `create or replace` chính hàm
-- này và cũng mang câu chữ mới, nên tệp nào chạy sau cũng ra cùng một kết quả.
select 'câu chữ lỗi dự án đã là đời mới chưa (kiem_du_an_du_o)',
       case when not exists (select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
                              where n.nspname='public' and p.proname='kiem_du_an_du_o')
            then '⬜ chưa có hàm — mảng dự án chưa dựng'
            when (select string_agg(prosrc,'') from pg_proc p join pg_namespace n on n.oid=p.pronamespace
                   where n.nspname='public' and p.proname='kiem_du_an_du_o') like '%câu đọc lên hỏi%'
            then '✅ đời mới'
            else '🟡 còn câu chữ cũ — chạy lại nang-cap-mang-du-an.sql (hoặc nang-cap-bo-tran-moc.sql, cũng mang câu mới)' end;


-- ─── ⛔ HAI TỆP KHÔNG ĐƯỢC CHẠY LẠI — chúng LÙI thứ đang chạy ──────────────
-- Không phải "chạy thừa thì thôi". Chạy vào là hỏng, và hỏng LẶNG LẼ: không
-- một câu lỗi nào, app vẫn mở, chỉ là một tính năng âm thầm biến mất.
--
-- ⛔ `nang-cap-mang-du-an.sql`
--    Nó `create or replace function kiem_so_moc()` rồi dựng lại
--    `trg_kiem_so_moc` — tức TRẢ VỀ trần 7 mốc mỗi dự án mà Tracy bảo bỏ hôm
--    01/09 ("vậy thì bỏ trần 7 mốc đi"). Nó còn dựng lại `viec_du_an` và
--    `danh_muc_du_an` ở bản KHÔNG có `moc_hieu_luc`, tức lùi trọn làn GM
--    (giai đoạn · cột mốc · việc đeo mốc).
--    Sổ từng ghi "phải chạy lại vì đổi câu chữ 4 raise exception" — lý do ấy
--    đã tự tiêu: câu chữ mới nằm sẵn trong `nang-cap-bo-tran-moc.sql`, và
--    khối ② ở trên dò được điều đó.
--
-- ⛔ `nang-cap-cho-ban.sql`
--    Nó `drop view if exists cho_ban` rồi dựng bản 46 dòng, đè bản 113 dòng
--    của `nang-cap-trao-pic-du-an.sql` (31/08) — mất `pic_moi`, tức luồng
--    TRAO PIC. Dòng dò ngay dưới canh đúng chỗ ấy.
--
-- Cả hai đã chạy từ lâu (tra máy dò 01/09), nên không có lý do nào phải
-- đụng tới chúng nữa. Để đây là để lần sau ai đọc một cái sổ chép tay cũ rồi
-- định dán cho đủ thì dừng lại kịp.
select '⛔ luồng trao PIC còn sống không (cho_ban.pic_moi)' as thu,
       case when to_regclass('public.cho_ban') is null then '⬜ chưa có khung nhìn'
            when pg_get_viewdef(to_regclass('public.cho_ban')) like '%pic_moi%'
            then '✅ CÒN — tuyệt đối đừng chạy nang-cap-cho-ban.sql'
            else '🟡 không thấy pic_moi — bản cũ đang sống, xem nang-cap-trao-pic-du-an.sql' end as tra_loi
union all
-- VẤN ĐỀ VÀO KHỐI CHỜ BẠN (thêm 05/09). `nang-cap-van-de-cho-ban.sql` không
-- dựng bảng, cột, hàm hay cò nào của riêng nó — nó chỉ nới thân khung nhìn
-- `cho_ban` thêm một nhánh, nên khối ① không có chỗ cho nó. Hỏi theo NHÃN
-- CHUỖI trong thân khung nhìn: chuỗi là thứ Postgres in lại y nguyên, khác
-- hẳn một `check` hay một policy.
select '⑦ vấn đề đã vào khối Chờ bạn chưa (cho_ban van-de)' as thu,
       case when to_regclass('public.cho_ban') is null then '⬜ chưa có khung nhìn'
            when pg_get_viewdef(to_regclass('public.cho_ban')) like '%''van-de''%'
            then '✅ ĐÃ CHẠY'
            else '⬜ CHƯA — chạy nang-cap-van-de-cho-ban.sql' end as tra_loi
union all
-- REALTIME LỊCH (thêm 03/09). `nang-cap-realtime-lich.sql` không dựng bảng, cột,
-- hàm hay trigger nào — nó chỉ kê bốn bảng vào publication `supabase_realtime`,
-- nên khối ① không có chỗ cho nó. Hỏi thẳng danh mục publication.
-- ⚠️ Phép dò này KHÔNG phân biệt được "đã chạy tệp" với "đã bật tay trên
-- Dashboard Supabase" — hai đường cho kết quả y hệt. Với app thì chúng tương
-- đương, nên đó là giới hạn chấp nhận được; chỉ đừng đọc nó thành "tệp đã chạy".
select 'realtime lịch — mấy trên bốn bảng đã kê',
       case when count(*) = 4 then '✅ đủ bốn'
            when count(*) = 0 then '🔴 CHƯA KÊ BẢNG NÀO — chạy nang-cap-realtime-lich.sql'
            else '🟡 mới ' || count(*) || '/4 — chạy nang-cap-realtime-lich.sql (an toàn khi chạy lại)' end
  from pg_publication_tables
 where pubname = 'supabase_realtime'
   and tablename in ('lich_chung','lich_chung_tham_du','lich_chung_ngoai_le','task')
union all
-- REALTIME VẤN ĐỀ (thêm 05/09). Cùng họ với dòng ngay trên và cùng giới hạn:
-- nó dò trạng thái máy chủ, không dò "tệp đã chạy". Tách riêng khỏi dòng lịch
-- vì hai tệp chạy độc lập — gộp chung thành một con số trên sáu là lúc thiếu
-- một bảng thì không biết thiếu bên nào, mà cách chữa hai bên là hai tệp khác.
select 'realtime vấn đề — mấy trên hai bảng đã kê',
       case when count(*) = 2 then '✅ đủ hai'
            when count(*) = 0 then '🔴 CHƯA KÊ BẢNG NÀO — chạy nang-cap-realtime-van-de.sql'
            else '🟡 mới ' || count(*) || '/2 — chạy nang-cap-realtime-van-de.sql (an toàn khi chạy lại)' end
  from pg_publication_tables
 where pubname = 'supabase_realtime'
   and tablename in ('van_de','van_de_binh_luan')
union all
-- THỨ TỰ HAI TỆP ĐÈ NHAU (thêm 03/09). `nang-cap-su-kien-nhieu-ngay.sql` bao
-- trọn `nang-cap-doi-buoi-rieng.sql` và dựng lại ràng buộc `ngoaile_doi_du_tham_so`
-- theo bản BIẾT `so_ngay_moi`. Chạy tệp cũ SAU tệp mới thì cột `so_ngay_moi`
-- vẫn còn — `add column` không bị gỡ — nhưng ràng buộc lùi về bản không biết
-- tới nó. Tức hai cột đều sáng ✅ ở khối ① mà máy chủ vẫn sai: **dò cột không
-- đủ khi thứ tự mới là thứ hỏng được.**
select 'ràng buộc ngoaile_doi_du_tham_so — bản nào đang sống',
       case when not exists (select 1 from pg_constraint
                              where conname = 'ngoaile_doi_du_tham_so')
            then '⬜ chưa có ràng buộc nào tên ấy'
            when (select pg_get_constraintdef(oid) from pg_constraint
                   where conname = 'ngoaile_doi_du_tham_so') like '%so_ngay_moi%'
            then '✅ bản mới — đúng thứ tự'
            else '🔴 BẢN CŨ ĐANG SỐNG — nang-cap-doi-buoi-rieng.sql đã chạy SAU '
                 || 'nang-cap-su-kien-nhieu-ngay.sql. Chạy lại tệp su-kien-nhieu-ngay '
                 || 'để dựng lại ràng buộc, đừng chạy tệp doi-buoi-rieng nữa' end
union all
-- DẤU VẾT BỊ GỠ MẤT (thêm 03/09). `nang-cap-doc-ghi-chu.sql` thêm hai cột vào
-- `tieu_diem`, rồi `nang-cap-doc-rieng-tu.sql` dời chúng sang bảng `doc_cam_ket`
-- và gỡ bản gốc — nên tệp đầu không còn dấu vết nào của riêng nó.
-- Hỏi theo CHUỖI: tệp dời `insert into doc_cam_ket ... select ... from tieu_diem`,
-- tức nó chỉ chạy trôi được khi hai cột kia ĐANG có. Vậy `doc_cam_ket` tồn tại
-- là bằng chứng cả hai tệp đã chạy, theo đúng thứ tự.
select 'ghi chú cam kết (doc_ghi_chu · doc_da_gop) — suy theo chuỗi',
       case when to_regclass('public.doc_cam_ket') is not null
            then '✅ cả nang-cap-doc-ghi-chu.sql và nang-cap-doc-rieng-tu.sql đã chạy'
            when exists (select 1 from information_schema.columns
                          where table_schema='public' and table_name='tieu_diem'
                            and column_name='doc_ghi_chu')
            then '🟡 mới chạy nang-cap-doc-ghi-chu.sql — còn nang-cap-doc-rieng-tu.sql'
            else '🔴 CHƯA CHẠY CÁI NÀO — chạy nang-cap-doc-ghi-chu.sql trước, rồi nang-cap-doc-rieng-tu.sql' end
union all
-- Loại CÁ NHÂN (04/09, TRI-100). Dấu vết là cột `task.rieng_tu` — đã soi bằng
-- `grep -l rieng_tu *.sql` trước khi viết dòng này, và nó ra ĐÚNG một tên tệp,
-- đúng luật dấu vết mà DOC-TRUOC.md dặn.
-- Hỏi tiếp một nấc nữa vì tệp có HAI hàng rào rời nhau: cột và chính sách là
-- hàng rào riêng tư, còn ba khung nhìn là hàng rào "không tính vào bảng đội".
-- Chạy nửa vời thì nửa nào cũng im lặng — nên hỏi tách ra.
select 'loại Cá nhân cho việc và sự kiện (task.rieng_tu)',
       case when not exists (select 1 from information_schema.columns
                              where table_schema='public' and table_name='task'
                                and column_name='rieng_tu')
            then '🔴 CHƯA CHẠY — chạy nang-cap-loai-ca-nhan.sql'
            when (select count(*) from pg_views
                   where schemaname='public'
                     and viewname in ('gio_deepwork_theo_loai','cham_theo_ngay','gat_theo_ngay')
                     and definition like '%rieng_tu%') < 3
            then '🟡 có cột nhưng khung nhìn chưa lọc — chạy lại nang-cap-loai-ca-nhan.sql trọn tệp'
            else '✅ có' end
union all
-- Trường LOẠI SỰ KIỆN (04/09, TRI-102). Dấu vết là ràng buộc
-- `lich_ca_nhan_khong_cam_ket` — đã soi bằng `grep -l` khắp thư mục, ra ĐÚNG
-- một tên tệp. KHÔNG lấy cột `tieu_diem_ma` làm dấu vết: cột trùng tên ấy có
-- trên `task` từ lâu, nên câu hỏi phải nêu cả tên bảng mới đúng — mà một dấu
-- vết cần đọc kỹ mới đúng là một dấu vết chờ ngày bị đọc lướt.
select 'trường Loại sự kiện — buổi gắn vào cam kết (lich_ca_nhan_khong_cam_ket)',
       case when not exists (select 1 from pg_constraint
                              where conname = 'lich_ca_nhan_khong_cam_ket')
            then '🔴 CHƯA CHẠY — chạy nang-cap-loai-su-kien.sql'
            when not exists (select 1 from pg_trigger
                              where not tgisinternal
                                and tgname = 'tg_cham_theo_su_kien_cha')
            then '🟡 có ràng buộc nhưng thiếu cò thừa hưởng — chạy lại trọn tệp'
            else '✅ có' end
union all
-- Sự kiện cá nhân mời được người (04/09, TRI-103). Dấu vết: chính sách
-- `doc_lich` có nhắc `nguoi_ids`. Đây là dấu vết theo NỘI DUNG, không theo sự
-- tồn tại — `doc_lich` có mặt từ `nang-cap-lich-chung.sql`, nên "có doc_lich"
-- chỉ nói tệp cũ đã chạy. Thứ đúng MỘT tệp dựng ra là một `doc_lich` nhắc tới
-- `nguoi_ids`.
select 'sự kiện cá nhân mời được người (doc_lich · nguoi_ids)',
       case when not exists (select 1 from pg_policies
                              where tablename = 'lich_chung' and policyname = 'doc_lich')
            then '🔴 THIẾU HẲN doc_lich — chạy nang-cap-lich-chung.sql trước'
            when (select qual from pg_policies
                   where tablename = 'lich_chung' and policyname = 'doc_lich')
                 not like '%nguoi_ids%'
            then '🔴 CHƯA CHẠY — chạy nang-cap-moi-vao-su-kien-ca-nhan.sql'
            else '✅ có' end
union all
-- Quyền của khách (04/09, TRI-105). Dấu vết: cột `lich_chung.khach_sua`.
select 'quyền của khách như Lịch Google (lich_chung.khach_sua)',
       case when not exists (select 1 from information_schema.columns
                              where table_schema='public' and table_name='lich_chung'
                                and column_name='khach_sua')
            then '🔴 CHƯA CHẠY — chạy nang-cap-quyen-khach.sql'
            when not exists (select 1 from pg_trigger
                              where not tgisinternal
                                and tgname='tg_chan_khach_sua_cot_cam')
            then '🔴 CÓ CỘT NHƯNG THIẾU CÒ — khách sửa được cả cờ riêng tư. Chạy lại trọn tệp'
            else '✅ có' end;


-- ─── ③ BỐN TỆP KHÔNG THUỘC SỔ ──────────────────────────────────────────────
-- Chúng không nâng cấp gì, nên không có "đã chạy hay chưa" — chạy lúc nào cũng
-- được, chạy lại cũng được:
--   · kiem-lai-mang-du-an.sql  — câu hỏi chẩn đoán mảng dự án
--   · seed-danh-muc-nhip.sql   — đổ dữ liệu mồi cho danh mục nhịp
--   · thu-pha-luat-3b.sql      — bài thử, cố tình phá luật 3b để xem có bị chặn
--   · SO-SQL.sql               — chính file này
