-- ═══════════════════════════════════════════════════════════════════════════
-- GHI CHÚ CỦA HOST CHO TỪNG BUỔI, CÓ GẮN LINK — Tracy duyệt 01/09/2026
--
-- Nguyên văn: *"Host là người được tạo và sửa, kể cả ở lúc tạo sự kiện hoặc
-- chỉnh sửa hoặc khi sự kiện đã xong, chỗ này cho tôi nút gắn link nữa để host
-- cho biên bản họp vào, và mỗi buổi sự kiện là 1 note riêng chứ không chung cả
-- chuỗi"*.
--
-- ── BỐN TẦNG GHI CHÚ CỦA MỘT SỰ KIỆN, sau cú chốt này ────────────────────
--   ① `lich_chung.ghi_chu`  — MỘT ô của CẢ CHUỖI, host gõ lúc khai lịch, cả
--      đội đọc. Chỗ của thứ buổi nào cũng đúng: link phòng Zoom, ai chủ trì.
--      Tracy chốt GIỮ LẠI (01/09). Tệp này không đụng tới nó.
--   ② bảng dưới đây     — của HOST, cho TỪNG BUỔI, cả đội đọc. Chỗ của biên
--      bản buổi ấy và những đường dẫn kèm theo.
--   ③ `ghi_chu_buoi`    — của TỪNG NGƯỜI, cho TỪNG BUỔI, chỉ mình họ đọc.
--   ④ `task.ghi_chu_chot` — ghi chú của VIỆC mà buổi ấy đẻ ra. Đã có.
--
-- VÌ SAO MỘT BẢNG RIÊNG, KHÔNG THÊM CỘT VÀO `lich_chung`. `lich_chung` giữ một
-- LUẬT LẶP: một dòng ở đó đẻ ra vô số buổi. Không có ô nào trong nó chứa nổi
-- thứ khác nhau ở từng buổi — thêm cột vào đấy là chép cùng một biên bản lên
-- mọi buổi của chuỗi. Cặp khoá của một LƯỢT là `(lich_id, ngay_goc)`, đúng cặp
-- mà `lich_chung_ngoai_le`, `lich_chung_tham_du` và `ghi_chu_buoi` đã dùng.
--
-- VÌ SAO KHÔNG DÙNG CHUNG `ghi_chu_buoi`. Bảng ấy đọc bằng `nguoi_id =
-- nguoi_id_dang_nhap()` — sổ tay riêng, lead cũng không đọc được. Bảng này
-- ngược hẳn: cả đội PHẢI đọc được. Nhét hai luật đọc trái nhau vào một bảng là
-- chỗ rò rỉ chờ sẵn.
--
-- KHÔNG có dòng = host chưa ghi gì. Cùng luật đọc với `lich_chung_tham_du`.
--
-- Chạy tệp này lúc nào cũng được: app dò bảng trong `doCotGio()` trước khi hỏi,
-- chưa chạy thì ô ghi chú của host nói ra tên tệp phải chạy, mọi thứ còn lại
-- chạy y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists thong_bao_buoi (
  lich_id   bigint not null references lich_chung (id) on delete cascade,
  ngay_goc  date   not null,
  noi_dung  text   not null default '',
  -- Danh sách link, mỗi cái `{"ten": "Biên bản", "url": "https://…"}`. Tracy
  -- chốt NHIỀU link có tên hiển thị (01/09), vì một buổi họp thường ra hơn một
  -- tài liệu: biên bản, slide, bản ghi màn hình.
  --
  -- Để là `jsonb` chứ không tách một bảng con: danh sách này luôn được đọc và
  -- ghi TRỌN GÓI cùng buổi của nó, không ai truy vấn riêng một cái link, và
  -- không có gì trỏ tới từng dòng. Tách bảng lúc ấy chỉ đẻ thêm một lượt nối.
  links     jsonb  not null default '[]'::jsonb,
  -- Ai đã ghi. Cột này để MÀN SỔ GHI CHÚ lọc được về đúng chữ của mình — bảng
  -- cả đội đọc, mà sổ là sổ riêng, nên nó cần một chỗ bám để loại chữ người
  -- khác ra. Luôn bằng người tạo sự kiện, vì hàng rào quyền dưới đây chỉ cho
  -- đúng người ấy ghi.
  tao_boi   uuid   references nguoi (id) on delete set null,
  tao_luc   timestamptz not null default now(),
  sua_luc   timestamptz not null default now(),
  primary key (lich_id, ngay_goc)
);

-- ── THÊM 01/09, cùng ngày: Ô GHI CHÚ THỨ HAI, CHO TRƯỚC CUỘC HỌP ─────────
-- Tracy: *"tôi thấy note chung các buổi không cần thiết đâu · Đổi thành ghi chú
-- cho người tham gia trước cuộc họp"*. Ô chung của cả chuỗi (`lich_chung.ghi_chu`)
-- thôi được bày trong app; chỗ của nó là một ô CỦA TỪNG BUỔI, gõ trước khi họp.
--
-- Một buổi họp có hai thứ để nói với người dự, ở hai thời điểm khác nhau: chuẩn
-- bị gì trước khi vào, và chốt được gì sau khi ra. Hai cột trên CÙNG MỘT DÒNG
-- chứ không hai bảng — chúng cùng khoá, cùng quyền, cùng được đọc và ghi trong
-- một cú bấm Lưu; tách bảng chỉ đẻ thêm một lượt nối.
--
-- `add column if not exists`: chạy lại cả tệp này lúc nào cũng được. Ai đã chạy
-- bản đầu rồi thì lượt này chỉ thêm đúng một cột.
alter table thong_bao_buoi
  add column if not exists noi_dung_truoc text not null default '';

