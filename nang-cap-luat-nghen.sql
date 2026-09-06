-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `kiem_nghen_co_viec_go`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-luat-nghen.sql                          (Tracy chốt 2026-08-12)
--
-- Chạy lại nhiều lần VÔ HẠI. Dán trọn file vào SQL Editor rồi Run.
-- Xong thì nhìn bảng cuối cùng: cột `dat` phải TRUE đủ cả ba dòng.
--
-- NGUYÊN LÝ Tracy chốt 12/08:
--   *"có 1 nguyên lý thôi là có việc nghẽn thì phải có việc gỡ nghẽn"*
--
-- File này dựng lại HÀNG RÀO MÁY CHỦ đã chết âm thầm từ hôm qua.
--
-- ⚠️ VÌ SAO NÓ CHẾT. `va-luat-3b.sql` mục 5 dựng ràng buộc:
--       check (trang_thai <> 'Nghen' or length(trim(ghi_chu_chot)) > 0)
--    Rồi `nang-cap-co-doi-han-va-trang-thai.sql` mục 1 đổi tên trạng thái
--    `Nghen` → `Blocked` và xoá hẳn `Miss`. Từ giây phút ấy KHÔNG dòng nào
--    mang được giá trị 'Nghen' nữa, nên vế trái luôn đúng, nên cả ràng buộc
--    luôn đúng — nó còn nằm trên bảng, `\d task` vẫn liệt kê nó, mà nó không
--    chặn được gì. Đây là kiểu hỏng tệ nhất: cái khoá vẫn treo ở cửa, nhìn
--    vào tưởng cửa đang khoá.
--
-- KHÔNG có gì phải chuyển đổi dữ liệu: ràng buộc mới chỉ soi dòng ghi vào từ
-- lúc chạy trở đi, và mục 0 dưới đây kiểm trước xem dữ liệu ĐANG CÓ có dòng
-- nào vi phạm không — có thì file dừng, không ghi đè gì cả.
-- ════════════════════════════════════════════════════════════════════════════


-- ─── 0. SOI TRƯỚC — có dòng nào đang vi phạm không ──────────────────────────
-- `add constraint` chạy trên bảng có dòng vi phạm sẽ trả lỗi và bỏ dở nửa
-- chừng. Thà biết trước bằng một câu nói được tiếng người.
do $$
declare n int;
begin
  select count(*) into n from task
   where trang_thai = 'Blocked' and coalesce(trim(ghi_chu_chot),'') = '';
  if n > 0 then
    raise exception 'Có % việc đang Nghẽn mà không khai thứ đang chặn. Mở app, vào từng việc gõ một dòng vào ô Ghi chú, rồi chạy lại file này.', n;
  end if;
end $$;


-- ─── 1. DỰNG LẠI RÀNG BUỘC, lần này soi đúng tên đang chạy ──────────────────
-- Ràng buộc `check` chỉ soi được TRONG MỘT DÒNG, nên nó bảo đảm được vế
-- "nghẽn thì phải GỌI TÊN thứ đang chặn". Vế còn lại của nguyên lý — "phải có
-- một việc gỡ nghẽn" — cần nhìn sang dòng khác nên phải là trigger, xem mục 2.
alter table task drop constraint if exists nghen_phai_khai_thu_chan;
alter table task add  constraint nghen_phai_khai_thu_chan
  check (trang_thai <> 'Blocked' or length(trim(ghi_chu_chot)) > 0);


-- ─── 2. TRIGGER — nghẽn thì phải có việc gỡ đứng cạnh ───────────────────────
-- Cùng hình dạng với `kiem_da_chuyen` (va-luat-3b.sql mục 6), vì cùng một loại
-- luật: "dòng này chỉ hợp lệ khi có một dòng khác trỏ về nó".
--
-- CHỈ soi lúc việc ĐANG ĐỔI sang Blocked (`old.trang_thai is distinct from
-- new.trang_thai`). Không có mệnh đề ấy thì mọi lần sửa một việc đã nghẽn —
-- đổi tên, dời hạn — đều bị soi lại, và một việc mà con của nó đã bị xoá sẽ
-- kẹt cứng: không sửa được gì nữa cho tới khi tạo lại con.
--
-- `constraint trigger ... deferrable initially deferred`: app ghi CON TRƯỚC
-- CHA SAU, nhưng nếu ngày nào có chỗ ghi ngược thứ tự thì trigger thường sẽ
-- bắt oan. Hoãn tới lúc commit là chỉ soi kết quả cuối, không soi thứ tự.
create or replace function kiem_nghen_co_viec_go() returns trigger as $$
begin
  if new.trang_thai = 'Blocked'
     and old.trang_thai is distinct from new.trang_thai
     and not exists (select 1 from task c where c.task_cha = new.id)
  then
    raise exception 'Việc đang nghẽn phải có một việc gỡ nghẽn đứng cạnh (task_cha = %).', new.id;
  end if;
  return new;
end $$ language plpgsql;

drop trigger if exists tg_nghen_co_viec_go on task;
create constraint trigger tg_nghen_co_viec_go
  after update on task
  deferrable initially deferred
  for each row execute function kiem_nghen_co_viec_go();


-- ─── 3. TỰ KIỂM — ba dòng, `dat` phải TRUE hết ──────────────────────────────
select 'Ràng buộc soi đúng chữ Blocked, không còn soi chữ Nghen đã chết' as muc,
       (select pg_get_constraintdef(oid) from pg_constraint
         where conrelid = 'task'::regclass
           and conname  = 'nghen_phai_khai_thu_chan') like '%Blocked%' as dat
union all
select 'Trigger việc-gỡ-nghẽn đã nằm trên bảng task',
       exists (select 1 from pg_trigger
                where tgrelid = 'task'::regclass
                  and tgname  = 'tg_nghen_co_viec_go'
                  and not tgisinternal)
union all
select 'Không còn việc nghẽn nào thiếu tên thứ đang chặn',
       not exists (select 1 from task
                    where trang_thai = 'Blocked'
                      and coalesce(trim(ghi_chu_chot),'') = '');
