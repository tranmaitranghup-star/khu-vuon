-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.da_chot`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- HAI TRẠNG THÁI CỦA MỘT SỰ KIỆN: DỰ KIẾN · ĐÃ CHỐT — Tracy duyệt 03/09/2026
--
-- Nguyên văn: *"ở sự kiện tôi cần thêm 1 tính năng là nút dự kiến/đã chốt lịch
-- nếu mà sự kiện đó dự kiến thì có thêm 1 đường nét đứt bao quanh vì chúng tôi
-- hay hoạch định lịch nhưng chưa chốt"*.
--
-- ĐẶT Ở CẤP CHUỖI, cùng chỗ và cùng lẽ với cột `mau`. Một dòng `lich_chung` là
-- một LUẬT LẶP chứ không phải một buổi; từng buổi do máy khách bung ra lúc vẽ
-- bằng `lcHopNgay`, không có dòng con nào trong kho. Nên một cột ở đây tự khắc
-- nói cho cả chuỗi. Chiều ngược lại — *"chỉ buổi này còn dự kiến"* — phải nới
-- `lich_chung_ngoai_le` (nay chỉ nhận 'huy' và 'doi'), và Tracy chốt để nhát
-- sau, đúng như đã chốt với màu hôm 01/09.
--
-- BOOLEAN, KHÔNG PHẢI CHUỖI TRẠNG THÁI. Đây là hai nấc loại trừ nhau và không
-- có nấc thứ ba nào đang chờ: *đã huỷ* đã có chỗ riêng (`dang_dung`), *đã dời*
-- cũng vậy (`lich_chung_ngoai_le`). Một cột text kê tên chỉ đáng khi tập giá
-- trị còn mở; ở đây nó chỉ thêm một ràng buộc phải nuôi.
--
-- ⚠️ MẶC ĐỊNH `true` — VÀ ĐÓ LÀ PHẦN QUAN TRỌNG NHẤT CỦA TỆP NÀY. Mọi sự kiện
-- đã khai từ trước hôm nay đều là lịch thật đang chạy; để mặc định `false` thì
-- chạy tệp xong CẢ LỊCH hoá nét đứt cùng lúc, và không ai đi sửa tay được vài
-- chục dòng. `not null` để không có nấc thứ ba "chưa biết" — một cột ba giá trị
-- thì mỗi chỗ đọc lại phải tự quyết `null` nghĩa là gì.
--
-- Chạy tệp này lúc nào cũng được: app dò cột trong `doCotGio()` trước khi gửi,
-- chưa chạy thì hàng hai nút trong form sự kiện nói ra tên tệp và mọi thứ còn
-- lại chạy y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

alter table lich_chung add column if not exists da_chot boolean not null default true;

comment on column lich_chung.da_chot is
  'false = lịch mới hoạch định, chưa chốt; khối trên lưới hiện viền nét đứt.';

-- Chính sách quyền KHÔNG phải đụng: `sua_lich` (nang-cap-su-kien-ca-nhan.sql:94)
-- đã cho người tạo hoặc lead sửa cả dòng, và cột mới nằm trong dòng ấy.

-- ── TỰ KIỂM — cả ba câu phải chạy trót lọt ────────────────────────────────
-- ① Cột đã có, đúng kiểu boolean, không cho rỗng, mặc định là true.
select column_name, data_type, is_nullable, column_default
  from information_schema.columns
 where table_name = 'lich_chung' and column_name = 'da_chot';

-- ② Không dòng cũ nào bị hoá dự kiến. Phải trả về 0 dòng.
select id, ten from lich_chung where da_chot is not true;

-- ③ Đếm hai nhóm — sau khi chạy tệp lần đầu, cả bảng phải nằm hết ở cột `chot`.
select count(*) filter (where da_chot)     as chot,
       count(*) filter (where not da_chot) as du_kien
  from lich_chung;
