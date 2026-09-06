# Spec một trang — Khu Vườn Tỉnh Thức

> Bảy mục theo khuôn Buổi 2 (Build to Own). Viết lại 06/09/2026 trên số đo thật của bản sao dữ liệu ngày 05/09.
> Spec trả lời **cái gì**, không trả lời **làm thế nào** — phần làm thế nào nằm ở `CAU-TRUC-APP.md` và `BAN-DO-INDEX.md`.

---

## 1. Vấn đề

**Mỗi sáng, từng người trong một doanh nghiệp nhỏ làm việc online lại gõ lại bằng tay những việc hôm qua chưa xong — vì việc dở không có chỗ nào giữ hộ, và không có cơ chế nào đóng nó lại.**

Đo trên chính ROVA, hai tháng 29/05→31/07/2026: **490 trong 1.922 task là việc cũ gõ lại** · danh mục "dự án" đi từ 6–7 lên **13 mà không cái nào đóng** · **156 nhịp việc lặp** gánh 34% lượng chữ báo cáo. Cùng lúc, mỗi người chỉ thực sự tập trung sâu khoảng **2,3 giờ mỗi ngày** dù ngồi bàn 8–10 giờ.

Cả ba là hỏng hóc thiết kế, không phải hỏng hóc thái độ: hệ thống cũ (chat Lark + bảng tính 12 tab) không có chỗ giữ hộ việc, và không có cơ chế đóng việc.

## 2. Người dùng

**Doanh nghiệp nhỏ dưới 20 người, làm việc online.** Ca dùng đầu tiên và nơi app đang chạy thật: đội ROVA (đào tạo trading, 12 người, cơ cấu phẳng) — **7 người dùng thật từ 08–10/08/2026**.

Hiện họ thay thế bằng ba chỗ rời nhau: **nhóm chat** để giao việc, **bảng tính** để báo cáo, và **một app danh sách việc** kiểu ClickUp/Todoist. Không chỗ nào giữ nổi chuỗi từ mục tiêu của công ty xuống tới giờ làm thật của một người, nên tổng tải của đội không ai nhìn thấy — người rảnh vẫn rảnh, người quá tải vẫn nhận thêm.

## 3. Nó làm gì

- **Giữ** nhịp việc lặp của từng phòng ban theo **vị trí, không theo người** — sáu khối chức năng, mỗi khối một danh mục dùng chung, người nghỉ thì việc vẫn có chủ
- **Chia** dự án của đội xuống thành cam kết của từng cá nhân, có giao và có ký nhận, rồi **tính** tiến độ ngược lên từ dữ liệu thật — không ai gõ phần trăm bằng tay
- **Công bố** lịch chung của công ty, để mỗi người tự xếp việc của mình vào khung giờ thật trên lịch trình riêng, nhìn trước 60 ngày
- **Chặn** quá tải bằng hai luật cứng: trần ba cam kết một người (CEO năm) đặt ở tầng cơ sở dữ liệu, và phiên tập trung có đồng hồ do máy chủ đóng dấu
- **Gỡ** vấn đề phát sinh giữa các phòng ban bằng một hàng có người nêu, có đồng hồ 24 giờ và có luật *chỉ người nêu mới được đóng*

*Chuỗi bốn tầng **dự án → cam kết → task → phiên tập trung** là điểm độc nhất về kiến trúc: benchmark 6 app (ClickUp, Asana, Todoist, TickTick, Sunsama, Motion) cho thấy mỗi app chỉ giữ được hai tầng liền nhau. Toàn bộ chuỗi này được kể lại bằng hình tượng một khu vườn — gieo hạt là tuyên bố cam kết, tưới cây là một phiên tập trung, quả chín là kết quả nộp được — và cây chỉ lớn bằng giờ làm việc thật.*

## 4. KHÔNG làm trong phiên bản này

Tám ranh giới, mỗi cái có lý do đã trả giá:

1. **Không để mô hình ngôn ngữ sinh ra một con số nào.** Máy chủ tính SỐ, phần chữ chỉ nối câu. Lý do: AI của WHOOP bị bắt quả tang bịa số liệu của chính người dùng, và mức nền lỗi của lời khuyên sức khoẻ do mô hình sinh ra là 21,6–43,2% câu có vấn đề (*npj Digital Medicine* 2026).
2. **Không có bảng xếp hạng cá nhân hằng ngày, không có chỉ số tổng hợp kiểu "tuổi hiệu suất".** Lý do: bảng xếp hạng hại đúng người đang làm tốt — Hydari và cs. 2023 (*Management Science*) đo được người ít vận động tăng 1.300 bước còn người đã năng động **giảm 630 bước**. Và cửa "rời nhóm" của app sức khoẻ không tồn tại trong một công ty.
3. **Không cho quản lý xem điểm số của từng cá nhân.** Lý do: Kluger & DeNisi 1996 (607 hệ số hiệu ứng, 23.663 quan sát) — phản hồi kéo chú ý về phía NGƯỜI thay vì về VIỆC có **38%** khả năng làm hiệu suất giảm. Mọi câu chữ trong app nói về *việc*, không nói về *người*.
4. **Không thưởng điểm cho hành vi thêm một task** (Todoist làm vậy), và **không có ma trận ưu tiên bốn ô**. Lý do: 490 task gõ lại chính là bệnh gốc, thưởng nó là thưởng đúng cái đang gây hại; còn trần ba cam kết đã mạnh hơn ma trận và có bằng chứng hơn.
5. **Không có bảng quy đổi điểm ra tiền.** Lý do: có tỉ giá thì mọi quả đổi nghĩa từ *kết quả của tôi* thành *đơn vị lương* — hiệu ứng biện minh quá mức. Tiền chỉ dùng để đặt cược trước, không dùng để trả sau theo điểm.
6. **Không phạt việc rời app.** Chỉ đếm giờ; cây chỉ héo khi người dùng tự bấm bỏ cuộc. App phạt sự IM LẶNG, không phạt việc vỡ cam kết — nên khi kết phiên không có cửa nào cho phép im lặng đi ra, và khi quá trần hoãn thì không bao giờ để người ta chỉ còn đúng một lối là huỷ.
7. **Không nối Google Calendar.** App tự dựng lớp lịch riêng, vì thứ cần đo là *giờ đã làm thật* chứ không phải *giờ đã đặt chỗ*.
8. **Không mở bán cho công ty ngoài trong phiên bản này.** Làm cho xong ca ROVA đã, tổng quát hoá sau.

