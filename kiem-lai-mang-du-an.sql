-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ KHÔNG THUỘC SỔ — tệp này không nâng cấp gì: câu hỏi chẩn đoán mảng dự án.
-- │ Chạy lúc nào cũng được, chạy lại cũng được.
-- └───────────────────────────────────────────────────────────────────────────
-- CHỈ CHẠY LẠI BỘ TỰ KIỂM của nang-cap-mang-du-an.sql.
-- Nó chỉ ĐỌC rồi báo, không sửa gì trên máy chủ — dán vào SQL Editor của
-- Supabase, bấm Run. Mọi dòng phải xanh.
-- Dòng 4 trước đây đỏ vì chính nó đếm nhầm (đếm ba ràng buộc, trong khi bản
-- chạy thật chỉ có hai — cái thứ ba thuộc cột "làn" Tracy đã bỏ). Đã chữa.

with kt(thu_tu, muc, dat) as (
  values
  (1, 'muc_tieu có đủ 4 cột hồ sơ dự án (loai · trang_thai · mo_ta · link_tai_lieu)',
   (select count(*) from information_schema.columns
     where table_name = 'muc_tieu'
       and column_name in ('loai','trang_thai','mo_ta','link_tai_lieu')) = 4),

  (1.5, 'KHÔNG mọc cột làn và cột "lần này không làm gì" (Tracy bỏ 25/08)',
   not exists (select 1 from information_schema.columns
                where table_name = 'muc_tieu' and column_name in ('lan','khong_lam'))),

  (2, 'muc_tieu có đủ 5 cột nghi thức đóng (cặp số + ba câu nhìn lại)',
   (select count(*) from information_schema.columns
     where table_name = 'muc_tieu'
       and column_name in ('so_ngay_du_kien','so_ngay_thuc_te',
                           'nhin_lai_duoc','nhin_lai_vuong','nhin_lai_lan_sau')) = 5),

  (3, 'muc_tieu KHÔNG mọc thêm cột ngày bắt đầu (ngày bắt đầu phải là SUY RA)',
   not exists (select 1 from information_schema.columns
                where table_name = 'muc_tieu'
                  and column_name in ('ngay_bat_dau','bat_dau','ngay_mo'))),

  -- Sửa 25/08: dòng này từng đếm BA ràng buộc và nói "sáu giá trị trang_thai",
  -- cả hai đều là số của bản nháp. Bản chạy thật chỉ có HAI ràng buộc, vì cái
  -- thứ ba là của cột `lan` mà Tracy đã bỏ hẳn cùng ngày (xem mục 1.5 ngay
  -- trên). Và trang_thai chốt NĂM nấc, không phải sáu. Để nguyên con số cũ thì
  -- dòng này đỏ vĩnh viễn trong khi máy chủ hoàn toàn đúng — một cái chuông
  -- báo cháy kêu khi không có lửa, kêu vài lần là không ai còn nghe nữa.
  (4, 'Ràng buộc ba giá trị của loai và năm nấc trang_thai đang chạy',
   (select count(*) from pg_constraint
     where conrelid = 'muc_tieu'::regclass
       and conname in ('muc_tieu_loai_hop_le','muc_tieu_trang_thai_hop_le')) = 2),

  (5, 'Bảng moc_du_an đã có và đã bật hàng rào RLS',
   to_regclass('public.moc_du_an') is not null
   and (select rowsecurity from pg_tables where schemaname='public' and tablename='moc_du_an')),

  (6, 'moc_du_an có đủ 4 policy (doc/them/sua/xoa)',
   (select count(*) from pg_policies where tablename = 'moc_du_an'
      and policyname in ('doc_moc','them_moc','sua_moc','xoa_moc')) = 4),

  (7, 'moc_du_an chép đủ bộ ba đếm dời hạn CỘNG cột lý do dời',
   (select count(*) from information_schema.columns
     where table_name = 'moc_du_an'
       and column_name in ('han_goc','so_lan_doi_han','ngay_troi','ly_do_doi')) = 4),

  -- Trần bảy mốc đã gỡ 01/09 (`nang-cap-bo-tran-moc.sql`), nên câu này nay chỉ
  -- đòi trigger dời mốc, và đòi thêm rằng trigger trần KHÔNG còn nữa.
  (8, 'Trigger dời mốc còn cắm trên moc_du_an, trigger trần bảy mốc đã gỡ',
   (select count(*) from pg_trigger
     where tgrelid = 'moc_du_an'::regclass and not tgisinternal
       and tgname = 'tg_doi_moc') = 1
   and (select count(*) from pg_trigger
     where tgrelid = 'moc_du_an'::regclass and not tgisinternal
       and tgname = 'trg_kiem_so_moc') = 0),

  (9, 'task có cột muc_tieu_id, kèm chỉ mục',
   exists (select 1 from information_schema.columns
            where table_name='task' and column_name='muc_tieu_id')
   and exists (select 1 from pg_indexes where tablename='task' and indexname='task_theo_muctieu')),

  (10, 'Khoá ngoại task.muc_tieu_id là ON DELETE SET NULL (xoá dự án không kéo theo việc)',
   exists (select 1 from pg_constraint
            where conrelid = 'task'::regclass and contype='f' and confdeltype='n'
              and conkey = (select array[attnum] from pg_attribute
                             where attrelid='task'::regclass and attname='muc_tieu_id'))),

  (11, 'Trigger tự điền dự án cho task đang chạy',
   exists (select 1 from pg_trigger where tgname='trg_tu_dien_du_an_cho_task'
             and tgrelid='task'::regclass and not tgisinternal)),

  (12, 'Trigger lan toả khi cam kết đổi dự án đang chạy',
   exists (select 1 from pg_trigger where tgname='trg_lan_toa_du_an_xuong_task'
             and tgrelid='tieu_diem'::regclass and not tgisinternal)),

  (13, 'Không còn task nào lệch dự án so với cam kết nó bám vào',
   not exists (select 1 from task t join tieu_diem o on o.ma = t.tieu_diem_ma
                where o.muc_tieu_id is not null
                  and t.muc_tieu_id is distinct from o.muc_tieu_id)),

  (14, 'Bảng tra cụm trạng thái có đủ 7 dòng, gom về đúng 3 cụm',
   (select count(*) from cum_trang_thai_task) = 7
   and (select count(distinct cum) from cum_trang_thai_task) = 3),

  (15, 'Bảy trạng thái trong bảng tra KHỚP đúng ràng buộc task_trang_thai_hop_le',
   not exists (select 1 from cum_trang_thai_task c
                where c.trang_thai not in
                  ('Confirm','Doing','Done','Chua_xong','Blocked','Da_chuyen','Da_huy'))),

  (16, 'Chỉ đúng MỘT trạng thái mang cờ tính-là-xong (Done)',
   (select count(*) from cum_trang_thai_task where tinh_la_xong) = 1
   and (select tinh_la_xong from cum_trang_thai_task where trang_thai='Done')),

  (17, 'Việc đã huỷ và đã chuyển KHÔNG nằm trong mẫu số',
   (select count(*) from cum_trang_thai_task
     where trang_thai in ('Da_huy','Da_chuyen') and not con_tren_ban) = 2),

  (17.5, 'Tầng THÀNH VIÊN đủ ba lớp: bảng · hàm hỏi · trigger chặn CẢ HAI cửa',
   to_regclass('public.thanh_vien_du_an') is not null
   and exists (select 1 from pg_proc where proname = 'la_thanh_vien_du_an')
   and exists (select 1 from pg_trigger where tgname = 'trg_kiem_thanh_vien_cam_ket'
                 and tgrelid = 'tieu_diem'::regclass and not tgisinternal)
   and exists (select 1 from pg_trigger where tgname = 'trg_tu_dien_du_an_cho_task'
                 and tgrelid = 'task'::regclass and not tgisinternal)),

  (17.6, 'PIC luôn có tên trong danh sách thành viên của chính mình',
   not exists (select 1 from muc_tieu m
                where m.loai = 'du-an'
                  and not exists (select 1 from thanh_vien_du_an v
                                   where v.muc_tieu_id = m.id and v.nguoi_id = m.nguoi_id))),

  (17.7, 'Không cam kết nào đang trỏ về dự án mà chủ nó chưa được mời',
   not exists (select 1 from tieu_diem o
                where o.muc_tieu_id is not null
                  and not la_thanh_vien_du_an(o.muc_tieu_id, o.nguoi_id))),

  (18, 'Trần danh mục đủ ba lớp: con số · chỉ mục · trigger',
   to_regclass('public.tran_danh_muc') is not null
   and exists (select 1 from information_schema.columns
                where table_name='nguoi' and column_name='so_du_an_toi_da')
   and exists (select 1 from pg_indexes where tablename='muc_tieu' and indexname='du_an_dang_chay')
   and exists (select 1 from pg_trigger where tgname='trg_kiem_tran_danh_muc'
                 and tgrelid='muc_tieu'::regclass and not tgisinternal)),

  (19, 'Trigger trần danh mục chạy bằng quyền định nghĩa (security definer)',
   (select prosecdef from pg_proc where proname='kiem_tran_danh_muc')),

  (20, 'Trần tổng toàn công ty có mặt và là một con số',
   (select so_suat from tran_danh_muc where khoa = 'tong') is not null),

  (21, 'Khung nhìn danh_muc_du_an và viec_du_an đã có, cùng chạy security_invoker',
   (select count(*) from pg_class
     where relkind='v' and relname in ('danh_muc_du_an','viec_du_an')
       and 'security_invoker=on' = any(coalesce(reloptions,'{}'))) = 2),

  (22, 'danh_muc_du_an mang đủ bốn ô bắt buộc cộng chín ô máy tính',
   (select count(*) from information_schema.columns
     where table_name='danh_muc_du_an'
       and column_name in ('ten','nguoi_id','ket_qua','han',
                           'so_cam_ket','so_nguoi_ganh','nguoi_ganh','so_viec','viec_xong',
                           'tong_phut','ngay_bat_dau','moc_ke_tiep_ngay','co_nhip_tuan')) = 13),

  (23, 'Hai khung nhìn máy tính đều CHẶN GHI, trả lỗi thật',
   (select count(*) from pg_trigger
     where tgname in ('trg_chan_ghi_danh_muc_du_an','trg_chan_ghi_viec_du_an')
       and not tgisinternal) = 2),

  (24, 'tien_do_o đã mang cột muc_tieu_id',
   exists (select 1 from information_schema.columns
            where table_name='tien_do_o' and column_name='muc_tieu_id')),

  (25, 'tien_do_o KHÔNG mất cột nào của bản cũ (28 cột cũ + 1 cột mới = 29)',
   (select count(*) from information_schema.columns
     where table_name='tien_do_o'
       and column_name in ('ma','nguoi_id','ten','luong','qua','mau','ten_loai',
         'tieu_chi_xong','han','xong','ngay_gieo','ngay_xong','nguoi_tick','bo_the',
         'output_chu','output_link','nop_luc','da_nhan_boi','da_nhan_luc',
         'han_goc','so_lan_doi_han','ngay_troi','cay_co_qua','cay_dang_lon',
         'tong_phut','so_task','so_xong','so_kho','muc_tieu_id')) = 29),

  (26, 'tien_do_o vẫn chạy security_invoker — không vượt mặt RLS',
   (select 'security_invoker=on' = any(coalesce(reloptions,'{}'))
      from pg_class where relname='tien_do_o')),

  (27, 'NĂM hàng rào tầng cam kết vẫn nguyên vẹn, file này không gỡ cái nào',
   (select count(*) from pg_trigger
     where tgrelid='tieu_diem'::regclass and not tgisinternal
       and tgname in ('trg_kiem_tran_cam_ket','tg_doi_han','trg_kiem_o_xong',
                      'trg_kiem_output_cam_ket','trg_kiem_muc_tieu_con_mo')) = 5),

  (28, 'Chỉ mục một-hạt-sống-mỗi-luống vẫn còn',
   exists (select 1 from pg_indexes where tablename='tieu_diem'
             and indexname='mot_hat_song_moi_luong')),

  (29, 'Chính sách ghi_task VẪN chặn cứng — file này không nới quyền giao việc',
   exists (select 1 from pg_policies where tablename='task' and policyname='ghi_task')),

  (30, 'KHÔNG có bảng việc thứ hai nào mọc ra',
   to_regclass('public.task_du_an') is null and to_regclass('public.viec_du_an_bang') is null),

  (31, 'Cờ xong của muc_tieu khớp trang_thai ở mọi dòng (một sự thật, không hai)',
   not exists (select 1 from muc_tieu
                where xong <> (trang_thai in ('hoan-thanh','huy'))))
)
select thu_tu,
       case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua,
       muc
from kt order by thu_tu;
