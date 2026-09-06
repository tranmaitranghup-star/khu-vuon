-- ════════════════════════════════════════════════════════════════════════════
-- VÁ SỔ ĐIỂM DANH: việc-của-buổi đã Done thì phải có dòng nhận dự  (TRI-99)
-- Chạy một lần trên Supabase. Chạy lại nhiều lần cũng vô hại — xem mục ② .
-- ════════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO. "Đã dự xong" đọc bảng `task` (việc của buổi chạy tới Done), còn "đã
-- nhận lời" đọc `lich_chung_tham_du`. Hai cửa của lịch — nút Hoàn thành và ô
-- tick trên khối sự kiện — vẫn ghi cả hai. Nhưng đóng đúng việc ấy từ màn Vườn
-- thì trước 04/09 chỉ chạm bảng `task`, nên trên một dòng lịch chung thẻ tên tô
-- xanh "đã dự xong" trong khi con số bên phải xếp người ấy vào "chưa trả lời".
-- Mã đã vá cho tương lai (`doiTrangThai`); tệp này vá những dòng đã lệch.
--
-- KHÔNG ĐÈ LÊN CÂU TRẢ LỜI CỦA AI. `on conflict do nothing` — ai đã bấm, kể cả
-- bấm "không tham gia", thì dòng của họ đứng nguyên. Chỉ những người CHƯA có
-- dòng nào mới được thêm.

-- ── ① SOI TRƯỚC: bao nhiêu dòng sắp được thêm ──────────────────────────────
-- Chạy riêng khối này trước. Ra 0 nghĩa là sổ đã sạch, không cần chạy ② nữa.
select count(*) as se_them
from (
  select distinct t.lich_id, t.lich_ngay, t.nguoi_id
  from task t
  where t.trang_thai = 'Done' and t.lich_id is not null and t.lich_ngay is not null
) x
where not exists (
  select 1 from lich_chung_tham_du d
  where d.lich_id = x.lich_id and d.ngay_goc = x.lich_ngay and d.nguoi_id = x.nguoi_id
);

-- ── ② VÁ ───────────────────────────────────────────────────────────────────
-- Trả về số dòng đã thêm — phải KHỚP con số ở ① .
insert into lich_chung_tham_du (lich_id, ngay_goc, nguoi_id, tham_du, luc)
select distinct t.lich_id, t.lich_ngay, t.nguoi_id, true, now()
from task t
where t.trang_thai = 'Done' and t.lich_id is not null and t.lich_ngay is not null
on conflict (lich_id, ngay_goc, nguoi_id) do nothing;

-- ── ③ TỰ KIỂM: phải ra 0 ───────────────────────────────────────────────────
-- Còn người nào đã dự xong mà vẫn thiếu dòng nhận dự không.
select count(*) as con_lech
from (
  select distinct t.lich_id, t.lich_ngay, t.nguoi_id
  from task t
  where t.trang_thai = 'Done' and t.lich_id is not null and t.lich_ngay is not null
) x
where not exists (
  select 1 from lich_chung_tham_du d
  where d.lich_id = x.lich_id and d.ngay_goc = x.lich_ngay and d.nguoi_id = x.nguoi_id
);
