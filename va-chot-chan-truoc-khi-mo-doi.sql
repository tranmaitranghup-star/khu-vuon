-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bẫy `trg_kiem_phien_dung_chu`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- CHỐT CHẶN TRƯỚC KHI MỞ APP CHO 12 NGƯỜI
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy SAU `va-luong-cheo-nhau.sql`. Chạy lại nhiều lần không sao.
--
-- VÌ SAO CÓ FILE NÀY: khoá công khai (anon key) nằm ngay trong mã nguồn trang
-- web — ai mở app cũng đọc được. Nên hàng rào thật KHÔNG phải là giao diện
-- (app chỉ liệt kê luống của chính mình), mà là RLS + ràng buộc ở máy chủ.
-- Với 2 người thì lỗ hở không ai chạm tới; với 12 người thì phải bịt trước,
-- vì dọn dữ liệu chéo sau khi đã lẫn là việc rất khó gỡ.
--
-- ⛔ LỖ HỞ FILE NÀY BỊT — cùng họ với hai lỗi đã sửa 08/08:
--    `phien_deepwork` chỉ soi chủ của CHÍNH NÓ (`nguoi_id = tôi`), không soi
--    chủ của `task_id` / `nhip_id` mà nó trỏ tới. Gọi thẳng API là đổ được
--    giờ deepwork vào task của NGƯỜI KHÁC. Hậu quả lệch hẳn nhau:
--      · `vuon_cay` gom theo CHỦ TASK  → cây và 🍎 quả mọc trong vườn người bị đổ
--      · `cham_theo_ngay` gom theo CHỦ PHIÊN → 💧 giờ lại tính cho người đổ
--    Một hành động, hai người khác nhau được cộng điểm. Hai bảng vinh danh
--    lệch nhau mà không ai biết vì sao.
--    Bảng `so_ngay` đã làm đúng từ đầu (policy soi chủ của `nhip`) — chỗ này
--    chỉ là áp lại đúng cái khuôn đó.
-- ============================================================================


-- ─── 1. Phiên deepwork phải đổ vào việc CỦA CHÍNH MÌNH ──────────────────────
create or replace function kiem_phien_dung_chu()
returns trigger language plpgsql security definer set search_path = public
as $$
declare chu uuid;
begin
  if new.task_id is not null then
    select nguoi_id into chu from task where id = new.task_id;
    if chu is null or chu <> new.nguoi_id then
      raise exception 'Task % không phải việc của bạn — giờ deepwork chỉ đổ vào việc mình.', new.task_id;
    end if;
  end if;
  if new.nhip_id is not null then
    select nguoi_id into chu from nhip where id = new.nhip_id;
    if chu is null or chu <> new.nguoi_id then
      raise exception 'Nhịp % không phải nhịp của bạn.', new.nhip_id;
    end if;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_phien_dung_chu on phien_deepwork;
create trigger trg_kiem_phien_dung_chu before insert or update on phien_deepwork
  for each row execute function kiem_phien_dung_chu();


-- ─── 2. Luống chỉ được là 1, 2 hoặc 3 ───────────────────────────────────────
-- "Ba luống là hết đất" đang chỉ là luật của giao diện. Gọi thẳng API thì đặt
-- luong = 7 được, và chỉ mục một-hạt-một-luống vẫn cho qua vì nó chỉ soi cặp
-- (người, luống). Người đó tự cho mình thêm đất mà bảng nào cũng không lộ ra.
alter table tieu_diem drop constraint if exists luong_trong_khoang_1_3;
alter table tieu_diem add  constraint luong_trong_khoang_1_3
  check (luong is null or luong between 1 and 3);


