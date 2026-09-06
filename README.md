<!-- BẢN KHUÔN — ĐỪNG DIFF TỆP NÀY VỚI BẢN ĐÃ ĐĂNG RỒI TƯỞNG LÀ LỆCH.

     Tệp này là NGUỒN phần chữ của README kho công khai `khu-vuon`. Khi
     `dong-bo-cong-khai.py` chạy, nó chép tệp này thành `README.md` của kho công
     khai RỒI GHI ĐÈ mọi khối số bằng số đếm được từ kho thật: tổng số tệp và
     dung lượng · ô `public/` và ô `gốc kho` · số tệp `.sql` · số bài thử, số tệp
     tài liệu · kết quả "đạt x/y". Nên bản đăng LUÔN khác tệp này ở mấy con số
     ấy, và đó là đúng thiết kế chứ không phải trôi lệch.

     ĐỪNG sửa tay mấy con số đó ở đây — sửa cũng bị ghi đè ở lượt đẩy kế tiếp.
     Muốn biết số thật thì chạy `python3 dong-bo-cong-khai.py` (chạy trần là thử,
     không đẩy), nó in ra bộ số hiện hành.

     Phần CHỮ thì ngược lại: sửa ở đây, đừng sửa trong kho công khai — mọi thay
     đổi bên đó sẽ bị lượt đẩy sau ghi đè. -->

# Khu Vườn Tỉnh Thức

Web app quản lý **cam kết** cho doanh nghiệp nhỏ làm việc online — không phải một chỗ ghi danh sách việc.

Khác biệt nằm ở đúng một chữ. Danh sách việc trả lời được câu *"làm cái này lúc nào"*. Cam kết trả lời câu khó hơn: *"tôi hứa nộp cái gì, cho ai, trước ngày nào, và bằng chứng xong là gì"*. App lấy cam kết làm đơn vị; danh sách việc chỉ là thứ đẻ ra từ nó.

Lõi một câu của cả sản phẩm: **biến cam kết thành kết quả.**

> ### 🔑 Đọc trước khi bấm link
>
> App thật chạy ở **`https://rovatinhthuc.tranmaitrang-hup.workers.dev`**, nhưng cửa vào là Google OAuth đối chiếu **danh sách trắng email**. Người ngoài mở link sẽ bị chặn ở màn đăng nhập — **đó là app đang chạy đúng, không phải app hỏng.**
>
> Muốn xem bên trong thì có ba đường: đọc `spec.md` (bảy mục, bản mô tả sản phẩm) · mở `kien-truc-app.html` bằng trình duyệt (sơ đồ kiến trúc, không cần chạy gì) · hoặc dựng một bản của riêng mình theo mục *Chạy tại máy* bên dưới.
>
> Đây là **bản công khai** của một sản phẩm đang chạy thật trong nội bộ. Kho nội bộ giữ riêng tư vì chứa email thật của thành viên; kho này đã thay hết bằng chỗ giữ chỗ dạng `<ten>@vidu.com`.

---

## Giải cái gì

Trong doanh nghiệp nhỏ, mỗi người chỉ thực sự tập trung sâu khoảng **2,3 giờ mỗi ngày** dù ngồi bàn 8–10 giờ, còn việc cũ chưa xong thì bị gõ lại mỗi sáng thay vì được đóng.

Đo trên đội ROVA, hai tháng 29/05→31/07/2026:

- **490 trong 1.922 task** là việc cũ gõ lại bằng tay
- Danh mục "dự án" đi từ 6–7 lên **13** mà không cái nào được đóng
- **156 nhịp việc lặp** gánh 34% lượng chữ báo cáo

Cả ba đều là hỏng hóc thiết kế của công cụ cũ (nhóm chat + bảng tính 12 tab), không phải hỏng hóc thái độ: không có chỗ giữ hộ việc, và không có cơ chế đóng việc.

Truy xuống dưới ba con số ấy là **bốn nguyên nhân gốc** — và cả bốn là một sự thật mặc bốn chiếc áo:

| Mã | Nguyên nhân gốc | Hiện ra thành |
|---|---|---|
| **N1** | Entropy — hệ nào không được áp cấu trúc thì trôi vào hỗn loạn | Việc trôi, dự án mở mãi không đóng |
| **N2** | Vòng lặp mở — việc dở không có chỗ nằm nên nằm lại trong đầu | Sáng nào cũng gõ lại việc hôm qua |
| **N3** | Sự chú ý bị thương mại hoá — người khác kiếm tiền trên chính sự phân tán của mình | Ngồi 8 giờ, sâu 2,3 giờ |
| **N4** | Cấp phát không có luật — việc sinh ra vô tổ chức thì dồn về người giỏi nhất | Người rảnh vẫn rảnh, người quá tải nhận thêm |

**N1 là nguyên nhân mẹ.** Và cấu trúc không tự sinh ra: phải có người dựng, và phải có máy giữ. Đó là lý do app chỉ đứng trên một lõi duy nhất thay vì gom nhiều giải pháp — vì một cam kết đúng nghĩa (mục tiêu rõ · có hạn · có Output nộp được) chính là **đơn vị cấu trúc nhỏ nhất áp được lên ý thức con người**, và nó chạm cả bốn nguyên nhân cùng lúc.

## Cho ai

Doanh nghiệp nhỏ **dưới 20 người, làm việc online**. Ca dùng đầu tiên là đội **ROVA** (đào tạo trading, 12 người, cơ cấu phẳng) — app đang chạy thật với **7 người dùng từ 08/2026**.

Thứ nó thay thế: nhóm chat để giao việc + bảng tính để báo cáo + một app danh sách việc kiểu ClickUp/Todoist. Ba chỗ rời nhau, không chỗ nào giữ nổi chuỗi từ mục tiêu xuống tới giờ làm thật.

## Làm gì

**Năm việc, và cả năm đều quy về cái lõi.**

**1 · Giữ nhịp việc cố định của từng phòng ban.** Việc lặp gắn vào **vị trí, không gắn vào người** — sáu khối chức năng (CEO · Vận hành · Sản phẩm · Kinh doanh · Tài chính · Trải nghiệm khách hàng), mỗi khối một danh mục dùng chung, người nghỉ thì việc vẫn có chủ. Lưới bảy ngày chấm từng lượt, bốn ô đo mỗi tuần (làm được bao nhiêu % · hôm nay · ngày trọn vẹn · ngày bỏ trống) và một câu chỉ ra nhịp yếu nhất tuần. Cả đội đọc được của nhau, nhưng chỉ ghi được trong khối của mình.