*Đang gác có chủ đích, dữ liệu giữ nguyên để bật lại:* lớp hiển thị giao diện nông trại · cỏ dại khi bỏ bê · ô "mồi mai" của nghi thức hoàn tất.

## 5. Dữ liệu

**Vào** — cam kết (tên · tiêu chí xong · hạn · luống) · task (nội dung · hạn · giờ trên lưới) · nhịp việc lặp hằng tuần và số làm được mỗi ngày · phiên tập trung (bấm bắt đầu và kết thúc, **giờ do máy chủ đóng dấu, người dùng không sửa được**) · chuông tỉnh thức · sự kiện lịch và lời mời · vấn đề phát sinh cùng mạch bàn luận · **Output bắt buộc khi đóng cam kết**, và lý do bắt buộc khi từ chối một việc được giao.

**Ra** — tiến độ cam kết và dự án được **tính** chứ không được **khai** · điểm ngày do máy tự chấm · hai bảng ghi nhận cân nhau (kết quả và giờ tập trung) · giờ sâu theo ngày, theo khung giờ trong ngày, theo loại việc · "nhịp này thật ra tốn bao lâu" · một hộp *Chờ bạn* gom mọi thứ đang chờ đúng tên mình.

**Lưu** — Supabase (Postgres): **30 bảng, 19 khung nhìn**, phân quyền từng dòng bật trên cả 30 bảng. Đăng nhập bằng Google, đối chiếu danh sách trắng email. Cả đội đọc được của nhau, mỗi người chỉ sửa được dòng của mình, ngày đã chốt thì không sửa không xoá. Mã nguồn ở GitHub riêng tư; đẩy nhánh `main` là Cloudflare Workers tự phát hành.

## 6. Xong là gì

**Trước Demo Day 20/09/2026, đủ 12/12 người ROVA dùng app làm chỗ duy nhất khai việc, bảng tính 12 tab đã tắt hẳn, và trong hệ có ít nhất 4 tuần liên tục dữ liệu phiên tập trung của cả đội.**

Kiểm được bằng ba phép đếm, không cần ai đánh giá: số người có phiên tập trung trong 7 ngày gần nhất **= 12** · script sinh bảng tuần trên bảng tính **đã dừng** · ngày cũ nhất trong chuỗi dữ liệu liên tục **cách hiện tại ≥ 28 ngày**.

Mốc hiện tại, đo ngày 05/09/2026: **7/12 người**, 401 phiên tập trung, 378 giờ, chuỗi dữ liệu đã liền 31 ngày. Tức phần còn thiếu là **5 người cuối**, không phải phần dữ liệu.

## 7. Dễ hỏng ở đâu

**Mất dữ liệu là chỗ đau nhất.** Supabase gói Free không giữ bản dự phòng nào; bản sao hiện chạy tay và mới phủ **12 trong 30 bảng** — **18 bảng chưa có bản sao nào**, trong đó có cả bảng lịch chung và bảng vấn đề vừa dựng. Đúng lúc dữ liệu bắt đầu đáng giá nhất thì vẫn chưa có lưới an toàn.

Ba chỗ hở nhỏ hơn, đã đo, chưa vá:

- **Đường giao cam kết chưa ai thử tay với dữ liệu thật** — mọi làn mới soi tới mức giao diện, chưa chạy trọn đường giao → nhận → vào luống.
- **Lớp vấn đề liên phòng ban đã lên sóng ở phần mã nhưng chưa có dấu đã chạy trên máy chủ** — chưa chạy thì lớp này chưa sống, dù giao diện đã có.
- **Một file 2,5 MB là toàn bộ giao diện.** Nó chạy tốt, nhưng mỗi lần sửa phải tra bản đồ hàm trước; và khi nhiều phiên cùng sửa thì lịch sử dễ lẫn — đã xảy ra ba lần, nay có bộ luật chia làn riêng.

**Chỗ hở lớn nhất không nằm ở kỹ thuật:** app hiện chỉ ràng buộc người NHẬN việc. Chưa có luật nào ràng buộc người GIAO việc — nên nếu đầu vào không đổi, app chỉ làm tình trạng quá tải trở nên đo được, chứ chưa làm nó nhỏ đi.
