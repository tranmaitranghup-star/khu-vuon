-- ╔══════════════════════════════════════════════════════════════════════════╗
-- │ BẢNG TIN — gắn thêm LINK vào một tin (TRI-96, Tracy 04/09)               │
-- │ Dấu vết riêng trên máy chủ: cột `ban_tin.link`                           │
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- Chạy SAU `nang-cap-ban-tin.sql`. Một cột, không policy nào phải đổi: quyền
-- đọc và sửa đã tính theo DÒNG, không theo cột.
--
-- App rào `http`/`https` ở cả hai đầu — lúc ghi và lúc vẽ — nên không thêm
-- ràng buộc ở đây: một `check` sẽ chặn cả những dòng máy chủ khác ghi vào sau
-- này, mà chưa biết chúng cần gì.

alter table ban_tin add column if not exists link text;

comment on column ban_tin.link is
  'Địa chỉ đính kèm một tin (biên bản mẫu, checklist, form…). App chỉ nhận http/https.';


-- ═══ TỰ KIỂM ══════════════════════════════════════════════════════════════
-- Phải ra ĐÚNG MỘT dòng: link | text
select column_name, data_type
  from information_schema.columns
 where table_name = 'ban_tin' and column_name = 'link';
