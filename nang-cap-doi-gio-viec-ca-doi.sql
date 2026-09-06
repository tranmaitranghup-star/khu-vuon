-- ═══════════════════════════════════════════════════════════════════════════
-- ĐỔI GIỜ CHUỖI SỰ KIỆN THÌ VIỆC CỦA CẢ ĐỘI ĐI THEO — Tracy chốt 05/09 (TRI-109)
--
-- Tracy 05/09: *"làm luôn máy chủ"*, sau khi nghe hạn chế của TRI-107.
--
-- VÌ SAO PHẢI LÀ MỘT HÀM Ở MÁY CHỦ. Chính sách `ghi_task` cho mỗi người sửa
-- đúng việc của chính mình. Đó là luật đúng và không nên nới: mở policy update
-- cho việc của người khác là mở TOÀN BỘ cột của dòng ấy — nội dung, trạng thái,
-- ghi chú chốt — chứ không riêng ba cột giờ, vì RLS của Postgres chặn theo DÒNG
-- chứ không theo CỘT. Nên lời giải là một hàm `security definer` khoanh đúng
-- những cột cần chạm, cùng lối đã dùng cho `nhan_cam_ket` và
-- `danh_dau_da_xem_du_an`.
--
-- AI ĐƯỢC GỌI. Đúng bằng quyền SỬA sự kiện, không rộng hơn: lead, hoặc người
-- tạo ra sự kiện ấy — chép nguyên vế `using` của policy `sua_lich`. Lý lẽ: ai
-- đổi được giờ một cuộc họp thì việc của cuộc họp ấy đi theo là hệ quả tất
-- yếu, không phải một quyền mới. Ai không đổi được giờ thì cũng không gọi được
-- hàm này, và hàm nói thẳng ra thay vì lặng lẽ trả về 0.
--
-- BA THỨ HÀM NÀY CỐ Ý KHÔNG CHẠM, cả ba đều chép từ luật máy khách của TRI-107:
--   ① Việc KHÔNG còn sạch — đã đổi trạng thái, hoặc đã có phiên deep work dù
--      chỉ một phiên bỏ dở. Việc người ta đã cầm trong tay thì không ghi đè.
--   ② Buổi ĐÃ DỜI RIÊNG — một dòng `kieu='doi'` trong `lich_chung_ngoai_le` là
--      quyết định có chủ ý của người dùng. Kéo nó về hàng là xoá quyết định ấy.
--   ③ NGÀY của việc. Với chuỗi định kỳ, ngày do luật lặp quyết; đổi ngày ở đây
--      là viết lại luật sau lưng người vừa đổi giờ.
--
-- Chạy tệp này lúc nào cũng được, chạy lại bao nhiêu lần cũng được. Chưa chạy
-- thì app vẫn chạy y như hôm qua — máy khách tự dò, không thấy hàm thì rơi về
-- đường cũ và chỉ dời việc của chính người đổi giờ.
-- ═══════════════════════════════════════════════════════════════════════════

create or replace function doi_gio_viec_theo_chuoi(
  p_lich_id bigint,
  p_gio     integer,      -- giờ bắt đầu mới, tính bằng phút từ 0h (0..1439)
  p_phut    integer        -- độ dài mới, phút
  -- Hai tham số khai `integer` chứ không `smallint` dù kho lưu smallint: máy
  -- khách gửi một số JSON, và một chữ ký smallint là chỗ dễ sinh ra lỗi "không
  -- tìm thấy hàm" khó đọc. Phép gán xuống cột smallint thì Postgres tự lo.
) returns integer
language plpgsql security definer set search_path = public as $$
declare
  v_toi    uuid := nguoi_id_dang_nhap();
  v_gio    text;
  v_het    text;
  v_ids    bigint[];
  v_co_gio boolean;
