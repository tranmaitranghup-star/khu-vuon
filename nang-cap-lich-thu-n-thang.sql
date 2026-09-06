-- ═══════════════════════════════════════════════════════════════════════════
-- SỰ KIỆN HẰNG THÁNG THEO «THỨ N CỦA THÁNG» — Tracy chốt 03/09/2026 (TRI-58)
--
-- Nguyên văn lúc phát hiện: *"sao lặp hàng tuần, tháng mất hàng t2-cn của tôi
-- rồi vì có thể 2 buổi 1 tuần/tháng mà"*.
--
-- Trước tệp này, một chuỗi hằng tháng chỉ rơi vào ĐÚNG MỘT ngày mỗi tháng:
-- cột `ngay_thang` là một `smallint`, và ràng buộc `lich_lap_du_tham_so` bắt
-- `lap='thang'` phải có nó. Muốn hai buổi một tháng thì phải khai hai sự kiện
-- riêng — hai cái tên, hai màu, sửa gì cũng phải sửa hai chỗ.
--
-- ── VÌ SAO ĐI LỐI «THỨ N», KHÔNG NỚI `ngay_thang` THÀNH MẢNG ──────────────
-- Lý do Tracy nêu khi chọn: nhịp họp thật tính theo THỨ, không theo ngày.
-- *"Ngày mùng 3"* có tháng rơi vào Chủ nhật, còn *"thứ Hai đầu tháng"* thì
-- không trôi. Đây cũng đúng khuôn chuẩn quốc tế — `RRULE FREQ=MONTHLY
-- BYDAY=1TU,3TU` của RFC 5545 — chứ không phải một khuôn tự nghĩ ra.
--
-- ── VÌ SAO DÙNG LẠI CỘT `thu`, KHÔNG DỰNG BỘ THỨ HAI ─────────────────────
-- Cột `thu smallint[]` đã giữ đúng thứ mấy trong tuần, đã có ràng buộc
-- `thu <@ array[0..6]`, và giao diện `lcVeThu`/`lcBatThu` đã cho bấm sáng
-- nhiều nút. Nhánh hằng tháng cần đúng thứ ấy cộng thêm MỘT chiều nữa: tuần
-- thứ mấy. Nên tệp này thêm đúng MỘT cột, không nhân đôi thứ đã chạy được.
--
-- ── HAI LỐI CÙNG SỐNG, KHÔNG BỎ LỐI CŨ ───────────────────────────────────
-- `ngay_thang` Ở LẠI NGUYÊN VẸN. Dữ liệu đang chạy dùng nó; bỏ là đứt mọi
-- chuỗi hằng tháng đã khai. Sau tệp này, `lap='thang'` có hai lối hợp lệ:
--   • theo NGÀY  — `ngay_thang` có giá trị, `tuan_thang` rỗng   (lối cũ)
--   • theo THỨ   — `thu` và `tuan_thang` cùng không rỗng        (lối mới)
-- App đọc ra lối nào đang dùng bằng chính việc `tuan_thang` rỗng hay không,
-- nên KHÔNG có cột "kiểu" thứ ba để hai chỗ trôi lệch khỏi nhau.
--
-- Chạy tệp này lúc nào cũng được: app dò cột bằng cờ `CO_TUAN_THANG` trước
-- khi gửi, chưa chạy thì nhánh «theo thứ» nói ra tên tệp phải chạy và mọi thứ
-- còn lại chạy y nguyên — cùng lối `CO_MAU_LICH` đã đi.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① CỘT MỚI. `-1` nghĩa là TUẦN CUỐI CÙNG của tháng, đúng quy ước `BYDAY=-1FR`
--    của RFC 5545. Nó không phải "tuần thứ năm": tháng nào cũng có tuần cuối,
--    còn tuần thứ năm thì tháng có tháng không — khai `-1` là khai một buổi
--    tháng nào cũng nổ, khai `5` là khai một buổi lúc có lúc không.
--
--    `not null default '{}'` chứ không để NULL: mảng rỗng nói "lối này không
--    dùng", còn NULL nói "chưa biết" — hai nghĩa khác nhau, mà mọi chỗ đọc
--    sau đây chỉ hỏi một câu *rỗng hay không*. Bỏ `not null` là mời một nhánh
--    `is null` thứ hai vào mọi câu truy vấn về sau.
alter table lich_chung
  add column if not exists tuan_thang smallint[] not null default '{}';

