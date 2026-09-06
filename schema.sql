-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `danh_muc_nhip`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- TỈNH THỨC APP — lược đồ Supabase
--
-- CÁCH DÙNG: tạo project Supabase MỚI (đừng dùng chung project app Tiêu điểm)
--            → SQL Editor → New query → dán TRỌN file này → Run.
--            → rồi chạy tiếp `nang-cap-khu-vuon.sql` (lớp hình tượng vườn).
--            Sau đó vào Authentication → Providers → bật Google.
--
-- ⚠️ File này là lớp NỀN. Bộ luật Khu Vườn (ba luống · một task một cây ·
--    hai bảng vinh danh) nằm trọn trong `nang-cap-khu-vuon.sql` để chạy được
--    cả khi project đã cài file này từ trước. Đừng sửa hai nơi cùng một thứ.
--
-- Nguyên lý giữ nguyên từ bảng Google Sheet (Tracy chốt 04/08/2026):
--   · HAI LÀN: nhịp ngày (lặp lại, khai 1 lần đầu tuần) ↔ task (phát sinh, xong là hết)
--   · Điểm ngày = trung bình từng nhịp, TRẦN 100% mỗi nhịp — vượt không bù nhịp bỏ trắng
--   · 💎 = 100% · 🪨 = có chốt ngày nhưng dưới 100% · 💩 = không chốt trước 24h
--   · Giờ chốt do MÁY CHỦ đóng dấu — không khai lùi được (thay cho lịch sử sửa ô)
--   · Deepwork: mỗi phiên 30 phút gắn vào một task → 🌳 cây sống / 🥀 cây héo.
--     Không chặn mở app khác (Tracy chốt) — chạy bằng tự giác + vườn công khai.
--
-- Phân quyền (⚠️ giả định chờ Tracy xác nhận): CẢ ĐỘI XEM ĐƯỢC HẾT,
-- mỗi người chỉ SỬA được dữ liệu của mình. Vườn cây cũng công khai.
--
-- Múi giờ: mọi phép tính "hôm nay" dùng Asia/Ho_Chi_Minh — luật 24h tính theo
-- đồng hồ Việt Nam, không theo UTC của máy chủ.
-- ============================================================================

-- ─── Hàm tiện ích: hôm nay theo giờ Việt Nam ────────────────────────────────
create or replace function hom_nay()
returns date language sql stable
as $$ select (now() at time zone 'Asia/Ho_Chi_Minh')::date $$;

-- Thứ Hai của tuần chứa một ngày (tuần bắt đầu thứ Hai, khớp khối tuần trong Sheet)
create or replace function thu_hai_cua(d date)
returns date language sql immutable
as $$ select d - ((extract(isodow from d))::int - 1) $$;


-- ─── BẢNG 1: nguoi — 12 thành viên, đồng thời là danh sách email ĐƯỢC VÀO ───
-- Đăng nhập Google xong, app đối chiếu email với bảng này. Email không có
-- trong đây thì không thấy gì cả → không cần màn hình duyệt thành viên.
create table if not exists nguoi (
  id         uuid primary key default gen_random_uuid(),
  email      text not null unique,
  ten        text not null,             -- tên hiển thị: Andy, Tracy, Hafi…
  vai        text not null default '',  -- CEO, Lead Sales, Cung ứng…
  phong_ban  text not null default '',  -- Ban điều hành, Bán hàng, Cung ứng…
  thu_tu     smallint not null default 99
);
comment on table nguoi is '12 thành viên ROVA. Email = danh sách trắng đăng nhập.';

-- Email của người đang đăng nhập (từ token Google)
create or replace function email_dang_nhap()
returns text language sql stable
as $$ select coalesce(auth.jwt() ->> 'email', '') $$;

-- id trong bảng nguoi của người đang đăng nhập
create or replace function nguoi_id_dang_nhap()
returns uuid language sql stable security definer set search_path = public
as $$ select id from nguoi where email = email_dang_nhap() $$;

-- Có phải thành viên đội không (mọi policy đọc đều dựa vào đây)
create or replace function la_thanh_vien()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from nguoi where email = email_dang_nhap()) $$;


-- ─── BẢNG 2: tieu_diem — O1…O10, dùng chung cả đội ──────────────────────────
create table if not exists tieu_diem (
  ma      text primary key,            -- 'O1'…'O10'
  ten     text not null default '',    -- mô tả kết quả lớn (Tracy điền dần)
  thu_tu  smallint not null default 99
);
insert into tieu_diem (ma, thu_tu)
select 'O' || n, n from generate_series(1, 10) n
on conflict (ma) do nothing;


