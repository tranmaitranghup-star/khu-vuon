-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nguoi.leader_id`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: PHÂN CẤP NGHIỆM THU — ai ký nhận output cho ai
--                                      (Tracy chốt 11/08/2026, sau việc 49)
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Nguyên văn Tracy: *"hiện tại chỉ có Andy là cấp trên của 6 người còn lại"*.
--
-- File trước (`nang-cap-output-cam-ket.sql`) chạy một LUẬT TẠM vì bảng `nguoi`
-- chưa có chỗ khai cấp trên: *ai cũng bấm được "Đã nhận", trừ chính chủ*. Luật
-- tạm ấy giữ được phần cốt lõi (không tự chấm) nhưng không đúng thực tế — John
-- ký nhận cho Sydney thì chữ ký đó không mang nghĩa gì.
--
-- File này thay nó bằng phân cấp thật, khai bằng DỮ LIỆU chứ không bằng tên
-- viết cứng trong mã: một cột `leader_id` trên bảng `nguoi`. Hôm nay cả 6 người
-- cùng trỏ về Andy; ngày ROVA có thêm tầng trưởng phòng (Hafi · Sydney · Justin
-- đang là trưởng team) thì chỉ sửa DỮ LIỆU, không phải sửa lại hàm.
--
-- AI KÝ CHO CHÍNH ANDY — Tracy chốt 11/08: *"Andy thì Andy tự bấm"*.
--    Andy là CEO, trong app không còn ai đứng trên. Nên luật đầy đủ là:
--       người ký = CẤP TRÊN TRỰC TIẾP, hoặc CHÍNH MÌNH nếu không có cấp trên.
--    Nhìn thì như thủng luật "không ai tự ký cho mình", nhưng không phải: luật
--    ấy sinh ra để chặn người CÓ cấp trên tự cấp cho mình một chữ ký. Người
--    đứng đầu thì không có ai để chờ — bắt họ chờ là cam kết của họ kẹt ở
--    "chờ xác nhận" vĩnh viễn, mà bắt một người dưới ký cho họ thì chữ ký ấy
--    cũng không mang nghĩa gì.
--
-- CÁCH CHẠY: dán trọn file vào SQL Editor của Supabase rồi Run. Chạy lại nhiều
-- lần vô hại — file này CỐ Ý idempotent để sửa luật thì sửa tại chỗ, không đẻ
-- thêm file thứ hai nói về cùng một chuyện.
-- Xong thì nhìn bảng tự kiểm ở cuối — cột `dat` phải đúng cả NĂM dòng.
--
-- CHẠY SAU: `nang-cap-output-cam-ket.sql`.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Cột cấp trên trên bảng nguoi ────────────────────────────────────────
-- Tự trỏ về chính bảng mình: một cây phân cấp, không phải một cái nhãn phẳng.
-- `on delete set null` để xoá một người không kéo theo lỗi khoá ngoại cho cả
-- nhánh dưới — họ chỉ thành người chưa có cấp trên, và app nói ra điều đó.
alter table nguoi add column if not exists leader_id uuid
  references nguoi (id) on delete set null;

comment on column nguoi.leader_id is
  'Cấp trên trực tiếp — người duy nhất ký nhận được output cam kết của người này. NULL = không có ai đứng trên (hiện chỉ Andy).';

-- Chỉ mục cho câu "ai là lính của tôi". Bảng 7 dòng thì chưa cần, nhưng đây là
-- cột sẽ bị hỏi mỗi lần vẽ khối "Đã hoàn thành", và thêm sau thì hay quên.
create index if not exists nguoi_theo_leader on nguoi (leader_id);


-- ─── 2. Khai phân cấp hiện tại: Andy là cấp trên của 6 người còn lại ────────
-- Tìm theo TÊN chứ không viết cứng một chuỗi id: id là uuid, chép tay vào đây
-- là một chỗ sai không ai đọc ra. Nhưng tìm theo tên thì phải DỪNG LẠI BÁO LỖI
-- khi không thấy — im lặng bỏ qua là cả file chạy "thành công" mà không phân
-- cấp ai cả.
do $$
declare
  v_andy uuid;
  v_dem  int;
begin
  select count(*) into v_dem from nguoi where lower(trim(ten)) = 'andy';
  if v_dem <> 1 then
    raise exception
      'Cần đúng MỘT người tên Andy trong bảng nguoi, đang thấy %. Sửa tên trong câu này rồi chạy lại.', v_dem;
  end if;

  select id into v_andy from nguoi where lower(trim(ten)) = 'andy';

  update nguoi set leader_id = v_andy where id <> v_andy;
  update nguoi set leader_id = null   where id  = v_andy;   -- CEO không có ai trên
end $$;


-- ─── 3. Hàm nghiệm thu — nay soi ĐÚNG cấp trên ──────────────────────────────
-- Vẫn là `security definer` và vẫn chỉ chạm hai cột, y như bản trước. Thay đổi
-- duy nhất: thêm một mệnh đề soi phân cấp.
create or replace function nhan_cam_ket(p_ma text)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_toi    uuid := nguoi_id_dang_nhap();
  v_chu    uuid;
  v_out    text;
  v_xong   boolean;
  v_leader uuid;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  select nguoi_id, output_chu, xong into v_chu, v_out, v_xong
    from tieu_diem where ma = p_ma;

  if not found then
    raise exception 'Không tìm thấy cam kết %', p_ma;
  end if;
  if not coalesce(v_xong, false) then
    raise exception 'Cam kết chưa đóng thì chưa nghiệm thu được';
  end if;
  if length(trim(coalesce(v_out, ''))) = 0 then
    raise exception 'Cam kết này chưa có output để nhận';
  end if;

  select leader_id into v_leader from nguoi where id = v_chu;

  -- ⬇️ LUẬT KÝ NHẬN (Tracy chốt 11/08) — sửa ở đây nếu phân cấp đổi.
  if v_leader is null then
    -- Không có ai đứng trên (Andy, CEO) → CHÍNH CHỦ tự ký: "Andy thì Andy tự bấm".
    if v_toi <> v_chu then
      raise exception 'Cam kết này chỉ chủ của nó ký nhận được — trong app không ai đứng trên họ';
    end if;
  else
    -- Có cấp trên → đúng một người ký được, và người đó không bao giờ là chính
    -- chủ (bài tự kiểm ④ ép không ai tự làm cấp trên của mình). Tức luật gốc
    -- "không tự ký cho mình" vẫn còn nguyên với 6 người còn lại.
    if v_toi <> v_leader then
      raise exception 'Chỉ cấp trên trực tiếp mới ký nhận được cam kết này';
    end if;
  end if;

  update tieu_diem
     set da_nhan_boi = v_toi, da_nhan_luc = now()
   where ma = p_ma;
end $$;

comment on function nhan_cam_ket(text) is
  'Nút "Đã nhận": ghi chữ ký nghiệm thu lên một cam kết đã đóng. Người bấm phải là CẤP TRÊN TRỰC TIẾP của chủ cam kết (nguoi.leader_id); chủ cam kết không có cấp trên (CEO) thì chính họ tự ký.';

grant execute on function nhan_cam_ket(text) to authenticated;

notify pgrst, 'reload schema';


-- ─── 4. Tự kiểm — chạy xong nhìn bảng này, cột `dat` phải ĐÚNG cả NĂM dòng ──
select * from (values
  (1, 'Bảng nguoi đã có cột leader_id',
   exists (select 1 from information_schema.columns
            where table_name = 'nguoi' and column_name = 'leader_id')),

  (2, 'Andy KHÔNG có cấp trên (đúng: trong app không ai đứng trên CEO)',
   (select leader_id is null from nguoi where lower(trim(ten)) = 'andy')),

  (3, 'CẢ 6 người còn lại đều trỏ về Andy',
   (select count(*) = 0 from nguoi
     where lower(trim(ten)) <> 'andy'
       and leader_id is distinct from (select id from nguoi where lower(trim(ten)) = 'andy'))),

  (4, 'Không ai tự làm cấp trên của chính mình',
   not exists (select 1 from nguoi where leader_id = id)),

  (5, 'Hàm nhan_cam_ket đã mang mệnh đề soi cấp trên',
   (select prosrc like '%leader_id%' from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
     where p.proname = 'nhan_cam_ket' and n.nspname = 'public'))
) as t(so, muc, dat);


-- ─── 5. Xem lại phân cấp bằng mắt (chạy kèm cho chắc) ───────────────────────
select n.thu_tu, n.ten, n.vai,
       coalesce(l.ten, '— không có cấp trên —') as cap_tren
  from nguoi n left join nguoi l on l.id = n.leader_id
 order by n.thu_tu;
