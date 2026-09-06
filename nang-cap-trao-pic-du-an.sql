-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `muc_tieu.pic_moi_luc`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-trao-pic-du-an.sql                   (Tracy giao 2026-08-31, làn TP)
--
-- Dán trọn file vào Supabase › SQL Editor › Run. CHẠY LẠI NHIỀU LẦN VÔ HẠI.
-- Xong thì nhìn bảng cuối cùng: mọi dòng phải ✅.
--
-- ⚠️ CHẠY SAU HAI TỆP NÀY, KHÔNG ĐƯỢC TRƯỚC:
--      ① `nang-cap-cho-ban.sql`        (nó dựng `thanh_vien_du_an.da_xem_luc`)
--      ② `nang-cap-giao-cam-ket.sql`   (nó dựng `cho_ban` bản bốn nhánh)
--    Tệp này dựng lại `cho_ban` thành SÁU nhánh. Chạy lại một trong hai tệp
--    trên SAU tệp này là cuốn mất hai nhánh mới TRONG IM LẶNG — khối "Chờ bạn"
--    thôi bày lời trao PIC, không một dòng lỗi nào. Cùng họ với bẫy 1 của
--    `BAN-GIAO-SQL-giao-va-kho-cam-ket.md`. Gặp ca ấy thì chạy lại tệp này.
--
-- ─── ĐỀ BÀI ────────────────────────────────────────────────────────────────
-- Tracy 31/08: *"làm tính năng đổi pic cho tôi"* → chốt ba điều:
--   ① **Đi theo khuôn cam kết** — *"oke cứ như cam kết đi"*. Tức KHÔNG trao
--      thẳng: có nấc CHỜ NHẬN, người kia gật hoặc từ chối kèm lý do, người
--      trao rút lại được khi chưa ai trả lời.
--   ② **Hỏi PIC cũ ở lại làm thành viên hay rời hẳn dự án** — khai lúc trao,
--      máy chủ thi hành lúc người kia gật.
--   ③ Chỉ dự án **chưa đóng** mới trao được (kho · đang chạy · nghẽn).
--
-- ─── VÌ SAO LÀ HÀM, KHÔNG PHẢI NỚI POLICY ──────────────────────────────────
-- Policy `sua_muctieu` (nang-cap-cam-ket-va-muc-tieu.sql) khai:
--     using (nguoi_id = nguoi_id_dang_nhap()) with check (nguoi_id = …)
-- Vế `with check` soi dòng SAU khi sửa, nên đổi `nguoi_id` sang người khác là
-- vi phạm — kể cả gọi thẳng REST. Đó là hàng rào đang giữ cho không ai đổi chủ
-- một dự án sau lưng người khác, và tệp này KHÔNG nới nó. Bốn hàm dưới chạy
-- `security definer`, mỗi hàm tự dựng hàng rào riêng bằng tiếng Việt đọc được.
--
-- ─── BỐN THỨ TỆP NÀY KHÔNG ĐỤNG ────────────────────────────────────────────
--   · Không nới, không gỡ policy nào của `muc_tieu`.
--   · Không đụng tầng cam kết: `giao_cam_ket` · `nhan_viec_cam_ket` ·
--     `kiem_giao_cam_ket` · `kiem_tran_cam_ket` giữ nguyên từng chữ.
--   · KHÔNG viết lại trần số dự án. `kiem_tran_danh_muc` (mang-du-an mục 11)
--     đã gác sẵn `before update on muc_tieu` và nhánh sớm của nó CỐ Ý thả cho
--     ca đổi chủ đi vào phần đếm — nên trao PIC cho người đã gánh đủ trần thì
--     chính nó chặn, bằng câu lỗi của nó. Viết lại ở đây là dựng chỗ thứ hai
--     giữ cùng một luật.
--   · Không đụng `thanh_vien_du_an` ngoài đúng một câu xoá ở hàm nhận, khi
--     PIC cũ đã khai là muốn rời hẳn.
-- ════════════════════════════════════════════════════════════════════════════

begin;


-- ════════════════════════════════════════════════════════════════════════════
-- 1. SÁU CỘT MỚI — SỔ GHI MỘT LỜI TRAO ĐANG TREO
-- ════════════════════════════════════════════════════════════════════════════
-- Một dự án chỉ treo được MỘT lời trao tại một lúc, nên sổ nằm thẳng trên
-- `muc_tieu`, không dựng bảng riêng. Muốn trao cho người khác thì rút lời cũ
-- lại đã — đúng nếp "một cam kết một chỗ" của tầng bên cạnh.

