# HỒ SƠ TOÀN CẢNH — KHU VƯỜN TỈNH THỨC

> **Cửa vào cho người mới và cho tác tử.** Đọc file này là hiểu app đang làm gì, vì sao làm thế, đang chạy tới đâu, và chỗ nào không được đụng vào.
>
> Viết lại **06/09/2026** trên số đo thật của bản sao dữ liệu 05/09 và mã trên `origin/main`. Bản cũ (mốc 09–10/08) lưu ở `luu-tru/ho-so-khu-vuon-cu-2026-09-06.md`.
>
> **Phần I** đọc để hiểu. **Phần II** đọc khi sắp sửa mã — trong đó mục *Nghĩa địa* quan trọng ngang phần đặc tả, vì không có nó thì phiên sau đọc nhật ký cũ rồi dựng lại đúng thứ đã bỏ.

---

# PHẦN I — HIỂU APP

## 1. Bản chất

**Khu Vườn Tỉnh Thức là app quản lý CAM KẾT, không phải app quản lý danh sách việc.**

Khác biệt nằm ở đơn vị. Danh sách việc trả lời được câu *"làm cái này lúc nào"*. Cam kết trả lời câu khó hơn: *"tôi hứa nộp cái gì, cho ai, trước ngày nào, và bằng chứng xong là gì"*. Task chỉ là thứ đẻ ra từ cam kết, và phiên tập trung là thứ nuôi task.

Lõi một câu, lời Tracy 12/08: **"biến cam kết thành kết quả."**

Một cam kết đúng nghĩa — mục tiêu rõ, đủ vừa sức, có hạn, có Output nộp được — chính là **đơn vị cấu trúc nhỏ nhất áp được lên ý thức con người**. Đó là lý do app chỉ đứng trên một lõi thay vì gom nhiều giải pháp.

## 2. Vấn đề gốc

Ba con số đo trên chính ROVA, hai tháng 29/05→31/07/2026:

- **490 trong 1.922 task** là việc cũ gõ lại bằng tay mỗi sáng
- Danh mục "dự án" đi từ 6–7 lên **13** mà không cái nào được đóng
- **156 nhịp việc lặp** gánh 34% lượng chữ báo cáo

Cộng thêm một sự thật nền: mỗi người chỉ thực sự tập trung sâu khoảng **2,3 giờ mỗi ngày** dù ngồi bàn 8–10 giờ.

Truy xuống dưới ba con số là **bốn nguyên nhân gốc**, và cả bốn là một sự thật mặc bốn chiếc áo:

| Mã | Nguyên nhân | Hiện ra thành |
|---|---|---|
| **N1** | **Entropy** — hệ nào không được áp cấu trúc thì trôi vào hỗn loạn | Việc trôi, dự án mở mãi không đóng |
| **N2** | **Vòng lặp mở** — việc dở không có chỗ nằm nên nằm lại trong đầu | Sáng nào cũng gõ lại việc hôm qua |
| **N3** | **Sự chú ý bị thương mại hoá** — người khác kiếm tiền trên chính sự phân tán của mình | Ngồi 8 giờ, sâu 2,3 giờ |
| **N4** | **Cấp phát không có luật** — việc sinh ra vô tổ chức thì dồn về người giỏi nhất | Người rảnh vẫn rảnh, người quá tải nhận thêm |

**N1 là nguyên nhân mẹ**, chiếm khoảng 80% ảnh hưởng lên mọi nỗi đau còn lại. Và cấu trúc không tự sinh ra — **phải có người dựng và có máy giữ**.

Chuẩn tự áp từ đó: *mọi tính năng phải truy được về một trong bốn nguyên nhân. Tính năng không truy được về nguyên nhân nào là ứng viên để không làm.*

## 3. Khác gì các app khác

Benchmark 6 app đầu ngành (ClickUp, Asana, Todoist, TickTick, Sunsama, Motion), làm 08–09/08. Ba kết luận:

**① Không app nào giữ đủ chuỗi bốn tầng.** Mỗi app chỉ giữ được hai tầng liền nhau — hoặc dự án ↔ task, hoặc task ↔ lịch. Không app nào nối được từ mục tiêu của công ty xuống tới giờ làm thật của một người, nên không app nào trả lời được câu *"giờ này của tôi phục vụ cái gì"*.

**② Không app nào dám chặn quá tải bằng luật thật.** Tất cả chỉ đổi màu cảnh báo; người dùng vẫn nhận thêm việc được như thường. Câu chốt của bản benchmark: *"máy của họ trả lời được 'làm cái này lúc nào', nhưng không trả lời được 'nên làm cái gì'."*

**③ Không app nào có tầng cam kết giữa dự án và task** — tức là không có chỗ cho một lời hứa giữa người với người.

Nghiên cứu thêm hai app đo cơ thể (WHOOP và Bevel, 10/08) cho ba thứ nên chép và ba thứ không nên. Nên chép: nhóm nhỏ có bối cảnh thân quen · nhiều bảng để không ai bét mọi bảng · chỗ nói chuyện đặt trước chỗ xem số. Không nên chép: chỉ số tổng hợp kiểu "tuổi hiệu suất" (nói dối đúng ngày họp nhiều) · bảng xếp hạng cá nhân hằng ngày · và tuyệt đối không để trợ lý AI sinh ra con số.

## 4. Kiến trúc và bộ luật vận hành

### 4.1. Chuỗi bốn tầng

```
🧭 DỰ ÁN            có vạch đích · một người gánh cuối · ngày xong
   └─ 🚩 CỘT MỐC    quãng ngày, mỗi mốc một ngày
        └─ 🌱 CAM KẾT   lời hứa của MỘT người, gói trong một tuần, có tiêu chí xong và Output
             └─ ✅ VIỆC        ngồi một buổi là xong (nửa giờ tới hai giờ)
                  └─ 💧 PHIÊN TẬP TRUNG   giờ do máy chủ đóng dấu
```

