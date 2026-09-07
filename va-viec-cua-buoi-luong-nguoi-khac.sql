-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `cham_theo_su_kien_cha` có chứa chữ
-- │ `chu_hat` (bản cũ không có biến này).
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- VÁ: KHÁCH MỜI KHÔNG DEEP WORK ĐƯỢC MỘT SỰ KIỆN CỦA NGƯỜI KHÁC
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn tệp → Run.
--            Chạy lại nhiều lần không sao.
--
-- ⛔ LỖI (Tracy gặp 07/09, sự kiện "Kịch bản Zoom Onboarding Master 1-1"):
--    bấm 💧 trên một sự kiện mình KHÔNG phải host thì hiện hai câu báo lỗi
--    chồng nhau — "Hạt O79 là luống của người khác" và "Máy chủ chưa có cột
--    việc của sự kiện" — và không vào được deep work.
--
-- NGUYÊN NHÂN: HAI CÒ ĐÚNG KHI ĐỨNG RIÊNG, GHÉP LẠI THÌ ĐÁ NHAU.
--    ① `cham_theo_su_kien_cha` (nang-cap-loai-su-kien.sql) kéo cam kết của SỰ
--       KIỆN xuống việc vừa đẻ. Cam kết ấy là luống của HOST.
--    ② `kiem_task_dung_luong` (va-luong-cheo-nhau.sql) chặn mọi việc bám vào
--       hạt của người khác — "cây chỉ mọc trong vườn mình".
--    Cả hai đều là cò BEFORE trên `task`, và Postgres chạy chúng theo thứ tự
--    TÊN: `tg_cham_theo_su_kien_cha` trước, `trg_kiem_task_dung_luong` sau.
--    Nên cò ① nhét hạt của host vào việc của khách, rồi cò ② chặn đúng cái
--    việc mà cò ① vừa làm hỏng. Khách mời không có đường nào lách.
--
-- CÁCH SỬA: cò ① chỉ thừa hưởng cam kết khi hạt ấy là luống CỦA CHÍNH người
--    đang đẻ việc. Không phải thì để trống — việc của khách thành 🪴 việc phát
--    sinh, đúng bản chất: khách đi dự một buổi không vì thế mà nhận cam kết
--    của host vào vườn mình.
--
-- ⚠️ CÒN MỘT VẾT CŨ PHẢI DỌN, mục 2. Tệp `nang-cap-loai-su-kien.sql` mục 4 đã
--    LẤP NGƯỢC cho dữ liệu cũ bằng một câu update không soi chủ hạt, nên những
--    việc đẻ từ sự kiện của người khác TRƯỚC hôm nay đang mang hạt của host.
--    Cò ② chặn MỌI cú update lên các dòng ấy — nghĩa là chủ của chúng không
--    tick xong được, không đổi trạng thái được, không deep work được. Chúng
--    đang đóng băng chứ không chỉ "hiển thị sai".
-- ============================================================================


-- ═══ 1. CÒ THỪA HƯỞNG — nay soi chủ hạt trước khi kéo cam kết xuống ════════
create or replace function cham_theo_su_kien_cha()
returns trigger language plpgsql security definer
set search_path = public
as $$
declare cha lich_chung%rowtype;
        chu_hat uuid;
