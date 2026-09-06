-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `task.chot_luc`
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- LUẬT 3b — KHÔNG ĐỂ MỘT TASK QUÁ MỘT NGÀY MÀ CHƯA ĐỔI TRẠNG THÁI
-- Tracy chốt luật 05/08, chốt mô hình đầy đủ và ra lệnh làm 08/08.
--
-- VÌ SAO CÓ FILE NÀY
-- Data Tỉnh thức hai tháng: 490 task là việc cũ chưa xong bị GÕ LẠI mỗi sáng.
-- Nguyên nhân không phải người lười — là việc chưa xong KHÔNG CÓ CHỖ NẰM, nên
-- sáng hôm sau phải gõ lại từ đầu. App hiện đẩy chúng sang mục "Còn nợ từ hôm
-- trước" một cách IM LẶNG, tức vẫn đang tái tạo đúng cơ chế ấy.
--
-- MÔ HÌNH TRACY CHỐT — hai lớp, đừng trộn:
--   · 24h  hỏi "HÔM QUA RA SAO?"   → 4 trạng thái: Done · Chua_xong · Miss · Nghen
--   · sáng hỏi "GIỜ LÀM GÌ VỚI NÓ?" → 4 hành động: Làm tiếp · Chia nhỏ · Về kho · Chờ
--   Trộn hai loại vào một danh sách là chỗ mọi bảng trạng thái phình rồi loạn.
--
-- File này chỉ dựng TẦNG DỮ LIỆU. Phần giao diện nằm ở public/index.html.
--
-- Chạy được nhiều lần, không hỏng gì.
-- Chạy SAU: nang-cap-cam-ket-va-muc-tieu.sql và va-sau-dot-soi-08-08.sql
--
-- ⚠️ CỐ Ý KHÔNG ĐỤNG chính sách RLS của bảng task — một phiên khác đang sửa
--    `ghi_task` cho tính năng giao việc cho nhau. File này chỉ THÊM cột và NỚI
--    ràng buộc, nên hai bên không giẫm lên nhau.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── 1. Bốn ô trạng thái mới ────────────────────────────────────────────────
-- Ràng buộc cũ chỉ có 'Confirm', 'Doing', 'Done', 'Miss' (schema.sql:141).
-- Mô hình mới cần thêm bốn ô. Bảng đầy đủ sau khi chạy file này:
--
--   NHÓM             Ô             NGHĨA
--   trong ngày       Confirm       đã hẹn hôm nay, chưa bắt đầu
--                    Doing         đang trong phiên deepwork (app hiện chữ "Deepwork")
--   chốt cuối ngày   Done          ✅ có output — ĐÓNG
--                    Chua_xong     có tiến độ · ghi_chu_chot = mai làm gì tiếp
--                    Miss          chưa động tới · ghi_chu_chot = mai làm gì
--                    Nghen         có thứ chặn · ghi_chu_chot = thứ đang chặn (BẮT BUỘC)
--   tuyên bố         Da_chuyen     đã thay bằng task con — ĐÓNG, bắt buộc có con
--                    Da_huy        dừng hẳn — ĐÓNG, không con
--
-- Vì sao 'Miss' không phải thêm: nó đã nằm sẵn trong ràng buộc từ đầu, và
-- nghĩa "chưa động tới" của Tracy trùng đúng nghĩa cũ. Dùng lại, không đẻ mới.
--
-- Vì sao giá trị viết tiếng Việt không dấu: phần còn lại của schema đã là
-- tiếng Việt (tieu_diem, phien_deepwork, nguoi, hom_nay). Bốn chữ tiếng Anh cũ
-- mới là cái lạc, chúng đến từ bảng Lark. Không đổi bốn cái cũ — đổi là phải
-- viết lại dữ liệu đang chạy, không đáng.
alter table task drop constraint if exists task_trang_thai_check;
alter table task drop constraint if exists task_trang_thai_hop_le;
alter table task add  constraint task_trang_thai_hop_le
  check (trang_thai in (
    'Confirm', 'Doing', 'Done', 'Miss',
    'Chua_xong', 'Nghen', 'Da_chuyen', 'Da_huy'
  ));


-- ─── 2. Bốn cột mới ─────────────────────────────────────────────────────────

