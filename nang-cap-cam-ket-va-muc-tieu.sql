-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `muc_tieu`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: KHO TASK CỦA CAM KẾT + TẦNG MỤC TIÊU LỚN
-- Tracy duyệt 2026-08-08 (bản duyệt 7 mục, phương án A).
--
-- Chạy MỘT LẦN cho cả hai tầng, dù giao diện ra hai nhát:
--   nhát 1 — ba bảng cam kết + kho task   (làm ngay)
--   nhát 2 — màn mục tiêu cho leader      (sau)
-- Thêm bảng là việc rẻ; sửa schema hai lần mới là việc đắt.
--
-- Chạy được nhiều lần, không hỏng gì (idempotent).
-- Chạy SAU: schema.sql · nang-cap-khu-vuon · nang-cap-luong-rieng-tung-nguoi
--           · nang-cap-deepwork-tu-do · nang-cap-thoi-luong-du-kien
--           · nang-cap-chuong-tinh-thuc · va-luong-cheo-nhau
--           · va-chot-chan-truoc-khi-mo-doi
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. KHO TASK: cho `task.ngay` được để trống ────────────────────────────
-- ĐÂY LÀ CHỖ CHẶN THẬT của tính năng "thêm task lúc nào cũng được".
--
-- Bản cũ: `ngay date not null default hom_nay()` — mọi task sinh ra là đã
-- thuộc về HÔM NAY. Không có chỗ nào cho một việc đã nghĩ ra nhưng chưa xếp
-- ngày, tức app không có KHO. Đó chính là cơ chế đẻ ra 490 task bị gõ lại mỗi
-- sáng trong data Tỉnh thức: việc chưa xong hôm qua không có chỗ nằm.
--
-- Sau lệnh này:
--   ngay IS NULL      → task nằm trong kho của cam kết, chưa hẹn ngày làm
--   ngay = một ngày   → task đã được kéo ra một ngày cụ thể
--
-- GIỮ NGUYÊN `default hom_nay()` — cố ý, không phải bỏ sót. Mọi chỗ thêm task
-- cũ (màn Hôm nay, nút ➕) không truyền cột `ngay` nên vẫn rơi vào hôm nay y
-- như trước. Chỉ đường thêm-vào-kho mới truyền thẳng `ngay: null`. Bỏ default
-- đi là mọi task cũ thành task kho, sai hẳn ý.
alter table task alter column ngay drop not null;

-- Kho đọc theo (người, cam kết) — chỉ mục cũ chạy theo (người, ngày) nên không
-- đỡ được câu hỏi "cam kết này có những task nào".
create index if not exists task_theo_nguoi_camket on task (nguoi_id, tieu_diem_ma);

-- Chỉ mục riêng cho kho: task chưa hẹn ngày. Kho phải mở nhanh vì nó là màn
-- người dùng nhìn nhiều nhất sau khi tính năng này lên.
create index if not exists task_trong_kho on task (nguoi_id, tieu_diem_ma)
  where ngay is null;

comment on column task.ngay is
  'Ngày làm việc này. ĐỂ TRỐNG = đang nằm trong kho của cam kết, chưa hẹn ngày.';


-- ─── 2. TẦNG MỤC TIÊU LỚN ───────────────────────────────────────────────────
-- Tracy chốt 08/08: "nhiều cam kết sẽ phục vụ cho 1 mục tiêu của phòng ban
-- hoặc doanh nghiệp → cũng sẽ cần nơi ghi ra mục tiêu lớn (đặc biệt quan
-- trọng với quản lý cấp trung/leader phòng ban)".
--
-- Đây KHÔNG phải tầng mới nghĩ ra: nó là tầng G phòng ban trong hệ bốn tầng
-- đã chốt 05/08 (`dong-chay-task-rova.md` mục 8.1). Bản thiết kế có tầng này
-- từ lâu, app thì chưa có. Nay ba tầng khớp lại:
--   Mục tiêu (phòng ban / doanh nghiệp, 1 tuần → 1 tháng)
--     └─ Cam kết (cá nhân, vài ngày → 1 tuần)      = bảng tieu_diem
--          └─ Task (1 → 4 block)                    = bảng task
create table if not exists muc_tieu (
  id         bigint generated always as identity primary key,
  ten        text not null check (length(trim(ten)) > 0),
  -- Trạng thái đã đạt, kèm số và hạn — theo luật viết KR đã chốt 05/08:
  -- đọc lên hỏi "xong chưa?" mà trả lời được CÓ hoặc KHÔNG dứt khoát thì đạt.
  ket_qua    text not null default '',
  -- Ai cũng tạo được, nhãn cho biết mục tiêu này của ai (Tracy chốt 08/08:
  -- chưa dựng phân quyền riêng cho leader — đội 12 người cơ cấu phẳng, thêm
  -- quyền lúc này là thêm chỗ hỏng).
  pham_vi    text not null default 'phong-ban'
             check (pham_vi in ('ca-nhan', 'phong-ban', 'doanh-nghiep')),
  phong_ban  text not null default '',
  han        date,
  xong       boolean not null default false,
  ngay_xong  date,
  nguoi_id   uuid not null references nguoi (id) on delete cascade,
  tao_luc    timestamptz not null default now()
);

