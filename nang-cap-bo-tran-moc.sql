-- ════════════════════════════════════════════════════════════════════════════
-- BỎ TRẦN 7 MỐC MỖI DỰ ÁN
-- Tracy chốt 2026-09-01: "vậy thì bỏ trần 7 mốc đi"
-- ════════════════════════════════════════════════════════════════════════════
--
-- VÌ SAO BỎ.
-- Trần 7 đặt ra ngày 25/08 cho một bảng chỉ chứa MỘT loại dòng: milestone hiểu
-- theo nghĩa "trạng thái đã đạt". Bảy cái cho một loại là con số hợp lý.
--
-- Ngày 01/09 mô hình đổi: cùng bảng `moc_du_an` nay mang HAI VAI, phân biệt
-- bằng chỗ có hay không có ngày bắt đầu —
--   · GIAI ĐOẠN (có quãng ngày) — một khúc thời gian, chứa việc;
--   · CỘT MỐC (một ngày) — không tốn thời gian, không chứa gì.
-- Nguồn phân vai: project-management-quickstart-croft.pdf ch.4 · ch.5 · ch.8.
--
-- Một kỳ webinar ROVA viết đủ hai vai đã 9 dòng: 4 giai đoạn + 5 cột mốc. Trần
-- 7 đếm chung cả bảng nên nó chặn đúng cái kế hoạch bình thường nhất, chứ không
-- chặn cái phình bất thường. Đếm riêng từng vai thì đỡ được ca này, nhưng lại
-- đẻ ra hai con số phải nhớ và vẫn sai với dự án dài. Nên bỏ hẳn.
--
-- CÒN GIỮ LẠI: sàn 3 mốc lúc bước vào 'dang-chay'. Nó trả lời một câu KHÁC —
-- "đã có kế hoạch chưa" — và câu ấy vẫn đúng. Chỉ gỡ TRẦN, không gỡ SÀN.
--
-- Cần `nang-cap-mang-du-an.sql` đã chạy trước.
-- ════════════════════════════════════════════════════════════════════════════

begin;

-- ── 1. Gỡ trigger chặn lúc THÊM một mốc mới ─────────────────────────────────
-- Đây là chỗ chặn cứng nhất: nó bắn lỗi ngay ở dòng thứ 8, trước cả khi người
-- dùng kịp bấm lưu xong.
drop trigger  if exists trg_kiem_so_moc on moc_du_an;
drop function if exists kiem_so_moc();

-- ── 2. Gỡ vế TRẦN trong cửa 'dang-chay', giữ nguyên mọi cửa khác ───────────
-- `kiem_du_an_du_o()` gác NĂM cửa cùng lúc (loại · mục tiêu · ngày xong · sàn
-- mốc · nghi thức đóng), nên phải chép lại trọn hàm chứ không sửa được một
-- dòng. Bản dưới chép NGUYÊN VĂN bản 25/08 và chỉ bỏ đúng khối `if so_moc > 7`.
-- Bốn cửa còn lại y nguyên, kể cả cặp số ngày và ba câu nhìn lại lúc đóng.
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

  /* SÀN ba mốc soi lúc BƯỚC VÀO 'dang-chay', không soi sớm hơn. Lý do là thứ
     tự sinh dữ liệu: dòng dự án phải có mặt trước thì mốc mới có chỗ treo, nên
     lúc dòng vừa sinh ra thì số mốc luôn bằng 0. Soi ở cửa 'dang-chay' vừa
     đúng nghĩa (chưa có kế hoạch thì chưa chạy được) vừa không tự chặn chính
     lệnh tạo dự án.
     ⚠️ TRẦN 7 đã bỏ ngày 01/09 — lý do ở đầu tệp này. Đừng cắm lại. */
  if new.trang_thai = 'dang-chay' then
    select count(*) into so_moc from moc_du_an where muc_tieu_id = new.id;
    if so_moc < 3 then
      raise exception 'Dự án cần ít nhất 3 milestone có ngày trước khi cho chạy — mới khai % cái.', so_moc;
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

commit;

-- ── SOÁT LẠI SAU KHI CHẠY ───────────────────────────────────────────────────
-- Bốn dòng phải trả về true. Dòng cuối bảo đảm tôi không lỡ tay gỡ nhầm cửa
-- khác: chuỗi 'so_moc > 7' phải biến mất mà 'so_moc < 3' phải còn.
select
  (select count(*) from pg_trigger
    where tgrelid = 'moc_du_an'::regclass and not tgisinternal
      and tgname = 'trg_kiem_so_moc') = 0                       as da_go_trigger_tran,
  (select count(*) from pg_proc where proname = 'kiem_so_moc') = 0
                                                                as da_go_ham_tran,
  (select count(*) from pg_trigger
    where tgrelid = 'moc_du_an'::regclass and not tgisinternal
      and tgname = 'tg_doi_moc') = 1                            as trigger_doi_moc_con_nguyen,
  (select prosrc not like '%so_moc > 7%' and prosrc like '%so_moc < 3%'
     from pg_proc where proname = 'kiem_du_an_du_o')            as san_con_tran_het;
