-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.ca_ngay`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — SỰ KIỆN CẢ NGÀY TRẢI NHIỀU NGÀY
--                                                  (Tracy duyệt 03/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-lich-chung.sql` (tệp dựng ba bảng lịch).
--            Không phải chạy trước khi đẩy mã: app dò cột bằng cờ `CO_NHIEU_NGAY`
--            trong `doCotGio()` rồi mới quyết bày ô tick hay không.
--
-- ⚠️ TỆP NÀY BAO TRỌN `nang-cap-doi-buoi-rieng.sql`. Chưa chạy tệp kia thì
--    KHÔNG cần chạy nữa — mọi thứ tệp kia làm đều nằm trong đây. Đã chạy rồi
--    thì cũng không sao, tệp này chạy đè lên vô hại. Nhưng đừng chạy tệp kia
--    SAU tệp này: nó dựng lại ràng buộc `ngoaile_doi_du_tham_so` theo bản
--    thiếu `so_ngay_moi`, và lúc ấy một cú nới mép dải bị máy chủ chặn.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 03/09: *"tôi không add được sự kiện kéo dài nhiều ngày như gg calendar"*.
--
-- Đi công tác 12→15/09, hội thảo hai ngày, nghỉ lễ bốn ngày — Lịch Google gọi
-- đây là *all-day event*, bày thành một dải nằm ngang trên đầu lưới và không
-- chiếm một ô giờ nào. App chưa có chỗ chứa thứ ấy.
--
-- VÌ SAO CHƯA CÓ: một dòng `lich_chung` khai buổi bằng `gio_bat_dau` cộng
-- `so_phut`, mà `so_phut` chặn ở 1440 — đúng một ngày, không hơn. Hai cột
-- `ngay_bat_dau`/`ngay_ket_thuc` trông giống một khoảng nhưng KHÔNG phải: chúng
-- là khoảng hiệu lực của LUẬT LẶP, thứ `lcHopNgay` dùng để biết luật còn nổ
-- buổi nữa hay thôi. Mượn chúng làm độ dài một buổi là để hai nghĩa chồng lên
-- một chỗ, và chuỗi lặp mất luôn đường khai ngày dừng.
--
-- ─── LỜI GIẢI: HAI CỘT, VÀ ĐỘ DÀI ĐO BẰNG SỐ NGÀY ───────────────────────────
--   ca_ngay  — buổi này không có giờ, trải trọn ngày.
--   so_ngay  — MỘT LƯỢT trải mấy ngày, tính cả ngày đầu. 1 là mặc định.
--
-- VÌ SAO `so_ngay` CHỨ KHÔNG PHẢI MỘT CỘT `ngay_cuoi`: một dòng `lich_chung` là
-- một LUẬT LẶP, không phải một buổi. "Nghỉ lễ hai ngày, hằng năm" bung ra nhiều
-- lượt, mỗi lượt một cặp ngày khác nhau — một ngày cuối tuyệt đối chỉ nói đúng
-- cho lượt đầu tiên rồi sai với mọi lượt sau. Độ dài tương đối thì đúng với mọi
-- lượt, và nó cũng chính là hình dạng `so_phut` đang dùng cho buổi có giờ.
--
-- ⚠️ SỐ NGÀY Ở ĐÂY ĐẾM CẢ NGÀY ĐẦU — 12→15/09 là `so_ngay = 4`. Lịch Google
-- lưu khác: `end` của họ là ngày SAU ngày cuối (16/09), vì API của họ khai rõ
-- *"the (exclusive) end time of the event"*. Cách ấy đúng cho họ nhưng KHÔNG
-- chép vào đây: mọi cột ngày khác trong app này đều là ngày thật người ta nhìn
-- thấy, và trộn hai lối đếm vào một bảng là đặt sẵn một chỗ lệch một ngày cho
-- phiên sau. Quy đổi sang lối của họ, nếu có ngày cần xuất ra tệp lịch, là việc
-- của đúng chỗ xuất ấy.
--
-- ─── BUỔI CÓ GIỜ VẪN CHỈ NẰM TRONG MỘT NGÀY ─────────────────────────────────
-- Ràng buộc `lich_ca_ngay_khop` giữ `so_ngay = 1` cho mọi dòng không phải cả
-- ngày. Sự kiện có giờ vắt qua nửa đêm (23h hôm nay → 2h sáng mai) là một việc
-- KHÁC, chưa làm lần này: máy khách đang kẹp cứng mọi khối ở mốc 24h tại bốn
-- chỗ, và mở cột ra trước khi bốn chỗ ấy biết tính sang ngày hôm sau thì dữ
-- liệu nói một đằng còn lưới vẽ một nẻo.
-- ============================================================================

