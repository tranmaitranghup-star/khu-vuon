-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: năm khung nhìn, tệp nào cũng viết đè được — dò bằng NỘI DUNG (có số 180 không)
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG TRẦN MỘT PHIÊN DEEPWORK: 120 → 180 PHÚT  (Tracy chốt 2026-08-12)
--
-- VÌ SAO PHẢI CÓ FILE NÀY. Trần một phiên nằm ở HAI BÊN, không chỉ trong app:
-- hằng `DW_TRAN_PHUT` bên `index.html`, và một mệnh đề `least(..., 120)` lặp
-- lại trong NĂM khung nhìn dưới đây. Sửa một bên mà quên bên kia thì người
-- ngồi 3 tiếng thấy app đếm 3 tiếng, còn vườn và bảng vinh danh ghi 2 tiếng —
-- và không dòng tự kiểm nào kêu lên, vì 180 bị kẹp thành 120 vẫn "hợp lệ".
-- Cảnh báo ấy đã dán sẵn ở `nang-cap-dem-o-may-chu.sql` từ 08/08.
--
-- CHẠY: dán trọn file này vào Supabase → SQL Editor → Run. Chạy lại nhiều lần
-- vô hại. Chạy xong nhìn bảng cuối: cột `dat` phải ĐÚNG cả sáu dòng.
--
-- ⚠️ CHẠY FILE NÀY TRƯỚC KHI ĐẨY BẢN APP MỚI. Trong quãng lệch, thà máy chủ
-- đếm rộng hơn app: giờ đã bị ghi thiếu thì không đòi lại được, còn app chưa
-- cho ngồi quá 120 thì chỉ là chưa dùng tới phần trần mới.
--
-- ⛔ KHÔNG đụng trigger `trg_kiem_cay_song`. Nó chỉ có sàn 4'45 và luật cấm
-- sửa giờ bắt đầu — không có trần nào ở đó, nên phiên 180 phút vốn đã ghi
-- xuống được. Thứ thiếu chỉ là mấy khung nhìn ĐẾM nó.
--
-- ⛔ KHÔNG đụng NẤC CÂY 30/60/120/240. Đó là TỔNG phút cộng dồn của một task
-- (mầm · non · vững · tán), khác hẳn trần MỖI PHIÊN — hai thứ chỉ tình cờ
-- cùng mang số 120. Trong `vuon_cay` dưới đây, mọi `least(..., 180)` là trần
-- phiên; mọi `>= 60 / >= 120 / >= 240` là nấc cây và giữ nguyên.
--
-- Năm khung nhìn phải đổi, và mỗi cái nuôi cái gì:
--   vuon_cay                → nấc cây trong vườn
--   cham_theo_ngay          → bảng vinh danh
--   gio_deepwork_theo_ngay  → tổng giờ, khối Tổng quan, lưới ngày
--   gio_deepwork_theo_gio   → ô GIỜ VÀNG
--   nhip_thoi_gian          → phút trung bình mỗi việc cố định
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. vuon_cay ────────────────────────────────────────────────────────────
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

comment on view vuon_cay is 'Một task = một cây, lớn theo TỔNG PHÚT THẬT (trần 180 phút/phiên). Phiên gắn nhịp không vào đây — vườn chỉ trồng task.';


-- ─── 2. cham_theo_ngay ──────────────────────────────────────────────────────
-- Giờ nhịp không vào bảng vinh danh: trộn vào thì người làm việc lặp lại
-- nhiều tự động dẫn đầu và bảng mất nghĩa. (Giữ nguyên luật đó.)
create or replace view cham_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.task_id is not null
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;

comment on view cham_theo_ngay is 'Phút deepwork của TASK gộp theo (người · ngày giờ Việt Nam), trần 180 phút mỗi phiên. Nuôi bảng vinh danh. Phiên gắn việc cố định KHÔNG vào đây.';


-- ─── 3. nhip_thoi_gian ──────────────────────────────────────────────────────
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

comment on view nhip_thoi_gian is 'Thời gian thật của việc lặp lại, theo người (trần 180 phút mỗi phiên). Dùng để soi quy trình — KHÔNG dùng xếp hạng.';


-- ─── 4. gio_deepwork_theo_ngay ──────────────────────────────────────────────
create or replace view gio_deepwork_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.ket_thuc is not null
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;

comment on view gio_deepwork_theo_ngay is
  'Giờ và số phiên deepwork gộp theo (người · ngày giờ Việt Nam). Khớp ĐÚNG hàm phutPhien() bên app: chặn 180 phút mỗi phiên, tính cả phiên gắn nhịp. Cố ý không dùng lại cham_theo_ngay vì khung nhìn đó có hai bản và cả hai đều khác ngữ nghĩa này.';


