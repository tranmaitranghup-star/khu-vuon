-- ╔══════════════════════════════════════════════════════════════════════════╗
-- │ BẢNG TIN chung toàn ROVA — Tracy đặt đề bài 04/09/2026 (TRI-96)          │
-- │ Dấu vết riêng trên máy chủ: bảng `ban_tin`                               │
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Tệp này làm HAI việc tách bạch:
--   ① thêm hai cột VAI TRÒ vào bảng `nguoi` — `la_lead` và `la_quan_tri`.
--      Chúng là khái niệm DÙNG CHUNG, không riêng bảng tin: đề bài gốc của
--      Tracy còn có "các leader hàng tuần thực hiện lịch giao ban", cũng cần
--      đúng cột `la_lead` này.
--   ② dựng bảng `ban_tin` cùng bộ policy ba mức.
--
-- BA MỨC QUYỀN (Tracy chốt 04/09):
--   đọc  → cả đội, mọi tin. Không lọc trước ở tầng máy chủ: doanh nghiệp nhỏ,
--          thông tin thông suốt. Tag phòng ban là NHÃN để lọc ở màn hình, KHÔNG
--          phải hàng rào quyền.
--   đăng → bảy lead.
--   sửa và gỡ MỌI tin → chỉ Tracy và Andy. Lead khác chỉ sửa gỡ tin của mình.
--
-- ⚠️ MỘT ĐIỀU PHẢI BIẾT TRƯỚC KHI ĐỌC CON SỐ: bảng `nguoi` hiện có ĐÚNG BẢY
-- người, và cả bảy đều là lead. Năm nhân sự còn lại (Andrew · Javis · Ham ·
-- Vicky · ZemC — bảng nhân sự Tracy xác nhận 28/07, `danh-muc-du-an-rova.md`
-- Mục 1b) CHƯA CÓ trong bảng, nên hôm nay họ không đăng nhập được app, chứ
-- không phải "đọc được tin mà không đăng được". Cột `la_lead` vì thế đang đúng
-- với cả bảy dòng; nó chỉ bắt đầu phân biệt được ai với ai khi năm người kia
-- được thêm vào (mặc định `false`, đúng vai của họ).


-- ═══ ① HAI CỘT VAI TRÒ TRÊN BẢNG nguoi ════════════════════════════════════

alter table nguoi add column if not exists la_lead     boolean not null default false;
alter table nguoi add column if not exists la_quan_tri boolean not null default false;

comment on column nguoi.la_lead is
  'Trưởng team / chuyên viên giữ dự án — được đăng tin và giao việc lặp. 7 người tính tới 04/09.';
comment on column nguoi.la_quan_tri is
  'Sửa và gỡ được MỌI tin của người khác. Chỉ Tracy và Andy.';

-- Đánh dấu theo TÊN GỌI, khớp đúng cột `ten` trong seed schema.sql.
update nguoi set la_lead = true
 where ten in ('Andy','Tracy','Peter','Hafi','Sydney','Justin','John');

update nguoi set la_quan_tri = true
 where ten in ('Tracy','Andy');


-- Hai hàm tra vai trò, để policy không phải viết lại phép hỏi ở mỗi dòng.
create or replace function la_lead_dang_nhap()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce((select la_lead or la_quan_tri from nguoi
                        where email = email_dang_nhap()), false) $$;

create or replace function la_quan_tri_dang_nhap()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce((select la_quan_tri from nguoi
                        where email = email_dang_nhap()), false) $$;


-- ═══ ② BẢNG ban_tin ═══════════════════════════════════════════════════════

