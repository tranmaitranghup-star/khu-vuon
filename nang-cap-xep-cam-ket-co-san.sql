-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `xep_cam_ket_vao_du_an(text, bigint, bigint)`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- KÉO MỘT CAM KẾT ĐÃ CÓ VÀO MỘT DỰ ÁN VÀ MỘT MILESTONE
-- Tracy chốt 2026-08-29 · chạy SAU `nang-cap-giao-cam-ket.sql`
-- ════════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO CÓ FILE NÀY. Tracy giao: *"tôi muốn các milestone này có thể chọn các
-- cam kết có sẵn vào (kể cả cam kết đã done hoặc là đang làm dở hoặc trong kho)
-- để tôi hoạch định các cam kết hiện tại của cả team vào các dự án"*.
--
-- App đã có đường XẾP một cam kết vào milestone (`duXepMoc` → `update tieu_diem
-- set moc_id`). Nhưng đường ấy chỉ chạy được trên cam kết ĐÃ trỏ về dự án, mà
-- gần như luôn là cam kết của chính người đang bấm. Kéo cam kết của ĐỒNG ĐỘI
-- vào thì đâm thẳng vào hàng rào phân quyền:
--
--     create policy sua_tieudiem on tieu_diem for update
--       using (nguoi_id = nguoi_id_dang_nhap())         -- nang-cap-luong-rieng-tung-nguoi.sql:95
--
-- ⚠️ HỎNG TRONG IM LẶNG, KHÔNG PHẢI BÁO LỖI. Câu `update` không bị từ chối —
-- nó chỉ **chạm 0 dòng**. PostgREST trả về 204, `error` rỗng, app gọi
-- `moHoSoDuAn` vẽ lại y nguyên màn cũ. Người bấm thấy cửa đóng lại rồi không
-- có gì xảy ra, và không có một dòng nào để đọc. Đây đúng họ với cái bẫy đã ghi
-- ở `duKhoaDeBai` (BAN-GIAO-SQL-giao-va-kho-cam-ket.md, mục 6).
--
-- Nên cửa mới phải đi qua MỘT HÀM `security definer`, và hàm ấy gánh luôn ba
-- hàng rào mà một câu `update` trần không gánh được.
--
-- ────────────────────────────────────────────────────────────────────────────
-- BA HÀNG RÀO ĐÃ CÓ SẴN TRÊN ĐƯỜNG NÀY — hàm chỉ nói chúng ra sớm hơn
-- ────────────────────────────────────────────────────────────────────────────
--
-- ① `trg_kiem_thanh_vien_cam_ket` (nang-cap-mang-du-an.sql:461) — cam kết chỉ
--    trỏ về dự án mà CHỦ CAM KẾT có tên trong đó. Kéo cam kết của Andy vào một
--    dự án Andy chưa được mời là bị đá.
--       → Tracy chốt 29/08: **tự mời chủ cam kết vào dự án**, khỏi bắt đi hai
--         vòng. Nhưng chỉ PIC mới mời người được — luật ấy đang hiện thành chữ
--         ngay dưới khối Thành viên (*"Chỉ PIC mời và rút người được"*), nên
--         thành viên thường gặp ca này thì hàm nói thẳng là phải nhờ PIC.
--         Không có cửa hậu nào thêm người vào dự án mà PIC không biết.
--
-- ② `kiem_giao_cam_ket` (nang-cap-giao-cam-ket.sql:810) — cam kết đang chờ
--    người được giao trả lời thì ĐỀ BÀI KHOÁ, `muc_tieu_id` và `moc_id` nằm
--    trong danh sách khoá. Đây là đúng thứ Tracy gọi là *"trong kho"*, và một
--    phần của nó **kéo không được**: chưa ai gật thì chưa có lời hứa nào để mà
--    xếp vào đích của dự án. Hàm trả lỗi có chữ, giao diện bày thẻ mờ kèm lý do
--    thay vì giấu thẻ đi.
--       Phần CÒN LẠI của kho — cam kết TỰ VIẾT chưa kéo vào luống (`luong` rỗng
--       mà `giao_luc` rỗng) — kéo được bình thường.
--
-- ③ `tg_moc_cung_du_an` (nang-cap-moc-cam-ket.sql:101) — milestone phải thuộc
--    đúng dự án ấy. Hàm đặt `muc_tieu_id` và `moc_id` TRONG CÙNG MỘT CÂU, đúng
--    thứ tự trigger chờ đợi.
--
-- KHÔNG dựng thêm hàng rào nào ở đây. Trần ba luống, trần kho, luật một hạt một
-- luống đều không đụng tới: hàm này KHÔNG chạm cột `luong`. Cam kết đang ngồi
-- luống nào thì ở nguyên luống ấy, chỉ đổi chỗ nó trỏ về.
--
-- ────────────────────────────────────────────────────────────────────────────
-- MỘT HỆ QUẢ PHẢI BIẾT TRƯỚC
-- ────────────────────────────────────────────────────────────────────────────
-- Khung nhìn `danh_muc_du_an` đếm mọi cam kết có `luong is not null`. Kéo một
-- cam kết ĐÃ XONG vào dự án là cộng vào CẢ TỬ LẪN MẪU của ô phần trăm — đúng
-- như Tracy chốt 29/08. Kéo một cam kết đang chạy vào thì mẫu số lên trước, tử
-- số lên sau: phần trăm dự án TỤT NGAY lúc kéo. Đó là số thật, không phải lỗi.
-- ════════════════════════════════════════════════════════════════════════════