-- ① ghi_chu_chot — MỘT cột dùng chung cho ba nghĩa, trạng thái quyết định nghĩa.
--    Cố ý không đẻ ba cột riêng (mai_lam_gi, thu_dang_chan, ly_do_huy): ba cột
--    thì mỗi lần đọc một dòng task phải hỏi "cột nào đang có nghĩa", và hai cột
--    kia luôn rỗng. Đúng nguyên tắc "thêm góc nhìn, đừng thêm cột" trong
--    tieu-diem/_cau-truc-task.md (Tracy duyệt 30/07).
alter table task add column if not exists ghi_chu_chot text not null default '';
comment on column task.ghi_chu_chot is
  'Câu trả lời bắt buộc lúc chốt. Chua_xong: mai làm gì tiếp. Miss: mai làm gì. Nghen: thứ đang chặn. Da_huy: lý do dừng. Nghĩa do trang_thai quyết định.';

-- ② chot_luc — NGƯỜI đã chốt chưa, hay máy đang đoán.
--    Đây là chỗ giữ cho luật không nói hộ người dùng. Máy được phép đánh dấu
--    một task quá hạn là Chua_xong, nhưng cái nhãn đó chỉ là CHẨN ĐOÁN TẠM cho
--    tới khi có người xác nhận. Rỗng nghĩa là câu hỏi cuối ngày CHƯA ai trả lời.
--
--    Nó cũng là thứ biến nghi thức tắt máy thành phần thưởng thay vì nghĩa vụ:
--    ai chịu chốt tối hôm trước thì sáng mở app đi thẳng vào việc, không bị chặn.
alter table task add column if not exists chot_luc timestamptz;
comment on column task.chot_luc is
  'Lúc NGƯỜI chốt trạng thái cuối ngày. Rỗng = máy đoán, sáng mai vẫn phải dọn. Có giờ = đã chốt, đi thẳng vào việc.';

-- ③ ngay_hen_dau — ngày ĐẦU TIÊN task này được hẹn làm.
--    Dùng để tính số ngày delay. Cố ý KHÔNG dựng một cột đếm rồi cộng dần: cột
--    đếm cần một lịch nền chạy mỗi đêm, còn cái này tính ra được bất cứ lúc nào
--    từ một mốc bất biến. Cùng cách app đang dùng cho phiên héo — không cần cron.
--
--    ⚠️ Giữ NGUYÊN suốt đời task, kể cả khi task về kho rồi được hẹn lại. Lý do:
--    nó đo "task này đã đứng bao lâu kể từ lần đầu tôi nói sẽ làm", mà đưa về
--    kho không xoá được lời đã nói. Cho reset thì đây thành đường lách trần
--    ba đêm: delay 2 đêm → về kho → hẹn lại → delay 0.
alter table task add column if not exists ngay_hen_dau date;
comment on column task.ngay_hen_dau is
  'Ngày đầu tiên task được hẹn làm. Bất biến, không reset khi task về kho. Số ngày delay = hôm nay trừ cột này.';

-- ④ task_cha — MỘT cột trả ba việc.
--    Tracy chốt 08/08: đổi hướng thì SINH TASK CON THAY THẾ, không đi qua cửa
--    Huỷ. Nếu mọi lần đổi hướng đều thành "huỷ" thì con số huỷ trộn ba chuyện
--    khác hẳn nhau — việc không đáng làm nữa, làm sai hướng rồi sửa, và bỏ cuộc
--    — rồi mất nghĩa.
--
--    LUẬT PHÂN BIỆT thay-thế với sinh-thêm: CHA CÒN SỐNG HAY KHÔNG.
--      · cha ĐÓNG (Da_chuyen)  → con thay cha   — chia nhỏ · đổi hướng
--      · cha CÒN SỐNG (Nghen)  → con đứng cạnh  — task gỡ chặn
--
--    on delete set null chứ không cascade: xoá cha thì con vẫn là việc thật.
alter table task add column if not exists task_cha bigint
  references task (id) on delete set null;
comment on column task.task_cha is
  'Task đẻ ra task này. Cha Da_chuyen = con thay cha (chia nhỏ, đổi hướng). Cha Nghen = con gỡ chặn, cha vẫn sống.';

create index if not exists task_theo_cha on task (task_cha) where task_cha is not null;


-- ─── 3. Điền ngay_hen_dau cho dữ liệu đã có ─────────────────────────────────
-- Task cũ chưa có mốc nào, lấy chính cột ngay làm mốc đầu. Task trong kho
-- (ngay rỗng) thì để rỗng — chưa hẹn ngày thì chưa nợ ai cái gì, chưa delay.
update task set ngay_hen_dau = ngay
 where ngay_hen_dau is null and ngay is not null;


