-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `tieu_diem.luong`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — lớp nâng cấp hình tượng vườn
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `schema.sql`. Chạy lại nhiều lần không sao (idempotent).
--
-- ⛔ ĐÚNG THỨ TỰ MỚI CHẠY LẠI: file này định nghĩa `vuon_cay` và `cham_theo_ngay`
--    với TRẦN 30 PHÚT MỖI PHIÊN — bản deepwork 30 phút cố định thời đầu.
--    `nang-cap-deepwork-tu-do.sql` (06/08) ghi đè hai khung nhìn đó bằng bản
--    TRẦN 120 PHÚT. Nếu chạy lại file này SAU nó, giờ deepwork của cả đội sẽ bị
--    thu về 30 phút mỗi phiên mà không báo lỗi gì. Chạy lại file này thì phải
--    chạy lại `nang-cap-deepwork-tu-do.sql` ngay sau đó.
--
-- Bộ luật Tracy chốt 06/08/2026:
--   · Gieo hạt = một O (kết quả lớn) · tưới nước & làm cỏ = nhịp ngày
--     · trồng cây = deepwork
--   · Vườn chỉ có BA LUỐNG. Xong một O mới có chỗ gieo O mới.
--   · MỘT TASK = MỘT CÂY. Cây lớn theo TỔNG giờ deepwork đổ vào task đó.
--     Task chuyển Done → cây ngừng lớn và RA QUẢ.
--   · Mỗi O một loài cây riêng (quả riêng, màu riêng).
--   · Hai bảng vinh danh, KHÔNG gộp thành một điểm tổng:
--       🍎 Ngày gặt bội thu     — đếm quả (kết quả)
--       💧 Người làm vườn chăm chỉ — đếm giờ (nỗ lực)
--   · Chốt chặn: một cây chỉ được tính quả nếu ĐÃ CÓ ít nhất một phiên
--     deepwork thật. Không có chuyện tick Done hàng loạt việc vặt rồi lên bảng.
--
-- Chưa làm ở bản này (Tracy hoãn): định mức giờ theo loại cây · cỏ dại.
-- ============================================================================


-- ─── 1. tieu_diem: từ "O1…O10 phẳng" thành BA LUỐNG ĐẤT có loài cây ─────────
alter table tieu_diem add column if not exists luong         smallint;
alter table tieu_diem add column if not exists qua           text not null default '🍎';
alter table tieu_diem add column if not exists mau           text not null default '#e05d5d';
alter table tieu_diem add column if not exists ten_loai      text not null default '';
alter table tieu_diem add column if not exists tieu_chi_xong text not null default '';
alter table tieu_diem add column if not exists xong          boolean not null default false;
alter table tieu_diem add column if not exists ngay_gieo     date;
alter table tieu_diem add column if not exists ngay_xong     date;
alter table tieu_diem add column if not exists nguoi_tick    uuid references nguoi (id);

comment on column tieu_diem.luong is 'Luống đất 1–3. Mỗi luống CHỈ MỘT hạt đang sống.';
comment on column tieu_diem.tieu_chi_xong is 'Xong là xong cái gì — người gieo tự khai lúc gieo, đo được.';
comment on column tieu_diem.nguoi_tick is 'Ai tick xong. Cả đội tick được, không riêng người gieo.';

-- Ba luống mặc định. Loài cây gắn theo luống để khỏi phải chọn tay,
-- nhưng lưu trên từng hạt — hạt sau gieo vào cùng luống vẫn giữ được loài riêng.
update tieu_diem set luong = 1, qua = '🍎', mau = '#e05d5d', ten_loai = 'Cây táo'
  where ma = 'O1' and luong is null;
update tieu_diem set luong = 2, qua = '🍊', mau = '#e8b34b', ten_loai = 'Cây cam'
  where ma = 'O2' and luong is null;
update tieu_diem set luong = 3, qua = '🍇', mau = '#a97bd6', ten_loai = 'Giàn nho'
  where ma = 'O3' and luong is null;

-- Dọn O4…O10 — chỉ bỏ những O CHƯA có task nào trỏ vào (không làm mất dữ liệu).
delete from tieu_diem o
where o.luong is null
  and not exists (select 1 from task t where t.tieu_diem_ma = o.ma);

-- Luật "xong một O mới có chỗ gieo O mới" — cưỡng chế ở tầng cơ sở dữ liệu,
-- không phải chỉ nhắc bằng chữ trên màn hình.
--
-- ⛔ CÂU NÀY ĐÃ CHẾT — cố ý để lại làm dấu, ĐỪNG BỎ DẤU CHÚ THÍCH.
--    Nó thuộc thời luống còn là của CHUNG công ty: cả đội gộp lại chỉ có ba
--    luống, nên chỉ mục chỉ soi (luong). Từ 06/08 mỗi người có ba luống riêng,
--    bản đúng là `mot_hat_song_moi_luong` on (nguoi_id, luong) trong
--    `nang-cap-luong-rieng-tung-nguoi.sql`.
--    Để câu này chạy lại là cả đội kẹt: người thứ hai gieo hạt sẽ đụng hạt của
--    người thứ nhất và nhận lỗi 23505 "luống đang có hạt sống rồi", trong khi
--    luống của họ trống trơn. Đúng lỗi Tracy gặp 08/08 với Andy.
--    Lỡ chạy rồi thì chạy `va-luong-cheo-nhau.sql` để gỡ.
-- create unique index if not exists mot_hat_moi_luong
--   on tieu_diem (luong) where not xong;

