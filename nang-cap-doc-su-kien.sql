-- ═══════════════════════════════════════════════════════════════════════════
-- GHI CHÚ TỔNG CỦA MỘT CHUỖI SỰ KIỆN — Tracy duyệt 01/09/2026
--
-- Nguyên văn: *"tại kho ghi chú có 1 ghi chú tổng cho tất cả các sự kiện cùng
-- 1 chuỗi để tổng hợp vào"* → và khi tôi hỏi lại: *"ghi chú cho cả chuỗi thì
-- cũng nằm trong kho ghi chú thôi mà"*.
--
-- ĐÂY LÀ LUẬT THỨ HAI CÙNG HÌNH DẠNG với luật Tracy đã chốt cho cam kết:
--   · một CAM KẾT      = một ghi chú (`doc_cam_ket`, đã có từ 15/08)
--   · một CHUỖI SỰ KIỆN = một ghi chú (bảng này)
-- Cùng một ý: thứ gì có nhiều mẩu con thì kho bày MỘT dòng tổng.
--
-- VÌ SAO MỘT BẢNG RIÊNG, KHÔNG MƯỢN `lich_chung.ghi_chu`. Cột ấy đọc bằng
-- `la_thanh_vien()` — CẢ ĐỘI thấy. Ghi chú tổng này gom từ `ghi_chu_buoi` vốn
-- đã khoá chỉ-chủ, nên để chung một bảng là mở lại đúng thứ vừa khoá. RLS của
-- Postgres theo DÒNG chứ không theo CỘT, nên tách bảng là cách duy nhất. Đúng
-- lý do `doc_cam_ket` từng phải tách khỏi `tieu_diem` (xem nang-cap-doc-rieng-tu.sql).
--
-- MỘT NGƯỜI MỘT BẢN cho mỗi chuỗi — khoá `(lich_id, nguoi_id)`. Mười hai người
-- cùng dự một chuỗi thì có mười hai bản tổng, không ai đọc của ai.
--
-- ⚠️ KHÔNG CÓ CỘT `da_gop`, VÀ ĐÓ LÀ CHỦ Ý. `doc_cam_ket` có cột ấy để nhớ mẩu
-- nào đã trích, nhưng nó kéo theo hai tật: nó chỉ trả lời "đã TỪNG bị trích"
-- (xoá một dòng khỏi doc thì khoá vẫn ở lại), và phép trích chạy NGAY lúc mở
-- doc nên mở ra là âm thầm ghi. Bản này đi lối khác: ghi chú từng buổi KHÔNG bị
-- nuốt vào đâu cả — chúng nằm nguyên chỗ cũ và được bày làm NGUYÊN LIỆU ngay
-- dưới ô tổng hợp. Người ta đọc rồi tự viết. Không có gì biến mất, không có
-- lượt ghi nào xảy ra sau lưng.
--
-- Chạy tệp này lúc nào cũng được: app dò bảng trước khi hỏi, chưa chạy thì kho
-- ghi chú vẫn bày đủ các nguồn khác.
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists doc_su_kien (
  lich_id   bigint not null references lich_chung (id) on delete cascade,
  nguoi_id  uuid   not null references nguoi (id) on delete cascade,
  noi_dung  text   not null default '',
  tao_luc   timestamptz not null default now(),
  sua_luc   timestamptz not null default now(),
  primary key (lich_id, nguoi_id)
);

comment on table doc_su_kien is
  'Ghi chú TỔNG của một người cho cả một chuỗi sự kiện — chỗ để tổng hợp nội '
  'dung nhiều buổi vào. Chỉ chủ dòng đọc được. Khác ghi_chu_buoi ở chỗ: bảng '
  'kia một dòng một BUỔI, bảng này một dòng cả CHUỖI.';

-- Chỉ mục theo NGƯỜI: câu hỏi "kho ghi chú của tôi có gì" đi đường này, cùng
-- lối `gcbuoi_theo_nguoi` đã dựng cho ghi chú từng buổi.
create index if not exists docsk_theo_nguoi
  on doc_su_kien (nguoi_id, sua_luc desc);

-- ═══ QUYỀN ════════════════════════════════════════════════════════════════
alter table doc_su_kien enable row level security;

-- ĐỌC: CHỈ chủ dòng, kể cả lead. Đây là sổ tay riêng, không phải việc chung —
-- một cửa hậu cho lead thì ô này thôi là chỗ ghi thật.
drop policy if exists doc_docsukien on doc_su_kien;
create policy doc_docsukien on doc_su_kien for select
  using (nguoi_id = nguoi_id_dang_nhap());

-- GHI: cũng chỉ dòng của chính mình, cả bốn phép. `with check` chặn luôn cú đổi
-- `nguoi_id` sang người khác — sửa chữ thì được, sang tên thì không.
drop policy if exists ghi_docsukien on doc_su_kien;
create policy ghi_docsukien on doc_su_kien for all
  using      (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());

-- ── TỰ KIỂM — gộp một bảng, vì Supabase chỉ bày kết quả câu CUỐI ──────────
select 'cột' as muc, string_agg(column_name, ' · ' order by ordinal_position) as ket_qua
  from information_schema.columns where table_name = 'doc_su_kien'
union all
select 'khoá chính', string_agg(a.attname, ' · ')
  from pg_constraint c
  join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
 where c.conrelid = 'doc_su_kien'::regclass and c.contype = 'p'
union all
select 'hàng rào quyền', case when relrowsecurity then 'ĐÃ BẬT' else '⚠️ CHƯA BẬT' end
  from pg_class where relname = 'doc_su_kien'
union all
select 'chính sách', string_agg(policyname || ' (' || cmd || ')', ' · ')
  from pg_policies where tablename = 'doc_su_kien'
union all
select 'chỉ mục', string_agg(indexname, ' · ')
  from pg_indexes where tablename = 'doc_su_kien';
