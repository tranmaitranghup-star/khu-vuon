-- ⛔ HAI PHẦN CỦA TỆP NÀY ĐÃ BỊ THAY THẾ — ĐỪNG CHẠY LẠI MỘT MÌNH (07/09, TRI-148)
-- Các policy dưới đây gọi `la_thanh_vien_du_an(bigint, uuid)`. Hàm ấy ĐÃ BỊ RÚT
-- quyền `execute` của vai `authenticated` ngày 07/09 vì nó là một cửa tra cứu mở
-- (đo được bằng khoá công khai — xem `nang-cap-bit-cua-tra-cuu-du-an.sql`). Chạy
-- lại tệp này một mình là dựng lại policy gọi một hàm mà người hỏi không có quyền
-- gọi → MỌI lượt `select` của thành viên ném "permission denied for function".
-- Hỏng to và hỏng ngay, không im lặng — nhưng vẫn là hỏng. Muốn chạy lại thì chạy
-- `nang-cap-bit-cua-tra-cuu-du-an.sql` NGAY SAU nó.
-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ Dấu vết riêng trên máy chủ: hàm `thu_hang_rao_cap`.
-- │ Đã chạy chưa? → chạy `SO-SQL.sql`, nó đọc thẳng danh mục Postgres.
-- │ Đừng chép câu trả lời vào đây — sổ chép tay thì rữa, máy dò thì không.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- NHÁT ① — GIỚI HẠN "CAM KẾT CẢ ROVA" XUỐNG TẦNG DỮ LIỆU
--                                          (Tracy duyệt 2026-09-07, TRI-144)
--
-- CHẠY SAU `nang-cap-cap-dang-nhap.sql` (nhát ⓪). Tệp này gọi `la_member()` do
-- nhát ⓪ dựng; chạy trước nó là lỗi "function does not exist".
--
-- Phía màn hình, Member không bật được phạm vi "Cả ROVA": hai đường bật cờ
-- `vuonCaDoi` đều đã bịt (`ckDoiPhamVi` và `cbKyNhan`), nên app chỉ hỏi máy chủ
-- cam kết của chính người ấy. Nhưng máy chủ vẫn trả lời mọi câu hỏi khác:
-- `doc_tieudiem` đang là `using (la_thanh_vien())`, tức mở cho cả 12 người.
-- Mở công cụ dev, gõ một dòng, là có trọn 64 cam kết của cả đội.
--
-- ═══ MEMBER ĐƯỢC ĐỌC NHỮNG DÒNG NÀO ═════════════════════════════════════════
-- Tracy chốt 07/09 (mặc định mục 7 của bản duyệt, không gạch):
--   · cam kết CỦA MÌNH — `nguoi_id = nguoi_id_dang_nhap()`, và
--   · cam kết thuộc DỰ ÁN MÌNH CÓ TÊN — để màn chi tiết dự án không trống.
-- Lead và Quản trị: không đổi gì, vẫn đọc trọn bảng.
--
-- Cam kết được GIAO cho một Member vẫn thuộc về họ ngay từ lúc sinh ra:
-- `giao_cam_ket()` chèn `nguoi_id = p_nguoi_nhan` và `giao_boi = người giao`
-- (ràng buộc `giao_boi is distinct from nguoi_id` canh đúng chuyện này). Nên
-- đường giao việc và khung nhìn `cho_ban` không gãy vì lượt siết này.
--
-- ═══ 🪤 MỘT VẾ LOAD-BEARING, DỄ BỊ "DỌN" NHẤT ═══════════════════════════════
-- Hàm `la_thanh_vien_du_an(p_muc_tieu_id, p_nguoi_id)` có sẵn từ 25/08, và
-- DÒNG ĐẦU thân hàm là `p_muc_tieu_id is null or …` — tức **truyền null vào nó
-- thì nó trả TRUE**. Vế ấy đúng cho chỗ nó sinh ra (một cò ghi: task chưa gắn dự
-- án thì không có gì để kiểm), nhưng ở đây nó là một cái cửa mở toang:
--
--     54 trên 64 cam kết hôm nay KHÔNG gắn dự án nào (`muc_tieu_id is null`).
--
-- Bỏ vế `muc_tieu_id is not null` là 54 dòng ấy hiện lại cho mọi Member — hàng
-- rào thành vô nghĩa với 84% dữ liệu, mà bộ tự kiểm vẫn xanh và màn hình vẫn
-- trông y như cũ, vì giao diện đã tự lọc rồi. Đây là loại hỏng chỉ lộ ra khi có
-- người mở công cụ dev. ĐỪNG rút gọn vế ấy đi. Dòng ⑤ của bộ tự kiểm đo bằng
-- việc thật, không bằng chuỗi mã.
--
-- ═══ VÌ SAO KHÔNG ĐỤNG KHUNG NHÌN NÀO ═══════════════════════════════════════
-- Bốn khung nhìn đứng trên `tieu_diem` — `tien_do_o` · `dem_cam_ket_da_dong` ·
-- `dem_task_theo_o` · `tien_do_muc_tieu` — đều đã bật `security_invoker` (soi
-- máy chủ 07/09). Chúng chạy bằng quyền NGƯỜI HỎI, nên siết bảng gốc là siết
-- luôn chúng, miễn phí. Dựng lại chúng chỉ để "cho chắc" là rước rủi ro không
-- đổi lấy gì: `drop view` làm rơi cờ trong im lặng, và riêng `tien_do_o` có TÁM
-- bản chồng nhau trong kho — chép nhầm một bản cũ là mất cột.
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ─── ① CỬA ĐỌC CỦA `tieu_diem` ─────────────────────────────────────────────
-- `drop` rồi `create` nằm trong cùng một giao dịch nên không có khoảnh khắc nào
-- bảng đứng không policy. Postgres không có `create or replace policy`.
drop policy if exists doc_tieudiem on tieu_diem;

