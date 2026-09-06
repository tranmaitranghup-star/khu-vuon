-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ ⚠️ KHÔNG có dấu vết riêng: khung nhìn `tien_do_o` — sáu tệp khác cũng dựng nó
-- │ Đã chạy chưa? → `SO-SQL.sql` **khối ②**, nó hỏi bằng câu khác:
-- │   không phải "tệp nào chạy rồi" mà "máy chủ có đang mang thứ app cần không".
-- └───────────────────────────────────────────────────────────────────────────
-- ════════════════════════════════════════════════════════════════════════════
-- nang-cap-doi-ten-trang-thai-task.sql          (Tracy chốt 27/08/2026)
--
-- ĐỔI TÊN MỘT GIÁ TRỊ: task.trang_thai 'Confirm' → 'Chua_lam'
--
-- Dán trọn file vào Supabase › SQL Editor › Run. CHẠY LẠI NHIỀU LẦN VÔ HẠI.
-- Chạy SAU `nang-cap-mang-du-an.sql`. Xong thì nhìn bảng cuối: mọi dòng phải ✅.
--
-- ─── VÌ SAO CÓ FILE NÀY ─────────────────────────────────────────────────────
-- Chữ `Confirm` trong app sắp mang HAI nghĩa ngược nhau cùng lúc:
--
--   · Ở tầng TASK nó có nghĩa "chưa ai đụng vào việc này" — một việc vừa tạo
--     ra, chưa làm. Không có ai xác nhận gì cả; cái tên nói dối ngay từ đầu.
--     Nó là mặc định của cột từ `schema.sql:140`, tức MỌI việc mới sinh ra đều
--     đeo nó, và nhãn hiện lên màn cũng đúng là chữ "Confirm" chưa dịch
--     (`public/index.html:7078`).
--   · Ở tầng CAM KẾT, chữ ấy sắp có nghĩa thật: cam kết được PIC dự án giao
--     cho người khác sẽ nằm ở nấc CHỜ NHẬN VIỆC, chờ đúng một cái gật. Đó mới
--     là chỗ chữ "xác nhận" nói đúng việc đang diễn ra.
--
-- Một chữ mang hai nghĩa ngược nhau trong cùng một cơ sở dữ liệu là mầm lỗi:
-- người sửa mã sáu tháng nữa đọc `trang_thai = 'Confirm'` không có cách nào
-- biết dòng đó nói "chưa làm" hay nói "chờ người ta gật". Nên trả chữ về đúng
-- một nghĩa: `Confirm` để dành cho tầng cam kết, tầng task đổi tên.
--
-- Tracy chốt kèm: TASK KHÔNG GIAO CHO NHAU. Việc giao qua giao lại nằm ở tầng
-- cam kết, không nằm ở task. Nên tầng task không cần một nấc "chờ xác nhận"
-- nào cả — bỏ hẳn chữ đó ở đây là bỏ đúng thứ không có việc để làm.
--
-- ─── VÌ SAO TÊN MÃ LÀ `Chua_lam`, VÀ NHÃN CŨNG LÀ "Chưa làm" ────────────────
-- Tracy chốt nguyên văn: *"trong task thì không dùng confirm nữa mà thay bằng
-- chưa làm là được vì task thì ko giao cho nhau"*. Nên nhãn trên màn là
-- **"Chưa làm"**, và tên mã lấy đúng chữ ấy: `Chua_lam`.
--
-- MỘT TÊN CHO CẢ BA TẦNG. Trước file này, app gọi cùng một trạng thái bằng BA
-- tên khác nhau: mã là `Confirm`, ô cây ở 7156 ghi "Chưa làm", nhóm ở tab tra
-- việc ghi "Chờ làm" (16769). Đó mới là cái tật thật. Sau file này chỉ còn một
-- tên duy nhất — mã `Chua_lam`, nhãn "Chưa làm" — nên mọi chỗ đang ghi "Chờ
-- làm" cho trạng thái này phải sửa thành "Chưa làm" cùng lượt (danh sách ở
-- mục A bên dưới).
--
-- ⚠️ ĐÃ CÂN NHẮC VÀ BÁC hai phương án khác, ghi lại để phiên sau khỏi bàn lại:
--   · `Cho_lam` + nhãn "Chờ làm" — nhất quán trong nội bộ, nhưng KHÔNG phải
--     chữ Tracy chốt. Đặt tên bằng chữ của người dùng là luật cao hơn.
--   · `Chua_bat_dau` — tránh được nhìn nhầm, nhưng lệch nhãn ("bắt đầu" ≠
--     "làm"), tức lại đẻ ra đúng cái tật tên-lệch-nhãn mà file này đang chữa.
--
-- ⚠️ VỀ LO NGẠI NHÌN NHẦM VỚI `Chua_xong`. Lo ngại có thật: hai giá trị cùng
-- tiền tố `Chua_`, gõ nhầm thì ràng buộc vẫn nhận, máy chủ không kêu một tiếng.
-- Nhưng nó KHÔNG đủ nặng để bẻ chữ của Tracy, vì bộ trạng thái này đã sống sẵn
-- với một cặp giống nhau hơn nhiều: `Doing` và `Done` chỉ khác hai ký tự, chung
-- tiền tố `Do`, và chưa từng gây ra sự cố nào. `Chua_lam` với `Chua_xong` khác
-- nhau trọn một từ ("làm" với "xong"), tức đã dễ tách hơn cặp đang chạy.
-- Người sửa mã sau này: soi kỹ chỗ nào so chuỗi hai giá trị ấy, và nhớ rằng
-- chúng mang nghĩa NGƯỢC nhau — `Chua_lam` là chưa động tay, `Chua_xong` là
-- đã làm dở dang.
--
-- ════════════════════════════════════════════════════════════════════════════
-- 🔢 THỨ TỰ CHẠY — HAI FILE CỦA ĐỢT 27/08
-- ════════════════════════════════════════════════════════════════════════════
--   ① `nang-cap-giao-cam-ket.sql`
--   ② `nang-cap-doi-ten-trang-thai-task.sql`   (file này)
-- Hai file KHÔNG chạm nhau: file kia chỉ đụng `tieu_diem` và `nguoi`, file này
-- chỉ đụng `task`, `cum_trang_thai_task` và `tien_do_o`. Chạy ngược thứ tự
-- cũng ra đúng kết quả, và file này chạy một mình cũng được.
-- Ghi thứ tự ra đây vì mục 18 của bộ tự kiểm dưới cùng có nói về
-- `tieu_diem.luong` — nó đã được viết cho ĐÚNG cả hai đời (trước và sau khi
-- file kia bỏ NOT NULL). Đọc khối ⚠️ ngay tại mục 18 trước khi sửa nó.
--
-- ─── BỐN THỨ CỐ Ý KHÔNG LÀM ─────────────────────────────────────────────────
--   · KHÔNG đụng tới `tieu_diem` (tầng cam kết). File này chỉ đổi tên một giá
--     trị ở tầng task. Nấc CHỜ NHẬN VIỆC của cam kết là file khác.
--   · KHÔNG đổi tên `Chua_xong`, `Blocked`, `Da_chuyen`, `Da_huy`. Tracy chốt
--     11/08 giữ nguyên (*"giữ chưa xong đi, từ kia khó nhớ quá"*), và chúng có
--     dòng dữ liệu thật.
--   · KHÔNG dựng lại bốn khung nhìn `tien_do_o` hoá thạch trong các file cũ.
--     Chúng đã bị đè, không chạy lại thì không sao. Danh sách ở cuối file.
--   · KHÔNG sửa `public/index.html`. SQL không với tới đó. Danh sách đầy đủ
--     chỗ phải sửa tay, kèm số dòng, nằm ở khối cuối file này.
-- ════════════════════════════════════════════════════════════════════════════

