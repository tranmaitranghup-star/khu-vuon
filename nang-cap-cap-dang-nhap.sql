-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `cap_dang_nhap`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- BA CẤP DÙNG APP, PHÍA MÁY CHỦ — nhát ⓪ nền   (Tracy duyệt 2026-09-07, TRI-144)
--
-- Ba cấp — Quản trị · Lead · Member — đã sống ở lớp giao diện từ 07/09 (TRI-139,
-- làn CAP). Nhưng lớp ấy chỉ dọn mắt và chặn đường bấm: ai mở công cụ dev vẫn
-- hỏi thẳng máy chủ và lấy được đúng thứ giao diện đang giấu. Loạt tệp này đưa
-- ba giới hạn của cấp Member xuống tầng RLS, mỗi giới hạn một nhát:
--
--     ⓪  tệp NÀY  — hai hàm nền, và vá một cái gác kêu oan
--     ①  cam kết Cả ROVA   → bảng `tieu_diem`
--     ②  dự án              → `muc_tieu` · `thanh_vien_du_an` · `moc_du_an`
--     ③  việc cố định       → `viec_co_dinh` · `nhip` · `so_ngay`
--
-- Tệp này KHÔNG siết gì cả. Nó chỉ thêm hai hàm và sửa một hàm gác. Chạy xong,
-- mọi người vẫn đọc đúng những gì họ đọc được hôm qua — cố ý như vậy, để nếu có
-- gì hỏng thì biết chắc nó hỏng ở nhát siết, không phải ở nền.
--
-- ═══ VÌ SAO MỘT HÀM, KHÔNG PHẢI MỘT CỘT `cap` ═══════════════════════════════
-- Cấp suy thẳng từ hai cờ ĐÃ CÓ trên bảng `nguoi`. Dựng thêm cột `cap` là dựng
-- một sự thật thứ hai về cùng một chuyện, và hai sự thật thì có ngày lệch nhau —
-- lệch trong im lặng, vì không màn nào đối chiếu chúng. Một hàm thì không lệch
-- được: nó đọc thẳng hai cờ mỗi lần được hỏi.
--
-- ═══ THỨ TỰ HỎI CỜ LÀ MỘT PHẦN CỦA LUẬT ═════════════════════════════════════
-- ⚠️ Quản trị mang CẢ HAI cờ (soi máy chủ 07/09: bảy người đội cũ đều bật
-- `la_lead`, hai trong số đó bật thêm `la_quan_tri`). Hỏi `la_lead` TRƯỚC là
-- Tracy và Andy đọc ra "Lead". Cái sai ấy KHÔNG làm ai mất quyền gì, nên nó
-- sống được rất lâu — tới ngày ai đó thêm một giới hạn cho riêng cấp Lead.
-- Hàm `capCua` phía màn hình hỏi đúng thứ tự này; hàm dưới đây phải khớp, và
-- dòng ③ của bộ tự kiểm canh đúng thứ tự ấy bằng máy.
--
-- ═══ VÌ SAO KHÔNG HỎI `ngay_nghi` Ở ĐÂY ═════════════════════════════════════
-- ⛔ Người đã nghỉ KHÔNG phải người bị hạ cấp — hai câu hỏi khác nhau, và trộn
-- chúng vào một hàm là ngày mai không ai tách ra được nữa. `la_thanh_vien()`
-- (bản mới ở `nang-cap-co-cau-to-chuc.sql`) đã hỏi `ngay_nghi is null`; hàm này
-- chỉ trả lời "cấp nào", và mọi policy đều đi qua cả hai.
--
-- ═══ VÌ SAO `la_member()` NGẢ VỀ PHÍA CHẶT KHI KHÔNG BIẾT ════════════════════
-- Người không có trong bảng `nguoi` thì `cap_dang_nhap()` trả `null`. Lúc ấy
-- `la_member()` trả **true**, không phải false. Nghe ngược, nhưng đây là hàng
-- rào: hàng rào không biết bạn là ai thì phải đối xử với bạn như người ít quyền
-- nhất. Ngả về false nghĩa là một người lạ được đối xử như Lead ở bất cứ policy
-- nào quên kèm `la_thanh_vien()` — và một ngày nào đó sẽ có một policy quên.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── ① CẤP CỦA NGƯỜI ĐANG ĐĂNG NHẬP ────────────────────────────────────────
-- Trả 'quan-tri' | 'lead' | 'member', hoặc null nếu email không có trong bảng.
-- Ba chuỗi này là hợp đồng: `la_member()` dưới đây và mọi policy sau này đều so
-- với chúng. Đổi cách viết một chuỗi là làm hỏng mọi chỗ so, trong im lặng.
create or replace function cap_dang_nhap()
returns text language sql stable security definer set search_path = public
as $$
  select case
           when n.la_quan_tri then 'quan-tri'   -- hỏi TRƯỚC: quản trị mang cả hai cờ
           when n.la_lead     then 'lead'
           else                    'member'
         end
    from nguoi n
   where n.email = email_dang_nhap()
