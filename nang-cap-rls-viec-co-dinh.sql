-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Tệp này viết lại một policy đã có, không dựng thứ gì mới. Dấu vết của nó ở
-- │ khối ② của `SO-SQL.sql` — khối hỏi theo NỘI DUNG: "doc_viec đã hỏi cấp chưa".
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NHÁT ③ — GIỚI HẠN "VIỆC CỐ ĐỊNH CHỈ KHỐI CỦA MÌNH" XUỐNG TẦNG DỮ LIỆU
--                                          (Tracy duyệt 2026-09-07, TRI-144)
--
-- CHẠY SAU nhát ⓪ · ① · ②.
--
-- ⚠️ TỆP NÀY SIẾT MỘT PHẦN CỦA GIỚI HẠN ③, KHÔNG SIẾT TRỌN. Đọc khối dưới đây
-- trước khi kết luận nó làm chưa xong việc — phần còn lại là một quyết định
-- đang chờ Tracy, không phải một chỗ bỏ quên.
--
-- ═══ SIẾT CÁI GÌ ════════════════════════════════════════════════════════════
-- `viec_co_dinh` — KHO DANH MỤC việc cố định, 29 dòng, mỗi dòng thuộc đúng một
-- khối (`chuc_nang_id`, khai `smallint not null`). Đây là thứ màn hình lọc:
--     sb.from('viec_co_dinh_da_dung').select('*').in('chuc_nang_id', ME.chuc_nang_ids)
-- Chú thích ngay trên câu ấy trong `index.html` tự khai chỗ hở: *"đội đọc, không
-- lọc thì bày ra kho việc của cả sáu khối"*. Nay máy chủ lọc hộ.
--
-- Khung nhìn `viec_co_dinh_da_dung` đã bật `security_invoker` nên tự thừa hưởng.
-- `nhip_thoi_gian` cũng đứng trên bảng này và cũng thừa hưởng — nó không được
-- màn nào gọi tới (dò cả `index.html`, không có `from('nhip_thoi_gian')`).
--
-- ═══ ⛔ KHÔNG SIẾT `nhip` VÀ `so_ngay`, VÀ ĐÂY LÀ LÝ DO ══════════════════════
-- Khung nhìn `ket_qua_ngay` — thứ nuôi dải 💎/🪨/💩 của BẢNG ĐO (`taiDoi()` đọc
-- nó) — có một vế `exists` gác ngay trong thân:
--
--     where … and exists (select 1 from nhip n where n.nguoi_id = ng.id …)
--
-- Vế `exists` ấy chạy dưới RLS của người đang hỏi. Nên siết `doc_nhip` là mỗi
-- Member MẤT HẲN dòng của những người ngoài khối mình khỏi bảng đo — không phải
-- mờ đi, mà biến mất, vì `exists` không tìm thấy `nhip` nào nữa. `so_ngay` cũng
-- vào chính khung nhìn ấy qua `cross join`.
--
-- Tracy chốt 07/09: **bảng đo và hàng deep work mở cho MỌI cấp**, và
-- `thu-ba-cap.js` mục ⑤ có ca canh đúng chiều ấy. Siết `nhip` là hỏng một luật
-- để vá một luật khác. Đã ghi thành câu hỏi chờ Tracy phân xử: **G-01.aq**.
--
-- 🪤 Và nếu ngày nào đó quyết siết thật, thì ĐỪNG lọc `nhip` qua danh mục việc:
-- `nhip.viec_id` do `alter table add column` sinh ra nên NULLABLE, và tệp dựng
-- nó tự khai *"dòng `nhip` cũ giữ nguyên tại chỗ, `viec_id` để NULL vĩnh viễn"*
-- — 36/97 dòng hôm nay đang rỗng. Đường đúng là hỏi theo NGƯỜI (ai chung khối
-- với tôi), vì màn ROVA chọn theo người chứ không theo việc.
--
-- ═══ VÌ SAO DÙNG `la_nguoi_cua_khoi()` CHỨ KHÔNG TỰ SO MẢNG ═════════════════
-- Hàm ấy có sẵn từ `nang-cap-van-de-giao-sau.sql`, và nó đã trả lời đúng câu
-- này: *"người đang đăng nhập có thuộc khối k không"* — kể cả vế `ngay_nghi is
-- null`. Chép lại phép so mảng vào policy là đẻ ra bản thứ hai của một luật,
-- rồi ngày đổi luật thì sót một bản.
--
-- ⚠️ Ngược với `la_thanh_vien_du_an()`: hàm này trả **FALSE** khi truyền null
-- (`k is not null and …`). Ở đây không cần vế chặn null vì `chuc_nang_id` khai
-- `not null` tận nơi — nhưng đừng suy từ đây rằng hai hàm cùng một nết.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── ① KHO DANH MỤC VIỆC CỐ ĐỊNH ───────────────────────────────────────────
drop policy if exists doc_viec on viec_co_dinh;

