-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bẫy `trg_kiem_output_cam_ket`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: CAM KẾT CÓ CHỖ THU HOẠCH OUTPUT  (việc 49 — Tracy giao 11/08/2026)
-- ═══════════════════════════════════════════════════════════════════════════
--
-- ĐỊNH NGHĨA LÕI Tracy chốt 08/08: *"đầu ra của cam kết là 1 output nộp cho
-- cấp trên"*. Trước file này, đóng cam kết chỉ là bật cờ `xong = true` — tức
-- mắt xích quan trọng nhất của cả hệ chưa có chỗ hiện hữu trong cơ sở dữ liệu.
-- Task đã có ô Output từ ba cửa ra deepwork; cam kết thì chưa có gì.
--
-- BA CÂU TRACY CHỐT 11/08, file này làm đúng cả ba:
--   ① AI ĐỌC   — cả ROVA đọc được (policy `doc_tieudiem` sẵn có);
--                chỉ CHỦ cam kết sửa được (policy `sua_tieudiem` sẵn có).
--   ② DẠNG     — một ô chữ BẮT BUỘC, link TUỲ Ý. "Bắt buộc" được ép ở tầng
--                cơ sở dữ liệu bằng trigger, không chỉ nhắc bằng chữ trên màn.
--   ③ NGHIỆM THU — có nút "Đã nhận", và người bấm phải là NGƯỜI KHÁC. Đây là
--                mắt xích biến *"tôi tự khai xong"* thành *"có người xác nhận
--                xong"* — nền chống tự chấm cho toàn bộ mạng lưới điểm (việc 48).
--
-- ✅ ĐÃ CHẠY XONG trên Supabase 11/08 — Tracy báo *"true hết r nha"* cả sáu dòng.
--
-- ⛔ MỤC 3 CỦA FILE NÀY ĐÃ BỊ THAY THẾ, ĐỪNG ĐỌC NÓ NHƯ LUẬT ĐANG CHẠY.
--    Lúc viết file, bảng `nguoi` chưa có chỗ khai cấp trên, nên hàm
--    `nhan_cam_ket` ở mục 3 chạy một LUẬT TẠM: ai cũng ký được, trừ chính chủ.
--    Ngay chiều 11/08 Tracy chốt *"hiện tại chỉ có Andy là cấp trên của 6 người
--    còn lại"* → `nang-cap-phan-cap-nghiem-thu.sql` thêm cột `nguoi.leader_id`
--    và ĐỊNH NGHĨA LẠI hàm ấy để soi đúng cấp trên.
--    Chạy lại file này là DỰNG DẬY LUẬT TẠM và xoá mất phân cấp trong hàm. Nếu
--    buộc phải chạy lại (vd dựng kho mới), chạy TIẾP file phân cấp ngay sau đó.
--
-- CÁCH CHẠY: dán trọn file vào SQL Editor của Supabase rồi Run. Chạy lại nhiều
-- lần vô hại. Xong thì nhìn bảng tự kiểm ở cuối — cột `dat` phải đúng cả SÁU dòng.
--
-- CHẠY SAU: `schema.sql` → `nang-cap-khu-vuon.sql` → `nang-cap-luong-rieng-tung-nguoi.sql`
--           → `nang-cap-dem-o-may-chu.sql` → file này.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Năm cột mới trên bảng tieu_diem ─────────────────────────────────────
-- `nop_luc` và `da_nhan_luc` để MÁY CHỦ đóng dấu, không nhận giờ từ máy người
-- dùng: đồng hồ máy lệch hoặc bị chỉnh tay thì mọi phép đo tốc độ nộp về sau
-- đều sai, mà loại sai đó không cách nào phát hiện lại được.
alter table tieu_diem add column if not exists output_chu   text;
alter table tieu_diem add column if not exists output_link  text;
alter table tieu_diem add column if not exists nop_luc      timestamptz;
alter table tieu_diem add column if not exists da_nhan_boi  uuid references nguoi (id);
alter table tieu_diem add column if not exists da_nhan_luc  timestamptz;

