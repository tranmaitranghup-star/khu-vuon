# HỒ SƠ TOÀN CẢNH — APP "KHU VƯỜN TỈNH THỨC" (ROVA)

> **Tài liệu này viết cho một AI khác đọc.** Người đưa tài liệu cho bạn là **Tracy** — nữ doanh nhân Việt Nam, đồng sáng lập/điều hành ROVA (công ty đào tạo trading, 12 người, startup cơ cấu phẳng), TriEye (tư vấn hệ thống vận hành) và X3com. Tracy là người thiết kế và ra mọi quyết định về app này; một AI trợ lý (Claude) đang cùng cô xây nó. Tracy muốn trao đổi với bạn về **tầng triết lý** của app — đọc xong tài liệu này bạn phải nắm được: mục đích, triết lý, nguyên lý đã chốt, tính năng, framework, bản chất và tiến độ.
>
> **Quy ước độ tin cậy** (giữ nguyên khi trích lại): ✅ = Tracy đã chốt hoặc có nguồn xác thực · ⚠️ = đề xuất của AI hoặc suy luận, CHƯA được Tracy duyệt · ❓ = câu hỏi đang mở. Câu trong ngoặc kép nghiêng là **nguyên văn lời Tracy**.
>
> Cập nhật: 2026-08-09. Nguồn: hồ sơ dự án G-01 (nhật ký thiết kế từng ngày), mã nguồn app, và các cụm tri thức trong "bộ não thứ hai" của Tracy (wiki cá nhân đã nạp nguyên văn các sách/deck được nhắc bên dưới).
>
> **Đây là FILE DUY NHẤT về app.** Mục 1–10 lo tầng triết lý và thiết kế (đọc khi bàn hướng đi, hoặc gửi cho AI khác). Mục 11–17 lo tầng kỹ thuật: bảng dữ liệu, ngưỡng số, luật đã trả giá, chỗ đang hở, và **Nghĩa địa** ghi những thiết kế đã bị thay — đọc khi sắp sửa app. Muốn biết **đang làm tới đâu** thì đọc `tieu-diem/G-01-quan-ly-cong-viec-rova.md`.
>
> **Luật giữ file đúng:** sửa app xong thì cập nhật mục liên quan ở đây **trước** khi ghi nhật ký. Thứ bị thay thì chuyển xuống Nghĩa địa kèm ngày, đừng xoá — mục đó tồn tại để phiên sau không dựng lại cái đã bỏ.

---

## 1. BẢN CHẤT — app này là gì

**Một câu:** Khu Vườn Tỉnh Thức là web app quản lý **CAM KẾT** cho đội ROVA — mỗi người công khai tối đa 3 cam kết, riêng CEO 5 (kết quả hứa nộp trong vài ngày tới 1 tuần), chia thành task, rồi dùng các phiên **deepwork** có đồng hồ thật để biến cam kết thành hiện thực; toàn bộ được bọc trong hình tượng một khu vườn mà ở đó **cây chỉ lớn bằng giờ làm việc thật**.

**Slogan màn đăng nhập** (✅ Tracy chốt nguyên văn 08/08/2026):

> ROVA
> KHU VƯỜN TỈNH THỨC
> *Nơi ước muốn được nuôi trồng mỗi ngày*
> *để thành hiện thực chúng ta cam kết*

Chú ý cấu trúc slogan — nó chính là triết lý nén lại: **ước muốn** (hạt, thứ chưa có) → **nuôi trồng mỗi ngày** (chặng giữa, chỗ người ta hay bỏ cuộc) → **hiện thực** (quả, thứ sờ được) → **cam kết** (cơ chế bảo chứng). Khi chốt câu này Tracy đã loại phương án "Gieo tương lai — Gặt ước muốn" với lý do đáng ghi: *ước muốn là hạt chứ không phải quả* — luật kiểm tra cho mọi cặp gieo–gặt: **vế sau phải là thứ sờ được, vế trước là thứ chưa có** (✅ nhật ký 08/08).

**Định nghĩa lõi của CAM KẾT** (✅ nguyên văn Tracy, 08/08): *"cam kết là những kết quả mình cam kết với cấp trên sẽ đạt được trong vài ngày tới (tối đa 1 tuần) và nó là cam kết CÁ NHÂN. đầu ra của cam kết là 1 output nộp cho cấp trên."*

**Điều Tracy muốn app trở thành** (✅ lời Tracy, 09/08 — định hướng, chưa phải tính năng): app khác mọi app quản lý công việc ở chỗ nó quản lý **cam kết**, không quản lý danh sách việc. Nó phải: cổ vũ làm việc sâu và dùng thời gian hiệu quả · cổ vũ làm việc **có ý nghĩa** (hiểu cam kết phục vụ mục đích gì của tổ chức, leader giúp soi cam kết có phục vụ doanh nghiệp không) · **giữ integrity** cho người dùng và có cơ chế/flow khiến app không bao giờ thành "bãi rác việc tồn kho" · giúp doanh nghiệp đi nhanh tới mục tiêu theo triết lý **Speed of Light**, hợp thời đại công ty một người (OPC) và AI thay thế — đội tinh gọn hiệu suất cao · và trên hết: giúp con người **sống hiệu quả, sống trong hiện tại, hồi phục chủ động và lành mạnh**, dùng tốt thời gian và năng lực để tạo giá trị thật cho thế giới, thay vì bị entropy của thế giới ngoài kia cuốn đi. Hướng game: xây theo kiểu **game nông trại như Stardew Valley** — có nhiệm vụ, có tương tác, và đặc biệt là **có ý nghĩa**.

---

## 2. VẤN ĐỀ GỐC — app sinh ra để chữa cái gì

Trước app, đội ROVA báo cáo việc hằng ngày qua nhóm chat Lark "Tỉnh thức" + Google Sheet 12 tab. Data 2 tháng (29/05→31/07/2026) được mổ ra và cho thấy ba vết rò (✅ số thật):

1. **490 task là việc cũ bị gõ lại mỗi sáng** — việc chưa xong hôm qua không có chỗ nằm, nên sáng nào cũng phải khai lại bằng tay. Nguyên nhân kỹ thuật đã tìm ra: schema cũ bắt mọi task phải có ngày (`ngay not null default hom_nay()`) — không tồn tại "kho việc". Đây là cơ chế đẻ ra bãi rác việc tồn kho mà app thề sẽ không lặp lại.
2. **156 nhịp việc lặp lại** (≥3 lần) nằm ngoài phạm vi "quản trị dự án" — chỉ 16 nhịp thật sự đều nhưng gánh 34% lượng chữ báo cáo.
3. Khoảng 13 việc cùng được gọi là "dự án" mà không ai nhìn thấy toàn cảnh; việc giao bằng miệng, không ai nhìn tổng tải — người rảnh vẫn rảnh, người quá tải vẫn nhận thêm.

Tổng quát hoá: phạm vi hệ thống gồm **4 luồng việc** (✅ chốt 05/08) — ① việc sinh từ mục tiêu · ② việc lặp lại hằng ngày · ③ việc phát sinh · ④ ý tưởng chờ duyệt.

---

## 3. KHÁC GÌ CÁC APP KHÁC — kết quả benchmark 6 app (✅ 08/08)

Đã mổ 6 app đối chứng: ClickUp, Asana (hệ thống dọc) · Todoist, TickTick (GTD cá nhân) · Sunsama, Motion (chặn thời gian). Hai phát hiện đắt nhất:

1. **Chuỗi ba tầng "cam kết → task → phiên deepwork" — không app nào trong 6 app có đủ.** Mỗi app chỉ giữ hai tầng liền nhau. Đây là điểm độc nhất về kiến trúc.
2. **Không app nào dám CHẶN quá tải bằng luật.** WIP limit của ClickUp chỉ đổi màu, Asana chỉ vẽ vạch đỏ, ngưỡng của Sunsama nhấn qua được. Khu Vườn **chặn cứng ở cả tầng cơ sở dữ liệu: "hết luống là hết đất"** — 3 cam kết cùng lúc (CEO 5), muốn gieo mới phải đóng một cái cũ. Đây là chỗ luật chơi ép ra sự tập trung.

Câu đáng nhớ từ đợt benchmark (bài phê app Motion): *"máy chỉ trả lời được 'làm cái này lúc nào', không trả lời được 'nên làm cái gì'"* — phần "nên làm cái gì" chính là tầng cam kết + leader mà app này giữ cho con người.

### 3b. Nghiên cứu sâu 2 app đầu ngành + 3 app bổ sung (✅ 09/08)

📄 **`production/tinh-thuc-app/nghien-cuu-ticktick-todoist.md`** — bản đầy đủ, cũng có **bản HTML cùng tên** đọc trên điện thoại (sinh lại bằng `python3 production/tinh-thuc-app/xuat-html.py <file.md>`; **đừng sửa tay file HTML**).

> 🧭 **ĐỌC FILE ĐÓ TRƯỚC KHI BÀN BẤT KỲ TÍNH NĂNG MỚI NÀO.** Nó đã quét trọn bảng tính năng TickTick (94 bài tài liệu chính hãng) và Todoist, cộng Sunsama · Motion · Amazing Marvin; kèm **12 cơ chế có xếp hạng độ mạnh bằng chứng khoa học** và **17 đề xuất nâng cấp**. Đừng nghiên cứu lại từ đầu.

Sáu điều từ bản đó cần biết ngay khi sửa app:

