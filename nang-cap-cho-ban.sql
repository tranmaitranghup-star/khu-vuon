-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `thanh_vien_du_an.da_xem_luc`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-cho-ban.sql                    (Tracy chốt 2026-08-25, phương án B)
--
-- Dán trọn file vào Supabase › SQL Editor › Run. CHẠY LẠI NHIỀU LẦN VÔ HẠI.
-- Chạy SAU `nang-cap-mang-du-an.sql`. Xong thì nhìn bảng cuối: mọi dòng phải ✅.
--
-- ─── VÌ SAO CÓ FILE NÀY ─────────────────────────────────────────────────────
-- Tracy thử mời Andy vào một dự án rồi hỏi: *"Andy không nhận được thông báo ở
-- đâu trong app à?"* Đúng — và đo ra thì chỗ hổng rộng hơn tính năng mời:
--
--   · App KHÔNG có tầng thông báo nào. Không có nếp "đã xem / chưa xem", không
--     có realtime (0 subscription trong `public/index.html`), không có chấm đỏ,
--     không có hộp thư. Chữ "chuông" trong app là chuông tỉnh thức của phiên
--     deep work, không liên quan.
--   · Sau khi được mời, thứ DUY NHẤT đổi với Andy là dự án hiện ra trong ô chọn
--     lúc anh ấy gieo cam kết. Danh mục dự án vốn đã bày mọi dự án cho cả đội
--     nên không đổi gì; muốn thấy tên mình trong khối Thành viên thì phải tự mở
--     đúng dự án đó ra.
--   · Và cùng chỗ hổng ấy đang chạy ở một nơi đau hơn: cam kết đã nộp sản phẩm,
--     đang CHỜ CẤP TRÊN KÝ NHẬN, thì cấp trên cũng không được báo gì. Nút "Đã
--     nhận" nằm im trong thẻ cam kết, chờ người ta tình cờ mở ra. Vòng bốn nhịp
--     (yêu cầu · hứa · tuyên bố xong · nghiệm thu) đứt ở đúng nhịp cuối.
--
-- Nên file này KHÔNG dựng riêng một cơ chế cho lời mời. Nó dựng MỘT chỗ chung
-- trả lời đúng một câu: **thứ gì đang chờ tôi?** Hôm nay chỗ ấy gom hai loại;
-- đợt giao việc sau chỉ thêm một nhánh `union all`, không phải dựng lại.
--
-- ─── BA THỨ CỐ Ý KHÔNG LÀM ──────────────────────────────────────────────────
--   · Không email, không push — app không có hạ tầng cho chúng.
--   · Không realtime. App chưa dùng một subscription nào; thêm nó vào chỉ để
--     báo hai loại tin là mở một mặt trận mới phải nuôi. Đọc lúc mở app là đủ.
--   · Không dựng bảng thông báo có lịch sử. Một bảng như thế phải có người dọn,
--     mà chưa ai xin nó. Loại ② dưới đây tính THẲNG từ dữ liệu đang có, không
--     tốn một cột nào; chỉ loại ① cần đúng một cột.
-- ════════════════════════════════════════════════════════════════════════════

begin;


-- ─── 1. Một cột duy nhất: lời mời này đã xem chưa ───────────────────────────
-- Để trống = chưa xem. Không dùng cờ boolean vì mốc giờ trả lời thêm được câu
-- "mời từ bao giờ mà tới giờ mới xem" — cùng giá, nhiều thông tin hơn.
alter table thanh_vien_du_an add column if not exists da_xem_luc timestamptz;

comment on column thanh_vien_du_an.da_xem_luc is
  'Lúc người được mời MỞ hồ sơ dự án lần đầu. Để trống = lời mời chưa xem, và khối "Chờ bạn" còn nhắc.';

create index if not exists loi_moi_chua_xem on thanh_vien_du_an (nguoi_id)
  where da_xem_luc is null;

