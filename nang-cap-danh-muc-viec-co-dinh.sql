-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `chuc_nang`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — DANH MỤC VIỆC CỐ ĐỊNH CÓ MÃ BỀN
-- Gom theo KHỐI CHỨC NĂNG, không gom theo người.  (Tracy chốt 14/08/2026)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán TRỌN file → Run.
--            Chạy lại nhiều lần vô hại. File này TỰ ĐỨNG ĐƯỢC — không cần chạy
--            file nào trước nó (xem mục 0).
--            Chạy xong nhìn bảng cuối: cột `dat` phải ĐÚNG hết.
--
-- ─── BÀI TOÁN ─────────────────────────────────────────────────────────────
-- Việc cố định hôm nay KHÔNG có danh tính. Bảng `nhip` cấp MỘT DÒNG MỚI mỗi
-- tuần, và thứ duy nhất nối các tuần lại là chuỗi `ten`. Hệ quả đang xảy ra:
--
--   · Sửa tên một việc là LỊCH SỬ GIỜ CỦA NÓ TÁCH LÀM ĐÔI — khung nhìn
--     `nhip_thoi_gian` gom theo `n.ten` (nang-cap-tran-180-phut.sql:80-89).
--   · Gõ lệch một chữ ở tuần sau là bộ bước quy trình không chép sang được
--     (`chep_checklist_tuan_truoc` khớp theo tên, nang-cap-checklist.sql:108).
--   · Hai người cùng làm một việc của doanh nghiệp mà gõ tên khác nhau thì
--     thành hai việc.
--
-- Tracy gọi đúng tên bài: *"họ muốn dùng mã việc cũ nhưng lần trước ghi ko
-- chuẩn thì có thể sửa mà mình thì vẫn giữ được mã thay vì họ tạo 2 việc mới
-- nhưng bản chất cùng làm 1 thứ việc trong doanh nghiệp"*.
--
-- ─── LỜI GIẢI ─────────────────────────────────────────────────────────────
-- Một DANH MỤC việc cố định, mỗi việc một mã đi suốt đời. Dòng `nhip` hằng
-- tuần chỉ TRỎ về danh mục. Tên là NHÃN gắn trên mã, sửa nhãn không đụng mã.
--
-- Danh mục gom theo KHỐI CHỨC NĂNG chứ không theo người, vì việc cố định là
-- việc của một cái GHẾ trong doanh nghiệp, không phải của một con người. Ca
-- thật đang có: Hafi và Justin cùng khối Kinh doanh — họ phải dùng chung một
-- kho việc, không phải mỗi người gõ một bản. Người nghỉ việc thì kho ở lại
-- với ghế.
--
-- ─── DANH MỤC KHỞI ĐẦU RỖNG ───────────────────────────────────────────────
-- Tracy chốt: *"coi như ai vào dùng app từ bây giờ thì xây lại việc cố định
-- từ đầu đó, data cũ để mình phân tích thôi"*.
-- File này KHÔNG có câu chuyển dữ liệu nào cho việc cố định. Bảng
-- `danh_muc_nhip` (144 dòng seed — chú thích schema.sql:79 ghi "156", SAI, đã
-- đếm lại chính file seed ngày 14/08) KHÔNG được đụng tới — nó xếp theo một sơ đồ
-- tổ chức đã không còn (Bán hàng · Cung ứng · Marketing · Chuyên môn), và
-- Tracy nói thẳng *"bảng đó mọi ng đã gọi tên đúng đâu"*.
-- Dòng `nhip` cũ GIỮ NGUYÊN TẠI CHỖ, `viec_id` để NULL vĩnh viễn, không
-- backfill, không xoá — chúng là data để phân tích.
--
-- ⚠️ NGOẠI LỆ CÓ CHỦ Ý ở mục 2: chép `nguoi.vai` sang mã chức năng. Đây KHÔNG
-- phải "data cũ" theo nghĩa Tracy cấm — đó là phân công nhân sự ĐANG HIỆU LỰC,
-- chính Tracy điền tay lên Supabase ngày 10/08 và xác nhận lại 14/08. Bắt khai
-- lại là bắt gõ lại thứ đã đúng.
--
-- ─── TÊN HIỂN THỊ ĐỌC TỪ ĐÂU (Tracy chốt phương án iii) ────────────────────
-- Tên sống ở DANH MỤC. Mọi chỗ người dùng NHÌN THẤY đều đọc tên từ đó — sửa
-- một lần là sạch ở mọi tuần, kể cả tuần đã qua. Vì Tracy nói *"lần trước GHI
-- KO CHUẨN thì có thể sửa"*: đây là chữa NHÃN, mà chữa nhãn thì phải sạch ở
-- mọi chỗ nhìn thấy, không thì người ta tưởng sửa không ăn rồi sửa lại lần nữa.
-- `nhip.ten` vẫn giữ BẢN CHỤP tên tại tuần đó, nhưng chỉ làm DẤU VẾT KIỂM
-- TOÁN — không phải thứ bày lên màn. Ai đổi hẳn NGHĨA của việc thì nên khai
-- việc mới, đừng đổi tên.
-- ============================================================================


