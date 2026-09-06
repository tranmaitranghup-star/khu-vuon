-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: ba cột đổi hạn — `nang-cap-ghi-chu.sql` cũng thêm đúng ba cột ấy
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-co-doi-han-va-trang-thai.sql          (Tracy giao 2026-08-11)
--
-- Chạy lại nhiều lần VÔ HẠI. Dán trọn file vào SQL Editor rồi Run.
-- Xong thì nhìn bảng cuối cùng: cột `dat` phải TRUE đủ cả năm dòng.
--
-- Gồm hai việc chung một mẻ vì cả hai đều đụng lớp dữ liệu:
--   ① Đổi tên trạng thái  Nghen → Blocked, bỏ hẳn Miss
--   ② Cắm bộ đếm DỜI HẠN cho cam kết, do máy chủ tự ghi
-- ════════════════════════════════════════════════════════════════════════════


-- ─── 1. TRẠNG THÁI TASK ─────────────────────────────────────────────────────
--
-- Vì sao đổi được rẻ: đo trên sao lưu 11/08 thì `Nghen` có 0 dòng và `Miss`
-- có 0 dòng. Không phải chuyển một dòng dữ liệu thật nào.
--
-- Vì sao BỎ `Miss`: không một dòng mã nào trong index.html hay trong 20 file
-- .sql từng ghi giá trị này xuống. Nó nằm trong ràng buộc từ schema.sql:141,
-- có ô lọc, có nút ở màn Dọn — nhưng nút ấy chỉ mở làn B rồi kết quả bị ghi
-- đè thành Confirm. Một giá trị không có người viết thì để lại chỉ gây nhầm.
--
-- Vì sao GIỮ `Chua_xong`, `Da_huy`, `Da_chuyen` nguyên tên: Tracy chốt 11/08
-- (*"giữ chưa xong đi, từ kia khó nhớ quá"*). `Da_chuyen` giữ trong ràng buộc
-- dù cửa sinh ra nó đã gỡ — có 1 dòng lịch sử đang mang giá trị đó, đụng vào
-- là viết lại lịch sử để đổi lấy đúng một chữ.

alter table task drop constraint if exists task_trang_thai_check;
alter table task drop constraint if exists task_trang_thai_hop_le;

-- Bỏ ràng buộc TRƯỚC rồi mới chuyển, vì ràng buộc cũ chưa biết chữ 'Blocked'.
-- Cả hai câu dưới hôm nay chạm 0 dòng; để đây phòng trường hợp có dòng mới
-- sinh ra giữa lúc đo và lúc bạn chạy file này.
update task set trang_thai = 'Blocked'   where trang_thai = 'Nghen';
update task set trang_thai = 'Chua_xong' where trang_thai = 'Miss';

alter table task add constraint task_trang_thai_hop_le
  check (trang_thai in (
    'Confirm', 'Doing', 'Done',
    'Chua_xong', 'Blocked', 'Da_chuyen', 'Da_huy'
  ));

comment on column task.ghi_chu_chot is
  'Câu trả lời bắt buộc lúc chốt. Chua_xong: tiến độ tới đâu. Blocked: thứ đang chặn. Da_huy: lý do dừng. Nghĩa do trang_thai quyết định.';


-- ─── 2. CỜ DỜI HẠN CHO CAM KẾT ──────────────────────────────────────────────
--
-- Bệnh nó chữa: cột `han` chỉ giữ giá trị HIỆN TẠI. Dời hạn là ghi đè, hạn cũ
-- biến mất không dấu vết — cùng đúng một bệnh với chẩn đoán ở màn Dọn.
--
-- Ba cột, không phải một, vì ba câu hỏi khác nhau:
--   han_goc         — lần đầu hứa là ngày nào
--   so_lan_doi_han  — đã dời mấy lần   (KHÔNG BAO GIỜ về 0, kể cả khi đóng)
--   ngay_troi       — tổng cộng trượt bao nhiêu ngày so với lời hứa đầu

alter table tieu_diem add column if not exists han_goc        date;
alter table tieu_diem add column if not exists so_lan_doi_han int not null default 0;
alter table tieu_diem add column if not exists ngay_troi      int not null default 0;

comment on column tieu_diem.han_goc        is 'Hạn lần đầu được đặt. Máy chủ ghi, không ai sửa được từ app.';
comment on column tieu_diem.so_lan_doi_han is 'Số lần hạn bị ĐẨY RA XA. Kéo gần lại không tính. Không bao giờ về 0.';
comment on column tieu_diem.ngay_troi      is 'Tổng số ngày đã trượt so với han_goc.';

-- 11 cam kết đang có hạn: coi hạn hiện tại là hạn gốc, vì trước hôm nay
-- không có chỗ nào ghi lại lần dời nào cả. Đây là vạch xuất phát, không
-- phải bản dựng lại lịch sử — và nói rõ ra để sau này không ai đọc nhầm.
update tieu_diem set han_goc = han where han is not null and han_goc is null;

create or replace function ghi_doi_han() returns trigger as $$
begin
  -- Ba dòng này là chỗ cả cơ chế đứng hay đổ: bộ đếm CHỈ do máy chủ ghi.
  -- Mọi giá trị app gửi lên cho ba cột đó đều bị bỏ, nên không ai gột được
  -- vết dời hạn của mình bằng cách gửi thẳng một câu update.
  new.so_lan_doi_han := coalesce(old.so_lan_doi_han, 0);
  new.ngay_troi      := coalesce(old.ngay_troi, 0);
  new.han_goc        := old.han_goc;

  if old.han is null and new.han is not null then
    -- Lần đầu đặt hạn KHÔNG phải dời hạn. Chưa hứa thì chưa lỡ hẹn.
    new.han_goc := new.han;

  elsif old.han is not null and new.han is not null and new.han > old.han then
    -- Chỉ đếm khi ĐẨY RA XA. Kéo hạn về gần là chuyện tốt, phạt nó thì
    -- người ta sẽ không bao giờ dám rút ngắn một lời hứa nào nữa.
    new.so_lan_doi_han := new.so_lan_doi_han + 1;
    new.ngay_troi      := new.ngay_troi + (new.han - old.han);
  end if;

  return new;
end $$ language plpgsql;

-- `before update` chứ không phải `before update of han`: phải chặn cả đường
-- sửa thẳng ba cột đếm mà không đụng tới `han`.
drop trigger if exists tg_doi_han on tieu_diem;
create trigger tg_doi_han before update on tieu_diem
  for each row execute function ghi_doi_han();


-- ─── 3. TỰ KIỂM — năm dòng, `dat` phải TRUE hết ─────────────────────────────

select 'Không còn task nào mang Nghen hay Miss' as muc,
       not exists (select 1 from task where trang_thai in ('Nghen','Miss')) as dat
union all
select 'Ràng buộc mới đã nhận chữ Blocked',
       coalesce((select pg_get_constraintdef(oid) from pg_constraint
                  where conname = 'task_trang_thai_hop_le'), '') like '%Blocked%'
union all
select 'Bảng tieu_diem có đủ ba cột mới',
       (select count(*) from information_schema.columns
         where table_name = 'tieu_diem'
           and column_name in ('han_goc','so_lan_doi_han','ngay_troi')) = 3
union all
select 'Mọi cam kết đang có hạn đều đã có han_goc',
       not exists (select 1 from tieu_diem where han is not null and han_goc is null)
union all
select 'Trigger tg_doi_han đã cắm trên tieu_diem',
       exists (select 1 from pg_trigger where tgname = 'tg_doi_han' and not tgisinternal);
