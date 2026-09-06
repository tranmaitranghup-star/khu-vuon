-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: cột `task.rieng_tu`, và hàm `cham_rieng_tu_phien`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- KHU VƯỜN TỈNH THỨC ROVA — LOẠI CÁ NHÂN cho việc và sự kiện
--                                     (Tracy duyệt 04/09/2026 — phương án A)
--
-- CÁCH DÙNG: Supabase → SQL Editor → New query → dán trọn file → Run.
--            Chạy lại nhiều lần vô hại (idempotent).
--            SAU KHI CHẠY: đẩy bản `public/index.html` mới lên (làn CNH).
--
-- ─── ĐỀ BÀI ─────────────────────────────────────────────────────────────────
-- Tracy 04/09: *"Loại việc và sự kiện tôi muốn phát triển thêm loại Cá nhân
-- (với loại việc và sự kiện này thì không được tính vào dashboard của ROVA và
-- giữ riêng tư cho mọi người)"*
--
-- Hai đòi hỏi rời nhau, và chúng cần hai hàng rào KHÁC NHAU:
--   ① RIÊNG TƯ  → người khác không đọc được dòng ấy. Hàng rào ở tầng quyền.
--   ② KHÔNG TÍNH → dòng ấy không góp số vào bảng của đội, KỂ CẢ ở hàng của
--      chính chủ. Hàng rào ở khung nhìn.
-- Chỉ làm ① thì hàng của chính chủ trên bảng đội vẫn cao hơn cái đồng đội nhìn
-- thấy — một con số không ai đối chiếu được. Nên phải làm cả hai.
--
-- ─── VÌ SAO KHÔNG DÙNG LẠI `pham_vi = 'ca_nhan'` ────────────────────────────
-- Giá trị ấy đã có từ 31/08 và nó mang nghĩa **"Mời người cụ thể"** — hẹn 1-1,
-- người nhận là đúng những cái tên được mời. Đó là chuyện AI NHẬN, không phải
-- chuyện AI ĐƯỢC NHÌN. Một cuộc hẹn 1-1 vẫn hiện chữ "Bận" trên lịch người
-- khác (Tracy chốt 03/09) — đúng như Lịch Google bày lịch người chỉ có quyền
-- xem rảnh-bận. Sự kiện CÁ NHÂN thì không: nó biến mất hẳn.
-- Đè hai nghĩa lên một giá trị là làm hỏng tính năng đang chạy. Nên riêng tư
-- đi bằng một CỜ RIÊNG, đứng cạnh `pham_vi` chứ không thay nó.
--
-- ─── VÌ SAO CỜ NẰM TRÊN CẢ `phien_deepwork` ─────────────────────────────────
-- Khung nhìn `gio_deepwork_theo_loai` cố ý KHÔNG nối sang `task` (luật đặt ra
-- 01/09, lý lẽ ở `DA-SOI-TRONG-MA.md` mục 🔒): nối sang thì việc còn trong kho
-- đẻ ra một ô "không rõ loại" cho đồng đội đọc, mà ô đó tố giác đúng thứ policy
-- kia định giấu. Cùng lý lẽ ấy áp cho việc riêng tư — nặng hơn nữa là **lộ
-- bằng phép trừ**: tổng phút mỗi người mỗi ngày vốn công khai, nên chỉ cần lấy
-- tổng trừ đi các ô nhìn thấy là ra phần giấu.
-- Nên nhãn phải nằm trên CHÍNH dòng phiên, đi đúng lối `viec_co_dinh`
-- (`nang-cap-loai-viec-co-dinh.sql:82`) và `co_cam_ket`
-- (`nang-cap-loai-phien.sql:32`) đã đi.
--
-- ⚠️ Cột chép thì cũ đi trong im lặng. Nên ở đây nó KHÔNG do app ghi: hai cò
--    máy chủ giữ nó khớp, và app không được đụng vào. Một cờ riêng tư mà phụ
--    thuộc vào việc máy khách có nhớ ghi hay không thì không phải một hàng rào.
--
-- ─── BA ĐIỀU FILE NÀY CỐ Ý KHÔNG LÀM ────────────────────────────────────────
--   · Không đụng `pham_vi = 'ca_nhan'` sẵn có (lý lẽ ở trên).
--   · Không vá lỗ *lộ bằng phép trừ* cho việc THƯỜNG còn trong kho — đó là một
--     lỗ có từ trước, đã ghi ở `DA-SOI-TRONG-MA.md`, và là một việc riêng.
--   · Không đụng `vuon_cay`, `gio_deepwork_theo_ngay`, `gio_deepwork_theo_gio`,
--     `dem_task_theo_o`, `tien_do_o` — app chỉ đọc chúng bằng
--     `.eq('nguoi_id', ME.id)`, tức màn của riêng mình. Tracy chốt: việc cá
--     nhân VẪN tính giờ và VẪN mọc cây trong vườn của chính chủ.
--
-- ─── CỬA LÙI ────────────────────────────────────────────────────────────────
-- Chạy file này mà chưa đẩy HTML mới: cả ba cột mặc định `false`, không dòng
-- nào đổi nghĩa, app cũ chạy y như cũ. Đẩy HTML mới mà chưa chạy file này: ô
-- chọn "Cá nhân" ghi xuống một cột chưa có, máy chủ trả lỗi và app báo không
-- lưu được — không có khoảnh khắc nào một việc riêng tư bị ghi thành công khai.
-- ============================================================================

