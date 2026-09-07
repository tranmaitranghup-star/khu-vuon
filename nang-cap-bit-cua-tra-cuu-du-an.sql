-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `toi_o_du_an`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- BỊT CỬA TRA CỨU "AI GÁNH DỰ ÁN NÀO"          (TRI-148, 2026-09-07)
--
-- ═══ LỖ LÀ GÌ — ĐÃ ĐO TRÊN MÁY CHỦ THẬT, KHÔNG SUY TỪ TỆP ═══════════════════
-- `la_thanh_vien_du_an(p_muc_tieu_id, p_nguoi_id)` (dựng 25/08) là
-- `security definer`, **không hỏi người gọi là ai**, và cả hai tham số do người
-- gọi tự đặt. PostgREST mở mọi hàm trong schema `public` mà vai gọi có quyền
-- `execute`, còn Postgres thì mặc định cấp `execute` cho `PUBLIC`. Cộng lại:
-- hàm ấy thành một máy tra cứu mở cho bất kỳ ai cầm khoá công khai — khoá nằm
-- ngay trong mã nguồn trang web, không cần đăng nhập.
--
-- Đo 07/09 bằng chính khoá công khai ấy:
--     dự án 5  × Andy → true      dự án 12 × Andy → true
--     dự án 9  × Andy → true      dự án 13 × Andy → true
--     dự án 11 × Andy → true      dự án 99 × Andy → false
-- Đối chiếu bằng khoá quản trị: khớp 100%. Dò `id` 1→N nhân với danh sách người
-- là dựng lại trọn bảng `thanh_vien_du_an`.
--
-- Lỗ có từ 25/08. Nó nặng lên hôm nay vì **năm chính sách RLS mới của TRI-144
-- đều dựa vào chính hàm này** — thứ đứng dưới chân hàng rào lại là một cái cửa.
--
-- ═══ HAI ĐƯỜNG VÁ HIỂN NHIÊN, VÀ VÌ SAO CẢ HAI ĐỀU HỎNG ═════════════════════
-- ① *Neo hàm vào `nguoi_id_dang_nhap()`* → gãy `giao_cam_ket()`: nó gọi hàm với
--    `p_nguoi_nhan` — NGƯỜI NHẬN, khác người gọi — nên PIC sẽ không giao được
--    cam kết cho ai nữa. `tu_dien_du_an_cho_task` cũng gọi với `new.nguoi_id`.
-- ② *Rút `execute` rồi thôi* → gãy cả năm policy: biểu thức policy chạy bằng
--    quyền NGƯỜI HỎI, nên vai `authenticated` vẫn cần `execute` trên hàm nó gọi.
--
-- ⚠️ Và một đường thứ ba nghe hay mà KHÔNG chạy được: *"hàm tự soi `current_user`
--    để biết mình đang bị gọi từ đâu"*. Không được — hàm này là `security definer`,
--    nên BÊN TRONG nó `current_user` LUÔN là người sở hữu hàm, dù ai gọi. Nó
--    không tự phân biệt được "gọi thẳng từ ngoài" với "gọi từ trong giao_cam_ket".
--
-- ═══ ĐƯỜNG ĐI: BỎ HẲN THAM SỐ "NGƯỜI" KHỎI CÁI CỬA NGOÀI ════════════════════
-- Cái làm hàm cũ nguy hiểm không phải là nó `definer`, mà là nó nhận **tham số
-- người** từ người gọi. Bỏ tham số ấy đi là cái cửa mất khả năng tra cứu:
--
--     toi_o_du_an(p_muc_tieu_id)  — luôn hỏi về CHÍNH NGƯỜI ĐANG ĐĂNG NHẬP
--
-- Hàm mới an toàn **theo cấu tạo**, không nhờ một câu kiểm nào: điều duy nhất
-- nó nói ra là *"tôi có ở dự án N không"* — thứ người hỏi vốn đã biết. Người
-- chưa đăng nhập gọi nó thì `nguoi_id_dang_nhap()` rỗng và nó trả `false`.
-- Nên cấp `execute` cho `authenticated` là không sao, và cấp thì bắt buộc: năm
-- policy gọi nó.
--
-- Rồi RÚT `execute` của hàm cũ. Bốn hàm gọi nó bên trong đều là `security
-- definer` nên chạy bằng quyền người sở hữu — quyền được kiểm lúc GỌI, và
-- người sở hữu vẫn có. Chúng không hề hấn gì:
--     giao_cam_ket · xep_cam_ket_vao_du_an · tu_dien_du_an_cho_task ·
--     kiem_thanh_vien_cam_ket
-- Rút quyền của `PUBLIC` cũng chính là thứ làm PostgREST thôi bày hàm ấy ra.
--
-- ⛔ KHÔNG `drop` hàm cũ. Bốn hàm trên gọi nó bằng TÊN trong thân plpgsql, mà
-- thân plpgsql chỉ là một chuỗi — Postgres KHÔNG ghi nhận phụ thuộc, nên câu
-- `drop` sẽ chạy trót lọt và bốn hàm kia gãy lúc CHẠY chứ không lúc drop. Rút
-- quyền thì đủ và lùi lại được bằng một câu `grant`.
--
-- ═══ MỘT CÁI LỢI KÈM THEO: BẪY NULL BIẾN MẤT KHỎI CỬA NGOÀI ═════════════════
-- Dòng đầu thân hàm cũ là `p_muc_tieu_id is null or …` — truyền null vào là nó
-- trả TRUE. Chính vì thế `doc_tieudiem` phải mang vế `muc_tieu_id is not null`.
-- Hàm mới trả `false` khi null. Vế trong policy nay là **lớp thứ hai**, không
-- còn là lớp duy nhất — vẫn giữ, vì hai lớp rẻ hơn một lần quên.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── ① CỬA NGOÀI MỚI: chỉ hỏi được về chính mình ───────────────────────────
create or replace function toi_o_du_an(p_muc_tieu_id bigint)
returns boolean language sql stable security definer set search_path = public
as $$
  select p_muc_tieu_id is not null            -- null trả FALSE, ngược nết hàm cũ
     and la_thanh_vien()                      -- người lạ không hỏi được gì
     and (
           exists (select 1 from thanh_vien_du_an v      -- có tên trong bảng gánh
                    where v.muc_tieu_id = p_muc_tieu_id
                      and v.nguoi_id    = nguoi_id_dang_nhap())
        or exists (select 1 from muc_tieu m              -- hoặc là PIC của dự án
                    where m.id       = p_muc_tieu_id
                      and m.nguoi_id = nguoi_id_dang_nhap())
         )
