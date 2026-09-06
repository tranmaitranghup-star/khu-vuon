-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ KHÔNG THUỘC SỔ — tệp này không nâng cấp gì: chỉ dựng lại chính sách `doc_task` — dò ở khối ② của sổ.
-- │ Chạy lúc nào cũng được, chạy lại cũng được.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- VÁ SAU ĐỢT SOI NGÀY 2026-08-08 — ba lỗi ở tầng máy chủ
-- Tracy chốt "vá hết đi" ngày 08/08.
--
-- Đợt soi 5 lăng kính, 34 tác tử, mỗi phát hiện có một tác tử riêng cố bác bỏ.
-- Ba mục dưới đây thuộc nhóm C và B, là phần KHÔNG sửa được bằng giao diện.
-- Bản đầy đủ 20 phát hiện: soi-app-20-phat-hien.md
--
-- Chạy được nhiều lần, không hỏng gì.
-- Chạy SAU: nang-cap-cam-ket-va-muc-tieu.sql
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Luật "ba cam kết là hết chỗ" đang phá được bằng `luong = null` ──────
-- (đợt soi, mục 9 — nhóm C, mức nặng)
--
-- Hai hàng rào giữ luật này đều TỰ LOẠI BỎ dòng có luong rỗng:
--   · ràng buộc `luong_trong_khoang_1_3` viết `luong is null or luong between 1 and 3`
--     → rỗng đi qua tự do
--   · chỉ mục `mot_hat_song_moi_luong` soi cặp (nguoi_id, luong)
--     → hai dòng cùng rỗng KHÔNG bị coi là trùng nhau, vì trong SQL
--       `null = null` cho ra null chứ không phải đúng
-- Cộng lại: một người gọi thẳng API, đặt luong rỗng, là tạo được bao nhiêu cam
-- kết tuỳ ý. Bộ tự kiểm 13 mục cũng không bắt được vì nó soi đúng cái chỉ mục
-- đã tự loại trường hợp này.
--
-- Vá gốc: cấm rỗng hẳn. Đã kiểm trên máy chủ trước khi viết — 7 dòng hiện có,
-- 0 dòng rỗng, nên lệnh này không làm hỏng dữ liệu nào.
alter table tieu_diem alter column luong set not null;

alter table tieu_diem drop constraint if exists luong_trong_khoang_1_3;
alter table tieu_diem add  constraint luong_trong_khoang_1_3
  check (luong between 1 and 3);

comment on column tieu_diem.luong is
  'Chỗ ngồi 1-3. BẮT BUỘC có. Người dùng không còn nhìn thấy con số này (từ 08/08 giao diện đếm thứ tự nhận), nhưng nó là thứ giữ luật ba cam kết là hết chỗ.';


-- ─── 2. Kho việc của mỗi người đang để cả đội đọc ───────────────────────────
-- (đợt soi, mục 10 — nhóm C, mức nặng)
--
-- Policy `doc_task` cho mọi thành viên đọc TOÀN BỘ bảng task. Giao diện có ý
-- thức che: khối việc phát sinh chỉ vẽ khi xem của mình. Nhưng khoá công khai
-- nằm ngay trong mã nguồn trang web, ai mở app cũng đọc được, nên hàng rào
-- thật phải nằm ở đây.
--
-- Kho là chỗ người ta ghi việc CHƯA CHÍN — thứ đã nghĩ ra nhưng chưa hẹn ngày,
-- và chưa chắc muốn ai biết.
--
-- Cách chọn: giữ nguyên tinh thần "cả đội nhìn thấy việc của nhau" cho việc đã
-- lên lịch, chỉ đóng lại phần chưa hẹn ngày. Đây là ranh giới tự nhiên: hẹn
-- ngày = đã nhận làm, công khai được; chưa hẹn ngày = còn đang nghĩ.
drop policy if exists doc_task on task;
create policy doc_task on task for select
  using (
    la_thanh_vien()
    and (ngay is not null or nguoi_id = nguoi_id_dang_nhap())
  );

comment on policy doc_task on task is
  'Cả đội đọc việc ĐÃ hẹn ngày. Việc còn trong kho (ngay rỗng) chỉ chủ đọc được.';