create policy doc_tieudiem on tieu_diem for select
using (
  la_thanh_vien()
  and (
        not la_member()                                   -- Lead · Quản trị: trọn bảng
     or nguoi_id = nguoi_id_dang_nhap()                    -- cam kết của chính mình
     or (
          muc_tieu_id is not null                          -- 🪤 vế load-bearing, xem đầu tệp
      and la_thanh_vien_du_an(muc_tieu_id, nguoi_id_dang_nhap())
        )
      )
);

comment on policy doc_tieudiem on tieu_diem is
  'Lead và Quản trị đọc trọn bảng. Member chỉ đọc cam kết của chính mình, cộng '
  'cam kết thuộc dự án mình có tên (PIC hoặc thành viên). ⚠️ Vế '
  '"muc_tieu_id is not null" là bắt buộc: la_thanh_vien_du_an(null, …) trả TRUE, '
  'nên bỏ nó đi là mở lại toàn bộ cam kết không gắn dự án — 54/64 dòng ngày '
  'ban hành.';


-- ─── ② BÀI THỬ HÀNG RÀO, CHẠY ĐƯỢC MÃI VỀ SAU ──────────────────────────────
-- Vì sao phải có hàm này thay vì soi chuỗi mã: Tracy chạy SQL bằng vai
-- `postgres`, mà chủ bảng thì KHÔNG bị policy soi (trừ khi bật `force row level
-- security`, việc riêng đã khoanh ra ngoài đợt này). Nên mọi câu `select` gõ
-- thẳng vào trình soạn đều trả về trọn bảng, dù hàng rào có dựng hay không —
-- đo kiểu ấy là đo một cái không đo gì cả.
--
-- Hàm này đóng vai từng người bằng `set local role authenticated` cộng một bộ
-- claims giả, rồi ĐẾM THẬT. Chỉ đọc; `local` nên mọi thứ tự trả về sau giao dịch.
--
-- ⚠️ CỘT `chay_bang` LÀ CHỐT CHỐNG ✅ OAN. Nếu vì lý do gì đó lượt đổi vai không
-- ăn, hàm vẫn chạy bằng `postgres` và mọi con số sẽ ra 64 — trông như "Lead và
-- Member đều đọc được", tức một kết luận SAI theo hướng nguy hiểm. Cột ấy phơi
-- ra vai thật đang đếm; thấy `postgres` thì vứt cả bảng đi, đừng đọc số.
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
    foreach b in array array['tieu_diem', 'tien_do_o'] loop
      -- đóng vai
      perform set_config('request.jwt.claims',
                         json_build_object('role', 'authenticated',
                                           'email', r.email)::text, true);
      perform set_config('role', 'authenticated', true);

      select current_user into vai;
      execute format('select count(*) from %I', b) into n;

      -- Trả vai lại NGAY, trước khi vòng lặp ngoài lấy dòng người tiếp theo:
      -- `for r in select …` lấy dòng một cách lười, nên còn đang đội vai
      -- `authenticated` lúc nó với sang bảng `nguoi` là một lối hỏng rất khó thấy.
      -- `reset role` (không phải `set role postgres`) để trả về đúng vai của
      -- phiên, dù phiên ấy là ai.
      execute 'reset role';

      ten := r.ten; cap := r.c; chay_bang := vai; bang := b; thay_bao_nhieu := n;
      return next;
    end loop;
  end loop;

  -- Dọn bộ claims giả: nó là `local` nên tự hết khi giao dịch đóng, nhưng phần
  -- còn lại của CHÍNH giao dịch này vẫn nhìn thấy nó. Để lại là các câu sau
  -- trong cùng lượt chạy âm thầm đọc dữ liệu dưới danh nghĩa người cuối vòng lặp.
  perform set_config('request.jwt.claims', '', true);
