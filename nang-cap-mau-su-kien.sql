-- ═══════════════════════════════════════════════════════════════════════════
-- MÀU CHO SỰ KIỆN trên lưới Lịch trình — Tracy duyệt 01/09/2026
--
-- Nguyên văn: *"sự kiện ở timeline tôi muốn thêm tính năng đổi màu cho họ và
-- có thể đổi màu các sự kiện trong chuỗi định kỳ luôn"*.
--
-- ĐẶT Ở CẤP CHUỖI, VÀ ĐÓ LÀ CHỖ TỰ NHIÊN CỦA NÓ. Một dòng `lich_chung` là một
-- LUẬT LẶP, không phải một buổi: từng buổi do máy khách bung ra lúc vẽ bằng
-- `lcHopNgay`, không có dòng con nào trong kho. Nên một cột ở đây tự khắc sơn
-- cả chuỗi — thứ Tracy hỏi xin như một tính năng thêm, thực ra là hình dạng
-- mặc định của mô hình. Chiều ngược lại mới đắt: *"chỉ đổi buổi này"* phải nới
-- `lich_chung_ngoai_le` (nay chỉ nhận 'huy' và 'doi'), và Tracy chốt để nhát
-- sau, đi cùng lúc với "dời riêng một buổi" vốn cũng đang thiếu.
--
-- LƯU TÊN MÀU, KHÔNG LƯU MÃ MÀU — cùng lý lẽ đã dùng cho `task.mau` hôm 29/08:
-- app có hai bản nền ngược nhau, ghi '#3d7fd1' xuống là đóng đinh một sắc độ
-- cho cả hai. Lưu 'ngoc' thì bảng CSS quyết sắc độ.
--
-- NULL = giữ họ xanh tím mặc định của buổi cố định. Không dòng nào phải di cư,
-- và mọi sự kiện đang có vẫn hiện y như hôm qua.
--
-- Chạy tệp này lúc nào cũng được: app dò cột trong `doCotGio()` trước khi hỏi,
-- chưa chạy thì dải màu trong form sự kiện hiện một dòng nhắc và mọi thứ còn
-- lại chạy y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

alter table lich_chung add column if not exists mau text;

-- Ràng buộc kê đúng tám tên trong dải màu của app. Kê tên chứ không để tự do:
-- một giá trị lạ lọt xuống thì lưới không có lớp CSS nào khớp, khối mất màu mà
-- không một tiếng kêu — kiểu hỏng khó tìm nhất.
--
-- ⚠️ DROP RỒI ADD, KHÔNG BỌC `if not exists`. Tệp anh em `nang-cap-mau-khoi-viec.sql`
-- bọc ràng buộc của nó trong `if not exists`, nên khi dải màu thêm hai tên mới
-- ('ngoc' và 'xtim') thì chạy lại tệp ấy KHÔNG vá được gì — nó thấy ràng buộc
-- đã tồn tại rồi bỏ qua, và tới giờ máy chủ vẫn chặn hai màu ấy. Tệp này đi
-- lối khác để lần sau thêm màu chỉ cần chạy lại nó.
alter table lich_chung drop constraint if exists lich_mau_hop_le;
alter table lich_chung add constraint lich_mau_hop_le
  check (mau is null or mau in
         ('cam','vang','luc','ngoc','lam','xtim','tim','hong'));

-- Chính sách quyền KHÔNG phải đụng: `sua_lich` (nang-cap-su-kien-ca-nhan.sql:94)
-- đã cho người tạo hoặc lead sửa cả dòng, và cột mới nằm trong dòng ấy.

-- ── TỰ KIỂM — cả ba câu phải chạy trót lọt ────────────────────────────────
-- ① Cột đã có, đúng kiểu text và cho phép rỗng.
select column_name, data_type, is_nullable
  from information_schema.columns
 where table_name = 'lich_chung' and column_name = 'mau';

-- ② Ràng buộc đã đứng đúng tên.
select conname from pg_constraint where conname = 'lich_mau_hop_le';

-- ③ Không dòng nào mang tên màu lạ. Phải trả về 0 dòng.
select id, ten, mau from lich_chung
 where mau is not null
   and mau not in ('cam','vang','luc','ngoc','lam','xtim','tim','hong');
