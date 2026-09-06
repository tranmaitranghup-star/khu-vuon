-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `phien_deepwork.nghi_ms`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: CHỐT CHẶN PHIÊN Ở TẦNG MÁY CHỦ — 14/08/2026
-- Gói A của đợt rà code 14/08 (ra-soat-code-14-08.md), Tracy duyệt cùng ngày.
--
-- Bốn việc, chữa tận gốc họ bug hai máy mà bản vá client cùng ngày chỉ che
-- được phần ngọn:
--   ① Khép các phiên dang_chay trùng (dọn nền), rồi UNIQUE INDEX chặn vĩnh
--      viễn hai phiên dang_chay cùng một người — kể cả ca đua hai máy bấm ▶
--      trong cùng giây, kể cả client lạ gọi thẳng API.
--   ② Hai cột mới tam_dung_luc + nghi_ms: trạng thái ⏸ tạm dừng LÊN MÁY CHỦ.
--      Trước giờ nó chỉ sống trong localStorage một máy — máy kia nhìn phiên
--      đang-nghỉ-hợp-lệ thành phiên chạy-quá-dài rồi khép héo oan, hoặc nối
--      phiên mà không biết quãng nghỉ nên giờ nghỉ thành phút làm.
--   ③ Trigger kiem_cay_song nâng cấp: thêm TRẦN 180 phút (trước chỉ có sàn
--      4'45), thêm luật kết-thúc-sau-bắt-đầu, và bắn ở CẢ INSERT (trước chỉ
--      BEFORE UPDATE — insert thẳng qua API lách được mọi luật).
--   ④ (ĐÃ DỜI 02/09 — TRI-20) Luật đọc bảng ghi_chu nay đặt DUY NHẤT ở
--      `nang-cap-ghi-chu.sql` mục 5, cạnh chính bảng. Tệp này không đặt luật
--      nữa, chỉ giữ một câu tự kiểm rằng máy chủ đang ở đúng luật.
--
-- Chạy: Supabase → SQL Editor → New query → dán trọn file → Run.
-- App ĐÃ viết phòng thủ: chưa chạy file này thì app vẫn chạy như cũ
-- (⏸ rơi về localStorage); chạy xong là các chốt chặn tự có hiệu lực.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── ① DỌN PHIÊN dang_chay TRÙNG rồi dựng UNIQUE INDEX ──────────────────────
-- Mỗi người chỉ giữ lại phiên dang_chay MỚI nhất; các dòng cũ hơn khép thành
-- héo, ket_thuc kẹp ở trần 180 phút (cùng phép kẹp dwKhoiPhuc đang dùng —
-- phút của phiên héo không vào khung nhìn nào nên kẹp không làm sai số nào).
with xep as (
  select id,
         row_number() over (partition by nguoi_id order by bat_dau desc) as hang
  from phien_deepwork
  where ket_qua = 'dang_chay'
)
update phien_deepwork p
set ket_qua  = 'heo',
    ket_thuc = least(p.bat_dau + interval '180 minutes', now())
from xep
where p.id = xep.id and xep.hang > 1;

-- Từ đây máy chủ TỰ chặn dòng dang_chay thứ hai: insert đụng index là lỗi
-- 23505 — app bắt mã này và nối lại phiên sẵn có thay vì báo lỗi thô.
create unique index if not exists uq_phien_dang_chay
  on phien_deepwork (nguoi_id)
  where ket_qua = 'dang_chay';


-- ─── ② TRẠNG THÁI ⏸ TẠM DỪNG LÊN MÁY CHỦ ───────────────────────────────────
alter table phien_deepwork add column if not exists tam_dung_luc timestamptz;
alter table phien_deepwork add column if not exists nghi_ms bigint not null default 0;

comment on column phien_deepwork.tam_dung_luc is
  'Khác null = phiên ĐANG tạm dừng từ thời điểm này. App ghi lúc bấm ⏸, xoá lúc bấm ▶. Máy khác nối phiên đọc cột này để không khép héo oan một phiên đang nghỉ.';
comment on column phien_deepwork.nghi_ms is
  'Tổng mili-giây đã nghỉ (cộng dồn qua các lần ⏸). Phút làm thật = (ket_thuc − bat_dau) đã trừ sẵn quãng nghỉ ở client, cột này để máy nối phiên dựng lại đúng đồng hồ.';