begin;


-- ════════════════════════════════════════════════════════════════════════════
-- 1. BỎ RÀNG BUỘC CŨ — PHẢI LÀM TRƯỚC, KHÔNG ĐƯỢC ĐẢO
-- ════════════════════════════════════════════════════════════════════════════
-- Ràng buộc đang sống chỉ biết bảy tên cũ, trong đó có `Confirm` mà KHÔNG có
-- `Chua_lam`. Chạy `update` khi nó còn hiệu lực là bị chính nó đá về, và vì cả
-- file nằm trong một `begin`, một lỗi cuộn ngược toàn bộ. Nên thứ tự bắt buộc:
--   bỏ ràng buộc → đổi dữ liệu → dựng ràng buộc mới.
--
-- Bỏ cả hai tên: `task_trang_thai_check` là tên Postgres tự đặt cho ràng buộc
-- viết thẳng trong `create table` (schema.sql:141), `task_trang_thai_hop_le`
-- là tên đặt tay từ `va-luat-3b.sql:53` và `nang-cap-co-doi-han-va-trang-thai
-- .sql:39`. Máy chủ thật có thể còn cái nào trong hai, tuỳ đã chạy tới đâu.
alter table task drop constraint if exists task_trang_thai_check;
alter table task drop constraint if exists task_trang_thai_hop_le;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. ĐỔI MẶC ĐỊNH CỦA CỘT
-- ════════════════════════════════════════════════════════════════════════════
-- Mặc định là thứ quyết định mọi việc SINH RA TỪ ĐÂY VỀ SAU. Quên nó thì file
-- này dọn sạch quá khứ rồi để tương lai tiếp tục đẻ ra dòng `Confirm` mới —
-- và lần này chúng rơi thẳng ra ngoài ràng buộc, tức app không tạo được việc.
--
-- Đặt mặc định TRƯỚC lệnh `update` ở mục 3 là cố ý: nếu có ai đó tạo một việc
-- mới ngay giữa lúc file này chạy thì việc ấy đã mang tên mới, không lọt lại.
alter table task alter column trang_thai set default 'Chua_lam';

comment on column task.trang_thai is
  'Nấc của việc: Chua_lam (chưa bắt đầu — mặc định) · Doing (đang trong phiên deep work) · Chua_xong (đã làm dở) · Blocked (đang nghẽn, chờ người khác gỡ) · Done (xong) · Da_chuyen · Da_huy. Tên cũ Confirm bỏ hẳn 27/08: chữ ấy để dành cho nấc CHỜ NHẬN VIỆC của tầng cam kết, task không giao cho nhau. Cụm và cờ tính-là-xong tra ở bảng cum_trang_thai_task, đừng liệt kê tên trong công thức.';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. CHUYỂN MỌI DÒNG ĐANG MANG TÊN CŨ