$$;

comment on function cap_dang_nhap() is
  'Cấp dùng app của người đang đăng nhập: quan-tri | lead | member, hoặc null '
  'nếu email không có trong bảng nguoi. Suy từ hai cờ la_quan_tri / la_lead, '
  'KHÔNG từ một cột cap riêng. ⚠️ Hỏi la_quan_tri TRƯỚC la_lead — quản trị mang '
  'cả hai cờ, hỏi ngược là quản trị đọc ra Lead. Cố ý KHÔNG hỏi ngay_nghi: đã '
  'nghỉ là câu hỏi khác, la_thanh_vien() lo việc đó.';


-- ─── ② CÓ PHẢI CẤP MEMBER KHÔNG ────────────────────────────────────────────
-- Cửa duy nhất mọi policy nên đi qua. Viết `cap_dang_nhap() = 'member'` thẳng
-- trong policy cũng chạy, nhưng rồi sẽ có hai mươi bản chép tay của cùng một
-- câu, và ngày đổi luật thì sót một bản là hở một cửa mà không ai thấy.
create or replace function la_member()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce(cap_dang_nhap() = 'member', true) $$;
--                                                 ↑ null → true: xem khối chú
--                                                   thích ở đầu tệp.

comment on function la_member() is
  'Người đang đăng nhập có phải cấp Member không. Không biết là ai thì trả '
  'TRUE — hàng rào ngả về phía chặt, không ngả về phía lỏng.';


