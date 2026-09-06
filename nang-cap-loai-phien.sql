-- ═══════════════════════════════════════════════════════════════════════════
-- NHÃN LOẠI VIỆC RỜI KHỎI `task` — vá phân loại sai ở dải Giờ deepwork
-- Tracy chốt 2026-09-01 sau khi đo: 6 phiên đang bị xếp nhầm (John 4 · Sydney 1
-- · Andy 1). Chạy MỘT LẦN trong SQL Editor của Supabase. Chỉ thêm, không xoá.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- BỆNH. `gio_deepwork_theo_loai` phân ba loại bằng cách `left join task` rồi
-- soi `t.tieu_diem_ma`. Khung nhìn ấy chạy `security_invoker = on` — đúng đắn,
-- nó không vượt mặt RLS — nhưng hệ quả là: khi NGƯỜI KHÁC xem dải Giờ deepwork
-- ở màn Cả ROVA, việc đang nằm trong kho của tôi bị `doc_task` giấu đi, phần
-- join trả rỗng, và phiên gắn việc ấy rơi vào nhóm `phat_sinh` thay vì loại
-- thật của nó. Bảng đo của đội nói sai về công việc của người ta.
--
-- Nó cũng là chỗ rò rỉ: chênh lệch giữa bản nhìn của chủ và bản nhìn của đồng
-- đội chính là dấu hiệu "người này có việc bị giấu". Nhẹ, nhưng có thật.
--
-- THUỐC. Nhãn loại KHÔNG được lấy bằng cách join sang `task` nữa. Nó phải nằm
-- trên chính `phien_deepwork`:
--   · `co_dinh`   suy từ `nhip_id` — đã có sẵn trên phiên, không cần gì thêm;
--   · `cam_ket` / `phat_sinh` cần MỘT cột mới, app ghi lúc mở phiên.
--
-- Vì sao là BOOLEAN chứ không phải mã cam kết: chú thích của khung nhìn cũ đã
-- nói rõ *"CỐ Ý không trả tieu_diem_ma, chỉ trả nhãn, để tính năng cam kết
-- riêng tư sau này không phải sửa khung nhìn"*. Chép mã cam kết xuống phiên là
-- dựng lại đúng cái rủi ro vừa gỡ, chỉ ở một bảng khác. Boolean đủ để phân
-- loại và không mang theo nội dung nào.

begin;

-- ── 1. Cột mới ────────────────────────────────────────────────────────────
alter table phien_deepwork
  add column if not exists co_cam_ket boolean;

comment on column phien_deepwork.co_cam_ket is
  'Lúc mở phiên, việc gắn với nó có mã cam kết hay không. Chép xuống đây để dải Giờ deepwork phân loại được mà KHÔNG phải join sang task — join ấy chịu RLS nên với người khác nó trả rỗng và phiên bị xếp nhầm vào phat_sinh. NULL = phiên không gắn việc (phiên nhịp), hoặc dòng cũ chưa lấp.';

-- ── 2. Lấp cho dữ liệu cũ ─────────────────────────────────────────────────
-- Chạy trong SQL Editor nên câu này thấy toàn bộ `task`, không bị RLS che.
update phien_deepwork p
   set co_cam_ket = (t.tieu_diem_ma is not null)
  from task t
 where t.id = p.task_id
   and p.co_cam_ket is null;

-- ── 3. Giữ cột luôn đúng, hai chiều ───────────────────────────────────────
-- Chiều VÀO: app cũ chưa tải lại trang vẫn chèn phiên không kèm cột mới —
-- trigger điền hộ, nên không có cửa nào đẻ ra dòng thiếu nhãn.
create or replace function dat_co_cam_ket()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.task_id is not null and new.co_cam_ket is null then
    select (t.tieu_diem_ma is not null) into new.co_cam_ket
      from task t where t.id = new.task_id;
  end if;
  return new;
end $$;

drop trigger if exists tg_phien_co_cam_ket on phien_deepwork;
create trigger tg_phien_co_cam_ket
  before insert on phien_deepwork
  for each row execute function dat_co_cam_ket();

-- Chiều ĐỔI: gắn một việc vào cam kết (hoặc gỡ ra) SAU khi đã chạy phiên thì
-- cột trên phiên phải đi theo. Không có nhánh này thì cột đúng lúc ghi rồi
-- lệch dần theo tháng — kiểu sai khó thấy nhất, vì nó đúng ở hôm đầu.
create or replace function dong_bo_co_cam_ket()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.tieu_diem_ma is distinct from old.tieu_diem_ma then
    update phien_deepwork
       set co_cam_ket = (new.tieu_diem_ma is not null)
     where task_id = new.id;
  end if;
  return new;
end $$;

drop trigger if exists tg_task_dong_bo_cam_ket on task;
create trigger tg_task_dong_bo_cam_ket
  after update of tieu_diem_ma on task
  for each row execute function dong_bo_co_cam_ket();