-- ════════════════════════════════════════════════════════════════════════════
-- Đây là lệnh chạm dữ liệu thật DUY NHẤT của cả file. Khác đợt 11/08 (`Miss`
-- và `Nghen` đều 0 dòng), lần này `Confirm` là mặc định của cột từ ngày đầu
-- nên gần như mọi việc chưa làm trong app đều đang đeo nó.
--
-- ⚠️ DÒ TRƯỚC KHI CHẠM. Câu `update` dưới đây chạm gần như MỌI dòng task đang
-- có, mà bảng `task` đang cắm sẵn HAI trigger `before insert or update` biết
-- ném lỗi — và cả hai đều nói về chuyện khác hẳn việc đổi tên trạng thái:
--   · `trg_tu_dien_du_an_cho_task` (nang-cap-mang-du-an.sql:495–520) ném
--     'Chưa được mời vào dự án này thì chưa đặt việc cho nó được' nếu task có
--     `muc_tieu_id` mà chủ task không còn tên trong `thanh_vien_du_an`. Chuyện
--     ấy xảy ra thật: `thanh_vien_du_an` cho phép rút người, `kiem_rut_thanh_
--     vien` chỉ chặn rút PIC.
--   · `trg_kiem_task_dung_luong` (va-luong-cheo-nhau.sql:63–81) ném
--     'Hạt % là luống của người khác' nếu task bám vào cam kết của người khác.
--
-- Chỉ cần MỘT dòng cũ lệch là câu update đổ, và vì cả file nằm trong một
-- `begin` thì TOÀN BỘ đợt sửa cuộn ngược — ràng buộc cũ đã bỏ cũng quay lại,
-- không có gì lên. Người chạy nhìn thấy một câu lỗi nói về 'chưa được mời vào
-- dự án' và không có cách nào nối nó với việc mình đang làm.
--
-- Nên hỏng ỒN ÀO TRƯỚC KHI CHẠM, cùng nếp với `nang-cap-giao-cam-ket.sql`
-- mục 2: đếm trước, đổ trước, và câu lỗi chỉ thẳng ra lệnh xem từng dòng.
do $$
declare so_lech int;
begin
  select count(*) into so_lech
    from task t
   where t.trang_thai = 'Confirm'
     and ( (t.muc_tieu_id is not null
            and not la_thanh_vien_du_an(t.muc_tieu_id, t.nguoi_id))
        or exists (select 1 from tieu_diem o
                    where o.ma = t.tieu_diem_ma
                      and o.nguoi_id <> t.nguoi_id) );

  if so_lech > 0 then
    raise exception
      'Có % việc cũ đang lệch (chủ việc không còn tên trong dự án của nó, hoặc việc bám vào cam kết của người khác). Hai trigger của bảng task sẽ đá câu update đổi tên trạng thái, và cả file cuộn ngược. Sửa mấy dòng ấy trước. Xem từng dòng: select t.id, t.noi_dung, t.nguoi_id, t.muc_tieu_id, t.tieu_diem_ma from task t where t.trang_thai = ''Confirm'' and ((t.muc_tieu_id is not null and not la_thanh_vien_du_an(t.muc_tieu_id, t.nguoi_id)) or exists (select 1 from tieu_diem o where o.ma = t.tieu_diem_ma and o.nguoi_id <> t.nguoi_id));',
      so_lech;
  end if;
end $$;

-- Chạy lại lần thứ hai thì câu này chạm 0 dòng — không có gì để chuyển nữa.
update task set trang_thai = 'Chua_lam' where trang_thai = 'Confirm';


-- ⚠️ DÒNG DƯỚI PHẢI CÓ. Không phải thừa, và đừng bỏ đi cho gọn.
--
-- `task` đang đeo một trigger HOÃN TỚI LÚC COMMIT: `tg_nghen_co_viec_go`
-- (`nang-cap-luat-nghen.sql:74`) khai `deferrable initially deferred`. Câu
-- `update` ngay trên xếp MỘT sự kiện trigger cho MỖI dòng vừa chạm, rồi treo
-- cả đám đó tới `commit`. Postgres từ chối mọi `alter table` trên một bảng còn
-- sự kiện treo, và ném đúng câu này ở mục 4:
--
--     ERROR: 55006: cannot ALTER TABLE "task" because it has pending trigger events
--
-- Cả file nằm trong một `begin` nên toàn bộ đợt sửa cuộn ngược, không có gì
-- lên. Đã cắn thật lượt chạy đầu của Tracy ngày 28/08.
--
-- `set constraints all immediate` bắt đám sự kiện ấy nổ NGAY BÂY GIỜ, dọn sạch
-- hàng đợi, rồi mục 4 mới đặt được ràng buộc.
--
-- AN TOÀN Ở ĐÂY, đã soi thân hàm: `kiem_nghen_co_viec_go` chỉ ném lỗi khi một
-- dòng ĐANG ĐỔI SANG `'Blocked'`. Câu update trên đặt `'Chua_lam'`, nên trigger
-- chạy tới nhánh `if` đầu tiên rồi trả về ngay. Nổ sớm hay nổ lúc commit cho
-- cùng một kết quả — chỉ khác chỗ nó không còn chặn `alter table`.
set constraints all immediate;


-- ════════════════════════════════════════════════════════════════════════════
-- 4. DỰNG LẠI RÀNG BUỘC — CHÉP NGUYÊN VĂN BẢN ĐANG SỐNG, ĐỔI ĐÚNG MỘT CHỮ
-- ════════════════════════════════════════════════════════════════════════════
-- Bản đang có hiệu lực là `nang-cap-co-doi-han-va-trang-thai.sql:38–42` (bảy
-- tên). Chép y nguyên, chỉ `'Confirm'` thành `'Chua_lam'`. Không thêm bớt tên
-- nào khác: file này đổi TÊN, không mở rộng bộ trạng thái.
alter table task add constraint task_trang_thai_hop_le
  check (trang_thai in (
    'Chua_lam', 'Doing', 'Done',
    'Chua_xong', 'Blocked', 'Da_chuyen', 'Da_huy'
  ));


