-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `kiem_khung_nhin_thieu_quyen`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- CỔNG GÁC KHUNG NHÌN: mọi view phải chạy bằng quyền NGƯỜI GỌI
--                                                     (Tracy chốt 2026-08-17)
--
-- VÌ SAO PHẢI CÓ FILE NÀY. Luật "mọi khung nhìn bật `security_invoker = on`"
-- là hàng rào riêng tư chính của app: thiếu cờ ấy thì khung nhìn chạy bằng
-- quyền NGƯỜI TẠO, vượt mặt toàn bộ RLS, và ai cầm khoá công khai — khoá nằm
-- ngay trong mã nguồn trang web — cũng đọc được số của cả 12 người. Luật được
-- viết thành chữ ở `nang-cap-danh-muc-viec-co-dinh.sql:340` và nhắc 47 lần
-- trong các file SQL.
--
-- Nhưng CỔNG GÁC soi nó thì có lỗ. Bộ tự kiểm ⑨ ở
-- `va-chot-chan-truoc-khi-mo-doi.sql:103` viết CỨNG danh sách sáu tên view và
-- cứng luôn con số 6. Đếm ngày 17/08: dự án có 14 khung nhìn.
--   · 6  cái được ⑨ soi:  vuon_cay · tien_do_o · cham_theo_ngay ·
--                         gat_theo_ngay · ket_qua_ngay · diem_ngay
--   · 8  cái sinh sau, KHÔNG cổng gác nào soi:
--                         gio_deepwork_theo_ngay · gio_deepwork_theo_gio ·
--                         nhip_thoi_gian · viec_con_no · dem_task_theo_o ·
--                         dem_cam_ket_da_dong · tien_do_muc_tieu ·
--                         viec_co_dinh_da_dung
-- Và mọi khung nhìn viết trong tương lai cũng sẽ lọt y hệt, vì một danh sách
-- đóng thì không tự dài ra.
--
-- ⚠️ HÔM NAY CHƯA RÒ RỈ. Rà 33 file SQL ngày 17/08: cả 14 view đều có dòng
-- `alter view … set (security_invoker = on)` ở đâu đó. Thứ hỏng là cái CỔNG
-- GÁC, không phải cái hàng rào. Nên đây là chốt chặn cho lần sau: `create or
-- replace view` giữ được cờ cũ, nhưng `drop view` rồi tạo lại thì MẤT cờ, mà
-- mất trong im lặng — không lỗi nào báo, app vẫn chạy, chỉ là mọi người đọc
-- được số của nhau. Trong dự án này đã có bốn file phải `drop` rồi tạo lại
-- (đổi bộ cột thì `replace` không cho), nên chuyện đó không hiếm.
--
-- CÁCH CHỮA. Đổi từ DANH SÁCH ĐÓNG sang CÂU HỎI MỞ: quét cả schema `public`,
-- đếm số view còn thiếu cờ, phải bằng 0. Câu ấy tự phủ mọi view sinh sau mà
-- không ai phải nhớ sửa file này.
--
-- CHẠY: Supabase → SQL Editor → New query → dán trọn file → Run.
--       Chạy lại nhiều lần vô hại. Chạy xong đọc bảng cuối: bốn dòng phải ✅.
--
-- ⚠️ FILE NÀY CÓ GHI VÀO MÁY CHỦ. Mục 2 tự đặt lại cờ cho khung nhìn nào còn
-- thiếu. Đọc danh sách nó in ra (tab Results → Messages) rồi hẵng đi tiếp.
--
-- ⛔ KHÔNG đụng `alter table … force row level security` ở đây. Đó là chuyện
-- khác — nó làm chủ bảng cũng bị policy soi, chạm mọi thao tác bảo trì chạy
-- bằng role `postgres` kể cả sửa tay trong Table Editor — nên phải thử ở nhánh
-- riêng và nghiệm thu riêng, không đi ké một file cổng gác.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Hàm cổng gác — kể TÊN khung nhìn còn chạy bằng quyền người tạo ──────
-- Đặt thành HÀM chứ không phải một câu lệnh rời, để ba việc cùng được một chỗ:
--   · bộ tự kiểm của MỌI file SQL sau này gọi lại bằng đúng một dòng,
--   · có chỗ `comment on` ghi luật vào chính máy chủ, phiên sau tra được,
--   · mục 2 dưới đây dùng lại nó, nên chỉ có MỘT định nghĩa "thế nào là thiếu".
--
-- `security invoker` (mặc định của hàm Postgres) — cổng gác mà chạy bằng quyền
-- người tạo thì chính nó là thứ đầu tiên phạm luật nó canh.
-- `set search_path` cố định để không ai lừa được nó bằng một schema dựng sẵn.
create or replace function kiem_khung_nhin_thieu_quyen()
returns table (ten_view text)
language sql
stable
security invoker
set search_path = public, pg_catalog
as $$
  select c.relname::text
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where c.relkind = 'v'                    -- 'v' = khung nhìn thường
     and n.nspname = 'public'               -- PostgREST chỉ mở schema này ra ngoài
     and not ('security_invoker=on' = any(coalesce(c.reloptions, '{}')))
   order by 1