-- ═══ 0. TỰ ĐỨNG ĐƯỢC — hai thứ file khác lẽ ra tạo ═════════════════════════
-- Mục 5 dưới đây đọc `nhip.thoi_luong_du_kien`; mục 6 đọc bảng `muc_viec`.
-- Nếu hai thứ ấy chưa có trên máy chủ thì `create function` VẪN THÀNH CÔNG
-- (thân plpgsql chỉ biên dịch lúc chạy lần đầu), bảng tự kiểm VẪN ĐÚNG HẾT,
-- rồi NGƯỜI ĐẦU TIÊN gõ một việc là cả tab Việc cố định chết với một dòng lỗi
-- 42703 bằng tiếng Anh. Đúng loại lỗi mà bảng tự kiểm sinh ra để bắt, lại lọt
-- qua chính bảng tự kiểm. Nên tạo luôn ở đây cho chắc.
alter table nhip add column if not exists thoi_luong_du_kien smallint;
alter table nhip drop constraint if exists nhip_du_kien_hop_le;
alter table nhip add  constraint nhip_du_kien_hop_le
  check (thoi_luong_du_kien is null or thoi_luong_du_kien between 1 and 1440);

comment on column nhip.thoi_luong_du_kien is
  'Thời gian dự kiến cho MỘT LƯỢT của TUẦN NÀY, đơn vị PHÚT. NULL = chưa khai. '
  'Bỏ trống thì trigger nhip_dong_dau lấy con số mặc định từ danh mục.';


-- ═══ 1. KHỐI CHỨC NĂNG — sáu cái ghế, mỗi cái một mã ═══════════════════════
-- Vì sao phải là BẢNG chứ không dùng thẳng chuỗi `nguoi.vai`: danh mục việc
-- gom theo chức năng, mà gom theo một chuỗi chữ tự do thì sửa "Trải nghiệm
-- khách hàng" thành "Trải nghiệm KH" một lần là CẢ KHO VIỆC của Sydney rơi
-- khỏi tay cô ấy, im lặng. Đúng cái hố file này sinh ra để trèo ra khỏi — nên
-- áp cùng một nguyên lý cho cả chức năng.
create table if not exists chuc_nang (
  id      smallint generated always as identity primary key,
  ten     text not null unique,
  thu_tu  smallint not null default 99
);

comment on table chuc_nang is
  'Sáu khối chức năng của ROVA. Việc cố định thuộc về CHỨC NĂNG, không thuộc '
  'về người — người nghỉ thì kho việc ở lại với ghế.';

