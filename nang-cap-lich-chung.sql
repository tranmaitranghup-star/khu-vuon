-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: ba bảng `lich_chung`, `lich_chung_ngoai_le`,
-- │ `lich_chung_tham_du`; cột `nguoi.la_lead`; hàm `la_lead()`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — LỊCH CHUNG CÔNG TY & PHÒNG BAN, CÓ LUẬT LẶP
--                                        (Tracy chốt G-01.z1·z2·z3, 31/08/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            KHÔNG phụ thuộc tệp nào chạy trước — nếu `chuc_nang` chưa có thì
--            file này dựng nó, đúng cùng khuôn `nang-cap-danh-muc-viec-co-dinh.sql`
--            nên chạy tệp kia trước hay sau đều được.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn LC).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 31/08: *"thêm tính năng add cho mọi người những lịch cố định của công ty
-- và phòng ban, set lịch lặp lại trên timeline như gg calendar ấy"* — cộng ba
-- câu chốt cùng ngày: cả 7 người đều tạo được (7 người trong app đều là lead
-- team), người nhận **tick được mình có tham gia buổi đó không**, và lead huỷ
-- được buổi.
--
-- ─── VÌ SAO KHÔNG DÙNG BẢNG `task` ──────────────────────────────────────────
-- Ba lý do, mỗi lý do đủ một mình:
--   ① Chính sách `ghi_task` (schema.sql:287) chặn cứng `nguoi_id =
--      nguoi_id_dang_nhap()` — không ai ghi được một dòng cho người khác. Nới nó
--      ra là mở đường cho MỌI thứ ghi chéo, không riêng lịch.
--   ② Một buổi lặp hằng tuần cho 7 người trong một năm là 364 dòng `task`, mà
--      đổi giờ một cái là phải sửa cả 364. Luật lặp giữ ĐÚNG MỘT dòng.
--   ③ `task` là trục đích (việc có vạch đích). Buổi họp không có vạch đích, và
--      ba ranh giới cứng 14/08 đã chốt: buổi họp KHÔNG chiếm ô `nhip`, KHÔNG
--      vào `diem_ngay`. Trộn vào `task` là mở lại cả ba.
--
-- ─── VÌ SAO KHÔNG SINH SẴN TỪNG LƯỢT VÀO BẢNG ───────────────────────────────
-- Bản định nghĩa nằm ở máy chủ, LƯỢT thì máy khách bung ra lúc vẽ, đúng lối
-- Google Calendar đi với RRULE. Được ba thứ: không tác vụ nền (app chưa có cái
-- nào), không bảng lượt phình theo thời gian, và đổi luật lặp là mọi lượt tương
-- lai đổi theo ngay — không phải đi sửa hàng trăm dòng đã sinh.
-- Cái giá: một lượt CỤ THỂ (dời giờ, huỷ, ai tick tham dự) thì phải có khoá
-- riêng để trỏ tới. Khoá ấy là cặp (mã lịch + NGÀY GỐC của lượt) — đúng ranh
-- giới ③ đã chốt 14/08: *"khoá nối là iCalUID + thời điểm gốc của lượt, tuyệt
-- đối không phải TÊN"*. Tên đổi thì lịch sử vẫn liền.
-- ============================================================================

begin;

-- ═══ 0. KHỐI CHỨC NĂNG — dựng nếu chưa có ══════════════════════════════════
-- Chép nguyên khuôn `nang-cap-danh-muc-viec-co-dinh.sql` mục 1–2 để file này
-- đứng một mình được. Mọi câu đều `if not exists` / `on conflict do nothing`
-- nên chạy tệp kia trước hay sau đều không đụng nhau.
create table if not exists chuc_nang (
  id      smallint generated always as identity primary key,
  ten     text not null unique,
  thu_tu  smallint not null default 99
);

insert into chuc_nang (ten, thu_tu) values
  ('CEO',                    1),
  ('Vận hành',               2),
  ('Sản phẩm',               3),
  ('Kinh doanh',             4),
  ('Tài chính',              5),
  ('Trải nghiệm khách hàng', 6)
on conflict (ten) do nothing;

alter table nguoi add column if not exists chuc_nang_id smallint
  references chuc_nang (id) on delete set null;

update nguoi n
   set chuc_nang_id = c.id
  from chuc_nang c
 where n.chuc_nang_id is null
   and lower(btrim(n.vai)) = lower(btrim(c.ten));