$$;

comment on function kiem_khung_nhin_thieu_quyen() is
  'CỔNG GÁC RIÊNG TƯ. Trả về tên mọi khung nhìn trong schema public còn chạy '
  'bằng quyền NGƯỜI TẠO — tức vượt mặt RLS, ai cầm khoá công khai cũng đọc '
  'được số của cả đội. Rỗng là đúng luật. Mọi file SQL sau này chỉ cần một '
  'dòng trong bộ tự kiểm: (select count(*) from kiem_khung_nhin_thieu_quyen()) '
  '= 0. Thay cho bộ tự kiểm ⑨ của va-chot-chan-truoc-khi-mo-doi.sql, vốn viết '
  'cứng 6 tên view nên bỏ sót 8 view sinh sau. ⚠️ Mù với khung nhìn VẬT CHẤT '
  '(materialized view) — loại đó không bật được security_invoker; dòng ③ của '
  'bộ tự kiểm canh riêng chuyện ấy.';

-- Cổng gác không phơi ra ngoài. Hàm nằm trong `public` thì PostgREST tự mở một
-- đường `/rest/v1/rpc/...` cho khoá công khai gọi — không cần thiết, và tên các
-- khung nhìn đang hở là thứ càng ít người biết càng tốt.
revoke execute on function kiem_khung_nhin_thieu_quyen() from public;
do $$
begin
  if to_regrole('anon')          is not null then revoke execute on function kiem_khung_nhin_thieu_quyen() from anon;          end if;
  if to_regrole('authenticated') is not null then revoke execute on function kiem_khung_nhin_thieu_quyen() from authenticated; end if;
end $$;


-- ─── 2. Đặt lại cờ cho mọi khung nhìn còn thiếu ─────────────────────────────
-- Luật nhà không có ngoại lệ nào: 14/14 view đều phải bật. Nên chỗ này không
-- quyết thay ai — nó chỉ áp lại đúng cái luật đã có thành chữ.
--
-- Mỗi view một `begin … exception` riêng: nếu có cái nào không đặt được (chủ sở
-- hữu khác chẳng hạn) thì chỉ cái đó bỏ qua, file vẫn chạy trọn tới bảng tự
-- kiểm — và cái bỏ qua ấy sẽ bị dòng ① kêu tên. Không bắt lỗi thì cả file dừng
-- giữa chừng, mà đúng lúc ta cần đọc bảng cuối nhất.
do $$
declare
  v  record;
  n  int := 0;
  bo int := 0;
begin
  for v in select ten_view from kiem_khung_nhin_thieu_quyen() loop
    begin
      execute format('alter view public.%I set (security_invoker = on)', v.ten_view);
      n := n + 1;
      raise notice '↻ Đã đặt lại security_invoker cho khung nhìn "%"', v.ten_view;
    exception when others then
      bo := bo + 1;
      raise notice '⚠ KHÔNG đặt được cho "%": % — dòng ① của bảng cuối sẽ kêu tên nó', v.ten_view, sqlerrm;
    end;
  end loop;

  if n = 0 and bo = 0 then
    raise notice '✓ Không khung nhìn nào thiếu cờ — máy chủ không đổi gì.';
  else
    raise notice '↻ Tổng: % khung nhìn vừa đặt lại, % cái không đặt được.', n, bo;
  end if;
end $$;