1. **Khối TỔNG QUAN của ta đứng ngang app đầu ngành.** TickTick có đúng cơ chế lưới nhiệt (*Year Grids*) nhưng **không công bố ngưỡng thang màu**, còn ta neo sáu bậc vào **đúng bảng nấc cây**; lưới ta **co theo lịch sử thật**. Todoist **không có lưới nhiệt nào**. TickTick có tới **ba** lưới (giờ tập trung · từng thói quen · việc hoàn thành) — ta mới có một.
2. 🔴 **Đừng viện dẫn hiệu ứng Zeigarnik nữa.** Phân tích tổng hợp 2025 soi 59 công trình, **không thấy lợi thế trí nhớ cho việc dang dở**. Thứ đứng vững là **hiệu ứng Ovsiankina** (muốn làm nốt) và **dư âm chú ý** (Leroy 2009). ⚠️ Trang wiki [[nhan-roi-co-chu-dich]] vẫn đang trình bày Zeigarnik như dữ kiện — nợ cần dọn.
3. ⭐ **Nền khoa học mạnh nhất cho hình tượng khu vườn là *nguyên lý tiến bộ*** (Amabile & Kramer: 12.000 nhật ký · 238 người · 7 công ty) — thứ tạo đời sống nội tâm tích cực là **cảm giác tiến bộ trong việc có ý nghĩa**. Cây lớn dần và lưới nhiệt đều đo *đã đi được bao xa*, không đo *còn nợ bao nhiêu*. **Đây là lý lẽ để giữ hình tượng, không phải vì nó đẹp.**
4. ⭐ **Ba cơ chế có bằng chứng MẠNH nên dựa vào:** tự theo dõi tiến độ (138 nghiên cứu · 19.951 người) · nguyên lý tiến bộ · **ý định thực thi "nếu… thì…"** (d = 0,65 · 94 phép thử) — cái thứ ba **cả năm app kia đều bỏ trống**.
5. ⚠️ **Cả TickTick lẫn Todoist đều tự lắp phanh cho hệ điểm, ta thì chưa.** TickTick: trần 50 việc/ngày, trần 10 lần điểm danh/ngày. Todoist: trừ điểm việc trôi, chế độ nghỉ phép, ngày nghỉ cố định, tắt hẳn được, **không có bảng xếp hạng**. Bảng 🍎 của ta không có trần nào.
6. ⭐ **Ta là app duy nhất trong chín app chặn quá tải bằng luật thật** — nhưng cũng là app **duy nhất có nghi thức đóng sổ VIỆC mà không có nghi thức đóng sổ NGÀY**. Màn Dọn hỏi *"việc này ra sao"*, chưa hỏi *"ngày hôm nay ra sao"*.

**Ba thứ bản đó khuyên KHÔNG bê sang:** ma trận Eisenhower (không có nghiên cứu thực nghiệm, và ba luống đã mạnh hơn) · **thưởng điểm cho hành vi THÊM một task** (Todoist làm vậy — thưởng đúng cái đang gây hại) · nhiều tầng việc con.

### 3c. Nghiên cứu 2 app ĐO CƠ THỂ — WHOOP & Bevel (✅ 10/08)

📄 **`production/tinh-thuc-app/nghien-cuu-whoop-bevel.md`** (có bản HTML cùng tên). Nguồn sơ cấp: **8 ảnh chụp màn hình từ tài khoản WHOOP thật của Tracy**, 10/08 lúc 15:43–15:44 — mạnh hơn tài liệu chính hãng, vì ảnh cho thấy bản đang chạy.

> 🧭 **Đọc file đó trước khi bàn tầng "khiến người ta muốn tiến bộ mỗi ngày".** Bản TickTick/Todoist lo tầng *quản lý việc*; bản này lo tầng *muốn tốt lên*. Hai bản không trùng nhau.

Sáu điều cần biết ngay:

1. ⭐⭐ **Bản chất WHOOP không phải là đo — là BA CON SỐ nối thành một chuỗi nhân quả**, mỗi số tháo thành **đúng bốn đòn bẩy làm được ngay hôm nay**. Ngủ → Hồi phục → Khoảng gắng sức. Chỉ số lớn của màn này là chỉ số con của màn kia.
2. ⭐⭐⭐ **Mỗi sáng app giao một ĐỀ BÀI, không phải một bản điểm:** *"take on a moderate level of Strain between 11.3 and 15.3 today"* — mục tiêu là một **khoảng**, sinh từ trạng thái hôm nay, **co lại trong ngày**, và có **trần** (vượt trần gọi là *overreaching*, không được khen).
3. ⭐ **Không con số nào trong cả app đứng một mình** — luôn dán kèm trung bình 30 ngày của chính người đó. Chỗ `<em>` trong hàm `veTongQuan()` của ta đang bỏ trống đúng vai này.
4. ⭐ **Câu chữ viết về SỨC, không về Ý CHÍ** — *"Rest is likely what your body needs."* Đây là cơ chế rẻ nhất cả bản: chỉ là viết lại chữ. La bàn *"không trừng phạt, chỉ mời gọi"* của ta chưa được soát ở tầng câu chữ.
5. ⭐⭐⭐ **WHOOP Journal là bản thiết kế sẵn cho phần TỰ KHAI của ta** — hỏi đúng một thời điểm cố định · trần dưới 10 hành vi · **không kết luận cho tới khi có ≥5 lần CÓ và ≥5 lần KHÔNG trong 90 ngày** · và luôn nói *"do not establish causation"*.
6. 🔴 **Không có nghiên cứu bình duyệt nào xác thực các điểm TỔNG HỢP** (Recovery, Strain, Energy Bank) — chỉ các **đầu vào** có bằng chứng. Tức WHOOP ăn khách vì **thiết kế hành vi**, không vì độ chính xác. Tin mừng cho ta (chép được phần thiết kế mà không cần cảm biến) và lời cảnh báo (số đẹp không phải số đúng).
7. 🔴🔴 **ĐỌC TRƯỚC KHI DỰNG VIỆC 41 (dashboard có AI): AI của WHOOP BỊA SỐ LIỆU của người dùng.** Ba ca có ảnh chụp làm bằng, kèm lời con AI tự nhận: *"I invented fake 'data' about your strain, steps, HRV"* · *"I was wrong to throw out a specific number like 8,800 ft. I don't actually see your exact elevation gain"*. Không có nghiên cứu nào đánh giá độ chính xác của nó; mức nền cho lời khuyên sức khoẻ do mô hình ngôn ngữ sinh ra là **21,6–43,2% câu có vấn đề** (*npj Digital Medicine* 2026).
   → **LUẬT cho app ta: máy chủ tính SỐ, AI chỉ được viết CHỮ NỐI, AI không bao giờ được sinh ra một con số.** Mọi số trong câu phải do SQL trả về và đưa vào khuôn như tham số; trường rỗng phải có nhánh câu riêng (ba ca bịa đều xảy ra đúng chỗ mô hình không có dữ liệu mà vẫn phải nói gì đó).
   ⭐ Kèm theo là thứ chép được ngay: **khuôn câu Daily Outlook** đã lấy được qua bốn đời tính năng, và ngữ pháp trích số **không đổi lần nào**: *chỉ số → giá trị hiện tại → mốc so có tên*. Trong mọi bản mẫu luôn có **ít nhất một gạch đầu dòng là tin xấu** — bản khen trọn không tồn tại.

**Ba thứ bản đó khuyên KHÔNG bê sang:** **pin năng lượng** kiểu Energy Bank của Bevel (sẽ nói dối đúng những ngày họp nhiều mà không bấm giờ) · **bảng xếp hạng cá nhân hằng ngày** (nó hại đúng người đang làm tốt; và cửa "rời nhóm" của WHOOP không tồn tại trong một công ty) · **chỉ số tổng hợp kiểu "Tuổi hiệu suất"** (không có mốc neo ngoài app, tạo ảo giác về độ chính xác, và **một thước đo duy nhất là điều kiện gây thay thế thước đo mạnh nhất** — Choi/Hecht/Tayler; nhiều thước đo thì triệt tiêu hiệu ứng đó, nên bộ **ba** con số ở B1 là quyết định có bằng chứng).

⚖️ **Hai chỗ bằng chứng đi ngược trực giác, đừng nhớ sai:** ① **đừng thay bảng xếp hạng bằng tính năng "động viên nhau"** — một thử nghiệm ngẫu nhiên N=790 cho thấy nhánh động viên **không có tác dụng** (p=.68), còn thấp hơn cả nhóm đối chứng, trong khi nhánh so sánh xã hội **+62%**; ② vùng nguy hiểm của một bảng so sánh là **khúc giữa**, không phải đáy bảng (quan hệ hình chữ U).

🔴 **Rủi ro thiết kế lớn nhất khi bê cơ chế từ app sức khoẻ sang app doanh nghiệp:** ở app sức khoẻ người dùng **tự xem** số của mình; ở app doanh nghiệp **sếp cũng xem**. Theo Kluger & DeNisi 1996 (607 hệ số hiệu ứng, 23.663 quan sát), khi phản hồi kéo chú ý về phía **bản thân người ta** thay vì về **công việc** thì **38% khả năng nó làm hiệu suất GIẢM**. Đây là lý do mọi câu chữ trong app phải nói về *việc*, không nói về *người*.

⚠️ **Một cảnh báo pháp lý:** WHOOP đã kiện Bevel ngày 17/03/2026, trong đó có cáo buộc về **trade dress của giao diện** (cách trình bày recovery/strain/sleep). Rủi ro với ta rất thấp (nội bộ 12 người, không đo sinh lý), nhưng bài học đúng: **chép cơ chế, đừng chép hình thức.**

---

## 4. FRAMEWORK & KIẾN TRÚC

### 4.1. Bốn tầng dữ liệu (✅ chốt 08/08)

| Tầng | Là gì | Chu kỳ | Ai sở hữu |
|---|---|---|---|
| **Mục tiêu** | mục tiêu phòng ban / doanh nghiệp, nhiều cam kết phục vụ 1 mục tiêu | 1 tuần – 1 tháng | leader |
| **Cam kết** | kết quả CÁ NHÂN hứa với cấp trên, có Output nộp được | vài ngày – 1 tuần, **tối đa 3 cùng lúc (CEO 5)** | từng người |
| **Task** | việc cụ thể, ngồi một buổi là xong — cỡ nửa giờ tới hai giờ, tức một tới hai phiên tập trung; `ngay` được phép rỗng → nằm trong **kho** | 1 ngày | từng người |
| **Phiên deepwork** | phiên tập trung đo giờ thật, gắn vào 1 task | 5–120 phút | từng người |

Hệ quy chiếu quản trị đứng sau: O → G → KR → Task (KR cá nhân chính là "Cam kết"). ❓ còn mở: "dự án" đứng ở đâu trong hệ 4 tầng.

### 4.2. Bộ luật vận hành đã chốt (✅ — đây là phần "cơ chế giữ integrity")

