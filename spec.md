# Spec một trang — Khu Vườn Tỉnh Thức

> Bảy mục theo khuôn Buổi 2 (Build to Own). Viết lại 30/08/2026 sau khi đọc lại toàn bộ app đang chạy.
> Nguồn: `ho-so-khu-vuon-cho-ai.md` · `BAN-GIAO-kien-truc-bon-man.md` · `schema.sql` + 33 tệp `nang-cap-*.sql` · `DANG-LAM.md` · bài luận nỗi đau (Rian Doris / Flow Research Collective).

---

## 1. Vấn đề

Trong doanh nghiệp nhỏ làm việc online, mỗi nhân sự chỉ thực sự tập trung sâu khoảng **2,3 giờ mỗi ngày** dù ngồi bàn 8–10 giờ, còn người quản lý thì mỗi tuần lại nhận thêm việc mà không ai nhìn thấy tổng tải của cả đội — nên việc cũ chưa xong bị gõ lại mỗi sáng thay vì được đóng.

Đo trên chính ROVA, hai tháng 29/05→31/07/2026: **490 trong 1.922 task là việc cũ gõ lại** · danh mục "dự án" đi từ 6–7 lên **13 mà không cái nào đóng** · **156 nhịp việc lặp** gánh 34% lượng chữ báo cáo. Cả ba đều là hỏng hóc thiết kế, không phải hỏng hóc thái độ: hệ thống cũ (chat Lark + Google Sheet 12 tab) không có chỗ giữ hộ việc, và không có cơ chế đóng việc.

## 2. Người dùng

**Doanh nghiệp nhỏ dưới 20 người, làm việc online.** Ca dùng đầu tiên và nơi app đang chạy thật: đội ROVA (công ty đào tạo trading, 12 người, cơ cấu phẳng) — **7 người dùng thật từ khoảng 08–10/08/2026**.

Hiện họ thay thế bằng: nhóm chat (Lark/Slack/Zalo) để giao việc + bảng tính để báo cáo + một app quản lý việc kiểu ClickUp/Todoist cho phần danh sách. Ba chỗ rời nhau, không chỗ nào giữ được chuỗi từ mục tiêu xuống tới giờ làm thật.

## 3. Nó làm gì

- **Giữ** ba luống cam kết mỗi người (CEO 5) — hết luống là hết đất, muốn gieo mới phải đóng một cái cũ, giới hạn nằm ở tầng cơ sở dữ liệu chứ không phải lời khuyên trên màn hình
- **Chia** cam kết thành task, rồi **chạy** phiên deepwork có đồng hồ do máy chủ đóng dấu — giờ không khai tay được
- **Đóng** ngày bằng nghi thức bốn cửa (xong · chưa xong · nghẽn · dừng) — việc chưa xong về kho có trạng thái, không phải gõ lại sáng mai
- **Tính** tiến độ từ dữ liệu thật (18 khung nhìn ở máy chủ) — không ai gõ phần trăm vào bằng tay
- **Bày** hai bảng vinh danh cân nhau: quả (kết quả) và giờ tập trung (nỗ lực)

*Chuỗi ba tầng cam kết → task → phiên deepwork là điểm độc nhất về kiến trúc: benchmark 6 app (ClickUp, Asana, Todoist, TickTick, Sunsama, Motion) cho thấy mỗi app chỉ giữ hai tầng liền nhau.*

## 4. KHÔNG làm trong phiên bản này

Sáu ranh giới, mỗi cái có lý do đã trả giá:

1. **Không để AI sinh ra một con số nào.** Máy chủ tính SỐ, AI chỉ viết CHỮ NỐI. Lý do: AI của WHOOP bị bắt quả tang bịa số liệu người dùng (có ảnh chụp, lời AI tự nhận *"I invented fake data about your strain, steps, HRV"*); mức nền lỗi của lời khuyên sức khoẻ do mô hình ngôn ngữ sinh ra là 21,6–43,2% câu có vấn đề (*npj Digital Medicine* 2026).
2. **Không có bảng xếp hạng cá nhân hằng ngày, không có chỉ số tổng hợp kiểu "tuổi hiệu suất".** Lý do: bảng xếp hạng hại đúng người đang làm tốt, và cửa "rời nhóm" của app sức khoẻ không tồn tại trong một công ty. Một thước đo duy nhất là điều kiện gây thay thế thước đo (Choi/Hecht/Tayler) — nên giữ bộ ba con số.
3. **Không cho quản lý xem điểm số của từng cá nhân.** Lý do: Kluger & DeNisi 1996 (607 hệ số hiệu ứng, 23.663 quan sát) — phản hồi kéo chú ý về phía NGƯỜI thay vì về VIỆC có 38% khả năng làm hiệu suất giảm. Mọi câu chữ trong app nói về *việc*, không nói về *người*.
4. **Không thưởng điểm cho hành vi thêm một task** (Todoist làm vậy), và **không có ma trận Eisenhower**. Lý do: thưởng đúng cái đang gây hại; còn ba luống đã mạnh hơn Eisenhower và có bằng chứng hơn.
5. **Không phạt việc rời app.** Chỉ đếm giờ; cây chỉ héo khi người dùng tự bấm huỷ. App phạt sự IM LẶNG, không phạt việc vỡ cam kết — cửa "thoát im lặng" khi kết phiên bị bỏ, còn quá trần hoãn thì không bao giờ để người ta chỉ còn đúng một cửa là Huỷ.
6. **Không mở bán cho công ty ngoài trong phiên bản này.** Làm cho xong ca ROVA đã, tổng quát hoá sau.

