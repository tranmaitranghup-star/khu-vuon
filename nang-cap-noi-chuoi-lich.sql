-- ═══════════════════════════════════════════════════════════════════════════
-- NỐI LẠI MỘT CHUỖI VỪA BỊ CHIA — đường lui cho `cat_chuoi_lich` (TRI-161)
--
-- Tracy 07/09: *"lịch trình liên quan đến người khác và toàn công ty nên đều
-- phải có nút hoàn tác cho an toàn"*. Chia một chuỗi làm hai là thao tác nặng
-- nhất trong cụm lịch, và tới nay là thao tác duy nhất còn lại không lùi được.
--
-- HÀM NÀY LÀ NGHỊCH ĐẢO CỦA `cat_chuoi_lich`, làm đúng ba bước THEO THỨ TỰ:
--   ① năm bảng con từ nửa SAU chuyển về nửa TRƯỚC;
--   ② trả `ngay_ket_thuc` cũ cho nửa trước;
--   ③ rồi mới xoá dòng của nửa sau.
--
-- ⛔ THỨ TỰ KHÔNG ĐỔI ĐƯỢC. `lich_chung_ngoai_le` (và các bảng con khác) móc
--    vào `lich_chung` bằng `on delete cascade`. Xoá nửa sau trước là để cascade
--    cuốn theo người dự, ghi chú buổi và thông báo của mọi lượt chưa kịp chuyển
--    về — mất sạch, không một dòng nào báo. Đây là chỗ duy nhất trong tệp này
--    mà một lỗi thứ tự đổi thành mất dữ liệu thật.
--
-- HÀNG RÀO `p_sua_luc` (Tracy chốt ở bản duyệt 07/09). Nửa sau đã bị người khác
-- sửa tiếp sau lúc chia thì hàm TỪ CHỐI nối. Lịch trình này chạm cả công ty:
-- thà báo "không lùi được" còn hơn âm thầm ghi đè lên việc người ta vừa làm.
-- Máy khách chụp `sua_luc` ngay sau cú chia rồi đưa lại vào đây.
--
-- QUYỀN: chép nguyên vế của `cat_chuoi_lich` — người tạo sự kiện, hoặc khách
-- được người đó cho quyền sửa. KHÔNG nới cho lead: một hàm `security definer`
-- không tự kiểm quyền là một cánh cửa mở, RLS không chặn hộ. Lỗi ấy đã xảy ra
-- một lần thật ở `doi_gio_viec_theo_chuoi`.
--
-- Chạy tệp này lúc nào cũng được, chạy lại bao nhiêu lần cũng được. Chưa chạy
-- thì app vẫn chạy y như hôm qua: máy khách dò hàm bằng chính lượt gọi, không
-- thấy thì nút Hoàn tác của nhánh chia chuỗi KHÔNG hiện ra — không hứa thứ chưa
-- làm được (Tracy chốt: nút vắng mặt, không phải hiện rồi báo lỗi khi bấm).
--
-- ⚠️ CHẠY SAU `nang-cap-cat-chuoi-lich.sql`. Không có cú chia thì không có gì
--    để nối; và vế kiểm quyền dùng chung hai cột `khach_sua` · `nguoi_ids` do
--    `nang-cap-quyen-khach.sql` dựng.
-- ═══════════════════════════════════════════════════════════════════════════

create or replace function noi_chuoi_lich(
  p_lich_cu          bigint,       -- nửa TRƯỚC, dòng còn sống sau khi nối
  p_lich_moi         bigint,       -- nửa SAU, dòng sẽ bị xoá
  p_ngay_ket_thuc_cu date,         -- điểm dừng của nửa trước TRƯỚC lúc chia; null = chuỗi vô hạn
  p_sua_luc          timestamptz default null
) returns boolean
language plpgsql security definer set search_path = public as $$
declare
  v_toi uuid := nguoi_id_dang_nhap();
  v_cu  lich_chung%rowtype;
  v_moi lich_chung%rowtype;
