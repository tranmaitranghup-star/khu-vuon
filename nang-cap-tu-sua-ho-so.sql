-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ SỬA HỒ SƠ — mỗi người sửa được bốn trường cá nhân của chính mình
-- Làn MCN · 05/09/2026 · TRI-128
-- ═══════════════════════════════════════════════════════════════════════════
-- Tracy giao: *"cho người đó tự thay đổi thông tin cá nhân ở đây được nữa nhé"*
-- (màn Cá nhân, mở bằng avatar ở thanh lề).
--
-- Trước tệp này, bảng `nguoi` chỉ có MỘT đường ghi: policy `sua_nguoi`, dành
-- riêng cho quản trị. Tệp này mở đường thứ hai — hẹp hơn hẳn.
--
-- ĐƯỜNG RANH, và đây là phần đáng đọc kỹ:
--   · TỰ SỬA ĐƯỢC → ten · ho_ten · ngay_sinh · so_dien_thoai.
--     Bốn thứ đúng kể cả khi người ấy rời công ty; không cái nào mở thêm cho ai
--     thấy gì hay giao được cho ai.
--   · KHÔNG TỰ SỬA ĐƯỢC → mọi cột còn lại. vai · chuc_nang_ids · leader_id và
--     ba cờ quyền QUYẾT AI THẤY VIỆC GÌ; bốn cột `so_*_toi_da` là hạn mức do
--     quản lý đặt; `email` là cửa đăng nhập. Cho tự đổi là cho tự cấp quyền.
--
-- ⚠️ VÌ SAO PHẢI CÓ CẢ MỘT CÒ, KHÔNG CHỈ MỘT POLICY. Quyền của Postgres tính
--    theo DÒNG. Một policy nói được "anh sửa dòng của anh", nhưng KHÔNG nói
--    được "chỉ sửa bốn cột này" — cùng cái bẫy mà `chan_tu_go_quyen` đã canh
--    trong `nang-cap-co-cau-to-chuc.sql`. Không có cò thì một người tự bật
--    `la_quan_tri` cho mình bằng đúng một lượt gọi máy chủ.
--
-- Chạy MỘT LẦN trên Supabase → SQL Editor. Chạy lại lần nữa không hỏng gì.
-- Cần chạy `nang-cap-co-cau-to-chuc.sql` TRƯỚC (tệp này mượn hai hàm của nó:
-- `nguoi_id_dang_nhap()` và `la_quan_tri_dang_nhap()`).


-- ═══ 1. POLICY — chính chủ được ghi dòng của chính mình ════════════════════
-- Hai policy UPDATE cùng đứng trên bảng `nguoi` và Postgres nối chúng bằng
-- HOẶC: quản trị đi cửa `sua_nguoi`, người thường đi cửa này. `with check` phải
-- lặp lại điều kiện của `using`, không thì một người sửa dòng mình rồi đổi luôn
-- `id` sang người khác — `using` gác dòng TRƯỚC khi sửa, `with check` gác dòng
-- SAU khi sửa.
drop policy if exists tu_sua_ho_so on nguoi;
create policy tu_sua_ho_so on nguoi for update
  using      (id = nguoi_id_dang_nhap())
  with check (id = nguoi_id_dang_nhap());

comment on policy tu_sua_ho_so on nguoi is
  'Chính chủ ghi được dòng của mình. Cột nào được đổi thật thì cò '
  'chan_tu_sua_co_cau quyết — policy chỉ gác theo DÒNG.';


-- ═══ 2. CÒ — trả lại nguyên bản mọi cột ngoài bốn cột cá nhân ══════════════
-- DANH SÁCH TRẮNG, cố ý không phải danh sách đen. Cột mới thêm vào bảng `nguoi`
-- ngày sau sẽ được bảo vệ SẴN, không phải chờ ai nhớ ra mà bổ sung vào đây.
-- Đó là khác biệt thật giữa hai cách viết, không phải chuyện gọn hay dài.
create or replace function chan_tu_sua_co_cau()
returns trigger language plpgsql security definer
set search_path = public
as $$
declare
  duoc text[] := array['ten', 'ho_ten', 'ngay_sinh', 'so_dien_thoai'];
  giu  jsonb;
  moi  jsonb;
  k    text;