-- ─── BẢNG 3: danh_muc_nhip — 156 nhịp rút từ 2 tháng data Tỉnh thức ─────────
-- Nguồn cho ô chọn nhịp. Chặn tận gốc chuyện một việc gõ 21 kiểu (Andrew).
create table if not exists danh_muc_nhip (
  id         bigint generated always as identity primary key,
  ten        text not null unique,
  phong_ban  text not null default '',
  don_vi_goi_y text not null default 'Lần/ngày',
  so_lan_da_lap int not null default 0   -- từ báo cáo tinh-thuc-danh-sach-viec-lap-lai
);
comment on table danh_muc_nhip is 'Danh mục nhịp chuẩn. Muốn thêm nhịp mới: Tracy thêm vào đây.';


-- ─── BẢNG 4: nhip — 5 nhịp của MỘT NGƯỜI trong MỘT TUẦN ─────────────────────
-- "Khối tuần" của Sheet nay chỉ còn là cột tuan_bat_dau. Không còn gì để sinh.
create table if not exists nhip (
  id            bigint generated always as identity primary key,
  nguoi_id      uuid not null references nguoi (id) on delete cascade,
  tuan_bat_dau  date not null,                    -- luôn là thứ Hai
  ten           text not null,
  muc_tieu      numeric not null check (muc_tieu > 0),  -- luật: không Mục tiêu = không tính điểm
  don_vi        text not null default 'Lần/ngày',
  thu_tu        smallint not null default 1 check (thu_tu between 1 and 5),
  unique (nguoi_id, tuan_bat_dau, thu_tu),
  constraint tuan_phai_la_thu_hai check (tuan_bat_dau = thu_hai_cua(tuan_bat_dau))
);
create index if not exists nhip_theo_tuan on nhip (nguoi_id, tuan_bat_dau);


-- ─── BẢNG 5: so_ngay — số làm được của một nhịp trong một ngày ──────────────
create table if not exists so_ngay (
  id        bigint generated always as identity primary key,
  nhip_id   bigint not null references nhip (id) on delete cascade,
  ngay      date not null,
  gia_tri   numeric not null check (gia_tri >= 0),   -- luật: không làm gõ 0, app luôn ghi số
  ghi_luc   timestamptz not null default now(),      -- máy chủ đóng dấu, client không ghi đè
  unique (nhip_id, ngay)
);


-- ─── BẢNG 6: nop_ngay — mốc "đã chốt ngày". LUẬT 24H SỐNG Ở ĐÂY ─────────────
-- 💩 không phải một cột — nó là SỰ VẮNG MẶT của dòng nop_ngay đúng hạn.
create table if not exists nop_ngay (
  id        bigint generated always as identity primary key,
  nguoi_id  uuid not null references nguoi (id) on delete cascade,
  ngay      date not null,
  nop_luc   timestamptz not null default now(),
  unique (nguoi_id, ngay)
);
-- Chặn khai lùi: chỉ chốt được cho ĐÚNG hôm nay (giờ VN)
alter table nop_ngay drop constraint if exists chi_chot_hom_nay;
alter table nop_ngay add constraint chi_chot_hom_nay check (ngay = hom_nay());


-- ─── BẢNG 7: task — làn việc phát sinh ──────────────────────────────────────
create table if not exists task (
  id            bigint generated always as identity primary key,
  nguoi_id      uuid not null references nguoi (id) on delete cascade,
  ngay          date not null default hom_nay(),
  noi_dung      text not null check (length(trim(noi_dung)) > 0),
  tieu_diem_ma  text references tieu_diem (ma),
  deadline      text not null default '',
  trang_thai    text not null default 'Confirm'
                check (trang_thai in ('Confirm', 'Doing', 'Done', 'Miss')),
  tao_luc       timestamptz not null default now(),
  xong_luc      timestamptz
);
create index if not exists task_theo_nguoi_ngay on task (nguoi_id, ngay);