-- ═══════════════════════════════════════════════════════════════════════════
-- TỰ KIỂM — bốn dòng phải ✅ hết. Có ❌ thì ĐỪNG mở app cho đội.
--
-- Dòng ① là cổng gác thật. Ba dòng còn lại canh chính cổng gác, vì một câu
-- `count(*) = 0` có một kiểu hỏng rất êm: lọc sai thì nó soi 0 khung nhìn và
-- vẫn báo ✅ suốt đời.
--   ② sàn số lượng — khác hẳn danh sách cứng của ⑨ cũ: danh sách cứng thì BỎ
--     SÓT cái mới trong im lặng, sàn thì cùng lắm kêu nhầm khi ta cố ý bỏ một
--     khung nhìn. Kêu nhầm thì sửa được, bỏ sót thì không biết mà sửa.
--   ③ điểm mù đã biết: khung nhìn VẬT CHẤT không bật được security_invoker và
--     RLS không áp lên nó. Hôm nay dự án không có cái nào — dòng này canh để
--     không ai lặng lẽ thêm vào.
--   ④ cổng gác còn đó và không mở ra cho khoá công khai.
-- ═══════════════════════════════════════════════════════════════════════════
with view_thuong as (
  select c.relname::text as ten,
         not ('security_invoker=on' = any(coalesce(c.reloptions, '{}'))) as thieu
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where c.relkind = 'v' and n.nspname = 'public'
),
view_vat_chat as (
  select c.relname::text as ten
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where c.relkind = 'm' and n.nspname = 'public'
)
select 1 as "#",
       'Không khung nhìn nào chạy bằng quyền NGƯỜI TẠO'::text as "Kiểm tra",
       case when (select count(*) from view_thuong where thieu) = 0
            then '✅ đạt — ' || (select count(*) from view_thuong)::text
                 || ' khung nhìn, tất cả đúng luật'
            else '❌ HỎNG — vượt mặt RLS: '
                 || (select string_agg(ten, ' · ' order by ten) from view_thuong where thieu)
       end::text as "Kết quả"

union all
select 2,
       'Cổng gác thật sự soi được (≥ 14 khung nhìn, đếm ngày 17/08)',
       case when (select count(*) from view_thuong) >= 14
            then '✅ đạt — đang soi ' || (select count(*) from view_thuong)::text
            else '❌ HỎNG — chỉ soi được ' || (select count(*) from view_thuong)::text
                 || '. Hoặc câu lọc sai, hoặc có khung nhìn đã bị bỏ. '
                 || 'Nếu bỏ có chủ ý thì hạ con số này VÀ ghi lý do ngay dòng dưới.'
       end

union all
select 3,
       'Không có khung nhìn VẬT CHẤT trong public (cơ chế này mù với nó)',
       case when (select count(*) from view_vat_chat) = 0
            then '✅ đạt'
            else '❌ HỎNG — '
                 || (select string_agg(ten, ' · ' order by ten) from view_vat_chat)
                 || ' — loại này không bật được security_invoker và RLS không áp lên nó. '
                 || 'Đổi sang khung nhìn thường, hoặc dựng hàng rào riêng cho nó.'
       end

union all
select 4,
       'Hàm cổng gác có mặt và khoá công khai không gọi được',
       case when exists (select 1 from pg_proc p
                           join pg_namespace n on n.oid = p.pronamespace
                          where p.proname = 'kiem_khung_nhin_thieu_quyen'
                            and n.nspname = 'public')
                 and (to_regrole('anon') is null
                      or not has_function_privilege('anon',
                            'public.kiem_khung_nhin_thieu_quyen()', 'execute'))
            then '✅ đạt'
            else '❌ HỎNG — hàm vắng mặt, hoặc anon vẫn gọi được qua /rest/v1/rpc'
       end

order by 1;


-- ── DÙNG LẠI CỔNG GÁC NÀY Ở FILE SQL SAU ───────────────────────────────────
-- Mỗi file `nang-cap-*.sql` có dựng lại khung nhìn nào, thêm đúng một dòng này
-- vào bộ tự kiểm của nó — không phải kể tên view nữa:
--
--    (n, 'Mọi khung nhìn vẫn chạy bằng quyền người gọi',
--     (select count(*) from kiem_khung_nhin_thieu_quyen()) = 0),
--
-- Và vẫn giữ thói quen cũ: `drop view` rồi tạo lại thì đặt `alter view … set
-- (security_invoker = on)` ngay dưới câu `create`. Cổng gác là lưới hứng, không
-- phải chỗ dựa để quên.
--
-- ── SOI TRẠNG THÁI TỪNG KHUNG NHÌN (chạy riêng khi cần) ────────────────────
--    select c.relname as khung_nhin,
--           case when 'security_invoker=on' = any(coalesce(c.reloptions,'{}'))
--                then '✅ quyền người gọi' else '❌ quyền người tạo' end as chay_bang
--      from pg_class c join pg_namespace n on n.oid = c.relnamespace
--     where c.relkind = 'v' and n.nspname = 'public'
--     order by 2 desc, 1;