alter table muc_tieu add column if not exists pic_moi_id      uuid references nguoi (id) on delete set null;
alter table muc_tieu add column if not exists pic_moi_boi     uuid references nguoi (id) on delete set null;
alter table muc_tieu add column if not exists pic_moi_luc     timestamptz;
alter table muc_tieu add column if not exists pic_cu_o_lai    boolean;
alter table muc_tieu add column if not exists pic_tu_choi_luc timestamptz;
alter table muc_tieu add column if not exists pic_tu_choi_ly_do text;

comment on column muc_tieu.pic_moi_id is
  'Người đang được mời nhận vai PIC dự án. Rỗng = không có lời trao nào treo.';
comment on column muc_tieu.pic_moi_boi is
  'Ai trao. Khoá ngoại on delete set null — người trao rời đội thì cột này tự rỗng, nên ĐỪNG neo dấu nhận biết vào đây (bẫy 4 của tầng giao cam kết). Neo vào pic_moi_luc.';
comment on column muc_tieu.pic_moi_luc is
  'DẤU NHẬN BIẾT của một lời trao đang treo. Mọi câu hỏi "có ai đang được mời không" phải soi cột này.';
comment on column muc_tieu.pic_cu_o_lai is
  'Lựa chọn của PIC cũ khai NGAY LÚC TRAO: true = ở lại làm thành viên thường, false = rời hẳn dự án. Máy chủ thi hành lúc người kia bấm nhận, không phải lúc trao.';
comment on column muc_tieu.pic_tu_choi_luc is
  'Lúc người được trao từ chối. Dòng Ở LẠI để PIC hiện tại nhìn thấy qua khối Chờ bạn; lối ra duy nhất là rut_lai_trao_pic().';
comment on column muc_tieu.pic_tu_choi_ly_do is
  'Lý do từ chối, máy chủ bắt buộc khai.';

create index if not exists trao_pic_dang_treo on muc_tieu (pic_moi_id)
  where pic_moi_luc is not null;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. BA RÀNG BUỘC
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ LOGIC BA TRỊ (bẫy 3 của tầng giao cam kết): mỗi biểu thức dưới đây đều
-- phải trả về FALSE khi vi phạm, chứ không NULL — NULL là ĐI QUA. Vì vậy vế
-- nào cũng mở đầu bằng một phép soi `is null` tường minh, không dựa vào `and`.

alter table muc_tieu drop constraint if exists khong_trao_pic_cho_minh;
alter table muc_tieu add  constraint khong_trao_pic_cho_minh
  check (pic_moi_id is null or pic_moi_id is distinct from nguoi_id);
--   pic_moi_id rỗng            → true  → đi qua (không có lời trao nào)
--   pic_moi_id = nguoi_id      → false → CHẶN  (tự trao cho chính mình)
--   pic_moi_id khác nguoi_id   → true  → đi qua
--   nguoi_id rỗng (không xảy ra, cột NOT NULL) → `is distinct from` vẫn ra true

alter table muc_tieu drop constraint if exists pic_tu_choi_phai_khai_ly_do;
alter table muc_tieu add  constraint pic_tu_choi_phai_khai_ly_do
  check (pic_tu_choi_luc is null
         or length(trim(coalesce(pic_tu_choi_ly_do, ''))) > 0);
--   chưa từ chối               → true  → đi qua
--   đã từ chối + lý do rỗng    → false → CHẶN   (coalesce lo ca NULL)
--   đã từ chối + có lý do      → true  → đi qua

alter table muc_tieu drop constraint if exists pic_tu_choi_phai_co_loi_trao;
alter table muc_tieu add  constraint pic_tu_choi_phai_co_loi_trao
  check (pic_tu_choi_luc is null or pic_moi_luc is not null);
--   Không từ chối được một lời trao không tồn tại. Ràng buộc này cũng là thứ
--   bắt hàm nhận phải dọn CẢ HAI cặp cột cùng lúc — xoá pic_moi_luc mà bỏ quên
--   pic_tu_choi_luc là dòng không ghi xuống được.


