-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `la_nguoi_cua_khoi`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — VẤN ĐỀ: LEAD GIAO SAU, VÀ BỐN NHÓM SỬA ĐƯỢC
--                                        (Tracy chốt 05/09/2026 — TRI-112)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- CHẠY SAU: `nang-cap-van-de-lien-phong.sql`.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 05/09: *"chỗ giao cho ai tôi đang nghĩ là lead tự giao chứ nhỉ, người
-- ghi vấn đề có thể chưa biết giao cho ai đâu"* · *"ô giao cho ai thì cho quyền
-- phòng ban xử lý, phòng ghi vấn đề, vận hành và điều hành được quyền edit"*.
--
-- ─── CHỖ NÀY VA VÀO MỘT LUẬT ĐÃ VIẾT, VÀ CÁCH GỠ ────────────────────────────
-- Điều 1 luật chuyển giao (`wiki/cong-ty/rova/van-de-lien-phong.md` mục 3) nói:
-- *"Người nhận có tên. Giao cho phòng vận hành là giao cho không ai."* Để cột
-- trống thì đúng là rơi vào chính cái bẫy ấy — một vấn đề không thuộc về ai.
--
-- Gỡ bằng cách giữ cả hai: cột trống KHÔNG có nghĩa "chưa ai chịu trách nhiệm",
-- mà có nghĩa **người chịu trách nhiệm là LEAD của phòng xử lý**. Đồng hồ 24 giờ
-- chạy vào họ y như chạy vào một người có tên. Vẫn có tên — chỉ là máy suy ra,
-- thay vì bắt người đang bực phải biết cơ cấu phòng bạn trước khi kể được việc.
--
-- ─── VÌ SAO PHẢI CÓ HÀM MỚI ─────────────────────────────────────────────────
-- Máy chủ chưa có hàm nào hỏi "người đang đăng nhập có thuộc khối X không".
-- Và `nguoi.chuc_nang_ids` là một MẢNG từ 03/09, nên phép hỏi là `= any(...)`,
-- không phải `=`. Đây là mảnh nhỏ nhất của TRI-27 mà lớp vấn đề thật sự cần;
-- phần lọc khách theo phòng vẫn để nguyên cho lúc CRM nối thật.
-- ============================================================================

begin;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. NỚI CỘT — chưa giao đích danh cũng ghi được
-- ════════════════════════════════════════════════════════════════════════════
alter table van_de alter column nguoi_nhan_id drop not null;

comment on column van_de.nguoi_nhan_id is
  'Người nhận đích danh. ĐỂ TRỐNG ĐƯỢC kể từ 05/09 (Tracy: "lead tự giao chứ '
  'nhỉ, người ghi vấn đề có thể chưa biết giao cho ai đâu"). Trống KHÔNG có '
  'nghĩa là không ai chịu trách nhiệm — nó có nghĩa người chịu trách nhiệm là '
  'LEAD của `chuc_nang_nhan`, và đồng hồ 24 giờ chạy vào họ y như chạy vào một '
  'người có tên. Đây là cách giữ được điều 1 luật chuyển giao mà vẫn không bắt '
  'người đang bực phải biết cơ cấu phòng bạn trước khi kể được việc.';

-- ════════════════════════════════════════════════════════════════════════════
-- 2. HÀM HỎI KHỐI — mảnh nhỏ nhất của TRI-27 mà lớp vấn đề cần
-- ════════════════════════════════════════════════════════════════════════════
-- `security definer` vì nó đọc bảng `nguoi`, mà policy của bảng ấy lại là thứ
-- gọi nó — không tách quyền ra thì thành vòng.
create or replace function la_nguoi_cua_khoi(k smallint)
returns boolean language sql stable security definer
set search_path = public
as $$
  select k is not null
     and exists (select 1 from nguoi
                  where email = email_dang_nhap()
                    and ngay_nghi is null
                    and k = any(chuc_nang_ids));
$$;

comment on function la_nguoi_cua_khoi(smallint) is
  'Người đang đăng nhập có ngồi trong khối chức năng k không. `= any(...)` chứ '
  'không `=`: từ 03/09 một người thuộc NHIỀU phòng và `chuc_nang_ids` là mảng. '
  'Người đã nghỉ trả về false, cùng luật với `la_thanh_vien()`.';