Đọc xuôi (người điều hành): mở dự án → thấy mốc nào tới hạn → cam kết nào đang gánh mốc đó → việc nào đang nằm trong kho của ai.
Đọc ngược (người làm việc): thấy một việc → nó thuộc cam kết nào → cam kết ấy phục vụ dự án nào.

**Tiến độ đi ngược từ dưới lên.** Máy chủ tự cộng; app không bao giờ hỏi *"bao nhiêu phần trăm rồi"*.

**Việc cố định đứng ngoài chuỗi** — việc lặp không có vạch đích nên không thuộc dự án nào. Nó gắn vào **vị trí, không gắn vào người**: sáu khối chức năng, mỗi khối một danh mục dùng chung, người nghỉ thì việc vẫn có chủ.

### 4.2. Bộ luật vận hành — phần giữ integrity

| Luật | Nội dung |
|---|---|
| **Hết luống là hết đất** | Trần 3 cam kết đang chạy mỗi người, CEO 5 — chặn ở tầng cơ sở dữ liệu, giao diện không lách được |
| **Luật một ngày (3b)** | Không việc nào nằm quá một ngày mà không đổi trạng thái |
| **Ba cửa ra** | Kết phiên bắt buộc chọn: xong · chưa xong · nghẽn. **Không có cửa nào cho phép im lặng đi ra** |
| **Bốn cửa dọn** | Mở ngày bằng màn dọn: xong · chưa xong · nghẽn · dừng |
| **Trần hoãn 3 lần** | Quá trần thì **không bao giờ để người ta chỉ còn đúng một lối là huỷ** — nút một tự thành 📦 *về kho* |
| **Cha–con** | Cha đóng thì con **thay** cha (chia nhỏ, đổi hướng); cha còn sống thì con **đứng cạnh** (gỡ nghẽn). *Huỷ* thu về đúng một nghĩa: dừng hẳn, không con |
| **Kho việc** | Việc đã hẹn ngày thì cả đội đọc được; việc còn trong kho thì chỉ chủ đọc. Ranh giới: hẹn ngày = đã nhận làm nên công khai được |
| **Chuỗi ngày** | Hai bản — *full tuần* và *nghỉ Chủ nhật*. **Thứ Bảy vẫn là ngày làm** |
| **Output bắt buộc** | Đóng cam kết phải nộp Output; từ chối một việc được giao phải khai lý do |

### 4.3. Năm luật không được phép lách

**Luật 1 · Cây chỉ lớn bằng giờ làm việc thật.** Không hệ số nhân, không điểm thưởng cho hành vi. Đây là điều kiện chống Goodhart. *Bằng chứng đang chạy:* 389 trong 401 phiên là giờ máy chủ đóng dấu.

**Luật 2 · App phạt sự im lặng, không phạt thất bại.** Hệ thống nào phạt thất bại thì người ta giấu; hệ thống chỉ phạt sự im lặng thì người ta nói. Đây là vế thứ hai của việc giữ lời trong mô hình Integrity. *Bằng chứng đang chạy:* 14 cam kết được dời hạn công khai 17 lần.

**Luật 3 · Chỉ đếm đường đã đi, không đếm nợ còn lại.** Tổng giờ, số cây, lưới ngày — chỉ tăng. Nền là Nguyên lý tiến bộ (Amabile & Kramer).

**Luật 4 · Mọi câu chữ nói về VIỆC, không nói về NGƯỜI.** Kluger & DeNisi 1996: phản hồi hướng vào người có 38% khả năng làm hiệu suất giảm.

**Luật 5 · Máy chủ tính SỐ, phần chữ chỉ nối câu.** Không một con số nào do mô hình ngôn ngữ sinh ra.

## 5. Hình tượng khu vườn và lớp trò chơi hoá

### 5.1. Vì sao là khu vườn

Chọn ngày 06/08/2026 trong sáu ứng viên. Đây **không phải lớp trang trí dán lên sau — nó là mô hình dữ liệu.**

| Trong vườn | Trong công việc thật |
|---|---|
| **Gieo hạt** | Mở một cam kết — một ước muốn được tuyên bố công khai |
| **Luống** (3, CEO 5) | Một cam kết đang chạy. Hết luống là hết đất |
| **Cây** (1 task = 1 cây) | Lớn theo tổng phút tập trung: mầm 30′ · cây non 60′ · cây vững 120′ · tán rộng 240′ |
| **Tưới cây** | Một phiên tập trung — nước là hành động, cây là kết quả |
| **Quả chín** 🍎🍊🍇 | Task xong, mang màu của luống đẻ ra nó |
| **Thu hoạch cả luống** 🧺 | Đóng trọn một cam kết, nộp Output |
| **Chậu lẻ** | Việc phát sinh ngoài cam kết |
| **Vật nuôi** | Việc cố định — không cho ăn thì chúng đói *(Tracy chốt 04/09, thay hình cũ là hoa)* |
| **Héo** | **Duy nhất** khi tự bấm bỏ cuộc — không bao giờ do rời app hay do thất bại |
| **Chuông** 🔔 | Tánh biết bật lên, quay về hiện tại |

Đích tuyên bố từ đầu: *người dùng mê app này như mê Stardew Valley*. Nhưng lấy đúng cơ chế ấy đặt lên công việc thật, **để càng mê càng không phải trốn đời** — đây là trò chơi duy nhất mà nhân vật lên cấp chính là người chơi.

### 5.2. Bốn thứ chép từ Stardew Valley

| Nguyên lý | App dịch sang công việc thật |
|---|---|
| **Cozy = an toàn + dư dả + mềm mại** — thứ phá cozy số một là thưởng ngoại lai | Không có bảng quy đổi điểm ra tiền; thưởng nằm TRONG việc |
| **Entropy đã định liều** — hỗn loạn vừa đủ để dọn, dọn xong thấy trật tự ngay | Ba luống · task ngồi một buổi là xong · màn dọn mỗi sáng. Không bao giờ để ai đứng trước bãi 490 việc |
| **Không có trạng thái thua** — lỡ một ngày thì vườn chỉ chờ | Cây chỉ héo khi tự bỏ cuộc |
| **Đường cong máy tưới** — càng thành thạo càng mua lại được thời gian | Việc lặp đóng gói thành quy trình thì có giàn tưới tự động |

