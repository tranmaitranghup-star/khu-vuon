-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: khung nhìn `dem_cam_ket_da_dong` — tệp `nang-cap-cam-ket-5-cua-ceo.sql` cũng dựng nó
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- CHẾ ĐỘ "CẢ ROVA" CỦA TAB CAM KẾT — đếm ở máy chủ + dọn một ghi chú sai
-- Tracy duyệt 09/08/2026. Chạy MỘT LẦN trên Supabase › SQL Editor.
-- Chạy lại nhiều lần vẫn ra cùng kết quả (idempotent).
-- ═══════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO CÓ FILE NÀY
--
-- Màn "Cam kết cả ROVA" phải trả lời ba câu: mỗi người đang giữ cam kết nào ·
-- tiến độ từng cam kết · ĐÃ HOÀN THÀNH BAO NHIÊU CAM KẾT. Hai câu đầu đã có dữ
-- liệu (khung nhìn `tien_do_o`). Câu thứ ba thì CHƯA — và không thể lấy bằng
-- cách kéo dòng về đếm:
--
--   Cam kết đã đóng KHÔNG BAO GIỜ rời khỏi bảng. 12 người × mỗi tuần một cái
--   ≈ 600 dòng trong năm đầu, 3.000 dòng sau năm năm. Trần `Max rows` của dự
--   án là 1000 và máy chủ CẮT ÂM THẦM phần dôi ra. Đếm trên phần bị cắt thì
--   con số cứ nhỏ dần theo thời gian mà không báo gì.
--
-- Nên đếm ở đây, trả về đúng MỘT DÒNG MỖI NGƯỜI — tối đa 12 dòng, đứng yên mãi
-- mãi dù đội đóng bao nhiêu cam kết. Cùng luật với `tien_do_o`: gộp sẵn ở
-- Postgres, đừng gửi dòng thô đi.


-- ─── 1. Khung nhìn: mỗi người đã đóng bao nhiêu cam kết (TRỌN ĐỜI) ──────────
-- Trọn đời chứ không theo quý — Tracy chốt 09/08: đây là thành tích tích luỹ.
--
-- Chỉ đếm cam kết THẬT (`luong` 1–3). Hạt cũ sót lại từ bản O1–O10 chưa gán
-- luống không phải cam kết theo nghĩa hiện nay, đếm vào là số cao hơn sự thật.
--
-- `left join` từ `nguoi` chứ không `group by` trên `tieu_diem`: người chưa đóng
-- cái nào vẫn phải có một dòng với số 0. Nhóm từ phía tieu_diem thì họ biến mất
-- khỏi kết quả, app lại phải tự đoán "không thấy dòng nghĩa là 0" — một chỗ dễ
-- lẫn với "chưa tải xong".
drop view if exists dem_cam_ket_da_dong;

create view dem_cam_ket_da_dong as
select
  n.id                                          as nguoi_id,
  count(o.ma) filter (where o.xong)             as so_da_dong
from nguoi n
left join tieu_diem o
       on o.nguoi_id = n.id
      and o.luong between 1 and 3
group by n.id;

comment on view dem_cam_ket_da_dong is
  'Mỗi người đã đóng bao nhiêu cam kết, tính trọn đời. Một dòng mỗi người, kể cả người chưa đóng cái nào (0). Nuôi dấu ✅ ở màn Cam kết cả ROVA.';

-- Bắt buộc, y như 6 khung nhìn kia: không có dòng này thì khung nhìn chạy bằng
-- quyền của người TẠO ra nó và vượt mặt RLS — ai đăng nhập cũng đếm được mọi
-- người, kể cả khi policy đọc bị siết lại sau này.
alter view dem_cam_ket_da_dong set (security_invoker = on);


-- ─── 2. Dọn một ghi chú NÓI NGƯỢC với luật đang chạy ────────────────────────
-- `nang-cap-khu-vuon.sql` (06/08) đặt cột `nguoi_tick` kèm ghi chú "Cả đội tick
-- được, không riêng người gieo" — đúng với thiết kế lúc đó.
-- Nhưng CŨNG NGÀY 06/08, `nang-cap-luong-rieng-tung-nguoi.sql` siết policy
-- `sua_tieudiem` xuống `using (nguoi_id = nguoi_id_dang_nhap())`. Từ đó chỉ chủ
-- cam kết mới sửa được dòng của mình, tức chỉ họ tick xong được.
--   ⇒ `nguoi_tick` LUÔN bằng `nguoi_id`. Ghi chú kia là chữ cũ sót lại, ai đọc
--     vào sẽ hiểu sai luật đang chạy (Tracy bắt được 09/08).
-- CỐ Ý KHÔNG gỡ cột: gỡ là việc riêng, và nếu ngày nào mở lại cho cả đội tick
-- thì lại cần đúng cột này. Chỉ sửa cho chữ khớp với luật.
comment on column tieu_diem.nguoi_tick is
  'Ai tick xong. Từ 06/08 policy sua_tieudiem chỉ cho CHỦ cam kết sửa dòng của mình, nên cột này luôn bằng nguoi_id. Giữ lại phòng khi mở lại cho cả đội tick.';


-- ─── 3. Tự kiểm ─────────────────────────────────────────────────────────────
-- Chạy xong phải thấy đủ 4 dòng `dat = true`. Có dòng false thì ĐỪNG deploy app.
with kiem(stt, dieu, dat) as (values
  (1, 'Khung nhìn dem_cam_ket_da_dong đã dựng',
   exists (select 1 from pg_views where viewname = 'dem_cam_ket_da_dong')),

  (2, 'Khung nhìn bật security_invoker — không vượt mặt RLS',
   exists (select 1 from pg_class
             where relname = 'dem_cam_ket_da_dong'
               and 'security_invoker=on' = any(coalesce(reloptions, '{}')))),

  (3, 'Trả đúng một dòng mỗi người, kể cả người chưa đóng cam kết nào',
   (select count(*) from dem_cam_ket_da_dong) = (select count(*) from nguoi)),

  -- Chốt chặn thật: tổng số đếm được phải bằng tổng cam kết đã đóng trong bảng.
  -- Sai một cái là biết ngay điều kiện lọc `luong between 1 and 3` bị lệch.
  (4, 'Tổng khớp với số cam kết đã đóng trong bảng',
   (select coalesce(sum(so_da_dong), 0) from dem_cam_ket_da_dong)
     = (select count(*) from tieu_diem where xong and luong between 1 and 3))
)
select stt, dieu, dat from kiem order by stt;
