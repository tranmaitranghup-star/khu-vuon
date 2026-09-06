-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: khung nhìn `gio_deepwork_theo_gio` — `nang-cap-tran-180-phut.sql` CHỨA SẴN khung nhìn này, nên nhiều khả năng tệp đó là thứ cần chạy
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ⚠️ TRẦN PHIÊN LÀ 180 PHÚT, KHÔNG PHẢI 120 (sửa 28/08).
-- Con số này khai ở `public/index.html` dòng 10107 (`DW_TRAN_PHUT = 180`) và ở
-- `nang-cap-tran-180-phut.sql`, nơi đổi CẢ NĂM khung nhìn sang 180. File này viết
-- trước đợt ấy nên còn giữ 120.
-- Vì cả ba file đều dùng `create or replace view`, chạy file này SAU file 180 là
-- hạ trần về 120 TRONG IM LẶNG — không báo lỗi, chỉ ra số phút thiếu. Đã suýt
-- dính một lần: file này nằm trong danh sách "chờ Tracy chạy".

-- ═══════════════════════════════════════════════════════════════════════════
-- GIỜ VÀNG — khung nhìn gộp phút deepwork theo GIỜ TRONG NGÀY
-- Tracy chốt 2026-08-09. Nuôi đúng MỘT ô trong khối "Tổng quan deepwork"
-- ở tab Timeline: "khung hai tiếng nào trong ngày bạn tập trung nhiều nhất".
--
-- VÌ SAO PHẢI CÓ KHUNG NHÌN RIÊNG: trong kho đang có 12 khung nhìn, gộp sẵn
-- theo ngày · theo người · theo ô cam kết — KHÔNG cái nào gộp theo giờ. Còn
-- tính ở máy khách thì phải kéo về từng phiên một, mà mảng phiên có trần và
-- app đã trả giá đúng một lần cho kiểu đếm đó (số giờ tập trung đóng băng sau
-- ~161 ngày mà không báo gì — đợt soi 08/08). Gộp ở đây thì trần CỨNG là
-- 24 giờ × số người: 12 người = 288 dòng, không bao giờ phình theo thời gian.
--
-- HAI QUYẾT ĐỊNH VỀ NGỮ NGHĨA, ghi ra để đời sau khỏi đoán:
--   ① CHIA PHÚT VÀO ĐÚNG GIỜ NÓ THẬT SỰ DIỄN RA, không dồn cả phiên vào giờ
--      bấm nút. Phiên 9:40 → 11:10 được tính 20 phút cho giờ 9, 60 phút cho
--      giờ 10, 10 phút cho giờ 11. Dồn hết vào giờ bấm nút thì người quen mở
--      phiên dài lúc 9 giờ sẽ thấy "giờ vàng 9h" kể cả khi phần lớn công sức
--      rơi vào 10–11h — tức con số nói ngược thứ nó định nói.
--   ② CÙNG NGỮ NGHĨA GIỜ với `gio_deepwork_theo_ngay`: chỉ phiên `ket_qua =
--      'song'` và đã có giờ kết thúc, trần 120 phút mỗi phiên, TÍNH CẢ phiên
--      gắn nhịp, mốc giờ quy về Asia/Ho_Chi_Minh. Nhờ vậy tổng phút của khung
--      nhìn này KHỚP tổng phút của khung nhìn theo ngày — mục ④ của bộ tự
--      kiểm bên dưới soi đúng chỗ đó.
--      ⚠️ CỐ Ý KHÔNG bắc vào `cham_theo_ngay`: trong kho có HAI bản khác ngữ
--      nghĩa nhau (một bản chặn 30 phút và bỏ phiên nhịp, bản kia chặn 120 và
--      không bỏ) nên không chắc bản nào đang sống trên máy chủ.
--
-- CHẠY: dán trọn file này vào Supabase → SQL Editor → Run. Chạy lại nhiều lần
-- vô hại. Chạy xong nhìn bảng cuối: cột `dat` phải ĐÚNG cả sáu dòng.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Khung nhìn ─────────────────────────────────────────────────────────
create or replace view gio_deepwork_theo_gio as
with phien as (
  select
    p.nguoi_id,
    (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')                      as bd,
    (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')
      + least(p.ket_thuc - p.bat_dau, interval '180 minutes')        as kt
  from phien_deepwork p
  where p.ket_qua = 'song'
    and p.ket_thuc is not null
    and p.ket_thuc > p.bat_dau
),
lat as (
  -- mỗi phiên nở ra thành các LÁT một giờ; lát đầu và lát cuối bị xén theo
  -- mốc thật của phiên, các lát giữa trọn 60 phút
  select
    phien.nguoi_id,
    extract(hour from moc)::int as gio,
    phien.bd::date              as ngay,
    extract(epoch from (
      least(phien.kt, moc + interval '1 hour') - greatest(phien.bd, moc)
    )) / 60                     as phut
  from phien
  cross join lateral generate_series(
    date_trunc('hour', phien.bd),
    phien.kt - interval '1 microsecond',    -- trừ 1 micro giây để phiên kết
    interval '1 hour'                       -- thúc đúng đầu giờ không đẻ
  ) as moc                                  -- thêm một lát rỗng
)
select
  nguoi_id,
  gio,
  round(sum(phut))::int         as phut,
  count(distinct ngay)::int     as so_ngay      -- bao nhiêu ngày có làm ở khung này
from lat
where phut > 0
group by nguoi_id, gio;


-- ─── 2. Bật quyền người gọi ────────────────────────────────────────────────
-- BẮT BUỘC. `create or replace` giữ được thiết lập cũ, nhưng nếu ai đó lỡ
-- `drop view` rồi tạo lại mà quên dòng này thì khung nhìn chạy bằng quyền
-- NGƯỜI TẠO — tức vượt mặt RLS, ai đăng nhập cũng đọc được của mọi người.
alter view gio_deepwork_theo_gio set (security_invoker = on);

comment on view gio_deepwork_theo_gio is
  'Phút deepwork gộp theo (người × giờ trong ngày, giờ Việt Nam). Phiên dài được CHIA ra đúng các giờ nó thật sự diễn ra, không dồn vào giờ bấm nút. Cùng ngữ nghĩa giờ với gio_deepwork_theo_ngay: chỉ phiên song, trần 120 phút mỗi phiên, tính cả phiên gắn nhịp. Trần cứng 24 dòng mỗi người nên không phình theo thời gian. Nuôi ô GIỜ VÀNG ở khối Tổng quan deepwork (tab Timeline).';


-- ─── 3. Tự kiểm — cột `dat` phải ĐÚNG cả sáu dòng ─────────────────────────
-- ⚠️ Cố ý KHÔNG viết câu kiểm nào bắt một phép đếm trên dữ liệu người dùng
-- phải bằng 0: kiểu đó đúng ở lần chạy đầu rồi báo sai mãi mãi về sau, và
-- người đọc sẽ đi sửa dữ liệu lành cho con số xanh trở lại. Kho này đã dính
-- đúng một lần (mục 11 của bộ tự kiểm cũ).
select * from (values

  (1, 'Khung nhìn đã tồn tại',
   (select count(*) from pg_class
     where relkind = 'v' and relname = 'gio_deepwork_theo_gio') = 1),

  (2, 'security_invoker đang BẬT (không vượt mặt RLS)',
   (select count(*) from pg_class
     where relname = 'gio_deepwork_theo_gio'
       and 'security_invoker=on' = any(coalesce(reloptions, '{}'))) = 1),

  (3, 'Mọi giờ nằm trong 0..23 và mọi dòng đều có phút dương',
   coalesce((select bool_and(gio between 0 and 23 and phut > 0)
               from gio_deepwork_theo_gio), true)),

  -- ĐÂY LÀ CÂU KIỂM THẬT: đối chiếu với một phép tính ĐỘC LẬP trên bảng thô,
  -- không viết lại phép gộp của chính khung nhìn bằng cú pháp khác (viết lại
  -- thì nó luôn ra đúng kể cả khi cả hai cùng sai — bẫy đã dính một lần).
  -- Dung sai: mỗi dòng làm tròn lệch nhiều nhất nửa phút.
  (4, 'Tổng phút khớp tổng phút tính thẳng từ bảng phien_deepwork',
   (select abs(
      coalesce((select sum(phut) from gio_deepwork_theo_gio), 0)
      - coalesce((select sum(least(extract(epoch from (ket_thuc - bat_dau)) / 60, 180))
                    from phien_deepwork
                   where ket_qua = 'song' and ket_thuc is not null
                     and ket_thuc > bat_dau), 0)
    ) <= greatest(1, (select count(*) from gio_deepwork_theo_gio)))),

  (5, 'Tổng phút cũng khớp khung nhìn theo NGÀY (hai khung nhìn không đá nhau)',
   (select abs(
      coalesce((select sum(phut) from gio_deepwork_theo_gio), 0)
      - coalesce((select sum(phut) from gio_deepwork_theo_ngay), 0)
    ) <= greatest(1, (select count(*) from gio_deepwork_theo_gio)
                   + (select count(*) from gio_deepwork_theo_ngay)))),

  (6, 'Số dòng không vượt 24 mỗi người — đây là thứ giữ khung nhìn khỏi phình',
   (select count(*) from gio_deepwork_theo_gio)
     <= 24 * greatest(1, (select count(distinct nguoi_id) from gio_deepwork_theo_gio)))

) as t(muc, noi_dung, dat);


-- ─── 4. Nhìn thử kết quả (không phải phép kiểm, chỉ để xem cho vui) ────────
-- Bỏ dấu chú thích rồi chạy nếu muốn thấy khung giờ vàng của từng người.
--
-- select n.ten,
--        g.gio || '–' || (g.gio + 2) || 'h'                     as khung,
--        round((g.phut + coalesce(g2.phut, 0)) / 60.0, 1)       as gio_dw
--   from gio_deepwork_theo_gio g
--   join nguoi n on n.id = g.nguoi_id
--   left join gio_deepwork_theo_gio g2
--          on g2.nguoi_id = g.nguoi_id and g2.gio = (g.gio + 1) % 24
--  order by n.ten, (g.phut + coalesce(g2.phut, 0)) desc;
