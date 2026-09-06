-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.so_cam_ket_kho_toi_da`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- GIAO CAM KẾT CHO NGƯỜI KHÁC — BA ĐƯỜNG SINH RA MỘT CAM KẾT
-- Tracy chốt 2026-08-27 · chạy SAU `nang-cap-moc-cam-ket.sql`
--
-- Dán trọn file vào Supabase › SQL Editor › Run. CHẠY LẠI NHIỀU LẦN VÔ HẠI.
-- Xong thì nhìn bảng cuối: mọi dòng phải ✔.
-- ════════════════════════════════════════════════════════════════════════════
--
-- ─── VÌ SAO CÓ FILE NÀY ─────────────────────────────────────────────────────
-- Hôm nay một cam kết BẮT BUỘC là lời TỰ hứa. Chính sách `them_tieudiem` viết
-- `with check (nguoi_id = nguoi_id_dang_nhap())` — nghĩa là dòng cam kết duy
-- nhất chèn được là dòng mang tên chính người đang bấm. Cộng lại:
--
--   · PIC dự án KHÔNG giao được một cam kết nào cho thành viên của mình.
--   · Cấp trên KHÔNG giao được việc xuống cấp dưới bằng app.
--   · Mọi việc giao nhau đang chạy ngoài app (Zalo, họp), rồi người nhận tự
--     gõ lại vào vườn mình — hoặc quên gõ. Dự án nhìn thấy một danh sách cam
--     kết THIẾU đúng những việc vừa được giao miệng.
--
-- Nới chính sách ra cho ai cũng chèn được dòng mang tên người khác thì mở toang
-- cả bảng: ai cũng gieo được cam kết vào vườn của bất cứ ai. Nên đường giao
-- việc đi qua MỘT HÀM `security definer` khoanh đúng việc cần làm — cùng lối
-- lẽ đã dùng cho `nhan_cam_ket` (11/08) và `danh_dau_da_xem_du_an` (25/08).
--
-- ─── BA ĐƯỜNG SINH RA MỘT CAM KẾT (Tracy chốt) ──────────────────────────────
--   ① TỰ VIẾT — tự hứa với mình. CÓ THỂ không thuộc dự án nào. Đi đường cũ:
--      app chèn thẳng, `giao_boi` để trống, có luống ngay từ lúc gieo.
--   ② GIEO TỪ TRONG MỘT MILESTONE cho CHÍNH MÌNH. Vẫn là đường ①, chỉ khác
--      chỗ app điền sẵn `muc_tieu_id` + `moc_id`. File này không đụng tới.
--   ③ ĐƯỢC GIAO — PIC dự án (hoặc cấp trên trực tiếp) giao cho người khác.
--      Dòng sinh ra ở nấc "CHỜ NHẬN VIỆC", nằm KHO, chưa chiếm luống nào.
--      Đây là đường file này dựng.
--
-- ─── KHÔNG CÓ ĐỒNG HỒ TỰ ĐỘNG ───────────────────────────────────────────────
-- Cam kết chờ nhận thì chờ VÔ HẠN. Không có hạn trả lời, không có nhắc, không
-- có "quá 3 ngày coi như đồng ý". Tracy: *"ai mà giao cam kết thì phải giao
-- tiếp với nhau chứ có phải chờ mỗi trên app đâu"*. App chỉ giữ sổ, không thay
-- mặt ai gật.
--
-- ─── TỪ CHỐI THÌ DÒNG Ở LẠI ─────────────────────────────────────────────────
-- Từ chối đặt `tu_choi_luc` + `tu_choi_ly_do`, GIỮ LUỐNG RỖNG, và quay về phía
-- người giao qua khối "Chờ bạn". KHÔNG tự xoá: một lời từ chối biến mất không
-- dấu vết là cách để việc rơi xuống đất mà không ai chịu.
--
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ BẪY SỐNG CÒN — ĐỌC TRƯỚC KHI SỬA FILE NÀY
-- ════════════════════════════════════════════════════════════════════════════
-- `va-sau-dot-soi-08-08.sql` đặt `tieu_diem.luong` thành NOT NULL, và ĐÓ LÀ
-- HÀNG RÀO DUY NHẤT đang giữ luật "mấy cam kết là hết chỗ". Ba hàng rào kia
-- đều MÙ với dòng có luống rỗng:
--
--   · `check (luong between 1 and 5)` gặp NULL trả về NULL (không xác định)
--     → dòng đi qua tự do, vì CHECK chỉ chặn khi kết quả là FALSE.
--   · chỉ mục `mot_hat_song_moi_luong` có sẵn mệnh đề `where … and luong is
--     not null` → nó TỰ LOẠI dòng rỗng ra khỏi tầm soi.
--   · trigger `kiem_tran_cam_ket` so `new.luong > tran`; NULL so với số cũng
--     ra NULL → nhánh `if` không chạy.
--
-- Cộng lại: BỎ NOT NULL MÀ KHÔNG THAY BẰNG THỨ KHÁC = MỞ LẠI NGUYÊN LỖ HỔNG
-- ĐÃ VÁ NGÀY 08/08 (gọi thẳng API, đặt luong rỗng, gieo bao nhiêu cam kết tuỳ
-- ý). Nên hai việc ấy BẮT BUỘC nằm trong CÙNG MỘT FILE, chạy CÙNG MỘT LƯỢT —
-- và cùng một `begin … commit` ở dưới. Đừng tách chúng ra hai file "cho gọn".
--
-- Thứ thay thế NOT NULL là một ràng buộc NÓI ĐƯỢC LÝ DO: luống rỗng chỉ hợp lệ
-- khi dòng đang ở nấc CHỜ NHẬN VIỆC. Dòng rỗng không còn là một cửa sau vô
-- danh nữa — nó phải khai một GIỜ GIAO có thật (`giao_luc`), và giờ ấy do máy
-- chủ đóng dấu trong hàm `giao_cam_ket`, không ai gõ tay được.
--
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ MỘT CHỖ LỆCH VỚI BẢN GIAO VIỆC — ĐÃ CHỌN THEO LỜI TRACY CHỐT
-- ════════════════════════════════════════════════════════════════════════════
-- Bản giao mô tả ràng buộc là *"luống rỗng khi và chỉ khi giao_boi is not null
-- and nhan_viec_luc is null AND TU_CHOI_LUC IS NULL"*. Viết đúng như vậy thì một
-- cam kết VỪA BỊ TỪ CHỐI lập tức bị ép phải có luống — trong khi luật từ chối
-- Tracy chốt nói rõ là *"giữ luong rỗng"*. Hai câu ấy đá nhau.
--
-- Chọn theo luật từ chối, vì đó là lời Tracy chốt trực tiếp: vế `tu_choi_luc`
-- ĐƯỢC BỎ khỏi ràng buộc. Điều kiện thật của KHO là:
--
--        luống rỗng  ⟺  (đã có LỜI GIAO)  VÀ  (chưa ai nhận)
--
-- Cả CHỜ NHẬN lẫn ĐÃ TỪ CHỐI đều nằm trong kho, đều không chiếm luống, đều
-- không tính vào trần 3. Đúng nghĩa: chừng nào chưa ai gật thì việc chưa vào
-- vườn của ai cả. Vế `tu_choi_luc` vẫn được dùng để PHÂN BIỆT hai nấc ấy ở
-- trần kho (mục 3c) và ở khung nhìn `cho_ban` (mục 8) — chỉ không dùng ở đây.
--
-- "Đã có lời giao" đo bằng `giao_luc`, KHÔNG bằng `giao_boi` — lý do đầy đủ ở
-- mục 1, đoạn ①. Đọc đoạn ấy trước khi đổi bất cứ hàng rào nào.
--
-- ════════════════════════════════════════════════════════════════════════════
-- 🔢 THỨ TỰ CHẠY — HAI FILE CỦA ĐỢT 27/08
-- ════════════════════════════════════════════════════════════════════════════
--   ① `nang-cap-giao-cam-ket.sql`          (file này)
--   ② `nang-cap-doi-ten-trang-thai-task.sql`
-- Hai file KHÔNG chạm nhau: file này chỉ đụng `tieu_diem` và `nguoi`, file kia
-- chỉ đụng `task`, `cum_trang_thai_task` và `tien_do_o`. Chạy ngược thứ tự
-- cũng ra đúng kết quả. Ghi thứ tự ra đây vì file kia có MỘT dòng tự kiểm nói
-- về `tieu_diem.luong`, và dòng ấy đã được sửa cho đúng ở cả hai đời — đừng
-- trả nó về bản cũ (chi tiết ở khối ⚠️ ngay dưới).
--
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ HAI DÒNG TỰ KIỂM Ở FILE KHÁC SẼ SAI SAU KHI CHẠY FILE NÀY
-- ════════════════════════════════════════════════════════════════════════════
-- `va-sau-dot-soi-08-08.sql` (17/08) có hai dòng khẳng định đúng cái điều file
-- này cố ý đảo ngược:
--   · mục 1 — 'tieu_diem.luong đã CẤM rỗng'      (dòng 86–88)
--   · mục 3 — 'Không dòng cam kết nào có luong rỗng' (dòng 96–97)
-- Ai chạy lại file ấy sau đợt này sẽ thấy hai ❌ trong khi máy chủ hoàn toàn
-- đúng — đúng cái bệnh mà CHÍNH file ấy, ở mục 4 của nó, đã đặt tên và ghi
-- "Không tái phạm". Sửa theo đúng nếp mục 4 của nó:
--   · mục 1 → 'Hàng rào luống còn đứng: hoặc luong NOT NULL, hoặc ràng buộc
--     luong_rong_chi_khi_cho_nhan đang sống'
--   · mục 3 → 'Không dòng nào có luong rỗng NGOÀI những dòng đang nằm kho'
-- ⚠️ TUYỆT ĐỐI KHÔNG "chữa" bằng cách chạy lại
-- `alter table tieu_diem alter column luong set not null` — lúc kho đang rỗng
-- thì câu ấy CHẠY LỌT, và từ đó `giao_cam_ket()` gãy ở mọi lời giao.
--
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ GIAO DIỆN CHƯA BIẾT HAI LOẠI MỚI CỦA `cho_ban` — LÊN CÙNG MỘT LƯỢT
-- ════════════════════════════════════════════════════════════════════════════
-- Mục 8 thêm hai giá trị `loai` là 'cho-nhan' và 'bi-tu-choi'. Từ điển
-- `CB_LOAI` trong `public/index.html` (khoảng dòng 17412) mới biết 'loi-moi'
-- và 'ky-nhan'. Hàm `veChoBan` bỏ qua loại lạ khi VẼ (`if (!L) return ''`)
-- nhưng vẫn ĐẾM chúng: con số trên thẻ lấy thẳng `CHO_BAN.length`.
-- Nghĩa là ngay sau khi chạy file này mà giao diện chưa lên, người được giao
-- một cam kết sẽ thấy khối "Chờ bạn" bật lên với con số 1 và một danh sách
-- TRỐNG RỖNG — không có gì để bấm, không có gì giải thích, và không có cách
-- nào làm con số ấy về 0.
-- Hai việc phải làm bên giao diện, cùng một lượt phát hành:
--   ① thêm hai nhánh 'cho-nhan' và 'bi-tu-choi' vào `CB_LOAI` (kèm hai nút gọi
--      `nhan_viec_cam_ket` / `tu_choi_cam_ket`, và nút gọi `rut_lai_cam_ket`
--      cho nhánh bị từ chối),
--   ② cho con số trên thẻ đếm SỐ DÒNG THẬT SỰ VẼ RA thay vì `CHO_BAN.length`
--      — lọc `CHO_BAN` qua `CB_LOAI` một lần rồi mới đếm và mới vẽ. Việc ② nên
--      làm dù sao, vì nó chặn luôn mọi loại thêm mới trong tương lai.
--
-- ─── BA THỨ CỐ Ý KHÔNG LÀM TRONG FILE NÀY ───────────────────────────────────
--   · KHÔNG đụng `public/index.html`. File này chỉ dựng tầng máy chủ; giao
--     diện là đợt sau (danh sách việc ở khối ⚠️ ngay trên).
--   · ~~KHÔNG dựng lại khung nhìn `tien_do_o`~~ — ⚠️ ĐÃ LẬT LẠI 27/08, XEM
--     MỤC 10. Bản đầu của file này hoãn việc ấy sang đợt sau, với hệ quả khai
--     rõ: app đọc `tien_do_o` bằng `select('*')`, nên năm cột mới CHƯA tới
--     được mắt người dùng qua đường đó. Lý do hoãn đứng được chừng nào giao
--     diện chưa đi qua đường ấy — và cùng ngày thì khối KHO CAM KẾT trên màn
--     "Của tôi" đi qua đúng đường ấy, đọc `giao_luc` từ `TIEU_DIEM` để biết
--     một dòng là lời người khác giao hay lời mình tự viết. Mục 10 dựng lại
--     khung nhìn kèm bảy cột (năm cột sổ giao nhận + `moc_id` + `ngay_bat_dau`).
--     Dòng kho (luống rỗng) VẪN hiện trong `tien_do_o` với `luong = null` — đó
--     là đường DUY NHẤT app nhìn thấy kho, đừng lọc nó đi.
--     (Khung nhìn `danh_muc_du_an` thì KHÔNG hoãn được — xem mục 9 và lý do
--     tại sao nó là ca khác hẳn.)
--   · KHÔNG đổi `task.trang_thai` từ 'Confirm' sang 'Chua_lam' (nhãn màn hình:
--     "Chờ làm"). Việc đó chạm ba chỗ khác — ràng buộc `task_trang_thai_hop_le`,
--     bảng tra `cum_trang_thai_task`, và truy vấn con `so_kho` trong
--     `tien_do_o` — và không dính gì tới đường giao cam kết. File riêng:
--     `nang-cap-doi-ten-trang-thai-task.sql`. (Khung nhìn `dem_task_theo_o`
--     KHÔNG viết cứng chữ 'Confirm', nó gom theo `t.trang_thai`, nên nó không
--     nằm trong danh sách.)
--
-- ─── HAI HÀNH VI NGẦM, NÓI RA CHO RÕ ────────────────────────────────────────
-- ① Hai khung nhìn `dem_task_theo_o` và `dem_cam_ket_da_dong` lọc cứng
-- `luong between 1 and 5`. Gặp luống rỗng, phép so sánh ấy trả NULL, nên MỌI
-- CAM KẾT ĐANG Ở KHO TỰ ĐỘNG RƠI KHỎI CẢ HAI. Đó ĐÚNG ý muốn — việc chưa ai
-- nhận thì chưa đếm vào số của ai — nhưng nó là hành vi ngầm của logic ba trị
-- chứ không phải một mệnh đề ai đó viết ra. Ghi lại đây để đợt sau ai sửa hai
-- khung nhìn kia thì biết mình đang cầm cái gì.
--
-- ② ⚠️ HAI Ô SỐ VỀ CÙNG MỘT CAM KẾT CÓ THỂ LỆCH NHAU — CHƯA VÁ, ĐỂ ĐỢT SAU.
-- `tien_do_o` KHÔNG lọc `luong`, nên nó vẫn đếm `so_task`/`so_kho` cho một
-- dòng đang nằm kho; `dem_task_theo_o` thì lọc bỏ. Không hàng rào nào cấm gắn
-- task vào một cam kết đang ở kho: `kiem_task_dung_luong`
-- (va-luong-cheo-nhau.sql:63–77) chỉ soi CHỦ của cam kết, không soi luống.
-- Qua giao diện thì chưa xảy ra vì `optCamKet` lọc `luong >= 1`, nhưng gọi
-- thẳng API thì lọt, và lúc ấy hai ô số cạnh nhau nói hai điều khác nhau mà
-- không lỗi nào báo. Cách vá rẻ nhất cho đợt sau: thêm một vế vào
-- `kiem_task_dung_luong` — cam kết đang nằm kho (`giao_luc is not null and
-- nhan_viec_luc is null`) thì chưa gắn task vào được, kèm câu tiếng Việt nói
-- rõ phải bấm Nhận việc trước. Cố ý không làm ở đây để file này không chạm
-- bảng `task`.
-- ════════════════════════════════════════════════════════════════════════════


begin;


-- ════════════════════════════════════════════════════════════════════════════
-- 1. NĂM CỘT MỚI — SỔ GIAO NHẬN CỦA MỘT CAM KẾT
-- ════════════════════════════════════════════════════════════════════════════
-- Tất cả đều là MỐC GIỜ, không phải cờ đúng/sai. Cùng giá lưu trữ nhưng trả
-- lời được thêm một câu mà cờ không trả lời nổi: *"giao từ bao giờ mà giờ mới
-- nhận?"* — đúng câu người điều hành cần khi việc chậm. Cùng lối lẽ đã dùng
-- cho `thanh_vien_du_an.da_xem_luc` (25/08) và `tieu_diem.nop_luc` (11/08).

-- ⚠️ ĐỌC KỸ HAI ĐOẠN NÀY TRƯỚC KHI ĐỔI BẤT CỨ THỨ GÌ Ở ĐÂY.
--
-- ① VÌ SAO `giao_boi` KHÔNG PHẢI LÀ DẤU NHẬN BIẾT CỦA KHO.
-- Khoá ngoại khai ON DELETE SET NULL, không CASCADE: người giao rời đội thì
-- cam kết ĐÃ GIAO vẫn phải ở lại với người nhận. Xoá một tài khoản không phải
-- là xoá những việc người ta đã hứa.
-- Nhưng Postgres thi hành SET NULL bằng MỘT CÂU `update` THẬT trên tieu_diem,
-- và câu update ấy đi qua đủ mọi ràng buộc lẫn trigger của bảng. Nghĩa là:
-- cột `giao_boi` CÓ THỂ tự chuyển từ có-giá-trị sang rỗng mà không ai gõ lệnh.
-- Lấy nó làm dấu nhận biết "dòng này đang ở kho" là dựng hàng rào trên một
-- cột biết tự rút chân — xoá một người là hàng rào sập, và câu lỗi hiện ra
-- nói về chuyện sửa lời khai chứ không nhắc gì tới việc đang xoá người.
--
-- Nên dấu nhận biết của KHO là `giao_luc`: một mốc giờ, không khoá ngoại nào
-- với tới, không lệnh nào của Postgres tự đặt lại. Mọi ràng buộc, trigger,
-- chỉ mục và khung nhìn dưới đây đều neo vào `giao_luc`, KHÔNG neo vào
-- `giao_boi`. `giao_boi` chỉ còn trả lời một câu: *tên người giao là ai*.
--
-- ② HAI CỘT ẤY KHÔNG CÒN LUÔN ĐI CÙNG NHAU.
-- Lúc CHÈN thì có đủ cả hai (trigger canh). Về sau chỉ có ĐÚNG MỘT đường làm
-- chúng lệch: người giao bị xoá khỏi bảng `nguoi`, `giao_boi` về rỗng còn
-- `giao_luc` ở lại. Chiều ngược lại — có `giao_boi` mà thiếu `giao_luc` —
-- vĩnh viễn không hợp lệ, và bộ tự kiểm mục 31 soi đúng chiều ấy.
alter table tieu_diem add column if not exists giao_boi uuid
  references nguoi (id) on delete set null;

alter table tieu_diem add column if not exists giao_luc      timestamptz;
alter table tieu_diem add column if not exists nhan_viec_luc timestamptz;
alter table tieu_diem add column if not exists tu_choi_luc   timestamptz;
alter table tieu_diem add column if not exists tu_choi_ly_do text;

comment on column tieu_diem.giao_boi is
  'TÊN người giao cam kết này. Để trống KHÔNG có nghĩa là cam kết tự viết — nó còn có nghĩa người giao đã bị xoá khỏi bảng nguoi (khoá ngoại on delete set null tự đặt lại cột này). Câu hỏi "dòng này có phải được giao không" tra ở giao_luc, không tra ở đây. Chỉ đổi được theo ĐÚNG MỘT hướng: từ có-giá-trị sang rỗng, và chỉ khi người ấy đã thật sự không còn trong bảng nguoi — trigger kiem_giao_cam_ket canh.';

comment on column tieu_diem.giao_luc is
  'Máy chủ đóng dấu lúc lời giao được gửi đi. ĐÂY LÀ DẤU NHẬN BIẾT CỦA ĐƯỜNG ③: có giá trị = cam kết được giao, để trống = cam kết TỰ VIẾT (đường ① và ②). Bất biến tuyệt đối, không lệnh nào sửa được, kể cả lúc người giao rời đội — khác hẳn giao_boi. Cũng là mốc để đếm "giao bao lâu rồi mà chưa ai trả lời".';

comment on column tieu_diem.nhan_viec_luc is
  'Máy chủ đóng dấu lúc người được giao bấm NHẬN VIỆC. Còn trống nghĩa là cam kết vẫn nằm KHO: chưa chiếm luống nào, chưa tính vào trần cam kết. Không bao giờ đưa về trống lại được. ⚠️ ĐỪNG LẪN VỚI da_nhan_luc — cột kia là giờ NGHIỆM THU cuối vòng (cấp trên ký nhận sản phẩm), cột này là giờ NHẬN VIỆC đầu vòng.';

comment on column tieu_diem.tu_choi_luc is
  'Máy chủ đóng dấu lúc người được giao bấm TỪ CHỐI. Dòng Ở LẠI chứ không bị xoá — một lời từ chối biến mất không dấu vết là cách để việc rơi xuống đất mà không ai chịu. Cam kết bị từ chối vẫn giữ luống rỗng và quay về khối "Chờ bạn" của người giao.';

comment on column tieu_diem.tu_choi_ly_do is
  'Vì sao từ chối, do chính người được giao khai. BẮT BUỘC — hàm tu_choi_cam_ket không nhận lời từ chối trống lý do: người giao cần biết vì sao để giao lại cho đúng người hoặc sửa lại đề bài.';

-- Kho của một người, và những lời giao chính mình đã gửi đi. Hai chỉ mục nhỏ
-- vì hai câu hỏi này chạy ở MỌI lần mở app (khối "Chờ bạn" hỏi cả hai).
--
-- Chỉ mục KHO neo vào `giao_luc`: nếu neo vào `giao_boi` thì ngày người giao
-- rời đội, mọi cam kết họ đã giao lặng lẽ rơi khỏi chỉ mục, và khối "Chờ bạn"
-- của người nhận trống trơn trong khi việc vẫn nằm đó.
-- Chỉ mục LỜI GIAO ĐÃ GỬI thì đúng là neo vào `giao_boi` — nó trả lời câu
-- "tôi đã giao những gì", mà người đã rời đội thì không còn hỏi câu ấy nữa.
drop index if exists cam_ket_trong_kho;
create index if not exists cam_ket_trong_kho on tieu_diem (nguoi_id)
  where giao_luc is not null and nhan_viec_luc is null;

create index if not exists cam_ket_da_giao_di on tieu_diem (giao_boi)
  where giao_boi is not null;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. DỌN NỀN — có dòng cũ nào sẽ phạm ràng buộc mới không?
-- ════════════════════════════════════════════════════════════════════════════
-- Mọi cam kết đang có đều có luống hợp lệ (NOT NULL đang gác từ 08/08) và đều
-- có `giao_boi` trống (cột vừa mọc lên xong). Nên không dòng nào phạm, và
-- KHÔNG cần một câu `update` vá dữ liệu nào cả.
--
-- Nhưng "không cần vá" là một điều được KIỂM chứ không phải một điều được tin.
-- Khối dưới đây đổ ngay nếu máy chủ thật khác với điều vừa nói — hỏng ồn ào
-- bao giờ cũng rẻ hơn hỏng im lặng.
--
-- ⚠️ CHỈ SOI MỘT CHIỀU — ĐÃ SỬA 27/08 CÙNG ĐỢT NỚI KHO.
-- Bản đầu soi đẳng thức hai chiều `(luong is null) <> (chờ nhận)`, đúng dáng
-- của ràng buộc hồi đó. Sau khi kho nhận thêm cam kết TỰ VIẾT, câu ấy tự bắn
-- vào chân file này: lần chạy ĐẦU vẫn xanh (chưa có dòng tự viết nào ở kho),
-- nhưng lần chạy THỨ HAI — sau khi ai đó đã để một cam kết tự viết nằm kho —
-- nó đếm đúng dòng hợp lệ ấy là "hỏng" và dừng cả file. Mà dòng đầu file hứa
-- "CHẠY LẠI NHIỀU LẦN VÔ HẠI", nên đó là một lời hứa gãy chứ không phải một
-- cảnh báo. Chiều còn đúng, và là chiều duy nhất ràng buộc mới cấm: đang chờ
-- người ta gật mà đã chiếm sẵn chỗ trong vườn người ta.
do $$
declare so_hong int;
begin
  select count(*) into so_hong
    from tieu_diem
   where giao_luc is not null and nhan_viec_luc is null and luong is not null;

  if so_hong > 0 then
    raise exception
      'Có % cam kết đang chờ nhận mà đã chiếm sẵn một luống — phạm ràng buộc cho_nhan_thi_luong_phai_rong. Dừng lại xem từng dòng trước khi chạy tiếp: select ma, ten, luong, giao_luc, nhan_viec_luc from tieu_diem where giao_luc is not null and nhan_viec_luc is null and luong is not null;',
      so_hong;
  end if;
end $$;


-- ════════════════════════════════════════════════════════════════════════════
-- 3. ĐỔI HÀNG RÀO — BỎ NOT NULL, DỰNG THỨ THAY THẾ NGAY TRONG CÙNG MỘT LƯỢT
-- ════════════════════════════════════════════════════════════════════════════

-- ─── 3a. Bỏ NOT NULL ────────────────────────────────────────────────────────
-- Cam kết ở kho chưa chiếm chỗ nào trong vườn ai cả, nên nó KHÔNG có luống.
-- LUỐNG RỖNG = ĐANG Ở KHO. Đó là định nghĩa, không phải một suy đoán — và từ
-- 27/08 nó là định nghĩa DUY NHẤT của chữ "kho" trong cả file này.
alter table tieu_diem alter column luong drop not null;

comment on column tieu_diem.luong is
  'Chỗ ngồi 1–5 trong vườn của chủ cam kết. RỖNG nghĩa là cam kết đang nằm KHO — chưa chiếm chỗ nào, chưa tính vào trần ba luống. Kho chứa HAI loại (Tracy chốt 27/08): ① cam kết người khác giao cho mình mà mình chưa bấm nhận (kể cả đã từ chối) · ② cam kết TỰ VIẾT mà mình chưa kéo vào một trong ba luống. Ràng buộc cho_nhan_thi_luong_phai_rong gác chiều ngược lại: đang chờ mình gật thì KHÔNG được chiếm sẵn luống. Kho không phải cửa hậu vô hạn — trigger tran_ca_kho_cam_ket đếm số dòng kho của từng người và so với nguoi.so_cam_ket_kho_toi_da. Ra vào luống bằng hai hàm vao_luong_cam_ket và ve_kho_cam_ket. Người dùng không nhìn thấy con số luống này (từ 08/08 giao diện đếm thứ tự nhận); trần chỗ ngồi của từng người nằm ở nguoi.so_cam_ket_toi_da và được trigger kiem_tran_cam_ket soi.';


-- ─── 3b. Thứ thay thế: chờ người ta gật thì đừng chiếm sẵn chỗ ──────────────
--
-- ⚠️ ĐÃ NỚI 27/08 — ĐỌC ĐOẠN NÀY TRƯỚC KHI SIẾT LẠI.
-- Bản đầu viết ĐẲNG THỨC HAI CHIỀU `(luong rỗng) = (đang chờ nhận)`, tức luống
-- rỗng CHỈ được phép cho cam kết được giao mà chưa ai nhận. Câu ấy chặn được
-- nhiều thứ, nhưng nó chặn nhầm luôn đúng thứ Tracy đặt hàng: *"Cam kết sẽ có
-- kho cam kết nữa nhưng khi thực hiện thì chỉ 3 cam kết 1 lúc thôi"*. Với đẳng
-- thức hai chiều, một cam kết TỰ VIẾT không vào kho được — nó buộc phải có
-- luống ngay từ lúc gieo, nghĩa là vườn đầy ba luống thì không viết thêm được
-- một dòng nào. Đợt trước vá tạm bằng cách CHẶN Ở CỬA (vườn đầy thì không cho
-- gieo). Đó là bắt người ta nhớ trong đầu thay vì cho họ một chỗ để ghi.
--
-- Nay chỉ giữ CHIỀU CÒN ĐÚNG, viết dạng "nếu … thì …":
--
--        đang CHỜ NHẬN   ⟹   luống BẮT BUỘC rỗng
--
-- Chiều này bảo vệ một thứ không ai được phép làm: chiếm chỗ trong vườn NGƯỜI
-- KHÁC trước khi người ta gật. Chiều ngược lại — "luống rỗng thì bắt buộc là
-- dòng chờ nhận" — nay SAI, vì luống rỗng còn có nghĩa thứ hai hoàn toàn hợp
-- lệ: cam kết tự viết đang nằm kho.
--
-- ⚠️ CHIỀU VỪA BỎ ĐI CHÍNH LÀ THỨ ĐANG GIỮ TRẦN BA LUỐNG. Bỏ nó mà không thay
-- bằng thứ khác là mở lại nguyên lỗ hổng 08/08 dưới một cái tên khác: gọi
-- thẳng API, đặt `luong = null`, gieo bao nhiêu cam kết tuỳ ý. Thứ thay thế là
-- HÀNG RÀO ĐẾM ở mục 3d — nó không hỏi "vì sao luống rỗng" nữa mà hỏi "kho của
-- người này đã bao nhiêu dòng rồi". Hai mục ấy là MỘT việc, đừng tách.
--
-- ─── ĐỔI TÊN RÀNG BUỘC — CÓ CHỦ Ý ───────────────────────────────────────────
-- Tên cũ `luong_rong_chi_khi_cho_nhan` đọc thành "luống rỗng CHỈ KHI chờ nhận"
-- — đúng cái vế vừa bỏ. Giữ tên cũ là để lại trong máy chủ một câu lỗi nói sai
-- luật cho người tiếp theo đọc nó. Tên mới `cho_nhan_thi_luong_phai_rong` đọc
-- đúng chiều còn lại. Câu `drop … if exists` khai CẢ HAI tên để chạy lại file
-- không đụng nhau, và để máy chủ nào đã chạy bản cũ thì tên cũ được dọn đi.
--
-- ⚠️ LOGIC BA TRỊ — chỗ này phải nghĩ kỹ, vì CHECK chỉ chặn khi ra FALSE, còn
-- ra NULL là dòng ĐI QUA. Cả ba vế ở đây đều dùng `is null` / `is not null`,
-- những phép toán KHÔNG BAO GIỜ trả NULL — chúng luôn ra đúng hoặc sai, kể cả
-- khi mọi cột đều rỗng. Nên mệnh đề luôn ra đúng hoặc sai, không có cửa NULL
-- nào để lọt. Đây chính là chỗ ba hàng rào cũ đã thua: chúng dùng `between` và
-- `>`, hai phép toán gặp NULL là trả NULL.
--
-- Vế điều kiện neo vào `giao_luc` chứ KHÔNG phải `giao_boi` — lý do đầy đủ ở
-- mục 1, đoạn ①. Tóm lại: `giao_boi` bị khoá ngoại tự đặt về rỗng lúc người
-- giao rời đội, và nếu ràng buộc này neo vào nó thì đúng lúc ấy mọi dòng kho
-- của người ta đồng loạt phạm ràng buộc, tức KHÔNG XOÁ ĐƯỢC MỘT NGƯỜI KHỎI
-- ĐỘI NỮA.
--
-- ─── BẢNG CHÂN TRỊ ĐỦ TÁM Ô — chép lại để phiên sau khỏi nghĩ lại ───────────
-- Điều kiện  P = (giao_luc CÓ và nhan_viec_luc RỖNG)  — "đang chờ nhận".
-- Kết luận   R = (luong RỖNG).
-- Dòng đi qua khi  (không P)  HOẶC  R.  Chỉ CHẶN ở đúng một ô: P đúng, R sai.
-- Không ô nào ra NULL.
--
--   #  giao_luc  nhan_viec_luc  luong │  P     R   │ kết quả
--   ─────────────────────────────────┼────────────┼─────────────────────────────
--   1   rỗng      rỗng          rỗng │ sai   đúng │ QUA — TỰ VIẾT NẰM KHO ✔ 🆕
--   2   rỗng      rỗng          có   │ sai   sai  │ QUA — TỰ VIẾT đang chạy ✔
--   3   rỗng      có            rỗng │ sai   đúng │ QUA ⚠️ XEM GHI CHÚ DƯỚI
--   4   rỗng      có            có   │ sai   sai  │ QUA ⚠️ XEM GHI CHÚ DƯỚI
--   5   có        rỗng          rỗng │ đúng  đúng │ QUA — ĐƯỢC GIAO, nằm kho ✔
--   6   có        rỗng          có   │ đúng  sai  │ CHẶN — chưa gật đã chiếm chỗ
--   7   có        có            rỗng │ sai   đúng │ QUA — ĐÃ NHẬN rồi TRẢ VỀ KHO ✔ 🆕
--   8   có        có            có   │ sai   sai  │ QUA — ĐÃ NHẬN, ngồi vườn ✔
--
-- 🆕 HAI Ô ĐỔI NGHĨA SO VỚI BẢN CŨ, và cả hai đều là thứ đợt này dựng ra:
--   · Ô 1 trước CHẶN, nay QUA — đây CHÍNH LÀ kho cam kết tự viết Tracy đặt.
--   · Ô 7 trước CHẶN ("đã nhận mà lách trần"), nay QUA — đây là hàm
--     `ve_kho_cam_ket`: trả một cam kết đang chạy về kho để nhường chỗ. Cái
--     từng là đường lách nay là một cửa có tên, và thứ giữ nó không thành
--     đường lách nữa là hàng rào ĐẾM ở mục 3d, không phải ràng buộc này.
--
-- ⚠️ Ô 3 VÀ Ô 4 RÀNG BUỘC NÀY KHÔNG BẮT ĐƯỢC: một cam kết TỰ VIẾT (không ai
-- giao) mà lại mang dấu đã-nhận-việc. Vế điều kiện SAI nên mệnh đề thành đúng
-- và dòng đi qua, dù luống rỗng hay có. Ràng buộc `check` không phân biệt được
-- ca này vì nó chỉ nhìn MỘT dòng, không nhìn dòng ấy đến từ đâu. Chỗ bịt là
-- trigger `kiem_giao_cam_ket`: nhánh CHÈN chặn ở phần "cam kết tự viết thì
-- không mang dấu vết giao nhận nào", nhánh SỬA chặn ở phần đối xứng ngay dưới
-- nó. Bỏ một trong hai nhánh ấy là hai ô ấy mở toang.
alter table tieu_diem drop constraint if exists luong_rong_chi_khi_cho_nhan;  -- tên đời đầu
alter table tieu_diem drop constraint if exists cho_nhan_thi_luong_phai_rong;
alter table tieu_diem add  constraint cho_nhan_thi_luong_phai_rong
  check ( not (giao_luc is not null and nhan_viec_luc is null)
          or luong is null );

-- Không ai tự giao việc cho mình. Tự hứa thì gieo thẳng vào vườn (đường ①) —
-- đi vòng qua đường giao việc chỉ để có thêm một dòng trong sổ giao nhận là
-- bịa ra một lời giao không có thật.
-- `is distinct from` chứ không phải `<>`: với `<>`, dòng tự viết (giao_boi
-- rỗng) cho ra NULL và đi qua mà mình không biết vì sao nó qua. `is distinct
-- from` trả về đúng/sai thật — dòng tự viết qua vì nó ĐƯỢC PHÉP qua.
--
-- BẢNG CHÂN TRỊ (nguoi_id là NOT NULL nên chỉ có ba ô):
--   giao_boi rỗng            → is distinct from → ĐÚNG  → QUA (tự viết, hoặc
--                                                          người giao đã rời đội)
--   giao_boi = nguoi_id      →                  → SAI   → CHẶN
--   giao_boi khác nguoi_id   →                  → ĐÚNG  → QUA (ca thường)
alter table tieu_diem drop constraint if exists khong_tu_giao_cho_minh;
alter table tieu_diem add  constraint khong_tu_giao_cho_minh
  check (giao_boi is distinct from nguoi_id);

-- ─── Lời từ chối và lý do của nó luôn đi cùng nhau ──────────────────────────
-- Không có ràng buộc này thì luật "từ chối phải khai lý do" chỉ sống bên trong
-- hàm `tu_choi_cam_ket`, tức nó nằm ở ĐƯỜNG ĐI chứ không nằm ở DỮ LIỆU. Mà
-- chính sách `sua_tieudiem` cho chủ dòng sửa dòng của mình, và chủ dòng ở đây
-- CHÍNH LÀ người được giao: một câu `update tieu_diem set tu_choi_luc = now()`
-- gọi thẳng API là trả lại được cam kết với lý do trống, người giao ngồi nhìn
-- một lời từ chối câm. Chú thích cột đã hứa lý do là BẮT BUỘC — hứa ở chú
-- thích mà không có hàng rào thì là hứa suông.
--
-- Cùng dáng đẳng-thức-hai-chiều với ràng buộc luống ở trên, và cùng lối lẽ với
-- `nghen_phai_khai_thu_chan` đang chạy trên bảng task.
--
-- BẢNG CHÂN TRỊ ĐỦ BỐN Ô. Vế phải dùng `coalesce` nên KHÔNG BAO GIỜ ra NULL,
-- kể cả khi tu_choi_ly_do rỗng:
--   tu_choi_luc rỗng · lý do trống      → đúng = đúng → QUA  (chưa từ chối ✔)
--   tu_choi_luc rỗng · lý do CÓ CHỮ     → đúng ≠ sai  → CHẶN (khai lý do cho
--                                                       một lời từ chối chưa
--                                                       có — sổ khai khống)
--   tu_choi_luc CÓ   · lý do trống      → sai  ≠ đúng → CHẶN (đúng lỗ hổng trên)
--   tu_choi_luc CÓ   · lý do CÓ CHỮ     → sai  = sai  → QUA  (ca thường ✔)
alter table tieu_diem drop constraint if exists tu_choi_phai_khai_ly_do;
alter table tieu_diem add  constraint tu_choi_phai_khai_ly_do
  check ( (tu_choi_luc is null)
          = (length(trim(coalesce(tu_choi_ly_do, ''))) = 0) );


-- ─── 3c. Trần LỜI GIAO — người khác dồn lên tôi thì cũng có giới hạn ────────
-- ⚠️ MỘT TRONG BA TRẦN, ĐỪNG LẪN. Bảng đối chiếu đủ ba nằm ở đầu mục 3d.
-- Mục này gác đúng MỘT câu: người khác được dồn lên tôi bao nhiêu lời giao
-- chưa trả lời. Trần CẢ KHO (gồm cả cam kết tôi tự viết) ở mục 3d; trần CHỖ
-- NGỒI đang chạy vẫn ở `kiem_tran_cam_ket` như cũ.
--
-- Trần chỗ ngồi (`kiem_tran_cam_ket`) đếm SỐ LUỐNG, nên nó mù với kho: dòng
-- kho có luống rỗng, `NULL > tran` ra NULL, nhánh `if` không chạy. Đúng thiết
-- kế — kho không được chiếm chỗ trong vườn. Nhưng để trống hoàn toàn thì một
-- PIC nóng ruột đổ được năm mươi cam kết vào kho một người, và khối "Chờ bạn"
-- của người ta thành một bãi không ai đọc nổi. Trần này gác chuyện đó.
--
-- ⚠️ MỘT CON SỐ RIÊNG, KHÔNG DÙNG CHUNG `so_cam_ket_toi_da` — ĐÃ SỬA 27/08.
-- Bản đầu dùng chung con số với trần chỗ ngồi, lập luận là "cùng một câu hỏi
-- người này ôm nổi mấy việc". Sai, và sai ngược lại đúng lời Tracy chốt: cam
-- kết chờ nhận *"nằm KHO, KHÔNG chiếm luống, KHÔNG tính vào trần 3"*. Dùng
-- chung con số 3 nghĩa là một người đang chẳng gánh việc nào, chỉ có ba lời
-- giao chưa kịp trả lời, đã bị đá lời giao thứ tư — tức kho CÓ tính vào trần
-- 3, đúng thứ Tracy vừa nói là không.
--
-- Nên trần kho có cột riêng, mặc định 10: rộng rãi cho việc thật, vẫn chặn
-- được ca đổ năm mươi lời giao vào một người. Hai con số tách nhau vì chúng
-- trả lời hai câu khác nhau — "ôm nổi mấy việc" và "đọc nổi mấy lời mời".
alter table nguoi add column if not exists so_loi_giao_toi_da smallint not null default 10;

comment on column nguoi.so_loi_giao_toi_da is
  'Trần KHO: nhiều nhất bao nhiêu lời giao chưa trả lời được phép nằm chờ người này cùng lúc. KHÁC HẲN so_cam_ket_toi_da (trần CHỖ NGỒI trong vườn, mặc định 3) — Tracy chốt 27/08 cam kết chờ nhận KHÔNG tính vào trần 3, nên hai con số phải tách nhau. Trigger tran_kho_cam_ket soi cột này.';

-- Cam kết ĐÃ TỪ CHỐI KHÔNG tính vào trần này: từ chối xong thì quả bóng đã
-- sang phía người giao, phạt người nhận vì một việc họ đã trả lại là sai vai.
-- ⚠️ Cộng với việc dòng bị từ chối KHÔNG tự biến mất, luật ấy làm trần kho
-- thành một cái cửa quay: giao đủ trần → bị từ chối → bộ đếm về 0 → giao tiếp.
-- Cái phanh của cửa quay là hàm `rut_lai_cam_ket` ở mục 7c: người giao phải
-- tự tay dọn lời giao đã bị trả lại thì mới có chỗ giao tiếp, và mỗi lần dọn
-- là một lần họ đọc lại lý do bị từ chối. Không có hàm ấy thì trần này chỉ
-- làm dài thêm một danh sách không ai xoá được.
create or replace function tran_kho_cam_ket()
returns trigger language plpgsql
security definer set search_path = public
as $$
declare
  tran   smallint;
  so_cho int;
begin
  -- Chỉ soi khi dòng NÀY đang thật sự ở nấc chờ nhận. Dòng tự viết, dòng đã
  -- nhận, dòng đã từ chối đều đi thẳng qua.
  if new.giao_luc is null
     or new.nhan_viec_luc is not null
     or new.tu_choi_luc is not null then
    return new;
  end if;

  -- Khoá dòng `nguoi` TRƯỚC khi đếm. Đây là kiểu đếm-rồi-chèn, thứ luôn hở ở
  -- giữa hai bước: hai PIC bấm Giao gần như cùng lúc cho cùng một người thì cả
  -- hai đọc được con số cũ và cả hai cùng lọt. Trần chỗ ngồi không cần câu này
  -- vì phía sau nó còn chỉ mục `mot_hat_song_moi_luong` làm hàng rào vật lý;
  -- trần kho KHÔNG có chỉ mục nào đỡ, nên phải tự xếp hàng. Dùng lại đúng dòng
  -- `nguoi` mà câu dưới vốn đã phải đọc — không thêm một lần chạm bảng nào.
  perform 1 from nguoi where id = new.nguoi_id for update;

  select so_loi_giao_toi_da into tran from nguoi where id = new.nguoi_id;
  tran := coalesce(tran, 10);

  select count(*) into so_cho
    from tieu_diem o
   where o.nguoi_id      = new.nguoi_id
     and o.ma           <> new.ma          -- không tự đếm chính mình khi UPDATE
     and o.giao_luc     is not null
     and o.nhan_viec_luc is null
     and o.tu_choi_luc  is null
     and not o.xong;

  -- Câu lỗi nói được CẢ HAI ca. Điều kiện là `so_cho + 1 > tran`, nên so_cho
  -- có thể LỚN HƠN trần chứ không chỉ bằng — ai đó hạ trần của một người từ 10
  -- xuống 3 trong lúc kho họ đang có 4 dòng là rơi vào ca ấy ngay. Bản đầu
  -- viết "bằng đúng trần %", một câu tự mâu thuẫn khi in ra: *"đang có 4, bằng
  -- đúng trần 3"*.
  if so_cho + 1 > tran then
    raise exception
      'Người này đang có % lời giao chưa trả lời, trần của họ là % chỗ. Giao thêm thì phải đợi họ trả lời bớt, hoặc rút lại một lời giao cũ — app không xếp hàng thay ai.',
      so_cho, tran;
  end if;

  return new;
end $$;

comment on function tran_kho_cam_ket is
  'Chặn dồn việc vào KHO của một người. Đếm số cam kết đang CHỜ NHẬN (chưa nhận, chưa từ chối) và so với nguoi.so_loi_giao_toi_da — con số RIÊNG, không dùng chung với trần chỗ ngồi so_cam_ket_toi_da, vì Tracy chốt cam kết chờ nhận không tính vào trần 3. Trigger kiem_tran_cam_ket không thay được việc này: nó soi số luống, mà dòng kho không có luống.';

drop trigger if exists trg_tran_kho_cam_ket on tieu_diem;
create trigger trg_tran_kho_cam_ket
  before insert or update of nguoi_id, giao_luc, nhan_viec_luc, tu_choi_luc on tieu_diem
  for each row execute function tran_kho_cam_ket();


-- ─── 3d. TRẦN CẢ KHO — hàng rào ĐẾM, thay cho vế vừa bỏ ở mục 3b ────────────
--
-- ⚠️ ĐÂY LÀ THỨ DUY NHẤT CÒN GIỮ LUẬT BA LUỐNG SAU KHI NỚI KHO. Đọc hết mục
-- này trước khi tháo bất cứ dòng nào của nó.
--
-- Ba hàng rào cũ của luật ba luống đều MÙ với dòng luống rỗng, và cái mù ấy
-- không phải lỗi — đó là thiết kế, vì cả ba đều hỏi "chỗ ngồi số mấy":
--   · `luong_trong_khoang_1_5` gặp NULL trả NULL → dòng đi qua,
--   · chỉ mục `mot_hat_song_moi_luong` có sẵn `where … luong is not null`,
--   · `kiem_tran_cam_ket` so `new.luong > tran`; NULL so với số cũng ra NULL.
-- Thứ từng bịt lỗ ấy là vế "luống rỗng thì BẮT BUỘC là dòng chờ nhận" của
-- ràng buộc mục 3b — nó không đếm gì cả, nó chỉ đòi mỗi dòng rỗng phải khai
-- một lời giao có thật, và lời giao thì phải đi qua `giao_cam_ket()`.
-- Mục 3b vừa bỏ vế ấy. Không có mục 3d thì từ giây phút đó, một câu
-- `insert … luong = null` gọi thẳng API sinh ra bao nhiêu cam kết cũng được,
-- và "chỉ 3 cam kết 1 lúc" chỉ còn là một câu nói trong giao diện.
--
-- Nên hàng rào mới KHÔNG hỏi lý do nữa, nó ĐẾM: kho của một người được phép
-- dài tới đâu. Câu hỏi đổi từ *"vì sao dòng này rỗng"* sang *"người này đã ôm
-- bao nhiêu dòng rỗng rồi"* — và câu sau mới là câu chặn được cửa hậu.
--
-- ─── VÌ SAO MỘT CỘT RIÊNG, KHÔNG DÙNG LẠI `so_loi_giao_toi_da` ──────────────
-- Cột ấy có thật, đang chạy, và đang trả lời một câu KHÁC. Xếp cạnh nhau:
--
--   nguoi.so_loi_giao_toi_da     (mục 3c, mặc định 10)
--     → "NGƯỜI KHÁC được phép dồn lên tôi bao nhiêu lời giao chưa trả lời"
--     → hàng rào che TÔI khỏi hành động của NGƯỜI KHÁC
--     → đếm tập CON: chờ nhận, chưa từ chối
--
--   nguoi.so_cam_ket_kho_toi_da  (mục này, mặc định 20)
--     → "danh sách chờ của CHÍNH TÔI được phép dài bao nhiêu"
--     → hàng rào che LUẬT BA LUỐNG khỏi hành động của CHÍNH TÔI
--     → đếm TOÀN BỘ kho: tự viết + được giao + đã từ chối
--
-- Dùng chung một con số thì cả hai chiều đều sai vai, và sai theo kiểu người
-- dùng không đời nào đoán ra:
--   → hai mươi cam kết nháp tôi tự viết làm cấp trên KHÔNG giao được việc cho
--     tôi nữa — phạt người ta vì danh sách nháp của tôi;
--   → hai mươi lời giao người ta vừa dồn lên tôi làm tôi KHÔNG ghi nổi một
--     dòng của riêng mình — phạt tôi vì cơn nóng ruột của người ta.
-- Hai câu hỏi khác nhau thì hai con số. Cùng lối lẽ mục 3c đã dùng khi tách
-- `so_loi_giao_toi_da` ra khỏi `so_cam_ket_toi_da`.
--
-- Hai trần LỒNG NHAU, không đá nhau: cả kho ≤ 20, trong đó phần lời giao chưa
-- trả lời ≤ 10. Ai hạ `so_cam_ket_kho_toi_da` xuống dưới `so_loi_giao_toi_da`
-- thì trần lời giao thành trần chết — trần kho chặn trước. Không hỏng lặng:
-- câu lỗi của trần kho nói rõ kho đầy, đọc là biết chỗ chỉnh.
--
-- Mặc định 20 chứ không phải 3: kho là chỗ GHI RA cho khỏi quên, nó phải rộng
-- hơn chỗ LÀM. Ba luống là trần của việc đang chạy, và trần ấy do
-- `kiem_tran_cam_ket` giữ, không phải cột này.
alter table nguoi add column if not exists so_cam_ket_kho_toi_da smallint not null default 20;

comment on column nguoi.so_cam_ket_kho_toi_da is
  'Trần CẢ KHO: nhiều nhất bao nhiêu cam kết luống-rỗng được phép nằm chờ của người này cùng lúc — đếm cả cam kết tự viết chưa kéo vào luống LẪN lời giao chưa trả lời. Đây là hàng rào ĐẾM dựng 27/08 để thay vế bị bỏ khỏi ràng buộc mục 3b; không có nó thì kho là cửa hậu vô hạn và luật ba luống chỉ còn nằm trong giao diện. KHÁC so_loi_giao_toi_da (trần riêng cho lời giao của NGƯỜI KHÁC dồn lên mình, mặc định 10) và KHÁC so_cam_ket_toi_da (trần CHỖ NGỒI đang chạy, mặc định 3). Trigger tran_ca_kho_cam_ket soi cột này.';

create or replace function tran_ca_kho_cam_ket()
returns trigger language plpgsql
security definer set search_path = public
as $$
declare
  tran      smallint;
  so_o_kho  int;
begin
  -- Dòng có luống thì không nằm kho; dòng đã đóng thì không chờ ai nữa. Cả
  -- hai đi thẳng qua. `new.xong` là boolean NOT NULL nên không có cửa NULL.
  if new.luong is not null or new.xong then
    return new;
  end if;

  -- Khoá dòng `nguoi` TRƯỚC khi đếm — cùng lý do đã ghi ở mục 3c, và ở đây
  -- còn nặng hơn: trần kho KHÔNG có chỉ mục nào đỡ phía sau (chỉ mục
  -- `mot_hat_song_moi_luong` tự loại dòng luống rỗng ra khỏi tầm soi), nên
  -- đếm-rồi-chèn mà không xếp hàng là hai lượt cùng lúc lọt cả hai, mãi mãi.
  -- Khoá cùng một dòng `nguoi` mà mục 3c khoá, theo cùng thứ tự — hai trigger
  -- không kẹt nhau.
  perform 1 from nguoi where id = new.nguoi_id for update;

  select so_cam_ket_kho_toi_da into tran from nguoi where id = new.nguoi_id;
  tran := coalesce(tran, 20);

  select count(*) into so_o_kho
    from tieu_diem o
   where o.nguoi_id = new.nguoi_id
     and o.ma      <> new.ma          -- không tự đếm chính mình khi UPDATE
     and o.luong   is null
     and not o.xong;

  if so_o_kho + 1 > tran then
    raise exception
      'Kho cam kết của người này đang có % dòng chưa vào luống, trần là % dòng. Kéo bớt một cam kết vào luống và làm cho xong, hoặc dọn bớt dòng không còn cần nữa.',
      so_o_kho, tran;
  end if;

  return new;
end $$;

comment on function tran_ca_kho_cam_ket is
  'Đếm số cam kết đang nằm KHO của một người (luong rỗng và chưa xong) rồi so với nguoi.so_cam_ket_kho_toi_da. Đây là thứ THAY THẾ vế "luống rỗng thì bắt buộc là dòng chờ nhận" bị bỏ khỏi ràng buộc mục 3b ngày 27/08 — không có nó, kho là cửa hậu vô hạn và luật ba luống sập theo đúng lối lỗ hổng 08/08. Gác cả INSERT lẫn UPDATE OF luong: chỉ gác chèn thì đẩy một cam kết đang chạy về kho là một đường vòng qua hàng rào.';

-- ⚠️ PHẢI GÁC CẢ `update of luong`, KHÔNG CHỈ `insert`.
-- Chỉ gác chèn thì đường vòng mở ngay và không cần một mẹo nào: gieo đủ ba
-- cam kết vào ba luống theo đúng luật, rồi `update … set luong = null` cả ba
-- — kho phình ra mà bộ đếm chưa lần nào chạy. Lặp lại là kho vô hạn, xây bằng
-- toàn những bước hợp lệ.
-- `nguoi_id` cũng trong danh sách: đổi chủ một dòng kho là chuyển nó sang kho
-- người khác, và kho ấy phải được đếm lại. `xong` cũng vậy: một dòng đã đóng
-- không nằm kho, nhưng mở lại (xong true → false) là nó quay vào kho.
drop trigger if exists trg_tran_ca_kho_cam_ket on tieu_diem;
create trigger trg_tran_ca_kho_cam_ket
  before insert or update of luong, nguoi_id, xong on tieu_diem
  for each row execute function tran_ca_kho_cam_ket();


-- ════════════════════════════════════════════════════════════════════════════
-- 4. SỔ GIAO NHẬN KHÔNG TẨY XOÁ ĐƯỢC
-- ════════════════════════════════════════════════════════════════════════════
-- Năm cột ở mục 1 là LỜI KHAI về một việc đã xảy ra giữa hai người. Chính sách
-- `sua_tieudiem` cho chủ dòng sửa dòng của mình, mà chủ dòng ở đây là NGƯỜI
-- NHẬN — tức không có trigger này thì người nhận sửa được cả lời khai ai giao
-- việc cho mình, giao lúc nào, và xoá được dấu vết mình đã từ chối.
--
-- Cùng một lối lẽ đã dùng cho `da_xem_luc` (25/08): RLS của Postgres chặn theo
-- DÒNG chứ không theo CỘT, nên chặn theo cột phải làm ở tầng trigger.
create or replace function kiem_giao_cam_ket()
returns trigger language plpgsql
as $$
begin
  -- ─── XOÁ ───────────────────────────────────────────────────────────────
  -- Luật: MỘT CAM KẾT ĐÃ ĐƯỢC GIAO THÌ NGƯỜI NHẬN KHÔNG XOÁ ĐƯỢC NỮA — kể cả
  -- sau khi đã bấm nhận việc. Bản đầu chỉ chặn lúc dòng còn nằm kho, và đó là
  -- một lỗ hổng đủ để xoá sạch một lời giao bằng đúng hai lệnh: bấm Nhận việc,
  -- rồi gọi thẳng API xoá dòng. Sau đó không bảng nào, khung nhìn nào, khối
  -- "Chờ bạn" nào của người giao còn thấy nó — nó chưa bao giờ tồn tại. Ngược
  -- đời hơn: từ chối công khai thì dòng ở lại vĩnh viễn, còn nhận rồi im lặng
  -- xoá thì trắng án.
  --
  -- Ba cửa được đi qua, xếp theo thứ tự soi:
  if tg_op = 'DELETE' then

    -- CỬA 1 — XOÁ DÂY CHUYỀN TỪ BẢNG CHA. `tieu_diem.nguoi_id` khai
    -- `on delete cascade`, nên xoá một người là Postgres tự phát lệnh xoá mọi
    -- cam kết của họ. Lệnh ấy do MỘT TRIGGER phát ra chứ không do ai gõ, và
    -- `pg_trigger_depth() > 1` là cách nhận ra chuyện đó. Không mở cửa này thì
    -- không xoá được khỏi bảng `nguoi` bất kỳ ai từng được giao một cam kết,
    -- và câu lỗi hiện ra nói về cam kết chứ không nhắc gì tới việc đang xoá
    -- người — người quản trị không tài nào lần ra.
    if pg_trigger_depth() > 1 then
      return old;
    end if;

    -- Cam kết TỰ VIẾT thì chủ nó muốn xoá lúc nào cũng được. Đường ① không
    -- dính gì tới sổ giao nhận.
    if old.giao_luc is null then
      return old;
    end if;

    -- CỬA 2 — NGƯỜI GIAO RÚT LẠI LỜI GIAO CỦA CHÍNH MÌNH, khi người kia chưa
    -- nhận (chưa trả lời, hoặc đã từ chối). Đường DUY NHẤT tới được đây là hàm
    -- `rut_lai_cam_ket` ở mục 7c: chính sách `xoa_tieudiem` chỉ cho CHỦ DÒNG
    -- xoá, mà chủ dòng là người NHẬN, còn ràng buộc `khong_tu_giao_cho_minh`
    -- bảo đảm người giao và người nhận không bao giờ là một. Nên vế dưới đây
    -- người nhận không tài nào thoả được.
    if old.nhan_viec_luc is null
       and old.giao_boi = nguoi_id_dang_nhap() then
      return old;
    end if;

    -- CỬA 3 — KHÔNG CÓ AI ĐANG ĐĂNG NHẬP. Mọi lệnh đi qua app đều mang theo
    -- một token, nên `nguoi_id_dang_nhap()` rỗng có đúng một nghĩa: đang gõ
    -- tay trong SQL Editor, tức Tracy tự dọn. Hàng rào này canh NGƯỜI DÙNG
    -- APP, không canh người quản trị — và chính sách RLS vẫn chặn đường ấy với
    -- mọi tài khoản thường (không có người đăng nhập thì `xoa_tieudiem` không
    -- khớp dòng nào).
    if nguoi_id_dang_nhap() is null then
      return old;
    end if;

    if old.nhan_viec_luc is not null then
      raise exception
        'Cam kết này người khác giao cho bạn và bạn đã bấm nhận việc — xoá đi là lời giao biến mất không dấu vết. Làm không nổi nữa thì nói với người giao, hoặc đóng cam kết lại.';
    elsif old.tu_choi_luc is null then
      raise exception
        'Cam kết này người khác giao cho bạn và bạn chưa trả lời — không xoá lặng đi được. Bấm Từ chối kèm lý do để lời giao quay về phía người giao.';
    else
      raise exception
        'Cam kết này đã bị từ chối rồi, dòng ở lại cho tới khi chính người giao rút nó về. Một lời từ chối biến mất không dấu vết là cách để việc rơi xuống đất mà không ai chịu.';
    end if;
  end if;

  -- ─── CHÈN ──────────────────────────────────────────────────────────────
  if tg_op = 'INSERT' then
    -- Hai cột này luôn đi cùng nhau, không bao giờ lệch một trong hai.
    if (new.giao_boi is null) <> (new.giao_luc is null) then
      raise exception
        'Dòng cam kết khai lệch sổ giao nhận: phải có ĐỦ cả người giao lẫn giờ giao, hoặc trống cả hai. Đường giao việc đúng là hàm giao_cam_ket().';
    end if;

    -- Cam kết tự viết thì không mang dấu vết giao nhận nào cả.
    if new.giao_boi is null
       and (new.nhan_viec_luc is not null
            or new.tu_choi_luc is not null
            or length(trim(coalesce(new.tu_choi_ly_do, ''))) > 0) then
      raise exception
        'Cam kết tự viết thì không có gì để nhận hay từ chối — bỏ trống nhan_viec_luc, tu_choi_luc và tu_choi_ly_do.';
    end if;

    -- Một lời giao vừa gửi đi thì chưa thể đã được trả lời.
    if new.giao_boi is not null
       and (new.nhan_viec_luc is not null or new.tu_choi_luc is not null) then
      raise exception
        'Lời giao vừa gửi mà đã mang sẵn câu trả lời — người nhận trả lời bằng nhan_viec_cam_ket() hoặc tu_choi_cam_ket(), không phải bằng dòng chèn.';
    end if;

    return new;
  end if;

  -- ─── SỬA ───────────────────────────────────────────────────────────────
  -- `giao_luc` BẤT BIẾN TUYỆT ĐỐI. Không lệnh nào, không khoá ngoại nào chạm
  -- được nó — đó chính là lý do mọi hàng rào của file này neo vào nó chứ không
  -- neo vào `giao_boi` (xem mục 1, đoạn ①).
  if new.giao_luc is distinct from old.giao_luc then
    raise exception 'Giờ giao cam kết do máy chủ đóng dấu, không sửa lại được.';
  end if;

  -- `giao_boi` đi được ĐÚNG MỘT HƯỚNG, và chỉ trong đúng một hoàn cảnh: từ
  -- có-giá-trị sang rỗng, khi người ấy đã thật sự không còn trong bảng `nguoi`.
  -- Đây là lệnh `update` mà khoá ngoại `on delete set null` tự phát ra lúc xoá
  -- một người, và cấm nó là cấm luôn việc cho ai đó rời đội.
  -- Vế `not exists` là thứ giữ cửa hẹp: người NHẬN cũng gọi được một câu
  -- update đặt `giao_boi = null` để xoá tên người giao khỏi dòng của mình —
  -- nhưng chừng nào người giao còn trong bảng thì vế ấy sai và cửa đóng.
  if new.giao_boi is distinct from old.giao_boi then
    if not (old.giao_boi is not null
            and new.giao_boi is null
            and not exists (select 1 from nguoi where id = old.giao_boi)) then
      raise exception 'Ai giao cam kết này là chuyện đã xảy ra rồi, không sửa lại được.';
    end if;
  end if;

  -- Ô SỐ 4 CỦA BẢNG CHÂN TRỊ Ở MỤC 3b — ô duy nhất ràng buộc `check` không bắt
  -- được. Đối xứng với câu đã có ở nhánh CHÈN: một cam kết TỰ VIẾT không có gì
  -- để nhận, để từ chối, hay để nêu lý do. Thiếu câu này thì một dòng tự viết
  -- bị đóng dấu `nhan_viec_luc` bằng một câu update thường, và sổ khai một lời
  -- nhận việc chưa từng có ai giao.
  if new.giao_luc is null
     and (new.nhan_viec_luc is not null
          or new.tu_choi_luc is not null
          or length(trim(coalesce(new.tu_choi_ly_do, ''))) > 0) then
    raise exception 'Cam kết tự viết thì không có gì để nhận hay từ chối.';
  end if;

  -- Mốc trả lời chỉ đi một chiều: từ trống sang có giờ, không bao giờ ngược.
  if old.nhan_viec_luc is not null and new.nhan_viec_luc is null then
    raise exception 'Đã nhận việc rồi thì không rút lại lời nhận được. Cam kết làm không nổi thì nói với người giao, đừng gỡ dấu.';
  end if;
  if old.tu_choi_luc is not null and new.tu_choi_luc is null then
    raise exception 'Đã từ chối rồi thì lời từ chối ở lại trong sổ. Muốn làm thì nhờ người giao giao lại một cam kết mới.';
  end if;

  -- Lý do từ chối cũng là một nửa của lời khai, và nửa nào cũng bất biến. Bản
  -- đầu canh `tu_choi_luc` mà bỏ quên `tu_choi_ly_do`: giờ từ chối ở lại, còn
  -- lý do thì một câu update là xoá trắng, và người giao không có cách nào
  -- biết nó từng có.
  if old.tu_choi_luc is not null
     and new.tu_choi_ly_do is distinct from old.tu_choi_ly_do then
    raise exception 'Lý do từ chối đã khai rồi thì ở lại trong sổ, không sửa lại được.';
  end if;

  -- ĐỀ BÀI LÀ CỦA NGƯỜI RA ĐỀ. Chừng nào cam kết còn nằm kho, người được giao
  -- chưa gật thì cũng chưa được sửa lại việc mình sắp gật. Không có câu này
  -- thì đường lách là: sửa đề bài cho nhẹ đi, rồi mới bấm Nhận việc — người
  -- giao không có dấu vết nào để biết. Đó vẫn là tẩy sổ, chỉ tẩy ở phần nội
  -- dung thay vì ở phần chữ ký.
  -- Không muốn làm đề bài này thì bấm Từ chối kèm lý do; người giao sửa đề rồi
  -- giao lại.
  if old.giao_luc is not null and old.nhan_viec_luc is null
     and (new.ten           is distinct from old.ten
       or new.tieu_chi_xong is distinct from old.tieu_chi_xong
       or new.han           is distinct from old.han
       or new.muc_tieu_id   is distinct from old.muc_tieu_id
       or new.moc_id        is distinct from old.moc_id) then
    raise exception 'Cam kết này đang chờ bạn trả lời — đề bài là của người giao, chưa nhận thì chưa sửa được. Không hợp thì bấm Từ chối kèm lý do để họ sửa lại rồi giao lại.';
  end if;

  -- Không có cửa nào vừa nhận vừa từ chối cùng một cam kết.
  if new.nhan_viec_luc is not null and new.tu_choi_luc is not null then
    raise exception 'Một cam kết chỉ có một câu trả lời: nhận, hoặc từ chối.';
  end if;

  -- Chưa nhận việc thì chưa có việc để đóng.
  if new.xong and not old.xong
     and new.giao_luc is not null and new.nhan_viec_luc is null then
    raise exception 'Cam kết này bạn chưa bấm nhận việc — chưa nhận thì chưa đóng được.';
  end if;

  return new;
end $$;

comment on function kiem_giao_cam_ket is
  'Giữ cho sổ giao nhận của một cam kết không tẩy xoá được. Bất biến: giao_luc (tuyệt đối), giao_boi (chỉ được về rỗng khi người ấy đã rời bảng nguoi), tu_choi_ly_do sau khi đã khai, và cả ĐỀ BÀI chừng nào dòng còn nằm kho. Một chiều: nhan_viec_luc và tu_choi_luc chỉ đi từ trống sang có giờ. Cấm: nhận và từ chối cùng lúc, đóng cam kết chưa nhận, đóng dấu nhận/từ chối lên một cam kết tự viết (ô số 4 của bảng chân trị mục 3b), và người nhận xoá một cam kết đã được giao — kể cả sau khi đã nhận. Ba cửa xoá còn mở: xoá dây chuyền lúc xoá một người, người GIAO rút lại lời giao chưa ai nhận (hàm rut_lai_cam_ket), và người quản trị gõ tay trong SQL Editor. Chính sách sua_tieudiem cho chủ dòng sửa dòng của mình, mà chủ dòng ở đây chính là người nhận — nên hàng rào phải nằm ở tầng trigger.';

drop trigger if exists trg_kiem_giao_cam_ket on tieu_diem;
create trigger trg_kiem_giao_cam_ket
  before insert or update on tieu_diem
  for each row execute function kiem_giao_cam_ket();

-- Trigger XOÁ tách riêng vì `before delete` không dùng chung câu lệnh
-- `create trigger` với `before insert or update` được.
drop trigger if exists trg_kiem_xoa_giao_cam_ket on tieu_diem;
create trigger trg_kiem_xoa_giao_cam_ket
  before delete on tieu_diem
  for each row execute function kiem_giao_cam_ket();


-- ════════════════════════════════════════════════════════════════════════════
-- 5. SIẾT CHÍNH SÁCH CHÈN — ĐƯỜNG GIEO THƯỜNG KHÔNG TẠO ĐƯỢC DÒNG KHO
-- ════════════════════════════════════════════════════════════════════════════
-- Không có vế `giao_boi is null` này thì bất cứ ai cũng chèn thẳng được một
-- dòng mang tên MÌNH với `giao_boi` trỏ vào một người khác — tức tự bịa ra
-- rằng sếp đã giao việc này cho mình, và tiện thể có một dòng luống rỗng hợp
-- lệ nằm ngoài trần chỗ ngồi. Đường ③ đi qua hàm `giao_cam_ket()` ở mục 6,
-- hàm ấy chạy bằng quyền người định nghĩa nên không vướng chính sách này.
--
-- Dựng lại theo đúng nếp cũ (drop rồi create) vì Postgres không có
-- `create or replace policy`.
drop policy if exists them_tieudiem on tieu_diem;
create policy them_tieudiem on tieu_diem for insert
  with check (nguoi_id = nguoi_id_dang_nhap()
              and giao_boi is null and giao_luc is null);

comment on policy them_tieudiem on tieu_diem is
  'Gieo cam kết bằng đường thường: chỉ tạo được dòng mang tên chính mình, và dòng đó phải là lời TỰ hứa (giao_boi VÀ giao_luc đều trống). Soi cả hai cột chứ không chỉ một, vì giao_luc mới là dấu nhận biết của đường ③ — soi mỗi giao_boi là chừa một cửa chèn dòng có giờ giao mà không có tên người giao. Muốn giao cam kết cho người khác thì gọi hàm giao_cam_ket().';


-- ════════════════════════════════════════════════════════════════════════════
-- 6. HÀM `giao_cam_ket` — ĐƯỜNG ③, PIC DỰ ÁN GIAO XUỐNG
-- ════════════════════════════════════════════════════════════════════════════
-- `security definer` vì đây là việc DUY NHẤT cần chèn một dòng mang tên người
-- khác. Hàm khoanh đúng việc ấy và tự soi lấy quyền, thay vì nới chính sách ra
-- cho mọi lệnh chèn. Dáng chép từ `nhan_cam_ket` (11/08).
--
-- HAI CỬA ĐƯỢC GIAO — RỜI NHAU, KHÔNG PHẢI HAI VẾ CỦA MỘT CHỮ `or`. Gọi đủ
-- tên để không lẫn hai tầng PIC:
--   · "PIC DỰ ÁN"  = muc_tieu.nguoi_id — người chịu trách nhiệm cuối của dự án.
--     Cửa DUY NHẤT cho cam kết CÓ dự án. Giao được cho bất cứ ai đã có tên
--     trong dự án của mình.
--   · "CẤP TRÊN TRỰC TIẾP" = nguoi.leader_id của người nhận (cột này CÓ THẬT,
--     dựng ở nang-cap-phan-cap-nghiem-thu.sql 11/08, cùng cột mà nhan_cam_ket
--     đang dùng để quyết ai ký nghiệm thu). Cửa DUY NHẤT cho cam kết KHÔNG
--     thuộc dự án nào. Cấp trên KHÔNG cắm được cam kết vào dự án của người
--     khác — lý do đầy đủ ghi ngay tại chỗ chốt quyền ở dưới.
-- Người nhận sau khi bấm nhận sẽ thành "PIC CAM KẾT" — người gánh việc ấy.
--
-- Trả về `ma` của cam kết vừa sinh (khác `nhan_cam_ket` trả void) để app nhảy
-- thẳng tới thẻ vừa tạo mà không phải đoán mã — mã do sequence máy chủ sinh,
-- app không tự tính được.
create or replace function giao_cam_ket(
  p_muc_tieu_id   bigint,
  p_nguoi_nhan    uuid,
  p_ten           text,
  p_tieu_chi_xong text,
  p_han           date   default null,
  p_moc_id        bigint default null,
  p_ngay_bat_dau  date   default null
)
returns text language plpgsql security definer set search_path = public
as $$
declare
  v_toi         uuid := nguoi_id_dang_nhap();
  v_la_pic      boolean := false;
  v_la_cap_tren boolean := false;
  v_ma          text;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  if p_nguoi_nhan is null then
    raise exception 'Chưa chọn người nhận cam kết';
  end if;

  if p_nguoi_nhan = v_toi then
    raise exception 'Tự hứa với mình thì gieo thẳng vào vườn của bạn, không đi đường giao việc.';
  end if;

  if not exists (select 1 from nguoi where id = p_nguoi_nhan) then
    raise exception 'Không tìm thấy người nhận trong danh sách đội';
  end if;

  if length(trim(coalesce(p_ten, ''))) = 0 then
    raise exception 'Cam kết phải có tên — người nhận cần biết mình đang được giao việc gì';
  end if;

  -- Tiêu chí xong khai NGAY LÚC GIAO, không để dành. Trigger kiem_o_xong sẽ
  -- chặn lúc đóng cam kết nếu ô này trống, và lúc ấy người phải nghĩ ra tiêu
  -- chí lại là người nhận chứ không phải người ra đề — sai vai.
  if length(trim(coalesce(p_tieu_chi_xong, ''))) = 0 then
    raise exception 'Giao việc thì phải khai XONG LÀ XONG CÁI GÌ, đo được. Không khai thì người nhận không biết đích ở đâu.';
  end if;

  -- ─── Cửa 1: PIC dự án ───────────────────────────────────────────────────
  if p_muc_tieu_id is not null then
    v_la_pic := exists (select 1 from muc_tieu m
                         where m.id = p_muc_tieu_id and m.nguoi_id = v_toi);
  end if;

  -- ─── Cửa 2: cấp trên trực tiếp của người nhận ───────────────────────────
  v_la_cap_tren := exists (select 1 from nguoi n
                            where n.id = p_nguoi_nhan and n.leader_id = v_toi);

  -- ⚠️ HAI CỬA NÀY KHÔNG ĐƯỢC GỘP BẰNG MỘT CHỮ `or` — đã sửa 27/08.
  -- Bản đầu chốt quyền bằng `if not (v_la_pic or v_la_cap_tren)`. Cửa 2 không
  -- hỏi một câu nào về dự án, nên một trưởng bộ phận cắm được cam kết vào dự
  -- án của PIC KHÁC: chỉ cần người nhận là cấp dưới của mình và có tên trong
  -- dự án ấy. Kiểm tra thành viên ở dưới cũng không cứu — nó soi NGƯỜI NHẬN,
  -- không soi người giao. Hậu quả là phần trăm tiến độ, thanh Gantt và danh
  -- sách cam kết của một dự án đổi mà PIC không hề gật, còn PIC thì không gỡ
  -- ra được vì họ không phải chủ dòng.
  --
  -- Nên hai cửa tách hẳn, đúng như chú thích ở đầu mục 6 vốn đã hứa:
  --   · CÓ dự án     → BẮT BUỘC là PIC của chính dự án ấy.
  --   · KHÔNG dự án  → BẮT BUỘC là cấp trên trực tiếp của người nhận.
  -- Cấp trên muốn giao việc trong một dự án của người khác thì nhờ PIC giao,
  -- hoặc nhận vai PIC. Đó là chuyện tổ chức, không phải chuyện app gật thay.
  if p_muc_tieu_id is null then
    if not v_la_cap_tren then
      raise exception 'Cam kết không thuộc dự án nào thì chỉ cấp trên trực tiếp của người nhận mới giao được. Chọn một dự án bạn làm PIC, hoặc để người ta tự gieo.';
    end if;
  else
    if not v_la_pic then
      raise exception 'Chỉ PIC của dự án này mới giao được cam kết vào đây. Bạn là cấp trên của người nhận thì giao được cho họ một cam kết KHÔNG thuộc dự án nào — cam kết nằm trong dự án của người khác phải do PIC dự án ấy giao.';
    end if;
  end if;

  -- Người nhận phải đã có tên trong dự án. Trigger kiem_thanh_vien_cam_ket
  -- cũng chặn ca này, nhưng chặn ở đây trước để câu lỗi nói đúng việc đang
  -- làm (đang GIAO, không phải đang gieo).
  if p_muc_tieu_id is not null
     and not la_thanh_vien_du_an(p_muc_tieu_id, p_nguoi_nhan) then
    raise exception 'Người này chưa có tên trong dự án — mời họ vào dự án trước rồi hãy giao cam kết.';
  end if;

  -- Cố ý KHÔNG nhận tham số `xong`: hai trigger kiem_o_xong và
  -- kiem_output_cam_ket đều chỉ gác `before update`, nên một dòng chèn thẳng
  -- với xong = true đi qua được cả hai. Đường giao việc không mở cửa đó.
  -- Cũng cố ý không nhận qua/mau/ten_loai: chúng là cách người nhận trang trí
  -- cây của mình, để họ chọn lúc bấm nhận việc. Mặc định của bảng lo phần này.
  insert into tieu_diem (
    ten, tieu_chi_xong, nguoi_id, muc_tieu_id, moc_id,
    han, ngay_bat_dau, ngay_gieo, luong, giao_boi, giao_luc
  )
  values (
    trim(p_ten), trim(p_tieu_chi_xong), p_nguoi_nhan, p_muc_tieu_id, p_moc_id,
    p_han, p_ngay_bat_dau, hom_nay(), null, v_toi, now()
  )
  returning ma into v_ma;

  return v_ma;
end $$;

comment on function giao_cam_ket(bigint, uuid, text, text, date, bigint, date) is
  'Đường ③: PIC DỰ ÁN (hoặc cấp trên trực tiếp theo nguoi.leader_id) giao một cam kết cho người khác. Dòng sinh ra ở nấc CHỜ NHẬN VIỆC — nằm kho, luống rỗng, chưa chiếm chỗ và chưa tính vào trần chỗ ngồi của người nhận. Trả về mã cam kết vừa sinh. Người nhận trả lời bằng nhan_viec_cam_ket() hoặc tu_choi_cam_ket(); app không tự gật thay ai và không có hạn trả lời.';

grant execute on function giao_cam_ket(bigint, uuid, text, text, date, bigint, date) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 7. TRẢ LỜI LỜI GIAO — VÀ HAI CỬA RA VÀO CỦA KHO
-- ════════════════════════════════════════════════════════════════════════════
-- Năm hàm, chia hai nhóm. Đừng lẫn nhóm nào với nhóm nào:
--
--   NHÓM KÝ TÊN — đóng dấu một việc đã xảy ra giữa HAI người, không gỡ lại:
--     7a `nhan_viec_cam_ket`  người được giao gật, và chọn luôn chỗ ngồi
--     7b `tu_choi_cam_ket`    người được giao lắc, kèm lý do bắt buộc
--     7c `rut_lai_cam_ket`    người GIAO gỡ lời giao chưa ai nhận
--
--   NHÓM XÊ DỊCH — chủ cam kết chuyển dòng CỦA MÌNH giữa kho và vườn, đi
--   lại được cả hai chiều, không đụng gì tới sổ giao nhận:
--     7d `vao_luong_cam_ket`  kéo một dòng từ kho vào một luống
--     7e `ve_kho_cam_ket`     trả một dòng đang chạy về kho, nhường chỗ
--
-- KHÔNG `security definer`, khác hẳn mục 6 — trừ 7c. Bốn hàm kia chỉ chạm dòng
-- của CHÍNH người gọi, mà chính sách `sua_tieudiem` đã cho phép đúng chuyện đó.
-- Chạy bằng quyền định nghĩa ở đây là cho không một quyền mà người ta vốn đã
-- có — mở rộng bề mặt tấn công mà chẳng đổi lấy được gì. Vẫn khoá
-- `search_path` để không ai lừa được hàm bằng một schema dựng sẵn.
--
-- Vẫn tự kiểm "dòng này là của tôi" bên trong: chính sách RLS trả về LẶNG LẼ
-- không dòng nào khi bị chặn, còn người dùng cần một câu nói rõ vì sao.

-- ─── 7a. NHẬN VIỆC ──────────────────────────────────────────────────────────
--
-- ⚠️ HÀM NÀY VẪN TỪ CHỐI DÒNG TỰ VIẾT — GIỮ NGUYÊN, ĐÃ CÂN NHẮC 27/08.
-- Sau khi kho nhận thêm cam kết tự viết, câu hỏi mở ra: có nên cho
-- `nhan_viec_cam_ket` nhận luôn cả dòng tự viết trong kho, thay vì đẻ thêm một
-- hàm nữa? Chốt là KHÔNG, và lý do là hai hàm làm HAI VIỆC khác nhau chứ không
-- phải một việc viết hai lần:
--
--   · `nhan_viec_cam_ket` là một CHỮ KÝ. Nó đóng dấu `nhan_viec_luc` — một lời
--     khai trong sổ giao nhận giữa hai người, và trigger `kiem_giao_cam_ket`
--     canh cho nó KHÔNG BAO GIỜ gỡ lại được. Việc chọn luống chỉ đi kèm.
--   · `vao_luong_cam_ket` (7d) là một CÚ XÊ DỊCH. Nó chỉ đổi chỗ ngồi, đi lại
--     được cả hai chiều qua `ve_kho_cam_ket` (7e), và không chạm một cột nào
--     của sổ giao nhận.
--
-- Gộp lại thì một trong hai hỏng: hoặc kéo một dòng tự viết vào luống lại lén
-- đóng dấu một lời nhận việc chưa từng có ai giao (đúng ô 3 của bảng chân trị
-- mục 3b, thứ trigger đang chặn), hoặc nút "Nhận việc" hiện lên trên một cam
-- kết không có lời giao nào để nhận.
--
-- Hai tập chúng đụng tới RỜI HẲN NHAU, nên không có luật nào bị viết hai chỗ:
--   7a  chỉ ăn dòng  `giao_luc is not null and nhan_viec_luc is null`
--   7d  chỉ ăn dòng  kho CÒN LẠI — tức mọi dòng luống rỗng KHÔNG thoả câu trên
-- Câu lỗi dưới đây chỉ thẳng sang cửa kia để không ai phải đoán.
create or replace function nhan_viec_cam_ket(p_ma text, p_luong int)
returns void language plpgsql set search_path = public
as $$
declare
  v_toi     uuid := nguoi_id_dang_nhap();
  v_chu     uuid;
  v_giao    timestamptz;   -- giao_luc, KHÔNG phải giao_boi: xem mục 1 đoạn ①
  v_nhan    timestamptz;
  v_tu_choi timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, giao_luc, nhan_viec_luc, tu_choi_luc
    into v_chu, v_giao, v_nhan, v_tu_choi
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if v_chu is distinct from v_toi then
    raise exception 'Cam kết này giao cho người khác — chỉ người được giao mới nhận việc được';
  end if;
  if v_giao is null then
    raise exception 'Cam kết này bạn tự viết chứ không ai giao, không có lời giao nào để nhận. Muốn bắt tay vào làm thì kéo nó vào một luống bằng vao_luong_cam_ket().';
  end if;
  if v_nhan is not null then
    raise exception 'Cam kết này bạn đã nhận rồi';
  end if;
  if v_tu_choi is not null then
    raise exception 'Cam kết này bạn đã từ chối rồi. Muốn làm thì nhờ người giao giao lại một cam kết mới.';
  end if;
  if p_luong is null then
    raise exception 'Nhận việc thì phải chọn chỗ cho cam kết ngồi trong vườn của bạn';
  end if;
  -- Ràng buộc luong_trong_khoang_1_5 cũng chặn ca này, nhưng nó ném về câu lỗi
  -- vi phạm ràng buộc của Postgres — thứ hiện thẳng lên toast của app.
  if p_luong < 1 or p_luong > 5 then
    raise exception 'Vườn chỉ có năm chỗ, đánh số 1 đến 5. Không có chỗ thứ %.', p_luong;
  end if;

  -- Chỗ đã có cây thì nói ra bằng tiếng Việt. Không chặn ở đây thì chỉ mục
  -- mot_hat_song_moi_luong vẫn chặn, nhưng nó ném về một câu lỗi trùng khoá
  -- của Postgres — thứ hiện thẳng lên toast của app mà không ai đọc hiểu.
  if exists (select 1 from tieu_diem
              where nguoi_id = v_toi and luong = p_luong
                and not xong and ma <> p_ma) then
    raise exception 'Chỗ thứ % trong vườn bạn đang có một cam kết khác ngồi. Thu hoạch nó trước, hoặc chọn chỗ còn trống.', p_luong;
  end if;

  -- Đúng lúc `luong` chuyển từ rỗng sang một con số, trigger kiem_tran_cam_ket
  -- (đang gác sẵn `update of luong`) tự soi trần chỗ ngồi. KHÔNG viết lại trần
  -- ở đây: hai chỗ giữ cùng một luật là hai chỗ để chúng lệch nhau.
  update tieu_diem
     set nhan_viec_luc = now(), luong = p_luong::smallint
   where ma = p_ma;
end $$;

comment on function nhan_viec_cam_ket(text, int) is
  'Nút "Nhận việc": người được giao gật, và chọn chỗ cho cam kết ngồi trong vườn mình. Lúc luong chuyển từ rỗng sang một con số thì trigger kiem_tran_cam_ket tự soi trần chỗ ngồi — hàm này không nhắc lại luật ấy. Chạy bằng quyền người gọi vì nó chỉ chạm dòng của chính họ.';

grant execute on function nhan_viec_cam_ket(text, int) to authenticated;


-- ─── 7b. TỪ CHỐI ────────────────────────────────────────────────────────────
-- Dòng Ở LẠI, luống vẫn rỗng, và quay về phía người giao qua khối "Chờ bạn".
create or replace function tu_choi_cam_ket(p_ma text, p_ly_do text)
returns void language plpgsql set search_path = public
as $$
declare
  v_toi     uuid := nguoi_id_dang_nhap();
  v_chu     uuid;
  v_giao    timestamptz;   -- giao_luc, KHÔNG phải giao_boi: xem mục 1 đoạn ①
  v_nhan    timestamptz;
  v_tu_choi timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, giao_luc, nhan_viec_luc, tu_choi_luc
    into v_chu, v_giao, v_nhan, v_tu_choi
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if v_chu is distinct from v_toi then
    raise exception 'Cam kết này giao cho người khác — chỉ người được giao mới từ chối được';
  end if;
  if v_giao is null then
    raise exception 'Cam kết này bạn tự viết chứ không ai giao. Không muốn làm nữa thì xoá nó đi.';
  end if;
  if v_nhan is not null then
    raise exception 'Cam kết này bạn đã nhận rồi, không từ chối ngược lại được. Làm không nổi thì nói thẳng với người giao.';
  end if;
  if v_tu_choi is not null then
    raise exception 'Cam kết này bạn đã từ chối rồi';
  end if;
  if length(trim(coalesce(p_ly_do, ''))) = 0 then
    raise exception 'Từ chối thì phải nói lý do — người giao cần biết vì sao để giao lại cho đúng người, hoặc sửa lại đề bài.';
  end if;

  update tieu_diem
     set tu_choi_luc = now(), tu_choi_ly_do = trim(p_ly_do)
   where ma = p_ma;
end $$;

comment on function tu_choi_cam_ket(text, text) is
  'Nút "Từ chối": người được giao trả lời KHÔNG, kèm lý do bắt buộc. Dòng ở lại với luống rỗng và quay về khối "Chờ bạn" của người giao — không tự xoá, vì một lời từ chối biến mất không dấu vết là cách để việc rơi xuống đất mà không ai chịu. Chạy bằng quyền người gọi vì nó chỉ chạm dòng của chính họ.';

grant execute on function tu_choi_cam_ket(text, text) to authenticated;


-- ─── 7c. RÚT LẠI LỜI GIAO — LỐI RA DUY NHẤT CỦA MỘT DÒNG KHO ────────────────
-- Bản đầu của file này cố ý KHÔNG làm hàm này, ghi nó thành một câu hỏi ngỏ.
-- Bỏ ra thì ba luật cộng lại thành một cái bẫy không có cửa:
--   · dòng bị từ chối KHÔNG tự xoá (đúng, Tracy chốt),
--   · người NHẬN không xoá được (đúng, trigger canh),
--   · người GIAO cũng không xoá được (chính sách xoa_tieudiem chỉ cho chủ dòng
--     xoá, mà chủ dòng là người nhận).
-- Kết cục: giao nhầm năm lần là năm thẻ nằm vĩnh viễn trong khối "Chờ bạn" của
-- người giao, năm dòng chết trong bảng, và phần trăm dự án tụt năm nấc không
-- kéo lên lại được. Đúng thứ mà cả file này được dựng ra để tránh.
--
-- Tracy chốt *"KHÔNG tự xoá"* — nghĩa là APP đừng tự động xoá thay ai, không
-- phải là cấm mọi người dọn. Ở đây quả bóng đang nằm phía người giao, nên
-- chính họ là người được quyền dọn: một hành động có chủ, do đúng người, sau
-- khi đã đọc lý do bị từ chối. Đó không phải "việc rơi xuống đất không ai
-- chịu" — đó là một người nhận lại việc mình đã giao.
--
-- `security definer` vì người giao KHÔNG phải chủ dòng, nên chính sách RLS
-- không cho họ chạm. Hàm khoanh đúng một việc và tự soi lấy quyền — cùng lối
-- lẽ với giao_cam_ket ở mục 6.
--
-- CHỈ rút được khi CHƯA AI NHẬN. Đã nhận rồi thì việc đã thuộc về vườn người
-- ta, rút sau lưng họ là xoá một cam kết đang chạy.
create or replace function rut_lai_cam_ket(p_ma text)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi   uuid := nguoi_id_dang_nhap();
  v_giao  uuid;
  v_nhan  timestamptz;
  v_gluc  timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select giao_boi, giao_luc, nhan_viec_luc
    into v_giao, v_gluc, v_nhan
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if v_gluc is null then
    raise exception 'Cam kết này người ta tự viết chứ không ai giao — không có lời giao nào để rút.';
  end if;
  if v_giao is distinct from v_toi then
    raise exception 'Chỉ người đã giao cam kết này mới rút lại được.';
  end if;
  if v_nhan is not null then
    raise exception 'Người ta đã nhận việc này rồi — việc đang nằm trong vườn của họ, không rút sau lưng được. Muốn dừng thì nói với họ.';
  end if;

  -- Trigger kiem_giao_cam_ket mở đúng cửa này: nhánh XOÁ cho qua khi người xoá
  -- CHÍNH LÀ giao_boi và chưa ai nhận. Không cần cờ phiên nào, không cần tắt
  -- trigger — hàng rào vẫn nguyên vẹn với mọi đường đi khác.
  delete from tieu_diem where ma = p_ma;
end $$;

comment on function rut_lai_cam_ket(text) is
  'Nút "Rút lại lời giao": người GIAO gỡ một cam kết mình đã giao mà người kia chưa nhận — dù đang chờ trả lời hay đã bị từ chối. Đây là lối ra DUY NHẤT của một dòng kho, và là cái phanh của trần kho (mục 3c): không có nó thì mỗi lời giao bị trả lại là một dòng chết vĩnh viễn trong bảng và một thẻ vĩnh viễn trong khối "Chờ bạn". Đã nhận rồi thì không rút được. Chạy bằng quyền người định nghĩa vì người giao không phải chủ dòng.';

grant execute on function rut_lai_cam_ket(text) to authenticated;


-- ─── 7d. VÀO LUỐNG — kéo một cam kết từ kho ra vườn ─────────────────────────
-- ⚠️ KHÔNG CÓ HAI HÀM NÀY THÌ KHO CHỈ LÀ MỘT CÁI HỐ. Mục 3b nới cho cam kết
-- tự viết nằm kho được, nhưng nới xong mà không có cửa thì dòng vào kho rồi ở
-- đó vĩnh viễn: `nhan_viec_cam_ket` từ chối nó (không có lời giao nào để
-- nhận), `rut_lai_cam_ket` từ chối nó (không có người giao nào để rút), và
-- đường duy nhất còn lại là một câu `update` gọi thẳng API — tức luật nằm
-- ngoài app. Đây là cửa.
--
-- Bốn thứ hàm tự kiểm, và MỘT thứ hàm CỐ Ý KHÔNG kiểm:
--   ✓ dòng của chính mình      — RLS đã chặn, nhưng chặn lặng lẽ; cần câu nói
--   ✓ đang ở kho               — luống rỗng, chưa xong
--   ✓ không phải dòng chờ gật  — dòng ấy đi cửa 7a, xem ghi chú ở mục 7a
--   ✓ luống trống              — nói bằng tiếng Việt thay cho lỗi trùng khoá
--   ✗ TRẦN BA LUỐNG            — ⛔ ĐỪNG VIẾT LẠI Ở ĐÂY.
--
-- Trigger `kiem_tran_cam_ket` (12/08) gác sẵn `before insert or update of
-- luong, nguoi_id`, nên đúng lúc câu `update` dưới đây đổi `luong` từ rỗng
-- sang một con số thì nó tự soi `luong > nguoi.so_cam_ket_toi_da` và tự ném
-- câu lỗi của nó. Cộng với chỉ mục `mot_hat_song_moi_luong`, luật ba luống
-- được giữ nguyên vẹn mà hàm này không nhắc một chữ. Viết lại trần ở đây là
-- dựng chỗ thứ hai giữ cùng một luật — rồi tới ngày Tracy đổi trần của một
-- người, hai chỗ nói hai điều khác nhau. Cùng nếp `nhan_viec_cam_ket` đã theo.
create or replace function vao_luong_cam_ket(p_ma text, p_luong int)
returns void language plpgsql set search_path = public
as $$
declare
  v_toi   uuid := nguoi_id_dang_nhap();
  v_chu   uuid;
  v_luong smallint;
  v_xong  boolean;
  v_giao  timestamptz;   -- giao_luc, KHÔNG phải giao_boi: xem mục 1 đoạn ①
  v_nhan  timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, luong, xong, giao_luc, nhan_viec_luc
    into v_chu, v_luong, v_xong, v_giao, v_nhan
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if v_chu is distinct from v_toi then
    raise exception 'Cam kết này là của người khác — chỉ chủ cam kết mới xếp chỗ cho nó trong vườn mình.';
  end if;
  if v_xong then
    raise exception 'Cam kết này đã đóng rồi, không kéo ra vườn lại được. Còn việc phải làm thì gieo một cam kết mới.';
  end if;
  if v_luong is not null then
    raise exception 'Cam kết này đang ở luống thứ % trong vườn bạn rồi, không nằm kho.', v_luong;
  end if;

  -- Dòng đang chờ chính mình gật thì đi cửa "Nhận việc", không đi cửa này.
  -- Cho nó lọt qua đây là đặt chỗ ngồi cho một việc mình chưa nhận — đúng ô số
  -- 6 của bảng chân trị mục 3b, thứ ràng buộc `cho_nhan_thi_luong_phai_rong`
  -- sẽ chặn ngay sau đó bằng một câu lỗi ràng buộc mà không ai đọc hiểu. Chặn
  -- ở đây trước để câu lỗi nói đúng việc phải làm.
  if v_giao is not null and v_nhan is null then
    raise exception 'Cam kết này người khác giao cho bạn và bạn chưa trả lời — bấm Nhận việc để gật (và chọn luôn chỗ ngồi), hoặc Từ chối kèm lý do.';
  end if;

  if p_luong is null then
    raise exception 'Kéo cam kết ra vườn thì phải chọn chỗ cho nó ngồi';
  end if;
  -- Ràng buộc luong_trong_khoang_1_5 cũng chặn ca này, nhưng nó ném về câu lỗi
  -- vi phạm ràng buộc của Postgres — thứ hiện thẳng lên toast của app.
  if p_luong < 1 or p_luong > 5 then
    raise exception 'Vườn chỉ có năm chỗ, đánh số 1 đến 5. Không có chỗ thứ %.', p_luong;
  end if;

  -- Chỗ đã có cây thì nói ra bằng tiếng Việt. Chép đúng câu của
  -- `nhan_viec_cam_ket` — hai cửa cùng vào một cái vườn thì nói cùng một câu.
  if exists (select 1 from tieu_diem
              where nguoi_id = v_toi and luong = p_luong
                and not xong and ma <> p_ma) then
    raise exception 'Chỗ thứ % trong vườn bạn đang có một cam kết khác ngồi. Thu hoạch nó trước, cất nó về kho, hoặc chọn chỗ còn trống.', p_luong;
  end if;

  -- Trần ba luống do trigger kiem_tran_cam_ket soi ngay tại câu này. Xem khối
  -- chú thích trên đầu hàm — KHÔNG viết lại luật ấy ở đây.
  update tieu_diem set luong = p_luong::smallint where ma = p_ma;
end $$;

comment on function vao_luong_cam_ket(text, int) is
  'Nút "Vào luống": chủ cam kết kéo một dòng từ KHO ra một trong ba luống đang chạy. Ăn mọi dòng luống rỗng TRỪ dòng đang chờ chính mình gật — dòng ấy đi cửa nhan_viec_cam_ket, hai tập rời hẳn nhau nên không luật nào bị viết hai chỗ. Trần ba luống KHÔNG nằm trong hàm này: trigger kiem_tran_cam_ket gác sẵn update of luong và tự soi. Đi ngược lại bằng ve_kho_cam_ket. Chạy bằng quyền người gọi vì nó chỉ chạm dòng của chính họ.';

grant execute on function vao_luong_cam_ket(text, int) to authenticated;


-- ─── 7e. VỀ KHO — cất một cam kết đang chạy về chỗ chờ ──────────────────────
-- Nửa còn lại của cửa. Ba luống đầy mà có việc gấp hơn thì phải có cách nhường
-- chỗ, nếu không người ta chỉ còn hai lối: đóng bừa một cam kết chưa xong (nói
-- dối vào sổ), hoặc xoá nó đi (mất luôn thứ đã nghĩ ra). Cất về kho giữ được
-- cả hai — dòng còn đó, chỗ ngồi nhường lại.
--
-- ⚠️ ĐÂY LÀ Ô SỐ 7 CỦA BẢNG CHÂN TRỊ MỤC 3b — ô mà bản cũ CHẶN với đúng cái
-- tên "đã nhận mà lách trần". Nó thôi là đường lách kể từ khi mục 3d có hàng
-- rào ĐẾM: về kho không còn là biến mất khỏi mọi bộ đếm nữa, nó chỉ là đổi từ
-- bộ đếm này sang bộ đếm kia, và bộ đếm kia cũng có trần. Nếu ai đó gỡ mục 3d
-- đi thì hàm này lập tức thành cửa hậu vô hạn — hai mục ấy sống chết cùng nhau.
--
-- KHÔNG đụng một cột nào của sổ giao nhận. Một cam kết được giao rồi đã nhận
-- mà cất về kho thì `giao_luc` và `nhan_viec_luc` Ở NGUYÊN: người ta ĐÃ gật,
-- và việc đó không rút lại được (trigger `kiem_giao_cam_ket` canh). Về kho là
-- xê dịch chỗ ngồi, không phải rút lại lời hứa.
create or replace function ve_kho_cam_ket(p_ma text)
returns void language plpgsql set search_path = public
as $$
declare
  v_toi   uuid := nguoi_id_dang_nhap();
  v_chu   uuid;
  v_luong smallint;
  v_xong  boolean;
  v_giao  timestamptz;
  v_nhan  timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, luong, xong, giao_luc, nhan_viec_luc
    into v_chu, v_luong, v_xong, v_giao, v_nhan
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if v_chu is distinct from v_toi then
    raise exception 'Cam kết này là của người khác — chỉ chủ cam kết mới cất nó về kho được.';
  end if;
  if v_xong then
    raise exception 'Cam kết này đã đóng rồi. Việc đã xong thì ở lại trong sổ, không cất về kho được.';
  end if;

  -- Dòng đang chờ gật vốn đã nằm kho — nói rõ nó đang chờ CÁI GÌ, đừng chỉ nói
  -- "đã ở kho rồi". Hai ca cùng một chỗ nhưng việc phải làm khác hẳn nhau.
  if v_luong is null then
    if v_giao is not null and v_nhan is null then
      raise exception 'Cam kết này đang chờ bạn trả lời nên nó vốn đã nằm kho — bấm Nhận việc hoặc Từ chối kèm lý do.';
    end if;
    raise exception 'Cam kết này đang nằm kho rồi, chưa chiếm chỗ nào trong vườn bạn.';
  end if;

  -- Trigger tran_ca_kho_cam_ket (mục 3d) soi trần kho ngay tại câu này — không
  -- viết lại ở đây, cùng lý do đã ghi ở 7d với trần ba luống.
  update tieu_diem set luong = null where ma = p_ma;
end $$;

comment on function ve_kho_cam_ket(text) is
  'Nút "Cất về kho": chủ cam kết trả một dòng đang chiếm luống về kho để nhường chỗ cho việc khác — dòng còn nguyên, chỉ mất chỗ ngồi. Đây là ô số 7 của bảng chân trị mục 3b, ô mà bản cũ chặn vì nó là đường lách trần; nó thôi là đường lách nhờ hàng rào đếm mục 3d, nên gỡ mục 3d đi là hàm này thành cửa hậu vô hạn. KHÔNG chạm sổ giao nhận: đã gật thì vẫn là đã gật, cất về kho chỉ là xê dịch chỗ ngồi. Chạy bằng quyền người gọi vì nó chỉ chạm dòng của chính họ.';

grant execute on function ve_kho_cam_ket(text) to authenticated;




-- ════════════════════════════════════════════════════════════════════════════
-- 8. DỰNG LẠI `cho_ban` — THÊM HAI NHÁNH CỦA ĐƯỜNG GIAO VIỆC
-- ════════════════════════════════════════════════════════════════════════════
-- Hai nhánh ① và ② chép NGUYÊN VĂN từ `nang-cap-cho-ban.sql`, không viết lại
-- theo trí nhớ: `create or replace view` cần trọn câu lệnh, mà mỗi lần gõ lại
-- một mệnh đề `where` từ đầu là một lần có cơ hội gõ sai.
--
-- Sáu cột giữ y nguyên (loai · khoa · ten · ai · luc · cua_toi). Hai nhánh mới
-- ép đúng sáu kiểu ấy: `khoa` mang `o.ma` (text), `luc` mang một mốc giờ THẬT
-- chứ không phải NULL — hai nhánh cũ đều có mốc thật, nhánh mới trả rỗng thì
-- app sắp xếp theo `luc` sẽ đẩy chúng lộn xộn lên đầu hoặc cuối danh sách.
--
-- ⚠️ `drop view` cũng XOÁ LUÔN trigger `instead of` chặn ghi. Mục 8b dựng lại
-- nó — quên câu ấy là khung nhìn im lặng nhận lệnh ghi rồi nuốt mất.
drop view if exists cho_ban;
create view cho_ban as

-- ① LỜI MỜI chưa xem
select
  'loi-moi'::text                    as loai,
  v.muc_tieu_id::text                as khoa,
  m.ten                              as ten,
  coalesce(n.ten, '—')               as ai,          -- ai mời tôi
  v.moi_luc                          as luc,
  v.nguoi_id                         as cua_toi
from thanh_vien_du_an v
join muc_tieu m on m.id = v.muc_tieu_id
left join nguoi  n on n.id = v.moi_boi
where v.nguoi_id = nguoi_id_dang_nhap()
  and v.da_xem_luc is null
  -- Không tự báo cho chính mình: trigger `tu_them_chu_du_an` tự thêm PIC vào
  -- danh sách, dòng đó không phải một lời mời.
  and v.moi_boi is distinct from v.nguoi_id
  -- Dự án đã hoàn thành hoặc đã hủy thì lời mời hết nghĩa.
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ② CAM KẾT chờ TÔI ký nhận
-- Điều kiện chép ĐÚNG luật của hàm `nhan_cam_ket` (bản 11/08, phân cấp nghiệm
-- thu) — không diễn giải lại, vì hai chỗ lệch nhau thì khối này bày ra thứ bấm
-- vào lại bị đá về:
--   · chủ cam kết CÓ cấp trên  → đúng cấp trên trực tiếp ký
--   · chủ cam kết KHÔNG có cấp trên (CEO) → chính chủ tự ký
select
  'ky-nhan'::text,
  o.ma,
  o.ten,
  n.ten,                                             -- ai đang chờ tôi ký
  coalesce(o.nop_luc, o.ngay_xong::timestamptz),
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.xong
  and length(trim(coalesce(o.output_chu, ''))) > 0
  and o.da_nhan_luc is null
  and (
        (n.leader_id is not null and n.leader_id = nguoi_id_dang_nhap())
     or (n.leader_id is null     and n.id        = nguoi_id_dang_nhap())
      )

union all

-- ③ CAM KẾT ĐƯỢC GIAO cho tôi, tôi chưa trả lời
-- Đây là thứ duy nhất trong bốn loại mà người ta CHƯA THẤY Ở ĐÂU KHÁC: cam
-- kết chờ nhận nằm kho, luống rỗng, nên nó không mọc lên luống nào trong vườn.
-- Không có nhánh này thì lời giao rơi vào im lặng hoàn toàn.
-- Không lọc theo `xong` vì trigger kiem_giao_cam_ket đã chặn đóng cam kết
-- chưa nhận — thêm một mệnh đề nữa ở đây là dựng hàng rào thứ hai cho cùng
-- một luật, rồi hai cái lệch nhau lúc nào không hay.
select
  'cho-nhan'::text,
  o.ma,
  o.ten,
  coalesce(g.ten, '—'),                              -- ai giao cho tôi
  o.giao_luc,
  o.nguoi_id
from tieu_diem o
left join nguoi g on g.id = o.giao_boi
where o.nguoi_id      = nguoi_id_dang_nhap()
  -- Lọc theo `giao_luc`, KHÔNG theo `giao_boi`: người giao rời đội thì
  -- `giao_boi` về rỗng (khoá ngoại on delete set null), và lọc theo nó là
  -- lời giao lặng lẽ biến khỏi khối "Chờ bạn" trong khi việc vẫn nằm đó chờ
  -- một câu trả lời. Cột `ai` đã có `coalesce(…, '—')` để lo phần tên.
  and o.giao_luc     is not null
  and o.nhan_viec_luc is null
  and o.tu_choi_luc  is null

union all

-- ④ CAM KẾT TÔI GIAO ĐI, BỊ TỪ CHỐI
-- Vòng bốn nhịp (yêu cầu · hứa · tuyên bố xong · nghiệm thu) có một nhánh rẽ
-- ít ai vẽ ra: lời hứa bị TỪ CHỐI. Không có nhánh này thì người giao ngồi đợi
-- một việc đã bị trả lại từ lâu — đúng kiểu việc rơi xuống đất không ai chịu.
-- Cột `ai` mang tên NGƯỜI TỪ CHỐI (chính là chủ dòng), `luc` mang giờ từ chối.
-- Dòng này ở lại cho tới khi người giao gọi `rut_lai_cam_ket` (mục 7c) — đó là
-- lối ra, và nó cố ý đòi một hành động có chủ chứ không tự tắt sau mấy ngày.
-- Vẫn CHƯA CÓ nấc "đã biết rồi mà giữ lại để giao lại sau": muốn giữ dòng mà
-- thôi nhắc thì đợt sau cần thêm cột `tu_choi_da_xem_luc`.
select
  'bi-tu-choi'::text,
  o.ma,
  -- ⚠️ GHÉP LÝ DO VÀO ĐÂY LÀ CỐ Ý. `cho_ban` khoá cứng sáu cột, và nhánh này
  -- đã dùng hết sáu ô cho tên cam kết, tên người từ chối và giờ từ chối — không
  -- còn ô nào cho `tu_choi_ly_do`. Mà `tien_do_o` thì file này không dựng lại,
  -- và đường app đọc thẳng bảng cũng kê danh sách cột cố định. Nghĩa là nếu
  -- không ghép vào đây thì cái lý do vừa bị ÉP KHAI không tới được mắt ai qua
  -- bất cứ đường nào app đang đọc — luật ép khai chỉ còn làm phiền người từ
  -- chối mà không đem lại thứ nó hứa. Đợt sau thêm cột thứ bảy `ghi_chu` thì
  -- tách ra lại; hôm nay ghép là cách rẻ nhất để lời khai có người đọc.
  o.ten || ' — lý do: ' || coalesce(nullif(trim(o.tu_choi_ly_do), ''), '(không khai)'),
  coalesce(n.ten, '—'),                              -- ai từ chối
  o.tu_choi_luc,
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.giao_boi     = nguoi_id_dang_nhap()
  and o.tu_choi_luc is not null
  and o.nhan_viec_luc    is null;

alter view cho_ban set (security_invoker = on);

comment on view cho_ban is
  'Thứ đang chờ người đang đăng nhập ra tay. Bốn loại: loi-moi (được mời vào dự án, chưa mở xem) · ky-nhan (cam kết đã nộp sản phẩm, đang chờ chính mình ký nhận) · cho-nhan (được giao một cam kết, chưa gật cũng chưa từ chối) · bi-tu-choi (cam kết chính mình giao đi, bị trả lại). Khung nhìn tự lọc theo người đăng nhập. Thêm loại mới thì thêm một nhánh union all, không dựng bảng.';

grant select on cho_ban to authenticated;


-- ─── 8b. Dựng lại cổng chặn ghi (drop view ở trên đã cuốn nó đi) ────────────
create or replace function chan_ghi_cho_ban() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "cho_ban" là ô MÁY CHỦ TÍNH, không ghi vào được. Xử ở chỗ thật: mở hồ sơ dự án, bấm nút Đã nhận trên cam kết, hoặc bấm Nhận việc / Từ chối trên lời giao.';
end $$;

drop trigger if exists trg_chan_ghi_cho_ban on cho_ban;
create trigger trg_chan_ghi_cho_ban
  instead of insert or update or delete on cho_ban
  for each row execute function chan_ghi_cho_ban();



-- ════════════════════════════════════════════════════════════════════════════
-- 9. DỰNG LẠI `danh_muc_du_an` — DÒNG KHO KHÔNG ĐƯỢC TÍNH LÀ VIỆC CỦA DỰ ÁN
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ ĐÂY LÀ KHUNG NHÌN DUY NHẤT CỦA TẦNG DỰ ÁN KHÔNG TỰ CỨU ĐƯỢC.
--
-- Hai khung nhìn `dem_task_theo_o` và `dem_cam_ket_da_dong` lọc cứng
-- `luong between 1 and 5`, nên dòng kho tự rơi khỏi chúng (xem khối "MỘT HÀNH
-- VI NGẦM" ở đầu file). `danh_muc_du_an` thì KHÔNG có mệnh đề `luong` nào:
-- bốn ô đếm và CẢ HAI công thức phần trăm đều lấy
-- `count(*) from tieu_diem where muc_tieu_id = m.id` làm mẫu số, không hỏi gì
-- về việc cam kết ấy đã có ai nhận chưa.
--
-- Hậu quả nếu để nguyên, bằng một ví dụ:
--   Dự án đang 4/5 cam kết đã nghiệm thu = 80%.
--   PIC giao thêm MỘT cam kết cho người khác, người ta chưa bấm gì cả.
--   → mẫu số thành 6, phần trăm tụt xuống 67%.
--   Người ta bấm Từ chối → dòng ở lại → phần trăm KẸT ở 67%.
--   `so_nguoi_ganh` cũng đếm người vừa từ chối là "đang gánh".
-- Không lỗi nào báo. Đúng kiểu sai trong im lặng mà cả kho này đang chống.
--
-- ─── VÌ SAO LỌC `o.luong is not null` CHỨ KHÔNG PHẢI `o.nhan_viec_luc is not
--     null` ─────────────────────────────────────────────────────────────────
-- Đây là chỗ dễ sửa nhầm nhất cả file, nên nói thẳng ra.
-- `nhan_viec_luc` CHỈ có giá trị ở đường ③ (được giao rồi bấm nhận). Cam kết
-- TỰ VIẾT — đường ① và ②, tức gần như toàn bộ dữ liệu đang có — có
-- `nhan_viec_luc` RỖNG vĩnh viễn. Lọc theo nó là quét sạch mọi con số của mọi
-- dự án về 0 ngay lần chạy đầu tiên.
-- `luong is not null` mới là câu hỏi đúng: *"cam kết này đã có chỗ ngồi trong
-- vườn của một người chưa"*. Từ 27/08, luống rỗng ĐỊNH NGHĨA chữ "nằm kho"
-- (xem chú thích cột `luong` ở mục 3a) — nên câu lọc này đúng cho cả HAI loại
-- dòng kho: lời giao chưa ai nhận, và cam kết tự viết chưa kéo vào luống. Và
-- nó là đúng cùng một câu hỏi mà hai khung nhìn đếm kia đang hỏi — ba chỗ cùng
-- một luật, không phải ba luật giống giống nhau.
--
-- ⚠️ HỆ QUẢ CỦA ĐỢT NỚI KHO, NÓI RA CHO RÕ: một cam kết TỰ VIẾT nằm kho cũng
-- rơi khỏi mọi con số của dự án, y như một lời giao chưa ai nhận. Đó là đúng ý
-- — việc chưa vào luống thì chưa chạy, và để nó vào mẫu số là phần trăm dự án
-- tụt xuống mỗi lần ai đó ghi ra một ý định. Nhưng nó cũng nghĩa là kéo một
-- cam kết từ kho vào luống sẽ LÀM TỤT phần trăm dự án ngay lúc ấy (mẫu số
-- tăng, tử số chưa). Không có gì hỏng; chỉ là con số nhúc nhích vào một lúc
-- người ta không chờ.
--
-- `drop` rồi `create` chứ không `create or replace`: mệnh đề `where` của truy
-- vấn con đổi thì replace vẫn chạy, nhưng nếp của kho này là dựng lại trọn vẹn
-- để bản trên đĩa và bản đang chạy khớp từng chữ.
-- ⚠️ `drop view` cuốn theo trigger chặn ghi và mọi `grant` — mục 9b dựng lại.
--
-- Thân dưới đây chép ĐÚNG bản sống `nang-cap-mang-du-an.sql:714–809` (25/08),
-- thêm đúng một mệnh đề `and o.luong is not null` vào MƯỜI HAI truy vấn con
-- đọc `tieu_diem`. Không đổi một cột nào, không đổi thứ tự cột nào.
drop view if exists danh_muc_du_an;
create view danh_muc_du_an as
select
  m.id,
  m.ten,
  m.ket_qua,
  m.nguoi_id,
  m.han,
  m.loai,
  m.trang_thai,
  m.mo_ta,
  m.link_tai_lieu,
  m.pham_vi,
  m.phong_ban,
  m.xong,
  m.ngay_xong,
  m.so_ngay_du_kien,
  m.so_ngay_thuc_te,
  m.nhin_lai_duoc,
  m.nhin_lai_vuong,
  m.nhin_lai_lan_sau,
  m.tao_luc,

  -- ─ cam kết trỏ về ─
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null)                       as so_cam_ket,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.xong)            as cam_ket_tick_xong,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null
     and o.da_nhan_luc is not null)                                                   as cam_ket_da_nhan,
  (select count(distinct o.nguoi_id) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null)     as so_nguoi_ganh,
  /* 🆕 25/08 — DANH SÁCH THÀNH VIÊN, không chỉ con số. Tracy: *"3 người đang
     gánh → thành viên (3): Tracy, Andy, Hafi"*. Một con số bắt người đọc đi tìm
     xem là ai; cái tên trả lời luôn.
     Đọc từ bảng `thanh_vien_du_an` — tức từ LỜI MỜI, không đếm ngược từ cam kết
     đã gieo. Đây là chỗ khác nhau thật: đếm ngược thì người vừa được mời mà
     chưa kịp hứa gì lại không có tên, mà họ mới chính là người cần thấy mình
     đã ở trong dự án. Trả `uuid[]` chứ không nối sẵn tên ở máy chủ — app đã cầm
     bảng `nguoi` trong tay, nối tên ở đây là hai chỗ cùng biết một sự thật. */
  (select array_agg(v.nguoi_id order by (v.nguoi_id = m.nguoi_id) desc, v.moi_luc)
     from thanh_vien_du_an v where v.muc_tieu_id = m.id)                              as nguoi_ganh,

  -- ─ việc của dự án ─
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.con_tren_ban)                                    as so_viec,
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.tinh_la_xong)                                    as viec_xong,
  (select count(*) from task t
    where t.muc_tieu_id = m.id and t.tieu_diem_ma is null)                            as viec_cho,

  /* 🆕 25/08 — TỔNG GIỜ DEEP WORK đã đổ vào dự án. Tracy: *"đếm tổng số giờ
     nữa"*. Mượn thẳng khung nhìn `vuon_cay` chứ không tự cộng lại từ bảng
     `phien_deepwork`: `vuon_cay` là chỗ DUY NHẤT trong app định nghĩa thế nào
     là "giờ làm việc sâu THẬT" — chỉ đếm phiên `ket_qua = 'song'` và chặn trần
     30 phút mỗi phiên. Cộng lại một lần nữa ở đây là đẻ ra bản sự thật thứ hai,
     rồi tới ngày hai con số lệch nhau mà không ai biết cái nào đúng. */
  (select coalesce(sum(c.phut), 0)::int from vuon_cay c
     join task t on t.id = c.task_id
    where t.muc_tieu_id = m.id)                                                       as tong_phut,

  -- ─ ngày bắt đầu SUY RA, không có cột nào phải nuôi ─
  least(
    (select min(k.ngay)      from moc_du_an  k where k.muc_tieu_id = m.id),
    (select min(o.ngay_gieo) from tieu_diem  o where o.muc_tieu_id = m.id and o.luong is not null)
  )                                                                                   as ngay_bat_dau,

  -- ─ mốc ─
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id)                       as so_moc,
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id and k.da_dat)          as moc_da_dat,
  (select count(*) from moc_du_an k
    where k.muc_tieu_id = m.id and not k.da_dat and k.ngay < hom_nay())               as moc_qua_ngay,
  (select k.ten  from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ten,
  (select k.ngay from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ngay,
  (select k.ngay - hom_nay() from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_con_may_ngay,

  -- ─ cờ nhịp tuần: tuần này đã có cam kết nào gieo trỏ về chưa ─
  exists (select 1 from tieu_diem o
           where o.muc_tieu_id = m.id and o.luong is not null
             and o.ngay_gieo >= thu_hai_cua(hom_nay()))                               as co_nhip_tuan,

  -- ─ hai cách đếm phần trăm, bày cả hai để Tracy so (d3) ─
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.da_nhan_luc is not null)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null))
  end                                                                                 as phan_tram,
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.xong)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null))
  end                                                                                 as phan_tram_tu_tick

from muc_tieu m;
alter view danh_muc_du_an set (security_invoker = on);

comment on view danh_muc_du_an is
  'Một dự án một dòng. MỌI con số ở đây do máy chủ đếm — không ô nào cho người gõ. phan_tram đếm theo LÚC KÝ NHẬN (mặc định d3); phan_tram_tu_tick đếm theo lúc người làm tự tick, bày cạnh để Tracy so rồi chốt. co_nhip_tuan = tuần này đã có cam kết gieo trỏ về chưa. Từ 27/08 mọi phép đếm cam kết đều bỏ qua dòng đang nằm KHO — tức luong rỗng, gồm cả lời giao chưa ai nhận LẪN cam kết tự viết chưa kéo vào luống: việc chưa vào luống thì chưa chạy, và để nó vào mẫu số là phần trăm tụt xuống mỗi lần PIC giao thêm một việc hoặc ai đó ghi ra một ý định.';

-- 9b. Dựng lại cổng chặn ghi và quyền đọc — `drop view` ở trên đã cuốn cả hai
-- đi. Hàm `chan_ghi_khung_nhin` là của nang-cap-mang-du-an.sql, vẫn còn nguyên
-- trên máy chủ; chỉ cái trigger cắm vào khung nhìn là mất theo khung nhìn cũ.
drop trigger if exists trg_chan_ghi_danh_muc_du_an on danh_muc_du_an;
create trigger trg_chan_ghi_danh_muc_du_an
  instead of insert or update or delete on danh_muc_du_an
  for each row execute function chan_ghi_khung_nhin();

grant select on danh_muc_du_an to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 10. DỰNG LẠI `tien_do_o` — NĂM CỘT SỔ GIAO NHẬN PHẢI TỚI ĐƯỢC MẮT NGƯỜI DÙNG
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ MỤC NÀY LẬT LẠI MỘT QUYẾT ĐỊNH CỦA CHÍNH FILE NÀY. Khối "BA THỨ CỐ Ý
-- KHÔNG LÀM" ở đầu file khai hoãn việc dựng lại khung nhìn sang đợt sau, và
-- nói thẳng hệ quả: *"app đọc tien_do_o bằng select('*'), nên năm cột mới của
-- file này CHƯA tới được mắt người dùng qua đường đó"*. Lý do hoãn đứng được
-- chừng nào giao diện chưa đi qua đường ấy.
--
-- Ngày 27/08 giao diện đi qua đúng đường ấy. Khối KHO CAM KẾT trên màn "Của
-- tôi" (`veKhoCamKet`, public/index.html) đọc `TIEU_DIEM` — mảng nạp từ
-- `tien_do_o` bằng `select('*')` — rồi phân biệt hai loại dòng kho bằng
-- `o.giao_luc`, `o.giao_boi`, `o.tu_choi_luc`, `o.tu_choi_ly_do`. Khung nhìn
-- không mang bốn cột ấy thì mọi phép so đều đọc `undefined`, và hỏng theo một
-- lối không kêu một tiếng nào:
--   · MỌI dòng kho gắn nhãn "Tự viết", kể cả lời người khác vừa giao;
--   · cặp nút "Nhận việc này" / "Từ chối" không bao giờ vẽ ra;
--   · bấm "Đưa vào vườn" trên một lời giao thì `vao_luong_cam_ket` chặn lại
--     bằng câu "bấm Nhận việc để gật" — mà nút ấy không tồn tại trên màn.
-- Tức lời giao bị NHỐT trong kho, không lối ra, không dòng lỗi nào trong
-- console. Đó là lý do mục này không hoãn thêm được nữa.
--
-- ─── BẢY CỘT THÊM VÀO, KHÔNG PHẢI NĂM ───────────────────────────────────────
-- Năm cột sổ giao nhận của file này, cộng `moc_id` và `ngay_bat_dau` (mọc
-- 26/08, chưa bản khung nhìn nào chở). Gom một lượt vì `drop`/`create` một
-- khung nhìn 29 cột là cái giá đắt nhất của việc này, và trả hai lần cho cùng
-- một cái giá là phí — danh sách "còn lại cho đợt sau" ở cuối file vốn đã xếp
-- ba thứ ấy đứng chung một dòng.
--
-- ─── BA ĐIỀU PHẢI BIẾT TRƯỚC KHI ĐỤNG VÀO ───────────────────────────────────
--   ① THÂN CHÉP TỪ `nang-cap-doi-ten-trang-thai-task.sql:231–268` (27/08 11:30)
--      — bản SỐNG, bản duy nhất mang chữ 'Chua_lam' trong ô `so_kho`. Tìm bằng
--      máy, đừng bằng trí nhớ:
--          grep -l "create view tien_do_o" *.sql | xargs ls -t | head -1
--      ⚠️ CHẠY LẠI file `nang-cap-doi-ten-trang-thai-task.sql` SAU file này là
--      dựng lại bản 29 cột và MẤT TRẮNG bảy cột dưới đây — khối Kho cam kết
--      lại mù, im lặng, y như trước. Chạy lại file kia thì chạy lại file này
--      ngay sau đó.
--   ② `drop` rồi `create`, không `create or replace`: replace chỉ cho THÊM cột
--      vào CUỐI, đụng vào giữa là Postgres ném 42P16. Bảy cột dưới đây đứng ở
--      cuối, nhưng `drop` vẫn rẻ hơn một cái bẫy đặt sẵn cho lần sửa sau.
--   ③ KHÔNG khung nhìn nào phụ thuộc `tien_do_o` (đã soát cả kho .sql), nên
--      `drop` không cần `cascade`. Nó xoá luôn mọi `grant` — câu `grant` cuối
--      mục là bắt buộc, không phải cho đẹp.
--
-- ─── MỘT THỨ CỐ Ý KHÔNG LÀM Ở ĐÂY ───────────────────────────────────────────
-- KHÔNG thêm mệnh đề lọc `luong` vào `so_task` / `so_xong` / `so_kho`. Khung
-- nhìn này là nơi DUY NHẤT app đọc được dòng đang nằm kho (`luong` rỗng) — chặn
-- ở đây là chặn luôn cả khối Kho cam kết vừa dựng. Chuyện "bốn ô đo của màn Của
-- tôi cộng cả phần của cam kết nằm kho" là chuyện của GIAO DIỆN và đã vá ở đó,
-- bằng cách cho bốn ô ấy cộng trên danh sách cam kết đã vào luống.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
  o.bo_the,
  o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
  o.han_goc, o.so_lan_doi_han, o.ngay_troi,

  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null)                                    as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null
       and t.trang_thai = 'Done')                                 as so_xong,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Chua_lam','Doing','Chua_xong'))
                                                                  as so_kho,

  o.muc_tieu_id,

  -- 🆕 27/08 — BẢY CỘT THÊM VÀO, ĐẶT Ở CUỐI, THỨ TỰ GIỮ NGUYÊN Ở `group by`.
  -- Hai cột đầu là mắt xích milestone (mọc 26/08); năm cột sau là SỔ GIAO NHẬN
  -- của mục 1, thứ khối Kho cam kết đọc để biết một dòng là lời người khác giao
  -- hay là lời mình tự viết.
  o.moc_id, o.ngay_bat_dau,
  o.giao_boi, o.giao_luc, o.nhan_viec_luc, o.tu_choi_luc, o.tu_choi_ly_do

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
         o.bo_the,
         o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
         o.han_goc, o.so_lan_doi_han, o.ngay_troi,
         o.muc_tieu_id,
         o.moc_id, o.ngay_bat_dau,
         o.giao_boi, o.giao_luc, o.nhan_viec_luc, o.tu_choi_luc, o.tu_choi_ly_do;

alter view tien_do_o set (security_invoker = on);

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm task ĐÃ HẸN NGÀY — việc còn trong kho là việc chưa nhận làm nên không vào mẫu số Done % (Tracy chốt 17/08); so_kho đếm riêng phần kho task, không đếm Blocked; output_* và da_nhan_* là phần thu hoạch khi đóng cam kết; han_goc, so_lan_doi_han, ngay_troi là cờ dời hạn; bo_the là bộ thẻ ghi chú; muc_tieu_id là dự án cam kết này phục vụ (25/08); moc_id và ngay_bat_dau là mắt xích milestone (26/08); giao_boi, giao_luc, nhan_viec_luc, tu_choi_luc, tu_choi_ly_do là SỔ GIAO NHẬN (27/08) — khối Kho cam kết đọc chúng để phân biệt lời người khác giao với lời mình tự viết. KHÔNG lọc luong: dòng luống rỗng là dòng đang nằm kho, và đây là đường duy nhất app nhìn thấy nó.';

grant select on tien_do_o to authenticated;


commit;


-- ════════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — mọi dòng phải ✔. Đỏ chỗ nào sửa chỗ đó, đừng chạy tiếp.
-- Đứng NGOÀI transaction: nó soi kết quả đã chốt, không soi ý định.
-- ════════════════════════════════════════════════════════════════════════════
with kiem(stt, muc, dat) as (
  values

  -- ─── Cột ────────────────────────────────────────────────────────────────
  (1, 'Đủ NĂM cột sổ giao nhận đã mọc trên tieu_diem',
   (select count(*) from information_schema.columns
     where table_name = 'tieu_diem'
       and column_name in ('giao_boi','giao_luc','nhan_viec_luc','tu_choi_luc','tu_choi_ly_do')) = 5),

  -- Đọc thẳng pg_attribute chứ KHÔNG dùng ordinal_position của
  -- information_schema: bảng tieu_diem đã từng gỡ cột (doc_ghi_chu, doc_da_gop
  -- gỡ ngày 15/08), mà ordinal_position đếm lại từ đầu theo cột còn thấy được
  -- trong khi col_description() cần attnum thật. Hai con số ấy đã lệch nhau
  -- kể từ lần gỡ đó — dùng nhầm là soi chú thích của một cột khác.
  (2, 'Cả năm cột đều có chú thích (không cột nào câm)',
   (select count(*) from pg_attribute a
     where a.attrelid = 'tieu_diem'::regclass
       and not a.attisdropped
       and a.attname in ('giao_boi','giao_luc','nhan_viec_luc','tu_choi_luc','tu_choi_ly_do')
       and col_description(a.attrelid, a.attnum) is not null) = 5),

  -- ⚠️ DÒNG NÀY CHỈ SOI CẤU TRÚC, KHÔNG SOI HÀNH VI. Nó xanh kể cả khi việc
  -- xoá một người vẫn đổ, vì `confdeltype` chỉ nói khoá ngoại ĐỊNH LÀM GÌ chứ
  -- không nói nó CÓ LÀM ĐƯỢC KHÔNG. Phép thử thật nằm ở khối `do $$` chạy sau
  -- bảng này — đọc cả hai, đừng chỉ đọc dòng ✔ ở đây.
  (3, 'Khoá ngoại giao_boi là ON DELETE SET NULL (người giao rời đội, cam kết ở lại)',
   exists (select 1 from pg_constraint c
            where c.conrelid = 'tieu_diem'::regclass
              and c.contype = 'f' and c.confdeltype = 'n'
              and c.conkey::int[] = array[(select attnum::int from pg_attribute
                                     where attrelid = 'tieu_diem'::regclass
                                       and attname = 'giao_boi')])),

  -- ─── Đổi hàng rào ───────────────────────────────────────────────────────
  (4, 'luong ĐÃ bỏ NOT NULL (cam kết ở kho không chiếm luống)',
   (select not attnotnull from pg_attribute
     where attrelid = 'tieu_diem'::regclass and attname = 'luong')),

  (5, 'Ràng buộc THAY THẾ đang sống: cho_nhan_thi_luong_phai_rong',
   exists (select 1 from pg_constraint
            where conrelid = 'tieu_diem'::regclass
              and conname = 'cho_nhan_thi_luong_phai_rong')),

  (6, 'Ràng buộc khong_tu_giao_cho_minh đang sống',
   exists (select 1 from pg_constraint
            where conrelid = 'tieu_diem'::regclass
              and conname = 'khong_tu_giao_cho_minh')),

  (7, 'Ràng buộc tu_choi_phai_khai_ly_do đang sống (lý do nằm ở DỮ LIỆU, không chỉ ở đường đi)',
   exists (select 1 from pg_constraint
            where conrelid = 'tieu_diem'::regclass
              and conname = 'tu_choi_phai_khai_ly_do')),

  (8, 'Ràng buộc luống NEO VÀO giao_luc, không neo vào giao_boi (xoá được người đã giao)',
   (select pg_get_constraintdef(oid) like '%giao_luc%'
       and pg_get_constraintdef(oid) not like '%giao_boi%'
      from pg_constraint
     where conrelid = 'tieu_diem'::regclass
       and conname = 'cho_nhan_thi_luong_phai_rong')),

  (9, 'Trần LỜI GIAO có con số RIÊNG: cột nguoi.so_loi_giao_toi_da đã mọc',
   exists (select 1 from information_schema.columns
            where table_name = 'nguoi' and column_name = 'so_loi_giao_toi_da')),

  (10, 'Ba hàng rào CŨ vẫn nguyên vẹn (file này không tháo cái nào)',
   exists (select 1 from pg_constraint where conrelid = 'tieu_diem'::regclass
             and conname = 'luong_trong_khoang_1_5')
   and (select indexdef like '%luong IS NOT NULL%' from pg_indexes
         where indexname = 'mot_hat_song_moi_luong')
   and exists (select 1 from pg_trigger where tgrelid = 'tieu_diem'::regclass
                 and not tgisinternal and tgname = 'trg_kiem_tran_cam_ket')),

  -- ─── Trigger ────────────────────────────────────────────────────────────
  (11, 'Trigger trg_kiem_giao_cam_ket đang cắm (sổ giao nhận không tẩy xoá được)',
   exists (select 1 from pg_trigger where tgrelid = 'tieu_diem'::regclass
             and not tgisinternal and tgname = 'trg_kiem_giao_cam_ket')),

  (12, 'Trigger trg_kiem_xoa_giao_cam_ket đang cắm (không xoá lặng dòng ở kho)',
   exists (select 1 from pg_trigger where tgrelid = 'tieu_diem'::regclass
             and not tgisinternal and tgname = 'trg_kiem_xoa_giao_cam_ket')),

  (13, 'Trigger trg_tran_kho_cam_ket đang cắm (không dồn việc vào kho một người)',
   exists (select 1 from pg_trigger where tgrelid = 'tieu_diem'::regclass
             and not tgisinternal and tgname = 'trg_tran_kho_cam_ket')),

  -- ─── Chính sách ─────────────────────────────────────────────────────────
  (14, 'Chính sách them_tieudiem ĐÃ SIẾT — đường gieo thường không tạo dòng kho',
   (select with_check like '%giao_boi%' and with_check like '%nguoi_id_dang_nhap%'
      from pg_policies
     where tablename = 'tieu_diem' and policyname = 'them_tieudiem')),

  (15, 'Ba chính sách kia của tieu_diem còn nguyên (doc · sua · xoa)',
   (select count(*) from pg_policies
     where tablename = 'tieu_diem'
       and policyname in ('doc_tieudiem','sua_tieudiem','xoa_tieudiem')) = 3),

  -- ─── Hàm ────────────────────────────────────────────────────────────────
  -- ⚠️ BỐN DÒNG DƯỚI ĐÂY PHẢI LỌC SCHEMA. Không có vế `nspname = 'public'` thì
  -- ngày nào có thêm một hàm trùng tên ở schema khác — hoặc một chồng chữ ký
  -- thứ hai của cùng một hàm, rất dễ xảy ra với `giao_cam_ket` vì nó có bảy
  -- tham số, thêm bớt một cái là sinh chồng mới chứ không thay — thì truy vấn
  -- con trả về NHIỀU DÒNG và CẢ BẢNG tự kiểm dừng lại với lỗi 21000, thay vì
  -- in một dấu ✘ ở đúng dòng sai. Nếp này chép từ nang-cap-phan-cap-nghiem-thu
  -- .sql mục 5.
  -- ⚠️ ĐÃ SỬA 28/08 — BẢN CŨ ĐỎ OAN, ĐỪNG TRẢ NÓ VỀ.
  -- Bản đầu so `pg_get_function_identity_arguments(p.oid)` với chuỗi chỉ có
  -- KIỂU: 'bigint, uuid, text, text, date, bigint, date'. Nhưng hàm ấy in ra
  -- cả TÊN tham số, nên chuỗi thật trên máy chủ là:
  --   'p_muc_tieu_id bigint, p_nguoi_nhan uuid, p_ten text, p_tieu_chi_xong
  --    text, p_han date, p_moc_id bigint, p_ngay_bat_dau date'
  -- Không khớp thì mệnh đề `where` loại sạch, truy vấn con trả về RỖNG, và ô
  -- `dat` mang giá trị rỗng — bảng bày ra y hệt một dấu đỏ. Đã đỏ oan ở lượt
  -- chạy của Tracy 28/08 trong khi hàm hoàn toàn đúng (đã dò tay: chữ ký đủ
  -- bảy tham số, `prosecdef` = true).
  --
  -- Nay so CẤU TRÚC chứ không so chuỗi chữ: đếm số tham số, rồi soi từng kiểu
  -- một qua `proargtypes` (oidvector, đánh số từ 0). Cách này không phụ thuộc
  -- vào việc Postgres in chữ ký ra sao, nên không gãy lại được vì lý do ấy.
  --
  -- LUẬT CHO MỌI DÒNG TỰ KIỂM SAU: đừng bao giờ so một chuỗi do máy chủ in ra
  -- khi so được thứ có cấu trúc. Chuỗi in ra là chi tiết trình bày, nó đổi mà
  -- không báo ai.
  (16, 'Hàm giao_cam_ket có mặt, ĐÚNG chữ ký bảy tham số, chạy bằng quyền định nghĩa',
   (select p.prosecdef from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'giao_cam_ket'
       and p.pronargs = 7
       and p.proargtypes[0] = 'bigint'::regtype
       and p.proargtypes[1] = 'uuid'::regtype
       and p.proargtypes[2] = 'text'::regtype
       and p.proargtypes[3] = 'text'::regtype
       and p.proargtypes[4] = 'date'::regtype
       and p.proargtypes[5] = 'bigint'::regtype
       and p.proargtypes[6] = 'date'::regtype)),

  (17, 'Hàm nhan_viec_cam_ket có mặt và CỐ Ý không phải security definer',
   (select not p.prosecdef from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'nhan_viec_cam_ket')),

  (18, 'Hàm tu_choi_cam_ket có mặt và CỐ Ý không phải security definer',
   (select not p.prosecdef from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'tu_choi_cam_ket')),

  (19, 'Hàm rut_lai_cam_ket có mặt và LÀ security definer (lối ra duy nhất của dòng kho)',
   (select p.prosecdef from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = 'rut_lai_cam_ket')),

  (20, 'Cả BỐN hàm đều mở cho người đã đăng nhập gọi',
   (select count(*) from information_schema.routine_privileges
     where routine_schema = 'public'
       and routine_name in ('giao_cam_ket','nhan_viec_cam_ket','tu_choi_cam_ket','rut_lai_cam_ket')
       and grantee = 'authenticated' and privilege_type = 'EXECUTE') = 4),

  (21, 'Hàm nhan_cam_ket (ký nghiệm thu) VẪN nguyên vẹn — file này không đụng luật ký',
   exists (select 1 from pg_proc p
             join pg_namespace n on n.oid = p.pronamespace
            where n.nspname = 'public' and p.proname = 'nhan_cam_ket' and p.prosecdef)),

  -- ─── Khung nhìn ─────────────────────────────────────────────────────────
  (22, 'cho_ban có đủ BỐN nhánh, gọi đúng tên từng loại',
   (select pg_get_viewdef('cho_ban'::regclass) like '%loi-moi%'
       and pg_get_viewdef('cho_ban'::regclass) like '%ky-nhan%'
       and pg_get_viewdef('cho_ban'::regclass) like '%cho-nhan%'
       and pg_get_viewdef('cho_ban'::regclass) like '%bi-tu-choi%')),

  (23, 'cho_ban vẫn đúng SÁU cột (loai · khoa · ten · ai · luc · cua_toi)',
   (select count(*) from information_schema.columns
     where table_name = 'cho_ban'
       and column_name in ('loai','khoa','ten','ai','luc','cua_toi')) = 6),

  (24, 'cho_ban vẫn CHẶN GHI (drop view đã cuốn trigger đi, mục 8b dựng lại)',
   exists (select 1 from pg_trigger where tgname = 'trg_chan_ghi_cho_ban'
             and not tgisinternal)),

  (25, 'Không khung nhìn nào trong schema public còn vượt mặt RLS',
   (select count(*) from kiem_khung_nhin_thieu_quyen()) = 0),

  (26, 'danh_muc_du_an ĐÃ bỏ qua dòng kho khi đếm cam kết (phần trăm không tụt vì một lời giao)',
   pg_get_viewdef('danh_muc_du_an'::regclass) like '%luong IS NOT NULL%'),

  (27, 'danh_muc_du_an vẫn CHẶN GHI (drop view đã cuốn trigger đi, mục 9b dựng lại)',
   exists (select 1 from pg_trigger where tgname = 'trg_chan_ghi_danh_muc_du_an'
             and not tgisinternal)),

  -- ─── HÀNG RÀO THẬT SỰ — mấy dòng cuối, quan trọng nhất cả bảng ──────────
  -- Mọi dòng trên soi CẤU TRÚC. Từ đây xuống soi DỮ LIỆU THẬT.
  --
  -- ⚠️ HAI DÒNG 28 VÀ 29 ĐÃ ĐỔI HẲN CÂU HỎI NGÀY 27/08. Bản cũ hỏi *"có dòng
  -- luống rỗng nào không phải đang chờ nhận không"* và *"có ai đã nhận việc mà
  -- vẫn để luống rỗng không"* — hai câu ấy nay SAI, vì luống rỗng đã có nghĩa
  -- thứ hai hợp lệ (cam kết tự viết nằm kho) và vì `ve_kho_cam_ket` cho một
  -- cam kết đã nhận trả chỗ ngồi lại. Giữ nguyên hai dòng ấy là hai dấu ✘ báo
  -- oan trong khi máy chủ hoàn toàn đúng — đúng cái bệnh mà mục 4 của
  -- `va-sau-dot-soi-08-08.sql` đã đặt tên và ghi "Không tái phạm".
  -- Nay chúng hỏi hai câu CÒN ĐÚNG, và là hai câu thật sự canh cửa: chiều còn
  -- lại của ràng buộc mục 3b, và hàng rào ĐẾM mục 3d — thứ đã thay chỗ của vế
  -- bị bỏ. Câu hỏi mà lỗ hổng 08/08 trả lời sai trong hai tháng nay nằm ở dòng
  -- 29: KHO CÓ ĐANG BỊ CHẶN KHÔNG.
  (28, 'KHÔNG cam kết nào đang chờ được nhận mà đã chiếm sẵn một luống',
   not exists (select 1 from tieu_diem
                where giao_luc is not null
                  and nhan_viec_luc is null
                  and luong is not null)),

  (29, 'KHÔNG ai đang ôm số dòng KHO vượt trần kho của chính mình',
   not exists (select o.nguoi_id
                 from tieu_diem o
                 join nguoi n on n.id = o.nguoi_id
                where o.luong is null and not o.xong
                group by o.nguoi_id, n.so_cam_ket_kho_toi_da
               having count(*) > n.so_cam_ket_kho_toi_da)),

  (30, 'KHÔNG ai tự giao cam kết cho chính mình',
   not exists (select 1 from tieu_diem where giao_boi = nguoi_id)),

  -- ⚠️ CHỈ SOI MỘT CHIỀU, CỐ Ý. Bản đầu đòi hai cột luôn đi cùng nhau
  -- (`(giao_boi is null) <> (giao_luc is null)`), và dòng ấy sẽ báo ✘ oan ngay
  -- lần đầu có ai đó rời đội: khoá ngoại đặt `giao_boi` về rỗng còn `giao_luc`
  -- ở lại, đúng như thiết kế. Chiều CÒN LẠI thì vĩnh viễn không hợp lệ.
  (31, 'KHÔNG dòng nào có tên người giao mà thiếu giờ giao',
   not exists (select 1 from tieu_diem
                where giao_boi is not null and giao_luc is null)),

  (32, 'KHÔNG cam kết nào vừa nhận vừa từ chối',
   not exists (select 1 from tieu_diem
                where nhan_viec_luc is not null and tu_choi_luc is not null)),

  (33, 'KHÔNG cam kết TỰ VIẾT nào mang dấu nhận việc hay từ chối (ô số 4, mục 3b)',
   not exists (select 1 from tieu_diem
                where giao_luc is null
                  and (nhan_viec_luc is not null
                       or tu_choi_luc is not null
                       or length(trim(coalesce(tu_choi_ly_do, ''))) > 0))),

  (34, 'KHÔNG lời từ chối nào bỏ trống lý do',
   not exists (select 1 from tieu_diem
                where tu_choi_luc is not null
                  and length(trim(coalesce(tu_choi_ly_do, ''))) = 0)),

  -- ─── ĐỢT NỚI KHO 27/08 — sáu dòng cuối, đánh số tiếp chứ KHÔNG chèn ─────
  -- Cố ý nối đuôi thay vì xếp xen vào giữa cho gọn: mấy khối chú thích trong
  -- file này gọi thẳng tên số dòng ("bộ tự kiểm mục 31 soi đúng chiều ấy",
  -- "Mục 3 của bảng trên đọc confdeltype"), nên đánh số lại là làm mọi câu ấy
  -- trỏ sang dòng khác mà không lỗi nào báo.
  (35, 'Tên ràng buộc CŨ đã dọn đi (luong_rong_chi_khi_cho_nhan nói sai luật mới)',
   not exists (select 1 from pg_constraint
                where conrelid = 'tieu_diem'::regclass
                  and conname = 'luong_rong_chi_khi_cho_nhan')),

  -- Soi HÌNH DÁNG chứ không chỉ soi cái tên. Một ràng buộc mang tên mới mà
  -- thân vẫn là đẳng thức hai chiều thì dòng 5 vẫn xanh trong khi kho tự viết
  -- không vào nổi — đúng thứ đợt này dựng ra để sửa. `pg_get_constraintdef`
  -- in lại thân đã chuẩn hoá, và bản một chiều luôn có chữ `NOT`.
  (36, 'Ràng buộc luống là mệnh đề MỘT CHIỀU (kho nhận được cả cam kết tự viết)',
   (select pg_get_constraintdef(oid) like '%NOT%'
      from pg_constraint
     where conrelid = 'tieu_diem'::regclass
       and conname = 'cho_nhan_thi_luong_phai_rong')),

  (37, 'Trần CẢ KHO có con số riêng: cột nguoi.so_cam_ket_kho_toi_da đã mọc',
   exists (select 1 from information_schema.columns
            where table_name = 'nguoi' and column_name = 'so_cam_ket_kho_toi_da')),

  -- ⚠️ DÒNG QUAN TRỌNG NHẤT CỦA ĐỢT NÀY. Trigger này là thứ DUY NHẤT còn giữ
  -- luật ba luống sau khi mục 3b bỏ vế "luống rỗng thì bắt buộc là dòng chờ
  -- nhận". Nó vắng mặt = lỗ hổng 08/08 mở lại, và không dòng nào khác trong
  -- bảng này thấy được chuyện đó.
  (38, 'Trigger trg_tran_ca_kho_cam_ket đang cắm (kho KHÔNG phải cửa hậu vô hạn)',
   exists (select 1 from pg_trigger where tgrelid = 'tieu_diem'::regclass
             and not tgisinternal and tgname = 'trg_tran_ca_kho_cam_ket')),

  -- Gác cả `insert` LẪN `update of luong`. Chỉ gác chèn thì đẩy một cam kết
  -- đang chạy về kho là một đường vòng đi quanh hàng rào — xây bằng toàn bước
  -- hợp lệ, không lỗi nào báo. Đọc bằng `pg_get_triggerdef`, thứ in lại nguyên
  -- câu `create trigger` kèm danh sách cột, chứ không mò trong `tgattr` (một
  -- int2vector, phải ép kiểu mới so được — thêm một chỗ để gõ sai).
  -- Chữ 'luong' chỉ có thể đến từ danh sách cột: cả tên trigger lẫn tên hàm
  -- đều không chứa nó.
  (39, 'Trigger trần kho gác CẢ update of luong, không chỉ insert',
   (select pg_get_triggerdef(oid) like '%UPDATE OF%'
       and pg_get_triggerdef(oid) like '%luong%'
      from pg_trigger
     where tgrelid = 'tieu_diem'::regclass
       and tgname = 'trg_tran_ca_kho_cam_ket')),

  (40, 'Hai cửa ra vào kho có mặt và mở cho người đã đăng nhập gọi',
   (select count(*) from information_schema.routine_privileges
     where routine_schema = 'public'
       and routine_name in ('vao_luong_cam_ket','ve_kho_cam_ket')
       and grantee = 'authenticated' and privilege_type = 'EXECUTE') = 2),

  -- ─── ĐỢT DỰNG LẠI KHUNG NHÌN (mục 10) ────────────────────────────────────
  -- ⚠️ Dòng 41 là dòng canh cửa cho cả khối Kho cam kết bên giao diện. Nó đỏ
  -- nghĩa là màn hình đang gắn nhãn "Tự viết" cho lời người khác giao, và cặp
  -- nút Nhận/Từ chối không vẽ ra — hỏng mà không kêu một tiếng nào. Nó cũng là
  -- dòng đỏ lên nếu ai chạy lại `nang-cap-doi-ten-trang-thai-task.sql` sau file
  -- này: bản kia dựng `tien_do_o` 29 cột, cuốn sạch bảy cột thêm.
  (41, 'tien_do_o đã chở đủ NĂM cột sổ giao nhận (khối Kho cam kết sống nhờ nó)',
   (select count(*) from information_schema.columns
     where table_name = 'tien_do_o'
       and column_name in ('giao_boi','giao_luc','nhan_viec_luc',
                           'tu_choi_luc','tu_choi_ly_do')) = 5),

  (42, 'tien_do_o đủ 36 cột và vẫn chạy security_invoker (29 cũ + 7 thêm)',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'tien_do_o') = 36
   and (select coalesce(reloptions::text, '') like '%security_invoker=on%'
          from pg_class where relname = 'tien_do_o'))
)
select stt,
       case when dat then '✔' else '✘ CHƯA ĐẠT' end as ket_qua,
       muc
from kiem order by stt;


-- ════════════════════════════════════════════════════════════════════════════
-- PHÉP THỬ THẬT — thứ bảng trên KHÔNG soi được
-- ════════════════════════════════════════════════════════════════════════════
-- Mục 3 của bảng trên đọc `confdeltype` và in ✔. Nó chỉ nói khoá ngoại ĐỊNH
-- LÀM GÌ lúc xoá một người, không nói nó CÓ LÀM ĐƯỢC KHÔNG — mà đúng chỗ ấy là
-- chỗ hỏng: hành động SET NULL của khoá ngoại chạy bằng một câu `update` thật,
-- và câu ấy đi qua trigger `kiem_giao_cam_ket` cùng ràng buộc
-- `luong_rong_chi_khi_cho_nhan`. Bản đầu của file này chặn nó, tức
-- `delete from nguoi` đổ với một câu lỗi nói về "sửa lời khai" — không nhắc gì
-- tới việc đang xoá người, không ai lần ra nổi. Bảng tự kiểm vẫn xanh.
--
-- Nên phải thử thật: xoá một người đã từng giao cam kết, xem có xoá được
-- không, rồi CUỘN LẠI. Không dòng nào mất.
-- Chưa có lời giao nào thì khối này không có gì để thử và nói ra điều đó.
do $$
declare v_ai uuid;
begin
  select giao_boi into v_ai from tieu_diem where giao_boi is not null limit 1;
  if v_ai is null then
    raise notice 'PHÉP THỬ XOÁ NGƯỜI — bỏ qua: chưa có lời giao nào trong bảng để thử. Chạy lại file này sau khi đã giao thử một cam kết.';
    return;
  end if;

  begin
    delete from nguoi where id = v_ai;
    -- Xoá được. Ném một lỗi có mã riêng để cuộn lại đúng khối này, không đụng
    -- gì tới dữ liệu thật. Khối `begin … exception` của plpgsql là một giao
    -- dịch con — bắt được lỗi là mọi thứ nó vừa làm bị cuộn ngược.
    raise exception using errcode = 'ZZ999', message = 'cuộn lại phép thử';
  exception
    when sqlstate 'ZZ999' then
      raise notice 'PHÉP THỬ XOÁ NGƯỜI ✔ — xoá được một người đã từng giao cam kết, và cam kết ở lại. Đã cuộn lại, không mất dữ liệu.';
    when others then
      raise notice 'PHÉP THỬ XOÁ NGƯỜI ✘ — không xoá được người đã giao cam kết. Máy chủ trả về: %  ĐỌC KỸ CÂU LỖI TRƯỚC KHI SỬA: nếu nó nhắc tới cam kết, lời khai hay luống thì đúng là cái bẫy mục 1 đoạn ① — có hàng rào nào đó vẫn đang neo vào giao_boi thay vì giao_luc. Nếu nó nhắc tới một bảng khác thì đó là một khoá ngoại khác, không phải việc của file này.', sqlerrm;
  end;
end $$;


-- ─── PHÉP THỬ THỨ HAI: HÀNG RÀO ĐẾM CÓ THẬT SỰ CHẶN KHÔNG ───────────────────
-- Dòng 38 của bảng trên chỉ nói trigger ĐANG CẮM. Cắm mà không chặn là ca dễ
-- xảy ra nhất và khó thấy nhất: nhánh `if` thoát sớm sai một dấu, hoặc trigger
-- gác nhầm cột, hoặc câu đếm lọc nhầm — bảng tự kiểm vẫn xanh trọn vẹn trong
-- khi kho đã là cửa hậu vô hạn. Mà đây đúng là hàng rào DUY NHẤT còn giữ luật
-- ba luống sau khi mục 3b bỏ vế của nó, nên nó phải được thử THẬT.
--
-- Cách thử: hạ trần kho của một người xuống 0 rồi ĐẨY MỘT CAM KẾT ĐANG CHẠY
-- CỦA HỌ VỀ KHO. Chọn đúng đường `update of luong` chứ không phải đường chèn,
-- vì đó mới là đường vòng — chèn thì ai cũng nghĩ tới mà gác, còn đẩy một dòng
-- hợp lệ sang kho thì không.
-- Lấy một dòng TỰ VIẾT đang sống để không lôi luật giao nhận vào phép thử.
-- Xong thì cuộn lại trọn khối: trần trả về như cũ, cam kết ở nguyên luống cũ.
do $$
declare
  v_ma    text;
  v_ai    uuid;
  v_chan  boolean := false;
begin
  select ma, nguoi_id into v_ma, v_ai
    from tieu_diem
   where luong is not null and not xong and giao_luc is null
   limit 1;

  if v_ma is null then
    raise notice 'PHÉP THỬ TRẦN KHO — bỏ qua: chưa có cam kết tự viết nào đang sống để thử. Gieo một cam kết rồi chạy lại file này.';
    return;
  end if;

  begin
    update nguoi set so_cam_ket_kho_toi_da = 0 where id = v_ai;

    -- Giao dịch con lồng trong giao dịch con: bắt được lỗi ở đây thì câu
    -- update hỏng tự cuộn ngược, còn biến `v_chan` sống sót (biến plpgsql
    -- không nằm trong thứ bị cuộn lại).
    begin
      update tieu_diem set luong = null where ma = v_ma;
    exception when others then
      v_chan := true;
    end;

    raise exception using errcode = 'ZZ999', message = 'cuộn lại phép thử';
  exception
    when sqlstate 'ZZ999' then
      if v_chan then
        raise notice 'PHÉP THỬ TRẦN KHO ✔ — hàng rào đếm chặn được đường đẩy một cam kết đang chạy về kho khi kho đã đầy. Đã cuộn lại, trần và cam kết nguyên vẹn.';
      else
        raise notice 'PHÉP THỬ TRẦN KHO ✘ ✘ ✘ — KHO ĐANG LÀ CỬA HẬU VÔ HẠN. Trần kho đặt 0 mà vẫn đẩy được một cam kết về kho, nghĩa là luật ba luống hiện KHÔNG có gì giữ (mục 3b đã bỏ vế của nó, mục 3d chưa thay được chỗ). Soi trigger trg_tran_ca_kho_cam_ket: nó có gác update of luong không, nhánh thoát sớm có đúng không, câu đếm có lọc nhầm không.';
      end if;
    when others then
      raise notice 'PHÉP THỬ TRẦN KHO — không chạy được, máy chủ trả về: %  Nếu câu lỗi nhắc tới cột so_cam_ket_kho_toi_da thì mục 3d chưa chạy.', sqlerrm;
  end;
end $$;


-- ════════════════════════════════════════════════════════════════════════════
-- KIỂM NHANH BẰNG MẮT SAU KHI CHẠY
-- ════════════════════════════════════════════════════════════════════════════
-- ① Kho của cả đội — ai đang được giao gì mà chưa trả lời:
--      select o.ma, o.ten, n.ten as nguoi_nhan, g.ten as nguoi_giao,
--             o.giao_luc, o.tu_choi_luc, o.tu_choi_ly_do
--        from tieu_diem o
--        join nguoi n on n.id = o.nguoi_id
--        left join nguoi g on g.id = o.giao_boi
--       where o.giao_luc is not null and o.nhan_viec_luc is null
--       order by o.giao_luc;
--
-- ② Thứ đang chờ chính bạn (chạy QUA APP bằng tài khoản của bạn — SQL Editor
--    không có người đăng nhập nên `nguoi_id_dang_nhap()` trả rỗng và khung
--    nhìn này ra bảng trắng):
--      select * from cho_ban order by luc;
--
-- ③ Thử một vòng giao–nhận từ SQL Editor thì KHÔNG chạy được, vì cả BỐN hàm
--    (giao · nhận việc · từ chối · rút lại) đều bắt đầu bằng
--    `nguoi_id_dang_nhap()`, mà SQL Editor không có người đăng nhập. Thử bằng
--    app, hoặc bằng hai tài khoản thật.
--
-- ④ ⛔ QUAY LUI TRỌN FILE NÀY — ĐỌC HẾT TRƯỚC KHI GÕ MỘT CHỮ.
--    ⚠️ CÂU `delete` DƯỚI ĐÂY XOÁ TRẮNG MỌI CAM KẾT ĐANG CHỜ NHẬN. Chỉ chạy
--    khi đã chắc chắn muốn bỏ hẳn tính năng giao việc, và đã xem trước danh
--    sách sắp mất bằng câu ① ở trên. Đừng bao giờ dán khối này để "chữa" một
--    dấu ✘ trong bảng tự kiểm — dấu ✘ thì sửa đúng chỗ nó chỉ.
--      drop trigger if exists trg_tran_kho_cam_ket      on tieu_diem;
--      drop trigger if exists trg_kiem_giao_cam_ket     on tieu_diem;
--      drop trigger if exists trg_kiem_xoa_giao_cam_ket on tieu_diem;
--      drop function if exists tran_kho_cam_ket();
--      drop function if exists kiem_giao_cam_ket();
--      drop function if exists giao_cam_ket(bigint, uuid, text, text, date, bigint, date);
--      drop function if exists nhan_viec_cam_ket(text, int);
--      drop function if exists tu_choi_cam_ket(text, text);
--      drop function if exists rut_lai_cam_ket(text);
--      alter table tieu_diem drop constraint if exists luong_rong_chi_khi_cho_nhan;
--      alter table tieu_diem drop constraint if exists khong_tu_giao_cho_minh;
--      alter table tieu_diem drop constraint if exists tu_choi_phai_khai_ly_do;
--      delete from tieu_diem where giao_luc is not null and nhan_viec_luc is null;
--      alter table tieu_diem alter column luong set not null;   -- ⚠️ dựng lại
--      alter table tieu_diem drop column if exists tu_choi_ly_do;
--      alter table tieu_diem drop column if exists tu_choi_luc;
--      alter table tieu_diem drop column if exists nhan_viec_luc;
--      alter table tieu_diem drop column if exists giao_luc;
--      alter table tieu_diem drop column if exists giao_boi;
--      alter table nguoi     drop column if exists so_loi_giao_toi_da;
--      drop policy if exists them_tieudiem on tieu_diem;
--      create policy them_tieudiem on tieu_diem for insert
--        with check (nguoi_id = nguoi_id_dang_nhap());
--    Rồi chạy lại HAI file để dựng lại hai khung nhìn bản cũ, nếu không app
--    mất khối "Chờ bạn" và cả tab Dự án:
--      · nang-cap-cho-ban.sql       (dựng lại `cho_ban` bản hai nhánh)
--      · nang-cap-mang-du-an.sql    (dựng lại `danh_muc_du_an` bản không lọc)
--
-- ⑤ CÒN LẠI CHO ĐỢT SAU (đã nêu ở đầu file, nhắc lại để không rơi):
--      · GIAO DIỆN — việc gấp nhất, xem khối ⚠️ "GIAO DIỆN CHƯA BIẾT HAI LOẠI
--        MỚI" ở đầu file: hai nhánh `CB_LOAI`, con số thẻ đếm theo dòng vẽ
--        được, nút Giao cam kết trong milestone, hai nút trả lời, nút Rút lại
--      · ✅ XONG 27/08 — dựng lại `tien_do_o` kèm moc_id · ngay_bat_dau · năm
--        cột sổ giao nhận (mục 10). ⚠️ Chạy lại `nang-cap-doi-ten-trang-thai-
--        task.sql` là mất bảy cột ấy; chạy lại file này ngay sau đó.
--      · nấc "người giao đã biết lời từ chối" (`tu_choi_da_xem_luc`) — hôm nay
--        lối ra duy nhất là rút hẳn lời giao, chưa có cách giữ dòng mà thôi nhắc
--      · chặn gắn task vào một cam kết đang nằm kho (xem hành vi ngầm ② ở đầu
--        file)
--      · sửa hai dòng tự kiểm của `va-sau-dot-soi-08-08.sql` (mục 1 và mục 3)
--      · đổi task.trang_thai 'Confirm' → 'Chua_lam' — file riêng
--        `nang-cap-doi-ten-trang-thai-task.sql`, chạy được ngay, không phụ
--        thuộc file này
-- ════════════════════════════════════════════════════════════════════════════

notify pgrst, 'reload schema';