Thêm hai chi tiết đắt: **"0 điểm vẫn thắp một ngọn nến"**, và **đặt một viên kim cương để xin được đánh giá lại** — nối thẳng vào Game Kim Cương đã chạy thật 154 ngày ở TriEye.

### 5.3. Trạng thái ba nhóm

**✅ ĐANG CHẠY:** cây lớn theo giờ thật · quả · thu hoạch · hai bảng ghi nhận cân nhau (kết quả và giờ) · điểm ngày do máy tự chấm · chuông tỉnh thức · chuỗi ngày và lưới ngày · ô giờ vàng · hàng hiện diện (thấy ai đang tập trung) · lưới 12 người.

**🚧 ĐANG DỰNG LẠI:** lớp hiển thị nông trại. Bị gác 08/08 để làm xong phần xương trước — nguyên văn Tracy: *"tạm bỏ phần giao diện vườn đi nha, cái đó idea triết lý hay tôi sẽ bổ sung sau, bạn lưu lại cho tôi."* **Bật lại từ 04/09**: bản đồ dựng bằng Tiled, mỗi người một ngôi nhà, nhiều người thành một làng đi thăm vườn nhau được, có giới hạn thu nhỏ. Chưa chạm `public/index.html`.

**📋 THIẾT KẾ XONG, CHƯA DỰNG** *(Tracy chốt từng mục 11/08)*:

| Hình tượng | Nghĩa |
|---|---|
| **Đất màu mỡ** | Niềm tin tích luỹ từ giữ lời và báo sớm — *người làm vườn giỏi không tối ưu cây, họ tối ưu đất* |
| **Ủ phân** | Việc phải huỷ, đóng đúng cách kèm một dòng bài học — *vườn không có bãi rác, chỉ có thứ chưa được ủ* |
| **Bảo tàng làng** | Mọi Output đã nộp, trưng bày vĩnh viễn |
| **Công trình làng** | Mục tiêu chung, chỉ xây xong khi nhiều người góp nhiều **loại** quả; mỗi viên gạch mang gương mặt người góp |
| **Cây ROVA cổ thụ** | Lớn theo giờ tưới của cả làng, mỗi mùa thêm một vòng gỗ, **không bao giờ héo** — chỉ "đang khát" |
| **Bình tưới** | Chất liệu theo độ đều đặn (sắt→đồng→bạc→vàng→kim cương). **Lỗ thủng** = lời treo không nói. Đứt chuỗi thì **tụt một bậc, không vỡ về sắt** |
| **Phất cờ** | Báo sớm sẽ trễ — cờ mang chữ **"đã báo"**, không mang chữ "trễ". Đếm cộng, không đếm trừ |
| **Giàn tưới tự động** | Việc lặp đã thành quy trình hoặc đã uỷ quyền — phần thưởng của sự trưởng thành hệ thống |
| **Mùa 28 ngày · năm 90 ngày · chợ phiên** | Chu kỳ dự án · lễ mùa gặt · khối họp trên lịch làng |

### 5.4. Cạnh tranh lành mạnh — cạnh tranh có luật

Tracy đặt đề 11/08: *"đừng chỉ nhìn WHOOP — nhìn vào cách cơ chế game thiết kế để tạo cạnh tranh lành mạnh và giúp mọi người thân nhau hơn."*

Thiết kế chốt lại ở một ranh giới: **tách chỉ số nền khỏi sới chơi.**

- **Chỉ số vận hành hằng ngày — không bao giờ đem ra thi.** Chúng để gỡ chặn cho nhau, không để chấm ai chăm ai lười.
- **Muốn thi thì mở một sới chơi theo vụ:** có ngày mở, có ngày đóng, tự nguyện đăng ký, phe xáo lại mỗi vụ, bảng đua **chỉ hiện tổng của phe** chứ không hiện từng người, luôn có một tầng thắng chung đứng trên tầng thắng riêng, và người thua vụ vẫn có phần. Cái kết là một **buổi hội có may rủi**, không phải một cái bảng.

Công thức một dòng: **ganh đua thì nóng, nhưng không để lại vết lạnh.**

⚠️ **Mâu thuẫn đã được Tracy đích thân phân xử 11/08.** Nguyên lý ghi *"không xếp hạng cá nhân"*, nhưng app có lưới 12 người mà mắt so được. Tracy chốt **giữ lưới** — *"Giữ chứ đang hay"*. Nguyên lý vì thế được viết lại cho trung thực, và thứ giữ lưới không thành camera là **luật đọc phải công bố với đội trước ngày mở app**.

**Bằng chứng hai chiều, để không ai tưởng đây là chuyện cảm tính:** Zhang 2016 (RCT, N=790, 11 tuần) — nhánh so sánh xã hội **+62%**, nhánh "động viên nhau" **không chạy** (p=.68) · Hydari và cs. 2023 (*Management Science*) — bảng xếp hạng làm người ít vận động **+1.300 bước** nhưng người đã năng động **−630 bước** · Yang & Koenigstorfer — vùng bỏ cuộc là **khúc giữa bảng**, không phải khúc cuối. ⚠️ **Lỗ hổng phải nói thẳng:** mọi nghiên cứu trên làm với người lạ hoặc bạn bè, **chưa có nghiên cứu nào làm với đồng nghiệp có quan hệ cấp trên – cấp dưới**.

**Kinh tế ba lớp**, giải điểm căng giữa ý Tracy 09/08 và bộ nguyên lý đã nạp: thưởng nằm TRONG việc (90%) · sưu tập và danh hiệu không quy đổi · quà thật nhỏ ở lễ mùa gặt. **Tuyệt đối không có bảng tỉ giá điểm = tiền.** Câu chốt: ***quả để sưu tập, cờ để tôn vinh, quà để kể chuyện, tiền chỉ để đặt cược.***

### 5.5. Nghi thức hoàn tất