-- ════════════════════════════════════════════════════════════════════════════
-- 3. HÀM ① — TRAO: PIC hiện tại mời một người khác nhận vai
-- ════════════════════════════════════════════════════════════════════════════
create or replace function trao_pic_du_an(
  p_muc_tieu_id bigint,
  p_pic_moi     uuid,
  p_o_lai       boolean
)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi   uuid := nguoi_id_dang_nhap();
  v_chu   uuid;
  v_loai  text;
  v_tt    text;
  v_treo  timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;
  if p_pic_moi is null then
    raise exception 'Chưa chọn người nhận vai PIC';
  end if;
  if p_o_lai is null then
    raise exception 'Khai luôn: sau khi trao xong bạn ở lại làm thành viên, hay rời hẳn dự án?';
  end if;

  select nguoi_id, loai, trang_thai, pic_moi_luc
    into v_chu, v_loai, v_tt, v_treo
    from muc_tieu where id = p_muc_tieu_id;

  if not found then
    raise exception 'Không tìm thấy dự án %', p_muc_tieu_id;
  end if;
  if v_loai <> 'du-an' then
    raise exception 'Dòng này không phải một dự án nên không có vai PIC để trao.';
  end if;
  if v_chu is distinct from v_toi then
    raise exception 'Chỉ PIC hiện tại mới trao được vai này. Bạn đang là thành viên của dự án.';
  end if;
  if p_pic_moi = v_toi then
    raise exception 'Bạn đang là PIC rồi — không trao cho chính mình được.';
  end if;
  -- Nấc đóng: dự án đã hoàn thành hoặc đã hủy thì vai PIC hết việc để gánh.
  if v_tt not in ('kho', 'dang-chay', 'nghen') then
    raise exception 'Dự án này đã đóng (%). Chỉ dự án còn trong kho, đang chạy hoặc đang nghẽn mới trao PIC được.', v_tt;
  end if;
  if v_treo is not null then
    raise exception 'Dự án này đang treo một lời trao PIC chưa có câu trả lời. Rút lời trao ấy lại trước, rồi hãy trao cho người khác.';
  end if;
  if not exists (select 1 from nguoi where id = p_pic_moi) then
    raise exception 'Không tìm thấy người này trong danh sách đội';
  end if;

  -- CỐ Ý KHÔNG đòi người nhận đã là thành viên dự án. Trigger
  -- `tu_them_chu_du_an` gác sẵn `update of nguoi_id` nên lúc họ gật, máy chủ
  -- tự thêm tên họ vào `thanh_vien_du_an`. Bắt mời trước rồi mới trao được là
  -- thêm một bước không giữ thêm điều gì.
  update muc_tieu
     set pic_moi_id        = p_pic_moi,
         pic_moi_boi       = v_toi,
         pic_moi_luc       = now(),
         pic_cu_o_lai      = p_o_lai,
         pic_tu_choi_luc   = null,
         pic_tu_choi_ly_do = null
   where id = p_muc_tieu_id;
end $$;

comment on function trao_pic_du_an(bigint, uuid, boolean) is
  'Nút "Trao vai PIC": PIC hiện tại mời một người khác nhận vai chủ dự án. KHÔNG đổi chủ ngay — dòng sinh ra ở nấc CHỜ NHẬN, đúng khuôn giao cam kết (Tracy chốt 31/08: "cứ như cam kết đi"). Tham số p_o_lai là lựa chọn của chính người trao: true = ở lại làm thành viên thường, false = rời hẳn dự án; máy chủ giữ đó và thi hành lúc người kia gật. Người kia trả lời bằng nhan_pic_du_an() hoặc tu_choi_pic_du_an(); không có hạn trả lời và app không gật thay ai.';

