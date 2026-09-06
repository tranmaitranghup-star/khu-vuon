-- ============================================================================
-- MỘT NGƯỜI THUỘC NHIỀU PHÒNG BAN — nguoi.chuc_nang_id → nguoi.chuc_nang_ids
-- Tracy chốt 03/09. Linear TRI-78.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Nguyên văn Tracy: *"bối cảnh là mỗi người có thể nằm ở 1 vài phòng ban.
-- Peter, Sydney ở cả phòng Trải nghiệm KH và sản phẩm. Giống Tracy ở cả phòng
-- vận hành và tài chính ấy. Vì vậy sửa tận gốc về vị trí vai trò của từng
-- thành viên luôn"*.
--
-- Cột `nguoi.chuc_nang_id` là một con số đơn, nên nó không nói được câu "người
-- này ở hai phòng". Mọi thứ dựng trên nó — lịch của khối, danh mục việc cố
-- định, lưới ROVA — đều đang trả lời sai cho ba người đó.
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- Một cột MẢNG thay cho cột số đơn. Chép đúng khuôn `nang-cap-nhom-nhan-lich`
-- đã làm cho `lich_chung` hôm 31/08 — cùng một phép biến đổi, cùng một lẽ.
--
-- VÌ SAO BỎ HẲN CỘT CŨ chứ không giữ cả hai (ví dụ "khối chính" + "khối phụ"):
-- giữ hai cột cùng nói về một câu hỏi là dựng hai nguồn sự thật, và chỗ nào
-- quên đọc cột mới thì sai TRONG IM LẶNG. Luật này chính tệp 31/08 đã viết ra
-- cho `lich_chung`; nay áp lại cho `nguoi`. (Tôi đã trình phương án hai cột và
-- Tracy bác — *"sửa tận gốc"*.)
--
-- ⚠️ BA CHỖ NGOÀI CỘT PHẢI SỬA CÙNG NHỊP, không tách được. Cả ba đang so bằng
--    dấu `=` với MỘT khối của người; đổi cột mà bỏ chúng lại thì chúng KHÔNG
--    sai lặng lẽ — chúng nổ lúc chạy:
--      ① trigger `nhip_dong_dau`  — nổ ở mọi lần xếp việc vào tuần;
--      ② policy `ghi_viec`        — chặn sạch mọi lượt thêm/sửa danh mục;
--      ③ câu tự kiểm số 2 của `nang-cap-danh-muc-viec-co-dinh.sql` — hết đúng.
--
-- THỨ TỰ CHẠY: tệp này chạy SAU `nang-cap-danh-muc-viec-co-dinh.sql` và
-- `nang-cap-lich-chung.sql` (hai tệp ấy sinh ra cột cũ và bảng `chuc_nang`).
-- Chạy lại tệp này lần thứ hai không hỏng gì: mọi câu đều tự dò trạng thái.
-- ============================================================================

begin;

-- ═══ 1. CỘT MẢNG ═══════════════════════════════════════════════════════════
alter table nguoi add column if not exists chuc_nang_ids smallint[] not null default '{}';

comment on column nguoi.chuc_nang_ids is
  'Các khối chức năng người này thuộc về. MẢNG chứ không phải số đơn, vì một '
  'người có thể ở nhiều phòng ban (Tracy chốt 03/09: Peter và Sydney ở cả '
  'Trải nghiệm khách hàng lẫn Sản phẩm; Tracy ở cả Vận hành lẫn Tài chính). '
  'Phần tử ĐẦU TIÊN là khối mặc định khi cần đúng một giá trị — không phải một '
  'cột riêng, chỉ là quy ước về thứ tự.';

-- Chuyển dữ liệu cũ TRƯỚC khi gỡ cột. Chỉ đụng dòng còn trống, nên chạy lại
-- không ghi đè thứ ai đó đã sửa tay.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'nguoi'
                and column_name = 'chuc_nang_id')
  then
    execute 'update nguoi set chuc_nang_ids = array[chuc_nang_id]::smallint[]
              where chuc_nang_id is not null
                and coalesce(array_length(chuc_nang_ids,1),0) = 0';
  end if;
end $$;