-- ═══ 1. CỜ QUYỀN — ai được tạo và huỷ lịch chung ═══════════════════════════
-- Tracy: *"hiện tại cứ để 7 người đều được nhé vì 7ng đều là lead team"* —
-- nên MẶC ĐỊNH BẬT. Ngày có người vào app mà không phải lead thì tắt cờ của
-- người đó, KHÔNG phải sửa một dòng mã nào.
-- Vì sao là một cột chứ không phải đọc `nguoi.vai = 'CEO'`: `vai` là chuỗi chữ
-- tự do dùng làm nhãn hiển thị; suy quyền từ một nhãn thì sửa nhãn là mất
-- quyền, im lặng. Đúng cái hố `chuc_nang` đã trèo ra một lần rồi.
alter table nguoi add column if not exists la_lead boolean not null default true;

comment on column nguoi.la_lead is
  'Được tạo · sửa · huỷ lịch chung. Mặc định BẬT vì 7 thành viên hiện tại đều '
  'là lead team (Tracy chốt 31/08). Tắt cho người không phải lead khi có.';

-- Không `security definer`: hàm chỉ ĐỌC `nguoi`, mà bảng ấy đã cho mọi thành
-- viên đọc (`doc_nguoi`, schema.sql:270). Quyền của chính người đang hỏi là đủ.
create or replace function la_lead()
returns boolean language sql stable set search_path = public
as $$ select coalesce(
         (select la_lead from nguoi where id = nguoi_id_dang_nhap()), false) $$;


-- ═══ 2. BẢN ĐỊNH NGHĨA MỘT LỊCH CHUNG ══════════════════════════════════════
create table if not exists lich_chung (
  id            bigint generated always as identity primary key,
  ten           text not null check (btrim(ten) <> ''),
  ghi_chu       text not null default '',

  -- PHẠM VI: cả công ty, hay một khối chức năng.
  pham_vi       text not null default 'cong_ty'
                check (pham_vi in ('cong_ty','khoi')),
  chuc_nang_id  smallint references chuc_nang (id),
  -- Hai chiều, không chỉ một: lịch khối PHẢI có khối, lịch công ty PHẢI trống
  -- khối. Thiếu vế sau thì một dòng 'cong_ty' còn đeo `chuc_nang_id` cũ sẽ đọc
  -- ra hai nghĩa khác nhau ở hai chỗ lọc.
  constraint lich_pham_vi_khop check (
    (pham_vi = 'khoi'    and chuc_nang_id is not null) or
    (pham_vi = 'cong_ty' and chuc_nang_id is null)),

  -- GIỜ: phút-từ-0h, cùng đơn vị `GIO_CAO` · `phutDeadline` · `tlgKhoangTask`
  -- đang dùng ở máy khách. Không đổi đơn vị ở chỗ nào cả.
  gio_bat_dau   smallint not null check (gio_bat_dau between 0 and 1439),
  so_phut       smallint not null default 60 check (so_phut between 5 and 1440),

  -- LUẬT LẶP.
  --   khong = một buổi duy nhất vào `ngay_bat_dau`
  --   ngay  = mỗi ngày (xem `bo_cn`)
  --   tuan  = những thứ khai trong `thu` — 0 là Chủ nhật, đúng quy ước
  --           `Date.getDay()` của máy khách VÀ `extract(dow)` của Postgres
  --   thang = ngày `ngay_thang` hằng tháng; tháng nào không có ngày ấy thì
  --           tháng đó KHÔNG có buổi (máy khách bỏ qua, không dồn sang 01)
  lap           text not null default 'tuan'
                check (lap in ('khong','ngay','tuan','thang')),
  thu           smallint[] not null default '{}'
                check (thu <@ array[0,1,2,3,4,5,6]::smallint[]),
  ngay_thang    smallint check (ngay_thang is null or ngay_thang between 1 and 31),
  -- ⚠️ `coalesce` KHÔNG thừa: `array_length('{}',1)` trả NULL chứ không trả 0,
  -- mà một CHECK cho kết quả NULL thì Postgres coi là ĐẠT. Thiếu nó, một lịch
  -- 'tuan' với danh sách thứ RỖNG lọt qua ràng buộc rồi nằm im trong bảng —
  -- không bao giờ nổ một buổi nào, và không một tiếng kêu.
  constraint lich_lap_du_tham_so check (
    (lap <> 'tuan'  or coalesce(array_length(thu,1),0) >= 1) and
    (lap <> 'thang' or ngay_thang is not null)),

  -- Chỉ có nghĩa với `lap='ngay'`. Luật Nghỉ CN của app áp cho việc lặp hằng
  -- ngày; còn một buổi khai ĐÚNG vào Chủ nhật thì đó là điều người ta cố ý.
  bo_cn         boolean not null default true,

  ngay_bat_dau  date not null default hom_nay(),
  ngay_ket_thuc date,
  constraint lich_khoang_ngay check (
    ngay_ket_thuc is null or ngay_ket_thuc >= ngay_bat_dau),

  -- VÒNG ĐỜI: cho NGƯNG, không xoá — xoá là đứt luôn ô tick tham dự của mọi
  -- buổi đã qua.
  dang_dung     boolean not null default true,
  ngung_luc     timestamptz,

  -- CHỖ NỐI VỀ SAU, cố ý để trống hôm nay: khi tầng việc cố định lên, một lịch
  -- chung trỏ được về một dòng danh mục mà KHÔNG phải chuyển bảng. Khoá ngoại
  -- gắn ở mục 6, chỉ khi `viec_co_dinh` đã có mặt trên máy chủ.
  viec_id       bigint,

  tao_boi       uuid references nguoi (id) on delete set null,
  tao_luc       timestamptz not null default now(),
  sua_luc       timestamptz not null default now()
);

