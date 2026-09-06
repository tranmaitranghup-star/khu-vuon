-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: ba bảng `van_de`, `van_de_binh_luan`,
-- │ `khach_con_tro`, và cò `chan_sua_cot_van_de`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — QUẢN TRỊ VẤN ĐỀ LIÊN PHÒNG BAN, nhát 1
--                       (Tracy duyệt 05/09/2026 — TRI-111, kèm TRI-26 đổi phạm vi)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            Bảng đạt/chưa đạt nằm ở CUỐI — kéo xuống đáy kết quả mà đọc.
--
-- CHẠY TRƯỚC: `nang-cap-van-de-cho-ban.sql` (nhát 3 — nó nới khung nhìn
--             `cho_ban` và cần bảng `van_de` của tệp này có trước).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 05/09: vấn đề phát sinh ở phòng này nhưng cách gỡ nằm ở phòng khác —
-- *"sales dùng CRM gặp vướng cần chuyển phòng vận hành · khách phàn nàn khoá
-- học cần phòng sản phẩm xem xét · khách cháy tài khoản do người của mình hỗ
-- trợ"*. Ba yêu cầu nguyên văn: **lưu trữ · bàn luận · mọi người đều theo dõi
-- được**. Và về chỗ đứng: *"mình có kênh thông báo ấy, các vấn đề và thông báo
-- đều đưa lên kênh đó đi"*.
--
-- Luật vận hành (thứ đội phải theo, không phụ thuộc công cụ):
--   `wiki/cong-ty/rova/van-de-lien-phong.md`
-- Đặc tả máy:  `production/tinh-thuc-app/dac-ta-van-de-lien-phong.md`
-- Bản bao:     `production/du-an/kien-truc-quan-tri-van-de-rova.md`
--
-- ─── BỐN HÀNG RÀO, VÀ VÌ SAO GIAO DIỆN KHÔNG LÀM ĐƯỢC CÁI NÀO ───────────────
--   ① Chỉ người nêu được đóng     → ràng buộc bảng + cò `chan_sua_cot_van_de`
--   ② Hạn 24 giờ do máy đặt       → mặc định cột + cò giữ nguyên bản cũ
--   ③ Nêu chỉ dưới tên mình       → policy `them_van_de` vế `with check`
--   ④ Không ai xoá được vấn đề    → CỐ Ý KHÔNG CÓ policy delete
--
-- Cả bốn đều là thứ một người gửi thẳng câu lệnh lên máy chủ sẽ đi vòng qua
-- được nếu hàng rào chỉ nằm trong giao diện. Và ① không thể là policy: **phân
-- quyền của Postgres tính theo DÒNG, không theo CỘT** — cho hai bên cùng sửa
-- một dòng là cho cả hai sửa mọi cột của dòng ấy. Nên nó phải là một cò.
--
-- ─── MỘT CHỖ CỐ Ý LÀM NHỎ ───────────────────────────────────────────────────
-- `khach_con_tro` KHÔNG phải bảng khách. Bản chốt kiến trúc bốn app 23/08 có
-- dòng chặn: *"dữ liệu thô của khách không sang app ① và ②"*. Khách thuộc kho
-- CRM. Ở đây chỉ ba trường — số điện thoại chuẩn hoá, tên hiển thị, link mở
-- CRM — đủ để neo một vấn đề vào một người ngoài công ty, và không hơn.
-- ============================================================================

begin;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. BẢNG CON TRỎ KHÁCH — ba trường, không hơn                       (TRI-26)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists khach_con_tro (
  sdt      text primary key,
  ten      text not null default '',
  link_crm text not null default '',
  tao_luc  timestamptz not null default now()
);

comment on table khach_con_tro is
  'CON TRỎ sang CRM, KHÔNG phải bảng khách. Ba trường: số điện thoại chuẩn hoá '
  '84xxx (khoá, cùng khoá MDM của cả bốn app) · tên hiển thị · link mở hồ sơ '
  'bên CRM. Nguồn chân lý về khách luôn nằm ở kho CRM (Vercel); bảng này là bản '
  'nhớ đệm để một vấn đề neo được vào một người ngoài công ty. Thêm cột hồ sơ '
  'khách vào đây là dựng bản sao thứ hai của CRM — đúng thứ MDM sinh ra để tránh.';