begin;

-- ═══ 1. BA CỘT CỜ ══════════════════════════════════════════════════════════
-- `not null default false`: mọi dòng đã có đều là việc chung, đúng như nó đang
-- là. Không có trạng thái "chưa biết" cho một cờ riêng tư — chưa biết thì mặc
-- định phải là công khai, vì đó là điều đúng với 100% dữ liệu cũ.

alter table task           add column if not exists rieng_tu boolean not null default false;
alter table lich_chung     add column if not exists rieng_tu boolean not null default false;
alter table phien_deepwork add column if not exists rieng_tu boolean not null default false;

comment on column task.rieng_tu is
  'Việc loại CÁ NHÂN — chỉ chủ của nó đọc được (policy doc_task), và không góp '
  'số vào bảng nào của đội (gat_theo_ngay, cham_theo_ngay). Vẫn mọc cây trong '
  'vườn của chính chủ và vẫn tính vào giờ deepwork của riêng họ: Tracy chốt '
  '04/09 rằng cá nhân là RIÊNG, không phải KHÔNG TÍNH GÌ CẢ.';

comment on column lich_chung.rieng_tu is
  'Sự kiện loại CÁ NHÂN — biến mất hẳn khỏi lịch người khác, không hiện cả chữ '
  '"Bận". Khác hẳn pham_vi = ''ca_nhan'' (nghĩa là "Mời người cụ thể", một cuộc '
  'hẹn 1-1 vẫn cho người ngoài thấy khung giờ đã kín). Ràng buộc lich_rieng_tu_la_ca_nhan '
  'không cho một sự kiện riêng tư gửi cho cả công ty.';

comment on column phien_deepwork.rieng_tu is
  'Chép từ task.rieng_tu, do HAI CÒ máy chủ giữ khớp — app không ghi cột này. '
  'Có mặt ở đây để gio_deepwork_theo_loai và cham_theo_ngay lọc được mà không '
  'phải nối sang task; nối sang là đẻ ra ô rỗng tố giác, và là lộ bằng phép trừ '
  '(DA-SOI-TRONG-MA.md mục 🔒). Phiên gắn nhịp (task_id rỗng) luôn là false.';


-- ═══ 2. SỰ KIỆN RIÊNG TƯ THÌ KHÔNG GỬI CHO NHÓM ════════════════════════════
-- Một sự kiện vừa "riêng tư" vừa "cả công ty" là một câu tự mâu thuẫn. Chặn nó
-- ở kho thay vì tin máy khách không bao giờ gửi lên: ô chọn trong app đã lo,
-- nhưng khoá công khai nằm ngay trong mã nguồn trang web nên hàng rào thật
-- phải ở đây.
alter table lich_chung drop constraint if exists lich_rieng_tu_la_ca_nhan;
alter table lich_chung add  constraint lich_rieng_tu_la_ca_nhan
  check (not rieng_tu or pham_vi = 'ca_nhan');


