-- ⛔ TỆP CŨ — ĐỪNG CHẠY LẠI MỘT MÌNH (dán 07/09) ─────────────────────────────
-- Tệp này còn giữ vế `la_lead()` trong ba policy `sua_lich` · `xoa_lich` · `ghi_lich_ngoai`, tức bản luật TRƯỚC ngày
-- 04/09 khi Tracy siết quyền sửa sự kiện về HOST. Chạy lại nó là lặng lẽ mở
-- lại cánh cửa ấy, và không một dòng lỗi nào báo.
-- Phải chạy thì chạy KÈM, theo đúng thứ tự, ngay sau nó:
--     nang-cap-quyen-host-su-kien.sql  →  nang-cap-quyen-khach.sql
--     →  nang-cap-doi-gio-viec-ca-doi.sql
-- Rồi soi lại bằng `SO-SQL.sql`: bốn dòng "sự kiện: … chỉ host" phải ✅.
-- Cũng đừng CHÉP policy từ tệp này sang tệp mới — một tệp .sql là ảnh chụp của
-- một ngày, không phải trạng thái hôm nay. Đọc bản đang chạy:
--     select policyname, qual from pg_policies where tablename = 'lich_chung';
-- ─────────────────────────────────────────────────────────────────────────────

-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.nguoi_ids` (mảng uuid), và
-- │ ràng buộc `lich_pham_vi_hop_le` có chứa chữ 'ca_nhan'.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — SỰ KIỆN MỜI ĐÍCH DANH, VÀ AI CŨNG TẠO ĐƯỢC
--                                                  (Tracy chốt 31/08/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-nhom-nhan-lich.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn SK).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 31/08: *"tính năng tạo lịch này tôi muốn mở rộng cho việc tạo lịch cá
-- nhân với cá nhân"* — ấn nút + sự kiện thì mời thêm được NGƯỜI, chứ không chỉ
-- chọn được một nhóm. Ô mời hiện cả tên từng cá nhân lẫn sáu nhóm đã chốt.
--
-- Hai chỗ kho hiện tại không đáp được:
--   ① Phạm vi chỉ nói được theo NHÓM (cả công ty · khối · coreteam). Không có
--      chỗ nào ghi "sự kiện này dành cho đúng hai người tên A và B".
--   ② Quyền ghi `lich_chung` đang là *chỉ lead*. Mà một cuộc hẹn 1-1 giữa hai
--      người thường thì không có lead nào đứng ra tạo hộ.
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- ① Một cột MẢNG NGƯỜI, đi đúng lối `chuc_nang_ids` đã đi (Tracy chọn phương
--    án A: không dựng bảng thứ hai). Người nhận sự kiện = NHÓM cộng CÁ NHÂN:
--        pham_vi = 'cong_ty'  → mọi người        ┐
--        pham_vi = 'khoi'     → ai thuộc khối    ├ cộng thêm mọi người có tên
--        pham_vi = 'coreteam' → ai mang cờ lead  ┘ trong `nguoi_ids`
--        pham_vi = 'ca_nhan'  → CHỈ những người có tên trong `nguoi_ids`
--    Người TẠO luôn nằm trong danh sách — máy khách tự cộng vào, không cần một
--    ràng buộc riêng canh chuyện đó.
--
--    VÌ SAO MẢNG CHỨ KHÔNG BẢNG RIÊNG: đội có 12 người, nên danh sách mời dài
--    nhất cũng 12 phần tử. Để nó nằm ngay trên dòng sự kiện thì mỗi lượt vẽ
--    lịch KHÔNG phải hỏi thêm một câu nữa (`lcLay` đang chạy đúng ba câu song
--    song). Đổi lại: không có khoá ngoại thật, nên người rời công ty vẫn còn
--    tên trong mảng — chấp nhận được, vì đó là sự thật lịch sử của sự kiện ấy.
--
-- ② Quyền tách làm hai nấc, thay cho một nấc "chỉ lead":
--        TẠO  → ai cũng được, nhưng chỉ tạo dưới tên mình (`tao_boi`).
--        SỬA · NGƯNG · HUỶ MỘT BUỔI → người TẠO ra nó, hoặc lead.
--    Nấc cũ chặn cả việc một người thường tự hẹn lịch với đồng nghiệp; nấc mới
--    mở đúng cửa ấy mà không mở cửa "sửa lịch của người khác".
-- ============================================================================

begin;

-- ═══ 1. CỘT MỚI ════════════════════════════════════════════════════════════
alter table lich_chung add column if not exists nguoi_ids uuid[] not null default '{}';

comment on column lich_chung.nguoi_ids is
  'Những người được mời ĐÍCH DANH vào sự kiện này, cộng thêm vào nhóm mà pham_vi '
  'chỉ ra. Rỗng là sự kiện thuần theo nhóm. Khi pham_vi = ''ca_nhan'' thì đây là '
  'TOÀN BỘ danh sách người nhận. Không có khoá ngoại: người rời công ty vẫn còn '
  'tên ở đây, và đó là sự thật lịch sử của sự kiện, không phải rác.';


-- ═══ 2. PHẠM VI NHẬN THÊM GIÁ TRỊ THỨ TƯ ═══════════════════════════════════
alter table lich_chung drop constraint if exists lich_pham_vi_hop_le;
alter table lich_chung add  constraint lich_pham_vi_hop_le
  check (pham_vi in ('cong_ty', 'khoi', 'coreteam', 'ca_nhan'));

-- Hai chiều, như ràng buộc cũ đã làm với khối: lịch khối PHẢI có khối và lịch
-- không-khối PHẢI trống khối; nay thêm vế thứ ba — sự kiện cá nhân PHẢI có ít
-- nhất một người, nếu không nó là một sự kiện không ai nhận được.
alter table lich_chung drop constraint if exists lich_pham_vi_khop;
alter table lich_chung add  constraint lich_pham_vi_khop check (
  ((pham_vi =  'khoi' and coalesce(array_length(chuc_nang_ids,1),0) >= 1) or
   (pham_vi <> 'khoi' and coalesce(array_length(chuc_nang_ids,1),0) =  0))
  and
  (pham_vi <> 'ca_nhan' or coalesce(array_length(nguoi_ids,1),0) >= 1));


-- ═══ 3. QUYỀN GHI — hai nấc thay cho một ═══════════════════════════════════
-- Nấc cũ `ghi_lich` là một chính sách `for all` gói cả bốn phép vào một câu
-- `la_lead()`. Bỏ nó rồi tách ra, vì TẠO và SỬA nay không còn cùng một câu trả
-- lời: ai cũng tạo được sự kiện của mình, nhưng sửa thì phải là chủ của nó.
drop policy if exists ghi_lich on lich_chung;
drop policy if exists them_lich on lich_chung;
drop policy if exists sua_lich  on lich_chung;
drop policy if exists xoa_lich  on lich_chung;

-- TẠO: bất kỳ thành viên nào, nhưng `tao_boi` phải là chính mình. Gửi tên
-- người khác lên là bị chặn tại chỗ, chứ không âm thầm ghi vào sổ một dòng
-- mang tên người không tạo nó.
create policy them_lich on lich_chung for insert
  with check (la_thanh_vien() and tao_boi = nguoi_id_dang_nhap());

-- SỬA và NGƯNG: chủ của sự kiện, hoặc lead. Vế `with check` chặn luôn cú đổi
-- `tao_boi` sang người khác — sửa nội dung thì được, sang tên thì không.
create policy sua_lich on lich_chung for update
  using       (la_lead() or tao_boi = nguoi_id_dang_nhap())
  with check  (la_lead() or tao_boi = nguoi_id_dang_nhap());

create policy xoa_lich on lich_chung for delete
  using (la_lead() or tao_boi = nguoi_id_dang_nhap());


-- ═══ 4. HUỶ MỘT BUỔI — theo chủ của sự kiện, không theo cờ lead ════════════
-- `lich_chung_ngoai_le` là chỗ ghi "buổi ngày ấy không diễn ra". Ai sửa được
-- sự kiện thì huỷ được một buổi của nó — cùng một câu trả lời, nên soi ngược
-- về dòng cha thay vì chép lại luật.
drop policy if exists ghi_lich_ngoai on lich_chung_ngoai_le;
create policy ghi_lich_ngoai on lich_chung_ngoai_le for all
  using (la_lead() or exists (
           select 1 from lich_chung l
            where l.id = lich_chung_ngoai_le.lich_id
              and l.tao_boi = nguoi_id_dang_nhap()))
  with check (la_lead() or exists (
           select 1 from lich_chung l
            where l.id = lich_chung_ngoai_le.lich_id
              and l.tao_boi = nguoi_id_dang_nhap()));

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả năm dòng ═════════════════════════════
select * from (values
  (1, 'cột nguoi_ids có mặt, kiểu mảng uuid',
   (select data_type || '/' || coalesce(udt_name,'') from information_schema.columns
     where table_schema = 'public' and table_name = 'lich_chung'
       and column_name = 'nguoi_ids') = 'ARRAY/_uuid'),

  (2, 'phạm vi nhận đủ bốn giá trị, có ca_nhan',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_pham_vi_hop_le') like '%ca_nhan%'),

  (3, 'ràng buộc khớp có nhắc nguoi_ids',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_pham_vi_khop') like '%nguoi_ids%'),

  (4, 'ba chính sách ghi mới đã thay chính sách gộp cũ',
   (select count(*) from pg_policies
     where tablename = 'lich_chung'
       and policyname in ('them_lich','sua_lich','xoa_lich')) = 3
   and not exists (select 1 from pg_policies
                    where tablename = 'lich_chung' and policyname = 'ghi_lich')),

  (5, 'không dòng nào rơi vào trạng thái nửa vời',
   not exists (select 1 from lich_chung
                where pham_vi = 'ca_nhan'
                  and coalesce(array_length(nguoi_ids,1),0) = 0))
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select pham_vi,
       count(*)                                            as so_su_kien,
       sum(coalesce(array_length(nguoi_ids,1),0))          as tong_luot_moi_dich_danh
  from lich_chung group by pham_vi order by pham_vi;