comment on column khach_con_tro.sdt is
  'Chuẩn hoá 84xxx: bỏ khoảng trắng và dấu chấm, 0 đầu thành 84, +84 thành 84. '
  'App chuẩn hoá trước khi gửi; ràng buộc dưới đây là chốt chặn cuối.';

-- Ràng buộc đặt rời để chạy lại tệp không ngã ở bước `add`.
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'khach_sdt_chuan') then
    alter table khach_con_tro
      add constraint khach_sdt_chuan check (sdt ~ '^84[0-9]{8,10}$');
  end if;
end $$;

alter table khach_con_tro enable row level security;

drop policy if exists doc_khach_con_tro on khach_con_tro;
drop policy if exists ghi_khach_con_tro on khach_con_tro;
drop policy if exists sua_khach_con_tro on khach_con_tro;

-- Đọc, thêm và sửa: cả team. Đây là bản nhớ đệm dùng chung — ai gắn một khách
-- vào một vấn đề cũng cần đặt được dòng ấy vào, và một cái tên gõ nhầm phải
-- sửa lại được. Số điện thoại là khoá chính nên nó tự đứng yên.
-- Không có policy XOÁ: một con trỏ bị gỡ là mọi vấn đề đang neo vào nó mất tên
-- khách mà không dòng nào báo.
create policy doc_khach_con_tro on khach_con_tro for select
  using (la_thanh_vien());
create policy ghi_khach_con_tro on khach_con_tro for insert
  with check (la_thanh_vien());
create policy sua_khach_con_tro on khach_con_tro for update
  using (la_thanh_vien()) with check (la_thanh_vien());


-- ════════════════════════════════════════════════════════════════════════════
-- 2. BẢNG VẤN ĐỀ                                                    (TRI-111)
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists van_de (
  id             bigint generated always as identity primary key,
  tieu_de        text        not null,
  mo_ta          text        not null default '',
  nguoi_neu_id   uuid        not null references nguoi(id),
  chuc_nang_neu  smallint             references chuc_nang(id),
  chuc_nang_nhan smallint    not null references chuc_nang(id),
  nguoi_nhan_id  uuid        not null references nguoi(id),
  khach_sdt      text,
  la_ca          boolean     not null default false,
  muc            smallint    not null default 2,
  trang_thai     text        not null default 'moi',
  loai_lap       text        not null default '',
  han_tra_loi    timestamptz not null default (now() + interval '24 hours'),
  nhan_luc       timestamptz,
  dong_luc       timestamptz,
  nguoi_dong_id  uuid                 references nguoi(id),
  tao_luc        timestamptz not null default now()
);

comment on table van_de is
  'Vấn đề liên phòng ban: thứ phát sinh ở phòng này mà cách gỡ nằm ở phòng khác. '
  'Khác BẢNG TIN ở ba chỗ, và ba chỗ ấy là lý do nó không nhập chung `ban_tin`: '
  'ai cũng nêu được (bảng tin chỉ lead đăng) · có người nhận đích danh, có trạng '
  'thái và có đồng hồ (tin chỉ đưa tin) · `chuc_nang_nhan` là ĐÍCH chuyển giao '
  '(tag của bảng tin chỉ là nhãn nhận diện). Hai bảng, nhưng chung một cửa vào '
  'trong app: màn sau nút loa, hai nấc.';

comment on column van_de.chuc_nang_neu is
  'Phòng của người nêu. ĐỂ TRỐNG ĐƯỢC, và app điền chứ không suy ở đây: từ '
  '03/09 `nguoi.chuc_nang_ids` là MỘT MẢNG, nên người ngồi nhiều phòng không có '
  'câu trả lời duy nhất. Cửa ghi đi theo lối đã chốt cho việc cố định — tự điền '
  'khi người ấy chỉ thuộc một phòng, chỉ hỏi khi thuộc nhiều phòng.';