-- ═══ 3. BỐN CÒ GIỮ BA CỜ KHỚP NHAU ════════════════════════════════════════
-- Cò ①: mỗi phiên sinh ra (hoặc đổi việc gắn vào) thì đọc lại cờ từ task.
-- Viết `security definer` vì hàm chạy trong ngữ cảnh của người dùng, mà cột
-- cần đọc nằm trên một dòng chính họ ĐANG được đọc (việc của họ) — nên đây
-- không phải một cửa mở thêm quyền, chỉ là giữ cho cò chạy được kể cả khi
-- policy về sau siết thêm.
create or replace function cham_rieng_tu_phien()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  new.rieng_tu := coalesce((select t.rieng_tu from task t where t.id = new.task_id), false);
  return new;
end $$;

drop trigger if exists tg_cham_rieng_tu_phien on phien_deepwork;
create trigger tg_cham_rieng_tu_phien
  before insert or update of task_id on phien_deepwork
  for each row execute function cham_rieng_tu_phien();

-- Cò ②: đổi cờ của MỘT VIỆC thì mọi phiên đã chạy cho việc ấy đổi theo. Đây là
-- vế thiếu của cò ①: không có nó thì bật riêng tư cho một việc đã có 10 phiên
-- chỉ giấu được cái việc, còn 10 dòng phiên vẫn nằm trong tổng của đội.
create or replace function cham_rieng_tu_theo_viec()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  update phien_deepwork set rieng_tu = new.rieng_tu
   where task_id = new.id and rieng_tu is distinct from new.rieng_tu;
  return new;
end $$;

drop trigger if exists tg_cham_rieng_tu_theo_viec on task;
create trigger tg_cham_rieng_tu_theo_viec
  after update of rieng_tu on task
  for each row when (old.rieng_tu is distinct from new.rieng_tu)
  execute function cham_rieng_tu_theo_viec();

-- Cò ③: việc SINH TỪ MỘT SỰ KIỆN riêng tư thì cũng riêng tư. `lcDeViec` bên
-- app đẻ ra những dòng này; để app tự nhớ đặt cờ là để ngỏ đúng chỗ dễ quên
-- nhất, vì nó là một đường ghi tự động không ai nhìn thấy lúc chạy.
create or replace function cham_rieng_tu_viec_cua_buoi()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  if new.lich_id is not null and not new.rieng_tu then
    new.rieng_tu := coalesce((select l.rieng_tu from lich_chung l where l.id = new.lich_id), false);
  end if;
  return new;
end $$;

drop trigger if exists tg_cham_rieng_tu_viec_cua_buoi on task;
create trigger tg_cham_rieng_tu_viec_cua_buoi
  before insert or update of lich_id on task
  for each row execute function cham_rieng_tu_viec_cua_buoi();

-- Cò ④: đổi cờ của MỘT SỰ KIỆN thì mọi việc nó đã đẻ ra đổi theo. Đây là vế
-- thiếu của cò ③, đúng cách cò ② là vế thiếu của cò ①. Không có nó thì đổi một
-- sự kiện cá nhân thành "Cả công ty" chỉ mở cái sự kiện ra, còn mười việc đã
-- sinh từ nó vẫn khuất khỏi cả đội — sai theo hướng an toàn, nhưng vẫn là sai,
-- và là kiểu sai không ai đi tìm vì màn hình nói mọi thứ đã công khai.
-- Luật một câu: cờ của SỰ KIỆN cai quản mọi việc mang `lich_id` của nó.
create or replace function cham_rieng_tu_theo_su_kien()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  update task set rieng_tu = new.rieng_tu
   where lich_id = new.id and rieng_tu is distinct from new.rieng_tu;
  return new;
end $$;

drop trigger if exists tg_cham_rieng_tu_theo_su_kien on lich_chung;
create trigger tg_cham_rieng_tu_theo_su_kien
  after update of rieng_tu on lich_chung
  for each row when (old.rieng_tu is distinct from new.rieng_tu)
  execute function cham_rieng_tu_theo_su_kien();


