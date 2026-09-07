-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Tệp này KHÔNG dựng vật gì mới — nó viết lại khung nhìn `ai_dang_lam`.
-- │ Đã chạy chưa? → `SO-SQL.sql`, khối ②, dòng "hàng hiện diện còn hỏi nhịp
-- │ tim không". Định nghĩa còn chứa `nhip_cuoi` là chưa chạy.
-- └───────────────────────────────────────────────────────────────────────────
-- NÂNG CẤP: HÀNG HIỆN DIỆN BÁM PHIÊN, KHÔNG BÁM NHỊP TIM — 07/09/2026 (TRI-150)
--
-- VÌ SAO CÓ TỆP NÀY
-- Andy deep work suốt buổi mà tên anh mất viền xanh trên máy Tracy; chạm vào
-- app một cái là viền hiện lại. Bản cũ của khung nhìn này đòi
-- `nhip_cuoi > now() - interval '5 minutes'`. Nhịp ấy do `dwDapNhip` phát, và
-- nó được gọi từ trong `dwVe` — một `setInterval(…, 1000)` nằm trong tab app
-- của người đang làm. Tab chìm sau cửa sổ khác thì trình duyệt ghìm rồi đông
-- lạnh bộ đếm giờ ấy, nhịp tắt, và sau năm phút im lặng thì người đang làm
-- thật rơi khỏi khung nhìn.
--
-- Bản cũ đã đặt cược vào đúng chỗ này và cược sai. Nguyên văn chú thích của nó:
-- *"tab bị đông lạnh hẳn thì nhịp tắt, và đó chính là tín hiệu ta muốn có: máy
-- này đã thật sự đi khỏi."* Người deep work trong một cửa sổ khác CHÍNH LÀ
-- người có tab chìm lâu nhất. Tín hiệu ấy không phân biệt được "đã đi khỏi"
-- với "đang làm việc chăm chú nhất".
--
-- HAI CÂU HỎI BỊ GỘP LÀM MỘT, NAY TÁCH RA
--   · *Ai đang hiện diện* — cái vòng viền xanh. Câu này hỏi phiên còn mở không.
--   · *Máy nào được đoạt lại một phiên* — `dwDongDuoc` ở `public/index.html`.
--     Câu này mới cần biết máy giữ phiên có còn lên tiếng hay không, vì đoạt
--     nhầm một phiên đang sống là cướp mất giờ của người khác.
-- Ngưỡng năm phút đúng cho câu sau và quá chặt cho câu trước.
-- `DW_IM_LANG_PHUT` bên máy khách GIỮ NGUYÊN bằng 5; từ nay nó không còn dây
-- mơ rễ má gì với tệp này nữa.
--
-- CÁI GIÁ CỦA LỰA CHỌN NÀY, nói thẳng: ai quên bấm kết thúc sẽ đeo viền xanh
-- cho tới lúc phiên chạm trần. Tracy chốt 07/09 rằng đó là cái giá rẻ hơn —
-- một người đang làm thật mà mất viền thì cả đội thôi tin cả hàng chip.
--
-- TRẦN BA TIẾNG LÀ HÀNG RÀO THAY THẾ, và nó nằm NGAY TRONG câu hỏi chứ không
-- gửi gắm cho việc định kỳ. `don_phien_bo_roi` chỉ chạy được khi máy chủ đã
-- bật `pg_cron`, và ngay cả khi bật thì nó chạy mỗi giờ một lượt — trông cậy
-- vào nó là để hở một quãng tới 60 phút. Mệnh đề `bat_dau > now() - interval
-- '180 minutes'` dưới đây đúng ở mọi thời điểm, không chờ ai chạy gì.
--
-- 180 phút là `DW_TRAN_PHUT` trong `public/index.html` (dòng 16775) — đúng
-- quãng mà phiên tự đóng ở máy khách. Đổi trần thì đổi cả hai chỗ.
--
-- Chạy lại tệp này nhiều lần vô hại.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── ① VIẾT LẠI KHUNG NHÌN ──────────────────────────────────────────────────
-- Ba lý do phải là khung nhìn chứ không phải hỏi thẳng bảng vẫn nguyên vẹn,
-- chép lại gọn ở đây để ai đọc tệp này không phải mở tệp cũ:
--   · RIÊNG TƯ — khung nhìn trả ĐÚNG BA cột, không cột nào chỉ về việc đang
--     làm. Hỏi thẳng bảng là trao cho mọi máy cả `task_id` lẫn `ghi_chu`.
--   · ĐỒNG HỒ — mọi phép so giờ đo bằng `now()` của máy chủ. Một cái điện
--     thoại sai giờ không được phép giấu mất hay dựng thêm một người nào.
--   · MỘT BẢN LUẬT — phép trừ giờ nghỉ tính một chỗ, không chép sang JavaScript.
-- `security_invoker = true` giữ nguyên: khung nhìn chạy bằng quyền NGƯỜI HỎI
-- nên vẫn đi qua `doc_deepwork`, tức phiên chạy cho một việc cá nhân vẫn khuất
-- khỏi mắt đồng đội. Thiếu nó là mở toang đúng hàng rào ấy.
create or replace view ai_dang_lam
with (security_invoker = true) as
select
  p.nguoi_id,
  /* Phút đã làm, đã trừ các quãng ⏸. Đang tạm dừng thì đồng hồ đứng ở
     `tam_dung_luc` — không thì quãng nghỉ hiện tại bị đếm thành giờ làm.
     `greatest(...,0)` chặn số âm: `nghi_ms` lớn hơn quãng đã trôi là chuyện
     không nên có, nhưng một con số âm trên màn thì khó hiểu hơn cả một con
     số sai. */
  floor(greatest(
    extract(epoch from (coalesce(p.tam_dung_luc, now()) - p.bat_dau))
      - coalesce(p.nghi_ms, 0) / 1000.0
  , 0) / 60)::int                    as phut,
  (p.tam_dung_luc is not null)       as dang_nghi