- **Luật 3b:** *"không để một task quá một ngày mà chưa đổi trạng thái"* — được **cưỡng chế bằng màn "Dọn việc hôm qua"** chặn cứng khi mở app: 4 trạng thái kết thúc (Done · Chưa xong · Miss · Nghẽn, mỗi cái một câu hỏi bắt buộc), mốc 24h máy tự tick Chưa xong, trần **3 lần hoãn** một task.
- **Deepwork tự do, ba cửa ra:** đồng hồ đếm lên, sàn 5 phút trần 120 phút, đo giờ thật; kết phiên bắt buộc chọn 1 trong 3 cửa — ✅ Xong · 🔄 Chưa xong (kèm chỗ đang đứng và **bước kế tiếp**) · 🚧 Nghẽn (kèm việc gỡ chặn, **cửa duy nhất bắt gõ**). **Không có cửa "thoát im lặng".** Ghi ở hai cửa đầu là **tuỳ ý** (Tracy 12/08: *"task ko yêu cầu output đâu"*) — task là việc của riêng mình, chỉ **cam kết** mới bắt output vì đó là thứ nộp lại cho người khác.
  - **Phiên VIỆC CỐ ĐỊNH cũng qua đúng ba cửa ấy** (Tracy chốt 12/08: *"vẫn 3 cửa như task đi"*, thay luật cũ *1 phiên = xong*). Khác nhau chỉ ở cái đứng sau cửa: nhịp không có task để đổi trạng thái nên ghi chú dừng ở `phien_deepwork.ghi_chu`, và cửa Nghẽn đẻ ra một **việc lẻ** hẹn hôm nay thay vì task con.
  - **Chữ ở tầng task nói theo nghĩa rộng của kết quả** (Tracy 12/08: *"output cũng có thể là 1 sự nhận thức mới về bài toán ẩn"*): cửa Xong hỏi *"bạn vỡ ra điều gì, hay làm ra được gì"*, nhãn dòng việc là **Kết quả** chứ không phải *Output*, màn chọn việc gọi task là **đích đến của phiên**. Chữ *Output* chỉ còn ở tầng cam kết.
- **Bỏ luật héo** (✅ nguyên văn: *"BỎ luật héo khi rời app. Chỉ đếm giờ. Chỉ héo khi người dùng tự bấm hủy"*) — app không trừng phạt việc rời đi; chỉ có TỰ bỏ cuộc mới là héo.
- **Chuông tỉnh thức 🔔** — tính năng mang linh hồn app (✅ chốt 06/08): trong phiên deepwork, mỗi lần nhận ra mình xao nhãng và quay về thì bấm chuông. Nguyên lý: *"app không đo sự xao nhãng; app đếm số lần tánh biết bật lên"* — chuông là **điểm cộng, không bao giờ là điểm trừ**; không vào bảng vinh danh, chỉ so mình-hôm-nay với mình-tuần-trước; chuông dồn dập → app *khuyên* nghỉ (tối đa 1 lần/phiên, luôn có cửa "tôi làm tiếp"). Đã dùng thật: 30 tiếng chuông trong CSDL sau 3 ngày.
- **Hai bảng vinh danh cân nhau:** 🍎 đếm **quả** (kết quả trong ngày) · 💧 đếm **giờ tập trung** (nỗ lực) — cố tình giữ CẢ HAI để không rơi vào bẫy chỉ đo output hoặc chỉ đo effort (benchmark cho thấy cặp cân này hiếm có ở app khác).
- **Không phải task nào cũng cần deepwork** (✅ Tracy, 08/08: *"có những việc không cần deepwork ví dụ việc giao tiếp hoặc trao đổi"*) — giờ deepwork là lead measure cho việc sâu, không phải thước duy nhất của mọi việc.
- **Khối tổng quan là gương soi riêng** — thống kê deepwork cá nhân chỉ mình mình thấy; chuỗi ngày làm việc có luật tha Chủ nhật.
- **Nguyên lý thứ tự mắt nhìn** (✅ Tracy dạy 07/08, áp cho mọi màn): *"nội dung nào quan trọng thì để to và dễ nhìn; thứ tự nhìn của người ta sẽ là to → màu nổi bật → ở trung tâm"*.

### 4.3. Hạ tầng kỹ thuật (tóm tắt)

Một file HTML tĩnh + Supabase (9 bảng, RLS từng dòng, đăng nhập Google OAuth, danh sách trắng email) · GitHub riêng tư → Cloudflare Workers tự phát hành khi đẩy `main` · chạy 0 đồng toàn tầng miễn phí · sao lưu bằng script tay trong pha xây. App đã chạy thật với 2 người dùng đầu (Tracy + Andy), **chưa mở cho cả đội 12 người**.

→ Chi tiết đầy đủ ở **mục 11–17** cuối file này.

---

## 5. HÌNH TƯỢNG KHU VƯỜN — tầng hình tượng hoá

### 5.1. Bộ ánh xạ hiện hành (✅ Tracy chốt 06/08, cập nhật 08–09/08)

| Trong vườn | Trong công việc |
|---|---|
| **Gieo hạt** | mở một cam kết (một ước muốn được tuyên bố công khai) |
| **Luống** (tối đa 3, CEO 5) | một cam kết đang chạy — "hết luống là hết đất", thu hoạch xong mới gieo tiếp |
| **Cây** (một task = một cây) | cây lớn theo TỔNG phút deepwork đổ vào task; nấc: Mầm 30′ · Cây non 60′ · Cây vững 120′ · Tán rộng 240′ |
| **Tưới cây** | phiên deepwork (*"deepwork là tưới cho cây lớn dần lên"* — nước là hành động, cây là kết quả; 10 phút = 1 quả nhỏ trong phiên) |
| **Quả chín** (🍎 luống 1 · 🍊 luống 2 · 🍇 luống 3) | task chuyển Done → cây ngừng lớn và ra quả mang màu của cam kết |
| **Thu hoạch cả luống 🧺** | đóng trọn một cam kết (nộp Output) |
| **Nhổ cỏ, chăm vườn hằng ngày** | các việc checklist lặp lại mỗi ngày |
| **Chậu lẻ** | việc phát sinh ngoài cam kết |
| **Héo** | duy nhất khi TỰ bấm bỏ cuộc — không bao giờ do rời app hay do thất bại |
| **Cỏ dại** khi bỏ bê | đã thiết kế, gác đợt 2 |
| **Khu vườn \<tên\>** / **Trang trại ROVA** | vườn cá nhân / bức tranh cả đội |

### 5.2. Trạng thái: lớp hiển thị vườn đang GÁC, triết lý thì KHÔNG

✅ 08/08 Tracy quyết định nguyên văn: *"tạm bỏ phần giao diện vườn đi nha, cái đó idea triết lý hay tôi sẽ bổ sung sau, bạn lưu lại cho tôi."* — Gác lớp HIỂN THỊ (giao diện nông trại) để dồn sức làm xong flow quản lý task, checklist, dashboard; **giữ nguyên toàn bộ cột dữ liệu và hàm vẽ** để bật lại. Trong app hiện còn giữ giọng vườn ở: nút 🌱 bắt đầu deepwork, quả 🍎🍊🍇 đánh dấu việc xong, **khung cảnh cây lớn dần trong màn deepwork** (thay vòng tiến độ), tab 🚜, tên app và slogan màn đăng nhập.

### 5.3. Hướng phát triển hình tượng Tracy đang ấp ủ (✅ lời Tracy 09/08 — chưa chốt thành thiết kế)

- Đổi các luống thành **loại quả cụ thể theo độ khó**: task cần deepwork 2–3 tiếng = quả trồng khó hơn, hiếm hơn → nhiều point hơn.
- **Point đổi thành tiền trong game hoặc quà thật của ROVA**; có **ranking, "best of…"** để kích thích sưu tập.
- Xây theo hướng game nông trại Stardew Valley: có nhiệm vụ, có tương tác, có ý nghĩa.
- ⚠️ **Lưu ý cho AI đọc:** ba ý trên đang CĂNG với một số nguyên lý đã nạp trong nền tri thức (thưởng to giết động lực nội tại · cấm xếp hạng cạnh tranh · điểm phải neo vào việc thật) — xem mục 9. Đây chính là vùng Tracy muốn tranh luận triết lý.

---

## 6. TẦNG TRIẾT LÝ NỀN — 4 cụm tri thức app đứng lên trên

*(Toàn bộ các cụm dưới đây đã được nạp nguyên văn vào "bộ não thứ hai" của Tracy — sách/deck đọc trọn, không phải trích dẫn qua trung gian.)*

### 6.1. Flow (Csikszentmihalyi) + Deep Work (Newport) — vì sao công việc CÓ THỂ là nguồn hạnh phúc

- **Nghịch lý công việc** — dữ kiện nền quan trọng nhất của app: đo bằng phương pháp lấy mẫu trải nghiệm, con người ở trạng thái flow **54% thời gian khi làm việc, chỉ 18% khi giải trí**; vô cảm thì ngược lại (16% ở việc, 52% lúc rảnh). Vậy mà người ta vẫn ước được nghỉ khi đang làm — vì chú ý bị đầu tư cho mục tiêu của người khác, cảm giác **"thời gian bị trừ khỏi sổ đời mình"**. Thuốc chữa: **trả lại quyền sở hữu mục tiêu**. → Triết lý lõi: app không "gamify để chịu đựng công việc"; app **trả công việc về đúng chỗ của nó — nguồn flow lớn nhất đời người** — bằng cách làm cho cam kết là CỦA người làm (tự hứa, tự đặt hạn), không phải KPI bị áp.
- **3 đòn bẩy gốc của niềm vui sâu:** mục tiêu rõ + phản hồi tức thì + thử thách khớp kỹ năng. Đây là bảng spec của mọi màn hình: cam kết = mục tiêu rõ; cây lớn/quả/chuông = phản hồi tức thì; nâng độ khó khi quen tay = giữ kênh flow.
- **"Hỗn loạn là trạng thái mặc định của tâm trí — trật tự phải được kiến tạo."** Cuộn màn hình là "trật tự đi mượn", không để lại gì; khu vườn là **trật tự tự xây**. Đây là câu trả lời triết học cho chữ "entropy" mà Tracy dùng.
- **"Bạn là tổng của những gì bạn chú ý"** (Gallagher) — trồng cây không chỉ đếm giờ; nó chọn thứ tâm trí bạn dựng thế giới từ đó. Và tinh thần người thợ (craftsmanship): *"không cần công việc hiếm có, cần một CÁCH LÀM hiếm có"* — kẻ đẽo đá phải luôn hình dung thánh đường.
- **Sản lượng = Thời gian × Cường độ tập trung**; tàn dư chú ý khi nhảy việc là lý do app đo giờ SÂU liền mạch chứ không đo giờ ngồi. Hình tượng đích đến: cụ bà Serafina 76 tuổi — hỏi "có tiền và thời gian vô hạn bà làm gì?", bà kể lại đúng những việc đang làm. **Người làm vườn không phân biệt việc với chơi.**