grant execute on function trao_pic_du_an(bigint, uuid, boolean) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 4. HÀM ② — NHẬN: người được trao gật, và vai đổi chủ ngay lúc này
-- ════════════════════════════════════════════════════════════════════════════
create or replace function nhan_pic_du_an(p_muc_tieu_id bigint)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi    uuid := nguoi_id_dang_nhap();
  v_chu_cu uuid;
  v_moi    uuid;
  v_luc    timestamptz;
  v_tuchoi timestamptz;
  v_o_lai  boolean;
  v_tt     text;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, pic_moi_id, pic_moi_luc, pic_tu_choi_luc, pic_cu_o_lai, trang_thai
    into v_chu_cu, v_moi, v_luc, v_tuchoi, v_o_lai, v_tt
    from muc_tieu where id = p_muc_tieu_id;

  if not found then
    raise exception 'Không tìm thấy dự án %', p_muc_tieu_id;
  end if;
  if v_luc is null then
    raise exception 'Dự án này không có lời trao PIC nào đang chờ.';
  end if;
  if v_moi is distinct from v_toi then
    raise exception 'Lời trao này gửi cho người khác — chỉ người được mời mới nhận vai được.';
  end if;
  if v_tuchoi is not null then
    raise exception 'Bạn đã từ chối lời trao này rồi. Muốn nhận thì nhờ PIC trao lại một lần nữa.';
  end if;
  -- Soi lại nấc dự án ngay lúc gật: giữa lúc trao và lúc nhận, PIC cũ có thể
  -- đã đóng hoặc hủy dự án.
  if v_tt not in ('kho', 'dang-chay', 'nghen') then
    raise exception 'Dự án này đã đóng (%) từ lúc lời trao được gửi đi. Không nhận vai của một dự án đã đóng.', v_tt;
  end if;

  -- ─── ĐỔI CHỦ TRƯỚC, RÚT NGƯỜI SAU — THỨ TỰ NÀY BẮT BUỘC ─────────────────
  -- Trigger `kiem_rut_thanh_vien` ném lỗi khi ai đó bị rút ra khỏi dự án mà
  -- họ đang là `muc_tieu.nguoi_id`. Rút PIC cũ trước khi đổi chủ là đâm thẳng
  -- vào hàng rào ấy. Đổi chủ trước thì lúc câu delete chạy, PIC cũ đã là một
  -- thành viên thường và cửa mở.
  --
  -- Câu update này cũng đánh thức hai trigger đang gác sẵn, cả hai đều ĐÚNG ý
  -- và KHÔNG được viết lại ở đây:
  --   · `tu_them_chu_du_an`  (after update of nguoi_id) → tự thêm tôi vào
  --     danh sách thành viên, nên không cần mời trước.
  --   · `kiem_tran_danh_muc` (before update) → soi trần số dự án của tôi và
  --     ném câu lỗi của nó nếu tôi đã gánh đủ. Câu ấy nói ở ngôi thứ ba
  --     ("Người này đang là PIC của N dự án") vì nó vốn viết cho ca PIC mở dự
  --     án mới; đọc hơi lạ ở đây nhưng đúng nghĩa, và một trần thì chỉ nên có
  --     một chỗ giữ.
  update muc_tieu
     set nguoi_id          = v_toi,
         pic_moi_id        = null,
         pic_moi_boi       = null,
         pic_moi_luc       = null,
         pic_cu_o_lai      = null,
         pic_tu_choi_luc   = null,
         pic_tu_choi_ly_do = null
   where id = p_muc_tieu_id;

  -- PIC cũ khai muốn rời hẳn thì gỡ tên khỏi danh sách thành viên. Cam kết và
  -- việc họ đã làm KHÔNG đụng tới — đó là việc thật đã diễn ra, đúng nếp
  -- `duRutNguoi` của app. Chỉ đóng cửa vào: từ giờ họ không gieo thêm cam kết
  -- cho dự án này được nữa.
  if v_o_lai is false and v_chu_cu is not null then
    delete from thanh_vien_du_an
     where muc_tieu_id = p_muc_tieu_id and nguoi_id = v_chu_cu;
  end if;
end $$;

comment on function nhan_pic_du_an(bigint) is
  'Nút "Nhận vai PIC": người được trao gật, và vai đổi chủ ngay tại đây. Thứ tự trong hàm là bắt buộc — đổi nguoi_id TRƯỚC rồi mới rút PIC cũ, vì kiem_rut_thanh_vien chặn rút một người đang là chủ dự án. PIC cũ ở lại hay rời là do chính họ khai lúc trao (cột pic_cu_o_lai), không phải người nhận quyết. Chạy bằng quyền người định nghĩa vì người nhận chưa phải chủ dòng.';

grant execute on function nhan_pic_du_an(bigint) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 5. HÀM ③ — TỪ CHỐI: dòng Ở LẠI, quay về phía người trao
-- ════════════════════════════════════════════════════════════════════════════
create or replace function tu_choi_pic_du_an(p_muc_tieu_id bigint, p_ly_do text)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi    uuid := nguoi_id_dang_nhap();
  v_moi    uuid;
  v_luc    timestamptz;
  v_tuchoi timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;
  if length(trim(coalesce(p_ly_do, ''))) = 0 then
    raise exception 'Từ chối thì khai lý do — người trao cần biết vì sao để còn tìm người khác.';
  end if;

  select pic_moi_id, pic_moi_luc, pic_tu_choi_luc
    into v_moi, v_luc, v_tuchoi
    from muc_tieu where id = p_muc_tieu_id;

  if not found then
    raise exception 'Không tìm thấy dự án %', p_muc_tieu_id;
  end if;
  if v_luc is null then
    raise exception 'Dự án này không có lời trao PIC nào đang chờ.';
  end if;
  if v_moi is distinct from v_toi then
    raise exception 'Lời trao này gửi cho người khác — chỉ người được mời mới từ chối được.';
  end if;
  if v_tuchoi is not null then
    raise exception 'Bạn đã từ chối lời trao này rồi.';
  end if;

  -- Dòng Ở LẠI nguyên vẹn, chỉ đeo thêm dấu từ chối. Nó quay về phía PIC hiện
  -- tại qua nhánh ⑥ của `cho_ban`, và ở đó cho tới khi họ gọi
  -- `rut_lai_trao_pic` — cố ý đòi một hành động có chủ chứ không tự tắt.
  update muc_tieu
     set pic_tu_choi_luc   = now(),
         pic_tu_choi_ly_do = trim(p_ly_do)
   where id = p_muc_tieu_id;