-- Dòng đang có coi như đã xem: chúng sinh ra trước khi có cơ chế này, nhắc lại
-- bây giờ là dựng một đống việc giả cho cả đội ngay lần đầu mở app.
update thanh_vien_du_an set da_xem_luc = now() where da_xem_luc is null;


-- ─── 2. Đánh dấu đã xem — một hàm, không nới chính sách ghi ─────────────────
-- Vì sao là HÀM chứ không phải một policy UPDATE: RLS của Postgres chặn theo
-- DÒNG chứ không theo CỘT. Mở policy update cho `nguoi_id = tôi` là mở luôn cả
-- `moi_boi` và `moi_luc` — tức người được mời sửa được cả lời khai ai mời mình
-- và mời lúc nào. Hàm `security definer` khoanh đúng một cột cần chạm. Cùng lý
-- lẽ đã dùng cho `nhan_cam_ket` (11/08).
create or replace function danh_dau_da_xem_du_an(p_muc_tieu_id bigint)
returns void language plpgsql security definer set search_path = public as $$
declare v_toi uuid := nguoi_id_dang_nhap();
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;
  update thanh_vien_du_an
     set da_xem_luc = now()
   where muc_tieu_id = p_muc_tieu_id
     and nguoi_id    = v_toi
     and da_xem_luc is null;
end $$;

comment on function danh_dau_da_xem_du_an(bigint) is
  'Người được mời mở hồ sơ dự án thì lời mời thôi nhắc. Chỉ chạm đúng cột da_xem_luc, và chỉ trên dòng của chính người gọi.';

grant execute on function danh_dau_da_xem_du_an(bigint) to authenticated;


-- ─── 3. Khung nhìn `cho_ban` — thứ gì đang chờ TÔI ──────────────────────────
-- Mỗi dòng là một thứ cần người đang đăng nhập ra tay. Khung nhìn tự lọc theo
-- `nguoi_id_dang_nhap()`, không để app truyền id vào: app truyền thì app đổi
-- được, mà đây là chỗ không nên đổi được.
--
-- Cột `khoa` cố ý là `text` cho cả hai loại: loại ① mang id dự án (số), loại ②
-- mang mã cam kết (chữ, dạng 'O31'). Ép chung một kiểu để app chỉ cần một
-- đường xử lý; kiểu thật thì nhìn cột `loai` là biết.
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
  -- Không tự báo cho chính mình: trigger `tu_them_chu_du_an` tự thêm PIC vào
  -- danh sách, dòng đó không phải một lời mời.
  and v.moi_boi is distinct from v.nguoi_id
  -- Dự án đã hoàn thành hoặc đã hủy thì lời mời hết nghĩa.
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ② CAM KẾT chờ TÔI ký nhận
-- Điều kiện chép ĐÚNG luật của hàm `nhan_cam_ket` (bản 11/08, phân cấp nghiệm
-- thu) — không diễn giải lại, vì hai chỗ lệch nhau thì khối này bày ra thứ bấm
-- vào lại bị đá về:
--   · chủ cam kết CÓ cấp trên  → đúng cấp trên trực tiếp ký
--   · chủ cam kết KHÔNG có cấp trên (CEO) → chính chủ tự ký
select
  'ky-nhan'::text,
  o.ma,
  o.ten,
  n.ten,                                             -- ai đang chờ tôi ký
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
      );

alter view cho_ban set (security_invoker = on);

comment on view cho_ban is
  'Thứ đang chờ người đang đăng nhập ra tay. Hai loại: loi-moi (được mời vào dự án, chưa mở xem) và ky-nhan (cam kết đã nộp sản phẩm, đang chờ chính mình ký nhận). Khung nhìn tự lọc theo người đăng nhập. Thêm loại mới thì thêm một nhánh union all, không dựng bảng.';

grant select on cho_ban to authenticated;


-- ─── 4. Chặn ghi — trả lỗi thật, đừng im lặng ───────────────────────────────
create or replace function chan_ghi_cho_ban() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "cho_ban" là ô MÁY CHỦ TÍNH, không ghi vào được. Xử ở chỗ thật: mở hồ sơ dự án, hoặc bấm nút Đã nhận trên cam kết.';
end $$;