$$;

comment on function toi_o_du_an(bigint) is
  'Người ĐANG ĐĂNG NHẬP có tên trong dự án này không — PIC hoặc có dòng trong '
  'thanh_vien_du_an. Đây là cửa NGOÀI, dành cho policy và cho PostgREST. Nó cố ý '
  'KHÔNG nhận tham số người: bỏ tham số ấy đi là cái cửa mất luôn khả năng tra '
  'cứu về người khác, an toàn theo cấu tạo chứ không nhờ một câu kiểm nào. '
  '⚠️ Trả FALSE khi p_muc_tieu_id là null — NGƯỢC nết của la_thanh_vien_du_an(), '
  'vốn trả TRUE. Đừng suy nết hàm này từ hàm kia.';

grant execute on function toi_o_du_an(bigint) to authenticated;


-- ─── ② NĂM POLICY ĐỔI SANG CỬA MỚI ─────────────────────────────────────────
-- Cả năm vốn đã gọi hàm cũ với đúng `nguoi_id_dang_nhap()`, nên đổi sang hàm
-- một tham số KHÔNG đổi nghĩa dòng nào — chỉ bỏ đi cái tham số mà không policy
-- nào cần, và nhờ đó rút được quyền của hàm cũ ở mục ③.

drop policy if exists doc_tieudiem on tieu_diem;
create policy doc_tieudiem on tieu_diem for select
using (
  la_thanh_vien()
  and (
        not la_member()
     or nguoi_id = nguoi_id_dang_nhap()
     or (
          muc_tieu_id is not null       -- nay là LỚP THỨ HAI: toi_o_du_an(null) đã trả false
      and toi_o_du_an(muc_tieu_id)
        )
      )
);

drop policy if exists doc_muctieu on muc_tieu;
create policy doc_muctieu on muc_tieu for select
using ( la_thanh_vien() and ( not la_member() or toi_o_du_an(id) ) );

drop policy if exists doc_thanhvien on thanh_vien_du_an;
create policy doc_thanhvien on thanh_vien_du_an for select
using ( la_thanh_vien() and ( not la_member() or toi_o_du_an(muc_tieu_id) ) );

drop policy if exists doc_moc on moc_du_an;
create policy doc_moc on moc_du_an for select
using ( la_thanh_vien() and ( not la_member() or toi_o_du_an(muc_tieu_id) ) );

comment on policy doc_tieudiem on tieu_diem is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc cam kết của chính mình, cộng '
  'cam kết thuộc dự án mình có tên. Vế "muc_tieu_id is not null" nay là lớp thứ '
  'hai — toi_o_du_an(null) đã trả false — nhưng giữ lại, hai lớp rẻ hơn một lần quên.';
