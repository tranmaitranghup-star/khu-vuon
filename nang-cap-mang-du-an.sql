-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: bảng `cum_trang_thai_task`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-mang-du-an.sql            (Tracy giao 2026-08-25 — mảng dự án đợt 1)
--
-- Dán trọn file vào Supabase › SQL Editor › Run. CHẠY LẠI NHIỀU LẦN VÔ HẠI.
-- Xong thì nhìn bảng cuối cùng: mọi dòng phải ✅.
--
-- ĐẶC TẢ: production/du-an/so-do-mang-du-an.html (bản khung 2, 25/08) và
--         production/du-an/prompt-dung-mang-du-an-v2.md
--
-- ─── ĐO MÁY CHỦ THẬT TRƯỚC KHI VIẾT (25/08, qua REST /rest/v1) ──────────────
-- Ghi chú của prompt nói "chưa ai biết file .sql nào đã chạy thật". Nay đã đo:
--
--   ✅ ĐÃ CÓ trên máy chủ  : bảng `muc_tieu` (ten · ket_qua · pham_vi ·
--                            phong_ban · han · xong · ngay_xong · nguoi_id ·
--                            tao_luc) · cột `tieu_diem.muc_tieu_id` ·
--                            khung nhìn `tien_do_muc_tieu` · khung nhìn
--                            `tien_do_o` · cột `nguoi.so_cam_ket_toi_da`
--        → tức `nang-cap-cam-ket-va-muc-tieu.sql` (08/08) ĐÃ CHẠY THẬT.
--
--   ❌ CHƯA CÓ             : `task.muc_tieu_id` (42703) · bảng `moc_du_an`
--                            (PGRST205) · `tien_do_o.muc_tieu_id` (42703) ·
--                            `nguoi.so_du_an_toi_da` (42703) · mọi cột hồ sơ
--                            dự án trên `muc_tieu` (loai · trang_thai · link_tai_lieu …)
--
-- Nên PHẦN LỚN file này là NỐI, không phải dựng. Không câu nào dựng lại thứ
-- đã có; mọi câu đều `if not exists` hoặc `drop … if exists` rồi tạo lại.
--
-- ─── BỐN THỨ FILE NÀY KHÔNG ĐỤNG (ranh giới đợt 1) ─────────────────────────
--   · Không gỡ, không sửa một hàng rào nào của tầng cam kết:
--     `kiem_tran_cam_ket` · `mot_hat_song_moi_luong` · `ghi_doi_han` ·
--     `kiem_o_xong` · `kiem_output_cam_ket` · `nhan_cam_ket`.
--   · Không nới chính sách ghi `ghi_task` — giao việc cho người khác là một
--     đợt riêng, có bàn về quyền trước.
--   · Không dựng bảng việc thứ hai. Dự án có danh sách việc bằng MỘT CỘT trên
--     chính bảng `task`.
--   · Không thêm ô nào cho người gõ phần trăm.
-- ════════════════════════════════════════════════════════════════════════════

begin;


-- ════════════════════════════════════════════════════════════════════════════
-- 1. `muc_tieu` LỚN LÊN THÀNH HỒ SƠ DỰ ÁN
-- ════════════════════════════════════════════════════════════════════════════
-- Tracy chốt: "Dự án = một dòng của bảng muc_tieu mang nhãn loại dự án. Thêm
-- nhãn, không thêm tầng." Nên đây là ALTER, không phải CREATE.
--
-- ⚠️ CỐ Ý KHÔNG THÊM CỘT NGÀY BẮT ĐẦU. Ngày bắt đầu suy ra từ mốc sớm nhất và
--    cam kết gieo sớm nhất (khung nhìn ở mục 7 tính sẵn). Bài học Nhóm 10 của
--    bản nghiên cứu chín app: "ngày dự án TỰ SUY từ việc con" — bớt một ô phải
--    nuôi là bớt một chỗ để hai con số lệch nhau.

-- 1a. Nhãn loại — dự án nào là dự án, cái nào chỉ là việc chạy đều
alter table muc_tieu add column if not exists loai text not null default 'van-hanh';
alter table muc_tieu drop constraint if exists muc_tieu_loai_hop_le;
alter table muc_tieu add  constraint muc_tieu_loai_hop_le
  check (loai in ('du-an', 'van-hanh', 'hanh-chinh'));

comment on column muc_tieu.loai is
  'du-an = có vạch đích, vào danh mục, chiếm suất. van-hanh = chạy đều, không có điểm kết thúc, cần SOP chứ không cần Gantt. hanh-chinh = việc bộ máy. Mặc định van-hanh nên mọi dòng cũ KHÔNG tự biến thành dự án.';

-- 1b. Trạng thái nhiều nấc — thay cho cờ `xong` hai nấc bật/tắt
-- "Thành quy trình" và "thành công việc" KHÔNG có mặt ở đây: chúng là lối RA
-- khỏi danh mục, ghi vào biên bản buổi duyệt, không phải trạng thái của dự án.
-- Tracy chốt 25/08 sau khi nhìn bản thật: NĂM nấc, không phải sáu. Hai nấc
-- 'nhap' và 'hang-doi' gộp làm một thành KHO — chúng vốn chỉ khác nhau ở chỗ
-- phiếu đã đủ ô chưa, mà "đủ ô chưa" thì trigger dưới đây soi được, không cần
-- một nấc trạng thái riêng để nói. Tên gọi cũng đổi theo lời Tracy:
--   kho · đang chạy · nghẽn · hoàn thành · huỷ
alter table muc_tieu add column if not exists trang_thai text not null default 'kho';
alter table muc_tieu alter column trang_thai set default 'kho';

-- Kéo dữ liệu cũ về bộ mới TRƯỚC khi siết ràng buộc, nếu không câu alter dưới
-- sẽ ngã ở đúng những dòng đang mang tên cũ.
alter table muc_tieu drop constraint if exists muc_tieu_trang_thai_hop_le;
update muc_tieu set trang_thai = case trang_thai
  when 'nhap'     then 'kho'   when 'hang-doi' then 'kho'
  when 'tam-dung' then 'nghen' when 'da-dong'  then 'hoan-thanh'
  when 'da-loai'  then 'huy'   else trang_thai end
 where trang_thai in ('nhap','hang-doi','tam-dung','da-dong','da-loai');

alter table muc_tieu add  constraint muc_tieu_trang_thai_hop_le
  check (trang_thai in ('kho', 'dang-chay', 'nghen', 'hoan-thanh', 'huy'));

comment on column muc_tieu.trang_thai is
  'kho = chưa chạy, nằm chờ (gộp hai nấc nháp và hàng đợi của bản đầu). dang-chay = CHIẾM SUẤT. nghen = bị chặn từ bên ngoài, TRẢ SUẤT về ngay. hoan-thanh = tới mục tiêu. huy = bỏ, ra khỏi danh mục.';

-- ⚠️ Tracy chốt 25/08 sau khi nhìn bản thật: BỎ HẲN khái niệm LÀN
--    (thời cơ · nền móng · gỡ chặn) và BỎ ô "lần này không làm gì". Cả hai là
--    thứ tôi đề xuất, chưa phải luật của đội, và bày ra thì thành hai ô nữa
--    phải nuôi. Nên chúng không có mặt ở bản này — không phải gỡ sau, mà là
--    chưa từng dựng. Trần danh mục vì thế đếm theo TỔNG và theo NGƯỜI LÀM CHỦ,
--    không đếm theo làn nữa (xem mục 7).

-- 1e. HỒ SƠ dự án — viết SAU khi lập, không phải ô bắt buộc lúc mở
-- Tracy chốt 25/08: *"tôi muốn có mục hồ sơ để sau khi tạo lập thì họ sẽ viết
-- mô tả và các thông tin sau"*. Nên biểu mẫu mở dự án chỉ hỏi thứ KHÔNG THỂ
-- thiếu; phần mô tả dài và link tài liệu để lại cho hồ sơ, điền dần.
alter table muc_tieu add column if not exists mo_ta text not null default '';
alter table muc_tieu add column if not exists link_tai_lieu text not null default '';

comment on column muc_tieu.mo_ta is
  'Mô tả và bối cảnh dự án, viết SAU khi mở. Cố ý không bắt buộc: bắt khai lúc mở là đẻ ra một ô điền cho có, rồi chẳng ai đọc.';

-- 1f. Nghi thức đóng: cặp số thật, cộng ba câu nhìn lại
-- Cặp số này là nguyên liệu để vài quý nữa ROVA dự báo dự án mới bằng lịch sử
-- của chính mình, thay vì bằng cảm giác.
alter table muc_tieu add column if not exists so_ngay_du_kien  int;
alter table muc_tieu add column if not exists so_ngay_thuc_te  int;
alter table muc_tieu add column if not exists nhin_lai_duoc    text not null default '';
alter table muc_tieu add column if not exists nhin_lai_vuong   text not null default '';
alter table muc_tieu add column if not exists nhin_lai_lan_sau text not null default '';