-- ─── 3. Mục 11 của bộ tự kiểm sai vĩnh viễn ────────────────────────────────
-- (đợt soi, mục 8 và 11 — hai lăng kính độc lập cùng chỉ ra)
--
-- File `nang-cap-cam-ket-va-muc-tieu.sql` tự khai ở đầu là chạy lại nhiều lần
-- không sao, nhưng mục 11 của bộ tự kiểm lại bắt:
--     (select count(*) from task where ngay is null) = 0
-- Câu đó chỉ đúng ở LẦN CHẠY ĐẦU, lúc soi xem lệnh `drop not null` có làm hỏng
-- dữ liệu cũ không. Từ lần thứ hai trở đi nó soi nhầm: task có ngay rỗng CHÍNH
-- LÀ thứ tính năng kho sinh ra. Chạy lại file sau khi đội đã dùng kho là gặp
-- "❌ CHƯA ĐẠT" giả, mà đầu bộ kiểm lại dặn có ❌ thì đừng mở app.
--
-- Không sửa được bằng SQL — phải sửa chính file kia. ĐÃ SỬA: mục 11 nay soi
-- "cột ngay cho phép rỗng" thay vì "chưa có dòng nào rỗng".
-- Mục này để lại đây làm dấu vết, không có lệnh nào chạy.


-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — đọc cột ket_qua, mọi dòng phải ✅
-- ═══════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'tieu_diem.luong đã CẤM rỗng',
   (select is_nullable = 'NO' from information_schema.columns
     where table_name = 'tieu_diem' and column_name = 'luong')),

  (2, 'Ràng buộc luong 1-3 không còn nhánh cho rỗng đi qua',
   exists (select 1 from pg_constraint
             where conrelid = 'tieu_diem'::regclass
               and conname = 'luong_trong_khoang_1_3'
               and pg_get_constraintdef(oid) not ilike '%is null%')),

  (3, 'Không dòng cam kết nào có luong rỗng',
   (select count(*) from tieu_diem where luong is null) = 0),

  /* ⚠️ MỤC NÀY ĐÃ ĐỔI NGHĨA NGÀY 17/08 — đừng trả lại bản cũ.
     Bản gốc đòi `qual ilike '%nguoi_id_dang_nhap%'`, tức đòi `doc_task` phải
     soi chủ cho việc trong kho. Tracy chốt 17/08 MỞ KHO cho cả đội
     (`nang-cap-gio-deepwork-theo-loai.sql` mục 1), nên vế ấy nay sai theo đúng
     chủ ý — để nguyên là mỗi lần chạy lại file này in ra một ❌ giả.
     Chính file này, ở mục 11 ngay phía trên, đã kể một ca y hệt: một dòng tự
     kiểm sai vĩnh viễn làm người chạy tưởng app hỏng. Không tái phạm.
     Nay soi thứ vẫn còn đúng: policy phải TỒN TẠI (mất nó là cả đội không đọc
     được việc của nhau) và phải soi tư cách thành viên. */
  (4, 'Policy doc_task còn sống và còn soi tư cách thành viên (kho MỞ từ 17/08)',
   exists (select 1 from pg_policies where tablename = 'task'
             and policyname = 'doc_task'
             and qual ilike '%la_thanh_vien%')),

  (5, 'task vẫn bật hàng rào RLS',
   (select rowsecurity from pg_tables
     where schemaname = 'public' and tablename = 'task')),

  (6, 'Cột task.ngay VẪN cho phép rỗng (kho còn chạy)',
   (select is_nullable = 'YES' from information_schema.columns
     where table_name = 'task' and column_name = 'ngay'))
)
select thu_tu, case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua, muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt ────────────────────────────────────────────────────
-- ① Thử phá luật ba chỗ (phải BÁO LỖI, không được chạy lọt):
--    insert into tieu_diem (ma, ten, luong, nguoi_id)
--    values ('TEST', 'thử', null, (select id from nguoi limit 1));
-- ② Xem ai đang giữ mấy chỗ:
--    select nguoi_id, count(*) from tieu_diem where not xong group by 1;
