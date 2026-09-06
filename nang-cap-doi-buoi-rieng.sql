-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung_ngoai_le.so_phut_moi`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — DỜI RIÊNG MỘT BUỔI, KỂ CẢ ĐỘ DÀI
--                                                  (Tracy duyệt 02/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-lich-chung.sql` (tệp dựng bảng này).
--            Không phải chạy trước khi đẩy mã: app dò cột bằng cờ `CO_DOI_PHUT`
--            trong `doCotGio()` rồi mới quyết gửi hay không.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 02/09: *"trong bảng timeline tôi thấy khối sự kiện chưa kéo được, cho nó
-- kéo được giống khối task đi"*, và chốt phương án B: kéo xong thì hỏi phạm vi
-- *Sự kiện này · Tất cả sự kiện*, đúng khuôn Lịch Google.
--
-- Nhánh *Sự kiện này* ghi xuống `lich_chung_ngoai_le` — chỗ kho đã dựng sẵn cho
-- nó từ ngày đầu, với `kieu in ('huy','doi')` cộng `ngay_moi` và `gio_moi`. Nên
-- dời NGÀY và dời GIỜ của riêng một buổi chạy được ngay, không cần tệp này.
--
-- Thiếu đúng một thứ: ĐỘ DÀI. Kéo mép dưới một khối để buổi dài thêm nửa tiếng
-- là một thao tác có sẵn trên lưới, mà bảng không có cột nào chứa kết quả của
-- nó. Không có tệp này thì kéo mép vẫn chạy, chỉ là độ dài giữ nguyên — và câu
-- toast nói ra điều đó chứ không im lặng nuốt.
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- Một cột, đi đúng lối `gio_moi` đã đi: số phút, cho phép rỗng, rỗng nghĩa là
-- "giữ theo luật lặp". Không có cột nào bị viết lại, không dòng nào phải di cư,
-- và mọi ngoại lệ đang có vẫn đọc ra y như hôm qua.
--
-- VÌ SAO KHÔNG LƯU `gio_ket_thuc_moi`: bảng chuỗi `lich_chung` đang lưu điểm bắt
-- đầu cộng SỐ PHÚT, không lưu điểm kết thúc. Một ngoại lệ lưu khác hình dạng với
-- chuỗi mà nó chồng lên là bắt mọi chỗ đọc phải nhớ hai cách tính cho cùng một
-- thứ — chỗ nào quên thì lệch, và lệch kiểu ấy không có tiếng kêu nào.
--
-- ─── RÀNG BUỘC PHẢI NỚI, KHÔNG CHỈ THÊM CỘT ─────────────────────────────────
-- `ngoaile_doi_du_tham_so` đang đọc: một dòng `kieu='doi'` phải khai ít nhất một
-- trong `ngay_moi` · `gio_moi`. Thêm cột mà không nới ràng buộc thì một cú kéo
-- MÉP thuần tuý — chỉ đổi độ dài, giữ nguyên ngày và giờ bắt đầu — bị máy chủ
-- chặn, dù nó vừa khai một thứ hợp lệ. Nới xong, ba trường thay nhau làm chứng.
--
-- ⚠️ DROP RỒI ADD, KHÔNG BỌC `if not exists` — cùng lý lẽ `nang-cap-mau-su-kien.sql`
-- đã ghi: bọc thì lần sau nới thêm một trường nữa, chạy lại tệp này KHÔNG vá được
-- gì. Nó thấy ràng buộc đã tồn tại rồi bỏ qua, và máy chủ vẫn chặn theo luật cũ.
-- ============================================================================

alter table lich_chung_ngoai_le
  add column if not exists so_phut_moi smallint;

-- Trần 1440 = một ngày. Sàn 5 phút, cùng con số `lich_chung.so_phut` đang dùng
-- cho một buổi ngắn nhất — một buổi 0 phút thì không phải một buổi.
alter table lich_chung_ngoai_le drop constraint if exists ngoaile_so_phut_moi_hop_le;
alter table lich_chung_ngoai_le add constraint ngoaile_so_phut_moi_hop_le
  check (so_phut_moi is null or so_phut_moi between 5 and 1440);

-- Nới luật "dòng 'doi' phải khai ít nhất một thứ" để độ dài cũng làm chứng được.
alter table lich_chung_ngoai_le drop constraint if exists ngoaile_doi_du_tham_so;
alter table lich_chung_ngoai_le add constraint ngoaile_doi_du_tham_so
  check (kieu <> 'doi'
         or (ngay_moi is not null or gio_moi is not null or so_phut_moi is not null));

comment on column lich_chung_ngoai_le.so_phut_moi is
  'Độ dài riêng của lượt này, phút. Rỗng = giữ theo lich_chung.so_phut.';

-- Chính sách quyền KHÔNG phải đụng: `ghi_lich_ngoai` (nang-cap-su-kien-ca-nhan.sql)
-- đã cho người tạo hoặc lead ghi cả dòng, và cột mới nằm trong dòng ấy.

-- ── TỰ KIỂM — cả bốn câu phải chạy trót lọt ───────────────────────────────
-- ① Cột đã có, đúng kiểu smallint và cho phép rỗng.
select column_name, data_type, is_nullable
  from information_schema.columns
 where table_name = 'lich_chung_ngoai_le' and column_name = 'so_phut_moi';

-- ② Hai ràng buộc đã đứng đúng tên. Phải trả về 2 dòng.
select conname from pg_constraint
 where conname in ('ngoaile_so_phut_moi_hop_le', 'ngoaile_doi_du_tham_so');

-- ③ Luật đã nới THẬT: một dòng 'doi' chỉ khai độ dài phải vào được. Câu này ghi
--    rồi xoá ngay trong một giao dịch, không để lại dấu vết nào.
--    ⚠️ Nếu không có sự kiện nào trong kho thì nó bỏ qua, không báo lỗi giả.
do $$
declare v_id bigint;
begin
  select id into v_id from lich_chung limit 1;
  if v_id is null then
    raise notice '③ Bỏ qua — kho chưa có sự kiện nào để thử.';
    return;
  end if;
  insert into lich_chung_ngoai_le (lich_id, ngay_goc, kieu, so_phut_moi)
       values (v_id, date '1900-01-01', 'doi', 45);
  delete from lich_chung_ngoai_le
        where lich_id = v_id and ngay_goc = date '1900-01-01';
  raise notice '③ ✅ Dòng chỉ khai độ dài đã vào được — ràng buộc đã nới đúng.';
end $$;

-- ④ Không dòng nào mang độ dài ngoài dải. Phải trả về 0 dòng.
select lich_id, ngay_goc, so_phut_moi from lich_chung_ngoai_le
 where so_phut_moi is not null and (so_phut_moi < 5 or so_phut_moi > 1440);
