-- ═══════════════════════════════════════════════════════════════════════════
-- LOẠI VIỆC CỐ ĐỊNH — việc sinh từ một sự kiện LẶP LẠI thôi bị kể là phát sinh
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Dấu vết riêng trên máy chủ: cột `task.loai_viec`                        │
-- └─────────────────────────────────────────────────────────────────────────┘
-- Tracy chốt 2026-09-01. Chạy MỘT LẦN trong SQL Editor của Supabase.
-- Chỉ thêm, không xoá. Chạy SAU `nang-cap-loai-phien.sql`.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- BỆNH. Mỗi sự kiện của hôm nay tự đẻ ra một việc của tôi (`task.lich_id`).
-- Việc ấy không mang mã cam kết nào, nên nó rơi hết vào nhóm `phat_sinh` của
-- dải Giờ deepwork. Nhưng một cuộc họp giao ban HẰNG TUẦN không phải việc ập
-- tới — nó đã nằm trên lịch từ trước. Hệ quả: bảng đo kể sai CẢ HAI vế, phần
-- "đã hoạch định" thấp hơn sự thật và phần "phát sinh" phồng lên vì một thứ
-- chẳng phát sinh gì cả. Chính con số đáng để mắt nhất của khối lại là con số
-- kém tin cậy nhất.
--
-- THUỐC. Thêm một loại khai được cho việc: `co_dinh`. Ba điều khoản nền, chép
-- lại đây để lần sau ai đụng vào còn tra được:
--   · Một sự kiện định kỳ là BẢN MÔ TẢ VIỆC, mỗi buổi diễn ra là MỘT LƯỢT —
--     hai vật khác loại, không được gộp (Workflow Management Coalition,
--     WFMC-TC-1011). Ở đây `lich_chung` giữ khuôn, `task` giữ lượt.
--   · Cái kích một lượt của nó là cò Timer kiểu timeCycle, chu kỳ tính từ lịch
--     (BPMN 2.0.2 bảng 10.84 và 10.101) — đúng tiêu chí 1 của loại cố định ①
--     trong đặc tả Tracy duyệt 31/08.
--   · Phép thử phân biệt: việc này để GIỮ một mức hay ĐẠT một mức (cặp SDCA và
--     PDCA của Toyota). Họp giao ban hằng tuần là giữ mức, nên là việc cố định.
--
-- LUẬT KHÔNG GIỮ NGẦM (Tracy chốt 01/09). Cam kết và loại việc là hai trục
-- khác nhau, mà ô chọn chỉ hiện được một dòng. Nên chọn cam kết là THÔI cố
-- định: app ghi `loai_viec = null`. Cố ý không giữ lại một giá trị mà người
-- dùng không nhìn thấy và không sửa được. Không mất gì: việc vẫn mang `lich_id`
-- và sự kiện gốc vẫn mang `lap`, nên câu "việc này có định kỳ không" lúc nào
-- cũng tra ngược được từ nguồn.
--
-- Vì sao nhãn phải xuống tới TẬN dòng phiên (`phien_deepwork.viec_co_dinh`) chứ
-- không join sang `task`: đúng lý do `nang-cap-loai-phien.sql` đã ghi hôm qua —
-- khung nhìn chạy `security_invoker = on`, nên khi NGƯỜI KHÁC xem dải Giờ
-- deepwork, việc nằm trong kho của tôi bị `doc_task` giấu, phần join trả rỗng
-- và phiên rơi nhầm loại. Bộ tự kiểm mục 2 vẫn canh chữ `task` trong khung nhìn.

