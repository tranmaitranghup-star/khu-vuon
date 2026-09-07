-- ═══════════════════════════════════════════════════════════════════════════
-- CHIA MỘT CHUỖI SỰ KIỆN TỪ MỘT NGÀY TRỞ ĐI — Tracy chốt 07/09 (TRI-146)
--
-- Tracy 07/09, kèm ảnh chụp hộp của Lịch Google: *"à trong gg calendar nó có 3
-- lựa chọn ấy — có 1 option là sửa sự kiện này và các sự kiện tiếp theo"*.
--
-- Hai hộp phạm vi của app đang có HAI nấc. Nấc thứ ba bị bỏ có chủ ý, và mã tự
-- khai lý do là "chưa ai xin nó" — nay Tracy xin rồi.
--
-- VÌ SAO NÓ KHÔNG PHẢI THÊM MỘT DÒNG RADIO. Một dòng `lich_chung` là MỘT luật
-- lặp. "Từ đây trở đi" nghĩa là chia nó thành hai luật: đặt điểm dừng cho dòng
-- cũ, rồi đẻ một dòng mới mang giá trị mới. Chuỗi mới có ID MỚI, mà năm bảng
-- khoá theo `lich_id`:
--
--   lich_chung_ngoai_le   buổi đã huỷ riêng · đã dời riêng   → chuyển
--   lich_chung_tham_du    ô tick của CẢ TEAM                 → chuyển
--   ghi_chu_buoi          ghi chú của CẢ TEAM                → chuyển
--   thong_bao_buoi        nội dung host đăng cho từng buổi   → chuyển
--   task                  việc đã đẻ, đang nằm màn Hôm nay   → chuyển
--   doc_su_kien           ai đã đọc mô tả (không có ngày)    → KHÔNG chuyển
--
-- `doc_su_kien` cố ý đứng ngoài: chuỗi mới mang nội dung mới, nên nó đáng được
-- đọc lại. Chép dấu "đã đọc" sang là nói dối về một thứ chưa ai nhìn.
--
-- VÌ SAO PHẢI LÀ MỘT HÀM Ở MÁY CHỦ, hai lẽ, mỗi lẽ đủ để một mình nó quyết:
--   ① BẢY THAO TÁC PHẢI CÙNG ĐỨNG HOẶC CÙNG NGÃ. Hỏng nửa chừng là chuỗi đã bị
--      chia mà dữ liệu nằm hai nơi — không màn nào nói ra, và không đường nào
--      lần lại. Một hàm plpgsql chạy trọn trong MỘT giao dịch; bảy lượt gọi từ
--      máy khách thì không.
--   ② BA TRONG NĂM BẢNG GIỮ DÒNG CỦA NGƯỜI KHÁC. RLS cho mỗi người sửa đúng
--      dòng của mình, và nó chặn theo DÒNG chứ không theo CỘT — nới policy để
--      máy khách với tới là mở trọn cả dòng. Cùng lý lẽ đã dựng nên
--      `doi_gio_viec_theo_chuoi` (TRI-109).
--
-- AI ĐƯỢC GỌI. Đúng bằng quyền SỬA sự kiện, không rộng hơn một ly: host, hoặc
-- khách mời khi host đã bật `khach_sua`. Chép nguyên vế `using` của policy
-- `sua_lich` bản 07/09 — KHÔNG chép bản cũ có `la_lead()`, đúng cái lỗ hổng đã
-- phải vá trong `nang-cap-doi-gio-viec-ca-doi.sql` hôm 07/09. Một hàm
-- `security definer` không tự kiểm quyền là một cánh cửa mở: RLS không chặn hộ.
--
-- Chạy tệp này lúc nào cũng được, chạy lại bao nhiêu lần cũng được. Chưa chạy
-- thì app vẫn chạy y như hôm qua — máy khách dò hàm lúc khởi động, không thấy
-- thì nấc thứ ba không hiện ra, hai nấc cũ nguyên vẹn.
--
-- ⚠️ CHẠY SAU `nang-cap-quyen-khach.sql` — cột `khach_sua` và `nguoi_ids` do
--    tệp ấy dựng. Chạy trước thì câu kiểm quyền ném "column does not exist".
-- ═══════════════════════════════════════════════════════════════════════════

create or replace function cat_chuoi_lich(
  p_lich_id  bigint,
  p_ngay_cat date,
  p_dong     jsonb        -- các cột người dùng vừa khai, đắp lên bản chép
) returns bigint
language plpgsql security definer set search_path = public as $$
declare
  v_toi  uuid := nguoi_id_dang_nhap();
  v_cu   lich_chung%rowtype;
  v_json jsonb;
  v_cot  text;
  v_moi  bigint;
