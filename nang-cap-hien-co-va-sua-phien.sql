-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `phien_deepwork.khai_tay`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-hien-co-va-sua-phien.sql                (Tracy giao 2026-08-11)
--
-- Chạy lại nhiều lần VÔ HẠI. Dán trọn file vào SQL Editor rồi Run.
-- Xong thì nhìn bảng cuối cùng: cột `dat` phải TRUE đủ cả sáu dòng.
--
-- Đây là phần MÁY CHỦ còn thiếu của hai việc:
--   ① Việc 53 — cờ dời hạn phải ĐI TỚI ĐƯỢC giao diện
--   ② Việc 38 — cho sửa bản ghi phiên deepwork
--
-- ⚠️ File này KHÔNG thay `nang-cap-co-doi-han-va-trang-thai.sql` — bạn đã chạy
--    file đó rồi (đo lúc 12/08: ba cột `han_goc·so_lan_doi_han·ngay_troi` đã có
--    trên bảng `tieu_diem`, và trigger đã ghi thật cho O21 và O22). File này
--    chỉ vá hai chỗ file kia chưa với tới.
-- ════════════════════════════════════════════════════════════════════════════


-- ─── 1. TRIGGER DỜI HẠN PHẢI BẮT CẢ LÚC GIEO ────────────────────────────────
--
-- Bệnh: `tg_doi_han` đang là `before update` thuần. Cam kết gieo ra mà ĐÃ có
-- hạn ngay từ đầu thì không lệnh update nào chạy, nên `han_goc` nằm NULL vĩnh
-- viễn — và một cam kết không có hạn gốc thì không bao giờ đếm được là dời hạn,
-- dù sau đó nó bị đẩy lùi bao nhiêu lần.
--
-- Vì sao hôm nay chưa ai dính: từ trước tới giờ cam kết được gieo trống hạn rồi
-- mới đặt hạn sau, tức đi qua đường UPDATE nên nhánh cũ đỡ được. Nhưng mốc
-- `81533c8` đã làm ô hạn thành BẮT BUỘC lúc gieo — từ nay cam kết mới ra đời
-- là đã mang hạn sẵn, đi thẳng vào đúng cái lỗ này.
--
-- `TG_OP = 'INSERT'` phải chốt TRƯỚC mọi câu chạm `old`: lúc chèn thì `old`
-- chưa được gán, đụng vào là Postgres ném 'record old is not assigned yet' và
-- chết luôn cả đường gieo cam kết.

create or replace function ghi_doi_han() returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    -- Lần gieo đầu: hạn đặt lúc này LÀ hạn gốc. Chưa hứa thì chưa lỡ hẹn,
    -- nên bộ đếm mở màn ở 0 và không có gì để cộng.
    new.han_goc        := new.han;
    new.so_lan_doi_han := 0;
    new.ngay_troi      := 0;
    return new;
  end if;

  -- Ba dòng này là chỗ cả cơ chế đứng hay đổ: bộ đếm CHỈ do máy chủ ghi.
  -- Mọi giá trị app gửi lên cho ba cột đó đều bị bỏ, nên không ai gột được
  -- vết dời hạn của mình bằng cách gửi thẳng một câu update.
  new.so_lan_doi_han := coalesce(old.so_lan_doi_han, 0);
  new.ngay_troi      := coalesce(old.ngay_troi, 0);
  new.han_goc        := old.han_goc;

  -- TỰ VÁ VẠCH XUẤT PHÁT cho dòng ra đời trong quãng trigger chưa bắt lúc gieo.
  -- Không thể vá bằng một câu `update ... set han_goc = han` chạy từ ngoài: câu
  -- ấy kích hoạt chính trigger này, và ba dòng ngay trên vừa gán han_goc về
  -- old.han_goc tức NULL — vá xong bị chính mình xoá, không dòng nào đổi.
  -- Chuyển câu update lên TRƯỚC khối create trigger cũng không cứu được, vì bản
  -- trigger CŨ đã nằm sẵn trên bảng từ hôm qua và nó cũng làm đúng như vậy.
  --
  -- Lấy `old.han` chứ KHÔNG phải `new.han`: nếu chính lệnh update này đang dời
  -- hạn thì hạn gốc là cái CŨ. Lấy cái mới là xoá đúng cái vết vừa định đếm,
  -- và nhánh `elsif` bên dưới sẽ cộng một lần dời vào một vạch xuất phát sai.
  if new.han_goc is null and old.han is not null then
    new.han_goc := old.han;
  end if;

  if old.han is null and new.han is not null then
    -- Lần đầu đặt hạn KHÔNG phải dời hạn. Chưa hứa thì chưa lỡ hẹn.
    new.han_goc := new.han;

  elsif old.han is not null and new.han is not null and new.han > old.han then
    -- Chỉ đếm khi ĐẨY RA XA. Kéo hạn về gần là chuyện tốt, phạt nó thì
    -- người ta sẽ không bao giờ dám rút ngắn một lời hứa nào nữa.
    new.so_lan_doi_han := new.so_lan_doi_han + 1;
    new.ngay_troi      := new.ngay_troi + (new.han - old.han);
  end if;

  return new;
