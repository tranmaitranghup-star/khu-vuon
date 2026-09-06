-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `doc_cam_ket`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — VÁ LỖ RIÊNG TƯ CỦA BẢN DOC GHI CHÚ
--                                              (Tracy duyệt 15/08/2026: "làm luôn")
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            CHẠY SAU: `nang-cap-ghi-chu.sql` → `nang-cap-doc-ghi-chu.sql`
--                      → `nang-cap-chot-chan-phien.sql`.
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (Làn M).
--
-- ─── LỖ ─────────────────────────────────────────────────────────────────────
-- Ngày 14/08 bảng `ghi_chu` được siết thành CHỈ CHỦ ĐỌC:
--     create policy doc_ghichu on ghi_chu for select
--       using (nguoi_id = nguoi_id_dang_nhap());     -- nang-cap-chot-chan-phien.sql:104
-- comment tại chỗ ghi rõ *"hẹp hơn la_thanh_vien(): chỉ mình thấy"*.
--
-- Nhưng cùng ngày, `nang-cap-doc-ghi-chu.sql:47` thêm cột
--     tieu_diem.doc_ghi_chu text
-- chứa CHÍNH các mẩu trích ra từ `ghi_chu`, và tự khai ở dòng 40:
--     *"Không thêm policy nào: hai cột nằm trong bảng `tieu_diem`,
--       dùng lại nguyên bộ quyền đã có"*.
-- Mà quyền ĐỌC của `tieu_diem` là:
--     create policy doc_tieudiem on tieu_diem for select
--       using (la_thanh_vien());                     -- schema.sql:266
-- tức CẢ ĐỘI.
--
-- Người viết file sau không biết file trước vừa siết. Kết quả: ý nghĩ riêng của
-- một người, đã được khoá ở bảng gốc, nằm phơi ở bảng bên cạnh — muốn đọc chỉ
-- cần đổi tên bảng trong câu truy vấn.
--
-- ⚠️ RLS của Postgres là theo DÒNG, không theo CỘT. Không có cách nào giấu hai
--    cột ấy mà vẫn để cả đội đọc những cột khác của cùng một dòng. Nên lời giải
--    bắt buộc là TÁCH SANG BẢNG RIÊNG — không phải "thêm một policy nữa".
--
-- ─── LỜI GIẢI ───────────────────────────────────────────────────────────────
-- Một bảng `doc_cam_ket`, khoá chính là mã cam kết, policy CHỈ CHỦ — cùng khuôn
-- `ghi_chu` và `tieng_chuong`. Dữ liệu cũ chuyển sang, rồi bỏ hai cột ở
-- `tieu_diem` (để lại là lỗ vẫn mở).
--
-- Quyền suy ra bằng TRUY VẤN CON tra `tieu_diem.nguoi_id`, không chép cột chủ
-- sang bảng mới. Cột chép có thể cũ đi trong im lặng; truy vấn con tra khoá
-- chính thì không bao giờ cũ. Với một cờ riêng tư, "không thể sai" thắng
-- "chạy nhanh" — và ở đây phép tra là theo khoá chính, nên rẻ sẵn.
--
-- ⭐ KHÔNG ĐỔI HÀNH VI NÀO KHÁC. Vẫn một bản doc cho mỗi cam kết, vẫn trích một
--    lần rồi thôi, mẩu gốc vẫn không bị đụng tới. Đổi duy nhất một điều: từ nay
--    chỉ CHỦ của cam kết đọc được bản doc ấy.
--
-- ─── CỬA LÙI ────────────────────────────────────────────────────────────────
-- App đã có sẵn phòng thủ cho cả hai chiều lệch pha (`baoLoiDoc`): chạy file này
-- mà chưa đẩy HTML mới → bản doc báo "chưa có", app vẫn chạy đủ mọi thứ khác;
-- đẩy HTML mới mà chưa chạy file này → cũng vậy. Không có khoảnh khắc nào app
-- chết.
-- ============================================================================

begin;

-- ─── 1. BẢNG MỚI ────────────────────────────────────────────────────────────
-- Khoá chính là `tieu_diem_ma` chứ không phải id tự tăng: một cam kết có ĐÚNG
-- một bản doc, nên chính mã cam kết đã là danh tính. Không cần khoá thứ hai, và
-- nhờ vậy `upsert` từ app chỉ cần một cột xung đột.
create table if not exists doc_cam_ket (
  tieu_diem_ma text primary key references tieu_diem (ma) on delete cascade,
  doc_ghi_chu  text   not null default '',
  doc_da_gop   text[] not null default '{}',
  sua_luc      timestamptz not null default now()
);

comment on table doc_cam_ket is
  'Bản doc ghi chú của một cam kết — CHỈ CHỦ CAM KẾT ĐỌC ĐƯỢC. Tách khỏi bảng tieu_diem ngày 15/08 vì tieu_diem cho cả đội đọc, mà nội dung ở đây trích từ ghi_chu vốn đã khoá chỉ-chủ. RLS của Postgres theo dòng chứ không theo cột, nên tách bảng là cách duy nhất.';

comment on column doc_cam_ket.doc_ghi_chu is
  'Văn bản liền mạch, người dùng sửa và xoá tự do. Mẩu gốc ở ghi_chu / phien_deepwork / task KHÔNG bao giờ bị đụng tới.';

