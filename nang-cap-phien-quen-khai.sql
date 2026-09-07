-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `phien_deepwork.bo_roi`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — PHIÊN QUÊN TẮT VÀO KHỐI "CHỜ BẠN"      (TRI-162)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn tệp → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- CHẠY SAU:  `nang-cap-don-phien-bo-roi.sql` (tệp dựng hàm dọn mà tệp này viết
--            đè) VÀ `nang-cap-van-de-cho-ban.sql` (tệp dựng khung nhìn bảy
--            nhánh mà tệp này chép lại).
--
-- ⚠️ ĐI CÙNG MỘT LƯỢT VỚI MÃ APP, KHÔNG TÁCH RA. Chú thích của chính khung
--    nhìn đã cảnh báo: khai thêm một loại ở đây mà quên khoá tương ứng trong
--    `CB_LOAI` của app thì ô đếm cộng một dòng còn danh sách không bày nó.
--
-- ─── VÌ SAO CÓ TỆP NÀY ──────────────────────────────────────────────────────
-- Andy 07/09: phiên 09:12–12:12, đủ 180 phút, nhịp tim đập đều tới phút cuối —
-- máy mở suốt buổi. Andy không bấm ⏹ nên phiên nằm lại `dang_chay`, rồi
-- `don_phien_bo_roi()` khép nó thành `heo`. Mọi khung nhìn đếm giờ đều lọc
-- `ket_qua = 'song'`, nên cả buổi làm thật ấy hiện ra thành 0 giờ. Ba người
-- cùng khung giờ hôm đó cũng chạm trần 180 phút, chỉ khác ở chỗ có bấm ⏹.
--
-- Tracy 07/09: *"nếu họ quên thì ở ô chờ bạn cho họ thông báo để họ nhận và
-- tính lại phiên đó là được chứ đừng để héo luôn"* và *"ai đi kiểm tra từng
-- người được, họ tự thôi"*.
--
-- ─── BA THỨ CỐ Ý KHÔNG LÀM ──────────────────────────────────────────────────
--   · KHÔNG tự đổi phiên bỏ rơi thành `song`. Nhịp tim chỉ chứng minh tab còn
--     mở, không chứng minh người còn ngồi làm. Số phút phải do chính chủ khai,
--     và khai xong thì mang dấu `khai_tay` để bảng không nói dối.
--   · KHÔNG mở quyền cho ai ghi nhận hộ người khác. Chính chủ tự nhận.
--   · KHÔNG treo dòng chờ vào lượt dọn định kỳ. Việc dọn chạy mỗi giờ vào phút
--     thứ 7, nên một phiên chạm trần lúc 12:12 phải đợi tới 13:07 mới có dòng —
--     trễ gần một tiếng. Nhánh ⑧ dưới đây đọc THẲNG THEO GIỜ, đúng ở cả hai
--     phía mốc dọn: phiên còn treo quá trần cũng đã nằm trong ô chờ rồi.
-- ============================================================================

begin;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. CỜ `bo_roi` — phân biệt MÁY DỌN với NGƯỜI TỰ BỎ
-- ════════════════════════════════════════════════════════════════════════════
-- Hai đường cùng dẫn tới `ket_qua = 'heo'` mà ý nghĩa ngược nhau:
--   · `dwHuy` ở máy khách — người ta CHỦ Ý bỏ phiên. Mời họ khai lại thứ vừa
--     cố ý bỏ là quấy.
--   · `don_phien_bo_roi()` — máy khép hộ một phiên không ai tắt. Đây mới là
--     thứ đáng mời khai.
-- Suy ra bằng độ dài phiên thì cũng ra, nhưng đó là đoán: một người bỏ phiên
-- đúng lúc chạm trần sẽ trông y hệt. Một cột thì đo được, nên dùng cột.

alter table phien_deepwork add column if not exists bo_roi boolean not null default false;

comment on column phien_deepwork.bo_roi is
  'true = phiên này do don_phien_bo_roi() khép hộ vì quá trần, KHÔNG phải người tự bỏ. Nuôi nhánh phien-quen-khai của khung nhìn cho_ban. Cờ ở lại sau khi khai để còn tra được phiên nào từng bị bỏ rơi.';


-- ════════════════════════════════════════════════════════════════════════════
-- 2. HÀM DỌN đặt cờ khi khép
-- ════════════════════════════════════════════════════════════════════════════
-- Chép nguyên phép kẹp `least(bat_dau + 180 phút, now())` của
-- `nang-cap-don-phien-bo-roi.sql` — một phiên bỏ quên ba tuần mà ghi
-- `ket_thuc = now()` thì thành một phiên dài ba tuần và mọi con số phút của
-- người đó vỡ. Thêm đúng một câu gán cờ.

