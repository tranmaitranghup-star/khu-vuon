-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `ghi_chu`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- GHI CHÚ TRONG PHIÊN + DÒNG GHI CHÚ CỦA CAM KẾT — Tracy chốt 2026-08-14.
--
-- VIỆC NÀY GIẢI CÁI GÌ: đến nay ghi chú sống ở hai chỗ, cả hai đều chỉ mở ra
-- SAU khi việc đã xảy ra — `task.ghi_chu_chot` gõ ở form sửa hoặc cửa ra, còn
-- `phien_deepwork.ghi_chu` chỉ gõ được khi phiên đã kết thúc. Đang CHẠY phiên
-- mà loé lên một ý thì không có chỗ nào hứng: phải rời màn (mất mạch) hoặc
-- nhớ trong đầu tới cuối phiên (mất ý). Nay có bảng `ghi_chu` hứng từng mẩu
-- ngay trong phiên, và tab Cam kết gom cả ba nguồn về MỘT dòng đọc lại.
--
-- BA QUYẾT ĐỊNH VỀ NGỮ NGHĨA, ghi ra để đời sau khỏi đoán:
--   ① BẢNG RIÊNG, KHÔNG NỐI CHỮ VÀO CỘT CŨ. Một phiên bắt được nhiều ý rời
--      rạc; nhồi chung một ô text thì mẩu sau đè mẩu trước, và trộn lẫn với
--      dòng Output gõ ở cửa ra — hai thứ khác bản chất (ý nghĩ ≠ lời khai kết
--      quả). Mỗi mẩu một dòng thì sửa/xoá/dán thẻ từng mẩu được.
--   ② DÒNG TỔNG HỢP LÀ BẢN ĐỌC LIVE, KHÔNG CHÉP DỮ LIỆU. Tab Cam kết truy vấn
--      ba nguồn (ghi_chu · task.ghi_chu_chot · phien_deepwork.ghi_chu) ngay lúc
--      mở, không chép về một bảng thứ tư — nên không bao giờ có hai bản lệch
--      nhau. Sửa một mẩu là ghi thẳng về nguồn của mẩu đó.
--   ③ THẺ ĐỂ TRỐNG LÚC GHI, XẾP Ở MÀN ĐỌC. Cả tính năng sinh ra để KHÔNG rời
--      phiên; bắt chọn thẻ lúc ghi là đặt thêm một quyết định vào đúng cái giây
--      đang cố bảo vệ. `the = ''` nghĩa là "chưa xếp" — hợp lệ, không phải lỗi.
--      Mỗi mẩu MỘT thẻ. Bộ thẻ là CỦA TỪNG CAM KẾT (`tieu_diem.bo_the`).
--
-- CHẠY: dán trọn file này vào Supabase → SQL Editor → Run. Chạy lại nhiều lần
-- vô hại — kể cả trên máy chủ đã chạy các đợt sau 14/08: mục 4 tự bỏ qua khi
-- khung nhìn đã mang `bo_the`, nên không lùi bản `tien_do_o` mới hơn (bẫy phát
-- hiện 02/09 khi gỡ TRI-20). Chạy xong nhìn bảng cuối: cột `dat` phải ĐÚNG cả
-- tám dòng.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 0. LƯỚI AN TOÀN: các cột mà khung nhìn ở mục 4 cần ─────────────────────
-- Khung nhìn dưới kê tên cột của HAI đợt nâng cấp trước (output 11/08 · cờ dời
-- hạn 12/08). Máy chủ nào chưa chạy hai file ấy thì câu tạo khung nhìn vỡ ngay
-- dòng đầu. Khai lại đúng nguyên văn định nghĩa cũ, `if not exists` nên máy đã
-- chạy rồi thì các dòng này không làm gì. KHÔNG khai lại trigger của chúng —
-- việc đó vẫn thuộc file gốc; đây chỉ là lưới đỡ cho khung nhìn dựng được.
alter table tieu_diem add column if not exists output_chu   text;
alter table tieu_diem add column if not exists output_link  text;
alter table tieu_diem add column if not exists nop_luc      timestamptz;
alter table tieu_diem add column if not exists da_nhan_boi  uuid references nguoi (id);
alter table tieu_diem add column if not exists da_nhan_luc  timestamptz;
alter table tieu_diem add column if not exists han_goc        date;
alter table tieu_diem add column if not exists so_lan_doi_han int not null default 0;
alter table tieu_diem add column if not exists ngay_troi      int not null default 0;