begin
  -- LƯỢT DÒ. Máy khách hỏi "máy chủ đã có hàm này chưa" bằng chính chữ ký này,
  -- đi chung chuyến với bộ dò cột lúc khởi động. Trả `null` và không chạm gì —
  -- một lượt dò phải rẻ và phải vô hại.
  if p_lich_id is null then return null; end if;

  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select * into v_cu from lich_chung where id = p_lich_id;
  if not found then
    raise exception 'Không còn sự kiện này';
  end if;

  if not (v_cu.tao_boi = v_toi
          or (v_cu.khach_sua and v_toi = any(v_cu.nguoi_ids))) then
    raise exception 'Chỉ người tạo sự kiện, hoặc khách được người đó cho quyền sửa, mới chia được chuỗi';
  end if;

  if p_ngay_cat is null then
    raise exception 'Thiếu ngày chia';
  end if;

  -- CA BIÊN: ngày chia CHÍNH LÀ ngày mở chuỗi. Lúc ấy "từ đây trở đi" và "tất
  -- cả" là một chuyện, mà chia thật thì đẻ ra một chuỗi cũ không còn buổi nào
  -- và một điểm dừng lùi trước ngày bắt đầu — phạm ràng buộc `lich_khoang_ngay`
  -- và đổ cả câu. Trả 0 để máy khách rẽ sang nhánh sửa cả chuỗi, đúng thứ người
  -- bấm đang muốn. `lcHuy` đã đi đúng lối này cho hộp xoá.
  if p_ngay_cat <= v_cu.ngay_bat_dau then
    return 0;
  end if;

  if v_cu.ngay_ket_thuc is not null and p_ngay_cat > v_cu.ngay_ket_thuc then
    raise exception 'Ngày chia nằm sau ngày kết thúc của chuỗi';
  end if;

  -- ── CHUỖI MỚI ────────────────────────────────────────────────────────────
  -- Chép nguyên dòng cũ rồi đắp giá trị mới lên. Cột nào người dùng không khai
  -- thì giữ y của chuỗi cũ — nấc này sửa MỘT thứ, không đặt lại cả bản ghi.
  v_json := to_jsonb(v_cu)
         || coalesce(p_dong, '{}'::jsonb)
         || jsonb_build_object('ngay_bat_dau', p_ngay_cat,
                               'tao_luc', now(), 'sua_luc', now());

  -- DANH SÁCH CỘT LẤY TỪ DANH MỤC, KHÔNG GÕ TAY. Bảng này đã nhận thêm cột hơn
  -- mười lần trong hai tuần (mau · tuan_thang · buoc · so_lan · ca_ngay ·
  -- so_ngay · da_chot · tieu_diem_ma · rieng_tu · nguoi_ids · chuc_nang_ids ·
  -- ba cột khach_*), và một danh sách gõ tay thì mỗi cột mới là một trường âm
  -- thầm rơi về mặc định trong chuỗi vừa chia. Lọc bỏ `id`: nó là
  -- `generated always as identity`, gán vào là Postgres từ chối.
  select string_agg(quote_ident(column_name), ', ' order by ordinal_position)
    into v_cot
    from information_schema.columns
   where table_schema = 'public'
     and table_name   = 'lich_chung'
     and is_generated = 'NEVER'
     and identity_generation is null;

  execute format(
    'insert into lich_chung (%s) select %s
       from jsonb_populate_record(null::lich_chung, $1) returning id',
    v_cot, v_cot) into v_moi using v_json;

  -- ── ĐIỂM DỪNG CHO CHUỖI CŨ ───────────────────────────────────────────────
  update lich_chung
     set ngay_ket_thuc = p_ngay_cat - 1, sua_luc = now()
   where id = p_lich_id;

  -- ── NĂM BẢNG CON ĐI THEO, TỪ NGÀY CHIA TRỞ ĐI ────────────────────────────
  -- Khoá của một lượt là NGÀY GỐC, thứ luật lặp sinh ra — buổi đã dời sang chỗ
  -- khác vẫn mang khoá cũ, nên so bằng `ngay_goc` là đúng, không phải ngày mà
  -- nó đang hiện trên lưới.
  --
  -- Ba bảng dưới tới sau bảng lịch, và hai cột của `task` cũng vậy. Nhắc tên
  -- một bảng chưa tồn tại trong plpgsql là hỏng ngay lúc hàm chạy, không phải
  -- bỏ qua một câu — nên hỏi danh mục trước rồi mới chạy câu tương ứng.
  update lich_chung_ngoai_le set lich_id = v_moi
   where lich_id = p_lich_id and ngay_goc >= p_ngay_cat;

  if to_regclass('public.lich_chung_tham_du') is not null then
    execute 'update lich_chung_tham_du set lich_id = $1
              where lich_id = $2 and ngay_goc >= $3'
      using v_moi, p_lich_id, p_ngay_cat;
  end if;

  if to_regclass('public.ghi_chu_buoi') is not null then
    execute 'update ghi_chu_buoi set lich_id = $1
              where lich_id = $2 and ngay_goc >= $3'
      using v_moi, p_lich_id, p_ngay_cat;
  end if;

  if to_regclass('public.thong_bao_buoi') is not null then
    execute 'update thong_bao_buoi set lich_id = $1
              where lich_id = $2 and ngay_goc >= $3'
      using v_moi, p_lich_id, p_ngay_cat;
  end if;

  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'task'
                and column_name = 'lich_ngay') then
    execute 'update task set lich_id = $1
              where lich_id = $2 and lich_ngay >= $3'
      using v_moi, p_lich_id, p_ngay_cat;
  end if;

  -- `doc_su_kien` cố ý KHÔNG đi theo — xem đầu tệp.

  return v_moi;
