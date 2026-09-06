-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `don_phien_bo_roi`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- NÂNG CẤP: DỌN PHIÊN BỎ RƠI — 28/08/2026
--
-- VÌ SAO CÓ FILE NÀY
-- Hai phiên còn trạng thái `dang_chay` từ 08/08 tới nay không ai khép. Chúng
-- không phải lỗi của máy khách: `dwKhoiPhuc` ở `public/index.html` đã khôi
-- phục phiên dang dở đúng cách từ đợt vá 14/08, nhưng nó lọc
-- `.eq('nguoi_id', ME.id)` — tức **chỉ dọn phiên của chính người đang đăng
-- nhập**. Phiên của một người không mở app nữa thì vĩnh viễn không ai chạm.
--
-- Trước đây có một lưới an toàn ở tầng máy chủ lo đúng việc này: bản `vuon_cay`
-- đời đầu trong `schema.sql` dòng 236-240 tự coi phiên quá 40 phút là `heo`,
-- và chú thích dòng 158 hứa thẳng *"không cần cron"*. **Lời hứa đó đã mất hiệu
-- lực trong im lặng**: `nang-cap-khu-vuon.sql` rồi `nang-cap-tran-180-phut.sql`
-- viết đè `vuon_cay`, và bản mới không còn mệnh đề 40 phút nào. Không ai gỡ nó
-- có chủ ý — nó rơi ra cùng lúc khung nhìn được viết lại.
--
-- File này dựng lại lưới ấy, lần này ở chỗ `create or replace view` không xoá
-- được: một câu UPDATE thật trên bảng, cộng một việc định kỳ gọi lại nó.
--
-- ⚠️ THỨ TỰ CHẠY
--   ① `nang-cap-chot-chan-phien.sql` — nếu chưa chạy lần nào. Nó dựng
--      `uq_phien_dang_chay`, thứ chặn hai phiên cùng lúc. Khối ⓪ dưới đây cho
--      biết đã có chưa.
--   ② File này.
--   ③ **ĐỪNG** chạy lại `nang-cap-dem-o-may-chu.sql`, `nang-cap-gio-vang.sql`
--      hay `nang-cap-deepwork-tu-do.sql` theo trí nhớ. Cả ba từng kẹp trần ở
--      **120** phút trong khi app chạy **180**, và vì đều là
--      `create or replace view` nên chạy sau file 180 là hạ trần trong im lặng.
--      Ba file ấy đã sửa sang 180 ngày 28/08, nhưng luật vẫn là: chạy đúng file
--      mình cần, đừng chạy lại cả loạt.
--
-- Chạy lại file này nhiều lần vô hại.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── ⓪ CHẨN ĐOÁN — chỉ ĐỌC, chạy trước cho biết máy chủ đang ở đâu ──────────
-- Chạy riêng khối này trước cũng được. Nó không sửa gì.
select 'index uq_phien_dang_chay đã dựng' as thu,
       case when exists (select 1 from pg_indexes
              where indexname = 'uq_phien_dang_chay') then 'CÓ' else 'CHƯA' end as tra_loi
union all
select 'cột may_ma + nhip_cuoi đã có',
       case when (select count(*) from information_schema.columns
                   where table_name = 'phien_deepwork'
                     and column_name in ('may_ma','nhip_cuoi')) = 2
            then 'CÓ' else 'CHƯA' end
union all
select 'có ai đang giữ 2 phiên dang_chay không',
       case when exists (select 1 from phien_deepwork where ket_qua = 'dang_chay'
                          group by nguoi_id having count(*) > 1)
            then 'CÓ — chạy nang-cap-chot-chan-phien.sql trước' else 'KHÔNG' end
union all
select 'số phiên bỏ rơi quá 180 phút',
       (select count(*)::text from phien_deepwork
         where ket_qua = 'dang_chay' and bat_dau < now() - interval '180 minutes')
union all
select 'phiên bỏ rơi cũ nhất bắt đầu lúc',
       coalesce((select to_char(min(bat_dau) at time zone 'Asia/Ho_Chi_Minh',
                                'DD/MM/YYYY HH24:MI')
                   from phien_deepwork
                  where ket_qua = 'dang_chay'
                    and bat_dau < now() - interval '180 minutes'), '(không có)');


