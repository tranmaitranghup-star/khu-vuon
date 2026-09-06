-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `tieu_diem.han`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — TRẢ LUỐNG VỀ CHO TỪNG NGƯỜI
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `nang-cap-khu-vuon.sql`. Chạy lại nhiều lần không sao.
--
-- ⛔ LỖI FILE NÀY SỬA (Tracy phát hiện 06/08, khi Andy đăng nhập):
--    Bảng `tieu_diem` sinh ra thời còn là "O1…O10 — mục tiêu CHUNG của công ty"
--    nên KHÔNG có cột chủ sở hữu, và policy `ghi_tieudiem` cho MỌI thành viên
--    sửa MỌI dòng. Khi đổi sang hình tượng BA LUỐNG CÁ NHÂN thì phần hiển thị
--    đổi nhưng phần sở hữu không đổi theo → cả đội nhìn chung một bộ ba luống,
--    Andy đổi tên luống 1 là đổi luôn của Tracy.
--    `nhip` · `task` · `phien_deepwork` đều đã có `nguoi_id` từ đầu — chỉ mỗi
--    bảng này thiếu.
--
-- Tracy chốt 06/08 (duyệt cả ba mặc định):
--   ① Chỉ CHỦ LUỐNG được tick hạt về đích. Luật cũ "cả đội tick được" sinh ra
--      khi luống còn dùng chung, nay không còn hợp.
--   ② Mọi hạt đang có gán hết cho Tracy.
--   ③ Vườn "Cả ROVA": mỗi người một nông trại với ba luống của chính họ.
-- ============================================================================


-- ─── 1. Cột chủ sở hữu ──────────────────────────────────────────────────────
alter table tieu_diem add column if not exists nguoi_id uuid references nguoi (id) on delete cascade;


-- ─── 1b. Hạn của hạt (Tracy chốt 06/08, cùng đợt đổi nhãn form gieo) ────────
-- Ba ô khi gieo hạt: Cam kết của bạn (cột `ten`) · Output đầu ra
-- (cột `tieu_chi_xong`) · Deadline (cột này). Ngày thật, không phải chữ như
-- `task.deadline` — hạt sống nhiều tuần nên cần so được với hôm nay.
alter table tieu_diem add column if not exists han date;
comment on column tieu_diem.han is 'Hạn của hạt. NULL = chưa đặt hạn (không ép).';


-- ─── 2. Dọn dòng mồi O1…O10 chưa ai dùng ────────────────────────────────────
-- Mười dòng trống sinh ra từ `schema.sql`. Chỉ xoá dòng nào CHƯA gieo (không
-- tên, không luống) và KHÔNG có task nào trỏ vào — dòng có task thì giữ,
-- xoá là task mất chỗ bám.
delete from tieu_diem o
 where o.luong is null
   and coalesce(o.ten, '') = ''
   and not exists (select 1 from task t where t.tieu_diem_ma = o.ma);


-- ─── 3. Gán chủ cho các hạt đang có → Tracy ─────────────────────────────────
-- Dừng hẳn nếu không tìm thấy Tracy trong bảng `nguoi`: thà báo lỗi to còn hơn
-- gán bừa rồi cả đội mất luống.
do $$
declare id_tracy uuid;
begin
  select id into id_tracy from nguoi where email = 'tracy@vidu.com';
  if id_tracy is null then
    raise exception 'Không tìm thấy Tracy trong bảng nguoi — kiểm lại email trước khi chạy tiếp.';
  end if;
  update tieu_diem set nguoi_id = id_tracy where nguoi_id is null;
end $$;

-- Từ đây mọi hạt bắt buộc có chủ. Câu này mà báo lỗi nghĩa là còn dòng vô chủ
-- → dừng lại xem dòng nào, đừng bỏ qua.
alter table tieu_diem alter column nguoi_id set not null;


-- ─── 4. Mã hạt do MÁY CHỦ sinh, app không đoán nữa ──────────────────────────
-- Trước đây app tự tính 'O' + (số lớn nhất nó NHÌN THẤY + 1). Khi mỗi người
-- chỉ nhìn thấy luống của mình, hai người gieo cùng lúc sẽ cùng ra 'O4' và
-- đụng khoá chính. Đẩy việc sinh mã xuống máy chủ là hết đụng.
create sequence if not exists tieu_diem_so;
select setval('tieu_diem_so',
  greatest(coalesce((select max(nullif(regexp_replace(ma, '\D', '', 'g'), '')::int) from tieu_diem), 0), 10));
alter table tieu_diem alter column ma set default 'O' || nextval('tieu_diem_so');


-- ─── 5. Một người, một luống, một hạt đang sống ─────────────────────────────
-- Giữ luật "ba luống là hết đất" ở tầng dữ liệu, không chỉ ở giao diện.
-- Hạt đã thu hoạch (xong = true) không tính, nên thu xong là gieo lại được.
create unique index if not exists mot_hat_song_moi_luong
  on tieu_diem (nguoi_id, luong) where not xong and luong is not null;


-- ─── 6. Phân quyền: đọc cả đội · ghi của mình ───────────────────────────────
-- Xem vườn nhau là chuyện tốt (đó là cả ý nghĩa của vườn chung). Sửa vườn
-- nhau thì không.
drop policy if exists ghi_tieudiem on tieu_diem;   -- policy cũ: ai cũng sửa được tất

drop policy if exists them_tieudiem on tieu_diem;
create policy them_tieudiem on tieu_diem for insert
  with check (nguoi_id = nguoi_id_dang_nhap());

drop policy if exists sua_tieudiem on tieu_diem;
create policy sua_tieudiem on tieu_diem for update
  using (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());

drop policy if exists xoa_tieudiem on tieu_diem;
create policy xoa_tieudiem on tieu_diem for delete
  using (nguoi_id = nguoi_id_dang_nhap());

-- Policy đọc `doc_tieudiem` (cả đội xem được) giữ nguyên từ schema.sql.

-- ⚠️ Giới hạn còn lại, ghi ra để biết chứ không vá vội: task của người này vẫn
--    gắn được vào hạt của người kia nếu gọi thẳng API (bảng `task` không soi
--    chủ của hạt). Qua app thì không xảy ra — ô chọn luống chỉ liệt kê luống
--    của chính mình. Muốn chặn tận gốc thì thêm trigger trên `task`.


-- ─── 7. Khung nhìn tien_do_o phải mang theo chủ luống ───────────────────────
-- ⚠️ Phải XOÁ rồi tạo lại, không dùng `create or replace`: lệnh đó chỉ cho
--    THÊM cột vào CUỐI, chèn `nguoi_id` vào giữa thì Postgres hiểu là đang đổi
--    tên cột `ten` và báo `42P16: cannot change name of view column`.
--    Xoá khung nhìn không mất dữ liệu — nó chỉ là câu truy vấn đặt sẵn tên.
drop view if exists tien_do_o;
create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
  count(c.task_id) filter (where c.nac = 'qua') as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                      as tong_phut
from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick;

alter view tien_do_o set (security_invoker = on);


-- ── Kiểm nhanh sau khi chạy ────────────────────────────────────────────────
-- ① Mọi hạt đều có chủ (phải trả về 0):
--    select count(*) from tieu_diem where nguoi_id is null;
-- ② Ai đang giữ luống nào:
--    select n.ten, o.luong, o.ten, o.xong from tieu_diem o join nguoi n on n.id = o.nguoi_id
--     order by n.ten, o.luong;
-- ③ Còn đúng ba policy ghi (them/sua/xoa) + một policy đọc:
--    select policyname, cmd from pg_policies where tablename = 'tieu_diem';