-- ════════════════════════════════════════════════════════════════════════════
-- 5. BẢNG TRA `cum_trang_thai_task` — KHOÁ CHÍNH LÀ CHÍNH CHỮ ẤY
-- ════════════════════════════════════════════════════════════════════════════
-- Đây là chỗ dễ bỏ sót nhất và đắt nhất. `cum_trang_thai_task.trang_thai` là
-- KHOÁ CHÍNH, tức đổi tên không phải `update một cột` mà là thêm dòng mới rồi
-- bỏ dòng cũ. Bỏ sót thì:
--   · `viec_du_an` (nang-cap-mang-du-an.sql:841) `join` THẲNG bảng này — task
--     nào không có dòng tra sẽ BIẾN MẤT khỏi khung nhìn, không báo lỗi.
--   · `so_viec` / `viec_xong` (dòng 755–760) cũng `join` như vậy — việc mới
--     tạo lặng lẽ rơi khỏi CẢ tử số lẫn mẫu số của phần trăm tiến độ.
--   · `cum_cua('Chua_lam')` trả NULL, và NULL đi tiếp vào mọi phép so sánh.
--
-- Thứ tự: CHÈN dòng mới TRƯỚC, XOÁ dòng cũ SAU. Làm ngược thì giữa hai lệnh
-- có một khoảnh khắc bảng tra không biết trạng thái của mấy dòng task vừa đổi
-- ở mục 3 — trong một giao dịch thì không ai thấy, nhưng nếp viết an toàn nên
-- giữ cả ở chỗ không đau, vì chỗ đau thì không kịp nhớ.
--
-- Ba cột cờ chép nguyên từ dòng `('Confirm', 'chua-lam', false, true, 1)`:
-- vẫn cụm `chua-lam`, vẫn không tính là xong, vẫn nằm trên bàn, vẫn thứ tự 1.
-- Lưu ý `chua-lam` ở cột `cum` là GẠCH NGANG và ở một cột khác — không liên
-- quan gì tới tên mã trạng thái, không va nhau.
insert into cum_trang_thai_task (trang_thai, cum, tinh_la_xong, con_tren_ban, thu_tu) values
  ('Chua_lam', 'chua-lam', false, true, 1)
on conflict (trang_thai) do update set
  cum          = excluded.cum,
  tinh_la_xong = excluded.tinh_la_xong,
  con_tren_ban = excluded.con_tren_ban,
  thu_tu       = excluded.thu_tu;

delete from cum_trang_thai_task where trang_thai = 'Confirm';


-- ════════════════════════════════════════════════════════════════════════════
-- 6. DỰNG LẠI KHUNG NHÌN `tien_do_o`
-- ════════════════════════════════════════════════════════════════════════════
-- Ba điều phải nói rõ trước khi đụng vào nó:
--
--   ① BẢN SỐNG là `nang-cap-mang-du-an.sql:894–936` (25/08) — bản DUY NHẤT có
--      cột `o.muc_tieu_id` ở cuối, mắt xích của cả mảng dự án. Bốn bản khác
--      trong kho đều là hoá thạch. Tìm bằng máy, đừng bằng trí nhớ:
--         grep -l "create view tien_do_o" *.sql | xargs ls -t | head -1
--      Thân dưới đây chép ĐÚNG bản đó, đổi đúng một chữ trong ô `so_kho`.
--
--   ② `drop` rồi `create` chứ không `create or replace`: replace chỉ cho THÊM
--      cột vào CUỐI, đụng vào giữa là Postgres ném 42P16.
--
--   ③ KHÔNG khung nhìn nào phụ thuộc `tien_do_o` (đã soát cả kho .sql: chỗ đọc
--      nó chỉ là mấy câu tự kiểm), nên `drop` không cần `cascade`.
--
-- Vì sao `so_kho` phải sửa chứ không kệ: nó đếm việc CÒN TRONG KHO (chưa hẹn
-- ngày). Để nguyên chữ cũ thì sau khi chạy file này ô ấy trả về 0 cho mọi cam
-- kết — kho rỗng giả, và không ai nghi ngờ một con số 0.
--
-- ⚠️⚠️ BẢN 29 CỘT DƯỚI ĐÂY ĐÃ BỊ VƯỢT MẶT — ĐỌC TRƯỚC KHI CHẠY LẠI FILE NÀY.
-- Chiều 27/08, `nang-cap-giao-cam-ket.sql` MỤC 10 dựng lại `tien_do_o` thành
-- bản 36 CỘT: bản 29 cột này cộng `moc_id`, `ngay_bat_dau`, và năm cột sổ giao
-- nhận (`giao_boi`, `giao_luc`, `nhan_viec_luc`, `tu_choi_luc`,
-- `tu_choi_ly_do`). Khối KHO CAM KẾT trên màn "Của tôi" SỐNG NHỜ năm cột ấy —
-- thiếu chúng thì mọi dòng kho gắn nhãn "Tự viết", cặp nút Nhận việc / Từ chối
-- không bao giờ vẽ ra, và lời người khác giao bị nhốt trong kho không lối ra,
-- không một dòng lỗi nào trong console.
-- Câu `drop … create` dưới đây CUỐN SẠCH bảy cột ấy. Nên:
--     chạy lại file này  →  chạy lại `nang-cap-giao-cam-ket.sql` NGAY SAU ĐÓ.
-- Cũng vì vậy dòng 12 của bộ tự kiểm cuối file (đếm đúng 29 cột) sẽ ĐỎ trên
-- một máy chủ đã chạy mục 10 — đó là dấu hiệu TỐT, không phải hỏng.
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
       and t.trang_thai in ('Chua_lam','Doing','Chua_xong'))
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
  'Tiến độ từng cam kết. cay_* và tong_phut đếm CÂY (task đã có deepwork thật); so_task và so_xong đếm task ĐÃ HẸN NGÀY — việc còn trong kho là việc chưa nhận làm nên không vào mẫu số Done % (Tracy chốt 17/08); so_kho đếm riêng phần kho, không đếm Blocked; output_* và da_nhan_* là phần thu hoạch khi đóng cam kết; han_goc, so_lan_doi_han, ngay_troi là cờ dời hạn; bo_the là bộ thẻ ghi chú; muc_tieu_id là dự án cam kết này phục vụ (25/08). Trạng thái Confirm đổi tên thành Chua_lam ngày 27/08.';