comment on column doc_cam_ket.doc_da_gop is
  'Khoá các mẩu ĐÃ trích vào doc, dạng loai:id (y:12 · cua:34 · viec:56). Đã có trong đây thì không trích lại — nhờ vậy xoá một dòng rồi mở lại không thấy nó mọc lại.';


-- ─── 2. CHUYỂN DỮ LIỆU CŨ SANG ──────────────────────────────────────────────
-- Chỉ chuyển dòng CÓ nội dung. Bọc trong `do` + kiểm cột còn tồn tại không, để
-- chạy lại lần thứ hai (lúc cột đã bị bỏ) không ném lỗi.
-- `on conflict do nothing`: chạy lại không đè lên bản người dùng đã sửa sau đó.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'tieu_diem'
                and column_name = 'doc_ghi_chu') then
    execute $q$
      insert into doc_cam_ket (tieu_diem_ma, doc_ghi_chu, doc_da_gop)
      select ma, doc_ghi_chu, doc_da_gop
        from tieu_diem
       where doc_ghi_chu <> '' or cardinality(doc_da_gop) > 0
      on conflict (tieu_diem_ma) do nothing
    $q$;
  end if;
end $$;


-- ─── 2b. DẤU GIỜ SỬA DO MÁY CHỦ ĐÓNG ────────────────────────────────────────
-- `default now()` chỉ bắn lúc THÊM dòng, không bắn lúc sửa — mà bản doc thì
-- sửa là chính. Đóng dấu ở máy chủ chứ không nhận giờ từ máy khách, cùng lý do
-- `phien_deepwork.bat_dau` do máy chủ đóng: đồng hồ máy người dùng lệch được.
create or replace function cham_sua_luc_doc()
returns trigger language plpgsql
as $$
begin
  new.sua_luc := now();
  return new;
end $$;

drop trigger if exists tg_cham_sua_luc_doc on doc_cam_ket;
create trigger tg_cham_sua_luc_doc before update on doc_cam_ket
  for each row execute function cham_sua_luc_doc();


-- ─── 3. PHÂN QUYỀN: CHỈ CHỦ CAM KẾT ─────────────────────────────────────────
-- Cùng khuôn `ghi_ghichu` (nang-cap-ghi-chu.sql:163) và `ghi_chuong`
-- (nang-cap-chuong-tinh-thuc.sql:53), khác ở chỗ chủ sở hữu nằm ở BẢNG CHA nên
-- phải tra sang — `tieu_diem.nguoi_id` là NOT NULL từ
-- `nang-cap-luong-rieng-tung-nguoi.sql:61`, nên phép tra luôn có câu trả lời.
alter table doc_cam_ket enable row level security;

drop policy if exists doc_doccamket on doc_cam_ket;
drop policy if exists ghi_doccamket on doc_cam_ket;

create policy doc_doccamket on doc_cam_ket for select
  using (exists (select 1 from tieu_diem t
                  where t.ma = doc_cam_ket.tieu_diem_ma
                    and t.nguoi_id = nguoi_id_dang_nhap()));

create policy ghi_doccamket on doc_cam_ket for all
  using      (exists (select 1 from tieu_diem t
                       where t.ma = doc_cam_ket.tieu_diem_ma
                         and t.nguoi_id = nguoi_id_dang_nhap()))
  with check (exists (select 1 from tieu_diem t
                       where t.ma = doc_cam_ket.tieu_diem_ma
                         and t.nguoi_id = nguoi_id_dang_nhap()));


-- ─── 4. BỎ HAI CỘT CŨ ───────────────────────────────────────────────────────
-- Đây mới là bước ĐÓNG lỗ. Bước 1–3 chỉ mở chỗ mới; để hai cột cũ nằm lại thì
-- dữ liệu vẫn phơi y như trước.
alter table tieu_diem drop column if exists doc_ghi_chu;
alter table tieu_diem drop column if exists doc_da_gop;

commit;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả bốn dòng ═════════════════════════════
select * from (values
  (1, 'bảng doc_cam_ket có mặt',
   (select count(*) from information_schema.tables
     where table_schema = 'public' and table_name = 'doc_cam_ket') = 1),

  (2, 'tieu_diem KHÔNG còn cột doc_ghi_chu / doc_da_gop',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'tieu_diem'
       and column_name in ('doc_ghi_chu','doc_da_gop')) = 0),

  (3, 'doc_cam_ket đã bật RLS',
   (select relrowsecurity from pg_class
     where oid = 'public.doc_cam_ket'::regclass)),

  (4, 'doc_cam_ket có đúng 2 policy, và KHÔNG policy nào dùng la_thanh_vien()',
   (select count(*) from pg_policies
     where schemaname = 'public' and tablename = 'doc_cam_ket') = 2
   and not exists (select 1 from pg_policies
                    where schemaname = 'public' and tablename = 'doc_cam_ket'
                      and (coalesce(qual,'') || coalesce(with_check,''))
                          like '%la_thanh_vien%'))
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from tieu_diem)                              as so_cam_ket,
  (select count(*) from doc_cam_ket)                            as so_ban_doc,
  (select count(*) from doc_cam_ket where doc_ghi_chu <> '')    as ban_doc_co_chu;