-- ─── ③ TRIGGER: SÀN 5' + TRẦN 180' + BẮN CẢ INSERT ──────────────────────────
-- Luật thời gian chỉ soi khi bat_dau / ket_thuc / ket_qua THAY ĐỔI — sửa mỗi
-- ghi_chu của một dòng cũ (kể cả dòng lịch sử lỡ dài hơn trần) thì không bị
-- đá oan. Trần đặt 181' cho 60 giây du di mạng chậm, cùng tinh thần sàn 4'45.
create or replace function kiem_cay_song()
returns trigger language plpgsql
as $$
begin
  if tg_op = 'INSERT'
     or new.ket_qua  is distinct from old.ket_qua
     or new.ket_thuc is distinct from old.ket_thuc
     or new.bat_dau  is distinct from old.bat_dau then

    if new.ket_thuc is not null and new.ket_thuc < new.bat_dau then
      raise exception 'Giờ kết thúc đứng trước giờ bắt đầu.';
    end if;

    if new.ket_qua = 'song' then
      if new.ket_thuc is null
         or new.ket_thuc - new.bat_dau < interval '4 minutes 45 seconds' then
        raise exception 'Phiên dưới 5 phút không tính — bấm nhầm thì bỏ phiên.';
      end if;
      if new.ket_thuc - new.bat_dau > interval '181 minutes' then
        raise exception 'Phiên dài quá trần 180 phút — nắn số phút về đúng quãng làm thật.';
      end if;
    end if;
  end if;

  if tg_op = 'UPDATE' and new.bat_dau <> old.bat_dau then
    raise exception 'Không sửa được giờ bắt đầu';
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_cay_song on phien_deepwork;
create trigger trg_kiem_cay_song
  before insert or update on phien_deepwork
  for each row execute function kiem_cay_song();


-- ─── ④ RLS ghi_chu — ĐÃ DỜI SANG nang-cap-ghi-chu.sql MỤC 5 (02/09, TRI-20) ──
-- Bản 14/08 của mục này siết luật đọc từ la_thanh_vien() về nguoi_id_dang_nhap().
-- Nhưng `nang-cap-ghi-chu.sql` cũng đặt luật đọc cho cùng bảng, và đặt NGƯỢC
-- lại (cả đội đọc). Hai tệp cùng ra lệnh cho một bảng thì kết quả trên máy chủ
-- phụ thuộc tệp nào chạy SAU — chạy lại tệp kia là mở ghi chú riêng tư cho cả
-- đội, không một câu lỗi nào báo. Nay luật gom về một chỗ, cạnh chính bảng, và
-- tệp này KHÔNG đụng policy nào của ghi_chu nữa. Câu tự kiểm ④ bên dưới vẫn
-- giữ: nó soi máy chủ đang ở đúng luật không, SAI thì chạy tệp kia.


-- ─── TỰ KIỂM — chạy xong phải thấy 5 dòng DUNG ──────────────────────────────
select '① không còn ai có 2 phiên dang_chay' as muc,
       case when not exists (
         select 1 from phien_deepwork where ket_qua = 'dang_chay'
         group by nguoi_id having count(*) > 1
       ) then 'DUNG' else 'SAI' end as ket_qua
union all
select '① index uq_phien_dang_chay đã dựng',
       case when exists (select 1 from pg_indexes
         where indexname = 'uq_phien_dang_chay') then 'DUNG' else 'SAI' end
union all
select '② hai cột tạm dừng đã có',
       case when (select count(*) from information_schema.columns
         where table_name = 'phien_deepwork'
           and column_name in ('tam_dung_luc','nghi_ms')) = 2
       then 'DUNG' else 'SAI' end
union all
select '③ trigger bắn cả INSERT lẫn UPDATE',
       case when (select count(distinct event_manipulation)
         from information_schema.triggers
         where trigger_name = 'trg_kiem_cay_song') = 2
       then 'DUNG' else 'SAI' end
union all
select '④ ghi_chu chỉ chủ đọc — luật ở nang-cap-ghi-chu.sql mục 5, SAI thì chạy tệp ấy',
       case when exists (select 1 from pg_policies
         where tablename = 'ghi_chu' and policyname = 'doc_ghichu'
           and qual like '%nguoi_id_dang_nhap%')
        and not exists (select 1 from pg_policies
         where tablename = 'ghi_chu'
           and (coalesce(qual,'') || coalesce(with_check,'')) like '%la_thanh_vien%')
       then 'DUNG' else 'SAI' end;