-- Sáu tên chép ĐÚNG chữ đang nằm trong cột `nguoi.vai` trên máy chủ (bản sao
-- lưu 2026-08-12). Sai một chữ là câu chép ở mục 2 không khớp được ai.
insert into chuc_nang (ten, thu_tu) values
  ('CEO',                    1),
  ('Vận hành',               2),
  ('Sản phẩm',               3),
  ('Kinh doanh',             4),
  ('Tài chính',              5),
  ('Trải nghiệm khách hàng', 6)
on conflict (ten) do nothing;


-- ═══ 2. NGƯỜI TRỎ VỀ CHỨC NĂNG BẰNG MÃ ═════════════════════════════════════
alter table nguoi add column if not exists chuc_nang_id smallint
  references chuc_nang (id) on delete set null;

comment on column nguoi.chuc_nang_id is
  'Khối chức năng của người này. Cột chữ `vai` GIỮ NGUYÊN làm nhãn hiển thị '
  'cũ, nhưng mọi thứ cần DANH TÍNH thì dùng cột này.';

-- Chép từ `nguoi.vai` — chỉ điền vào ô đang trống nên chạy lại vô hại, và
-- không đè lên thứ ai đó đã sửa tay.
update nguoi n
   set chuc_nang_id = c.id
  from chuc_nang c
 where n.chuc_nang_id is null
   and lower(btrim(n.vai)) = lower(btrim(c.ten));


-- ═══ 3. DANH MỤC VIỆC CỐ ĐỊNH ══════════════════════════════════════════════
create table if not exists viec_co_dinh (
  id            bigint generated always as identity primary key,
  chuc_nang_id  smallint not null references chuc_nang (id),
  ten           text not null check (btrim(ten) <> ''),
  -- Khoá so trùng. Cột SINH nên không bao giờ lệch khỏi `ten`; dùng đúng phép
  -- chuẩn hoá `lower(btrim())` đã có ở `chep_checklist_tuan_truoc` — đừng đẻ
  -- luật so tên thứ hai trong cùng một kho.
  ten_chuan     text generated always as (lower(btrim(ten))) stored,
  don_vi        text not null default 'Lần/ngày',
  -- Con số mặc định cho một lượt. Dòng `nhip` hằng tuần chép về lúc sinh ra,
  -- rồi tuần ấy sửa riêng được mà không đụng mặc định.
  thoi_luong_du_kien smallint
    check (thoi_luong_du_kien is null or thoi_luong_du_kien between 1 and 1440),
  -- CHO NGHỈ thay vì XOÁ. Đây là đường DUY NHẤT dọn danh sách mà không mất mã;
  -- xoá thì đứt luôn lịch sử của mọi tuần đã trỏ về nó.
  dang_dung     boolean not null default true,
  ngay_cho_nghi timestamptz,
  tao_boi       uuid references nguoi (id) on delete set null,
  tao_luc       timestamptz not null default now(),
  -- Chặn đúng cái Tracy sợ: "2 việc mới nhưng bản chất cùng 1 việc".
  -- CỐ Ý KHÔNG thêm `where dang_dung`: nếu chỉ chặn trong đám đang dùng thì gõ
  -- lại tên một việc đã cho nghỉ sẽ đẻ MÃ THỨ HAI cho cùng một việc — thua
  -- đúng ván bài file này sinh ra để thắng.
  unique (chuc_nang_id, ten_chuan)
);

comment on table viec_co_dinh is
  'Danh mục việc cố định của từng khối chức năng. Mỗi việc MỘT MÃ đi suốt đời; '
  'tên chỉ là nhãn gắn trên mã, sửa nhãn không đụng mã. Khởi đầu RỖNG — Tracy '
  'chốt 14/08 xây lại từ đầu, không mang data cũ sang.';

create index if not exists viec_theo_chuc_nang
  on viec_co_dinh (chuc_nang_id, dang_dung);