begin;


-- ════════════════════════════════════════════════════════════════════════════
-- 1. HÀM — kéo một cam kết đã có vào một dự án và một milestone
-- ════════════════════════════════════════════════════════════════════════════
--
-- Trả về MỘT CHỮ để app biết nói gì trong toast:
--     'xep'      xếp xong
--     'xep+moi'  xếp xong, và đã mời chủ cam kết vào dự án
--
-- `p_moc_id` rỗng = kéo về dự án nhưng chưa xếp milestone nào (cột "Chưa xếp
-- milestone"). Đó là ca hợp lệ, không phải thiếu tham số.

create or replace function xep_cam_ket_vao_du_an(
  p_ma          text,
  p_muc_tieu_id bigint,
  p_moc_id      bigint default null
) returns text
language plpgsql security definer set search_path = public as $$
declare
  v_toi     uuid := nguoi_id_dang_nhap();
  v_chu     uuid;
  v_ten     text;
  v_giao    timestamptz;
  v_nhan    timestamptz;
  v_tt      text;
  v_moc_cua bigint;
  v_moi     boolean := false;
begin
  if v_toi is null then
    raise exception 'Chưa đăng nhập nên chưa xếp được cam kết nào.';
  end if;

  select o.nguoi_id, o.ten, o.giao_luc, o.nhan_viec_luc
    into v_chu, v_ten, v_giao, v_nhan
    from tieu_diem o where o.ma = p_ma;
  if not found then
    raise exception 'Không tìm thấy cam kết % — có thể nó vừa bị xoá.', p_ma;
  end if;

  select m.trang_thai into v_tt from muc_tieu m where m.id = p_muc_tieu_id;
  if not found then
    raise exception 'Không tìm thấy dự án này.';
  end if;

  -- Cùng bộ trạng thái mà `napDuAnChoGieo` và `duDuocGieo()` đang dùng ở app.
  -- Một luật "dự án nào còn nhận cam kết", giữ ở ba chỗ thì sớm muộn cũng lệch,
  -- nên chỗ nào sửa thì sửa cả ba.
  if v_tt not in ('kho', 'dang-chay') then
    raise exception 'Dự án này không còn nhận cam kết (đang ở trạng thái %).', v_tt;
  end if;

  -- ── ① NGƯỜI BẤM phải có tên trong dự án ───────────────────────────────────
  -- Tracy chốt 29/08: *"cho những người tham gia chỉnh được đi"* — không riêng
  -- PIC. Nhưng người ngoài dự án thì vẫn chỉ có quyền xem, đúng câu đang hiện
  -- dưới khối Thành viên.
  if not la_thanh_vien_du_an(p_muc_tieu_id, v_toi) then
    raise exception 'Bạn chưa có tên trong dự án này nên chỉ xem được — nhờ PIC mời bạn vào trước.';
  end if;

  -- ── ② Cam kết đang chờ một câu trả lời thì đề bài khoá ────────────────────
  -- Nói ra Ở ĐÂY thay vì để `kiem_giao_cam_ket` ném ra, vì lỗi của trigger nói
  -- với NGƯỜI ĐƯỢC GIAO ("đang chờ bạn trả lời"), còn người đọc câu này là
  -- người thứ ba đang xếp việc. Cùng một luật, hai người nghe, hai câu khác.
  if v_giao is not null and v_nhan is null then
    raise exception 'Cam kết "%" đang nằm kho chờ người được giao trả lời — chưa ai gật thì chưa xếp vào milestone được. Đợi họ nhận việc, hoặc nhờ họ từ chối để người giao giao lại.', v_ten;
  end if;

  -- ── ③ Chủ cam kết chưa có tên trong dự án ─────────────────────────────────
  if not la_thanh_vien_du_an(p_muc_tieu_id, v_chu) then
    if exists (select 1 from muc_tieu m
                where m.id = p_muc_tieu_id and m.nguoi_id = v_toi) then
      insert into thanh_vien_du_an (muc_tieu_id, nguoi_id, moi_boi)
      values (p_muc_tieu_id, v_chu, v_toi)
      on conflict do nothing;
      v_moi := true;
    else
      raise exception 'Cam kết "%" là của người chưa có tên trong dự án. Chỉ PIC mời người vào được — nhờ PIC mời họ rồi quay lại.', v_ten;
    end if;
  end if;

  -- ── ④ Milestone phải thuộc đúng dự án này ─────────────────────────────────
  -- `tg_moc_cung_du_an` cũng bắt ca này, nhưng bắt SAU khi câu update đã chạy
  -- một nửa đường. Soi trước thì câu lỗi ngắn hơn và không cuộn ngược gì.
  if p_moc_id is not null then
    select k.muc_tieu_id into v_moc_cua from moc_du_an k where k.id = p_moc_id;
    if not found then
      raise exception 'Không tìm thấy milestone này.';
    end if;
    if v_moc_cua is distinct from p_muc_tieu_id then
      raise exception 'Milestone này thuộc dự án khác. Cam kết chỉ xếp được vào milestone của chính dự án nó.';
    end if;
  end if;

  update tieu_diem
     set muc_tieu_id = p_muc_tieu_id,
         moc_id      = p_moc_id
   where ma = p_ma;

  return case when v_moi then 'xep+moi' else 'xep' end;
end $$;

comment on function xep_cam_ket_vao_du_an(text, bigint, bigint) is
  'Kéo một cam kết ĐÃ CÓ vào một dự án và (không bắt buộc) một milestone. security definer vì policy sua_tieudiem chỉ cho sửa dòng của chính mình — không có hàm này thì kéo cam kết của đồng đội sẽ chạm 0 dòng TRONG IM LẶNG. Người gọi phải có tên trong dự án (Tracy chốt 29/08: thành viên chỉnh được, không riêng PIC). Chủ cam kết chưa có tên thì hàm tự mời — nhưng chỉ khi người gọi là PIC, vì mời người là quyền của PIC. Cam kết đang chờ người được giao trả lời thì không kéo được: đề bài đang khoá. KHÔNG chạm cột luong, nên mọi trần (ba luống, kho) giữ nguyên. Trả về ''xep'' hoặc ''xep+moi''.';

grant execute on function xep_cam_ket_vao_du_an(text, bigint, bigint) to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. DÒNG TỰ KIỂM — chạy xong nhìn bảng này, đỏ chỗ nào sửa chỗ đó
-- ════════════════════════════════════════════════════════════════════════════
--
-- ⚠️ Đừng so `pg_get_function_identity_arguments()` với một chuỗi — nó in ra CẢ
--    TÊN THAM SỐ, nên phép so chuỗi trả rỗng và bày ra y hệt một dấu đỏ trong
--    khi hàm hoàn toàn đúng. Án lệ: dòng tự kiểm 16 của `nang-cap-giao-cam-ket.sql`,
--    đỏ oan tới lúc vá 28/08. Ở đây so THỨ CÓ CẤU TRÚC: `pronargs` và
--    `proargtypes`.

with kiem(stt, muc, dat) as (
  values
  (1, 'Hàm xep_cam_ket_vao_du_an đang có trên máy chủ',
   exists (select 1 from pg_proc where proname = 'xep_cam_ket_vao_du_an')),

  (2, 'Hàm nhận đúng 3 tham số (text, bigint, bigint)',
   exists (select 1 from pg_proc p
            where p.proname = 'xep_cam_ket_vao_du_an'
              and p.pronargs = 3
              and p.proargtypes[0] = 'text'::regtype
              and p.proargtypes[1] = 'bigint'::regtype
              and p.proargtypes[2] = 'bigint'::regtype)),

  (3, 'Hàm chạy dưới quyền chủ hàm (security definer) — không có thì RLS chặn',
   exists (select 1 from pg_proc where proname = 'xep_cam_ket_vao_du_an' and prosecdef)),

  (4, 'Tham số thứ ba có giá trị mặc định (gọi 2 tham số cũng được)',
   exists (select 1 from pg_proc where proname = 'xep_cam_ket_vao_du_an' and pronargdefaults = 1)),

  (5, 'Vai authenticated được phép gọi hàm',
   has_function_privilege('authenticated', 'xep_cam_ket_vao_du_an(text, bigint, bigint)', 'execute')),

  (6, 'Hàm có ghi chú giải thích (người sau đọc được vì sao nó tồn tại)',
   (select obj_description(p.oid) is not null from pg_proc p
     where p.proname = 'xep_cam_ket_vao_du_an')),

  -- Ba thứ hàm này ĐỨNG TRÊN. Thiếu bất cứ cái nào là chạy sai file thứ tự.
  (7, 'Nền: hàm la_thanh_vien_du_an đang có (nang-cap-mang-du-an.sql)',
   exists (select 1 from pg_proc where proname = 'la_thanh_vien_du_an')),

  (8, 'Nền: bảng thanh_vien_du_an đang có',
   to_regclass('public.thanh_vien_du_an') is not null),

  (9, 'Nền: tieu_diem có cột moc_id (nang-cap-moc-cam-ket.sql)',
   exists (select 1 from information_schema.columns
            where table_name = 'tieu_diem' and column_name = 'moc_id')),

  (10, 'Nền: tieu_diem có cột giao_luc + nhan_viec_luc (nang-cap-giao-cam-ket.sql)',
   (select count(*) = 2 from information_schema.columns
     where table_name = 'tieu_diem' and column_name in ('giao_luc', 'nhan_viec_luc'))),

  (11, 'Nền: trigger tg_moc_cung_du_an vẫn đang cắm (hàm dựa vào nó gác vòng cuối)',
   exists (select 1 from pg_trigger
            where tgrelid = 'tieu_diem'::regclass and not tgisinternal
              and tgname = 'tg_moc_cung_du_an')),

  (12, 'Nền: policy sua_tieudiem vẫn khoá theo chủ dòng — đây là LÝ DO hàm tồn tại',
   exists (select 1 from pg_policies
            where tablename = 'tieu_diem' and policyname = 'sua_tieudiem')),

  -- Không dòng nào được lệch sau khi chạy: mọi cam kết trỏ về dự án đều phải có
  -- chủ nằm trong dự án ấy. Hàm không tạo ra dòng lệch, nhưng dữ liệu cũ có thể
  -- đã lệch từ trước — biết sớm hơn là tốt.
  (13, 'Không cam kết nào trỏ về dự án mà chủ nó không có tên trong đó',
   not exists (select 1 from tieu_diem o
                where o.muc_tieu_id is not null
                  and not la_thanh_vien_du_an(o.muc_tieu_id, o.nguoi_id))),

  (14, 'Không cam kết nào đeo milestone của dự án khác',
   not exists (select 1 from tieu_diem o join moc_du_an k on k.id = o.moc_id
                where k.muc_tieu_id is distinct from o.muc_tieu_id))
)
select stt,
       case when dat then '✅' else '❌ XEM LẠI' end as ket_qua,
       muc
  from kiem order by stt;


commit;

-- ────────────────────────────────────────────────────────────────────────────
-- CHẠY LẠI ĐƯỢC KHÔNG? Được. `create or replace` + `on conflict do nothing`,
-- không câu nào xoá hay đổi dữ liệu đang có. Cả file nằm trong một giao dịch:
-- đỏ một dòng là cuộn ngược sạch, không để lại nửa vời.
--
-- GỠ RA THẾ NÀO (nếu cần lùi):
--     drop function if exists xep_cam_ket_vao_du_an(text, bigint, bigint);
-- Bỏ hàm KHÔNG mất dữ liệu nào — mọi cam kết đã kéo vào dự án ở nguyên chỗ.
-- Chỉ là cửa "Chọn cam kết có sẵn" của app quay về chế độ chỉ xếp được cam kết
-- của chính mình.
-- ────────────────────────────────────────────────────────────────────────────
