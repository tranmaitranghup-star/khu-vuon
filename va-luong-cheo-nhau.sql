-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bẫy `trg_kiem_task_dung_luong`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- VÁ: LUỐNG ĐÈ CHÉO NHAU — trả mỗi người về đúng khu đất của mình
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `nang-cap-luong-rieng-tung-nguoi.sql`.
--            Chạy lại nhiều lần không sao.
--
-- ⛔ HAI LỖI FILE NÀY SỬA (Tracy phát hiện 08/08, khi Andy không gieo được hạt
--    và luống 2 của Tracy hiện ra cam kết của Andy):
--
--    ① CHỈ MỤC CŨ CHƯA GỠ — đây là thứ chặn Andy.
--       `nang-cap-khu-vuon.sql` dựng chỉ mục `mot_hat_moi_luong` on (luong)
--       — thời luống còn là của CHUNG công ty, cả đội gộp lại chỉ có 3 luống.
--       `nang-cap-luong-rieng-tung-nguoi.sql` dựng chỉ mục ĐÚNG là
--       `mot_hat_song_moi_luong` on (nguoi_id, luong) nhưng QUÊN gỡ cái cũ.
--       Hai chỉ mục cùng sống → cái cũ vẫn cưỡng chế luật cũ: Andy gieo vào
--       luống 1 là đụng hạt luống 1 của Tracy, Postgres trả 23505, app dịch
--       thành "Luống này đang có một hạt sống rồi". Andy nhìn màn hình thấy
--       trống trơn nên tưởng app hỏng — thực ra nó đang tính hạt của Tracy.
--
--    ② TASK GẮN ĐƯỢC VÀO HẠT CỦA NGƯỜI KHÁC — đây là đường đè chéo còn lại.
--       Đã ghi ra ở cuối `nang-cap-luong-rieng-tung-nguoi.sql` mục ⚠️ nhưng
--       hoãn chưa vá. Bảng `task` không soi chủ của hạt, nên cây của người này
--       mọc được vào luống người kia. Mục 3 dưới đây chặn tận gốc.
--
-- ⚠️ CÁI FILE NÀY KHÔNG SỬA — cần Tracy quyết, xem mục 4 ở cuối:
--    Luống 2 của Tracy đang mang cam kết của Andy ("Công nghệ đóng gói và
--    truyền tải trí tuệ"), đè mất cam kết cũ của Tracy ("CRM"). Đó là VẾT
--    THƯƠNG CŨ, xảy ra TRƯỚC 06/08 khi bảng `tieu_diem` chưa có cột chủ và
--    policy `ghi_tieudiem` cho mọi thành viên sửa mọi dòng: cả đội dùng CHUNG
--    một dòng O2, Andy đổi tên là ghi đè thẳng lên chữ của Tracy — không phải
--    tạo dòng mới. Chữ "CRM" đã mất khỏi cơ sở dữ liệu, không khôi phục được.
--    Rồi mục 3 của file `nang-cap-luong-rieng-tung-nguoi.sql` gán mọi hạt vô
--    chủ cho Tracy, nên dòng mang chữ của Andy thành ra thuộc về Tracy.
-- ============================================================================


-- ─── 1. Gỡ chỉ mục cũ "cả công ty chung ba luống" ───────────────────────────
-- Sau câu này mỗi người mới thật sự có ba luống riêng.
drop index if exists mot_hat_moi_luong;

-- Chỉ mục ĐÚNG phải còn sống. Dựng lại cho chắc (có rồi thì không làm gì).
create unique index if not exists mot_hat_song_moi_luong
  on tieu_diem (nguoi_id, luong) where not xong and luong is not null;


-- ─── 2. Chốt chặn: đừng bao giờ để chỉ mục cũ sống lại ──────────────────────
-- `nang-cap-khu-vuon.sql` vẫn còn câu tạo nó. Ai chạy lại file đó là cả đội
-- lại kẹt y như cũ, mà không có lỗi nào báo. Câu dưới không ngăn được việc
-- chạy lại, nhưng làm nó ĐỔ NGAY thay vì hỏng âm thầm — hỏng ồn ào bao giờ
-- cũng rẻ hơn hỏng im lặng.
do $$
begin
  if exists (select 1 from pg_class where relname = 'mot_hat_moi_luong') then
    raise exception 'Chỉ mục cũ mot_hat_moi_luong vừa sống lại — có người chạy lại nang-cap-khu-vuon.sql. Chạy lại file va-luong-cheo-nhau.sql này.';
  end if;
end $$;


-- ─── 3. Chặn task mọc sang luống người khác ─────────────────────────────────
-- Qua app thì không xảy ra (ô chọn luống chỉ liệt kê luống của chính mình),
-- nhưng gọi thẳng API thì lọt. Đây là đường đè chéo cuối cùng còn hở.
create or replace function kiem_task_dung_luong()
returns trigger language plpgsql security definer set search_path = public
as $$
declare chu_hat uuid;
begin
  if new.tieu_diem_ma is null then return new; end if;   -- việc phát sinh: không thuộc luống nào, cho qua
  select nguoi_id into chu_hat from tieu_diem where ma = new.tieu_diem_ma;
  if chu_hat is null then
    raise exception 'Không tìm thấy hạt % — task không bám vào hư không được.', new.tieu_diem_ma;
  end if;
  if chu_hat <> new.nguoi_id then
    raise exception 'Hạt % là luống của người khác — cây chỉ mọc trong vườn mình.', new.tieu_diem_ma;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_task_dung_luong on task;
create trigger trg_kiem_task_dung_luong before insert or update on task
  for each row execute function kiem_task_dung_luong();


-- ─── 4. SOI VẾT THƯƠNG CŨ — chạy rồi ĐỌC, chưa sửa gì ───────────────────────
-- Ba câu này chỉ HỎI, không ghi. Đọc xong rồi Tracy quyết ở mục 5.

-- ① Ai đang giữ luống nào, cam kết là gì:
--    select n.ten as chu_luong, o.luong, o.ma, o.ten as cam_ket,
--           o.tieu_chi_xong as output, o.han, o.xong, o.ngay_gieo
--      from tieu_diem o join nguoi n on n.id = o.nguoi_id
--     where not o.xong order by n.ten, o.luong;

-- ② Task nào đang mọc trong luống của NGƯỜI KHÁC (đè chéo còn sót lại):
--    select t.id, nt.ten as chu_task, t.noi_dung, t.tieu_diem_ma,
--           no.ten as chu_luong, o.ten as cam_ket_luong
--      from task t
--      join tieu_diem o on o.ma = t.tieu_diem_ma
--      join nguoi nt on nt.id = t.nguoi_id
--      join nguoi no on no.id = o.nguoi_id
--     where t.nguoi_id <> o.nguoi_id;
--    → Phải trả về 0 dòng. Có dòng thì mục 3 ở trên sẽ CHẶN mọi lần sửa task
--      đó về sau — phải dọn bằng mục 5 trước.

-- ③ Hạt nào chưa nằm trong luống nào (sót từ bản O1…O10):
--    select ma, nguoi_id, ten, luong, xong from tieu_diem where luong is null;


-- ─── 5. HAI CÁCH DỌN — chọn một, bỏ dấu chú thích rồi chạy ──────────────────
-- CHƯA CHẠY GÌ Ở ĐÂY. Đọc mục 4 xong mới chọn.
--
-- CÁCH A — Trả hạt về đúng chủ. Dùng khi cam kết đó THẬT SỰ là của Andy và
--          Andy vẫn đang theo đuổi nó. Hạt sang vườn Andy, TASK VÀ CÂY ĐI THEO,
--          luống 2 của Tracy trống ra để gieo lại "CRM".
--          ⚠️ Chỉ chạy được nếu luống 2 của Andy đang trống (chỉ mục chặn).
--    do $$
--    declare id_andy uuid; ma_hat text := 'O2';   -- ← đổi cho đúng mã ở mục 4①
--    begin
--      select id into id_andy from nguoi where email = 'andy@vidu.com';
--      update tieu_diem set nguoi_id = id_andy where ma = ma_hat;
--      update task      set nguoi_id = id_andy where tieu_diem_ma = ma_hat;
--    end $$;
--
-- CÁCH B — Giữ luống cho Tracy, viết lại cam kết. Dùng khi Andy không còn
--          theo đuổi nó nữa. Không cần SQL: Tracy vào tab 🌳 Vườn, bấm ✎ trên
--          biển gỗ luống 2, gõ lại "CRM" + Output + Deadline. Task cũ của Andy
--          nếu còn bám vào hạt này thì dọn bằng câu dưới trước:
--    update task set tieu_diem_ma = null
--     where tieu_diem_ma = 'O2' and nguoi_id <> (select nguoi_id from tieu_diem where ma = 'O2');
--          (task không mất, chỉ chuyển thành 🪴 việc phát sinh)


-- ── KIỂM NHANH SAU KHI CHẠY ────────────────────────────────────────────────
-- ① Chỉ còn ĐÚNG MỘT chỉ mục luống, và nó có nguoi_id (phải ra 1 dòng):
--    select indexname, indexdef from pg_indexes
--     where tablename = 'tieu_diem' and indexdef ilike '%luong%';
-- ② Thử gieo: Andy đăng nhập app → tab ☀️ Hôm nay → 🌱 Gieo vào luống 1.
--    Vào được là xong. Vẫn báo "đang có một hạt sống rồi" nghĩa là mục 1
--    chưa chạy tới.