-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy cùng lúc với phần trên, đọc cột ket_qua
-- Mọi dòng phải ✅. Có ❌ thì ĐỪNG mở app cho đội.
-- ═══════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  -- ① Hàng rào bật đủ trên mọi bảng
  (1, 'RLS bật trên cả 9 bảng',
   (select count(*) from pg_tables where schemaname = 'public'
      and tablename in ('nguoi','tieu_diem','danh_muc_nhip','nhip','so_ngay',
                        'nop_ngay','task','phien_deepwork','tieng_chuong')
      and rowsecurity) = 9),

  -- ② Luống: ba quyền ghi đều soi chủ, và KHÔNG còn policy mở cho cả đội
  (2, 'tieu_diem có đủ 3 policy ghi riêng (them/sua/xoa)',
   (select count(*) from pg_policies where tablename = 'tieu_diem'
      and policyname in ('them_tieudiem','sua_tieudiem','xoa_tieudiem')) = 3),
  (3, 'tieu_diem KHÔNG còn policy ghi_tieudiem mở cho cả đội',
   not exists (select 1 from pg_policies where tablename = 'tieu_diem'
                 and policyname = 'ghi_tieudiem')),

  -- ④⑤ Chỉ mục luống: đúng một cái, và nó phải soi theo người
  (4, 'Chỉ mục cũ mot_hat_moi_luong đã gỡ',
   not exists (select 1 from pg_class where relname = 'mot_hat_moi_luong')),
  (5, 'Chỉ mục mot_hat_song_moi_luong soi theo (nguoi_id, luong)',
   exists (select 1 from pg_indexes where tablename = 'tieu_diem'
             and indexname = 'mot_hat_song_moi_luong'
             and indexdef like '%nguoi_id%' and indexdef like '%luong%')),

  -- ⑥⑦ Hai chốt chặn chéo
  (6, 'Trigger chặn task mọc sang luống người khác',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_task_dung_luong'
             and not tgisinternal)),
  (7, 'Trigger chặn phiên deepwork đổ vào việc người khác',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_phien_dung_chu'
             and not tgisinternal)),

  -- ⑧ Ràng buộc ba luống
  (8, 'Ràng buộc luống chỉ nhận 1–3',
   exists (select 1 from pg_constraint where conname = 'luong_trong_khoang_1_3')),

  -- ⑨ Khung nhìn chạy bằng quyền người gọi, không vượt mặt RLS
  -- ⚠️ DÒNG NÀY ĐÃ CÓ BẢN THAY THẾ — `nang-cap-cong-gac-khung-nhin.sql`
  --    (17/08) quét CẢ SCHEMA nên tự phủ mọi khung nhìn sinh sau. Danh sách
  --    sáu tên dưới đây viết ngày dự án còn 6 view; nay có 14, tức tám cái
  --    không được dòng này soi. Giữ nguyên câu lệnh để file cũ vẫn chạy lại
  --    được, nhưng ĐỪNG dựa vào một mình nó: chạy file kia rồi hẵng mở app.
  (9, 'Cả 6 khung nhìn bật security_invoker (bản cũ — xem nhãn ngay trên)',
   (select count(*) from pg_class
      where relkind = 'v'
        and relname in ('vuon_cay','tien_do_o','cham_theo_ngay','gat_theo_ngay',
                        'ket_qua_ngay','diem_ngay')
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 6),

  -- ⑩⑪⑫ Dữ liệu hiện tại đã sạch chưa
  (10, 'Không có task nào nằm trong luống người khác',
   not exists (select 1 from task t join tieu_diem o on o.ma = t.tieu_diem_ma
                where t.nguoi_id <> o.nguoi_id)),
  (11, 'Không có phiên deepwork nào đổ vào việc người khác',
   not exists (select 1 from phien_deepwork p join task t on t.id = p.task_id
                where p.nguoi_id <> t.nguoi_id)),
  (12, 'Không có hạt nào vô chủ',
   not exists (select 1 from tieu_diem where nguoi_id is null)),

  -- ⑬ Không ai có quá ba luống sống
  (13, 'Không ai giữ quá 3 hạt sống',
   not exists (select nguoi_id from tieu_diem where not xong and luong is not null
                group by nguoi_id having count(*) > 3))
)
select thu_tu as "#", muc as "Kiểm tra",
       case when dat then '✅ đạt' else '❌ HỎNG — đừng mở app' end as ket_qua
  from kt order by thu_tu;


-- ── NẾU DÒNG ⑩ HOẶC ⑪ BÁO ❌, xem cụ thể dòng nào rồi hẵng dọn ─────────────
-- ⑩ Task nằm nhầm luống:
--    select t.id, nt.ten as chu_task, t.noi_dung, t.tieu_diem_ma, no.ten as chu_luong
--      from task t join tieu_diem o on o.ma = t.tieu_diem_ma
--      join nguoi nt on nt.id = t.nguoi_id join nguoi no on no.id = o.nguoi_id
--     where t.nguoi_id <> o.nguoi_id;
--    Dọn (task không mất, thành 🪴 việc phát sinh):
--    update task t set tieu_diem_ma = null from tieu_diem o
--     where o.ma = t.tieu_diem_ma and t.nguoi_id <> o.nguoi_id;
--
-- ⑪ Phiên đổ nhầm việc:
--    select p.id, np.ten as chu_phien, nt.ten as chu_task, t.noi_dung, p.bat_dau
--      from phien_deepwork p join task t on t.id = p.task_id
--      join nguoi np on np.id = p.nguoi_id join nguoi nt on nt.id = t.nguoi_id
--     where p.nguoi_id <> t.nguoi_id;
--    Chưa có cách dọn tự động — phải đọc từng dòng rồi quyết giờ đó của ai.
--    ⚠️ Dọn TRƯỚC khi chạy mục 1, vì sau đó mọi lần sửa dòng đó sẽ bị chặn.