begin;

-- ═══ 1. HAI CỘT MỚI TRÊN CHUỖI ═════════════════════════════════════════════
alter table lich_chung add column if not exists ca_ngay boolean  not null default false;
alter table lich_chung add column if not exists so_ngay smallint not null default 1;

-- Trần 366 = trọn một năm nhuận. Một "sự kiện" dài hơn thế thì nó không còn là
-- sự kiện nữa mà là một giai đoạn, và app đã có dự án cho việc đó.
alter table lich_chung drop constraint if exists lich_so_ngay_hop_le;
alter table lich_chung add  constraint lich_so_ngay_hop_le
  check (so_ngay between 1 and 366);

-- Hai chiều, đúng lối `lich_pham_vi_khop` đã đi: chỉ buổi CẢ NGÀY mới được trải
-- nhiều ngày. Thiếu vế này thì một dòng có giờ đeo `so_ngay = 3` sẽ đọc ra hai
-- nghĩa khác nhau ở lưới giờ và ở dải cả ngày.
alter table lich_chung drop constraint if exists lich_ca_ngay_khop;
alter table lich_chung add  constraint lich_ca_ngay_khop
  check (ca_ngay or so_ngay = 1);

comment on column lich_chung.ca_ngay is
  'Buổi trải trọn ngày, không có giờ. Bày ở dải ngang trên đầu lưới, không '
  'chiếm ô giờ, và không làm ai bận trong bảng giờ rảnh.';
comment on column lich_chung.so_ngay is
  'MỘT LƯỢT trải mấy ngày, TÍNH CẢ ngày đầu: 12->15/09 là 4. Chỉ khác 1 khi '
  'ca_ngay. Đây là độ dài tương đối của một lượt, không phải ngày cuối tuyệt '
  'đối — một luật lặp bung ra nhiều lượt, mỗi lượt một cặp ngày khác nhau.';

-- Dải cả ngày lọc theo `ca_ngay` ở mọi lượt vẽ lưới, cạnh `dang_dung` đã có.
create index if not exists lich_ca_ngay
  on lich_chung (dang_dung, ca_ngay);


-- ═══ 2. NGOẠI LỆ CỦA MỘT LƯỢT — nay chứa được cả độ dài ════════════════════
-- Hai cột đi cùng nhau vì cú kéo dải sinh ra cả hai: kéo cả dải sang chỗ khác
-- ghi `ngay_moi`, kéo một mép ghi `so_ngay_moi`, và kéo mép TRÁI ghi cả hai.
alter table lich_chung_ngoai_le add column if not exists so_phut_moi smallint;
alter table lich_chung_ngoai_le add column if not exists so_ngay_moi smallint;

alter table lich_chung_ngoai_le drop constraint if exists ngoaile_so_phut_moi_hop_le;
alter table lich_chung_ngoai_le add  constraint ngoaile_so_phut_moi_hop_le
  check (so_phut_moi is null or so_phut_moi between 5 and 1440);

alter table lich_chung_ngoai_le drop constraint if exists ngoaile_so_ngay_moi_hop_le;
alter table lich_chung_ngoai_le add  constraint ngoaile_so_ngay_moi_hop_le
  check (so_ngay_moi is null or so_ngay_moi between 1 and 366);

