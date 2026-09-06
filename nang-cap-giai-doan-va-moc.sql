-- ════════════════════════════════════════════════════════════════════════════
-- GIAI ĐOẠN CÓ QUÃNG NGÀY · VIỆC ĐEO THẲNG VÀO MỐC
-- Tracy chốt 2026-09-01 sau bốn lượt đào tới bản chất. Ca gốc: "tổ chức wbn
-- ngày 13/9 … sự kiện 13/9-14/9, chạy quảng cáo 7-13/9, tạo nhóm zalo…"
-- ════════════════════════════════════════════════════════════════════════════
--
-- ─── MÔ HÌNH: MỘT BẢNG, HAI VAI ────────────────────────────────────────────
-- `moc_du_an` từ nay mang hai vai, phân biệt bằng ĐÚNG MỘT THỨ — cột
-- `ngay_bat_dau` có giá trị hay rỗng. Không thêm cột `loai` nào cả: một cột
-- loại và một cột ngày cùng nói một chuyện thì sớm muộn chúng lệch nhau.
--
--   · GIAI ĐOẠN  (ngay_bat_dau CÓ)    — một khúc thời gian, CHỨA việc,
--                                       tên đặt theo việc diễn ra trong đó,
--                                       vẽ THANH NGANG trên Gantt.
--   · CỘT MỐC    (ngay_bat_dau RỖNG)  — không tốn thời gian, KHÔNG chứa gì,
--                                       tên là DANH TỪ nói cái sẽ có,
--                                       vẽ HÌNH THOI trên Gantt.
--
-- Phép thử phân vai: **nó có tốn thời gian không.** "Chạy quảng cáo 7→13/9"
-- tốn bảy ngày nên là giai đoạn; "Đủ 500 người đăng ký" đúng một ngày có hoặc
-- không nên là cột mốc.
--
-- Nguồn ✅ (cụm Croft, vault nạp 28/07):
--   · "cột mốc là DANH TỪ, đầu việc là ĐỘNG TỪ" — 1 trong 7 tiêu chí WBS tốt
--     (project-management-quickstart-croft.pdf, ch.4)
--   · cột mốc coi như một hoạt động dài một phút (ch.5)
--   · "sự kiện không tốn thời gian thì vẽ hình thoi" (ch.8)
--   · giai đoạn là tầng 1 của WBS phase-based (ch.4)
--
-- ─── VÌ SAO PHẢI ĐỘNG TỚI DỮ LIỆU ──────────────────────────────────────────
-- Trước tệp này, một VIỆC không có đường nào đeo vào mốc: `task` có
-- `muc_tieu_id` (dự án) nhưng không có `moc_id`. Đường duy nhất là đi vòng qua
-- cam kết (`tieu_diem.moc_id`) — mà cam kết là lời hứa cá nhân có sổ giao
-- nhận, ký nhận, luống vườn. Mặc bộ áo ấy cho "tạo nhóm Zalo" là quá rộng.
--
-- ─── BA THỨ TỆP NÀY CỐ Ý KHÔNG LÀM ─────────────────────────────────────────
--   ① Không đụng `tieu_diem.moc_id`. Cam kết vẫn đeo mốc như từ 26/08.
--   ② Không đổi tên cột nào. `moc_du_an` vẫn tên ấy dù nay chở hai vai —
--      cùng lối đã chọn 25/08 khi chữ trên màn là MILESTONE còn mã là `moc`.
--   ③ Không tự dời dữ liệu cũ. Mọi dòng `moc_du_an` đang có `ngay_bat_dau`
--      rỗng, tức tất cả đều thành CỘT MỐC — đúng nghĩa cũ của chúng.
--
-- Cần chạy sau: `nang-cap-mang-du-an.sql` · `nang-cap-giao-cam-ket.sql` ·
--               `nang-cap-bo-tran-moc.sql`.
-- ════════════════════════════════════════════════════════════════════════════

begin;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. `moc_du_an.ngay_bat_dau` — cột duy nhất phân vai
-- ════════════════════════════════════════════════════════════════════════════
alter table moc_du_an add column if not exists ngay_bat_dau date;