Tracy chốt tên 11/08: **hoàn tất**, không phải hoàn thành. *Hoàn thành* là việc đã xong; *hoàn tất* là việc đã về đúng chỗ của nó, không còn ngồi trong đầu mình điều khiển ngày mai. Lời Tracy: *"rất thích… giữ integrity bằng hoàn tất mỗi ngày dù chưa xong… giảm RAM não."*

Năm bước, đích 90 giây:

| # | Bước | Trạng thái |
|---|---|---|
| 1 | **Khép lời** — mỗi việc còn mở đi qua đúng một trong bốn cửa: xong · chưa xong kèm tiến độ · nghẽn kèm thứ chặn và việc gỡ · trả về kho | ✅ đang chạy |
| 2 | **Gieo mồi mai** — *"sáng mai, việc đầu tiên là gì?"* | 🚧 gác 11/08 (*"tôi thấy hơi phức tạp"*) |
| 3 | **Một câu về mình** — 5–7 câu có/không, đủ mẫu mới được kết luận | ⬜ chưa làm |
| 4 | **Tấm gương ngày** — máy chủ trả số, phần chữ chỉ nối câu | ✅ đang chạy |
| 5 | **Cài then** — *"Vườn đã cài then. Hẹn mai."* | 🚧 gác (*"cài then thì chưa cần đâu"*) |

Đang chạy thêm: điền trọn số của việc cố định ngay trong nghi thức, có đếm *đã điền x/N*.

**Nền khoa học:** Masicampo & Baumeister — não không đòi việc phải **xong**, nó chỉ đòi việc phải **có chỗ**; cam kết một kế hoạch cụ thể là đủ để trả lại chỗ trong đầu. Cộng nghi thức tắt máy của Newport (cần 1–2 tuần mới tin được) và dư âm chú ý của Leroy 2009. ⚠️ **Không viện dẫn hiệu ứng Zeigarnik** — phân tích tổng hợp 2025 soi 59 công trình đã lật nó.

Câu văn hoá Tracy lưu 11/08: ***"Nỗ lực sâu khi làm, buông trọn khi nghỉ."***

## 6. Tầng triết lý nền

App đứng trên tám triết lý, viết đầy đủ ở `giai-phap-khu-vuon-tinh-thuc.md`. Bốn cụm gốc:

**① Flow (Csikszentmihalyi) + Deep Work (Newport)** — vì sao công việc **có thể** là nguồn hạnh phúc. Csikszentmihalyi đo được người ta ở trong dòng chảy **54% thời gian khi làm việc nhưng chỉ 18% khi giải trí**; vậy mà ai cũng mong hết giờ, vì mục tiêu không phải của mình. Newport cho công thức: *thành quả chất lượng cao = thời gian × cường độ tập trung* — vế chúng ta thiếu là cường độ, không phải giờ.

**② Integrity + Kiến tạo cuộc chơi + Speed of Light** — tầng tổ chức. Integrity (Erhard – Jensen – Zaffron) không phải đạo đức mà là **trạng thái lời-nói-toàn-vẹn**, một điều kiện vận hành khách quan: lời nói của một đội toàn vẹn tới đâu thì đội đó vận hành được tới đó. Kiến tạo cuộc chơi (deck nội bộ ROVA): *"KPI là điểm số. Kế hoạch là cách chơi. Quy trình là luật chơi. Nhưng CUỘC CHƠI là bối cảnh khiến con người MUỐN bước vào hành động."* Speed of Light (Jensen Huang): đo bằng giới hạn lý tưởng để soi độ trễ của **hệ thống**, không phải để giao hạn cho người.

**③ Game Kim Cương + Time Wizard (TriEye)** — triết lý game đã chạy thật 154 ngày. Bài học đắt nhất: *"99% vẫn là Than"*, và **trễ báo cáo bị phạt nặng hơn làm dở** — tức game định giá integrity cao hơn thành tích.

**④ Stardew Valley** — hình mẫu trò chơi hoá, đã nghiên cứu sâu hai vòng có nguồn web xác thực (mục 5.2).

Thêm một trụ cho tầng đội: **Team Flow** (van den Hout & Davis, TU Eindhoven) — 7 điều kiện tiên quyết **không ngang hàng nhau**: tham vọng tập thể, tự chủ và giao tiếp mở phải dựng TRƯỚC. Và câu đáng dán lên bàn mọi người điều hành, lời Rian Doris: *nếu bạn ở trong dòng chảy cả ngày mà đội của bạn thì không, bạn vẫn ra ít kết quả hơn nhiều so với khi chính bạn không ở trong dòng chảy nhưng cả đội bạn thì có.*

## 7. Đang chạy thật tới đâu

Số rút từ bản sao dữ liệu **05/09/2026**:

| Số đo | Giá trị |
|---|---|
| Người dùng thật | **7** (trên đội 12), 6 người đã chạy phiên tập trung |
| Phiên tập trung | **401 phiên**, ~**378 giờ**, trải 31 ngày liền (05/08 → 05/09) |
| Giờ máy chủ đóng dấu | **389/401** — chỉ 12 phiên khai tay (3%) |
| Trung bình một phiên | **72 phút** |
| Giờ sâu trung vị mỗi người mỗi ngày có làm | **3,0 giờ** |
| Chuông tỉnh thức | **426** |
| Cam kết | **60** gieo · 35 đóng xong · 28 có Output nộp · **14 cái dời hạn công khai 17 lần** |
| Task | **400**, xong 338 |
| Cửa ra khi kết phiên | xong 193 · chưa xong 92 · **nghẽn 5** |

Năm mảng tính năng và trạng thái:

| Mảng | Trạng thái |
|---|---|
| Việc cố định theo khối chức năng | ✅ chạy — lưới tuần, 6 khối, 4 ô đo, việc gắn vào vị trí |
| Dự án → cột mốc → cam kết → task → phiên | ✅ chạy — có Gantt, kanban kéo thả, giao và ký nhận, kho cam kết, trao vai phụ trách |
| Lịch doanh nghiệp + lịch trình cá nhân | ✅ chạy — 5 khung nhìn, mời đích danh, quyền host và quyền khách, việc riêng tư khoá ở máy chủ, giờ rảnh của đội, nhìn trước 60 ngày |
| Môi trường tập trung | ✅ chạy — trần cam kết, phiên 5–180 phút, ba cửa ra, nghi thức dọn và nghi thức hoàn tất |
| Vấn đề liên phòng ban | 🚧 mã đã lên `main` 05/09 — **chưa có dấu đã chạy tệp SQL trên máy chủ** |

## 8. Điểm căng và câu hỏi mở

1. **Quả đang mang hai nghĩa** — 10 phút tập trung = 1 quả trong phiên, và task xong = quả chín theo luống. Đã đề xuất phân biệt bằng độ chín, Tracy chưa ưng bản nhạt.
2. **Bảng 💧 giờ tập trung bỏ sót trọn lớp việc giao tiếp** — loại việc không cần phiên tập trung thì không bao giờ lên bảng. Đây là chỗ bảng công khai **phạt oan**.
3. **Việc xong mà không có phiên tập trung thì không lên bảng gặt** — chốt chặn cố ý, nhưng bảy ngày tới 02/09 nó lọc mất 21/28 việc của Tracy, 12/18 của Andy, 5/14 của Justin. Con số này cần Tracy phân xử.
4. **Chưa có luật nào ràng buộc người GIAO việc.** Cả tám triết lý đều ràng buộc người nhận. Nếu đầu vào không đổi, app chỉ làm tình trạng quá tải trở nên **đo được**, chứ chưa làm nó nhỏ đi. Đây là chỗ trống lớn nhất của cả hệ.
5. **Họp làng hằng tuần** — nguồn (Gerber) khẳng định cuộc chơi chết nếu thiếu nhịp người thật; app không thay được nhịp đó. ROVA chưa chốt.
6. **Bảng tính *ROVA Tỉnh thức* 12 tab vẫn chạy tự động sáng thứ Hai** trong khi đội đang chuyển sang app — nguy cơ hai hệ song song.
7. **Ranh giới ClickUp ↔ app** chưa ai tuyên bố; mục tiêu *"đưa dự án lên ClickUp"* vẫn nằm trong OKR quý và vẫn quá hạn.

## 9. Từ vựng nhanh

| Từ | Nghĩa trong hệ này |
|---|---|
| **Cam kết** | Kết quả cá nhân hứa với cấp trên, vài ngày tới một tuần, có Output. **KHÔNG** phải "task lớn" |
| **Deep work** | Phiên tập trung đo giờ thật có nghi thức vào và ra; không phải mọi giờ làm việc |
| **Tưới cây** | Làm một phiên tập trung cho một task |
| **Ba cửa ra** | Xong / chưa xong / nghẽn — bắt buộc chọn khi kết phiên |
| **Chuông tỉnh thức** | Lần nhận ra mình trôi và **quay về** — luôn là điểm cộng |
| **Luật 3b** | Không việc nào quá một ngày mà không đổi trạng thái |
| **Hết luống là hết đất** | Trần cứng 3 cam kết, CEO 5 (`nguoi.so_cam_ket_toi_da`) |
| **Phất cờ** | Báo sớm khi biết sẽ trễ — hành vi được tôn vinh |
| **Integrity** | Lời-nói-toàn-vẹn, một hiện tượng khách quan, không phải đạo đức |
| **Entropy định liều** | Thứ game nông trại bán: hỗn loạn vừa đủ để dọn và thấy trật tự ngay |
| **Tỉnh thức** | Tánh biết quay về hiện tại; đồng thời là tên nhóm Lark cũ của đội |
| **Sới chơi** | Cuộc thi ngắn có ngày mở ngày đóng, tự nguyện — khác hẳn chỉ số nền |

---

# PHẦN II — TẦNG KỸ THUẬT

> Đọc khi sắp **sửa** app. Mục 15 (*luật đã trả giá*) và mục 16 (*quyết định đã bị thay*) là hai mục cứu nhiều thời gian nhất.

## 10. Hạ tầng và địa chỉ

| Thứ | Giá trị |
|---|---|
| Địa chỉ app thật | `https://rovatinhthuc.tranmaitrang-hup.workers.dev` |
| Kho mã | GitHub **riêng tư** `tranmaitranghup-star/khu-vuon-tinh-thuc`, nhánh `main` |
| Nền chạy | Cloudflare Workers — đẩy `main` là tự phát hành sau ~36–60 giây, không tốn credit |
| Thư mục ra web | **chỉ `public/`** (khai trong `wrangler.jsonc`). Mọi tệp `.sql` và `.md` nằm ngoài nên không ra web |
| Cơ sở dữ liệu | Supabase project **ROVA**, ref `bgstlkeplgluppmdknci`, gói Free |
| Đăng nhập | Google OAuth + danh sách trắng email trong bảng `nguoi`. Client tạo trong project Google `tracy-claude-drive` ⚠️ *nên tách project riêng* |
| Chạy thử tại máy | `python3 phuc-vu.py` → cổng 8082. Lệnh `python3 -m http.server` **không chạy được trên máy này** — `os.getcwd()` bị chặn quyền, và ngã trước khi kịp truyền `--directory` |
| Sao lưu | `sao-luu.py` **nằm ngoài kho này**, ở `~/Desktop/ROVA/sao-luu-khu-vuon/` — kéo về `~/Desktop/ROVA/ban-sao-theo-ngay/`. **Chạy tay**, mới phủ **12 trong 30 bảng**. Supabase Free **không giữ bản dự phòng nào** 🔴 |

**Đổi sang tên miền riêng thì đúng ba bước, thiếu bước ② là đăng nhập gãy:**
1. Cloudflare → Workers & Pages → `rovatinhthuc` → Settings → Domains & Routes → Add Custom Domain.
2. **Supabase → Authentication → URL Configuration: thêm tên miền mới vào Site URL và Redirect URLs** (app dùng `redirectTo: location.origin`).
3. Tắt `workers.dev` thì phải ghi `workers_dev = false` vào `wrangler.jsonc` — tắt ở bảng điều khiển mà không ghi vào tệp thì lần phát hành sau nó bật lại.

