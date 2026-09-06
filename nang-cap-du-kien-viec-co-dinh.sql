-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bẫy `nhip_ke_thua_du_kien`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ⛔⛔⛔ FILE NÀY ĐÃ BỊ THAY — ĐỪNG CHẠY. Chạy `nang-cap-danh-muc-viec-co-dinh.sql`.
--
-- Viết sáng 14/08 làm bản BẮC CẦU, bị thay ngay chiều 14/08 khi Tracy chốt cho
-- việc cố định một MÃ BỀN qua danh mục. File mới làm trọn cả hai việc: nó tạo
-- cột `nhip.thoi_luong_du_kien` ở mục 0, và lấy con số mặc định thẳng từ danh
-- mục theo MÃ (mục 5) — chính xác hơn hẳn cách khớp theo TÊN dưới đây, vốn chỉ
-- là cách chống chế khi việc cố định chưa có danh tính.
-- Nó cũng tự gỡ trigger `nhip_ke_thua_du_kien` của file này, nên chạy file này
-- SAU file kia là dựng lại đúng thứ vừa được gỡ. Đừng chạy.
--
-- GIỮ LẠI vì phần kể "vì sao con số bốc hơi mỗi sáng thứ Hai" là bối cảnh đã
-- dẫn tới quyết định làm danh mục — xoá đi thì phiên sau đọc file mới sẽ không
-- hiểu vì sao phải nhọc thế.
-- ============================================================================

-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — THỜI GIAN DỰ KIẾN cho VIỆC CỐ ĐỊNH
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần không sao (idempotent). Không đụng khung nhìn
--            nào nên không có bẫy thứ tự.
--
-- Tracy chốt 14/08/2026: việc cố định khai được thời gian dự kiến, y như task
-- đã có từ 06/08 (`nang-cap-thoi-luong-du-kien.sql`).
--
-- ── VÌ SAO PHẢI CÓ FILE NÀY, KHÔNG CHỈ THÊM MỘT Ô NHẬP ────────────────────
-- Việc cố định KHÔNG phải một dòng dữ liệu bền. Bảng `nhip` cấp MỘT DÒNG MỚI
-- mỗi tuần: dòng "Check tỉnh thức ROVA" của tuần này và dòng cùng tên của tuần
-- trước là hai bản ghi khác nhau, hai `id` khác nhau. Thứ duy nhất nối chúng
-- lại là chuỗi `ten`.
--
-- Nên nếu chỉ thêm cột rồi lưu như thường: thứ Tư khai "45 phút", sáng thứ Hai
-- bấm "⤺ Chép 5 việc của tuần trước" — nút ấy chỉ chép BỐN trường (ten ·
-- muc_tieu · don_vi · thu_tu) — con số biến mất, không báo gì. Gõ lại. Tuần sau
-- lại mất. 52 lần một năm.
--
-- ── VÌ SAO CHỐT Ở MÁY CHỦ, KHÔNG VÁ NÚT CHÉP BÊN APP ──────────────────────
-- Có HAI đường đẻ ra một dòng `nhip` mới: bấm nút Chép (`chepTuanTruoc`), và
-- gõ lại tên bằng tay (`luuNhip` → insert). Vá bên app chỉ bịt được đường thứ
-- nhất; ai gõ tay vẫn mất số, và mất im lặng. Trigger đứng ở chỗ CẢ HAI đường
-- cùng đi qua.
--
-- Thêm nữa, nút Chép còn cứng ở "tuần trước = tuần này trừ 7 ngày": nghỉ một
-- tuần là nó báo "Tuần trước không có việc nào để chép" và đường ấy chết hẳn.
-- Trigger dưới đây `order by tuan_bat_dau desc` nên với lại bao nhiêu tuần cũng
-- được — nó không chỉ BẰNG bản vá app, nó MẠNH HƠN.
--
-- Đây không phải sáng kiến mới: bộ bước quy trình của việc cố định gặp ĐÚNG bài
-- này ngày 10/08 và đã giải bằng một trigger bám theo TÊN — xem
-- `nang-cap-checklist.sql` mục 5. File này chép đúng khuôn ấy cho một con số.
--
-- ── APP CHẠY ĐƯỢC TRƯỚC KHI CHẠY FILE NÀY ─────────────────────────────────
-- Ô Dự kiến của việc cố định bắt mã lỗi cột lạ (PGRST204 / 42703) rồi nói thẳng
-- phải chạy file nào — cùng khuôn `baoLoiTask`. Không có gì khác gãy theo, và
-- phiên deepwork vẫn mở bình thường: phiên tập trung đắt hơn con số.
--
-- ⚠️ MỤC 2 LÀ BẢN BẮC CẦU, CÓ NGÀY GỠ. Tracy chốt 14/08 (cùng ngày, sau khi
-- file này viết xong): sẽ cho việc cố định một DANH MỤC có mã bền — sang tuần
-- mới người ta chọn "chép 5 việc tuần trước" / "chọn 5 việc trong danh mục đã
-- từng làm" / "tạo mới". Lúc ấy mỗi việc cố định có MỘT mã đi suốt đời, con số
-- Dự kiến về sống ở danh mục, và trigger khớp-theo-TÊN dưới đây thành thừa —
-- gỡ nó đi. Chừng nào danh mục chưa có thì trigger này giữ cho con số không
-- chết mỗi sáng thứ Hai. Cột `nhip.thoi_luong_du_kien` thì giữ cả hai đời: nó
-- là con số của MỘT TUẦN cụ thể, danh mục giữ con số mặc định.
--
-- ⚠️ MẶT TRÁI ĐÃ BIẾT, CỐ Ý CHẤP NHẬN: khi đã có trigger này thì XOÁ TRẮNG con
-- số chỉ sống được một tuần — sáng thứ Hai trigger thấy ô trống sẽ tìm ngược và
-- dựng lại số cũ. Muốn phân biệt "cố tình để trống" với "chưa khai" thì phải
-- thêm một dấu nữa; chưa làm, vì xoá khai là chuyện hiếm. Trong tuần thì xoá
-- vẫn ăn bình thường (trigger chỉ chạy lúc INSERT). Checklist cũng đang mang
-- đúng mặt trái này (`nang-cap-checklist.sql` mục 5) — cố ý giữ giống nhau để
-- khỏi phải nhớ hai luật.
-- ============================================================================