-- ② GIÁ TRỊ HỢP LỆ. Bốn tuần đầu cộng tuần cuối. Không có `5`: xem lý do ở ①.
alter table lich_chung drop constraint if exists lich_tuan_thang_hop_le;
alter table lich_chung add constraint lich_tuan_thang_hop_le
  check (tuan_thang <@ array[1,2,3,4,-1]::smallint[]);

-- ③ NỚI RÀNG BUỘC THAM SỐ. Bản cũ (`nang-cap-lich-chung.sql:136-139`) bắt
--    `lap='thang'` phải có `ngay_thang`; bản này cho lối thứ hai đi qua.
--
--    ⚠️ `coalesce` KHÔNG thừa, và đây là cùng cái bẫy đã ghi ở tệp gốc:
--    `array_length('{}',1)` trả NULL chứ không trả 0, mà một CHECK cho kết quả
--    NULL thì Postgres coi là ĐẠT. Thiếu nó, một lịch «theo thứ» với danh sách
--    thứ RỖNG lọt qua ràng buộc rồi nằm im trong bảng — không bao giờ nổ một
--    buổi nào, và không một tiếng kêu.
--
--    Vế thứ ba là RÀNG BUỘC HAI CHIỀU, cùng lẽ với `lich_pham_vi_khop`: một
--    dòng KHÔNG phải hằng tháng thì `tuan_thang` phải rỗng. Thiếu vế ấy, một
--    chuỗi đổi từ 'thang' sang 'tuan' còn đeo `tuan_thang` cũ, và dòng đó đọc
--    ra hai nghĩa khác nhau ở hai chỗ lọc.
--
--    Nới thì mọi dòng đang có chắc chắn đạt, nên `add constraint` không ngã.
--    Siết mới là lúc phải soi dữ liệu trước.
alter table lich_chung drop constraint if exists lich_lap_du_tham_so;
alter table lich_chung add constraint lich_lap_du_tham_so check (
  (lap <> 'tuan'  or coalesce(array_length(thu,1),0) >= 1) and
  (lap <> 'thang' or ngay_thang is not null
                  or (coalesce(array_length(thu,1),0)        >= 1 and
                      coalesce(array_length(tuan_thang,1),0) >= 1)) and
  (lap =  'thang' or coalesce(array_length(tuan_thang,1),0)  =  0));

comment on column lich_chung.tuan_thang is
  'Chỉ có nghĩa với lap=''thang'', lối «theo thứ»: tuần thứ mấy trong tháng — '
  '1·2·3·4 và -1 là tuần cuối cùng. Đi cùng cột `thu`. Rỗng = chuỗi này dùng '
  'lối cũ «ngày mùng N» ở `ngay_thang`. Khuôn RRULE FREQ=MONTHLY BYDAY.';

-- ── TỰ KIỂM ──────────────────────────────────────────────────────────────
-- ⚠️ BẪY ĐÃ CẮN MỘT LẦN, 03/09 — ĐỌC TRƯỚC KHI VIẾT BỘ TỰ KIỂM CHO TỆP SAU.
-- Bản đầu của tệp này dùng `begin; insert …; rollback;` để thử một dòng mà
-- không để lại dấu vết. Nghe thì sạch, nhưng **trình chạy SQL của Supabase bọc
-- CẢ TỆP trong MỘT transaction**. Cú `rollback` ấy vì thế không chỉ huỷ dòng
-- thử — nó cuốn ngược mọi thứ phía trên, kể cả `alter table add column`. Kết
-- quả: chạy xong tệp mà cột không hề được tạo, và câu tự kiểm cuối cùng báo
-- *column "tuan_thang" does not exist* — một câu báo lỗi trỏ vào chỗ nó LỘ RA,
-- không trỏ vào chỗ nó HỎNG.
--
-- Luật rút ra: **trong tệp nâng cấp, KHÔNG dùng `begin`/`rollback` ở tầng ngoài
-- cùng.** Muốn thử một dòng rồi bỏ thì bọc trong một khối `do $$ … $$` — khối
-- ấy mở một transaction CON, nên bắt được lỗi và dọn được dấu vết mà không đụng
-- tới transaction bao ngoài.