-- Rỗng thì là cột mốc. Có thì phải THỰC SỰ sớm hơn ngày khép: bằng nhau nghĩa
-- là nó không tốn thời gian, mà thứ không tốn thời gian thì phải để rỗng cho
-- đúng vai, đừng khai một quãng dài không ngày.
alter table moc_du_an drop constraint if exists moc_quang_hop_le;
alter table moc_du_an add  constraint moc_quang_hop_le
  check (ngay_bat_dau is null or ngay_bat_dau < ngay);

comment on column moc_du_an.ngay_bat_dau is
  'RỖNG = cột mốc (không tốn thời gian, không chứa việc, vẽ hình thoi). CÓ = giai đoạn (khúc thời gian, chứa việc, vẽ thanh ngang). Đây là cột DUY NHẤT phân hai vai — đừng thêm cột loại.';

create index if not exists moc_giai_doan on moc_du_an (muc_tieu_id, ngay_bat_dau)
  where ngay_bat_dau is not null;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. `task.moc_id` — việc đeo THẲNG vào giai đoạn
-- ════════════════════════════════════════════════════════════════════════════
alter table task add column if not exists moc_id bigint
  references moc_du_an (id) on delete set null;

comment on column task.moc_id is
  'Giai đoạn mà việc này thuộc về. Rỗng thì việc mượn mốc của cam kết nó treo vào (xem khung nhìn viec_du_an, cột moc_hieu_luc). on delete set null: xoá một giai đoạn thì việc rơi về nhóm "chưa xếp", KHÔNG mất theo.';

create index if not exists task_theo_moc on task (moc_id) where moc_id is not null;

-- 2b. HAI HÀNG RÀO, cả hai đều chặn thứ hỏng ÂM THẦM ────────────────────────
-- Không có chúng thì hai chuyện sau xảy ra mà không một dòng lỗi nào: việc của
-- dự án A treo lên giai đoạn của dự án B (không màn nào bày ra), và việc treo
-- lên một CỘT MỐC (mà cột mốc thì không có chỗ nào liệt kê việc, nên nó biến
-- mất khỏi mắt người dùng trong khi vẫn nằm nguyên trong bảng).
create or replace function kiem_moc_cua_task() returns trigger
language plpgsql as $$
declare m record;
begin
  if new.moc_id is null then return new; end if;

  select muc_tieu_id, ngay_bat_dau, ten into m
    from moc_du_an where id = new.moc_id;

  if m.muc_tieu_id is distinct from new.muc_tieu_id then
    raise exception 'Việc này thuộc dự án khác với giai đoạn "%" — một việc chỉ xếp được vào giai đoạn của chính dự án nó.', m.ten;
  end if;
  if m.ngay_bat_dau is null then
    raise exception 'Không xếp việc vào CỘT MỐC "%" được — cột mốc không tốn thời gian nên không chứa việc. Xếp vào một giai đoạn, hoặc cho mốc ấy một ngày bắt đầu để nó thành giai đoạn.', m.ten;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_moc_cua_task on task;
create trigger trg_kiem_moc_cua_task before insert or update of moc_id, muc_tieu_id on task
  for each row execute function kiem_moc_cua_task();

-- Chiều ngược lại: gỡ ngày bắt đầu của một giai đoạn đang ôm việc là biến nó
-- thành cột mốc, và đám việc ấy lập tức không còn chỗ nào hiện ra. Chặn, và
-- nói rõ phải làm gì trước.
create or replace function kiem_giai_doan_con_viec() returns trigger
language plpgsql as $$
declare so int;
begin
  if old.ngay_bat_dau is not null and new.ngay_bat_dau is null then
    select count(*) into so from task where moc_id = new.id;
    if so > 0 then
      raise exception 'Giai đoạn "%" đang ôm % việc — bỏ ngày bắt đầu là biến nó thành cột mốc, mà cột mốc không chứa việc. Dời % việc ấy sang chỗ khác trước.', new.ten, so, so;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_giai_doan_con_viec on moc_du_an;
create trigger trg_kiem_giai_doan_con_viec before update of ngay_bat_dau on moc_du_an
  for each row execute function kiem_giai_doan_con_viec();