-- ── 1. Cột: đơn vị PHÚT, y hệt `task.thoi_luong_du_kien` ────────────────────
-- Người dùng gõ tự do ở app ("45" · "1h30" · "1.5h"), `phutTuChu()` quy ra phút
-- trước khi ghi xuống — cột này luôn là một số phút sạch.
alter table nhip add column if not exists thoi_luong_du_kien smallint;

comment on column nhip.thoi_luong_du_kien is
  'Thời gian dự kiến cho MỘT LƯỢT chạy việc cố định này, đơn vị PHÚT. '
  'NULL = chưa khai (không ép). Sang tuần mới trigger nhip_ke_thua_du_kien '
  'mang sang theo TÊN việc. Soi cùng phut_trung_binh của khung nhìn '
  'nhip_thoi_gian để ra khoảng chênh Dự kiến ↔ Thực tế.';

-- Trần 1440 phút = 24 giờ, ĐÚNG BẰNG trần của task. Hai ô cùng nghĩa phải cùng
-- luật — không thì app phải nhớ hai ngưỡng, và sớm muộn nhớ nhầm một cái.
alter table nhip drop constraint if exists nhip_du_kien_hop_le;
alter table nhip add constraint nhip_du_kien_hop_le
  check (thoi_luong_du_kien is null or thoi_luong_du_kien between 1 and 1440);

-- Không thêm policy nào: cột nằm trong bảng `nhip`, dùng lại nguyên bộ quyền đã
-- có — `doc_nhip` cho cả đội đọc (schema.sql:268), `ghi_nhip` cho mỗi người sửa
-- dòng của mình (schema.sql:275).


