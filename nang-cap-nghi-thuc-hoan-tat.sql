-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `nop_ngay.moi_mai`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: NGHI THỨC HOÀN THÀNH (11/08/2026)
-- Dán trọn file vào Supabase › SQL Editor › Run. Chạy lại nhiều lần vô hại.
--
-- App vẫn chạy được TRƯỚC khi file này chạy — chỉ riêng câu "mồi mai" sẽ nằm
-- tạm ở máy người gõ (localStorage) thay vì theo người sang thiết bị khác.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① Cột mồi mai: câu "sáng mai, việc đầu tiên là gì" gieo ở nghi thức tối,
--    hiện lại ở đầu màn Hôm nay sáng hôm sau. Khoa học: viết kế hoạch cho việc
--    dang dở là não buông được nó (Masicampo & Baumeister, "Consider It Done").
alter table nop_ngay add column if not exists moi_mai text;

-- ② Cho người chốt SỬA dòng chốt của CHÍNH MÌNH — để ghi mồi mai sau khi dòng
--    đã tạo. Ràng buộc chi_chot_hom_nay (ngay = hom_nay()) vẫn giữ nguyên nên
--    chỉ sửa được dòng của đúng hôm nay; dòng các ngày cũ không chạm được.
drop policy if exists sua_nop_cua_minh on nop_ngay;
create policy sua_nop_cua_minh on nop_ngay for update
  using (nguoi_id = nguoi_id_dang_nhap() and ngay = hom_nay())
  with check (nguoi_id = nguoi_id_dang_nhap() and ngay = hom_nay());

-- ── Tự kiểm: cả hai dòng dưới phải có kết quả ────────────────────────────────
select 'cot moi_mai co mat' as kiem, count(*) = 1 as dat
  from information_schema.columns
 where table_name = 'nop_ngay' and column_name = 'moi_mai'
union all
select 'policy sua_nop_cua_minh co mat', count(*) = 1
  from pg_policies
 where tablename = 'nop_ngay' and policyname = 'sua_nop_cua_minh';
