-- ═══════════════════════════════════════════════════════════════════════════
-- XOÁ HẲN CỘT `lich_chung.ghi_chu` — Tracy chốt 01/09/2026
--
-- Nguyên văn: *"tôi thấy note chung các buổi không cần thiết đâu"*, rồi
-- *"xóa hết ghi chú chung của cả chuỗi đi tôi đã bảo thừa rồi mà"*.
--
-- ⛔ TỆP NÀY KHÔNG THỂ LÙI. Cột bị xoá là chữ trong đó mất vĩnh viễn — không có
--    thùng rác, không có bản chép. Đọc hết ba mục dưới rồi hãy chạy.
--
-- ── ① CHẠY SAU, KHÔNG CHẠY TRƯỚC ──────────────────────────────────────────
-- App phải THÔI ĐỌC cột này trước đã. Bản trên sóng từ 01/09 (làn SK9) đã gỡ cả
-- ba lối: cửa sự kiện, form khai lịch, và màn Sổ ghi chú. Nếu máy của bạn còn
-- đang mở bản cũ thì tải lại trang trước khi chạy — bản cũ hỏi cột này, và một
-- câu hỏi cột không còn sẽ dựng cả dải lịch thành màn báo lỗi.
--
-- ── ② XEM CÒN GÌ TRONG ĐÓ TRƯỚC KHI XOÁ ───────────────────────────────────
-- Chạy RIÊNG câu này trước. Nó không sửa gì, chỉ cho bạn nhìn thứ sắp mất.
-- Thấy có chữ đáng giữ thì dừng lại, chép ra chỗ khác, rồi mới chạy phần ③.
select id, ten, ghi_chu, sua_luc
  from lich_chung
 where coalesce(btrim(ghi_chu), '') <> ''
 order by sua_luc desc nulls last;

-- ── ③ XOÁ ─────────────────────────────────────────────────────────────────
-- Bỏ dấu chú thích ở dòng dưới rồi chạy. Để nguyên dấu thì tệp này vô hại.
--
-- alter table lich_chung drop column if exists ghi_chu;

-- ── ④ TỰ KIỂM — chạy sau ③ ────────────────────────────────────────────────
-- Không trả về dòng nào là cột đã đi.
select column_name from information_schema.columns
 where table_name = 'lich_chung' and column_name = 'ghi_chu';
