-- ═══════════════════════════════════════════════════════════════════════════
-- GHI CHÚ RIÊNG CỦA TỪNG NGƯỜI CHO TỪNG BUỔI — Tracy duyệt 01/09/2026
--
-- Nguyên văn: *"note của từng thành viên tham gia là ô khác và chỉ có họ xem
-- được thôi, khác nhau của từng buổi"*.
--
-- ── BA TẦNG GHI CHÚ CỦA MỘT SỰ KIỆN, sau khi Tracy chốt *"Host 1 ô chung là
--    được"* ───────────────────────────────────────────────────────────────
--   ① `lich_chung.ghi_chu`  — MỘT ô, của CẢ CHUỖI, do người tạo gõ, cả đội đọc.
--      Đã có từ 31/08. Chỗ của thông tin cố định: link phòng họp, ai chủ trì.
--      Tệp này KHÔNG đụng tới nó, chỉ nâng cách bày nó ở phía app.
--   ② bảng dưới đây     — của TỪNG NGƯỜI, cho TỪNG BUỔI, chỉ mình họ đọc.
--   ③ `task.ghi_chu_chot` — ghi chú của VIỆC mà buổi ấy đẻ ra. Đã có, không đụng.
--
-- VÌ SAO MỘT BẢNG RIÊNG, KHÔNG THÊM CỘT VÀO `ghi_chu`. Bảng `ghi_chu` neo vào
-- ba thứ (cam kết · task · phiên) và từ 16/08 mỗi phiên deepwork ứng đúng một
-- dòng, viết đè lên chính nó. Nhét thêm một dây neo thứ tư vào đó là trộn hai
-- vòng đời khác nhau trong một bảng; mà cặp khoá của một LƯỢT sự kiện là
-- (lich_id, ngay_goc) — đúng cặp khoá ba bảng phụ của lịch đã dùng, không phải
-- một id đơn.
--
-- KHÔNG có dòng = chưa ghi gì. Cùng luật đọc với `lich_chung_tham_du`.
--
-- Chạy tệp này lúc nào cũng được: app dò bảng trong `doCotGio()` trước khi hỏi,
-- chưa chạy thì ô ghi chú riêng nói ra tên tệp phải chạy, mọi thứ còn lại chạy
-- y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists ghi_chu_buoi (
  lich_id   bigint not null references lich_chung (id) on delete cascade,
  ngay_goc  date   not null,
  nguoi_id  uuid   not null references nguoi (id) on delete cascade,
  noi_dung  text   not null default '',
  tao_luc   timestamptz not null default now(),
  sua_luc   timestamptz not null default now(),
  primary key (lich_id, ngay_goc, nguoi_id)
);

comment on table ghi_chu_buoi is
  'Ghi chú RIÊNG TƯ của một người cho MỘT LƯỢT của một sự kiện. Chỉ chủ dòng '
  'đọc được — kể cả lead cũng không. Khác hẳn lich_chung.ghi_chu, vốn là một ô '
  'chung của cả chuỗi do người tạo gõ và cả đội đọc.';

-- Chỉ mục theo NGƯỜI + NGÀY: câu hỏi "sổ ghi chú của tôi có gì" đi đường này.
-- Dựng sẵn ở đây thay vì đợi nhát 3, vì thêm chỉ mục lên bảng rỗng là tức thì
-- còn thêm lên bảng đã đầy thì khoá bảng.
create index if not exists gcbuoi_theo_nguoi
  on ghi_chu_buoi (nguoi_id, ngay_goc desc);

-- ═══ QUYỀN ════════════════════════════════════════════════════════════════
alter table ghi_chu_buoi enable row level security;

-- ĐỌC: CHỈ dòng của chính mình. Đây là chỗ khác hẳn ba bảng lịch kia — chúng
-- cho cả đội đọc vì lịch là việc chung, còn đây là sổ tay riêng. Lead cũng
-- không đọc được: một cái cửa hậu cho lead thì ô này thôi là chỗ ghi thật.
drop policy if exists doc_gc_buoi on ghi_chu_buoi;
create policy doc_gc_buoi on ghi_chu_buoi for select
  using (nguoi_id = nguoi_id_dang_nhap());

-- GHI: cũng chỉ dòng của chính mình, cả bốn cửa. `with check` chặn luôn cú đổi
-- `nguoi_id` sang người khác — sửa chữ thì được, sang tên thì không.
drop policy if exists ghi_gc_buoi on ghi_chu_buoi;
create policy ghi_gc_buoi on ghi_chu_buoi for all
  using      (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());

-- ── TỰ KIỂM — cả bốn câu phải chạy trót lọt ───────────────────────────────
-- ① Bảng đã có, đủ sáu cột.
select column_name, data_type, is_nullable
  from information_schema.columns
 where table_name = 'ghi_chu_buoi' order by ordinal_position;

-- ② Khoá chính đúng bộ ba.
select a.attname
  from pg_constraint c
  join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
 where c.conrelid = 'ghi_chu_buoi'::regclass and c.contype = 'p';

-- ③ Hàng rào quyền đã bật, và có đúng hai chính sách.
select relrowsecurity from pg_class where relname = 'ghi_chu_buoi';
select policyname, cmd from pg_policies where tablename = 'ghi_chu_buoi';

-- ④ Chỉ mục đã dựng.
select indexname from pg_indexes where tablename = 'ghi_chu_buoi';