-- 🪤 BẪY ĐÃ CẮN, VÁ 02/09 — chép lại vì nó sẽ tái diễn với mọi cột boolean sau.
-- Bản đầu viết `set viec_co_dinh = (t.loai_viec = 'co_dinh')`. Trong Postgres,
-- so sánh một giá trị NULL cho ra **NULL, không phải false** — mà `loai_viec`
-- NULL chính là đại đa số dòng (mọi việc phát sinh và mọi việc có cam kết). Nên
-- câu lấp ghi NULL đè lên NULL, và mục 9 bộ tự kiểm đỏ đúng như nó sinh ra để
-- làm. Chữa bằng `is not distinct from`, phép so sánh luôn trả true hoặc false.
--
-- Vì sao tệp hôm trước không dính: nó viết `(t.tieu_diem_ma is not null)` —
-- một phép hỏi NULL, vốn đã luôn trả true/false. Chép sang một phép so sánh
-- BẰNG là đổi mất tính chất ấy mà nhìn thì y hệt.
--
-- Hậu quả thật thì nhẹ: khung nhìn đọc NULL trong `case ... when` thành "không
-- đúng" nên phiên vẫn rơi về đúng nhóm phát sinh. Cái mất là bất biến "gắn việc
-- thì phải có nhãn" — và đúng luật đã ghi hôm qua: **ghi false KHÁC bỏ trống**,
-- bỏ trống nghĩa là "chưa biết", tức mời một lượt ghi nữa đi điền lại.
--
-- CHẠY LẠI TRỌN TỆP NÀY là xong: mọi câu đều chạy lại được, và câu lấp có sẵn
-- `and p.viec_co_dinh is null` nên nó nhặt đúng những dòng còn trống.

begin;

-- ── 1. Hai cột mới ────────────────────────────────────────────────────────
alter table task
  add column if not exists loai_viec text;

comment on column task.loai_viec is
  'Loại việc do NGƯỜI DÙNG khai, khi việc không thuộc cam kết nào. NULL = việc phát sinh (mặc định, và cũng là giá trị app ghi khi người ta chọn một cam kết — xem luật không giữ ngầm ở đầu tệp). co_dinh = việc lặp theo lịch; app gieo sẵn giá trị này lúc đẻ việc từ một sự kiện có lap <> khong, từ đó về sau là của người dùng.';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'task_loai_viec_hop_le') then
    alter table task add constraint task_loai_viec_hop_le
      check (loai_viec is null or loai_viec in ('co_dinh', 'phat_sinh'));
  end if;
end $$;
-- Ghi chú: 'phat_sinh' để dành, app KHÔNG ghi giá trị này — phát sinh là NULL.
-- Có nó trong ràng buộc để ngày nào cần khai tay "cố ý là việc phát sinh" thì
-- không phải sửa ràng buộc trên bảng đang có dữ liệu.

alter table phien_deepwork
  add column if not exists viec_co_dinh boolean;

comment on column phien_deepwork.viec_co_dinh is
  'Lúc mở phiên, việc gắn với nó có được khai là việc cố định hay không. Chép xuống đây để dải Giờ deepwork phân loại được mà KHÔNG phải join sang task — join ấy chịu RLS nên với người khác nó trả rỗng và phiên bị xếp nhầm. NULL = phiên không gắn việc (phiên nhịp), hoặc dòng cũ chưa lấp.';

-- ── 2. Lấp cho dữ liệu cũ ─────────────────────────────────────────────────
-- Chạy trong SQL Editor nên hai câu này thấy toàn bộ bảng, không bị RLS che.
-- Thứ tự bắt buộc: lấp `task` TRƯỚC, vì câu lấp phiên đọc lại chính cột ấy.
update task t
   set loai_viec = 'co_dinh'
  from lich_chung l
 where l.id = t.lich_id
   and l.lap is distinct from 'khong'
   and t.tieu_diem_ma is null      -- luật không giữ ngầm: có cam kết thì thôi cố định
   and t.loai_viec is null;

-- ⚠️ `is not distinct from` chứ KHÔNG phải `=`. Xem bẫy ở đầu tệp: với việc
-- chưa khai loại (đại đa số), `t.loai_viec = 'co_dinh'` trả NULL chứ không trả
-- false, nên câu này từng ghi NULL đè lên NULL và mục 9 bộ tự kiểm đỏ.
update phien_deepwork p
   set viec_co_dinh = (t.loai_viec is not distinct from 'co_dinh')
  from task t
 where t.id = p.task_id
   and p.viec_co_dinh is null;