-- ═══ 4. LẤP CHO DỮ LIỆU ĐÃ CÓ ══════════════════════════════════════════════
-- Lần chạy đầu chưa có dòng riêng tư nào nên câu này không đổi gì. Nó có mặt
-- để lần chạy THỨ HAI — sau khi tính năng đã dùng một thời gian — kéo lại mọi
-- dòng lệch pha, nếu có. Chạy lại file là một phép soát, không phải một phép
-- ghi mù.
-- Thứ tự có nghĩa: kéo VIỆC khớp SỰ KIỆN trước, rồi mới kéo PHIÊN khớp VIỆC —
-- ngược lại là phiên khớp với một cờ việc sắp bị đổi ngay câu sau.
update task t
   set rieng_tu = l.rieng_tu
  from lich_chung l
 where l.id = t.lich_id and t.rieng_tu is distinct from l.rieng_tu;

update phien_deepwork p
   set rieng_tu = t.rieng_tu
  from task t
 where t.id = p.task_id and p.rieng_tu is distinct from t.rieng_tu;


-- ═══ 5. BA CHÍNH SÁCH ĐỌC ══════════════════════════════════════════════════
-- Đây là hàng rào ①. Không có nó thì mọi thứ dưới đây chỉ là che mắt: khoá
-- công khai nằm trong mã nguồn trang web, ai mở app cũng truy vấn thẳng kho.

-- VIỆC. Giữ nguyên vế cũ (cả đội đọc việc ĐÃ hẹn ngày, việc trong kho chỉ chủ
-- đọc — `va-sau-dot-soi-08-08.sql:53`), thêm vế riêng tư đứng độc lập: một việc
-- cá nhân ĐÃ hẹn ngày vẫn phải khuất, nên vế mới không thể gộp vào vế cũ.
drop policy if exists doc_task on task;
create policy doc_task on task for select
  using (
    la_thanh_vien()
    and (ngay is not null or nguoi_id = nguoi_id_dang_nhap())
    and (not rieng_tu    or nguoi_id = nguoi_id_dang_nhap())
  );

comment on policy doc_task on task is
  'Cả đội đọc việc ĐÃ hẹn ngày. Việc còn trong kho (ngay rỗng) chỉ chủ đọc được. Việc loại CÁ NHÂN (rieng_tu) chỉ chủ đọc được, kể cả khi đã hẹn ngày.';

-- SỰ KIỆN. Trước file này, `doc_lich` là `la_thanh_vien()` trần — cả đội đọc
-- được MỌI dòng sự kiện, và việc che chỉ diễn ra ở màn hình (`dbTenBuoi` in chữ
-- "Bận"). Với hẹn 1-1 thì chấp nhận được, vì thứ giấu chỉ là cái tên buổi. Với
-- sự kiện cá nhân thì không: giấu phải là giấu thật.
drop policy if exists doc_lich on lich_chung;
create policy doc_lich on lich_chung for select
  using (la_thanh_vien() and (not rieng_tu or tao_boi = nguoi_id_dang_nhap()));

comment on policy doc_lich on lich_chung is
  'Cả đội đọc mọi sự kiện — để còn biết khối bên cạnh họp lúc nào mà tránh trùng giờ. Trừ sự kiện loại CÁ NHÂN: chỉ người tạo ra nó đọc được.';

-- PHIÊN DEEP WORK. Không siết chỗ này thì một phiên chạy cho việc riêng tư vẫn
-- hiện trong `ai_dang_lam` ("đang làm gì đó") và vẫn góp phút vào mọi khung
-- nhìn đọc thẳng bảng phiên.
drop policy if exists doc_deepwork on phien_deepwork;
create policy doc_deepwork on phien_deepwork for select
  using (la_thanh_vien() and (not rieng_tu or nguoi_id = nguoi_id_dang_nhap()));

comment on policy doc_deepwork on phien_deepwork is
  'Cả đội đọc phiên của nhau. Trừ phiên chạy cho một việc CÁ NHÂN: chỉ chủ đọc được. Cột rieng_tu do cò máy chủ chép từ task, app không ghi nó.';


