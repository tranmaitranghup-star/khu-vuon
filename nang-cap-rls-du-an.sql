-- ⛔ HAI PHẦN CỦA TỆP NÀY ĐÃ BỊ THAY THẾ — ĐỪNG CHẠY LẠI MỘT MÌNH (07/09, TRI-148)
-- Các policy dưới đây gọi `la_thanh_vien_du_an(bigint, uuid)`. Hàm ấy ĐÃ BỊ RÚT
-- quyền `execute` của vai `authenticated` ngày 07/09 vì nó là một cửa tra cứu mở
-- (đo được bằng khoá công khai — xem `nang-cap-bit-cua-tra-cuu-du-an.sql`). Chạy
-- lại tệp này một mình là dựng lại policy gọi một hàm mà người hỏi không có quyền
-- gọi → MỌI lượt `select` của thành viên ném "permission denied for function".
-- Hỏng to và hỏng ngay, không im lặng — nhưng vẫn là hỏng. Muốn chạy lại thì chạy
-- `nang-cap-bit-cua-tra-cuu-du-an.sql` NGAY SAU nó.
-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Tệp này KHÔNG dựng thứ gì mới — nó viết lại ba policy đã có. Nên dấu vết của
-- │ nó không nằm ở khối ① của `SO-SQL.sql` (khối "tệp nào đã chạy") mà ở khối ②,
-- │ khối hỏi theo NỘI DUNG: "policy doc_muctieu đã hỏi cấp chưa".
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NHÁT ② — GIỚI HẠN "DỰ ÁN CHỈ HIỆN DỰ ÁN CÓ TÊN MÌNH" XUỐNG TẦNG DỮ LIỆU
--                                          (Tracy duyệt 2026-09-07, TRI-144)
--
-- CHẠY SAU nhát ⓪ (`nang-cap-cap-dang-nhap.sql`) và nhát ① (`nang-cap-rls-cam-ket.sql`).
--
-- Phía màn hình, `duVeLuoi()` lọc lưới dự án cho Member bằng đúng hai vế:
--     d.nguoi_id === ME.id  ||  (d.nguoi_ganh || []).includes(ME.id)
-- tức PIC của dự án, hoặc có tên trong bảng gánh. Máy chủ thì chưa hỏi gì:
-- `doc_muctieu` · `doc_thanhvien` · `doc_moc` đều đang là `using (la_thanh_vien())`.
--
-- ═══ DÙNG LẠI ĐÚNG HÀM ĐÃ CÓ ════════════════════════════════════════════════
-- `la_thanh_vien_du_an(p_muc_tieu_id, p_nguoi_id)` (25/08) trả lời đúng câu hỏi
-- ấy và trả lời cả hai vế: `muc_tieu.nguoi_id = p_nguoi_id` (PIC) hoặc có dòng
-- trong `thanh_vien_du_an`. Không viết hàm thứ hai cho cùng một câu hỏi.
--
-- ⚠️ Hàm ấy là `security definer` — và ở đây điều đó KHÔNG phải chi tiết vụn.
-- Nó đọc chính `muc_tieu` và `thanh_vien_du_an`, hai bảng tệp này vừa siết. Là
-- `invoker` thì policy của `muc_tieu` gọi một hàm đọc `muc_tieu` → đệ quy vô
-- hạn, Postgres ném lỗi ngay lượt `select` đầu tiên. Là `definer` thì hàm chạy
-- bằng quyền người tạo, bỏ qua RLS, và vòng lặp không khép. Đừng "dọn" chữ
-- `security definer` khỏi hàm ấy.
--
-- ═══ 🪤 VẾ CHẶN NULL CHỈ CÓ Ở `tieu_diem`, VÀ ĐÓ LÀ CÓ LÝ DO ═════════════════
-- Nhát ① phải kèm `muc_tieu_id is not null` vì `tieu_diem.muc_tieu_id` do một
-- câu `alter table add column` sinh ra, KHÔNG có `not null` — 54/64 dòng đang
-- rỗng, mà `la_thanh_vien_du_an(null, …)` trả TRUE.
-- Ba bảng của nhát này thì khác, và đã tra tận nơi khai báo:
--     thanh_vien_du_an.muc_tieu_id   bigint NOT NULL  (còn là một nửa khoá chính)
--     moc_du_an.muc_tieu_id          bigint NOT NULL
--     muc_tieu.id                    khoá chính
-- nên vế chặn null ở đây là thừa, và thêm cho "đồng nhất" là dạy người đọc rằng
-- nó chỉ là một thói quen — rồi ngày ai đó dọn cả bốn cho gọn, cái duy nhất
-- LOAD-BEARING đi theo. Khác nhau ở đây là cố ý.
--
-- ═══ ⛔ MỘT MẢNG CỦA GIỚI HẠN ② TỆP NÀY KHÔNG ĐÓNG, VÀ VÌ SAO ═══════════════
-- Khung nhìn `viec_du_an` (danh sách VIỆC của một dự án, 69 dòng) đứng trên bảng
-- `task`, không đứng trên `muc_tieu`. Siết ba bảng dưới đây làm Member không còn
-- thấy dự án nào trong lưới, nhưng gõ thẳng `viec_du_an?muc_tieu_id=eq.12` thì
-- vẫn ra việc của dự án ấy.
--
-- Đóng nó phải siết `doc_task` — và ĐÓ LÀ RANH GIỚI ĐÃ KHOANH RA NGOÀI ĐỢT NÀY:
-- `gat_theo_ngay` và `vuon_cay` đều đọc `task`, mà hai khung nhìn ấy nuôi BẢNG
-- ĐO. Tracy chốt 07/09 rằng bảng đo và hàng deep work mở cho MỌI cấp, và
-- `thu-ba-cap.js` mục ⑤ có ca canh đúng chiều ấy. Siết `task` là bảng đo của
-- Member lệch số so với của Lead — hỏng một luật để vá một luật khác.
-- Đã ghi thành câu hỏi chờ Tracy phân xử (G-01.ap). Dòng ⑦ của bộ tự kiểm ĐO
-- chỗ hở ấy bằng số và gắn nhãn ℹ️, không gắn ❌ — nó là một quyết định đang
-- chờ, không phải một lỗi bỏ quên.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── ① DỰ ÁN ───────────────────────────────────────────────────────────────
drop policy if exists doc_muctieu on muc_tieu;