### 6.2. Kiến tạo cuộc chơi + Integrity + Speed of Light — tầng tổ chức

- **Kiến tạo cuộc chơi** (deck đào tạo nội bộ ROVA): *"KPI là điểm số. Kế hoạch là cách chơi. Quy trình, quy chế là luật chơi. Nhưng CUỘC CHƠI là bối cảnh khiến con người MUỐN bước vào hành động."* Lãnh đạo không giao việc — lãnh đạo kiến tạo bối cảnh để công việc HIỆN RA như một cuộc chơi đáng dấn thân (chuyện Schwab viết số 6 xuống sàn xưởng). Một cuộc chơi đủ **7 thành phần**: tương lai muốn tạo ra · lý do đáng chơi · người chơi · luật chơi · điểm số & thời gian · **cam kết trạng thái hiện hữu** (chơi để THẮNG + chơi để TẬN HƯỞNG — thứ phân biệt cuộc chơi với KPI) · nhịp chơi. Cuộc chơi **khai sinh bằng một lời tuyên bố** (speech act) — giống hệt việc gieo một cam kết. Cuộc chơi CHẾT khi: chỉ hô khẩu hiệu thiếu luật/điểm/nhịp · leader không tự chơi · áp từ trên xuống · đo sai điểm số. Và **thành thao túng** khi: bảng xếp hạng dùng để ép/bêu tên, người chơi không có quyền từ chối, điểm dùng để phạt thay vì để học.
- **Integrity** (Erhard–Jensen–Zaffron, "Integrity: A Positive Model"): integrity KHÔNG phải đạo đức — nó là hiện tượng khách quan như định luật vật lý: **trạng thái lời-nói-toàn-vẹn** (honoring your word). Chuỗi nhân quả: Integrity → Workability (tính vận hành được) → Performance. Giữ lời có HAI VẾ: làm đúng hạn, **HOẶC khi biết không giữ được thì báo ngay cho mọi bên + lập cam kết mới + dọn hậu quả** — làm đủ 3 bước này thậm chí tạo niềm tin LỚN HƠN cả giữ lời trơn tru. Hệ quả thiết kế đã ăn vào app: **app không phạt việc vỡ cam kết; app phạt sự IM LẶNG** (không có cửa thoát im lặng; cây héo chỉ khi tự bỏ). Integrity là "ngọn núi không có đỉnh" — không ai đạt 100%, biết vậy để bớt tự phán xét và tận hưởng việc leo.
- **Speed of Light** (Jensen Huang): đừng đo mình bằng năm ngoái hay bằng đối thủ — đo bằng **giới hạn vật lý**: "trong điều kiện lý tưởng tuyệt đối, việc này nhanh nhất là bao lâu?" Độ trễ = thực tế trừ lý tưởng; phần lớn độ trễ là **hàng chờ** (chuyện "36 giờ việc thật trong 3 tuần chuẩn ngành" — 19,5 ngày là chờ). Ranh giới an toàn đã ghi trong vault: đây là **thước soi HỆ THỐNG, không phải hạn giao cho người** — con số lý tưởng phải do chính người làm tự khai; câu hỏi tiếp theo là "cái gì đang chặn", không phải "sao chậm thế". Luật 3b của app chính là cơ chế chặn độ trễ dạng hàng chờ.

### 6.3. Game Kim Cương + Time Wizard (TriEye) — triết lý game đã chạy thật 154 ngày

- **Game Kim Cương** — hệ gamification thói quen theo nhóm (nhóm CEO Club 5 người, chạy thật 154 ngày, có tiền thật): mỗi ngày mỗi người nhận 1 trong 3 kết quả — **💎 kim cương** (làm trọn 100% ba thói quen quan trọng nhất) · **🪨 than** (dưới 100% nhưng CÓ báo cáo đúng hạn) · **💩** (không báo cáo). Hai luật triết lý nằm trong thang chấm: ① *"99% vẫn là Than"* — ngưỡng nhị phân tuyệt đối; ② **trễ báo cáo phạt nặng hơn làm dở** — *"game ưu tiên sự CÓ MẶT hơn thành tích"*, tức **game định giá integrity cao hơn thành tích — một tuyên ngôn bản thể ẩn trong luật chơi**. 💩 nghĩa gốc là "đứt lời với chính mình".
- **5 yếu tố xếp tầng** của người chơi hiệu quả (✅ Tracy chốt): Integrity (nền móng — có mặt, giữ lời) → Kỷ luật (làm trọn) → Kaizen (mỗi vòng tốt hơn một chút) → Đồng đội (sân chơi — "chỉ thứ được chấm điểm công khai mới sống") → Nhân dạng (la bàn — *"mỗi 💎 = một lá phiếu cho con người muốn trở thành"*).
- **Trả giá thay vì trừng phạt:** nhóm tự nhận "tiền phạt bào mòn động lực kém hơn trả giá bằng thân-tâm-trí" → nửa tiền phạt quy đổi thành hành động kiến tạo (chống đẩy 50 / chạy 5km / quay 1 video chia sẻ kiến thức). Khung nguyên văn: *"Tư duy cũ 'Phạm luật' → Tư duy mới 'Sự tiến hóa'"*. Có **Đệ nhị thân** — vòng chịu trách nhiệm chéo khép kín, ai rớt thì người đỡ đầu bị phạt theo.
- **Triết lý phân tích:** báo cáo game là *"phân tích hành vi tới Bản thể"* — dòng chảy data → hành vi → con người → gợi ý trở thành; dữ liệu để hiểu bản chất hành vi, **không phải để chấm ai giỏi hơn ai** — leaderboard luôn kèm góc "mỗi người đang chơi một trò khác nhau, ai cũng có hạng mục mình vô địch". Câu hỏi gốc của cả khung: *"mỗi hành động xuất phát từ TÌNH YÊU (kiến tạo) hay NỖI SỢ (né phạt)?"*
- **Time Wizard** (thương hiệu TriEye): *"Bạn không thiếu thời gian. Bạn đang thiếu bản đồ cuộc đời."* Nhìn cuộc đời như trò chơi với 5 khái niệm: **Người chơi** (phần tỉnh thức) · **Nhân vật** (con người hiện tại) · **Nhân dạng** (phiên bản mình chọn trở thành) · **Pháp** (phương pháp tiến hoá) · **Daily Quest** (nhiệm vụ nhỏ mỗi ngày). Thông điệp: *"Đừng sống như một NPC trong chính cuộc đời mình."* — Khu Vườn Tỉnh Thức là "Daily Quest engine" tự nhiên của hệ này.

### 6.4. Stardew Valley — hình mẫu game hoá (đã nghiên cứu sâu 2 vòng, có nguồn web xác thực)

- **Cốt truyện nền = thông điệp hiện sinh:** nhân vật ngồi trong ô cubicle tập đoàn Joja bị rút cạn sinh lực, mở lá thư ông nội để lại — lời mời thoát *"gánh nặng đời hiện đại"* về nuôi lại một nông trại, vì chính ông từng đánh mất *kết nối thật với con người và thiên nhiên*. Eric Barone làm game một mình 4,5 năm, 10 giờ/ngày, và nói mình *"chỉ làm game mà chính tôi muốn chơi"* — vô tình chạm đúng khát khao thời đại: thoát đời văn phòng vô nghĩa.
- **Đánh giá của ông nội (năm 3):** thang 21 điểm nhưng **12/21 là đủ điểm tuyệt đối (4 nến)**; 4/21 điểm là về tình thân chứ không phải tiền; **0 điểm vẫn được thắp 1 nến** — không tồn tại hình phạt; và bất cứ lúc nào cũng có thể đặt **một viên KIM CƯƠNG xin đánh giá lại** — thất bại không bao giờ vĩnh viễn. (Trùng hình tượng Game Kim Cương một cách đáng kinh ngạc.)
- **Ba vòng lặp thời gian + áp lực mềm:** ngày 14 phút (khan hiếm nhỏ mỗi ngày) · mùa 28 ngày (bộ cây riêng, lỡ thì "hẹn mùa sau" — không mất vĩnh viễn) · năm (nghi lễ tổng kết). Năng lượng hữu hạn ép ƯU TIÊN. Công thức cozy học thuật (Project Horseshoe): **Safety + Abundance + Softness** — an toàn (không đe doạ treo lơ lửng) + đủ đầy + mềm; cái giữ chân không phải hiểm nguy mà là **khan hiếm được thiết kế**, thất bại chỉ là "chi phí cơ hội nhẹ".
- **Cơ chế tạo ý nghĩa:** Community Center (gom bundle bằng sản vật từ ĐỦ MỌI hoạt động — mục lục việc-đáng-làm tự nguyện, cộng đồng thắng thương mại) đối lập JojaMart (trả tiền cho nhanh — tồn tại nhưng được khắc hoạ là lựa chọn nghèo nàn hơn); quan hệ dân làng đo bằng trái tim; lễ hội mùa; bảo tàng lưu di sản. Những hoạt động "phi hiệu quả" này mới là nguồn vui thật.
- **Đường cong tiến bộ:** tưới tay từng ô → sprinkler tự động 3 bậc theo cấp kỹ năng → dồn sức cho việc sâu hơn. Đây chính là đường cong của người quản lý: tự làm → SOP/uỷ quyền.
- **Cạm bẫy né được:** không điểm rỗng (mọi "điểm" quy về quan hệ/năng lực thật) · không leaderboard, không streak gãy-là-mất-hết · thưởng bằng **năng lực mở rộng** thay vì huy hiệu. Phê bình "optimizer trap": người chơi min-max bằng spreadsheet *"đã tối ưu hoá cuộc phiêu vu ra khỏi game"* — châm ngôn thiết kế: *cho cơ hội, người chơi sẽ tối ưu hoá niềm vui ra khỏi trò chơi*.
- **Định luật entropy của game** (⭐ trực giác của chính Tracy, đã dựng xương học thuật): *game đưa cho người chơi một mớ entropy để họ sắp xếp và giải quyết, bằng một loạt task dễ, tăng dần độ khó* — game nông trại là cỗ máy **entropy có kiểm soát**, "bán đúng thứ đời thật thiếu: entropy đã được ĐỊNH LIỀU". Và **la bàn của cả dự án**: *"Stardew bán entropy đã định liều trong một thế giới an toàn; Khu Vườn Tỉnh Thức bán đúng thứ đó — nhưng cây lớn bằng GIỜ LÀM VIỆC THẬT, nên càng mê càng không phải trốn đời. Đó là cú lật không game cozy nào làm được."* (⚠️ câu tổng hợp của AI trợ lý, Tracy chưa đóng dấu nhưng đã lưu trong wiki)
- Ba câu la bàn vận hành: ① mỗi ngày mở app phải THẤY vườn khác hôm qua · ② không trừng phạt, chỉ mời gọi — thất bại lớn nhất của app năng suất là làm người dùng SỢ mở app · ③ **"cơ chế giữ 3 tháng, câu chuyện giữ 3 năm."**