comment on column tieu_diem.output_chu  is 'Output nộp lại khi đóng cam kết. BẮT BUỘC — trigger kiem_output_cam_ket ép.';
comment on column tieu_diem.output_link is 'Link kèm output (file, sheet, bài đăng…). Tuỳ ý.';
comment on column tieu_diem.nop_luc     is 'Máy chủ đóng dấu lúc output được nộp lần đầu.';
comment on column tieu_diem.da_nhan_boi is 'Ai nghiệm thu. Luôn KHÁC chủ cam kết — hàm nhan_cam_ket ép.';
comment on column tieu_diem.da_nhan_luc is 'Máy chủ đóng dấu lúc nghiệm thu.';


-- ─── 2. Trigger: không có output thì không đóng được cam kết ────────────────
-- CỐ Ý LÀ MỘT TRIGGER RIÊNG, không nhét thêm vế vào `kiem_o_xong` đang có ở
-- `nang-cap-khu-vuon.sql`. Hai lẽ: ① luật ở đó là *"chưa khai tiêu chí thì chưa
-- tick xong"* — một luật khác, của một đợt khác; ② sửa hàm ấy ở đây là cùng
-- một luật nằm ở hai file, ngày nào chạy lại file cũ là luật output biến mất
-- không kèn không trống. Trigger riêng thì chạy lại file nào cũng không đụng nhau.
create or replace function kiem_output_cam_ket()
returns trigger language plpgsql
as $$
begin
  -- Chỉ soi lúc CHUYỂN sang xong. Cam kết đóng từ trước file này (output rỗng)
  -- vẫn sửa được bình thường, không bị khoá cứng vì một luật ra đời sau.
  if new.xong and not coalesce(old.xong, false) then
    if length(trim(coalesce(new.output_chu, ''))) = 0 then
      raise exception 'Chưa nộp output thì chưa đóng cam kết được';
    end if;
  end if;

  -- Đóng dấu giờ nộp LẦN ĐẦU. Sửa lại output về sau không dời dấu này — nếu
  -- dời thì mọi phép đo "nộp đúng hạn hay muộn" đều tự chữa lành bằng một lần
  -- sửa chính tả, tức không đo được gì nữa.
  if length(trim(coalesce(new.output_chu, ''))) > 0
     and length(trim(coalesce(old.output_chu, ''))) = 0 then
    new.nop_luc := coalesce(new.nop_luc, now());
  end if;

  return new;
end $$;

drop trigger if exists trg_kiem_output_cam_ket on tieu_diem;
create trigger trg_kiem_output_cam_ket before update on tieu_diem
  for each row execute function kiem_output_cam_ket();


-- ─── 3. Hàm nghiệm thu — nút "Đã nhận" ──────────────────────────────────────
-- VÌ SAO PHẢI LÀ MỘT HÀM, không update thẳng bảng từ app:
--   ① policy `sua_tieudiem` chỉ cho CHỦ sửa dòng của mình — mà người nghiệm thu
--      theo định nghĩa là người khác, nên update thẳng luôn bị từ chối;
--   ② RLS của Postgres chặn theo DÒNG chứ không theo CỘT. Nới policy cho người
--      khác ghi được dòng ấy là họ ghi được LUÔN CẢ `output_chu` — tức sửa được
--      lời khai của nhau. Hàm `security definer` khoanh đúng hai cột cần chạm.
create or replace function nhan_cam_ket(p_ma text)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi  uuid := nguoi_id_dang_nhap();
  v_chu  uuid;
  v_out  text;
  v_xong boolean;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, output_chu, xong into v_chu, v_out, v_xong
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if not coalesce(v_xong, false) then
    raise exception 'Cam kết chưa đóng thì chưa nghiệm thu được';
  end if;
  if length(trim(coalesce(v_out, ''))) = 0 then
    raise exception 'Cam kết này chưa có output để nhận';
  end if;
  -- ⬇️ ĐÂY là mệnh đề duy nhất phải sửa ngày nào có bảng phân cấp.
  if v_chu = v_toi then
    raise exception 'Không tự nghiệm thu cho chính mình được';
  end if;

  update tieu_diem
     set da_nhan_boi = v_toi, da_nhan_luc = now()
   where ma = p_ma;
end $$;

comment on function nhan_cam_ket(text) is
  'Nút "Đã nhận": ghi chữ ký nghiệm thu lên một cam kết đã đóng. Người bấm phải là thành viên và KHÔNG phải chủ cam kết.';

grant execute on function nhan_cam_ket(text) to authenticated;