-- ═══ 4. NHỊP HẰNG TUẦN TRỎ VỀ DANH MỤC ═════════════════════════════════════
-- NULL VĨNH VIỄN: dòng cũ không backfill (chốt "xây lại từ đầu"), nên mọi truy
-- vấn phía dưới đều phải sống được với NULL. Đã lần từng câu.
alter table nhip add column if not exists viec_id bigint;

-- `no action` chứ KHÔNG `restrict`: hai cái chỉ khác nhau ở chỗ `restrict`
-- kiểm NGAY, còn `no action` hoãn tới cuối câu lệnh. Xoá một dòng `nguoi` kích
-- hoạt hai nhánh cascade (`viec_co_dinh.tao_boi` và `nhip.nguoi_id`); với
-- `restrict` thì nhánh chạy trước có thể làm nhánh sau nổ, tức KHÔNG XOÁ ĐƯỢC
-- MỘT NGƯỜI khỏi hệ thống. `no action` vẫn kêu lên khi thật sự còn tham chiếu
-- — giữ nguyên mọi lợi ích, bỏ đi cái bẫy.
-- Cố ý KHÔNG `cascade`: `so_ngay` cascade theo `nhip` (schema.sql:110), nên
-- cascade ở đây là xoá một dòng danh mục quét sạch số liệu của mọi tuần.
-- Cố ý KHÔNG `set null`: nó cắt lịch sử trong IM LẶNG.
alter table nhip drop constraint if exists nhip_viec_fk;
alter table nhip add  constraint nhip_viec_fk
  foreign key (viec_id) references viec_co_dinh (id) on delete no action;

-- Một việc chỉ được chiếm MỘT ô trong một tuần. Không có nó thì `diem_ngay`
-- lấy trung bình trên cả 5 dòng (schema.sql:188-204) → việc xếp trùng ăn hai
-- suất trong điểm ngày. Chỉ mục RIÊNG PHẦN nên dòng cũ NULL không bị đụng.
create unique index if not exists nhip_moi_tuan_mot_viec
  on nhip (nguoi_id, tuan_bat_dau, viec_id)
  where viec_id is not null;

-- ⛔ KHOÁ `unique (nguoi_id, tuan_bat_dau, thu_tu)` cũ GIỮ NGUYÊN.
-- `thu_tu` là Ô SỐ MẤY trên lưới, không phải danh tính việc: `veTuan` dựng lưới
-- bằng nó, `luuNhip`/`xoaNhip` gọi theo nó. Gỡ là gãy nguyên tab.


-- ═══ 5. ĐÓNG DẤU LÚC SINH DÒNG NHỊP ════════════════════════════════════════
-- Làm ba việc, đều BEFORE INSERT vì phải sửa được `new`:
--   ① canh việc được chọn đúng là việc của khối chức năng người đó đang giữ;
--   ② đóng dấu bản chụp tên vào `nhip.ten` (dấu vết kiểm toán);
--   ③ chưa khai dự kiến thì lấy con số mặc định của danh mục.
--
-- Không `security definer`: hàm chỉ ĐỌC `viec_co_dinh`/`nguoi`, mà cả hai đều
-- đã cho mọi thành viên đọc. Quyền của chính người đang ghi là đủ.
create or replace function nhip_dong_dau()
returns trigger language plpgsql set search_path = public
as $$
declare v_ten text; v_dk smallint; v_cn_viec smallint; v_cn_nguoi smallint;
begin
  if new.viec_id is null then
    return new;                       -- đường cũ: gõ tay, không qua danh mục
  end if;

  select ten, thoi_luong_du_kien, chuc_nang_id
    into v_ten, v_dk, v_cn_viec
    from viec_co_dinh where id = new.viec_id;
  if not found then
    raise exception 'Việc cố định không có trong danh mục.';
  end if;

  select chuc_nang_id into v_cn_nguoi from nguoi where id = new.nguoi_id;
  if v_cn_nguoi is null or v_cn_nguoi <> v_cn_viec then
    raise exception 'Việc này thuộc khối chức năng khác — không xếp vào tuần của người này được.';
  end if;

  new.ten := v_ten;
  if new.thoi_luong_du_kien is null then
    new.thoi_luong_du_kien := v_dk;
  end if;
  return new;
