-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `tieu_diem.doc_da_gop`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- ⛔ FILE NÀY ĐÃ BỊ THAY THẾ — ĐỪNG CHẠY LẠI (15/08/2026)
--
-- Hai cột nó thêm (`tieu_diem.doc_ghi_chu` · `tieu_diem.doc_da_gop`) đã được
-- CHUYỂN sang bảng riêng `doc_cam_ket` bởi `nang-cap-doc-rieng-tu.sql`, vì để
-- trên `tieu_diem` là cả 12 người đọc được ghi chú riêng của nhau — `tieu_diem`
-- đọc bằng `la_thanh_vien()` (schema.sql:266), trong khi bảng gốc `ghi_chu` đã
-- được siết chỉ-chủ-đọc từ 14/08 (`nang-cap-chot-chan-phien.sql:104`).
--
-- CHẠY LẠI FILE NÀY = thêm lại hai cột cũ = MỞ LẠI ĐÚNG CÁI LỖ VỪA VÁ.
-- Cần dựng lại kho từ đầu thì chạy file này rồi chạy TIẾP `nang-cap-doc-rieng-tu.sql`.
-- Giữ lại để đọc lý do thiết kế bản doc (phần BÀI TOÁN · LỜI GIẢI bên dưới vẫn đúng).
-- ============================================================================
--
-- KHU VƯỜN TỈNH THỨC ROVA — GHI CHÚ CAM KẾT GOM VỀ MỘT BẢN DOC
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại.
--
-- Tracy chốt 14/08: *"không cần tách thành các ghi chú nhỏ như vậy đâu, trích
-- hết về 1 bản doc và tìm cách ghi được nguồn là được, để hết thành 1 bản doc
-- thì sửa các ghi chú mới dễ ấy với cả để còn xóa được nữa chứ, phân biệt note
-- đó đến từ task nào là được ý"*.
--
-- ─── BÀI TOÁN ─────────────────────────────────────────────────────────────
-- Dòng ghi chú của cam kết gom ba nguồn: ý bắt trong phiên (`ghi_chu`), lời
-- khai cuối phiên (`phien_deepwork.ghi_chu`), ghi chú của việc
-- (`task.ghi_chu_chot`). Trước bản này mỗi mẩu là một thẻ riêng, và **chỉ mẩu
-- thuộc nguồn thứ nhất mới xoá được** — hai nguồn kia chỉ đọc, vì xoá chúng ở
-- đây là âm thầm sửa ghi chú của một task hay một phiên khác.
--
-- Hệ quả: muốn dọn lại cho gọn thì không dọn được, muốn sửa một câu viết vội
-- thì tuỳ nó thuộc nguồn nào.
--
-- ─── LỜI GIẢI ─────────────────────────────────────────────────────────────
-- Mỗi cam kết có MỘT BẢN DOC riêng. Lần đầu mở, app trích mọi mẩu đang có vào
-- doc, mỗi mẩu kèm một dòng nguồn (đến từ việc nào, lúc nào, thẻ gì). Từ đó doc
-- là văn bản của người dùng: sửa thoải mái, xoá thoải mái.
--
-- ⭐ MẨU GỐC KHÔNG BAO GIỜ BỊ ĐỤNG TỚI (Tracy chốt: *"đồng ý không mất ở task
-- gốc"*). Xoá một dòng trong doc chỉ có nghĩa "dòng này tôi không cần trong bản
-- tổng hợp nữa"; mở task ra ghi chú của nó vẫn còn nguyên. Doc là MẶT LÀM VIỆC,
-- mẩu gốc là SỔ CỦA VIỆC ĐÓ. Đây là lý do file này không thêm một trigger nào —
-- không có chiều ghi ngược nào tồn tại để mà phải canh.
--
-- ─── VÌ SAO KHÔNG ĐỤNG KHUNG NHÌN `tien_do_o` ─────────────────────────────
-- App đọc cam kết qua khung nhìn ấy, nên thêm cột vào đó là phải `drop view`
-- rồi tạo lại — mà `tien_do_o` nuôi cả tab Vườn lẫn Cam kết lẫn bảng đội, hỏng
-- giữa chừng là ba màn chết cùng lúc. Hai cột dưới đây app đọc bằng MỘT truy vấn
-- riêng thẳng vào bảng `tieu_diem`, nên file này chỉ thêm cột, không chạm khung
-- nhìn nào. Rẻ hơn và không có đường nào hỏng to.
--
-- Không thêm policy nào: hai cột nằm trong bảng `tieu_diem`, dùng lại nguyên bộ
-- quyền đã có — `sua_tieudiem` cho mỗi người sửa cam kết của mình
-- (`nang-cap-luong-rieng-tung-nguoi.sql` mục 84-93).
-- ============================================================================


-- ─── 1. BẢN DOC ─────────────────────────────────────────────────────────────
alter table tieu_diem add column if not exists doc_ghi_chu text not null default '';

comment on column tieu_diem.doc_ghi_chu is
  'Bản doc ghi chú của cam kết này — một văn bản liền mạch, người dùng sửa và '
  'xoá tự do. Các mẩu từ ghi_chu / phien_deepwork / task được TRÍCH vào đây một '
  'lần rồi thôi; sửa hay xoá trong doc KHÔNG đụng tới mẩu gốc.';


-- ─── 2. DẤU ĐÃ GỘP ─────────────────────────────────────────────────────────
-- Danh sách khoá của các mẩu ĐÃ trích vào doc, dạng 'y:12' · 'cua:34' · 'viec:56'
-- (loại : id). Không có nó thì mỗi lần mở doc lại nối thêm một bản nữa của mọi
-- mẩu cũ — và người dùng vừa xoá một dòng xong, mở lại thấy nó mọc lại.
--
-- Mảng chứ không phải bảng riêng: số mẩu của một cam kết đếm bằng chục, và thứ
-- duy nhất cần hỏi là "khoá này có trong danh sách chưa" — một phép hỏi mà mảng
-- làm tốt bằng cả một bảng, mà không đẻ thêm quyền, thêm khoá ngoại, thêm chỗ
-- phải dọn khi xoá cam kết.
alter table tieu_diem add column if not exists doc_da_gop text[] not null default '{}';

comment on column tieu_diem.doc_da_gop is
  'Khoá các mẩu đã trích vào doc_ghi_chu, dạng loai:id (y:12 · cua:34 · viec:56). '
  'Đã có trong đây thì KHÔNG trích lại — nhờ vậy người dùng xoá một dòng đi rồi '
  'mở lại không thấy nó mọc lại.';


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả hai ══════════════════════════════════
select * from (values
  (1, 'cột tieu_diem.doc_ghi_chu có mặt',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'tieu_diem'
       and column_name = 'doc_ghi_chu') = 1),

  (2, 'cột tieu_diem.doc_da_gop có mặt, và đúng kiểu MẢNG chữ',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'tieu_diem'
       and column_name = 'doc_da_gop' and data_type = 'ARRAY') = 1)
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from tieu_diem)                                as so_cam_ket,
  (select count(*) from tieu_diem where doc_ghi_chu <> '')        as cam_ket_da_co_doc,
  (select count(*) from ghi_chu)                                  as so_y_da_bat;