-- ─── ① HÀM DỌN ─────────────────────────────────────────────────────────────
-- Đặt thành HÀM chứ không phải một câu update rời, vì hai lý do: việc định kỳ
-- ở khối ② gọi được nó, và lần sau muốn đổi luật thì sửa một chỗ.
--
-- `least(bat_dau + 180 phút, now())` — cùng đúng phép kẹp mà `dwKhoiPhuc` dùng
-- ở máy khách. Không lấy `now()` trơn: một phiên bỏ rơi ba tuần mà ghi
-- `ket_thuc = now()` thì thành một phiên dài ba tuần, và mọi con số phút của
-- người đó vỡ. Kẹp ở trần thì phiên ấy đọc ra đúng cái nó là — một phiên chạm
-- trần rồi bị bỏ.
--
-- ⚠️ `ket_qua = 'heo'` chứ KHÔNG phải `'song'`. Ba giá trị hợp lệ của cột này
-- là `dang_chay` · `song` · `heo` (ràng buộc ở `schema.sql:155`). `heo` nghĩa
-- là bỏ dở — đúng thứ đã xảy ra. Ghi `song` là cộng giờ khống vào vườn.
-- Trigger `trg_kiem_cay_song` chỉ soi nhánh `song` nên đường này đi lọt.
create or replace function don_phien_bo_roi()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare so_dong integer;
begin
  update phien_deepwork
     set ket_qua  = 'heo',
         ket_thuc = least(bat_dau + interval '180 minutes', now())
   where ket_qua = 'dang_chay'
     and bat_dau < now() - interval '180 minutes';
  get diagnostics so_dong = row_count;
  return so_dong;
end;
$$;

comment on function don_phien_bo_roi is
  'Khép các phiên deep work bị bỏ rơi quá trần 180 phút thành heo, kẹp ket_thuc ở trần. Thay cho lưới 40 phút đã rơi khỏi vuon_cay. Chạy lại nhiều lần vô hại.';

-- Dọn ngay một lượt cho đống đang tồn.
select don_phien_bo_roi() as so_phien_vua_khep;


-- ─── ② VIỆC ĐỊNH KỲ — để nó không tái diễn ─────────────────────────────────
-- Không có khối này thì file trên chỉ dọn được một lần, và ba tuần nữa lại có
-- một đống mới. `pg_cron` là tiện ích Supabase bật sẵn được từ trang
-- Database › Extensions.
--
-- Bọc trong `do $$` để nếu máy chủ chưa bật `pg_cron` thì cả file vẫn chạy
-- xong, chỉ báo một dòng nhắc — thay vì đổ lỗi và cuộn ngược mọi thứ ở trên.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.unschedule('don-phien-bo-roi')
      where exists (select 1 from cron.job where jobname = 'don-phien-bo-roi');
    perform cron.schedule('don-phien-bo-roi', '7 * * * *',
                          'select don_phien_bo_roi()');
    raise notice '✅ Đã hẹn dọn phiên bỏ rơi mỗi giờ, vào phút thứ 7.';
  else
    raise notice '⚠️ Máy chủ chưa bật pg_cron nên CHƯA hẹn được việc định kỳ. Đống phiên đang tồn đã dọn xong, nhưng lần sau vẫn phải chạy tay. Bật ở Database › Extensions › pg_cron rồi chạy lại file này.';
  end if;
end $$;


-- ─── TỰ KIỂM — chạy xong phải thấy 3 dòng DUNG ─────────────────────────────
-- ⚠️ Ba dòng này soi ba thứ KHÁC NHAU và không dòng nào chọi dòng nào — đã
-- kiểm chéo bằng tay. (Án lệ 28/08: một bộ tự kiểm qua bốn lượt thẩm định mà
-- vẫn lọt hai dòng đòi ngược nhau, vì mỗi lượt chỉ soi từng dòng riêng lẻ.)
select '① không còn phiên bỏ rơi quá trần' as muc,
       case when not exists (
         select 1 from phien_deepwork
          where ket_qua = 'dang_chay' and bat_dau < now() - interval '180 minutes'
       ) then 'DUNG' else 'SAI' end as ket_qua
union all
select '② hàm don_phien_bo_roi đã dựng',
       case when exists (select 1 from pg_proc where proname = 'don_phien_bo_roi')
            then 'DUNG' else 'SAI' end
union all
select '③ phiên vừa khép mang ket_qua heo, không phải song',
       case when not exists (
         select 1 from phien_deepwork
          where ket_qua = 'song'
            and ket_thuc - bat_dau > interval '181 minutes'
       ) then 'DUNG' else 'SAI' end;

-- Dòng ③ nói gì: nếu phép dọn lỡ ghi `song` thay vì `heo` thì sẽ đẻ ra những
-- phiên `song` dài hơn trần — đúng thứ trigger cấm. Không có dòng nào như vậy
-- nghĩa là phép dọn đã đi đúng nhánh.
