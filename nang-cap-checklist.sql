-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `muc_viec`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- CHECKLIST TRONG VIỆC CỐ ĐỊNH — hai bảng mới + tự mang sang tuần sau
-- Tracy chốt 2026-08-10 (phương án A).
--
-- VIỆC NÀY GIẢI CÁI GÌ: đến nay một việc cố định chỉ có tên, mục tiêu và một ô
-- số. Người mới vào ghế không biết "check tình thức ROVA" gồm những bước nào,
-- và người làm lâu vẫn bỏ sót bước phụ. Nay mỗi việc cố định mang theo được
-- QUY TRÌNH của nó: 5–9 bước then chốt, tick từng bước trong ngày.
-- Nền: The Checklist Manifesto — checklist tốt là 5–9 mục then chốt gói trong
-- một trang, chỉ ghi bước dễ bỏ sót chứ không chép lại toàn bộ công việc.
--
-- BA QUYẾT ĐỊNH VỀ NGỮ NGHĨA, ghi ra để đời sau khỏi đoán:
--   ① HAI BẢNG, KHÔNG PHẢI MỘT. `muc_viec` giữ các BƯỚC — thứ sống lâu, sửa
--      thưa. `tick_muc` giữ cái TICK — thứ xoá sạch mỗi sáng. Gộp một bảng
--      thì mỗi sáng phải ghi đè lên chính dữ liệu gốc, và chỉ cần một lần lỗi
--      là mất luôn quy trình. Tách ra thì tick chỉ là dòng thêm vào, không
--      dòng nào phải xoá.
--   ② TICK GẮN VỚI NGÀY, không phải với tuần hay với phiên. Một dòng trong
--      `tick_muc` nghĩa là "bước này đã làm trong ngày đó" — nên sang ngày mới
--      checklist tự trắng ra mà không cần cron dọn, và lịch sử từng ngày còn
--      nguyên để về sau soi xem bước nào hay bị bỏ.
--   ③ SANG TUẦN MỚI TỰ MANG THEO. Bảng `nhip` cấp một dòng MỚI cho mỗi tuần,
--      nên nếu checklist chỉ bám vào dòng đó thì cứ mỗi thứ Hai là quy trình
--      biến mất. Trigger bên dưới bám theo TÊN việc: dòng mới sinh ra mà cùng
--      người, cùng tên với một việc cũ thì chép luôn bộ bước của việc đó.
--
-- CHẠY: dán trọn file này vào Supabase → SQL Editor → Run. Chạy lại nhiều lần
-- vô hại. Chạy xong nhìn bảng cuối: cột `dat` phải ĐÚNG cả sáu dòng.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. BẢNG muc_viec — các BƯỚC của một việc cố định ──────────────────────
create table if not exists muc_viec (
  id       bigint generated always as identity primary key,
  nhip_id  bigint not null references nhip (id) on delete cascade,
  noi_dung text not null check (length(trim(noi_dung)) > 0),
  thu_tu   smallint not null default 1,
  tao_luc  timestamptz not null default now()
);
create index if not exists muc_viec_theo_nhip on muc_viec (nhip_id, thu_tu);
comment on table muc_viec is
  'Các bước trong checklist của MỘT việc cố định (một dòng bảng nhip). Đây là phần sống lâu — sửa thưa, không xoá mỗi ngày. Tick nằm ở bảng tick_muc.';


-- ─── 2. BẢNG tick_muc — bước nào đã làm, trong ngày nào ────────────────────
-- Không có cột `xong` kiểu đúng/sai: CÓ DÒNG là đã tick, BỎ TICK là xoá dòng.
-- Cách này làm việc "sang ngày mới thì trắng ra" thành chuyện hiển nhiên chứ
-- không phải một việc phải nhớ làm.
create table if not exists tick_muc (
  id       bigint generated always as identity primary key,
  muc_id   bigint not null references muc_viec (id) on delete cascade,
  ngay     date not null default hom_nay(),
  tick_luc timestamptz not null default now(),
  unique (muc_id, ngay)
);
create index if not exists tick_muc_theo_ngay on tick_muc (ngay);
comment on table tick_muc is
  'Một dòng = một bước đã tick trong một ngày (giờ Việt Nam). Bỏ tick là xoá dòng. Sang ngày mới checklist tự trắng, không cần cron dọn.';


-- ─── 3. Phân quyền — đúng khuôn của schema.sql ─────────────────────────────
-- Đọc: mọi thành viên đọc được của nhau (như bảng nhip, so_ngay).
-- Ghi: chỉ chạm được bước và tick thuộc việc cố định CỦA CHÍNH MÌNH — kiểm
-- bằng cách lần ngược về nhip.nguoi_id, vì hai bảng này không giữ nguoi_id.
alter table muc_viec enable row level security;
alter table tick_muc enable row level security;

drop policy if exists doc_mucviec on muc_viec;
drop policy if exists ghi_mucviec on muc_viec;
drop policy if exists doc_tickmuc on tick_muc;
drop policy if exists ghi_tickmuc on tick_muc;

create policy doc_mucviec on muc_viec for select using (la_thanh_vien());
create policy ghi_mucviec on muc_viec for all
  using       (exists (select 1 from nhip n where n.id = nhip_id and n.nguoi_id = nguoi_id_dang_nhap()))
  with check  (exists (select 1 from nhip n where n.id = nhip_id and n.nguoi_id = nguoi_id_dang_nhap()));