-- ═══ 2. BA NGƯỜI TRACY KÊ ĐÍCH DANH ════════════════════════════════════════
-- Gán TUYỆT ĐỐI (ghi đè cả mảng), không cộng thêm vào cái đang có: cộng thêm
-- thì chạy tệp hai lần ra hai kết quả khác nhau, và ai đã sửa tay ở giữa thì
-- không ai biết. Ghi bằng TÊN KHỐI chứ không bằng mã số — mã do máy chủ sinh,
-- khác nhau giữa hai lần dựng kho, mà tệp này thì nằm trong mã nguồn.
--
-- Thứ tự trong mảng CÓ NGHĨA: phần tử đầu là khối mặc định (xem chú thích cột).
-- Với Tracy để Vận hành trước Tài chính; với Peter và Sydney để Sản phẩm trước
-- — đó là khối họ đang mang hôm nay, giữ nguyên thì việc cố định của họ không
-- đổi chỗ dưới chân.
do $$
declare
  v_ten   text;
  v_khoi  text[];
  v_ids   smallint[];
  v_thieu text[];
begin
  foreach v_ten in array array['Tracy', 'Peter', 'Sydney'] loop
    v_khoi := case v_ten
                when 'Tracy'  then array['Vận hành', 'Tài chính']
                else               array['Sản phẩm', 'Trải nghiệm khách hàng']
              end;

    -- Tên khối nào không có trong bảng `chuc_nang` thì DỪNG, đừng ghi một mảng
    -- thiếu: một người rơi mất khối là một người biến mất khỏi lịch của khối
    -- ấy, mà không dấu hiệu nào báo.
    select array_agg(c.id order by array_position(v_khoi, c.ten))
      into v_ids
      from chuc_nang c where c.ten = any(v_khoi);

    if v_ids is null or array_length(v_ids,1) <> array_length(v_khoi,1) then
      select array_agg(k) into v_thieu from unnest(v_khoi) k
       where k not in (select ten from chuc_nang);
      raise exception 'Bảng chuc_nang thiếu khối: %', array_to_string(v_thieu, ', ');
    end if;

    -- Không có ai tên ấy thì nói ra, đừng im lặng cập nhật 0 dòng.
    -- So LỎNG (`lower(btrim())`, đúng phép `nang-cap-lich-chung.sql` dùng): tên
    -- người do người gõ vào, một khoảng trắng thừa hay một chữ hoa lệch là đủ
    -- để cả tệp dừng lại giữa chừng. Tên KHỐI thì so chặt ở trên, vì nó do
    -- chính tệp SQL sinh ra chứ không ai gõ.
    if not exists (select 1 from nguoi where lower(btrim(ten)) = lower(v_ten)) then
      raise exception 'Không có ai tên "%" trong bảng nguoi.', v_ten;
    end if;

    update nguoi set chuc_nang_ids = v_ids where lower(btrim(ten)) = lower(v_ten);
  end loop;
end $$;


-- ═══ 3. TRIGGER — chốt chặn khi xếp việc cố định vào tuần ═══════════════════
-- Bản cũ: `if v_cn_nguoi is null or v_cn_nguoi <> v_cn_viec then raise`.
-- Đây là chỗ DUY NHẤT khối-của-người bị so trực tiếp với khối-của-việc. Với
-- mảng thì `<>` phải thành "không nằm trong", nếu không mọi cú bấm chọn việc ở
-- giao diện đều nổ.
create or replace function nhip_dong_dau()
returns trigger language plpgsql security definer set search_path = public
as $$
declare v_ten text; v_dk smallint; v_cn_viec smallint; v_cn_nguoi smallint[];
begin
  if new.viec_id is null then
    return new;                       -- đường cũ: gõ tay, không qua danh mục
  end if;

  select ten, thoi_luong_du_kien, chuc_nang_id
    into v_ten, v_dk, v_cn_viec
    from viec_co_dinh where id = new.viec_id;
  if not found then
    raise exception 'Việc cố định không có trong danh mục.';
  end if;

  select chuc_nang_ids into v_cn_nguoi from nguoi where id = new.nguoi_id;
  if v_cn_nguoi is null or not (v_cn_viec = any(v_cn_nguoi)) then
    raise exception 'Việc này thuộc khối chức năng khác — không xếp vào tuần của người này được.';
  end if;

  new.ten := v_ten;
  if new.thoi_luong_du_kien is null then
    new.thoi_luong_du_kien := v_dk;
  end if;
  return new;
