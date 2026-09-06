-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.khach_sua`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — QUYỀN CỦA KHÁCH, học theo Lịch Google
--                                                  (Tracy chốt 04/09/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-moi-vao-su-kien-ca-nhan.sql`.
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 04/09: *"cho thêm tính năng quyền của khách nữa cho tôi như gg calendar
-- nhé"*, kèm lý do: *"tôi muốn thiết kế giống gg calendar để mọi người đỡ mất
-- công học lại cách dùng"*. Lịch Google có đúng ba ô tick, và ta chép đúng ba:
--     ☐ Sửa đổi sự kiện · ☑ Mời những người khác · ☑ Xem danh sách khách mời
--
-- MẶC ĐỊNH CHÉP LUÔN CỦA GOOGLE: sửa thì TẮT, hai ô kia BẬT. Đó là mặc định
-- người ta đã quen, và cả lý do chép giao diện này là để khỏi phải học lại.
--
-- ─── HAI Ô CHỈ GÁC MÀN HÌNH, MỘT Ô PHẢI GÁC Ở KHO ───────────────────────────
-- `khach_moi` và `khach_xem_ds` đổi thứ app BÀY RA. Chúng không mở thêm đường
-- ghi nào, nên hàng rào ở màn hình là đủ đúng tầm.
-- `khach_sua` thì khác: nó mở một đường GHI. Khoá công khai nằm ngay trong mã
-- nguồn trang web, nên nó phải nằm trong policy — ẩn nút Lưu đi không phải là
-- một hàng rào.
--
-- ─── LỖ PHẢI BỊT CÙNG LÚC ───────────────────────────────────────────────────
-- Cho khách sửa là cho họ chạy `update` trên dòng ấy. RLS của Postgres theo
-- DÒNG chứ không theo CỘT, nên không có cách nào nói "sửa được tên, không sửa
-- được cờ riêng tư" bằng một policy. Mà hai cột thì tuyệt đối không được để
-- khách chạm:
--     · `rieng_tu`  — hạ nó xuống là công khai một buổi riêng của người khác;
--     · `tao_boi`   — đổi nó là chiếm quyền chủ sự kiện.
-- Nên đi bằng CÒ: ai không phải chủ (và không phải lead) thì hai cột ấy bị kéo
-- về giá trị cũ trước khi ghi. Cò chạy TRƯỚC policy `with check`, và nó nhìn
-- được cả bản cũ lẫn bản mới — thứ policy không làm được.
-- ============================================================================

begin;

-- ═══ 1. BA CỘT, ĐÚNG BA Ô TICK CỦA LỊCH GOOGLE ═════════════════════════════
alter table lich_chung add column if not exists khach_sua     boolean not null default false;
alter table lich_chung add column if not exists khach_moi     boolean not null default true;
alter table lich_chung add column if not exists khach_xem_ds  boolean not null default true;

comment on column lich_chung.khach_sua is
  'Khách mời được sửa sự kiện. Mặc định TẮT, đúng mặc định của Lịch Google. Có '
  'hàng rào thật ở policy sua_lich, không chỉ ẩn nút. Kể cả khi bật, cò '
  'chan_khach_sua_cot_cam vẫn giữ rieng_tu và tao_boi khỏi tay khách.';
comment on column lich_chung.khach_moi is
  'Khách mời được mời thêm người. Gác ở màn hình: nó không mở đường ghi nào mới.';
comment on column lich_chung.khach_xem_ds is
  'Khách mời thấy TÊN những khách khác. Tắt thì họ chỉ thấy SỐ người — đúng cách Lịch Google làm. Gác ở màn hình.';