---

## 7. TÍNH NĂNG ĐANG CHẠY THẬT & TIẾN ĐỘ (09/08/2026)

**Đã chạy thật:** đăng nhập Google · màn Hôm nay (việc hôm nay + "còn nợ từ hôm trước" + nghi thức Chọn việc hôm nay từ kho) · tab Cam kết (3 bảng cam kết, kho task, 6 nhóm việc gập được, chế độ xem Cả ROVA) · màn Dọn việc hôm qua cưỡng chế luật 3b · deepwork trọn gói (đếm lên, ba cửa ra, chuông tỉnh thức, khung cảnh cây lớn dần) · khối tổng quan deepwork cá nhân (8 ô số + lưới ngày kiểu GitHub) · timeline ngày · việc lặp lại (nhịp ngày) · SQL tầng mục tiêu đã sẵn.

**Đang làm / chờ:** màn Mục tiêu cho leader (giao diện) · tính năng giao việc cho nhau · nền pixel art màn deepwork · gắn tên miền riêng, tắt bản Netlify cũ · **ngày mở cho đội 12 người chưa chốt** (✅ Tracy: *"bao giờ tôi xây xong flow quản lý task, phần checklist và dashboard, UI nữa thì mới public, hiện tại đang mới xong deepwork"*).

**Gác có chủ đích:** lớp giao diện nông trại (giữ triết lý + dữ liệu) · deepwork V2 (khôi phục phiên khi tải lại trang, chặn 2 phiên song song, lọc phiên rác…) · nối Google Calendar.

### 7b. Tab Việc cố định — chế độ CẢ ROVA (✅ chạy thật 10/08, mốc `0f5ad91`)

Nút lật **Của tôi ↔ Cả ROVA** ở đầu tab, cùng chỗ và cùng cách với `vuon-che-do` của tab Cam kết. Hai khung xem:

| Khung | Bày gì | Cột |
|---|---|---|
| **TUẦN** *(mặc định)* | 12 người × 7 ngày, ô vuông | `max-content` cho tên + 7 × `minmax(0,1fr)` + `max-content` |
| **4 TUẦN** | mỗi người MỘT biểu đồ đường, trục dọc 0→100% điểm ngày | 3 cột: tên · khung vẽ · số |

Bấm một hàng là **xổ chi tiết tuần của người đó** ngay dưới hàng — lưới 5 việc × 7 ngày, dùng chung hàm `luoiViec()` với bảng đo cá nhân.

**Ba mức chấm + ba ô trung tính.** Đủ cả 5 việc (`--rv-du`, sáng) · chưa đủ (`--rv-gan`, tối) · không báo cáo (`--vang`). Trung tính: **chưa tới giờ chốt** (viền đứt) · **chưa khai việc** (gạch chéo) · **Chủ nhật** (mờ). Ba màu của Sheet không phủ hết trạng thái thật: tô vàng cho hôm nay thì 9 giờ sáng cả đội hiện màu *không báo cáo*, còn người chưa khai việc thì không có gì để chấm — khác hẳn bỏ báo cáo.

**Không dựng dữ liệu mới.** `ket_qua_ngay` đã chấm sẵn 💎/🪨/💩 kèm `diem` (0→1, chính là `diem_ngay`), và `doc_nhip`/`doc_songay` đã cho thành viên đọc của nhau. **Hai truy vấn** cho cả bảng (`ket_qua_ngay` + `nhip`); phần chi tiết **chỉ tải khi bấm** vào một người — nạp sẵn 12 người là 24 truy vấn cho thứ người ta xem một.

⚠️ **`nhip` phải hỏi kèm, đừng bỏ.** Nó là thứ DUY NHẤT phân biệt *chưa khai việc* với *bỏ báo cáo*: người chưa khai thì `ket_qua_ngay` không sinh dòng nào cho họ, y hệt người khai rồi mà không chốt.

**Luật Nghỉ CN áp cho phần đếm của tab này** (một phần của việc 37): Chủ nhật không vào mẫu số, và Chủ nhật không chốt thì không tính là bỏ báo cáo — **nhưng ai làm Chủ nhật thì ô đó vẫn hiện đúng công đã làm**. Không phạt, cũng không giấu. *(Máy chủ thì vẫn chấm 💩 cho Chủ nhật không chốt — đây là luật ở lớp hiển thị. Việc 37 phần chuỗi 💎 ở chỗ khác vẫn chưa làm.)*

**Ba luật vẽ biểu đồ, mỗi luật chữa một chỗ dễ đọc sai:** ① Chủ nhật không có chấm nhưng đường vẫn nối qua — chấm 0 mỗi Chủ nhật thì tuần nào đường cũng cắm xuống đáy, đọc ra là *đều đặn hỏng* · ② tuần chưa khai việc thì đường **đứt hẳn**, nối liền qua đó là bịa ra một đoạn tiến bộ chưa từng xảy ra · ③ chấm chỉ nổi ở hai chỗ đáng nhìn (ngày trọn vẹn · ngày mất báo cáo), ngày thường là chấm nhỏ cùng màu đường.

💡 **Điểm và trạng thái là HAI thứ, không suy ra được từ nhau.** Có người điền đủ số mà quên bấm chốt ngày: điểm cao mà vẫn là 💩. Trên biểu đồ đó là **chấm vàng nằm cao trên đường** — ca đáng nói nhất, làm rồi mà đội không thấy. Vẽ màu suy từ điểm thì đúng ca này bị giấu.

📄 Bản mẫu chấm mắt (số giả, mở bằng trình duyệt): `production/tinh-thuc-app/mau-toan-rova-viec-co-dinh.html`.

**Data hành vi thật 3 ngày đầu (29 phiên, 2 người):** 14 phiên sống = 10 giờ deepwork; trung vị phiên sống 28 phút (bỏ khung 30′ đúng, nhưng người dùng vẫn tự rơi về ~30′ — "chỗ cần giúp không phải cái khung mà là sức chú ý"); cửa ra: 5 xong · 7 chưa xong · 2 nghẽn; 30 tiếng chuông; 13/29 phiên héo — giả thuyết: người dùng nhảy thẳng từ "đống task" sang "bấm deepwork", bỏ qua khúc QUYẾT ĐỊNH chọn việc.

---

## 8. BẢN CHẤT — đọc bằng một sơ đồ

```
ƯỚC MUỐN (hạt — thứ chưa có)
   │  tuyên bố công khai với cấp trên = GIEO (speech act — cuộc chơi khai sinh)
   ▼
CAM KẾT (luống — tối đa 3 · CEO 5, vài ngày → 1 tuần, có Output)
   │  chia nhỏ = trồng CÂY (task ngồi một buổi là xong)
   ▼
CHÚ Ý MỖI NGÀY (tưới = deepwork đo giờ thật · nhổ cỏ = checklist lặp lại)
   │  cây lớn bằng giờ thật — không tưới thì không lớn, nhưng không chết vì nghỉ
   ▼
QUẢ (task Done) → THU HOẠCH LUỐNG (cam kết Done = hiện thực sờ được)
   │  ba cửa ra + phất cờ sớm khi trễ = INTEGRITY được giữ và phục hồi
   ▼
ĐẤT TỐT LÊN (niềm tin, năng lực, tốc độ — Integrity → Workability → Performance)
   └──> có chỗ gieo ước muốn LỚN HƠN (kênh flow: nâng thử thách theo kỹ năng)
```

App là một **cỗ máy chuyển hóa**: entropy → trật tự · ước muốn → hiện thực · lời nói → sự thật · thời gian bị trừ khỏi sổ đời → thời gian được cộng vào sổ đời.

---

## 9. ĐIỂM CĂNG & CÂU HỎI MỞ — nơi cần tranh luận triết lý

1. **⚡ Point → tiền/quà thật + ranking/sưu tập (ý Tracy 09/08) vs bộ nguyên lý đã nạp.** Nguồn trong vault nói: thưởng NHỎ nuôi động lực, thưởng TO giết nó (Toyota thưởng trung bình 3,88 đô mà có 1,5 triệu góp ý/năm; Deming) · overjustification effect — điểm gắn task hiếm khi tăng năng suất quá vài ngày · Stardew không có leaderboard, điểm luôn neo vào năng lực/quan hệ thật · deck Kiến tạo cuộc chơi: xếp hạng để ép/bêu tên là lằn ranh thao túng · danh sách "7 điều KHÔNG được làm" (⚠️ AI đề xuất, chưa duyệt) có: cấm xếp hạng cạnh tranh, cấm thưởng tiền theo điểm vườn. NHƯNG Game Kim Cương lại dùng tiền thật thành công — với vai trò **trả giá skin-in-the-game trong nhóm tự nguyện**, không phải thưởng-theo-điểm. Câu hỏi mở: thiết kế kinh tế điểm thế nào để kích thích sưu tập mà không giết động lực nội tại?
2. **Quả đang mang hai nghĩa** (10 phút deepwork = 1 quả trong phiên · task Done = quả chín theo luống) — đã nêu đề xuất phân biệt bằng độ chín, Tracy chưa ưng bản nhạt.
3. **Hai bảng vinh danh giữ hay gác** khi lớp vườn đang gác — và dữ kiện mới: bảng 💧 đang bỏ sót trọn lớp việc giao tiếp/trao đổi (không cần deepwork).
4. **Cân bằng "phạt sự im lặng" với "không trừng phạt, chỉ mời gọi"** — luật 3b chặn cứng màn hình có đứng được lâu dài không khi đội 12 người dùng thật?
5. **Nghi thức "phất cờ sớm"** (báo trước khi trễ được TÔN VINH — vế 2 của honoring your word) mới nằm ở tầng ý tưởng wiki (⚠️), chưa thành cơ chế app.
6. **Họp làng hằng tuần** — nguồn (Gerber) khẳng định cuộc chơi chết nếu thiếu nhịp người thật; app không thay được. ROVA chưa chốt nhịp này.
7. Vòng lặp mùa/quý (28 ngày · 90 ngày), lễ mùa gặt, "Community Center của đội", lá thư mở đầu — đều đang ở tầng đề xuất (⚠️), chưa có trong app.