create policy doc_muctieu on muc_tieu for select
using (
  la_thanh_vien()
  and ( not la_member()                                    -- Lead · Quản trị: trọn bảng
     or la_thanh_vien_du_an(id, nguoi_id_dang_nhap()) )    -- PIC, hoặc có tên trong bảng gánh
);

comment on policy doc_muctieu on muc_tieu is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc dự án mình đứng tên — PIC '
  '(muc_tieu.nguoi_id) hoặc có dòng trong thanh_vien_du_an. Khớp đúng hai vế mà '
  'duVeLuoi() lọc phía màn hình. Siết RLS theo cấp, TRI-144, 07/09.';


-- ─── ② AI GÁNH DỰ ÁN ───────────────────────────────────────────────────────
-- Member thấy TRỌN danh sách người gánh của dự án mình có tên — không phải chỉ
-- dòng của chính mình. Màn dự án bày "ai đang gánh", cắt xuống một dòng là mỗi
-- người nhìn thấy một dự án chỉ có mình họ trong đó.
drop policy if exists doc_thanhvien on thanh_vien_du_an;

create policy doc_thanhvien on thanh_vien_du_an for select
using (
  la_thanh_vien()
  and ( not la_member()
     or la_thanh_vien_du_an(muc_tieu_id, nguoi_id_dang_nhap()) )
);

comment on policy doc_thanhvien on thanh_vien_du_an is
  'Lead và Quản trị đọc trọn bảng. Member đọc trọn danh sách người gánh của các '
  'dự án mình có tên — cố ý không cắt xuống một dòng, vì màn dự án bày cả nhóm.';


-- ─── ③ MỐC DỰ ÁN ───────────────────────────────────────────────────────────
drop policy if exists doc_moc on moc_du_an;

create policy doc_moc on moc_du_an for select
using (
  la_thanh_vien()
  and ( not la_member()
     or la_thanh_vien_du_an(muc_tieu_id, nguoi_id_dang_nhap()) )
);

comment on policy doc_moc on moc_du_an is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc mốc của dự án mình có tên. '
  'Mốc đi theo dự án: thấy mốc mà không thấy dự án là một dòng thời gian không '
  'gắn vào đâu.';