comment on column van_de.khach_sdt is
  'Con trỏ sang `khach_con_tro`, CỐ Ý không phải khoá ngoại: một vấn đề vẫn '
  'phải ghi được khi chưa ai kịp đặt dòng con trỏ cho khách ấy. Trống nếu vấn '
  'đề không gắn khách nào.';

comment on column van_de.la_ca is
  'NỢ CÓ NGÀY TRẢ. Bật khi đây là CA của một khách (đích là xử xong cho khách '
  'đó) chứ không phải VẤN ĐỀ của hệ thống (đích là không tái diễn). Chỗ đúng của '
  'ca là app ③ CRM; nó nằm tạm ở đây vì CRM chưa có chỗ chứa. Ranh giới hỏi bằng '
  'một câu: đóng xong thì ai được lợi — một khách, hay mọi khách sau này?';

comment on column van_de.han_tra_loi is
  'Máy đặt = lúc tạo + 24 giờ. Cò `chan_sua_cot_van_de` giữ nguyên bản cũ ở mọi '
  'lượt sửa, nên không ai dời được hạn của chính mình. "Trả lời" nghĩa là ĐÃ NHẬN '
  'và định xử thế nào — khác hạn xong.';

comment on column van_de.loai_lap is
  'Nhãn gom các vấn đề cùng loại, nuôi luật lặp ba lần. Nay là chữ tự do nên sẽ '
  'tản mát; bản sau gom thành danh sách chọn sinh từ chính dữ liệu.';

-- ─── Ràng buộc: ba nấc mức, sáu trạng thái, và luật chỉ người nêu được đóng ──
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'van_de_muc_hop_le') then
    alter table van_de add constraint van_de_muc_hop_le check (muc in (1, 2, 3));
  end if;

  if not exists (select 1 from pg_constraint where conname = 'van_de_trang_thai_hop_le') then
    alter table van_de add constraint van_de_trang_thai_hop_le
      check (trang_thai in ('moi','da_nhan','dang_xu_ly','cho_ben_khac','xong','khong_lam'));
  end if;

  /* Hàng rào ① ở tầng dữ liệu. Cò bên dưới canh AI đang gõ; ràng buộc này canh
     KẾT QUẢ — một dòng mang trạng thái `xong` mà người đóng không phải người nêu
     thì không tồn tại được, kể cả khi ai đó chạy thẳng câu lệnh trong SQL Editor.
     `khong_lam` đứng ngoài ràng buộc, cố ý: đó là lối ra mà quản trị cũng đi được
     (bảng trạng thái của đặc tả), và lúc ấy ô người đóng phải ghi ĐÚNG TÊN quản
     trị. Ép nó bằng tên người nêu cho khớp ràng buộc là để lại một dòng nói dối
     — mà `xong`, câu "đã hết chưa", vẫn giữ nguyên hàng rào chặt. */
  if not exists (select 1 from pg_constraint where conname = 'van_de_chi_nguoi_neu_dong') then
    alter table van_de add constraint van_de_chi_nguoi_neu_dong
      check (nguoi_dong_id is null
             or nguoi_dong_id = nguoi_neu_id
             or trang_thai = 'khong_lam');
  end if;
end $$;

create index if not exists van_de_cho_nhan on van_de (nguoi_nhan_id)
  where nhan_luc is null;
create index if not exists van_de_dem_lap on van_de (loai_lap, tao_luc)
  where loai_lap <> '';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. MẠCH BÀN LUẬN — để hai phòng nói chuyện tại chỗ, không trong Zalo
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists van_de_binh_luan (
  id        bigint generated always as identity primary key,
  van_de_id bigint      not null references van_de(id) on delete cascade,
  nguoi_id  uuid        not null references nguoi(id),
  noi_dung  text        not null,
  tao_luc   timestamptz not null default now()
);

create index if not exists van_de_bl_theo_van_de
  on van_de_binh_luan (van_de_id, tao_luc);

comment on table van_de_binh_luan is
  'Mạch bàn luận của một vấn đề. `on delete cascade` là chỗ DUY NHẤT bình luận '
  'biến mất — mà `van_de` cố ý không có policy xoá, nên trên thực tế không đường '
  'nào trong app gỡ được chúng.';


