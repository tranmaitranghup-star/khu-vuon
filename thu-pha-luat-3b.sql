-- ┌─ SỔ SQL ──────────────────────────────────────────────────────────────────
-- │ KHÔNG THUỘC SỔ — tệp này không nâng cấp gì: bài thử, cố tình phá luật 3b để xem có bị chặn.
-- │ Chạy lúc nào cũng được, chạy lại cũng được.
-- └───────────────────────────────────────────────────────────────────────────
-- ═══════════════════════════════════════════════════════════════════════════
-- THỬ PHÁ HAI HÀNG RÀO CỦA LUẬT 3b — chạy sau va-luat-3b.sql
--
-- VÌ SAO CẦN FILE NÀY
-- Bộ tự kiểm 11 mục chỉ soi "ràng buộc CÓ tồn tại không". Nó không trả lời
-- được câu đắt hơn: "ràng buộc có THẬT SỰ chặn không". Hai câu đó khác nhau —
-- đợt soi 08/08 đã bắt được đúng một ca ràng buộc tồn tại đầy đủ mà vẫn phá
-- được (luật ba cam kết, phá bằng `luong = null`), và chính bộ tự kiểm hôm ấy
-- cũng báo ✅ vì nó soi nhầm chỗ.
--
-- Tôi đã thử phá từ ngoài bằng khoá công khai nhưng KHÔNG tới được: bảng task
-- bật RLS nên mọi lệnh của người chưa đăng nhập dừng ở 42501, chưa chạm tới
-- tầng ràng buộc. Trong SQL editor thì không bị chắn, nên phải chạy ở đây.
--
-- KHÔNG ĐỔI DỮ LIỆU. Mỗi phép thử nằm trong một khối con có bắt lỗi: lệnh nào
-- lọt qua thì bị ép quay lui ngay tại chỗ, nên chạy bao nhiêu lần cũng sạch.
-- ═══════════════════════════════════════════════════════════════════════════

create temp table if not exists kq_thu_pha (thu_tu int, muc text, ket_qua text);
truncate kq_thu_pha;

do $$
declare
  id_thu bigint := (select min(id) from task);
  id_con bigint;
  -- Biến plpgsql KHÔNG bị quay lui theo giao dịch (nó nằm trong bộ nhớ), nên
  -- đây là cách duy nhất mang kết quả của phép thử ⑥ ra khỏi khối bị quay lui.
  moc_ok boolean;
begin
  if id_thu is null then
    insert into kq_thu_pha values (0,'Bảng task đang rỗng','⚠️ không thử được');
    return;
  end if;

  -- ① Trạng thái không có trong bảng 8 ô
  begin
    update task set trang_thai = 'Xong roi' where id = id_thu;
    raise exception 'LOT';
  exception when others then
    insert into kq_thu_pha values (1, 'Trạng thái bịa bị ràng buộc 8 ô chặn',
      case when sqlerrm = 'LOT' then '❌ LỌT — không chặn được'
           else '✅ chặn (' || sqlstate || ')' end);
  end;

  -- ② Nghẽn mà không khai thứ đang chặn
  begin
    update task set trang_thai = 'Nghen', ghi_chu_chot = '' where id = id_thu;
    raise exception 'LOT';
  exception when others then
    insert into kq_thu_pha values (2, 'Nghẽn không khai thứ chặn bị chặn',
      case when sqlerrm = 'LOT' then '❌ LỌT — Nghẽn thành ô trốn việc'
           else '✅ chặn (' || sqlstate || ')' end);
  end;

  -- ③ Nghẽn CÓ khai thứ chặn — phải cho qua, không thì hàng rào siết nhầm
  begin
    update task set trang_thai = 'Nghen', ghi_chu_chot = 'thử' where id = id_thu;
    raise exception 'LOT';
  exception when others then
    insert into kq_thu_pha values (3, 'Nghẽn CÓ khai thứ chặn thì đi qua được',
      case when sqlerrm = 'LOT' then '✅ đi qua'
           else '❌ bị chặn nhầm (' || sqlstate || ')' end);
  end;

  -- ④ Đóng bằng Da_chuyen khi CHƯA có task con
  begin
    update task set trang_thai = 'Da_chuyen' where id = id_thu;
    raise exception 'LOT';
  exception when others then
    insert into kq_thu_pha values (4, 'Đã chuyển mà chưa có task con bị chặn',
      case when sqlerrm = 'LOT' then '❌ LỌT — task biến mất im lặng được'
           else '✅ chặn (' || sqlstate || ')' end);
  end;

  -- ⑤ Đóng bằng Da_chuyen khi ĐÃ có task con — phải cho qua
  begin
    insert into task (nguoi_id, noi_dung, ngay, task_cha)
      select nguoi_id, 'con thử', hom_nay(), id_thu from task where id = id_thu
      returning id into id_con;
    update task set trang_thai = 'Da_chuyen' where id = id_thu;
    raise exception 'LOT';
  exception when others then
    insert into kq_thu_pha values (5, 'Đã chuyển CÓ task con thì đi qua được',
      case when sqlerrm = 'LOT' then '✅ đi qua'
           else '❌ bị chặn nhầm (' || sqlstate || ')' end);
  end;

  -- ⑥ ngay_hen_dau tự điền đúng lúc task rời kho
  begin
    insert into task (nguoi_id, noi_dung, ngay)
      select nguoi_id, 'thử mốc ngày', null from task where id = id_thu
      returning id into id_con;
    update task set ngay = hom_nay() where id = id_con;
    moc_ok := (select ngay_hen_dau from task where id = id_con) = hom_nay();
    raise exception 'LOT';   -- ép quay lui hai dòng vừa tạo
  exception when others then
    insert into kq_thu_pha values (6, 'Rời kho là tự đóng mốc ngay_hen_dau',
      case when sqlerrm <> 'LOT' then '❌ nổ giữa chừng (' || sqlstate || ')'
           when moc_ok            then '✅ đóng mốc đúng ngày'
           else                        '❌ không đóng mốc' end);
  end;
end $$;

-- ⚠️ MỘT câu select duy nhất ở cuối file, cố ý gộp cả phép đếm dòng rác vào
-- làm dòng thứ 7. Supabase SQL editor CHỈ hiện bảng của lệnh cuối cùng — để
-- hai câu select cạnh nhau là bảng đầu bị nuốt mất, đúng lỗi đã vấp lần đầu.
select thu_tu, ket_qua, muc from kq_thu_pha
union all
select 7,
       case when count(*) = 0 then '✅ sạch'
            else '❌ còn ' || count(*) || ' dòng' end,
       'Không để lại dòng rác nào'
  from task where noi_dung in ('con thử', 'thử mốc ngày')
order by 1;