end $$;

comment on function cat_chuoi_lich(bigint, date, jsonb) is
  'Chia một chuỗi sự kiện làm hai luật từ một ngày trở đi: đặt điểm dừng cho '
  'chuỗi cũ, đẻ chuỗi mới mang giá trị mới, rồi chuyển năm bảng con sang id '
  'mới. Chạy bằng quyền định nghĩa vì ba trong năm bảng giữ dòng của người '
  'khác; hàm tự kiểm đúng quyền sửa sự kiện trước khi chạm gì. Trả về id chuỗi '
  'mới, hoặc 0 khi ngày chia chính là ngày mở chuỗi (khi ấy "từ đây" và "tất '
  'cả" là một chuyện), hoặc null khi được gọi để dò. Tracy chốt 07/09 '
  '(TRI-146), theo hộp ba nấc của Lịch Google.';

grant execute on function cat_chuoi_lich(bigint, date, jsonb) to authenticated;


-- ─── SỐ LIỆU THAM KHẢO ──────────────────────────────────────────────────────
-- Bao nhiêu dòng đang móc vào mỗi chuỗi. Không phải phép kiểm — chỉ để biết
-- một cú chia sẽ phải bê theo chừng nào.
select l.id, l.ten, l.lap,
       (select count(*) from lich_chung_ngoai_le n where n.lich_id = l.id) as ngoai_le,
       (select count(*) from task t where t.lich_id = l.id)                as viec
  from lich_chung l
 where l.dang_dung and l.lap <> 'khong'
 order by viec desc, ngoai_le desc
 limit 10;


-- ─── TỰ KIỂM ────────────────────────────────────────────────────────────────
-- Trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh CUỐI CÙNG, nên bộ
-- này đứng ở đây. Dòng chưa đạt nổi lên đầu.
with kiem as (
  select 1 as so, 'hàm có mặt và chạy bằng quyền định nghĩa' as muc,
         exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                  where n.nspname = 'public' and p.proname = 'cat_chuoi_lich'
                    and p.prosecdef) as dat
  union all
  select 2, 'người đăng nhập gọi được',
         exists (select 1 from information_schema.routine_privileges
                  where routine_schema = 'public' and routine_name = 'cat_chuoi_lich'
                    and grantee = 'authenticated' and privilege_type = 'EXECUTE')
  union all
  -- Hàm KHÔNG được nhận quyền lead. Bảy người đang bật cờ lead, nên một vế
  -- `la_lead()` lọt vào đây là bất kỳ ai trong số đó chia được chuỗi sự kiện
  -- của người khác — đi vòng qua đúng hàng rào quyền host. Lỗi này đã xảy ra
  -- một lần thật, ở `doi_gio_viec_theo_chuoi`.
  select 3, 'quyền gọi KHÔNG nới cho lead',
         (select pg_get_functiondef(p.oid) not like '%la_lead()%'
            from pg_proc p join pg_namespace n on n.oid = p.pronamespace
           where n.nspname = 'public' and p.proname = 'cat_chuoi_lich')
  union all
  select 4, 'lượt dò trả null, không chạm gì',
         cat_chuoi_lich(null, null, null) is null
  union all
  -- Bảng đích của năm câu chuyển phải còn nguyên khoá chính theo (lich_id,
  -- ngay_goc): mất nó thì hai chuỗi có thể cùng giữ một lượt.
  select 5, 'ngoại lệ vẫn khoá theo (lich_id, ngay_goc)',
         exists (select 1 from pg_constraint
                  where conrelid = 'public.lich_chung_ngoai_le'::regclass
                    and contype  = 'p')
)
select so, muc, case when dat then '✅ đạt' else '❌ CHƯA ĐẠT' end as ket_qua
  from kiem order by dat, so;