-- ════════════════════════════════════════════════════════════════════════════
-- 4. CÒ KHOÁ TỪNG CỘT — hàng rào ① và ②
-- ════════════════════════════════════════════════════════════════════════════
-- Chạy cho MỌI lượt update, không chỉ lượt của người ngoài cuộc: một cò chỉ
-- đúng trong một số cảnh là một cò phải đi kèm trí nhớ của người đọc mã.
-- Khuôn chép từ `chan_khach_sua_cot_cam()` (lich_chung, 04/09) và
-- `chan_tu_go_quyen()` (nguoi, 05/09), gồm cả lối thoát cho SQL Editor.
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

  -- Hàng rào ①: chỉ NGƯỜI NÊU đóng. `khong_lam` mở thêm cho quản trị, đúng
  -- bảng trạng thái của đặc tả. Người xử lý báo xong bằng `dang_xu_ly` → cửa
  -- app hiện nút Đóng cho riêng người nêu.
  if new.trang_thai in ('xong','khong_lam')
     and old.trang_thai not in ('xong','khong_lam') then
    if not (nguoi_id_dang_nhap() = old.nguoi_neu_id
            or (new.trang_thai = 'khong_lam' and la_quan_tri_dang_nhap())) then
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

drop trigger if exists tg_chan_sua_cot_van_de on van_de;
create trigger tg_chan_sua_cot_van_de
  before update on van_de
  for each row execute function chan_sua_cot_van_de();


-- ════════════════════════════════════════════════════════════════════════════
-- 5. POLICY — bốn mức, và một chỗ CỐ Ý TRỐNG
-- ════════════════════════════════════════════════════════════════════════════
alter table van_de enable row level security;
alter table van_de_binh_luan enable row level security;

drop policy if exists doc_van_de   on van_de;
drop policy if exists them_van_de  on van_de;
drop policy if exists sua_van_de   on van_de;

-- Đọc: cả team, mọi vấn đề. Đây là chữ *"mọi người đều theo dõi được"* của
-- Tracy, và cùng lẽ với bảng tin — doanh nghiệp nhỏ thì thông tin nên thông suốt.
create policy doc_van_de on van_de for select
  using (la_thanh_vien());

-- Ghi: ai trong team cũng nêu được, nhưng CHỈ DƯỚI TÊN MÌNH. Vế `with check`
-- là thứ chặn cú ghi một dòng rồi gán tên người khác vào ô người nêu.
create policy them_van_de on van_de for insert
  with check (la_thanh_vien() and nguoi_neu_id = nguoi_id_dang_nhap());

-- Sửa: hai bên trong cuộc, cộng quản trị. Người ngoài cuộc bàn luận được
-- (bảng bình luận) nhưng không đổi được dòng vấn đề.
-- `with check` lặp lại đúng điều kiện để không ai sửa một dòng rồi ĐẨY nó sang
-- tên hai người khác, tự đưa mình ra khỏi tầm với của chính policy này.
create policy sua_van_de on van_de for update
  using      (nguoi_neu_id  = nguoi_id_dang_nhap()
           or nguoi_nhan_id = nguoi_id_dang_nhap()
           or la_quan_tri_dang_nhap())
  with check (nguoi_neu_id  = nguoi_id_dang_nhap()
           or nguoi_nhan_id = nguoi_id_dang_nhap()
           or la_quan_tri_dang_nhap());

/* CỐ Ý KHÔNG CÓ policy DELETE trên `van_de`. Cùng lẽ với bảng `nguoi`: xoá một
   vấn đề là xoá luôn mạch bàn luận đã treo vào nó, và xoá cả bằng chứng cho
   luật lặp ba lần — cái đếm ấy chỉ có nghĩa khi không ai dọn được lịch sử.
   Lối ra đúng là trạng thái `khong_lam`, nó để lại dấu vết. */

drop policy if exists doc_van_de_bl on van_de_binh_luan;
drop policy if exists ghi_van_de_bl on van_de_binh_luan;
drop policy if exists sua_van_de_bl on van_de_binh_luan;