-- ─── BẢNG 8: phien_deepwork — 30 phút = một cái cây ─────────────────────────
create table if not exists phien_deepwork (
  id        bigint generated always as identity primary key,
  task_id   bigint not null references task (id) on delete cascade,
  nguoi_id  uuid not null references nguoi (id) on delete cascade,
  bat_dau   timestamptz not null default now(),   -- máy chủ đóng dấu
  ket_thuc  timestamptz,
  ket_qua   text not null default 'dang_chay'
            check (ket_qua in ('dang_chay', 'song', 'heo'))
  -- 'song' chỉ được đặt khi ket_thuc - bat_dau >= 30 phút (trigger dưới).
  -- Phiên bỏ ngang / rời tab: app đặt 'heo'. Phiên treo quá 40' không kết thúc:
  -- khung nhìn vuon_cay tự coi là héo — không cần cron.
);
create index if not exists deepwork_theo_nguoi on phien_deepwork (nguoi_id, bat_dau);

-- Không cho tự phong cây sống khi chưa đủ 30 phút (trừ 30 giây du di mạng chậm)
create or replace function kiem_cay_song()
returns trigger language plpgsql
as $$
begin
  if new.ket_qua = 'song' then
    if new.ket_thuc is null
       or new.ket_thuc - new.bat_dau < interval '29 minutes 30 seconds' then
      raise exception 'Chưa đủ 30 phút, cây không thể sống';
    end if;
  end if;
  if new.bat_dau <> old.bat_dau then
    raise exception 'Không sửa được giờ bắt đầu';
  end if;
  return new;
end $$;
drop trigger if exists trg_kiem_cay_song on phien_deepwork;
create trigger trg_kiem_cay_song before update on phien_deepwork
  for each row execute function kiem_cay_song();


-- ─── KHUNG NHÌN 1: diem_ngay — điểm checklist mỗi người mỗi ngày ────────────
-- Đúng hàm đã đặt trong Sheet: từng nhịp chấm riêng, trần 1.0, rồi trung bình.
-- QUAN TRỌNG: trung bình trên CẢ 5 nhịp của tuần đó — nhịp chưa điền tính 0.
-- (Không thì điền đúng 1 nhịp đạt 100% là được 💎 oan.)
create or replace view diem_ngay as
with ngay_co as (
  select n2.nguoi_id, s.ngay
  from so_ngay s join nhip n2 on n2.id = s.nhip_id
  union
  select nguoi_id, ngay from nop_ngay
)
select
  nc.nguoi_id,
  nc.ngay,
  round(avg(least(coalesce(s.gia_tri, 0) / n.muc_tieu, 1))::numeric, 4) as diem,
  count(s.id) as so_nhip_da_ghi
from ngay_co nc
join nhip n on n.nguoi_id = nc.nguoi_id
           and n.tuan_bat_dau = thu_hai_cua(nc.ngay)
left join so_ngay s on s.nhip_id = n.id and s.ngay = nc.ngay
group by nc.nguoi_id, nc.ngay;

-- ─── KHUNG NHÌN 2: ket_qua_ngay — 💎 / 🪨 / 💩 tự chấm, không ai tự phong ───
-- Chỉ chấm người ĐÃ CÓ nhịp tuần đó (thành viên mới chưa setup thì chưa bị 💩).
create or replace view ket_qua_ngay as
select
  ng.id as nguoi_id,
  d.ngay,
  case
    when np.id is null             then '💩'   -- không chốt trước 24h
    when coalesce(dm.diem, 0) >= 1 then '💎'
    else                                '🪨'
  end as ket_qua,
  coalesce(dm.diem, 0) as diem,
  np.nop_luc
from nguoi ng
cross join (select distinct ngay from so_ngay
            union select distinct ngay from nop_ngay) d
left join nop_ngay np on np.nguoi_id = ng.id and np.ngay = d.ngay
left join diem_ngay dm on dm.nguoi_id = ng.id and dm.ngay = d.ngay
where (d.ngay < hom_nay() or np.id is not null)
  and exists (select 1 from nhip n
              where n.nguoi_id = ng.id
                and n.tuan_bat_dau = thu_hai_cua(d.ngay));

-- ─── KHUNG NHÌN 3: vuon_cay — cây của từng người từng ngày ──────────────────
create or replace view vuon_cay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  p.task_id,
  t.noi_dung as ten_task,
  p.bat_dau,
  case
    when p.ket_qua = 'dang_chay'
         and now() - p.bat_dau > interval '40 minutes' then 'heo'  -- phiên treo
    else p.ket_qua
  end as ket_qua
from phien_deepwork p
join task t on t.id = p.task_id;