end $$;

drop trigger if exists nhip_dong_dau_tr on nhip;
create trigger nhip_dong_dau_tr
  before insert on nhip
  for each row execute function nhip_dong_dau();

-- ── Chặn sửa tên ĐI CỬA SAU ────────────────────────────────────────────────
-- Không có chốt này thì đường ghi `nhip.ten` vẫn mở toang (`luuNhip` →
-- `update nhip set ten`), và hậu quả rất hiểm: người ta sửa tên trên lưới,
-- `nhip.ten` đổi mà danh mục KHÔNG đổi, tuần sau dòng mới đóng dấu lại TÊN CŨ
-- SAI CHÍNH TẢ. Sửa. Tuần sau lại về. 52 lần một năm — đúng bệnh file này chữa,
-- tái phát ở cột `ten`. Kêu lên còn hơn để nó trôi ngược.
create or replace function nhip_chan_sua_ten()
returns trigger language plpgsql set search_path = public
as $$
begin
  if new.viec_id is not null and new.ten is distinct from old.ten then
    raise exception 'Đổi tên việc cố định phải sửa ở danh mục (viec_co_dinh), không sửa trên dòng của tuần.';
  end if;
  return new;
end $$;

drop trigger if exists nhip_chan_sua_ten_tr on nhip;
create trigger nhip_chan_sua_ten_tr
  before update on nhip
  for each row execute function nhip_chan_sua_ten();


-- ═══ 6. BỘ BƯỚC QUY TRÌNH CHÉP SANG TUẦN MỚI — theo MÃ ═════════════════════
-- Thay bản khớp-theo-TÊN ở `nang-cap-checklist.sql` mục 5.
-- Hai tầng, và tầng 2 có RÀO Ở CẢ HAI ĐẦU:
--   · tầng 1 — dòng mới CÓ mã  → tìm dòng cũ CÙNG MÃ. Đây là đường chính.
--   · tầng 2 — dòng mới KHÔNG mã → mới xét theo tên, và chỉ với nguồn cũng
--     không mã.
-- Rào `new.viec_id is null` ở điều kiện vào tầng 2 là BẮT BUỘC. Thiếu nó thì
-- một việc mới toanh trong danh mục sẽ HÚT bộ bước của bất kỳ dòng đời cũ nào
-- trùng tên — tức một cây cầu vĩnh viễn bắc sang data trước ngày cắt, đúng thứ
-- chốt "xây lại từ đầu" cấm. Có rào thì tầng 2 TỰ TẮT khi app đã gửi mã.
create or replace function chep_checklist_tuan_truoc()
returns trigger language plpgsql security definer set search_path = public
as $$
declare nguon bigint;
begin
  if new.viec_id is not null then
    select n.id into nguon
      from nhip n
     where n.nguoi_id = new.nguoi_id
       and n.viec_id  = new.viec_id
       and n.id      <> new.id
       and exists (select 1 from muc_viec m where m.nhip_id = n.id)
     order by n.tuan_bat_dau desc, n.id desc
     limit 1;
  else
    select n.id into nguon
      from nhip n
     where n.nguoi_id = new.nguoi_id
       and n.viec_id is null
       and lower(btrim(n.ten)) = lower(btrim(new.ten))
       and n.id <> new.id
       and exists (select 1 from muc_viec m where m.nhip_id = n.id)
     order by n.tuan_bat_dau desc, n.id desc
     limit 1;
  end if;

  if nguon is not null then
    insert into muc_viec (nhip_id, noi_dung, thu_tu)
    select new.id, m.noi_dung, m.thu_tu
      from muc_viec m where m.nhip_id = nguon
     order by m.thu_tu;
  end if;
  return new;
