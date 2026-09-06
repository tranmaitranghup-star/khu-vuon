-- ═══════════════════════════════════════════════════════════════════════════
-- GIỜ CHỮ ĐỔI, VÀ NEO Ý VÀO VIỆC CỐ ĐỊNH — Tracy duyệt 01/09/2026
--
-- Tệp này dọn ĐÚNG HAI món nợ mà làn GN2 (sổ ghi chú đổi trục) cố ý để lại vì
-- chúng không sửa được ở tầng máy khách. Tracy: *"làm luôn sql dọn cả 2 đi"*.
--
-- ── NỢ ①: HAI CHỖ GHI CHÚ KHÔNG BIẾT LÚC NÀO CHỮ CỦA MÌNH ĐỔI ─────────────
-- `task.ghi_chu_chot` và `phien_deepwork.ghi_chu` là chữ tự do, sửa được bất cứ
-- lúc nào, nhưng hai bảng ấy không có cột nào đo lúc CHỮ đổi. Sổ ghi chú vì thế
-- phải mượn `xong_luc` và `ket_thuc` — tức giờ XONG VIỆC và giờ KẾT PHIÊN. Sửa
-- lại một câu hôm nay thì dòng ấy vẫn đứng ở ngày cũ, và trong một sổ xếp theo
-- thời gian thì đó là một lời nói dối im lặng: không sai màn hình nào, chỉ sai
-- thứ tự, và sai theo kiểu không ai nghi.
--
-- ĐÓNG DẤU BẰNG TRIGGER, KHÔNG BẰNG MÁY KHÁCH — ba lý do, theo thứ tự quan trọng:
--   ① `task.ghi_chu_chot` có NHIỀU chỗ ghi (cửa ra phiên · form việc · sổ ghi
--      chú · nghi thức buổi tối). Bắt mọi chỗ nhớ đóng dấu là bắt trí nhớ làm
--      việc của lược đồ, và chỗ thứ năm mọc lên sau này sẽ quên.
--   ② Giờ của máy khách là giờ máy NGƯỜI DÙNG — lệch múi giờ, lệch đồng hồ, và
--      sửa được. `doc_cam_ket.sua_luc` đang là cột thời gian đáng tin nhất trong
--      cả sáu nguồn của sổ CHÍNH VÌ nó do máy chủ đóng.
--   ③ Trigger `before update OF <cột>` chỉ bắn khi câu lệnh có KÊ TÊN cột ấy,
--      nên mọi lượt cập nhật thường của `task` (tick trạng thái, kéo giờ, đổi
--      màu) không chạm tới nó. `task` là bảng nóng nhất app — điều này có giá.
--
-- KHÔNG BACKFILL, VÀ ĐÓ LÀ CHỦ Ý. Dòng cũ để `null` = *"không biết lúc nào"*,
-- và máy khách rơi về giờ mượn như hôm nay. Điền đại `xong_luc` vào là biến một
-- ô trống trung thực thành một con số trông như đã đo — sai kiểu tệ hơn.
--
-- ── NỢ ②: VIỆC CỐ ĐỊNH KHÔNG CÓ CHỖ ĐẬU CHO MỘT Ý MỚI ────────────────────
-- `ghi_chu` có ba dây neo — `tieu_diem_ma` · `task_id` · `phien_id` — nên một ý
-- CHỈ tới được việc cố định bằng đường vòng: phải có một PHIÊN đã chạy rồi mới
-- neo được vào phiên ấy. Muốn ghi một ý cho việc cố định lúc chưa vào phiên thì
-- không có cột nào nhận. Sổ ghi chú vì thế phải giấu nút ＋ Thêm ý ở đúng nhóm
-- ấy — một cái lỗ nhìn thấy được trên màn.
--
-- NEO VÀO `nhip`, KHÔNG NEO VÀO `viec_co_dinh` — hai lý do:
--   ① `nhip.viec_id` là NULL VĨNH VIỄN với dòng cũ (chốt "xây lại từ đầu" ở
--      `nang-cap-danh-muc-viec-co-dinh.sql`). Neo vào danh mục thì mọi nhịp
--      chưa trỏ danh mục đều không nhận được ý nào — tức đúng những việc đang
--      chạy hằng ngày lại là những việc không ghi chú được.
--   ② `phien_deepwork.nhip_id` đã đi đúng đường ấy từ `nang-cap-deepwork-tu-do`.
--      Hai cột cùng nghĩa nên cùng trỏ một chỗ; đẻ đường thứ hai là đẻ hai luật
--      phải giữ khớp bằng trí nhớ.
-- Sổ gộp NHIỀU TUẦN của cùng một việc về MỘT dòng (theo `viec_id`, hoặc theo
-- tên đã chuẩn hoá khi chưa có `viec_id`), nên neo vào nhịp của một tuần cụ thể
-- vẫn ra đúng chỗ.
--
-- `on delete set null` như ba dây neo kia: nhịp của một tuần bị xoá thì Ý VẪN
-- CÒN GIÁ TRỊ, nó chỉ rơi về nhóm Tự do chứ không biến mất theo.
--
-- Chạy tệp này lúc nào cũng được. App dò cột trước khi ghi: chưa chạy thì sổ
-- vẫn bày đủ, chỉ là nhóm Việc cố định chưa có nút ＋ Thêm ý và hai loại mẩu
-- kia vẫn mượn giờ như cũ. Chạy rồi thì lần mở app kế tiếp tự dùng lối mới.
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══ ① GIỜ CHỮ ĐỔI ════════════════════════════════════════════════════════