comment on table lich_chung is
  'Bản ĐỊNH NGHĨA một buổi cố định của công ty hoặc một khối. Một dòng = một '
  'luật lặp; từng LƯỢT do máy khách bung ra lúc vẽ, không sinh dòng.';
comment on column lich_chung.thu is
  'Thứ trong tuần, 0 = Chủ nhật (khớp Date.getDay() và extract(dow)).';

create index if not exists lich_theo_pham_vi
  on lich_chung (dang_dung, pham_vi, chuc_nang_id);


-- ═══ 3. NGOẠI LỆ CỦA MỘT LƯỢT — huỷ hoặc dời ═══════════════════════════════
-- Khoá là (mã lịch + NGÀY GỐC của lượt). Ngày gốc là ngày luật lặp sinh ra lượt
-- ấy, không phải ngày sau khi dời — dời rồi mà khoá đi theo chỗ mới thì lượt
-- gốc mọc lại ở chỗ cũ ngay lượt vẽ sau.
create table if not exists lich_chung_ngoai_le (
  lich_id   bigint not null references lich_chung (id) on delete cascade,
  ngay_goc  date   not null,
  kieu      text   not null check (kieu in ('huy','doi')),
  ngay_moi  date,
  gio_moi   smallint check (gio_moi is null or gio_moi between 0 and 1439),
  constraint ngoaile_doi_du_tham_so check (
    kieu <> 'doi' or (ngay_moi is not null or gio_moi is not null)),
  ly_do     text not null default '',
  boi       uuid references nguoi (id) on delete set null,
  luc       timestamptz not null default now(),
  primary key (lich_id, ngay_goc)
);

comment on table lich_chung_ngoai_le is
  'Một lượt bị huỷ hoặc bị dời. Không có dòng ở đây thì lượt chạy đúng luật.';


-- ═══ 4. Ô TICK THAM DỰ — mỗi người tự tick lượt của mình ═══════════════════
-- Tracy: *"người nhận thì tôi muốn có nút cho họ tick buổi đó họ có tham gia
-- không"*. Một ô cho cả trước và sau buổi — tách RSVP với điểm danh là hỏi
-- người ta hai lần cho một buổi.
-- KHÔNG có dòng = CHƯA TRẢ LỜI, khác hẳn `tham_du = false` (đã trả lời: không
-- tham gia). Ba trạng thái ấy phải phân biệt được, nếu không thì mọi buổi mới
-- mở ra đã mang nghĩa "cả đội từ chối".
create table if not exists lich_chung_tham_du (
  lich_id   bigint not null references lich_chung (id) on delete cascade,
  ngay_goc  date   not null,
  nguoi_id  uuid   not null references nguoi (id) on delete cascade,
  tham_du   boolean not null default true,
  luc       timestamptz not null default now(),
  primary key (lich_id, ngay_goc, nguoi_id)
);

comment on table lich_chung_tham_du is
  'Ô tick "tôi có tham gia buổi này". KHÔNG có dòng = chưa trả lời; đó là một '
  'trạng thái khác với tham_du = false.';

create index if not exists thamdu_theo_nguoi
  on lich_chung_tham_du (nguoi_id, ngay_goc);


