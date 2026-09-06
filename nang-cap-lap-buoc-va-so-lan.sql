-- ═══════════════════════════════════════════════════════════════════════════
-- BƯỚC NHẢY VÀ SỐ LẦN CỦA LUẬT LẶP — Tracy chốt 03/09/2026 (TRI-66)
--
-- Tracy đưa ảnh hộp «Lặp lại tuỳ chỉnh» của Lịch Google: *"lặp lại hàng tháng
-- thử học hỏi gg calendar này"*. Đối chiếu xong thì app thiếu đúng hai thứ
-- trong ảnh — lối «thứ N của tháng» đã lên sóng cùng ngày bằng TRI-58.
--
--   ① BƯỚC NHẢY  — *"Lặp lại mỗi 1 tháng"*, đổi được thành 2 hay 3.
--      Hôm nay mọi chuỗi đều nhảy đúng một bước: hằng tuần là tuần nào cũng
--      có, hằng tháng là tháng nào cũng có. Họp quý và giao ban cách tuần
--      không khai được, phải khai thành nhiều chuỗi rời.
--
--   ② SỐ LẦN     — *"Sau 12 lần xuất hiện"*, cạnh «Không bao giờ» và
--      «Vào ngày». App có hai nấc đầu, thiếu nấc thứ ba.
--
-- ── VÌ SAO `so_lan` KHÔNG PHẢI MỘT LUẬT THỨ HAI ──────────────────────────
-- `lcHopNgay` trả lời một câu hỏi về MỘT ngày: *buổi này có nổ vào ngày ấy
-- không*. Nó không có bối cảnh chuỗi, nên "lần thứ mấy" là câu nó không trả
-- lời được nếu không đếm lại từ đầu chuỗi ở mọi ngày của mọi dải — một vòng
-- lặp lồng trong vòng lặp, cho một con số không đổi.
--
-- Nên `so_lan` KHÔNG gác luật nổ ngày. Nó giữ Ý ĐỊNH của người khai, còn
-- `ngay_ket_thuc` giữ LUẬT — và hàm lưu suy `ngay_ket_thuc` ra từ `so_lan`
-- ở mỗi lần lưu, nên hai cột không trôi lệch được: sửa thứ, sửa bước, sửa
-- ngày bắt đầu thì ngày kết thúc tính lại theo. Một nguồn luật, một chỗ suy.
--
-- Chạy tệp này lúc nào cũng được: app dò cột bằng cờ `CO_BUOC_LAP` trước khi
-- gửi. Chưa chạy thì hai ô mới không bày ra, ô chọn nói ra tên tệp, và mọi
-- chuỗi đang khai chạy y nguyên — cùng lối `CO_TUAN_THANG` vừa đi hôm nay.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① BƯỚC NHẢY. `not null default 1` chứ không để NULL: mọi dòng đang có đều
--    nhảy một bước, đó là một dữ kiện đã biết chứ không phải một chỗ trống.
--    Đặt NULL là mời một nhánh `coalesce(buoc,1)` vào mọi chỗ đọc về sau.
--
--    Trần 30 là con số của Lịch Google ở đơn vị tháng — không phải luật vật
--    lý, chỉ là chỗ dừng để một cú gõ nhầm không dựng ra chuỗi nhảy 900 tháng.
alter table lich_chung
  add column if not exists buoc smallint not null default 1;

alter table lich_chung drop constraint if exists lich_buoc_hop_le;
alter table lich_chung add constraint lich_buoc_hop_le
  check (buoc between 1 and 30);

-- ② SỐ LẦN. Đây là cột DUY NHẤT trong bảng được phép NULL mang nghĩa "không
--    dùng nấc này" — vì ba nấc kết thúc loại trừ nhau và hai nấc kia đã có
--    chỗ riêng: «Không bao giờ» là `ngay_ket_thuc` null, «Vào ngày» là
--    `ngay_ket_thuc` có giá trị. Nấc thứ ba cần một chỗ nói ra rằng con số
--    ngày kia là SUY RA, không phải người ta gõ.
alter table lich_chung
  add column if not exists so_lan smallint;

alter table lich_chung drop constraint if exists lich_so_lan_hop_le;
alter table lich_chung add constraint lich_so_lan_hop_le
  check (so_lan is null or so_lan between 1 and 99);

-- ③ HAI CHIỀU. `so_lan` chỉ có nghĩa khi chuỗi CÓ lặp, và khi đã suy ra được
--    một ngày kết thúc. Một dòng `lap='khong'` còn đeo `so_lan` cũ đọc ra hai
--    nghĩa ở hai chỗ — cùng cái bẫy `lich_pham_vi_khop` đã chặn ở tệp gốc.
alter table lich_chung drop constraint if exists lich_so_lan_khop;
alter table lich_chung add constraint lich_so_lan_khop
  check (so_lan is null or (lap <> 'khong' and ngay_ket_thuc is not null));

comment on column lich_chung.buoc is
  'Bước nhảy của luật lặp: 2 = cách một lượt (mỗi 2 tuần, mỗi 2 tháng). '
  'Đơn vị lấy theo `lap`. Mặc định 1 = lượt nào cũng có.';
comment on column lich_chung.so_lan is
  'Ý định "dừng sau N lần" của người khai. KHÔNG gác luật nổ ngày — luật nằm '
  'ở `ngay_ket_thuc`, và hàm lưu ở máy khách suy nó ra từ cột này mỗi lần lưu.';

-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ KIỂM — chạy cả khối, bốn dòng phải cùng ✅.
-- ═══════════════════════════════════════════════════════════════════════════
select
  (select count(*) from information_schema.columns
    where table_name = 'lich_chung' and column_name in ('buoc','so_lan')) = 2
    as "① hai cột đã có",
  (select bool_and(buoc = 1) from lich_chung)  is not false
    as "② mọi dòng cũ nhảy một bước",
  (select count(*) from pg_constraint
    where conrelid = 'lich_chung'::regclass
      and conname in ('lich_buoc_hop_le','lich_so_lan_hop_le','lich_so_lan_khop')) = 3
    as "③ ba ràng buộc đã gắn",
  (select count(*) from lich_chung where so_lan is not null and ngay_ket_thuc is null) = 0
    as "④ không dòng nào có số lần mà thiếu ngày kết thúc";
