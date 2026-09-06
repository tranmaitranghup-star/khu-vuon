-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: chính sách `doc_lich` có nhắc `nguoi_ids`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — SỰ KIỆN CÁ NHÂN MỜI ĐƯỢC NGƯỜI
--                                                  (Tracy chốt 04/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-loai-ca-nhan.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn MSK).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 04/09: *"mặc dù là sự kiện cá nhân nhưng mà cho nút mời người nữa đi"*.
--
-- Sáng nay "cá nhân" được dựng thành CHỈ MÌNH TÔI, và policy `doc_lich` viết
-- đúng theo nghĩa ấy: chỉ người tạo đọc được. Nhưng đời thật không xếp gọn như
-- vậy — một buổi tennis, một bữa với người nhà, một cái hẹn khám: đều là
-- chuyện ngoài công việc, đều không nên tính vào bảng của team, mà vẫn có
-- người thứ hai trong đó.
--
-- ─── NGHĨA MỚI, NÓI THẲNG ───────────────────────────────────────────────────
-- "Cá nhân" từ nay KHÔNG còn nghĩa *chỉ mình tôi*. Nó nghĩa là:
--     · KHÔNG phải chuyện của công ty → không góp số vào bảng nào của team;
--     · CHỈ NGƯỜI TRONG CUỘC nhìn thấy → người tạo, cộng những ai được mời.
-- Người ngoài vẫn không đọc được một chữ nào, kể cả tên buổi. Cái đổi là danh
-- sách "người trong cuộc" nay dài hơn một.
--
-- ⚠️ ĐÂY LÀ MỘT CÚ NỚI QUYỀN, không phải một cú dọn dẹp. Mời một người là cho
--    họ đọc dòng ấy — không có cách nào vừa mời vừa giấu. Ghi ra đây để phiên
--    sau đọc policy không tưởng nó bị lỏng do sơ ý.
--
-- ─── KHÔNG ĐỔI GÌ KHÁC ──────────────────────────────────────────────────────
-- · `rieng_tu` vẫn buộc `pham_vi = 'ca_nhan'` — một buổi riêng không bắn được
--   cho cả công ty hay cho một khối. Ràng buộc `lich_rieng_tu_la_ca_nhan` giữ
--   nguyên, và nó vẫn đúng: người nhận là một danh sách tên, không phải nhóm.
-- · Ba khung nhìn của bảng team vẫn lọc `rieng_tu` — việc riêng của khách mời
--   cũng không lên bảng nào, y như của người tạo.
-- · `doc_task` và `doc_deepwork` KHÔNG đụng tới: việc và phiên là của TỪNG
--   NGƯỜI, không dùng chung. Mời ai vào một buổi không phải là cho họ đọc việc
--   riêng của mình — hai chuyện khác nhau, và gộp là nới nhầm chỗ.
-- ============================================================================

begin;

-- ═══ NỚI ĐÚNG MỘT VẾ CỦA `doc_lich` ════════════════════════════════════════
-- `nguoi_id_dang_nhap() = any(nguoi_ids)` đọc một cột nằm ngay trên chính dòng
-- đang xét, nên không kéo theo phép tra bảng nào — cùng hình dạng với vế
-- `tao_boi` đã có, chỉ khác là so với một MẢNG.
--
-- ⚠️ `any(<mảng>)` chứ không phải `any(<truy vấn con>)`: hai thứ trùng tên mà
--    khác hẳn nhau, và đây là cái bẫy đã cắn hôm 03/09 khi `chuc_nang_ids` đổi
--    sang mảng. Ở đây `nguoi_ids` là `uuid[]`, nên đúng là vế mảng.
drop policy if exists doc_lich on lich_chung;
create policy doc_lich on lich_chung for select
  using (
    la_thanh_vien()
    and (not rieng_tu
         or tao_boi = nguoi_id_dang_nhap()
         or nguoi_id_dang_nhap() = any(nguoi_ids))
  );

comment on policy doc_lich on lich_chung is
  'Cả đội đọc mọi sự kiện — để còn biết khối bên cạnh họp lúc nào mà tránh trùng giờ. Trừ sự kiện loại CÁ NHÂN: chỉ NGƯỜI TRONG CUỘC đọc được, tức người tạo cộng những ai có tên trong nguoi_ids. Nới từ "chỉ người tạo" ngày 04/09 khi Tracy cho sự kiện cá nhân mời được người: mời một người là cho họ đọc dòng ấy, không có cách nào vừa mời vừa giấu.';

-- Hai bảng con soi ngược về dòng cha, nên chúng tự nới theo — không sửa gì.
-- Ghi ra đây để phiên sau khỏi đi tìm: `doc_lich_ngoai` và `doc_lich_td` hỏi
-- `exists (select 1 from lich_chung ...)`, mà câu ấy chạy bằng quyền người gọi.

commit;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select count(*)                                          as su_kien_ca_nhan,
       count(*) filter (where coalesce(array_length(nguoi_ids,1),0) > 1) as co_moi_them_nguoi
  from lich_chung where rieng_tu;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả bốn dòng ═════════════════════════════
-- (mẫu so chỉ chứa TÊN CỘT và tên hàm — Postgres viết hoa từ khoá khi in lại,
--  nên mẫu có từ khoá là ra ❌ oan; bài học 04/09, DOC-TRUOC.md)
select * from (values
  (1, 'doc_lich nay nhắc tới nguoi_ids',
   (select qual from pg_policies
     where tablename = 'lich_chung' and policyname = 'doc_lich') like '%nguoi_ids%'),

  (2, 'và vẫn giữ hai vế cũ — cờ riêng tư và người tạo',
   (select qual from pg_policies
     where tablename = 'lich_chung' and policyname = 'doc_lich')
     like '%rieng_tu%tao_boi%'),

  (3, 'ràng buộc "riêng thì phải là ca_nhan" KHÔNG bị nới theo',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_rieng_tu_la_ca_nhan') like '%ca_nhan%'),

  (4, 'quyền đọc VIỆC và PHIÊN không bị đụng tới',
   (select qual from pg_policies
     where tablename = 'task' and policyname = 'doc_task') like '%rieng_tu%'
   and (select qual from pg_policies
     where tablename = 'phien_deepwork' and policyname = 'doc_deepwork') like '%rieng_tu%'
   and (select qual from pg_policies
     where tablename = 'task' and policyname = 'doc_task') not like '%nguoi_ids%')
) as t(so, muc, dat)
order by dat, so;
