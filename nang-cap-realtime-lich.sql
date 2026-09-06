-- ═══════════════════════════════════════════════════════════════════════════
-- BẬT TIN THỜI GIAN THỰC cho nhóm lịch — Tracy duyệt 03/09/2026 (TRI-74)
--
-- Nguyên văn: *"khi có 1 người xác nhận tham gia họp thì cũng cần reload mới
-- hiện… sự update các thao tác chưa được real time như app"*.
--
-- VÌ SAO PHẢI CÓ TỆP NÀY. Máy khách đã biết nghe, nhưng máy chủ chưa biết nói:
-- Postgres chỉ phát tin về những bảng được kê tên trong publication
-- `supabase_realtime`. Bảng không có tên trong đó thì im lặng tuyệt đối — máy
-- khách đăng ký thành công, không một lỗi nào, và không bao giờ nhận được gì.
-- Đó là kiểu hỏng khó tìm nhất của cả tính năng, nên nếu một ngày realtime
-- "chạy mà không chạy" thì đây là chỗ soi đầu tiên.
--
-- BỐN BẢNG, KHÔNG PHẢI CẢ KHO. Mỗi bảng trong publication là một dòng chảy tin
-- gửi tới mọi máy đang mở app, kể cả khi không ai quan tâm. Bốn bảng dưới đây
-- là đúng những thứ hai người có thể cùng chạm trong một buổi:
--     · lich_chung            — sự kiện thêm mới, đổi giờ, ngưng
--     · lich_chung_tham_du    — CHÍNH LÀ ô Tracy hỏi: ai đã nhận dự
--     · lich_chung_ngoai_le   — dời hoặc huỷ riêng một buổi
--     · task                  — việc, gồm cả việc app đẻ ra từ một buổi
-- Thêm bảng thì sửa cả hai đầu: mảng `RT_BANG` trong `public/index.html` và
-- danh sách ngay dưới đây. Sửa một đầu là nghe một bảng câm, hoặc phát tin cho
-- một bên không ai nghe.
--
-- HÀNG RÀO QUYỀN. Tin của INSERT và UPDATE đi qua đúng chính sách RLS đang có:
-- ai không được đọc một dòng thì không nhận tin về dòng ấy. Riêng DELETE là
-- ngoại lệ của Supabase — tin xoá gửi cho mọi người đăng ký, vì lúc ấy không
-- còn dòng nào để đối chiếu chính sách. Ở app này điều đó vô hại, và lý do nằm
-- ở chính cách máy khách được viết: nó KHÔNG đọc nội dung gói tin, chỉ coi mọi
-- gói tin là câu "có gì đó vừa đổi" rồi tự hỏi lại máy chủ bằng đường cũ. Thứ
-- lọt ra nhiều nhất là việc một dòng nào đó vừa bị xoá, không phải nội dung nó.
-- Ai sau này định đọc payload thì phải đọc lại đoạn này trước.
--
-- Chạy tệp này lúc nào cũng được, chạy lại bao nhiêu lần cũng được: mỗi câu
-- đều tự soi trước khi thêm. Chưa chạy thì app vẫn chạy y như hôm qua, chỉ là
-- màn không tự đổi — không có gì hỏng.
-- ═══════════════════════════════════════════════════════════════════════════

-- ① Publication phải tồn tại. Dự án Supabase nào cũng dựng sẵn nó, nhưng một
--    dự án khôi phục từ bản lưu có thể thiếu — và câu ② sẽ đổ với một thông báo
--    không ai đọc ra nguyên nhân.
do $$
begin
  if not exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    create publication supabase_realtime;
  end if;
end $$;

-- ② Kê bốn bảng. `alter publication ... add table` KHÔNG có dạng `if not exists`
--    và đổ khi bảng đã nằm sẵn trong đó, nên phải tự soi — không thì tệp này chỉ
--    chạy được đúng một lần, mà một tệp chỉ chạy được một lần là một tệp không ai
--    dám chạy lại.
do $$
declare
  ten text;
begin
  foreach ten in array array['lich_chung', 'lich_chung_tham_du',
                             'lich_chung_ngoai_le', 'task']
  loop
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime'
                     and schemaname = 'public' and tablename = ten) then
      execute format('alter publication supabase_realtime add table public.%I', ten);
      raise notice 'Đã thêm % vào supabase_realtime', ten;
    else
      raise notice '% đã có sẵn, bỏ qua', ten;
    end if;
  end loop;
end $$;

-- ③ SOI LẠI. Bốn dòng, đủ bốn tên là xong. Thiếu tên nào thì bảng ấy câm, và
--    phần app phụ thuộc vào nó vẫn phải tải lại trang mới thấy.
select tablename as bang, 'đang phát tin' as trang_thai
  from pg_publication_tables
 where pubname = 'supabase_realtime'
   and schemaname = 'public'
   and tablename in ('lich_chung', 'lich_chung_tham_du', 'lich_chung_ngoai_le', 'task')
 order by tablename;
