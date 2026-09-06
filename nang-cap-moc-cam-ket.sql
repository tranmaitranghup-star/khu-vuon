-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `tieu_diem.moc_id`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- NỐI CAM KẾT VÀO MỐC, VÀ CHO CAM KẾT MỘT NGÀY BẮT ĐẦU
-- Tracy chốt 2026-08-26 · chạy SAU `nang-cap-mang-du-an.sql`
-- ════════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO CÓ FILE NÀY. Tracy giao: *"tôi muốn giao diện bên trong mỗi dự án này
-- cũng được chia thành các bảng đặt cạnh nhau, mỗi milestone là 1 bảng và bên
-- trong milestone là các cam kết + PIC + Deadline + trạng thái và được đưa vào
-- gantt view"*. Soi máy chủ thì gặp một chỗ trống chặn đường:
--
--   `moc_du_an` treo dưới `muc_tieu` (dự án).
--   `tieu_diem` (cam kết) cũng treo dưới `muc_tieu`.
--   Nhưng HAI NHÁNH ẤY KHÔNG NỐI VỚI NHAU.
--
-- Nghĩa là không ai biết cam kết nào thuộc mốc nào — nên "bên trong milestone
-- là các cam kết" chưa dựng được bằng giao diện thuần.
--
-- HAI CỘT, KHÔNG PHẢI MỘT. Tracy chốt thêm: *"cam kết cần start và end date"*.
-- Cam kết đã có `han` (end) và `ngay_gieo`, nhưng NGÀY GIEO KHÔNG PHẢI NGÀY BẮT
-- ĐẦU: nó là ngày cam kết được tạo ra. Vẽ thanh Gantt theo nó là vẽ một quãng
-- không có thật — một cam kết gieo hôm nay cho việc tháng sau sẽ ra một thanh
-- dài ba mươi ngày trong khi chưa ai động tay.
--
-- VÌ SAO KHÔNG SUY MỐC THEO NGÀY. Cách rẻ hơn là không thêm cột, cứ cam kết nào
-- có hạn rơi vào trước mốc nào thì tính là của mốc ấy. Không chọn cách đó vì
-- xếp một cam kết vào mốc nào CHÍNH LÀ một quyết định — của người điều hành,
-- không phải của phép tính. Suy theo ngày thì Tracy không xếp lại được, mà dời
-- một mốc là mọi cam kết tự nhảy sang mốc khác trong im lặng.
--
-- VÌ SAO KHÔNG VÁ DỮ LIỆU CŨ. Cam kết đang có đều để `ngay_bat_dau` TRỐNG. Lấp
-- nó bằng `ngay_gieo` cho Gantt có cái mà vẽ là bịa ra một ngày chưa ai khai —
-- và về sau không cách nào phân biệt ngày thật với ngày máy đoán. Giao diện lo
-- chỗ này: cam kết chưa khai ngày bắt đầu thì thanh vẽ NÉT ĐỨT từ ngày gieo,
-- kèm chữ nói rõ đó là quãng ước, bấm vào khai được ngày thật.
--
-- ════════════════════════════════════════════════════════════════════════════


-- ⚠️ CHỮ NGƯỜI DÙNG ĐỌC LUÔN LÀ "milestone", KỂ CẢ TRONG THÔNG BÁO LỖI Ở ĐÂY —
-- lỗi máy chủ trả về hiện thẳng lên toast của app. Tên mã (`moc_du_an`, `moc_id`)
-- giữ tiếng Việt: cố ý lệch, đừng đồng bộ lại.
--
-- ════════════════════════════════════════════════════════════════════════════
-- 1. CỘT `moc_id` — cam kết thuộc mốc nào
-- ════════════════════════════════════════════════════════════════════════════
-- ON DELETE SET NULL, không CASCADE: xoá một mốc là bỏ một cái đích, KHÔNG phải
-- bỏ những việc người ta đã hứa. Cam kết rơi về bảng "Chưa xếp mốc" (Tracy chốt
-- 26/08 là giữ bảng đó) chứ không biến mất cùng cái mốc.
alter table tieu_diem add column if not exists moc_id bigint
  references moc_du_an (id) on delete set null;

comment on column tieu_diem.moc_id is
  'Milestone mà cam kết này gánh. NULL = chưa xếp milestone, vẫn thuộc dự án. Bắt buộc cùng dự án với cam kết — trigger tg_moc_cung_du_an canh.';

create index if not exists tieudiem_theo_moc on tieu_diem (moc_id)
  where moc_id is not null;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. HÀNG RÀO — mốc phải CÙNG DỰ ÁN với cam kết
