-- ═══════════════════════════════════════════════════════════════════════════
-- ĐỌC QUYỀN ĐANG CHẠY — chỉ ĐỌC, không sửa gì. An toàn tuyệt đối.
--
-- VÌ SAO CÓ TỆP NÀY. Một tệp `.sql` trong kho là ảnh chụp của một ngày, không
-- phải trạng thái hôm nay: `tien_do_o` có tám bản chồng nhau, `ghi_viec` có hai
-- bản mà bản cũ nay đã gãy. Dựng lại một policy bằng cách chép từ tệp cũ nhất
-- tìm thấy chính là nguyên nhân của CẢ HAI lỗ hổng TRI-140 (07/09). Nên trước
-- mỗi nhát siết, đọc bản đang chạy bằng tệp này.
--
-- CÁCH DÙNG: dán trọn, chạy, chép trọn kết quả về cho tác tử.
--
-- ⚠️ Cố ý KHÔNG trả thân hàm (`pg_get_functiondef`) — một hàm dài vài nghìn ký
-- tự, mười hàm là một bảng không ai chép nổi. Khối ② chỉ trả về mấy cờ "thân
-- hàm có nhắc tới cái này không", đủ để biết hàm nào phải mở ra xem.
--
-- ĐỌC BẢNG KẾT QUẢ THẾ NÀO — ba cột cuối đổi nghĩa theo `phan`:
--
--   phan │ ten là          │ chi_tiet_1        │ chi_tiet_2      │ chi_tiet_3
--   ─────┼─────────────────┼───────────────────┼─────────────────┼──────────────
--    ①   │ tên policy      │ việc (SELECT…)    │ điều kiện ĐỌC   │ điều kiện GHI
--    ②   │ tên hàm         │ kiểu trả về       │ chạm bảng nào   │ cờ đáng ngờ
--    ③   │ tên khung nhìn  │ chạy bằng quyền ai│ đứng trên bảng  │ reloptions thô
-- ═══════════════════════════════════════════════════════════════════════════

with bang_quan_tam(ten) as (
  values ('tieu_diem'::text), ('muc_tieu'), ('thanh_vien_du_an'), ('moc_du_an'),
         ('nhip'), ('viec_co_dinh'), ('so_ngay'), ('nguoi')
)

-- ─── ① POLICY ĐANG CHẠY TRÊN TÁM BẢNG SẮP BỊ CHẠM ──────────────────────────
select 1                            as phan,
       'policy'                     as loai,
       p.tablename::text            as tren,
       p.policyname::text           as ten,
       p.cmd::text                  as chi_tiet_1,
       coalesce(p.qual, '—')        as chi_tiet_2,
       coalesce(p.with_check, '—')  as chi_tiet_3
  from pg_policies p
 where p.schemaname = 'public'
   and p.tablename in (select ten from bang_quan_tam)

union all

-- ─── ② HÀM `security definer` CÓ NHẮC TÊN MỘT TRONG TÁM BẢNG ───────────────
-- RLS KHÔNG chặn hộ loại hàm này: nó chạy bằng quyền người định nghĩa. Policy
-- sạch mà hàm còn vế cũ thì cửa vẫn mở, chỉ là mở bằng đường khác — đúng lỗi
-- bắt được 07/09 ở `doi_gio_viec_theo_chuoi`. Cột `chi_tiet_3` cho biết hàm nào
-- đáng mở ra đọc; `⛔KHÔNG-TỰ-KIỂM-QUYỀN` nghĩa là thân hàm không nhắc tới bất
-- kỳ hàm tra quyền nào — thường là cò dữ liệu, nhưng phải liếc qua từng cái.
select 2,
       'hàm definer',
       'public',
       p.proname::text,
       pg_catalog.pg_get_function_result(p.oid),
       coalesce((select string_agg(b.ten, ' ' order by b.ten)
                   from bang_quan_tam b
                  where pg_catalog.pg_get_functiondef(p.oid) ~ ('\m' || b.ten || '\M')), '—'),
       coalesce(nullif(concat_ws(' ',
         case when pg_catalog.pg_get_functiondef(p.oid) ~ '\mla_lead\M'        then '⚠️la_lead'     end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ 'la_quan_tri'        then 'la_quan_tri'   end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ '\mla_member\M'      then 'la_member'     end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ 'cap_dang_nhap'      then 'cap_dang_nhap' end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ 'la_thanh_vien'      then 'la_thanh_vien' end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ 'nguoi_id_dang_nhap' then 'nguoi_id'      end,
         case when pg_catalog.pg_get_functiondef(p.oid) ~ 'email_dang_nhap'    then 'email'         end
       ), ''), '⛔KHÔNG-TỰ-KIỂM-QUYỀN')
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
 where n.nspname = 'public'
   and p.prosecdef
   and p.prokind = 'f'          -- chỉ hàm thường: `pg_get_functiondef` ném lỗi với hàm gộp
   and exists (select 1 from bang_quan_tam b
                where pg_catalog.pg_get_functiondef(p.oid) ~ ('\m' || b.ten || '\M'))

union all

-- ─── ③ KHUNG NHÌN ĐỨNG TRÊN TÁM BẢNG, VÀ CỜ QUYỀN CỦA CHÚNG ────────────────
-- Khung nhìn có `security_invoker` thì tự thừa hưởng policy của bảng gốc — siết
-- bảng là siết luôn nó, không phải dựng lại nó (mà `drop view` còn làm rơi cờ
-- trong im lặng). Thiếu cờ thì ngược lại: nó chạy bằng quyền người tạo và lách
-- qua mọi policy vừa siết.
--
-- ⚠️ Đọc cờ bằng cách ÉP VỀ BOOLEAN, không so chuỗi với '=on': Postgres cất lại
-- đúng chữ người ta gõ, nên `with (… = true)` và `set (… = on)` cùng bật một cờ
-- mà cất thành hai chuỗi khác nhau. Bản so chuỗi của `kiem_khung_nhin_thieu_quyen()`
-- kêu oan `ai_dang_lam` suốt từ 03/09 tới 07/09 vì đúng chuyện này.
select 3,
       'khung nhìn',
       'public',
       c.relname::text,
       case when coalesce((select split_part(opt, '=', 2)::boolean
                             from unnest(coalesce(c.reloptions, '{}'::text[])) as opt
                            where split_part(opt, '=', 1) = 'security_invoker'
                            limit 1), false)
            then '✅ quyền NGƯỜI HỎI'
            else '⛔ quyền NGƯỜI TẠO — lách RLS' end,
       coalesce((select string_agg(distinct b.ten, ' ')
                   from bang_quan_tam b
                  where pg_catalog.pg_get_viewdef(c.oid) ~ ('\m' || b.ten || '\M')), '—'),
       array_to_string(coalesce(c.reloptions, '{}'::text[]), ' ')
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
 where c.relkind = 'v'
   and n.nspname = 'public'
   and exists (select 1 from bang_quan_tam b
                where pg_catalog.pg_get_viewdef(c.oid) ~ ('\m' || b.ten || '\M'))

order by 1, 3, 4;