alter table muc_tieu drop constraint if exists muc_tieu_so_ngay_duong;
alter table muc_tieu add  constraint muc_tieu_so_ngay_duong
  check (coalesce(so_ngay_du_kien, 1) > 0 and coalesce(so_ngay_thuc_te, 1) > 0);

comment on column muc_tieu.so_ngay_du_kien  is 'Lúc mở, hứa bao nhiêu ngày.';
comment on column muc_tieu.so_ngay_thuc_te  is 'Lúc đóng, thật ra mất bao nhiêu ngày. Cặp số này là kho kết quả thật.';
comment on column muc_tieu.nhin_lai_duoc    is 'Câu 1 lúc đóng: cái gì đã chạy tốt, giữ lại cho lần sau.';
comment on column muc_tieu.nhin_lai_vuong   is 'Câu 2 lúc đóng: chỗ nào vướng, vì sao.';
comment on column muc_tieu.nhin_lai_lan_sau is 'Câu 3 lúc đóng: lần sau làm khác ở đâu.';


-- ════════════════════════════════════════════════════════════════════════════
-- 2. MỘT SỰ THẬT VỀ "ĐÃ ĐÓNG", KHÔNG PHẢI HAI
-- ════════════════════════════════════════════════════════════════════════════
-- Bảng đã có cờ `xong` từ 08/08, nay thêm `trang_thai` sáu nấc. Hai chỗ cùng
-- nói một chuyện là chỗ đẻ ra hai bản sự thật — và ở đây nó có hậu quả thật:
-- trigger `kiem_muc_tieu_con_mo()` (đang chạy) đọc `xong` để cấm cam kết treo
-- vào mục tiêu đã đóng. Lệch hai cột là luật ấy tự tắt mà không báo gì.
--
-- Nên `trang_thai` là ô người bấm, `xong` là ảnh chiếu do máy chủ ghi.
create or replace function dong_bo_xong_du_an() returns trigger
language plpgsql as $$
begin
  new.xong := (new.trang_thai in ('hoan-thanh', 'huy'));
  if new.xong and new.ngay_xong is null then
    new.ngay_xong := hom_nay();
  end if;
  if not new.xong then
    new.ngay_xong := null;
  end if;
  return new;
end $$;

drop trigger if exists trg_dong_bo_xong_du_an on muc_tieu;
create trigger trg_dong_bo_xong_du_an before insert or update on muc_tieu
  for each row execute function dong_bo_xong_du_an();

comment on function dong_bo_xong_du_an is
  'trang_thai là ô người bấm; xong là ảnh chiếu máy chủ ghi. Giữ trigger kiem_muc_tieu_con_mo (08/08) tiếp tục đúng mà không phải sửa nó.';

-- ⚠️ Câu VÁ DỮ LIỆU CŨ cho hai cột này KHÔNG đặt ở đây mà đặt ở cuối mục 4 —
--    nó chạm trigger `kiem_du_an_du_o()`, mà trigger ấy đọc bảng `moc_du_an`
--    còn chưa được dựng tới dòng này. Đặt đúng thứ tự thay vì tin vào may.


-- ════════════════════════════════════════════════════════════════════════════
-- 3. BỐN Ô BẮT BUỘC — CHẶN Ở TẦNG DỮ LIỆU, GIAO DIỆN KHÔNG LÁCH ĐƯỢC
-- ════════════════════════════════════════════════════════════════════════════
-- Bốn ô: TÊN (đã `not null`) · CHỦ (`nguoi_id` đã `not null`) · VẠCH ĐÍCH
-- (`ket_qua`) · NGÀY XONG (`han`).
--
-- Vì sao là TRIGGER chứ không phải ràng buộc `check` trên bảng: bảng này còn
-- chứa mục tiêu vận hành và hành chính, những dòng ấy KHÔNG bắt buộc có vạch
-- đích và hạn. Ràng buộc bảng thì áp cho cả bảng; trigger soi được `loai`.
--
-- Bậc thang: mục tiêu và ngày xong soi LUÔN; ba tới bảy mốc chỉ soi lúc dự án
-- bước vào 'dang-chay'. Đây là chỗ "thiếu ô nào thì không mở được".
create or replace function kiem_du_an_du_o() returns trigger
language plpgsql as $$
declare so_moc int;
begin
  if new.loai <> 'du-an' then
    return new;
  end if;

  -- Hai ô này soi LUÔN, kể cả khi dự án còn nằm trong kho: một dòng không có
  -- mục tiêu và không có ngày thì chưa phải dự án, dù nó đứng ở đâu.
  if length(trim(coalesce(new.ket_qua, ''))) = 0 then
    raise exception 'Dự án phải có MỤC TIÊU — câu đọc lên hỏi "xong chưa?" trả lời được CÓ hoặc KHÔNG.';
  end if;
  if new.han is null then
    raise exception 'Dự án phải có NGÀY XONG. Chưa biết ngày thì nó còn là ý tưởng.';
  end if;

  /* Ba tới bảy mốc soi lúc BƯỚC VÀO 'dang-chay', không soi sớm hơn. Lý do là
     thứ tự sinh dữ liệu: dòng dự án phải có mặt trước thì mốc mới có chỗ treo,
     nên lúc dòng vừa sinh ra thì số mốc luôn bằng 0. Soi ở cửa 'dang-chay' vừa
     đúng nghĩa (chưa có kế hoạch thì chưa chạy được) vừa không tự chặn chính
     lệnh tạo dự án. */
  if new.trang_thai = 'dang-chay' then
    select count(*) into so_moc from moc_du_an where muc_tieu_id = new.id;
    if so_moc < 3 then
      raise exception 'Dự án cần ít nhất 3 milestone có ngày trước khi cho chạy — mới khai % cái.', so_moc;
    end if;
    -- ⛔ Khối trần này đã gỡ 01/09 — xem `nang-cap-bo-tran-moc.sql`.
    if so_moc > 7 then
      raise exception 'Quá 7 milestone (% cái). Dài hơn thì chia giai đoạn, mỗi giai đoạn nghiệm thu độc lập.', so_moc;
    end if;
  end if;

  -- Nghi thức đóng: cặp số thật cộng ba câu nhìn lại. Cùng khuôn với
  -- kiem_o_xong() và kiem_output_cam_ket() đang gác cửa đóng của cam kết.
  if new.trang_thai = 'hoan-thanh' then
    if new.so_ngay_du_kien is null or new.so_ngay_thuc_te is null then
      raise exception 'Hoàn thành dự án phải chốt CẶP SỐ: dự kiến bao nhiêu ngày, thực tế bao nhiêu ngày.';
    end if;
    if length(trim(coalesce(new.nhin_lai_duoc, ''))) = 0
       or length(trim(coalesce(new.nhin_lai_vuong, ''))) = 0
       or length(trim(coalesce(new.nhin_lai_lan_sau, ''))) = 0 then
      raise exception 'Hoàn thành dự án phải trả lời đủ BA CÂU nhìn lại (được gì · vướng gì · lần sau khác gì).';
    end if;
  end if;

  return new;
end $$;

drop trigger if exists trg_kiem_du_an_du_o on muc_tieu;
create trigger trg_kiem_du_an_du_o before insert or update on muc_tieu
  for each row execute function kiem_du_an_du_o();


