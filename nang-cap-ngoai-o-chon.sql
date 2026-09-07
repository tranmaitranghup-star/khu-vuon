-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.ngoai_o_chon`.
-- │ Đã chạy chưa? → đọc bộ tự kiểm ở cuối tệp này.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- AI HIỆN TRONG Ô CHỌN NGƯỜI                    (Tracy chốt 2026-09-07, chiều)
--
-- Tracy, nhìn hàng chip mời người của cửa sự kiện: *"chỗ này xóa tên Hương
-- Giang đi nha"*, rồi mở rộng: *"bỏ hết ở những chỗ chọn nhé"*.
--
-- ⛔ VÌ SAO KHÔNG DÙNG LẠI `ngoai_bang_do`. Cờ ấy đang mang SÁU người: Hương
-- Giang cộng năm member chưa onboard. Lọc ô chọn theo nó là năm người kia thôi
-- được mời và thôi được giao việc — mà Tracy giữ họ lại đúng để còn giao. Ba
-- câu hỏi khác nhau thì ba cột:
--     la_quan_tri / la_lead  → ai được XEM gì
--     ngoai_bang_do          → ai được ĐẾM trong bảng đo
--     ngoai_o_chon (tệp này) → ai được CHỌN để giao hoặc mời
--
-- ⚠️ CHỌN KHÁC TRA TÊN. Cờ này chỉ ăn ở những chỗ BÀY RA để bấm chọn. Mọi chỗ
-- dịch một id sẵn có thành cái tên vẫn đọc cả team — nếu không, việc bạn ấy
-- từng nhận sẽ hiện ra mang tên "—", mà một dòng mất tên còn khó hiểu hơn một
-- dòng có tên không mong đợi.
--
-- SÁU Ô CHỌN đi qua cờ này:
--     ① mời người vào sự kiện        ④ trao dự án cho người khác
--     ② thêm thành viên vào dự án    ⑤ mời thêm người vào dự án
--     ③ chọn PIC cho cam kết         ⑥ chọn người nhận vấn đề
--
-- KHÔNG ĐỘNG TỚI TÀI KHOẢN. Hương Giang vẫn đăng nhập, vẫn thấy việc đã có,
-- vẫn nhận sự kiện phạm vi "Cả công ty", vẫn có tên trong màn Team.
--
-- CHẠY: Supabase → SQL Editor → New query → dán trọn tệp → Run.
--       Chạy lại nhiều lần vô hại. Chạy xong đọc bảng cuối: ba dòng phải ✅.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

alter table nguoi add column if not exists ngoai_o_chon boolean not null default false;

comment on column nguoi.ngoai_o_chon is
  'Người này KHÔNG hiện trong các ô chọn người (mời sự kiện, thêm vào dự án, '
  'chọn PIC, giao vấn đề). Không phải quyền, cũng không phải bảng đo — cột này '
  'chỉ trả lời "ai được CHỌN". Mặc định false: ra ngoài là một việc phải khai.';

-- Khai theo EMAIL, không theo tên hiển thị: email là khoá duy nhất của bảng,
-- còn tên thì sửa được ở màn Team và sửa xong là câu này trượt trong im lặng.
update nguoi set ngoai_o_chon = true
 where email = 'nguoi-13@vidu.com';   -- Hương Giang · trợ lý

commit;


-- ═══════════════════════════════════════════════════════════════════════════
-- 🔓 NGÀY MUỐN CHO HIỆN LẠI — bỏ dấu chú thích dòng dưới rồi chạy.
-- ═══════════════════════════════════════════════════════════════════════════
-- update nguoi set ngoai_o_chon = false
--  where email = 'nguoi-13@vidu.com';


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
select so, muc, ket_qua from (values
  (1, 'cột ngoai_o_chon có mặt',
      case when exists (select 1 from information_schema.columns
                         where table_schema='public' and table_name='nguoi'
                           and column_name='ngoai_o_chon')
           then '✅ có' else '❌ chưa có' end),
  (2, 'đúng MỘT người đứng ngoài ô chọn, và đó là Hương Giang',
      coalesce((select case when count(*) = 1 and min(ten) = 'Hương Giang'
                            then '✅ ' || min(ten)
                            else '❌ ' || count(*) || ' người: '
                                 || coalesce(string_agg(ten, ', '), '(không ai)') end
                  from nguoi where ngoai_o_chon), '❌ chưa chạy được')),
  (3, 'năm member chưa onboard VẪN chọn được — cờ này không lây sang họ',
      coalesce((select case when count(*) = 5 and count(*) filter (where ngoai_o_chon) = 0
                            then '✅ 5/5 vẫn mời và giao được'
                            else '❌ ' || count(*) filter (where ngoai_o_chon)
                                 || '/5 bị lọt vào cờ ô chọn' end
                  from nguoi
                 where email in ('nguoi-14@vidu.com', 'nguoi-11@vidu.com',
                                 'nguoi-16@vidu.com', 'nguoi-09@vidu.com',
                                 'nguoi-04@vidu.com')), '❌ chưa chạy được'))
) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' then 2 else 1 end, so;