-- ═══ 6. HAI BẢNG CON CỦA LỊCH SOI NGƯỢC VỀ DÒNG CHA ════════════════════════
-- Ngoại lệ ("buổi ngày ấy huỷ") và điểm danh ("tôi có dự") của một sự kiện
-- riêng tư cũng là chuyện riêng — và chúng mang `lich_id`, tức đủ để đếm được
-- một người có bao nhiêu buổi riêng và vào ngày nào.
-- Soi ngược về dòng cha thay vì chép lại luật: policy chạy bằng quyền NGƯỜI
-- GỌI nên câu `exists` dưới đây đã đi qua `doc_lich` — sự kiện cha khuất thì
-- câu hỏi trả lời "không", và dòng con khuất theo. Một luật, một chỗ sửa.
drop policy if exists doc_lich_ngoai on lich_chung_ngoai_le;
create policy doc_lich_ngoai on lich_chung_ngoai_le for select
  using (la_thanh_vien() and exists (
           select 1 from lich_chung l where l.id = lich_chung_ngoai_le.lich_id));

drop policy if exists doc_lich_td on lich_chung_tham_du;
create policy doc_lich_td on lich_chung_tham_du for select
  using (la_thanh_vien() and exists (
           select 1 from lich_chung l where l.id = lich_chung_tham_du.lich_id));


-- ═══ 7. BA KHUNG NHÌN CỦA BẢNG ĐỘI ═════════════════════════════════════════
-- Đây là hàng rào ②. Mục 5 đã lo phần đồng đội không nhìn thấy; ba câu dưới
-- lo phần CHÍNH CHỦ cũng không thấy việc riêng của mình cộng vào bảng chung —
-- nếu không, hàng của họ trên bảng đội là một con số không ai đối chiếu được.
--
-- ⚠️ Chỉ ba khung nhìn này, và chỉ vì cả ba đều CHỈ nuôi màn của đội:
--      gio_deepwork_theo_loai → dải Giờ deepwork ở màn Cả ROVA (`rvdTai`)
--      cham_theo_ngay         → bảng vinh danh 💧 người làm vườn chăm chỉ
--      gat_theo_ngay          → bảng Kết quả trong ngày ở màn Bảng đo
--    `vuon_cay`, `gio_deepwork_theo_ngay`, `gio_deepwork_theo_gio`,
--    `dem_task_theo_o`, `tien_do_o` KHÔNG đụng tới: app đọc chúng bằng
--    `.eq('nguoi_id', ME.id)`, tức chúng là màn của riêng mình.
--
-- `create or replace` chứ không `drop` rồi tạo lại: bộ cột không đổi, và
-- `replace` giữ được cờ `security_invoker`, còn `drop` thì làm mất nó TRONG IM
-- LẶNG (`nang-cap-cong-gac-khung-nhin.sql` mục đầu). Ba câu `alter view` cuối
-- mục là lưới hứng, không phải thứ thay cho việc chọn đúng lệnh.

create or replace view gio_deepwork_theo_loai as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  case
    when p.nhip_id is not null then 'co_dinh'
    when p.co_cam_ket          then 'cam_ket'
    when p.viec_co_dinh        then 'co_dinh'
    else                            'phat_sinh'
  end                                               as loai,
  count(*)                                          as so_phien,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.ket_thuc is not null
  and not p.rieng_tu