comment on table muc_tieu is
  'Tầng trên cam kết. Nhiều cam kết cá nhân phục vụ một mục tiêu phòng ban hoặc doanh nghiệp. Kéo dài 1 tuần → 1 tháng.';

-- Nối cam kết lên mục tiêu. `set null` chứ không `cascade`: xoá một mục tiêu
-- KHÔNG được kéo theo cam kết và task của người khác — cam kết vẫn là việc
-- thật đã làm, chỉ mất chỗ treo.
alter table tieu_diem add column if not exists muc_tieu_id bigint
  references muc_tieu (id) on delete set null;

create index if not exists tieudiem_theo_muctieu on tieu_diem (muc_tieu_id);


-- ─── 3. Hàng rào cho bảng mới ───────────────────────────────────────────────
-- Đúng khuôn của tieu_diem: cả đội ĐỌC được, chỉ chủ mới GHI.
-- Khoá công khai nằm ngay trong mã nguồn trang web nên hàng rào thật là RLS,
-- không phải giao diện.
alter table muc_tieu enable row level security;

drop policy if exists doc_muctieu  on muc_tieu;
create policy doc_muctieu on muc_tieu for select
  using (la_thanh_vien());

drop policy if exists them_muctieu on muc_tieu;
create policy them_muctieu on muc_tieu for insert
  with check (nguoi_id = nguoi_id_dang_nhap());

drop policy if exists sua_muctieu  on muc_tieu;
create policy sua_muctieu on muc_tieu for update
  using      (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());

drop policy if exists xoa_muctieu  on muc_tieu;
create policy xoa_muctieu on muc_tieu for delete
  using (nguoi_id = nguoi_id_dang_nhap());


-- ─── 4. Chốt chặn chéo: cam kết chỉ treo được lên mục tiêu ĐANG CÓ ─────────
-- Cùng họ với lỗ hổng đã vá ngày 08/08 ở `phien_deepwork`: một bảng chỉ soi
-- chủ của CHÍNH NÓ mà không soi chủ của thứ nó trỏ tới. Ở đây thì ngược lại —
-- mục tiêu là thứ DÙNG CHUNG (cam kết của tôi treo lên mục tiêu phòng ban do
-- leader tạo là chuyện bình thường), nên KHÔNG soi chủ. Chỉ soi tồn tại, và
-- khoá ngoại ở mục 2 đã lo việc đó.
--
-- Nhưng có một chỗ phải chặn: gọi thẳng API đặt `muc_tieu_id` trỏ tới mục tiêu
-- ĐÃ XONG thì cam kết mới treo vào một cái đã đóng sổ, không bảng nào lộ ra.
create or replace function kiem_muc_tieu_con_mo() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.muc_tieu_id is not null
     and exists (select 1 from muc_tieu m where m.id = new.muc_tieu_id and m.xong) then
    raise exception 'Mục tiêu này đã đóng — chọn mục tiêu khác hoặc mở lại nó trước.';
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_muc_tieu_con_mo on tieu_diem;
create trigger trg_kiem_muc_tieu_con_mo before insert or update on tieu_diem
  for each row execute function kiem_muc_tieu_con_mo();


-- ─── 5. Khung nhìn: một mục tiêu đang được mấy cam kết gánh ─────────────────
-- Đây là mắt xích "tiến độ phải được TÍNH, không được KHAI" mà cả ClickUp lẫn
-- Asana đều ép (nghiên cứu 6 app, 08/08). Không ai gõ phần trăm vào — máy đếm
-- từ cam kết thật bên dưới.
drop view if exists tien_do_muc_tieu;
create view tien_do_muc_tieu as
select
  m.id, m.ten, m.ket_qua, m.pham_vi, m.phong_ban, m.han, m.xong, m.nguoi_id,
  count(o.ma)                                   as so_cam_ket,
  count(o.ma) filter (where o.xong)             as cam_ket_xong,
  count(distinct o.nguoi_id)                    as so_nguoi_ganh