-- ════════════════════════════════════════════════════════════════════════════
-- 3. `viec_du_an` — chở `moc_id`, và MỘT cột trả lời "việc này thuộc khúc nào"
-- ════════════════════════════════════════════════════════════════════════════
-- `moc_hieu_luc` là chỗ luật "nghe ai" sống, và nó sống ở ĐÚNG MỘT chỗ: việc
-- có mốc riêng thì theo mốc riêng, trống thì mượn mốc của cam kết nó treo vào.
-- Để app tự làm phép coalesce ấy là đặt cùng một luật ở mọi màn, rồi tới ngày
-- một màn quên mất.
drop view if exists viec_du_an;
create view viec_du_an as
select
  t.id,
  t.muc_tieu_id,
  t.nguoi_id,
  t.noi_dung,
  t.tieu_diem_ma,
  t.ngay,
  t.deadline,
  t.trang_thai,
  c.cum,
  c.tinh_la_xong,
  c.con_tren_ban,
  t.thoi_luong_du_kien,
  t.task_cha,
  t.ghi_chu_chot,
  t.tao_luc,
  t.xong_luc,
  (t.tieu_diem_ma is null) as la_viec_cho,
  n.ten as ten_nguoi,
  o.ten as ten_cam_ket,
  t.moc_id,
  coalesce(t.moc_id, o.moc_id) as moc_hieu_luc,
  (t.moc_id is null and o.moc_id is not null) as moc_muon_cua_cam_ket
from task t
join cum_trang_thai_task c on c.trang_thai = t.trang_thai
left join nguoi     n on n.id = t.nguoi_id
left join tieu_diem o on o.ma = t.tieu_diem_ma
where t.muc_tieu_id is not null;

alter view viec_du_an set (security_invoker = on);

comment on view viec_du_an is
  'Việc của dự án, một bảng task duy nhất chứ không phải bảng thứ hai. la_viec_cho = đã nghĩ ra nhưng chưa ai gieo cam kết. moc_hieu_luc (01/09) = giai đoạn việc này thuộc về: mốc riêng của việc trước, trống thì mượn mốc của cam kết nó treo vào; moc_muon_cua_cam_ket nói rõ nó đang mượn, để màn nào cần thì phân biệt được.';