create or replace function don_phien_bo_roi()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare so_dong integer;
begin
  update phien_deepwork
     set ket_qua  = 'heo',
         bo_roi   = true,
         ket_thuc = least(bat_dau + interval '180 minutes', now())
   where ket_qua = 'dang_chay'
     and bat_dau < now() - interval '180 minutes';
  get diagnostics so_dong = row_count;
  return so_dong;
end;
$$;

comment on function don_phien_bo_roi is
  'Khép các phiên deep work bị bỏ rơi quá trần 180 phút thành heo, kẹp ket_thuc ở trần, và đánh cờ bo_roi để khối Chờ bạn mời chính chủ khai lại. Chạy lại nhiều lần vô hại.';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. VÁ DẤU VẾT CHO NHỮNG PHIÊN ĐÃ BỊ DỌN TRƯỚC KHI CÓ CỜ
-- ════════════════════════════════════════════════════════════════════════════
-- Chỉ đụng phiên trong 7 ngày — bằng đúng cửa sổ nhìn lại của nhánh ⑧, quá hạn
-- ấy thì cờ có bật cũng không dòng chờ nào đọc tới.
--
-- Ba điều kiện cộng lại mới ra dấu vết của lượt dọn: héo · không khai cửa nào ·
-- dài đúng bằng trần (phép kẹp của hàm dọn luôn cho ra 180 phút chằn, trừ phiên
-- bị dọn muộn hơn trần thì vẫn là 180). Người tự bỏ phiên đúng lúc 180 phút mà
-- cũng không khai cửa thì lọt — hệ quả là một dòng mời khai mà họ bỏ qua được,
-- nên không đáng dựng thêm cột thứ hai để chặn.

update phien_deepwork
   set bo_roi = true
 where ket_qua  = 'heo'
   and not bo_roi
   and cua is null
   and bat_dau > now() - interval '7 days'
   and ket_thuc - bat_dau >= interval '179 minutes';


-- ════════════════════════════════════════════════════════════════════════════
-- 4. `cho_ban` — NHÁNH THỨ TÁM                                     (TRI-162)
-- ════════════════════════════════════════════════════════════════════════════
-- Bảy nhánh dưới đây chép NGUYÊN VĂN từ `nang-cap-van-de-cho-ban.sql`; chỉ
-- nhánh ⑧ là mới.
--
-- ⚠️ `drop view` cuốn theo cả `security_invoker`, quyền `grant`, và cò chặn
--    ghi. Cả ba dựng lại ở mục 4b bên dưới — bỏ sót một cái là một lỗ im lặng.

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
  and v.trang_thai not in ('xong', 'khong_lam')

union all

-- ⑧ PHIÊN DEEP WORK QUÊN TẮT, chưa ai khai số phút                  (07/09, QK)
-- ĐỌC THEO GIỜ, KHÔNG ĐỢI LƯỢT DỌN. Hai trạng thái cùng vào đây và đó là chủ ý:
--   · `dang_chay` quá trần — phiên vừa bị bỏ quên, lượt dọn chưa chạy tới.
--   · `heo` mang cờ `bo_roi` — lượt dọn đã khép hộ.
-- Nhờ vậy dòng chờ có mặt ngay khi phiên vượt 180 phút, thay vì trễ tới gần một
-- tiếng theo lịch chạy `7 * * * *` của việc dọn.
--
-- Phiên `heo` KHÔNG mang cờ thì đứng ngoài: đó là phiên người ta tự bỏ.
-- Phiên đã khai thì mang `ket_qua = 'song'` nên tự rụng khỏi nhánh này, không
-- cần lọc thêm `khai_tay`.
--
-- Cột `ai` chở KHUNG GIỜ chứ không chở tên người — cùng lối nhánh ⑦ mượn cột
-- `luc`: khung nhìn có sáu cột cứng, mà thứ người đọc cần nhận ra là "phiên
-- nào của tôi", và khung giờ nói điều đó gọn hơn mọi thứ khác. Giờ kết thúc
-- lấy theo NHỊP TIM cuối cùng, không lấy mốc trần: người bỏ máy đi lúc 10:30
-- phải đọc ra 09:12–10:30, không phải 09:12–12:12.
select
  'phien-quen-khai'::text,
  p.id::text,
  coalesce(nullif(trim(t.noi_dung), ''), nullif(trim(nh.ten), ''), 'Phiên deep work'),
  to_char(p.bat_dau at time zone 'Asia/Ho_Chi_Minh', 'HH24:MI') || '–' ||
  to_char(coalesce(p.nhip_cuoi, p.bat_dau + interval '180 minutes')
            at time zone 'Asia/Ho_Chi_Minh', 'HH24:MI'),
  p.bat_dau,
  p.nguoi_id
from phien_deepwork p
left join task t  on t.id  = p.task_id
left join nhip nh on nh.id = p.nhip_id
where p.nguoi_id = nguoi_id_dang_nhap()
  and p.bat_dau > now() - interval '7 days'
  and p.bat_dau < now() - interval '180 minutes'
  and (p.ket_qua = 'dang_chay' or (p.ket_qua = 'heo' and p.bo_roi));

