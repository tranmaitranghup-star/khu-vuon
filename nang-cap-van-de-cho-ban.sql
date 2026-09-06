-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: nhãn loại `van-de` trong thân khung nhìn `cho_ban`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — VẤN ĐỀ VÀO KHỐI "CHỜ BẠN", nhát 3      (TRI-113)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- CHẠY SAU:  `nang-cap-van-de-lien-phong.sql` (nhát 1 — nhánh mới đọc bảng
--            `van_de` của tệp ấy) VÀ `nang-cap-trao-pic-du-an.sql` (tệp dựng
--            khung nhìn sáu nhánh mà tệp này chép lại).
--
-- ⚠️ ĐI CÙNG MỘT LƯỢT VỚI MÃ APP, KHÔNG TÁCH RA. Chú thích của chính khung
--    nhìn đã cảnh báo: khai thêm một loại ở đây mà quên khoá tương ứng trong
--    `CB_LOAI` của app thì ô đếm cộng một dòng còn danh sách không bày nó —
--    một dòng chờ vô hình, đúng loại hỏng im lặng khó thấy nhất.
--
-- ─── VÌ SAO KHÔNG DỰNG MÀN MỚI ──────────────────────────────────────────────
-- Khối *Chờ bạn* đã chạy sẵn ở màn Hôm nay, đã có nút Nhận, và đã gom sáu loại
-- đang chờ. Vấn đề giao đích danh cho một người là loại thứ bảy của đúng câu
-- hỏi ấy — "thứ gì đang chờ tôi ra tay" — nên nó là một nhánh `union all`, không
-- phải một bảng, cũng không phải một màn.
-- ============================================================================

begin;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. `cho_ban` — NHÁNH THỨ BẢY                                      (TRI-113)
-- ════════════════════════════════════════════════════════════════════════════
-- Không dựng màn mới: chú thích của chính khung nhìn này đã viết sẵn cách nới —
-- *"Thêm loại mới thì thêm một nhánh union all, không dựng bảng — và nhớ khai
-- khoá tương ứng trong CB_LOAI của app, không thì ô đếm cộng một dòng mà danh
-- sách không bày nó."* Sáu nhánh dưới đây chép NGUYÊN VĂN từ
-- `nang-cap-trao-pic-du-an.sql`; chỉ nhánh ⑦ là mới.
--
-- ⚠️ `drop view` cuốn theo cả `security_invoker`, quyền `grant`, và cò chặn
--    ghi. Cả ba dựng lại ở mục 6b bên dưới — bỏ sót một cái là một lỗ im lặng.

drop view if exists cho_ban;

create view cho_ban as

-- ① LỜI MỜI chưa xem
select
  'loi-moi'::text                    as loai,
  v.muc_tieu_id::text                as khoa,
  m.ten                              as ten,
  coalesce(n.ten, '—')               as ai,          -- ai mời tôi
  v.moi_luc                          as luc,
  v.nguoi_id                         as cua_toi
from thanh_vien_du_an v
join muc_tieu m on m.id = v.muc_tieu_id
left join nguoi  n on n.id = v.moi_boi
where v.nguoi_id = nguoi_id_dang_nhap()
  and v.da_xem_luc is null
  and v.moi_boi is distinct from v.nguoi_id
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ② CAM KẾT chờ TÔI ký nhận
select
  'ky-nhan'::text,
  o.ma,
  o.ten,
  n.ten,
  coalesce(o.nop_luc, o.ngay_xong::timestamptz),
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.xong
  and length(trim(coalesce(o.output_chu, ''))) > 0
  and o.da_nhan_luc is null
  and (
        (n.leader_id is not null and n.leader_id = nguoi_id_dang_nhap())
     or (n.leader_id is null     and n.id        = nguoi_id_dang_nhap())
      )

union all

-- ③ CAM KẾT ĐƯỢC GIAO cho tôi, tôi chưa trả lời
select
  'cho-nhan'::text,
  o.ma,
  o.ten,
  coalesce(g.ten, '—'),
  o.giao_luc,
  o.nguoi_id
from tieu_diem o
left join nguoi g on g.id = o.giao_boi
where o.nguoi_id       = nguoi_id_dang_nhap()
  and o.giao_luc      is not null
  and o.nhan_viec_luc is null
  and o.tu_choi_luc   is null

