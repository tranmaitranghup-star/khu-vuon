-- ═══════════════════════════════════════════════════════════════════════════
-- AI ĐANG DEEPWORK — cho cả đội nhìn thấy nhau (TRI-88)
-- Tracy duyệt 03/09/2026, phương án A + realtime.
--
-- Nguyên văn: *"tôi cần cả team cùng nhìn được ai đang deepwork… ở phần đầu
-- trang hiện tên của các thành viên và nếu mà ai đang deepwork thì tên người
-- đó có viền xanh dương đậm lên"*.
--
-- KHÔNG THÊM MỘT CỘT NÀO. Đề bài ban đầu là "task và sự kiện cần thêm trạng
-- thái đang làm". Không cần: `phien_deepwork.ket_qua = 'dang_chay'` đã được
-- ghi NGAY lúc bấm ▶ (`dwMoPhienMoi`), có `uq_phien_dang_chay` bảo đảm mỗi
-- người tối đa một dòng, và `doc_deepwork` đã cho cả đội đọc từ đầu. Dữ liệu
-- nằm sẵn đó từ lâu; thứ thiếu chỉ là một câu hỏi và một chỗ để bày ra.
--
-- Tệp này làm đúng hai việc: dựng khung nhìn để hỏi, và kê bảng vào publication
-- để máy chủ chịu phát tin. Chạy lại bao nhiêu lần cũng được.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① KHUNG NHÌN. Ba lý do phải là khung nhìn chứ không phải select thẳng bảng:
--
--    · RIÊNG TƯ. `doc_task` cố tình giấu việc còn trong kho khỏi đồng đội,
--      còn `doc_deepwork` thì mở trần. Select thẳng bảng là trao cho mọi máy
--      cả `task_id` và `ghi_chu` của phiên — tức lộ đúng thứ hàng rào kia
--      đang giấu. Khung nhìn này trả ĐÚNG BA cột, không có cột nào chỉ về
--      việc đang làm. Ai sau này định thêm `task_id` vào đây thì phải siết
--      `doc_deepwork` lại trước.
--
--    · ĐỒNG HỒ. Mọi phép so giờ phải đo bằng `now()` của máy chủ. Đo bằng
--      đồng hồ máy khách thì một cái điện thoại sai giờ đủ để hoặc giấu mất
--      người đang làm, hoặc giữ mãi một người đã tắt máy từ sáng.
--
--    · MỘT BẢN LUẬT. Phút đã trừ giờ nghỉ được tính một chỗ, không phải chép
--      lại phép trừ ấy sang JavaScript rồi chờ hai bên lệch nhau.
--
--    `security_invoker = true` để khung nhìn chạy bằng quyền NGƯỜI HỎI, tức
--    vẫn đi qua `doc_deepwork` như thường. Thiếu nó thì khung nhìn chạy bằng
--    quyền người tạo và lách qua mọi chính sách — người đăng nhập nhưng không
--    thuộc đội cũng đọc được.
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
  /* ⚠️ SỬA 07/09 (TRI-150) — ĐÃ TỪNG LÀ NGƯỠNG NHỊP TIM NĂM PHÚT.
     Bản gốc đòi `nhip_cuoi > now() - interval '5 minutes'` và tin rằng một tab
     đông lạnh nghĩa là máy ấy đã đi khỏi. Sai: người deep work trong một cửa
     sổ khác chính là người có tab chìm lâu nhất, nên Andy làm suốt buổi mà mất
     viền xanh trên máy Tracy, chạm vào app một cái là viền hiện lại.
     Nay hỏi TRẦN thay cho nhịp tim. `DW_IM_LANG_PHUT` bên máy khách giữ nguyên
     bằng 5 nhưng chỉ còn dùng cho việc đoạt lại phiên, không dính tới đây.
     Mệnh đề dưới đã chép sang `nang-cap-hien-dien-theo-tran.sql` — SỬA CẢ HAI
     TỆP để chạy lại tệp nào cũng ra cùng một kết quả. Đầu đuôi ở tệp kia.
     180 phút là `DW_TRAN_PHUT` trong `public/index.html`. */
  and p.bat_dau > now() - interval '180 minutes';

comment on view ai_dang_lam is
  'Ai trong đội đang trong một phiên deep work NGAY LÚC NÀY — hỏi phiên còn mở và chưa chạm trần 180 phút, KHÔNG hỏi nhịp tim (TRI-150, 07/09). Cố ý không có cột nào chỉ về việc đang làm.';

grant select on ai_dang_lam to authenticated;

-- ② KÊ BẢNG VÀO PUBLICATION. Máy khách đăng ký nghe một bảng chưa được kê tên
--    thì đăng ký THÀNH CÔNG, không một lỗi nào, và không bao giờ nhận được gì.
--    Đó là kiểu hỏng khó tìm nhất của cả cụm realtime.
--
--    ⚠️ `phien_deepwork` CỐ Ý KHÔNG nằm trong mảng `RT_BANG` của
--    `public/index.html`, khác với bốn bảng lịch. Lý do: nhịp tim 60 giây của
--    mỗi người là một lượt UPDATE, và `RT_BANG` dẫn mọi tin về `rtTaiLai` —
--    một lượt tải lại nặng cả timeline lẫn màn Của tôi. Bảy người đang chạy
--    phiên là bảy lượt tải lại mỗi phút trên MỌI máy, cho một thứ chỉ cần vẽ
--    lại một hàng chip. Nó có một người nghe riêng là `hdCoTin`, đăng ký trong
--    cùng kênh `khu-vuon-lich` nhưng đi vào một đường nhẹ.
do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;

  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime'
                   and schemaname = 'public' and tablename = 'phien_deepwork') then
    alter publication supabase_realtime add table public.phien_deepwork;
    raise notice 'Đã thêm phien_deepwork vào supabase_realtime';
  else
    raise notice 'phien_deepwork đã có sẵn, bỏ qua';
  end if;
end $$;

-- ③ TỰ KIỂM — ba dòng, cả ba phải ✅.
select '① khung nhìn ai_dang_lam có mặt' as muc,
       case when exists (select 1 from pg_views
                          where schemaname = 'public' and viewname = 'ai_dang_lam')
            then '✅' else '❌ chưa dựng' end as ket_qua
union all
select '② khung nhìn chạy bằng quyền người hỏi (security_invoker)',
       case when exists (select 1 from pg_class c
                          where c.relname = 'ai_dang_lam' and c.relkind = 'v'
                            and array_to_string(c.reloptions, ',') like '%security_invoker=true%')
            then '✅' else '❌ thiếu — người ngoài đội cũng đọc được' end
union all
select '③ phien_deepwork đang phát tin thời gian thực',
       case when exists (select 1 from pg_publication_tables
                          where pubname = 'supabase_realtime'
                            and schemaname = 'public' and tablename = 'phien_deepwork')
            then '✅' else '❌ bảng câm — chip sẽ chỉ đổi khi tải lại trang' end;

-- ④ NHÌN THỬ. Chạy lúc có ai đó đang trong phiên thì ra tên người ấy; không
--    có ai đang làm thì ra bảng rỗng — đó cũng là một kết quả đúng.
select n.ten, a.phut, case when a.dang_nghi then 'đang tạm dừng' else 'đang làm' end as trang_thai
  from ai_dang_lam a join nguoi n on n.id = a.nguoi_id
 order by a.phut desc;
