-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: ràng buộc `van_de_dau_dong_khop_nac`
-- │ (thế chỗ `van_de_chi_nguoi_neu_dong`), và vế `la_quan_tri_dang_nhap()`
-- │ trong thân cò `chan_sua_cot_van_de`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — QUẢN TRỊ ĐỔI ĐƯỢC NẤC CỦA MỌI VẤN ĐỀ
--                                   (Tracy duyệt 06/09/2026 — TRI-136)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- CHẠY TRƯỚC: `nang-cap-van-de-lien-phong.sql` (nó dựng bảng, cò và ràng buộc
--             mà tệp này nới ra).
--
-- ⚠️ ĐỪNG CHẠY LẠI `nang-cap-van-de-lien-phong.sql` SAU TỆP NÀY. Tệp ấy dựng
--    lại đúng cái ràng buộc và cái cò bản cũ, và làm thế là lặng lẽ lấy lại
--    quyền vừa trao. Cần chạy lại nó thì chạy tệp này ngay sau.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 06/09: *"cho Tracy quyền đổi trạng thái đi"* — và khi hỏi cho riêng
-- Tracy hay cho cả nhóm quản trị: *"QUẢN TRỊ NHÉ"*. Nên quyền đi theo cột
-- `nguoi.la_quan_tri` (Tracy và Andy), không khai riêng một cái tên.
--
-- Trước tệp này, quản trị đã sửa được dòng vấn đề (policy `sua_van_de` có sẵn
-- vế quản trị) nên hai nấc `dang_xu_ly` và `cho_ben_khac` vốn đã đi được —
-- chỉ là màn hình không bày nút. Lối DUY NHẤT bị máy chủ chặn thật là `xong`,
-- và nó bị chặn ở HAI chỗ khác nhau, phải gỡ cả hai thì mới thông:
--
--   ① CÒ `chan_sua_cot_van_de` canh AI ĐANG GÕ — chỉ cho người nêu đặt `xong`.
--   ② RÀNG BUỘC `van_de_chi_nguoi_neu_dong` canh KẾT QUẢ — một dòng `xong` mà
--      ô người đóng không phải người nêu thì không tồn tại được.
--
-- Gỡ mỗi ① thì cú bấm vẫn ngã, lần này ở tầng dữ liệu, với một câu báo lỗi khó
-- đọc hơn nhiều. Đây là chỗ dễ làm nửa vời nhất của cả việc.
--
-- ─── VÌ SAO RÀNG BUỘC ② KHÔNG ĐƯỢC NỚI MÀ BỊ THAY ──────────────────────────
-- Luật mới là *"người đóng phải là người nêu HOẶC một người có `la_quan_tri`"*.
-- Vế sau tra bảng `nguoi`, mà một `check` không truy vấn được bảng khác — nó
-- chỉ nhìn thấy các cột của chính dòng đang ghi. Nên phép canh ấy không diễn
-- đạt được ở tầng ràng buộc nữa; chỗ đúng của nó là cò, nơi biết ai đang gõ.
--
-- Ràng buộc mới giữ lại phần vẫn nói được, và nó không thừa: dấu người đóng
-- chỉ tồn tại trên một dòng đã đóng. Đó là thứ canh cho hai dòng xoá dấu ở
-- cuối cò — mở lại một vấn đề mà quên xoá dấu đóng thì ràng buộc này ngã ngay,
-- thay vì để lại một dòng đang chạy mà vẫn mang tên người đã đóng nó.
--
-- CÁI MẤT, nói thẳng: lối chạy tay trong SQL Editor không còn bị chặn khi đặt
-- `xong` dưới tên người khác — cò vốn đã cố ý bỏ qua lượt ấy, nên ràng buộc là
-- lớp duy nhất canh nó. Chấp nhận được, vì SQL Editor chỉ Tracy vào, mà Tracy
-- chính là người vừa được trao quyền này.
-- ============================================================================


-- ════════════════════════════════════════════════════════════════════════════
-- 1. CÒ — nới hàng rào ① cho quản trị
-- ════════════════════════════════════════════════════════════════════════════
-- Chép nguyên bản cũ, đổi đúng MỘT vế. Chép trọn chứ không vá từng dòng vì
-- `create or replace function` thay cả thân hàm — một bản vá nửa vời ở đây
-- không báo lỗi, nó chỉ lặng lẽ dựng lại một cái cò thiếu mất mấy dòng.
create or replace function chan_sua_cot_van_de()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  -- Lượt chạy từ SQL Editor không có token nên không có "chính mình" — để yên.
  -- Đó là lối chữa cháy cuối cùng của Tracy và không được khoá lại.
  if email_dang_nhap() = '' then return new; end if;

  -- Bốn cột do máy đặt lúc ghi, giữ nguyên bản cũ dù người ta gửi lên gì.
  new.han_tra_loi   := old.han_tra_loi;
  new.nguoi_neu_id  := old.nguoi_neu_id;
  new.chuc_nang_neu := old.chuc_nang_neu;
  new.tao_luc       := old.tao_luc;

  -- Đã nhận rồi thì mốc nhận đứng yên: đồng hồ 24 giờ chỉ dừng MỘT lần.
  if old.nhan_luc is not null then new.nhan_luc := old.nhan_luc; end if;

  -- Hàng rào ①, NỚI 06/09 (TRI-136): người nêu, hoặc quản trị — và nay cho cả
  -- `xong` chứ không riêng `khong_lam`. Người xử lý vẫn không tự đóng được:
  -- họ báo đã xong bằng `dang_xu_ly`, người nêu hoặc quản trị xác nhận.
  -- Ô người đóng luôn ghi ĐÚNG TÊN người vừa gõ, kể cả khi đó là quản trị đóng
  -- thay — dòng bàn luận mà app ghi kèm là để người nêu đọc, còn ô này là để
  -- máy tra. Hai thứ khác nhau, đừng bỏ thứ nào.
  if new.trang_thai in ('xong','khong_lam')
     and old.trang_thai not in ('xong','khong_lam') then
    if not (nguoi_id_dang_nhap() = old.nguoi_neu_id
            or la_quan_tri_dang_nhap()) then
      raise exception
        'Chỉ người nêu vấn đề mới đóng được nó. Bạn báo đã xong, người nêu xác nhận.';
    end if;
    new.dong_luc      := coalesce(new.dong_luc, now());
    new.nguoi_dong_id := nguoi_id_dang_nhap();
  end if;

  -- Mở lại một vấn đề đã đóng thì xoá dấu đóng, đừng để lại mốc cũ nói dối.
  if new.trang_thai not in ('xong','khong_lam') then
    new.dong_luc      := null;
    new.nguoi_dong_id := null;
  end if;

  return new;