comment on column thong_bao_buoi.noi_dung_truoc is
  'Ghi chú host viết TRƯỚC buổi — chuẩn bị gì, mang gì, đọc gì. Cột noi_dung là '
  'ghi chú viết SAU buổi (biên bản).';

-- ── THÊM 01/09: DÃY LINK RIÊNG CHO Ô TRƯỚC ───────────────────────────────
-- Tracy: *"ô trước cuộc họp cũng cho gắn link luôn nhé"*. Hai ô nay đối xứng
-- hoàn toàn — mỗi ô một đoạn chữ và một dãy link của riêng nó.
--
-- Hai cột chứ KHÔNG một dãy dùng chung: tài liệu đọc trước và biên bản sau là
-- hai tập khác nhau, gộp lại thì người mở buổi ra đọc chuẩn bị phải lọc qua cả
-- mấy đường dẫn của một buổi chưa diễn ra.
alter table thong_bao_buoi
  add column if not exists links_truoc jsonb not null default '[]'::jsonb;

comment on column thong_bao_buoi.links_truoc is
  'Đường dẫn kèm ô ghi chú TRƯỚC buổi — agenda, tài liệu đọc trước. Cột links '
  'là đường dẫn kèm ô SAU buổi (biên bản, slide, bản ghi).';

comment on table thong_bao_buoi is
  'Ghi chú của HOST cho MỘT LƯỢT của một sự kiện — biên bản buổi ấy và các '
  'đường dẫn kèm theo. Cả đội đọc, chỉ người tạo sự kiện ghi. Khác '
  'lich_chung.ghi_chu (một ô của cả chuỗi) và ghi_chu_buoi (sổ riêng từng người).';

-- Chỉ mục theo NGƯỜI GHI: câu hỏi "sổ ghi chú của tôi có gì" đi đường này, y
-- như `gcbuoi_theo_nguoi` đã mở cho bảng ghi chú riêng. Dựng lúc bảng còn rỗng
-- thì tức thì; đợi tới lúc bảng đầy thì lượt dựng giữ bảng lại.
create index if not exists tbbuoi_theo_nguoi
  on thong_bao_buoi (tao_boi, ngay_goc desc);

-- ═══ QUYỀN ════════════════════════════════════════════════════════════════
alter table thong_bao_buoi enable row level security;

-- ĐỌC: cả đội, y như ba bảng lịch kia. Biên bản một buổi họp là việc chung —
-- người dự phải đọc được, kể cả người vắng mặt hôm ấy.
drop policy if exists doc_tb_buoi on thong_bao_buoi;
create policy doc_tb_buoi on thong_bao_buoi for select
  using (la_thanh_vien());

-- GHI: CHỈ người tạo sự kiện (Tracy chốt 01/09 — *"chỉ host"*). Lead KHÔNG có
-- cửa hậu ở đây, dù `sua_lich` trên `lich_chung` có cho lead sửa chuỗi. Hai
-- quyền khác nhau và cố ý khác: sửa giờ họp là việc điều phối, còn viết biên
-- bản nhân danh người chủ trì thì không.
--
-- Vế `with check` ép thêm `tao_boi` phải là chính mình — chặn cú ghi một dòng
-- rồi gán tên người khác vào đó.
drop policy if exists ghi_tb_buoi on thong_bao_buoi;
create policy ghi_tb_buoi on thong_bao_buoi for all
  using (exists (
    select 1 from lich_chung l
     where l.id = thong_bao_buoi.lich_id
       and l.tao_boi = nguoi_id_dang_nhap()))
  with check (
    tao_boi = nguoi_id_dang_nhap()
    and exists (
      select 1 from lich_chung l
       where l.id = thong_bao_buoi.lich_id
         and l.tao_boi = nguoi_id_dang_nhap()));

-- ── TỰ KIỂM — cả năm câu phải chạy trót lọt ───────────────────────────────
-- ① Bảng đã có, đủ CHÍN cột (bảy cột bản đầu + `noi_dung_truoc` + `links_truoc`).
select column_name, data_type, is_nullable, column_default
  from information_schema.columns
 where table_name = 'thong_bao_buoi' order by ordinal_position;

-- ② Khoá chính đúng cặp `(lich_id, ngay_goc)` — KHÔNG có `nguoi_id`. Đây là
--    chỗ khác `ghi_chu_buoi`: một buổi có đúng MỘT ghi chú của host.
select a.attname
  from pg_constraint c
  join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
 where c.conrelid = 'thong_bao_buoi'::regclass and c.contype = 'p';

-- ③ Hàng rào quyền đã bật, và có đúng hai chính sách.
select relrowsecurity from pg_class where relname = 'thong_bao_buoi';
select policyname, cmd from pg_policies where tablename = 'thong_bao_buoi';

-- ④ Chỉ mục đã dựng.
select indexname from pg_indexes where tablename = 'thong_bao_buoi';

-- ⑤ Xoá một sự kiện thì ghi chú của mọi buổi thuộc nó đi theo — không để lại
--    dòng mồ côi trỏ vào một `lich_id` không còn.
select confdeltype from pg_constraint
 where conrelid = 'thong_bao_buoi'::regclass and contype = 'f'
   and confrelid = 'lich_chung'::regclass;