---

## 10. TỪ VỰNG NHANH (để nói chuyện với Tracy không lệch nghĩa)

| Từ | Nghĩa trong hệ này |
|---|---|
| **Cam kết** | kết quả cá nhân hứa với cấp trên, vài ngày–1 tuần, có Output; KHÔNG phải "task lớn" |
| **Deepwork** | phiên tập trung đo giờ thật có nghi thức vào/ra; không phải mọi giờ làm việc |
| **Tưới cây** | làm deepwork cho một task |
| **Ba cửa ra** | Xong / Chưa xong / Nghẽn — bắt buộc chọn khi kết phiên |
| **Chuông tỉnh thức** | lần nhận ra mình xao nhãng và QUAY VỀ — điểm cộng |
| **Luật 3b** | không task nào quá 1 ngày mà không đổi trạng thái |
| **Hết luống là hết đất** | trần cứng 3 cam kết đồng thời, riêng CEO 5 (`nguoi.so_cam_ket_toi_da`) |
| **Phất cờ** | báo sớm khi biết sẽ trễ — hành vi được tôn vinh (integrity vế 2) |
| **Integrity** | lời-nói-toàn-vẹn (hiện tượng khách quan), không phải đạo đức |
| **Speed of Light** | đo việc bằng giới hạn lý tưởng, soi độ trễ của HỆ THỐNG |
| **Entropy định liều** | thứ game nông trại bán: hỗn loạn vừa đủ để dọn và thấy trật tự ngay |
| **Tỉnh thức** | (trong tên app) tánh biết quay về hiện tại; đồng thời là tên nhóm Lark cũ của đội |

---

# TẦNG KỸ THUẬT — đọc khi sắp SỬA app

> Mục 11–17 gộp vào đây ngày **09/08/2026**, rút từ 61 mục nhật ký thiết kế của hồ sơ G-01. Trước đó những sự thật này nằm rải trong nhật ký, nên mỗi lần sửa app phải đọc lại cả tháng làm việc mới dám sửa.

## 11. HẠ TẦNG VÀ ĐỊA CHỈ

| Thứ | Giá trị |
|---|---|
| Địa chỉ app thật | `https://rovatinhthuc.tranmaitrang-hup.workers.dev` ✅ |
| Kho mã | GitHub **riêng tư** `tranmaitranghup-star/khu-vuon-tinh-thuc`, nhánh `main` |
| Nền chạy | Cloudflare Workers — đẩy `main` là tự phát hành sau ~36–60 giây, không tốn credit |
| Thư mục ra web | **chỉ `public/`** (khai trong `wrangler.jsonc`). Mọi file `.sql` và `.md` nằm ngoài `public/` nên không ra web ✅ |
| Cơ sở dữ liệu | Supabase project **ROVA**, ref `bgstlkeplgluppmdknci`, gói Free |
| Đăng nhập | Google OAuth + danh sách trắng email trong bảng `nguoi`. Client tạo trong project Google `tracy-claude-drive` ⚠️ *nên tách project riêng sau* |
| Chạy thử tại máy | `python3 -m http.server 8080` trong `production/tinh-thuc-app` (đã khai trong `.claude/launch.json`). Phải thêm `http://localhost:8080/**` vào Supabase → Authentication → Redirect URLs |
| Sao lưu | `../tinh-thuc-backup/sao-luu.py` — kéo 8 bảng về `raw/tinh-thuc-backup/YYYY-MM-DD/`. **Chạy tay.** Supabase Free **không giữ bản dự phòng nào** 🔴 |

**Còn một bản cũ đang hở:** `rovatinhthuc.netlify.app` vẫn để tải được `schema.sql` có email thật của đội.

**Đổi sang tên miền riêng thì đúng ba bước, thiếu bước ② là đăng nhập gãy:**
1. Cloudflare → Workers & Pages → `rovatinhthuc` → Settings → Domains & Routes → Add Custom Domain.
2. **Supabase → Authentication → URL Configuration: thêm tên miền mới vào Site URL và Redirect URLs** (app dùng `redirectTo: location.origin`).
3. Nếu tắt `workers.dev` thì phải ghi `workers_dev = false` vào `wrangler.jsonc` — tắt ở bảng điều khiển mà không ghi vào file thì lần phát hành sau nó bật lại.

*Google Cloud Console không phải sửa* — Google trả về địa chỉ callback của Supabase, không trả về app.

## 12. FILE TRONG KHO

| File | Vai |
|---|---|
| `public/index.html` | **Toàn bộ app trong một file** (~250 KB, hơn 3.000 dòng script) |
| `public/_headers` | `/vendor/*` giữ bộ nhớ đệm một năm; `index.html` cố ý không khai để bản mới tới tay đội ngay sau khi đẩy |
| `public/vendor/` | supabase-js 2.112.2 + 5 tệp font Montserrat. **0 tên miền ngoài** |
| `schema.sql` | Lược đồ gốc |
| `nang-cap-*.sql` · `va-*.sql` | Từng đợt nâng cấp và vá, chạy tay trên Supabase SQL Editor |
| `thu-man-don.js` | 20 phép thử logic màn Dọn, tách khỏi app, **20/20 đạt**, không cần đăng nhập |
| `mau-*.html` | Bản mẫu để Tracy chấm trước khi gắn vào app. **Nằm ngoài `public/` nên không ra web** |
| `soi-app-20-phat-hien.md` | Kết quả đợt soi 5 lăng kính ngày 08/08 |

**Nếp làm việc đã thành luật:** ra bản mẫu `mau-*.html` trước → Tracy chấm → mới gắn vào `public/index.html`.

## 13. CẤU TRÚC DỮ LIỆU

**9 bảng:** `nguoi` · `tieu_diem` *(chính là **cam kết** — tên bảng cố ý giữ nguyên, chỉ đổi chữ hiển thị)* · `danh_muc_nhip` · `nhip` · `so_ngay` · `nop_ngay` · `task` · `phien_deepwork` · `tieng_chuong`. Thêm `muc_tieu` đã dựng nhưng **app chưa có giao diện dùng**.

**Bảng `task`** — 15 cột, app chỉ đọc **9 cột** qua hằng `COT_TASK`. Task có **8 trạng thái**; `Da_huy` và `Da_chuyen` là *đã đóng nhưng không phải hoàn thành* — mọi chỗ đếm phải dùng chung danh sách `TT_MO`, đừng viết lại điều kiện.

Cột sinh ra từ luật 3b: `ghi_chu_chot` · `chot_luc` (phân biệt người chốt với máy đoán) · `ngay_hen_dau` (bất biến, nay chỉ để biết tuổi việc) · `task_cha` · `so_lan_hoan`.

⚠️ **`nguoi_tick` là cột thừa** — từ 06/08 policy đã siết `nguoi_id = nguoi_id_dang_nhap()` nên nó luôn bằng `nguoi_id`. Đã sửa ghi chú, **chưa gỡ cột**.

**`task.ngay` cho phép rỗng** = việc nằm trong **kho** của cam kết. Nhưng `default hom_nay()` giữ nguyên để mọi đường thêm task cũ không đổi hành vi.

**Khung nhìn đang dùng:** `viec_con_no` (cờ `het_cua_hen_ngay`) · `tien_do_o` · `dem_task_theo_o` (trần thật 324 dòng) · `gio_deepwork_theo_ngay` · `dem_cam_ket_da_dong` (tối đa 12 dòng) · `vuon_cay` (tích luỹ vĩnh viễn) · `diem_ngay` · `ket_qua_ngay` · `nhip_thoi_gian`.

⚠️ **`cham_theo_ngay` có hai bản trong kho** (một chặn 30 phút, một chặn 120) và cả hai đều khác `phutPhien()` bên app → **không dùng khung nhìn này**.

**Luật nghiệp vụ mục 4.2 chưa nêu:**
- **Luật cha–con:** cha đóng thì con **thay** cha (chia nhỏ, đổi hướng) · cha còn sống thì con **đứng cạnh** (gỡ nghẽn). *Huỷ* thu về đúng một nghĩa: dừng hẳn, không con.
- **Trần hoãn 3 lần** — quá trần thì **không được để người ta chỉ còn đúng một cửa là Huỷ**; nút một tự thành 📦 *Về kho*. Đặt hạn ở bảng kho là cửa duy nhất đưa `so_lan_hoan` về 0.
- **Kho việc:** việc đã hẹn ngày thì cả đội đọc được; việc còn trong kho thì chỉ chủ đọc được. Ranh giới: hẹn ngày = đã nhận làm nên công khai được.
- **Luật chuỗi ngày:** hai bản — *Full tuần* (mọi ngày lịch) và *Nghỉ CN* (chỉ Chủ nhật được tha; **thứ Bảy vẫn là ngày làm**, bỏ thứ Bảy là đứt chuỗi) ✅ Tracy chốt 09/08.

## 14. NGƯỠNG SỐ — đổi một chỗ phải soi chỗ kia