-- `drop view` xoá luôn mọi `grant` đã cấp cho khung nhìn cũ. Supabase có
-- `alter default privileges` nên bản mới thường tự có quyền lại — nhưng "thường"
-- không phải "chắc chắn", và nếu trượt thì app báo LỖI QUYỀN chứ không báo
-- thiếu khung nhìn, một lỗi rất khó lần ra từ phía giao diện. Ghi thẳng ra cho
-- rẻ, đúng nếp `nang-cap-mang-du-an.sql:940–949`.
grant select on tien_do_o to authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- 7. QUÉT TOÀN CSDL — CÒN CHỖ NÀO NHẮC CHỮ CŨ KHÔNG
-- ════════════════════════════════════════════════════════════════════════════
-- Không sửa gì, chỉ nêu tên. Bản kiểm kê đọc từ FILE .sql; câu này đọc từ CÁI
-- ĐANG CHẠY THẬT trên máy chủ — hai thứ có thể lệch nhau nếu ai đó từng chạy
-- lại một file hoá thạch. Chỗ nào hiện ra ở đây là chỗ bản kiểm kê chưa thấy.
do $$
declare v_con text;
begin
  select string_agg(ten, ', ') into v_con from (
    select 'khung nhìn ' || viewname as ten
      from pg_views where schemaname = 'public' and definition like '%Confirm%'
    union all
    select 'hàm ' || p.proname
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.prosrc like '%Confirm%'
  ) x;
  if v_con is not null then
    raise notice 'CÒN SÓT chữ Confirm ở: %  — xem lại trước khi đóng việc.', v_con;
  end if;
end $$;

commit;