grant select on viec_du_an to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 4. `danh_muc_du_an` — đếm riêng hai vai
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ THÂN KHUNG NHÌN DƯỚI ĐÂY DO MÁY CHÉP từ bản sống
-- (`nang-cap-giao-cam-ket.sql`, mục 9), rồi thay đúng hai khối: ngày bắt đầu
-- suy ra, và cụm đếm mốc. Bốn mươi cột còn lại nguyên văn, không gõ lại chữ
-- nào — sáng nay đã suýt hỏng một hàm vì chép tay khi mới đọc một đoạn.
--
-- `drop` rồi `create` chứ không `create or replace`: replace chỉ cho THÊM cột
-- vào cuối, mà ba cột giai đoạn dưới đây chen vào giữa. Drop cuốn theo cả
-- trigger chặn ghi lẫn quyền đọc, nên phải dựng lại cả hai ngay sau.
drop view if exists danh_muc_du_an;
create view danh_muc_du_an as
select
  m.id,
  m.ten,
  m.ket_qua,
  m.nguoi_id,
  m.han,
  m.loai,
  m.trang_thai,
  m.mo_ta,
  m.link_tai_lieu,
  m.pham_vi,
  m.phong_ban,
  m.xong,
  m.ngay_xong,
  m.so_ngay_du_kien,
  m.so_ngay_thuc_te,
  m.nhin_lai_duoc,
  m.nhin_lai_vuong,
  m.nhin_lai_lan_sau,
  m.tao_luc,

  -- ─ cam kết trỏ về ─
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null)                       as so_cam_ket,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.xong)            as cam_ket_tick_xong,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null
     and o.da_nhan_luc is not null)                                                   as cam_ket_da_nhan,
  (select count(distinct o.nguoi_id) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null)     as so_nguoi_ganh,
  /* 🆕 25/08 — DANH SÁCH THÀNH VIÊN, không chỉ con số. Tracy: *"3 người đang
     gánh → thành viên (3): Tracy, Andy, Hafi"*. Một con số bắt người đọc đi tìm
     xem là ai; cái tên trả lời luôn.
     Đọc từ bảng `thanh_vien_du_an` — tức từ LỜI MỜI, không đếm ngược từ cam kết
     đã gieo. Đây là chỗ khác nhau thật: đếm ngược thì người vừa được mời mà
     chưa kịp hứa gì lại không có tên, mà họ mới chính là người cần thấy mình
     đã ở trong dự án. Trả `uuid[]` chứ không nối sẵn tên ở máy chủ — app đã cầm
     bảng `nguoi` trong tay, nối tên ở đây là hai chỗ cùng biết một sự thật. */
  (select array_agg(v.nguoi_id order by (v.nguoi_id = m.nguoi_id) desc, v.moi_luc)
     from thanh_vien_du_an v where v.muc_tieu_id = m.id)                              as nguoi_ganh,

  -- ─ việc của dự án ─
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.con_tren_ban)                                    as so_viec,
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.tinh_la_xong)                                    as viec_xong,
  (select count(*) from task t
    where t.muc_tieu_id = m.id and t.tieu_diem_ma is null)                            as viec_cho,

  /* 🆕 25/08 — TỔNG GIỜ DEEP WORK đã đổ vào dự án. Tracy: *"đếm tổng số giờ
     nữa"*. Mượn thẳng khung nhìn `vuon_cay` chứ không tự cộng lại từ bảng
     `phien_deepwork`: `vuon_cay` là chỗ DUY NHẤT trong app định nghĩa thế nào
     là "giờ làm việc sâu THẬT" — chỉ đếm phiên `ket_qua = 'song'` và chặn trần
     30 phút mỗi phiên. Cộng lại một lần nữa ở đây là đẻ ra bản sự thật thứ hai,
     rồi tới ngày hai con số lệch nhau mà không ai biết cái nào đúng. */
  (select coalesce(sum(c.phut), 0)::int from vuon_cay c
     join task t on t.id = c.task_id
    where t.muc_tieu_id = m.id)                                                       as tong_phut,

  /* ─ ngày bắt đầu SUY RA, không có cột nào phải nuôi ─
     01/09: lấy `coalesce(ngay_bat_dau, ngay)` chứ không lấy `ngay` trần. Một
     giai đoạn mở ngày 7 và khép ngày 13 thì dự án bắt đầu ngày 7, không phải
     13 — bản cũ đọc mọi dòng như một cái điểm nên nó trả về ngày KHÉP. */
  least(
    (select min(coalesce(k.ngay_bat_dau, k.ngay))
                             from moc_du_an  k where k.muc_tieu_id = m.id),
    (select min(o.ngay_gieo) from tieu_diem  o where o.muc_tieu_id = m.id and o.luong is not null)
  )                                                                                   as ngay_bat_dau,

  /* ─ CỘT MỐC — dòng KHÔNG có ngày bắt đầu ────────────────────────────────
     Bốn ô `moc_*` dưới đây trước 01/09 đếm cả bảng. Từ khi `moc_du_an` mang
     hai vai, đếm cả bảng là trộn hai thứ khác loại vào một con số: ô "cột mốc
     đã đạt" trên màn hồ sơ sẽ nhảy lên mỗi khi một GIAI ĐOẠN xong, mà giai
     đoạn thì chẳng ai bấm "đạt" cả — nó xong khi việc bên trong xong. */
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is null)                                                      as so_moc,
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is null and k.da_dat)                                         as moc_da_dat,
  (select count(*) from moc_du_an k
    where k.muc_tieu_id = m.id and k.ngay_bat_dau is null
      and not k.da_dat and k.ngay < hom_nay())                                        as moc_qua_ngay,
  (select k.ten  from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is null and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ten,
  (select k.ngay from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is null and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ngay,
  (select k.ngay - hom_nay() from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is null and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_con_may_ngay,

  /* ─ GIAI ĐOẠN — dòng CÓ ngày bắt đầu ────────────────────────────────────
     "Xong" của một giai đoạn KHÔNG phải một cờ ai bấm, mà là: nó có việc, và
     không còn việc nào chưa xong. Giai đoạn rỗng thì chưa xong — chưa làm gì
     thì chưa thể gọi là đã làm hết. */
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is not null)                                                  as so_giai_doan,
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is not null
     and exists (select 1 from task t where t.moc_id = k.id)
     and not exists (select 1 from task t
                       join cum_trang_thai_task c on c.trang_thai = t.trang_thai
                      where t.moc_id = k.id and not c.tinh_la_xong))                  as giai_doan_xong,
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id
     and k.ngay_bat_dau is not null and k.ngay < hom_nay()
     and exists (select 1 from task t
                   join cum_trang_thai_task c on c.trang_thai = t.trang_thai
                  where t.moc_id = k.id and not c.tinh_la_xong))                      as giai_doan_qua_ngay,

  -- ─ cờ nhịp tuần: tuần này đã có cam kết nào gieo trỏ về chưa ─
  exists (select 1 from tieu_diem o
           where o.muc_tieu_id = m.id and o.luong is not null
             and o.ngay_gieo >= thu_hai_cua(hom_nay()))                               as co_nhip_tuan,

  -- ─ hai cách đếm phần trăm, bày cả hai để Tracy so (d3) ─
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.da_nhan_luc is not null)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null))
  end                                                                                 as phan_tram,
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null and o.xong)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.luong is not null))
  end                                                                                 as phan_tram_tu_tick