end $$;

comment on function tu_choi_pic_du_an(bigint, text) is
  'Nút "Từ chối": người được trao trả lại vai PIC kèm lý do bắt buộc. Lời trao KHÔNG biến mất — nó ở lại mang dấu từ chối và hiện về phía PIC hiện tại qua khối Chờ bạn, cho tới khi họ rút lại. Cùng nếp tu_choi_cam_ket của tầng cam kết.';

grant execute on function tu_choi_pic_du_an(bigint, text) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 6. HÀM ④ — RÚT LẠI: lối ra DUY NHẤT của một lời trao
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ KHÔNG CÓ HÀM NÀY THÌ MỖI LỜI TRAO BỊ TỪ CHỐI LÀ MỘT DÒNG CHẾT: dự án
-- vĩnh viễn mang cờ "đang treo một lời trao", `trao_pic_du_an` từ chối trao
-- cho người khác, và khối "Chờ bạn" mang một thẻ không tắt được. Đây là cái
-- phanh — cùng vai `rut_lai_cam_ket` ở tầng cam kết.
create or replace function rut_lai_trao_pic(p_muc_tieu_id bigint)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi uuid := nguoi_id_dang_nhap();
  v_chu uuid;
  v_luc timestamptz;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, pic_moi_luc into v_chu, v_luc
    from muc_tieu where id = p_muc_tieu_id;

  if not found then
    raise exception 'Không tìm thấy dự án %', p_muc_tieu_id;
  end if;
  if v_luc is null then
    raise exception 'Dự án này không có lời trao PIC nào để rút.';
  end if;
  -- Neo vào PIC HIỆN TẠI, không neo vào `pic_moi_boi`: cột ấy có khoá ngoại
  -- `on delete set null` nên người trao rời đội là nó tự rỗng, và lúc ấy lời
  -- trao sẽ không còn ai rút được — đúng cái dòng chết mà hàm này sinh ra để
  -- tránh. Người đang gánh dự án luôn là người có quyền dọn nó.
  if v_chu is distinct from v_toi then
    raise exception 'Chỉ PIC hiện tại của dự án mới rút lại lời trao được.';
  end if;

  update muc_tieu
     set pic_moi_id        = null,
         pic_moi_boi       = null,
         pic_moi_luc       = null,
         pic_cu_o_lai      = null,
         pic_tu_choi_luc   = null,
         pic_tu_choi_ly_do = null
   where id = p_muc_tieu_id;
end $$;

comment on function rut_lai_trao_pic(bigint) is
  'Nút "Rút lại": PIC hiện tại gỡ lời trao mình đã gửi — dù người kia đang im lặng hay đã từ chối. Đây là lối ra DUY NHẤT của một lời trao và là cái phanh giữ cho dự án không kẹt vĩnh viễn ở nấc chờ. Đã có người nhận rồi thì không còn gì để rút: lúc ấy vai đã đổi chủ và người trao không còn là PIC.';

grant execute on function rut_lai_trao_pic(bigint) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 7. DỰNG LẠI `cho_ban` — BỐN NHÁNH THÀNH SÁU
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ ĐỌC TRƯỚC KHI SỬA: khung nhìn này đã được dựng ở hai tệp trước
-- (`nang-cap-cho-ban.sql` mục 4 · `nang-cap-giao-cam-ket.sql` mục 8a) và đây là
-- lần thứ BA. Bốn nhánh đầu chép NGUYÊN VĂN từ bản của tệp ②, không sửa một
-- chữ — sửa ở đây là dựng chỗ thứ ba giữ cùng một luật.
--
-- Vì sao lời trao PIC PHẢI có nhánh ở đây: một lời trao đang chờ không mọc lên
-- màn nào cả. Người được trao không phải chủ dự án nên hồ sơ dự án của họ
-- không bày nút nào, và dự án ấy có thể họ chưa từng vào. Không có nhánh này
-- thì lời trao rơi vào im lặng hoàn toàn — đúng lý lẽ nhánh ③ đã ghi.
--
-- 🔒 KHOÁ CỨNG SÁU CỘT: loai · khoa · ten · ai · luc · cua_toi. Nhánh ⑥ ghép
-- lý do vào cột `ten` y như nhánh ④ đã làm, cùng một lý do: hết ô, mà lý do
-- vừa bị ép khai thì phải có người đọc.

drop view if exists cho_ban;

create view cho_ban as