-- ════════════════════════════════════════════════════════════════════════════
-- Khoá ngoại chỉ bảo đảm mốc CÓ THẬT, không bảo đảm mốc thuộc ĐÚNG dự án. Thiếu
-- hàng rào này thì gọi thẳng API gắn được cam kết của dự án A vào mốc của dự án
-- B, và phần trăm của cả hai dự án cùng sai mà không có lỗi nào báo.
--
-- Hai nhánh, cố ý xử lý khác nhau:
--   · Gán `moc_id` KHÔNG khớp dự án  → TRẢ LỖI. Đây là lệnh sai, phải nói ra.
--   · Đổi `muc_tieu_id` sang dự án khác → TỰ GỠ mốc. Đây là lệnh đúng, chỉ kéo
--     theo một hệ quả; bắt người dùng gỡ mốc trước rồi mới đổi được dự án là
--     bắt họ làm việc của máy.
create or replace function kiem_moc_cung_du_an() returns trigger
language plpgsql as $$
declare du_an_cua_moc bigint;
begin
  -- đổi dự án thì mốc cũ hết nghĩa — gỡ, không báo lỗi
  if tg_op = 'UPDATE' and new.muc_tieu_id is distinct from old.muc_tieu_id
     and new.moc_id is not distinct from old.moc_id then
    new.moc_id := null;
  end if;

  if new.moc_id is null then return new; end if;

  if new.muc_tieu_id is null then
    raise exception 'Cam kết chưa trỏ về dự án nào thì chưa xếp được vào milestone. Chọn dự án trước.';
  end if;

  select muc_tieu_id into du_an_cua_moc from moc_du_an where id = new.moc_id;
  if du_an_cua_moc is distinct from new.muc_tieu_id then
    raise exception 'Milestone này thuộc dự án khác. Cam kết chỉ xếp được vào milestone của chính dự án nó.';
  end if;

  return new;
end $$;

drop trigger if exists tg_moc_cung_du_an on tieu_diem;
create trigger tg_moc_cung_du_an before insert or update on tieu_diem
  for each row execute function kiem_moc_cung_du_an();


-- ════════════════════════════════════════════════════════════════════════════
-- 3. CỘT `ngay_bat_dau` — đầu kia của thanh Gantt
-- ════════════════════════════════════════════════════════════════════════════
alter table tieu_diem add column if not exists ngay_bat_dau date;

comment on column tieu_diem.ngay_bat_dau is
  'Ngày ĐỊNH BẮT TAY VÀO LÀM. Khác ngay_gieo (ngày cam kết được tạo ra) và khác han (ngày phải xong). NULL = chưa khai; giao diện vẽ thanh nét đứt từ ngay_gieo và nói rõ đó là quãng ước.';

-- Ràng buộc mềm: chỉ chặn thứ vô nghĩa (bắt đầu SAU khi phải xong), không ép
-- phải khai. Ép khai là dựng một cửa nữa trước mỗi lần gieo cam kết, mà gieo
-- cam kết là việc phải nhẹ tay nhất trong app.
alter table tieu_diem drop constraint if exists tieudiem_bat_dau_truoc_han;
alter table tieu_diem add  constraint tieudiem_bat_dau_truoc_han
  check (ngay_bat_dau is null or han is null or ngay_bat_dau <= han);


-- ════════════════════════════════════════════════════════════════════════════
-- 4. DÒNG TỰ KIỂM — chạy xong nhìn bảng này, đỏ chỗ nào sửa chỗ đó
-- ════════════════════════════════════════════════════════════════════════════
with kiem(stt, muc, dat) as (
  values
  (1, 'tieu_diem có cột moc_id',
   exists (select 1 from information_schema.columns
            where table_name = 'tieu_diem' and column_name = 'moc_id')),

  (2, 'Khoá ngoại moc_id là ON DELETE SET NULL (xoá milestone không kéo theo cam kết)',
   exists (select 1 from pg_constraint c
            where c.conrelid = 'tieu_diem'::regclass
              and c.contype = 'f' and c.confdeltype = 'n'
              and c.conkey::int[] = array[(select attnum::int from pg_attribute
                                     where attrelid = 'tieu_diem'::regclass
                                       and attname = 'moc_id')])),

  (3, 'Chỉ mục tieudiem_theo_moc đang có',
   to_regclass('public.tieudiem_theo_moc') is not null),

  (4, 'Trigger tg_moc_cung_du_an đang cắm trên tieu_diem',
   exists (select 1 from pg_trigger
            where tgrelid = 'tieu_diem'::regclass and not tgisinternal
              and tgname = 'tg_moc_cung_du_an')),

  (5, 'tieu_diem có cột ngay_bat_dau',
   exists (select 1 from information_schema.columns
            where table_name = 'tieu_diem' and column_name = 'ngay_bat_dau')),

  (6, 'Ràng buộc bắt đầu không được sau hạn đang chạy',
   exists (select 1 from pg_constraint
            where conrelid = 'tieu_diem'::regclass
              and conname = 'tieudiem_bat_dau_truoc_han')),

  -- Không có dòng nào kiểm "đã vá ngay_bat_dau chưa": một ngày trùng ngày gieo
  -- có thể là ngày người ta khai thật, không cách nào phân biệt với ngày máy
  -- đoán. Dòng kiểm không phân biệt được hai thứ ấy là dòng luôn xanh — đúng
  -- thứ `nang-cap-mang-du-an.sql` gọi là chuông báo cháy kêu khi không có lửa.

  (7, 'Không cam kết nào đang xếp vào milestone của dự án khác',
   not exists (select 1 from tieu_diem o join moc_du_an k on k.id = o.moc_id
                where k.muc_tieu_id is distinct from o.muc_tieu_id))
)
select stt,
       case when dat then '✔' else '✘ CHƯA ĐẠT' end as ket_qua,
       muc
from kiem order by stt;