begin
  -- Lượt chạy từ SQL Editor không có token nên không có "chính mình" — để yên.
  -- Đây là lối chữa cháy cuối cùng của Tracy, cùng lẽ với `chan_tu_go_quyen`.
  if email_dang_nhap() = '' then return new; end if;
  -- Quản trị sửa qua màn Team thì được đổi mọi thứ, kể cả dòng của chính họ:
  -- đó là công việc của họ. Cò này chỉ canh người thường tự sửa hồ sơ mình.
  if la_quan_tri_dang_nhap() then return new; end if;
  -- Sửa dòng người khác thì policy ở trên đã chặn từ trước khi tới đây.
  if old.id is distinct from nguoi_id_dang_nhap() then return new; end if;

  giu := to_jsonb(old);
  moi := to_jsonb(new);
  foreach k in array duoc loop
    giu := jsonb_set(giu, array[k], moi -> k);
  end loop;
  new := jsonb_populate_record(new, giu);
  return new;
end $$;

-- ⚠️ TÊN CÒ MANG TIỀN TỐ `tg_`, KHÁC TÊN HÀM. Đây là quy ước của kho, thấy ở
-- `tg_chan_tu_go_quyen` · `tg_chan_trong_quan_tri` · `tg_chan_khach_sua_cot_cam`.
-- Bản đầu 05/09 đặt cò trùng tên hàm, và chính bộ tự kiểm bên dưới đã dò nhầm
-- theo tên hàm rồi báo ❌ oan cho cò cũ. Hai cái tên phải khác nhau thì mọi câu
-- dò mới buộc phải nói rõ nó đang hỏi CÒ hay hỏi HÀM.
drop trigger if exists chan_tu_sua_co_cau on nguoi;     -- tên cũ, bản 05/09 đầu
drop trigger if exists tg_chan_tu_sua_co_cau on nguoi;
create trigger tg_chan_tu_sua_co_cau
  before update on nguoi
  for each row execute function chan_tu_sua_co_cau();

-- Chú thích gắn lên HÀM, không lên cò: hàm là chỗ ai đọc `\df` cũng thấy.
comment on function chan_tu_sua_co_cau() is
  'Người thường tự sửa hồ sơ: giữ nguyên mọi cột trừ ten, ho_ten, ngay_sinh, '
  'so_dien_thoai. Danh sách TRẮNG nên cột mới được bảo vệ sẵn.';


-- ═══ 3. TỰ KIỂM — xếp CUỐI để trình soạn Supabase bày đúng bảng này ════════
-- (Trình soạn chỉ hiện kết quả của câu lệnh CUỐI CÙNG. Dòng chưa đạt nổi lên
--  đầu nhờ `order by dat`.)
with kiem as (
  select 1 as so, 'Policy tu_sua_ho_so có trên bảng nguoi' as muc,
         exists (select 1 from pg_policies
                 where tablename = 'nguoi' and policyname = 'tu_sua_ho_so') as dat
  union all
  select 2, 'Policy sua_nguoi của quản trị vẫn còn',
         exists (select 1 from pg_policies
                 where tablename = 'nguoi' and policyname = 'sua_nguoi')
  union all
  -- Hỏi TÊN CÒ (`tg_…`), không hỏi tên hàm. Bản đầu hỏi tên hàm và ca ④ báo
  -- ❌ oan cho một cò đang chạy tốt — mà ❌ oan tệ hơn không kiểm: nó dạy người
  -- đọc thôi tin cả bảng.
  select 3, 'Cò tg_chan_tu_sua_co_cau gắn trên bảng nguoi',
         exists (select 1 from pg_trigger
                 where tgrelid = 'nguoi'::regclass
                   and tgname  = 'tg_chan_tu_sua_co_cau' and not tgisinternal)
  union all
  select 4, 'Cò tg_chan_tu_go_quyen cũ vẫn còn (hai cò cùng canh, không thay nhau)',
         exists (select 1 from pg_trigger
                 where tgrelid = 'nguoi'::regclass
                   and tgname  = 'tg_chan_tu_go_quyen' and not tgisinternal)
  union all
  select 5, 'Bảng nguoi có đủ bốn cột tự sửa',
         (select count(*) = 4 from information_schema.columns
          where table_name = 'nguoi'
            and column_name in ('ten', 'ho_ten', 'ngay_sinh', 'so_dien_thoai'))
  union all
  -- Ca này chạy THẬT cái phép mà cò dùng, trên một dòng thật của bảng: dựng
  -- lại y nguyên một dòng người từ jsonb của chính nó. Đạt nghĩa là ba hàm
  -- to_jsonb · jsonb_set · jsonb_populate_record ăn khớp với hình dạng bảng
  -- này — thứ mà một ca "hàm có tồn tại không" không chứng minh được.
  select 6, 'Phép dựng lại dòng bằng jsonb chạy đúng trên bảng nguoi',
         coalesce((select jsonb_populate_record(n, jsonb_set(to_jsonb(n),
                            array['ten'], to_jsonb(n.ten))) = n
                   from nguoi n order by thu_tu limit 1), true)
)
select so, case when dat then '✅' else '❌' end as ket, muc from kiem
order by dat, so;