-- ① LỜI MỜI chưa xem
select
  'loi-moi'::text                    as loai,
  v.muc_tieu_id::text                as khoa,
  m.ten                              as ten,
  coalesce(n.ten, '—')               as ai,          -- ai mời tôi
  v.moi_luc                          as luc,
  v.nguoi_id                         as cua_toi
from thanh_vien_du_an v
join muc_tieu m on m.id = v.muc_tieu_id
left join nguoi  n on n.id = v.moi_boi
where v.nguoi_id = nguoi_id_dang_nhap()
  and v.da_xem_luc is null
  and v.moi_boi is distinct from v.nguoi_id
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ② CAM KẾT chờ TÔI ký nhận
select
  'ky-nhan'::text,
  o.ma,
  o.ten,
  n.ten,
  coalesce(o.nop_luc, o.ngay_xong::timestamptz),
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.xong
  and length(trim(coalesce(o.output_chu, ''))) > 0
  and o.da_nhan_luc is null
  and (
        (n.leader_id is not null and n.leader_id = nguoi_id_dang_nhap())
     or (n.leader_id is null     and n.id        = nguoi_id_dang_nhap())
      )

union all

-- ③ CAM KẾT ĐƯỢC GIAO cho tôi, tôi chưa trả lời
select
  'cho-nhan'::text,
  o.ma,
  o.ten,
  coalesce(g.ten, '—'),
  o.giao_luc,
  o.nguoi_id
from tieu_diem o
left join nguoi g on g.id = o.giao_boi
where o.nguoi_id       = nguoi_id_dang_nhap()
  and o.giao_luc      is not null
  and o.nhan_viec_luc is null
  and o.tu_choi_luc   is null

union all

-- ④ CAM KẾT TÔI GIAO ĐI, BỊ TỪ CHỐI
select
  'bi-tu-choi'::text,
  o.ma,
  o.ten || ' — lý do: ' || coalesce(nullif(trim(o.tu_choi_ly_do), ''), '(không khai)'),
  coalesce(n.ten, '—'),
  o.tu_choi_luc,
  nguoi_id_dang_nhap()
from tieu_diem o
join nguoi n on n.id = o.nguoi_id
where o.giao_boi      = nguoi_id_dang_nhap()
  and o.tu_choi_luc  is not null
  and o.nhan_viec_luc is null

union all

-- ⑤ VAI PIC ĐƯỢC TRAO cho tôi, tôi chưa trả lời                    (31/08, TP)
-- Lọc theo `pic_moi_luc`, KHÔNG theo `pic_moi_boi` — cùng lý lẽ nhánh ③: người
-- trao rời đội thì `pic_moi_boi` về rỗng (khoá ngoại on delete set null) và
-- lọc theo nó là lời trao lặng lẽ biến mất trong khi vai vẫn đang chờ một câu
-- trả lời. Cột `ai` đã có `coalesce(…, '—')` lo phần tên.
-- Nấc dự án lọc y hệt nhánh ①: đóng hoặc hủy rồi thì lời trao hết nghĩa.
select
  'cho-nhan-pic'::text,
  m.id::text,
  m.ten,
  coalesce(n.ten, '—'),                              -- ai trao cho tôi
  m.pic_moi_luc,
  m.pic_moi_id
from muc_tieu m
left join nguoi n on n.id = m.pic_moi_boi
where m.pic_moi_id      = nguoi_id_dang_nhap()
  and m.pic_moi_luc    is not null
  and m.pic_tu_choi_luc is null
  and m.loai = 'du-an'
  and m.trang_thai in ('kho', 'dang-chay', 'nghen')

union all

-- ⑥ VAI PIC TÔI TRAO ĐI, BỊ TỪ CHỐI                                (31/08, TP)
-- Neo vào `m.nguoi_id` (PIC hiện tại) chứ không `pic_moi_boi`: người còn đang
-- gánh dự án chính là người cần biết lời trao bị trả lại, và cũng là người
-- duy nhất `rut_lai_trao_pic` cho phép dọn nó. Dòng ở lại cho tới khi họ rút —
-- cố ý đòi một hành động có chủ, không tự tắt sau mấy ngày.
select
  'pic-tu-choi'::text,
  m.id::text,
  m.ten || ' — lý do: ' || coalesce(nullif(trim(m.pic_tu_choi_ly_do), ''), '(không khai)'),
  coalesce(n.ten, '—'),                              -- ai từ chối
  m.pic_tu_choi_luc,
  nguoi_id_dang_nhap()
from muc_tieu m
left join nguoi n on n.id = m.pic_moi_id
where m.nguoi_id        = nguoi_id_dang_nhap()
  and m.pic_tu_choi_luc is not null;