comment on policy doc_muctieu on muc_tieu is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc dự án mình đứng tên (PIC hoặc '
  'có dòng trong thanh_vien_du_an), qua cửa toi_o_du_an().';
comment on policy doc_thanhvien on thanh_vien_du_an is
  'Lead và Quản trị đọc trọn bảng. Member đọc trọn danh sách người gánh của các '
  'dự án mình có tên — cố ý không cắt xuống một dòng, vì màn dự án bày cả nhóm.';
comment on policy doc_moc on moc_du_an is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc mốc của dự án mình có tên.';


-- ─── ③ RÚT QUYỀN CỦA HÀM CŨ — đây là bước bịt cửa ──────────────────────────
-- Rút của `PUBLIC` là thứ làm PostgREST thôi bày hàm ra. Rút thêm của hai vai
-- web cho chắc: nếu ngày nào đó ai cấp thẳng cho chúng thì cửa mở lại mà không
-- một dòng lỗi nào báo.
revoke execute on function la_thanh_vien_du_an(bigint, uuid) from public;
revoke execute on function la_thanh_vien_du_an(bigint, uuid) from anon;
revoke execute on function la_thanh_vien_du_an(bigint, uuid) from authenticated;

comment on function la_thanh_vien_du_an(bigint, uuid) is
  '⛔ HÀM NỘI BỘ — ĐỪNG CẤP LẠI QUYỀN CHO anon / authenticated / PUBLIC. Nó nhận '
  'tham số NGƯỜI từ người gọi và không hỏi người gọi là ai, nên hễ vai web gọi '
  'được là nó thành máy tra cứu trọn bảng thanh_vien_du_an (đo được bằng khoá '
  'công khai, 07/09 — TRI-148). Cửa dành cho bên ngoài là toi_o_du_an(bigint), '
  'hàm một tham số, luôn hỏi về chính người đang đăng nhập. Hàm này chỉ còn để '
  'bốn hàm security definer gọi bên trong: giao_cam_ket · xep_cam_ket_vao_du_an · '
  'tu_dien_du_an_cho_task · kiem_thanh_vien_cam_ket — chúng chạy bằng quyền người '
  'sở hữu nên không cần quyền của vai web.';

-- Bảo PostgREST nạp lại danh mục ngay, đừng đợi lượt làm mới định kỳ.
notify pgrst, 'reload schema';

commit;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
with thu as (select * from thu_hang_rao_cap())
select so, muc, ket_qua from (values

  /* 🪤 BẢN ĐẦU CỦA DÒNG NÀY BÁO ❌ OAN, và oan đúng cái bẫy `SO-SQL.sql` đã kê
     tên từ 28/08: so `pg_get_function_identity_arguments()` với chuỗi 'bigint',
     trong khi hàm ấy in ra CẢ TÊN THAM SỐ — `p_muc_tieu_id bigint`. Chữ ký hoàn
     toàn đúng mà bảng vẫn đỏ. Nay hỏi bằng thứ CÓ CẤU TRÚC: đếm tham số và so
     kiểu bằng `regtype`, không so chuỗi máy chủ in ra. */
  (1, 'cửa mới toi_o_du_an() có mặt, một tham số bigint, trả boolean',
      coalesce((select case when p.pronargs = 1
                             and p.proargtypes[0] = 'bigint'::regtype
                             and p.prorettype    = 'boolean'::regtype
                            then '✅ toi_o_du_an(bigint) → boolean'
                            else '❌ chữ ký lạ: ' || p.pronargs || ' tham số, trả '
                                 || p.prorettype::regtype::text end
                  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname='public' and p.proname='toi_o_du_an'),
               '❌ chưa có hàm')),

  /* Đây là dòng nghiệm thu của TRI-148. `has_function_privilege` hỏi thẳng danh
     mục quyền, không suy từ chuỗi nào. */
  (2, 'CỬA ĐÃ BỊT: hai vai web không còn gọi được la_thanh_vien_du_an',
      coalesce((select case when not bool_or(co) then '✅ cả anon và authenticated đều mất quyền'
                            else '❌ còn gọi được bằng vai: '
                                 || string_agg(vai, ', ') filter (where co) end
                  /* Chỉ hỏi hai VAI CÓ THẬT. `public` không phải một vai —
                     `has_function_privilege('public', …)` ném lỗi "role does not
                     exist" và làm chết cả bảng tự kiểm. Không cần hỏi nó: quyền
                     cấp cho PUBLIC thì `has_function_privilege('anon', …)` cũng
                     thấy, vì mọi vai đều thừa hưởng PUBLIC. */
                  from (values ('anon'), ('authenticated')) as v(vai)
                  cross join lateral (select has_function_privilege(
                         v.vai, 'public.la_thanh_vien_du_an(bigint, uuid)', 'execute') as co) x),
               '❌ chưa chạy được')),

  (3, 'nhưng vai authenticated VẪN gọi được cửa mới — năm policy cần nó',
      case when has_function_privilege('authenticated', 'public.toi_o_du_an(bigint)', 'execute')
           then '✅ có quyền'
           else '❌ MẤT QUYỀN — năm policy sẽ ném lỗi permission denied ngay lượt select đầu' end),

  (4, 'bốn policy đã đổi sang cửa mới',
      coalesce((select case when count(*) = 4 then '✅ đủ bốn'
                            else '❌ mới ' || count(*) || '/4: '
                                 || coalesce(string_agg(policyname, ', ' order by policyname), '(chưa cái nào)') end
                  from pg_policies
                 where schemaname='public'
                   and policyname in ('doc_tieudiem','doc_muctieu','doc_thanhvien','doc_moc')
                   and qual like '%toi_o_du_an%'),
               '❌ chưa chạy được')),

  (5, 'và không policy nào còn gọi hàm cũ',
      coalesce((select case when count(*) = 0 then '✅ không còn'
                            else '❌ còn ' || count(*) || ': ' || string_agg(tablename || '.' || policyname, ', ') end
                  from pg_policies
                 where schemaname='public' and coalesce(qual,'') like '%la_thanh_vien_du_an%'),
               '❌ chưa chạy được')),

  /* Chốt chống ✅ oan: đọc dòng này TRƯỚC hai dòng có con số. */
  (6, 'bài thử thật sự chạy bằng vai authenticated, không phải chủ bảng',
      coalesce((select case when count(*) filter (where chay_bang <> 'authenticated') = 0
                            then '✅ authenticated'
                            else '❌ chạy bằng ' || string_agg(distinct chay_bang, ', ') end
                  from thu),
               '❌ chưa chạy được')),

  /* Đổi cửa mà làm lệch một con số nào là hàng rào vừa đổi nghĩa — phải biết ngay. */
  (7, 'hàng rào giữ NGUYÊN nghĩa: Member vẫn đọc đúng chừng ấy dòng',
      coalesce((select case when max(thay_bao_nhieu) = 0 then '✅ Member vẫn 0 dòng trên cả bốn bảng'
                            else 'ℹ️ nhiều nhất ' || max(thay_bao_nhieu)
                                 || ' dòng (đúng nếu Member ấy có tên trong dự án)' end
                  from thu
                 where cap='member'
                   and bang in ('tieu_diem','muc_tieu','thanh_vien_du_an','moc_du_an')),
               '❌ chưa chạy được')),

  (8, 'Lead và Quản trị KHÔNG mất gì',
      coalesce((select case when count(*) = 0 then '✅ cả 7 người vẫn đọc trọn'
                            else '❌ có người mất dòng: '
                                 || string_agg(distinct ten || '/' || bang, ', ') end
                  from thu t
                 where t.cap in ('lead','quan-tri')
                   and t.bang in ('tieu_diem','muc_tieu','thanh_vien_du_an','moc_du_an')
                   and t.thay_bao_nhieu < (case t.bang
                         when 'tieu_diem'        then (select count(*) from tieu_diem)
                         when 'muc_tieu'         then (select count(*) from muc_tieu)
                         when 'thanh_vien_du_an' then (select count(*) from thanh_vien_du_an)
                         else                         (select count(*) from moc_du_an) end)),
               '❌ chưa chạy được')),

  /* Bốn hàm định-nghĩa-quyền vẫn gọi hàm cũ bên trong. Chúng chạy bằng quyền
     người sở hữu nên lượt rút quyền ở mục ③ không chạm tới — dòng này khẳng
     định điều đó bằng danh mục, không bằng lời hứa. */
  (9, 'người sở hữu hàm vẫn gọi được hàm cũ — bốn hàm definer không hề hấn',
      coalesce((select case when has_function_privilege(pg_get_userbyid(p.proowner),
                                   'public.la_thanh_vien_du_an(bigint, uuid)', 'execute')
                            then '✅ ' || pg_get_userbyid(p.proowner) || ' vẫn gọi được'
                            else '❌ chính người sở hữu cũng mất quyền — bốn hàm kia sẽ gãy lúc chạy' end
                  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                 where n.nspname='public' and p.proname='giao_cam_ket' limit 1),
               '❌ không thấy hàm giao_cam_ket')),

  (10, 'không khung nhìn nào chạy bằng quyền người tạo',
      coalesce((select case when count(*) = 0 then '✅ rỗng'
                            else '❌ còn ' || count(*) || ': ' || string_agg(ten_view, ', ') end
                  from kiem_khung_nhin_thieu_quyen()),
               '❌ chưa chạy được'))

) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' or ket_qua like 'ℹ️%' then 2 else 1 end, so;