from muc_tieu m;
alter view danh_muc_du_an set (security_invoker = on);

comment on view danh_muc_du_an is
  'Một dự án một dòng. MỌI con số ở đây do máy chủ đếm — không ô nào cho người gõ. Từ 01/09 cụm moc_* chỉ đếm CỘT MỐC (ngay_bat_dau rỗng), còn giai_doan_* đếm GIAI ĐOẠN (có ngay_bat_dau): trộn hai vai vào một con số là ô "cột mốc đã đạt" nhảy lên mỗi khi một giai đoạn xong, mà giai đoạn thì không ai bấm đạt. phan_tram đếm theo LÚC KÝ NHẬN (mặc định d3); phan_tram_tu_tick đếm theo lúc người làm tự tick. co_nhip_tuan = tuần này đã có cam kết gieo trỏ về chưa. Từ 27/08 mọi phép đếm cam kết đều bỏ qua dòng đang nằm KHO.';

drop trigger if exists trg_chan_ghi_danh_muc_du_an on danh_muc_du_an;
create trigger trg_chan_ghi_danh_muc_du_an
  instead of insert or update or delete on danh_muc_du_an
  for each row execute function chan_ghi_khung_nhin();

grant select on danh_muc_du_an to authenticated;

commit;


-- ════════════════════════════════════════════════════════════════════════════
-- SOÁT LẠI SAU KHI CHẠY — sáu dòng phải ra true cả sáu
-- ════════════════════════════════════════════════════════════════════════════
select
  exists (select 1 from information_schema.columns
           where table_name='moc_du_an' and column_name='ngay_bat_dau')      as moc_co_ngay_bat_dau,
  exists (select 1 from information_schema.columns
           where table_name='task' and column_name='moc_id')                 as task_co_moc_id,
  exists (select 1 from information_schema.columns
           where table_name='viec_du_an' and column_name='moc_hieu_luc')     as view_co_moc_hieu_luc,
  exists (select 1 from information_schema.columns
           where table_name='danh_muc_du_an' and column_name='so_giai_doan') as view_co_so_giai_doan,
  (select count(*) from pg_trigger
    where tgrelid = 'task'::regclass and not tgisinternal
      and tgname = 'trg_kiem_moc_cua_task') = 1                              as hang_rao_task,
  (select count(*) from pg_trigger
    where tgrelid = 'moc_du_an'::regclass and not tgisinternal
      and tgname = 'trg_kiem_giai_doan_con_viec') = 1                        as hang_rao_giai_doan;

-- Mọi dòng cũ đều thành CỘT MỐC — đúng nghĩa cũ của chúng. Câu này chỉ để nhìn.
select count(*) filter (where ngay_bat_dau is null)     as cot_moc,
       count(*) filter (where ngay_bat_dau is not null) as giai_doan
  from moc_du_an;