*Google Cloud Console không phải sửa* — Google trả về địa chỉ callback của Supabase, không trả về app.

## 11. Tệp trong kho

Repo có 6.478 tệp được theo dõi, nhưng **97% là ảnh**. Chỗ đáng đọc rất nhỏ:

| Nơi | Số | Là gì |
|---|---:|---|
| `public/` | 34 | **Toàn bộ thứ chạy được.** `index.html` là app; `vendor/` có supabase-js và font, **0 tên miền ngoài** |
| gốc repo | 288 | 87 tệp `.sql` · 41 tệp `.md` · 59 bài thử · script Python công cụ |
| `bo-hinh/` | 5.947 | Ảnh sprite nông trại |
| `vuon-tiled/` | 187 | Bản đồ vườn dựng bằng Tiled |
| `luu-tru/` | 12+ | Tài liệu hết hiệu lực, giữ để đối chiếu |

| Tệp | Vai |
|---|---|
| `public/index.html` | **Toàn bộ app trong một tệp** — 2,54 MB, 38.728 dòng, 1.204 hàm, 13 màn |
| `public/_headers` | `/vendor/*` giữ bộ nhớ đệm một năm; `index.html` cố ý không khai để bản mới tới tay đội ngay |
| `schema.sql` · `nang-cap-*.sql` · `va-*.sql` | Lược đồ gốc và từng đợt nâng cấp, **chạy tay** trên Supabase SQL Editor |
| `thu-*.js` · `thu-*.py` | 59 bài thử, 457 câu khẳng định. Mỗi bài **tự cắt khối mã gốc từ `public/index.html`** nên không trôi khỏi bản thật |
| `mau-*.html` | Bản mẫu để Tracy chấm trước khi gắn vào app. Nằm ngoài `public/` nên không ra web |
| `BAN-DO-INDEX.md` | Bản đồ hàm — **tra trước, đọc sau** |
| `DANG-LAM.md` · `LUAT-LAN.md` | Bảng chia làn khi nhiều phiên cùng sửa |

**Nếp làm việc đã thành luật:** ra bản mẫu `mau-*.html` trước → Tracy chấm → mới gắn vào `public/index.html`.

## 12. Cấu trúc dữ liệu

**30 bảng, 19 khung nhìn, 80 hàm, 53 trigger, phân quyền từng dòng bật trên cả 30 bảng.**

Nhóm theo mảng:

- **Người và tổ chức:** `nguoi` · `chuc_nang` *(khối chức năng; `nguoi.chuc_nang_ids` là **mảng** — một người thuộc nhiều khối)*
- **Cam kết và việc:** `tieu_diem` *(chính là **cam kết** — tên bảng cố ý giữ nguyên, chỉ đổi chữ hiển thị)* · `task` · `muc_viec` · `tick_muc` · `cum_trang_thai_task` · `tran_danh_muc`
- **Dự án:** `muc_tieu` · `moc_du_an` · `thanh_vien_du_an` · `doc_cam_ket`
- **Việc lặp:** `danh_muc_nhip` · `nhip` · `so_ngay` · `nop_ngay` · `viec_co_dinh`
- **Tập trung:** `phien_deepwork` · `tieng_chuong`
- **Lịch:** `lich_chung` *(một dòng = một **chuỗi**)* · `lich_chung_ngoai_le` *(huỷ hoặc dời từng buổi)* · `lich_chung_tham_du` · `doc_su_kien` · `ghi_chu_buoi` · `thong_bao_buoi`
- **Vấn đề và ghi chú:** `van_de` · `van_de_binh_luan` · `khach_con_tro` · `ghi_chu` · `ban_tin`

**Khung nhìn đang dùng:** `cho_ban` *(7 nhánh — mọi thứ đang chờ đúng tên mình)* · `tien_do_o` · `tien_do_muc_tieu` · `viec_du_an` · `danh_muc_du_an` · `dem_cam_ket_da_dong` · `dem_task_theo_o` · `viec_con_no` · `gio_deepwork_theo_ngay` · `gio_deepwork_theo_gio` *(ô giờ vàng)* · `gio_deepwork_theo_loai` · `vuon_cay` · `diem_ngay` · `ket_qua_ngay` · `gat_theo_ngay` · `cham_theo_ngay` · `nhip_thoi_gian` · `ai_dang_lam` · `viec_co_dinh_da_dung`.

**Ba chi tiết dễ vấp:**

- **Task có 8 trạng thái.** `Da_huy` và `Da_chuyen` là *đã đóng nhưng không phải hoàn thành* — mọi chỗ đếm phải dùng chung danh sách `TT_MO`, đừng viết lại điều kiện.
- **`task.ngay` cho phép rỗng** = việc nằm trong **kho** của cam kết. Nhưng `default hom_nay()` giữ nguyên để mọi đường thêm task cũ không đổi hành vi.
- ⚠️ **`nguoi_tick` là cột thừa** — từ 06/08 policy đã siết `nguoi_id = nguoi_id_dang_nhap()` nên nó luôn bằng `nguoi_id`. Đã sửa ghi chú, **chưa gỡ cột**.

## 13. Ngưỡng số — đổi một chỗ phải soi chỗ kia

