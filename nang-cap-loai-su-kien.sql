-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.tieu_diem_ma`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — TRƯỜNG "LOẠI SỰ KIỆN"
--                                     (Tracy chốt 04/09/2026 — phương án B)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-loai-ca-nhan.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn LSK).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 04/09: *"bổ sung thêm ở cửa sổ sự kiện 1 trường thông tin là sự kiện
-- này thuộc loại nào (y như task ý)"*, chọn phương án B — ô Loại của sự kiện
-- bày đúng bộ dòng như ô của việc, tức có cả danh sách CAM KẾT.
--
-- Đây là lời sửa cho một chỗ tôi làm ẩu hôm qua: tôi nhét dòng "Cá nhân" vào ô
-- NHÓM NHẬN, mà ô ấy trả lời câu *ai nhận sự kiện này*. Còn "loại gì" là một
-- câu khác. Hai câu chung một ô thì sớm muộn đá nhau — và nó đá ngay: một sự
-- kiện cá nhân không thể đồng thời khai là gửi cho khối Kinh doanh, nên dòng
-- thứ tám ấy phải mang theo một ràng buộc mà sáu dòng kia không có.
-- Nay tách ra: ô nhóm nhận về đúng bảy dòng của nó, ô Loại lo phần còn lại.
--
-- ─── ĐƯỢC GÌ NGOÀI CHUYỆN GỌN ───────────────────────────────────────────────
-- Cột `tieu_diem_ma` trên `lich_chung` trả lời được câu mà tới hôm nay app chưa
-- trả lời được: *"cam kết này đã họp mấy buổi"*. Và việc đẻ ra từ một buổi
-- thừa hưởng luôn cam kết ấy, nên giờ ngồi họp cũng chảy về đúng cam kết nó
-- phục vụ thay vì rơi hết vào "việc phát sinh".
--
-- ─── MỘT PHÂN BIỆT CÓ CHỦ Ý: THỪA HƯỞNG vs ĐỒNG BỘ ──────────────────────────
-- Hai cột cùng chảy từ sự kiện xuống việc của nó, nhưng chảy theo hai luật
-- khác nhau, và khác nhau là cố ý:
--
--   · `rieng_tu`      → ĐỒNG BỘ MÃI. Đổi cờ ở sự kiện thì mọi việc của nó đổi
--     theo (cò `tg_cham_rieng_tu_theo_su_kien`, đã dựng hôm qua). Vì đây là một
--     LỜI HỨA về quyền riêng tư: một cột hứa mà trôi lệch được thì nó không còn
--     là lời hứa, nó là một sự trùng hợp.
--
--   · `tieu_diem_ma`  → THỪA HƯỞNG LÚC RA ĐỜI, rồi thôi. Đây là một GIÁ TRỊ
--     MẶC ĐỊNH, không phải một lời hứa: người ta được phép kéo riêng một việc
--     sang cam kết khác, và một cò đồng bộ sẽ giật nó về mà không hỏi. Đổi cam
--     kết của sự kiện thì các buổi SAU nhận cam kết mới; buổi cũ giữ nguyên,
--     đúng như lịch sử của nó.
--
-- Đừng "dọn cho nhất quán" bằng cách cho cả hai cùng một luật. Sự khác nhau
-- này là câu trả lời, không phải chỗ sót.
-- ============================================================================

begin;

-- ═══ 1. CỘT MỚI ════════════════════════════════════════════════════════════
-- `on delete set null` chứ không `cascade`: xoá một cam kết thì buổi họp vẫn đã
-- diễn ra, nó chỉ thôi thuộc về đâu. `cascade` ở đây là xoá mất lịch sử họp.
alter table lich_chung add column if not exists tieu_diem_ma text
  references tieu_diem (ma) on delete set null;

comment on column lich_chung.tieu_diem_ma is
  'Cam kết mà buổi này phục vụ — rỗng là sự kiện thường, không thuộc cam kết '
  'nào. Việc đẻ ra từ buổi thừa hưởng giá trị này LÚC RA ĐỜI rồi thôi: đây là '
  'một mặc định, không phải một lời hứa, nên người dùng kéo riêng một việc sang '
  'cam kết khác thì không cò nào giật về. Khác hẳn rieng_tu, thứ đồng bộ mãi.';

create index if not exists lich_theo_camket on lich_chung (tieu_diem_ma)
  where tieu_diem_ma is not null;


-- ═══ 2. HAI DÒNG CỦA Ô LOẠI LOẠI TRỪ NHAU ══════════════════════════════════
-- Ô Loại là MỘT ô, nên trong đời thật không ai chọn được cả hai. Nhưng khoá
-- công khai nằm ngay trong mã nguồn trang web, nên hàng rào thật phải ở đây —
-- và nó cũng là thứ giữ cho luật KHÔNG GIỮ NGẦM không bị một cú ghi thiếu
-- trường làm hỏng: đổi từ cam kết sang cá nhân mà quên xoá cột kia thì câu ghi
-- bị chặn ngay, thay vì đẻ ra một dòng tự mâu thuẫn không ai đọc ra.
alter table lich_chung drop constraint if exists lich_ca_nhan_khong_cam_ket;
alter table lich_chung add  constraint lich_ca_nhan_khong_cam_ket
  check (not rieng_tu or tieu_diem_ma is null);


-- ═══ 3. CÒ THỪA HƯỞNG — nay mang HAI cột thay vì một ═══════════════════════
-- Thay cho `cham_rieng_tu_viec_cua_buoi` dựng hôm qua. Đổi TÊN chứ không sửa
-- ruột tại chỗ: tên cũ nói nó chỉ lo cờ riêng tư, mà từ nay nó lo hai cột —
-- một cái tên nói thiếu việc mình làm là chỗ phiên sau đọc lướt rồi hiểu sai.
create or replace function cham_theo_su_kien_cha()
returns trigger language plpgsql security definer
set search_path = public
as $$
declare cha lich_chung%rowtype;
begin
  if new.lich_id is null then return new; end if;
  select * into cha from lich_chung where id = new.lich_id;
  if not found then return new; end if;

  -- Cờ riêng tư: NÂNG LÊN theo cha, không bao giờ hạ. Hạ là chuyện của cò
  -- `tg_cham_rieng_tu_theo_su_kien`, nơi nhìn được cả cú đổi.
  if cha.rieng_tu then new.rieng_tu := true; end if;

  -- Cam kết: chỉ điền khi việc CHƯA có cam kết nào. Người dùng đã chọn tay thì
  -- giữ nguyên — đây là mặc định, không phải lệnh.
  if new.tieu_diem_ma is null then new.tieu_diem_ma := cha.tieu_diem_ma; end if;

  -- Ràng buộc bên trên áp cho `lich_chung`; việc thì chưa có ràng buộc tương
  -- đương, nên giữ vế ấy ngay tại đây: việc riêng tư thì không mang cam kết.
  if new.rieng_tu then new.tieu_diem_ma := null; end if;
  return new;
end $$;

drop trigger if exists tg_cham_rieng_tu_viec_cua_buoi on task;
drop function if exists cham_rieng_tu_viec_cua_buoi();

drop trigger if exists tg_cham_theo_su_kien_cha on task;
create trigger tg_cham_theo_su_kien_cha
  before insert or update of lich_id on task
  for each row execute function cham_theo_su_kien_cha();


-- ═══ 4. LẤP CHO DỮ LIỆU ĐÃ CÓ ══════════════════════════════════════════════
-- Buổi đã đẻ việc trước khi có cột này: kéo cam kết xuống cho việc nào CHƯA có
-- cam kết. Không đụng việc người ta đã tự xếp — đúng luật "thừa hưởng, không
-- đồng bộ" ở đầu tệp.
update task t
   set tieu_diem_ma = l.tieu_diem_ma
  from lich_chung l
 where l.id = t.lich_id
   and t.tieu_diem_ma is null
   and l.tieu_diem_ma is not null
   and not t.rieng_tu;

commit;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from lich_chung where tieu_diem_ma is not null) as su_kien_co_cam_ket,
  (select count(*) from lich_chung where rieng_tu)                 as su_kien_ca_nhan,
  (select count(*) from task where lich_id is not null
                               and tieu_diem_ma is not null)       as viec_cua_buoi_co_cam_ket;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả sáu dòng ═════════════════════════════
-- (đứng CUỐI vì trình soạn SQL của Supabase chỉ bày kết quả câu lệnh cuối cùng;
--  `order by dat, so` để dòng chưa đạt nổi lên đầu — luật rút ra 04/09)
select * from (values
  (1, 'cột tieu_diem_ma có mặt trên lich_chung',
   exists (select 1 from information_schema.columns
            where table_schema = 'public' and table_name = 'lich_chung'
              and column_name = 'tieu_diem_ma')),

  (2, 'nó trỏ thật sang tieu_diem, và xoá cam kết thì để lại buổi',
   exists (select 1 from pg_constraint c
            where c.conrelid = 'public.lich_chung'::regclass
              and c.contype = 'f' and c.confrelid = 'public.tieu_diem'::regclass
              and c.confdeltype = 'n')),

  /* 🪤 SO CHUỖI VỚI MỘT RÀNG BUỘC THÌ CHỈ SO TÊN CỘT, ĐỪNG SO TỪ KHOÁ.
     Bản đầu hỏi `like '%tieu_diem_ma is null%'` và ra ❌ oan trên máy chủ thật
     (Tracy chạy 04/09). Postgres KHÔNG cất lại nguyên văn câu mình gõ: nó phân
     tích rồi in lại, và lúc in thì TỪ KHOÁ VIẾT HOA, còn tên cột giữ nguyên —
     `check (not rieng_tu or tieu_diem_ma is null)` cất vào thành
     `CHECK (((NOT rieng_tu) OR (tieu_diem_ma IS NULL)))`.
     Ngoặc cũng được thêm vào, nên cả khoảng cách lẫn hình dạng đều đổi.
     Vậy nên mẫu so chỉ được chứa TÊN CỘT và chuỗi trong nháy — hai thứ duy nhất
     Postgres trả lại y nguyên. Năm câu so trong tệp hôm qua đều đúng luật này
     nên đều xanh; đúng câu này phạm, và nó phạm vì tôi gõ theo trí nhớ về câu
     mình vừa viết chứ không theo thứ máy chủ sẽ trả về. */
  (3, 'sự kiện cá nhân không mang cam kết được',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_ca_nhan_khong_cam_ket'
       and conrelid = 'public.lich_chung'::regclass) like '%rieng_tu%tieu_diem_ma%'),

  (4, 'cò thừa hưởng đã đổi sang bản mang hai cột',
   exists (select 1 from pg_trigger
            where not tgisinternal and tgname = 'tg_cham_theo_su_kien_cha')
   and not exists (select 1 from pg_trigger
            where not tgisinternal and tgname = 'tg_cham_rieng_tu_viec_cua_buoi')),

  (5, 'ba cò của tệp hôm qua vẫn còn nguyên',
   (select count(*) from pg_trigger
     where not tgisinternal
       and tgname in ('tg_cham_rieng_tu_phien','tg_cham_rieng_tu_theo_viec',
                      'tg_cham_rieng_tu_theo_su_kien')) = 3),

  (6, 'không dòng nào rơi vào trạng thái tự mâu thuẫn',
   not exists (select 1 from lich_chung where rieng_tu and tieu_diem_ma is not null)
   and not exists (select 1 from task where rieng_tu and tieu_diem_ma is not null))
) as t(so, muc, dat)
order by dat, so;