**2 · Chia dự án của đội thành cam kết của từng người.** Một dự án có giai đoạn và cột mốc, xem được ba cách (danh sách · bảng cột kéo thả · Gantt). Người phụ trách dự án **giao cam kết** cho người khác; người nhận **ký nhận hoặc từ chối có khai lý do** — không có đồng hồ tự động nhận thay. Cam kết chưa tới lượt nằm trong **kho**, chưa chiếm luống. Tiến độ dự án được **tính từ dữ liệu thật**, app không bao giờ hỏi *"bao nhiêu phần trăm rồi"*. Đóng một cam kết thì **bắt buộc nộp Output**.

**3 · Công bố lịch doanh nghiệp, để mỗi người tự lên kế hoạch ngày.** Lịch chung có bảy nhóm nhận (cả công ty · bốn khối · coreteam · mời đích danh), mời người và điểm danh, quyền host và quyền khách tách bạch, sự kiện cả ngày hoặc trải nhiều ngày, ghi chú trước và sau buổi. Trên đó, mỗi người có **lịch trình riêng ba nấc ngày · tuần · tháng**, nhìn trước 60 ngày, kéo việc từ kho thả thẳng vào khung giờ. Có ô **"giờ rảnh của đội"** quét sẵn khung nào cả đội cùng trống. Việc riêng tư khoá ở tầng máy chủ, không chỉ giấu trên màn.

**4 · Dựng môi trường cho sự tập trung.** Hai cơ chế đứng cạnh nhau: **trần cam kết** (ba luống, CEO năm — hết luống là hết đất) chặn ở tầng cơ sở dữ liệu chứ không phải một lời nhắc trên màn hình; và **cửa sổ deep work** có đồng hồ do máy chủ đóng dấu, sàn 5 phút, trần 180 phút, giờ không khai tay được. Kết phiên đi qua **ba cửa** (xong · chưa xong · nghẽn), mở ngày đi qua **nghi thức dọn bốn cửa**. Trong phiên có **chuông tỉnh thức**: mỗi lần nhận ra mình trôi và kéo về thì bấm một tiếng — chuông luôn là điểm cộng.

**5 · Quản lý vấn đề phát sinh giữa các phòng ban.** Một vấn đề là một hàng: người nêu, phòng ban liên quan, sáu trạng thái, **đồng hồ 24 giờ** đếm ngược, mạch bàn luận phẳng theo thời gian. Chuyển sang *"chờ bên khác"* thì **bắt buộc nói câu trước, đổi trạng thái sau**. Chỉ người nêu mới đóng được vấn đề của mình. Cùng một loại vấn đề lặp đủ ba lần trong 90 ngày thì máy gợi ý sửa quy trình thay vì chữa lần thứ tư. Mọi thứ đang chờ đúng tên mình gom về một khối **Chờ bạn** duy nhất.

**6 · Bọc tất cả trong một khu vườn.** Đây không phải lớp trang trí dán lên sau — nó là **mô hình dữ liệu**, chọn từ 06/08/2026 sau khi loại năm hình tượng khác. Gieo hạt là tuyên bố một cam kết. Một task là **một cái cây**, lớn theo tổng phút tập trung thật: mầm 30′ · cây non 60′ · cây vững 120′ · tán rộng 240′. Tưới cây là một phiên deep work. Quả chín là task nộp được, mang màu của luống đẻ ra nó. Thu hoạch cả luống là đóng trọn một cam kết kèm Output. Cây **không héo khi nghỉ, không héo khi làm chưa xong** — cây chỉ héo khi người dùng tự bấm bỏ cuộc.

Đích đặt ra từ đầu là *người dùng mê app này như mê Stardew Valley* — nhưng lấy đúng cơ chế gây nghiện ấy đặt lên công việc thật, để càng mê càng không phải trốn đời. Bốn thứ chép từ Stardew, mỗi thứ có lý do: **entropy đã định liều** (hỗn loạn vừa đủ để dọn, dọn xong thấy trật tự ngay — nên có ba luống và màn dọn mỗi sáng, không bao giờ để ai đứng trước bãi 490 việc) · **không có trạng thái thua** (lỡ một ngày thì vườn chỉ chờ) · **đường cong máy tưới** (càng thành thạo càng mua lại được thời gian — việc lặp đóng gói thành quy trình thì có giàn tưới tự động) · và **0 điểm vẫn thắp một ngọn nến**.

Lớp hiển thị nông trại từng bị gác ngày 08/08 để làm xong phần xương trước, **và đang được bật lại từ 04/09** — bản đồ vườn dựng bằng Tiled, mỗi người một ngôi nhà, nhiều người thành một làng đi thăm vườn nhau được, việc cố định hiện ra thành **vật nuôi** (không cho ăn thì chúng đói). Còn nằm trong bản thiết kế chưa dựng: **cây ROVA cổ thụ** giữa làng lớn theo giờ tưới của cả đội và không bao giờ héo · **công trình làng** chỉ xây xong khi nhiều người góp nhiều *loại* quả · **bảo tàng** trưng bày vĩnh viễn mọi Output đã nộp · **bình tưới** nâng chất liệu theo độ đều đặn · **ủ phân** cho việc phải huỷ, đóng đúng cách kèm một dòng bài học — vườn không có bãi rác, chỉ có thứ chưa được ủ.

**Cạnh tranh trong vườn là cạnh tranh có luật.** Chỉ số vận hành hằng ngày **không bao giờ đem ra thi**; muốn thi thì mở một *sới chơi theo vụ* — có ngày mở, có ngày đóng, tự nguyện đăng ký, phe xáo lại mỗi vụ, bảng đua chỉ hiện tổng của phe chứ không hiện từng người, và luôn có một tầng thắng chung đứng trên tầng thắng riêng. Người thua vụ vẫn có phần. Công thức một dòng: **ganh đua thì nóng, nhưng không để lại vết lạnh.**

**Và mỗi ngày khép lại bằng một nghi thức.** *Hoàn thành* là việc đã xong; *hoàn tất* là việc đã về đúng chỗ của nó, không còn ngồi trong đầu mình điều khiển ngày mai. Nghi thức mất khoảng 90 giây: mỗi việc còn mở đi qua đúng một trong bốn cửa (xong · chưa xong kèm tiến độ · nghẽn kèm thứ chặn và việc gỡ · trả về kho), điền nốt số của việc cố định, rồi nhìn tấm gương ngày do máy chủ tính. Nền của nó là phát hiện của Masicampo & Baumeister: não không đòi việc phải **xong**, nó chỉ đòi việc phải **có chỗ** — cam kết một kế hoạch cụ thể là đủ để trả lại chỗ trong đầu.

