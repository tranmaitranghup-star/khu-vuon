-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: chính sách `sua_lich` trên bảng `lich_chung`
-- │ CÓ chứa chuỗi 'la_quan_tri_dang_nhap'.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — QUẢN TRỊ SỬA ĐƯỢC MỌI SỰ KIỆN
--                                                  (Tracy chốt 07/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-quyen-khach.sql` — tệp này nối thêm một vế vào
--            chính sách mà tệp ấy vừa dựng, nên chạy trước là dựng lên khoảng
--            không. Có một câu chặn ngay đầu, không cần nhớ thứ tự.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn QS).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 07/09: *"cho Tracy và Andy quyền chỉnh sửa toàn bộ sự kiện dù không
-- phải mình host"*.
--
-- ─── ĐI THEO CỘT, KHÔNG ĐI THEO TÊN ─────────────────────────────────────────
-- Quyền neo vào `nguoi.la_quan_tri` — cột đang bật đúng hai người ấy — chứ
-- không khai hai cái tên vào chính sách. Đổi người thì đổi dữ liệu, mã không
-- phải sửa. Cùng cách làn VQ đã làm hôm 06/09 cho nấc của Vấn đề.
--
-- ─── ĐÂY KHÔNG PHẢI MỞ LẠI CỬA CHO LEAD ─────────────────────────────────────
-- Đọc lướt thì việc này giống hệt thứ `nang-cap-quyen-host-su-kien.sql` đóng
-- lại hôm 04/09, và giống thứ `nang-cap-quyen-khach.sql` phải sửa hồi quy sáng
-- 07/09. Không phải. Cửa bị đóng hai lần ấy là vế `la_lead()`, mà cả bảy người
-- trong đội đều đang bật cờ lead — nên nó đọc ra *ai cũng sửa được lịch của
-- ai*. Vế mở ở đây là `la_quan_tri`, đúng HAI người. Chính Tracy phân biệt hai
-- vế ấy trong cùng một ngày: sáng 07/09 *"Lead không sửa được mọi sự kiện trên
-- lịch chung"*, chiều 07/09 *"cho Tracy và Andy quyền"*.
-- ⛔ Tệp sau đừng gộp hai vế làm một. `la_lead()` KHÔNG được quay lại ba chính
--    sách dưới đây; bộ tự kiểm cuối tệp canh đúng điều đó.
--
-- ─── SỰ KIỆN CÁ NHÂN NẰM NGOÀI ──────────────────────────────────────────────
-- Mọi vế quản trị dưới đây đều kèm `not rieng_tu`. Lý do không phải sự thận
-- trọng chung chung mà là một mâu thuẫn cụ thể: chính sách `doc_lich` không cho
-- quản trị ĐỌC sự kiện loại cá nhân của người khác (chỉ người tạo và người được
-- mời đọc được, xem `nang-cap-moi-vao-su-kien-ca-nhan.sql`). Cho quyền sửa một
-- thứ mình không nhìn thấy là dựng một cánh cửa mở ra bức tường.
--
-- ─── HAI CỘT VẪN NẰM NGOÀI TẦM, VÀ ĐÓ LÀ CÒ CŨ LO ───────────────────────────
-- Cò `tg_chan_khach_sua_cot_cam` (dựng ở `nang-cap-quyen-khach.sql`) chạy cho
-- MỌI lượt update trên `lich_chung`, không riêng lượt của khách: ai không phải
-- `tao_boi` thì `rieng_tu` và `tao_boi` bị kéo về giá trị cũ trước khi ghi. Nên
-- quản trị sửa được tên, giờ, địa điểm, mọi thứ — mà KHÔNG:
--     · chiếm được quyền host (`tao_boi` giữ nguyên);
--     · hạ được cờ riêng tư của một buổi (`rieng_tu` giữ nguyên).
-- Tệp này KHÔNG đụng vào cò ấy. Ghi ra đây vì đó là câu trả lời cho câu hỏi
-- *"quản trị có sang tên được sự kiện không"* — không, và không cần thêm rào.
--
-- ─── BỐN CỬA, KHÔNG PHẢI MỘT ────────────────────────────────────────────────
-- Trong app, "sửa một sự kiện" là bốn đường ghi khác nhau tới ba bảng:
--     sua_lich        nút ✏️ — sửa hoặc ngưng cả chuỗi
--     xoa_lich        nút 🗑 — xoá
--     ghi_lich_ngoai  cú KÉO một khối sang chỗ khác trên lưới, và cú huỷ một
--                     buổi lẻ — ghi vào `lich_chung_ngoai_le`, không ghi vào
--                     `lich_chung`
--     ghi_tb_buoi     hai ô "Thông tin trước / sau sự kiện" của từng buổi
-- Siết ba cửa mà bỏ cửa thứ ba thì người ta vẫn dời được buổi họp của người
-- khác, chỉ là bằng đường khác — đúng lý lẽ `nang-cap-quyen-host-su-kien.sql`
-- đã ghi hôm 04/09, nay đọc ngược lại cho chiều nới.
--
-- ⚠️ `ghi_tb_buoi` là chỗ đảo một quyết định cũ, ghi rõ để không ai tưởng sót.
-- Ngày 01/09 tệp `nang-cap-thong-bao-buoi.sql` cố ý KHÔNG cho lead viết hai ô
-- ấy, lý lẽ là *"viết biên bản nhân danh người chủ trì thì không"*. Lý lẽ ấy
-- vẫn đúng với lead. Với quản trị thì Tracy chốt "toàn bộ sự kiện", và để nó
-- lại thì app rơi vào cảnh tệ hơn cả hai: nút hiện ra vì màn hình hỏi
-- `lcDuocSua`, bấm vào thì máy chủ chối.
-- ============================================================================

-- ═══ 0. CHẶN CHẠY SAI THỨ TỰ ═══════════════════════════════════════════════
-- Dừng ngay và nói ra, thay vì dựng một chính sách thiếu vế khách rồi lặng lẽ
-- lấy mất quyền mà `nang-cap-quyen-khach.sql` vừa trao.
do $$
begin
  if not exists (select 1 from information_schema.columns
                  where table_name = 'lich_chung' and column_name = 'khach_sua')
  then
    raise exception 'Chua chay nang-cap-quyen-khach.sql — chay tep ay truoc.';
  end if;
end $$;


begin;

-- ═══ 1. SỬA VÀ NGƯNG MỘT CHUỖI ═════════════════════════════════════════════
-- Ba vế, đọc từ hẹp ra rộng: chủ sự kiện · quản trị · khách được host cấp
-- quyền. Vế khách chép nguyên từ `nang-cap-quyen-khach.sql` (07/09) — nó vẫn
-- đòi CẢ HAI: cờ bật, và có tên trong danh sách mời.
drop policy if exists sua_lich on lich_chung;
create policy sua_lich on lich_chung for update
  using      (tao_boi = nguoi_id_dang_nhap()
              or (la_quan_tri_dang_nhap() and not rieng_tu)
              or (khach_sua and nguoi_id_dang_nhap() = any(nguoi_ids)))
  with check (tao_boi = nguoi_id_dang_nhap()
              or (la_quan_tri_dang_nhap() and not rieng_tu)
              or (khach_sua and nguoi_id_dang_nhap() = any(nguoi_ids)));

comment on policy sua_lich on lich_chung is
  'Sửa một sự kiện: chủ sự kiện (host), hoặc quản trị với mọi sự kiện trừ loại cá nhân, hoặc khách mời khi host đã bật khach_sua. Lead không có cửa nào ở đây. Cò tg_chan_khach_sua_cot_cam giữ rieng_tu và tao_boi khỏi tay mọi người trừ host, nên quản trị sửa được nội dung mà không sang tên được sự kiện.';

-- ═══ 2. XOÁ MỘT CHUỖI ══════════════════════════════════════════════════════
-- ⚠️ Khác `sua_lich` ở chỗ KHÔNG có vế khách — Lịch Google cũng vậy, và
--    `nang-cap-quyen-khach.sql` ghi rõ đó là chủ ý chứ không phải chỗ sót.
--    Quản trị thì có: "toàn bộ sự kiện" gồm cả huỷ một sự kiện đặt nhầm.
drop policy if exists xoa_lich on lich_chung;
create policy xoa_lich on lich_chung for delete
  using (tao_boi = nguoi_id_dang_nhap()
         or (la_quan_tri_dang_nhap() and not rieng_tu));

comment on policy xoa_lich on lich_chung is
  'Xoá một sự kiện: chủ sự kiện, hoặc quản trị với mọi sự kiện trừ loại cá nhân. Khách được cấp quyền sửa vẫn KHÔNG xoá được — chủ ý, chép theo Lịch Google.';

-- ═══ 3. DỜI HOẶC HUỶ MỘT BUỔI LẺ ═══════════════════════════════════════════
-- Giữ nguyên cách soi ngược của bản cũ: quyền ở đây đọc từ dòng cha. Chép lại
-- luật thay vì gọi lại là để hai chỗ có ngày trôi khác nhau — nhưng nhớ rằng
-- chúng PHẢI khớp: lệch nhau thì nút kéo có mà cú thả bị chối.
drop policy if exists ghi_lich_ngoai on lich_chung_ngoai_le;
create policy ghi_lich_ngoai on lich_chung_ngoai_le for all
  using (exists (select 1 from lich_chung l
                  where l.id = lich_chung_ngoai_le.lich_id
                    and (l.tao_boi = nguoi_id_dang_nhap()
                         or (la_quan_tri_dang_nhap() and not l.rieng_tu))))
  with check (exists (select 1 from lich_chung l
                       where l.id = lich_chung_ngoai_le.lich_id
                         and (l.tao_boi = nguoi_id_dang_nhap()
                              or (la_quan_tri_dang_nhap() and not l.rieng_tu))));

-- ═══ 4. HAI Ô THÔNG TIN TRƯỚC / SAU SỰ KIỆN ════════════════════════════════
-- Vế `tao_boi = nguoi_id_dang_nhap()` trong `with check` nói về `tao_boi` của
-- BẢNG NÀY — người viết dòng ghi chú, không phải host của sự kiện. Nó ở lại
-- nguyên vẹn: quản trị viết thì dòng mang tên quản trị, đúng thứ đã xảy ra.
drop policy if exists ghi_tb_buoi on thong_bao_buoi;
create policy ghi_tb_buoi on thong_bao_buoi for all
  using (exists (
    select 1 from lich_chung l
     where l.id = thong_bao_buoi.lich_id
       and (l.tao_boi = nguoi_id_dang_nhap()
            or (la_quan_tri_dang_nhap() and not l.rieng_tu))))
  with check (
    tao_boi = nguoi_id_dang_nhap()
    and exists (
      select 1 from lich_chung l
       where l.id = thong_bao_buoi.lich_id
         and (l.tao_boi = nguoi_id_dang_nhap()
              or (la_quan_tri_dang_nhap() and not l.rieng_tu))));

comment on policy ghi_tb_buoi on thong_bao_buoi is
  'Viết hai ô thông tin của một buổi: host của sự kiện, hoặc quản trị trừ sự kiện loại cá nhân (Tracy chốt 07/09). Lead vẫn không có cửa — lý lẽ 01/09 giữ nguyên với lead.';

commit;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select (select count(*) from nguoi where la_quan_tri and ngay_nghi is null)
                                                       as nguoi_dang_la_quan_tri,
       (select count(*) from lich_chung)               as tong_su_kien,
       (select count(*) from lich_chung where rieng_tu) as su_kien_ca_nhan_ngoai_tam,
       (select count(*) from lich_chung where khach_sua) as cho_khach_sua;

select ho_ten, email from nguoi where la_quan_tri order by ho_ten;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả mười dòng ════════════════════════════
-- Dòng chưa đạt nổi lên đầu.
with p as (select tablename, policyname, qual, with_check from pg_policies)
select * from (values
  (1, 'sua_lich mở cho quản trị',
   (select qual from p where tablename='lich_chung' and policyname='sua_lich')
     like '%la_quan_tri_dang_nhap%'),
  (2, 'sua_lich giữ nguyên vế khách',
   (select qual from p where tablename='lich_chung' and policyname='sua_lich')
     like '%khach_sua%'),
  (3, 'sua_lich vẫn không có vế lead',
   (select qual from p where tablename='lich_chung' and policyname='sua_lich')
     not like '%la_lead%'),
  (4, 'sua_lich chừa sự kiện cá nhân ra',
   (select qual from p where tablename='lich_chung' and policyname='sua_lich')
     like '%rieng_tu%'),
  (5, 'sua_lich gác cả vế sau khi ghi',
   (select with_check from p where tablename='lich_chung' and policyname='sua_lich')
     like '%la_quan_tri_dang_nhap%'),
  (6, 'xoa_lich mở cho quản trị, chừa sự kiện cá nhân',
   (select qual from p where tablename='lich_chung' and policyname='xoa_lich')
     like '%la_quan_tri_dang_nhap%'
   and (select qual from p where tablename='lich_chung' and policyname='xoa_lich')
     like '%rieng_tu%'),
  (7, 'xoa_lich vẫn đóng với khách',
   (select qual from p where tablename='lich_chung' and policyname='xoa_lich')
     not like '%khach_sua%'),
  (8, 'ghi_lich_ngoai mở cho quản trị — cú kéo trên lưới',
   (select qual from p where tablename='lich_chung_ngoai_le' and policyname='ghi_lich_ngoai')
     like '%la_quan_tri_dang_nhap%'),
  (9, 'ghi_tb_buoi mở cho quản trị — hai ô thông tin buổi',
   (select qual from p where tablename='thong_bao_buoi' and policyname='ghi_tb_buoi')
     like '%la_quan_tri_dang_nhap%'),
  (10, 'cò giữ tao_boi và rieng_tu còn nguyên',
   exists (select 1 from pg_trigger
            where not tgisinternal and tgname = 'tg_chan_khach_sua_cot_cam'))
) as t(so, muc, dat)
order by dat, so;