-- ════════════════════════════════════════════════════════════════════════════
-- 4. BẢNG MỐC — `moc_du_an`
-- ════════════════════════════════════════════════════════════════════════════
-- Ba tới bảy mốc KẾT QUẢ có ngày cho mỗi dự án. Chỉ chốt mốc kết quả, để ngỏ
-- cách đạt mốc (milestone planning — nguyên lý #4).
--
-- Bộ ba cột đếm dời hạn chép ĐÚNG KHUÔN `han_goc` / `so_lan_doi_han` /
-- `ngay_troi` của cam kết (nang-cap-co-doi-han-va-trang-thai.sql, 11/08),
-- CỘNG một cột `ly_do_doi` — chỗ cả hai cơ chế hiện có đều thiếu.
create table if not exists moc_du_an (
  id              bigint generated always as identity primary key,
  muc_tieu_id     bigint not null references muc_tieu (id) on delete cascade,
  ten             text   not null check (length(trim(ten)) > 0),
  ngay            date   not null,
  thu_tu          smallint not null default 1,
  da_dat          boolean not null default false,
  ngay_dat        date,
  -- ba cột đếm dời hạn — máy chủ ghi, app chỉ đọc
  han_goc         date,
  so_lan_doi_han  int  not null default 0,
  ngay_troi       int  not null default 0,
  ly_do_doi       text not null default '',
  tao_luc         timestamptz not null default now()
);

comment on table moc_du_an is
  'Ba tới bảy mốc kết quả có ngày cho mỗi dự án. Dời mốc không phải tội, im lặng mới là tội: mỗi lần dời phải khai lý do, máy ghi hạn gốc và số ngày trôi, KHÔNG có lời trách nào trên màn hình.';
comment on column moc_du_an.han_goc        is 'Ngày lần đầu được đặt. Máy chủ ghi, app không sửa được.';
comment on column moc_du_an.so_lan_doi_han is 'Số lần mốc bị ĐẨY RA XA. Kéo gần lại không tính. Không bao giờ về 0.';
comment on column moc_du_an.ngay_troi      is 'Tổng số ngày đã trượt so với han_goc.';
comment on column moc_du_an.ly_do_doi      is 'Lý do lần dời GẦN NHẤT. Bắt buộc khai mới dời được — đây là cột cả tầng cam kết lẫn tầng việc đều đang thiếu.';

create index if not exists moc_theo_du_an on moc_du_an (muc_tieu_id, thu_tu);
create index if not exists moc_chua_dat   on moc_du_an (muc_tieu_id, ngay) where not da_dat;

-- 4a. Hàng rào — đúng khuôn `muc_tieu`: cả đội ĐỌC, chỉ CHỦ DỰ ÁN mới GHI.
-- Bảng này không có cột chủ; chủ suy từ dự án nó treo vào, nên bốn policy đều
-- hỏi ngược lên `muc_tieu`.
alter table moc_du_an enable row level security;

drop policy if exists doc_moc  on moc_du_an;
create policy doc_moc on moc_du_an for select
  using (la_thanh_vien());

drop policy if exists them_moc on moc_du_an;
create policy them_moc on moc_du_an for insert
  with check (exists (select 1 from muc_tieu m
                       where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()));

drop policy if exists sua_moc  on moc_du_an;
create policy sua_moc on moc_du_an for update
  using      (exists (select 1 from muc_tieu m
                       where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()))
  with check (exists (select 1 from muc_tieu m
                       where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()));

drop policy if exists xoa_moc  on moc_du_an;
create policy xoa_moc on moc_du_an for delete
  using (exists (select 1 from muc_tieu m
                  where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()));

-- 4b. Trần bảy mốc, soi ngay lúc thêm
-- ⛔ ĐÃ GỠ NGÀY 01/09 bằng `nang-cap-bo-tran-moc.sql` (Tracy chốt). Khối dưới
--    giữ lại vì tệp này là SỔ ghi cái đã chạy ngày 25/08, không phải bản hiện
--    hành. CHẠY LẠI TỆP NÀY SẼ DỰNG LẠI TRẦN — chạy xong nhớ chạy tiếp tệp gỡ.
create or replace function kiem_so_moc() returns trigger
language plpgsql as $$
declare so_moc int;
begin
  select count(*) into so_moc from moc_du_an where muc_tieu_id = new.muc_tieu_id;
  if so_moc >= 7 then
    raise exception 'Dự án này đã đủ 7 milestone. Phình quá thì chia giai đoạn, đừng thêm cái thứ 8.';
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_so_moc on moc_du_an;
create trigger trg_kiem_so_moc before insert on moc_du_an
  for each row execute function kiem_so_moc();

-- 4c. Bộ đếm dời mốc — chép khuôn `ghi_doi_han()` (11/08), cộng lý do bắt buộc
create or replace function ghi_doi_moc() returns trigger
language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    -- Đặt mốc lần đầu KHÔNG phải dời mốc. Chưa hứa thì chưa lỡ hẹn.
    new.han_goc        := new.ngay;
    new.so_lan_doi_han := 0;
    new.ngay_troi      := 0;
    if new.da_dat and new.ngay_dat is null then new.ngay_dat := hom_nay(); end if;
    return new;
  end if;

  -- Ba dòng này là chỗ cả cơ chế đứng hay đổ: bộ đếm CHỈ do máy chủ ghi. Mọi
  -- giá trị app gửi lên cho ba cột đó đều bị bỏ, nên không ai gột được vết dời
  -- mốc của mình bằng một câu update gửi thẳng.
  new.so_lan_doi_han := coalesce(old.so_lan_doi_han, 0);
  new.ngay_troi      := coalesce(old.ngay_troi, 0);
  new.han_goc        := coalesce(old.han_goc, old.ngay);

  if new.ngay > old.ngay then
    -- Chỉ đếm khi ĐẨY RA XA. Kéo mốc về gần là chuyện tốt; phạt nó thì không
    -- ai dám rút ngắn một lời hứa nào nữa.
    if length(trim(coalesce(new.ly_do_doi, ''))) = 0
       or trim(coalesce(new.ly_do_doi, '')) = trim(coalesce(old.ly_do_doi, '')) then
      raise exception 'Dời milestone phải khai LÝ DO mới. Máy ghi hạn gốc và số ngày trôi, không có lời trách nào.';
    end if;
    new.so_lan_doi_han := new.so_lan_doi_han + 1;
    new.ngay_troi      := new.ngay_troi + (new.ngay - old.ngay);
  end if;

  if new.da_dat and not coalesce(old.da_dat, false) then
    new.ngay_dat := coalesce(new.ngay_dat, hom_nay());
  elsif not new.da_dat then
    new.ngay_dat := null;
  end if;

  return new;
end $$;

-- `before insert or update` chứ không `before update of ngay`: phải chặn cả
-- đường sửa thẳng ba cột đếm mà không đụng tới `ngay`.
drop trigger if exists tg_doi_moc on moc_du_an;
create trigger tg_doi_moc before insert or update on moc_du_an
  for each row execute function ghi_doi_moc();


-- 4d. VÁ DỮ LIỆU CŨ — đặt ở đây, sau khi `moc_du_an` đã tồn tại
-- `trang_thai` vừa sinh ra mang mặc định 'kho', nên dòng nào đang `xong` sẽ bị
-- ảnh chiếu ở mục 2 ghi đè ngược thành chưa xong. Kéo về đúng chiều một lần.
-- Mọi dòng cũ đều mang `loai = 'van-hanh'` (mặc định) nên trigger ở mục 3 thoát
-- ngay dòng đầu — nhưng vẫn đặt sau `moc_du_an` để câu này không phụ thuộc vào
-- một sự thật có thể đổi.
update muc_tieu set trang_thai = 'hoan-thanh' where xong and trang_thai = 'kho';


-- ════════════════════════════════════════════════════════════════════════════
-- 4e. THÀNH VIÊN DỰ ÁN — PIC MỜI thì người ta mới vào được
-- ════════════════════════════════════════════════════════════════════════════
-- Tracy chốt 25/08: *"phải có tính năng mời tham gia dự án, do PIC của dự án mời
-- người tham gia thì người đó mới có thể add cam kết và task"*.
--
-- Vì sao phải là một bảng riêng chứ không suy từ cam kết: trước bản này, "ai
-- đang gánh dự án" được ĐẾM NGƯỢC từ cam kết đã gieo. Nghĩa là muốn biết mình
-- có được tham gia không thì phải gieo thử một cam kết rồi xem có bị đá về
-- không. Danh sách thành viên phải có TRƯỚC lời hứa, không phải sinh ra từ nó.
--
-- Ba lớp, cùng khuôn với mọi hàng rào khác của app:
--   ① bảng ghi ai được mời             → thanh_vien_du_an
--   ② hàm trả lời "người này vào được không" → la_thanh_vien_du_an()
--   ③ trigger chặn ở CẢ HAI cửa vào    → cam kết và việc
create table if not exists thanh_vien_du_an (
  muc_tieu_id bigint not null references muc_tieu (id) on delete cascade,
  nguoi_id    uuid   not null references nguoi (id)    on delete cascade,
  moi_boi     uuid   references nguoi (id) on delete set null,
  moi_luc     timestamptz not null default now(),
  primary key (muc_tieu_id, nguoi_id)
);

comment on table thanh_vien_du_an is
  'Ai được mời vào dự án nào. PIC luôn có mặt ở đây (trigger tự thêm). Chỉ người có tên mới gieo được cam kết hay đặt được việc thuộc dự án.';

create index if not exists thanhvien_theo_nguoi on thanh_vien_du_an (nguoi_id);

alter table thanh_vien_du_an enable row level security;

drop policy if exists doc_thanhvien on thanh_vien_du_an;
create policy doc_thanhvien on thanh_vien_du_an for select
  using (la_thanh_vien());

-- Chỉ PIC mới mời và rút người. Không mở cho thành viên tự mời tiếp: một dự
-- án mà ai cũng mời được thì trần suất và câu "một người chịu trách nhiệm cuối"
-- đều mất nghĩa.
drop policy if exists moi_thanhvien on thanh_vien_du_an;
create policy moi_thanhvien on thanh_vien_du_an for insert
  with check (exists (select 1 from muc_tieu m
                       where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()));

drop policy if exists rut_thanhvien on thanh_vien_du_an;
create policy rut_thanhvien on thanh_vien_du_an for delete
  using (exists (select 1 from muc_tieu m
                  where m.id = muc_tieu_id and m.nguoi_id = nguoi_id_dang_nhap()));

-- PIC tự có mặt trong danh sách, kể cả khi chưa ai bấm mời ai.
create or replace function tu_them_chu_du_an() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.loai = 'du-an' then
    insert into thanh_vien_du_an (muc_tieu_id, nguoi_id, moi_boi)
    values (new.id, new.nguoi_id, new.nguoi_id)
    on conflict do nothing;
  end if;
  return null;
end $$;

drop trigger if exists trg_tu_them_chu_du_an on muc_tieu;
create trigger trg_tu_them_chu_du_an after insert or update of nguoi_id, loai on muc_tieu
  for each row execute function tu_them_chu_du_an();

-- Không ai rút được chính PIC ra khỏi dự án của mình.
create or replace function kiem_rut_thanh_vien() returns trigger
language plpgsql as $$
begin
  if exists (select 1 from muc_tieu m
              where m.id = old.muc_tieu_id and m.nguoi_id = old.nguoi_id) then
    raise exception 'Không rút được PIC khỏi chính dự án của mình. Muốn đổi PIC thì đổi ở hồ sơ dự án.';
  end if;
  return old;
end $$;

drop trigger if exists trg_kiem_rut_thanh_vien on thanh_vien_du_an;
create trigger trg_kiem_rut_thanh_vien before delete on thanh_vien_du_an
  for each row execute function kiem_rut_thanh_vien();

-- Câu hỏi dùng chung cho cả hai cửa vào.
create or replace function la_thanh_vien_du_an(p_muc_tieu_id bigint, p_nguoi_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select p_muc_tieu_id is null
      or exists (select 1 from thanh_vien_du_an v
                  where v.muc_tieu_id = p_muc_tieu_id and v.nguoi_id = p_nguoi_id)
      or exists (select 1 from muc_tieu m
                  where m.id = p_muc_tieu_id and m.nguoi_id = p_nguoi_id)
$$;

-- CỬA MỘT: gieo cam kết trỏ về dự án.
create or replace function kiem_thanh_vien_cam_ket() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.muc_tieu_id is not null
     and not la_thanh_vien_du_an(new.muc_tieu_id, new.nguoi_id) then
    raise exception 'Chưa được mời vào dự án này thì chưa gieo cam kết cho nó được — nhờ PIC của dự án mời trước.';
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_thanh_vien_cam_ket on tieu_diem;
create trigger trg_kiem_thanh_vien_cam_ket before insert or update of muc_tieu_id, nguoi_id on tieu_diem
  for each row execute function kiem_thanh_vien_cam_ket();

-- Vá dữ liệu đang có: ai đã gieo cam kết trỏ về một dự án thì coi như đã được
-- mời. Không có câu này thì bật hàng rào lên là khoá luôn người đang làm dở.
insert into thanh_vien_du_an (muc_tieu_id, nguoi_id, moi_boi)
select distinct o.muc_tieu_id, o.nguoi_id, o.nguoi_id
  from tieu_diem o where o.muc_tieu_id is not null
on conflict do nothing;


-- ════════════════════════════════════════════════════════════════════════════
-- 5. CỘT DỰ ÁN TRÊN BẢNG VIỆC — MỘT CỘT, KHÔNG PHẢI MỘT BẢNG THỨ HAI
-- ════════════════════════════════════════════════════════════════════════════
-- Hôm nay task nối lên trên bằng đúng `tieu_diem_ma`, và đường tới dự án đi
-- hai chặng task → cam kết → dự án. Lỗ thật của đường hai chặng: một việc
-- thuộc dự án mà CHƯA AI GIEO CAM KẾT thì không có chỗ đứng. Đây là chỗ danh
-- sách "việc chờ" của dự án hiện không có nhà.
--
-- Vá bằng MỘT cột cộng MỘT trigger tự điền. Nếu dựng bảng việc riêng cho dự án
-- thì mỗi người sẽ có hai hộp thư — đúng chỗ làm người dùng ClickUp mệt.
alter table task add column if not exists muc_tieu_id bigint
  references muc_tieu (id) on delete set null;

create index if not exists task_theo_muctieu on task (muc_tieu_id);
-- Việc CHỜ của dự án: đã nghĩ ra, chưa ai gieo cam kết. Chỉ mục riêng vì đây
-- là câu hỏi màn hồ sơ dự án hỏi mỗi lần mở.
create index if not exists task_cho_cua_du_an on task (muc_tieu_id)
  where tieu_diem_ma is null and muc_tieu_id is not null;

comment on column task.muc_tieu_id is
  'Dự án việc này thuộc về. MÁY CHỦ điền khi việc được gieo dưới một cam kết có dự án — không có hai nguồn sự thật. Để trống + tieu_diem_ma trống = việc chờ của dự án, thứ trước nay không có nhà.';

-- 5a. Trigger tự điền: task gieo dưới một cam kết thì THỪA HƯỞNG dự án của
-- cam kết đó. Cam kết là nguồn sự thật; app không được cãi.
-- Cam kết KHÔNG có dự án thì nó chẳng khẳng định gì, nên giữ nguyên giá trị
-- task đang mang — đó là ca "việc chờ của dự án X được kéo vào một cam kết
-- chung chung", và làm mất con trỏ ở đó mới là mất dữ liệu.
create or replace function tu_dien_du_an_cho_task() returns trigger
language plpgsql security definer set search_path = public as $$
declare du_an_cua_cam_ket bigint;
begin
  if new.tieu_diem_ma is not null then
    select o.muc_tieu_id into du_an_cua_cam_ket
      from tieu_diem o where o.ma = new.tieu_diem_ma;
    if du_an_cua_cam_ket is not null then
      new.muc_tieu_id := du_an_cua_cam_ket;
    end if;
  end if;

  -- CỬA HAI của luật thành viên (25/08). Cửa một là gieo cam kết; đây là đường
  -- còn lại — đặt thẳng một việc vào dự án mà không qua cam kết nào (việc chờ).
  -- Chặn cả hai cửa mới là chặn, chặn một cửa chỉ là gợi ý.
  if new.muc_tieu_id is not null
     and not la_thanh_vien_du_an(new.muc_tieu_id, new.nguoi_id) then
    raise exception 'Chưa được mời vào dự án này thì chưa đặt việc cho nó được — nhờ PIC của dự án mời trước.';
  end if;

  return new;
end $$;

drop trigger if exists trg_tu_dien_du_an_cho_task on task;
create trigger trg_tu_dien_du_an_cho_task before insert or update on task
  for each row execute function tu_dien_du_an_cho_task();

-- 5b. Cam kết ĐỔI dự án thì mọi việc dưới nó đi theo. Không có câu này thì
-- một lần đổi ô chọn dự án là đẻ ra hai bản sự thật ngay lập tức.
create or replace function lan_toa_du_an_xuong_task() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.muc_tieu_id is distinct from old.muc_tieu_id
     and new.muc_tieu_id is not null then
    update task set muc_tieu_id = new.muc_tieu_id
     where tieu_diem_ma = new.ma
       and muc_tieu_id is distinct from new.muc_tieu_id;
  end if;
  return null;
end $$;

drop trigger if exists trg_lan_toa_du_an_xuong_task on tieu_diem;
create trigger trg_lan_toa_du_an_xuong_task after update of muc_tieu_id on tieu_diem
  for each row execute function lan_toa_du_an_xuong_task();

-- Vá dữ liệu đang có một lần: cam kết nào đã trỏ về dự án thì việc dưới nó
-- thừa hưởng ngay, không phải đợi ai sửa lại từng dòng.
update task t set muc_tieu_id = o.muc_tieu_id
  from tieu_diem o
 where o.ma = t.tieu_diem_ma
   and o.muc_tieu_id is not null
   and t.muc_tieu_id is distinct from o.muc_tieu_id
   -- Bỏ qua dòng lệch chủ (nếu còn sót từ trước đợt vá 12/08): đụng vào là
   -- trigger `kiem_task_dung_luong` ném lỗi và CUỘN NGƯỢC CẢ FILE. Một dòng
   -- lệch cũ không đáng để cả bản nâng cấp không chạy được.
   and t.nguoi_id = o.nguoi_id;


-- ════════════════════════════════════════════════════════════════════════════
-- 6. CỜ "TÍNH LÀ XONG" — MỘT CHỖ DUY NHẤT CHO MỌI PHÉP TÍNH TIẾN ĐỘ
-- ════════════════════════════════════════════════════════════════════════════
-- Bài học Nhóm 10 (Monday + Notion): đặt cờ trên TỪNG NHÃN trạng thái, đừng
-- suy từ tên nhãn. Không gom thì mọi công thức phải liệt kê đủ bảy tên, và vỡ
-- ngay lần đầu thêm trạng thái thứ tám.
--
-- Ba cột trả lời BA câu khác nhau — cố ý không nhồi vào một:
--   cum           — việc đang ở khúc nào của dòng chảy (dùng để lọc, để bày)
--   tinh_la_xong  — có cộng vào TỬ SỐ của phần trăm không
--   con_tren_ban  — có nằm trong MẪU SỐ không (việc đã huỷ thì không)
-- Gộp ba câu vào một cột là chỗ "đã huỷ" bị đếm thành "đã xong".
create table if not exists cum_trang_thai_task (
  trang_thai   text primary key,
  cum          text    not null check (cum in ('chua-lam', 'dang-lam', 'xong')),
  tinh_la_xong boolean not null default false,
  con_tren_ban boolean not null default true,
  thu_tu       smallint not null default 1
);

comment on table cum_trang_thai_task is
  'Bảng tra bảy trạng thái task về ba cụm. MỌI phép tính tiến độ hỏi bảng này, không liệt kê bảy tên. Thêm trạng thái thứ tám thì thêm MỘT DÒNG ở đây, không sửa một công thức nào.';

insert into cum_trang_thai_task (trang_thai, cum, tinh_la_xong, con_tren_ban, thu_tu) values
  ('Confirm',   'chua-lam', false, true,  1),
  ('Doing',     'dang-lam', false, true,  2),
  ('Chua_xong', 'dang-lam', false, true,  3),
  ('Blocked',   'dang-lam', false, true,  4),
  ('Done',      'xong',     true,  true,  5),
  ('Da_chuyen', 'xong',     false, false, 6),
  ('Da_huy',    'xong',     false, false, 7)
on conflict (trang_thai) do update set
  cum          = excluded.cum,
  tinh_la_xong = excluded.tinh_la_xong,
  con_tren_ban = excluded.con_tren_ban,
  thu_tu       = excluded.thu_tu;

alter table cum_trang_thai_task enable row level security;
drop policy if exists doc_cum_trang_thai on cum_trang_thai_task;
create policy doc_cum_trang_thai on cum_trang_thai_task for select
  using (la_thanh_vien());
-- Không có policy ghi: bảng luật chỉ đổi từ SQL Editor, đúng khuôn
-- `nguoi.so_cam_ket_toi_da` (12/08).

create or replace function cum_cua(p_trang_thai text)
returns text language sql stable
as $$ select cum from cum_trang_thai_task where trang_thai = p_trang_thai $$;


-- ════════════════════════════════════════════════════════════════════════════
-- 7. TRẦN DANH MỤC — CHÉP ĐÚNG KHUÔN BA LỚP CỦA TRẦN CAM KẾT
-- ════════════════════════════════════════════════════════════════════════════
-- Lớp ①: một chỗ chứa CON SỐ   → bảng `tran_danh_muc` + cột `nguoi.so_du_an_toi_da`
-- Lớp ②: một CHỈ MỤC            → `du_an_dang_chay`
-- Lớp ③: một TRIGGER security definer chặn khi vượt → `kiem_tran_danh_muc()`
--
-- Trần là LUẬT VẬT LÝ, không phải lời kêu gọi tập trung (nguyên lý #3). Muốn
-- nhận dự án mới khi danh mục đầy thì buổi duyệt phải cho một dự án khác chờ
-- hoặc loại. Đổi con số thì sửa MỘT DÒNG DỮ LIỆU, không đụng mã nguồn.
--
-- ⚠️ Số đang áp là MẶC ĐỊNH d1 — Tracy chưa chốt, dựng để nhìn thấy rồi sửa.

-- Lớp ① — con số của từng làn
create table if not exists tran_danh_muc (
  khoa    text primary key,
  so_suat smallint,
  ghi_chu text not null default ''
);

comment on table tran_danh_muc is
  'Nguồn DUY NHẤT của con số trần danh mục toàn công ty. Đổi trần thì sửa dòng ở đây, không sửa mã nguồn app.';

insert into tran_danh_muc (khoa, so_suat, ghi_chu) values
  ('tong', 6, 'Số dự án được ĐANG CHẠY cùng lúc trên toàn công ty.')
on conflict (khoa) do nothing;   -- `do nothing`: Tracy sửa số trên máy chủ rồi
                                 -- thì chạy lại file KHÔNG được kéo về mặc định.

alter table tran_danh_muc enable row level security;
drop policy if exists doc_tran_danh_muc on tran_danh_muc;
create policy doc_tran_danh_muc on tran_danh_muc for select
  using (la_thanh_vien());

-- Lớp ① (chiều thứ hai) — trần theo PIC, sống trên bảng `nguoi`,
-- đúng chỗ `so_cam_ket_toi_da` đang sống. Đặt trên cột chứ không đọc theo
-- `vai`: chính seed schema.sql ghi "vai để trống", khoá luật vào một cột có
-- thể rỗng là luật tự tắt mà không báo gì (bài học 12/08).
alter table nguoi add column if not exists so_du_an_toi_da smallint not null default 2;
alter table nguoi drop constraint if exists tran_du_an_1_6;
alter table nguoi add  constraint tran_du_an_1_6 check (so_du_an_toi_da between 1 and 6);
comment on column nguoi.so_du_an_toi_da is
  'Số dự án một người được làm PIC cùng lúc. Mặc định 2 (d1, Tracy chưa chốt). Góp sức vào dự án của người khác thì không tính — chỉ đếm dự án mình gánh cuối.';

-- Lớp ② — chỉ mục
create index if not exists du_an_dang_chay on muc_tieu (nguoi_id)
  where trang_thai = 'dang-chay' and loai = 'du-an';

-- Lớp ③ — trigger
create or replace function kiem_tran_danh_muc() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  tran_tong smallint;
  dang_tong int;
  tran_chu  smallint;
  dang_chu  int;
begin
  -- Chỉ soi lúc BƯỚC VÀO chỗ 'dang-chay'. Dòng đã đang chạy sẵn mà sửa tên,
  -- sửa mục tiêu… thì không phải xin suất lần nữa.
  if new.loai <> 'du-an' or new.trang_thai <> 'dang-chay' then
    return new;
  end if;
  if tg_op = 'UPDATE'
     and old.loai = 'du-an' and old.trang_thai = 'dang-chay'
     and old.nguoi_id = new.nguoi_id then
    return new;
  end if;

  -- ① trần TOÀN CÔNG TY
  select t.so_suat into tran_tong from tran_danh_muc t where t.khoa = 'tong';
  if tran_tong is not null then
    select count(*) into dang_tong from muc_tieu m
      where m.loai = 'du-an' and m.trang_thai = 'dang-chay'
        and m.id is distinct from new.id;
    if dang_tong >= tran_tong then
      raise exception 'Cả công ty đã có % dự án đang chạy, trần là %. Đóng hoặc cho chờ một cái trước.', dang_tong, tran_tong;
    end if;
  end if;

  -- ② trần của NGƯỜI LÀM CHỦ
  select n.so_du_an_toi_da into tran_chu from nguoi n where n.id = new.nguoi_id;
  tran_chu := coalesce(tran_chu, 2);
  select count(*) into dang_chu from muc_tieu m
    where m.loai = 'du-an' and m.trang_thai = 'dang-chay'
      and m.nguoi_id = new.nguoi_id and m.id is distinct from new.id;
  if dang_chu >= tran_chu then
    raise exception 'Người này đang là PIC của % dự án, trần là %. Một người gánh cuối quá nhiều thì không gánh cái nào.', dang_chu, tran_chu;
  end if;

  return new;
end $$;

drop trigger if exists trg_kiem_tran_danh_muc on muc_tieu;
create trigger trg_kiem_tran_danh_muc before insert or update on muc_tieu
  for each row execute function kiem_tran_danh_muc();

comment on function kiem_tran_danh_muc is
  'Chặn nhận dự án vượt trần, đếm HAI CHIỀU: tổng toàn công ty (tran_danh_muc.tong) và số dự án một người làm PIC (nguoi.so_du_an_toi_da). Chỉ soi lúc bước vào dang-chay; tạm dừng là TRẢ SUẤT ngay.';


-- ════════════════════════════════════════════════════════════════════════════
-- 8. KHUNG NHÌN DANH MỤC — MỖI DỰ ÁN MỘT DÒNG
-- ════════════════════════════════════════════════════════════════════════════
-- Mọi con số ở đây do MÁY CHỦ đếm. Không ô nào cho người gõ phần trăm.
--
-- Viết bằng TRUY VẤN CON VÔ HƯỚNG chứ không `left join` nhiều bảng — bài học
-- `tien_do_o` (17/08): join hai bảng con vào cùng một câu là nhân chéo, mọi
-- phép đếm phồng lên sai bét mà không ai thấy.
--
-- d3 — phần trăm đếm tới đâu là xong: BÀY CẢ HAI CON SỐ để Tracy so, và cột
-- `phan_tram` (cột app dùng) đếm theo LÚC KÝ NHẬN, đúng mặc định d3. Đếm theo
-- lúc tự tick thì vòng bốn nhịp (yêu cầu · hứa · tuyên bố xong · nghiệm thu)
-- chỉ còn ba.
drop view if exists danh_muc_du_an;
create view danh_muc_du_an as
select
  m.id,
  m.ten,
  m.ket_qua,
  m.nguoi_id,
  m.han,
  m.loai,
  m.trang_thai,
  m.mo_ta,
  m.link_tai_lieu,
  m.pham_vi,
  m.phong_ban,
  m.xong,
  m.ngay_xong,
  m.so_ngay_du_kien,
  m.so_ngay_thuc_te,
  m.nhin_lai_duoc,
  m.nhin_lai_vuong,
  m.nhin_lai_lan_sau,
  m.tao_luc,

  -- ─ cam kết trỏ về ─
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id)                       as so_cam_ket,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.xong)            as cam_ket_tick_xong,
  (select count(*) from tieu_diem o where o.muc_tieu_id = m.id
     and o.da_nhan_luc is not null)                                                   as cam_ket_da_nhan,
  (select count(distinct o.nguoi_id) from tieu_diem o where o.muc_tieu_id = m.id)     as so_nguoi_ganh,
  /* 🆕 25/08 — DANH SÁCH THÀNH VIÊN, không chỉ con số. Tracy: *"3 người đang
     gánh → thành viên (3): Tracy, Andy, Hafi"*. Một con số bắt người đọc đi tìm
     xem là ai; cái tên trả lời luôn.
     Đọc từ bảng `thanh_vien_du_an` — tức từ LỜI MỜI, không đếm ngược từ cam kết
     đã gieo. Đây là chỗ khác nhau thật: đếm ngược thì người vừa được mời mà
     chưa kịp hứa gì lại không có tên, mà họ mới chính là người cần thấy mình
     đã ở trong dự án. Trả `uuid[]` chứ không nối sẵn tên ở máy chủ — app đã cầm
     bảng `nguoi` trong tay, nối tên ở đây là hai chỗ cùng biết một sự thật. */
  (select array_agg(v.nguoi_id order by (v.nguoi_id = m.nguoi_id) desc, v.moi_luc)
     from thanh_vien_du_an v where v.muc_tieu_id = m.id)                              as nguoi_ganh,

  -- ─ việc của dự án ─
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.con_tren_ban)                                    as so_viec,
  (select count(*) from task t
     join cum_trang_thai_task c on c.trang_thai = t.trang_thai
    where t.muc_tieu_id = m.id and c.tinh_la_xong)                                    as viec_xong,
  (select count(*) from task t
    where t.muc_tieu_id = m.id and t.tieu_diem_ma is null)                            as viec_cho,

  /* 🆕 25/08 — TỔNG GIỜ DEEP WORK đã đổ vào dự án. Tracy: *"đếm tổng số giờ
     nữa"*. Mượn thẳng khung nhìn `vuon_cay` chứ không tự cộng lại từ bảng
     `phien_deepwork`: `vuon_cay` là chỗ DUY NHẤT trong app định nghĩa thế nào
     là "giờ làm việc sâu THẬT" — chỉ đếm phiên `ket_qua = 'song'` và chặn trần
     30 phút mỗi phiên. Cộng lại một lần nữa ở đây là đẻ ra bản sự thật thứ hai,
     rồi tới ngày hai con số lệch nhau mà không ai biết cái nào đúng. */
  (select coalesce(sum(c.phut), 0)::int from vuon_cay c
     join task t on t.id = c.task_id
    where t.muc_tieu_id = m.id)                                                       as tong_phut,

  -- ─ ngày bắt đầu SUY RA, không có cột nào phải nuôi ─
  least(
    (select min(k.ngay)      from moc_du_an  k where k.muc_tieu_id = m.id),
    (select min(o.ngay_gieo) from tieu_diem  o where o.muc_tieu_id = m.id)
  )                                                                                   as ngay_bat_dau,

  -- ─ mốc ─
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id)                       as so_moc,
  (select count(*) from moc_du_an k where k.muc_tieu_id = m.id and k.da_dat)          as moc_da_dat,
  (select count(*) from moc_du_an k
    where k.muc_tieu_id = m.id and not k.da_dat and k.ngay < hom_nay())               as moc_qua_ngay,
  (select k.ten  from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ten,
  (select k.ngay from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_ngay,
  (select k.ngay - hom_nay() from moc_du_an k where k.muc_tieu_id = m.id and not k.da_dat
    order by k.ngay, k.thu_tu limit 1)                                                as moc_ke_tiep_con_may_ngay,

  -- ─ cờ nhịp tuần: tuần này đã có cam kết nào gieo trỏ về chưa ─
  exists (select 1 from tieu_diem o
           where o.muc_tieu_id = m.id
             and o.ngay_gieo >= thu_hai_cua(hom_nay()))                               as co_nhip_tuan,

  -- ─ hai cách đếm phần trăm, bày cả hai để Tracy so (d3) ─
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.da_nhan_luc is not null)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id))
  end                                                                                 as phan_tram,
  case when (select count(*) from tieu_diem o where o.muc_tieu_id = m.id) = 0 then 0
       else round(100.0
              * (select count(*) from tieu_diem o where o.muc_tieu_id = m.id and o.xong)
              / (select count(*) from tieu_diem o where o.muc_tieu_id = m.id))
  end                                                                                 as phan_tram_tu_tick