begin
  if v_toi is null then
    raise exception 'Không phải thành viên ROVA';
  end if;

  -- Đúng vế `using` của policy `sua_lich` (nang-cap-su-kien-ca-nhan.sql:94).
  -- Chép ra đây chứ không soi ngược policy: hàm chạy bằng quyền định nghĩa nên
  -- RLS không tự chặn hộ, và một hàm security definer không tự kiểm quyền là
  -- một cánh cửa mở.
  if not (la_lead() or exists (select 1 from lich_chung l
                                where l.id = p_lich_id and l.tao_boi = v_toi)) then
    raise exception 'Chỉ người tạo sự kiện hoặc lead mới đổi được giờ của nó';
  end if;

  if p_gio is null or p_gio < 0 or p_gio > 1439 then
    raise exception 'Giờ bắt đầu phải nằm trong một ngày (0..1439 phút)';
  end if;
  if p_phut is null or p_phut < 5 or p_phut > 1440 then
    raise exception 'Độ dài buổi phải từ 5 tới 1440 phút';
  end if;

  -- Giờ lưu trong `task` là chuỗi 'HH:MM' — cùng dạng máy khách vẫn ghi.
  -- Giờ kết thúc quấn vòng qua nửa đêm bằng phép chia dư, đúng như một buổi
  -- 23:30 dài 60 phút vẫn kết thúc lúc 00:30.
  v_gio := lpad((p_gio / 60)::text, 2, '0') || ':' || lpad((p_gio % 60)::text, 2, '0');
  v_het := lpad((((p_gio + p_phut) % 1440) / 60)::text, 2, '0') || ':'
        || lpad((((p_gio + p_phut) % 1440) % 60)::text, 2, '0');

  select array_agg(t.id) into v_ids
    from task t
   where t.lich_id = p_lich_id
     and t.trang_thai = 'Chua_lam'
     and not exists (select 1 from phien_deepwork p where p.task_id = t.id)
     and not exists (select 1 from lich_chung_ngoai_le n
                      where n.lich_id = p_lich_id
                        and n.kieu    = 'doi'
                        and n.ngay_goc = t.lich_ngay);

  if v_ids is null then return 0; end if;

  -- Hai cột `gio_start`/`gio_end` tới sau (nang-cap-gio-start-end.sql). Dự án
  -- chưa chạy tệp ấy thì câu update nhắc tên chúng là hỏng cả câu, không phải
  -- bỏ qua một trường — nên hỏi danh mục trước rồi dựng câu cho khớp.
  select exists (select 1 from information_schema.columns
                  where table_schema = 'public' and table_name = 'task'
                    and column_name = 'gio_start') into v_co_gio;

  if v_co_gio then
    execute 'update task set deadline = $1, thoi_luong_du_kien = $2,
                             gio_start = $1, gio_end = $3
              where id = any($4)'
      using v_gio, p_phut, v_het, v_ids;
  else
    execute 'update task set deadline = $1, thoi_luong_du_kien = $2
              where id = any($3)'
      using v_gio, p_phut, v_ids;
  end if;

  return array_length(v_ids, 1);
end $$;

comment on function doi_gio_viec_theo_chuoi(bigint, integer, integer) is
  'Đổi giờ một chuỗi sự kiện thì việc đã đẻ của MỌI người đi theo giờ mới. '
  'Chạy bằng quyền định nghĩa vì ghi_task chỉ cho mỗi người sửa việc của chính '
  'mình; hàm tự kiểm đúng quyền sửa sự kiện trước khi chạm gì. Chừa ba thứ: '
  'việc không còn sạch, buổi đã dời riêng, và ngày của việc. Tracy chốt 05/09 '
  '(TRI-109): lịch trình là thứ để nhìn lại, task là thứ để làm.';

grant execute on function doi_gio_viec_theo_chuoi(bigint, integer, integer) to authenticated;


-- ─── SOI LẠI ────────────────────────────────────────────────────────────────
-- Ba dòng dưới đây phải ra đúng ba kết quả đã ghi. Sai dòng nào thì dừng ở đó.

-- ① Hàm có mặt và chạy bằng quyền định nghĩa. Phải ra đúng 1 dòng, cột
--    `quyen_dinh_nghia` = true.
select p.proname as ten,
       p.prosecdef as quyen_dinh_nghia,
       pg_get_function_arguments(p.oid) as tham_so
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public' and p.proname = 'doi_gio_viec_theo_chuoi';

-- ② Người đăng nhập gọi được. Phải ra đúng 1 dòng.
select grantee, privilege_type
  from information_schema.routine_privileges
 where routine_schema = 'public'
   and routine_name   = 'doi_gio_viec_theo_chuoi'
   and grantee        = 'authenticated';

-- ③ Chính sách ghi của `task` KHÔNG bị nới — vẫn phải là "mỗi người việc của
--    mình". Nếu dòng này trả về một chính sách rộng hơn thì tệp nào đó đã nới
--    quyền và hàm này thành thừa, đồng thời là một chỗ hở.
select polname as chinh_sach, pg_get_expr(polqual, polrelid) as dieu_kien
  from pg_policy
 where polrelid = 'public.task'::regclass and polname = 'ghi_task';