group by p.nguoi_id,
         (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date,
         3;

create or replace view cham_theo_ngay as
select
  p.nguoi_id,
  (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date as ngay,
  count(*)                                          as so_lan_cham,
  round(sum(least(extract(epoch from (p.ket_thuc - p.bat_dau)) / 60, 180))) as phut
from phien_deepwork p
where p.ket_qua = 'song' and p.task_id is not null
  and not p.rieng_tu
group by p.nguoi_id, (p.bat_dau at time zone 'Asia/Ho_Chi_Minh')::date;

create or replace view gat_theo_ngay as
select
  t.nguoi_id,
  (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date          as ngay,
  count(*)                                                    as so_qua,
  count(*) filter (where dw.task_id is not null)              as so_qua_dw
from task t
left join (select distinct task_id
             from phien_deepwork
            where ket_qua = 'song' and task_id is not null) dw
       on dw.task_id = t.id
where t.trang_thai = 'Done'
  and t.xong_luc is not null
  and not t.rieng_tu
group by t.nguoi_id, (t.xong_luc at time zone 'Asia/Ho_Chi_Minh')::date;

alter view gio_deepwork_theo_loai set (security_invoker = on);
alter view cham_theo_ngay         set (security_invoker = on);
alter view gat_theo_ngay          set (security_invoker = on);

commit;


-- ⚠️ THỨ TỰ HAI KHỐI NÀY CÓ NGHĨA — đảo lại 04/09 sau khi Tracy chạy thật.
-- Trình soạn SQL của Supabase chỉ bày kết quả của câu LỆNH CUỐI CÙNG. Bản đầu
-- xếp số liệu tham khảo sau bộ tự kiểm, nên thứ Tracy nhìn thấy là ba con số 0
-- — đúng nhưng vô thưởng vô phạt — còn mười dòng đạt/chưa đạt thì bị che, phải
-- chạy lại một lượt nữa mới thấy. Câu quan trọng nhất phải đứng CUỐI.
-- Mọi tệp nâng cấp sau này xếp theo thứ tự này.

-- ═══ SỐ LIỆU THAM KHẢO — không có đúng/sai ═════════════════════════════════
select
  (select count(*) from task           where rieng_tu) as viec_ca_nhan,
  (select count(*) from lich_chung     where rieng_tu) as su_kien_ca_nhan,
  (select count(*) from phien_deepwork where rieng_tu) as phien_ca_nhan;


-- ═══ TỰ KIỂM — cột `dat` phải ĐÚNG cả mười dòng ═══════════════════════════
select * from (values
  (1, 'ba cột rieng_tu có mặt, không cột nào cho rỗng',
   (select count(*) from information_schema.columns
     where table_schema = 'public' and column_name = 'rieng_tu'
       and table_name in ('task','lich_chung','phien_deepwork')
       and is_nullable = 'NO'
       and coalesce(column_default,'') like 'false%') = 3),

  (2, 'sự kiện riêng tư bị buộc phải là ca_nhan',
   (select pg_get_constraintdef(oid) from pg_constraint
     where conname = 'lich_rieng_tu_la_ca_nhan') like '%ca_nhan%'),

  (3, 'bốn cò giữ cờ đã dựng',
   (select count(*) from pg_trigger
     where not tgisinternal
       and tgname in ('tg_cham_rieng_tu_phien','tg_cham_rieng_tu_theo_viec',
                      'tg_cham_rieng_tu_viec_cua_buoi','tg_cham_rieng_tu_theo_su_kien')) = 4),

  (4, 'doc_task nay soi cả rieng_tu',
   (select qual from pg_policies
     where tablename = 'task' and policyname = 'doc_task') like '%rieng_tu%'),

  (5, 'doc_lich thôi là la_thanh_vien() trần',
   (select qual from pg_policies
     where tablename = 'lich_chung' and policyname = 'doc_lich') like '%rieng_tu%'),

  (6, 'doc_deepwork nay soi cả rieng_tu',
   (select qual from pg_policies
     where tablename = 'phien_deepwork' and policyname = 'doc_deepwork') like '%rieng_tu%'),

  (7, 'ba khung nhìn của bảng đội đều đã lọc',
   (select count(*) from pg_views
     where schemaname = 'public'
       and viewname in ('gio_deepwork_theo_loai','cham_theo_ngay','gat_theo_ngay')
       and definition like '%rieng_tu%') = 3),

  /* Dòng quan trọng nhất mục 7: `replace` phải GIỮ được cờ quyền. Mất cờ là mọi
     người đọc được số của nhau, mà mất trong im lặng — không lỗi nào báo. */
  (8, 'ba khung nhìn ấy vẫn chạy bằng quyền NGƯỜI GỌI',
   (select count(*) from pg_class c
     where c.relkind = 'v' and c.relname in
           ('gio_deepwork_theo_loai','cham_theo_ngay','gat_theo_ngay')
       and 'security_invoker=on' = any(coalesce(c.reloptions, '{}'))) = 3),

  (9, 'không dòng phiên nào lệch cờ so với việc của nó',
   not exists (select 1 from phien_deepwork p join task t on t.id = p.task_id
                where p.rieng_tu is distinct from t.rieng_tu)),

  (10, 'không việc nào lệch cờ so với sự kiện đẻ ra nó',
   not exists (select 1 from task t join lich_chung l on l.id = t.lich_id
                where t.rieng_tu is distinct from l.rieng_tu))
) as t(so, muc, dat)
order by dat, so;