-- ─── ③ VÁ CỔNG GÁC KHUNG NHÌN: nó đang kêu oan ─────────────────────────────
-- `kiem_khung_nhin_thieu_quyen()` (dựng 17/08, `nang-cap-cong-gac-khung-nhin.sql`)
-- so chuỗi: `'security_invoker=on' = any(reloptions)`. Nhưng Postgres cất lại
-- ĐÚNG CHỮ người ta gõ, không quy về một cách viết. Hai câu dưới đây cùng bật
-- một cờ mà cất thành hai chuỗi khác nhau:
--
--     create view … with (security_invoker = true)  →  {security_invoker=true}
--     alter view … set  (security_invoker = on)     →  {security_invoker=on}
--
-- Nên khung nhìn `ai_dang_lam` — dựng ngày 03/09 bằng lối `with (… = true)` —
-- bị hàm gác kêu tên suốt, dù cờ của nó đang sống. Kiểm bằng việc thật (07/09):
-- khoá công khai chưa đăng nhập đọc `ai_dang_lam` ra RỖNG, trong khi khoá quản
-- trị ra 4 dòng. Cờ có thật; cái sai nằm ở phép so.
--
-- 🪤 Đây đúng cái bẫy mà `DOC-TRUOC.md` đã kê tên — *mẫu so chuỗi chỉ được chứa
-- tên cột và chuỗi trong nháy* — lần này nằm trong chính cái gác. Và nó là loại
-- sai tệ nhất: hàm gác KHÔNG BAO GIỜ bỏ sót một lỗ thật (thiếu cờ vẫn bị kêu),
-- nó chỉ kêu oan. Mà một dòng ❌ oan thì dạy người đọc thôi tin cả bảng — rồi
-- ngày có một khung nhìn hở thật, tên nó nằm lẫn giữa những cái tên đã quen bị
-- bỏ qua.
--
-- Cách chữa: đọc giá trị của tuỳ chọn rồi ÉP VỀ BOOLEAN, thay vì so chuỗi.
-- `'true'::boolean` · `'on'::boolean` · `'yes'::boolean` · `'1'::boolean` đều ra
-- true; `'off'` · `'false'` ra false. Postgres đã kiểm tính hợp lệ của tuỳ chọn
-- ngay lúc tạo khung nhìn, nên không có chuỗi lạ nào lọt vào đây để ép hỏng.
--
-- KHÔNG đụng vào chính khung nhìn `ai_dang_lam`. Nó đang đúng; sửa nó là một
-- lượt `create or replace` không cần thiết trên một khung nhìn đang chạy, đổi
-- lấy đúng con số 0 (`drop view` thì còn làm rơi cờ trong im lặng).
create or replace function kiem_khung_nhin_thieu_quyen()
returns table (ten_view text)
language sql
stable
security invoker   -- cổng gác mà chạy bằng quyền người tạo thì chính nó phạm luật nó canh
set search_path = public, pg_catalog
as $$
  select c.relname::text
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where c.relkind = 'v'                    -- 'v' = khung nhìn thường
     and n.nspname = 'public'               -- PostgREST chỉ mở schema này ra ngoài
     and not coalesce((
           select split_part(opt, '=', 2)::boolean
             from unnest(coalesce(c.reloptions, '{}'::text[])) as opt
            where split_part(opt, '=', 1) = 'security_invoker'
            limit 1), false)
   order by 1
$$;

comment on function kiem_khung_nhin_thieu_quyen() is
  'CỔNG GÁC RIÊNG TƯ. Trả về tên mọi khung nhìn trong schema public còn chạy '
  'bằng quyền NGƯỜI TẠO — tức vượt mặt RLS, ai cầm khoá công khai cũng đọc '
  'được số của cả đội. Rỗng là đúng luật. Mọi file SQL sau này chỉ cần một '
  'dòng trong bộ tự kiểm: (select count(*) from kiem_khung_nhin_thieu_quyen()) '
  '= 0. ⚠️ Đọc tuỳ chọn rồi ÉP VỀ BOOLEAN, không so chuỗi với ''=on'': Postgres '
  'cất lại đúng chữ người ta gõ, nên `with (… = true)` và `set (… = on)` cùng '
  'bật một cờ mà cất thành hai chuỗi — bản so chuỗi kêu oan ai_dang_lam suốt từ '
  '03/09 tới 07/09. ⚠️ Vẫn mù với khung nhìn VẬT CHẤT (materialized view) — '
  'loại đó không bật được security_invoker; phải canh riêng.';

commit;


-- ═══ SỐ LIỆU THAM KHẢO — xem trước, không phải bảng đạt/chưa đạt ════════════
-- (Kết quả của khối này KHÔNG hiện ra: trình soạn SQL của Supabase chỉ bày kết
--  quả của câu lệnh CUỐI CÙNG. Muốn xem thì bôi đen riêng khối này rồi chạy.)
select
  case when la_quan_tri then 'quan-tri'
       when la_lead     then 'lead'
       else                  'member' end               as cap,
  count(*)                                              as so_nguoi,
  string_agg(ten, ', ' order by ten)                    as ai
