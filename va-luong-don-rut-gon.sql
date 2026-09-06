-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `task.so_lan_hoan`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- RÚT GỌN LUỒNG DỌN VIỆC HÔM QUA — Tracy chốt 08/08 sau khi xem flow vẽ lại
--
-- BA THỨ FILE NÀY LÀM
--   ① Gộp hai cột "task cha" đang chạy song song về MỘT.
--   ② Đổi thước đo của cái trần: từ SỐ ĐÊM sang SỐ LẦN HOÃN.
--   ③ Dựng lại khung nhìn viec_con_no theo thước đo mới.
--
-- VÌ SAO ĐỔI THƯỚC ĐO — chỗ kẹt phát hiện lúc ráp luồng mới:
--   Số ngày trễ tính từ `ngay_hen_dau`, mà cột này cố ý BẤT BIẾN. Ghép với luật
--   mới "quá trần thì chỉ được về kho" thì thành bẫy: việc trễ bốn đêm bị đẩy
--   về kho → vào kho đặt hạn thứ Sáu → tới thứ Sáu nó VẪN mang con số trễ mười
--   ngày → vẫn quá trần → lại chỉ được về kho. Việc đó không bao giờ ra khỏi
--   kho được nữa.
--   Gốc của kẹt là đo sai thứ: cái đáng đếm không phải "việc này đã đứng bao
--   nhiêu ngày" mà "tôi đã dời nó bao nhiêu lần". Dời sang thứ Sáu một cách có
--   chủ ý không phải là trễ; dời tới lần thứ tư thì đúng là có chuyện.
--   `ngay_hen_dau` GIỮ NGUYÊN, vẫn là mốc đo tuổi thật của việc — chỉ thôi
--   không dùng nó để khoá nút nữa.
--
-- Chạy được nhiều lần, không hỏng gì.
-- Chạy SAU: va-luat-3b.sql
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── 0. Gỡ khung nhìn cũ TRƯỚC ──────────────────────────────────────────────
-- Bắt buộc đứng đầu. Khung nhìn `viec_con_no` cũ chọn `t.*` nên nó bám vào
-- MỌI cột của bảng task, gồm cả `cha_id` sắp bị gỡ. Gỡ cột trước là Postgres
-- chặn ngay: "cannot drop column cha_id ... view viec_con_no depends on it".
-- Không dùng `cascade`: cascade sẽ lặng lẽ xoá luôn mọi thứ khác bám vào cột
-- đó mà không cho ta nhìn thấy. Gỡ đúng một khung nhìn, rồi dựng lại nó ở mục
-- 3 trong cùng giao dịch này — không có khoảnh khắc nào app mất khung nhìn.
drop view if exists viec_con_no;


-- ─── 1. Một cột cha, không phải hai ─────────────────────────────────────────
-- `cha_id` đến từ nang-cap-deepwork-tu-do.sql (cửa nghẽn của phiên deepwork),
-- `task_cha` đến từ va-luat-3b.sql. Hai cột cùng một nghĩa, và trigger
-- kiem_da_chuyen chỉ đếm con theo `task_cha` — nên mọi task con sinh ra từ
-- deepwork đang VÔ HÌNH với tầng luật 3b.
update task set task_cha = cha_id
 where task_cha is null and cha_id is not null;

alter table task drop column if exists cha_id;


-- ─── 2. Số lần hoãn — thước đo mới của cái trần ─────────────────────────────
-- Cộng một mỗi lần việc bị dời sang ngày khác hoặc bị đẩy về kho ở màn Dọn.
-- ĐẶT LẠI VỀ 0 khi người ta vào bảng kho và tự tay đặt cho nó một hạn mới:
-- đó là một lời hứa MỚI, có cân nhắc, chứ không phải một cú dời cho qua ngày.
-- Đây cũng là chỗ luồng thoát ra khỏi kho — không có nó thì lại kẹt như cũ.
alter table task add column if not exists so_lan_hoan int not null default 0;

alter table task drop constraint if exists so_lan_hoan_khong_am;
alter table task add  constraint so_lan_hoan_khong_am check (so_lan_hoan >= 0);

comment on column task.so_lan_hoan is
  'Số lần việc này bị dời ngày hoặc đẩy về kho ở màn Dọn. Về 0 khi được đặt hạn mới từ bảng kho. Quá 3 là hết cửa hẹn ngày, chỉ còn về kho.';


