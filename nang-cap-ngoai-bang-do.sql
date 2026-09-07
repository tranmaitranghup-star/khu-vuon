-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.ngoai_bang_do`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- AI ĐỨNG TRONG BẢNG ĐO                            (Tracy chốt 2026-09-07)
--
-- Tracy: *"bỏ Hương Giang khỏi dashboard (bảng đo) và tên ở đầu mục hôm nay
-- đi"*. Bạn ấy là trợ lý khối Vận hành, không tham gia cuộc đo — nên một dòng
-- 0 quả mang tên bạn ấy nằm giữa bảng xếp hạng là một con số nói sai về một
-- người, và một cái tên trong hàng "ai đang deepwork" là một chỗ trống vĩnh
-- viễn mà mắt cứ phải bỏ qua mỗi lần nhìn.
--
-- ⛔ ĐÂY KHÔNG PHẢI QUYỀN. Cột `la_quan_tri`/`la_lead` trả lời *ai được xem gì*;
-- cột này trả lời *ai được đếm*. Năm Member còn lại vẫn đứng đủ trong bảng đo —
-- họ có deepwork thật. Đừng gộp hai câu hỏi ấy vào một cột, và đừng suy cột này
-- ra từ cấp.
--
-- VÌ SAO MỘT CỜ, KHÔNG PHẢI MỘT CÁI TÊN VIẾT CỨNG. Ghim tên vào mã thì ngày có
-- trợ lý thứ hai lại phải sửa mã, và ngày người ấy đổi tên hiển thị thì bảng
-- lặng lẽ nhận lại một dòng không ai chờ — hỏng trong im lặng, kiểu tệ nhất.
--
-- MẶC ĐỊNH `false`, KHÔNG PHẢI `true`. Người thứ mười ba vào app đứng trong
-- bảng như mọi người; ra ngoài là một việc phải KHAI. Ngược lại thì một người
-- mới lặng lẽ biến mất khỏi bảng và không ai biết để hỏi vì sao.
--
-- 📌 CẬP NHẬT chiều 07/09: cờ nay ăn ở BẢY chỗ, và mang thêm 5 member chưa
-- onboard — xem `nang-cap-tam-an-5-member-chua-onboard.sql`. Bộ tự kiểm ở cuối
-- tệp NÀY vì thế sẽ báo ❌ ở dòng 2 (nó canh "đúng một người"); đó là dấu vết
-- lịch sử, không phải lỗi — đọc bộ tự kiểm của tệp mới.
--
-- ⚠️ CỜ NÀY ĂN Ở NĂM CHỖ ĐỔ CẢ TEAM RA MÀN (đúng vào lúc dựng tệp này) — hàng hiện diện deepwork, dải
-- chuỗi bảy ngày, bảng Kết quả, bảng Giờ tập trung, biểu đồ so sánh. Nó KHÔNG
-- giấu người ấy khỏi ô chọn người, khỏi danh sách mời vào sự kiện, hay khỏi màn
-- Team: bạn ấy vẫn là người trong team, vẫn nhận được việc và lời mời.
--
-- CHẠY: Supabase → SQL Editor → New query → dán trọn file → Run.
--       Chạy lại nhiều lần vô hại. Chạy xong đọc bảng cuối: hai dòng phải ✅.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

alter table nguoi add column if not exists ngoai_bang_do boolean not null default false;

comment on column nguoi.ngoai_bang_do is
  'Người này KHÔNG đứng trong bảng đo và hàng hiện diện deepwork. Không phải '
  'quyền — họ không bị chặn khỏi gì cả, chỉ là không tham gia cuộc đo (trợ lý, '
  'cộng tác viên…). Mặc định false: ra ngoài bảng là một việc phải khai.';

-- Khai theo EMAIL, không theo tên hiển thị: email là khoá duy nhất của bảng,
-- còn tên thì sửa được ở màn Team và sửa xong là câu này trượt trong im lặng.
update nguoi set ngoai_bang_do = true
 where email = 'nguoi-13@vidu.com';

commit;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
select so, muc, ket_qua from (values
  (1, 'cột ngoai_bang_do có mặt',
      case when exists (select 1 from information_schema.columns
                         where table_schema='public' and table_name='nguoi'
                           and column_name='ngoai_bang_do')
           then '✅ có' else '❌ chưa có' end),
  (2, 'đúng MỘT người đứng ngoài bảng đo, và đó là Hương Giang',
      coalesce((select case when count(*) = 1 and min(ten) = 'Hương Giang'
                            then '✅ ' || min(ten)
                            else '❌ ' || count(*) || ' người: '
                                 || coalesce(string_agg(ten, ', '), '(không ai)') end
                  from nguoi where ngoai_bang_do), '❌ chưa chạy được'))
) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' then 2 else 1 end, so;