Chuỗi bốn tầng **Dự án → cam kết → task → phiên deep work** (nối với nhau qua cột mốc của dự án) là điểm độc nhất về kiến trúc: benchmark 6 app (ClickUp, Asana, Todoist, TickTick, Sunsama, Motion) cho thấy mỗi app chỉ giữ được hai tầng liền nhau. Hệ quả là mỗi giờ đổ vào đều truy ngược được lên tới mục tiêu mà nó phục vụ.

## Nguyên lý

App này không dựng từ một danh sách tính năng hay. Nó dựng từ bốn nguyên lý, và mỗi ô trạng thái trong app là một chỗ nguyên lý được đóng thành luật — không phải một nút bấm cho đẹp. Bốn trụ đi từ trong ra ngoài: **một tâm trí → một giờ làm việc → một lời hứa → một doanh nghiệp.**

### Trụ 1 · Tỉnh thức là năng lực nhận ra mình đã trôi — không phải năng lực không trôi

Đây là chỗ cái tên của app đến từ.

Trôi là **mặc định sinh học của não**, không phải lỗi cá nhân: Killingsworth & Gilbert đo trên 250.000 điểm dữ liệu (*Science*, 2010) và thấy con người dành **46,9% số giờ thức** để nghĩ về thứ khác với việc đang làm. Nên đo sự xao nhãng là đo một hằng số — vô nghĩa. Thứ thật sự biến thiên giữa người này với người kia là **khoảnh khắc nhận ra**.

Nghiên cứu fMRI của Hasenkamp (*NeuroImage*, 2011) cho thấy chú ý chạy theo một vòng bốn pha: ① trôi → ② **nhận ra** → ③ kéo chú ý về → ④ giữ mạch. Người thiền trong thí nghiệm **bấm một cái nút** đúng vào pha ②. Pha ② là pha quý nhất, và nó là một sự kiện rời rạc, **đếm được**.

Vì vậy trong app, mỗi lần bạn nhận ra mình đang trôi và kéo mình về, bạn bấm **một tiếng chuông** — đúng cú bấm nút trong thí nghiệm ấy. Từ đó suy ra ba luật cứng:

- **Chuông luôn là điểm cộng, không bao giờ là điểm trừ.** App không đo sự xao nhãng của bạn; app đếm số lần tánh biết của bạn bật lên.
- **Chuông vĩnh viễn không vào công thức chấm điểm ngày.** Nếu chuông có điểm, thì muốn số đẹp phải trôi nhiều — thước đo tự huỷ.
- **Chỉ số của chuông là mạch tập trung** (khoảng cách giữa hai tiếng), và nó chỉ so **mình tuần này với mình tuần trước**, không bao giờ so người với người.

Nền tri thức của chính vault ROVA gọi cái đó là **tánh biết — thứ luôn có sẵn, chỉ cần nhận ra, không phải thứ phải tạo ra.**

### Trụ 2 · Hỗn loạn là trạng thái mặc định của tâm trí, và deep work là cách kiến tạo trật tự

Csikszentmihalyi đặt tên cho trạng thái mặc định ấy: **psychic entropy — hỗn loạn tâm trí**. Không được huấn luyện, đầu óc không giữ nổi một dòng suy nghĩ quá vài phút và trôi về phía thứ gây đau. Dòng chảy là trạng thái ngược lại, mà ông gọi là **negentropy**.

Đây là lý do đề bài của app **không phải là quản lý thời gian**. Đặt nó thành bài toán kỷ luật là thua ngay ở đề: kỷ luật bắt một người dùng ý chí đối lại cả một ngành công nghiệp được trả tiền để lấy sự chú ý của họ — và Hofmann & Baumeister (205 người, 7.500 mẫu) đo được rằng cưỡng lại internet chỉ thành công khoảng **50%**, tức là trò sấp ngửa. Đặt nó thành bài toán **chủ quyền** thì lời giải khác hẳn: **thiết kế lại địa hình**, đừng luyện ý chí.

Và entropy chính là **nguyên nhân mẹ** của cả bốn nguyên nhân gốc ở mục *Giải cái gì*: việc dở không có chỗ nằm là entropy ở tầng bộ nhớ làm việc · sự chú ý bị bán đi là entropy được bơm vào có chủ đích · việc dồn về người giỏi nhất là entropy ở tầng tổ chức. Một câu: **hệ nào không được áp cấu trúc thì trôi vào hỗn loạn, và cấu trúc không tự sinh.**

Deep work là cấu trúc ấy ở tầng một giờ làm việc. Newport định nghĩa nó là *"tập trung không xao nhãng, đẩy năng lực nhận thức tới giới hạn, tạo ra giá trị mới và khó sao chép"*, rồi cho một công thức là **phép nhân**:

> **Thành quả chất lượng cao = Thời gian × Cường độ tập trung**

Phép nhân, không phải phép cộng — một vế bằng 0 thì tích bằng 0. Vế đội ROVA thiếu chưa bao giờ là giờ; là cường độ. Và app mở rộng nó thành công thức riêng:

> **Sự chắc chắn = Mục tiêu rõ × Khung thời gian đã định × Thực thi tập trung**

Đây là lý do app **bắt chọn một task trước khi đồng hồ được phép chạy**. Không phải thủ tục — đó là vế thứ nhất của phép nhân.

Hai con số dùng để thiết kế, không phải để hô hào: **trần khoảng 4 giờ sâu mỗi ngày** (người mới chừng 1 giờ là kịch; nhóm violin ưu tú của Ericsson chừng 3,5 giờ chia hai khối) — nên đừng thiết kế lịch cho 6–8 giờ sâu. Và **23 phút** là thời gian trung bình để quay lại việc cũ sau một lần bị ngắt (Gloria Mark).

Sau cùng là câu của Winifred Gallagher, thứ nâng deep work từ chuyện năng suất lên chuyện sống: ***bạn là tổng của những gì bạn chú ý.*** Mỗi phiên tập trung không chỉ tạo ra sản phẩm — nó chọn chất liệu mà tâm trí bạn dùng để dựng nên chính bạn. Đó là lý do cây trong vườn **chỉ lớn bằng giờ làm việc thật**, không có hệ số nhân nào: nếu cây lớn được bằng cách khác thì con số đo mất nghĩa, và thứ đang lớn không còn là bạn.

### Trụ 3 · Tuyên bố → nguyên vẹn → vận hành được → hiệu suất

Trụ này đứng trên bài báo học thuật *Integrity: A Positive Model* (Erhard – Jensen – Zaffron, Harvard Business School), sách *The Three Laws of Performance* (Zaffron – Logan), và bộ tài liệu đào tạo của chính ROVA.

