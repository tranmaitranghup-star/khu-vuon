-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `task.thoi_luong_du_kien`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — THỜI LƯỢNG DỰ KIẾN của một task
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `nang-cap-deepwork-tu-do.sql`. Chạy lại nhiều lần
--            không sao (idempotent) — file này chỉ thêm cột, không đụng
--            khung nhìn nào, nên không có bẫy thứ tự như hai file trước.
--
-- Tracy chốt 06/08/2026: mỗi task khai được THỜI LƯỢNG DỰ KIẾN — định làm
-- xong trong bao lâu. Ghép với giờ deepwork THỰC TẾ đã có sẵn, app hiện ra
-- khoảng chênh giữa Dự kiến và Thực tế.
--
-- Vì sao đo cái này: đây là "độ trễ" theo nguyên lý Tốc độ ánh sáng — chênh
-- lệch giữa thời gian việc ĐÁNG RA cần và thời gian nó THỰC SỰ tốn. Người
-- ước lượng ngày càng sát là người ngày càng hiểu việc của mình.
--
-- KHÔNG dùng con số này để xếp hạng hay chấm điểm ai. Nó là gương soi cho
-- chính người làm — biến nó thành thước đo thi đua là mọi người sẽ khai
-- dự kiến thật rộng cho an toàn, và số liệu chết ngay từ ngày đó.
-- ============================================================================

-- Đơn vị PHÚT. Người dùng gõ tự do ở app ("45" · "1h30" · "1.5h" · "90 phút"),
-- app quy ra phút trước khi ghi xuống đây — cột này luôn là một số phút sạch.
alter table task add column if not exists thoi_luong_du_kien smallint;

comment on column task.thoi_luong_du_kien is
  'Thời lượng dự kiến để làm xong task, đơn vị PHÚT. NULL = chưa khai (không ép). '
  'Đối chiếu với tổng phút deepwork thật của task để ra khoảng chênh Dự kiến ↔ Thực tế.';

-- Trần 1440 phút = 24 giờ. Việc dự kiến quá một ngày làm liên tục thì đó là
-- một hạt (kết quả lớn), không phải một task — phải chia nhỏ trước khi khai.
alter table task drop constraint if exists thoi_luong_du_kien_hop_le;
alter table task add constraint thoi_luong_du_kien_hop_le
  check (thoi_luong_du_kien is null or thoi_luong_du_kien between 1 and 1440);

-- Không thêm policy nào: cột nằm trong bảng `task`, dùng lại nguyên bộ quyền
-- đã có (cả đội xem được, mỗi người chỉ sửa task của mình).

-- ── Kiểm nhanh sau khi chạy (phải trả về đúng một dòng) ─────────────────────
-- select column_name, data_type from information_schema.columns
--  where table_name = 'task' and column_name = 'thoi_luong_du_kien';
