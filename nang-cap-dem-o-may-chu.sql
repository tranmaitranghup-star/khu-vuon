-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: ba khung nhìn đếm ô — nhiều tệp sau viết đè
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ⚠️ TRẦN PHIÊN LÀ 180 PHÚT, KHÔNG PHẢI 120 (sửa 28/08).
-- Con số này khai ở `public/index.html` dòng 10107 (`DW_TRAN_PHUT = 180`) và ở
-- `nang-cap-tran-180-phut.sql`, nơi đổi CẢ NĂM khung nhìn sang 180. File này viết
-- trước đợt ấy nên còn giữ 120.
-- Vì cả ba file đều dùng `create or replace view`, chạy file này SAU file 180 là
-- hạ trần về 120 TRONG IM LẶNG — không báo lỗi, chỉ ra số phút thiếu. Đã suýt
-- dính một lần: file này nằm trong danh sách "chờ Tracy chạy".

-- ═══════════════════════════════════════════════════════════════════════════
-- ĐẾM Ở MÁY CHỦ — để app không phải kéo dòng về chỉ để đếm
-- Tracy duyệt 08/08/2026. Chạy MỘT LẦN trên Supabase › SQL Editor.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO CÓ FILE NÀY
--
-- Thiết lập `Max rows` của dự án đang là 1000 (Tracy kiểm 08/08). Nghĩa là mọi
-- câu `.limit(2000)` trong app THẬT RA chỉ lấy về 1000 dòng — máy chủ cắt phần
-- còn lại, KHÔNG báo lỗi gì. App cứ thế đếm trên phần bị cắt và hiện ra số nhỏ
-- hơn sự thật, không ai biết.
--
-- Chỗ chạm trần sớm nhất là tab Cam kết ở chế độ "Cả ROVA": nó kéo task của cả
-- 12 người về máy chỉ để đếm "7/11 task xong" cho từng cam kết.
--   Nhịp thật đo được: 22 task / 4 ngày / 1 người ≈ 5,5 task/người/ngày.
--   12 người → 66 task/ngày → 1000 ÷ 66 ≈ 15 NGÀY là số bắt đầu sai.
--
-- Cách chữa: đừng gửi dòng đi nữa. Postgres đếm ngay tại chỗ và trả về đúng
-- HAI CON SỐ. Sau file này, chế độ Cả ROVA không cần một dòng task nào — trần
-- 1000 không còn chạm tới nó được, dù một năm hay mười năm.
--
-- ⚠️ PHÁT HIỆN PHỤ, file này chữa luôn:
-- `nang-cap-khu-vuon.sql` (dòng 145) định nghĩa lại tien_do_o mà THIẾU hai cột
-- `nguoi_id` và `han`, trong khi app đang lọc theo `nguoi_id` và đọc `han`.
-- Postgres không cho `create or replace view` bỏ cột, nên câu đó chắc chắn đã
-- BÁO LỖI lúc chạy và khung nhìn cũ được giữ nguyên — app vẫn chạy được là nhờ
-- vậy. File này viết lại trọn vẹn nên hết mập mờ: từ đây chỉ còn MỘT định nghĩa
-- đúng, và nó nằm ở đây.
--
-- AN TOÀN: chỉ đụng một khung nhìn, không đụng bảng, không đụng dữ liệu. Không
-- khung nhìn hay hàm nào khác đọc `tien_do_o` (đã tìm khắp kho .sql), nên
-- `drop` không kéo theo thứ gì. Chạy lại nhiều lần vẫn ra cùng kết quả.


-- ─── 1. Dựng lại tien_do_o với đủ cột + hai cột đếm mới ─────────────────────
-- Dùng `drop` rồi `create` thay vì `create or replace`: replace không cho đổi
-- thứ tự hay bỏ cột, mà ta thì không biết chắc trên máy chủ đang là bản nào
-- trong hai bản cũ. Dựng lại từ đầu là hết đoán.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,

  -- Ba cột cũ, giữ nguyên: đếm CÂY (task đã có phiên deepwork thật).
  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  -- ─── HAI CỘT MỚI: đếm TASK (mọi task, kể cả chưa từng deepwork) ───────────
  -- Viết bằng TRUY VẤN CON VÔ HƯỚNG, cố ý KHÔNG dùng thêm một `left join`.
  -- Join thứ hai vào `task` sẽ nhân chéo với `vuon_cay` đang join sẵn ở dưới,
  -- làm ba cột cũ (cay_co_qua, cay_dang_lon, tong_phut) phồng lên sai bét.
  -- Truy vấn con chạy độc lập từng dòng nên không đụng gì tới chúng.
  --
  -- Lọc theo CẢ `nguoi_id` lẫn `tieu_diem_ma` vì hai lẽ: ① khớp đúng chỉ mục
  -- `task_theo_nguoi_camket (nguoi_id, tieu_diem_ma)` đã có sẵn, nên không phải
  -- thêm chỉ mục mới · ② nếu có ngày nào dữ liệu lệch (task nằm trong cam kết
  -- của người khác) thì con số vẫn đúng theo từng người, không lẫn sang ai.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma)     as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.trang_thai = 'Done')                                 as so_xong,
  -- Việc đang nằm trong kho: đã nghĩ ra, chưa hẹn ngày làm, chưa đóng.
  -- Năm ô "còn mở" phải khớp ĐÚNG hằng TT_MO bên app (index.html). Sửa một bên
  -- mà quên bên kia là con số ở đây lệch với con số app tự đếm ở chỗ khác.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Confirm','Doing','Miss','Chua_xong','Nghen'))
                                                                  as so_kho

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick;


