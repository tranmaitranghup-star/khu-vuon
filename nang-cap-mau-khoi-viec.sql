-- ═══════════════════════════════════════════════════════════════════════════
-- MÀU KHỐI VIỆC trên lưới Lịch trình — Tracy duyệt 29/08/2026
--
-- Nguyên văn: *"tôi muốn ấn vào task thì ra thông tin task, có thể đổi màu
-- được khối task đó nữa"*.
--
-- MỘT cột, không một bảng riêng — cùng lý lẽ đã dùng cho `gio_bat_dau` hồi
-- 15/08: màu là một thuộc tính của chính việc ấy, không phải một thực thể có
-- đời sống riêng. Bảng riêng thì kéo theo quyền đọc riêng, khoá ngoại, và một
-- lượt truy vấn nữa ở mỗi lần vẽ lưới.
--
-- LƯU TÊN MÀU, KHÔNG LƯU MÃ MÀU. Ghi '#3d7fd1' xuống CSDL là đóng đinh một sắc
-- độ cho cả bản sáng lẫn bản tối; mà app này có hai bản, và nền hai bản ngược
-- nhau. Lưu 'lam' thì bảng CSS quyết sắc độ, đổi ở một chỗ là đổi khắp nơi.
--
-- NULL = không màu, tức khối giữ nguyên dáng cũ (viền xanh, nền nhạt). Không
-- một dòng dữ liệu cũ nào phải di cư.
--
-- Chạy tệp này lúc nào cũng được: app dò cột bằng `doCotGio()` trước khi hỏi,
-- chưa chạy thì dải màu hiện một dòng nhắc và mọi thứ còn lại vẫn chạy y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

alter table task add column if not exists mau text;

-- Ràng buộc kê đúng tám tên trong dải màu của app. Kê tên chứ không để tự do:
-- một giá trị lạ lọt xuống thì lưới không có lớp CSS nào khớp, khối mất màu mà
-- không một tiếng kêu nào — kiểu hỏng khó tìm nhất.
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'task_mau_hop_le') then
    alter table task add constraint task_mau_hop_le
      check (mau is null or mau in
             ('do','cam','vang','luc','lam','tim','hong','xam'));
  end if;
end $$;

-- Tự kiểm: câu này phải chạy trót lọt và trả về 0 dòng.
select id, mau from task
 where mau is not null
   and mau not in ('do','cam','vang','luc','lam','tim','hong','xam');