create policy doc_van_de_bl on van_de_binh_luan for select
  using (la_thanh_vien());
create policy ghi_van_de_bl on van_de_binh_luan for insert
  with check (la_thanh_vien() and nguoi_id = nguoi_id_dang_nhap());
create policy sua_van_de_bl on van_de_binh_luan for update
  using      (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());


commit;


-- ════════════════════════════════════════════════════════════════════════════
-- SỐ LIỆU THAM KHẢO — không có đúng/sai
-- ════════════════════════════════════════════════════════════════════════════
select
  (select count(*) from van_de)            as van_de_dang_co,
  (select count(*) from van_de_binh_luan)  as binh_luan_dang_co,
  (select count(*) from khach_con_tro)     as con_tro_khach,
  (select count(*) from chuc_nang)         as so_khoi_chuc_nang,
  (select count(*) from nguoi
     where ngay_nghi is null)              as nguoi_dang_lam;


-- ════════════════════════════════════════════════════════════════════════════
-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả mười dòng ═══════════════════════════
-- ════════════════════════════════════════════════════════════════════════════
-- Đặt CUỐI tệp vì trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh
-- cuối cùng. `order by dat, so` đẩy dòng chưa đạt lên đầu.
--
-- ⚠️ Không dòng nào ở đây so chuỗi với một `check` hay một policy. Postgres
--    KHÔNG cất lại nguyên văn câu mình gõ — nó phân tích rồi in lại, từ khoá
--    viết HOA và ngoặc thêm vào. Mẫu `like` chứa từ khoá thì ra ❌ oan, mà ❌
--    oan tệ hơn không kiểm: nó dạy người đọc thôi tin cả bảng. Nên dưới đây
--    chỉ soi TÊN và ĐẾM.
select * from (values

  (1, 'ba bảng mới đã có mặt',
   (select count(*) from information_schema.tables
     where table_schema = 'public'
       and table_name in ('van_de','van_de_binh_luan','khach_con_tro')) = 3),

  (2, 'van_de đủ mười bảy cột',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'van_de') = 17),

  (3, 'ba ràng buộc của van_de đã dựng (mức · trạng thái · chỉ người nêu đóng)',
   (select count(*) from pg_constraint
     where conname in ('van_de_muc_hop_le','van_de_trang_thai_hop_le',
                       'van_de_chi_nguoi_neu_dong')) = 3),

  (4, 'con trỏ khách CHỈ có bốn cột — nó không phải bảng khách',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'khach_con_tro') = 4),

  (5, 'hạn trả lời do máy đặt, không để trống',
   (select column_default is not null and is_nullable = 'NO'
      from information_schema.columns
     where table_schema = 'public' and table_name = 'van_de'
       and column_name = 'han_tra_loi')),

  (6, 'cò khoá cột đã dựng trên van_de',
   (select count(*) from pg_trigger
     where not tgisinternal and tgname = 'tg_chan_sua_cot_van_de') = 1),

  (7, 'cò ấy chạy bằng quyền định nghĩa (security definer)',
   (select prosecdef from pg_proc where proname = 'chan_sua_cot_van_de')),

  /* Dòng này canh một thứ KHÔNG CÓ. Thiếu policy delete chính là hàng rào —
     thêm nó vào sau này là mở đường xoá vấn đề mà không ai để ý. */
  (8, 'không có policy xoá nào trên van_de',
   (select count(*) from pg_policies
     where tablename = 'van_de' and cmd = 'DELETE') = 0),

  (9, 'ba policy của van_de đã dựng (đọc · thêm · sửa)',
   (select count(*) from pg_policies
     where tablename = 'van_de'
       and policyname in ('doc_van_de','them_van_de','sua_van_de')) = 3),

  (10, 'con trỏ khách: ba policy, và cũng không có đường xoá',
   (select count(*) from pg_policies where tablename = 'khach_con_tro') = 3
   and (select count(*) from pg_policies
         where tablename = 'khach_con_tro' and cmd = 'DELETE') = 0)

) as t(so, muc, dat)
order by dat, so;
