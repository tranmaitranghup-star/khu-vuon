-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `phien_deepwork.may_ma`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NÂNG CẤP: MÃ MÁY + NHỊP TIM CHO PHIÊN DEEPWORK — 14/08/2026
-- Chữa gốc lỗi "phiên treo giả" John báo qua Tracy cùng ngày.
--
-- BỆNH. App có một unique index cho mỗi người đúng một phiên `dang_chay`,
-- nhưng KHÔNG có chỗ nào ghi lại MÁY NÀO đang giữ phiên đó, cũng không có dấu
-- hiệu nào cho biết máy ấy còn sống hay đã đi khỏi. Thiếu hai dữ kiện đó, mọi
-- câu hỏi kiểu "phiên này có ai đang dùng không?" chỉ còn cách ĐOÁN — và app
-- đã đoán, rồi nói cái đoán ra như sự thật đã kiểm chứng ("có thể đang chạy
-- trên một máy khác"), ngay trên chính cái máy vừa mở phiên đó.
--
-- THUỐC. Hai cột, mỗi cột trả lời đúng một câu:
--   ① may_ma    — MÁY NÀO mở phiên này. Máy đó luôn được quyền đóng lại phiên
--                 của chính nó, không phải chờ hết trần 180 phút.
--   ② nhip_cuoi — máy giữ phiên LẦN CUỐI còn lên tiếng lúc nào. App đập nhịp
--                 mỗi 60 giây suốt phiên. Im quá 5 phút nghĩa là máy ấy đã đi
--                 khỏi (đóng tab, tắt máy, hết pin) → máy khác được đoạt lại.
--                 Phiên đang ⏸ KHÔNG tính là im lặng: nó đứng yên có chủ ý.
--
-- Nhờ hai cột này, "hết hạn" được đo bằng SỰ IM LẶNG thay vì bằng TUỔI tính từ
-- lúc bắt đầu. Đó là khác biệt quan trọng: bản cũ bắt người ta chờ đủ 180 phút
-- kể từ giờ bắt đầu mới cho đụng vào phiên, nên bỏ máy đi 30 phút rồi quay lại
-- vẫn bị chặn.
--
-- Chạy: Supabase → SQL Editor → New query → dán trọn file → Run.
-- App ĐÃ viết phòng thủ: chưa chạy file này thì hai cột chưa có, app tự bỏ
-- chúng khỏi gói gửi và rơi về đúng nết cũ (chặn theo trần 180 phút) — không
-- màn nào hỏng. Chạy xong là hai cửa trên tự mở.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── ① HAI CỘT MỚI ──────────────────────────────────────────────────────────
alter table phien_deepwork add column if not exists may_ma    text;
alter table phien_deepwork add column if not exists nhip_cuoi timestamptz;

comment on column phien_deepwork.may_ma is
  'Mã máy đã mở phiên (sinh bằng crypto.randomUUID, nằm ở localStorage khoá dw_may nên theo MÁY chứ không theo tài khoản). Máy trùng mã luôn được quyền tự đóng / khai lại phiên của chính nó. Xoá bộ nhớ trình duyệt thì mã đổi và máy đó mất đường tắt này — cửa nhịp tim vẫn còn.';
comment on column phien_deepwork.nhip_cuoi is
  'Lần cuối máy giữ phiên còn lên tiếng. App đập mỗi 60 giây trong lúc phiên chạy, kể cả khi tab đang chìm. Im quá 5 phút mà không ở trạng thái ⏸ = máy giữ phiên đã đi khỏi, máy khác được đoạt lại. Đây là thước đo THẬT thay cho phép đoán "có thể đang chạy trên máy khác" của bản trước 14/08.';


-- ─── ② DỌN NỀN: các phiên dang_chay có sẵn chưa hề có nhịp ───────────────────
-- Dòng cũ có nhip_cuoi null thì hàm dwDongDuoc ở client trả về false — tức là
-- không ai đoạt lại được, phải chờ đủ trần 180 phút y như bản cũ. Với những
-- phiên đã bắt đầu từ lâu thì điều đó chỉ làm khổ người dùng chứ không bảo vệ
-- ai: máy mở chúng chắc chắn đã đi khỏi từ lâu. Đóng dấu nhịp cuối = giờ bắt
-- đầu để chúng lập tức được tính là im lặng.
update phien_deepwork
set nhip_cuoi = bat_dau
where ket_qua = 'dang_chay' and nhip_cuoi is null;


-- ─── ③ CHỈ MỤC ĐỌC NHANH ────────────────────────────────────────────────────
-- Hàng ngày chỉ có tối đa một dòng dang_chay mỗi người nên chỉ mục này không
-- đổi đời truy vấn nào; nó có mặt cho ngày kho phiên lớn lên và ai đó muốn
-- quét "những phiên đang chạy mà đã im lặng".
create index if not exists idx_phien_nhip_cuoi
  on phien_deepwork (nhip_cuoi)
  where ket_qua = 'dang_chay';


-- ─── TỰ KIỂM — chạy xong phải thấy 3 dòng DUNG ──────────────────────────────
select '① hai cột may_ma + nhip_cuoi đã có' as muc,
       case when (select count(*) from information_schema.columns
         where table_name = 'phien_deepwork'
           and column_name in ('may_ma','nhip_cuoi')) = 2
       then 'DUNG' else 'SAI' end as ket_qua
union all
select '② không còn phiên dang_chay nào thiếu nhịp',
       case when not exists (
         select 1 from phien_deepwork
         where ket_qua = 'dang_chay' and nhip_cuoi is null
       ) then 'DUNG' else 'SAI' end
union all
select '③ chỉ mục idx_phien_nhip_cuoi đã dựng',
       case when exists (select 1 from pg_indexes
         where indexname = 'idx_phien_nhip_cuoi') then 'DUNG' else 'SAI' end;