end $$ language plpgsql;

drop trigger if exists tg_doi_han on tieu_diem;
create trigger tg_doi_han before insert or update on tieu_diem
  for each row execute function ghi_doi_han();

-- Vá cho những cam kết đã lỡ ra đời trong quãng trigger chưa bắt lúc gieo.
-- Hôm nay đo được 0 dòng như vậy; để đây phòng lúc bạn chạy file này thì đã có.
update tieu_diem set han_goc = han where han is not null and han_goc is null;


-- ─── 2. KHUNG NHÌN tien_do_o PHẢI MANG THEO BA CỘT CỜ ───────────────────────
--
-- Vì sao bắt buộc: app KHÔNG đọc thẳng bảng `tieu_diem` để vẽ cam kết. Nó đọc
-- khung nhìn này (index.html dòng 2689 · 2729 · 5366 · 5389, đều `select('*')`).
-- Khung nhìn kê từng tên cột một, nên ba cột mới không tự chảy qua — chưa dựng
-- lại thì cờ dời hạn có đủ dữ liệu trên máy chủ mà vĩnh viễn không tới được mắt
-- người dùng.
--
-- Phải XOÁ rồi tạo lại chứ không `create or replace`: lệnh đó chỉ cho THÊM cột
-- vào CUỐI danh sách, chèn vào giữa là Postgres báo `42P16`.
--
-- Thân giữ NGUYÊN VĂN bản ở `nang-cap-output-cam-ket.sql` dòng 148–181, thêm ba
-- cột cờ vào CẢ `select` LẪN `group by`. Một sửa nữa nói rõ ở chỗ nó nằm.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,

  -- Năm cột output (11/08) — app đọc thẳng từ đây, không hỏi bảng thô lần nữa.
  o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,

  -- Ba cột cờ dời hạn (12/08, việc 53). Máy chủ ghi, app chỉ đọc.
  o.han_goc, o.so_lan_doi_han, o.ngay_troi,

  -- Ba cột cũ, giữ nguyên: đếm CÂY (task đã có phiên deepwork thật).
  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  -- Hai cột đếm TASK, viết bằng truy vấn con vô hướng — KHÔNG thêm `left join`
  -- thứ hai vào `task`, vì nó sẽ nhân chéo với `vuon_cay` đang join sẵn ở dưới
  -- và làm ba cột cây phía trên phồng lên sai bét.
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma)     as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.trang_thai = 'Done')                                 as so_xong,
  -- Ô "còn mở" phải khớp ĐÚNG cái NHÓM KHO mà bảng cam kết vẽ ra (index.html).
  --
  -- ⚠️ SỬA 12/08: bản cũ lọc ('Confirm','Doing','Miss','Chua_xong','Nghen').
  --    `Miss` và `Nghen` đã bị xoá khỏi CSDL ở `nang-cap-co-doi-han-va-trang-
  --    thai.sql` mục 1, nên hai giá trị đó nay không đếm được gì; giá trị đang
  --    chạy cho việc nghẽn là `Blocked`.
  --
  --    NHƯNG CỐ Ý KHÔNG THÊM `Blocked` VÀO ĐÂY. Bản thảo đầu có thêm, với lý lẽ
  --    "việc đang nghẽn là loại cần thấy nhất". Lý lẽ ấy đúng khi việc nghẽn
  --    không có chỗ nào lộ ra — và nó vừa hết đúng: từ 12/08 bảng cam kết có
  --    hẳn một nhóm `🚧 Đang nghẽn` LUÔN XỔ nằm trên cùng thẻ, tức việc nghẽn
  --    đã là thứ đập vào mắt trước nhất rồi.
  --    Cái giá thì lại vừa xuất hiện: `NHOM_TASK` xếp việc `Blocked` vào nhóm
  --    Nghẽn chứ không vào nhóm Kho, nên đếm nó vào đây là đầu thẻ báo "2 trong
  --    kho" mà đếm dòng dưới ra 1. Một con số không khớp danh sách ngay cạnh nó
  --    thì hỏng hơn là thiếu một con số.
  --    (`Chua_xong` thì giữ: việc ấy không hẹn ngày VẪN nằm trong nhóm Kho.)
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Confirm','Doing','Chua_xong'))
                                                                  as so_kho

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
         o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
         o.han_goc, o.so_lan_doi_han, o.ngay_troi;