-- ── 2. SANG TUẦN MỚI TỰ MANG THEO ───────────────────────────────────────────
-- Khớp theo TÊN đã chuẩn hoá (bỏ khoảng trắng thừa, không phân biệt hoa
-- thường), trong phạm vi CÙNG MỘT NGƯỜI, lấy dòng gần nhất CÓ khai số — dòng
-- gần nhất mới là con số mới nhất. Y hệt luật của `chep_checklist_tuan_truoc`.
--
-- Chỉ điền khi dòng mới CHƯA có số: người gọi cố tình gửi số xuống thì số ấy
-- thắng, trigger không ghi đè.
--
-- KHÔNG dùng `security definer`. Trigger này chỉ ĐỌC bảng `nhip`, mà `doc_nhip`
-- đã cho mọi thành viên đọc mọi dòng `nhip` rồi — quyền của chính người đang
-- ghi là đủ. (Trigger checklist phải `security definer` vì nó còn GHI sang bảng
-- `muc_viec`; đừng chép cái đó sang đây cho giống.)
--
-- Không cần chốt `and n.id <> new.id` như bên checklist: đây là BEFORE INSERT
-- nên dòng mới chưa nằm trong bảng, không thể tự khớp chính mình.
create or replace function ke_thua_du_kien_viec_co_dinh()
returns trigger language plpgsql set search_path = public
as $$
begin
  if new.thoi_luong_du_kien is null then
    select n.thoi_luong_du_kien into new.thoi_luong_du_kien
      from nhip n
     where n.nguoi_id = new.nguoi_id
       and lower(btrim(n.ten)) = lower(btrim(new.ten))
       and n.thoi_luong_du_kien is not null
     order by n.tuan_bat_dau desc, n.id desc
     limit 1;
  end if;
  return new;
end $$;

comment on function ke_thua_du_kien_viec_co_dinh() is
  'Dòng nhip mới trùng tên với một việc cũ của cùng người thì mang theo luôn '
  'con số Dự kiến. Nhờ vậy con số sống qua các tuần, dù dòng mới sinh ra bằng '
  'nút chép hay bằng gõ lại tên bằng tay.';

-- ⛔ KHÔNG đụng trigger `nhip_chep_checklist` (nang-cap-checklist.sql mục 5).
-- Nó là AFTER INSERT; cái dưới đây là BEFORE INSERT — phải BEFORE mới sửa được
-- `new`. Hai trigger khác thời điểm nên không giẫm chân nhau; dòng tự kiểm số 4
-- canh đúng chuyện đó.
drop trigger if exists nhip_ke_thua_du_kien on nhip;
create trigger nhip_ke_thua_du_kien
  before insert on nhip
  for each row execute function ke_thua_du_kien_viec_co_dinh();


-- ── 3. ĐỔI TÊN VIỆC thì con số ĐI THEO ──────────────────────────────────────
-- Không phải làm gì: con số bám `nhip.id`, không bám tên. Trigger chỉ chạy lúc
-- INSERT nên đổi tên trong tuần không đụng gì. Sang tuần sau khớp theo TÊN MỚI
-- — tên mới chưa từng khai thì coi như việc mới. Đúng bằng hành vi của
-- checklist, cố ý giữ giống để khỏi phải nhớ hai luật.


-- ═══ TỰ KIỂM — bốn dòng, cột `dat` phải ĐÚNG hết ════════════════════════════
select * from (values
  (1, 'cột nhip.thoi_luong_du_kien có mặt',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nhip'
       and column_name = 'thoi_luong_du_kien') = 1),

  (2, 'ràng buộc 1 → 1440 đã gắn',
   (select count(*) from pg_constraint
     where conname = 'nhip_du_kien_hop_le') = 1),

  /* `tgtype` là bộ cờ bit: 2 = BEFORE, 4 = INSERT. Hỏi thẳng hai bit đó chứ
     không chỉ hỏi "trigger có tồn tại không" — gắn nhầm thành AFTER thì trigger
     vẫn tồn tại đủ mọi mặt, chỉ có điều `new` sửa xong không ai nhận, và con số
     im lặng không bao giờ được kế thừa. */
  (3, 'trigger kế thừa đã gắn, và đúng là BEFORE INSERT',
   (select count(*) from pg_trigger
     where tgname = 'nhip_ke_thua_du_kien' and not tgisinternal
       and (tgtype & 2) = 2 and (tgtype & 4) = 4) = 1),

  (4, 'trigger checklist cũ còn nguyên (file này không đá văng nó)',
   (select count(*) from pg_trigger
     where tgname = 'nhip_chep_checklist' and not tgisinternal) = 1)
) as t(so, muc, dat);