create policy doc_viec on viec_co_dinh for select
using (
  la_thanh_vien()
  and ( not la_member()                       -- Lead · Quản trị: trọn kho
     or la_nguoi_cua_khoi(chuc_nang_id) )     -- Member: chỉ khối mình ngồi
);

comment on policy doc_viec on viec_co_dinh is
  'Lead và Quản trị đọc trọn kho danh mục. Member chỉ đọc việc thuộc khối mình '
  'ngồi (nguoi.chuc_nang_ids chứa chuc_nang_id). Khớp đúng phép lọc '
  'in(chuc_nang_id, ME.chuc_nang_ids) phía màn hình. ⚠️ Policy ghi_viec là FOR '
  'ALL nên nó CŨNG mở cửa đọc cho đúng những dòng ấy — hai policy permissive '
  'cộng lại bằng phép HOẶC, và ở đây chúng nói cùng một câu nên không nới thêm gì.';


-- ─── ② MỞ RỘNG BÀI THỬ ─────────────────────────────────────────────────────
-- `nhip` · `so_ngay` · `ket_qua_ngay` nằm trong danh sách để ĐO, không phải vì
-- đã siết: hai cái đầu là chỗ đang chờ Tracy phân xử (G-01.aq), cái thứ ba là
-- BẢNG ĐO — nó phải giữ nguyên số cho mọi cấp, và dòng ⑦ canh đúng điều đó.
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
                             'viec_du_an', 'task',
                             'viec_co_dinh', 'viec_co_dinh_da_dung',
                             'nhip', 'so_ngay', 'ket_qua_ngay'] loop
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
  'chứng cho hàng rào RLS theo cấp, thay cho việc soi chuỗi mã. ⚠️ Đọc cột '
  'chay_bang TRƯỚC: nó phải là "authenticated". Ra "postgres" nghĩa là lượt đổi '
  'vai không ăn và mọi con số vô nghĩa. Ba nhóm bảng trong danh sách: đã siết '
  '(tieu_diem, muc_tieu, thanh_vien_du_an, moc_du_an, viec_co_dinh) · đang chờ '
  'Tracy phân xử (task, viec_du_an, nhip, so_ngay) · PHẢI GIỮ NGUYÊN cho mọi cấp '
  '(ket_qua_ngay — bảng đo).';

revoke execute on function thu_hang_rao_cap() from public;