end $$;

comment on function thu_hang_rao_cap() is
  'Đóng vai từng người trong bảng nguoi rồi ĐẾM THẬT số dòng họ đọc được — bằng '
  'chứng cho hàng rào RLS theo cấp, thay cho việc soi chuỗi mã. Chỉ đọc, mọi '
  'thay đổi đều là SET LOCAL nên tự trả về sau giao dịch. ⚠️ Đọc cột chay_bang '
  'TRƯỚC: nó phải là "authenticated". Ra "postgres" nghĩa là lượt đổi vai không '
  'ăn và mọi con số trong bảng đều vô nghĩa — chủ bảng không bị policy soi.';

-- Hàm chẩn đoán, KHÔNG phải cửa của app: rút quyền mặc định mà Postgres cấp cho
-- PUBLIC, để nó không mọc thêm một lối gọi trong API công khai. Tracy chạy nó
-- bằng vai chủ, và quyền được kiểm lúc GỌI — nên việc đổi vai bên trong vẫn chạy.
revoke execute on function thu_hang_rao_cap() from public;

commit;


-- ═══ TỰ KIỂM — đọc bảng này, dòng chưa đạt nổi lên đầu ══════════════════════
-- Xem chi tiết từng người: chạy riêng `select * from thu_hang_rao_cap();`
with thu as (select * from thu_hang_rao_cap())
select so, muc, ket_qua from (values

  /* Dò bằng TÊN HÀM và TÊN CỘT — hai thứ Postgres trả lại y nguyên. Không dò
     mệnh đề `case`/`and`/`or`: Postgres phân tích rồi in lại, từ khoá viết HOA
     và ngoặc thêm vào, nên mẫu chứa từ khoá ra ❌ oan. */
  (1, 'policy doc_tieudiem đã hỏi cấp',
      coalesce((select case when qual like '%la_member%' then '✅ có gọi la_member()'
                            else '❌ chưa hỏi cấp — vẫn mở cho cả 12 người' end
                  from pg_policies
                 where schemaname='public' and tablename='tieu_diem'
                   and policyname='doc_tieudiem'),
               '❌ không thấy policy doc_tieudiem')),

  (2, 'policy giữ đủ hai lối ra cho Member: của mình, và dự án có tên',
      coalesce((select case when qual like '%nguoi_id_dang_nhap%'
                             and qual like '%la_thanh_vien_du_an%'
                            then '✅ đủ hai vế'
                            else '❌ thiếu một vế — Member sẽ mất một trong hai' end
                  from pg_policies
                 where schemaname='public' and tablename='tieu_diem'
                   and policyname='doc_tieudiem'),
               '❌ không thấy policy doc_tieudiem')),

  /* 🪤 Vế dễ bị "dọn" nhất. Dò theo TÊN CỘT `muc_tieu_id` có mặt trong qual —
     nó chỉ vào đó vì vế chặn null, không vì lý do nào khác. */
  (3, 'vế chặn null của muc_tieu_id còn nguyên',
      coalesce((select case when qual like '%muc_tieu_id%' then '✅ còn'
                            else '❌ MẤT — la_thanh_vien_du_an(null,…) trả TRUE, 54/64 dòng hở lại' end
                  from pg_policies
                 where schemaname='public' and tablename='tieu_diem'
                   and policyname='doc_tieudiem'),
               '❌ không thấy policy doc_tieudiem')),

  /* Chốt chống ✅ oan: đọc dòng này TRƯỚC ⑤ và ⑥. */
  (4, 'bài thử thật sự chạy bằng vai authenticated, không phải chủ bảng',
      coalesce((select case when count(*) filter (where chay_bang <> 'authenticated') = 0
                            then '✅ authenticated'
                            else '❌ chạy bằng ' || string_agg(distinct chay_bang, ', ')
                                 || ' — chủ bảng không bị policy soi, mọi số dưới đây vô nghĩa' end
                  from thu),
               '❌ chưa chạy được')),

  (5, 'Member không còn đọc được cam kết của cả đội',
      coalesce((select case when max(thay_bao_nhieu) = 0
                            then '✅ mọi Member đọc 0 dòng'
                            when max(thay_bao_nhieu) < (select count(*) from tieu_diem)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu)
                                 || ' / ' || (select count(*) from tieu_diem)
                                 || ' dòng (cam kết của chính họ + dự án có tên)'
                            else '❌ vẫn đọc trọn ' || max(thay_bao_nhieu) || ' dòng — hàng rào chưa ăn' end
                  from thu where cap = 'member' and bang = 'tieu_diem'),
               '❌ chưa chạy được')),

  /* Khung nhìn phải tự thừa hưởng, không phải siết riêng. Sai ở đây nghĩa là
     một khung nhìn nào đó tuột cờ security_invoker. */
  (6, 'khung nhìn tien_do_o thừa hưởng đúng hàng rào của bảng gốc',
      coalesce((select case when max(thay_bao_nhieu) = 0
                            then '✅ Member đọc 0 dòng qua khung nhìn'
                            when max(thay_bao_nhieu) < (select count(*) from tien_do_o)
                            then '✅ nhiều nhất ' || max(thay_bao_nhieu) || ' dòng'
                            else '❌ khung nhìn vẫn trả ' || max(thay_bao_nhieu)
                                 || ' dòng — nó đang lách RLS' end
                  from thu where cap = 'member' and bang = 'tien_do_o'),
               '❌ chưa chạy được')),

  /* Siết nhầm người là hỏng nặng hơn siết thiếu: một Lead mất cam kết của đội
     thì họ mất luôn cái nhìn toàn cảnh mà app sinh ra để phục vụ. */
  (7, 'Lead và Quản trị KHÔNG mất gì',
      coalesce((select case when min(thay_bao_nhieu) = max(thay_bao_nhieu)
                             and min(thay_bao_nhieu) = (select count(*) from tieu_diem)
                            then '✅ cả 7 người vẫn đọc trọn ' || min(thay_bao_nhieu) || ' dòng'
                            else '❌ có người mất dòng: ít nhất ' || min(thay_bao_nhieu)
                                 || ' / bảng có ' || (select count(*) from tieu_diem) end
                  from thu where cap in ('lead','quan-tri') and bang = 'tieu_diem'),
               '❌ chưa chạy được')),

  (8, 'không khung nhìn nào chạy bằng quyền người tạo',
      coalesce((select case when count(*) = 0 then '✅ rỗng'
                            else '❌ còn ' || count(*) || ': ' || string_agg(ten_view, ', ') end
                  from kiem_khung_nhin_thieu_quyen()),
               '❌ chưa chạy được'))

) as t(so, muc, ket_qua)
order by case when ket_qua like '✅%' then 2 else 1 end, so;