from phien_deepwork p
where p.ket_qua = 'dang_chay'
  /* TRẦN, không phải nhịp tim. Xem phần đầu tệp. */
  and p.bat_dau > now() - interval '180 minutes';

comment on view ai_dang_lam is
  'Ai trong đội đang trong một phiên deep work NGAY LÚC NÀY — hỏi phiên còn mở và chưa chạm trần 180 phút, KHÔNG hỏi nhịp tim (TRI-150, 07/09). Cố ý không có cột nào chỉ về việc đang làm.';

grant select on ai_dang_lam to authenticated;


-- ─── ② NHÌN THỬ — số liệu tham khảo, chạy trước bảng tự kiểm ────────────────
-- Cột `im_lang_phut` để ở đây cho thấy đúng thứ vừa thôi có quyền phủ quyết:
-- một người im mười lăm phút mà vẫn hiện tên là tệp này đã ăn.
select n.ten,
       a.phut,
       case when a.dang_nghi then 'đang tạm dừng' else 'đang làm' end as trang_thai,
       round(extract(epoch from (now() - p.nhip_cuoi))/60.0, 1)       as im_lang_phut
  from ai_dang_lam a
  join nguoi n           on n.id = a.nguoi_id
  join phien_deepwork p  on p.nguoi_id = a.nguoi_id and p.ket_qua = 'dang_chay'
 order by a.phut desc;


-- ─── ③ TỰ KIỂM — bảng CUỐI CÙNG, đây là thứ Supabase bày ra ─────────────────
-- Trình soạn SQL chỉ hiện kết quả của câu lệnh cuối, nên bảng này phải đứng
-- chót. `order by dat, so` đẩy dòng chưa đạt lên đầu.
with kiem(so, muc, dat) as (values
  (1, 'khung nhìn ai_dang_lam có mặt',
      (select exists (select 1 from pg_views
                       where schemaname = 'public' and viewname = 'ai_dang_lam'))),
  (2, 'vẫn chạy bằng quyền người hỏi (security_invoker) — hàng rào việc cá nhân còn nguyên',
      (select exists (select 1 from pg_class c
                       where c.relname = 'ai_dang_lam' and c.relkind = 'v'
                         and array_to_string(c.reloptions, ',') like '%security_invoker=true%'))),
  (3, 'ĐỊNH NGHĨA KHÔNG CÒN HỎI nhip_cuoi — đây là dòng nói tệp này đã chạy',
      (select to_regclass('public.ai_dang_lam') is not null
          and pg_get_viewdef('public.ai_dang_lam'::regclass) not like '%nhip_cuoi%')),
  (4, 'phien_deepwork vẫn đang phát tin thời gian thực',
      (select exists (select 1 from pg_publication_tables
                       where pubname = 'supabase_realtime'
                         and schemaname = 'public' and tablename = 'phien_deepwork')))
)
select so, muc, case when dat then '✅' else '❌' end as ket_qua
  from kiem order by dat, so;