-- ─── 4. Tự điền ngay_hen_dau từ nay về sau ──────────────────────────────────
-- Bắt đúng khoảnh khắc task rời kho: ngay chuyển từ rỗng sang có giá trị.
create or replace function dat_ngay_hen_dau()
returns trigger language plpgsql as $$
begin
  if new.ngay is not null and new.ngay_hen_dau is null then
    new.ngay_hen_dau := new.ngay;
  end if;
  return new;
end $$;

drop trigger if exists trg_ngay_hen_dau on task;
create trigger trg_ngay_hen_dau before insert or update on task
  for each row execute function dat_ngay_hen_dau();


-- ─── 5. Nghẽn BẮT BUỘC khai thứ đang chặn ───────────────────────────────────
-- Không có cái này thì Nghen thành ô trốn việc rẻ nhất: bấm một nút là task
-- rời khỏi mặt mà không ai biết nó đang chờ gì. Mà điểm nghẽn không gọi được
-- tên thì leader không gỡ được — đúng nguyên lý số 8 (nút thắt trước) và luật
-- phất cờ trong ngày.
alter table task drop constraint if exists nghen_phai_khai_thu_chan;
alter table task add  constraint nghen_phai_khai_thu_chan
  check (trang_thai <> 'Nghen' or length(trim(ghi_chu_chot)) > 0);


-- ─── 6. Đã chuyển BẮT BUỘC có ít nhất một con ───────────────────────────────
-- Ràng buộc check không viết được (cần truy vấn sang dòng khác), nên dùng
-- trigger. App phải tạo task con TRƯỚC rồi mới đóng cha — thứ tự đó cũng là
-- thứ tự đúng về nghĩa: chưa biết làm gì thay thì chưa được đóng cái cũ.
--
-- Đây là hàng rào giữ cho Da_chuyen không thành đường cho task biến mất im
-- lặng — đúng thứ luật 3b sinh ra để chặn.
create or replace function kiem_da_chuyen()
returns trigger language plpgsql as $$
begin
  if new.trang_thai = 'Da_chuyen'
     and not exists (select 1 from task c where c.task_cha = new.id) then
    raise exception
      'Task % chưa có task con nào nên chưa đóng bằng Da_chuyen được. Tạo việc thay thế trước, hoặc dùng Da_huy nếu dừng hẳn.', new.id;
  end if;
  return new;
end $$;

drop trigger if exists trg_kiem_da_chuyen on task;
create trigger trg_kiem_da_chuyen before update on task
  for each row when (new.trang_thai = 'Da_chuyen')
  execute function kiem_da_chuyen();


-- ─── 7. Khung nhìn "việc còn nợ" — thứ màn dọn buổi sáng đọc ────────────────
-- Gồm CẢ hai loại, vì cả hai đều cần một hành động sáng nay:
--   · chưa chốt (chot_luc rỗng) → phải trả lời cả hai câu
--   · đã chốt nhưng còn mở      → chỉ còn câu "giờ làm gì với nó"
--
-- so_ngay_delay tính ra tại chỗ, không lưu. Bọc greatest(...,0) vì task hẹn
-- ngày tương lai cho ra số âm.
--
-- security_invoker: chạy bằng quyền người gọi, nên hàng rào doc_task vẫn ăn —
-- không ai đọc được việc còn trong kho của người khác qua đường khung nhìn này.
-- Khai bằng `alter view` ở dưới cho khớp quy ước ba khung nhìn đã có trong
-- schema.sql (diem_ngay, ket_qua_ngay, vuon_cay) — giá trị lưu là `on`, nên bộ
-- tự kiểm phải soi `on` chứ không phải `true`.
create or replace view viec_con_no as
select
  t.*,
  greatest(0, hom_nay() - coalesce(t.ngay_hen_dau, t.ngay))::int as so_ngay_delay,
  (t.chot_luc is not null)                                        as da_chot,
  greatest(0, hom_nay() - coalesce(t.ngay_hen_dau, t.ngay)) >= 3  as het_cua_lam_tiep