-- ─── 3. Dựng lại khung nhìn theo thước đo mới ───────────────────────────────
-- Phải drop rồi create chứ không `create or replace` được: cột `so_lan_hoan`
-- vừa thêm nằm trong `t.*` nên nó chen vào giữa danh sách cột của khung nhìn,
-- mà `create or replace view` không cho đổi thứ tự cột.
--
-- Đổi tên cờ `het_cua_lam_tiep` → `het_cua_hen_ngay` cho đúng việc nó làm: quá
-- trần thì không mất nút Làm tiếp, chỉ mất quyền CHỌN NGÀY — nút tự chuyển
-- thành Về kho. Để nguyên tên cũ là tên nói sai việc.
-- (Khung nhìn cũ đã gỡ ở mục 0, không gỡ lại ở đây.)
create view viec_con_no as
select
  t.*,
  greatest(0, hom_nay() - coalesce(t.ngay_hen_dau, t.ngay))::int as so_ngay_delay,
  (t.chot_luc is not null)                                        as da_chot,
  (t.so_lan_hoan >= 3)                                            as het_cua_hen_ngay
from task t
where t.ngay is not null
  and t.ngay < hom_nay()
  and t.trang_thai not in ('Done', 'Da_chuyen', 'Da_huy')
  -- Chốt HÔM NAY rồi thì thôi, mai hỏi lại. Thiếu dòng này là màn dọn thành
  -- vòng lặp không thoát được: task Nghen sau khi chốt vẫn quá ngày và vẫn mở,
  -- nên nó rơi lại vào khung nhìn ngay lập tức.
  and (t.chot_luc is null
       or (t.chot_luc at time zone 'Asia/Ho_Chi_Minh')::date < hom_nay());

alter view viec_con_no set (security_invoker = on);

comment on view viec_con_no is
  'Việc quá ngày mà chưa đóng. Màn "Dọn việc hôm qua" đọc thẳng khung nhìn này. het_cua_hen_ngay = đã hoãn từ 3 lần, ô ngày khoá lại, nút một chỉ còn Về kho.';

commit;


-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — đọc cột ket_qua, mọi dòng phải ✅
-- ═══════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'Cột cha_id đã gỡ, chỉ còn task_cha',
   (select count(*) = 0 from information_schema.columns
     where table_name = 'task' and column_name = 'cha_id')),

  (2, 'Cột so_lan_hoan đã có',
   (select count(*) = 1 from information_schema.columns
     where table_name = 'task' and column_name = 'so_lan_hoan')),

  (3, 'Không dòng nào mang số lần hoãn âm',
   (select count(*) = 0 from task where so_lan_hoan < 0)),

  (4, 'Khung nhìn viec_con_no đã dựng lại',
   exists (select 1 from information_schema.views
             where table_schema = 'public' and table_name = 'viec_con_no')),

  (5, 'Khung nhìn đã đổi sang cờ het_cua_hen_ngay',
   (select count(*) = 1 from information_schema.columns
     where table_name = 'viec_con_no' and column_name = 'het_cua_hen_ngay')),

  (6, 'Khung nhìn chạy bằng quyền người gọi (không rò kho người khác)',
   (select reloptions::text like '%security_invoker=on%'
      from pg_class where relname = 'viec_con_no')),

  (7, 'Trigger chặn Da_chuyen không con vẫn sống',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_da_chuyen' and not tgisinternal)),

  (8, 'Ràng buộc Nghẽn phải khai thứ chặn vẫn sống',
   exists (select 1 from pg_constraint
             where conrelid = 'task'::regclass and conname = 'nghen_phai_khai_thu_chan')),

  (9, 'task vẫn bật hàng rào RLS',
   (select rowsecurity from pg_tables where schemaname = 'public' and tablename = 'task'))
)
select thu_tu, case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua, muc
from kt order by thu_tu;


-- ── Xem việc còn nợ của mình ───────────────────────────────────────────────
--    select id, noi_dung, trang_thai, so_ngay_delay, so_lan_hoan, het_cua_hen_ngay
--      from viec_con_no order by so_lan_hoan desc, so_ngay_delay desc;
