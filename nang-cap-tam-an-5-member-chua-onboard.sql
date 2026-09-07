-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: 5 dòng `nguoi.ngoai_bang_do = true` mang đúng
-- │ năm email dưới đây. Đã chạy chưa? → chạy bộ tự kiểm ở cuối tệp này.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- TẠM ẨN 5 MEMBER CHƯA ONBOARD KHỎI BẢNG ĐO      (Tracy chốt 2026-09-07, chiều)
--
-- Tracy: *"tạm thời ẩn giúp tôi tên của 5 member ra khỏi dashboard và bảng ở
-- đầu mục hôm nay… tôi pending chưa onboard luôn hôm nay mà đợi mấy hôm nữa
-- (chỉ là ẩn tên đi chứ vẫn giữ acc của họ đã đăng ký)"*. Duyệt thêm sau đó:
-- *"cả màn cố định luôn đi"*.
--
-- AI, VÀ VÌ SAO LÀ NĂM NGƯỜI NÀY. Sổ người ngày 05/09 có bảy ai; ngày 06/09
-- thành mười hai. Năm người mới đúng là năm người dưới đây, và tới lúc viết tệp
-- này cả năm đều chưa có một phiên deep work, một task, hay một ngày nộp nào.
-- Nên họ đang là năm dòng 0 nằm giữa một bảng xếp hạng — một con số nói sai về
-- một người chưa kịp bắt đầu.
--
-- ⛔ ĐÂY KHÔNG PHẢI QUYỀN, VÀ KHÔNG ĐỘNG TỚI TÀI KHOẢN. Cả năm vẫn đăng nhập
-- được, vẫn nhận việc, vẫn nhận lời mời vào sự kiện, vẫn có tên trong ô chọn
-- người và ở màn Team. Thứ đổi là họ không có TÊN trong bảng đo — đúng nguyên
-- văn *"chỉ là ẩn tên đi chứ vẫn giữ acc"*.
--
-- ⚠️ DÙNG LẠI CỜ ĐÃ CÓ, không dựng cột mới. Cột `nguoi.ngoai_bang_do` do
-- `nang-cap-ngoai-bang-do.sql` dựng sáng 07/09 cho Hương Giang. Một câu hỏi thì
-- một cột — dựng cột thứ hai cho cùng câu hỏi là hai nguồn sớm muộn trôi lệch.
--
-- ⚠️ HAI LÝ DO KHÁC NHAU CÙNG ĐI CHUNG MỘT CỜ, và cột không phân biệt được:
--     · Hương Giang đứng ngoài VĨNH VIỄN — trợ lý, không tham gia cuộc đo;
--     · năm người dưới đây đứng ngoài TỚI KHI onboard xong.
--   Nên chỗ ghi lý do là chính tệp này. Ngày gỡ, gỡ đúng năm email dưới —
--   ĐỪNG gỡ sạch cả cột, làm thế là Hương Giang lặng lẽ hiện lại.
--
-- CỜ NÀY ĂN Ở BẢY CHỖ ĐỔ CẢ TEAM RA MÀN (bảy, không phải năm như tệp trước ghi
-- — hai chỗ cuối vừa nối vào chiều 07/09):
--     Màn Hôm nay   ① hàng hiện diện deepwork ở đầu màn
--     Màn Bảng đo   ② dải chuỗi bảy ngày   ③ bảng Kết quả trong ngày
--                   ④ bảng Giờ tập trung   ⑤ biểu đồ Deep work và việc hoàn thành
--                   ⑥ khối 💧 Giờ deep work            ← nối 07/09
--     Màn Việc cố định ⑦ lưới nhịp cả team + bốn ô số  ← nối 07/09
--
-- CHẠY: Supabase → SQL Editor → New query → dán trọn tệp → Run.
--       Chạy lại nhiều lần vô hại. Chạy xong đọc bảng cuối: ba dòng phải ✅.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- Có sẵn rồi thì câu này không làm gì. Để ở đây để tệp tự đứng được, phòng khi
-- `nang-cap-ngoai-bang-do.sql` chưa kịp chạy trên máy chủ này.
alter table nguoi add column if not exists ngoai_bang_do boolean not null default false;

-- Khai theo EMAIL, không theo tên hiển thị: email là khoá duy nhất của bảng,
-- còn tên thì sửa được ở màn Team và sửa xong là câu này trượt trong im lặng.
update nguoi set ngoai_bang_do = true
 where email in (
   'nguoi-14@vidu.com',    -- Andrew · Trương Văn Tiến · Mentor
   'nguoi-11@vidu.com',            -- Javis  · Nguyễn Hữu Thắng · Sales
   'nguoi-16@vidu.com',          -- Ham    · Nguyễn Xuân Đại  · Mentor
   'nguoi-09@vidu.com',  -- Vicky  · Nguyễn Sơn Tùng  · Sales
   'nguoi-04@vidu.com'           -- ZemC   · Dương Bảo Ngọc   · MKT
 );

commit;


-- ═══════════════════════════════════════════════════════════════════════════
-- 🔓 NGÀY ONBOARD XONG THÌ GỠ — bỏ dấu chú thích hai dòng dưới rồi chạy.
--    Gỡ được từng người một: bỏ bớt email nào ra khỏi danh sách thì người ấy
--    còn đứng ngoài. Sau khi chạy, bộ tự kiểm dưới sẽ đổi sang ❌ — đúng như
--    vậy, vì lúc ấy tệp này thôi là thứ đang có hiệu lực.
-- ═══════════════════════════════════════════════════════════════════════════
-- update nguoi set ngoai_bang_do = false
--  where email in ('nguoi-14@vidu.com', 'nguoi-11@vidu.com',
--                  'nguoi-16@vidu.com', 'nguoi-09@vidu.com',
--                  'nguoi-04@vidu.com');


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
select so, muc, ket_qua from (values
  (1, 'cột ngoai_bang_do có mặt',
      case when exists (select 1 from information_schema.columns
                         where table_schema='public' and table_name='nguoi'
                           and column_name='ngoai_bang_do')
           then '✅ có' else '❌ chưa có' end),
  (2, 'đủ 5 member chưa onboard đứng ngoài bảng đo',
      coalesce((select case when count(*) = 5
                            then '✅ ' || string_agg(ten, ', ' order by thu_tu)
                            else '❌ mới ' || count(*) || '/5: '
                                 || coalesce(string_agg(ten, ', ' order by thu_tu), '(không ai)') end
                  from nguoi
                 where ngoai_bang_do
                   and email in ('nguoi-14@vidu.com', 'nguoi-11@vidu.com',
                                 'nguoi-16@vidu.com', 'nguoi-09@vidu.com',
                                 'nguoi-04@vidu.com')), '❌ chưa chạy được')),
  (3, 'năm tài khoản vẫn còn nguyên, không ai bị xoá hay cho nghỉ',
      coalesce((select case when count(*) = 5 and count(ngay_nghi) = 0
                            then '✅ 5/5 còn hoạt động'
                            else '❌ còn ' || count(*) || '/5, trong đó '
                                 || count(ngay_nghi) || ' người đã ghi ngày nghỉ' end
                  from nguoi
                 where email in ('nguoi-14@vidu.com', 'nguoi-11@vidu.com',
                                 'nguoi-16@vidu.com', 'nguoi-09@vidu.com',
                                 'nguoi-04@vidu.com')), '❌ chưa chạy được'))
) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' then 2 else 1 end, so;
