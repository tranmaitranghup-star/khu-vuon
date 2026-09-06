-- ┌───────────────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hai bảng `van_de` và `van_de_binh_luan` có tên
-- │ trong publication `supabase_realtime`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- BẬT TIN THỜI GIAN THỰC cho lớp vấn đề liên phòng — làn VD4, 05/09/2026
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn tệp → Run.
--            Chạy lại bao nhiêu lần cũng vô hại: mỗi câu tự soi trước khi thêm.
--
-- CHẠY SAU: `nang-cap-van-de-lien-phong.sql` (nó dựng hai bảng này).
--
-- ─── VÌ SAO CẦN ─────────────────────────────────────────────────────────────
-- Mạch bàn luận vừa lên sóng: hai phòng nói chuyện với nhau ngay trong một vấn
-- đề, thay vì trong Zalo. Nhưng Postgres chỉ phát tin về những bảng được KÊ TÊN
-- trong publication `supabase_realtime`, và hai bảng mới thì chưa có tên trong
-- đó. Máy khách đăng ký thành công, không một lỗi nào, và không bao giờ nhận
-- được gì — nên hôm nay một câu mới chỉ hiện khi người kia tải lại màn.
--
-- Một mạch bàn luận không tự đổi thì hỏng đúng cái nó sinh ra để làm: hai người
-- cùng mở một vấn đề, người này gõ một câu, người kia ngồi nhìn một màn hình
-- đứng yên. Đó là lý do tệp này đi CÙNG ĐỢT với màn chi tiết, không để đợt sau.
--
-- ─── HAI BẢNG, VÀ VÌ SAO CẢ HAI ─────────────────────────────────────────────
--   · van_de_binh_luan  — câu mới trong mạch bàn luận
--   · van_de            — nấc trạng thái vừa đổi, và vấn đề vừa được nêu
-- Thiếu bảng thứ hai thì người kia thấy câu trả lời nhưng không thấy vấn đề đã
-- chuyển sang *Đang xử lý* — mà chính cú đổi nấc mới là điều câu ấy nói tới.
--
-- ─── ĐẦU BÊN KIA NẰM Ở ĐÂU ──────────────────────────────────────────────────
-- ⚠️ KHÔNG phải mảng `RT_BANG` trong `public/index.html` — đừng thêm vào đó.
-- Hai bảng này đi một NGƯỜI NGHE RIÊNG là `vdCoTin`, khai ngay cạnh `rtMoKenh`,
-- cùng lối `phien_deepwork` đã đi và cũng cố ý vắng mặt trong `RT_BANG`.
--
-- Lý do là một chỗ dễ vấp: `rtTaiLai` (đường của `RT_BANG`) HOÃN lại chừng nào
-- còn một cửa sổ nổi đang mở — đúng đắn cho một bảng lịch, vì không ai muốn bị
-- giật mất thứ đang gõ dở. Nhưng ở đây cái cửa đang mở CHÍNH LÀ thứ cần đổi.
-- Đi chung đường ấy là mạch bàn luận chỉ tự đổi sau khi người ta đóng cửa lại.
-- `vdCoTin` vẽ lại tại chỗ và giữ nguyên câu đang gõ dở.
--
-- ─── HÀNG RÀO QUYỀN ─────────────────────────────────────────────────────────
-- Tin của INSERT và UPDATE đi qua đúng chính sách RLS đang có. Riêng DELETE là
-- ngoại lệ của Supabase — tin xoá gửi cho mọi người đăng ký. Ở đây điều đó
-- không đáng lo, vì hai lẽ: `van_de` cố ý KHÔNG có policy xoá (bảng bình luận
-- chỉ mất theo `on delete cascade`, tức không đường nào trong app gỡ được), và
-- máy khách KHÔNG đọc nội dung gói tin — nó coi mọi gói tin là câu "có gì đó
-- vừa đổi" rồi tự hỏi lại máy chủ bằng đường cũ, đường vốn đã lọc theo quyền.
-- Ai sau này định đọc payload thì phải đọc lại đoạn này trước.
--
-- Chưa chạy tệp này thì app vẫn chạy y như hôm qua, chỉ là màn không tự đổi.
-- Không có gì hỏng.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① Publication phải tồn tại. Dự án Supabase nào cũng dựng sẵn nó, nhưng một dự
--    án khôi phục từ bản lưu có thể thiếu — và câu ② sẽ đổ với một thông báo
--    không ai đọc ra nguyên nhân.
do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end $$;

-- ② Kê hai bảng. `alter publication ... add table` KHÔNG có dạng `if not exists`
--    và đổ khi bảng đã nằm sẵn trong đó, nên phải tự soi — không thì tệp này chỉ
--    chạy được đúng một lần, mà một tệp chỉ chạy được một lần là một tệp không
--    ai dám chạy lại.
--    Soi luôn cả sự tồn tại của bảng: chạy tệp này trước
--    `nang-cap-van-de-lien-phong.sql` thì báo bằng một câu đọc ra được, thay vì
--    một lỗi Postgres nói về một quan hệ không có tên.
do $$
declare
  ten text;
begin
  foreach ten in array array['van_de', 'van_de_binh_luan']
  loop
    if not exists (select 1 from information_schema.tables
                   where table_schema = 'public' and table_name = ten) then
      raise notice 'CHƯA CÓ bảng % — chạy nang-cap-van-de-lien-phong.sql trước', ten;
    elsif not exists (select 1 from pg_publication_tables
                      where pubname = 'supabase_realtime'
                        and schemaname = 'public' and tablename = ten) then
      execute format('alter publication supabase_realtime add table public.%I', ten);
      raise notice 'Đã thêm % vào supabase_realtime', ten;
    else
      raise notice '% đã có sẵn, bỏ qua', ten;
    end if;
  end loop;
end $$;

-- ③ TỰ KIỂM — xếp XUỐNG CUỐI vì trình soạn SQL của Supabase chỉ bày kết quả của
--    câu lệnh cuối cùng. Hai dòng, cả hai phải ✅ đạt.
--    `order by dat, so` cho dòng chưa đạt nổi lên đầu.
select *
  from (
    select 1 as so,
           'van_de đang phát tin' as muc,
           case when exists (select 1 from pg_publication_tables
                              where pubname = 'supabase_realtime'
                                and schemaname = 'public' and tablename = 'van_de')
                then '✅ đạt' else '❌ chưa' end as dat
    union all
    select 2,
           'van_de_binh_luan đang phát tin',
           case when exists (select 1 from pg_publication_tables
                              where pubname = 'supabase_realtime'
                                and schemaname = 'public'
                                and tablename = 'van_de_binh_luan')
                then '✅ đạt' else '❌ chưa' end
  ) t
 order by dat, so;