from muc_tieu m;

alter view danh_muc_du_an set (security_invoker = on);

comment on view danh_muc_du_an is
  'Một dự án một dòng. MỌI con số ở đây do máy chủ đếm — không ô nào cho người gõ. phan_tram đếm theo LÚC KÝ NHẬN (mặc định d3); phan_tram_tu_tick đếm theo lúc người làm tự tick, bày cạnh để Tracy so rồi chốt. co_nhip_tuan = tuần này đã có cam kết gieo trỏ về chưa.';


-- 8b. Danh sách việc của một dự án — gồm cả việc CHỜ
drop view if exists viec_du_an;
create view viec_du_an as
select
  t.id,
  t.muc_tieu_id,
  t.nguoi_id,
  t.noi_dung,
  t.tieu_diem_ma,
  t.ngay,
  t.deadline,
  t.trang_thai,
  c.cum,
  c.tinh_la_xong,
  c.con_tren_ban,
  t.thoi_luong_du_kien,
  t.task_cha,
  t.ghi_chu_chot,
  t.tao_luc,
  t.xong_luc,
  (t.tieu_diem_ma is null) as la_viec_cho,
  n.ten as ten_nguoi,
  o.ten as ten_cam_ket
from task t
join cum_trang_thai_task c on c.trang_thai = t.trang_thai
left join nguoi     n on n.id = t.nguoi_id
left join tieu_diem o on o.ma = t.tieu_diem_ma
where t.muc_tieu_id is not null;