from muc_tieu m
left join tieu_diem o on o.muc_tieu_id = m.id
group by m.id, m.ten, m.ket_qua, m.pham_vi, m.phong_ban, m.han, m.xong, m.nguoi_id;

alter view tien_do_muc_tieu set (security_invoker = on);

comment on view tien_do_muc_tieu is
  'Tiến độ mục tiêu ĐẾM RA từ cam kết bên dưới, không ai khai bằng tay.';


-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy cùng lúc với phần trên, đọc cột ket_qua.
-- Mọi dòng phải ✅. Có ❌ thì ĐỪNG đưa bản giao diện mới lên.
-- ═══════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'task.ngay đã cho để trống (kho việc chạy được)',
   (select is_nullable = 'YES' from information_schema.columns
     where table_name = 'task' and column_name = 'ngay')),

  (2, 'task.ngay VẪN giữ default hom_nay() (đường thêm task cũ không đổi)',
   (select column_default like '%hom_nay%' from information_schema.columns
     where table_name = 'task' and column_name = 'ngay')),

  (3, 'Bảng muc_tieu đã có',
   to_regclass('public.muc_tieu') is not null),

  (4, 'muc_tieu đã bật hàng rào RLS',
   (select rowsecurity from pg_tables
     where schemaname = 'public' and tablename = 'muc_tieu')),

  (5, 'muc_tieu có đủ 4 policy (doc/them/sua/xoa)',
   (select count(*) from pg_policies where tablename = 'muc_tieu'
      and policyname in ('doc_muctieu','them_muctieu','sua_muctieu','xoa_muctieu')) = 4),

  (6, 'tieu_diem có cột muc_tieu_id',
   exists (select 1 from information_schema.columns
             where table_name = 'tieu_diem' and column_name = 'muc_tieu_id')),

  (7, 'Khoá ngoại muc_tieu_id là ON DELETE SET NULL (xoá mục tiêu không kéo theo cam kết)',
   exists (select 1 from pg_constraint
             where conrelid = 'tieu_diem'::regclass
               and contype = 'f' and confdeltype = 'n'
               and conkey = (select array[attnum] from pg_attribute
                              where attrelid = 'tieu_diem'::regclass
                                and attname = 'muc_tieu_id'))),

  (8, 'Chốt chặn "không treo cam kết lên mục tiêu đã đóng" đang chạy',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_muc_tieu_con_mo'
             and tgrelid = 'tieu_diem'::regclass and not tgisinternal)),

  (9, 'Khung nhìn tien_do_muc_tieu chạy bằng quyền người gọi',
   (select reloptions::text like '%security_invoker=on%' from pg_class
     where relname = 'tien_do_muc_tieu')),

  (10, 'Chỉ mục kho task đã có',
   exists (select 1 from pg_indexes where tablename = 'task'
             and indexname in ('task_trong_kho','task_theo_nguoi_camket'))),

  -- ĐÃ SỬA 08/08 sau đợt soi (mục 8 và 11, hai lăng kính độc lập cùng chỉ ra).
  -- Bản cũ bắt `count(task where ngay is null) = 0` — đúng ở LẦN CHẠY ĐẦU, lúc
  -- soi xem lệnh drop not null có làm hỏng dữ liệu cũ không. Nhưng từ lần thứ
  -- hai trở đi nó soi nhầm: task có ngay rỗng CHÍNH LÀ thứ tính năng kho sinh
  -- ra. Chạy lại file sau khi đội đã dùng kho là gặp "❌ CHƯA ĐẠT" giả, mà đầu
  -- bộ kiểm lại dặn có ❌ thì đừng mở app — file tự mâu thuẫn với chính nó.
  -- Nay soi đúng thứ cần soi: cột có cho phép rỗng hay không.
  (11, 'Cột task.ngay cho phép rỗng và ràng buộc cũ đã gỡ đúng',
   (select is_nullable = 'YES' from information_schema.columns
     where table_name = 'task' and column_name = 'ngay'))
)
select thu_tu, case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua, muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt sau khi chạy ───────────────────────────────────────
-- ① Kho của từng cam kết:
--    select tieu_diem_ma, count(*) from task where ngay is null group by 1;
-- ② Mục tiêu và số cam kết đang gánh nó:
--    select ten, so_cam_ket, cam_ket_xong, so_nguoi_ganh from tien_do_muc_tieu;
-- ③ Muốn quay lui mục 1 (hiếm khi cần, và chỉ chạy được khi kho đang rỗng):
--    alter table task alter column ngay set not null;