end $$;

drop trigger if exists nhip_dong_dau_tr on nhip;
create trigger nhip_dong_dau_tr
  before insert or update on nhip
  for each row execute function nhip_dong_dau();


-- ═══ 4. LUẬT QUYỀN — ai sửa được danh mục việc của khối nào ═════════════════
-- Bản cũ: `chuc_nang_id = (select chuc_nang_id from nguoi where …)`.
-- ⚠️ Truy vấn con nay trả về một MẢNG, không phải một số. Giữ dấu `=` thì
--    Postgres so số với mảng và câu lệnh hỏng ngay lần đầu ai đó thêm việc.
--
-- 🪤 BẢN VÁ ĐẦU CỦA TỆP NÀY CŨNG HỎNG, VÀ HỎNG NGAY LÚC CHẠY TỆP — chép lại đây
--    vì cái bẫy này rình mọi lần đổi một cột đơn thành cột mảng:
--        chuc_nang_id = any(select coalesce(chuc_nang_ids,'{}') from nguoi ...)
--    → ERROR 42883: operator does not exist: smallint = smallint[]
--    `any(<truy vấn con>)` và `any(<mảng>)` là HAI phép khác nhau viết giống
--    hệt nhau. Thấy một truy vấn con trong ngoặc, Postgres chọn phép thứ nhất:
--    nó so vế trái với TỪNG DÒNG truy vấn trả về — mà mỗi dòng ở đây là cả một
--    mảng. Muốn dùng phép thứ hai thì tham số phải là một BIỂU THỨC mảng, tức
--    một cột mảng cầm trên tay, không phải một truy vấn con.
--
--    Nên viết bằng `exists`: kéo dòng `nguoi` ra trước, rồi so với cột mảng của
--    chính nó. Dài hơn một dòng nhưng đọc ra đúng câu cần hỏi, và không nhờ vào
--    một mẹo cú pháp nào.
drop policy if exists ghi_viec on viec_co_dinh;
create policy ghi_viec on viec_co_dinh for all
  using      (exists (select 1 from nguoi n
                       where n.id = nguoi_id_dang_nhap()
                         and viec_co_dinh.chuc_nang_id = any(n.chuc_nang_ids)))
  with check (exists (select 1 from nguoi n
                       where n.id = nguoi_id_dang_nhap()
                         and viec_co_dinh.chuc_nang_id = any(n.chuc_nang_ids)));


-- ═══ 5. GỠ CỘT CŨ ══════════════════════════════════════════════════════════
-- Sau cùng, khi mọi thứ đọc nó đã chuyển sang cột mới. Gỡ chứ không để lại:
-- xem lý do ở đầu tệp.
alter table nguoi drop column if exists chuc_nang_id;

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ═════════════════════════════
select * from (values
  (1, 'cột chuc_nang_ids có mặt, kiểu mảng số nguyên nhỏ',
   (select data_type || '/' || coalesce(udt_name,'') from information_schema.columns
     where table_schema = 'public' and table_name = 'nguoi'
       and column_name = 'chuc_nang_ids') = 'ARRAY/_int2'),

  (2, 'cột chuc_nang_id cũ ĐÃ biến mất',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nguoi'
       and column_name = 'chuc_nang_id') = 0),

  (3, 'không ai bị rơi mất khối trong lúc chuyển',
   (select count(*) from nguoi where coalesce(array_length(chuc_nang_ids,1),0) = 0) = 0),

  (4, 'ba người Tracy kê đều đang ở đúng hai khối',
   (select count(*) from nguoi
     where lower(btrim(ten)) in ('tracy','peter','sydney')
       and array_length(chuc_nang_ids,1) = 2) = 3),

  (5, 'trigger nhip_dong_dau đã đọc mảng, không còn so bằng dấu bằng',
   (select prosrc from pg_proc where proname = 'nhip_dong_dau') like '%any(v_cn_nguoi)%'),

  (6, 'luật ghi danh mục đã đọc mảng',
   (select pg_get_expr(polqual, polrelid) from pg_policy
     where polname = 'ghi_viec') like '%chuc_nang_ids%')
) as t(so, muc, dat);