alter view viec_du_an set (security_invoker = on);

comment on view viec_du_an is
  'Việc của dự án, một bảng task duy nhất chứ không phải bảng thứ hai. la_viec_cho = đã nghĩ ra nhưng chưa ai gieo cam kết — chỗ trước nay không có nhà.';


-- ════════════════════════════════════════════════════════════════════════════
-- 9. CHẶN GHI LÊN Ô MÁY TÍNH RA — TRẢ LỖI THẬT, KHÔNG IM LẶNG
-- ════════════════════════════════════════════════════════════════════════════
-- Bẫy chính Monday vấp và tự ghi vào tài liệu của họ: ghi vào ô tổng hợp trả
-- về THÀNH CÔNG nhưng không đổi gì — lỗi âm thầm. Ta không chép chỗ đó.
create or replace function chan_ghi_khung_nhin() returns trigger
language plpgsql as $$
begin
  raise exception 'Khung nhìn "%" là ô MÁY CHỦ TÍNH, không ghi vào được. Sửa ở bảng gốc: muc_tieu · moc_du_an · tieu_diem · task.', tg_table_name;
end $$;

drop trigger if exists trg_chan_ghi_danh_muc_du_an on danh_muc_du_an;
create trigger trg_chan_ghi_danh_muc_du_an
  instead of insert or update or delete on danh_muc_du_an
  for each row execute function chan_ghi_khung_nhin();