-- ════════════════════════════════════════════════════════════════════════════
-- BỘ TỰ KIỂM — mọi dòng phải ✅.
-- ════════════════════════════════════════════════════════════════════════════
with kt(thu_tu, muc, dat) as (
  values
  (1, 'KHÔNG còn dòng task nào mang trạng thái Confirm',
   not exists (select 1 from task where trang_thai = 'Confirm')),

  (2, 'Ràng buộc task_trang_thai_hop_le còn sống, ĐÃ biết Chua_lam',
   exists (select 1 from pg_constraint
            where conname = 'task_trang_thai_hop_le'
              and conrelid = 'task'::regclass
              and pg_get_constraintdef(oid) like '%Chua_lam%')),

  (3, 'Ràng buộc ấy KHÔNG còn nhắc chữ Confirm',
   exists (select 1 from pg_constraint
            where conname = 'task_trang_thai_hop_le'
              and conrelid = 'task'::regclass
              and pg_get_constraintdef(oid) not like '%Confirm%')),

  (4, 'Ràng buộc CŨ tự đặt tên (task_trang_thai_check) đã bỏ hẳn',
   not exists (select 1 from pg_constraint
                where conname = 'task_trang_thai_check'
                  and conrelid = 'task'::regclass)),

  (5, 'Mặc định của cột task.trang_thai đã là Chua_lam',
   (select column_default from information_schema.columns
     where table_schema = 'public' and table_name = 'task'
       and column_name = 'trang_thai') like '%Chua_lam%'),

  (6, 'Bảng tra có dòng Chua_lam, đúng cụm chua-lam, chưa tính là xong, còn trên bàn',
   exists (select 1 from cum_trang_thai_task
            where trang_thai = 'Chua_lam' and cum = 'chua-lam'
              and not tinh_la_xong and con_tren_ban)),

  (7, 'Bảng tra KHÔNG còn dòng Confirm',
   not exists (select 1 from cum_trang_thai_task where trang_thai = 'Confirm')),

  (8, 'Bảng tra vẫn đúng 7 dòng gom về đúng 3 cụm (không thừa, không thiếu)',
   (select count(*) from cum_trang_thai_task) = 7
   and (select count(distinct cum) from cum_trang_thai_task) = 3),

  (9, 'MỌI trạng thái task đang có đều tra được — không dòng nào rơi khỏi viec_du_an',
   not exists (select 1 from task t
                where not exists (select 1 from cum_trang_thai_task c
                                   where c.trang_thai = t.trang_thai))),

  (10, 'cum_cua(''Chua_lam'') trả về chua-lam, không trả rỗng',
   cum_cua('Chua_lam') = 'chua-lam'),

  (11, 'Khung nhìn tien_do_o đã đổi chữ trong ô so_kho',
   pg_get_viewdef('tien_do_o'::regclass) like '%Chua_lam%'
   and pg_get_viewdef('tien_do_o'::regclass) not like '%Confirm%'),

  -- ⚠️ ĐỎ Ở ĐÂY CÓ HAI NGHĨA NGƯỢC NHAU, ĐỌC CON SỐ RỒI HÃY KẾT LUẬN:
  --   dưới 29 → chép thiếu cột thật, app mất ô số trong im lặng → sửa ngay.
  --   đúng 36 → máy chủ đang chạy bản của `nang-cap-giao-cam-ket.sql` mục 10
  --             (thêm moc_id, ngay_bat_dau và năm cột sổ giao nhận). Nếu bạn
  --             VỪA chạy file này thì bản 36 cột ấy vừa bị cuốn đi — chạy lại
  --             `nang-cap-giao-cam-ket.sql` để dựng lại, không thì khối Kho cam
  --             kết mù.
  (12, 'tien_do_o còn đủ 29 cột (chép thiếu là app mất ô số trong im lặng)',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and table_name = 'tien_do_o') >= 29),

  (13, 'tien_do_o vẫn mang cột muc_tieu_id — mắt xích mảng dự án',
   exists (select 1 from information_schema.columns
            where table_name = 'tien_do_o' and column_name = 'muc_tieu_id')),

  (14, 'tien_do_o vẫn chạy security_invoker — không vượt mặt RLS',
   (select 'security_invoker=on' = any(coalesce(reloptions, '{}'))
      from pg_class where relname = 'tien_do_o')),

  (15, 'KHÔNG khung nhìn nào trong CSDL còn nhắc chữ Confirm',
   not exists (select 1 from pg_views
                where schemaname = 'public' and definition like '%Confirm%')),

  (16, 'KHÔNG hàm nào trong CSDL còn nhắc chữ Confirm',
   not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                where n.nspname = 'public' and p.prosrc like '%Confirm%')),

  -- ⚠️ ĐÃ SỬA 28/08 — BẢN CŨ TỰ MÂU THUẪN, ĐỪNG TRẢ NÓ VỀ.
  -- Bản đầu hỏi `not exists (… where trang_thai = 'Chua_lam')`, tức đòi TUYỆT
  -- ĐỐI KHÔNG dòng nào mang chính cái tên mà cả file này sinh ra. Nó chọi
  -- thẳng vào dòng 6 ('bảng tra PHẢI có dòng Chua_lam') và dòng 10, 11 — ba
  -- dòng ấy xanh thì dòng này bắt buộc đỏ. Nói cách khác: bản cũ chỉ xanh khi
  -- đợt sửa KHÔNG chạy. Đã đỏ thật ở lượt chạy của Tracy 28/08, trong khi máy
  -- chủ hoàn toàn đúng.
  --
  -- Ý ĐỊNH THẬT của dòng này là câu ở nhãn: soi xem có TÊN THỨ HAI cho cùng
  -- một ý nào lẻn vào không. Mục 5 của file đã cân rồi bác hai cái tên khác —
  -- `Cho_lam` và `Chua_bat_dau` — nên đó mới là thứ phải đi tìm, cùng với chữ
  -- `Confirm` đáng lẽ đã đi hẳn.
  (17, 'KHÔNG có tên thứ hai lẻn vào: không dòng nào mang Confirm, Cho_lam hay Chua_bat_dau',
   not exists (select 1 from task
                where trang_thai in ('Confirm', 'Cho_lam', 'Chua_bat_dau'))
   and not exists (select 1 from cum_trang_thai_task
                    where trang_thai in ('Confirm', 'Cho_lam', 'Chua_bat_dau'))),

  -- ⚠️ DÒNG NÀY ĐÃ ĐỔI CÁCH HỎI 27/08 — ĐỪNG TRẢ LẠI BẢN CŨ.
  -- Bản đầu hỏi `attnotnull` của `tieu_diem.luong`, tức đòi cột ấy VẪN NOT
  -- NULL. Nhưng file anh em cùng đợt — `nang-cap-giao-cam-ket.sql` mục 3a —
  -- CỐ Ý bỏ NOT NULL và thay bằng ràng buộc `luong_rong_chi_khi_cho_nhan`,
  -- để cam kết đang chờ nhận nằm kho mà không chiếm luống nào.
  -- Giữ bản cũ thì chạy hai file theo bất kỳ thứ tự nào cũng in một ❌ oan ở
  -- đây trong khi máy chủ hoàn toàn đúng. Nguy hiểm nằm ở cách chữa hiển
  -- nhiên: ai đó đọc nhãn "hàng rào ba luống" rồi chạy
  -- `alter table tieu_diem alter column luong set not null`. Lúc kho đang
  -- rỗng thì câu ấy CHẠY LỌT, và từ đó `giao_cam_ket()` gãy im lặng ở mọi
  -- lời giao. Đây đúng cái bệnh `va-sau-dot-soi-08-08.sql` mục 3 đã đặt tên.
  --
  -- Nay hỏi thứ VẪN CÒN ĐÚNG ở cả hai đời: hàng rào luống còn đứng, dù nó
  -- đang đứng bằng chân nào.
  (18, 'Tầng CAM KẾT còn nguyên hàng rào luống: hoặc luong NOT NULL, hoặc ràng buộc luong_rong_chi_khi_cho_nhan đang sống',
   (select attnotnull from pg_attribute
     where attrelid = 'tieu_diem'::regclass and attname = 'luong')
   or exists (select 1 from pg_constraint
               where conrelid = 'tieu_diem'::regclass
                 and conname = 'luong_rong_chi_khi_cho_nhan'))
   -- CỐ Ý KHÔNG soi thêm dữ liệu thật ở đây (kiểu "không dòng nào luống rỗng
   -- ngoài dòng đang nằm kho"). Câu ấy phải đọc hai cột `giao_luc` và
   -- `nhan_viec_luc`, mà hai cột ấy chỉ mọc lên khi file kia đã chạy — chạy
   -- file này trước thì CẢ BẢNG tự kiểm đổ với lỗi "column does not exist",
   -- tệ hơn hẳn một dấu ❌. Phép soi dữ liệu thật nằm đúng chỗ của nó: bộ tự
   -- kiểm của `nang-cap-giao-cam-ket.sql`, mục 28.
)
select thu_tu,
       case when dat then '✅' else '❌ CHƯA ĐẠT' end as ket_qua,
       muc
from kt order by thu_tu;


-- ── Kiểm nhanh bằng mắt sau khi chạy ───────────────────────────────────────
-- ① Việc đang nằm ở nấc nào, mỗi nấc mấy dòng:
--      select trang_thai, count(*) from task group by trang_thai order by 2 desc;
-- ② Bảng tra bảy nấc, đọc theo thứ tự dòng chảy:
--      select * from cum_trang_thai_task order by thu_tu;
-- ③ Kho việc chưa hẹn ngày của từng cam kết (ô so_kho phải khác 0 ở đâu đó):
--      select ma, ten, so_kho from tien_do_o where so_kho > 0 order by so_kho desc;
-- ④ Quay lui trọn file này:
--      alter table task drop constraint if exists task_trang_thai_hop_le;
--      update task set trang_thai = 'Confirm' where trang_thai = 'Chua_lam';
--      alter table task alter column trang_thai set default 'Confirm';
--      insert into cum_trang_thai_task values ('Confirm','chua-lam',false,true,1)
--        on conflict do nothing;
--      delete from cum_trang_thai_task where trang_thai = 'Chua_lam';
--      alter table task add constraint task_trang_thai_hop_le check (trang_thai in
--        ('Confirm','Doing','Done','Chua_xong','Blocked','Da_chuyen','Da_huy'));
--      -- rồi chạy lại nang-cap-mang-du-an.sql để dựng lại tien_do_o bản cũ.