-- ─── 4. Khung nhìn tien_do_o phải mang theo năm cột mới ─────────────────────
-- ⚠️ Phải XOÁ rồi tạo lại chứ không `create or replace`: lệnh đó chỉ cho THÊM
--    cột vào CUỐI danh sách, mà giữ nguyên thứ tự cũ thì Postgres vẫn có thể
--    hiểu nhầm là đang đổi tên cột và báo `42P16`. Dựng lại từ đầu là hết đoán.
--    Không khung nhìn nào đọc `tien_do_o`, nên xoá nó không kéo theo cái gì.
--
-- Phần thân giữ NGUYÊN VĂN bản ở `nang-cap-dem-o-may-chu.sql` — chỉ thêm năm
-- cột output vào danh sách chọn và danh sách gom nhóm. Đừng nhân tiện sửa phép
-- đếm ở đây: nó là bản đã soi kỹ đợt 08/08, sửa ở hai file là hai bản lệch nhau.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,

  -- Năm cột output (11/08) — app đọc thẳng từ đây, không hỏi bảng thô lần nữa.
  o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,

  -- Ba cột cũ, giữ nguyên: đếm CÂY (task đã có phiên deepwork thật).
  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  -- Hai cột đếm TASK, viết bằng truy vấn con vô hướng — KHÔNG thêm `left join`
  -- thứ hai vào `task`, vì nó sẽ nhân chéo với `vuon_cay` đang join sẵn ở dưới
  -- và làm ba cột cây phía trên phồng lên sai bét.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma)     as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.trang_thai = 'Done')                                 as so_xong,
  -- Năm ô "còn mở" phải khớp ĐÚNG hằng TT_MO bên app (index.html).
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Confirm','Doing','Miss','Chua_xong','Nghen'))
                                                                  as so_kho

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
         o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc;

-- ⚠️ BẮT BUỘC. `drop view` xoá luôn thiết lập này; quên bật lại là khung nhìn
-- chạy bằng quyền người TẠO nó, tức vượt mặt RLS và ai cũng đọc được của người
-- khác. Bài tự kiểm ③ dưới đây soi đúng chỗ này.
alter view tien_do_o set (security_invoker = on);

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm MỌI task; năm cột output_* / da_nhan_* là phần thu hoạch khi đóng cam kết (việc 49).';

-- PostgREST giữ một bản chụp lược đồ trong bộ nhớ. Thêm hàm mới mà không nhắc
-- thì app gọi `nhan_cam_ket` có thể ăn 404 cho tới lần nạp lại kế tiếp.
notify pgrst, 'reload schema';


-- ─── 5. Tự kiểm — chạy xong nhìn bảng này, cột `dat` phải ĐÚNG cả SÁU dòng ──
select * from (values
  (1, 'tieu_diem có đủ năm cột output',
   (select count(*) from information_schema.columns
     where table_name = 'tieu_diem'
       and column_name in ('output_chu','output_link','nop_luc','da_nhan_boi','da_nhan_luc')) = 5),

  (2, 'tien_do_o đã mang năm cột đó ra cho app đọc',
   (select count(*) from information_schema.columns
     where table_name = 'tien_do_o'
       and column_name in ('output_chu','output_link','nop_luc','da_nhan_boi','da_nhan_luc')) = 5),

  (3, 'tien_do_o vẫn bật security_invoker — không vượt mặt RLS',
   (select 'security_invoker=on' = any(coalesce(reloptions, '{}'))
      from pg_class where relkind = 'v' and relname = 'tien_do_o')),

  (4, 'tien_do_o KHÔNG mất cột nào của bản cũ (app đang đọc đủ 16 cột kia)',
   (select count(*) from information_schema.columns
     where table_name = 'tien_do_o'
       and column_name in ('ma','nguoi_id','ten','luong','qua','mau','ten_loai',
                           'tieu_chi_xong','han','xong','ngay_gieo','ngay_xong',
                           'nguoi_tick','so_task','so_xong','so_kho')) = 16),

  (5, 'Trigger ép output đã gắn vào bảng',
   exists (select 1 from pg_trigger
            where tgname = 'trg_kiem_output_cam_ket' and not tgisinternal)),

  (6, 'Hàm nghiệm thu nhan_cam_ket đã có và chạy bằng quyền định nghĩa',
   exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
            where p.proname = 'nhan_cam_ket' and n.nspname = 'public' and p.prosecdef))
) as t(so, muc, dat);