drop trigger if exists trg_chan_ghi_viec_du_an on viec_du_an;
create trigger trg_chan_ghi_viec_du_an
  instead of insert or update or delete on viec_du_an
  for each row execute function chan_ghi_khung_nhin();


-- ════════════════════════════════════════════════════════════════════════════
-- 10. DỰNG LẠI `tien_do_o` ĐỂ NÓ MANG THEO `muc_tieu_id`
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ ĐÂY LÀ CHỖ DỄ HỎNG NHẤT CỦA CẢ FILE. Ba điều đã soát trước khi viết:
--
--   ① Bản SỐNG của `tien_do_o` là bản trong `nang-cap-gio-deepwork-theo-loai.sql`
--      (17/08) — tìm bằng máy, không bằng trí nhớ:
--         grep -l "create view tien_do_o" *.sql | xargs ls -t | head -1
--      Thân dưới đây chép ĐÚNG bản đó, KHÔNG đổi một dòng logic nào.
--
--   ② `drop` rồi `create` chứ không `create or replace`: lệnh replace chỉ cho
--      THÊM cột vào CUỐI, và Postgres đọc cột chèn giữa thành "đổi tên cột" rồi
--      ném 42P16. Vẫn thêm `muc_tieu_id` vào ĐÚNG CUỐI để hai đường đều an toàn.
--
--   ③ KHÔNG khung nhìn nào phụ thuộc `tien_do_o` — đã soát cả 35 file .sql,
--      chỗ duy nhất đọc nó là một câu tự kiểm trong `nang-cap-dem-o-may-chu.sql`,
--      không phải một định nghĩa khung nhìn. Nên `drop` không cần `cascade` và
--      không kéo đổ gì.
drop view if exists tien_do_o;