end $$;

comment on function chan_sua_cot_van_de() is
  'Khoá các cột do máy đặt, và canh ai được đóng vấn đề: người nêu hoặc quản '
  'trị (nới 06/09, TRI-136). Lượt chạy từ SQL Editor được bỏ qua.';

-- Cò gắn vào bảng thì không phải dựng lại — `create or replace function` đã
-- thay thân hàm mà cò đang trỏ tới. Dòng này chỉ để chạy tệp trên một máy chủ
-- chưa từng có cò cũng ra kết quả đúng.
drop trigger if exists tg_chan_sua_cot_van_de on van_de;
create trigger tg_chan_sua_cot_van_de
  before update on van_de
  for each row execute function chan_sua_cot_van_de();


-- ════════════════════════════════════════════════════════════════════════════
-- 2. RÀNG BUỘC — thay hàng rào ② bằng phép canh còn nói được
-- ════════════════════════════════════════════════════════════════════════════
alter table van_de drop constraint if exists van_de_chi_nguoi_neu_dong;

do $$
begin
  if not exists (select 1 from pg_constraint
                  where conname = 'van_de_dau_dong_khop_nac') then
    alter table van_de add constraint van_de_dau_dong_khop_nac
      check (nguoi_dong_id is null or trang_thai in ('xong','khong_lam'));
  end if;
end $$;

comment on constraint van_de_dau_dong_khop_nac on van_de is
  'Dấu người đóng chỉ tồn tại trên một dòng đã đóng. Canh cho hai dòng xoá dấu '
  'ở cuối cò chan_sua_cot_van_de. Thế chỗ van_de_chi_nguoi_neu_dong (06/09).';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. TỰ KIỂM — bảng đạt/chưa đạt, dòng chưa đạt nổi lên đầu
-- ════════════════════════════════════════════════════════════════════════════
select * from (values

  (1, 'ràng buộc cũ "chỉ người nêu đóng" đã gỡ',
   (select count(*) from pg_constraint
     where conname = 'van_de_chi_nguoi_neu_dong') = 0),

  (2, 'ràng buộc mới "dấu đóng khớp nấc" đã dựng',
   (select count(*) from pg_constraint
     where conname = 'van_de_dau_dong_khop_nac') = 1),

  /* Đọc thẳng THÂN hàm. Với hàm plpgsql thì `prosrc` là nguyên văn đã gõ —
     Postgres cất lại y như cũ chứ không phân tích rồi in lại, khác hẳn định
     nghĩa một ràng buộc. Nên mẫu `like` ở đây tin được. */
  (3, 'cò đã mang vế quản trị',
   (select prosrc like '%la_quan_tri_dang_nhap()%'
      from pg_proc where proname = 'chan_sua_cot_van_de')),

  (4, 'và vẫn chạy bằng quyền định nghĩa (security definer)',
   (select prosecdef from pg_proc where proname = 'chan_sua_cot_van_de')),

  (5, 'cò vẫn gắn trên bảng van_de',
   (select count(*) from pg_trigger
     where not tgisinternal and tgname = 'tg_chan_sua_cot_van_de') = 1),

  (6, 'lối thoát SQL Editor còn nguyên — không tự khoá mình ra ngoài',
   (select prosrc like '%email_dang_nhap() = %'
      from pg_proc where proname = 'chan_sua_cot_van_de')),

  (7, 'đúng hai người mang quyền quản trị (Tracy · Andy)',
   (select count(*) from nguoi where la_quan_tri) = 2),

  (8, 'ba policy của van_de còn nguyên, không đụng tới',
   (select count(*) from pg_policies
     where tablename = 'van_de'
       and policyname in ('doc_van_de','them_van_de','sua_van_de')) = 3),

  (9, 'và vẫn không có đường xoá vấn đề',
   (select count(*) from pg_policies
     where tablename = 'van_de' and cmd = 'DELETE') = 0),

  /* Dòng dữ liệu thật: không dòng nào đang vi phạm ràng buộc vừa dựng. Nếu có
     thì câu `alter table` bên trên đã ngã và tệp dừng ngay ở đó — dòng này là
     để bảng kết quả nói ra điều ấy thay vì để người đọc tự suy. */
  (10, 'không dòng nào mang dấu đóng mà chưa đóng',
   (select count(*) from van_de
     where nguoi_dong_id is not null
       and trang_thai not in ('xong','khong_lam')) = 0)

) as t(so, muc, dat)
order by dat, so;
