-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `tieng_chuong`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — lớp nâng cấp 🔔 CHUÔNG TỈNH THỨC
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `schema.sql`, `nang-cap-khu-vuon.sql` và
--            `nang-cap-deepwork-tu-do.sql`. Chạy lại nhiều lần không sao.
--
-- Bộ luật Tracy chốt 06/08/2026 (bản nghiên cứu: nghien-cuu-tinh-thuc-tap-trung.md):
--   · Mỗi lần nhận ra mình trôi rồi quay về = bấm 🔔 một tiếng chuông.
--     Chuông là ĐIỂM CỘNG, không bao giờ là điểm trừ — nó đánh dấu khoảnh khắc
--     tánh biết bật lên, không đánh dấu sự xao nhãng.
--   · Mỗi tiếng chuông là MỘT DÒNG RIÊNG kèm mốc giờ (không phải cột đếm).
--     Hai yêu cầu của Tracy cùng cần thiết kế này: ✕ xoá từng tiếng khi bấm
--     nhầm, và đo được khoảng cách giữa hai tiếng để biết lúc nào nên khuyên dừng.
--   · Hai LOẠI chuông:
--       tu_bam   — tự nhận ra mình trôi giữa phiên
--       tam_dung — bấm ⏸ rồi ▶ chạy tiếp; khoảnh khắc quay lại cũng là quay về
--     Cả hai cùng đếm vào tổng chuông của phiên, nhưng CHỈ `tu_bam` tham gia
--     thuật toán nhắc dừng — chủ động rời máy đi họp không phải dấu hiệu vỡ mạch.
--   · Chuông KHÔNG vào bảng vinh danh và KHÔNG so người này với người kia
--     (nguyên lý 2). Vì vậy luật đọc ở dưới hẹp hơn mọi bảng khác trong app:
--     mỗi người chỉ đọc được chuông của chính mình.
-- ============================================================================


-- ─── 1. Bảng tieng_chuong — một dòng một tiếng chuông ───────────────────────
create table if not exists tieng_chuong (
  id       bigint generated always as identity primary key,
  phien_id bigint not null references phien_deepwork (id) on delete cascade,
  nguoi_id uuid   not null references nguoi (id) on delete cascade,
  luc      timestamptz not null default now(),      -- máy chủ đóng dấu
  loai     text not null default 'tu_bam'
           check (loai in ('tu_bam', 'tam_dung'))
);

comment on table  tieng_chuong is 'Mỗi dòng = một lần người dùng nhận ra mình trôi và quay về trong một phiên deepwork. Điểm cộng, không phải điểm trừ.';
comment on column tieng_chuong.loai is 'tu_bam = tự nhận ra giữa phiên (tham gia thuật toán nhắc dừng) · tam_dung = quay lại sau khi bấm ⏸ (không tham gia).';

-- Xoá phiên là xoá chuông theo (on delete cascade) — huỷ phiên trong 30 giây
-- đầu không để lại chuông mồ côi.
create index if not exists chuong_theo_phien on tieng_chuong (phien_id, luc);
create index if not exists chuong_theo_nguoi on tieng_chuong (nguoi_id, luc);


-- ─── 2. Luật đọc/ghi — chuông là chuyện riêng của từng người ────────────────
alter table tieng_chuong enable row level security;

drop policy if exists doc_chuong on tieng_chuong;
create policy doc_chuong on tieng_chuong for select
  using (nguoi_id = nguoi_id_dang_nhap());          -- hẹp hơn la_thanh_vien(): chỉ mình thấy

drop policy if exists ghi_chuong on tieng_chuong;
create policy ghi_chuong on tieng_chuong for all
  using (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());