**Bước 0 — một cam kết là một lời tuyên bố, không phải một dòng ghi chú.** Có hai cách dùng ngôn ngữ. **Mô tả** được chấm bằng độ chính xác, nên nó buộc phải neo vào cái đã tồn tại — bạn không thể mô tả chính xác một thứ chưa có. Hệ quả là khi hướng ngôn ngữ mô tả về phía trước, thứ duy nhất nó xuất ra được là phép ngoại suy của quá khứ: **tương lai mặc định**. **Tuyên bố** thì khai sinh cái chưa có, ngay tại thời điểm phát ngôn — như lời thệ nguyện tạo nên một cuộc hôn nhân ngay khi thốt ra. Gieo một cam kết trong app là một hành vi tuyên bố, và đó là lý do nó phải công khai, phải có tên, có số, có hạn.

**Bước 1 — integrity không phải đạo đức, nó là yếu tố sản xuất.** Ẩn dụ gốc là một bánh xe: rút nan hoa thì bánh xe không còn nguyên vẹn. Bánh xe không "thiếu trung thực" — nó chỉ thiếu nan hoa. Với con người, nan hoa chính là **lời** của người đó. Bài báo nói thẳng cái giá của việc phân loại sai:

> Khi được giữ như một đức tính thay vì như một yếu tố sản xuất, sự nguyên vẹn rất dễ bị hy sinh mỗi khi có vẻ như một người hay một tổ chức buộc phải làm vậy để thành công.

Đức tính là thứ người ta tự hào khi có và tặc lưỡi khi mất. Yếu tố sản xuất thì khác — không ai "hy sinh nguyên liệu để kịp đơn hàng".

**Bước 2 — thác đổ một chiều.** Nguyên vẹn → vận hành được → thành quả. Bất kỳ suy giảm nào ở nấc trước cũng là suy giảm ở nấc sau. Nhưng phải nói cho đúng, và đây là chỗ dễ hứa quá tay: **giữ lời không sinh ra thành quả.** Nó chỉ mở rộng tập cơ hội để thành quả có thể xảy ra. Cách nói đúng là: *mất cam kết thì cái giá phải trả là số phương án khả dĩ của cả đội thu hẹp lại.*

**Bước 3 — và đây là viên ngọc, thứ khiến mô hình dùng được trong đời thực.** Nếu integrity nghĩa là *luôn giữ đúng lời*, thì mọi người tham vọng đều tự động là kẻ thất tín, và định nghĩa tự huỷ:

> Một người luôn luôn giữ được lời gần như chắc chắn đang sống một cuộc đời quá nhỏ. Tuy nhiên, **trân trọng** lời của mình thì luôn luôn khả thi.

Trân trọng lời có hai vế, và là mệnh đề **VÀ** chứ không phải HOẶC: ① giữ lời, đúng hạn — **hoặc**, khi đã hụt vế một thì ② **ngay khi biết** mình sẽ không giữ được, nói với **mọi người bị ảnh hưởng** rằng mình sẽ không giữ được, rằng mình sẽ làm vào lúc nào hoặc sẽ dừng hẳn, và mình sẽ làm gì để dọn hậu quả cho họ.

Ba hệ quả đi thẳng vào thiết kế app:

- **Mốc phát sinh nghĩa vụ là lúc BIẾT, không phải lúc ĐẾN HẠN.** Nên trong app, cờ báo sớm mang chữ **"đã báo"**, không mang chữ "trễ", và nó được **đếm cộng**.
- **Nút "tôi sẽ không kịp" phải rẻ về mặt tâm lý.** Nếu báo trễ bị đối xử như thú tội thì cả hệ chuyển sang chế độ im lặng, và mình mất luôn dữ liệu — thứ duy nhất khiến hệ thống có ích. Trọng lực không chê bạn xấu khi bạn ngã; nó chỉ báo rằng bạn đã ngã.
- **Im lặng gây hụt y như thất hứa.** Một kỳ vọng không được từ chối tường minh gây hại **y hệt** một lời hứa bị bỏ. Từ đó có luật bốn hồi đáp hợp lệ trước một yêu cầu — nhận · từ chối · chào ngược · hẹn giờ trả lời cụ thể — và **im lặng bằng đã nhận**. Nhưng luật này **chỉ chạy một chiều**: kỳ vọng chưa nói ra của cấp trên **không phải là lời** của cấp dưới, nên hệ thống không được biến nó thành nợ.

Có một dữ liệu ngược chiều đáng chú ý: Bitner, Booms & Tetreault (1990, *Journal of Marketing*) đo được **23,3%** trải nghiệm hài lòng lại đến từ việc xử lý chuẩn mực một lần **thất bại** trong cam kết cốt lõi. Nói cách khác, một cú trượt được xử lý tử tế dựng được niềm tin lớn hơn cả một chuỗi giữ lời trơn tru.

⚠️ **Một cảnh báo về con số, để bản này trung thực:** tài liệu đào tạo nội bộ có câu *"Integrity có thể tạo đột phá 100% đến 500%"*. Con số đó **đứng trơ một mình, không tên nghiên cứu, không tác giả, không năm** — và bài báo học thuật gốc tự thừa nhận rằng bằng chứng thực nghiệm chính thức **vẫn chưa được tạo ra**. Toàn bộ mô hình là định tính và thứ tự, không hệ số. Chúng tôi không dùng con số ấy.

Cuối cùng, chẩn đoán mà cả app này được xây để chữa — yếu tố duy nhất trong danh sách của bài báo **xử lý được bằng công cụ** thay vì bằng thay đổi nhận thức:

> Một nguồn gốc lớn của việc người ta không trân trọng lời mình là: đến lúc phải thực hiện, lời của họ **không còn hiện diện** với họ theo một cách cho họ cơ hội đáng tin cậy để trân trọng nó.

Câu hỏi đóng lại cả bài báo là: ***"Lời của tôi ở đâu khi đến lúc tôi phải giữ nó?"*** — và một app quản lý cam kết chính là một câu trả lời cho nó. Nhưng câu trả lời cần đủ ba phần, không phải một: **bước kế tiếp cụ thể · hạn hoàn thành · và một khoảng thời gian thật đã đặt chỗ trong lịch.** Thiếu phần thứ ba thì cam kết vẫn chỉ là một dòng chữ nằm chờ — đó là lý do app có tầng lịch trình, không chỉ có danh sách.

### Trụ 4 · Dòng chảy không có hướng chỉ là tốc độ