| Ngưỡng | Giá trị | Ghi chú |
|---|---|---|
| Cam kết đang chạy mỗi người | **3**, CEO **5** | Cột `nguoi.so_cam_ket_toi_da` + trigger `kiem_tran_cam_ket`. Cố ý **không** đọc theo `nguoi.vai` |
| Phiên tập trung | sàn **5** · trần **180** phút | `nang-cap-tran-180-phut.sql` đổi cả 5 khung nhìn |
| Quả trong phiên | **10 phút = 1 quả**, tối đa 12 | |
| Nấc cây | **30 · 60 · 120 · 240** phút | Cũng là thang đậm nhạt của lưới tổng quan |
| `TRAN_MAY_CHU` | **2000** | Phải đổi đồng thời với *Max rows* bên Supabase; để lệch là chuông báo hỏng hai chiều |
| Trần hoãn một task | **3 lần** | Cột `so_lan_hoan` |
| Lịch trình nhìn trước | **60 ngày** (dò giờ rảnh 14 ngày) | |
| Giờ rảnh của đội | quét **8h–23h**, bước **15 phút**, chừa trưa và Chủ nhật | |
| Kích thước task | **nửa giờ tới hai giờ** | Không ước lượng nổi thì còn quá to, chia nhỏ tiếp |
| Màu neo | `--xanh #258c86` · tầng cam kết tím `#b98cdd` | **Đỏ dành riêng cho nút bỏ cuộc** |

**Sức chịu tải đã soi:** 12 người × 1 năm ≈ 105.000 dòng, ~21 MB. Phải tới ~1,2 triệu dòng mới chạm trần 500 MB, tức khoảng 14 năm. **Nút thắt nằm trong mã app, không nằm ở máy chủ.**

## 14. Luật kỹ thuật — đã trả giá thật, đừng tái phạm

- **Một đợt truy vấn mỗi màn.** Thêm truy vấn mới thì thêm vào mảng `Promise.all` có sẵn, đừng viết `await` riêng bên dưới — mỗi `await` nối tiếp là một lượt chờ cộng vào thời gian mở app.
- **Đếm ở máy chủ.** Đừng kéo dòng về chỉ để đếm. *"Trần chỉ dời ngày vỡ, bỏ mới là hết vỡ."*
- **Im lặng là nói dối.** Mọi lần dữ liệu bị chặn ở trần phải báo ra — nhưng chỉ báo khi **máy chủ** chặn, không báo với trần app tự đặt. Kêu mãi thì người ta thôi đọc.
- **`create or replace view` chỉ cho thêm cột vào cuối.** Đổi thứ tự cột phải `drop view` rồi tạo lại.
- **Tệp SQL đưa người khác chạy: chỉ được có đúng MỘT câu `select` ở cuối** — SQL Editor chỉ hiện bảng của lệnh cuối.
- **Phân quyền từng dòng:** không dùng `for all`, tách policy hẹp. Luôn kèm bộ tự kiểm **và thử phá thật** — tự kiểm chỉ trả lời *"ràng buộc có tồn tại không"*, khác hẳn *"nó có chặn thật không"*.
- **Giờ Việt Nam:** mọi bộ lọc theo ngày khai thẳng `+07:00`, không trông vào máy chủ đoán múi giờ.
- **`vendor/`:** tệp phải mang số bản trong tên (vì bộ nhớ đệm một năm) và phải trỏ bằng đường dẫn **tuyệt đối** — đường dẫn tương đối bị lớp dự phòng nuốt thành màn đen câm.
- **Commit nêu đích danh tệp, cấm `git add -A` và cấm `git add <thư-mục>`.** Đã vi phạm ba lần, lần nào cũng gánh làn của phiên khác vào commit mang tên không liên quan.
- **`node --check` không bắt được hàm thiếu định nghĩa** — phải có phép quét riêng dò hàm gọi từ thuộc tính `on*`.
- **Ảnh chụp từ khung xem không phải bằng chứng** — phải hỏi trang xem nó đang chạy cái gì.
- **AI không chạy được SQL** — cổng REST không nhận lệnh đổi lược đồ. Mọi tệp SQL phải để Tracy tự dán vào SQL Editor, và **phải dán thẳng khối SQL vào chat**, không chỉ nêu tên tệp.
- **Ghi vào sổ làn thì commit ngay trong lượt đó.** Sổ sửa dở nằm trên đĩa chặn `git pull` của **mọi** phiên, không riêng phiên viết nó.
- **Font:** Poppins và Outfit **không có bộ dấu tiếng Việt**. Montserrat rộng hơn font hệ thống +24% — đổi chữ trong ô nhập thì phải đo bề rộng thật ở khổ 375px. Chỗ nào hiện số cũng phải khai `tabular-nums`.
- **Điều khiển tự vẽ:** thay điều khiển gốc của trình duyệt thì **giữ ô thật ẩn phía sau**, để vẫn dùng được bàn phím và bảng chọn hệ điều hành.
- **Khoảng trắng:** vạch kẻ nói *"chỗ này hết"*, khoảng trắng mới nói *"khối sau là chuyện khác"*.
- **Bài thử chết lúc khởi động thì mọi ca im lặng biến mất** — chạy cả bộ và so với bản trước sau mỗi lần sửa mã.

## 15. Đang hở

> ⚠️ **LUẬT ĐỌC MỤC NÀY:** một dòng ở đây là **giả thuyết, không phải kết luận**. Ngày 28/08 danh sách cũ khiến tôi báo Tracy bốn lỗi "đang cắn" mà ba đã sửa từ hai tuần trước, và Tracy duyệt một phạm vi dựa trên thông tin sai. **Trước khi báo bất kỳ dòng nào là lỗi đang sống, phải soi mã xác nhận và ghi lại ngày soi.**

