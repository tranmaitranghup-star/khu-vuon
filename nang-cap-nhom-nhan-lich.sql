-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `lich_chung.chuc_nang_ids` (mảng), và cột
-- │ `lich_chung.chuc_nang_id` (số đơn) ĐÃ BIẾN MẤT.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — SÁU NHÓM NHẬN LỊCH CỐ ĐỊNH
--                                                  (Tracy chốt 31/08/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU `nang-cap-lich-chung.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn NL).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy đưa đúng sáu lựa chọn cho ô phạm vi:
--     Cả công ty · Kinh doanh · Trải nghiệm khách hàng ·
--     Vận hành & tài chính · Sản phẩm · Coreteam
--
-- Danh sách ấy KHÔNG trùng bảng `chuc_nang` đang có, lệch ở đúng hai chỗ:
--   ① "Vận hành & tài chính" gộp HAI khối. Cột `chuc_nang_id` là một con số
--      đơn, nên nó không nói được câu "hai khối này".
--   ② "Coreteam" không phải một khối nào cả — nó là một lát cắt ngang, gom
--      người theo VAI chứ không theo ghế.
-- Và "CEO" rơi ra khỏi danh sách: người khối CEO nhận lịch qua "Cả công ty"
-- hoặc "Coreteam", không qua một nhóm riêng.
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- Một cột MẢNG thay cho cột số đơn, cộng một giá trị phạm vi thứ ba.
--   pham_vi = 'cong_ty'  → mọi người
--   pham_vi = 'khoi'     → ai có chuc_nang_id nằm trong chuc_nang_ids
--   pham_vi = 'coreteam' → ai mang cờ nguoi.la_lead
--
-- ✅ "Coreteam = người có cờ la_lead" — Tracy xác nhận 31/08: "coreteam là 7
--    người lead hiện tại trong app đó". Lọc theo CỜ chứ không theo danh sách
--    tên chép cứng, nên người thứ 8 vào app mà không phải lead thì tự động nằm
--    ngoài. Hôm nay cả 7 đều bật cờ nên nhóm này trùng khít "Cả công ty".
--
-- VÌ SAO BỎ HẲN CỘT CŨ chứ không giữ cả hai: giữ hai cột cùng nói về phạm vi là
-- dựng hai nguồn sự thật cho một câu hỏi, và chỗ nào quên đọc cột mới thì sai
-- trong im lặng. Toàn kho lúc này có đúng MỘT dòng lịch, phạm vi "cả công ty",
-- nên không có gì để mất.
-- ============================================================================

begin;

-- ═══ 1. CỘT MẢNG ═══════════════════════════════════════════════════════════
alter table lich_chung add column if not exists chuc_nang_ids smallint[] not null default '{}';

comment on column lich_chung.chuc_nang_ids is
  'Các khối chức năng nhận lịch này. Rỗng khi pham_vi là cong_ty hoặc coreteam. '
  'Mảng chứ không phải số đơn, vì một nhóm có thể gộp nhiều khối '
  '(Tracy chốt 31/08: "Vận hành & tài chính").';

-- Chuyển dữ liệu cũ trước khi bỏ cột. Chỉ đụng dòng còn trống, nên chạy lại
-- không ghi đè thứ ai đó đã sửa tay.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'lich_chung'
                and column_name = 'chuc_nang_id')
  then
    execute 'update lich_chung set chuc_nang_ids = array[chuc_nang_id]::smallint[]
              where chuc_nang_id is not null
                and coalesce(array_length(chuc_nang_ids,1),0) = 0';
  end if;
end $$;


-- ═══ 2. NỚI PHẠM VI, RỒI GỠ CỘT CŨ ═════════════════════════════════════════
-- Ràng buộc cũ do Postgres tự đặt tên (`lich_chung_pham_vi_check`) vì nó viết
-- ngay trong khai báo cột. Gỡ cả tên tự sinh lẫn tên tự đặt, rồi dựng lại MỘT
-- cái có tên — để lần sau đọc `SO-SQL.sql` là biết nó ở đâu ra.
alter table lich_chung drop constraint if exists lich_chung_pham_vi_check;
alter table lich_chung drop constraint if exists lich_pham_vi_hop_le;
alter table lich_chung add  constraint lich_pham_vi_hop_le
  check (pham_vi in ('cong_ty', 'khoi', 'coreteam'));

-- Ràng buộc khớp phải bỏ TRƯỚC khi gỡ cột, vì nó đang đọc chính cột ấy.
alter table lich_chung drop constraint if exists lich_pham_vi_khop;
alter table lich_chung drop column if exists chuc_nang_id;

-- Hai chiều, y như bản cũ: lịch theo khối PHẢI kê ít nhất một khối, và hai
-- phạm vi kia PHẢI để trống. `coalesce` không thừa — `array_length('{}',1)` trả
-- NULL, mà một CHECK cho NULL thì Postgres coi là ĐẠT (đã vấp một lần ở
-- `lich_lap_du_tham_so`, chép lại bài học tại chỗ).
alter table lich_chung add constraint lich_pham_vi_khop check (
  (pham_vi =  'khoi' and coalesce(array_length(chuc_nang_ids,1),0) >= 1) or
  (pham_vi <> 'khoi' and coalesce(array_length(chuc_nang_ids,1),0) =  0));

-- Chỉ mục cũ trỏ vào cột vừa gỡ nên Postgres đã tự bỏ nó. Dựng lại theo cột mới.
create index if not exists lich_theo_pham_vi_moi
  on lich_chung (dang_dung, pham_vi);

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả bốn dòng ═════════════════════════════
select * from (values
  (1, 'cột chuc_nang_ids có mặt, kiểu mảng số nguyên nhỏ',
   (select data_type || '/' || coalesce(udt_name,'') from information_schema.columns
     where table_schema = 'public' and table_name = 'lich_chung'
       and column_name = 'chuc_nang_ids') = 'ARRAY/_int2'),

  (2, 'cột chuc_nang_id cũ ĐÃ biến mất',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'lich_chung'
       and column_name = 'chuc_nang_id') = 0),

  (3, 'phạm vi nhận đúng ba giá trị, có coreteam',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_pham_vi_hop_le') like '%coreteam%'),

  (4, 'không dòng nào rơi vào trạng thái nửa vời',
   not exists (select 1 from lich_chung
                where (pham_vi =  'khoi' and coalesce(array_length(chuc_nang_ids,1),0) = 0)
                   or (pham_vi <> 'khoi' and coalesce(array_length(chuc_nang_ids,1),0) > 0)))
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select pham_vi, count(*) as so_lich
  from lich_chung group by pham_vi order by pham_vi;