commit;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
with thu as (select * from thu_hang_rao_cap())
select so, muc, ket_qua from (values

  (1, 'policy doc_viec đã hỏi cấp, và đi qua đúng cửa la_nguoi_cua_khoi()',
      coalesce((select case when qual like '%la_member%' and qual like '%la_nguoi_cua_khoi%'
                            then '✅ đủ hai vế'
                            when qual like '%la_member%'
                            then '❌ có hỏi cấp nhưng tự chép lại phép so mảng thay vì gọi hàm'
                            else '❌ chưa hỏi cấp — kho việc vẫn mở cho cả 12 người' end
                  from pg_policies
                 where schemaname='public' and tablename='viec_co_dinh' and policyname='doc_viec'),
               '❌ không thấy policy doc_viec')),

  /* Chốt chống ✅ oan: đọc dòng này TRƯỚC mọi dòng có con số. */
  (2, 'bài thử thật sự chạy bằng vai authenticated, không phải chủ bảng',
      coalesce((select case when count(*) filter (where chay_bang <> 'authenticated') = 0
                            then '✅ authenticated'
                            else '❌ chạy bằng ' || string_agg(distinct chay_bang, ', ')
                                 || ' — chủ bảng không bị policy soi, mọi số dưới đây vô nghĩa' end
                  from thu),
               '❌ chưa chạy được')),

  (3, 'Member không còn đọc được kho việc của khối khác',
      coalesce((select case when max(thay_bao_nhieu) < (select count(*) from viec_co_dinh)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu) || ' / '
                                 || (select count(*) from viec_co_dinh) || ' việc'
                            else '❌ vẫn đọc trọn ' || max(thay_bao_nhieu) || ' việc — hàng rào chưa ăn' end
                  from thu where cap='member' and bang='viec_co_dinh'),
               '❌ chưa chạy được')),

  /* Siết quá tay ở đây là một Member mở màn Việc cố định ra thấy trống trơn.
     Ai cũng phải còn ít nhất kho việc của chính khối mình. */
  (4, 'không Member nào bị đá khỏi kho việc của chính khối mình',
      coalesce((select case when count(*) = 0 then '✅ ai cũng còn kho của mình'
                            else '❌ đọc 0 việc: ' || string_agg(ten, ', ')
                                 || ' — xem lại chuc_nang_ids của họ' end
                  from thu
                 where cap='member' and bang='viec_co_dinh' and thay_bao_nhieu = 0),
               '❌ chưa chạy được')),

  (5, 'khung nhìn viec_co_dinh_da_dung thừa hưởng đúng hàng rào',
      coalesce((select case when max(thay_bao_nhieu) < (select count(*) from viec_co_dinh_da_dung)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu) || ' dòng'
                            else '❌ khung nhìn vẫn trả trọn ' || max(thay_bao_nhieu)
                                 || ' dòng — nó đang lách RLS' end
                  from thu where cap='member' and bang='viec_co_dinh_da_dung'),
               '❌ chưa chạy được')),

  (6, 'Lead và Quản trị KHÔNG mất gì trong kho việc',
      coalesce((select case when min(thay_bao_nhieu) = (select count(*) from viec_co_dinh)
                            then '✅ cả 7 người vẫn đọc trọn ' || min(thay_bao_nhieu) || ' việc'
                            else '❌ có người mất dòng: ít nhất ' || min(thay_bao_nhieu)
                                 || ' / kho có ' || (select count(*) from viec_co_dinh) end
                  from thu where cap in ('lead','quan-tri') and bang='viec_co_dinh'),
               '❌ chưa chạy được')),

  /* ⛔ RANH GIỚI TRACY CHỐT 07/09: bảng đo mở cho MỌI cấp. Dòng này không kiểm
     hàng rào — nó kiểm rằng hàng rào KHÔNG lan sang chỗ cấm. Đỏ ở đây nghĩa là
     một nhát siết nào đó vừa cắt vào bảng đo, và phải lùi ngay. */
  (7, 'BẢNG ĐO vẫn mở như nhau cho cả ba cấp',
      coalesce((select case when count(distinct thay_bao_nhieu) = 1
                            then '✅ mọi cấp cùng đọc ' || max(thay_bao_nhieu) || ' dòng ket_qua_ngay'
                            else '❌ ĐÃ LỆCH: ' || min(thay_bao_nhieu) || '–' || max(thay_bao_nhieu)
                                 || ' dòng tuỳ cấp — một nhát siết vừa cắt vào bảng đo, lùi lại ngay' end
                  from thu where bang='ket_qua_ngay'),
               '❌ chưa chạy được')),

  /* ⛔ CHỖ CÒN HỞ, CÓ CHỦ Ý — G-01.aq. Đóng nó phải siết nhip/so_ngay, mà
     ket_qua_ngay có vế `exists` đứng trên nhip, nên siết là dòng ⑦ đỏ ngay. */
  (8, 'CÒN HỞ, chờ Tracy phân xử: nhịp tuần và số theo ngày của khối khác',
      coalesce((select 'ℹ️ Member vẫn đọc được ' || max(thay_bao_nhieu) || '/'
                       || (select count(*) from nhip) || ' dòng nhip — xem G-01.aq'
                  from thu where cap='member' and bang='nhip'),
               '❌ chưa chạy được')),

  (9, 'ba nhát trước vẫn còn nguyên',
      coalesce((select case when count(*) = 4 then '✅ đủ bốn policy còn hỏi cấp'
                            else '❌ mới ' || count(*) || '/4 — chạy lại nhát còn thiếu' end
                  from pg_policies
                 where schemaname='public'
                   and policyname in ('doc_tieudiem','doc_muctieu','doc_thanhvien','doc_moc')
                   and qual like '%la_member%'),
               '❌ chưa chạy được')),

  (10, 'không khung nhìn nào chạy bằng quyền người tạo',
      coalesce((select case when count(*) = 0 then '✅ rỗng'
                            else '❌ còn ' || count(*) || ': ' || string_agg(ten_view, ', ') end
                  from kiem_khung_nhin_thieu_quyen()),
               '❌ chưa chạy được'))

) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' or ket_qua like 'ℹ️%' then 2 else 1 end, so;