-- ── 3. Giữ cột luôn đúng, hai chiều ───────────────────────────────────────
-- Chiều VÀO: app cũ chưa tải lại trang vẫn chèn phiên không kèm cột mới —
-- trigger điền hộ, nên không có cửa nào đẻ ra dòng thiếu nhãn.
create or replace function dat_viec_co_dinh()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.task_id is not null and new.viec_co_dinh is null then
    -- `is not distinct from` giữ kết quả luôn là true/false. Còn `coalesce` ở
    -- dòng dưới để đỡ nốt ca task_id trỏ vào một dòng không còn: lúc ấy `select
    -- into` không tìm thấy gì và biến giữ nguyên NULL, không phải false.
    select (t.loai_viec is not distinct from 'co_dinh') into new.viec_co_dinh
      from task t where t.id = new.task_id;
    new.viec_co_dinh := coalesce(new.viec_co_dinh, false);
  end if;
  return new;
end $$;

drop trigger if exists tg_phien_viec_co_dinh on phien_deepwork;
create trigger tg_phien_viec_co_dinh
  before insert on phien_deepwork
  for each row execute function dat_viec_co_dinh();

-- Chiều ĐỔI: khai lại loại việc SAU khi đã chạy phiên thì cột trên phiên phải
-- đi theo. Không có nhánh này thì cột đúng lúc ghi rồi lệch dần theo tháng —
-- kiểu sai khó thấy nhất, vì nó đúng ở hôm đầu.
create or replace function dong_bo_viec_co_dinh()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.loai_viec is distinct from old.loai_viec then
    update phien_deepwork
       set viec_co_dinh = (new.loai_viec is not distinct from 'co_dinh')
     where task_id = new.id;
  end if;
  return new;
end $$;

drop trigger if exists tg_task_dong_bo_viec_co_dinh on task;
create trigger tg_task_dong_bo_viec_co_dinh
  after update of loai_viec on task
  for each row execute function dong_bo_viec_co_dinh();

-- ── 4. Khung nhìn — thêm MỘT nhánh, vẫn KHÔNG một chữ `task` nào ───────────
-- Thứ tự nhánh là thứ tự ưu tiên, và nó có lý do:
--   · `nhip_id` đứng đầu vì phiên nhịp không gắn việc nào, hai nhánh dưới
--     không có gì để đọc.
--   · `co_cam_ket` đứng trên `viec_co_dinh` theo đúng luật không giữ ngầm:
--     việc có cam kết thì app đã xoá nhãn cố định, nên hai cột không bao giờ
--     cùng đúng. Thứ tự này chỉ là hàng rào thứ hai cho dữ liệu cũ.
--   · Hai nhánh cùng trả 'co_dinh' là CỐ Ý: nhịp của riêng mình và buổi lặp
--     trên lịch chung là cùng một loại việc, chỉ khác chỗ ở.
create or replace view gio_deepwork_theo_loai as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  case
    when p.nhip_id is not null then 'co_dinh'
    when p.co_cam_ket          then 'cam_ket'
    when p.viec_co_dinh        then 'co_dinh'
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
  'Phút và số phiên deepwork gộp theo (người × ngày giờ Việt Nam × loại việc). Ba loại rời nhau và phủ hết. TỪ 01/09/2026 KHÔNG còn join sang task: nhãn đọc thẳng từ nhip_id, co_cam_ket và viec_co_dinh trên chính phiên. Nhờ vậy người khác xem dải này thấy đúng loại, kể cả khi việc gắn với phiên đang nằm trong kho và bị doc_task giấu. Nhóm co_dinh gồm CẢ nhịp của riêng mình lẫn việc sinh từ một sự kiện lặp lại trên lịch chung. Cùng bộ lọc phiên và cùng trần 180 phút với gio_deepwork_theo_ngay nên tổng hai bên khớp nhau — bất biến cũ, mục 5 và 6 bộ tự kiểm vẫn canh. Nuôi dải Giờ deepwork ở màn Cả ROVA.';

commit;

