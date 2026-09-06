-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `phien_deepwork.cua`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ⚠️ TRẦN PHIÊN LÀ 180 PHÚT, KHÔNG PHẢI 120 (sửa 28/08).
-- File này dựng lại BA khung nhìn `vuon_cay` · `cham_theo_ngay` · `nhip_thoi_gian`
-- — đúng ba trong năm khung nhìn mà `nang-cap-tran-180-phut.sql` đã nâng lên 180.
-- Cả hai đều dùng `create or replace view`, nên chạy file này SAU file 180 là hạ
-- trần về 120 TRONG IM LẶNG: không báo lỗi, chỉ ra số phút thiếu.
-- Bảy chỗ kẹp đã đổi sang 180. Ba con số 240 · 120 · 60 ở mệnh đề `case` là
-- NGƯỠNG XẾP NẤC (mầm · non · vừng · tán), không phải trần — giữ nguyên.

-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — lớp nâng cấp DEEPWORK TỰ DO
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `schema.sql` và `nang-cap-khu-vuon.sql`.
--            Chạy lại nhiều lần không sao (idempotent).
--
-- Bộ luật Tracy chốt 06/08/2026 (nguyên lý Speed of Light — đo thời gian thật,
-- không đóng khung năng lực ai):
--   · BỎ KHUNG 30 PHÚT. Đồng hồ đếm LÊN — bấm bắt đầu, làm tới đâu tính tới đó,
--     bấm kết thúc khi dừng. 15, 30, 45, 56 phút… đều là phiên hợp lệ.
--   · Kết thúc phiên PHẢI đi qua MỘT TRONG BA CỬA (không có kết thúc mơ hồ):
--       ✅ xong      → khai OUTPUT (bằng chứng xong) → task Done, cây ra quả
--       🔄 chua-xong → khai TIẾN ĐỘ tới hiện tại — phiên sau đọc lại là nhớ ngay
--       🚧 nghen    → khai NGHẼN Ở ĐÂU → app tạo TASK CON để gỡ nghẽn
--   · Sàn 5 phút: phiên dưới 5 phút không tính (lọc bấm nhầm). Trần đếm 120
--     phút mỗi phiên: quên bấm kết thúc thì không cộng oan cả buổi.
--   · Đo lường & vinh danh theo GIỜ THẬT (đơn vị phút), không theo block.
--   · NHỊP (việc lặp lại) cũng bấm giờ được — 1 phiên = xong, không qua cửa.
--     Giờ nhịp KHÔNG vào bảng vinh danh (số soi quy trình, không phải số thi đua)
--     — có khung nhìn riêng `nhip_thoi_gian`.
-- ============================================================================


-- ─── 1. phien_deepwork: thêm cửa ra + ghi chú + gắn được vào NHỊP ────────────
alter table phien_deepwork alter column task_id drop not null;
alter table phien_deepwork add column if not exists nhip_id bigint references nhip (id) on delete cascade;
alter table phien_deepwork add column if not exists cua     text
  check (cua in ('xong', 'chua-xong', 'nghen'));
alter table phien_deepwork add column if not exists ghi_chu text not null default '';

-- Một phiên phục vụ ĐÚNG MỘT thứ: hoặc task, hoặc nhịp.
alter table phien_deepwork drop constraint if exists mot_phien_mot_viec;
alter table phien_deepwork add constraint mot_phien_mot_viec
  check (num_nonnulls(task_id, nhip_id) = 1);

-- Chế độ 🔒 Tập trung sâu (Tracy chốt 06/08): mặc định ĐƯỢC rời trang để làm
-- việc trên máy (Sheet, Lark…) — đồng hồ vẫn chạy, quay lại app tự nối phiên.
-- Bật Tập trung sâu thì mới áp luật cũ: rời trang là phiên mất trắng.
alter table phien_deepwork add column if not exists tap_trung_sau boolean not null default false;
comment on column phien_deepwork.tap_trung_sau is 'true = phiên tự khoá: rời trang là héo. false (mặc định) = được mở cửa sổ khác làm việc.';

comment on column phien_deepwork.cua is 'Cửa ra khi kết thúc: xong (kèm Output) · chua-xong (kèm tiến độ) · nghen (kèm mô tả nghẽn, app tạo task con). Phiên nhịp không có cửa.';
comment on column phien_deepwork.ghi_chu is 'Output / tiến độ tới hiện tại / nghẽn ở đâu — tuỳ cửa. Phiên sau đọc lại để nhớ mình đã làm tới đâu.';