-- ─── 1b. Khung nhìn đếm task theo từng ô trạng thái ─────────────────────────
-- Màn Hôm nay bày phân rã đủ sáu ô dưới mỗi cam kết ("3 Doing · 2 Miss · 8
-- Done…"). Trước đây app kéo tối đa 2000 dòng task về rồi tự đếm — mà trần thật
-- là 1000, nên sau ~182 ngày phân rã bắt đầu thiếu, không báo gì.
--
-- ⚠️ CHỖ NÀY TỪNG SUÝT SAI. Bản nháp đầu chỉ viết `where tieu_diem_ma is not
-- null` rồi tự khen là "trần tự nhiên 27 dòng mỗi người". SAI: cam kết ĐÃ ĐÓNG
-- không bao giờ rời khỏi khung nhìn, mà mỗi người đóng chừng một cam kết mỗi
-- tuần → 12 người × 52 tuần × tới 9 ô trạng thái là vượt 1000 trong năm đầu.
-- Đợt soi đối kháng 08/08 bắt được, hai tác tử phản biện đều không bác bỏ nổi.
--
-- CHỮA: chỉ gộp task của cam kết CÒN MỞ. Đây không phải cắt bớt cho gọn — màn
-- Hôm nay vốn CHỈ bày cam kết còn mở (hàm `luongDangGieo()` lọc `!xong` và luống
-- 1–3), nên cam kết đã đóng ở đây là dữ liệu không ai đọc. Số của cam kết đã
-- đóng vẫn còn nguyên, lấy từ `tien_do_o.so_task`.
--
-- Nay trần mới là THẬT: 12 người × 3 cam kết mở × 9 ô trạng thái = 324 dòng,
-- và nó KHÔNG lớn theo thời gian — đóng một cam kết là một cam kết rời đi.
create or replace view dem_task_theo_o as
select
  t.nguoi_id,
  t.tieu_diem_ma,
  t.trang_thai,
  count(*)                               as so,
  -- Việc chưa hẹn ngày = đang nằm trong kho. Đếm luôn ở đây để app khỏi hỏi
  -- thêm câu nữa; ô nào không phải trạng thái mở thì app tự bỏ qua cột này.
  count(*) filter (where t.ngay is null) as so_kho
from task t
join tieu_diem o
  on o.ma = t.tieu_diem_ma and o.nguoi_id = t.nguoi_id
where not o.xong
  and o.luong between 1 and 3
group by t.nguoi_id, t.tieu_diem_ma, t.trang_thai;

alter view dem_task_theo_o set (security_invoker = on);

comment on view dem_task_theo_o is
  'Đếm task theo (người · cam kết còn mở · trạng thái). Chỉ gộp cam kết CHƯA đóng nên số dòng không lớn theo thời gian: nhiều nhất 12 người × 3 cam kết × 9 ô = 324. Thay cho việc app kéo 2000 dòng task về máy để tự đếm.';


-- ─── 1c. Giờ deepwork gộp theo ngày ─────────────────────────────────────────
-- Tab Timeline hiện "số giờ tập trung" và "số phiên" của một kỳ. Trước đây app
-- kéo 500 phiên gần nhất về rồi tự cộng — chọn kỳ "Toàn bộ từ trước tới nay" là
-- con số đóng băng ở trần sau khoảng 161 ngày, không báo gì.
--
-- ⚠️ VÌ SAO KHÔNG DÙNG LẠI `cham_theo_ngay` ĐÃ CÓ SẴN. Nhìn qua thì nó làm đúng
-- việc này, nhưng nó KHÔNG cùng ngữ nghĩa với con số app đang hiện, và trong kho
-- lại có hai bản khác nhau nên không chắc bản nào đang sống:
--   · `nang-cap-deepwork-tu-do.sql` — chặn 120 phút/phiên VÀ bỏ phiên gắn NHỊP
--     (`task_id is not null`), tức phiên deepwork của việc lặp lại bị loại.
--   · `nang-cap-khu-vuon.sql`       — chặn 30 phút/phiên, không bỏ phiên nhịp.
-- Dùng bản nào cũng ra một con số KHÁC với `phutPhien()` bên app (chặn ở
-- DW_TRAN_PHUT = 120, tính cả phiên nhịp). Đổi số mà không ai đòi thì đó là lỗi,
-- không phải nâng cấp. Nên dựng riêng một khung nhìn khớp đúng app.
--
-- ⚠️ Số 120 dưới đây phải bằng hằng DW_TRAN_PHUT trong index.html. Sửa một bên
-- mà quên bên kia là hai màn hiện hai con số giờ khác nhau.
--
-- Trần tự nhiên: một dòng cho mỗi (người × ngày). 12 người × 365 ngày = 4.380
-- dòng một năm — nhưng app luôn lọc theo `nguoi_id` và theo kỳ, nên một lần hỏi
-- nhiều nhất là 365 dòng. Không chạm nổi trần 1000.
create or replace view gio_deepwork_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.ket_thuc is not null
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;

alter view gio_deepwork_theo_ngay set (security_invoker = on);

comment on view gio_deepwork_theo_ngay is
  'Giờ và số phiên deepwork gộp theo (người · ngày giờ Việt Nam). Khớp ĐÚNG hàm phutPhien() bên app: chặn 120 phút mỗi phiên, tính cả phiên gắn nhịp. Cố ý không dùng lại cham_theo_ngay vì khung nhìn đó có hai bản và cả hai đều khác ngữ nghĩa này.';


-- ─── 2. Bật lại quyền người gọi ─────────────────────────────────────────────
-- BẮT BUỘC. `drop view` xoá luôn thiết lập này; quên bật lại là khung nhìn chạy
-- bằng quyền người TẠO nó, tức vượt mặt RLS và ai cũng đọc được của người khác.
-- Bài tự kiểm ⑨ trong `va-chot-chan-truoc-khi-mo-doi.sql` soi đúng chỗ này.
alter view tien_do_o set (security_invoker = on);

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm MỌI task. Có hai cột đếm này thì app không phải kéo dòng task về máy để tự đếm — đó là thứ từng làm chế độ Cả ROVA sai số sau ~15 ngày.';


-- ─── 3. Tự kiểm — chạy xong nhìn bảng này, cột `dat` phải ĐÚNG cả BẢY dòng ──
-- ⚠️ Câu ④ ở bản nháp đầu tự kiểm chính nó: nó viết lại y nguyên phép đếm của
-- khung nhìn bằng cú pháp khác, nên luôn ra ĐÚNG kể cả khi cả hai cùng sai. Đợt
-- soi 08/08 bắt được. Nay ④ đối chiếu với một phép đếm ĐỘC LẬP trên bảng thô.
select * from (values
  (1, 'tien_do_o có đủ ba cột đếm mới',
   (select count(*) from information_schema.columns
     where table_name = 'tien_do_o'
       and column_name in ('so_task','so_xong','so_kho')) = 3),

  (2, 'tien_do_o vẫn còn nguoi_id và han (app cần hai cột này)',
   (select count(*) from information_schema.columns
     where table_name = 'tien_do_o' and column_name in ('nguoi_id','han')) = 2),

  (3, 'Cả BA khung nhìn đều bật security_invoker — không vượt mặt RLS',
   (select count(*) from pg_class
     where relkind = 'v'
       and relname in ('tien_do_o','dem_task_theo_o','gio_deepwork_theo_ngay')
       and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 3),

  (4, 'Tổng so_task khớp tổng số task có cam kết trên bảng thô',
   (select (select coalesce(sum(so_task), 0) from tien_do_o)
         = (select count(*) from task t join tieu_diem o
              on o.ma = t.tieu_diem_ma and o.nguoi_id = t.nguoi_id))),

  (5, 'Hai khung nhìn mới đã tồn tại',
   (select count(*) from pg_class
     where relkind = 'v'
       and relname in ('dem_task_theo_o','gio_deepwork_theo_ngay')) = 2),

  (6, 'dem_task_theo_o chỉ chứa cam kết CÒN MỞ (đây là thứ giữ nó khỏi phình)',
   not exists (select 1 from dem_task_theo_o d
                 join tieu_diem o on o.ma = d.tieu_diem_ma
                where o.xong)),

  (7, 'gio_deepwork_theo_ngay chặn đúng 120 phút mỗi phiên, khớp DW_TRAN_PHUT bên app',
   coalesce((select bool_and(g.phut <= 120 * g.so_phien)
               from gio_deepwork_theo_ngay g), true))
) as t(so, muc, dat);