drop trigger if exists trg_chan_ghi_cho_ban on cho_ban;
create trigger trg_chan_ghi_cho_ban
  instead of insert or update or delete on cho_ban
  for each row execute function chan_ghi_cho_ban();


commit;


-- ════════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — mọi dòng phải ✅.
-- ════════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'thanh_vien_du_an có cột da_xem_luc, kèm chỉ mục lời mời chưa xem',
   exists (select 1 from information_schema.columns
            where table_name = 'thanh_vien_du_an' and column_name = 'da_xem_luc')
   and exists (select 1 from pg_indexes where tablename = 'thanh_vien_du_an'
                 and indexname = 'loi_moi_chua_xem')),

  (2, 'Hàm đánh dấu đã xem chạy bằng quyền định nghĩa (security definer)',
   (select prosecdef from pg_proc where proname = 'danh_dau_da_xem_du_an')),

  (3, 'thanh_vien_du_an VẪN không có policy UPDATE nào — cột chỉ đổi qua hàm',
   not exists (select 1 from pg_policies
                where tablename = 'thanh_vien_du_an' and cmd = 'UPDATE')),

  (4, 'Khung nhìn cho_ban đã có và chạy security_invoker',
   (select 'security_invoker=on' = any(coalesce(reloptions, '{}'))
      from pg_class where relname = 'cho_ban')),

  (5, 'cho_ban mang đủ sáu cột (loai · khoa · ten · ai · luc · cua_toi)',
   (select count(*) from information_schema.columns
     where table_name = 'cho_ban'
       and column_name in ('loai','khoa','ten','ai','luc','cua_toi')) = 6),

  (6, 'cho_ban CHẶN GHI, trả lỗi thật',
   exists (select 1 from pg_trigger where tgname = 'trg_chan_ghi_cho_ban'
             and not tgisinternal)),

  (7, 'Không lời mời cũ nào còn bị coi là chưa xem (đã vá một lần lúc chạy file)',
   not exists (select 1 from thanh_vien_du_an
                where da_xem_luc is null
                  and moi_luc < now() - interval '1 minute')),

  (8, 'Hàm nhan_cam_ket VẪN nguyên vẹn — file này không đụng luật ký nhận',
   exists (select 1 from pg_proc where proname = 'nhan_cam_ket' and prosecdef)),

  (9, 'KHÔNG mọc thêm bảng thông báo nào',
   to_regclass('public.thong_bao') is null and to_regclass('public.notification') is null)
)
select thu_tu,
       case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua,
       muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt sau khi chạy ───────────────────────────────────────
-- ① Thứ đang chờ chính bạn (chạy bằng tài khoản của bạn qua app, không phải
--    SQL Editor — SQL Editor không có người đăng nhập nên nó trả rỗng):
--      select * from cho_ban;
-- ② Ai đang có lời mời chưa xem (chạy được ở SQL Editor):
--      select n.ten, m.ten as du_an, v.moi_luc
--        from thanh_vien_du_an v
--        join nguoi n on n.id = v.nguoi_id
--        join muc_tieu m on m.id = v.muc_tieu_id
--       where v.da_xem_luc is null;
-- ③ Cam kết nào đang chờ ký nhận, và chờ AI ký:
--      select o.ma, o.ten, n.ten as chu, coalesce(l.ten, n.ten) as cho_nguoi_nay_ky
--        from tieu_diem o
--        join nguoi n on n.id = o.nguoi_id
--        left join nguoi l on l.id = n.leader_id
--       where o.xong and coalesce(o.output_chu,'') <> '' and o.da_nhan_luc is null;
-- ④ Quay lui trọn file này:
--      drop view if exists cho_ban;
--      drop function if exists danh_dau_da_xem_du_an(bigint);
--      alter table thanh_vien_du_an drop column if exists da_xem_luc;
