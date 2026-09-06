-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.ngay_nghi`, và cò `chan_tu_go_quyen`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — MÀN TEAM: cơ cấu tổ chức, nhân sự và quyền
--                                        (Tracy duyệt 05/09/2026 — TRI-124)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 05/09: *"phòng kinh doanh của ROVA thời gian tới có thêm tôi và Andy
-- nữa, và nhân sự thì sẽ có thể thường xuyên thay đổi nên tôi muốn trên app có
-- tính năng sắp xếp cơ cấu tổ chức, dành cho tôi và Andy"* — đổi tên nhân sự ·
-- thêm tài khoản · đặt phòng ban và quyền hạn. Bổ sung cùng ngày: họ và tên ·
-- tên hiển thị · ngày sinh · số điện thoại, và *"cả team xem được"*.
--
-- ─── VÌ SAO TỆP NÀY PHẢI CÓ TRƯỚC MÃ ────────────────────────────────────────
-- Bảng `nguoi` từ ngày dựng tới nay có ĐÚNG MỘT policy, và là policy ĐỌC
-- (`doc_nguoi`, schema.sql). Chưa từng có một đường ghi nào — mọi thay đổi
-- nhân sự đều làm tay trong Supabase. Nên không phải "nới quyền", mà là **mở
-- một cửa chưa từng có**, và cửa ấy phải có bản lề trước khi có cánh.
--
-- ─── BỐN HÀNG RÀO, VÀ VÌ SAO GIAO DIỆN KHÔNG LÀM ĐƯỢC CÁI NÀO ───────────────
--   ① Chỉ quản trị ghi được          → policy `them_nguoi` · `sua_nguoi`
--   ② Không tự gỡ quyền của chính mình → cò `chan_tu_go_quyen`
--   ③ Không để team trống quản trị     → cò `chan_trong_quan_tri`
--   ④ Không ai xoá được một dòng người → CỐ Ý không có policy `delete`
-- Giấu một cái nút trong trình duyệt không phải là phân quyền: bảng điều khiển
-- của trình duyệt gọi thẳng được vào máy chủ. Và quyền của Postgres tính theo
-- DÒNG chứ không theo CỘT — cho quản trị `update` một dòng `nguoi` là cho họ
-- đổi luôn `email` của người khác và tự bật tắt cờ quyền của mình. Nên ② và ③
-- phải là cò, không thể là policy.
-- ============================================================================

begin;

-- ═══ 1. BỐN CỘT MỚI ════════════════════════════════════════════════════════
-- Ba cột đầu là thông tin CÁ NHÂN: chúng đúng kể cả khi người ấy rời công ty.
-- `ten` đã có sẵn và GIỮ NGUYÊN vai trò tên hiển thị — mười ba chỗ trong app
-- đọc nó, kể cả chữ tắt trên avatar. Đừng gộp hai cột làm một.

alter table nguoi add column if not exists ho_ten        text not null default '';
alter table nguoi add column if not exists ngay_sinh     date;
alter table nguoi add column if not exists so_dien_thoai text not null default '';

comment on column nguoi.ho_ten is
  'Họ và tên đầy đủ (Trần Mai Trang). Khác `ten` — cột kia là tên hiển thị app '
  'gọi ở mọi nơi (Tracy). Để rỗng thì app bày tạm `ten`.';
comment on column nguoi.ngay_sinh is
  'Ngày sinh. Cả team đọc được (Tracy chốt 05/09) — bảng này là danh bạ nội bộ.';
comment on column nguoi.so_dien_thoai is
  'Số điện thoại, cất đúng chữ người khai gõ, chỉ cắt khoảng trắng hai đầu. '
  'KHÔNG chuẩn hoá ở đây: bảng khách hàng của CRM mới là chỗ số điện thoại làm '
  'khoá và cần chuẩn hoá (TRI-26); áp luật ấy vào đây là mượn một ràng buộc của '
  'bảng khác mà không được lợi gì.';

-- Cột thứ tư là trạng thái LÀM VIỆC, không phải thông tin cá nhân.
-- NULL = đang làm. Có ngày = đã nghỉ.
alter table nguoi add column if not exists ngay_nghi date;

comment on column nguoi.ngay_nghi is
  'Ngày người này rời team. NULL là đang làm. Điền ngày thì họ không đăng nhập '
  'được nữa (xem `la_thanh_vien`), nhưng MỌI việc · cam kết · giờ làm việc sâu '
  'của họ ở lại nguyên vẹn. App KHÔNG có đường xoá một dòng `nguoi` — xoá là '
  'kéo theo mọi thứ đang treo vào nó.';


-- ═══ 2. LẬT MẶC ĐỊNH `la_lead` XUỐNG `false` ═══════════════════════════════
-- ⚠️ ĐÂY LÀ CHỖ ĐÁNG ĐỌC NHẤT TỆP NÀY.
-- Cột `la_lead` được khai HAI LẦN với hai mặc định ngược nhau:
--     `nang-cap-lich-chung.sql`  →  default true
--     `nang-cap-ban-tin.sql`     →  default false
-- Cả hai đều là `add column if not exists`, nên câu chạy TRƯỚC thắng và câu
-- sau lặng lẽ không làm gì. Trên máy chủ mặc định thật đang là **true**.
--
-- Hậu quả: **người thứ tám vào app tự động thành lead** — đăng bản tin được,
-- sửa lịch chung của cả team được, giao việc lặp được. Không ai bật, không ai
-- thấy. Tracy đã nói nhiều lần rằng năm người vào sau là NHÂN SỰ, không phải
-- lead; điều ấy vẫn tái diễn được vì lỗi không nằm ở trí nhớ ai cả — nó nằm ở
-- một cái mặc định chưa ai lật.
alter table nguoi alter column la_lead set default false;

-- CỐ Ý không chạy `update nguoi set la_lead = false` cho ai. Bảy người đang
-- mang cờ ấy là mang đúng. Câu tự kiểm số 3 ở cuối tệp canh con số này.


-- ═══ 3. NGƯỜI ĐÃ NGHỈ THÌ KHÔNG VÀO ĐƯỢC NỮA ═══════════════════════════════
-- `la_thanh_vien()` là nền của MỌI policy đọc trong app. Thêm một vế ở đây là
-- đóng cửa vào cho người đã nghỉ ở tất cả các bảng cùng lúc, không phải sửa
-- từng policy một.
create or replace function la_thanh_vien()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from nguoi
                      where email = email_dang_nhap()
                        and ngay_nghi is null) $$;

comment on function la_thanh_vien() is
  'Người đang đăng nhập có phải thành viên ĐANG LÀM VIỆC không. Từ 05/09 soi '
  'thêm `ngay_nghi`: cho nghỉ là đóng cửa vào ở mọi bảng cùng lúc.';


-- ═══ 4. HAI POLICY GHI — CHỈ QUẢN TRỊ ══════════════════════════════════════
-- `la_quan_tri_dang_nhap()` đã dựng sẵn từ `nang-cap-ban-tin.sql`, và cờ
-- `la_quan_tri` đã bật đúng Tracy và Andy. Không dựng lại gì.
drop policy if exists them_nguoi on nguoi;
create policy them_nguoi on nguoi for insert
  with check (la_quan_tri_dang_nhap());

drop policy if exists sua_nguoi on nguoi;
create policy sua_nguoi on nguoi for update
  using      (la_quan_tri_dang_nhap())
  with check (la_quan_tri_dang_nhap());

comment on policy them_nguoi on nguoi is
  'Thêm một người vào team: chỉ quản trị (Tracy, Andy).';
comment on policy sua_nguoi on nguoi is
  'Sửa một dòng người: chỉ quản trị. Hai cò chan_tu_go_quyen và '
  'chan_trong_quan_tri canh phần mà một policy theo DÒNG không canh được.';

-- ⛔ KHÔNG có policy `for delete`, và đó là một quyết định chứ không phải chỗ
--    sót. RLS bật mà thiếu policy nghĩa là không ai xoá được — đúng ý muốn.
--    Người rời team thì điền `ngay_nghi`, đừng xoá dòng.


-- ═══ 5. CÒ ② — KHÔNG TỰ GỠ QUYỀN CỦA CHÍNH MÌNH ════════════════════════════
-- Quyền của Postgres tính theo DÒNG. Policy `sua_nguoi` cho quản trị sửa mọi
-- dòng, kể cả dòng của chính họ, kể cả cột `la_quan_tri` và `ngay_nghi`. Một cú
-- bấm nhầm là tự khoá mình ra ngoài, và lối chữa lúc ấy chỉ còn là mở Supabase.
--
-- Cò này giữ hai cột ấy nguyên bản cũ KHI người sửa chính là người bị sửa.
-- Gỡ quyền của người khác thì vẫn được — cò ③ lo phần đừng để trống.
create or replace function chan_tu_go_quyen()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  -- Lượt chạy từ SQL Editor không có token nên không có "chính mình" — để yên,
  -- đó là lối chữa cháy cuối cùng của Tracy và không được khoá lại.
  if email_dang_nhap() = '' then return new; end if;
  if old.id is distinct from nguoi_id_dang_nhap() then return new; end if;

  new.la_quan_tri := old.la_quan_tri;   -- không tự gỡ quyền quản trị
  new.ngay_nghi   := old.ngay_nghi;     -- không tự cho mình nghỉ
  return new;
end $$;

drop trigger if exists tg_chan_tu_go_quyen on nguoi;
create trigger tg_chan_tu_go_quyen
  before update on nguoi
  for each row execute function chan_tu_go_quyen();


-- ═══ 6. CÒ ③ — KHÔNG ĐỂ TEAM TRỐNG QUẢN TRỊ ════════════════════════════════
-- Cò ② đã đủ để chứng minh điều này về lý: người đang sửa là quản trị đang làm
-- việc, và họ không đổi được hai cột của chính mình — nên sau mọi lượt ghi qua
-- app vẫn còn ít nhất một quản trị. Cò này canh phần lý lẽ ấy không với tới:
-- một lượt `update` nhiều dòng cùng lúc, hoặc một đường ghi nào đó về sau.
--
-- Chạy ở tầng CÂU LỆNH chứ không tầng dòng: giữa chừng một lượt sửa nhiều dòng,
-- con số có thể tụt xuống 0 rồi lên lại — hỏi ở tầng dòng là báo oan.
create or replace function chan_trong_quan_tri()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  if email_dang_nhap() = '' then return null; end if;   -- SQL Editor: để yên
  if not exists (select 1 from nguoi
                  where la_quan_tri and ngay_nghi is null) then
    raise exception
      'Team phải luôn còn ít nhất một quản trị đang làm việc. Bật quyền cho người khác trước, rồi mới gỡ.';
  end if;
  return null;
end $$;

drop trigger if exists tg_chan_trong_quan_tri on nguoi;
create trigger tg_chan_trong_quan_tri
  after update or insert on nguoi
  for each statement execute function chan_trong_quan_tri();

commit;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai, chỉ để nhìn ════════════════════
select ten, ho_ten, vai,
       chuc_nang_ids,
       la_lead, la_dieu_hanh, la_quan_tri,
       (ngay_nghi is null) as dang_lam
  from nguoi
 order by thu_tu;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả chín dòng ════════════════════════════
-- Đặt CUỐI tệp vì trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh
-- cuối cùng. `order by dat` đẩy dòng chưa đạt lên đầu.
select * from (values
  (1, 'bốn cột mới đã có mặt',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nguoi'
       and column_name in ('ho_ten','ngay_sinh','so_dien_thoai','ngay_nghi')) = 4),

  (2, 'mặc định la_lead nay là false',
   coalesce((select column_default from information_schema.columns
              where table_schema = 'public' and table_name = 'nguoi'
                and column_name = 'la_lead'), '') like 'false%'),

  (3, 'đúng bảy người mang cờ lead',
   (select count(*) from nguoi where la_lead) = 7),

  (4, 'đúng hai quản trị, và cả hai đang làm việc',
   (select count(*) from nguoi where la_quan_tri and ngay_nghi is null) = 2),

  (5, 'hai policy ghi đã dựng',
   (select count(*) from pg_policies
     where tablename = 'nguoi' and policyname in ('them_nguoi','sua_nguoi')) = 2),

  /* Dòng này canh một thứ KHÔNG CÓ. Thiếu policy delete chính là hàng rào —
     thêm nó vào sau này là mở đường xoá người mà không ai để ý. */
  (6, 'không có policy xoá nào trên bảng nguoi',
   (select count(*) from pg_policies
     where tablename = 'nguoi' and cmd = 'DELETE') = 0),

  (7, 'hai cò đã dựng',
   (select count(*) from pg_trigger
     where not tgisinternal
       and tgname in ('tg_chan_tu_go_quyen','tg_chan_trong_quan_tri')) = 2),

  /* `pg_get_functiondef` trả lại NGUYÊN VĂN thân hàm sql, khác hẳn cách
     Postgres in lại một `check` — nên so chuỗi ở đây là an toàn. */
  (8, 'la_thanh_vien nay soi cả ngay_nghi',
   pg_get_functiondef('la_thanh_vien()'::regprocedure) like '%ngay_nghi%'),

  (9, 'không ai vừa đã nghỉ vừa còn đang giữ cửa vào',
   not exists (select 1 from nguoi
                where ngay_nghi is not null and ngay_nghi > current_date))
) as t(so, muc, dat)
order by dat, so;