create view tien_do_o as
select
  o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
  o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
  o.bo_the,
  o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
  o.han_goc, o.so_lan_doi_han, o.ngay_troi,

  count(c.task_id) filter (where c.nac = 'qua')  as cay_co_qua,
  count(c.task_id) filter (where c.nac <> 'qua') as cay_dang_lon,
  coalesce(sum(c.phut), 0)                       as tong_phut,

  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null)                                    as so_task,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is not null
       and t.trang_thai = 'Done')                                 as so_xong,
  (select count(*) from task t
     where t.nguoi_id = o.nguoi_id and t.tieu_diem_ma = o.ma
       and t.ngay is null
       and t.trang_thai in ('Confirm','Doing','Chua_xong'))
                                                                  as so_kho,

  -- 🆕 25/08 — CỘT DUY NHẤT THÊM VÀO, ĐẶT Ở CUỐI. Đây là thứ cho màn cam kết
  -- biết cam kết này thuộc dự án nào, và là mắt xích của cả Phần D.
  o.muc_tieu_id

from tieu_diem o
left join vuon_cay c on c.tieu_diem_ma = o.ma
group by o.ma, o.nguoi_id, o.ten, o.luong, o.qua, o.mau, o.ten_loai,
         o.tieu_chi_xong, o.han, o.xong, o.ngay_gieo, o.ngay_xong, o.nguoi_tick,
         o.bo_the,
         o.output_chu, o.output_link, o.nop_luc, o.da_nhan_boi, o.da_nhan_luc,
         o.han_goc, o.so_lan_doi_han, o.ngay_troi,
         o.muc_tieu_id;

alter view tien_do_o set (security_invoker = on);

comment on view tien_do_o is
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm task ĐÃ HẸN NGÀY — việc còn trong kho là việc chưa nhận làm nên không vào mẫu số Done % (Tracy chốt 17/08); so_kho đếm riêng phần kho, không đếm Blocked; output_* và da_nhan_* là phần thu hoạch khi đóng cam kết; han_goc, so_lan_doi_han, ngay_troi là cờ dời hạn; bo_the là bộ thẻ ghi chú; muc_tieu_id là dự án cam kết này phục vụ (25/08).';


-- ════════════════════════════════════════════════════════════════════════════
-- 11. QUYỀN BẢNG — tường minh, đừng tin vào mặc định
-- ════════════════════════════════════════════════════════════════════════════
-- Supabase có `alter default privileges` sẵn nên bảng mới thường tự có quyền.
-- Vẫn ghi thẳng ra: hàng rào thật là RLS ở trên, còn đây chỉ là cánh cửa. Cửa
-- khoá nhầm thì app báo lỗi quyền mà không ai đoán ra vì sao.
grant select                         on cum_trang_thai_task to authenticated;
grant select                         on tran_danh_muc       to authenticated;
grant select, insert, update, delete on moc_du_an           to authenticated;
grant usage, select on sequence moc_du_an_id_seq            to authenticated;
grant select                         on danh_muc_du_an      to authenticated;
grant select                         on viec_du_an          to authenticated;


commit;