alter view cho_ban set (security_invoker = on);

comment on view cho_ban is
  'Thứ đang chờ người đang đăng nhập ra tay. Tám loại: loi-moi (được mời vào dự án, chưa mở xem) · ky-nhan (cam kết đã nộp sản phẩm, đang chờ chính mình ký nhận) · cho-nhan (được giao một cam kết, chưa gật cũng chưa từ chối) · bi-tu-choi (cam kết chính mình giao đi, bị trả lại) · cho-nhan-pic (được trao vai PIC một dự án, chưa trả lời) · pic-tu-choi (vai PIC chính mình trao đi, bị trả lại) · van-de (một vấn đề liên phòng giao đích danh cho mình, chưa bấm Nhận) · phien-quen-khai (phiên deep work quá trần chưa khai số phút, giờ chưa vào vườn). Khung nhìn tự lọc theo người đăng nhập. Thêm loại mới thì thêm một nhánh union all, không dựng bảng — và nhớ khai khoá tương ứng trong CB_LOAI của app, không thì ô đếm cộng một dòng mà danh sách không bày nó.';

grant select on cho_ban to authenticated;


-- ─── 4b. Dựng lại cổng chặn ghi (drop view ở trên đã cuốn nó đi) ────────────
create or replace function chan_ghi_cho_ban() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "cho_ban" là ô MÁY CHỦ TÍNH, không ghi vào được. Xử ở chỗ thật: mở hồ sơ dự án, bấm nút Đã nhận trên cam kết, bấm Nhận việc / Từ chối trên lời giao, bấm Nhận vai / Từ chối trên lời trao PIC, bấm Nhận trên một vấn đề, hoặc chạm dòng phiên quên tắt rồi khai số phút.';
end $$;

drop trigger if exists trg_chan_ghi_cho_ban on cho_ban;
create trigger trg_chan_ghi_cho_ban
  instead of insert or update or delete on cho_ban
  for each row execute function chan_ghi_cho_ban();

commit;


-- ════════════════════════════════════════════════════════════════════════════
-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
-- ════════════════════════════════════════════════════════════════════════════
select
  (select count(*) from phien_deepwork
    where bo_roi and bat_dau > now() - interval '7 days')            as phien_bo_roi_7_ngay,
  (select count(*) from phien_deepwork
    where ket_qua = 'dang_chay'
      and bat_dau < now() - interval '180 minutes')                  as dang_treo_qua_tran,
  (select count(*) from phien_deepwork
    where khai_tay and bat_dau > now() - interval '7 days')          as da_khai_tay_7_ngay;


-- ════════════════════════════════════════════════════════════════════════════
-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ═════════════════════════════
-- ════════════════════════════════════════════════════════════════════════════
-- Đặt CUỐI tệp vì trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh
-- cuối cùng. `order by dat, so` đẩy dòng chưa đạt lên đầu.
--
-- ⚠️ Không dòng nào so chuỗi với một `check` hay một policy: Postgres không cất
--    lại nguyên văn câu mình gõ, nó phân tích rồi in lại với từ khoá viết HOA.
--    Dòng 2 và 3 so được vì thứ chúng tìm là HẰNG CHUỖI trong thân khung nhìn
--    và trong thân hàm — chuỗi thì Postgres in lại y nguyên.
select * from (values

  (1, 'cột bo_roi đã có trên phien_deepwork',
      (select count(*) = 1 from information_schema.columns
        where table_name = 'phien_deepwork' and column_name = 'bo_roi')),

  (2, 'hàm dọn đặt cờ bo_roi khi khép',
      (select pg_get_functiondef(oid) like '%bo_roi   = true%'
         from pg_proc where proname = 'don_phien_bo_roi')),

  (3, 'cho_ban có nhánh phien-quen-khai',
      (select pg_get_viewdef('cho_ban'::regclass) like '%phien-quen-khai%')),

  (4, 'cho_ban còn ĐỦ TÁM nhánh — đếm số lần union all, không chỉ dò tên loại',
      (select (length(pg_get_viewdef('cho_ban'::regclass))
             - length(replace(pg_get_viewdef('cho_ban'::regclass), 'UNION ALL', ''))
              ) / length('UNION ALL') = 7)),

  (5, 'khung nhìn chạy bằng quyền người hỏi (security_invoker)',
      (select 'security_invoker=on' = any(reloptions)
         from pg_class where relname = 'cho_ban')),

  (6, 'cổng chặn ghi đã dựng lại sau drop view',
      (select count(*) = 1 from pg_trigger
        where tgname = 'trg_chan_ghi_cho_ban' and not tgisinternal))

) as t(so, muc, dat)
order by dat, so;