create table if not exists ban_tin (
  id              uuid primary key default gen_random_uuid(),
  tieu_de         text        not null,
  noi_dung        text        not null default '',
  -- Tag trỏ về DANH MỤC bằng mã, không chép tên: đổi tên khối một lần trong
  -- `chuc_nang` là sạch ở mọi tin, kể cả tin cũ. Cùng hình dạng đã dùng cho
  -- `nguoi.chuc_nang_ids` — một tin gắn được nhiều phòng, y như một người
  -- thuộc được nhiều phòng.
  chuc_nang_ids   smallint[]  not null default '{}',
  -- Tách riêng khỏi mảng trên, cố ý: "Toàn công ty" KHÔNG phải một phòng thứ
  -- bảy. Nó đi kèm được với phòng cụ thể — "cả nhà đọc, và câu này nói về
  -- Sản phẩm" là một câu có nghĩa.
  toan_cong_ty    boolean     not null default false,
  tu_ngay         date        not null default current_date,
  den_ngay        date,       -- null = chưa có hạn, tin nằm lại tới khi gỡ
  nguoi_dang      uuid        not null references nguoi (id),
  tao_luc         timestamptz not null default now(),
  sua_luc         timestamptz
);

comment on table ban_tin is
  'Bảng tin chung toàn ROVA. Ai cũng đọc được mọi tin; tag phòng ban là nhãn để lọc, không phải hàng rào quyền.';

-- Lọc theo phòng ban chạy trên mảng → chỉ mục GIN.
create index if not exists ban_tin_chuc_nang_idx on ban_tin using gin (chuc_nang_ids);
-- Màn hình luôn hỏi "tin nào đang hiệu lực", xếp mới nhất trên cùng.
create index if not exists ban_tin_hieu_luc_idx  on ban_tin (tu_ngay desc, den_ngay);

-- `sua_luc` để máy chủ tự điền, đừng trông vào app nhớ ghi.
create or replace function ban_tin_cham_sua()
returns trigger language plpgsql as $$
begin new.sua_luc := now(); return new; end $$;

drop trigger if exists ban_tin_sua on ban_tin;
create trigger ban_tin_sua before update on ban_tin
  for each row execute function ban_tin_cham_sua();


-- ═══ ③ POLICY — ba mức ════════════════════════════════════════════════════

alter table ban_tin enable row level security;

drop policy if exists ban_tin_doc    on ban_tin;
drop policy if exists ban_tin_dang   on ban_tin;
drop policy if exists ban_tin_sua_p  on ban_tin;
drop policy if exists ban_tin_go     on ban_tin;

-- đọc: cả đội, mọi tin
create policy ban_tin_doc on ban_tin for select
  using (la_thanh_vien());

-- đăng: bảy lead, và chỉ đăng được DƯỚI TÊN MÌNH
create policy ban_tin_dang on ban_tin for insert
  with check (la_lead_dang_nhap() and nguoi_dang = nguoi_id_dang_nhap());

-- sửa: quản trị sửa mọi tin; lead khác chỉ sửa tin của mình.
-- `with check` lặp lại đúng điều kiện để không ai sửa một tin rồi ĐỔI LUÔN
-- người đăng sang tên người khác.
create policy ban_tin_sua_p on ban_tin for update
  using      (la_quan_tri_dang_nhap() or nguoi_dang = nguoi_id_dang_nhap())
  with check (la_quan_tri_dang_nhap() or nguoi_dang = nguoi_id_dang_nhap());

-- gỡ: cùng luật với sửa
create policy ban_tin_go on ban_tin for delete
  using (la_quan_tri_dang_nhap() or nguoi_dang = nguoi_id_dang_nhap());


-- ═══ ④ TỰ KIỂM — chạy xong nhìn bốn dòng này ══════════════════════════════

-- 1) Bảy lead. Phải ra: so_lead = 7
select count(*) filter (where la_lead)     as so_lead,
       count(*) filter (where la_quan_tri) as so_quan_tri,
       count(*)                            as tong_nguoi
  from nguoi;
-- ✅ đúng khi: so_lead = 7 · so_quan_tri = 2 · tong_nguoi = 7

-- 2) Hai quản trị là ai. Phải ra đúng hai dòng: Andy, Tracy
select ten, la_lead, la_quan_tri from nguoi where la_quan_tri order by ten;

-- 3) Bảng dựng đủ cột. Phải ra 10 dòng
select column_name, data_type
  from information_schema.columns
 where table_name = 'ban_tin'
 order by ordinal_position;

-- 4) Bốn policy. Phải ra đúng 4 dòng: ban_tin_dang · ban_tin_doc · ban_tin_go · ban_tin_sua_p
select policyname, cmd from pg_policies
 where tablename = 'ban_tin' order by policyname;