-- ─── ④ MỞ RỘNG BÀI THỬ SANG CÁC BẢNG CỦA NHÁT NÀY ──────────────────────────
-- Cùng một hàm của nhát ①, chỉ dài thêm danh sách bảng. `task` và `viec_du_an`
-- nằm trong danh sách KHÔNG phải để siết, mà để ĐO chỗ còn hở — một con số nhìn
-- thấy được thì không ai quên nó, còn một dòng ghi chú thì có.
create or replace function thu_hang_rao_cap()
returns table (ten text, cap text, chay_bang text, bang text, thay_bao_nhieu bigint)
language plpgsql
volatile                  -- cố ý KHÔNG `stable`: thân hàm gọi set_config, và một
                          -- hàm `stable` được phép gọi một lần rồi dùng lại kết quả
security invoker          -- phải chạy bằng quyền NGƯỜI GỌI, không thì vô nghĩa
set search_path = public
as $$
declare
  r    record;
  b    text;
  n    bigint;
  vai  text;
begin
  for r in
    select ng.ten, ng.email,
           case when ng.la_quan_tri then 'quan-tri'
                when ng.la_lead     then 'lead'
                else                     'member' end as c
      from nguoi ng
     order by 3, 1
  loop
    foreach b in array array['tieu_diem', 'tien_do_o',
                             'muc_tieu', 'danh_muc_du_an',
                             'thanh_vien_du_an', 'moc_du_an',
                             'viec_du_an', 'task'] loop
      perform set_config('request.jwt.claims',
                         json_build_object('role', 'authenticated',
                                           'email', r.email)::text, true);
      perform set_config('role', 'authenticated', true);

      select current_user into vai;
      execute format('select count(*) from %I', b) into n;

      -- Trả vai lại NGAY, trước khi vòng lặp ngoài lấy dòng người tiếp theo:
      -- `for r in select …` lấy dòng một cách lười, nên còn đội vai
      -- `authenticated` lúc nó với sang bảng `nguoi` là một lối hỏng khó thấy.
      execute 'reset role';

      ten := r.ten; cap := r.c; chay_bang := vai; bang := b; thay_bao_nhieu := n;
      return next;
    end loop;
  end loop;

  perform set_config('request.jwt.claims', '', true);
end $$;

comment on function thu_hang_rao_cap() is
  'Đóng vai từng người trong bảng nguoi rồi ĐẾM THẬT số dòng họ đọc được — bằng '
  'chứng cho hàng rào RLS theo cấp, thay cho việc soi chuỗi mã. Chỉ đọc, mọi '
  'thay đổi đều là SET LOCAL nên tự trả về sau giao dịch. ⚠️ Đọc cột chay_bang '
  'TRƯỚC: nó phải là "authenticated". Ra "postgres" nghĩa là lượt đổi vai không '
  'ăn và mọi con số trong bảng đều vô nghĩa — chủ bảng không bị policy soi. '
  'task và viec_du_an có trong danh sách để ĐO chỗ còn hở, không phải vì chúng '
  'đã được siết.';

revoke execute on function thu_hang_rao_cap() from public;