-- ═══ 2. CÒ GIỮ HAI CỘT KHỎI TAY KHÁCH ══════════════════════════════════════
-- Chạy cho MỌI lượt update, không chỉ lượt của khách: một cò chỉ đúng trong
-- một số cảnh là một cò phải đi kèm trí nhớ của người đọc mã.
create or replace function chan_khach_sua_cot_cam()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  -- Chủ sự kiện và lead đi qua, không đụng gì.
  if old.tao_boi = nguoi_id_dang_nhap() or la_lead() then return new; end if;
  -- Còn lại là khách: hai cột này giữ nguyên bản cũ, dù họ gửi lên gì.
  new.rieng_tu := old.rieng_tu;
  new.tao_boi  := old.tao_boi;
  return new;
end $$;

drop trigger if exists tg_chan_khach_sua_cot_cam on lich_chung;
create trigger tg_chan_khach_sua_cot_cam
  before update on lich_chung
  for each row execute function chan_khach_sua_cot_cam();


-- ═══ 3. NỚI `sua_lich` — thêm ĐÚNG một vế ══════════════════════════════════
-- Vế mới đòi CẢ HAI: cờ bật, VÀ người đang sửa có tên trong danh sách khách.
-- Bật cờ mà không mời ai thì không mở cửa cho ai cả — đúng như Lịch Google.
drop policy if exists sua_lich on lich_chung;
create policy sua_lich on lich_chung for update
  using      (la_lead() or tao_boi = nguoi_id_dang_nhap()
              or (khach_sua and nguoi_id_dang_nhap() = any(nguoi_ids)))
  with check (la_lead() or tao_boi = nguoi_id_dang_nhap()
              or (khach_sua and nguoi_id_dang_nhap() = any(nguoi_ids)));

comment on policy sua_lich on lich_chung is
  'Sửa một sự kiện: lead, chủ sự kiện, hoặc khách mời khi chủ đã bật khach_sua. Cò tg_chan_khach_sua_cot_cam giữ rieng_tu và tao_boi khỏi tay khách kể cả lúc ấy.';

-- ⛔ `xoa_lich` KHÔNG nới. Lịch Google cũng vậy: khách sửa được nội dung, nhưng
--    huỷ cả sự kiện là việc của người tổ chức. Ghi ra đây để phiên sau đọc thấy
--    hai policy lệch nhau mà không tưởng là chỗ sót.

commit;


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select count(*)                                as tong_su_kien,
       count(*) filter (where khach_sua)       as cho_khach_sua,
       count(*) filter (where not khach_moi)   as cam_khach_moi_them,
       count(*) filter (where not khach_xem_ds) as giau_danh_sach_khach
  from lich_chung;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả năm dòng ═════════════════════════════
-- (mẫu so chỉ chứa TÊN CỘT và tên hàm — Postgres viết hoa từ khoá khi in lại)
select * from (values
  (1, 'ba cột quyền khách có mặt, không cột nào cho rỗng',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'lich_chung'
       and column_name in ('khach_sua','khach_moi','khach_xem_ds')
       and is_nullable = 'NO') = 3),

  (2, 'mặc định chép của Lịch Google — sửa TẮT, hai ô kia BẬT',
   (select column_default from information_schema.columns
     where table_schema='public' and table_name='lich_chung'
       and column_name='khach_sua') like 'false%'
   and (select count(*) from information_schema.columns
         where table_schema='public' and table_name='lich_chung'
           and column_name in ('khach_moi','khach_xem_ds')
           and column_default like 'true%') = 2),

  (3, 'sua_lich nay soi cả khach_sua',
   (select qual from pg_policies
     where tablename = 'lich_chung' and policyname = 'sua_lich') like '%khach_sua%'),

  (4, 'cò giữ hai cột cấm đã dựng',
   exists (select 1 from pg_trigger
            where not tgisinternal and tgname = 'tg_chan_khach_sua_cot_cam')),

  (5, 'xoa_lich KHÔNG bị nới theo — huỷ buổi vẫn là việc của chủ',
   (select qual from pg_policies
     where tablename = 'lich_chung' and policyname = 'xoa_lich') not like '%khach_sua%')
) as t(so, muc, dat)
order by dat, so;