alter view cho_ban set (security_invoker = on);

comment on view cho_ban is
  'Thứ đang chờ người đang đăng nhập ra tay. Sáu loại: loi-moi (được mời vào dự án, chưa mở xem) · ky-nhan (cam kết đã nộp sản phẩm, đang chờ chính mình ký nhận) · cho-nhan (được giao một cam kết, chưa gật cũng chưa từ chối) · bi-tu-choi (cam kết chính mình giao đi, bị trả lại) · cho-nhan-pic (được trao vai PIC một dự án, chưa trả lời) · pic-tu-choi (vai PIC chính mình trao đi, bị trả lại). Khung nhìn tự lọc theo người đăng nhập. Thêm loại mới thì thêm một nhánh union all, không dựng bảng — và nhớ khai khoá tương ứng trong CB_LOAI của app, không thì ô đếm cộng một dòng mà danh sách không bày nó.';

grant select on cho_ban to authenticated;


-- ─── 7b. Dựng lại cổng chặn ghi (drop view ở trên đã cuốn nó đi) ────────────
create or replace function chan_ghi_cho_ban() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "cho_ban" là ô MÁY CHỦ TÍNH, không ghi vào được. Xử ở chỗ thật: mở hồ sơ dự án, bấm nút Đã nhận trên cam kết, bấm Nhận việc / Từ chối trên lời giao, hoặc Nhận vai / Từ chối trên lời trao PIC.';
end $$;

drop trigger if exists trg_chan_ghi_cho_ban on cho_ban;
create trigger trg_chan_ghi_cho_ban
  instead of insert or update or delete on cho_ban
  for each row execute function chan_ghi_cho_ban();

commit;


-- ════════════════════════════════════════════════════════════════════════════
-- 8. TỰ KIỂM — mọi dòng phải ✅
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ Đọc cả những dòng CHỌI NHAU, đừng chỉ đếm dấu đỏ: một bảng tự kiểm tự mâu
-- thuẫn thì chỉ xanh được khi đợt sửa KHÔNG chạy (án lệ dòng 17 của tệp ①).
-- ⚠️ So CẤU TRÚC, không so chuỗi máy chủ in ra — `pg_get_function_identity_arguments`
-- in ra cả TÊN tham số nên so nó với một chuỗi chỉ có kiểu là đỏ oan (án lệ
-- dòng 16 của tệp ②). Dưới đây soi `pronargs` và `proargtypes`.