union all

-- ④ CAM KẾT TÔI GIAO ĐI, BỊ TỪ CHỐI
select
  'bi-tu-choi'::text,
  o.ma,
  o.ten || ' — lý do: ' || coalesce(nullif(trim(o.tu_choi_ly_do), ''), '(không khai)'),
  coalesce(n.ten, '—'),
  o.tu_choi_luc,
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.giao_boi      = nguoi_id_dang_nhap()
  and o.tu_choi_luc  is not null
  and o.nhan_viec_luc is null

union all

-- ⑤ VAI PIC ĐƯỢC TRAO cho tôi, tôi chưa trả lời                    (31/08, TP)
-- Lọc theo `pic_moi_luc`, KHÔNG theo `pic_moi_boi` — cùng lý lẽ nhánh ③: người
-- trao rời đội thì `pic_moi_boi` về rỗng (khoá ngoại on delete set null) và
-- lọc theo nó là lời trao lặng lẽ biến mất trong khi vai vẫn đang chờ một câu
-- trả lời. Cột `ai` đã có `coalesce(…, '—')` lo phần tên.
-- Nấc dự án lọc y hệt nhánh ①: đóng hoặc hủy rồi thì lời trao hết nghĩa.
select
  'cho-nhan-pic'::text,
  m.id::text,
  m.ten,
  coalesce(n.ten, '—'),                              -- ai trao cho tôi
  m.pic_moi_luc,
  m.pic_moi_id
from muc_tieu m
left join nguoi n on n.id = m.pic_moi_boi
where m.pic_moi_id      = nguoi_id_dang_nhap()
  and m.pic_moi_luc    is not null
  and m.pic_tu_choi_luc is null
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ⑥ VAI PIC TÔI TRAO ĐI, BỊ TỪ CHỐI                                (31/08, TP)
-- Neo vào `m.nguoi_id` (PIC hiện tại) chứ không `pic_moi_boi`: người còn đang
-- gánh dự án chính là người cần biết lời trao bị trả lại, và cũng là người
-- duy nhất `rut_lai_trao_pic` cho phép dọn nó. Dòng ở lại cho tới khi họ rút —
-- cố ý đòi một hành động có chủ, không tự tắt sau mấy ngày.
select
  'pic-tu-choi'::text,
  m.id::text,
  m.ten || ' — lý do: ' || coalesce(nullif(trim(m.pic_tu_choi_ly_do), ''), '(không khai)'),
  coalesce(n.ten, '—'),                              -- ai từ chối
  m.pic_tu_choi_luc,
  nguoi_id_dang_nhap()
from muc_tieu m
left join nguoi n on n.id = m.pic_moi_id
where m.nguoi_id        = nguoi_id_dang_nhap()
  and m.pic_tu_choi_luc is not null

union all

-- ⑦ VẤN ĐỀ LIÊN PHÒNG giao đích danh cho tôi, tôi chưa bấm Nhận      (05/09, VD)
-- Neo vào `nhan_luc`, không vào trạng thái: mốc nhận do cò giữ cho chỉ đặt được
-- MỘT lần, còn trạng thái thì đổi được bằng nhiều đường. Hai dòng loại trừ ở
-- cuối là để một vấn đề đóng thẳng bằng `khong_lam` — chưa ai nhận bao giờ —
-- thôi nằm chờ trong khối Chờ bạn của người được giao.
-- Cột `luc` chở LÚC NÊU chứ không phải hạn 24 giờ: khung nhìn có sáu cột cứng,
-- và khối Chờ bạn vốn đếm "chờ bao lâu rồi" từ chính cột này. Hạn và đồng hồ
-- ba mặt nằm ở màn Vấn đề, nơi đọc thẳng bảng `van_de`.
select
  'van-de'::text,
  v.id::text,
  v.tieu_de,
  coalesce(n.ten, '—'),                              -- ai nêu cho tôi
  v.tao_luc,
  v.nguoi_nhan_id
from van_de v
left join nguoi n on n.id = v.nguoi_neu_id
where v.nguoi_nhan_id = nguoi_id_dang_nhap()
  and v.nhan_luc is null
  and v.trang_thai not in ('xong', 'khong_lam');