-- ════════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — chạy cùng lúc với phần trên.
-- Mọi dòng phải ✅. Có ❌ thì ĐỪNG đưa bản giao diện mới lên.
-- ════════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'muc_tieu có đủ 4 cột hồ sơ dự án (loai · trang_thai · mo_ta · link_tai_lieu)',
   (select count(*) from information_schema.columns
     where table_name = 'muc_tieu'
       and column_name in ('loai','trang_thai','mo_ta','link_tai_lieu')) = 4),

  (1.5, 'KHÔNG mọc cột làn và cột "lần này không làm gì" (Tracy bỏ 25/08)',
   not exists (select 1 from information_schema.columns
                where table_name = 'muc_tieu' and column_name in ('lan','khong_lam'))),

  (2, 'muc_tieu có đủ 5 cột nghi thức đóng (cặp số + ba câu nhìn lại)',
   (select count(*) from information_schema.columns
     where table_name = 'muc_tieu'
       and column_name in ('so_ngay_du_kien','so_ngay_thuc_te',
                           'nhin_lai_duoc','nhin_lai_vuong','nhin_lai_lan_sau')) = 5),

  (3, 'muc_tieu KHÔNG mọc thêm cột ngày bắt đầu (ngày bắt đầu phải là SUY RA)',
   not exists (select 1 from information_schema.columns
                where table_name = 'muc_tieu'
                  and column_name in ('ngay_bat_dau','bat_dau','ngay_mo'))),

  -- Sửa 25/08: dòng này từng đếm BA ràng buộc và nói "sáu giá trị trang_thai",
  -- cả hai đều là số của bản nháp. Bản chạy thật chỉ có HAI ràng buộc, vì cái
  -- thứ ba là của cột `lan` mà Tracy đã bỏ hẳn cùng ngày (xem mục 1.5 ngay
  -- trên). Và trang_thai chốt NĂM nấc, không phải sáu. Để nguyên con số cũ thì
  -- dòng này đỏ vĩnh viễn trong khi máy chủ hoàn toàn đúng — một cái chuông
  -- báo cháy kêu khi không có lửa, kêu vài lần là không ai còn nghe nữa.
  (4, 'Ràng buộc ba giá trị của loai và năm nấc trang_thai đang chạy',
   (select count(*) from pg_constraint
     where conrelid = 'muc_tieu'::regclass
       and conname in ('muc_tieu_loai_hop_le','muc_tieu_trang_thai_hop_le')) = 2),

  (5, 'Bảng moc_du_an đã có và đã bật hàng rào RLS',
   to_regclass('public.moc_du_an') is not null
   and (select rowsecurity from pg_tables where schemaname='public' and tablename='moc_du_an')),

  (6, 'moc_du_an có đủ 4 policy (doc/them/sua/xoa)',
   (select count(*) from pg_policies where tablename = 'moc_du_an'
      and policyname in ('doc_moc','them_moc','sua_moc','xoa_moc')) = 4),

  (7, 'moc_du_an chép đủ bộ ba đếm dời hạn CỘNG cột lý do dời',
   (select count(*) from information_schema.columns
     where table_name = 'moc_du_an'
       and column_name in ('han_goc','so_lan_doi_han','ngay_troi','ly_do_doi')) = 4),

  (8, 'Trigger dời mốc và trigger trần bảy mốc đang cắm trên moc_du_an',
   (select count(*) from pg_trigger
     where tgrelid = 'moc_du_an'::regclass and not tgisinternal
       and tgname in ('tg_doi_moc','trg_kiem_so_moc')) = 2),

  (9, 'task có cột muc_tieu_id, kèm chỉ mục',
   exists (select 1 from information_schema.columns
            where table_name='task' and column_name='muc_tieu_id')
   and exists (select 1 from pg_indexes where tablename='task' and indexname='task_theo_muctieu')),

  (10, 'Khoá ngoại task.muc_tieu_id là ON DELETE SET NULL (xoá dự án không kéo theo việc)',
   exists (select 1 from pg_constraint
            where conrelid = 'task'::regclass and contype='f' and confdeltype='n'
              and conkey = (select array[attnum] from pg_attribute
                             where attrelid='task'::regclass and attname='muc_tieu_id'))),

  (11, 'Trigger tự điền dự án cho task đang chạy',
   exists (select 1 from pg_trigger where tgname='trg_tu_dien_du_an_cho_task'
             and tgrelid='task'::regclass and not tgisinternal)),

  (12, 'Trigger lan toả khi cam kết đổi dự án đang chạy',
   exists (select 1 from pg_trigger where tgname='trg_lan_toa_du_an_xuong_task'
             and tgrelid='tieu_diem'::regclass and not tgisinternal)),

  (13, 'Không còn task nào lệch dự án so với cam kết nó bám vào',
   not exists (select 1 from task t join tieu_diem o on o.ma = t.tieu_diem_ma
                where o.muc_tieu_id is not null
                  and t.muc_tieu_id is distinct from o.muc_tieu_id)),

  (14, 'Bảng tra cụm trạng thái có đủ 7 dòng, gom về đúng 3 cụm',
   (select count(*) from cum_trang_thai_task) = 7
   and (select count(distinct cum) from cum_trang_thai_task) = 3),

  (15, 'Bảy trạng thái trong bảng tra KHỚP đúng ràng buộc task_trang_thai_hop_le',
   not exists (select 1 from cum_trang_thai_task c
                where c.trang_thai not in
                  ('Confirm','Doing','Done','Chua_xong','Blocked','Da_chuyen','Da_huy'))),

  (16, 'Chỉ đúng MỘT trạng thái mang cờ tính-là-xong (Done)',
   (select count(*) from cum_trang_thai_task where tinh_la_xong) = 1
   and (select tinh_la_xong from cum_trang_thai_task where trang_thai='Done')),

  (17, 'Việc đã huỷ và đã chuyển KHÔNG nằm trong mẫu số',
   (select count(*) from cum_trang_thai_task
     where trang_thai in ('Da_huy','Da_chuyen') and not con_tren_ban) = 2),

  (17.5, 'Tầng THÀNH VIÊN đủ ba lớp: bảng · hàm hỏi · trigger chặn CẢ HAI cửa',
   to_regclass('public.thanh_vien_du_an') is not null
   and exists (select 1 from pg_proc where proname = 'la_thanh_vien_du_an')
   and exists (select 1 from pg_trigger where tgname = 'trg_kiem_thanh_vien_cam_ket'
                 and tgrelid = 'tieu_diem'::regclass and not tgisinternal)
   and exists (select 1 from pg_trigger where tgname = 'trg_tu_dien_du_an_cho_task'
                 and tgrelid = 'task'::regclass and not tgisinternal)),

  (17.6, 'PIC luôn có tên trong danh sách thành viên của chính mình',
   not exists (select 1 from muc_tieu m
                where m.loai = 'du-an'
                  and not exists (select 1 from thanh_vien_du_an v
                                   where v.muc_tieu_id = m.id and v.nguoi_id = m.nguoi_id))),

  (17.7, 'Không cam kết nào đang trỏ về dự án mà chủ nó chưa được mời',
   not exists (select 1 from tieu_diem o
                where o.muc_tieu_id is not null
                  and not la_thanh_vien_du_an(o.muc_tieu_id, o.nguoi_id))),

  (18, 'Trần danh mục đủ ba lớp: con số · chỉ mục · trigger',
   to_regclass('public.tran_danh_muc') is not null
   and exists (select 1 from information_schema.columns
                where table_name='nguoi' and column_name='so_du_an_toi_da')
   and exists (select 1 from pg_indexes where tablename='muc_tieu' and indexname='du_an_dang_chay')
   and exists (select 1 from pg_trigger where tgname='trg_kiem_tran_danh_muc'
                 and tgrelid='muc_tieu'::regclass and not tgisinternal)),

  (19, 'Trigger trần danh mục chạy bằng quyền định nghĩa (security definer)',
   (select prosecdef from pg_proc where proname='kiem_tran_danh_muc')),

  (20, 'Trần tổng toàn công ty có mặt và là một con số',
   (select so_suat from tran_danh_muc where khoa = 'tong') is not null),

  (21, 'Khung nhìn danh_muc_du_an và viec_du_an đã có, cùng chạy security_invoker',
   (select count(*) from pg_class
     where relkind='v' and relname in ('danh_muc_du_an','viec_du_an')
       and 'security_invoker=on' = any(coalesce(reloptions,'{}'))) = 2),

  (22, 'danh_muc_du_an mang đủ bốn ô bắt buộc cộng chín ô máy tính',
   (select count(*) from information_schema.columns
     where table_name='danh_muc_du_an'
       and column_name in ('ten','nguoi_id','ket_qua','han',
                           'so_cam_ket','so_nguoi_ganh','nguoi_ganh','so_viec','viec_xong',
                           'tong_phut','ngay_bat_dau','moc_ke_tiep_ngay','co_nhip_tuan')) = 13),

  (23, 'Hai khung nhìn máy tính đều CHẶN GHI, trả lỗi thật',
   (select count(*) from pg_trigger
     where tgname in ('trg_chan_ghi_danh_muc_du_an','trg_chan_ghi_viec_du_an')
       and not tgisinternal) = 2),

  (24, 'tien_do_o đã mang cột muc_tieu_id',
   exists (select 1 from information_schema.columns
            where table_name='tien_do_o' and column_name='muc_tieu_id')),

  (25, 'tien_do_o KHÔNG mất cột nào của bản cũ (28 cột cũ + 1 cột mới = 29)',
   (select count(*) from information_schema.columns
     where table_name='tien_do_o'
       and column_name in ('ma','nguoi_id','ten','luong','qua','mau','ten_loai',
         'tieu_chi_xong','han','xong','ngay_gieo','ngay_xong','nguoi_tick','bo_the',
         'output_chu','output_link','nop_luc','da_nhan_boi','da_nhan_luc',
         'han_goc','so_lan_doi_han','ngay_troi','cay_co_qua','cay_dang_lon',
         'tong_phut','so_task','so_xong','so_kho','muc_tieu_id')) = 29),

  (26, 'tien_do_o vẫn chạy security_invoker — không vượt mặt RLS',
   (select 'security_invoker=on' = any(coalesce(reloptions,'{}'))
      from pg_class where relname='tien_do_o')),

  (27, 'NĂM hàng rào tầng cam kết vẫn nguyên vẹn, file này không gỡ cái nào',
   (select count(*) from pg_trigger
     where tgrelid='tieu_diem'::regclass and not tgisinternal
       and tgname in ('trg_kiem_tran_cam_ket','tg_doi_han','trg_kiem_o_xong',
                      'trg_kiem_output_cam_ket','trg_kiem_muc_tieu_con_mo')) = 5),

  (28, 'Chỉ mục một-hạt-sống-mỗi-luống vẫn còn',
   exists (select 1 from pg_indexes where tablename='tieu_diem'
             and indexname='mot_hat_song_moi_luong')),

  (29, 'Chính sách ghi_task VẪN chặn cứng — file này không nới quyền giao việc',
   exists (select 1 from pg_policies where tablename='task' and policyname='ghi_task')),

  (30, 'KHÔNG có bảng việc thứ hai nào mọc ra',
   to_regclass('public.task_du_an') is null and to_regclass('public.viec_du_an_bang') is null),

  (31, 'Cờ xong của muc_tieu khớp trang_thai ở mọi dòng (một sự thật, không hai)',
   not exists (select 1 from muc_tieu
                where xong <> (trang_thai in ('hoan-thanh','huy'))))
)
select thu_tu,
       case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua,
       muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt sau khi chạy ───────────────────────────────────────
-- ① Danh mục dự án và nhịp tuần của từng cái:
--    select ten, trang_thai, phan_tram, so_cam_ket, so_nguoi_ganh, tong_phut,
--           co_nhip_tuan, moc_ke_tiep_ten, moc_qua_ngay
--      from danh_muc_du_an where loai = 'du-an' order by trang_thai, ten;
-- ② Còn mấy suất trong danh mục:
--    select (select so_suat from tran_danh_muc where khoa='tong') as tran,
--           count(*) as dang_chay
--      from muc_tieu where loai='du-an' and trang_thai='dang-chay';
-- ③ Việc chờ của dự án (chưa ai gieo cam kết):
--    select muc_tieu_id, noi_dung from viec_du_an where la_viec_cho;
-- ④ Muốn quay lui trọn file này (hiếm khi cần):
--    drop view if exists danh_muc_du_an; drop view if exists viec_du_an;
--    drop table if exists thanh_vien_du_an;
--    drop table if exists moc_du_an; drop table if exists tran_danh_muc;
--    alter table task drop column if exists muc_tieu_id;
--    -- rồi chạy lại nang-cap-gio-deepwork-theo-loai.sql để dựng lại tien_do_o cũ.