-- Khung nhìn phải chạy bằng quyền NGƯỜI GỌI — không thì nó vượt mặt RLS
-- và người chưa đăng nhập cũng đọc được điểm của cả đội.
alter view diem_ngay     set (security_invoker = on);
alter view ket_qua_ngay  set (security_invoker = on);
alter view vuon_cay      set (security_invoker = on);


-- ═══ PHÂN QUYỀN (RLS) ═══════════════════════════════════════════════════════
-- ⚠️ Giả định chờ Tracy xác nhận: cả đội XEM hết · chỉ SỬA của mình.
alter table nguoi          enable row level security;
alter table tieu_diem      enable row level security;
alter table danh_muc_nhip  enable row level security;
alter table nhip           enable row level security;
alter table so_ngay        enable row level security;
alter table nop_ngay       enable row level security;
alter table task           enable row level security;
alter table phien_deepwork enable row level security;

-- Đọc: mọi thành viên đọc được mọi bảng
create policy doc_nguoi     on nguoi          for select using (la_thanh_vien());
create policy doc_tieudiem  on tieu_diem      for select using (la_thanh_vien());
create policy doc_danhmuc   on danh_muc_nhip  for select using (la_thanh_vien());
create policy doc_nhip      on nhip           for select using (la_thanh_vien());
create policy doc_songay    on so_ngay        for select using (la_thanh_vien());
create policy doc_nopngay   on nop_ngay       for select using (la_thanh_vien());
create policy doc_task      on task           for select using (la_thanh_vien());
create policy doc_deepwork  on phien_deepwork for select using (la_thanh_vien());

-- Ghi: chỉ dòng của chính mình
create policy ghi_nhip on nhip for all
  using (nguoi_id = nguoi_id_dang_nhap()) with check (nguoi_id = nguoi_id_dang_nhap());
create policy ghi_songay on so_ngay for all
  using (exists (select 1 from nhip n where n.id = nhip_id and n.nguoi_id = nguoi_id_dang_nhap()))
  with check (exists (select 1 from nhip n where n.id = nhip_id and n.nguoi_id = nguoi_id_dang_nhap()));
create policy ghi_nopngay on nop_ngay for insert
  with check (nguoi_id = nguoi_id_dang_nhap());          -- chốt rồi không sửa không xoá
create policy ghi_task on task for all
  using (nguoi_id = nguoi_id_dang_nhap()) with check (nguoi_id = nguoi_id_dang_nhap());
create policy ghi_deepwork on phien_deepwork for all
  using (nguoi_id = nguoi_id_dang_nhap()) with check (nguoi_id = nguoi_id_dang_nhap());

-- nguoi / tieu_diem / danh_muc_nhip: không ai ghi qua app.
-- Tracy quản bằng Supabase dashboard (hoặc thêm policy admin sau).


-- ═══ DỮ LIỆU MỒI: thành viên ════════════════════════════════════════════════
-- Đợt core team 10/08: 7 người. 5 người còn lại (Andrew · Ham · Vicky · ZemC
-- và người thứ 12) chưa có email — gom xong thì thêm bằng Table Editor, hoặc
-- chạy thêm câu insert cùng mẫu (on conflict do nothing).
--
-- `ten` là TÊN GỌI trong ROVA, đúng bảng nhân sự Tracy xác nhận 2026-07-28
-- (wiki/cong-ty/rova/danh-muc-du-an-rova.md Mục 1b). `thu_tu` theo STT bảng đó.
-- `vai` và `phong_ban` để trống — Tracy chốt 10/08 "chức vụ tạm bỏ đi".
-- Email LUÔN ghi chữ thường: token Google trả email chữ thường, mà
-- la_thanh_vien() so chuỗi có phân biệt hoa thường → hoa một chữ là mất quyền.
insert into nguoi (ten, email, vai, phong_ban, thu_tu) values
  ('Andy',   'andy@vidu.com',       'CEO',      'Ban điều hành', 1),
  ('Tracy',  'tracy@vidu.com',   'Vận hành', 'Vận hành',      2),
  ('Peter',  'peter@vidu.com',          '',         '',              3),
  ('Hafi',   'hafi@vidu.com',        '',         '',              4),
  ('Sydney', 'sydney@vidu.com', '',         '',              5),
  ('Justin', 'justin@vidu.com',          '',         '',              6),
  ('John',   'john@vidu.com',        '',         '',              7)
on conflict (email) do nothing;