-- Không cho tick xong khi chưa khai tiêu chí xong.
create or replace function kiem_o_xong()
returns trigger language plpgsql
as $$
begin
  if new.xong and not coalesce(old.xong, false) then
    if length(trim(coalesce(new.tieu_chi_xong, ''))) = 0 then
      raise exception 'Chưa khai tiêu chí xong thì chưa tick xong được';
    end if;
    new.ngay_xong := coalesce(new.ngay_xong, hom_nay());
  end if;
  return new;
end $$;
drop trigger if exists trg_kiem_o_xong on tieu_diem;
create trigger trg_kiem_o_xong before update on tieu_diem
  for each row execute function kiem_o_xong();


-- ─── 2. vuon_cay: MỘT TASK = MỘT CÂY, lớn theo tổng phút ────────────────────
-- Bản cũ: một phiên 30 phút = một cây, lưới vẽ lại theo từng ngày → vườn dọn
-- sạch mỗi sáng. Bản này cây tích luỹ, không bao giờ về không.
drop view if exists vuon_cay;
create view vuon_cay as
select
  t.id                                   as task_id,
  t.nguoi_id,
  t.noi_dung                             as ten_task,
  t.tieu_diem_ma,
  t.trang_thai,
  t.ngay                                 as ngay_gieo,
  (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date as ngay_ra_qua,
  count(p.id)                            as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 30))) as phut,
  (max(p.ket_thuc) at time zone 'Asia/Ho_Chi_Minh')::date as ngay_cham_cuoi,
  case
    when t.trang_thai = 'Done' then 'qua'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 30)) >= 240 then 'tan'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 30)) >= 120 then 'vung'
    when sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 30)) >=  60 then 'non'
    else 'mam'
  end                                    as nac
from task t
join phien_deepwork p on p.task_id = t.id and p.ket_qua = 'song'
group by t.id, t.nguoi_id, t.noi_dung, t.tieu_diem_ma, t.trang_thai, t.ngay, t.xong_luc;

comment on view vuon_cay is 'Một task = một cây. Chỉ task ĐÃ CÓ phiên deepwork thật mới mọc thành cây — đây là chốt chặn để không ai tick Done hàng loạt việc vặt rồi lên bảng gặt.';


-- ─── 3. Bảng vinh danh 1: 🍎 NGÀY GẶT BỘI THU (kết quả) ─────────────────────
create or replace view gat_theo_ngay as
select nguoi_id, ngay_ra_qua as ngay, count(*) as so_qua
from vuon_cay
where nac = 'qua' and ngay_ra_qua is not null
group by nguoi_id, ngay_ra_qua;

-- ─── 4. Bảng vinh danh 2: 💧 NGƯỜI LÀM VƯỜN CHĂM CHỈ (nỗ lực) ───────────────
create or replace view cham_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 30))) as phut
from phien_deepwork p
where p.ket_qua = 'song'
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;


-- ─── 5. Tiến độ ba O — ĐÃ DỜI SANG FILE KHÁC, đừng dựng lại ở đây ───────────
-- ⛔ Định nghĩa `tien_do_o` từng nằm ngay chỗ này. Nó THIẾU hai cột `nguoi_id`
-- và `han` — hai cột mà app đang lọc và đọc. Postgres không cho `create or
-- replace view` bỏ cột, nên lần chạy file này câu đó đã BÁO LỖI và khung nhìn
-- cũ được giữ nguyên; app chạy được là nhờ vậy, chứ không phải nhờ câu này đúng.
--
-- Ai chạy lại file này về sau mà câu đó còn đây thì hoặc script gãy giữa chừng,
-- hoặc tệ hơn: nếu khung nhìn đã bị xoá trước đó, nó dựng lại BẢN THIẾU CỘT và
-- app vỡ. Nên gỡ hẳn ra thay vì để lại làm bẫy. Đợt soi 08/08 chỉ ra chỗ này.
--
-- ✅ Định nghĩa ĐÚNG và DUY NHẤT của `tien_do_o` nay ở `nang-cap-dem-o-may-chu.sql`
--    (đủ cột cũ + nguoi_id + han + ba cột đếm so_task/so_xong/so_kho).
--    Cần dựng lại khung nhìn thì chạy file đó.


-- ─── 6. Khung nhìn chạy bằng quyền người gọi (giữ nguyên luật cũ) ───────────
alter view vuon_cay       set (security_invoker = on);
alter view gat_theo_ngay  set (security_invoker = on);
alter view cham_theo_ngay set (security_invoker = on);
-- Dòng dưới chỉ ĐẶT LẠI thuộc tính, không dựng khung nhìn. Nó cần `tien_do_o`
-- đã tồn tại — tức `nang-cap-dem-o-may-chu.sql` phải chạy trước file này nếu
-- dựng lại kho từ đầu. Giữ lại vì nó khẳng định đúng cái luật ⑨ trong bộ tự kiểm.
alter view tien_do_o      set (security_invoker = on);


-- ─── 7. Phân quyền: CẢ ĐỘI gieo hạt và tick O xong được ─────────────────────
-- ✅ Tracy chốt 06/08: "O xong nếu mọi người tick là xong rồi."
-- Hiểu theo nghĩa nhẹ nhất: ai trong đội cũng tick được, không riêng người gieo.
-- Muốn chặt hơn (phải đủ N người xác nhận) thì làm thêm bảng xác nhận sau.
drop policy if exists ghi_tieudiem on tieu_diem;
create policy ghi_tieudiem on tieu_diem for all
  using (la_thanh_vien()) with check (la_thanh_vien());