-- Khối Vận hành tra theo TÊN, không ghim số 2: id do `identity` sinh ra nên
-- một máy chủ dựng lại từ đầu có thể đánh số khác.
create or replace function la_nguoi_van_hanh()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from nguoi n
                  where n.email = email_dang_nhap()
                    and n.ngay_nghi is null
                    and exists (select 1 from chuc_nang c
                                 where c.ten = 'Vận hành'
                                   and c.id = any(n.chuc_nang_ids)));
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- 3. POLICY SỬA — bốn nhóm Tracy kê, cộng hai người trong cuộc
-- ════════════════════════════════════════════════════════════════════════════
drop policy if exists sua_van_de on van_de;

/* Bốn nhóm Tracy kê 05/09: phòng XỬ LÝ · phòng GHI vấn đề · Vận hành · điều
   hành. Cộng hai người trong cuộc (người nêu và người đã được giao đích danh),
   vì họ vẫn phải thao tác được trên chính dòng của mình.
   `with check` lặp lại y hệt: thiếu nó thì một người sửa được một dòng có thể
   ĐẨY nó sang hai phòng khác rồi tự đưa mình ra ngoài tầm với của policy. */
create policy sua_van_de on van_de for update
  using      (nguoi_neu_id  = nguoi_id_dang_nhap()
           or nguoi_nhan_id = nguoi_id_dang_nhap()
           or la_nguoi_cua_khoi(chuc_nang_nhan)
           or la_nguoi_cua_khoi(chuc_nang_neu)
           or la_nguoi_van_hanh()
           or la_dieu_hanh()
           or la_quan_tri_dang_nhap())
  with check (nguoi_neu_id  = nguoi_id_dang_nhap()
           or nguoi_nhan_id = nguoi_id_dang_nhap()
           or la_nguoi_cua_khoi(chuc_nang_nhan)
           or la_nguoi_cua_khoi(chuc_nang_neu)
           or la_nguoi_van_hanh()
           or la_dieu_hanh()
           or la_quan_tri_dang_nhap());

commit;

-- ════════════════════════════════════════════════════════════════════════════
-- SỐ LIỆU THAM KHẢO — không có đúng/sai
-- ════════════════════════════════════════════════════════════════════════════
select
  (select count(*) from van_de)                          as van_de_dang_co,
  (select count(*) from van_de where nguoi_nhan_id is null) as chua_giao_dich_danh,
  (select count(*) from nguoi
     where ngay_nghi is null and la_lead)                as so_lead,
  (select count(*) from chuc_nang where ten = 'Vận hành') as co_khoi_van_hanh;

-- ════════════════════════════════════════════════════════════════════════════
-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ════════════════════════════
-- ════════════════════════════════════════════════════════════════════════════
-- Đặt CUỐI tệp vì trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh
-- cuối cùng. `order by dat, so` đẩy dòng chưa đạt lên đầu.
select * from (values

  (1, 'nguoi_nhan_id nay để trống được',
   (select is_nullable = 'YES' from information_schema.columns
     where table_schema = 'public' and table_name = 'van_de'
       and column_name = 'nguoi_nhan_id')),

  (2, 'hai hàm hỏi khối đã dựng',
   (select count(*) from pg_proc
     where proname in ('la_nguoi_cua_khoi','la_nguoi_van_hanh')) = 2),

  (3, 'cả hai chạy bằng quyền định nghĩa — không thì policy gọi nó thành vòng',
   (select bool_and(prosecdef) from pg_proc
     where proname in ('la_nguoi_cua_khoi','la_nguoi_van_hanh'))),

  (4, 'policy sửa vẫn còn đúng MỘT bản, không đẻ ra bản thứ hai',
   (select count(*) from pg_policies
     where tablename = 'van_de' and policyname = 'sua_van_de') = 1),

  (5, 'policy sửa có cả vế using lẫn vế with check',
   (select qual is not null and with_check is not null from pg_policies
     where tablename = 'van_de' and policyname = 'sua_van_de')),

  /* Dòng này canh một thứ KHÔNG CÓ, y như dòng 8 của tệp nhát 1: nới quyền sửa
     không được kéo theo một đường xoá. */
  (6, 'vẫn không có policy xoá nào trên van_de',
   (select count(*) from pg_policies
     where tablename = 'van_de' and cmd = 'DELETE') = 0)

) as t(so, muc, dat)
order by dat, so;