- 🔴 **Sao lưu mới phủ 12 trong 30 bảng — 18 bảng chưa có bản sao nào**, trong đó có cả bảng lịch chung và bảng vấn đề vừa dựng. Supabase Free không giữ bản dự phòng nào. Đây là chỗ đau nhất.
- 🔴 **Lớp vấn đề liên phòng ban: mã đã lên `main` nhưng bốn tệp SQL chưa có dấu đã chạy** trên máy chủ. Chưa chạy thì lớp này chưa sống dù giao diện đã có. Cùng tình trạng: `nang-cap-co-cau-to-chuc.sql` của màn Team.
- 🟠 **Đường giao cam kết chưa ai thử tay với dữ liệu thật** — mọi làn mới soi tới mức giao diện, chưa chạy trọn đường giao → nhận → vào luống.
- 🟠 **Chuông bấm dồn không có phanh** — một phiên từng ghi 7 tiếng trong 2 giây. *(Còn thật, soi 28/08.)*
- 🟡 **Chuông tỉnh thức không phát ra tiếng** — nút câm, mới đếm số lần bấm.
- 🟡 **Riêng tư của sự kiện `pham_vi='ca_nhan'` chỉ giấu ở máy khách**, chưa khoá ở máy chủ. *(Việc riêng tư của task thì đã khoá ở máy chủ — hai đường khác nhau, đừng lẫn.)*
- 🟡 **Khung nhìn `nhip_thoi_gian`** — số phút trung bình thật của mỗi việc lặp — đã nằm sẵn ở máy chủ từ 06/08 nhưng **app chưa gọi lần nào**.
- 🟡 **Trạng thái gấp/mở của các thẻ chưa nhớ qua lần tải trang.**
- ⬜ **Chưa giữ được:** chọn *chưa xong* hay *chưa làm* rồi bấm làm tiếp thì task về `Confirm` ngay — phân biệt hai ô đó không đọng lại đâu để đếm về sau.

## 16. Những quyết định đã bị thay — đừng dựng lại

> Mỗi dòng là một thứ **từng đúng, nay đã bị thay**. Giữ lại vì phiên sau đọc nhật ký cũ rất dễ dựng lại đúng cái đã bỏ — và mất nguyên một buổi mới phát hiện ra.

**Hạ tầng**
- Netlify → **Cloudflare Workers** (06/08). Luật *"gom nhiều sửa rồi kéo lên một lần"* và trần 20 lượt mỗi tháng **hết hiệu lực** — đẩy bao nhiêu lần cũng 0 đồng.
- `rovatinhthuc.pages.dev` → thực tế là **`…workers.dev`**.
- `python3 -m http.server 8080` → **`python3 phuc-vu.py`** cổng 8082.

**Mô hình việc**
- Trần **3 đêm** tính từ `ngay_hen_dau` → trần **3 lần hoãn** qua `so_lan_hoan` (08/08).
- Cột `cha_id` → **`task_cha`**. Cờ `het_cua_lam_tiep` → **`het_cua_hen_ngay`**.
- **Máy phân biệt "lỡ" với "chưa xong" bằng có phiên tập trung hay không** → **bỏ hẳn** (08/08). Có cả một lớp việc giao tiếp không cần phiên tập trung; suy như vậy là suy ngược.
- `select('*')` → hằng **`COT_TASK`**.

**Tập trung**
- Khung **30 phút cố định** → **phiên tự do**, đồng hồ đếm lên (06/08). Trần **120** → **180 phút**.
- Chế độ 🔒 *tập trung sâu* và luật *"rời trang là phiên mất trắng"* → **bỏ hẳn** (07/08). Cột `tap_trung_sau` giữ lại để dữ liệu cũ không gãy.
- **Mỗi phút một lá** → **10 phút một quả**.
- Bốn cửa ra → **ba cửa ra** (Tracy bỏ cửa *chia nhỏ*).
- Ngưỡng "cây héo 40 phút" → **bỏ**, thay bằng im lặng nhịp tim 5 phút. *(Luật 40 phút chỉ còn sót trong `schema.sql:244`, bản `vuon_cay` ấy đã bị viết đè.)*

**Giao diện**
- **Lớp hiển thị nông trại** → gác 08/08, **bật lại 04/09**. Triết lý và toàn bộ cột dữ liệu (`qua`, `mau`, `ten_loai`) giữ nguyên suốt thời gian gác.
- **Sáu nút tab → bốn** (26/08): Hôm nay · Của tôi · Dự án · ROVA. *Deep work thôi làm một nơi chốn — nó là một hành động, bấm 💧 trên một việc.* Tab *Timeline* và tab *Việc cố định* thôi làm màn riêng, thành khối trong *Của tôi*.
- Nút **"Cả ROVA"** ở màn cam kết → **bỏ**. Phạm vi do **nơi đang đứng** quyết định, không do một nút chuyển chế độ.
- Việc xong **gạch ngang** → chỉ **lùi màu** (*"gạch nhìn rối lắm"*).
- Nhãn *"Xong khi:"* → **"Tiêu chí done:"**. Ô `dd/mm/yyyy` → **nút "Deadline"**.
- Phương án *"bảng đội"* một hàng một người → Tracy bác, giữ kiểu **thẻ**.
- Chữ **"Thôi"** trên mọi nút → **"Huỷ"**. Chữ **"đội"** trong giao diện → **"team"**.
- Hình **bông lúa** ở mốc nghi thức hoàn tất → **cửa vòm** (Tracy chọn 05/09).

**Tổ chức**
- Ba luống **dùng chung cả đội** → mỗi người ba luống riêng (06/08).
- *"Cả đội ai cũng tick được"* → **chỉ chủ cam kết** (06/08).
- 10 tiêu điểm chung công ty O1–O10 → **3 cam kết cá nhân**. Nhãn *"tiêu điểm O"* → **"Cam kết của bạn"**; tên bảng `tieu_diem` **cố ý giữ nguyên**.
- Chu kỳ cam kết **một tháng** → **một tuần** (05/08). Tầng 4 gọi là *KA* → gọi thẳng là **task**.
- Trần 3 cam kết cho tất cả → **trần riêng từng người** (11/08).
- Kích thước task *"1–4 block × 30 phút"* → **"ngồi một buổi là xong"** (11/08).
- **`nguoi.phong_ban` một giá trị → `chuc_nang_ids` là MẢNG** (03/09). Đọc bằng phép giao hai mảng; bẫy: `any(truy vấn con)` ≠ `any(mảng)`.
- **Nối Google Calendar** → **bỏ**; app tự dựng lớp lịch riêng từ 31/08. Luật *"hút một chiều, không kéo thả"* của bản 15/08 cũng đã bị lật — kéo thả chạy thật.
- **Danh sách việc trong hồ sơ `G-01`** → chuyển sang **Linear** (02/09). Hồ sơ giữ bối cảnh và quyết định; Linear giữ việc.