end $$;

comment on function chep_checklist_tuan_truoc() is
  'Chép bộ bước sang dòng nhip mới. Khớp theo MÃ việc khi có; dòng đời cũ '
  '(viec_id NULL) mới rơi về khớp theo tên. Tầng tên tự tắt khi app gửi mã.';


-- ═══ 7. KẾ THỪA DỰ KIẾN — gỡ bản khớp-theo-TÊN ═════════════════════════════
-- `nang-cap-du-kien-viec-co-dinh.sql` từng cài một trigger khớp theo TÊN, và
-- file ấy tự khai đó là BẢN BẮC CẦU "có ngày gỡ". Hôm nay là ngày ấy: mục 5
-- lấy con số thẳng từ danh mục theo MÃ, chính xác hơn và không đoán mò.
-- Gỡ bằng `if exists` nên chạy được cả khi file kia chưa từng chạy.
drop trigger  if exists nhip_ke_thua_du_kien on nhip;
drop function if exists ke_thua_du_kien_viec_co_dinh();


-- ═══ 8. KHUNG NHÌN — giờ thật, gom theo MÃ ═════════════════════════════════
-- `drop` rồi tạo lại, KHÔNG `create or replace`: view mới đổi bộ cột, mà
-- `create or replace view` chỉ cho THÊM cột ở đuôi. Dùng `replace` thì hai file
-- cũ (`nang-cap-deepwork-tu-do.sql`, `nang-cap-tran-180-phut.sql`) mất tính
-- chạy-lại-được vĩnh viễn — chạy lại chúng sẽ nổ "cannot drop columns from
-- view". Drop rồi tạo lại thì cả hai file kia vẫn chạy lại được như cũ.
drop view if exists nhip_thoi_gian;
create view nhip_thoi_gian as
select
  -- Khoá gom CÓ TIỀN TỐ. Không có tiền tố thì việc mã 12 rơi chung rổ với một
  -- dòng đời cũ tên "12".
  case when n.viec_id is not null
       then 'ma:'  || n.viec_id::text
       else 'ten:' || lower(btrim(n.ten)) end            as khoa,
  n.viec_id,
  n.nguoi_id,
  -- Tên hiển thị đọc từ DANH MỤC khi có mã (Tracy chốt phương án iii): sửa tên
  -- một lần là mọi tuần kể cả tuần đã qua hiện tên mới.
  coalesce(v.ten, max(n.ten))                            as ten,
  count(p.id)                                            as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as tong_phut,
  round(avg(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut_trung_binh,
  max(n.tuan_bat_dau)                                    as tuan_gan_nhat
from nhip n
join phien_deepwork p on p.nhip_id = n.id and p.ket_qua = 'song'
left join viec_co_dinh v on v.id = n.viec_id
group by 1, 2, 3, v.ten;

-- BẮT BUỘC sau mỗi lần dựng lại view — mất dòng này là cả đội đọc được số của
-- nhau, vượt mặt RLS. Cùng lý do nang-cap-tran-180-phut.sql:161 phải lặp lại nó.
alter view nhip_thoi_gian set (security_invoker = on);

comment on view nhip_thoi_gian is
  'Giờ deepwork thật của việc cố định. ⚠️ CONSUMER PHẢI KHOÁ THEO CỘT `khoa`, '
  'KHÔNG theo `ten` — một việc có mã và một dòng đời cũ trùng tên cho ra HAI '
  'dòng cùng `ten`. Đổi tên trong đời có mã thì lịch sử TỰ LIỀN; bắc sang đời '
  'cũ thì không, vì dòng NULL không có gì chứng minh là cùng một việc.';


-- ═══ 9. DANH MỤC KÈM SỐ LIỆU — thứ màn chọn việc đọc ═══════════════════════
-- ⚠️ App PHẢI lọc `chuc_nang_id` của chính người đang đăng nhập khi đọc khung
-- nhìn này. Không lọc thì ô "chọn trong list đã làm" bày ra kho việc của cả sáu
-- khối, bấm vào là trigger mục 5 ném lỗi.
create or replace view viec_co_dinh_da_dung as
select
  v.id, v.chuc_nang_id, v.ten, v.don_vi, v.thoi_luong_du_kien,
  v.dang_dung, v.ngay_cho_nghi,
  count(distinct n.id)      as so_tuan_da_dung,
  max(n.tuan_bat_dau)       as tuan_gan_nhat
from viec_co_dinh v
left join nhip n on n.viec_id = v.id
group by v.id;

alter view viec_co_dinh_da_dung set (security_invoker = on);


-- ═══ 10. QUYỀN ════════════════════════════════════════════════════════════
-- Chép khuôn `doc_nhip`/`ghi_nhip` (schema.sql:268, :275-276), nhưng dùng cặp
-- drop/create để chạy lại được — `schema.sql` dùng `create policy` trần nên
-- chạy lần hai là nổ.
alter table chuc_nang    enable row level security;
alter table viec_co_dinh enable row level security;

drop policy if exists doc_chucnang on chuc_nang;
create policy doc_chucnang on chuc_nang for select using (la_thanh_vien());
-- Không có policy GHI cho `chuc_nang`: sáu cái ghế là việc của Tracy, sửa
-- thẳng trên Supabase. Cùng lối với `nguoi`/`tieu_diem` (schema.sql:287-288).

drop policy if exists doc_viec on viec_co_dinh;
create policy doc_viec on viec_co_dinh for select using (la_thanh_vien());

-- GHI: ai giữ khối chức năng nào thì thêm/sửa danh mục của khối đó (Tracy chốt
-- 14/08). Không để một mình Tracy duyệt — như vậy Tracy thành nút cổ chai cho
-- mọi việc mới, giết luôn chính lựa chọn "tạo mới".
drop policy if exists ghi_viec on viec_co_dinh;
create policy ghi_viec on viec_co_dinh for all
  using      (chuc_nang_id = (select chuc_nang_id from nguoi where id = nguoi_id_dang_nhap()))
  with check (chuc_nang_id = (select chuc_nang_id from nguoi where id = nguoi_id_dang_nhap()));


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG HẾT ═════════════════════════════════════
select * from (values
  (1,  'bảng chuc_nang có đủ 6 khối',
   (select count(*) from chuc_nang) >= 6),

  (2,  'cả 7 người đã có mã chức năng',
   (select count(*) from nguoi where chuc_nang_id is null) = 0),

  (3,  'bảng viec_co_dinh có mặt',
   (select count(*) from information_schema.tables
     where table_schema = 'public' and table_name = 'viec_co_dinh') = 1),

  (4,  'nhip.viec_id có mặt và CHO PHÉP NULL',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nhip'
       and column_name = 'viec_id' and is_nullable = 'YES') = 1),

  (5,  'nhip.thoi_luong_du_kien có mặt (mục 0 lo, đừng bỏ)',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nhip'
       and column_name = 'thoi_luong_du_kien') = 1),

  (6,  'bảng muc_viec có mặt — mục 6 đọc nó',
   (select count(*) from information_schema.tables
     where table_schema = 'public' and table_name = 'muc_viec') = 1),

  /* tgtype là bộ cờ bit: 2 = BEFORE, 4 = INSERT, 16 = UPDATE. Hỏi thẳng bit
     chứ không chỉ hỏi "trigger có tồn tại không" — gắn nhầm thành AFTER thì
     trigger vẫn tồn tại đủ mọi mặt, chỉ có điều `new` sửa xong không ai nhận. */
  (7,  'trigger đóng dấu đúng là BEFORE INSERT',
   (select count(*) from pg_trigger
     where tgname = 'nhip_dong_dau_tr' and not tgisinternal
       and (tgtype & 2) = 2 and (tgtype & 4) = 4) = 1),

  (8,  'trigger chặn sửa tên đúng là BEFORE UPDATE',
   (select count(*) from pg_trigger
     where tgname = 'nhip_chan_sua_ten_tr' and not tgisinternal
       and (tgtype & 2) = 2 and (tgtype & 16) = 16) = 1),

  (9,  'trigger checklist cũ còn nguyên (file này chỉ thay RUỘT, không đá văng)',
   (select count(*) from pg_trigger
     where tgname = 'nhip_chep_checklist' and not tgisinternal) = 1),

  (10, 'trigger kế thừa dự kiến theo TÊN đã được gỡ',
   (select count(*) from pg_trigger
     where tgname = 'nhip_ke_thua_du_kien' and not tgisinternal) = 0),

  (11, 'khung nhìn nhip_thoi_gian có cột khoa',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'nhip_thoi_gian'
       and column_name = 'khoa') = 1),

  /* Bản đầu hỏi `count(*) >= 150` — SAI, và Tracy bắt được ngay lần chạy đầu
     (14/08). Câu ấy kiểm "file seed 156 dòng đã từng được nạp chưa", KHÔNG kiểm
     "file này có đụng vào bảng không". Máy chủ thật chưa bao giờ chạy
     `seed-danh-muc-nhip.sql` nên bảng rỗng, và dòng kiểm đỏ lên trong khi chẳng
     có gì sai. Bài học: phép kiểm phải hỏi ĐÚNG thứ mình muốn chứng minh —
     một phép kiểm đo nhầm thứ khác thì báo động của nó là báo động giả, mà báo
     động giả làm người ta thôi đọc cả bảng.
     Thứ file này thật sự phải chứng minh là: bảng cũ CÒN NGUYÊN CHỖ. Số dòng
     bao nhiêu không phải việc của nó. */
  (12, 'bảng danh_muc_nhip cũ còn nguyên chỗ (file này không xoá, không sửa)',
   (select count(*) from information_schema.tables
     where table_schema = 'public' and table_name = 'danh_muc_nhip') = 1),

  /* CHỈ ĐÚNG Ở LẦN CHẠY ĐẦU. Từ tuần thứ hai trở đi dòng này hoá đỏ là BÌNH
     THƯỜNG — lúc ấy đã có tuần cũ mang mã thật. Mốc ngày cứng chứ không dùng
     `hom_nay()`, để nó không thành một báo động giả vĩnh viễn (báo động giả
     vĩnh viễn thì người ta thôi đọc cả bảng). */
  (13, 'dòng nhip TRƯỚC 18/08/2026 không bị backfill  [chỉ đúng ở lần chạy đầu]',
   (select count(*) from nhip
     where viec_id is not null and tuan_bat_dau < date '2026-08-18') = 0)
) as t(so, muc, dat);


-- ═══ SỐ LIỆU THAM KHẢO — KHÔNG phải phép kiểm, không có đúng/sai ═══════════
-- Chạy xong liếc qua cho biết máy chủ đang ở đâu. Không dòng nào ở đây là lỗi.
select
  (select count(*) from chuc_nang)                             as so_khoi_chuc_nang,
  (select count(*) from nguoi)                                 as so_nguoi,
  (select count(*) from nguoi where chuc_nang_id is not null)  as nguoi_da_co_ma_chuc_nang,
  (select count(*) from viec_co_dinh)                          as so_viec_trong_danh_muc,
  (select count(*) from nhip where viec_id is not null)         as nhip_da_gan_ma,
  (select count(*) from nhip where viec_id is null)             as nhip_doi_cu_giu_nguyen,
  (select count(*) from danh_muc_nhip)                          as bang_goi_y_cu_con_bao_nhieu_dong;