-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy sau khi commit. Mọi dòng phải `dat = true`.
-- ═══════════════════════════════════════════════════════════════════════════
with kiem(stt, dieu, dat) as (values

  (1, 'Cột loai_viec đã có trên task',
   exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'task'
               and column_name = 'loai_viec')),

  (2, 'Cột viec_co_dinh đã có trên phien_deepwork',
   exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'phien_deepwork'
               and column_name = 'viec_co_dinh')),

  /* ⚠️ DÒNG QUAN TRỌNG NHẤT của file này, giữ nguyên từ tệp hôm qua. Còn một
     chữ `task` trong định nghĩa khung nhìn là cái bệnh vẫn còn nguyên — nhãn
     lại đi qua một hàng rào đọc, và với người khác nó lại trả rỗng. */
  (3, 'Khung nhìn KHÔNG còn join sang task',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) not ilike '%task%'),

  (4, 'Khung nhìn đã đọc cột viec_co_dinh',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) like '%viec_co_dinh%'),

  (5, 'Khung nhìn vẫn bật security_invoker (không vượt mặt RLS)',
   (select count(*) from pg_class
      where relname = 'gio_deepwork_theo_loai'
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  (6, 'Khung nhìn vẫn kẹp trần 180 phút',
   pg_get_viewdef('gio_deepwork_theo_loai'::regclass) like '%180%'),

  /* Bất biến cũ, giữ nguyên: khung nhìn bỏ sót phiên nào thì tổng của nó thấp
     hơn `gio_deepwork_theo_ngay`. Cho lệch 2 phút mỗi cặp vì hai bên làm tròn
     ở hai mức khác nhau — sai số làm tròn, không phải dòng bị mất. */
  (7, 'Tổng phút vẫn khớp gio_deepwork_theo_ngay',
   not exists (
     select 1
     from (select nguoi_id, ngay, sum(phut) as p
             from gio_deepwork_theo_loai group by 1, 2) a
     full join (select nguoi_id, ngay, phut as p
             from gio_deepwork_theo_ngay) b using (nguoi_id, ngay)
     where abs(coalesce(a.p, 0) - coalesce(b.p, 0)) > 2)),

  (8, 'Số phiên khớp tuyệt đối',
   (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_loai)
   = (select coalesce(sum(so_phien), 0) from gio_deepwork_theo_ngay)),

  (9, 'Không còn phiên nào gắn việc mà thiếu nhãn cố định',
   not exists (select 1 from phien_deepwork
                where task_id is not null and viec_co_dinh is null)),

  /* Luật không giữ ngầm, canh ở tầng dữ liệu: không việc nào được vừa mang cam
     kết vừa mang nhãn cố định. Dòng này đỏ lên là có một cửa ghi nào đó đang
     đi vòng qua `manhLoai` trong app. */
  (10, 'Không việc nào vừa có cam kết vừa khai cố định',
   not exists (select 1 from task
                where tieu_diem_ma is not null and loai_viec is not null)),

  /* Phần đáng tiền của cả tệp: mọi việc đang mở sinh từ một sự kiện LẶP LẠI
     và chưa gắn cam kết thì phải mang nhãn cố định. Còn sót là câu lấp ở mục 2
     chạy hụt, hoặc app đang đẻ việc mà quên gieo nhãn. */
  (11, 'Mọi việc sinh từ sự kiện lặp lại đều đã có nhãn',
   not exists (select 1 from task t join lich_chung l on l.id = t.lich_id
                where l.lap is distinct from 'khong'
                  and t.tieu_diem_ma is null
                  and t.loai_viec is distinct from 'co_dinh')),

  /* Ngược lại: câu lấp ở mục 2 không được quét nhầm sang buổi MỘT LẦN.
     ⚠️ Dòng này chỉ đúng NGAY SAU khi chạy tệp. Về sau người dùng hoàn toàn có
     quyền khai tay một buổi một lần thành việc cố định, và lúc ấy nó đỏ lên
     một cách chính đáng — bảng `task` không có cột ghi dấu lần sửa nên không
     có cách nào tách hai ca. Đọc nó như một phép soát của lượt chạy, không
     phải một bất biến sống mãi. */
  (12, 'Câu lấp không quét nhầm sang buổi một lần',
   not exists (select 1 from task t join lich_chung l on l.id = t.lich_id
                where l.lap = 'khong' and t.loai_viec = 'co_dinh'))

)
select stt, case when dat then '✅' else '❌ HỎNG' end as ket, dieu
from kiem order by stt;