Mười hai người cùng vào phiên sâu mỗi sáng vẫn có thể là một đội đứng yên, nếu mười hai mũi tên chỉ mười hai hướng. Đây chính là entropy của Trụ 2 ở quy mô tổ chức: **một tổ chức không có chồng mục tiêu chung là một ý thức tập thể không có cấu trúc.**

Khung nền là **OGSM** — **O**bjective (định tính) → **G**oal (số hoá) → **S**trategy → **M**easure, ép sự nhất quán dọc trên một trang: không hành động nào mồ côi, không mục tiêu nào thiếu cách đạt. Cộng thêm ba thứ đã nạp từ nguồn có tên: **Locke & Latham** (*American Psychologist* 2002 — hơn 40.000 người, cỡ hiệu ứng d = 0,42–0,80, kèm hai điều kiện hay bị quên là **cam kết với mục tiêu** và **phản hồi cho thấy tiến độ**) · **Rocks** của Wickman (3 tới 7 ưu tiên mỗi kỳ, mỗi ưu tiên đúng một chủ; quá 7 là không còn ưu tiên nào) · và phân biệt **lead / lag**: kết quả là thứ biết thì đã xong, hành động mới là thứ bấm được hôm nay.

Chồng mục tiêu trong app có **bốn tầng, một hướng**:

| Tầng | Hình dạng |
|---|---|
| ① Mục tiêu doanh nghiệp | Động từ, **không có số** |
| ② Mục tiêu phòng ban | Danh từ, có số, có hạn |
| ③ **Cam kết cá nhân** | Gói trong một tuần, trần ba chỗ (CEO năm) |
| ④ Task | Ngồi một buổi là xong |

Hai luật sắc nhất của tầng này:

- **Một cam kết chỉ được đứng dưới đúng một mục tiêu còn sống.**
- **Cam kết là bức ảnh chụp thế giới lúc xong, không phải một hành động.** Đọc lên mà hỏi *"xong chưa"* thì phải trả lời được CÓ hoặc KHÔNG dứt khoát. *"Cải thiện CRM"* không phải cam kết; *"2.435 dòng CRM có trạng thái công nợ"* mới là.

❓ **Chỗ trống phải nói thẳng:** ROVA **chưa viết ra thành văn bản mục tiêu tháng của công ty**, nên tầng ① hiện còn trống trong dữ liệu thật. Chưa có trang đó thì mọi tính năng của tầng mục tiêu là kệ sách chờ sách.

**Chữ KR trong sơ đồ luồng đến từ OKR** (Objectives and Key Results — *Mục tiêu và Kết quả Then chốt*), khung của John Doerr, gốc từ Andy Grove ở Intel và trước đó là quản trị theo mục tiêu của Drucker. Công thức của nó gọn đúng một dòng: **"Tôi sẽ ⟨Mục tiêu⟩, đo bằng ⟨các Kết quả then chốt⟩."** Mục tiêu trả lời câu *cái gì*, Kết quả then chốt trả lời câu *thế nào* — và Kết quả then chốt thì **không có vùng xám**: đạt hoặc không đạt, không có chỗ cho nghi ngờ.

Ba luật của OKR đi thẳng vào thiết kế app này, và cả ba đều trùng với thứ app đã làm trước khi nạp nguồn:

- **OKR không bao giờ gắn với lương thưởng.** Trang chính chủ dùng đúng chữ *độc hại* cho việc buộc mục tiêu vào tiền thưởng, và nêu năm lý do — đứng đầu là **người ta sẽ đặt vạch thấp cho chắc ăn**, kế đó là nó giết hợp tác vì *"thay vì cùng chèo một hướng, thành mạnh ai nấy lo"*. Đây chính là lý do app không có bảng quy đổi điểm ra tiền.
- **Điểm ngọt là 0,6–0,7 trên thang 0–1,0**, không phải 1,0. Ai liên tục đạt trọn thì đó không phải tin vui — đó là dấu hiệu vạch đặt chưa đủ cao. Một thước đo mà **đạt trọn là điều đáng ngờ** thì không được bày như thanh tiến độ chạy tới 100% rồi ăn mừng.
- **Một Kết quả then chốt bị trượt báo hiệu một chỗ trục trặc trong cả kế hoạch — đó là cơ hội chỉnh hướng, không phải dịp phán xét hay trừng phạt một con người.** Câu này của Doerr và luật *"nói về việc, không nói về người"* của app là cùng một điều, nói bằng hai giọng.

Và OKR phân biệt hai loại mục tiêu có kỳ vọng khác hẳn nhau — **đã cam kết** (phải đạt 1,0; trượt thì báo lên ngay) và **khát vọng** (0,7 là tốt, trượt là chuyện được lường trước, thất bại được tôn vinh như một nỗ lực đáng nể). Dán nhầm nhãn giữa hai loại là lỗi số một của cả hệ.

*Quan hệ với OGSM: OGSM ép cả kế hoạch lên một trang có chiến lược, ngân sách và người chịu trách nhiệm; OKR nhẹ hơn, lặp nhanh hơn, và có luật chấm điểm rõ. Dùng chung được — **OGSM cho năm, OKR cho quý**.*

⚠️ *Bậc nguồn của cụm OKR trong vault hiện là **bậc 2*** — chắt từ trang chính chủ của Doerr và tài liệu chính thức của Google, chưa phải từ sách gốc. Ba chỗ hai nguồn chính chủ **nói lệch nhau** (số siêu năng lực 4 hay 5 · số Mục tiêu tối đa · năm mang OKR sang Google là 1998 hay 1999) đã được ghi thẳng trong trang wiki thay vì chọn bừa một bên.

### Luồng của một việc — sáu chặng

Bốn trụ trên trả lời câu **vì sao**. Sơ đồ dưới trả lời câu **một việc đi qua những chặng nào**, và mỗi chặng chỉ ngược về đúng trụ đứng sau nó:

| # | Chặng | Chuyện gì xảy ra | Trụ đứng sau |
|---|---|---|---|
| ① | **Sinh ra** | Việc vào hệ qua đúng **bốn cửa**: từ một mục tiêu · từ nhịp lặp · từ việc phát sinh (qua bộ lọc 15 phút) · từ một ý tưởng (chờ buổi duyệt, không chen ngang). *Việc lặp từ ba lần trở lên thì nó là nhịp, không phải task.* | Trụ 4 |
| ② | **Viết và gieo** dưới một cam kết | Cam kết viết theo dạng *danh từ + số + hạn*; task viết theo dạng *làm gì, xong lúc nào* — một động từ, ước lượng được 30 đến 120 phút | Trụ 3 · ngôn ngữ tuyên bố |
| ③ | **Vào ngày** | Task lên màn *Hôm nay* kèm thời lượng dự kiến. Ước không nổi nghĩa là còn quá to, chia nhỏ tiếp | Trụ 3 · lời hứa cần một khoảng thời gian thật trong lịch |
| ④ | **Phiên deep work** | Đồng hồ đếm lên, sàn 5 phút trần 180 phút, kết thúc phải đi qua **một trong ba cửa** — không có cửa kết thúc mơ hồ | Trụ 1 và Trụ 2 |
| ⑤ | **Nghi thức hoàn tất** | Cuối ngày, tự tay chốt từng việc. Mỗi ô có **một câu bắt buộc phải khai**, máy chủ đá về nếu để trống. *Người tự chốt thì sáng mai đi thẳng vào việc; để máy đoán thì sáng phải dọn* | Trụ 3 · sự hoàn tất |
| ⑥ | **Nghiệm thu** | Đóng cam kết **bắt buộc có output bằng chữ**. Người ký *đã nhận* là cấp trên trực tiếp, **luôn khác chủ cam kết** — không ai tự chấm mình xong | Trụ 3 · lời được trao cho người khác |

Ba nhánh rẽ, mỗi nhánh là một nguyên lý được đóng thành luật:

- **Nghẽn — cha vẫn sống.** Khai tên thứ đang chặn, app sinh một **task con gỡ nghẽn** đứng cạnh; task cha giữ nguyên ô *nghẽn* chứ không đóng lại.
- **Đổi hướng — con thay cha.** Chia nhỏ hoặc đổi cách làm thì sinh task con thay thế, cha đóng ở ô *đã chuyển* và **bắt buộc phải có con**. Đổi hướng không đi qua cửa huỷ — vì gộp cả đổi hướng vào con số huỷ thì con số ấy trộn ba chuyện khác nhau rồi mất nghĩa.
- **Biết mình sẽ trễ.** Làm ngay **lúc biết**. Dời hạn thì máy chủ tự đếm số lần và số ngày trượt so với hạn gốc.

### Bốn luồng việc của doanh nghiệp

Một sơ đồ thứ hai, nhìn từ chỗ đứng của công ty thay vì của một việc. Bốn nguồn nước, một hợp lưu:

| Luồng | Nhịp | Đường đi |
|---|---|---|
| **① Mục tiêu** | quý, tháng | Mục tiêu cấp công ty → *(đàm phán CEO và leader)* → mục tiêu phòng ban, mỗi cái một phòng gánh chính → *(đàm phán leader và nhân sự)* → **kết quả then chốt cá nhân tự nhận, tự viết** → task |
| **② Nhịp vận hành** | ngày, tuần | Của từng **vị trí** → dòng checklist ngày kèm mục tiêu và đơn vị đo → điền số trước 24h |
| **③ Phát sinh** | bất kỳ | Việc đột ngột đến → **bộ lọc 15 phút** (làm luôn hay ghi vào bảng) → task lẻ |
| **④ Ý tưởng** | theo buổi duyệt | Ý tưởng, đề xuất → phiếu đề xuất → buổi duyệt → thành dự án · để lại chờ · hoặc loại bỏ |

Bốn luồng ấy đổ vào **đúng ba khối** mà app đang có ở màn *Hôm nay*: 🌳 **cây** (việc luồng ①, làm bằng phiên deep work) · 💧 **tưới nước và làm cỏ** (checklist luồng ②, điền số mỗi ngày) · 🪴 **chậu lẻ** (việc luồng ③). Rồi vòng phản hồi đi ngược lên: báo cáo ngày → họp tuần → duyệt danh mục tháng → chỉnh lại mục tiêu và quy trình ở đầu các luồng.

Điểm đáng chú ý nhất trong sơ đồ này là chữ **tự nhận, tự viết** ở luồng ①. Mục tiêu chảy xuống bằng **đàm phán**, không bằng mệnh lệnh — vì một cam kết bị giao xuống thì không phải một lời tuyên bố, và theo Trụ 3, nó không tạo ra integrity nào cả.

### Bằng chứng đứng sau từng cơ chế

| Cơ chế trong app | Nghiên cứu |
|---|---|
| Chuông tỉnh thức là điểm cộng | Hasenkamp và cs., fMRI, *NeuroImage* 2011 — vòng bốn pha, pha **nhận ra** là pha quý nhất |
| Không xấu hổ vì bị trôi | Killingsworth & Gilbert, *Science* 2010 — tâm trí lang thang **46,9%** giờ thức |
| Đo giờ sâu liền mạch, không đo giờ ngồi | Leroy 2009 — dư âm chú ý: đổi việc khi việc cũ còn dở thì một phần chú ý kẹt lại |
| Nghi thức dọn việc và ba cửa ra | Gloria Mark — trung bình **23 phút** để quay lại việc sau một lần bị ngắt |
| Nghi thức hoàn tất | Masicampo & Baumeister — não không đòi việc **xong**, chỉ đòi việc **có chỗ** |
| Cây lớn dần, lưới nhiệt tiến bộ | Amabile & Kramer — 12.000 trang nhật ký, 238 người, 7 công ty |
| Cam kết phải có output rõ và hạn rõ | Gollwitzer & Sheeran 2006 — ý định thực thi, **d = 0,65** trên 94 phép thử |
| Trần ba luống, mục tiêu rõ | Locke & Latham 2002 — hơn 40.000 người, **d = 0,42–0,80** |
| Trần 180 phút một phiên, nghỉ chủ động | Ericsson qua Newport — trần khoảng **4 giờ sâu** mỗi ngày; Viện Não Paris 2022 |
| Chuỗi ngày không trừng phạt | Lally (UCL) — bỏ lỡ một ngày **không gây hại đo được** |
| Mọi câu chữ nói về việc, không nói về người | Kluger & DeNisi 1996 — 607 hệ số hiệu ứng, phản hồi hướng vào **người** có **38%** khả năng làm hiệu suất giảm |

**Hai nguồn đã bị lật, chúng tôi cố ý không viện dẫn lại:** *hiệu ứng Zeigarnik* — phân tích tổng hợp 2025 soi 59 công trình, không thấy lợi thế trí nhớ cho việc dang dở · và *transient hypofrontality* — tổng quan hệ thống trên *Cortex* 2022 (25 nghiên cứu, 471 người) cho thấy vùng trán vẫn giữ vai trò then chốt. Nêu ra vì nó cho thấy bộ nguyên lý này được **sàng**, không phải gom bừa cho nhiều.

## Cố tình không làm

Mỗi dòng dưới đây là một ranh giới có lý do, không phải một việc chưa kịp làm:

- **Không có bảng xếp hạng cá nhân hằng ngày.** Hydari và cs. 2023 (*Management Science*): bảng xếp hạng làm người ít vận động tăng 1.300 bước nhưng người **đã đang làm tốt giảm 630 bước** — nó hại đúng nhóm mình cần giữ. Trong một công ty lại không có cửa "rời nhóm" như app sức khoẻ.
- **Không có chuỗi trừng phạt kiểu trượt một ngày mất tất cả.** Chỉ 0,90% người đứt chuỗi quay lại.
- **Không có bảng quy đổi điểm ra tiền.** Có tỉ giá thì mọi quả đổi nghĩa từ *kết quả của tôi* thành *đơn vị lương* — hiệu ứng biện minh quá mức.
- **Không thưởng điểm cho hành vi thêm một task** (Todoist làm vậy). 490 task gõ lại chính là bệnh gốc; thưởng nó là thưởng đúng cái đang gây hại.
- **Không có ma trận ưu tiên bốn ô.** Không có nghiên cứu thực nghiệm đứng sau, và ba luống đã mạnh hơn.
- **Không cho quản lý xem điểm số của từng cá nhân.** Kluger & DeNisi 1996 (607 hệ số hiệu ứng, 23.663 quan sát): phản hồi kéo chú ý về phía NGƯỜI thay vì về VIỆC có **38%** khả năng làm hiệu suất giảm. Leader thấy luống và cờ báo sớm, không thấy từng phút.
- **Không phạt việc rời app.** Chỉ đếm giờ. Thất bại lớn nhất của một app năng suất là làm người dùng sợ mở nó ra.
- **Không mở bán cho công ty ngoài trong phiên bản này.** Làm cho xong ca ROVA đã.

*Đang gác có chủ đích, dữ liệu giữ nguyên để bật lại:* lớp hiển thị giao diện nông trại · cỏ dại khi bỏ bê · nối Google Calendar.

## Đang chạy thật tới đâu

Số rút từ bản sao dữ liệu ngày **05/09/2026**, không phải ước lượng:

| Số đo | Giá trị |
|---|---|
| Người dùng thật | **7**, trong đó 6 người đã chạy phiên deep work |
| Phiên deep work | **401 phiên**, ~**378 giờ**, trải 31 ngày (05/08 → 05/09) |
| Giờ do máy chủ đóng dấu | **389/401 phiên** — chỉ 12 phiên khai tay (3%) |
| Độ dài trung bình một phiên | **72 phút** — dài gấp gần ba lần khung Pomodoro 25 phút |
| Giờ sâu trung vị, mỗi người mỗi ngày có làm | **3,0 giờ** (so với mốc đau 2,3 giờ ban đầu) |
| Chuông tỉnh thức đã bấm | **426** |
| Cam kết đã gieo | **60**, đóng xong 35, có Output nộp 28 |
| Cam kết được dời hạn công khai | **14 cam kết / 17 lần** — tức cơ chế báo sớm đang được dùng thật, không phải nằm im |
| Task | **400**, xong 338 |
| Cửa ra khi kết phiên | xong 193 · chưa xong 92 · **nghẽn 5** |

Dòng đáng đọc nhất trong bảng là dòng **dời hạn**: nó cho thấy vế "báo sớm và lập hạn mới" đang có người dùng thật, chứ không chỉ có trong tài liệu thiết kế.

## Chạy ở đâu

| Tầng | Dùng gì |
|---|---|
| Giao diện | Một file HTML tĩnh trong `public/` — 38.729 dòng, 1.204 hàm, 13 màn |
| Cơ sở dữ liệu | Supabase (Postgres) — **30 bảng, 19 khung nhìn**, 80 hàm, 53 trigger; RLS bật trên cả 30 bảng |
| Đăng nhập | Google OAuth, đối chiếu danh sách trắng email trong bảng `nguoi` |
| Phát hành | Đẩy nhánh `main` → Cloudflare Workers tự phát hành, chỉ `public/` ra web |
| Bộ thử | 53 tệp `thu-*.js`, 457 câu khẳng định — chạy từng tệp bằng `node` |

*(Con số cơ sở dữ liệu đếm từ 87 tệp `.sql` trên đĩa; chưa đối chiếu trực tiếp với máy chủ sống.)*

## Chạy tại máy

App là **một file HTML tĩnh** — không có bước dựng, không có `node_modules`, không có `package.json`.

```
git clone https://github.com/tranmaitranghup-star/khu-vuon.git
cd khu-vuon
python3 phuc-vu.py            # mở http://localhost:8082
```

`phuc-vu.py` là đường lui cho `python3 -m http.server` — trên máy chủ dự án, lệnh sẵn có của Python ngã ngay lúc dựng bộ đọc tham số vì `os.getcwd()` bị chặn quyền, và ngã trước khi kịp truyền `--directory` nên không tham số nào cứu được. Script này khai thẳng thư mục gốc để đi vòng chỗ đó. Mặc định cổng 8082, thư mục `./public`.

Mở như thế là **thấy được giao diện**, nhưng chưa có dữ liệu — app cần một cơ sở dữ liệu Supabase phía sau và một tài khoản nằm trong danh sách trắng.

Dựng bản đầy đủ thì cần một project Supabase: chạy `schema.sql` để có 8 bảng nền, rồi chạy các tệp `nang-cap-*.sql` theo thứ tự thời gian để lên đủ **30 bảng và 19 khung nhìn**, bật đăng nhập Google, rồi điền `SUPABASE_URL` và `SUPABASE_ANON_KEY` vào đầu phần `<script>` của `public/index.html`. Từng cú bấm nằm trong `HUONG-DAN-TRIEN-KHAI.md`. Mọi địa chỉ email trong các tệp này là chỗ giữ chỗ dạng `<ten>@vidu.com` — thay bằng email thật của đội bạn ở bảng `nguoi`.

## Bản đồ kho

**200 tệp, 10 MB** — và gần như tệp nào cũng đáng đọc. Kho này không mang theo tài nguyên hình ảnh, nên thứ còn lại đều là mã, tài liệu, hoặc bài thử:

| Nơi | Số | Là gì |
|---|---:|---|
| `public/` | 34 | **Toàn bộ thứ chạy được.** `index.html` là app; `vendor/` giữ thư viện và font, **0 tên miền ngoài** |
| gốc kho | 166 | **87** tệp `.sql` (một tệp = một lần nâng cấp cơ sở dữ liệu, đọc theo thứ tự là thấy cả lịch sử thiết kế) · **59** bài thử · **10** tệp `.md` tài liệu · 10 tệp sơ đồ, cấu hình và script |