begin
  if new.lich_id is null then return new; end if;
  select * into cha from lich_chung where id = new.lich_id;
  if not found then return new; end if;

  -- Cờ riêng tư: NÂNG LÊN theo cha, không bao giờ hạ. Hạ là chuyện của cò
  -- `tg_cham_rieng_tu_theo_su_kien`, nơi nhìn được cả cú đổi.
  if cha.rieng_tu then new.rieng_tu := true; end if;

  -- Cam kết: chỉ điền khi việc CHƯA có cam kết nào, VÀ hạt ấy là luống của
  -- chính người đang đẻ việc. Người dùng đã chọn tay thì giữ nguyên — đây là
  -- mặc định, không phải lệnh.
  --
  -- Vế `chu_hat = new.nguoi_id` là chỗ vá 07/09. Thiếu nó thì khách mời nhận
  -- hạt của host, rồi bị `kiem_task_dung_luong` chặn ngay ở cùng một cú ghi.
  -- Đọc chủ hạt bằng một câu riêng chứ không nối vào câu trên: `cha` là dòng
  -- sự kiện, chủ của HẠT nằm ở bảng khác và có thể khác chủ sự kiện.
  if new.tieu_diem_ma is null and cha.tieu_diem_ma is not null then
    select nguoi_id into chu_hat from tieu_diem where ma = cha.tieu_diem_ma;
    if chu_hat = new.nguoi_id then new.tieu_diem_ma := cha.tieu_diem_ma; end if;
  end if;

  -- Ràng buộc bên trên áp cho `lich_chung`; việc thì chưa có ràng buộc tương
  -- đương, nên giữ vế ấy ngay tại đây: việc riêng tư thì không mang cam kết.
  if new.rieng_tu then new.tieu_diem_ma := null; end if;
  return new;
end $$;

drop trigger if exists tg_cham_theo_su_kien_cha on task;
create trigger tg_cham_theo_su_kien_cha
  before insert or update of lich_id on task
  for each row execute function cham_theo_su_kien_cha();


-- ═══ 2. DỌN VẾT CŨ — gỡ việc của khách ra khỏi luống của host ══════════════
-- CHỈ đụng việc ĐẺ TỪ SỰ KIỆN (`lich_id is not null`). Đó là loại duy nhất bị
-- máy gán nhầm; ngoài nó ra, một việc nằm sai luống là chuyện người ta tự làm
-- và tự quyết — `va-luong-cheo-nhau.sql` mục 5 để dành đúng cho Tracy.
--
-- Gỡ về `null` chứ không chuyển sang luống nào của khách: máy không biết buổi
-- ấy phục vụ cam kết nào của khách, và đoán hộ là gieo một cây vào luống người
-- ta không chọn. Việc thành 🪴 phát sinh; giờ deep work đã cày vẫn nguyên vẹn,
-- `phien_deepwork` nối theo `task_id` chứ không theo cam kết.
update task t
   set tieu_diem_ma = null
  from tieu_diem o
 where o.ma = t.tieu_diem_ma
   and t.lich_id is not null
   and t.nguoi_id <> o.nguoi_id;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
-- Số dòng mục 2 vừa gỡ đã nằm trong tự kiểm ②. Bảng dưới đếm phần CÒN LẠI:
-- việc nằm sai luống mà KHÔNG đẻ từ sự kiện — tệp này cố ý không đụng tới.
select count(*) as viec_lech_luong_khong_tu_su_kien
  from task t join tieu_diem o on o.ma = t.tieu_diem_ma
 where t.lich_id is null and t.nguoi_id <> o.nguoi_id;


-- ═══ TỰ KIỂM — đọc bảng này, dòng ❌ nổi lên đầu ════════════════════════════
select * from (
  select 1 as so,
         'Cò thừa hưởng đã soi chủ hạt' as muc,
         case when exists (
           select 1 from pg_proc where proname = 'cham_theo_su_kien_cha'
             and prosrc like '%chu_hat%'
         ) then '✅ đạt' else '❌ chưa' end as dat
  union all
  select 2, 'Không còn việc của sự kiện nằm trong luống người khác',
         case when (select count(*) from task t join tieu_diem o on o.ma = t.tieu_diem_ma
                     where t.lich_id is not null and t.nguoi_id <> o.nguoi_id) = 0
         then '✅ đạt' else '❌ chưa' end
  union all
  select 3, 'Cò chặn luống chéo vẫn còn sống (KHÔNG được gỡ nó)',
         case when exists (
           select 1 from pg_trigger where tgname = 'trg_kiem_task_dung_luong'
         ) then '✅ đạt' else '❌ chưa' end
) k order by dat, so;
