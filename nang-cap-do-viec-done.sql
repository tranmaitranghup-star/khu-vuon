-- ═══════════════════════════════════════════════════════════════════════════
-- BẢNG GẶT ĐẾM MỌI VIỆC ĐÃ XONG, KHÔNG CHỈ VIỆC CÓ BẤM ĐỒNG HỒ
-- Tracy chốt 2026-09-03: *"chỉ cần cứ đo lường task done đi đã"*.
-- Chạy MỘT LẦN trong SQL Editor của Supabase. Chỉ dựng lại MỘT khung nhìn.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- BỆNH. `gat_theo_ngay` đọc `vuon_cay`, mà `vuon_cay` mở đầu bằng
--   join phien_deepwork p on p.task_id = t.id and p.ket_qua = 'song'
-- — một phép nối TRONG. Việc xong mà không chạy phiên deep work nào thì không
-- có dòng trong `vuon_cay`, nên không bao giờ tới được bảng gặt. Đo trên dữ
-- liệu thật 7 ngày tới 02/09: Tracy 21/28 việc Done bị lọc · Andy 12/18 ·
-- Justin 5/14. Ba phần tư việc làm xong của một người không hiện ở đâu cả.
--
-- Cái sai không nằm ở phép cộng mà ở CHỖ ĐỨNG của chốt chặn: nó đo người ta có
-- bấm nút hay không, rồi dùng câu trả lời đó để nói về kết quả công việc. Một
-- cuộc họp hai tiếng, một việc bàn giao cho người khác nghiệm thu, một việc làm
-- xong trong mười phút giữa hai cuộc gọi — đều là việc thật, đều tàng hình.
--
-- THUỐC. Bảng gặt đọc thẳng `task`, không đi vòng qua `vuon_cay` nữa:
--   một việc `trang_thai = 'Done'` có `xong_luc` = một quả.
--
-- ⚠️ ĐÁNH ĐỔI, ghi ra để người sau không tưởng là sơ suất. Chú thích cũ của
-- `vuon_cay` nói rõ chốt chặn ấy CỐ Ý — *"để không ai tick Done hàng loạt việc
-- vặt rồi lên bảng gặt"*. Tệp này bỏ chốt chặn đó khỏi bảng gặt, nên cửa ấy mở
-- ra thật. Tracy biết và chọn vậy: một bảng đo nói thiếu ba phần tư sự thật thì
-- hại hơn một bảng đo có thể bị chạy đua. Bù lại, cột `so_qua_dw` bên dưới giữ
-- nguyên con số cũ đứng cạnh con số mới — ai gặt bằng việc vặt thì hai con số
-- đó doãng ra, nhìn là thấy. Muốn siết lại thì siết bằng TRỌNG LƯỢNG việc
-- (cam kết · mốc dự án · đã xếp giờ · ước lượng phút — bốn cột `task` đã có
-- sẵn), đừng quay lại siết bằng "có bấm đồng hồ hay không".
--
-- ⛔ KHÔNG ĐỤNG `vuon_cay`. Nó còn nuôi Khu Vườn (`taiVuon`): một cây lớn theo
-- SỐ GIỜ đổ vào, nên việc không có giờ thì không phải một cây, và đó vẫn đúng.
-- Hai khung nhìn từ nay trả lời hai câu khác nhau — đừng "sửa" cho chúng khớp.
--
-- 🔒 Vì sao đọc thẳng `task` là an toàn (chỗ này từng cắn làn AH). Khung nhìn
-- chạy `security_invoker = on`, nên nếu `doc_task` còn giấu việc trong kho thì
-- mỗi người xem sẽ thấy một con số khác nhau. Nhưng `doc_task` ĐÃ MỞ từ 17/08
-- (`nang-cap-gio-deepwork-theo-loai.sql` mục 1, Tracy chốt): cả đội đọc mọi việc
-- của nhau. Mục 4 bộ tự kiểm canh đúng điều kiện này — nó đỏ thì đừng chạy tiếp.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── 1. gat_theo_ngay: một việc Done = một quả ──────────────────────────────
-- `create or replace` giữ nguyên ba cột cũ đúng thứ tự và đúng kiểu
-- (nguoi_id uuid · ngay date · so_qua bigint) rồi THÊM `so_qua_dw` vào cuối —
-- Postgres cho thêm cột ở cuối, không cho bỏ hay đổi tên.
create or replace view gat_theo_ngay as
select
  t.nguoi_id,
  (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date          as ngay,
  count(*)                                                    as so_qua,
  count(*) filter (where dw.task_id is not null)              as so_qua_dw
from task t
left join (select distinct task_id
             from phien_deepwork
            where ket_qua = 'song' and task_id is not null) dw
       on dw.task_id = t.id
where t.trang_thai = 'Done'
  and t.xong_luc is not null
group by t.nguoi_id, (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date;

comment on view gat_theo_ngay is
  'Số việc đã xong theo (người × ngày giờ Việt Nam). TỪ 03/09/2026 đếm MỌI việc Done, không còn đòi phải có phiên deepwork — trước đó nó đọc vuon_cay (nối TRONG với phien_deepwork) nên ba phần tư việc xong của một người không hiện. Cột so_qua_dw giữ lại con số theo luật cũ để đứng cạnh so sánh. Ngày của quả tính theo LÚC BẤM XONG (xong_luc), không theo task.ngay — người làm khuya tick sau nửa đêm thì công rơi sang hôm sau; muốn chữa thì chữa bằng mốc đổi ngày 3h sáng, đừng đổi cột. Nuôi bảng Kết quả trong ngày ở màn Bảng đo.';

-- Giữ nguyên luật cũ: khung nhìn chạy bằng quyền NGƯỜI GỌI, không vượt mặt RLS.
alter view gat_theo_ngay set (security_invoker = on);

commit;

-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy sau khi commit. Mọi dòng phải `dat = true`.
-- ═══════════════════════════════════════════════════════════════════════════
with kiem(stt, dieu, dat) as (values

  (1, 'Khung nhìn KHÔNG còn đọc vuon_cay',
   pg_get_viewdef('gat_theo_ngay'::regclass) not ilike '%vuon_cay%'),

  (2, 'Cột so_qua_dw đã có',
   exists (select 1 from information_schema.columns
             where table_schema = 'public' and table_name = 'gat_theo_ngay'
               and column_name = 'so_qua_dw')),

  (3, 'Vẫn bật security_invoker (không vượt mặt RLS)',
   (select count(*) from pg_class
      where relname = 'gat_theo_ngay'
        and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  /* ⚠️ DÒNG QUAN TRỌNG NHẤT. Khung nhìn nay đọc thẳng `task`, nên nếu `doc_task`
     còn giấu việc trong kho thì mỗi người xem thấy một con số khác — đúng cái
     bệnh làn AH đã vá cho dải Giờ deepwork. `doc_task` mở từ 17/08; dòng này
     canh nó chưa bị đóng lại. Đỏ thì DỪNG, đừng dùng bảng gặt cho cả đội. */
  (4, 'doc_task còn mở cho cả đội (không lọc theo ngay/nguoi_id)',
   not exists (select 1 from pg_policies
                where schemaname = 'public' and tablename = 'task'
                  and policyname = 'doc_task'
                  and (coalesce(qual, '') ilike '%ngay%'
                    or coalesce(qual, '') ilike '%nguoi_id_dang_nhap%'))),

  /* Con số MỚI không bao giờ nhỏ hơn con số CŨ: tập việc Done có deepwork là
     tập con của tập việc Done. Sai bất biến này là phép đếm hỏng, không phải
     dữ liệu lạ. */
  (5, 'so_qua luôn ≥ so_qua_dw',
   not exists (select 1 from gat_theo_ngay where so_qua < so_qua_dw)),

  /* Con số CŨ phải dựng lại được y hệt từ `vuon_cay` — chứng minh cột giữ lại
     đúng là luật cũ chứ không phải một phép đếm gần đúng. Chênh lệch duy nhất
     được phép: việc Done mà `vuon_cay` đã lọc mất vì không có phiên nào. */
  (6, 'so_qua_dw dựng lại đúng bằng luật cũ',
   not exists (
     select 1
     from (select nguoi_id, ngay, so_qua_dw as n from gat_theo_ngay) a
     full join (select nguoi_id, ngay_ra_qua as ngay, count(*) as n
                  from vuon_cay
                 where nac = 'qua' and ngay_ra_qua is not null
                 group by nguoi_id, ngay_ra_qua) b using (nguoi_id, ngay)
     where coalesce(a.n, 0) <> coalesce(b.n, 0))),

  /* Mỗi việc Done đều phải có `xong_luc`, nếu không nó rơi khỏi bảng gặt mà
     không ai biết. Sáu đường ghi trong app đều đặt cột này; dòng đây canh xem
     có đường nào bỏ sót, hoặc có dòng cũ nào còn thiếu. */
  (7, 'Không việc Done nào thiếu xong_luc',
   not exists (select 1 from task where trang_thai = 'Done' and xong_luc is null))
)
select stt, dieu, dat, case when dat then '✅' else '❌ PHẢI SỬA' end as ket
  from kiem order by stt;

-- ═══════════════════════════════════════════════════════════════════════════
-- SỐ TRƯỚC / SAU — chạy để nhìn tệp này đổi con số của ai, bao nhiêu.
-- Chỉ đọc, không ghi gì.
-- ═══════════════════════════════════════════════════════════════════════════
select n.ten,
       sum(g.so_qua)                    as qua_moi,
       sum(g.so_qua_dw)                 as qua_cu,
       sum(g.so_qua - g.so_qua_dw)      as vua_hien_ra
  from gat_theo_ngay g
  join nguoi n on n.id = g.nguoi_id
 where g.ngay >= current_date - 7
 group by n.ten
 order by vua_hien_ra desc;