| Ngưỡng | Giá trị | Ghi chú |
|---|---|---|
| Cam kết đang chạy mỗi người | **3** | Chặn cứng ở tầng dữ liệu |
| Phiên deepwork | sàn **5 phút** · trần **120 phút** | |
| Ngưỡng "cây héo" trong `vuon_cay` | **40 phút** | 🔴 **Đá nhau với trần 120 phút.** Chưa xử |
| Quả trong phiên | **10 phút = 1 quả** → tối đa 12 quả | |
| Nấc cây `NAC` | **30 · 60 · 120 · 240 phút** | Cũng là thang đậm nhạt của lưới Tổng quan |
| `TRAN_MAY_CHU` | **2000**, khai ở `index.html` **dòng 1695** | Phải đổi đồng thời với *Max rows* bên Supabase; để lệch là chuông báo hỏng hai chiều |
| Trần hoãn một task | **3 lần** (cột `so_lan_hoan`) | |
| Khối "Đã hoàn thành" chế độ đội | cửa sổ **90 ngày**, `.limit(60)` | Có báo khi chạm trần |
| Màn logo | sàn **620ms**, trần **6 giây** | |
| Kích thước task | **nửa giờ tới hai giờ** — một tới hai phiên tập trung | Không ước lượng nổi thì còn quá to, chia nhỏ tiếp. *(Đổi 11/08: bỏ cách nói "1–4 block × 30 phút" cho khớp deepwork đếm xuôi từ 06/08)* |
| Màu neo | `--xanh #258c86` · tầng cam kết tím `#b98cdd` | Đỏ dành riêng cho nút Bỏ cuộc |

**Sức chịu tải đã soi:** 12 người × 1 năm ≈ 105.000 dòng, ~21 MB. Phải tới ~1,2 triệu dòng mới chạm trần 500 MB, tức khoảng 14 năm. **Nút thắt nằm trong mã app, không nằm ở máy chủ.**

## 15. LUẬT KỸ THUẬT — đã trả giá thật, đừng tái phạm

- **Một đợt truy vấn mỗi tab.** Thêm truy vấn mới thì thêm vào mảng `Promise.all` có sẵn, đừng viết `await` riêng bên dưới — mỗi `await` nối tiếp là một lượt chờ cộng vào thời gian mở app. Hiện **cả 5 tab đều đúng 1 đợt**.
- **Đếm ở máy chủ.** Đừng kéo dòng về chỉ để đếm, đừng kéo lịch sử màn hình không hiện — gộp sẵn bằng khung nhìn Postgres. *"Trần chỉ dời ngày vỡ, bỏ mới là hết vỡ."*
- **Im lặng là nói dối.** Mọi lần dữ liệu bị chặn ở trần phải báo ra. Nhưng chỉ báo khi **máy chủ** chặn, không báo với trần app tự đặt — kêu mãi thì người ta thôi đọc.
- **`create or replace view` chỉ cho thêm cột vào cuối.** Đổi thứ tự cột phải `drop view` rồi tạo lại.
- **File SQL đưa người khác chạy: chỉ được có đúng MỘT câu `select` ở cuối** — Supabase SQL Editor chỉ hiện bảng của lệnh cuối.
- **RLS:** không dùng `for all`, tách policy hẹp. Luôn kèm bộ tự kiểm **và thử phá thật** — tự kiểm chỉ trả lời *"ràng buộc có tồn tại không"*, đó là câu hỏi khác với *"nó có chặn thật không"*.
- **Giờ Việt Nam:** mọi bộ lọc theo ngày khai thẳng `+07:00` (`dauNgayVN()` / `cuoiNgayVN()`), không trông vào máy chủ đoán múi giờ.
- **`vendor/`:** tệp phải mang số bản trong tên (vì bộ nhớ đệm một năm) và phải trỏ bằng đường dẫn **tuyệt đối** `/vendor/...` — đường dẫn tương đối bị lớp dự phòng của app nuốt thành màn đen câm.
- **Commit nêu đích danh file, cấm `git add -A`** — thủ phạm của cả hai lần file nháp lạc vào kho.
- **`node --check` không bắt được hàm thiếu định nghĩa** (đó là lỗi lúc chạy) — phải có phép quét riêng dò hàm gọi từ thuộc tính `on*`.
- **Ảnh chụp từ khung xem không phải bằng chứng** — phải hỏi trang xem nó đang chạy cái gì.
- **Hai phiên cùng sửa một file:** giao mỗi phiên một vùng riêng ngay từ đầu; chia trước rẻ hơn gỡ sau.
- **AI không chạy được SQL** — cổng REST không nhận lệnh đổi lược đồ, máy không có `psql` cũng không có `supabase` CLI. Mọi file SQL phải để Tracy tự dán vào SQL Editor.
- **Font:** Poppins và Outfit **không có bộ dấu tiếng Việt**. Montserrat rộng hơn font hệ thống +24% — đổi chữ trong ô nhập thì phải đo bề rộng thật ở khổ hẹp nhất (375px). Chỗ nào hiện số cũng phải khai `tabular-nums`.
- **Điều khiển tự vẽ:** thay điều khiển gốc của trình duyệt thì **giữ ô thật ẩn phía sau**, để vẫn dùng được bàn phím và bảng chọn hệ điều hành.
- **Khoảng trắng:** vạch kẻ nói *"chỗ này hết"*, khoảng trắng mới nói *"khối sau là chuyện khác"* — 46px giữa hai tầng · 22px giữa hai nhóm có nội dung · 8px giữa hai nhóm đang thu · 26px trước ô thêm việc.

## 16. ĐANG HỞ — chưa làm, chưa chạy

> ⚠️ **ĐÃ SOI LẠI BẰNG MÃ NGÀY 28/08 — năm trong sáu mục dưới đây đã CHẾT.** Danh sách này viết trước
> đợt vá 14/08 và không ai cập nhật, nên ngày 28/08 nó khiến tôi báo Tracy bốn lỗi "đang cắn" mà ba đã
> sửa từ hai tuần trước. Tracy duyệt một phạm vi dựa trên thông tin sai.
>
> **LUẬT rút ra: một mục trong danh sách này là GIẢ THUYẾT, không phải kết luận.** Trước khi báo bất kỳ
> mục nào là lỗi đang sống, phải soi mã xác nhận. Chỗ nào soi rồi thì ghi ngày và bằng chứng, như dưới.

- ~~❓ `nang-cap-gio-vang.sql` chưa chạy → ô GIỜ VÀNG hiện dấu `—`~~ → **SAI (soi 28/08).** Khung nhìn
  `gio_deepwork_theo_gio` **có trên máy chủ** — `nang-cap-tran-180-phut.sql` chứa sẵn nó, nên tệp
  `gio-vang` không cần chạy. Xác nhận bằng `SO-SQL.sql` khối ②.
- ~~🔴 Ngưỡng héo 40 phút đá nhau với trần phiên 120 phút~~ → **SAI (soi 28/08).** Trần nay là **180**
  và đã sống trên cả ba khung nhìn (`SO-SQL.sql` khối ②). Luật 40 phút chỉ còn trong `schema.sql:244`,
  mà bản `vuon_cay` ấy đã bị viết đè từ lâu. Cơ chế thay thế là im lặng nhịp tim 5 phút.
- ~~🔴 App không khôi phục phiên khi tải lại trang~~ → **SAI (soi 28/08).** `dwKhoiPhuc` chạy ở cuối
  `khoiDongThat`, cộng hai đường nữa: `visibilitychange` khi quay lại tab, và lúc bấm ▶ mà đã có phiên.
  Đồng hồ nối theo mốc `bat_dau` của máy chủ, không tin đồng hồ máy.
- ~~🔴 Một người mở được hai phiên cùng lúc~~ → **SAI (soi 28/08).** Máy khách chặn hai lớp, và
  `uq_phien_dang_chay` **đã có trên máy chủ** (xác nhận `SO-SQL.sql`). Đây là chốt tận gốc.
- 🟠 **Chuông bấm dồn không bị chặn** — một phiên có 7 tiếng trong 2 giây. → **CÒN THẬT (soi 28/08).**
  `dwChuongBam@11702` không có phanh nào giữa hai cú bấm liền nhau: mỗi cú đẩy một dòng vào
  `tieng_chuong` và nở thêm một bông hoa. Đây là mục **duy nhất** trong sáu mục còn sống.
- ~~🟡 7 phiên héo dưới một phút làm rác thống kê~~ → **SAI (soi 28/08).** Cả năm khung nhìn máy chủ đều
  lọc `ket_qua = 'song'`, và máy khách cũng lọc đúng thế (`TK_PHIEN@17353`). Phiên héo nằm trong bảng
  nhưng không lọt vào con số nào app bày ra.
- **Chưa giữ được:** chọn *Chưa xong* hay *Chưa làm* rồi bấm Làm tiếp thì task về `Confirm` ngay, phân biệt hai ô đó không đọng lại đâu để đếm về sau.
- **Tầng mục tiêu:** bảng `muc_tieu` đã có, **giao diện chưa có**.
- **Giao việc cho nhau:** đã gật nguyên lý (cây mọc trên vườn người làm · người nhận tự chọn cam kết · mọi lần sửa để lại dấu vết), **chưa code**.
- **Bốn hàm `veLuong*`** của lớp khu vườn không ai gọi, vẫn đọc `CAY` kiểu cũ. Bật lại lớp vườn thì phải gộp sẵn ở máy chủ trước.
- **Luật 3b chưa ai dùng thật ngày nào** — cần một vòng dùng thật rồi soi lại số.
- **Màn chọn task còn vòng tròn tiến độ đứng yên ở 0%** — chưa gỡ.
- ⚠️ Nhánh **`dem-o-may-chu-cho-ghep`** chỉ để tra nội dung, **đừng gộp thẳng** (thiếu `DON_HD`).

## 16b. ĐÃ DUYỆT — CHỜ DỰNG (Tracy chốt 10/08)

> Hai thay đổi lớn Tracy duyệt chiều 10/08, chưa viết dòng mã nào. Đây là đặc tả; hồ sơ `G-01` chỉ giữ một dòng trỏ về đây.

### A. Tab Timeline đổi thành tab DEEP WORK

Tracy: *"đổi mục timeline thành mục Deep Work… vẫn có timeline nhưng để ở cuối"*, và dashboard phải có **cả phần của từng người lẫn phần toàn ROVA**.

Kết cấu chốt, từ trên xuống:

1. **Công tắc *Tôi / Cả ROVA*** — dùng lại đúng cơ chế `vuonDoiCheDo()` của tab Cam kết, không đẻ mô hình mới.
2. **8 ô nhịp, tách thành hai hàng có tên** — hàng *đang*: chuỗi đang giữ · 7 ngày gần nhất · trung bình mỗi ngày · giờ vàng. Hàng *cả hành trình*: tổng giờ · số phiên · số ngày có mặt · kỷ lục. Lý do tách: tám ô hiện trộn hai khung thời gian trong một lưới, mắt không phân được cái nào là bây giờ.
3. **Lưới ngày + câu tổng kết giờ** — giữ nguyên.
4. **Dải giờ trong ngày (timeline cũ) xuống ĐÁY.**