-- ─── 1. BẢNG ghi_chu — mỗi ý bắt được là một dòng ───────────────────────────
create table if not exists ghi_chu (
  id           bigint generated always as identity primary key,
  nguoi_id     uuid not null references nguoi (id) on delete cascade,
  noi_dung     text not null check (length(trim(noi_dung)) > 0),
  -- '' = chưa xếp thẻ (quyết định ③). Giá trị là chữ tự do vì bộ thẻ mỗi cam
  -- kết mỗi khác — không check theo danh sách cứng nào.
  the          text not null default '',
  -- Ba dây neo, đều ĐƯỢC PHÉP trống:
  --   · phiên nhịp (việc cố định) không thuộc cam kết nào → tieu_diem_ma null
  --   · ghi lúc chưa vào phiên (màn chọn việc)            → phien_id null
  --   · task bị xoá thì ý vẫn còn giá trị                 → set null, không cascade
  tieu_diem_ma text references tieu_diem (ma) on delete set null,
  task_id      bigint references task (id) on delete set null,
  phien_id     bigint references phien_deepwork (id) on delete set null,
  tao_luc      timestamptz not null default now(),
  sua_luc      timestamptz
);
create index if not exists ghi_chu_theo_cam_ket on ghi_chu (tieu_diem_ma, tao_luc desc);
create index if not exists ghi_chu_theo_phien   on ghi_chu (phien_id) where phien_id is not null;
comment on table ghi_chu is
  'Mỗi dòng = một ý bắt được trong (hoặc quanh) một phiên deepwork. Khác task.ghi_chu_chot (lời khai ở cửa/form) và phien_deepwork.ghi_chu (lời khai cuối phiên) — đây là Ý NGHĨ, nhiều mẩu một phiên, dán thẻ được. the='''' nghĩa là chưa xếp.';


-- ─── 2. THẺ cho hai chỗ ghi chú CŨ ──────────────────────────────────────────
-- Dòng tổng hợp ở tab Cam kết bày cả ba nguồn cạnh nhau và cho dán thẻ MỌI mẩu.
-- Hai nguồn cũ chưa có chỗ chứa thẻ thì mẩu của chúng thành "chưa xếp" vĩnh
-- viễn — thẻ nằm cạnh chữ của nó, không nằm ở một bảng ánh xạ rời.
-- (Đây là thẻ của GHI CHÚ, không phải thẻ của task — dán thẻ cho chính công
-- việc là chuyện bản sau, Tracy chốt 14/08.)
alter table task            add column if not exists ghi_chu_the text not null default '';
alter table phien_deepwork  add column if not exists ghi_chu_the text not null default '';


-- ─── 3. BỘ THẺ của từng cam kết ─────────────────────────────────────────────
-- Ba giá trị, phân biệt rõ vì hai cái sau trông giống nhau mà nghĩa khác hẳn:
--   null  = CHƯA CHỌN — lần đầu mở dòng ghi chú app sẽ hỏi
--   ''    = ĐÃ CHỌN "không dùng thẻ" — đừng hỏi lại nữa
--   'Mindset|Skillset|Toolset' = các thẻ, nối bằng thanh đứng
alter table tieu_diem add column if not exists bo_the text;
comment on column tieu_diem.bo_the is
  'Bộ thẻ ghi chú của cam kết này, nối bằng |. null = chưa chọn (app hỏi lần đầu), chuỗi rỗng = đã chọn không dùng thẻ.';


-- ─── 4. KHUNG NHÌN tien_do_o MANG THEO bo_the ───────────────────────────────
-- App không đọc thẳng bảng `tieu_diem` — nó đọc khung nhìn này. Khung nhìn kê
-- từng tên cột, nên cột mới không tự chảy qua. Phải XOÁ rồi tạo lại chứ không
-- `create or replace` (lệnh đó chỉ cho thêm cột vào CUỐI, chèn giữa là 42P16 —
-- ở đây bo_the đứng cạnh nhóm cột gốc nên cứ drop cho lành).
-- Thân giữ NGUYÊN VĂN bản mới nhất ở `nang-cap-hien-co-va-sua-phien.sql`
-- (dòng 104–156, đã bỏ Blocked khỏi so_kho), chỉ thêm `o.bo_the` vào cả
-- `select` lẫn `group by`.
--
-- ⛔ CHỐT CHẶN (02/09, TRI-20): cả mục này CHỈ CHẠY KHI khung nhìn CHƯA có cột
-- `bo_the`. Sau 14/08 đã có ít nhất bốn tệp dựng lại `tien_do_o` với cột mới
-- hơn (mới nhất: `nang-cap-mang-du-an.sql` thêm `muc_tieu_id`, 25/08). Dán trọn
-- tệp này lên máy chủ ấy mà không có chốt chặn là ĐÈ bản mới bằng bản 14/08 —
-- mất `muc_tieu_id`, và không một câu lỗi nào báo. Có chốt chặn thì mục 5 và
-- bài tự kiểm bên dưới chạy lại thoải mái. Thân khung nhìn bên trong GIỮ NGUYÊN
-- VĂN bản 14/08, chỉ được bọc lại.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'tien_do_o'
                and column_name = 'bo_the') then
    raise notice 'tien_do_o đã mang bo_the — bỏ qua mục 4, giữ nguyên bản đang sống.';
    return;
  end if;

  execute 'drop view if exists tien_do_o';

  execute $q$
  create view tien_do_o as
  select
    o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
    o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,

    -- Bộ thẻ ghi chú (14/08) — app đọc để dựng chip lọc và chip xếp.
    o.bo_the,

    -- Năm cột output (11/08) — app đọc thẳng từ đây, không hỏi bảng thô lần nữa.
    o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,

    -- Ba cột cờ dời hạn (12/08, việc 53). Máy chủ ghi, app chỉ đọc.
    o.han_goc, o.so_lan_doi_han, o.ngay_troi,

    -- Ba cột cũ, giữ nguyên: đếm CÂY (task đã có phiên deepwork thật).
    count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
    count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
    coalesce(sum(c.phut), 0)                       as tong_phut,

    -- Hai cột đếm TASK, viết bằng truy vấn con vô hướng — KHÔNG thêm `left join`
    -- thứ hai vào `task`, vì nó sẽ nhân chéo với `vuon_cay` đang join sẵn ở dưới
    -- và làm ba cột cây phía trên phồng lên sai bét.
    (select count(*) from task t
       where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma)     as so_task,
    (select count(*) from task t
       where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
         and t.trang_thai = 'Done')                                 as so_xong,
    -- Ô "còn mở" khớp ĐÚNG nhóm Kho mà bảng cam kết vẽ — cố ý KHÔNG đếm
    -- `Blocked` (nó có nhóm 🚧 riêng luôn xổ; lý lẽ đầy đủ ở
    -- `nang-cap-hien-co-va-sua-phien.sql` mục 2).
    (select count(*) from task t
       where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
         and t.ngay is null
         and t.trang_thai in ('Confirm','Doing','Chua_xong'))
                                                                    as so_kho

  from tieu_diem o
  left join vuon_cay c on c.tieu_diem_ma = o.ma
  group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
           o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
           o.bo_the,
           o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
           o.han_goc, o.so_lan_doi_han, o.ngay_troi
  $q$;

  -- ⚠️ BẮT BUỘC, và đây là dòng dễ mất nhất cả file. `drop view` xoá luôn thiết
  -- lập này; quên bật lại thì khung nhìn chạy bằng quyền người TẠO nó, tức vượt
  -- mặt RLS — mà KHÔNG có lỗi nào báo ra. Bài tự kiểm ⑥ soi đúng chỗ này.
  execute 'alter view tien_do_o set (security_invoker = on)';

  execute $q$
  comment on view tien_do_o is
    'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY; so_task/so_xong đếm MỌI task; output_*/da_nhan_* là phần thu hoạch; han_goc/so_lan_doi_han/ngay_troi là cờ dời hạn; bo_the là bộ thẻ ghi chú (14/08).'
  $q$;
end $$;


-- ─── 5. Phân quyền bảng ghi_chu — CHỈ CHỦ ĐỌC, CHỈ CHỦ GHI ──────────────────
-- ⭐ ĐÂY LÀ NGUỒN LUẬT DUY NHẤT cho phân quyền bảng `ghi_chu` (gộp 02/09, TRI-20).
--
-- Trước 02/09 có HAI tệp cùng đặt luật đọc và ra lệnh trái nhau: tệp này để
-- cả đội đọc (`la_thanh_vien()`), còn `nang-cap-chot-chan-phien.sql` mục ④ siết
-- về chỉ chủ (`nguoi_id_dang_nhap()`). Kết quả trên máy chủ phụ thuộc thứ tự
-- chạy — chạy lại tệp này sau tệp kia là mở toang ghi chú riêng cho cả đội, và
-- không lỗi nào báo. Tracy chốt 02/09: *"Ghi chú của cá nhân thì chỉ cá nhân
-- đọc được"*. Nên luật gom về đây, cạnh chính bảng; tệp kia chỉ còn câu tự kiểm.
--
-- Đọc: chỉ chủ — ý nghĩ trong phiên là riêng tư; app luôn lọc theo chủ nhưng
--      devtools thì không. Cùng khuôn bảng `tieng_chuong` và `doc_cam_ket`.
--      Muốn cho người khác đọc thì đi đường CHIA SẺ có chủ ý (mốc 📓 Ghi chú
--      trên Linear: TRI-21 · TRI-27), không nới luật này.
-- Ghi: chỉ chạm được mẩu CỦA CHÍNH MÌNH.
alter table ghi_chu enable row level security;

drop policy if exists doc_ghichu on ghi_chu;
drop policy if exists ghi_ghichu on ghi_chu;

create policy doc_ghichu on ghi_chu for select
  using (nguoi_id = nguoi_id_dang_nhap());
create policy ghi_ghichu on ghi_chu for all
  using      (nguoi_id = nguoi_id_dang_nhap())
  with check (nguoi_id = nguoi_id_dang_nhap());


-- ═══ TỰ KIỂM — tám dòng, cột `dat` phải đúng hết ════════════════════════════
with kiem as (
  select 'bảng ghi_chu có mặt' as muc,
         (select count(*) from information_schema.tables
           where table_schema='public' and table_name='ghi_chu') = 1 as dat
  union all
  select 'ghi_chu đã bật phân quyền dòng',
         (select count(*) from pg_tables
           where schemaname='public' and tablename='ghi_chu' and rowsecurity) = 1
  union all
  select 'đủ 2 luật phân quyền cho ghi_chu',
         (select count(*) from pg_policies
           where schemaname='public' and tablename='ghi_chu') = 2
  union all
  -- Câu này là lý do TRI-20 tồn tại: đếm đủ 2 luật vẫn chưa nói luật ĐÚNG hay
  -- SAI. Soi thẳng thân luật: đọc phải theo chủ, và KHÔNG luật nào còn dính
  -- la_thanh_vien() — SAI là có tệp cũ vừa chạy đè lên.
  select 'ghi_chu chỉ chủ đọc — không luật nào dùng la_thanh_vien()',
         (select count(*) from pg_policies
           where schemaname='public' and tablename='ghi_chu'
             and policyname='doc_ghichu'
             and qual like '%nguoi_id_dang_nhap%') = 1
         and not exists (select 1 from pg_policies
           where schemaname='public' and tablename='ghi_chu'
             and (coalesce(qual,'') || coalesce(with_check,''))
                 like '%la_thanh_vien%')
  union all
  select 'task và phien_deepwork có cột ghi_chu_the',
         (select count(*) from information_schema.columns
           where table_schema='public' and column_name='ghi_chu_the'
             and table_name in ('task','phien_deepwork')) = 2
  union all
  select 'tieu_diem có cột bo_the',
         (select count(*) from information_schema.columns
           where table_schema='public' and table_name='tieu_diem'
             and column_name='bo_the') = 1
  union all
  select 'khung nhìn tien_do_o chạy bằng quyền người gọi',
         (select coalesce(
            (select 'security_invoker=on' = any (reloptions)
               from pg_class where relname = 'tien_do_o'), false))
  union all
  select 'khung nhìn tien_do_o mang cột bo_the',
         (select count(*) from information_schema.columns
           where table_schema='public' and table_name='tien_do_o'
             and column_name='bo_the') = 1
)
select muc, dat from kiem;