*Đang gác có chủ đích, giữ nguyên dữ liệu để bật lại: lớp hiển thị giao diện nông trại · cỏ dại khi bỏ bê · nối Google Calendar.*

## 5. Dữ liệu

**Vào** — cam kết (tên · tiêu chí xong · hạn · luống) · task (nội dung · deadline · giờ trên lưới · màu) · nhịp việc lặp hằng tuần và số làm được mỗi ngày · checklist việc con · phiên deepwork (bấm bắt đầu/kết thúc, giờ do máy chủ đóng dấu, không sửa được) · chuông tỉnh thức · ghi chú kèm thẻ · output khi đóng cam kết (bắt buộc) và lý do khi từ chối (bắt buộc).

**Ra** — điểm ngày tự chấm 💎/🪨/💩 (máy chấm, không ai tự phong) · hai bảng vinh danh quả và giờ · giờ deepwork theo ngày/theo giờ (ô "Giờ vàng")/theo loại việc · tiến độ cam kết và dự án được TÍNH chứ không được KHAI · "nhịp này thật ra tốn bao lâu" · hộp *Chờ bạn*.

**Lưu** — Supabase (Postgres), **20 bảng + 18 khung nhìn**. Đăng nhập Google OAuth, đối chiếu danh sách trắng email; RLS từng dòng: cả đội đọc được của nhau, chỉ sửa được dòng của mình; chốt ngày rồi không sửa không xoá. Mã nguồn ở GitHub riêng tư, đẩy `main` là Cloudflare Workers tự phát hành.

## 6. Xong là gì

⚠️ **Cần Tracy chốt** — hai câu hỏi ở cuối file.

Đề xuất: *Trước [ngày Demo Day], đủ 12/12 người ROVA dùng app làm chỗ duy nhất khai việc, Google Sheet 12 tab đã tắt hẳn, và có ít nhất 4 tuần liên tục dữ liệu deepwork của cả đội để đọc ra được xu hướng.*

Kiểm được bằng: đếm số người có phiên deepwork trong 7 ngày gần nhất = 12 · Apps Script sinh tuần đã dừng.

## 7. Dễ hỏng ở đâu

**Mất dữ liệu là chỗ đau nhất.** Supabase gói Free không giữ bản dự phòng nào; sao lưu hiện chạy tay bằng `sao-luu.py` và chỉ phủ 12 trong 20 bảng — **8 bảng chưa có bản sao nào** (`moc_du_an`, `thanh_vien_du_an`, `chuc_nang`, `viec_co_dinh`, `ghi_chu`, `doc_cam_ket`, `cum_trang_thai_task`, `tran_danh_muc`). Bật lịch sao lưu tự động là việc #23 trong hồ sơ G-01, đang hoãn tới ngày mở app cho cả đội — tức đúng lúc dữ liệu bắt đầu đáng giá nhất thì vẫn chưa có lưới an toàn.

Ba chỗ hở nhỏ hơn, đã đo, chưa vá: đường GHI xuống máy chủ **chưa thử lần nào với dữ liệu thật** (mọi làn mới soi tới mức DOM) · tầng giao cam kết chưa ai thử tay đường giao → nhận → vào luống · chuông bấm dồn không có phanh (một phiên ghi 7 tiếng chuông trong 2 giây).

---

## Hai câu hỏi cho Tracy

1. **Ngày Demo Day của khoá là ngày nào?** — cần con số này để mục 6 kiểm được.
2. **Mốc "xong" của 4 tuần này là mở đủ 12 người, hay là một tính năng cụ thể?** Mặc định tôi đi theo phương án 12 người ở trên.