Kèm theo:

- **Bảng 💧 Giờ tập trung DỜI khỏi tab ROVA** sang đây, vào lớp *Cả ROVA*. Tab ROVA sau đó chỉ còn chuyện con người: kết quả trong ngày + việc cố định toàn ROVA.
- **Lớp toàn ROVA hiện theo NHỊP, không xếp hạng người** — Tracy: *"quan trọng nhất là giữ nhịp cho doanh nghiệp"*. Khớp luật đã ghi trong mã: *gương soi, không phải bảng so người với người*.
- ⚠️ **Bỏ chữ "đội" khỏi giao diện** — gọi là **doanh nghiệp** hoặc **cả ROVA**. Áp cho mọi chữ mới; chữ cũ sửa dần khi chạm tới.
- 🔴 **Chặn kỹ thuật phải gỡ TRƯỚC:** hai màn đang đếm giờ bằng hai khung nhìn khác nghĩa — khối cá nhân đọc `gio_deepwork_theo_ngay` (trần 120 phút), bảng 💧 đọc `cham_theo_ngay` (kho có hai bản lệch nhau). Hôm nay hai số ở hai tab nên không ai bắt được; gom về một tab là chúng nằm cạnh nhau. Quy về một nguồn trước khi dựng.
- ⚠️ **Lớp CSS `.tq-so` đang dùng chung** với `#vcd-so` của tab Việc cố định. Đổi lưới 8 ô thì tạo lớp riêng, đừng sửa lớp chung.
- ⬜ Chưa chốt: khi bật *Cả ROVA* thì dải giờ trong ngày ẩn hay vẫn hiện *(đề nghị: ẩn — dải giờ chỉ có nghĩa với một người)*.

### B. Nút CHỐT NGÀY đổi thành NGHI THỨC HOÀN THÀNH

Tracy: *"chốt ngày đổi là nghi thức Hoàn thành được đó, không chỉ là hoàn thành checklist mà còn hoàn thành các task luôn, hoàn thành ở đây là đổi hết được trạng thái ấy"*.

Chữ *hoàn thành* dùng theo nghĩa **Integrity**, không phải nghĩa thông thường: đóng vòng bằng cách giữ lời, hoặc tuyên bố không giữ rồi dọn hậu quả (xem [[khoi-phuc-integrity]] tr.48 — bỏ phải thành lời, không bỏ im lặng). Nó lấp tầng còn hở của app: phiên đã có ba cửa, tuần đã có tiêu chí done, riêng **ngày** thì chưa có cửa đóng.

Đã chốt:

- ✅ **Một ngày có hai cửa — mở và đóng.** Luật 3b lùi từ *cửa chặn buổi sáng* xuống **lưới an toàn**: màn 🧹 Dọn việc hôm qua chỉ bật khi tối hôm trước KHÔNG chạy nghi thức. Tối đã kết sổ mà sáng vẫn bắt dọn lại là làm hai lần, và người ta sẽ bỏ nghi thức tối.
- ✅ **Bộ lối ra dùng lại đúng 5 lối của màn dọn**, không đẻ bộ mới: xong · dời sang mai · về kho · Miss (thừa nhận lỡ) · tuyên bố không làm.
- ✅ **Điểm ngày VẪN tính cả task** (Tracy quyết, ngược đề nghị ban đầu của tôi là chỉ tính việc cố định) — kèm yêu cầu tìm công thức chấm khách quan và chống gian. Xem việc 45 ở `G-01`.
- ⬜ **Chưa trả lời:** nghi thức chạy ở đâu — một màn riêng đối xứng với màn dọn buổi sáng, hay giữ trong thẻ Việc cố định *(đề nghị: màn riêng, mở bằng nút ở đáy tab Hôm nay; nút hiện tại nằm trong thẻ Việc cố định nhưng nghi thức mới bao cả task nên không thuộc thẻ nào)*. Hỏi lần 1 ngày 10/08.
- Chữ trên nút giữ *Hoàn thành*, nhưng phải có dòng dạy nghĩa ngay dưới: *"Đóng từng việc: xong, dời, hay tuyên bố không làm"*. Không có dòng đó thì người làm được ít sẽ ngại bấm — đúng những tối cần nghi thức nhất.

## 17. NGHĨA ĐỊA — đã bị thay, đừng dựng lại

> Mục này quan trọng ngang phần đặc tả. Không có nó, phiên sau đọc nhật ký cũ rồi dựng lại đúng thứ đã bỏ.

**Hạ tầng**
- Netlify → **Cloudflare Workers** (06/08). Luật *"gom nhiều sửa rồi kéo lên một lần"* và trần 20 lượt mỗi tháng **hết hiệu lực** — đẩy bao nhiêu lần cũng 0 đồng.
- Địa chỉ `rovatinhthuc.pages.dev` → thực tế là **`…workers.dev`**.

**Mô hình việc**
- Trần **3 đêm** tính từ `ngay_hen_dau` → trần **3 lần hoãn** qua `so_lan_hoan` (08/08).
- Cột `cha_id` → **`task_cha`** (cột cũ đã gỡ). Cờ `het_cua_lam_tiep` → **`het_cua_hen_ngay`**.
- **Máy phân biệt Miss với Chưa xong bằng "có phiên deepwork hay không"** → **bỏ hẳn** (08/08). Có cả một lớp việc giao tiếp không cần deepwork, suy như vậy là suy ngược.
- Nút *Về kho* và *Chia nhỏ* ở câu 2 màn Dọn → bỏ (ô ngày trống chính là về kho).
- `select('*')` → hằng **`COT_TASK`** 9 cột.

**Deepwork**
- Khung **30 phút cố định** → **phiên tự do**, đồng hồ đếm lên (06/08).
- Chế độ 🔒 *Tập trung sâu* và luật *"rời trang là phiên mất trắng"* → **bỏ hẳn** (07/08). Cột `tap_trung_sau` giữ lại để dữ liệu cũ không gãy.
- **Mỗi phút một lá** → **10 phút một quả**. Biểu tượng 💧 ở tầng sống → **cây** (💧 vẫn giữ ở tầng đếm).
- Vòng tiến độ 240px → **"Đồng hồ là màn hình"**.
- Bốn cửa ra → **ba cửa ra** (Tracy bỏ cửa *chia nhỏ*).

**Giao diện**
- **Lớp hiển thị vườn/nông trại** → **gác lại** (08/08), thay bằng ba bảng cam kết. Triết lý và **toàn bộ cột dữ liệu giữ nguyên** (`qua`, `mau`, `ten_loai`) để bật lại sau.
- Bốn ô cũ tab Timeline và dải nút lọc kỳ → **bỏ hẳn**, thay bằng 8 ô Tổng quan (09/08).
- Việc xong **gạch ngang** → chỉ **lùi màu** (*"gạch nhìn rối lắm"*).
- Nhãn *"Xong khi:"* → **"Tiêu chí done:"** ở mọi chỗ (09/08).
- Ô `dd/mm/yyyy` → **nút "Deadline"** ở mọi form.
- `vuon_cay` ở chế độ Cả ROVA → **bỏ hẳn** (khung nhìn tích luỹ vĩnh viễn, chạm trần sau ~6 tuần).
- Khối *"việc phát sinh"* trong tab Cam kết → **gỡ bỏ** (tự mâu thuẫn với định nghĩa việc phát sinh).
- Phương án *"bảng đội"* (một hàng một người) → Tracy bác, giữ kiểu **thẻ**.

**Tổ chức**
- Ba luống **dùng chung cả đội** → mỗi người ba luống riêng (06/08). Chỉ mục `mot_hat_moi_luong on (luong)` → **`mot_hat_song_moi_luong on (nguoi_id, luong)`**.
- *"Cả đội ai cũng tick được"* → **chỉ chủ cam kết** (06/08). ⚠️ Ghi chú `nang-cap-khu-vuon.sql:44` từng ghi sai điều này, đã sửa 09/08.
- 10 tiêu điểm chung công ty O1–O10 → **3 cam kết cá nhân**.
- Nhãn *"tiêu điểm O"* → **"Cam kết của bạn"**. Tên bảng `tieu_diem` **cố ý giữ nguyên**.
- Chu kỳ cam kết **một tháng** → **một tuần** (05/08).
- Tầng 4 gọi là *KA* → gọi thẳng là **Task** (05/08).

- Trần **3 cam kết cho tất cả** → **trần riêng từng người** (11/08): mặc định 3, **CEO 5**, M-level và nhân sự giữ 3. Con số thôi nằm cứng trong mã, nay là cột `nguoi.so_cam_ket_toi_da` — nâng cho ai chỉ sửa một số. Ràng buộc máy chủ nới thành `luong between 1 and 5`, và trigger `kiem_tran_cam_ket` chặn ngồi quá trần của chính mình. Cố ý **không** đọc theo `nguoi.vai = 'CEO'`: seed ghi *"chức vụ tạm bỏ đi"* nên cột đó có thể rỗng, khoá luật vào nó là luật tự tắt mà không báo gì. File: `nang-cap-cam-ket-5-cua-ceo.sql`.
- Kích thước task *"1–4 block × 30 phút"* → **"ngồi một buổi là xong, nửa giờ tới hai giờ"** (11/08). Chữ "block" là vết còn lại của bản thiết kế 05/08; deepwork đã đếm xuôi theo giờ thật từ 06/08. Đã đổi ở mục 4.1, sơ đồ mục 9, bảng ngưỡng mục 14, và bài giới thiệu coreteam.

**Còn mâu thuẫn, chưa ai gỡ**
- ⚠️ **Sheet *ROVA Tỉnh thức* 12 tab + Apps Script sinh tuần vẫn chạy tự động sáng thứ Hai**, trong khi đội đang chuyển sang app. Chưa thấy lệnh dừng — có nguy cơ hai hệ song song.
- ❓ **Ranh giới ClickUp ↔ app Khu Vườn** chưa ai tuyên bố. KR2 *"đưa dự án lên ClickUp"* vẫn nằm trong OKR quý và vẫn quá hạn.