alter table task           add column if not exists ghi_chu_luc timestamptz;
alter table phien_deepwork add column if not exists ghi_chu_luc timestamptz;

comment on column task.ghi_chu_luc is
  'Lúc CHỮ trong ghi_chu_chot đổi lần gần nhất, do máy chủ đóng dấu. NULL = '
  'chưa từng đổi kể từ khi cột này có mặt; máy khách rơi về xong_luc. KHÁC '
  'chot_luc, vốn là lúc NGƯỜI chốt trạng thái cuối ngày.';
comment on column phien_deepwork.ghi_chu_luc is
  'Lúc CHỮ trong ghi_chu đổi lần gần nhất, do máy chủ đóng dấu. NULL = chưa '
  'từng đổi kể từ khi cột này có mặt; máy khách rơi về ket_thuc.';

-- Hai hàm riêng, KHÔNG một hàm chung đọc cột động qua `to_jsonb(new)->>tg_argv[0]`.
-- Bản chung ngắn hơn ba dòng nhưng dựng cả một bản JSON của mỗi dòng ở mỗi lượt
-- ghi, trên đúng bảng nóng nhất app. Trả ba dòng để không phải trả cái đó.
--
-- ⚠️ `nullif(btrim(...), '')` chứ không so thẳng: `task.ghi_chu_chot` khai
-- `not null default ''`, nên một việc mới sinh ra đã mang chuỗi rỗng. So thẳng
-- thì `'' is distinct from null` là ĐÚNG, và MỌI việc mới đều bị đóng dấu một
-- giờ ghi chú trong khi chưa có chữ nào. Quy rỗng về null trước là hết.
--
-- ⚠️ Tách nhánh INSERT / UPDATE bằng `tg_op` chứ không viết một biểu thức có
-- `old` bên trong `case`: trong trigger INSERT thì `OLD` chưa được gán, và
-- plpgsql tính cả nhánh không dùng tới.
create or replace function dong_dau_gc_task()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    if nullif(btrim(new.ghi_chu_chot), '') is not null then
      new.ghi_chu_luc := now();
    end if;
  elsif nullif(btrim(new.ghi_chu_chot), '')
        is distinct from nullif(btrim(old.ghi_chu_chot), '') then
    new.ghi_chu_luc := now();
  end if;
  return new;
end $$;

create or replace function dong_dau_gc_phien()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    if nullif(btrim(new.ghi_chu), '') is not null then
      new.ghi_chu_luc := now();
    end if;
  elsif nullif(btrim(new.ghi_chu), '')
        is distinct from nullif(btrim(old.ghi_chu), '') then
    new.ghi_chu_luc := now();
  end if;
  return new;