with kt(thu_tu, muc, dat) as (values

  (1, 'muc_tieu có đủ SÁU cột sổ trao PIC',
   (select count(*) = 6 from information_schema.columns
     where table_name = 'muc_tieu'
       and column_name in ('pic_moi_id','pic_moi_boi','pic_moi_luc',
                           'pic_cu_o_lai','pic_tu_choi_luc','pic_tu_choi_ly_do'))),

  (2, 'Ba ràng buộc mới đều có mặt',
   (select count(*) = 3 from pg_constraint
     where conrelid = 'muc_tieu'::regclass
       and conname in ('khong_trao_pic_cho_minh','pic_tu_choi_phai_khai_ly_do',
                       'pic_tu_choi_phai_co_loi_trao'))),

  (3, 'Bốn hàm có mặt, đúng số tham số (trao 3 · nhan 1 · tu_choi 2 · rut 1)',
   (select count(*) = 4 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and ((p.proname = 'trao_pic_du_an'    and p.pronargs = 3)
         or (p.proname = 'nhan_pic_du_an'    and p.pronargs = 1)
         or (p.proname = 'tu_choi_pic_du_an' and p.pronargs = 2)
         or (p.proname = 'rut_lai_trao_pic'  and p.pronargs = 1)))),

  (4, 'Cả bốn hàm chạy security definer (người nhận chưa phải chủ dòng)',
   (select bool_and(p.prosecdef) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname in ('trao_pic_du_an','nhan_pic_du_an',
                         'tu_choi_pic_du_an','rut_lai_trao_pic'))),

  (5, 'Cả bốn hàm đã grant cho authenticated',
   (select count(*) = 4 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public'
       and p.proname in ('trao_pic_du_an','nhan_pic_du_an',
                         'tu_choi_pic_du_an','rut_lai_trao_pic')
       and has_function_privilege('authenticated', p.oid, 'execute'))),

  (6, 'cho_ban có ĐỦ SÁU nhánh — hai nhánh PIC nằm trong định nghĩa view',
   (select pg_get_viewdef('cho_ban'::regclass) like '%cho-nhan-pic%'
       and pg_get_viewdef('cho_ban'::regclass) like '%pic-tu-choi%')),

  -- ⚠️ ĐẾM NHÁNH, không chỉ dò chuỗi: '%cho-nhan%' cũng khớp trong 'cho-nhan-pic',
  -- nên một bảng tự kiểm chỉ dò chuỗi vẫn xanh khi nhánh ③ đã rơi mất.
  (7, 'cho_ban còn ĐỦ SÁU nhánh — đếm union all, không chỉ dò tên loại',
   (select (length(upper(d)) - length(replace(upper(d), 'UNION ALL', ''))) / 9 = 5
       and d like '%loi-moi%' and d like '%ky-nhan%' and d like '%bi-tu-choi%'
      from (select pg_get_viewdef('cho_ban'::regclass) as d) t)),

  (8, 'cho_ban vẫn security_invoker (không thì nó đọc bằng quyền người tạo)',
   (select reloptions::text like '%security_invoker=on%'
      from pg_class where oid = 'cho_ban'::regclass)),

  (9, 'Cổng chặn ghi cho_ban dựng lại sau drop view',
   exists (select 1 from pg_trigger where tgname = 'trg_chan_ghi_cho_ban')),

  (10, 'Policy sua_muctieu KHÔNG bị nới — vế with check còn nguyên',
   exists (select 1 from pg_policies
            where tablename = 'muc_tieu' and policyname = 'sua_muctieu'
              and with_check like '%nguoi_id_dang_nhap()%')),

  (11, 'trg_tu_them_chu_du_an còn gác update of nguoi_id (hàm nhận dựa vào nó)',
   exists (select 1 from pg_trigger t join pg_class c on c.oid = t.tgrelid
            where c.relname = 'muc_tieu' and t.tgname = 'trg_tu_them_chu_du_an')),

  (12, 'trg_kiem_rut_thanh_vien còn sống (hàm nhận xếp thứ tự để né đúng nó)',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_rut_thanh_vien')),

  (13, 'trg_kiem_tran_danh_muc còn sống — trần số dự án chỉ có MỘT chỗ giữ',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_tran_danh_muc')),

  (14, 'Chỉ mục lời trao đang treo có mặt',
   exists (select 1 from pg_indexes
            where tablename = 'muc_tieu' and indexname = 'trao_pic_dang_treo')),

  (15, 'Không dòng nào đang tự trao cho chính mình',
   not exists (select 1 from muc_tieu
                where pic_moi_id is not null and pic_moi_id = nguoi_id)),

  (16, 'Không dòng nào từ chối mà thiếu lý do, hoặc từ chối một lời trao rỗng',
   not exists (select 1 from muc_tieu
                where pic_tu_choi_luc is not null
                  and (pic_moi_luc is null
                       or length(trim(coalesce(pic_tu_choi_ly_do, ''))) = 0)))
)
select thu_tu,
       case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua,
       muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt sau khi chạy ───────────────────────────────────────
-- ① Dự án nào đang treo một lời trao PIC:
--    select m.ten, c.ten as pic_hien_tai, n.ten as duoc_trao,
--           m.pic_moi_luc, m.pic_cu_o_lai, m.pic_tu_choi_luc, m.pic_tu_choi_ly_do
--      from muc_tieu m
--      join nguoi c on c.id = m.nguoi_id
--      left join nguoi n on n.id = m.pic_moi_id
--     where m.pic_moi_luc is not null;
-- ② Ai đang là PIC của mấy dự án đang chạy (soi trước khi trao, vì trần
--    `kiem_tran_danh_muc` sẽ chặn lúc người ta bấm nhận chứ không phải lúc trao):
--    select n.ten, count(*) as dang_gánh, coalesce(n.so_du_an_toi_da, 2) as tran
--      from muc_tieu m join nguoi n on n.id = m.nguoi_id
--     where m.loai = 'du-an' and m.trang_thai = 'dang-chay'
--     group by n.ten, n.so_du_an_toi_da order by 2 desc;
-- ③ Muốn quay lui trọn tệp này (hiếm khi cần):
--    drop function if exists trao_pic_du_an(bigint, uuid, boolean);
--    drop function if exists nhan_pic_du_an(bigint);
--    drop function if exists tu_choi_pic_du_an(bigint, text);
--    drop function if exists rut_lai_trao_pic(bigint);
--    alter table muc_tieu drop column if exists pic_moi_id, drop column if exists pic_moi_boi,
--      drop column if exists pic_moi_luc, drop column if exists pic_cu_o_lai,
--      drop column if exists pic_tu_choi_luc, drop column if exists pic_tu_choi_ly_do;
--    -- rồi chạy lại `nang-cap-giao-cam-ket.sql` để dựng lại `cho_ban` bản bốn nhánh.