from nguoi
group by 1
order by 1;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
select so, muc, ket_qua from (values

  (1, 'hàm cap_dang_nhap() có mặt và trả về text',
      coalesce((select case when pg_catalog.pg_get_function_result(p.oid) = 'text'
                            then '✅ có, trả text'
                            else '❌ có nhưng trả ' || pg_catalog.pg_get_function_result(p.oid) end
                  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'public' and p.proname = 'cap_dang_nhap'),
               '❌ chưa có hàm')),

  (2, 'hàm la_member() có mặt và trả về boolean',
      coalesce((select case when pg_catalog.pg_get_function_result(p.oid) = 'boolean'
                            then '✅ có, trả boolean'
                            else '❌ có nhưng trả ' || pg_catalog.pg_get_function_result(p.oid) end
                  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'public' and p.proname = 'la_member'),
               '❌ chưa có hàm')),

  /* Dò theo VỊ TRÍ hai TÊN CỘT trong thân hàm — hai thứ Postgres trả lại y
     nguyên. Không dò cả mệnh đề `case when …`: nó bị phân tích rồi in lại, từ
     khoá viết HOA và ngoặc thêm vào, nên mọi mẫu chứa từ khoá đều ❌ oan. */
  (3, 'cap_dang_nhap() hỏi la_quan_tri TRƯỚC la_lead',
      coalesce((select case
                  when strpos(d, 'la_quan_tri') = 0 or strpos(d, 'la_lead') = 0
                       then '❌ thân hàm thiếu một trong hai cờ'
                  when strpos(d, 'la_quan_tri') < strpos(d, 'la_lead')
                       then '✅ đúng thứ tự'
                  else '❌ NGƯỢC — quản trị sẽ đọc ra Lead' end
                  from (select pg_catalog.pg_get_functiondef(p.oid) as d
                          from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                         where n.nspname = 'public' and p.proname = 'cap_dang_nhap'
                         limit 1) q),
               '❌ chưa có hàm')),

  (4, 'la_member() ngả về phía chặt khi không biết người hỏi là ai',
      coalesce((select case when strpos(pg_catalog.pg_get_functiondef(p.oid), 'coalesce') > 0
                            then '✅ có coalesce bọc ngoài'
                            else '❌ thiếu coalesce — người lạ sẽ được đối xử như Lead' end
                  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname = 'public' and p.proname = 'la_member'),
               '❌ chưa có hàm')),

  /* Đây là mục nghiệm thu số 3 của cả loạt việc. Trước lượt vá này nó trả
     `ai_dang_lam` — một tiếng kêu oan, không phải một lỗ hổng. */
  (5, 'không khung nhìn nào chạy bằng quyền người tạo',
      coalesce((select case when count(*) = 0 then '✅ rỗng'
                            else '❌ còn ' || count(*) || ': '
                                 || string_agg(ten_view, ', ') end
                  from kiem_khung_nhin_thieu_quyen()),
               '❌ chưa chạy được')),

  /* Ba cấp phải đếm ra 2 · 5 · 6 (soi máy chủ 07/09). Lệch đi thì hoặc có người
     mới, hoặc một cờ vừa bị lật — cả hai đều đáng dừng lại nhìn trước khi siết
     policy dựa trên chúng. Con số này KHÔNG phải lỗi của tệp này. */
  (6, 'phân bố ba cấp vẫn là 2 quản trị · 5 lead · 6 member',
      coalesce((select case when q = '2/5/6' then '✅ ' || q else '⚠️ ' || q || ' — đã đổi, xem lại trước khi siết' end
                  from (select count(*) filter (where la_quan_tri)                 || '/' ||
                               count(*) filter (where la_lead and not la_quan_tri) || '/' ||
                               count(*) filter (where not la_lead and not la_quan_tri) as q
                          from nguoi) z),
               '❌ chưa chạy được')),

  /* Nhát ⓪ cố ý KHÔNG siết gì. Dòng này khẳng định điều đó bằng máy: nếu một
     policy nào đã gọi la_member() rồi thì tệp này không còn là nhát nền nữa,
     và người chạy nó đáng được biết. */
  (7, 'nhát ⓪ chưa siết policy nào (đúng như thiết kế)',
      coalesce((select case when count(*) = 0 then '✅ chưa policy nào gọi la_member()'
                            else 'ℹ️ ' || count(*) || ' policy đã gọi: '
                                 || string_agg(tablename || '.' || policyname, ', ') end
                  from pg_policies
                 where schemaname = 'public'
                   and coalesce(qual, '') || coalesce(with_check, '') like '%la_member%'),
               '❌ chưa chạy được'))

) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' then 2 else 1 end, so;