-- ── 4. Khung nhìn mới — KHÔNG một chữ `task` nào ───────────────────────────
create or replace view gio_deepwork_theo_loai as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  case
    when p.nhip_id is not null then 'co_dinh'
    when p.co_cam_ket          then 'cam_ket'
    else                            'phat_sinh'
  end                                               as loai,
  count(*)                                          as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.ket_thuc is not null
group by p.nguoi_id,
         (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date,
         3;

alter view gio_deepwork_theo_loai set (security_invoker = on);

comment on view gio_deepwork_theo_loai is
  'Phút và số phiên deepwork gộp theo (người × ngày giờ Việt Nam × loại việc). Ba loại rời nhau và phủ hết. TỪ 01/09/2026 KHÔNG còn join sang task: nhãn đọc thẳng từ nhip_id và co_cam_ket trên chính phiên. Nhờ vậy người khác xem dải này thấy đúng loại, kể cả khi việc gắn với phiên đang nằm trong kho và bị doc_task giấu. Cùng bộ lọc phiên và cùng trần 180 phút với gio_deepwork_theo_ngay nên tổng hai bên khớp nhau — bất biến cũ, mục 4 bộ tự kiểm vẫn canh. Nuôi dải Giờ deepwork ở màn Cả ROVA.';

commit;

-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy sau khi commit. Mọi dòng phải `dat = true`.
-- ═══════════════════════════════════════════════════════════════════════════
with kiem(stt, dieu, dat) as (values

  (1, 'Cột co_cam_ket đã có trên phien_deepwork',
   exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'phien_deepwork'
               and column_name = 'co_cam_ket')),

  /* ⚠️ DÒNG QUAN TRỌNG NHẤT của file này. Còn một chữ `task` trong định nghĩa
     khung nhìn là cái bệnh vẫn còn nguyên — nhãn lại đi qua một hàng rào đọc,
     và với người khác nó lại trả rỗng. */
  (2, 'Khung nhìn KHÔNG còn join sang task',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) not ilike '%task%'),

  (3, 'Khung nhìn vẫn bật security_invoker (không vượt mặt RLS)',
   (select count(*) from pg_class
      where relname = 'gio_deepwork_theo_loai'
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  (4, 'Khung nhìn vẫn kẹp trần 180 phút',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) like '%180%'),

  /* Bất biến cũ, giữ nguyên: khung nhìn mới bỏ sót phiên nào thì tổng của nó
     thấp hơn `gio_deepwork_theo_ngay`, và đúng phần chênh ấy là thứ người
     trong đội trừ ra được để suy ngược. Cho lệch 2 phút mỗi cặp vì hai bên
     làm tròn ở hai mức khác nhau — sai số làm tròn, không phải dòng bị mất. */
  (5, 'Tổng phút vẫn khớp gio_deepwork_theo_ngay',
   not exists (
     select 1
     from (select nguoi_id, ngay, sum(phut) as p
             from gio_deepwork_theo_loai group by 1, 2) a
     full join (select nguoi_id, ngay, phut as p
             from gio_deepwork_theo_ngay) b using (nguoi_id, ngay)
     where abs(coalesce(a.p, 0) - coalesce(b.p, 0)) > 2)),

  (6, 'Số phiên khớp tuyệt đối',
   (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_loai)
   = (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_ngay)),

  (7, 'Không còn phiên nào gắn việc mà thiếu nhãn',
   not exists (select 1 from phien_deepwork
                where task_id is not null and co_cam_ket is null)),

  /* Đối chiếu từng dòng với sự thật ở bảng `task`. Đây là dòng chứng minh
     phép lấp ở mục 2 đã chạy ĐÚNG, không chỉ chạy xong. */
  (8, 'Nhãn trên phiên khớp đúng mã cam kết của việc',
   not exists (select 1 from phien_deepwork p join task t on t.id = p.task_id
                where p.co_cam_ket is distinct from (t.tieu_diem_ma is not null))),

  (9, 'Trigger điền hộ lúc chèn đã có (app cũ chưa tải lại vẫn ghi đủ)',
   exists (select 1 from pg_trigger where tgname = 'tg_phien_co_cam_ket'
             and not tgisinternal)),

  (10, 'Trigger đồng bộ khi việc đổi cam kết đã có',
   exists (select 1 from pg_trigger where tgname = 'tg_task_dong_bo_cam_ket'
             and not tgisinternal)),

  /* Sáu dòng Tracy đếm được sáng 01/09 chính là tập này. Sau khi lấp, chúng
     phải mang nhãn thật — không còn dòng nào rơi vào phat_sinh chỉ vì việc của
     nó đang nằm trong kho. */
  (11, 'Phiên gắn việc trong kho nay vẫn có nhãn đúng',
   not exists (select 1 from phien_deepwork p join task t on t.id = p.task_id
                where t.ngay is null and p.co_cam_ket is null))
)
select stt, dieu, dat, case when dat then '✅' else '❌ PHẢI SỬA' end as ket
  from kiem order by stt;
