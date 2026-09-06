-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hai cột `task.lich_id` và `task.lich_ngay`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — VIỆC CỦA MỘT BUỔI CỐ ĐỊNH
--                                          (Tracy duyệt phương án A, 31/08/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-lich-chung.sql` — file này bám vào `lich_chung`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn LV).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 31/08: *"bạn có coi lịch cố định mà bạn vừa làm là 1 task không? nó vẫn
-- là 1 task và mang cấu trúc có thể deep work như 1 task đó nha"*.
--
-- Bản 31/08 sáng cố ý tách buổi cố định RA KHỎI `task`. Chỗ hở lộ ra ngay ở một
-- ràng buộc có tên:
--     phien_deepwork: check (num_nonnulls(task_id, nhip_id) = 1)
--     -- "Một phiên phục vụ ĐÚNG MỘT thứ: hoặc task, hoặc nhịp."
--                                        (nang-cap-deepwork-tu-do.sql:44)
-- Buổi cố định là loại THỨ BA, nên đồng hồ deep work không nhận nó.
--
-- ─── HAI ĐƯỜNG, VÀ VÌ SAO ĐI ĐƯỜNG NÀY ──────────────────────────────────────
-- ⛔ Đường B — thêm cột thứ ba vào `phien_deepwork` rồi nới `num_nonnulls` lên
--    ba đối số. BỎ, hai lý do: ① nó là bảng NÓNG NHẤT của app, mọi lần đóng
--    phiên đều đi qua, kể cả phiên đang chạy dở trên máy đội lúc ta sửa;
--    ② nó không trả lời đúng câu Tracy hỏi — buổi họp vẫn KHÔNG phải một việc,
--    chỉ là cái đồng hồ biết thêm một loại.
--
-- ✅ Đường A — buổi ĐẺ RA một việc thật, và chỉ khi có người chạm vào. Luật lặp
--    vẫn đúng một dòng ở `lich_chung`; lượt nào có người bấm tick tham dự hoặc
--    bấm vào deep work thì lượt ấy mới sinh MỘT dòng `task` cho CHÍNH người đó.
--    Ba cái được, không cái nào nhỏ:
--      · deep work chạy nguyên bộ máy cũ — không một nhánh mã mới nào ở chỗ nóng;
--      · tường quyền không phải nới một chữ: `ghi_task` đòi
--        `nguoi_id = nguoi_id_dang_nhap()`, mà đây đúng là người ấy tự ghi dòng
--        của chính mình;
--      · kho việc không phình theo lịch, chỉ phình theo NGƯỜI THẬT SỰ LÀM.
--
-- ─── KHÔNG ĐỘNG TỚI ─────────────────────────────────────────────────────────
-- `phien_deepwork` và ràng buộc `mot_phien_mot_viec`: không một dòng nào.
-- Ba ranh giới cứng 14/08 cũng nguyên vẹn — chúng nói về `nhip` và `diem_ngay`,
-- hai thứ file này không chạm.
-- ============================================================================

begin;

-- ═══ 1. HAI CỘT NỐI MỘT VIỆC VỀ ĐÚNG MỘT LƯỢT ══════════════════════════════
-- Khoá vẫn là cặp (mã lịch + NGÀY GỐC), y như `lich_chung_ngoai_le` và
-- `lich_chung_tham_du` — ba bảng cùng một khoá thì ba bảng nói cùng một thứ
-- tiếng, và không chỗ nào phải dịch.
alter table task add column if not exists lich_id  bigint;
alter table task add column if not exists lich_ngay date;

-- `no action` chứ KHÔNG `set null`: `set null` chỉ gỡ `lich_id` mà để `lich_ngay`
-- nằm lại, tức đẻ ra đúng cái trạng thái nửa vời mà ràng buộc dưới cấm — và cấm
-- trong im lặng, vì `set null` chạy sau lưng người ta. `no action` thì Postgres
-- kêu lên khi có ai định xoá một lịch còn việc bám vào. Cũng KHÔNG `cascade`:
-- cascade ở đây là xoá một dòng lịch quét sạch giờ deep work đã ghi của cả đội.
-- Đường dọn danh sách là NGƯNG (`dang_dung = false`), không phải xoá.
alter table task drop constraint if exists task_lich_fk;
alter table task add  constraint task_lich_fk
  foreign key (lich_id) references lich_chung (id) on delete no action;

-- Hai cột đi CÙNG NHAU hoặc cùng rỗng. `<> 1` chứ không `= 0 or = 2`: cùng một
-- ý, nhưng viết thế này thì đọc ra ngay điều đang cấm là "đúng một cột có giá trị".
alter table task drop constraint if exists task_lich_du_doi;
alter table task add  constraint task_lich_du_doi
  check (num_nonnulls(lich_id, lich_ngay) <> 1);

comment on column task.lich_id is
  'Việc này sinh ra từ một buổi trên lịch chung. NULL = việc thường. Cùng với '
  'lich_ngay tạo thành khoá trỏ tới đúng MỘT lượt của luật lặp.';

-- MỘT người, MỘT buổi, MỘT lượt → đúng MỘT việc. Không có nó thì hai cú bấm
-- nhanh liên tiếp (tick rồi bấm deep work) đẻ hai dòng cho cùng một buổi, và từ
-- đó giờ deep work của buổi ấy tách làm đôi mà không ai thấy.
-- Chỉ mục RIÊNG PHẦN nên mọi việc thường (`lich_id is null`) không bị đụng.
create unique index if not exists task_moi_luot_mot_viec
  on task (nguoi_id, lich_id, lich_ngay)
  where lich_id is not null;

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả bốn dòng ═════════════════════════════
select * from (values
  (1, 'hai cột lich_id / lich_ngay có mặt trên task',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'task'
       and column_name in ('lich_id','lich_ngay')) = 2),

  (2, 'khoá ngoại task_lich_fk có mặt và KHÔNG phải cascade/set null',
   (select confdeltype from pg_constraint where conname = 'task_lich_fk') = 'a'),

  (3, 'chỉ mục chống trùng một-lượt-một-việc có mặt',
   (select count(*) from pg_indexes
     where schemaname = 'public' and indexname = 'task_moi_luot_mot_viec') = 1),

  (4, 'phien_deepwork KHÔNG bị đụng — vẫn đúng hai đường task/nhip',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'mot_phien_mot_viec')
   like '%num_nonnulls(task_id, nhip_id) = 1%')
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from task)                             as tong_viec,
  (select count(*) from task where lich_id is not null)   as viec_sinh_tu_buoi,
  (select count(*) from lich_chung where dang_dung)       as lich_dang_chay;
