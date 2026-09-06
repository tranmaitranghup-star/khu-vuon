-- ═══════════════════════════════════════════════════════════════════════════
-- VÁ RÀNG BUỘC MÀU CỦA `task` — Tracy duyệt 01/09/2026
--
-- ⚠️ TỆP VÁ MỘT LỖI ĐANG SỐNG, không phải một tính năng mới.
--
-- Triệu chứng: dải màu trong cửa Thông tin việc mời chọn khoá 'ngoc' từ hôm
-- 01/09, nhưng ràng buộc `task_mau_hop_le` dựng hôm 29/08 chỉ kê tám tên cũ và
-- KHÔNG có nó. Người dùng chọn Ngọc rồi bấm Lưu thì Postgres trả 400 cho CẢ
-- CÂU — tức mất luôn tên · ngày · giờ · trạng thái vừa sửa trong cùng lượt ấy,
-- không phải một trường bị bỏ qua. Chỉ hiện một dòng lỗi tiếng Anh thô, nên
-- rất khó lần ra thủ phạm là cái ô màu.
--
-- ⚠️ VÌ SAO CHẠY LẠI TỆP CŨ KHÔNG VÁ ĐƯỢC. `nang-cap-mau-khoi-viec.sql` bọc
-- ràng buộc trong `do $$ … if not exists … end $$`. Ràng buộc đã tồn tại nên
-- lượt chạy lại bỏ qua nó — im lặng, không lỗi, và máy chủ vẫn chặn y như cũ.
-- Tệp này đi lối DROP RỒI ADD, giống `nang-cap-mau-su-kien.sql`, nên lần sau
-- thêm màu chỉ cần sửa danh sách trong tệp NÀY rồi chạy lại nó.
--
-- ── VÌ SAO DANH SÁCH LÀ MƯỜI TÊN, KHÔNG PHẢI SÁU ──────────────────────────
-- Bảng chọn nay chỉ mời SÁU màu (vang · luc · ngoc · lam · tim · hong — Tracy
-- rút cam và xanh tím chiều 01/09 vì hai khoá ấy trùng khít với hai họ hệ
-- thống). Nhưng rút khỏi bảng chọn KHÔNG phải xoá khỏi dữ liệu: việc nào đã lỡ
-- sơn 'cam' · 'xtim' · 'do' · 'xam' thì dòng vẫn đang mang tên ấy, và CSS vẫn
-- giữ đủ bốn thang để chúng hiện đúng màu. Siết ràng buộc xuống sáu là bắt
-- những dòng cũ ấy thành sai — câu `add constraint` sẽ NGÃ NGAY vì Postgres
-- soát cả dữ liệu đang có, và nếu có lọt thì lần sửa kế tiếp của chính những
-- việc đó cũng hoá lỗi.
-- Giữ chúng KHÔNG mở đường cho màu mới: app chỉ gửi được thứ có trong
-- `MAU_VIEC`, mà bốn tên ấy không nằm đó. Chúng chỉ còn là chỗ đậu cho quá khứ.
--
-- Tệp này KHÔNG chạm `lich_chung.mau` — ràng buộc ấy do `nang-cap-mau-su-kien.sql`
-- (làn MS) dựng và đã kê đủ. Chạy lúc nào cũng được, chạy lại bao nhiêu lần
-- cũng được: không thêm cột, không đụng dữ liệu, chỉ thay một ràng buộc.
--
-- Bước 0 và lối gộp tự kiểm vào một bảng học từ bản nháp `nang-cap-va-mau-hop-le.sql`
-- của một phiên chạy song song; hai tệp kê cùng một danh sách, giữ tệp này.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── BƯỚC 0 · HÀNG RÀO — dừng lại nếu kho có tên màu NGOÀI cả mười ─────────
-- Không để `add constraint` ngã với một câu báo khó đọc. Nếu kho đang giữ một
-- tên lạ (tệp cũ hơn, một lần sửa tay), khối này dừng cả tệp và ĐỌC TÊN nó ra
-- để người chạy quyết định: thêm tên ấy vào danh sách, hay dọn dòng ấy trước.
do $$
declare la text;
begin
  select string_agg(distinct coalesce(mau,'?'), ', ')
    into la
    from task
   where mau is not null
     and mau not in ('do','cam','vang','luc','ngoc','lam','xtim','tim','hong','xam');

  if la is not null then
    raise exception
      'DỪNG: kho đang giữ tên màu ngoài danh sách → %. Thêm tên ấy vào mọi chỗ kê danh sách trong tệp này, hoặc dọn những dòng ấy trước, rồi chạy lại.', la;
  end if;
end $$;

-- ── BƯỚC 1 · THAY RÀNG BUỘC ───────────────────────────────────────────────
-- Kê tên chứ không để tự do: một giá trị lạ lọt xuống thì lưới không có lớp
-- CSS nào khớp, khối mất màu mà không một tiếng kêu — kiểu hỏng khó tìm nhất.
alter table task drop constraint if exists task_mau_hop_le;
alter table task add constraint task_mau_hop_le
  check (mau is null or mau in
         ('do','cam','vang','luc','ngoc','lam','xtim','tim','hong','xam'));

-- ── TỰ KIỂM ───────────────────────────────────────────────────────────────
-- Trình soạn SQL của Supabase chỉ bày kết quả của câu CUỐI, nên bốn phép soát
-- gộp vào một bảng. Cột `ket_qua` phải đọc ra ba dòng ✅ rồi tới dòng liệt kê.
select 'ràng buộc đã đứng đúng tên' as phep_soat,
       case when exists (select 1 from pg_constraint where conname='task_mau_hop_le')
            then '✅ có' else '❌ KHÔNG THẤY' end as ket_qua
union all
select 'ràng buộc đã nhận ''ngoc''',
       case when (select pg_get_constraintdef(oid) from pg_constraint where conname='task_mau_hop_le') like '%ngoc%'
            then '✅ có' else '❌ CÒN THIẾU — tệp cũ chưa bị thay' end
union all
select 'không dòng nào mang tên màu lạ',
       case when exists (select 1 from task where mau is not null
              and mau not in ('do','cam','vang','luc','ngoc','lam','xtim','tim','hong','xam'))
            then '❌ CÒN' else '✅ sạch' end
union all
select 'các tên màu đang có thật trong kho',
       coalesce((select string_agg(distinct mau, ', ' order by mau)
                   from task where mau is not null), '(chưa dòng nào có màu)');