-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ VIỆC CÒN LẠI — SQL KHÔNG VỚI TỚI. PHẢI SỬA TAY, KHÔNG SỬA LÀ APP VỠ.
-- ════════════════════════════════════════════════════════════════════════════
-- ⚠️ TẠO VIỆC MỚI VẪN CHẠY — VÀ ĐÓ MỚI LÀ CHỖ NGUY HIỂM.
-- Bản đầu của khối này viết "app KHÔNG TẠO ĐƯỢC VIỆC MỚI: mã cũ vẫn gửi chữ
-- Confirm xuống". Đọc lại mã thì SAI: năm trong sáu chỗ `sb.from('task')
-- .insert` (khoảng dòng 7649, 7842, 12072, 14147, 17203) KHÔNG gửi
-- `trang_thai` — chúng dựa vào mặc định của cột, mà mục 2 vừa đổi mặc định
-- sang `Chua_lam`. Chỉ hàm nạp dữ liệu mẫu (khoảng 18559–18561) gửi thẳng chữ
-- cũ. Nghĩa là người thử sẽ tạo được việc mới bình thường và tưởng đã lên sóng
-- an toàn.
--
-- Thứ HỎNG THẬT nặng hơn và im lặng hơn, xếp theo mức đau:
--   ① `TT_MO` (≈7088) nuôi HAI truy vấn LỌC PHÍA MÁY CHỦ — `.in('trang_thai',
--      TT_MO)` ở ≈6529 và ≈6538. Danh sách vẫn là ['Confirm',…] nên không khớp
--      `Chua_lam` nữa: KHO VIỆC RỖNG SẠCH ở nghi thức chọn việc buổi sáng, và
--      việc quá hạn chưa bắt đầu biến mất khỏi màn Hôm nay. Không lỗi nào báo,
--      chỉ là một danh sách trống.
--   ② `TASK_THEO_O` (≈6608) không có ô `Chua_lam`, nên `o[d.trang_thai]` là
--      undefined và số task cạnh mỗi cam kết đếm hụt.
--   ③ `TT_NHAN` (≈7078) không có khoá `Chua_lam`, nên nhãn trạng thái in ra
--      chữ "undefined" cho người dùng đọc.
-- Sửa ① trước tiên. Hai bên phải lên cùng một lượt.
--
-- ⚠️ SỐ DÒNG DƯỚI ĐÂY lấy từ bản kiểm kê 27/08 (`public/index.html` = 18.650
-- dòng, có 807 dòng chưa commit của phiên khác). Số dòng ĐÃ LỆCH ngay khi ai đó
-- gõ thêm một dòng. LUÔN `grep -n "Confirm" public/index.html` lại trước khi
-- sửa, đừng nhảy thẳng tới số dòng.
--
-- ─── A. PHẢI ĐỔI — mã so chuỗi, khoá từ điển, giá trị ghi xuống ─────────────
--   ⚠️ BA DÒNG ĐẦU LÀ BA CHỖ ĐAU NHẤT, SỬA TRƯỚC:
--   7088   `TT_MO = ['Confirm','Doing','Chua_xong','Blocked']`
--          (nuôi `.in('trang_thai',TT_MO)` ở 6529, 6538 — HAI TRUY VẤN LỌC
--           PHÍA MÁY CHỦ — và `TT_MO.includes()` ở 6615; sửa một chỗ này là đủ
--           cho cả ba. Không sửa thì kho việc rỗng sạch, xem khối ⚠️ ở trên.)
--   6608   khung đếm `TASK_THEO_O`: `{tong:0, Confirm:0, Doing:0, …}`
--   7078   `TT_NHAN = {Confirm:'Confirm', …}` — ĐỔI CẢ KHOÁ LẪN NHÃN.
--          Đây là chỗ chốt nhãn tiếng Việt: đề nghị `Chua_lam:'Chờ làm'`.
--          Không sửa thì nhãn in ra chữ "undefined".
--   ─── còn lại ───
--   2368   `.tt-Confirm{color:var(--tt-vang)}`   → `.tt-Chua_lam{…}`
--          (lớp CSS này được SINH RA từ giá trị trạng thái ở ba chỗ: 7437,
--           14012, 16791 — ba chỗ ấy không phải sửa, nhưng đổi tên lớp ở 2368
--           mà quên thì chip trạng thái mất màu, không ai báo lỗi.)
--   6731   giá trị dự phòng `|| {tong:0, Confirm:0, Doing:0, Done:0}`
--   7101   `TT_CHON = ['Confirm','Done','Chua_xong','Blocked','Da_huy']`
--   7156   `O_CAY.Confirm = {e:'🌱', ten:'Chưa làm — bấm để vào phiên deepwork'}`
--          (đổi khoá; nếu chốt nhãn "Chờ làm" thì sửa luôn chữ trong `ten` cho
--           ba tầng nói cùng một tên)
--   7187   dự phòng `O_CAY[t.trang_thai] || O_CAY.Confirm`
--   11068  `dwNhoTTCu(t.id, t.trang_thai || 'Confirm')` — GHI XUỐNG
--          localStorage `dw_tt_cu`. Xem mục C bên dưới, chỗ này có bẫy.
--   15907  `(t.trang_thai==='Confirm' || t.trang_thai==='Chua_xong') ? 'cho'`
--          — màu khối trên dải Timeline
--   16769  `['Chờ làm', 'var(--tt-vang)', ds.filter(t=>t.trang_thai==='Confirm')]`
--   17555  `DU_MAU_VIEC = { … 'Confirm':'chua', … }` — bảng màu hồ sơ dự án
--   18559–18561  ba dòng `trang_thai:'Confirm'` trong hàm nạp dự án mẫu
--
-- ─── B. NÊN SỬA CÙNG LƯỢT — chú thích nói sai sau khi đổi ───────────────────
--   2345 · 2352 · 6525 · 6685 · 7075 · 7212 · 10072 · 11060 · 12129 ·
--   16933 · 16940 · 17271–17272
--   Không sửa thì mã vẫn chạy, nhưng người đọc sáu tháng nữa tin vào chú thích
--   sai — đúng cái bệnh file này đang chữa.
--
-- ─── C. ⚠️ BẪY: DỮ LIỆU CŨ NẰM TRONG TRÌNH DUYỆT, KHÔNG NẰM Ở MÁY CHỦ ───────
--   `dw_tt_cu` (localStorage) đang giữ chuỗi 'Confirm' của những phiên deep
--   work đang dở TRÊN MÁY TỪNG NGƯỜI. File .sql không với tới đó, và người
--   dùng cũng không xoá bộ nhớ trình duyệt giúp mình.
--   Người vào phiên trước lúc lên bản mới, thoát phiên sau lúc lên bản mới, sẽ
--   được trả về trạng thái 'Confirm' — ràng buộc mới đá về, thoát phiên thất
--   bại, việc kẹt ở `Doing`.
--   Cách chữa rẻ nhất: chỗ ĐỌC lại (`dwLayTTCu`) dịch tại chỗ — đọc ra
--   'Confirm' thì trả về 'Chua_lam'. Ba dòng, và bỏ được sau vài tuần.
--
-- ─── D. BA BÀI THỬ SẼ ĐỎ NGAY — sửa kỳ vọng, đừng tắt bài thử ───────────────
--   thu-kho-cam-ket.js:40 (bản chép `TT_MO`) · 64–68 (5 dòng dữ liệu mẫu)
--   thu-luong-nghen.js:189, 265, 293 (dữ liệu mẫu)
--                     · 270, 279, 283 (kỳ vọng: `tckDoiTT('Confirm', …)`)
--   thu-trang-thai-phien.js:11, 111, 115, 132, 136, 140–141, 145, 153, 162, 166
--                     (cả vòng nhớ/trả trạng thái quanh `dw_tt_cu`; dòng 132
--                      giữ luật "bỏ cuộc → Chua_xong, không nâng thành nấc đầu"
--                      — luật ấy KHÔNG đổi, chỉ đổi chữ)
--   thu-man-don.js:68 (dữ liệu mẫu)
--
-- ─── E. LỖI CÓ SẴN, KHÔNG PHẢI DO ĐỢT NÀY GÂY RA ───────────────────────────
--   `public/index.html:17557` in MÃ TRẦN ra màn, không đi qua `TT_NHAN`:
--     `duNhanViec = tt => <span …>${chuSach(tt)}</span>`  (gọi ở 17852)
--   Hôm nay nó hiện "Confirm", "Chua_xong" nguyên gạch dưới cho người dùng đọc.
--   Sau đợt này nó hiện "Chua_lam" — xấu như cũ, không xấu thêm. Đáng sửa,
--   nhưng là việc riêng: cho nó đi qua `TT_NHAN` như ba chỗ kia.
--
-- ─── F. FILE .sql SẼ BÁO ❌ GIẢ NẾU AI CHẠY LẠI ─────────────────────────────
--   Hai câu tự kiểm dưới đây khai bảy tên CŨ. Chúng không làm hỏng gì, nhưng
--   sẽ kêu ❌ sau đợt này — sửa chữ `'Confirm'` thành `'Chua_lam'` trong:
--     · nang-cap-mang-du-an.sql:1041   (mục 15)
--     · kiem-lai-mang-du-an.sql:89     (bản sao mục 15)
--   Và BỐN khung nhìn `tien_do_o` hoá thạch: ai chạy lại một trong bốn file
--   này là `tien_do_o` LÙI VỀ BẢN CŨ, mất cột `muc_tieu_id` và mang lại chữ
--   `Confirm` — chữa bằng cách chạy lại đúng file này:
--     · nang-cap-hien-co-va-sua-phien.sql:148   (12/08)
--     · nang-cap-ghi-chu.sql:133                (14/08)
--     · nang-cap-gio-deepwork-theo-loai.sql:215 (17/08)
--     · nang-cap-dem-o-may-chu.sql:72 · nang-cap-output-cam-ket.sql:173
--       (08/08 và 11/08 — hai bản này còn mang cả 'Miss' và 'Nghen' đã bỏ)
--   `schema.sql:140–141` và `va-luat-3b.sql:53` cũng còn chữ cũ. CỐ Ý KHÔNG
--   SỬA: chúng là lịch sử của cơ sở dữ liệu này, và một máy chủ dựng mới từ
--   `schema.sql` rồi chạy tuần tự các file nâng cấp vẫn ra đúng kết quả.
-- ════════════════════════════════════════════════════════════════════════════


-- `drop view` rồi `create view` ở mục 6 ĐỔI OID của quan hệ, mà PostgREST giữ
-- bộ nhớ đệm lược đồ theo OID. Không đánh thức nó thì cho tới lúc nó tự làm
-- mới, app có thể nhận lỗi quyền hoặc lỗi không tìm thấy quan hệ khi đọc
-- `tien_do_o` — một lỗi rất khó lần ra từ phía giao diện vì màn hình chỉ báo
-- trống. Đứng NGOÀI transaction, đúng nếp `nang-cap-giao-cam-ket.sql`.
notify pgrst, 'reload schema';