-- ⚠️ DROP RỒI ADD, KHÔNG BỌC `if not exists` — cùng lý lẽ hai tệp trước đã ghi:
-- bọc thì lần sau nới thêm một trường nữa, chạy lại tệp này KHÔNG vá được gì.
-- Nó thấy ràng buộc đã tồn tại rồi bỏ qua, và máy chủ vẫn chặn theo luật cũ.
--
-- BỐN trường thay nhau làm chứng cho một dòng `kieu='doi'`. Thiếu `so_ngay_moi`
-- ở đây thì một cú nới mép thuần tuý — dải vẫn bắt đầu đúng ngày cũ, chỉ dài
-- thêm một ngày — bị chặn, dù nó vừa khai một thứ hợp lệ.
alter table lich_chung_ngoai_le drop constraint if exists ngoaile_doi_du_tham_so;
alter table lich_chung_ngoai_le add  constraint ngoaile_doi_du_tham_so
  check (kieu <> 'doi'
         or num_nonnulls(ngay_moi, gio_moi, so_phut_moi, so_ngay_moi) >= 1);

comment on column lich_chung_ngoai_le.so_phut_moi is
  'Độ dài riêng của lượt này, phút. Rỗng = giữ theo lich_chung.so_phut.';
comment on column lich_chung_ngoai_le.so_ngay_moi is
  'Độ dài riêng của lượt này, số ngày, tính cả ngày đầu. Rỗng = giữ theo '
  'lich_chung.so_ngay. Chỉ có nghĩa với chuỗi ca_ngay.';

-- Chính sách quyền KHÔNG phải đụng: `ghi_lich` và `ghi_lich_ngoai` đã cho người
-- tạo hoặc lead ghi cả dòng, và cột mới nằm trong dòng ấy.

commit;


-- ── TỰ KIỂM — cả năm câu phải chạy trót lọt ───────────────────────────────
-- ① Hai cột mới trên chuỗi, đúng kiểu và đúng mặc định.
select column_name, data_type, column_default, is_nullable
  from information_schema.columns
 where table_name = 'lich_chung' and column_name in ('ca_ngay','so_ngay')
 order by column_name;

-- ② Hai cột mới trên bảng ngoại lệ.
select column_name, data_type, is_nullable
  from information_schema.columns
 where table_name = 'lich_chung_ngoai_le'
   and column_name in ('so_phut_moi','so_ngay_moi')
 order by column_name;

-- ③ Bốn ràng buộc đã đứng đúng chỗ.
select conname
  from pg_constraint
 where conname in ('lich_so_ngay_hop_le','lich_ca_ngay_khop',
                   'ngoaile_so_ngay_moi_hop_le','ngoaile_doi_du_tham_so')
 order by conname;

-- ④ Ràng buộc `lich_ca_ngay_khop` thật sự chặn: câu này PHẢI ngã.
--    Ghi rồi xoá ngay trong một khối, không để lại dấu vết nào.
do $$
begin
  begin
    insert into lich_chung (ten, gio_bat_dau, so_phut, lap, so_ngay, ca_ngay)
    values ('__thu ca ngay khop__', 540, 60, 'khong', 3, false);
    raise exception 'HỎNG: ràng buộc lich_ca_ngay_khop KHÔNG chặn';
  exception
    when check_violation then
      raise notice 'ĐẠT: buổi có giờ không trải được nhiều ngày';
    -- Câu này chạy với vai trò `postgres` trong SQL Editor nên hàng rào quyền
    -- không chắn. Chạy bằng một vai trò khác thì nó chắn TRƯỚC ràng buộc, và
    -- lúc ấy phép thử không nói được gì về ràng buộc — nói thẳng ra thế, đừng
    -- báo hỏng oan một thứ chưa được thử.
    when insufficient_privilege or others then
      raise notice 'BỎ QUA: chưa thử được ràng buộc (%). Chạy câu ⑤ để soi thay.', sqlerrm;
  end;
  delete from lich_chung where ten = '__thu ca ngay khop__';
end $$;

-- ⑤ Mọi dòng đang có đều hợp lệ sau khi nâng cấp — con số phải là 0.
select count(*) as dong_sai
  from lich_chung
 where so_ngay <> 1 and not ca_ngay;