commit;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
-- Xem chi tiết từng người: chạy riêng `select * from thu_hang_rao_cap();`
with thu as (select * from thu_hang_rao_cap())
select so, muc, ket_qua from (values

  (1, 'cả ba policy dự án đã hỏi cấp',
      coalesce((select case when count(*) = 3 then '✅ đủ ba: ' || string_agg(policyname, ', ' order by policyname)
                            else '❌ mới ' || count(*) || '/3: '
                                 || coalesce(string_agg(policyname, ', ' order by policyname), '(chưa cái nào)') end
                  from pg_policies
                 where schemaname='public'
                   and policyname in ('doc_muctieu','doc_thanhvien','doc_moc')
                   and qual like '%la_member%'),
               '❌ chưa chạy được')),

  (2, 'cả ba đều đi qua đúng một cửa la_thanh_vien_du_an()',
      coalesce((select case when count(*) = 3 then '✅ đủ ba'
                            else '❌ mới ' || count(*) || '/3 — có chỗ tự chép lại điều kiện thay vì gọi hàm' end
                  from pg_policies
                 where schemaname='public'
                   and policyname in ('doc_muctieu','doc_thanhvien','doc_moc')
                   and qual like '%la_thanh_vien_du_an%'),
               '❌ chưa chạy được')),

  /* Chốt chống ✅ oan: đọc dòng này TRƯỚC mọi dòng có con số. */
  (3, 'bài thử thật sự chạy bằng vai authenticated, không phải chủ bảng',
      coalesce((select case when count(*) filter (where chay_bang <> 'authenticated') = 0
                            then '✅ authenticated'
                            else '❌ chạy bằng ' || string_agg(distinct chay_bang, ', ')
                                 || ' — chủ bảng không bị policy soi, mọi số dưới đây vô nghĩa' end
                  from thu),
               '❌ chưa chạy được')),

  (4, 'Member không còn đọc được dự án mình không có tên',
      coalesce((select case when max(thay_bao_nhieu) < (select count(*) from muc_tieu)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu) || ' / '
                                 || (select count(*) from muc_tieu) || ' dự án'
                            else '❌ vẫn đọc trọn ' || max(thay_bao_nhieu) || ' dự án — hàng rào chưa ăn' end
                  from thu where cap='member' and bang='muc_tieu'),
               '❌ chưa chạy được')),

  /* Mốc và bảng gánh phải đi theo dự án. Lệch nhau nghĩa là một trong ba policy
     hỏi một câu khác hai policy kia — chỗ hở kiểu ấy không nhìn thấy trên màn. */
  (5, 'mốc và bảng gánh đi theo đúng dự án, không rơi lại',
      coalesce((select case when max(thay_bao_nhieu) = 0 then '✅ Member đọc 0 mốc, 0 dòng gánh'
                            else 'ℹ️ nhiều nhất ' || max(thay_bao_nhieu)
                                 || ' dòng (đúng nếu Member ấy có tên trong dự án)' end
                  from thu where cap='member' and bang in ('moc_du_an','thanh_vien_du_an')),
               '❌ chưa chạy được')),

  (6, 'khung nhìn danh_muc_du_an thừa hưởng đúng hàng rào của bảng gốc',
      coalesce((select case when max(thay_bao_nhieu) < (select count(*) from danh_muc_du_an)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu) || ' dòng'
                            else '❌ khung nhìn vẫn trả trọn ' || max(thay_bao_nhieu)
                                 || ' dòng — nó đang lách RLS' end
                  from thu where cap='member' and bang='danh_muc_du_an'),
               '❌ chưa chạy được')),

  /* ⛔ CHỖ CÒN HỞ, CÓ CHỦ Ý — không phải lỗi bỏ quên. Đóng nó phải siết `task`,
     mà `task` nuôi bảng đo, và bảng đo Tracy chốt mở cho mọi cấp. Câu hỏi đang
     chờ Tracy: G-01.ap. Gắn ℹ️ để nó không lẫn vào những dòng ❌ thật. */
  (7, 'CÒN HỞ, chờ Tracy phân xử: việc của dự án đọc thẳng qua bảng task',
      coalesce((select 'ℹ️ Member vẫn đọc được ' || max(thay_bao_nhieu) || '/'
                       || (select count(*) from viec_du_an)
                       || ' dòng viec_du_an — xem G-01.ap'
                  from thu where cap='member' and bang='viec_du_an'),
               '❌ chưa chạy được')),

  (8, 'Lead và Quản trị KHÔNG mất gì trên cả bốn bảng dự án',
      coalesce((select case when count(*) = 0 then '✅ cả 7 người vẫn đọc trọn'
                            else '❌ có người mất dòng: '
                                 || string_agg(distinct ten || '/' || bang, ', ') end
                  from thu t
                 where t.cap in ('lead','quan-tri')
                   and t.bang in ('muc_tieu','thanh_vien_du_an','moc_du_an','danh_muc_du_an')
                   and t.thay_bao_nhieu < (case t.bang
                         when 'muc_tieu'         then (select count(*) from muc_tieu)
                         when 'thanh_vien_du_an' then (select count(*) from thanh_vien_du_an)
                         when 'moc_du_an'        then (select count(*) from moc_du_an)
                         else                         (select count(*) from danh_muc_du_an) end)),
               '❌ chưa chạy được')),

  (9, 'nhát ① vẫn còn nguyên — không bị lượt này ghi đè',
      coalesce((select case when qual like '%la_member%' and qual like '%muc_tieu_id%'
                            then '✅ doc_tieudiem còn đủ vế'
                            else '❌ doc_tieudiem đã đổi — chạy lại nang-cap-rls-cam-ket.sql' end
                  from pg_policies
                 where schemaname='public' and tablename='tieu_diem' and policyname='doc_tieudiem'),
               '❌ không thấy policy doc_tieudiem')),

  (10, 'không khung nhìn nào chạy bằng quyền người tạo',
      coalesce((select case when count(*) = 0 then '✅ rỗng'
                            else '❌ còn ' || count(*) || ': ' || string_agg(ten_view, ', ') end
                  from kiem_khung_nhin_thieu_quyen()),
               '❌ chưa chạy được'))

) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' or ket_qua like 'ℹ️%' then 2 else 1 end, so;