create index if not exists deepwork_theo_nhip on phien_deepwork (nhip_id) where nhip_id is not null;


-- ─── 2. task: nhớ task con sinh ra từ nghẽn của task nào ────────────────────
alter table task add column if not exists cha_id bigint references task (id) on delete set null;
comment on column task.cha_id is 'Task cha — dòng này là task con sinh ra để gỡ nghẽn cho task cha.';


-- ─── 3. Trigger: sàn 5 phút thay cho khung 30 phút ──────────────────────────
-- (giữ nguyên luật không sửa được giờ bắt đầu)
create or replace function kiem_cay_song()
returns trigger language plpgsql
as $$
begin
  if new.ket_qua = 'song' then
    if new.ket_thuc is null
       or new.ket_thuc - new.bat_dau < interval '4 minutes 45 seconds' then
      raise exception 'Phiên dưới 5 phút không tính — bấm nhầm thì bỏ phiên.';
    end if;
  end if;
  if new.bat_dau <> old.bat_dau then
    raise exception 'Không sửa được giờ bắt đầu';
  end if;
  return new;
end $$;
-- trigger trg_kiem_cay_song đã tồn tại từ schema.sql, hàm thay là đủ.


-- ─── 4. vuon_cay: phút THẬT (trần 120/phiên), nấc cây theo phút thật ────────
-- Bản cũ chặn mỗi phiên ở 30 phút → phạt người tập trung dài, thưởng người
-- ngắt quãng. Bỏ hẳn. (Cột giữ nguyên nên create or replace được.)
create or replace view vuon_cay as
select
  t.id                                   as task_id,
  t.nguoi_id,
  t.noi_dung                             as ten_task,
  t.tieu_diem_ma,
  t.trang_thai,
  t.ngay                                 as ngay_gieo,
  (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date as ngay_ra_qua,
  count(p.id)                            as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut,
  (max(p.ket_thuc) at time zone 'Asia/Ho_Chi_Minh')::date as ngay_cham_cuoi,
  case
    when t.trang_thai = 'Done' then 'qua'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180)) >= 240 then 'tan'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180)) >= 120 then 'vung'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180)) >=  60 then 'non'
    else 'mam'
  end                                    as nac
from task t
join phien_deepwork p on p.task_id = t.id and p.ket_qua = 'song'
group by t.id, t.nguoi_id, t.noi_dung, t.tieu_diem_ma, t.trang_thai, t.ngay, t.xong_luc;

comment on view vuon_cay is 'Một task = một cây, lớn theo TỔNG PHÚT THẬT (trần 120 phút/phiên). Phiên gắn nhịp không vào đây — vườn chỉ trồng task.';


-- ─── 5. cham_theo_ngay: phút thật + CHỈ đếm phiên task ──────────────────────
-- Giờ nhịp không vào bảng vinh danh: trộn vào thì người làm việc lặp lại
-- nhiều tự động dẫn đầu và bảng mất nghĩa.
create or replace view cham_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.task_id is not null
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;


-- ─── 6. nhip_thoi_gian: nhịp này THẬT RA tốn bao lâu ────────────────────────
-- Con số Speed of Light của việc lặp lại: trung bình bao nhiêu phút, ai nhanh
-- nhất, ai chậm nhất → chênh lệch là chỗ soi quy trình (không phải chỗ trách người).
create or replace view nhip_thoi_gian as
select
  n.ten,
  n.nguoi_id,
  count(p.id)                                       as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as tong_phut,
  round(avg(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut_trung_binh
from nhip n
join phien_deepwork p on p.nhip_id = n.id and p.ket_qua = 'song'
group by n.ten, n.nguoi_id;

comment on view nhip_thoi_gian is 'Thời gian thật của việc lặp lại, theo người. Dùng để soi quy trình — KHÔNG dùng xếp hạng.';


-- ─── 7. Khung nhìn chạy bằng quyền người gọi (giữ luật cũ) ──────────────────
alter view vuon_cay       set (security_invoker = on);
alter view cham_theo_ngay set (security_invoker = on);
alter view nhip_thoi_gian set (security_invoker = on);