-- ① Cột đã có, đúng kiểu mảng smallint, không cho NULL, mặc định mảng rỗng.
--    KHÔNG có dòng nào trả về = tệp chưa chạy tới nơi; đọc tiếp là vô nghĩa.
select column_name, data_type, udt_name, is_nullable, column_default
  from information_schema.columns
 where table_name = 'lich_chung' and column_name = 'tuan_thang';

-- ② Hai ràng buộc đã đứng đúng tên.
select conname, pg_get_constraintdef(oid)
  from pg_constraint
 where conrelid = 'lich_chung'::regclass
   and conname in ('lich_tuan_thang_hop_le','lich_lap_du_tham_so');

-- ③④⑤ BỐN PHÉP THỬ GHI, gộp một khối. Hai câu đầu PHẢI đi qua, hai câu sau
--     PHẢI bị chặn. Mỗi câu nằm trong một khối con riêng nên câu này ngã không
--     kéo theo câu kia, và dòng thử nào lọt vào bảng đều bị xoá ngay sau đó.
--     Đọc kết quả ở tab **Notices/Messages**, không phải tab Results.
do $$
declare so_dong integer;
begin
  -- ③ LỐI MỚI: hằng tháng, không `ngay_thang`, khai thứ Ba tuần 1 và tuần 3.
  begin
    insert into lich_chung (ten, gio_bat_dau, so_phut, lap, thu, tuan_thang)
      values ('__thu tu kiem TRI-58__', 540, 60, 'thang',
              array[2]::smallint[], array[1,3]::smallint[]);
    raise notice '✅ ③ loi «theo thu» ghi xuong duoc';
  exception when others then
    raise notice '❌ ③ loi «theo thu» BI CHAN: %', sqlerrm;
  end;

  -- ④ LỐI CŨ vẫn đi qua: hằng tháng theo ngày mùng N, không khai tuần nào.
  begin
    insert into lich_chung (ten, gio_bat_dau, so_phut, lap, ngay_thang)
      values ('__thu tu kiem TRI-58__', 540, 60, 'thang', 3);
    raise notice '✅ ④ loi cu «ngay mung N» van ghi xuong duoc';
  exception when others then
    raise notice '❌ ④ loi cu BI CHAN — day la mot buoc LUI: %', sqlerrm;
  end;

  -- ⑤a PHẢI NGÃ: hằng tháng «theo thứ» mà bỏ trống danh sách thứ.
  begin
    insert into lich_chung (ten, gio_bat_dau, so_phut, lap, tuan_thang)
      values ('__thu tu kiem TRI-58__', 540, 60, 'thang', array[1]::smallint[]);
    raise notice '❌ ⑤a LOT QUA — mot lich khong co thu nao van vao duoc bang';
  exception when check_violation then
    raise notice '✅ ⑤a bi chan dung boi rang buoc';
  end;

  -- ⑤b PHẢI NGÃ: hằng tuần mà còn đeo `tuan_thang` (ràng buộc hai chiều).
  begin
    insert into lich_chung (ten, gio_bat_dau, so_phut, lap, thu, tuan_thang)
      values ('__thu tu kiem TRI-58__', 540, 60, 'tuan',
              array[2]::smallint[], array[1]::smallint[]);
    raise notice '❌ ⑤b LOT QUA — mot lich hang TUAN van deo duoc danh sach tuan';
  exception when check_violation then
    raise notice '✅ ⑤b bi chan dung boi rang buoc';
  end;

  -- DỌN: mọi dòng thử lọt vào đều đi khỏi đây, không để lại dấu vết nào.
  delete from lich_chung where ten = '__thu tu kiem TRI-58__';
  get diagnostics so_dong = row_count;
  raise notice '🧹 da xoa % dong thu', so_dong;
end $$;

-- ⑥ DỮ LIỆU CŨ CÒN NGUYÊN: mọi chuỗi hằng tháng đang có vẫn ở lối «theo ngày»,
--    và cột `phai_bang_khong` đúng như tên nó — khác 0 là ràng buộc hai chiều
--    đã không được dựng.
select count(*) filter (where lap = 'thang' and ngay_thang is not null) as theo_ngay,
       count(*) filter (where lap = 'thang'
                          and coalesce(array_length(tuan_thang,1),0) > 0) as theo_thu,
       count(*) filter (where coalesce(array_length(tuan_thang,1),0) > 0
                          and lap <> 'thang')                             as phai_bang_khong
  from lich_chung;