alter view cho_ban set (security_invoker = on);

comment on view cho_ban is
  'Thứ đang chờ người đang đăng nhập ra tay. Bảy loại: loi-moi (được mời vào dự án, chưa mở xem) · ky-nhan (cam kết đã nộp sản phẩm, đang chờ chính mình ký nhận) · cho-nhan (được giao một cam kết, chưa gật cũng chưa từ chối) · bi-tu-choi (cam kết chính mình giao đi, bị trả lại) · cho-nhan-pic (được trao vai PIC một dự án, chưa trả lời) · pic-tu-choi (vai PIC chính mình trao đi, bị trả lại) · van-de (một vấn đề liên phòng giao đích danh cho mình, chưa bấm Nhận). Khung nhìn tự lọc theo người đăng nhập. Thêm loại mới thì thêm một nhánh union all, không dựng bảng — và nhớ khai khoá tương ứng trong CB_LOAI của app, không thì ô đếm cộng một dòng mà danh sách không bày nó.';

grant select on cho_ban to authenticated;


-- ─── 1b. Dựng lại cổng chặn ghi (drop view ở trên đã cuốn nó đi) ────────────
create or replace function chan_ghi_cho_ban() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "cho_ban" là ô MÁY CHỦ TÍNH, không ghi vào được. Xử ở chỗ thật: mở hồ sơ dự án, bấm nút Đã nhận trên cam kết, bấm Nhận việc / Từ chối trên lời giao, bấm Nhận vai / Từ chối trên lời trao PIC, hoặc bấm Nhận trên một vấn đề.';
end $$;

drop trigger if exists trg_chan_ghi_cho_ban on cho_ban;
create trigger trg_chan_ghi_cho_ban
  instead of insert or update or delete on cho_ban
  for each row execute function chan_ghi_cho_ban();

commit;

-- ════════════════════════════════════════════════════════════════════════════
-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả bốn dòng ════════════════════════════
-- ════════════════════════════════════════════════════════════════════════════
-- Đặt CUỐI tệp vì trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh
-- cuối cùng. `order by dat, so` đẩy dòng chưa đạt lên đầu.
--
-- ⚠️ Không dòng nào so chuỗi với một `check` hay một policy: Postgres không cất
--    lại nguyên văn câu mình gõ, nó phân tích rồi in lại với từ khoá viết HOA.
--    Riêng dòng 1 so được, vì thứ nó tìm là một HẰNG CHUỖI trong thân khung
--    nhìn — chuỗi thì Postgres in lại y nguyên.
select * from (values

  (1, 'cho_ban nay có đủ BẢY loại',
   (select count(distinct loai) from (
      select 'loi-moi' as loai union all select 'ky-nhan' union all
      select 'cho-nhan' union all select 'bi-tu-choi' union all
      select 'cho-nhan-pic' union all select 'pic-tu-choi' union all select 'van-de'
    ) mong where pg_get_viewdef('cho_ban'::regclass) like '%''' || loai || '''%') = 7),

  (2, 'cho_ban vẫn đủ sáu cột cứng',
   (select count(*) from information_schema.columns
     where table_name = 'cho_ban'
       and column_name in ('loai','khoa','ten','ai','luc','cua_toi')) = 6),

  /* Ba thứ `drop view` cuốn đi mà phải dựng lại. Quên cái nào cũng là một lỗ
     im lặng: thiếu security_invoker thì khung nhìn chạy bằng quyền người dựng
     và mọi người thấy dòng chờ của nhau; thiếu cò thì ghi thẳng vào khung nhìn
     không còn báo lỗi. */
  (3, 'vẫn chạy security_invoker',
   (select 'security_invoker=on' = any(coalesce(reloptions, '{}'))
      from pg_class where relname = 'cho_ban')),

  (4, 'vẫn chặn ghi, và vẫn cho authenticated đọc',
   exists (select 1 from pg_trigger
            where tgname = 'trg_chan_ghi_cho_ban' and not tgisinternal)
   and has_table_privilege('authenticated', 'cho_ban', 'select'))

) as t(so, muc, dat)
order by dat, so;
