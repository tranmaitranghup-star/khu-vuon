-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: chính sách `sua_lich` trên bảng `lich_chung`
-- │ KHÔNG còn chứa chuỗi 'la_lead'.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — SỰ KIỆN: CHỈ HOST MỚI ĐỔI ĐƯỢC
--                                                  (Tracy chốt 04/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-su-kien-ca-nhan.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn HS).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 04/09: *"với các sự kiện thì chỉ có host mới có thể thay đổi thông tin
-- và thời gian"*.
--
-- Luật đang chạy (dựng 31/08) là *"người tạo HOẶC người mang cờ lead"*. Vế thứ
-- hai nghe như một lối thoát hiếm dùng, nhưng đọc cùng một dữ kiện khác thì nó
-- không hiếm chút nào: cả 7 người trong đội hôm nay đều đang bật cờ `la_lead`
-- (xem `lcChoToi` — nhóm 'coreteam' lọc đúng theo cờ ấy). Nên trên thực tế luật
-- cũ đọc ra là *ai cũng sửa và xoá được sự kiện của bất kỳ ai*, kể cả một cuộc
-- hẹn 1-1 giữa hai người khác.
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- Bỏ vế `la_lead()` khỏi BA chính sách, giữ nguyên mọi thứ còn lại:
--
--   them_lich      GIỮ NGUYÊN — ai cũng tạo được sự kiện, dưới tên mình.
--   sua_lich       → chỉ `tao_boi`
--   xoa_lich       → chỉ `tao_boi`   (ở đây là NGƯNG, xem dưới)
--   ghi_lich_ngoai → chỉ `tao_boi` của dòng lịch cha
--
-- BA CHÍNH SÁCH, KHÔNG PHẢI MỘT, vì trong app chúng là ba cửa khác nhau mà
-- người dùng gặp: nút ✏️ (sửa cả chuỗi), nút 🗑 (xoá), và cú kéo một khối sang
-- chỗ khác trên lưới — cú kéo ấy ghi xuống `lich_chung_ngoai_le` chứ không ghi
-- vào `lich_chung`. Siết hai cửa đầu mà bỏ cửa thứ ba thì một người không phải
-- host vẫn dời được buổi họp của người khác, chỉ là bằng đường khác.
--
-- QUYỀN ĐỌC KHÔNG ĐỔI — cả đội vẫn thấy mọi lịch, để còn tránh trùng giờ (lý
-- lẽ đầy đủ ở `nang-cap-lich-chung.sql` mục 5). Tracy siết quyền SỬA, không
-- siết quyền NHÌN. Bảng điểm danh có tên trong cửa buổi cũng ở lại với lead,
-- cùng lẽ ấy.
--
-- VẾ `with check` VẪN Ở LẠI trong `sua_lich`, và nó vẫn cần: `using` gác dòng
-- TRƯỚC khi sửa, `with check` gác dòng SAU khi sửa. Thiếu vế sau thì host đổi
-- được `tao_boi` sang tên người khác — tức trao quyền host đi bằng một cú sửa
-- lặng lẽ, thứ app chưa có màn nào cho phép làm tử tế.
--
-- ⚠️ MỘT HỆ QUẢ CÓ THẬT, ghi ra để không ai ngạc nhiên: người rời công ty mà
-- còn để lại sự kiện định kỳ thì KHÔNG ai sửa hay ngưng nó được nữa qua app —
-- kể cả lead. Tracy đã cân nhắc và chọn siết sạch (04/09), vì cửa ấy hiếm khi
-- cần mà lại mở suốt ngày. Lúc thật sự cần thì vào thẳng Supabase.
-- ============================================================================

begin;

-- ═══ 1. SỬA VÀ NGƯNG MỘT CHUỖI — bỏ vế lead ════════════════════════════════
drop policy if exists sua_lich on lich_chung;
create policy sua_lich on lich_chung for update
  using       (tao_boi = nguoi_id_dang_nhap())
  with check  (tao_boi = nguoi_id_dang_nhap());

drop policy if exists xoa_lich on lich_chung;
create policy xoa_lich on lich_chung for delete
  using (tao_boi = nguoi_id_dang_nhap());


-- ═══ 2. HUỶ HOẶC DỜI MỘT BUỔI LẺ — soi ngược về dòng cha ═══════════════════
-- Giữ nguyên cách soi ngược của bản cũ: ai sửa được chuỗi thì dời được một
-- buổi của nó. Chép lại luật ở đây là để hai chỗ có ngày trôi khác nhau.
drop policy if exists ghi_lich_ngoai on lich_chung_ngoai_le;
create policy ghi_lich_ngoai on lich_chung_ngoai_le for all
  using (exists (select 1 from lich_chung l
                  where l.id = lich_chung_ngoai_le.lich_id
                    and l.tao_boi = nguoi_id_dang_nhap()))
  with check (exists (select 1 from lich_chung l
                       where l.id = lich_chung_ngoai_le.lich_id
                         and l.tao_boi = nguoi_id_dang_nhap()));

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ═════════════════════════════
select * from (values
  (1, 'sua_lich còn đó và KHÔNG còn nhắc la_lead',
   (select count(*) from pg_policies
     where tablename = 'lich_chung' and policyname = 'sua_lich') = 1
   and not exists (select 1 from pg_policies
                    where tablename = 'lich_chung' and policyname = 'sua_lich'
                      and (coalesce(qual,'') || coalesce(with_check,'')) like '%la_lead%')),

  (2, 'sua_lich vẫn giữ CẢ HAI vế using và with check',
   (select with_check is not null and qual is not null from pg_policies
     where tablename = 'lich_chung' and policyname = 'sua_lich')),

  (3, 'xoa_lich còn đó và KHÔNG còn nhắc la_lead',
   (select count(*) from pg_policies
     where tablename = 'lich_chung' and policyname = 'xoa_lich') = 1
   and not exists (select 1 from pg_policies
                    where tablename = 'lich_chung' and policyname = 'xoa_lich'
                      and coalesce(qual,'') like '%la_lead%')),

  (4, 'ghi_lich_ngoai còn đó và KHÔNG còn nhắc la_lead',
   (select count(*) from pg_policies
     where tablename = 'lich_chung_ngoai_le' and policyname = 'ghi_lich_ngoai') = 1
   and not exists (select 1 from pg_policies
                    where tablename = 'lich_chung_ngoai_le'
                      and policyname = 'ghi_lich_ngoai'
                      and (coalesce(qual,'') || coalesce(with_check,'')) like '%la_lead%')),

  (5, 'quyền TẠO không bị siết theo — ai cũng còn tạo được sự kiện',
   (select count(*) from pg_policies
     where tablename = 'lich_chung' and policyname = 'them_lich') = 1),

  (6, 'quyền ĐỌC không đổi — cả đội vẫn thấy mọi lịch',
   exists (select 1 from pg_policies
            where tablename = 'lich_chung' and cmd in ('SELECT','ALL')))
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
-- Bao nhiêu sự kiện đang sống mà chủ của nó KHÔNG còn trong bảng người, hoặc
-- trống chủ. Đây đúng là những dòng mà từ nay không ai sửa được qua app.
select count(*) filter (where tao_boi is null)               as khong_co_chu,
       count(*) filter (where tao_boi is not null
                          and not exists (select 1 from nguoi n
                                           where n.id = lich_chung.tao_boi))
                                                             as chu_da_roi_bang,
       count(*)                                              as tong_su_kien_dang_dung
  from lich_chung where dang_dung;