-- ⚠️ BẮT BUỘC, và đây là dòng dễ mất nhất cả file. `drop view` xoá luôn thiết
-- lập này; quên bật lại thì khung nhìn chạy bằng quyền người TẠO nó, tức vượt
-- mặt RLS và cả bảy người đọc được cam kết của nhau — mà KHÔNG có lỗi nào báo
-- ra, mọi thứ trông vẫn như chạy đúng. Bài tự kiểm ④ dưới đây soi đúng chỗ này.
alter view tien_do_o set (security_invoker = on);

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm MỌI task; năm cột output_* / da_nhan_* là phần thu hoạch khi đóng cam kết (việc 49); ba cột han_goc / so_lan_doi_han / ngay_troi là cờ dời hạn do trigger tg_doi_han ghi (việc 53).';


-- ─── 3. ĐÁNH DẤU PHIÊN DEEPWORK KHAI BẰNG TAY ───────────────────────────────
--
-- Việc 38 cho người ta khai bù một phiên đã làm mà quên bấm nút. Đó là việc
-- đúng — công đã bỏ ra thì phải được ghi. Nhưng một phiên KHAI ra và một phiên
-- ĐO được là hai loại bằng chứng khác hẳn nhau, gộp chung vào một cột là mất
-- luôn khả năng phân biệt về sau, không cách nào dựng lại.
--
-- Một cột boolean, mặc định false — nên mọi phiên đã có từ trước tự động đứng
-- đúng chỗ của nó là phiên đo được, không phải chuyển một dòng nào.
--
-- ⚠️ CỐ Ý KHÔNG đụng trigger `trg_kiem_cay_song`. Nó là `before update` thuần
--    (schema.sql:179–181), mà khai tay đi đường INSERT nên không chạm nó. Đổi
--    nó thành `before insert or update` là chạm đúng đường mà nút ▶ Bắt đầu và
--    cả ba nhánh cửa ra deepwork đang đi qua — rủi ro lớn, đổi lấy một cái chặn
--    mà việc 38 không cần.
--    Hệ quả phải nhận và nói thẳng: phiên khai tay KHÔNG bị luật 30 phút soi.
--    Người khai bù có thể khai một phiên 'song' dài bao nhiêu tuỳ ý. Cột
--    `khai_tay` chính là chỗ chịu trách nhiệm cho chuyện đó — nó làm việc khai
--    thành thứ NHÌN THẤY ĐƯỢC, thay vì cấm bằng một luật dễ đi vòng.

alter table phien_deepwork add column if not exists khai_tay boolean not null default false;

comment on column phien_deepwork.khai_tay is
  'true = phiên do người tự khai bù sau khi đã làm, không phải phiên đồng hồ đo được. Không bị luật 30 phút của trg_kiem_cay_song soi, nên phải hiện rõ ở mọi chỗ bày phiên ra.';


-- ─── 4. TỰ KIỂM — sáu dòng, `dat` phải TRUE hết ─────────────────────────────

select 'Trigger tg_doi_han bắt CẢ lúc gieo lẫn lúc sửa' as muc,
       (select count(*) from pg_trigger
         where tgname = 'tg_doi_han' and not tgisinternal
           and (tgtype & 4) > 0 and (tgtype & 16) > 0) = 1 as dat
union all
select 'Không còn cam kết nào có hạn mà thiếu hạn gốc',
       not exists (select 1 from tieu_diem where han is not null and han_goc is null)
union all
select 'Khung nhìn tien_do_o đã mang đủ ba cột cờ',
       (select count(*) from information_schema.columns
         where table_name = 'tien_do_o'
           and column_name in ('han_goc','so_lan_doi_han','ngay_troi')) = 3
union all
select 'tien_do_o CHẠY BẰNG QUYỀN NGƯỜI ĐỌC (không vượt mặt RLS)',
       coalesce((select 'security_invoker=on' = any(reloptions) from pg_class
                  where relname = 'tien_do_o'), false)
union all
select 'Bảng phien_deepwork đã có cột khai_tay',
       exists (select 1 from information_schema.columns
                where table_name = 'phien_deepwork' and column_name = 'khai_tay')
union all
select 'Ô kho KHÔNG đếm việc đang Nghẽn (nó có nhóm riêng trên bảng cam kết)',
       (select pg_get_viewdef('tien_do_o'::regclass)) not like '%Blocked%';


-- PostgREST giữ một bản chụp lược đồ trong bộ nhớ. Không nhắc thì cột mới và
-- khung nhìn vừa dựng lại có thể vẫn trả 404 hoặc 42703 trong ít phút.
notify pgrst, 'reload schema';
