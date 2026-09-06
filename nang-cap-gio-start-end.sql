-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nhip.gio_end`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
--  GIỜ BẮT ĐẦU · GIỜ DỰ KIẾN KẾT THÚC  (Tracy chốt 25/08)
--
--  Nguyên văn: *"nâng cấp tính năng task sẽ có cả giờ bắt đầu và giờ dự kiến
--  kết thúc, đổi tên là start và end để phục vụ tính năng hoạch định trên
--  timeline… user chọn ngày giờ bắt đầu và app tính trường end và đẩy task lên
--  timeline dự kiến. Nếu mà user không viết là trong bao lâu thì để trống
--  trường end"*.
--
--  CHẠY LẠI NHIỀU LẦN VÔ HẠI — mọi câu đều `if not exists`.
--
--  Ba điều đã cân nhắc, ghi lại để sau này khỏi hỏi lại:
--
--  ① VÌ SAO TÊN LÀ `gio_start` / `gio_end` chứ không phải `start` / `end`.
--     `end` là TỪ KHOÁ của Postgres (nó đóng khối `case … end`). Đặt cột tên
--     trần như thế thì mọi câu lệnh chạm tới nó đều phải bọc ngoặc kép, và chỉ
--     cần một chỗ quên bọc là hỏng — mà lúc đã có dữ liệu thật thì đổi tên cột
--     đắt hơn nhiều so với đặt đúng ngay từ đầu. Tiền tố `gio_` giữ nguyên chữ
--     start/end Tracy đặt, chỉ dời nó ra khỏi vùng từ khoá.
--
--  ② VÌ SAO KIỂU `text` CHỨ KHÔNG PHẢI `time`.
--     Cột `deadline` đang chạy từ 06/08 là `text` giữ chữ người đọc — "16h30",
--     "16h". Cả `phutDeadline` trong app lẫn mọi chỗ bày ⏰ đều đọc kiểu ấy.
--     Hai cột mới đi cùng khuôn thì dùng lại được nguyên bộ hàm cũ, không phải
--     viết lớp dịch thứ hai — và một lớp dịch thứ hai là chỗ hai bên trôi lệch
--     nhau về sau.
--
--  ③ VÌ SAO KHÔNG ĐỘNG VÀO `deadline` CŨ.
--     Nó đang giữ giờ của hàng trăm việc do 12 người gõ. App đọc theo lối:
--     có `gio_start` thì dùng, không có thì rơi về `deadline` như cũ. Nên
--     không phải di trú gì, không ai mất giờ đã khai, và ngày nào muốn dọn thì
--     dọn — không phải hôm nay.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Hai cột mới trên bảng việc ─────────────────────────────────────────
--     `not null default ''` cùng khuôn với `deadline`: app gửi chuỗi rỗng cho
--     ô bỏ trống, không gửi null — gửi null vào cột not null là mất luôn việc
--     vừa gõ.
alter table task add column if not exists gio_start text not null default '';
alter table task add column if not exists gio_end   text not null default '';

comment on column task.gio_start is
  'Giờ BẮT ĐẦU dự kiến, chữ người đọc: "9h", "14h30". Rỗng = chưa hẹn giờ.';
comment on column task.gio_end is
  'Giờ DỰ KIẾN XONG = gio_start + thoi_luong_du_kien, do app tính. '
  'Rỗng khi chưa khai "làm trong bao lâu" — đúng luật Tracy chốt 25/08.';

-- ── 2. Việc cố định cũng cần hai đầu giờ ─────────────────────────────────
--     Bảng `nhip` là việc lặp hằng ngày. Chưa dùng tới hôm nay, nhưng mở sẵn
--     cùng lúc thì sau này khỏi phải xin chạy SQL lần nữa cho đúng một cột.
alter table nhip add column if not exists gio_start text not null default '';
alter table nhip add column if not exists gio_end   text not null default '';

-- ── 3. BỘ TỰ KIỂM — chạy xong nhìn bảng này là biết đã ăn chưa ────────────
select
  'task.gio_start'  as cot,
  (select count(*) from information_schema.columns
    where table_name='task' and column_name='gio_start') as co
union all select 'task.gio_end',
  (select count(*) from information_schema.columns
    where table_name='task' and column_name='gio_end')
union all select 'nhip.gio_start',
  (select count(*) from information_schema.columns
    where table_name='nhip' and column_name='gio_start')
union all select 'nhip.gio_end',
  (select count(*) from information_schema.columns
    where table_name='nhip' and column_name='gio_end');
-- Bốn dòng, cột `co` phải bằng 1 cả bốn. Có dòng nào bằng 0 là câu trên chưa chạy.
