-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.so_cam_ket_toi_da`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- TRẦN CAM KẾT THEO TỪNG NGƯỜI — CEO 5 CHỖ, CÒN LẠI 3 CHỖ
-- Tracy chốt 12/08/2026. Dán trọn file vào Supabase › SQL Editor › Run.
-- Chạy lại nhiều lần vẫn ra cùng kết quả (idempotent).
--
-- VÌ SAO CÓ FILE NÀY
--
-- Luật "ba cam kết là hết chỗ" đang nằm ở HAI hàng rào máy chủ:
--   · ràng buộc `luong_trong_khoang_1_3` trên bảng `tieu_diem`
--   · chỉ mục `mot_hat_song_moi_luong` — mỗi luống chỉ một cam kết đang sống
-- Nới cho CEO mà chỉ sửa giao diện thì app cho gieo, máy chủ đá về ngay ở
-- luống thứ 4. Nên trần phải nới ở đây trước.
--
-- CÁCH LÀM: trần là MỘT CON SỐ TRÊN TỪNG NGƯỜI, không phải một hằng số trong
-- mã nguồn. Lý do chọn cột thay vì đọc theo `nguoi.vai = 'CEO'`: chính seed
-- của `schema.sql` ghi *"vai và phong_ban để trống — Tracy chốt 10/08 chức vụ
-- tạm bỏ đi"*, tức cột `vai` có thể rỗng trên máy chủ thật. Khoá luật vào một
-- cột có thể rỗng là luật tự tắt mà không báo gì. Sau này muốn nâng trần cho
-- ai thì sửa MỘT SỐ, không đụng mã nguồn app.
--
-- TRẦN ĐANG ÁP (Tracy chốt 12/08): CEO 5 · M-level (quản lý) 3 · nhân sự 3.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── 1. Cột trần trên bảng `nguoi` ─────────────────────────────────────────
-- Mặc định 3: người mới thêm vào đội tự có đúng luật cũ, không phải nhớ điền.
-- Trần trên là 5 vì giao diện chỉ có 5 lớp màu chỗ (l1…l5); cho phép số lớn
-- hơn là bày ra một cam kết không có màu nền, trông như dòng hỏng.
alter table nguoi add column if not exists so_cam_ket_toi_da smallint not null default 3;

alter table nguoi drop constraint if exists tran_cam_ket_1_5;
alter table nguoi add  constraint tran_cam_ket_1_5
  check (so_cam_ket_toi_da between 1 and 5);

comment on column nguoi.so_cam_ket_toi_da is
  'Số cam kết được giữ cùng lúc. Mặc định 3 cho cả đội; CEO 5 (Tracy chốt 12/08). Đây là nguồn duy nhất của luật "mấy cam kết là hết chỗ" — app đọc thẳng cột này, không có con số 3 nào nằm cứng trong mã nguồn nữa.';

-- Bảng `nguoi` không có policy INSERT/UPDATE nào (schema.sql chỉ mở `doc_nguoi`
-- cho SELECT), nên cột này chỉ đổi được từ SQL Editor. Người dùng gọi thẳng API
-- không tự nâng trần của mình được — không cần dựng thêm hàng rào nào.


-- ─── 2. Ai được mấy chỗ ────────────────────────────────────────────────────
-- Viết thành hai lệnh chứ không một lệnh gán: chạy lại file sau khi đội đổi
-- người thì trần cũng tự về đúng, kể cả khi ai đó được nâng nhầm trước đó.
--
-- Nhận diện CEO bằng CẢ email lẫn `vai` — email là mỏ neo chắc (khoá duy nhất,
-- dùng để đăng nhập), `vai` là đường dự phòng nếu sau này đổi email.
update nguoi set so_cam_ket_toi_da = 5
 where lower(email) = 'andy@vidu.com' or vai = 'CEO';

update nguoi set so_cam_ket_toi_da = 3
 where lower(email) <> 'andy@vidu.com' and coalesce(vai, '') <> 'CEO';


-- ─── 3. Nới ràng buộc luống 1–3 lên 1–5 ────────────────────────────────────
-- Giữ nguyên `not null` (vá ngày 08/08: `luong` rỗng đi vòng qua được cả hai
-- hàng rào). Chỉ nới khoảng, không nới kiểu.
alter table tieu_diem drop constraint if exists luong_trong_khoang_1_3;
alter table tieu_diem drop constraint if exists luong_trong_khoang_1_5;
alter table tieu_diem add  constraint luong_trong_khoang_1_5
  check (luong between 1 and 5);

comment on column tieu_diem.luong is
  'Chỗ ngồi 1–5. BẮT BUỘC có. Người dùng không nhìn thấy con số này (từ 08/08 giao diện đếm thứ tự nhận), nhưng nó là thứ giữ luật "mấy cam kết là hết chỗ". Trần thật của từng người nằm ở nguoi.so_cam_ket_toi_da và được trigger kiem_tran_cam_ket soi.';


-- ─── 4. Trigger: không ai ngồi quá trần CỦA MÌNH ───────────────────────────
-- Ràng buộc ở mục 3 chỉ nói "1 đến 5" — nó không biết ai được mấy chỗ. Không có
-- trigger này thì một người có trần 3 vẫn gọi thẳng API gieo được vào luống 5.
-- Cùng họ với lỗ hổng đã vá ngày 08/08: hàng rào soi ĐÚNG bảng của nó mà không
-- soi thứ nó phụ thuộc vào.
create or replace function kiem_tran_cam_ket()
returns trigger language plpgsql
security definer set search_path = public
as $$
declare tran smallint;
begin
  select so_cam_ket_toi_da into tran from nguoi where id = new.nguoi_id;
  tran := coalesce(tran, 3);
  if new.luong > tran then
    raise exception 'Người này chỉ có % chỗ cam kết, không nhận được vào chỗ thứ %', tran, new.luong;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_tran_cam_ket on tieu_diem;
create trigger trg_kiem_tran_cam_ket
  before insert or update of luong, nguoi_id on tieu_diem
  for each row execute function kiem_tran_cam_ket();

comment on function kiem_tran_cam_ket is
  'Chặn nhận cam kết vượt trần của chính người đó (nguoi.so_cam_ket_toi_da). Ràng buộc luong_trong_khoang_1_5 chỉ giữ khoảng chung 1–5; trần riêng từng người sống ở đây.';


-- ─── 5. Hai khung nhìn đang lọc cứng `luong between 1 and 3` ───────────────
-- Không sửa hai chỗ này thì cam kết ở chỗ 4 và 5 của CEO biến mất khỏi mọi con
-- số: bảng đo tab Cam kết đếm thiếu task, dấu ✅ đếm thiếu cam kết đã đóng.
-- Định nghĩa giữ nguyên từng chữ, chỉ đổi đúng con số — chép lại đầy đủ vì
-- `create or replace view` cần trọn câu lệnh.

-- 5a. dem_task_theo_o (nguồn: nang-cap-dem-o-may-chu.sql mục 1b)
create or replace view dem_task_theo_o as
select
  t.nguoi_id,
  t.tieu_diem_ma,
  t.trang_thai,
  count(*)                               as so,
  count(*) filter (where t.ngay is null) as so_kho
from task t
join tieu_diem o
  on o.ma = t.tieu_diem_ma and o.nguoi_id = t.nguoi_id
where not o.xong
  and o.luong between 1 and 5
group by t.nguoi_id, t.tieu_diem_ma, t.trang_thai;

alter view dem_task_theo_o set (security_invoker = on);

comment on view dem_task_theo_o is
  'Đếm task theo (người · cam kết còn mở · trạng thái). Chỉ gộp cam kết CHƯA đóng nên số dòng không lớn theo thời gian: nhiều nhất 12 người × 5 cam kết × 9 ô = 540. Thay cho việc app kéo 2000 dòng task về máy để tự đếm.';

-- 5b. dem_cam_ket_da_dong (nguồn: nang-cap-cam-ket-ca-doi.sql mục 1)
create or replace view dem_cam_ket_da_dong as
select
  n.id                                          as nguoi_id,
  count(o.ma) filter (where o.xong)             as so_da_dong
from nguoi n
left join tieu_diem o
       on o.nguoi_id = n.id
      and o.luong between 1 and 5
group by n.id;

alter view dem_cam_ket_da_dong set (security_invoker = on);

comment on view dem_cam_ket_da_dong is
  'Mỗi người đã đóng bao nhiêu cam kết, tính trọn đời. Một dòng mỗi người, kể cả người chưa đóng cái nào (0). Nuôi dấu ✅ ở màn Cam kết cả ROVA.';

commit;


-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ KIỂM — cả 5 dòng phải ra `dat = true`
-- ═══════════════════════════════════════════════════════════════════════════
select 'cot so_cam_ket_toi_da co mat' as kiem,
       count(*) = 1 as dat
  from information_schema.columns
 where table_name = 'nguoi' and column_name = 'so_cam_ket_toi_da'

union all
select 'dung MOT nguoi co tran 5 (CEO)',
       count(*) = 1 from nguoi where so_cam_ket_toi_da = 5

union all
select 'moi nguoi con lai deu tran 3',
       count(*) = 0 from nguoi
 where so_cam_ket_toi_da not in (3, 5)

union all
select 'rang buoc luong da noi len 1-5',
       count(*) = 1 from pg_constraint
 where conname = 'luong_trong_khoang_1_5'

union all
select 'trigger tran cam ket co mat',
       count(*) = 1 from pg_trigger
 where tgname = 'trg_kiem_tran_cam_ket';

-- Xem ai được mấy chỗ:
--   select ten, vai, so_cam_ket_toi_da from nguoi order by thu_tu;