-- ═══ 5. QUYỀN ═════════════════════════════════════════════════════════════
alter table lich_chung           enable row level security;
alter table lich_chung_ngoai_le  enable row level security;
alter table lich_chung_tham_du   enable row level security;

-- ĐỌC: cả đội đọc mọi lịch, kể cả lịch của khối khác. Lọc theo khối là việc của
-- màn hình, không phải của quyền — cùng lối `tam nhìn khối là một tham số có
-- công tắc` đã chốt cho màn Việc cố định. Giấu ở tầng quyền thì người ta không
-- bao giờ biết khối bên cạnh đang họp lúc nào để mà tránh trùng giờ.
drop policy if exists doc_lich       on lich_chung;
drop policy if exists doc_lich_ngoai on lich_chung_ngoai_le;
drop policy if exists doc_lich_td    on lich_chung_tham_du;
create policy doc_lich       on lich_chung          for select using (la_thanh_vien());
create policy doc_lich_ngoai on lich_chung_ngoai_le for select using (la_thanh_vien());
create policy doc_lich_td    on lich_chung_tham_du  for select using (la_thanh_vien());

-- GHI bản định nghĩa và ngoại lệ: chỉ lead. Hôm nay cả 7 người đều là lead nên
-- ai cũng qua; mai tắt cờ một người là người đó chỉ còn đọc, không sửa mã.
drop policy if exists ghi_lich       on lich_chung;
drop policy if exists ghi_lich_ngoai on lich_chung_ngoai_le;
create policy ghi_lich on lich_chung for all
  using (la_lead()) with check (la_lead());
create policy ghi_lich_ngoai on lich_chung_ngoai_le for all
  using (la_lead()) with check (la_lead());

-- GHI ô tick: CHỈ dòng của chính mình, kể cả lead. Tick hộ người khác là nói
-- thay họ về việc họ có mặt hay không.
drop policy if exists ghi_lich_td on lich_chung_tham_du;
create policy ghi_lich_td on lich_chung_tham_du for all
  using (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());


-- ═══ 6. CHỖ NỐI VỀ VIỆC CỐ ĐỊNH — chỉ gắn khi bảng ấy đã có ════════════════
-- `viec_co_dinh` do `nang-cap-danh-muc-viec-co-dinh.sql` dựng. Tệp ấy có thể
-- chưa chạy trên máy chủ này (đó là chỗ `SO-SQL.sql` trả lời). Gắn khoá ngoại
-- vô điều kiện thì cả tệp này đổ; nên hỏi trước, gắn sau.
do $$
begin
  if to_regclass('public.viec_co_dinh') is not null
     and not exists (select 1 from pg_constraint where conname = 'lich_viec_fk')
  then
    alter table lich_chung add constraint lich_viec_fk
      foreign key (viec_id) references viec_co_dinh (id) on delete no action;
  end if;
end $$;

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ═════════════════════════════
select * from (values
  (1, 'ba bảng lịch chung có mặt',
   (select count(*) from information_schema.tables
     where table_schema = 'public'
       and table_name in ('lich_chung','lich_chung_ngoai_le','lich_chung_tham_du')) = 3),

  (2, 'cột nguoi.la_lead có mặt và mặc định bật',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nguoi'
       and column_name = 'la_lead') = 1
   and (select count(*) from nguoi where la_lead) = (select count(*) from nguoi)),

  (3, 'hàm la_lead() có mặt',
   (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'la_lead') = 1),

  (4, 'cả ba bảng đã bật RLS',
   (select bool_and(relrowsecurity) from pg_class
     where oid in ('public.lich_chung'::regclass,
                   'public.lich_chung_ngoai_le'::regclass,
                   'public.lich_chung_tham_du'::regclass))),

  (5, 'ô tick CHỈ chủ ghi được — không policy ghi nào của bảng tham dự dùng la_lead',
   not exists (select 1 from pg_policies
                where schemaname = 'public' and tablename = 'lich_chung_tham_du'
                  and cmd <> 'SELECT'
                  and coalesce(with_check,'') like '%la_lead%')),

  (6, 'sáu khối chức năng đã có',
   (select count(*) from chuc_nang) >= 6)
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from nguoi)                          as so_nguoi,
  (select count(*) from nguoi where la_lead)            as so_lead,
  (select count(*) from lich_chung where dang_dung)     as lich_dang_chay,
  (select count(*) from lich_chung_ngoai_le)            as so_ngoai_le,
  (select count(*) from lich_chung_tham_du)             as so_o_tick;