begin
  -- LƯỢT DÒ, cùng khuôn `cat_chuoi_lich`: máy khách hỏi "máy chủ có hàm này
  -- chưa" bằng chính chữ ký này. Trả null và không chạm gì — một lượt dò phải
  -- rẻ và phải vô hại.
  if p_lich_cu is null then return null; end if;

  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select * into v_cu from lich_chung where id = p_lich_cu;
  if not found then
    raise exception 'Không còn nửa trước của chuỗi — không nối lại được';
  end if;

  select * into v_moi from lich_chung where id = p_lich_moi;
  if not found then
    -- Ai đó đã xoá nửa sau rồi. Không phải lỗi của người bấm, nhưng cũng không
    -- có gì để nối: nói thẳng thay vì lặng lẽ trả true.
    raise exception 'Nửa sau của chuỗi đã không còn';
  end if;

  if not (v_cu.tao_boi = v_toi
          or (v_cu.khach_sua and v_toi = any(v_cu.nguoi_ids))) then
    raise exception 'Chỉ người tạo sự kiện, hoặc khách được người đó cho quyền sửa, mới nối lại chuỗi';
  end if;

  if p_sua_luc is not null and v_moi.sua_luc is distinct from p_sua_luc then
    raise exception 'Nửa sau của chuỗi đã được sửa sau lúc chia — nối lại sẽ xoá mất thay đổi ấy';
  end if;

  -- ── ① NĂM BẢNG CON VỀ TRƯỚC ──────────────────────────────────────────────
  -- Chuyển TẤT CẢ dòng của nửa sau, không lọc theo ngày: mọi dòng đang móc vào
  -- nó đều là dòng cú chia đã bê sang. Nửa trước không thể có dòng trùng khoá
  -- (lich_id, ngay_goc) vì điểm dừng của nó nằm trước ngày chia — nếu vẫn đụng
  -- thì câu này ném lỗi, và ném lỗi ở đây đúng hơn là ghi đè.
  --
  -- Ba bảng dưới tới sau bảng lịch, và cột `lich_id` của `task` cũng vậy. Nhắc
  -- tên một bảng chưa tồn tại trong plpgsql là hỏng ngay lúc hàm chạy chứ không
  -- phải bỏ qua một câu — nên hỏi danh mục trước rồi mới chạy câu tương ứng.
  update lich_chung_ngoai_le set lich_id = p_lich_cu where lich_id = p_lich_moi;

  if to_regclass('public.lich_chung_tham_du') is not null then
    execute 'update lich_chung_tham_du set lich_id = $1 where lich_id = $2'
      using p_lich_cu, p_lich_moi;
  end if;

  if to_regclass('public.ghi_chu_buoi') is not null then
    execute 'update ghi_chu_buoi set lich_id = $1 where lich_id = $2'
      using p_lich_cu, p_lich_moi;
  end if;

  if to_regclass('public.thong_bao_buoi') is not null then
    execute 'update thong_bao_buoi set lich_id = $1 where lich_id = $2'
      using p_lich_cu, p_lich_moi;
  end if;

  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'task'
                and column_name = 'lich_id') then
    execute 'update task set lich_id = $1 where lich_id = $2'
      using p_lich_cu, p_lich_moi;
  end if;

  -- ── ② ĐIỂM DỪNG CŨ TRẢ VỀ NỬA TRƯỚC ──────────────────────────────────────
  update lich_chung
     set ngay_ket_thuc = p_ngay_ket_thuc_cu, sua_luc = now()
   where id = p_lich_cu;

  -- ── ③ XOÁ NỬA SAU, sau cùng ──────────────────────────────────────────────
  delete from lich_chung where id = p_lich_moi;

  return true;
end $$;

comment on function noi_chuoi_lich(bigint, bigint, date, timestamptz) is
  'Nối lại một chuỗi vừa bị cat_chuoi_lich chia làm hai: chuyển năm bảng con '
  'từ nửa sau về nửa trước, trả điểm dừng cũ, rồi xoá nửa sau. Thứ tự bắt '
  'buộc — xoá trước là để on delete cascade cuốn mất dữ liệu chưa chuyển về. '
  'Chạy bằng quyền định nghĩa, tự kiểm quyền host y như cat_chuoi_lich.';

grant execute on function noi_chuoi_lich(bigint, bigint, date, timestamptz) to authenticated;


-- ─── SỐ LIỆU THAM KHẢO ──────────────────────────────────────────────────────
-- Những chuỗi đang có điểm dừng — dấu hiệu của một cú chia đã xảy ra. Không
-- phải phép kiểm, chỉ để nhìn thấy bối cảnh.
select l.id, l.ten, l.lap, l.ngay_bat_dau, l.ngay_ket_thuc,
       (select count(*) from lich_chung_ngoai_le n where n.lich_id = l.id) as ngoai_le
  from lich_chung l
 where l.dang_dung and l.lap <> 'khong' and l.ngay_ket_thuc is not null
 order by l.ngay_ket_thuc desc
 limit 10;


-- ─── TỰ KIỂM ────────────────────────────────────────────────────────────────
-- Trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh CUỐI CÙNG, nên bộ
-- này đứng ở đây. Dòng chưa đạt nổi lên đầu.
with kiem as (
  select 1 as so, 'hàm có mặt và chạy bằng quyền định nghĩa' as muc,
         exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                  where n.nspname = 'public' and p.proname = 'noi_chuoi_lich'
                    and p.prosecdef) as dat
  union all
  select 2, 'người đăng nhập gọi được',
         exists (select 1 from information_schema.routine_privileges
                  where routine_schema = 'public' and routine_name = 'noi_chuoi_lich'
                    and grantee = 'authenticated' and privilege_type = 'EXECUTE')
  union all
  -- Cùng hàng rào đã đặt cho `cat_chuoi_lich`: một vế `la_lead()` lọt vào đây
  -- là bất kỳ ai đang bật cờ lead cũng nối lại được chuỗi của người khác.
  select 3, 'quyền gọi KHÔNG nới cho lead',
         (select pg_get_functiondef(p.oid) not like '%la_lead()%'
            from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where n.nspname = 'public' and p.proname = 'noi_chuoi_lich')
  union all
  select 4, 'lượt dò trả null, không chạm gì',
         noi_chuoi_lich(null, null, null) is null
  union all
  -- XOÁ PHẢI ĐỨNG SAU NĂM CÂU CHUYỂN. Đây là phép kiểm đáng giá nhất của tệp:
  -- đảo thứ tự là cascade cuốn mất dữ liệu, mà không câu lệnh nào báo. So vị
  -- trí chữ trong chính thân hàm.
  select 5, 'câu xoá nửa sau đứng SAU câu chuyển bảng con',
         (select position('delete from lich_chung where id = p_lich_moi' in def)
                 > position('update lich_chung_ngoai_le set lich_id' in def)
            from (select pg_get_functiondef(p.oid) as def
                    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                   where n.nspname = 'public' and p.proname = 'noi_chuoi_lich') s)
  union all
  -- Hàm nghịch đảo chỉ có nghĩa khi hàm thuận còn đó.
  select 6, 'cat_chuoi_lich vẫn có mặt (hàm này là nghịch đảo của nó)',
         exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                  where n.nspname = 'public' and p.proname = 'cat_chuoi_lich')
)
select so, muc, case when dat then '✅ đạt' else '❌ CHƯA ĐẠT' end as ket_qua
  from kiem order by dat, so;