from task t
where t.ngay is not null
  and t.ngay < hom_nay()
  and t.trang_thai not in ('Done', 'Da_chuyen', 'Da_huy')
  -- ⚠️ Chốt HÔM NAY rồi thì thôi, mai hỏi lại. Thiếu dòng này là màn dọn thành
  -- vòng lặp không thoát được: task Nghen sau khi chốt vẫn quá ngày và vẫn mở,
  -- nên nó rơi lại vào khung nhìn ngay lập tức. Ba ô kia tự rời đi (Làm tiếp
  -- đẩy sang hôm nay, Về kho xoá ngày, Huỷ đóng task) — chỉ Nghen là ở lại.
  -- Mỗi sáng hỏi lại đúng một lần "thứ chặn đã gỡ chưa" là đúng nhịp, và khớp
  -- luật phất cờ: bị chặn quá một ngày thì phải nêu ra, không đứng chờ im lặng.
  and (t.chot_luc is null
       or (t.chot_luc at time zone 'Asia/Ho_Chi_Minh')::date < hom_nay());

alter view viec_con_no set (security_invoker = on);

comment on view viec_con_no is
  'Việc quá ngày mà chưa đóng. Màn "Dọn việc hôm qua" đọc thẳng khung nhìn này. het_cua_lam_tiep = quá 3 đêm, nút Làm tiếp đóng lại, chỉ còn Chia nhỏ / Về kho / Huỷ.';

commit;


-- ═══════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — đọc cột ket_qua, mọi dòng phải ✅
-- ═══════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'Ràng buộc trang_thai đã nhận đủ 8 ô',
   (select count(*) = 4 from (values ('Chua_xong'),('Nghen'),('Da_chuyen'),('Da_huy')) v(o)
     where exists (select 1 from pg_constraint
                     where conrelid = 'task'::regclass
                       and conname  = 'task_trang_thai_hop_le'
                       and pg_get_constraintdef(oid) like '%' || v.o || '%'))),

  (2, 'Đủ bốn cột mới trên bảng task',
   (select count(*) = 4 from information_schema.columns
     where table_name = 'task'
       and column_name in ('ghi_chu_chot','chot_luc','ngay_hen_dau','task_cha'))),

  (3, 'Mọi task ĐÃ hẹn ngày đều có ngay_hen_dau',
   (select count(*) = 0 from task where ngay is not null and ngay_hen_dau is null)),

  (4, 'Task trong kho KHÔNG bị gán ngay_hen_dau (chưa hẹn thì chưa delay)',
   (select count(*) = 0 from task where ngay is null and ngay_hen_dau is not null)),

  (5, 'Trigger tự điền ngay_hen_dau đang sống',
   exists (select 1 from pg_trigger where tgname = 'trg_ngay_hen_dau' and not tgisinternal)),

  (6, 'Nghẽn không khai thứ chặn thì bị chặn',
   exists (select 1 from pg_constraint
             where conrelid = 'task'::regclass and conname = 'nghen_phai_khai_thu_chan')),

  (7, 'Trigger chặn Da_chuyen không con đang sống',
   exists (select 1 from pg_trigger where tgname = 'trg_kiem_da_chuyen' and not tgisinternal)),

  (8, 'Khung nhìn viec_con_no đã dựng',
   exists (select 1 from information_schema.views
             where table_schema = 'public' and table_name = 'viec_con_no')),

  (9, 'viec_con_no chạy bằng quyền người gọi (không rò kho người khác)',
   (select reloptions::text like '%security_invoker=on%'
      from pg_class where relname = 'viec_con_no')),

  (10, 'task vẫn bật hàng rào RLS',
   (select rowsecurity from pg_tables where schemaname = 'public' and tablename = 'task')),

  (11, 'Không dòng task nào mang trạng thái ngoài bảng 8 ô',
   (select count(*) = 0 from task
     where trang_thai not in ('Confirm','Doing','Done','Miss','Chua_xong','Nghen','Da_chuyen','Da_huy')))
)
select thu_tu, case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua, muc
from kt order by thu_tu;


-- ── Thử phá bằng tay, chạy từng câu (cả ba PHẢI báo lỗi) ───────────────────
-- ① Nghẽn mà không khai thứ chặn:
--    update task set trang_thai='Nghen', ghi_chu_chot='' where id=(select min(id) from task);
-- ② Đóng bằng Da_chuyen khi chưa có con:
--    update task set trang_thai='Da_chuyen' where id=(select min(id) from task);
-- ③ Trạng thái không có trong bảng 8 ô:
--    update task set trang_thai='Xong roi' where id=(select min(id) from task);
--
-- ── Xem việc còn nợ của mình ───────────────────────────────────────────────
--    select id, noi_dung, trang_thai, so_ngay_delay, da_chot, het_cua_lam_tiep
--      from viec_con_no order by so_ngay_delay desc;