Mười tệp tài liệu: `spec.md` · `DOC-TRUOC.md` · `CAU-TRUC-APP.md` · `BAN-DO-INDEX.md` · `ho-so-khu-vuon-cho-ai.md` · `giai-phap-khu-vuon-tinh-thuc.md` · `HUONG-DAN-TRIEN-KHAI.md` · `dac-ta-van-de-lien-phong.md` · `LUAT-LAN.md` · `DANG-LAM.md`.

⚠️ **`public/index.html` là một app trong một tệp: 2,42 MB, 38.729 dòng, 1.204 hàm — đừng mở trọn nó.** Tra `BAN-DO-INDEX.md` lấy số dòng rồi đọc đúng khúc cần. Đây là lựa chọn có chủ ý chứ không phải nợ kỹ thuật: không bước dựng, không `node_modules`, mở tệp là chạy.

Ba thứ **cố ý không có trong kho này**: bộ ảnh sprite nông trại (tài sản mua của bên thứ ba, chưa rõ giấy phép phát hành lại) · bản đồ vườn dựng bằng Tiled · và thư mục lưu trữ tài liệu đã hết hiệu lực.

## Bộ thử

**59 bài thử — đạt 58/59, và không bài nào chết lúc khởi động.**

```
./chay-bo-thu.sh              # chạy trọn 59 bài, in "đạt x/59"
node thu-cu-phap.js           # hoặc chạy lẻ một bài
```

Con số **0 bài chết** đáng nói riêng một câu, vì một bài chết lúc khởi động thì mọi ca bên trong nó **im lặng biến mất** khỏi kết quả — nguy hơn hẳn một ca đỏ, vốn ít nhất còn kêu lên. Vì cùng lý do đó, bộ chạy đếm bằng **mã thoát** chứ không quét ký hiệu trong màn hình: có bài in dấu `✗` ngay trong phần mô tả, nên lối quét theo ký hiệu từng bỏ sót nguyên một bài đang hỏng.

Bài duy nhất chưa xanh là `thu-van-de.js`, đạt **128 trong 129 ca**.

Điểm đáng nói về cách viết: mỗi bài **tự cắt khối mã gốc ra từ `index.html`** rồi chạy trên đúng khối đó. Nghĩa là bài thử không bao giờ trôi khỏi bản mã thật — sửa app mà quên sửa bài thử thì bài thử gãy ngay, chứ không lặng lẽ kiểm một bản chép cũ.

Bài đáng chạy đầu tiên là `thu-cu-phap.js`: nó soát cú pháp mọi khối `<script>` trong app, chặn lỗi dấu tiếng Việt trong chú thích, và soát những chữ bị cấm dùng trong giao diện.

## Chỗ còn hở

Ghi thẳng, vì một README giấu chỗ hở thì không dùng được để ra quyết định:

- **Sao lưu là chỗ đau nhất.** Supabase gói Free không giữ bản dự phòng nào; bản sao chạy tay bằng một script nằm ngoài kho này, và mới phủ 12 trong 30 bảng — **18 bảng chưa có bản sao nào**.
- **Đường giao cam kết chưa ai thử tay với dữ liệu thật** — mọi làn mới soi tới mức giao diện.
- **Lớp vấn đề liên phòng ban đã lên sóng ở phần mã nhưng chưa được kích hoạt trên máy chủ** — giao diện đã có, tầng dữ liệu thì chưa bật.
- **Chuông tỉnh thức hiện không phát ra tiếng** — nút câm, mới đếm số lần bấm.
- App mới hiện thực hoá khoảng **42% (22/52)** số cơ chế của bản giải pháp đầy đủ. Chỗ trống lớn nhất: **chưa có luật nào ràng buộc người GIAO việc** — cả tám triết lý hiện chỉ ràng buộc người nhận.

## Tài liệu

| File | Nội dung |
|---|---|
| `spec.md` | Spec một trang — bảy mục |
| `ho-so-khu-vuon-cho-ai.md` | Hồ sơ toàn cảnh: triết lý, thiết kế, tầng kỹ thuật |
| `CAU-TRUC-APP.md` | Bốn mục, flow năm cấp, và bộ luật trình bày giao diện |
| `kien-truc-app.html` | Sơ đồ kiến trúc, mở bằng trình duyệt |
| `nguyen-ly-va-kien-truc.html` | **Bản vẽ một trang**: bốn trụ nguyên lý nối xuống tên bảng và tên trigger thật, vòng đời một việc qua sáu chặng, bốn luồng việc hợp lưu |
| `so-do-luong-task.html` | Sơ đồ luồng một task đi qua hệ thống |
| `giai-phap-khu-vuon-tinh-thuc.md` | Tám triết lý, mỗi cái có nguyên lý · bằng chứng · công thức · bảng tính năng |
| `BAN-DO-INDEX.md` | Bản đồ hàm của `public/index.html` — tra trước, đọc sau |
| `HUONG-DAN-TRIEN-KHAI.md` | Các bước dựng lần đầu — Supabase, Google OAuth, phát hành |
| `schema.sql` | Lược đồ gốc (8 bảng nền — xem cảnh báo ở mục *Chạy tại máy*) |
| `.env.example` | Tên các biến môi trường, không chứa giá trị nào |

Đọc theo thứ tự này là nhanh nhất: `spec.md` để biết sản phẩm là gì → `nguyen-ly-va-kien-truc.html` để nhìn nguyên lý nối xuống cấu trúc thật → `kien-truc-app.html` để nhìn nó chạy thế nào → `ho-so-khu-vuon-cho-ai.md` khi muốn biết vì sao từng cơ chế được thiết kế như vậy.

## Luật về khoá bảo mật

- Khoá thật nằm trong `.env` (đã có trong `.gitignore`) hoặc trong trình quản lý mật khẩu — **không bao giờ trong mã**
- `SUPABASE_ANON_KEY` trong `public/index.html` là khoá **công khai** (`sb_publishable_…`), được thiết kế để nằm trong trình duyệt và có RLS bảo vệ phía sau
- Khoá `sb_secret_…` và mật khẩu cơ sở dữ liệu **không bao giờ rời khỏi máy** — không dán vào mã, không gửi qua chat
- Quét trước mỗi lần đẩy lên: `gitleaks git . --redact`
- Lộ khoá thì **xoay khoá mới**, đừng đi xoá commit

---

*Bản công khai, cập nhật 06/09/2026. Ba câu la bàn của sản phẩm: mỗi ngày mở app phải thấy vườn khác hôm qua · không trừng phạt, chỉ mời gọi · cơ chế giữ được ba tháng, câu chuyện giữ được ba năm.*