-- ─── 5. gio_deepwork_theo_gio ───────────────────────────────────────────────
-- Phiên dài được CHIA ra đúng các giờ nó thật sự diễn ra. Nâng trần ở đây có
-- một hệ quả riêng: một phiên 180 phút nay trải qua tới BỐN lát giờ thay vì
-- ba, nên ô GIỜ VÀNG đọc được cả những buổi ngồi dài.
create or replace view gio_deepwork_theo_gio as
with phien as (
  select
    p.nguoi_id,
    (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')                      as bd,
    (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')
      + least(p.ket_thuc - p.bat_dau, interval '180 minutes')        as kt
  from phien_deepwork p
  where p.ket_qua = 'song'
    and p.ket_thuc is not null
    and p.ket_thuc > p.bat_dau
),
lat as (
  -- mỗi phiên nở ra thành các LÁT một giờ; lát đầu và lát cuối bị xén theo
  -- mốc thật của phiên, các lát giữa trọn 60 phút
  select
    phien.nguoi_id,
    extract(hour from moc)::int as gio,
    phien.bd::date              as ngay,
    extract(epoch from (
      least(phien.kt, moc + interval '1 hour') - greatest(phien.bd, moc)
    )) / 60                     as phut
  from phien
  cross join lateral generate_series(
    date_trunc('hour', phien.bd),
    phien.kt - interval '1 microsecond',    -- trừ 1 micro giây để phiên kết
    interval '1 hour'                       -- thúc đúng đầu giờ không đẻ
  ) as moc                                  -- thêm một lát rỗng
)
select
  nguoi_id,
  gio,
  round(sum(phut))::int         as phut,
  count(distinct ngay)::int     as so_ngay      -- bao nhiêu ngày có làm ở khung này
from lat
where phut > 0
group by nguoi_id, gio;

comment on view gio_deepwork_theo_gio is
  'Phút deepwork gộp theo (người × giờ trong ngày, giờ Việt Nam). Phiên dài được CHIA ra đúng các giờ nó thật sự diễn ra, không dồn vào giờ bấm nút. Cùng ngữ nghĩa giờ với gio_deepwork_theo_ngay: chỉ phiên song, trần 180 phút mỗi phiên, tính cả phiên gắn nhịp. Trần cứng 24 dòng mỗi người nên không phình theo thời gian. Nuôi ô GIỜ VÀNG ở khối Tổng quan deepwork (tab Timeline).';


-- ─── 6. Bật lại quyền người gọi ─────────────────────────────────────────────
-- BẮT BUỘC. `create or replace` giữ được thiết lập cũ, nhưng đặt lại cho chắc:
-- khung nhìn chạy bằng quyền NGƯỜI TẠO là vượt mặt RLS, ai đăng nhập cũng đọc
-- được dữ liệu của mọi người.
alter view vuon_cay               set (security_invoker = on);
alter view cham_theo_ngay         set (security_invoker = on);
alter view nhip_thoi_gian         set (security_invoker = on);
alter view gio_deepwork_theo_ngay set (security_invoker = on);
alter view gio_deepwork_theo_gio  set (security_invoker = on);


-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ KIỂM — sáu dòng phải ĐÚNG hết
--
-- Dòng 1–5 hỏi thẳng định nghĩa đang sống trong máy chủ (`pg_get_viewdef`):
-- còn chữ "120" trong mệnh đề trần nghĩa là khung nhìn ấy chưa đổi. Dòng 6 đo
-- trên DỮ LIỆU THẬT — cách duy nhất bắt được chuyện đổi định nghĩa mà quên một
-- chỗ nào đó vẫn kẹp cũ.
-- ═══════════════════════════════════════════════════════════════════════════
select * from (values
  (1, 'vuon_cay kẹp 180, không còn kẹp 120',
   pg_get_viewdef('vuon_cay'::regclass) like '%180%'
     and pg_get_viewdef('vuon_cay'::regclass) not like '%60, 120%'),

  (2, 'cham_theo_ngay kẹp 180',
   pg_get_viewdef('cham_theo_ngay'::regclass) like '%180%'),

  (3, 'nhip_thoi_gian kẹp 180',
   pg_get_viewdef('nhip_thoi_gian'::regclass) like '%180%'),

  (4, 'gio_deepwork_theo_ngay kẹp 180',
   pg_get_viewdef('gio_deepwork_theo_ngay'::regclass) like '%180%'),

  /* ⚠️ KHÔNG tìm chữ "180" ở dòng này. Bốn khung nhìn trên kẹp bằng SỐ THƯỜNG
     (`least(..., 180)`) nên chữ 180 nằm nguyên trong định nghĩa; riêng khung
     nhìn này kẹp bằng INTERVAL, mà Postgres CHUẨN HOÁ interval khi lưu —
     `interval '180 minutes'` được ghi lại thành `'03:00:00'::interval`, chữ
     "180" biến mất dù kẹp vẫn đúng ba tiếng. Bản đầu của file này tìm "180" ở
     đây nên báo FALSE ngay lần chạy đầu tiên (Tracy gặp 12/08) trong khi khung
     nhìn hoàn toàn đúng.
     Phép thử quyết định là VẾ SAU: bản cũ kẹp 120 phút thì deparse ra
     `'02:00:00'`. Còn thấy nó tức là khung nhìn chưa đổi thật. */
  (5, 'gio_deepwork_theo_gio kẹp 3 tiếng, không còn kẹp 2 tiếng',
   pg_get_viewdef('gio_deepwork_theo_gio'::regclass) like '%03:00:00%'
     and pg_get_viewdef('gio_deepwork_theo_gio'::regclass) not like '%02:00:00%'),

  (6, 'Không ngày nào vượt 180 phút mỗi phiên (đo trên dữ liệu thật)',
   coalesce((select bool_and(g.phut <= 180 * g.so_phien)
               from gio_deepwork_theo_ngay g), true))
) as t(so, muc, dat);