create policy doc_tickmuc on tick_muc for select using (la_thanh_vien());
create policy ghi_tickmuc on tick_muc for all
  using      (exists (select 1 from muc_viec m join nhip n on n.id = m.nhip_id
                      where m.id = muc_id and n.nguoi_id = nguoi_id_dang_nhap()))
  with check (exists (select 1 from muc_viec m join nhip n on n.id = m.nhip_id
                      where m.id = muc_id and n.nguoi_id = nguoi_id_dang_nhap()));


-- ─── 4. Chặn khai lùi tick ─────────────────────────────────────────────────
-- Cùng tinh thần với `chi_chot_hom_nay` của bảng nop_ngay: tick là lời khai
-- "tôi vừa làm bước này", nên chỉ khai được cho ĐÚNG hôm nay. Không có ràng
-- buộc này thì tối thứ Bảy ngồi tick bù cả tuần, và mọi con số dựng trên nó
-- thành vô nghĩa.
alter table tick_muc drop constraint if exists chi_tick_hom_nay;
alter table tick_muc add  constraint chi_tick_hom_nay check (ngay = hom_nay());


-- ─── 5. SANG TUẦN MỚI TỰ MANG THEO ─────────────────────────────────────────
-- Bảng `nhip` cấp một dòng mới mỗi tuần. Không có trigger này thì mỗi thứ Hai
-- quy trình biến mất và người dùng phải gõ lại từ đầu — đúng cái bệnh mà nút
-- "Chép việc của tuần trước" đã sinh ra để chữa cho phần tên và mục tiêu.
--
-- Khớp theo TÊN đã chuẩn hoá (bỏ khoảng trắng thừa, không phân biệt hoa
-- thường), trong phạm vi CÙNG MỘT NGƯỜI. Lấy dòng cũ GẦN NHẤT có bước — dòng
-- gần nhất mới là bản quy trình mới nhất; dòng cũ hơn có thể đã lỗi thời.
--
-- `security definer` vì trigger phải đọc dòng nhip của tuần trước rồi ghi vào
-- muc_viec trong cùng một câu lệnh insert; để chạy bằng quyền người gọi thì
-- thứ tự kiểm tra RLS trong trigger là chỗ dễ vỡ về sau. Phạm vi vẫn khoá
-- chặt: chỉ chép trong phạm vi `new.nguoi_id`, không đọc sang người khác.
create or replace function chep_checklist_tuan_truoc()
returns trigger language plpgsql security definer set search_path = public
as $$
declare nguon bigint;
begin
  select n.id into nguon
    from nhip n
   where n.nguoi_id = new.nguoi_id
     and n.id      <> new.id
     and lower(btrim(n.ten)) = lower(btrim(new.ten))
     and exists (select 1 from muc_viec m where m.nhip_id = n.id)
   order by n.tuan_bat_dau desc
   limit 1;

  if nguon is not null then
    insert into muc_viec (nhip_id, noi_dung, thu_tu)
    select new.id, m.noi_dung, m.thu_tu
      from muc_viec m
     where m.nhip_id = nguon
     order by m.thu_tu, m.id;
  end if;

  return new;
end $$;

drop trigger if exists nhip_chep_checklist on nhip;
create trigger nhip_chep_checklist
  after insert on nhip
  for each row execute function chep_checklist_tuan_truoc();

comment on function chep_checklist_tuan_truoc() is
  'Dòng nhip mới sinh ra mà trùng tên với một việc cũ của cùng người thì chép luôn bộ bước checklist của việc đó. Nhờ vậy quy trình sống qua các tuần, dù người dùng bấm nút chép hay gõ lại tên bằng tay.';


-- ─── 6. Đổi tên việc thì bộ bước ĐI THEO ───────────────────────────────────
-- Không cần làm gì: bước bám vào `nhip.id`, không bám vào tên. Trigger trên
-- chỉ chạy lúc INSERT nên đổi tên không đẻ thêm bản sao. Ghi ra đây vì đọc
-- mục 5 xong rất dễ tưởng ngược lại.


-- ═══ TỰ KIỂM — sáu dòng, cột `dat` phải đúng hết ═══════════════════════════
with kiem as (
  select 'muc_viec có mặt' as muc,
         (select count(*) from information_schema.tables
           where table_schema='public' and table_name='muc_viec') = 1 as dat
  union all
  select 'tick_muc có mặt',
         (select count(*) from information_schema.tables
           where table_schema='public' and table_name='tick_muc') = 1
  union all
  select 'cả hai bảng đã bật phân quyền dòng',
         (select count(*) from pg_tables
           where schemaname='public' and tablename in ('muc_viec','tick_muc')
             and rowsecurity) = 2
  union all
  select 'đủ 4 luật phân quyền',
         (select count(*) from pg_policies
           where schemaname='public' and tablename in ('muc_viec','tick_muc')) = 4
  union all
  select 'tick chỉ khai được cho hôm nay',
         (select count(*) from pg_constraint
           where conname='chi_tick_hom_nay') = 1
  union all
  select 'trigger chép sang tuần mới đã gắn',
         (select count(*) from pg_trigger
           where tgname='nhip_chep_checklist' and not tgisinternal) = 1
)
select muc, dat from kiem;
