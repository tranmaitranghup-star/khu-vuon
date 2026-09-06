-- ═══════════════════════════════════════════════════════════════════════════
-- CỜ ĐIỀU HÀNH — ai được xem LỊCH TRÌNH CỦA CẢ ĐỘI. Tracy duyệt 03/09/2026
--
-- Nguyên văn: *"tôi làm vận hành và ceo làm điều hành đang cần xem được lịch
-- trình của toàn bộ mọi người (không cần task)... ví dụ bây giờ phòng sản phẩm
-- add 1 sự kiện họp là tôi sẽ ko biết vì ko có tôi tham gia. mà điều hành và
-- vận hành cần nắm được"*.
--
-- VÌ SAO MỘT CỘT RIÊNG, KHÔNG ĐỌC `nguoi.vai`. Cùng lẽ đã ghi cho `la_lead`
-- trong `nang-cap-lich-chung.sql`: `vai` là chuỗi chữ tự do dùng làm nhãn hiển
-- thị, suy quyền từ một nhãn thì sửa nhãn là mất quyền, im lặng. Cột riêng thì
-- đổi nhãn bao nhiêu lần quyền vẫn đứng yên.
--
-- VÌ SAO KHÔNG DÙNG LẠI `la_lead`. Cờ ấy đang BẬT cho cả bảy người (mặc định
-- `true`, ghi trong chính comment của nó), nên nó không tách được hai người ra
-- khỏi năm người kia. Hai cờ trả lời hai câu khác nhau: `la_lead` = "được đặt
-- lịch cho nhóm", `la_dieu_hanh` = "được nhìn lịch của mọi nhóm".
--
-- MẶC ĐỊNH `false`, NGƯỢC VỚI `la_lead`. Người thứ tám vào app không tự nhiên
-- nhìn được lịch cả công ty; phải có người bật tay. Cờ này mở một khung nhìn
-- rộng nên nó phải đóng sẵn, không mở sẵn.
--
-- ⛔ ĐÂY KHÔNG PHẢI MỘT HÀNG RÀO QUYỀN, và chỗ này phải nói thẳng. Chính sách
-- `doc_lich` (nang-cap-lich-chung.sql, mục 5) cho MỌI thành viên đọc MỌI dòng
-- `lich_chung` — có chủ ý, để khối bên cạnh biết nhau họp lúc nào mà tránh
-- trùng giờ. Việc giấu bớt xưa nay nằm ở hàm `lcChoToi` trong trình duyệt.
-- Cờ này đi đúng lối ấy: nó mở một KHUNG NHÌN, không cấp thêm một quyền đọc
-- nào mà người khác không có. Ai gọi thẳng API vẫn đọc được như trước — không
-- hơn, không kém. Muốn siết thật thì phải sửa chính `doc_lich`, và đó là việc
-- khác, chạm cả mảng lịch đang chạy hằng ngày.
--
-- Chạy tệp này lúc nào cũng được: app dò cột trước khi dùng, chưa chạy thì
-- không ai thấy chế độ mới và mọi thứ còn lại chạy y nguyên.
-- ═══════════════════════════════════════════════════════════════════════════

alter table nguoi add column if not exists la_dieu_hanh boolean not null default false;

comment on column nguoi.la_dieu_hanh is
  'Được xem LỊCH TRÌNH của cả đội — mọi sự kiện của mọi khối, kèm tên buổi và '
  'trạng thái trả lời. Mặc định TẮT, ngược với la_lead: cờ này mở một khung '
  'nhìn rộng nên phải có người bật tay. Không phải một quyền đọc — policy '
  'doc_lich vốn đã cho cả đội đọc mọi dòng; cờ này chỉ mở khung nhìn ở app.';

-- HÀM TRA — cùng khuôn `la_lead()`. `coalesce(..., false)`: người chưa có dòng
-- trong bảng `nguoi` thì trả về false chứ không trả null, để mọi phép so ở
-- chính sách và ở app đều đọc ra một giá trị thật.
create or replace function la_dieu_hanh()
returns boolean language sql stable set search_path = public
as $$ select coalesce(
         (select la_dieu_hanh from nguoi where id = nguoi_id_dang_nhap()), false) $$;

comment on function la_dieu_hanh() is
  'Người đang đăng nhập có xem được lịch trình cả đội không (nguoi.la_dieu_hanh).';

-- ── BẬT CHO HAI NGƯỜI, VÀ DỪNG LẠI NẾU KHÔNG KHỚP ĐỦ ─────────────────────
-- Khớp bằng EMAIL, không bằng tên: email là khoá `unique` của bảng và là thứ
-- đăng nhập so, còn tên thì trùng được. Tiền lệ viết email thẳng vào tệp SQL đã
-- có ở `nang-cap-cam-ket-5-cua-ceo.sql`.
--
-- `raise exception` khi không đúng hai dòng — theo lối `nang-cap-phan-cap-
-- nghiem-thu.sql`. Một câu `update` khớp 0 dòng chạy xong vẫn báo thành công,
-- và lúc ấy tệp coi như đã chạy trong khi chẳng ai được bật: hỏng LẶNG, đúng
-- loại hỏng đắt nhất. Thà ngã ngay ở đây.
do $$
declare n int;
begin
  update nguoi set la_dieu_hanh = true
   where lower(btrim(email)) in ('tracy@vidu.com',   -- Tracy · vận hành
                                 'andy@vidu.com');      -- Andy  · điều hành
  get diagnostics n = row_count;
  if n <> 2 then
    raise exception 'Chỉ khớp % dòng, phải là 2. Kiểm lại email trong bảng nguoi — '
                    'so chuỗi có phân biệt hoa thường ở chỗ đăng nhập, nhưng phép '
                    'khớp ở đây đã hạ hoa thường nên lệch là do email khác thật.', n;
  end if;
end $$;

-- ── TỰ KIỂM — gộp một bảng, vì Supabase chỉ bày kết quả câu CUỐI ──────────
select 'cột' as muc,
       case when exists (select 1 from information_schema.columns
                          where table_name = 'nguoi' and column_name = 'la_dieu_hanh')
            then 'ĐÃ CÓ' else '⚠️ CHƯA CÓ' end as ket_qua
union all
select 'mặc định',
       coalesce((select column_default from information_schema.columns
                  where table_name = 'nguoi' and column_name = 'la_dieu_hanh'), '⚠️ không có')
union all
select 'hàm la_dieu_hanh()',
       case when exists (select 1 from pg_proc where proname = 'la_dieu_hanh')
            then 'ĐÃ CÓ' else '⚠️ CHƯA CÓ' end
union all
select 'đang bật cho',
       coalesce(string_agg(ten, ' · ' order by thu_tu), '⚠️ KHÔNG AI')
  from nguoi where la_dieu_hanh
union all
select 'số người tắt cờ', count(*)::text from nguoi where not la_dieu_hanh;