end $$;

-- `drop` rồi `create` để chạy lại tệp được. `update OF <cột>` là chỗ tiết kiệm:
-- câu lệnh không kê tên cột ấy thì trigger không bắn một lần nào.
drop trigger if exists dau_gc_task on task;
create trigger dau_gc_task
  before insert or update of ghi_chu_chot on task
  for each row execute function dong_dau_gc_task();

drop trigger if exists dau_gc_phien on phien_deepwork;
create trigger dau_gc_phien
  before insert or update of ghi_chu on phien_deepwork
  for each row execute function dong_dau_gc_phien();

-- ═══ ② NEO Ý VÀO NHỊP VIỆC CỐ ĐỊNH ════════════════════════════════════════

alter table ghi_chu add column if not exists nhip_id bigint
  references nhip (id) on delete set null;

comment on column ghi_chu.nhip_id is
  'Dây neo THỨ TƯ: ý thuộc một việc cố định, qua nhịp của tuần ấy. Trống cũng '
  'được, như ba dây kia. Sổ ghi chú gộp mọi tuần của cùng một việc về MỘT dòng.';

-- Chỉ mục một phần, đúng lối `ghi_chu_theo_phien` đã dựng: đại đa số dòng có
-- `nhip_id` trống, không việc gì phải đánh chỉ mục cho chúng.
create index if not exists ghi_chu_theo_nhip
  on ghi_chu (nhip_id) where nhip_id is not null;

-- Không thêm chính sách nào: `ghi_chu` đã có `doc_ghichu` / `ghi_ghichu` khoá
-- theo DÒNG, mà RLS của Postgres không đọc theo cột — một cột mới nằm trong
-- dòng đã khoá thì được khoá theo, không cần khai lại.

-- ── TỰ KIỂM — gộp một bảng, vì Supabase chỉ bày kết quả câu CUỐI ──────────
select 'cột giờ chữ đổi' as muc,
       coalesce(string_agg(table_name || '.' || column_name, ' · ' order by table_name), '⚠️ CHƯA CÓ') as ket_qua
  from information_schema.columns
 where column_name = 'ghi_chu_luc' and table_name in ('task','phien_deepwork')
union all
select 'dây neo nhịp',
       coalesce(string_agg(column_name, ' · '), '⚠️ CHƯA CÓ')
  from information_schema.columns
 where table_name = 'ghi_chu' and column_name = 'nhip_id'
union all
select 'khoá ngoại của dây neo',
       coalesce(string_agg(conname || ' → ' || confrelid::regclass::text, ' · '), '⚠️ CHƯA CÓ')
  from pg_constraint
 where conrelid = 'ghi_chu'::regclass and contype = 'f'
   and conkey = array[(select attnum from pg_attribute
                        where attrelid = 'ghi_chu'::regclass and attname = 'nhip_id')]
union all
select 'trigger đóng dấu',
       coalesce(string_agg(tgname || ' trên ' || tgrelid::regclass::text, ' · ' order by tgname), '⚠️ CHƯA CÓ')
  from pg_trigger
 where tgname in ('dau_gc_task','dau_gc_phien') and not tgisinternal
union all
select 'trigger chỉ bắn khi cột ấy bị kê tên',
       coalesce(string_agg(tgname || ': ' || coalesce(
         (select string_agg(a.attname, '+') from pg_attribute a
           where a.attrelid = t.tgrelid and a.attnum = any(t.tgattr)), 'MỌI CỘT ⚠️'), ' · '), '—')
  from pg_trigger t
 where t.tgname in ('dau_gc_task','dau_gc_phien') and not t.tgisinternal
union all
select 'chỉ mục nhịp',
       coalesce(string_agg(indexname, ' · '), '⚠️ CHƯA CÓ')
  from pg_indexes where tablename = 'ghi_chu' and indexname = 'ghi_chu_theo_nhip';
