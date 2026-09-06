---
tieu_de: Giải pháp Khu Vườn Tỉnh Thức — tám triết lý cho một hệ điều hành của sự chú ý
loai: tong-hop
ngay_tao: 2026-08-10
ngay_cap_nhat: 2026-08-11
nguon:
  - raw/rian-doris-flow/ghi-chu-chat/nhom-1.md
  - raw/rian-doris-flow/ghi-chu-chat/nhom-2.md
  - raw/rian-doris-flow/ghi-chu-chat/nhom-3.md
  - raw/rian-doris-flow/ghi-chu-chat/nhom-4.md
  - raw/rian-doris-flow/ghi-chu-chat/nhom-5.md
  - raw/rian-doris-flow/ghi-chu-chat/nhom-6.md
  - production/phan-tich-rian-doris-hieu-suat-dinh-cao.md
  - production/du-an/bai-luan-lam-viec-sau-quan-ly-cong-viec.md
  - production/du-an/dong-chay-task-rova.md
  - production/tinh-thuc-app/ho-so-khu-vuon-cho-ai.md
  - production/tinh-thuc-app/gioi-thieu-khu-vuon-coreteam.md
  - production/tinh-thuc-app/nghien-cuu-whoop-bevel.md
  - production/tinh-thuc-app/nghien-cuu-ticktick-todoist.md
  - production/tinh-thuc-app/tong-hop-nghien-cuu-khu-vuon.md
  - wiki/dac-thu-van-hanh-dn-tracy.md
  - wiki/quan-tri-van-hanh/khai-niem/su-toan-ven-integrity.md
  - wiki/quan-tri-van-hanh/khai-niem/kien-tao-cuoc-choi.md
  - wiki/tam-thuc/game-hoa/stardew-valley-phan-tich-sau.md
  - tieu-diem/G-01-quan-ly-cong-viec-rova.md
tags:
  - khu-vuon-tinh-thuc
  - giai-phap
  - rian-doris
  - lam-viec-sau
  - quan-ly-cong-viec
---

# GIẢI PHÁP KHU VƯỜN TỈNH THỨC

## Tám triết lý cho một hệ điều hành của sự chú ý

> ✅ **ĐÂY LÀ BẢN ĐẦY ĐỦ**, viết theo lệnh của Tracy ngày 11/08: *"việc 47 viết bản đầy đủ rồi bạn tự gạch"*. Tracy gạch bỏ trực tiếp trên bản này; gạch tới đâu tôi sửa tới đó. Bản khung ngày 11/08 đã được lưu tại `luu-tru/giai-phap-khu-vuon-tinh-thuc-KHUNG-2026-08-11.md` để đối chiếu.
>
> **Bốn quyết định đã nhập vào bản này so với bản khung:** ① Lưới 12 người **giữ nguyên** theo lời chốt của Tracy ngày 11/08 (*"Giữ chứ đang hay"*) — nguyên lý của Triết lý 5 đã được viết lại cho trung thực. ② Bốn câu hỏi còn lại của Phụ lục **chạy theo phương án mặc định** đúng như đã khai, chỗ nào dùng mặc định thì đánh dấu ⏳ ngay tại chỗ — Tracy gạch được. ③ Bản này chỉ ra **file .md**, không kèm HTML (*"bao giờ xuất mới cần"*). ④ Không còn chia bản V1 và V2 ở bất kỳ đâu — tính năng xử lý theo thứ tự gỡ chặn, đúng lời chốt ngày 11/08.

---

## MỞ ĐẦU

Bản này là phần **GIẢI PHÁP**. Nó nối tiếp trực tiếp bản phân tích nỗi đau và đề bài đã viết trước đó (`production/du-an/bai-luan-lam-viec-sau-quan-ly-cong-viec.md`), nơi mười hai nỗi đau được mô tả và ba bài toán lồng nhau được đặt ra. Phần trước chỉ chẩn đoán, và tự khai rõ ranh giới đó ở dòng 587 của chính nó. Phần này kê toa — nhưng kê theo trật tự Tracy đặt ngày 12/08: **Biểu hiện → Hệ quả → Nguyên nhân → rồi mới ra giải pháp**. Mục 1 vì thế không còn là bảng đối ứng nỗi-đau-với-triết-lý nữa: nó truy 12 nỗi đau về **4 nguyên nhân gốc** và chỉ ra cái lõi một câu của app — *biến cam kết thành kết quả*. Tám triết lý sau đó, mỗi cái khai rõ mình trả lời nguyên nhân nào, có một framework mang tên riêng, một công thức để tính, và một bảng tính năng nói rõ app Khu Vườn hôm nay đã hiện thực hoá được bao nhiêu phần.

Bản này đứng ở vị trí bản lề trong bộ ba tài liệu. Bản nỗi đau nói *vì sao phải làm*. Bản này nói *làm gì và theo nguyên lý nào*. Bản lộ trình tính năng và bản giáo trình đào tạo sẽ nói *làm theo thứ tự nào* — hai bản đó chưa viết, chỉ được nêu tên ở cuối, và chỉ bắt đầu sau khi Tracy gạch xong bản này.

Về nguồn. Sáu triết lý đầu rút từ kênh của **Rian Doris** — người Ireland, Thạc sĩ Khoa học Thần kinh Ứng dụng tại King's College London, đồng sáng lập và CEO của Flow Research Collective cùng Steven Kotler. Chất liệu là trọn 57 video, khoảng 215.000 từ, đã được đọc hết và kiểm chứng qua tám đợt tra cứu độc lập trong bản phân tích riêng. Hai điều phải nói thẳng về nguồn này ngay từ đầu: thứ nhất, sức mạnh thật của Doris không nằm ở phát minh — hầu hết khái niệm ông vay từ Csikszentmihalyi, Kotler, Benson, Loehr và Schwartz, Locke, Sweller — mà nằm ở chỗ ông **biến lý thuyết của người khác thành giao thức có số**: bao nhiêu phút, mấy giờ, mấy lần một tuần. Thứ hai, đây là kênh của một doanh nghiệp đào tạo, mỗi video là một cửa phễu bán hàng, và nhiều trải nghiệm nền là chuyện một người tự chữa cho mình sau tai nạn — nghĩa là cỡ mẫu một. Vì vậy mọi luận cứ trong bản này đều gắn nhãn độ tin, con số nào chỉ là kinh nghiệm cá nhân của ông thì bị loại hoặc bị dán cảnh báo, và chỗ nào tôi tự ghép thì tôi ghi là tôi tự ghép.

Hai triết lý sau — Giữ lời và Cuộc chơi, Chồng mục tiêu chung — lấy từ kho tri thức của vault, vì Doris không có tầng đó: ông dạy một người chơi đơn, còn ROVA là mười hai người chơi chung một bàn. Nền của hai triết lý này là cụm Integrity của Erhard, Jensen và Zaffron, cụm Kiến Tạo Cuộc Chơi, bộ EOS của Wickman, nhịp của Harnish, và Ba Quy Luật Hiệu Suất của Zaffron và Logan — tất cả đã được nạp vào vault từ trước, có trang riêng để tra.

Chuyển từ nỗi đau sang lời giải không phải là thêm một danh sách mẹo năng suất vào chồng mẹo đã có. Mười hai nỗi đau kia không sinh ra từ việc thiếu mẹo; chúng sinh ra từ chỗ một bộ não cổ xưa bị thả vào một môi trường được thiết kế để lấy đi sự chú ý của nó. Thứ phải dựng là **một hệ điều hành cho ý thức** — biết chọn đúng việc, biết đưa não vào trạng thái sâu, và biết lặp lại điều đó bền vững đủ lâu để nó cộng dồn. Tám triết lý dưới đây là tám thành phần của hệ điều hành ấy, và app Khu Vườn là nơi chúng hiện hình thành cơ chế. Nguyên lý không có cơ chế thì chỉ là khẩu hiệu; cơ chế không có nguyên lý thì chỉ là tính năng chờ bị lách.

---

## MỤC 0 — CÁCH ĐỌC BẢN NÀY

### 0.1. Bảy tầng của mỗi triết lý

Mỗi triết lý được viết theo đúng bảy tầng, đi từ trừu tượng xuống thứ cầm nắm được. Thứ tự này không đảo, vì mỗi tầng trả lời một câu hỏi mà tầng sau cần: không biết *vì sao đúng* thì luật rút ra là luật võ đoán, không có luật thì framework chỉ là danh sách việc, không có công thức thì không biết mình đang khá lên hay tệ đi.

| Tầng | Nhan đề | Nội dung tầng | Câu hỏi tầng đó trả lời |
|---|---|---|---|
| 1 | **Bản chất** | Phát biểu cốt lõi trong vài câu, kèm câu nguyên văn nếu có | Triết lý này nói điều gì |
| 2 | **Cơ chế** | Chuyện gì diễn ra trong não hoặc trong tổ chức khi nó đúng | Vì sao nó đúng |
| 3 | **Cơ sở khoa học** | Từng luận cứ một, gắn nhãn độ tin, kèm tác giả và cỡ mẫu | Ai đã chứng minh, và mạnh tới đâu |
| 4 | **Nguyên lý** | 4 nguyên lý rút ra, viết ở dạng luật áp dụng được | Suy ra luật gì |
| 5 | **Framework** | Một framework có tên, chia thành các bước đánh số | Làm theo trình tự nào |
| 6 | **Công thức** | Một phương trình có biến số và ngưỡng | Đo bằng gì, vặn núm nào |
| 7 | **Tính năng** | Bảng tính năng trong app, có cột trạng thái hôm nay | Nó hiện hình ở đâu |

Sau bảy tầng là **Kết luận của triết lý**, một đoạn ngắn nối triết lý đó về bài toán mà nó phục vụ và nói thẳng chỗ nó còn yếu.

### 0.2. Bốn nhãn trạng thái tính năng

| Nhãn | Nghĩa | Cách đọc |
|---|---|---|
| ✅ | Đã chạy trong app hôm nay | Có mã thật, người dùng đã chạm được |
| 🔶 | Đã duyệt hoặc đang dựng dở | Kết cấu đã chốt, mã chưa xong hoặc đang chờ một bước cuối |
| ⬜ | Chưa có | Chưa có dòng mã nào, có thể đang chờ Tracy chốt |
| ⚰️ | Đã dừng lại có chủ ý | Từng có hoặc từng được đề xuất, đã bỏ, ghi lại để không đề xuất lần nữa |

### 0.3. Ba nhãn độ tin nguồn

| Nhãn | Nghĩa | Luật dùng |
|---|---|---|
| ✅ | Có nguồn dẫn được, đã đối chiếu | Được khẳng định như dữ kiện, luôn kèm tên tác giả và cỡ mẫu |
| ⚠️ | Suy luận của người viết, hoặc nguồn tự gắn cảnh báo, hoặc con số chưa được thử nghiệm | Không được trình bày như sự thật chắc chắn |
| ❓ | Chưa xác thực, hoặc đang chờ Tracy phân xử | Nêu cả hai phía, không tự chốt |

Ngoài ra dùng 🔴 cho chỗ hụt nặng đã được bằng chứng mới lật lại, ❌ cho những con số bị loại khỏi bản này, và ⏳ cho chỗ đang **chạy theo phương án mặc định** vì Tracy chưa nói khác — gạch được.

### 0.4. Xưng hô và phạm vi

Bản này viết ở chế độ *tôi* là người viết và *Tracy* là ngôi thứ ba, vì nó là bản tư duy cho Tracy đọc và gạch — không phải bản gửi đội. Khi cần bản cho coreteam thì rút gọn từ bản này ra, đổi toàn bộ sang chế độ *mình* và *bạn* theo hồ sơ văn phong, và lấy ra những phần dành riêng cho tầng điều hành (toàn bộ Mục 10, các đoạn nói về quyền của người giao việc, và mọi số liệu hành vi có tên người).

---

## MỤC 1 — CHUỖI NHÂN QUẢ: TỪ BIỂU HIỆN VỀ NGUYÊN NHÂN CỐT LÕI

> Khung của mục này do Tracy đặt ngày 12/08: **Biểu hiện → Hệ quả → Nguyên nhân → rồi mới ra giải pháp; thứ gì bổ sung ngoài chuỗi thì phải khai cơ sở.** Mười hai nỗi đau lấy nguyên từ bản nỗi đau, không thêm bớt — nhưng không xếp ngang hàng nữa: chúng được truy về bốn nguyên nhân gốc. Giải cả 12 nỗi đau riêng lẻ sẽ ra một app 12 nhóm tính năng, rối và loãng; chạm đúng nguyên nhân gốc thì một giải pháp khép được nhiều nỗi đau cùng lúc — đó là tiêu chí Tracy đặt cho một giải pháp tuyệt vời.

Ký hiệu triết lý dùng suốt bản này: **TL1** Chủ quyền Ý thức · **TL2** Vận động viên Điều hành · **TL3** Đòn bẩy vô hạn · **TL4** Sự bỏ rơi chiến lược · **TL5** Chỉ huy dàn nhạc · **TL6** Tối giản hoá Nhận thức · **TL7** Giữ lời và Cuộc chơi · **TL8** Chồng mục tiêu chung.

Ký hiệu nguyên nhân, dựng ở mục này và dùng suốt bản: **N1** Entropy · **N2** Vòng lặp mở · **N3** Thương mại hoá sự chú ý · **N4** Cấp phát không có luật.

> ⚠️ *Ghi chú về dữ liệu, theo lời Tracy 12/08: app mới chạy thật vài ngày, số đo hành vi từ nó chưa đủ tin để làm bằng chứng. Toàn bộ lập luận của mục này đứng trên nền nghiên cứu đã nạp — các bài nghiên cứu, wiki và nguồn thô đã đi qua — không đứng trên số đo của app. Số đo app khi nào xuất hiện đều mang nhãn "tín hiệu sớm".*

### 1.1. Vì sao phải rút gọn — các nỗi đau có quan hệ nhân quả với nhau

Mười hai nỗi đau trong bản nỗi đau không đứng độc lập. Đọc kỹ sẽ thấy chúng xếp thành tầng: có nỗi đau là **gốc**, có nỗi đau là **hệ quả** của cái gốc. Ví dụ rõ nhất — và là ví dụ Tracy chỉ ra: *thói tập trung suy giảm* (CN3) không phải một căn bệnh riêng, nó là hệ quả của entropy tâm trí (CN1) cộng với môi trường được thiết kế để lấy chú ý (CN2). Chữa CN3 mà không chạm CN1 và CN2 là hạ sốt cho một ổ nhiễm trùng: sốt sẽ quay lại. Tương tự, *kiệt sức của cả bộ máy* (DN6) là hệ quả của cách cấp phát việc không có luật — sáu tiền điều kiện kiệt sức của Maslach đều là biến tổ chức, không phải biến ý chí — chứ không phải do 12 người cùng lười nghỉ.

Truy ngược như vậy, mười hai biểu hiện chụm về **bốn nguyên nhân gốc**, đánh mã N1 tới N4. Đây là thao tác quan trọng nhất của cả bản giải pháp, vì nó đổi đề bài: từ "giải 12 nỗi đau" thành "chạm 4 nguyên nhân" — và trong bốn cái đó có một **nguyên nhân mẹ**, thứ 80 phần trăm mà mọi nỗi đau còn lại đều dây vào (tầng 1.3).

### 1.2. Bảng nhân quả — một bảng xâu trọn chuỗi

Đọc bảng theo hàng ngang: mỗi hàng là một chuỗi *nguyên nhân → biểu hiện → hệ quả → giải pháp → cơ sở* khép kín.

| Nguyên nhân gốc | Biểu hiện (nỗi đau) | Hệ quả đang diễn ra | Giải pháp — triết lý và cơ chế lõi | Cơ sở |
|---|---|---|---|---|
| **N1 · ENTROPY** — trạng thái mặc định của ý thức và của tổ chức là hỗn loạn. Ý thức không có mục tiêu thì trôi; tổ chức không có chồng mục tiêu chung là một ý thức tập thể không có cấu trúc. **Nguyên nhân mẹ** | CN1 entropy tâm trí · CN5 sự phân tán · DN4 phân tán tổ chức, tích luỹ dừng · DN3 giờ tại bàn không thành giờ thật | Thói tập trung suy giảm (CN3) · dòng chảy sai chỗ — hăng say vào việc không tạo kết quả then chốt · bận cả năm mà không có gì cộng dồn | **TL8** chồng mục tiêu bốn tầng — áp cấu trúc lên ý thức tập thể · **TL4** bỏ rơi chiến lược — áp cấu trúc bằng loại trừ · **TL1** giao thức vào phiên — áp cấu trúc lên từng buổi sáng · **TL3** một chướng ngại lớn theo đuổi nhiều tháng | ✅ Csikszentmihalyi: entropy tâm trí là trạng thái nền của ý thức, trật tự nội tâm phải dựng chủ động (cụm `wiki/tam-thuc/flow/`) · ✅ Locke và Latham 2002: mục tiêu cụ thể và khó kèm phản hồi, d=0,42–0,80 |
| **N2 · VÒNG LẶP MỞ** — não không tự đóng được việc dở. Mỗi việc mở chưa có bước kế tiếp chiếm một phần bộ nhớ làm việc, kể cả khi không nghĩ tới nó | CN4 tải nhận thức · DN2 điểm nghẽn lịch trình — họp rải làm vỡ khối và để lại đuôi dư âm | Dư âm chú ý sau mỗi lần chuyển việc, mất hơn 20 phút mới về lại độ sâu cũ · tải nền lúc nào cũng cao dù chưa làm gì · góp vào CN3 | **TL6** cú đổ tải — đổ hết ra giấy, mỗi mục qua đúng một cửa · **TL7** nghi thức đóng — việc dở phải có chỗ nằm và bước kế tiếp trước khi rời bàn · **TL1** ngày một khoảnh khắc — gom việc vào khối thay vì rải | ✅ Zeigarnik, và Masicampo với Baumeister: lập kế hoạch cho việc dở là đủ để não buông (cụm `deep-work/`, nghi thức tắt máy) · ✅ Leroy: dư âm chú ý (attention residue) · ✅ Gloria Mark: trung bình 23 phút 15 giây quay lại việc sau gián đoạn |
| **N3 · THƯƠNG MẠI HOÁ SỰ CHÚ Ý** — môi trường được thiết kế để lấy chú ý: ứng dụng chạy phần thưởng biến thiên, nhóm chat nội bộ chạy văn hoá phản hồi tức thì | CN2 thương nhân của sự chú ý · một phần DN2 và DN3 | Cửa sổ sáng bị chiếm trước khi kịp vào việc · kiểm tra thành phản xạ · góp thẳng vào CN3 | **TL1** thức dậy là vào việc — chiếm cửa sổ sáng trước thuật toán, dòng chảy trước điện thoại, điện thoại từ đồ chơi thành công cụ · **TL5** luật kênh của đội — nhóm chat không phải chuông báo cháy | ✅ Cơ chế phần thưởng biến thiên và dopamine của Schultz: phần thưởng chắc chắn và tức thời chi phối tín hiệu (dẫn đủ ở TL4) — đúng cái các ứng dụng khai thác |
| **N4 · CẤP PHÁT KHÔNG CÓ LUẬT** — việc sinh ra và đổ xuống không qua cấu trúc nào: giao bằng miệng, lời hứa không có chỗ hiện hữu, không trần số việc đang chạy, không ai thấy tổng tải, không luật nào ràng buộc người giao | DN1 bẫy nhạc công · DN6 kiệt sức của cả bộ máy · CN6 trần kiệt sức · DN5 xói mòn văn hoá và mất nhân tài | Quá tải dồn về người giỏi nhất, người đó thành điểm nghẽn của cả công ty · người giỏi rời đi trước, chi phí nhân sự đội lên · mọi quyết định xếp hàng chờ một người | **TL7** giữ lời và cuộc chơi — cam kết có chỗ hiện hữu, trần chặn ở cơ sở dữ liệu, không cửa thoát im lặng · **TL5** uỷ thác phải nhìn suất trống · **TL2** nhịp nghỉ cho người chịu tải · **lớp luật người giao việc** (Mục 10.6) | ✅ Maslach: 6 tiền điều kiện kiệt sức đều là biến tổ chức · ✅ Erhard và Jensen: chuỗi toàn vẹn → tính vận hành → hiệu suất |

Đọc bảng theo chiều dọc cột giải pháp là thấy tiêu chí của Tracy hiện ra: **một giải pháp chạm nguyên nhân gốc khép được nhiều nỗi đau cùng lúc.** TL1 có mặt ở ba hàng, TL7 ở hai hàng — không phải trùng lặp, mà là dấu hiệu các triết lý này đứng gần gốc. Ngược lại, CN3 không có hàng riêng: nó là hệ quả, được giải bằng cách chạm N1, N2, N3 cùng lúc — chữa gốc thì sốt tự hạ.

**Chỗ còn hụt giữ lại từ bản đối ứng cũ** (không để mất khi gộp bảng): CN1 còn thiếu tầng động lực nội sinh và mục tiêu tiến trình gạch dần · CN5 còn thiếu cơ chế cao nguyên dòng chảy — phân biệt đổi hướng có lý do với bỏ dở vì chán · DN4 còn thiếu cơ chế chướng ngại mở rộng viết trong một câu, bám 3 tới 18 tháng · DN5 phải khai thẳng khung Team Flow là do người viết ghép, ruột thật từ van den Hout · DN3 giữ cơ chế, bỏ con số 2,3 giờ vì nằm trong danh sách khẳng định bị loại của bản nỗi đau.

### 1.3. Nguyên nhân mẹ và cái lõi một câu của app

Trong bốn nguyên nhân, **N1 entropy là nguyên nhân mẹ** — thứ 80 phần trăm ảnh hưởng đến mọi nỗi đau khác. Nhìn lại ba nguyên nhân còn lại sẽ thấy chúng là entropy mặc những chiếc áo khác nhau: N2 là entropy ở tầng bộ nhớ làm việc — việc mở không cấu trúc thì chiếm chỗ; N3 là entropy được bơm từ bên ngoài vào có chủ đích — kẻ khác kiếm tiền trên sự hỗn loạn chú ý của mình; N4 là entropy ở tầng tổ chức — việc sinh ra không cấu trúc thì đổ về người giỏi nhất. Bốn cái tên của cùng một sự thật: **hệ nào không được áp cấu trúc thì trôi vào hỗn loạn, và cấu trúc không tự sinh — phải có người dựng và có máy giữ.**

Đó là lý do app không cần nhiều giải pháp, và không được phép nhiều giải pháp — nó đứng trên **một lõi duy nhất, lời Tracy 12/08: "biến cam kết thành kết quả."** Một cam kết đúng nghĩa — mục tiêu rõ ràng, đủ vừa, dễ hình dung, có hạn, có output — chính là đơn vị cấu trúc nhỏ nhất áp lên được ý thức. Cái lõi này chạm cả bốn nguyên nhân, và đó là phép thử cho thấy nó là lõi thật chứ không phải khẩu hiệu:

- Chạm **N1**: cam kết cho ý thức đúng ba điều kiện dựng trạng thái dòng chảy — mục tiêu rõ, phản hồi tức thì, thách thức vừa sức (✅ Csikszentmihalyi) — tức là cho entropy một cấu trúc để bám.
- Chạm **N2**: cam kết có bước kế tiếp, có chỗ nằm, có nghi thức đóng — vòng lặp mở đóng lại được, não buông được.
- Chạm **N3**: phiên tập trung tạo kết quả thật cho não một nguồn phần thưởng chắc chắn và nhìn thấy được, đủ sức cạnh tranh với phần thưởng biến thiên của thuật toán.
- Chạm **N4**: cam kết công khai, có trần, có hạn, có người nhận — cấp phát bắt đầu có luật.

Chuẩn của bản này từ đây trở đi: **mọi tính năng phải truy được về một trong bốn nguyên nhân, và tính năng phục vụ thẳng cái lõi biến-cam-kết-thành-kết-quả được ưu tiên trước.** Tính năng không truy được về nguyên nhân nào là ứng viên để không làm. *(⚠️ Dữ kiện vận hành, lời Tracy 12/08: lõi này đang chạy thật với 7 người coreteam — tín hiệu sớm đáng mừng, chưa dùng làm bằng chứng.)*

### 1.4. Ba bài toán lồng nhau — ba mặt trận của cùng một cuộc chiến chống entropy

Ba bài toán của bản đề bài không đứng cạnh nhau mà lồng nhau, và nay truy được về chuỗi nhân quả: **HỆ THỐNG** là chống entropy ở tầng hướng đi, **TRẠNG THÁI** là chống entropy ở tầng một phiên làm việc, **TÍCH LUỸ** là chống entropy ở tầng thời gian dài. Thứ tự không đảo được. Bằng chứng nằm trong chính bản nỗi đau: chương trình chỉ luyện trạng thái làm lượng trạng thái sâu tăng 70 tới 80 phần trăm rồi vài tháng sau rơi về mốc cũ — vì trạng thái không có hướng thì không biết đổ vào đâu, và không có cơ chế tích luỹ thì không giữ lại được.

| Bài toán | Đề bài | Chống nguyên nhân | Triết lý phục vụ | Chỗ hụt lớn nhất |
|---|---|---|---|---|
| **1 · HỆ THỐNG** — biết đúng việc cần làm | Triệt tiêu dòng chảy sai chỗ: nhân sự hăng say vào việc không tạo kết quả then chốt | N1 ở tầng hướng, N4 | TL8 chủ lực, TL4, TL3, TL5 | Chồng mục tiêu chung của ROVA chưa được viết ra thành văn bản — tầng trên cùng còn trống, phải dựng trước khi mọi tính năng TL8 có nghĩa |
| **2 · TRẠNG THÁI** — đưa não vào tập trung | Vào trạng thái sâu nhanh, thay vì mất hơn 20 phút tập trung lại sau mỗi lần bị ngắt | N2, N3, N1 ở tầng phiên | TL1 chủ lực, TL6, TL2 làm nền năng lượng | Tầng điều tiết hệ thần kinh như điều kiện đứng trước mọi điều kiện khác vẫn chưa có chỗ, dù là chỗ có nguồn cứng nhất cả kho |
| **3 · TÍCH LUỸ** — lặp lại bền vững, cộng dồn | Hiệu suất là tăng trưởng cộng dồn, không phải một đợt bùng lên, đồng thời ngăn kiệt sức | N1 ở tầng thời gian, N4 | TL2, TL3, TL7 | Đơn vị đếm hiện là tổng giờ cộng dồn mà sàn phiên là 5 phút — 24 phiên 5 phút bằng một phiên 120 phút trên bảng. Phải có ngưỡng chất lượng, xem Mục 10, lỗi A3 |

### 1.5. Khoảng trống — cái gì chưa được giải, và thứ bổ sung ngoài chuỗi

Bốn khoảng trống dưới đây tôi nêu thẳng, không giấu trong phần thân bài.

| Khoảng trống | Nội dung | Ai lẽ ra phải giải | Trạng thái |
|---|---|---|---|
| **KT1 · Người giao việc** | Cả tám triết lý đều ràng buộc người NHẬN việc. Không triết lý nào ràng buộc người GIAO việc. Nếu 12 người chạy đủ tám triết lý mà đầu vào không đổi, app chỉ làm tình trạng quá tải trở nên đo được, không làm nó nhỏ đi | Chưa có chủ | ⏳ Chạy theo mặc định: **có** thêm lớp luật ở phía cấp phát, ràng buộc chính Tracy, đưa vào lộ trình tính năng ngay đợt sau. Xem Mục 10.6 |
| **KT2 · Đơn vị đếm của tích luỹ** | Hiệp tập dòng chảy với liều tối thiểu 2 hiệp mỗi tuần, mỗi hiệp ít nhất 120 phút, chỉ hiệp sạch mới tính — thứ duy nhất trong cả kho Doris cho một đơn vị đếm được để cộng dồn | Nay xếp vào TL2 | ⏳ Chạy theo mặc định: ngưỡng hiệp sạch đặt tạm **45 phút** — 120 phút của nguồn là chuẩn vận động viên, không phải chuẩn ngày vào nghề; số đo của đội mới có vài ngày, chưa đủ tin để định ngưỡng, chạy vài tuần rồi tính lại theo phân vị thật |
| **KT3 · Tải vận hành đời sống** | Doris chia tải làm ba loại: tải thích nghi, tải nhận thức, tải vận hành đời sống. Tám triết lý chạm hai loại đầu, bỏ trống loại thứ ba với luật loại bỏ thay vì tối ưu | Chưa có chủ | ⬜ Để ở tầng cá nhân của Tracy, không đưa vào bản gửi đội |
| **KT4 · Ra quyết định bằng trực giác** | Để hệ thống chậm chuẩn bị đề bài rồi hệ thống nhanh giải: viết một câu hỏi ra giấy, ủ ít nhất 48 giờ bằng hoạt động kích thích nhẹ, rồi ngồi viết | Chưa có chủ | ⬜ Ứng viên cho một triết lý thứ chín. Chưa đưa vào bản này vì chưa truy được về nguyên nhân nào trong bốn nguyên nhân |
| **BS · Bổ sung ngoài chuỗi** | Hai triết lý 🟢 từ vault (TL7, TL8) không có trong nguồn Doris — chúng là phần "bổ sung thêm" của chuỗi | Đã có chủ | ✅ Cơ sở khai đủ: TL7 đứng trên Erhard và Jensen cùng cụm Kiến Tạo Cuộc Chơi; TL8 đứng trên Locke và Latham, Traction, Scaling Up, Ba Quy Luật Hiệu Suất — đều đã nạp vào vault, và cả hai truy thẳng về N4 và N1 |

**Ba thứ đã cố ý bỏ khỏi bản này**, ghi lại để không đề xuất lần nữa: bộ điều răn về liều caffeine, vì nghiên cứu nền chưa công bố và doanh nghiệp không kê liều cho nhân viên · các chế độ nước rút cực đoan đòi tái cấu trúc thời gian gia đình và dậy lúc 4 giờ 30, giữ như tuỳ chọn riêng của Tracy · phần tối giản đồ vật với ngưỡng dưới 100 món, vì không truy được về nguyên nhân nào và không dựng được thành tính năng.

---

## MỤC 2 — TRIẾT LÝ 1 · CHỦ QUYỀN Ý THỨC 🟣

*Framework: Wake Up and Flow — Thức dậy là vào việc*
*Trả lời nguyên nhân: **N3** thương mại hoá sự chú ý (chính) và **N1**, **N2** ở tầng phiên — biểu hiện CN2, góp phần giải CN3 và DN3.*

### 2.1. Bản chất

Sự chú ý là tài sản có chủ, và mỗi ngày nó bị tranh chấp bởi những bên được trả tiền để giành nó. Các ứng dụng trên điện thoại không phải công cụ trung tính: chúng được thiết kế bởi những đội ngũ giỏi nhất thế giới, theo nguyên lý phần thưởng biến thiên — cùng nguyên lý của máy đánh bạc — với chỉ tiêu kinh doanh đo bằng số phút của người dùng. Bản nỗi đau gọi họ là *thương nhân của sự chú ý*, và cách gọi đó chính xác về mặt kinh tế: sự chú ý của mỗi người trong đội là doanh thu của họ.

Triết lý này vì thế không nói về kỷ luật. Nó nói về **quyền sở hữu**. Câu nguyên văn của Doris: *"Every flow state achieved is a victory in the struggle for sovereignty of your own mind"* — mỗi phiên sâu giành lại được là một lần giành lại quyền sở hữu tâm trí của chính mình. Đặt vấn đề theo kiểu kỷ luật thì thua ngay từ đề bài, vì kỷ luật là trận đấu tay đôi giữa ý chí một người với cả một ngành công nghiệp; đặt theo kiểu chủ quyền thì lời giải đổi hẳn: không đấu tay đôi nữa, mà **thiết kế lại địa hình** để trận đấu không diễn ra.

### 2.2. Cơ chế

Cơ chế thứ nhất nằm ở cửa sổ sau khi thức dậy. Vừa mở mắt, sóng não còn nằm ở ranh giới alpha và theta — thuật ngữ có thật của hiện tượng này là *hypnopompic window*, do Frederic Myers đặt, và điện não đồ xác nhận vùng chuyển tiếp alpha-theta lúc tỉnh dậy là có thật. Đó là vùng gần trạng thái sâu nhất trong cả ngày, và tải nhận thức lúc ấy đang ở mức thấp nhất: chưa có tin nhắn nào, chưa có cuộc họp nào, chưa có vòng lặp nào mở. Vào việc ngay thì não gần như không phải dịch chuyển trạng thái; chần chừ — đọc tin, lướt điện thoại, họp buổi sáng — thì não bị kéo lên nhịp beta của xử lý vụn, và muốn xuống sâu lại phải đi đường vòng, trả đủ giá của pha vật lộn.

Cơ chế thứ hai là **xung đột tiếp cận và né tránh**: càng lại gần một nhiệm vụ khó, hạch hạnh nhân càng nổi tín hiệu đe doạ và cortisol càng tăng, nên cảm giác muốn né mạnh nhất đúng vào lúc sắp bắt đầu. Suy ra luật hành động: phải gõ phím **trước khi** não kịp dựng hàng rào kháng cự — đó là gốc của con số 60 tới 90 giây. Điểm chết của cả chu trình dòng chảy không nằm trong pha vật lộn, mà nằm **trước** nó: khoảng trống giữa bất động và bắt đầu.

Cơ chế thứ ba là sự chắc chắn. Phát biểu thành lời một cửa sổ chắc chắn — việc gì, trong bao lâu — làm hạch hạnh nhân dịu xuống, vỏ đai trước khoá vào mục tiêu, vỏ trán lưng bên gắn bộ nhớ làm việc vào đúng việc đó. Não không đòi môi trường hết bất định; nó chỉ đòi **một mẩu chắc chắn đủ dùng**. Đây là chỗ triết lý này trả lời nỗi đau thói tập trung suy giảm: trạng thái đó do môi trường gây ra, và đảo ngược được bằng cách cấp lại cho não những cửa sổ chắc chắn nhỏ, lặp lại.

### 2.3. Cơ sở khoa học

- ✅ **Gloria Mark**, Đại học California Irvine, đo thực địa 2004 trên nhân viên văn phòng thật: sau khi bị ngắt, cần trung bình **23 phút 15 giây** để quay lại đúng việc cũ. Đây là con số nền của cả đề bài "vào trạng thái nhanh, giữ trạng thái lâu".
- ✅ **Hofmann và Baumeister 2012**, nghiên cứu máy nhắn trên **205 người với 7.500 mẫu** tình huống thật giữa đời: khi cưỡng lại ham muốn dùng internet và tivi, người ta chỉ thành công khoảng **50 phần trăm** số lần. Ý chí trước màn hình là trò sấp ngửa.
- ✅ **Leroy 2009**, *Organizational Behavior and Human Decision Processes* 109(2):168–181: **dư âm chú ý** — chuyển việc giữa chừng thì một lớp chú ý còn dính lại ở việc cũ, làm việc mới chạy dưới công suất. Đây là nền khoa học của luật "chạy hết cửa sổ".
- ⚠️ Con số **60 tới 90 giây** sau khi thức dậy là của Doris, chưa truy được nghiên cứu gốc. Cửa sổ alpha-theta lúc tỉnh dậy là có thật; độ dài chính xác của cửa sổ thì không có nguồn.
- 🔴 Bản này **không dùng** phát biểu "vỏ trán tắt bớt, cái tôi tan biến" (giả thuyết transient hypofrontality, Dietrich 2004): tổng quan hệ thống trên *Cortex* 2022, gộp 25 nghiên cứu với 471 người, cho thấy các vùng trán **giữ vai trò then chốt** trong dòng chảy, không ngắt kết nối.
- 🔴 Bản này **không viện** hiệu ứng Zeigarnik (việc dang dở được nhớ tốt hơn): phân tích tổng hợp 2025 soi 59 công trình, không thấy lợi thế trí nhớ ổn định cho việc dang dở. Chỗ nào cần nói về vòng lặp mở, bản này dùng dư âm chú ý của Leroy — nguồn còn đứng vững.

### 2.4. Nguyên lý

- **Thiết kế môi trường thắng ý chí.** Một hệ thống đặt nền trên thứ chỉ đúng 50 phần trăm số lần thì không phải hệ thống. Mọi tính năng của app phải hỏi: cái này có còn đòi ý chí không, hay đã đổi được địa hình?
- **Chắc chắn tối thiểu là đủ.** Không cần môi trường hết bất định, không cần kế hoạch ngày hoàn hảo mới vào được trạng thái sâu. Một việc đã chọn cộng một cửa sổ đã khai là đủ để bắt đầu.
- **Chạy hết cửa sổ**, kể cả khi giữa chừng tin chắc mình đang làm nhầm việc. Bẻ cửa sổ giữa chừng là đưa chu trình về mốc không và trả thêm dư âm chú ý; nhầm việc thì hết cửa sổ đổi, không đổi giữa dòng.
- **Công cụ không được là nguồn phân tâm của chính nó.** App Khu Vườn phải đo được sự chú ý mà không giành sự chú ý — mọi tính năng đẩy thông báo, mọi con số đỏ nhấp nháy đều phải qua cửa soát này.

### 2.5. Framework — Wake Up and Flow

① **Tối hôm trước, gỡ sẵn bước đầu tiên của bước đầu tiên.** Không phải "chuẩn bị làm báo cáo" mà là: mở sẵn file, đặt sẵn tên, để con trỏ đúng chỗ sẽ gõ chữ đầu. Mức chi tiết phải nhỏ tới vô lý — vì thứ cản buổi sáng không phải độ khó của việc, mà là ma sát của việc khởi động.

② **Sáng hôm sau, vào việc trong 60 tới 90 giây.** Không điện thoại, không tin tức, không email. Từ giường tới bàn là một đường thẳng.

③ **Giữ khối 1 tới 3 giờ.** Đây là khối sâu thứ nhất và quan trọng nhất của ngày, đặt ở chỗ tải nhận thức thấp nhất.

④ **Nghi thức sáng xếp SAU khối sâu, không phải trước.** Tập, thiền, ăn sáng, vệ sinh cá nhân đầy đủ — tất cả vẫn có chỗ, nhưng đứng sau khối sâu. Doris gọi đây là *inverted morning routine*: nghi thức sáng truyền thống tiêu mất đúng cửa sổ vàng vào những việc có thể làm ở bất kỳ giờ nào.

⑤ **Chạm điện thoại lần đầu sau 3 tới 4 giờ.** Không phải cả ngày không dùng — mà là dòng chảy trước, điện thoại sau. Buổi sáng thắng thì cả ngày khó thua.

Giao thức phụ **Chắc chắn tối thiểu khả dụng** — dùng khi giữa ngày mất nhịp, hoặc khi ngồi xuống mà đầu đầy việc lộn xộn: quét đúng **120 giây** viết ra mọi thứ chưa giải quyết mà không xử lý gì; chọn **một** việc gỡ được gánh nặng lớn nhất; khai độ dài cửa sổ **10 tới 30 phút**; chạy hết cửa sổ. Bốn bước, dưới ba phút chuẩn bị. Giao thức này là lời giải trực tiếp cho mẫu hỏng dễ đoán nhất khi mở app cho cả đội: nhảy thẳng từ đống task sang bấm giờ mà bỏ qua khúc quyết định chọn việc — tín hiệu sớm từ vài ngày chạy thật cũng đang chỉ về đúng hướng này, dù số còn quá non để làm bằng chứng.

### 2.6. Công thức

`Sự chắc chắn = Mục tiêu rõ × Khung thời gian đã định × Thực thi tập trung`

✅ Đây là công thức duy nhất trong bản này lấy nguyên từ nguồn Doris. Ba điều đọc ra từ nó. Thứ nhất, đây là phép **nhân** chứ không phải phép cộng: một vế bằng không thì cả tích bằng không — có mục tiêu rõ và giờ đã định mà cứ hai phút xem điện thoại một lần thì kết quả vẫn là không. Thứ hai, vế nào cũng vặn được ngay hôm nay mà không tốn thêm giờ: rút ngắn khoảng cách từ lúc tỉnh đến lúc gõ phím là tăng vế thực thi; khai cửa sổ trước khi bấm giờ là tăng vế khung thời gian. Thứ ba, công thức này giải thích vì sao app bắt chọn task trước khi cho chạy đồng hồ — đó không phải một bước thủ tục, đó là vế thứ nhất của phép nhân.

### 2.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Nghi thức Chọn việc hôm nay, mở kho và kéo việc về ngày | Chọn trước, không quyết định lúc đã mệt | ✅ |
| Phiên deepwork đếm lên, bắt chọn task trước khi chạy | Cửa sổ chắc chắn phải được khai trước khi đồng hồ chạy | ✅ |
| Chuông tỉnh thức, đếm số lần nhận ra mình đã trôi | Chủ quyền là kỹ năng nhận ra mình đã trôi, không phải kỹ năng không trôi | ✅ |
| Cửa quét 120 giây bắt buộc trước nút bắt đầu phiên | Chắc chắn tối thiểu; chặn mẫu hỏng nhảy thẳng vào phiên mà chưa chọn việc | ⬜ |
| Chuẩn bị bước đầu của bước đầu từ tối hôm trước | Bớt ma sát khởi động. ⚠️ Ô mồi mai — dạng gần nhất của nó trong nghi thức hoàn tất — đã gác theo lệnh Tracy 11/08 (*"hơi phức tạp"*); bật lại thì phải kèm màn nhìn cam kết ngay trong nghi thức, không đề xuất lại dạng cũ | ⬜ |
| Khoảng giờ sâu cho hôm nay, máy chủ tính, người dùng không sửa được | Mở app buổi sáng để nhận đề bài, không phải để xem điểm cũ | ⬜ |

### Kết luận Triết lý 1

TL1 là chủ lực của Bài toán Trạng thái và là triết lý được app hiện thực hoá nhiều nhất — ba tính năng lõi đã chạy, và cả ba đều đúng cơ chế: chọn trước, khai cửa sổ trước, nhận ra mình trôi thay vì cấm trôi. Điểm yếu của nó không nằm ở cơ chế mà nằm ở phạm vi: hiện nó chỉ bảo vệ người dùng trước điện thoại. Muốn nó giải được nỗi đau điểm nghẽn lịch trình, phạm vi phải mở rộng thành chủ quyền trước **mọi** thứ giành chú ý — gồm cả đồng nghiệp, nhóm chat nội bộ, và những cuộc họp đặt vào giữa buổi sáng. Phần đó thuộc TL5, và ranh giới này được vẽ lại ở đó.

---

## MỤC 3 — TRIẾT LÝ 2 · VẬN ĐỘNG VIÊN ĐIỀU HÀNH 🟣

*Framework: ⚠️ Live Like a Lion — Sống như sư tử. Tên này do bản luận đặt, không phải tên Doris. Tên có nguồn của cụm nội dung này là "6 tác nhân kiệt sức và 5 giao thức tháo ngòi".*
*Trả lời nguyên nhân: **N1** ở tầng năng lượng — nhịp không có cấu trúc thì chạy 110 phần trăm tới sập — và đỡ hệ quả của **N4** cho người chịu tải; biểu hiện CN6, DN6.*

### 3.1. Bản chất

Trần gắng sức được quyết bởi tốc độ hồi phục chứ không bởi ý chí. Vì vậy phục hồi chủ động là một phần của công việc, không phải phần thưởng sau công việc. Đây là triết lý duy nhất trong tám cái đặt việc dừng lại ngang hàng với việc làm.

Phép đối chiếu gốc — của Jim Loehr và Tony Schwartz trong bài *The Making of a Corporate Athlete* trên Harvard Business Review — tàn nhẫn ở chỗ này: vận động viên chuyên nghiệp dành phần lớn thời gian để **tập** và rất ít thời gian để thi đấu, có mùa nghỉ dài vài tháng, và sự nghiệp kéo khoảng bảy năm. Người làm việc trí óc gần như không tập, phải "thi đấu" 8 tới 12 giờ mỗi ngày, nghỉ 3 tới 4 tuần một năm, và sự nghiệp kéo **40 tới 50 năm**. Không một chương trình thể thao nào dám thiết kế lịch như vậy cho vận động viên — nhưng đó chính xác là lịch mặc định của người điều hành. Kết luận của Loehr và Schwartz: kẻ thù không phải áp lực, kẻ thù là **tính tuyến tính** — gắng sức liên tục không dao động. Cơ bắp mạnh lên trong lúc phục hồi, không phải trong lúc tập; hiệu suất đỉnh cao là chuyện **dao động giỏi hơn** người khác, không phải làm nhiều hơn người khác.

### 3.2. Cơ chế

Tầng thứ nhất là **tải thích nghi** (allostatic load): mỗi lần cơ thể thích nghi với áp lực, một ít hao mòn được ghi lại, và nếu không có giao thức dọn hằng ngày thì nó tích luỹ rồi tràn sang ngày sau. Ẩn dụ của McEwen: như cuốn tạ không nghỉ — tới một lúc không nhấc nổi chai nước khỏi bàn. Người kẹt trong trạng thái này thấy thiền và đi bộ không đủ, và họ đúng: khi hệ thần kinh đã kẹt ở mức kích thích cao, các giao thức nhẹ không chạm đủ mạnh vào sinh lý để kéo nó xuống. Đó là lý do phục hồi chủ động đôi khi phải **khó chịu** — và cũng là ranh giới giữa phục hồi với thư giãn: xem phim với đồ uống là thư giãn, dễ chịu về cảm giác nhưng không bật hệ phó giao cảm, không nạp lại hoá chất thần kinh, không hạ tải thích nghi.

Tầng thứ hai là hoá học: sau nhiều giờ tập trung liên tục, **glutamate tích tới nồng độ độc ở vỏ trán trước** — phát hiện của Viện Não Paris năm 2022. Cảm giác "não đặc lại" cuối một ngày dài không phải chuyện tâm lý; nó là chuyện hoá học, và hệ dọn dẹp chỉ chạy khi hồi phục sâu và kéo dài. Nghĩa là vượt trần hôm nay không phải là "làm thêm được một ít" — nó là vay của ngày mai với lãi.

Tầng thứ ba là tổ chức. Sáu tiền điều kiện kiệt sức của Maslach — thiếu kiểm soát, xung đột giá trị, phần thưởng không tương xứng, quá tải, bất công, cộng đồng rạn vỡ — **đều là biến tổ chức, không phải biến cá nhân**. Điều này có nghĩa: kiệt sức của một đội không chữa được bằng cách dạy từng người nghỉ đúng. Triết lý này kê thuốc cho người chịu tải; bệnh gốc nằm ở cơ chế phát tải, và bản này xử chỗ đó ở Mục 10.

### 3.3. Cơ sở khoa học

- ✅ **McEwen và Stellar**, Đại học Rockefeller: khái niệm tải thích nghi — hao mòn thể chất và tinh thần tích tụ do liên tục thích nghi với áp lực, vượt ngưỡng thì đổ xuống thành bệnh.
- ✅ **Loehr và Schwartz**, Harvard Business Review, *The Making of a Corporate Athlete*: khung vận động viên điều hành, dao động thay vì tuyến tính, siêu bù đắp — mạnh lên trong lúc phục hồi.
- ✅ **Christina Maslach**: 6 tiền điều kiện kiệt sức, cả 6 đều là biến tổ chức.
- ✅ **Viện Não Paris 2022**: glutamate tích tới ngưỡng độc ở vỏ trán trước sau nhiều giờ tập trung liên tục.
- ✅ **Corinna Peifer**, Đại học Lübeck: quan hệ giữa dòng chảy với kích thích giao cảm và cortisol là **hình chữ U ngược** — kích thích vừa phải thúc đẩy dòng chảy, kích thích quá cao chặn nó; còn chỉ số phó giao cảm tương quan thuận với dòng chảy. Đây là con số nên dùng khi cần thuyết phục, thay cho mọi con số phần trăm của giới bán khoá học.
- ✅ **Newport**: trần khoảng 4 giờ sâu mỗi ngày; nhóm violin ưu tú ở Berlin tập khoảng 3,5 giờ chia làm hai khối.
- ✅ **Kotler**: trong các loại bền chí, bền chí để **hồi phục** là loại nên rèn trước tiên — vì người tham vọng không ai thích chậm lại, nên đó là kỹ năng khan hiếm nhất.
- ⚠️ Doris tự mâu thuẫn giữa trần 5 tới 6 giờ và mục tiêu 7 tới 8 giờ mỗi ngày ở hai video khác nhau. Bản này lấy **4 giờ làm trần thiết kế** vì đó là con số có nguồn ngoài Doris.
- ⚠️ Nhịp 45 phút làm và 5 phút nghỉ: cơ chế nền — giảm điều hoà rồi tái nhạy hoá thụ thể dopamine — có thật, nhưng chính nguồn ghi rõ **liều 45 trên 5 chưa được thử nghiệm kiểm chứng**. Chờ 2 tới 3 tuần dữ liệu thật của đội để hiệu chỉnh.
- ❌ Không dùng con số năng suất tăng 500 phần trăm: gốc là tổng hợp quan sát giai thoại tự báo cáo, không công bố dữ liệu hay phương pháp, không bình duyệt.

### 3.4. Nguyên lý

- **Chạy ở 80 phần trăm chứ không 110.** Chạm trần là hoàng hôn đẹp, không phải lời chê chưa đủ. Hệ thống nào khen người vượt trần là hệ thống đang dạy cả đội vay lãi của ngày mai.
- **Nghỉ phải tiết ít kích thích hơn chính công việc.** Nếu giờ nghỉ hấp dẫn hơn giờ làm thì sau giờ nghỉ người ta muốn tiếp tục nghỉ, không muốn quay lại việc. Vì thế app không bao giờ gợi ý "xem gì đó cho thư giãn" — màn nghỉ đúng phải nhàm chán một cách cố ý.
- **Thứ tự rèn không đảo được: động lực nội sinh, rồi đặt mục tiêu, rồi bền chí.** Bền chí dựng trên nền mục tiêu, mục tiêu dựng trên nền động lực. Bắt đầu từ bền chí — cách đa số chương trình rèn luyện làm — là xây từ mái xuống.
- **Đo bằng số ngày có mặt, không đo bằng tổng giờ.** Tổng giờ thưởng cho đợt bùng lên; số ngày có mặt thưởng cho sự đều đặn — và đối tượng của bài toán tích luỹ là sự đều đặn.

### 3.5. Framework — Sống như sư tử

① **Khai trần giờ sâu của ngày.** Mỗi người biết trần của mình hôm nay — ngủ đủ thì 4 giờ, đêm trước kém thì thấp hơn — và chạm trần thì dừng, không cố.

② **Nhịp làm và nghỉ, với quãng nghỉ cố ý nhàm chán.** Đứng dậy, nhìn ra xa, uống nước, không màn hình. ⚠️ Liều cụ thể (45 trên 5 hay khác) chờ dữ liệu thật của đội để hiệu chỉnh, vì con số của nguồn chưa qua thử nghiệm.

③ **Đổi tư thế trước, đổi địa điểm sau.** Đổi tư thế để hạ cảm giác gắng sức; đổi địa điểm để đặt lại cảm nhận nỗ lực. Đây là hai núm vặn tốn ít công nhất khi phiên bắt đầu nặng mà chưa tới trần.

④ **Nghi thức tắt máy bốn bước cuối ngày:** đối chiếu với chồng mục tiêu để sửa hướng trôi · chọn tối đa 3 hành động cho ngày mai · gỡ sẵn bước đầu của bước đầu cho từng hành động · đóng mọi vòng lặp dở — mỗi vòng lặp mở là một lưỡi câu kéo giật ý thức về đêm.

⑤ **Nhịp nghỉ đặt trước trong lịch:** 5 tới 6 ngày làm và 1 tới 2 ngày nghỉ, cộng 3 tới 4 ngày mỗi quý. Nghỉ nằm trong thiết kế từ đầu, không phải phần thưởng xin thêm khi đã mệt.

Cụm **Hiệp tập dòng chảy** được đặt vào triết lý này: *hiệp sạch* — một phiên sâu đủ dài, không bị ngắt — là đơn vị đếm của Bài toán Tích luỹ, với liều tối thiểu 2 hiệp mỗi tuần. ⏳ Ngưỡng độ dài một hiệp sạch chạy theo mặc định **45 phút** chứ không phải 120 phút như nguồn — mốc 120 là chuẩn của vận động viên đã luyện nhiều năm, không phải chuẩn ngày vào nghề; đặt cái xà không ai với tới thì không ai nhảy. Số đo của đội mới có vài ngày, chưa đủ tin để định ngưỡng — chạy vài tuần rồi tính lại theo phân vị thật.

### 3.6. Công thức

`Phong độ bền = Số ngày có mặt × (Giờ sâu mỗi ngày, chặn ở trần 4 giờ)`

⚠️ Công thức do tôi ghép, không có trong nguồn. Ý nghĩa nằm ở chỗ trần: vượt trần làm tăng thừa số thứ hai hôm nay nhưng làm giảm thừa số thứ nhất tuần sau — người vắt kiệt hôm nay là người vắng mặt ngày kia — nên tổng giảm. Công thức này cũng là lý do bảng đo của app phải chặn giờ mỗi phiên ở trần (điều app đã làm: mọi khung nhìn sống đều chặn 120 phút mỗi phiên), và phải đo sự có mặt như một trục riêng thay vì chỉ cộng giờ.

### 3.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Hộp khuyên nghỉ khi chuông dồn, luôn có cửa Tôi làm tiếp | Mời gọi chứ không trừng phạt | ✅ |
| Khối Tổng quan deepwork 8 ô, làm gương soi riêng | Đo mình, không đo người | ✅ 7 trên 8 ô; ô Giờ vàng còn 🔶 |
| Luật Nghỉ Chủ nhật áp cho mọi chỗ đếm | Nghỉ nằm trong thiết kế, không phải ngoại lệ | 🔶 |
| Nghi thức hoàn tất buổi tối (ô mồi mai đã gác theo lệnh 11/08) | Đóng vòng lặp còn mở trước khi rời việc | ✅ lên sóng 11/08 |
| Ngưỡng hiệp sạch: chỉ phiên đủ dài mới vào số cộng dồn công khai | Tích luỹ cần đơn vị đếm có chất lượng | ⬜ |
| Nhật ký hành vi 7 câu có kỷ luật thống kê | Phục hồi phải đo được, không kết luận cho tới khi đủ dữ liệu | ⬜ |
| Màn hình nghỉ cố ý nhàm chán, kèm hành động thật | Nghỉ ít kích thích hơn việc | ⬜ |

### Kết luận Triết lý 2

TL2 gánh nửa Bài toán Tích luỹ và toàn bộ tầng năng lượng — nó là tầng quyết định **trần** của mọi triết lý khác: không có năng lượng thì chủ quyền ý thức chỉ là ý định, và đòn bẩy chỉ là kế hoạch. Điểm gãy đã biết và phải nhắc lại ở đây: nó kê thuốc cho người chịu tải trong khi 6 tiền điều kiện của Maslach đều nằm ở phía phát tải. Bản đầy đủ xử chỗ này bằng hai việc ở Mục 10: một chỉ số cấp đội có chủ — số cam kết đang mở trên mỗi người, hiện ở nhịp tuần — và một luật thành văn: giảm tải là quyết định của người giao, không phải kỷ luật của người nhận.

---

## MỤC 4 — TRIẾT LÝ 3 · ĐÒN BẨY VÔ HẠN 🟣

*Framework: The Leverage Trifecta — Bộ ba đòn bẩy*
*Trả lời nguyên nhân: **N1** ở tầng tích luỹ — sản lượng không cấu trúc thì tuyến tính theo giờ công; biểu hiện DN4.*

### 4.1. Bản chất

Một giờ của người điều hành chỉ đáng giá bằng số giờ nó tiết kiệm cho tương lai. Câu gốc của Doris: *"Time is finite. Leverage is infinite"* — thời gian hữu hạn, đòn bẩy vô hạn. Đằng sau nó là một phép định nghĩa lại năng suất: năng suất bằng giá trị đầu ra chia chi phí đầu vào, **nhân với đòn bẩy** — nhà máy không năng suất hơn vì công nhân đổ mồ hôi nhiều hơn, mà vì ra nhiều đơn vị hơn mỗi giờ.

Nhưng xây đòn bẩy luôn đòi trả trước bằng một **vũng sản lượng phẳng**, và đó là lý do gần như không ai xây. Ẩn dụ gốc là chiếc rìu cùn: đang đốn củi giữa trời lạnh, dừng lại mài rìu nghĩa là tạm thời không có khúc củi nào — tay cóng, nhà run, trời sắp tối, và một phần trong đầu hoảng lên. Não không quan tâm việc mài rìu sẽ tiết kiệm hàng trăm giờ về sau; nó chỉ biết hôm nay chưa xong gì cả, nên nó kéo ta quay về đốn tiếp để có phần thưởng ngay. **Đây không phải thiếu kỷ luật hay thiếu trí tuệ — não được lập trình để né đúng cái mà đòn bẩy đòi hỏi.** Hiểu điều đó thì thôi tự trách, và bắt đầu thiết kế quanh nó.

### 4.2. Cơ chế

Tầng thần kinh: nghiên cứu của Wolfram Schultz về nơron dopamine cho thấy chúng phóng mạnh khi phần thưởng đến **ngay và chắc chắn**; phần thưởng trì hoãn hoặc bất định gần như không sinh tín hiệu, kể cả khi nó lớn hơn. Việc trả lời tin nhắn cho một nhát dopamine tức thì; việc viết quy trình để không phải trả lời loại tin nhắn đó nữa cho con số không tròn trĩnh — hôm nay. Đó là lý do sinh học khiến không ai tự nguyện bước vào vũng sụt, và là lý do app phải làm cho tiến trình xây đòn bẩy **nhìn thấy được** — biến phần thưởng trì hoãn thành phản hồi tức thời.

Tầng tổ chức: cơ chế ngược lại cũng có thật. Gerber trong *The E-Myth Revisited* chỉ ra hệ thống vận hành doanh nghiệp và con người vận hành hệ thống — đầu tư nặng một lần vào quy trình làm khối lượng việc lặp giảm dần liên tục về sau. Và có một vòng tự củng cố ở tầng cá nhân: việc có đòn bẩy cao được não nhận diện là việc giá trị cao, pha vật lộn với nó rút ngắn, vào trạng thái sâu dễ hơn — người xây đòn bẩy càng lâu càng thấy việc xây dễ vào.

### 4.3. Cơ sở khoa học

- ✅ **Wolfram Schultz**: độ chắc chắn và độ tức thời của phần thưởng chi phối tín hiệu dopamine mạnh hơn độ lớn của nó.
- ✅ **Gerber**, *The E-Myth Revisited* tr.75–81: làm TRÊN doanh nghiệp thay vì TRONG doanh nghiệp; hệ thống vận hành doanh nghiệp, con người vận hành hệ thống. Đã nạp trọn vào vault, có trang riêng.
- ✅ **Newport** tr.139: thước sinh viên mới ra trường — với mỗi việc, hỏi *cần bao nhiêu tháng đào tạo một cử nhân giỏi để làm được việc này*; câu trả lời phân loại việc nên giữ và việc nên giao.
- ⚠️ Các con số so sánh giờ của người đứng đầu với giờ nhân viên, và tỉ lệ 5 phần trăm nỗ lực tạo 95 phần trăm tiến triển: nguồn tự gắn nhãn chưa xác thực, không dùng.
- ❓ Không tìm được nghiên cứu nào đo riêng hiệu ứng của vũng sụt sản lượng. Đây là mô tả quan sát — khớp với trải nghiệm thật và với cơ chế Schultz, nhưng chưa phải phát hiện đã kiểm định. Ghi rõ để không ai đem nó đi giảng như định luật.

### 4.4. Nguyên lý

- **Lượng hoá vũng sụt bằng số giờ rồi bước thẳng vào nó, thay vì né.** Nỗi sợ vũng sụt sống bằng sự mơ hồ; "xây cái này tốn 12 giờ, hoà vốn sau 5 tuần" là một quyết định tính được, không còn là một nỗi sợ.
- **Rèn cơ bắp đòn bẩy ở việc nhỏ để có nó ở việc lớn.** Người chưa từng viết nổi một checklist 5 dòng sẽ không tự nhiên viết được một quy trình tuyển người. Bắt đầu từ template tin nhắn, câu trả lời mẫu, một bước tự động nhỏ.
- **Mỗi việc lặp có ba lối ra chứ không phải một: tự động hoá, giao lại, bỏ đi.** Và lối thứ ba — bỏ đi — là hình thức đòn bẩy cao nhất: quy trình tốt nhất là quy trình không cần tồn tại.
- **Tự động hoá là phần thưởng của thành thạo, không phải một tính năng cao cấp.** Chỉ tự động hoá được thứ mình đã hiểu tới mức viết ra thành bước; tự động hoá thứ chưa thành thạo là đóng gói sự lộn xộn.

### 4.5. Framework — Bộ ba đòn bẩy

① **Người.** Tuyển đúng trước khi cài cơ chế cho đội hiện tại — một người đúng có thể nén 5 năm vật lộn thành 6 tháng. Giao thức: xác định mục tiêu lớn nhất, chỉ ra nút thắt đang chặn đầu ra, hỏi *ai gỡ được hoàn toàn nút đó*, và dùng dự án thử việc có trả tiền 1 tới 2 ngày thay cho phỏng vấn suông. Chuyện minh hoạ của nguồn: Robert Caro sắp bỏ dở *The Power Broker* vì hết tiền thì gặp Robert Gottlieb — người không chỉ xuất bản mà tìm vốn cho ông viết xong, rồi làm biên tập viên của ông suốt 50 năm. Người như vậy không gõ cửa; phải đi tìm.

② **Quy trình.** Việc nào đã làm 2 lần thì sẽ có lần 3 — việc đó cần một quy trình. Viết theo tỉ lệ 20 trên 80: hai mươi phần trăm công viết lấy tám mươi phần trăm giá trị, không cầu toàn từng chữ ngay bản đầu. Đóng gói thành *cách làm của chúng ta*, nhịp đều một quy trình mới mỗi tháng. Câu giữ nhịp của nguồn: khi có việc gấp, đừng chỉ dập lửa — lắp luôn hệ thống phun nước.

③ **Thành thạo.** Học đúng kỹ năng, không phải mọi kỹ năng — câu lọc: *kỹ năng nào nếu thành thạo sẽ làm mọi việc còn lại dễ đi, hoặc không cần làm nữa?* Giao thức 5-cho-4: 5 giờ mỗi tuần, trong 4 tuần, tổng 20 giờ — đủ để có năng lực làm việc thật ở một kỹ năng đòn bẩy cao, khác hẳn với việc rải 20 giờ đó thành mười lăm phút mỗi ngày trong bốn tháng.

### 4.6. Công thức

`Hệ số đòn bẩy = Kết quả tạo ra ÷ Số giờ của chính tôi`

⚠️ Công thức do tôi ghép. Cách tăng đúng là **hạ mẫu số** — qua giao lại, qua tự động hoá, qua bỏ đi — chứ không phải tăng tử số bằng cách đổ thêm giờ; đổ thêm giờ là cách duy nhất không có đòn bẩy trong đó. Giai đoạn xây làm tử số phẳng trong 1 tới 4 tuần rồi mới bật lên — đó chính là vũng sụt, và ai đọc công thức này phải đọc kèm điều đó, nếu không sẽ bỏ cuộc đúng tuần thứ hai.

### 4.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Hỏi ước lượng thời gian lúc mở phiên, đối chiếu với giờ thật | Biết giá thật của mỗi việc trước khi tính đòn bẩy | 🔶 |
| Cho phép sửa bản ghi phiên deepwork | Dữ liệu tự khai phải sửa được, nhưng không được sửa lịch sử | 🔶 |
| Giao việc cho nhau, cây mọc trên vườn người làm | Giao lại là một lối ra chính thức, không phải cửa sau | ⬜ |
| Thước sinh viên mới ra trường ngay lúc tạo task | Phân loại việc giao được và việc không giao được | ⬜ |
| Ba lối ra cho việc lặp: tự động hoá, giao lại, bỏ đi | Vòng lợi tức tăng dần | ⬜ |

### Kết luận Triết lý 3

TL3 là chỗ trống nặng nhất trong app hôm nay: không có tính năng nào đang chạy, chỉ có hai cái đã duyệt chờ dựng. Điều đó không tình cờ — đòn bẩy là triết lý khó dựng thành tính năng nhất, vì phần thưởng của nó nằm ở tương lai trong khi giao diện sống ở hôm nay. Đây cũng là triết lý dễ va nhất với TL2, vì một bên đặt trần giờ còn một bên có những đợt xây đòi tăng giờ. Cách hoà giải ghi ở Mục 10: quá tải là chế độ **có hạn kỳ** — tối đa 14 ngày, khai trước, có ngày kết thúc — còn mặc định của mọi tuần vẫn là 80 phần trăm.

---

## MỤC 5 — TRIẾT LÝ 4 · SỰ BỎ RƠI CHIẾN LƯỢC 🟣

*Framework: Bộ lọc hướng mục tiêu. Tên gốc trong nguồn là GDA hay Goal-Directed Spectrum, kèm phép thử Litmus Test.*
*Trả lời nguyên nhân: **N1** bằng phép loại trừ — áp cấu trúc bằng cách bỏ bớt; biểu hiện CN5, CN1.*

### 5.1. Bản chất

Đa số việc chỉ cần đạt 80 phần trăm là đủ, và tài nguyên khan hiếm thật sự không phải giờ mà là **sự chú ý**. Từ hai mệnh đề đó suy ra một điều ngược với bản năng của người chăm chỉ: bỏ bớt là một hành động chiến lược, không phải sự lười. Doris đặt cho nó cái tên *strategic neglect* — bỏ rơi có chiến lược, một cách hạnh phúc — và đóng khung thành hai xô không có khoảng giữa: một việc hoặc thuộc xô **tập trung cộng dồn**, hoặc thuộc xô **bỏ rơi có chiến lược**. Sai lầm sinh học của con người là nhét phần lớn mọi thứ vào khoảng giữa, và khoảng giữa dẫn tới cam kết nửa vời cùng sự tầm thường. Khi phân vân, chọn phương án tập trung hơn.

Cái giá của việc không bỏ bớt có tên riêng: **sự phân tán** — đi rộng một dặm nhưng chỉ sâu một inch. Bản nỗi đau đã gọi nó là anh lớn của trì hoãn: trì hoãn ngăn ta lên xe, còn phân tán để ta lên xe rồi liên tục bắt rẽ khỏi cao tốc — mất quyền truy cập vào lãi kép, tức là mất theo cấp số nhân. Có một cảnh báo dành riêng cho người sáng lập trong nguồn: doanh nhân thường điểm cao ở nét *cởi mở với trải nghiệm*, nghĩa là rủi ro phân tán cao hơn người thường — chính khí chất làm nên doanh nhân cũng là thứ kéo họ dàn trải.

### 5.2. Cơ chế

Tầng hành vi: hai hệ điều khiển hành động tranh nhau trong não — hệ **kích thích và phản ứng** (thấy thông báo thì mở, thấy việc dễ thì làm) và hệ **hành động và kết quả** (làm vì nó dẫn tới đích). Không có bộ lọc thành lời thì hệ thói quen thắng, vì nó rẻ hơn về năng lượng. Bộ lọc hướng mục tiêu là cách ép mọi việc đi qua hệ thứ hai ít nhất một lần trước khi được nhận.

Tầng lịch: vỏ trán lưng bên có thói quen bám vào nghĩa vụ sắp tới và **khẩu phần hoá nỗ lực từ trước khi bắt đầu** — biết 10 giờ có họp thì từ 8 giờ não đã tự động giữ sức, không dám vào việc sâu. Đó là cơ chế thật đằng sau nỗi đau "một cuộc họp 30 phút lấy đi cả buổi sáng": cuộc họp không lấy 30 phút, nó lấy cả khoảng trống trước nó.

Tầng vòng đời: trong một theo đuổi dài luôn có **cao nguyên dòng chảy** — giai đoạn đã giỏi tới mức thấy chán, mất quyền vào trạng thái sâu ngay trong việc của mình, và hệ thần kinh dụ ta đi thám hiểm việc mới để được nhát dopamine của sự mới lạ. Đi theo tiếng dụ đó là quay về vạch xuất phát của một đường cong lãi kép khác. Luật của nguồn: khi chạm cao nguyên, đừng nhảy khỏi đường cong hàm mũ — ngồi yên, để sự tập trung tích luỹ. Phân biệt cho rõ: đổi dự án **có lý do chiến lược** là quyền; đổi dự án **vì gặp cao nguyên** là bẫy. Bảng nhân quả ở Mục 1 đã ghi thật thà rằng cơ chế này chưa có chỗ đứng riêng trong app — nó hiện chỉ là một đoạn văn trong triết lý này.

### 5.3. Cơ sở khoa học

- ✅ **Balleine** (UNSW) và **O'Doherty** (Caltech): hai hệ điều khiển hành động — hệ thói quen kích thích-phản ứng và hệ mục tiêu hành động-kết quả — với nền giải phẫu riêng biệt.
- ✅ **Wickman**, bộ EOS: khung bốn ô yêu, thích, ghét nhưng giỏi, ghét và dở; kỷ luật uỷ thác dần từng ô một, một việc mỗi quý.
- ✅ **Goldratt**, Theory of Constraints: 5 bước tập trung — và phát hiện quan trọng nhất cho ROVA: nút thắt thật thường là **chính sách** chứ không phải vật lý. Đã nạp trọn vào vault.
- ✅ **Newport** tr.141: định mức việc nông 30 tới 50 phần trăm mỗi tuần — bỏ bớt phải có ngân sách thành số, không dựa cảm giác.
- ✅ **Csikszentmihalyi**, *Good Business*: ta tưởng mình chú ý tới thứ mình thích, nhưng quan hệ chạy cả chiều ngược lại — **ta trở nên thích thứ mà ta chú ý kỹ càng**. Hệ quả chiến lược: đầu tư sự chú ý vào thứ có tiềm năng tăng trưởng bền, kể cả khi ban đầu chưa đặc biệt hứng thú; hứng thú sẽ được đánh thức sau.
- ⚠️ Tên gọi Strategic Neglect được nguồn gán cho Jonathan Cronstedt, chính nguồn tự ghi là chưa xác thực.
- ❌ Không dùng con số 70 phần trăm cuộc họp không cần thiết.

### 5.4. Nguyên lý

- **Hai xô, không có ở giữa: tập trung cộng dồn, hoặc bỏ rơi có chiến lược.** Mọi việc lửng lơ ở giữa phải bị ép chọn xô — đó là việc của nhịp tuần, không phải của cảm hứng.
- **Loại bỏ thay vì tối ưu.** Tối ưu chính cái đáng lẽ phải loại bỏ là dạng lãng phí tinh vi nhất — nó cho cảm giác tiến bộ trong khi đang đánh bóng một thứ không nên tồn tại.
- **Chia suất theo LOẠI.** Làn nền móng được bảo vệ; việc thời cơ không mượn được suất của làn nền móng, dù hấp dẫn tới đâu. Đây là phiên bản tổ chức của luật hai xô, khớp với cặp phân loại thời cơ và nền móng đã có trong đặc thù vận hành của Tracy.
- **Trần cứng số việc đang chạy phải nằm ở tầng dữ liệu, không nằm ở lời khuyên.** Lời khuyên bị quên sau ba ngày; ràng buộc trong cơ sở dữ liệu thì không. App đã làm đúng điều này với trần cam kết theo từng người — mặc định 3, CEO 5, đọc từ cột `so_cam_ket_toi_da` — chốt ngày 11/08.

### 5.5. Framework — Bộ lọc hướng mục tiêu

① **Phép thử mở màn** — nếu một người mình kính trọng xuất hiện và hỏi *việc hướng mục tiêu nhất ngay lúc này là gì* mà mình ấp úng, thì việc đúng lúc này là dừng lại đi tìm câu trả lời. Sự ấp úng chính là kết quả đo.

② **Phân loại việc cần tối ưu và việc chỉ cần đủ, khai ngay lúc giao.** Quyền định nghĩa "80 phần trăm là đủ" thuộc người đặt hàng, không thuộc người làm — bài học từ chính ROVA: một bản nộp chưa soát chính tả kèm lời dẫn triết lý 80 phần trăm là cách nhanh nhất biến triết lý này thành cái cớ. Ô hai lựa chọn lúc giao việc, bỏ trống mặc định là phải chuẩn.

③ **Lọc bằng câu hỏi con thuyền** — *việc này có làm con thuyền đi nhanh hơn không?* Câu của đội chèo thuyền Anh trước Sydney 2000: từ đội kém cỏi thành huy chương vàng Olympic đầu tiên của Anh ở nội dung này kể từ 1912, bằng cách áp đúng một câu đó cho mọi quyết định, từ buổi tập tới bữa ăn.

④ **Chỉ ra một nút thắt, mọi việc khác phục tùng.** Theo Goldratt: cả hệ thống chỉ chảy nhanh bằng chỗ hẹp nhất, nên tăng tốc chỗ không hẹp là vô nghĩa. Mỗi kỳ chỉ một nút thắt được nêu tên; và nhớ rằng ở ROVA nút thắt thật nhiều khả năng là một chính sách — một luật bất thành văn, một thói quen giao việc — chứ không phải một con người hay một công cụ.

⚠️ Bước soát lại theo chu kỳ 6 tháng từng có trong bản nháp đã được bỏ: trong nguồn, chu kỳ 6 tháng gắn với việc kiểm kê gánh vận hành đời sống chứ không gắn với bộ lọc này.

### 5.6. Công thức

`Sản lượng có ích = Giờ × Cường độ tập trung × Mức khớp mục tiêu`

⚠️ Hai biến đầu là công thức của Newport (`Sản lượng chất lượng cao = Thời gian × Cường độ`). Biến thứ ba là phần tôi thêm, không có nguồn. Ba biến nhân nhau, nên nhận thêm một việc kém khớp không phải phép cộng nhỏ mà là phép nhân với một số bé hơn một — nó làm giảm tổng chứ không tăng. Đây là câu trả lời bằng số cho câu hỏi vì sao một đội bận hơn lại tạo ra ít hơn.

### 5.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Ba luống là hết đất — trần cam kết theo từng người (mặc định 3, CEO 5) chặn cứng ở cơ sở dữ liệu | Trần cứng phải nằm ở tầng dữ liệu, giao diện không lách được | ✅ |
| Kho task, việc chưa hẹn ngày chỉ chủ đọc được | Chưa chọn thì không chiếm chỗ trên bảng | ✅ |
| Trần 3 lần hoãn, quá trần thì nút một tự thành Về kho | Không để người dùng chỉ còn cửa Huỷ | ✅ |
| Ô mức hoàn thiện lúc giao việc: đủ dùng hoặc phải chuẩn | Quyền chọn mức hoàn thiện thuộc người đặt hàng, bỏ trống thì mặc định là phải chuẩn | ⬜ |
| Ngân sách việc nông 30 tới 50 phần trăm mỗi tuần | Bỏ bớt phải có định mức, không dựa vào cảm giác | ⬜ |
| Sàng việc bốn ô yêu, thích, ghét nhưng giỏi, ghét và dở | Uỷ thác một việc mỗi quý | ⬜ |
| Nhãn loại dự án: thời cơ, nền móng, gỡ chặn | Luật làn nền móng | ⬜ |

### Kết luận Triết lý 4

TL4 là chủ lực thứ hai của Bài toán Hệ thống, và là triết lý có tính năng nền vững nhất trong app: trần cam kết chặn ở cơ sở dữ liệu là hiện thân đúng nghĩa của nó. Rủi ro lớn nhất của nó là bị dùng sai chiều: bỏ rơi có chiến lược là đặc quyền của người có quyền quyết, và nếu áp thẳng xuống 12 người thì hoặc không ai dám dùng, hoặc ai cũng dùng để tránh việc khó. Bản đầy đủ chia đôi quyền cho rõ: **chọn việc nào** thuộc người có quyền quyết; **chọn mức hoàn thiện** phải được khai ngay lúc giao. Người nhận việc không tự quyết bỏ, nhưng có quyền nhìn thấy định mức việc nông của mình và có quyền nói suất đã đầy — hai quyền đó nằm ở tính năng, không nằm ở thiện chí.

---

## MỤC 6 — TRIẾT LÝ 5 · CHỈ HUY DÀN NHẠC 🟣

*Framework: ⚠️ The Team Flow Architecture — Kiến trúc dòng chảy đội. Tên này không tồn tại trong nguồn Doris nhóm 1 tới 3; đây là khung do người viết ghép. Ruột lấy từ van den Hout.*
*Trả lời nguyên nhân: **N4** ở khâu uỷ thác và suất trống, cùng **N3** ở tầng đội — luật kênh nội bộ; biểu hiện DN1, DN5.*

### 6.1. Bản chất

Lãnh đạo tốt không phải người vào trạng thái sâu giỏi nhất, mà là người dựng được môi trường để cả đội có cửa sổ chắc chắn dài. Vai chỉ huy là vai duy nhất mà thành công đo bằng thành công của người khác — nhạc trưởng không chơi nhạc cụ nào trong buổi diễn, và không ai nói ông ta không làm gì.

Cái giữ người lãnh đạo lại trong vai nhạc công có tên là **Bẫy Nhạc Công**: cái ta giỏi nhất chính là cái giữ chân ta. Chuyển từ nhạc công sang nhạc trưởng không phải chuyển kỹ năng — nó là chuyển **nguồn phần thưởng thần kinh**, và vì thế nó khó hơn mọi khoá học quản trị thừa nhận. Kèm một cảnh báo sắc từ nguồn dành cho người điều hành: **đừng dùng nghề nghiệp làm nguồn dòng chảy chính của mình.** Nó bóp méo việc ra quyết định — ta bắt đầu tối ưu cho cảm giác thăng hoa cá nhân thay vì cho thành công của tổ chức, và dùng công ty như một cần điều khiển để lấy dopamine. Giải pháp là kiếm một nguồn dòng chảy ngoài công việc (thể thao là ứng viên tự nhiên) để phần tâm trí thèm thám hiểm được nuôi ở chỗ khác.

### 6.2. Cơ chế

Trong trạng thái sâu của nhóm, ngoài cocktail hoá chất của dòng chảy cá nhân còn có thêm **oxytocin** — hoá chất của gắn kết — kèm hiện tượng đồng bộ sóng não, nhịp tim và nhịp thở giữa các thành viên. Ở phía ngược lại, tự tay làm cho dopamine đến ngay và chắc chắn, nên người quản lý nghiện cảm giác tự tay hoàn thành, và mỗi lần "để tôi làm cho nhanh" là một lần cả công ty được dạy rằng mọi đường đều phải đi qua một người. Điểm nghẽn không phải do người đó kém — chính vì người đó giỏi nên mọi thứ mới dồn về.

Ở tầng đội, phát hiện quan trọng nhất của van den Hout là các điều kiện của dòng chảy đội **không ngang hàng nhau**: tham vọng tập thể, quyền tự chủ nghề nghiệp và giao tiếp mở phải được vun trồng có chủ ý **trước**, những điều kiện còn lại mới dựng lên được trên nền đó. Nghĩa là không thể mua dòng chảy đội bằng một buổi team building; phải xây nền theo thứ tự.

### 6.3. Cơ sở khoa học

- ✅ **Jef van den Hout và Davis**, Đại học Công nghệ Eindhoven: 7 điều kiện tiên quyết và 4 đặc trưng của dòng chảy đội (cảm giác hợp nhất, tiến bộ chung, tin cậy lẫn nhau, tập trung toàn thể), có bộ đo Team Flow Monitor đã kiểm định tâm trắc. Đây là mảnh có nguồn vững nhất trong cả hệ tám triết lý.
- ✅ **Zhang và cộng sự 2016**, *Preventive Medicine Reports* 4:453–458, thử nghiệm ngẫu nhiên bốn nhánh, N=790, 11 tuần: nhánh so sánh xã hội tăng 62 phần trăm sau hiệu chỉnh (p=.03), giữ chân 95 phần trăm; nhánh động viên nhau **không có tác dụng** (p=.68). Nhìn thấy nhau làm việc có sức mạnh thật — lớn hơn cả lời cổ vũ.
- ✅ **Hydari, Adjerid và Striegel 2023**, *Management Science*: bảng xếp hạng làm người ít vận động tăng khoảng 1.300 bước nhưng làm người đã năng động **giảm 630 bước**. Con dao hai lưỡi có số đo cả hai lưỡi.
- 🟡 **Yang và Koenigstorfer**, *Computers in Human Behavior* 165:108532: quan hệ hình chữ U — vùng bỏ cuộc cao nhất nằm ở khúc giữa bảng xếp hạng, không phải ở đáy.
- ❓ Trong nguồn Doris nhóm 1 tới 3, phần dòng chảy đội rất mỏng: chỉ có hiệu ứng lan từ cuộc họp này sang cuộc họp kế, oxytocin, và định nghĩa lãnh đạo tốt là người dựng cửa sổ chắc chắn dài cho đội. Toàn bộ phần còn lại của triết lý này đứng trên van den Hout và trên tầng giữ lời của vault, không phải trên Doris.

### 6.4. Nguyên lý

- **Chỉ huy chứ không tự tay làm thay. Hỏi ai làm trước khi hỏi làm thế nào.** Câu "ai" đi trước câu "thế nào" là ranh giới hành vi giữa nhạc trưởng và nhạc công — kiểm được từng lần giao việc.
- **Ba điều kiện nền — tham vọng tập thể, tự chủ nghề nghiệp, giao tiếp mở — phải được vun trồng có chủ ý trước.** Chúng không tự có, và không mua được bằng sự kiện; chúng được xây bằng nhịp.
- **Chia đôi ngày là cách hoà giải duy nhất giữa khối sáng bất khả xâm phạm và nhu cầu sẵn sàng cho đội.** Sáng làm việc của mình, chiều làm việc của đội — cả hai vai đều có chỗ đứng trong lịch, nên không vai nào phải lấn vào giờ của vai kia.
- **Lưới của đội là quảng trường để gỡ chặn cho nhau, không phải camera để chấm người.** ✅ Tracy đã chốt ngày 11/08: lưới 12 người giữ nguyên, giữ cả đường bấm xuống chi tiết cá nhân (*"Giữ chứ đang hay"*). Bản khung từng viết nguyên lý này là "không xếp hạng cá nhân" — viết vậy không còn trung thực nữa, vì một lưới 12 hàng có độ sáng so được bằng mắt **là** một bảng xếp hạng dù không đánh số. Nguyên lý viết lại theo thực tế: app **có** một bảng nhìn thấy nhau, và thứ giữ nó không biến thành camera là **luật đọc** — đọc lưới để tìm chỗ cần gỡ chặn cho nhau, không để chấm ai chăm ai lười. Luật đọc này phải được nói thành lời với cả đội một lần, trước ngày mở app cho 12 người, và nó là điều kiện đi kèm của quyết định giữ lưới chứ không phải một gợi ý.

### 6.5. Framework — Kiến trúc dòng chảy đội

① **Bảng liệt kê mọi việc trong tuần** của người điều hành; việc ngoài vùng sở trường thì loại bỏ hoặc uỷ thác. Đây là bước phá Bẫy Nhạc Công bằng giấy trắng mực đen thay vì bằng quyết tâm.

② **Dựng đủ 7 điều kiện tiên quyết của van den Hout:** tham vọng tập thể, mục tiêu đội táo bạo, giao tiếp mở, mục tiêu cá nhân khớp nhau, tích hợp kỹ năng cao, an toàn, và cam kết tương hỗ. Thứ tự dựng theo phát hiện của chính van den Hout: vun bộ nền trước — tham vọng tập thể, quyền tự chủ nghề nghiệp, giao tiếp mở — rồi những điều kiện còn lại mới dựng lên được trên đó.

③ **Gom họp về một ngày, giữ 3 tới 4 ngày liên tiếp không điểm nghẽn.** Một cuộc họp giữa sáng thứ Ba không tốn 30 phút — nó bẻ đôi đường băng đắm chìm của cả tuần. Dồn họp lại là món quà lớn nhất người xếp lịch tặng được cho đội.

④ **Nhịp ngày 5 tới 15 phút và nhịp tuần 90 phút.** Giao tiếp mở không dựng bằng thiện chí mà bằng nhịp có giờ: nhịp ngày trả lời có gì mới, một con số, đang tắc ở đâu; nhịp tuần là chỗ những tín hiệu yếu được nói thành lời.

⑤ **Chia đôi ngày: sáng làm việc của mình, chiều làm việc của đội.** Cửa của đội mở buổi chiều — có giờ, có thật, đáng tin — để khối sáng được thiêng mà không ai bị bỏ rơi.

### 6.6. Công thức

`Dòng chảy đội = min(7 điều kiện tiên quyết)`

⚠️ Công thức do tôi ghép từ danh sách của van den Hout. Đây là quy tắc mắt xích yếu nhất: hàm min chứ không phải trung bình — một điều kiện bằng không, chẳng hạn an toàn tâm lý, thì mọi đầu tư vào sáu điều kiện kia không đổi được kết quả. Hệ quả thực dụng: đo cả bảy, và mỗi kỳ chỉ đầu tư vào điều kiện đang thấp nhất thay vì vun tiếp chỗ đã cao.

### 6.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Chế độ Cả ROVA, thẻ từng người, số chấm theo trần cam kết của từng người (mặc định 3, CEO 5) | Nhìn thấy nhau ở tầng cam kết | ✅ |
| Lưới 12 người nhân 7 ngày, kèm khung 4 tuần | Nhìn thấy nhau ở tầng nhịp ngày. ✅ Tracy chốt 11/08 giữ nguyên cả đường bấm xuống; đi kèm luật đọc công bố một lần trước ngày mở app | ✅ |
| Hai bảng vinh danh cân nhau: quả và giờ | Không để một trục đứng một mình | ✅ |
| Nhịp ngày 5 tới 15 phút: có gì mới, một con số, đang tắc ở đâu | Giao tiếp mở phải có nhịp, không dựa vào thiện chí | ⬜ |
| Ô tuần ba phần: Ưu tiên, Khó khăn, Quan sát | Radar tín hiệu yếu giữa hai buổi họp | ⬜ |
| Cảnh báo lịch khi mất chuỗi ngày không họp | Đường băng đắm chìm | ⬜ đang bị chặn bởi quyết định gác việc nối Google Calendar |

### Kết luận Triết lý 5

TL5 là triết lý duy nhất không minh hoạ được bằng app cá nhân, và cũng là triết lý có nguồn khoa học vững nhất. Mâu thuẫn lớn nhất của nó — nguyên lý cấm xếp hạng trong khi app chạy một lưới so được bằng mắt — **đã được Tracy phân xử ngày 11/08: giữ lưới, và bản này đã viết lại nguyên lý cho trung thực.** Cái giá của quyết định đó được ghi nhận thẳng: app có một bảng nhìn thấy nhau hoạt động như bảng xếp hạng, bằng chứng khoa học về loại bảng này có cả hai chiều, nên phần bù bắt buộc là luật đọc công bố với đội và nhịp gặp nhau thật (nhịp ngày, ô tuần) phải được dựng **trước** khi mở rộng chế độ nhìn thấy nhau — nhìn thấy nhau mà không có chỗ nói chuyện với nhau thì đúng định nghĩa của camera, như Mục 10 lỗi E2 đã cảnh báo.

---

## MỤC 7 — TRIẾT LÝ 6 · TỐI GIẢN HOÁ NHẬN THỨC 🟣

*Framework: Cognitive Load Dump — Cú đổ tải nhận thức. Lưu ý: Cognitive Offloading là tên cơ chế não, không phải tên framework.*
*Trả lời nguyên nhân: **N2** vòng lặp mở (chính); biểu hiện CN4.*

### 7.1. Bản chất

Người làm việc đỉnh cao không có bộ não tốt hơn, họ có bộ não rỗng hơn — *"Elite performers don't have better brains. They have emptier ones."* Câu này đảo ngược cả một nền văn hoá làm việc: ta quen phục người nhớ được nhiều thứ cùng lúc, trong khi năng lực thật nằm ở chỗ **không phải nhớ gì cả** — mọi thứ đáng nhớ đã có chỗ nằm bên ngoài đầu. Và tải nhận thức không phải *một trong những* thứ chặn dòng chảy; nó là **thứ** chặn dòng chảy — mọi blocker khác cuối cùng đều quy về việc chiếm chỗ trong bộ nhớ làm việc.

### 7.2. Cơ chế

Bộ nhớ làm việc chỉ giữ được vài đơn vị cùng lúc — các ước lượng dao động quanh 4 tới 7. Mỗi việc dở dang giữ trong đầu, mỗi lời hứa chưa ghi ra, mỗi con số phải nhớ chiếm một suất trong quỹ ít ỏi đó, và chúng không xếp hàng im lặng: khi tải cao, mạng lưới chế độ mặc định và mạng lưới nhiệm vụ cùng bắn một lúc, tạo tình trạng kẹt xe thần kinh — vừa không nghĩ sâu được vừa không nghỉ được. Đó là trạng thái quen thuộc của buổi chiều nhiều việc: ngồi trước màn hình không làm được gì, đứng dậy nghỉ cũng không yên.

Việc viết ra giấy hiệu quả không phải vì giấy thần kỳ: viết tay huy động vỏ thị giác và vỏ vận động, nhưng phần lớn lợi ích đến từ hành động **đưa ra ngoài** — một vòng lặp đã có chỗ nằm bên ngoài thì thôi chiếm suất bên trong. Nền khoa học của vế này là dư âm chú ý của Leroy, không phải hiệu ứng Zeigarnik (đã bị lật, xem 7.6).

### 7.3. Cơ sở khoa học

- ✅ **George Miller**, Harvard, bài kinh điển 1956: trí nhớ ngắn hạn giữ 7 cộng trừ 2 đối tượng.
- ✅ **John Sweller** (UNSW): lý thuyết tải nhận thức; các ước lượng hiện đại quanh 4 tới 7 mảnh.
- ✅ **Csikszentmihalyi**: ý thức xử lý khoảng 7 đơn vị thông tin cùng lúc, trần khoảng 126 bit mỗi giây; riêng nghe hiểu một người nói đã tốn khoảng 40 bit mỗi giây — tức là gần một phần ba băng thông của ý thức.
- ⚠️ Hai ước lượng cạnh tranh nhau: Miller 7 cộng trừ 2 và Cowan 4 cộng trừ 1. Đây chưa phải con số đã chốt; bản này dùng khoảng 4 tới 7 và không xây gì đòi độ chính xác cao hơn thế.
- ❌ Không dùng cặp số ý thức 40 bit mỗi giây so với tiềm thức 400 tỷ bit mỗi giây; chính nguồn ghi đây là mục đáng nghi nhất trong kho số của Doris.

### 7.4. Nguyên lý

- **Giữ tải nền ở mức 20 tới 30 phần trăm, không phải 0 và không phải 100.** Về 0 là ảo tưởng — luôn có việc đang sống; lên 100 là kẹt xe. Mục tiêu của mọi cơ chế dọn là đưa tải nền về vùng này.
- **Mỗi mục sau khi đổ ra chỉ có bốn cửa: làm ngay nếu dưới 2 phút, lên lịch, bỏ đi, giao lại.** Không có cửa thứ năm "để đó tính sau" — để đó nghĩa là quay lại trong đầu.
- **Nội dung quan trọng nhất phải to và dễ nhìn nhất. Màu nói tốt hay xấu, không nói tăng hay giảm.** Đây là nguyên lý thứ tự mắt nhìn — đã thành bộ luật thiết kế chung của app, nhắc ở đây vì gốc của nó là tải nhận thức: mỗi giây người dùng phải tự tìm con số quan trọng là một giây tải vô ích.
- **Chỗ nào phải nhớ bằng đầu thì chỗ đó là một lỗi thiết kế.** Quy trình phải nằm trong checklist, việc chưa xong phải có chỗ nằm, ý xen ngang phải có ô ghi — trí nhớ con người không phải hạ tầng lưu trữ của hệ thống.

### 7.5. Framework — Cú đổ tải nhận thức

① **Đổ hết ra giấy** — mọi thứ đang mở trong đầu, việc lớn việc vặt lẫn lộn không sao; và viết thêm 3 tới 5 phút **sau khi tưởng đã hết**, vì lớp cuối cùng mới là lớp chiếm chỗ dai nhất.

② **Mỗi mục đi qua đúng một trong bốn cửa:** dưới 2 phút thì làm ngay · lên lịch có ngày giờ · bỏ đi có chủ ý · giao lại có người nhận.

③ **Gấp giấy cất khuất mắt.** Tờ giấy nằm trong tầm nhìn là tờ giấy còn phát tín hiệu; cất đi là nghi thức nói với não rằng mọi thứ đã có chỗ.

④ **Thở theo nhịp hít 3, giữ 2, thở ra 10 — ba vòng.** Thở ra dài gấp ba hít vào bật hệ phó giao cảm; ba vòng mất chưa đầy một phút, đủ hạ nhịp trước khi vào việc.

⑤ **Vào việc ngay, không đọc lại danh sách.** Đọc lại là mở lại từng vòng lặp vừa đóng.

### 7.6. Công thức

`Dung lượng khả dụng = Trần bộ nhớ làm việc (4 tới 7, ⚠️ khoảng ước lượng đang tranh cãi) − Số vòng lặp còn mở đang giữ trong đầu`

⚠️ Công thức do tôi ghép. Nền của vế thứ hai là **dư âm chú ý** (Leroy 2009) — một việc dở dang giữ trong đầu tiếp tục chiếm một phần chú ý — chứ không phải hiệu ứng Zeigarnik: hiệu ứng đó đã bị phân tích tổng hợp 2025 trên 59 công trình lật lại, và bản này không viện dẫn nó ở bất kỳ đâu. Điều công thức nói bằng số: với trần chỉ 4 tới 7, mỗi vòng lặp đóng lại được là giành lại 15 tới 25 phần trăm dung lượng của cả bộ não — không có khoản đầu tư nào rẻ hơn thế.

### 7.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Ô thêm việc nhanh, hai ô nặng dời sang lúc Sửa | Cửa vào ít ma sát, nếu khó nhập thì người ta giữ trong đầu | ✅ |
| Checklist bước con trong việc cố định | Quy trình nằm ngoài đầu, không phải trong trí nhớ | ✅ |
| Khối Còn nợ từ hôm trước | Việc chưa xong phải có chỗ nằm, nếu không nó nằm trong đầu | ✅ |
| Ô ghi chú giữa phiên cho ý xen ngang | Ghi ra thì thôi chiếm chỗ | ⬜ |
| Ba con số lõi, mỗi số tháo thành bốn đòn bẩy làm được hôm nay | Một màn hình trả lời được câu tối nay làm gì để mai khá hơn | ⬜ |
| Mốc so 30 ngày dán kèm mọi con số | Số không có mốc là số câm | ⬜ |

### Kết luận Triết lý 6

TL6 phục vụ Bài toán Trạng thái và là triết lý dễ dựng thành tính năng nhất, vì mọi cơ chế của nó đều là thao tác giao diện: một ô nhập nhanh, một chỗ nằm cho việc dở, một checklist. Ba tính năng lõi đã chạy. Chỗ hụt được khai thật: nó chỉ dọn **tải nhận thức**, trong khi bộ ba tải của Doris còn tải thích nghi (đã thuộc TL2) và tải vận hành đời sống (không có chủ, đã ghi ở KT3 và cố ý để ở tầng cá nhân của Tracy). Nguyên lý thứ tự mắt nhìn đã được chuyển về đúng chỗ là bộ luật thiết kế chung, không tính là một tính năng.

---

## MỤC 8 — TRIẾT LÝ 7 · GIỮ LỜI VÀ CUỘC CHƠI 🟢

*Framework: Cuộc chơi Giữ Lời. Triết lý mở thêm từ vault, không có trong sáu triết lý gốc.*
*Trả lời nguyên nhân: **N4** cấp phát không có luật (chính) và **N2** qua nghi thức đóng; biểu hiện DN6, CN6. Đây là triết lý ôm cái lõi "biến cam kết thành kết quả" trực tiếp nhất.*

### 8.1. Bản chất

Giữ lời không phải phạm trù đạo đức mà là một **yếu tố sản xuất** — cùng hàng với vốn, công nghệ và con người. Đó là luận điểm trung tâm của Erhard, Jensen và Zaffron trong *Integrity: A Positive Model*: họ cố ý tách integrity ra khỏi đạo đức và luân lý, định nghĩa nó thuần tuý như một trạng thái **toàn vẹn** — như một chiếc bánh xe đủ nan hoa — và chứng minh rằng thiếu nó thì không có gì thực sự vận hành được, bất kể ý định tốt tới đâu.

Và giữ lời có hai vế chứ không phải một: **làm đúng lời**, và khi không thể làm đúng thì **báo sớm cộng dọn hậu quả**. Vế thứ hai mới là vế phân biệt hệ thống trưởng thành với hệ thống ngây thơ: đời thật không ai giữ được mọi lời, nên một hệ thống chỉ có vế một sẽ dạy người ta hoặc hứa thật ít, hoặc giấu thật kỹ. Hệ thống có vế hai thì giữ được cả tham vọng lẫn sự thật.

Vế "cuộc chơi" đến từ cụm Kiến Tạo Cuộc Chơi của vault: người lãnh đạo giỏi không giao chỉ tiêu — họ dựng một **cuộc chơi** có tương lai đáng muốn, luật rõ, điểm số đo được và nhịp review, để đội **tự muốn** chơi thay vì bị thúc. App Khu Vườn chính là bảng điểm của một cuộc chơi như thế; nó không phải phần mềm chấm công.

### 8.2. Cơ chế

Cơ chế tổ chức là chuỗi ba mắt xích của Erhard và Jensen: **toàn vẹn → tính vận hành → hiệu suất**. Rút một nan hoa thì bánh xe vẫn còn hình tròn nhưng không lăn được: một lời hứa bị lặng lẽ bỏ rơi làm người quanh nó phải tự phòng bị — kiểm tra lại, làm dư, không dám xây kế hoạch của mình lên lời hứa của người khác — và chính sự phòng bị đó là chỗ hiệu suất chảy mất. Cái giá của thất hứa không nằm ở việc không xong; nó nằm ở chỗ **cả hệ thống thôi tin được nhau**, và từ đó mọi thứ đều đắt lên.

Cơ chế thần kinh của vế cá nhân: khi một trạng thái khó chịu **kết thúc** — nói xong lời từ chối khó nói, báo xong tin xấu phải báo — dopamine ở nhân accumbens tăng và cortisol tụt mạnh, củng cố hành vi vừa làm. Nghĩa là tính quyết đoán, việc nói không, việc báo sớm tin xấu đều **rèn được bằng lặp lại**: mỗi lần làm là một lần não được thưởng cho đúng hành vi đó, và lần sau rẻ hơn lần trước. Hệ thống chỉ cần đảm bảo một điều: cửa để làm những việc khó đó phải luôn mở và không bị phạt.

### 8.3. Cơ sở khoa học

- ✅ **Erhard, Jensen và Zaffron**, *Integrity: A Positive Model* — mô hình toàn vẹn như yếu tố sản xuất, đã nạp tại `wiki/quan-tri-van-hanh/tom-tat-nguon/integrity-positive-model.md`.
- ✅ **Kluger và DeNisi 1996**, *Psychological Bulletin* 119(2):254–284, phân tích tổng hợp 607 hệ số hiệu ứng trên 23.663 quan sát: phản hồi giúp hiệu suất trung bình d=0,41 — nhưng **38 phần trăm hệ số mang dấu âm**. Biến quyết định chiều: phản hồi hướng về **việc** thì giúp, phản hồi hướng về **bản thân người làm** thì hại. Đây là nền của luật "câu chữ nói về việc, không nói về người" mà mọi lời văn trong app phải theo.
- ✅ **Lally 2010** (UCL), nghiên cứu hình thành thói quen: bỏ một ngày **không ảnh hưởng đo được** tới đường hình thành thói quen; trung vị 66 ngày, dải 18 tới 254. Nghĩa là nỗi sợ "đứt một ngày là mất hết" không có nền khoa học.
- 🔴 **Chuỗi ngày liên tục:** dữ liệu lớn về chuỗi cho thấy chỉ **0,90 phần trăm** người đứt chuỗi quay lại mở chuỗi mới — chuỗi càng dài, cú đứt càng giống một lời mời rời bỏ. Cơ chế thật bên dưới sự hăng hái gần đích là **dốc mục tiêu** (Kivetz, Urminsky và Zheng 2006, *JMR* 43(1):39–58), không phải bản thân chuỗi. Chuỗi mượn sức của dốc mục tiêu rồi trả bằng cú rơi khi đứt.
- ⚠️ Con số đột phá 100 tới 500 phần trăm trên slide nguồn, và con số 23,3 phần trăm của Bitner: vault đã gắn nhãn chưa xác thực, không dùng.

### 8.4. Nguyên lý

- **Hệ thống phạt thất bại thì người ta giấu; hệ thống chỉ phạt sự im lặng thì người ta nói.** Đây là nguyên lý mẹ của mọi cơ chế trạng thái trong app: mọi cửa ra đều hợp lệ trừ cửa biến mất không lời.
- **Mỗi cam kết phải có chỗ hiện hữu: bước kế tiếp, hạn, và một khối giờ thật đặt vào lịch.** Lời hứa không có ba thứ đó chưa phải cam kết — nó là một ý định mặc áo cam kết. App đã siết đúng hướng này: hạn thành bắt buộc ở cả cửa gieo lẫn cửa sửa từ 11/08.
- **Cân nhắc kỹ TRƯỚC khi hứa; sau khi đã hứa thì không cân nhắc lại lúc thực hiện.** Chuyển toàn bộ sự đắn đo về trước cái gật đầu. Sau gật đầu, câu hỏi duy nhất còn hợp lệ là "làm thế nào", không phải "có đáng không" — trừ khi kích hoạt đường báo sớm.
- **Thưởng nhỏ để công nhận, không có bảng tỉ giá điểm đổi ra tiền.** ⏳ Chạy theo mặc định — Tracy từng đề nghị điểm đổi quà ngày 09/08 và chưa chốt lại. Lý lẽ của mặc định: một khi có bảng tỉ giá, mọi quả trên vườn đổi nghĩa từ *kết quả của tôi* thành *đơn vị lương*, và toàn bộ tầng động lực nội sinh mà app xây dựng chuyển sang chạy bằng động lực ngoại sinh — đúng cái bẫy mà 154 ngày chạy thật của Game Kim Cương đã tránh được: tiền chỉ dùng để đặt cược, quà nhỏ dùng để công nhận.

### 8.5. Framework — Cuộc chơi Giữ Lời

① **Tuyên bố một thứ tự ưu tiên** — cuộc chơi ra đời tại thời điểm có người đứng ra nói *cái này quan trọng hơn cái kia*. Không có tuyên bố thì chỉ có một đống việc, không có cuộc chơi.

② **Khai đủ 7 thành phần của cuộc chơi:** tương lai muốn tạo ra · lý do đủ quan trọng và hào hứng để tham gia · ai chơi vị trí nào · hành vi khuyến khích, cấm, bắt buộc · cách đo tiến bộ và thời hạn chơi · cam kết hiện hữu của người chơi — **chơi để thắng và chơi để tận hưởng** · cuộc chơi sống trong nhịp họp nào. Thành phần 6 là linh hồn: thiếu nó thì cuộc chơi thành chỉ tiêu khoác áo trò chơi, và người chơi đọc ra sự giả rất nhanh.

③ **Mỗi lời hứa được đặt một khối giờ thật.** Lời hứa chưa có giờ trong lịch là lời hứa đang cạnh tranh vô vọng với những thứ đã có giờ.

④ **Khi biết sẽ lỡ thì chạy ba bước dọn dẹp: báo ngay, hạn mới, dọn hậu quả.** Dọn hậu quả nghĩa là xử lý hệ quả cho **người đang chờ** — nếu không ai chờ thì hạn mới là đủ, không bày nghi thức thừa.

⑤ **Hai nhịp tách bạch** — nhịp **tuần** bắt buộc để nói chuyện về cuộc chơi (điểm số, chỗ tắc, lời sắp lỡ), và nhịp **90 ngày** để soi lại chính luật chơi (luật nào đang bị lách, điểm nào đo sai việc). Luật gốc của Kiến Tạo Cuộc Chơi nói đừng bao giờ mong cuộc chơi tự duy trì — và nhịp mà luật đó đòi là nhịp TUẦN chứ không phải nhịp quý.

### 8.6. Công thức

`Tỉ lệ giữ lời = Số cam kết đóng tử tế ÷ Số cam kết đến hạn`

Đóng tử tế nghĩa là xong đúng hạn, HOẶC báo trước hạn kèm hạn mới kèm việc dọn hậu quả. Im lặng tính bằng không. ⚠️ Công thức do tôi ghép từ chuỗi toàn vẹn, tính vận hành và hiệu suất; chuỗi đó có nguồn, còn dạng phân số là của tôi. Hai điều bắt buộc đi kèm để công thức không phản chủ: thứ nhất, một cột riêng bên cạnh phải đếm số lần **dừng có tuyên bố** — nếu không, việc dừng lại đúng theo TL4 sẽ bị chấm như thất hứa, và hệ thống phạt đúng hành vi nó đang dạy (Mục 10, lỗi C2). Thứ hai, mẫu số chỉ đếm cam kết **có hạn** — và vì hạn nay đã bắt buộc, mẫu số này mới bắt đầu có nghĩa.

### 8.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Ba cửa ra khi kết phiên kèm ô ghi bắt buộc, không có cửa thoát im lặng | Im lặng là thứ duy nhất bị phạt | ✅ |
| Màn Dọn việc hôm qua chặn cứng, bốn trạng thái kết thúc | Không để một việc trôi quá một ngày mà chưa đổi trạng thái | ✅ |
| Cây chỉ héo khi tự bấm bỏ cuộc, đã bỏ luật héo khi rời app | Không trừng phạt thất bại, chỉ không chấp nhận sự im lặng | ✅ |
| Lưới ngày kiểu lịch nhiệt và tổng giờ cộng dồn, chỉ tăng | Đơn vị cộng dồn không đứt được | ✅ |
| Bỏ đếm chuỗi ngày liên tục ở tầng có tính trừng phạt | Chống bẫy chuỗi ngày. ⏳ Chạy theo mặc định: chuỗi giữ ở gương soi riêng, bỏ khỏi mọi chỗ công khai và mọi công thức điểm — dung hoà với luật chuỗi hai bản Tracy chốt 09/08 bằng cách giữ chuỗi cho mình, không giữ chuỗi trước đám đông. ⚠️ Dữ kiện mới hơn 11/08: Tracy chốt *mất chuỗi thì trả giá để khôi phục* (100 squat, 3 km chạy, hoặc 50 chống đẩy) cho bình tưới vòng 2 — cơ chế trả giá là một đường quay lại sau cú đứt, chữa đúng con số 0,90%; khi gạch thì phân xử cả cặp chuỗi và trả giá một lần | ⬜ |
| Nút Tôi sẽ lỡ hẹn: báo người liên quan, chọn hạn mới, ghi việc dọn | Vế hai của giữ lời được tôn vinh thay vì bị giấu | ⬜ |
| Trạng thái Dừng có tuyên bố, cần xác nhận của người nhận cam kết | Việc dừng đúng theo TL4 không được rơi vào mẫu số như một lần lỡ hẹn | ⬜ |
| Chỉ số tỉ lệ cam kết đúng hạn làm con số sức khoẻ chính | Đo giữ lời thay vì đo số việc xong | ⬜ |
| Lễ mùa gặt 90 ngày, vật nhỏ kèm nghi thức | Thưởng nhỏ nuôi động lực, thưởng lớn làm hỏng nó | ⬜ |

### Kết luận Triết lý 7

TL7 là tầng triết lý đang nằm dưới toàn bộ app mà Doris không có — Doris dạy một người tự giữ trạng thái, còn tầng này giữ **lời giữa người với người**, và chính nó biến app từ công cụ cá nhân thành hệ vận hành của một đội. Bốn tính năng lõi của nó đã chạy, và chúng là những tính năng táo bạo nhất của app: chặn cứng buổi sáng, không cửa thoát im lặng, cây chỉ héo khi tự tuyên bố. Hai chỗ từng chờ phân xử nay chạy theo mặc định có đánh dấu ⏳ — chuỗi ngày rút về gương soi riêng, điểm không đổi ra tiền — cả hai đều gạch được nếu Tracy muốn khác.

---

## MỤC 9 — TRIẾT LÝ 8 · CHỒNG MỤC TIÊU CHUNG 🟢

*Framework: Bốn tầng một hướng. Triết lý mở thêm từ vault; Doris chỉ có chồng mục tiêu cá nhân.*
*Trả lời nguyên nhân: **N1** entropy ở tầng tổ chức (chính) — nguyên nhân mẹ; biểu hiện CN1, DN4.*

### 9.1. Bản chất

Dòng chảy không có hướng chỉ là tốc độ; thứ cần là vận tốc — *"Flow without goal directedness is just speed. What we want is velocity."* Một đội mười hai người đều đặn vào trạng thái sâu mỗi sáng vẫn có thể là một đội đứng yên, nếu mười hai mũi tên chỉ mười hai hướng. Doris có chồng mục tiêu — nhưng là chồng **cá nhân**: mục đích đời người, mục tiêu năm, quý, tuần, hành động hôm nay. Với một doanh nghiệp, thứ phải có là **một chồng mục tiêu chung**: hành động từng phút của từng người truy được ngược lên cùng một mục tiêu doanh nghiệp, không phải mười hai chồng riêng tình cờ đứng cạnh nhau. Đây là triết lý trả lời nỗi đau đầu tiên và sâu nhất của bản nỗi đau — entropy tâm trí, ý thức không có cấu trúc thì trôi vào hỗn loạn — ở quy mô tổ chức: một tổ chức không có chồng mục tiêu chung là một ý thức tập thể không có cấu trúc.

### 9.2. Cơ chế

Ở tầng cá nhân, chồng mục tiêu nối hành động từng phút với tầm nhìn dài hạn và chặn **sự trôi mục tiêu** — thứ mà mỗi bước rời chỉ nhỏ một chút, không bước nào đáng báo động, và sau một quý thì việc đang làm không còn liên quan tới việc định làm. Chốt chặn của nó là nghi thức đối chiếu: mỗi tuần mở chồng mục tiêu ra so một lần, sửa hướng khi độ lệch còn rẻ.

Ở tầng tổ chức, cơ chế là **sự hiện ra** theo Ba Quy Luật Hiệu Suất của Zaffron và Logan: con người hành xử theo cách công việc *hiện ra* với họ, không phải theo cách công việc *là*. Cùng một chỉ tiêu, hiện ra như mệnh lệnh bị áp thì sinh đối phó, hiện ra như kỷ lục cần vượt trong một cuộc chơi mình đã nhận lời thì sinh nỗ lực tự nguyện. Đổi cách mục tiêu hiện ra — qua ngôn ngữ, qua cách giao, qua việc ai được tham gia đặt nó — làm đổi hành vi mà không cần thêm một lời thúc ép nào. Đây là chỗ TL8 bắt tay TL7: chồng mục tiêu cho cuộc chơi cái đích, cuộc chơi cho chồng mục tiêu sức sống.

### 9.3. Cơ sở khoa học

- ✅ **Locke và Latham 2002**, *American Psychologist* 57(9):705–717, tổng kết 35 năm nghiên cứu đặt mục tiêu: hơn 100 loại nhiệm vụ, hơn 40.000 người, ít nhất 8 quốc gia, d=0,42 tới 0,80 — mục tiêu cụ thể và khó tạo hiệu suất cao hơn hẳn "cố hết sức". Hai điều kiện bắt buộc hay bị quên: cam kết với mục tiêu, và **phản hồi cho thấy tiến độ** — không có phản hồi thì mục tiêu khó chỉ còn là áp lực.
- ✅ **Wickman**, *Traction* tr.151–157: kỷ luật Rocks — 3 tới 7 ưu tiên mỗi 90 ngày, mỗi ưu tiên đúng một chủ; quá 7 là không còn ưu tiên nào.
- ✅ **Harnish**, *Scaling Up*: nhịp họp lồng nhau ngày, tuần, tháng, quý, năm — ai nhịp nhanh hơn thì lớn nhanh hơn; nhịp là thứ biến mục tiêu từ văn bản thành sinh hoạt.
- ✅ **Zaffron và Logan**, *The Three Laws of Performance*: hành xử đi theo cách sự việc hiện ra; sự hiện ra đổi được qua ngôn ngữ tạo sinh. Đã nạp vào vault trong cụm Ba Quy Luật Hiệu Suất.
- ⚠️ Ràng buộc thật của ROVA: chu kỳ quyết định khoảng **1 tháng**, ngắn hơn nhịp 90 ngày của cả EOS lẫn Scaling Up. Bản này rút nhịp mục tiêu về tháng và phải nói rõ vì sao rút được: các khung 90 ngày sinh ra cho tổ chức trăm người đổi hướng chậm; một đội 12 người phẳng, quyết trong ngày, thì chu kỳ tháng giữ được cùng cấu trúc với giá điều phối rẻ hơn. Cái phải giữ nguyên không phải độ dài chu kỳ mà là **kỷ luật bức tường**: trong chu kỳ không chen mục tiêu mới.
- ❓ Vault chưa có mục tiêu quý của ROVA, nên toàn bộ tầng trên cùng của chồng chưa ánh xạ được bằng dữ liệu thật. Đây là khoảng trống dữ liệu, không phải khoảng trống thiết kế — và nó là lý do TL8 phải triển khai trước.

### 9.4. Nguyên lý

- **Một cam kết chỉ được đứng dưới đúng một mục tiêu còn sống.** Không có mục tiêu cha thì nó là việc phát sinh, không phải cam kết — vẫn được làm, nhưng không được mang danh cam kết và không chiếm suất cam kết.
- **Cam kết là bức ảnh chụp thế giới lúc xong, không phải một hành động.** Đọc lên hỏi *xong chưa*, phải trả lời được CÓ hoặc KHÔNG dứt khoát. "Cải thiện CRM" không phải cam kết; "2.435 dòng CRM có trạng thái công nợ" là cam kết.
- **Tầm nhìn thì mềm, kế hoạch thì cứng.** Chân trời 6 tới 18 tháng ở tầng của Tracy được phép mơ hồ và được phép đổi; chân trời tuần ở tầng nhân viên thì phải cứng tới mức đặt được vào lịch. Đảo lại — tầm nhìn cứng, tuần mơ hồ — là công thức của tổ chức vừa cứng nhắc vừa hỗn loạn.
- **Bức tường mục tiêu: chốt rồi thì việc mới rơi vào danh sách kỳ sau, không chen ngang.** Bức tường không cấm ý tưởng — nó cho ý tưởng một chỗ xếp hàng, để người đang chạy không bị đổi đề bài giữa chừng.

### 9.5. Framework — Bốn tầng một hướng

① **Mục tiêu doanh nghiệp** do người đứng đầu công bố, dạng động từ, không có số — nó là hướng, không phải chỉ tiêu; có số ở tầng này là làm thay việc của tầng dưới.

② **Mục tiêu phòng ban** dạng danh từ, có số và có hạn — bức ảnh chụp trạng thái phải đạt.

③ **Cam kết cá nhân** gói trong 1 tuần, tối đa theo trần của vị trí — mặc định 3, CEO 5 — khớp trần cứng đã chạy trong app từ 11/08.

④ **Task** cỡ 1 tới 4 khối làm việc. ⚠️ Chỗ này đang hở và khai thật: luật "1 tới 4 khối nhân 30 phút" vẫn còn sống trong tài liệu trong khi khung phiên 30 phút cố định đã được bỏ khỏi app từ bản deepwork tự do — bản lộ trình phải chọn lại đơn vị đo cỡ task (đề nghị: đổi sang ước lượng phút tự khai, đã có tính năng 🔶 ở TL3).

⑤ **Bánh đà mục tiêu mỗi tuần:** rà lại chồng mục tiêu từ trên xuống, chọn tối đa 3 hành động, đặt vào lịch **trước mọi thứ khác**. Đây là phiên bản đội của nghi thức tắt máy — cùng một cơ chế chống trôi, chạy ở nhịp tuần.

### 9.6. Công thức

`Vận tốc = Tốc độ × Hướng`, đo được bằng `Mức căn chỉnh = Giờ sâu đổ vào task đứng dưới một cam kết còn sống ÷ Tổng giờ sâu`

⚠️ Vế đầu là ẩn dụ của Doris, vế sau là công thức do tôi ghép. Ý nghĩa: tăng giờ sâu mà mẫu số tăng nhanh hơn tử số thì đội bận hơn nhưng công ty không tiến — đó chính là *dòng chảy sai chỗ*, đề bài của Bài toán Hệ thống, nay có một con số để theo dõi. Dữ liệu cho tử số đã có sẵn trong app hôm nay: phiên deepwork gắn task, task gắn được cam kết — chỉ còn thiếu phép chia.

### 9.7. Tính năng trong công cụ

| Tính năng | Nguyên lý đứng sau | Trạng thái |
|---|---|---|
| Tầng cam kết cá nhân, gieo kèm Output và hạn | Cam kết là bức ảnh chụp lúc xong | ✅ |
| Bảng đo bốn ô đầu tab Cam kết | Phản hồi cho thấy tiến độ, điều kiện bắt buộc của Locke và Latham | ✅ |
| Vòng điểm ngày và nút Chốt ngày cho luồng nhịp vận hành | Hai luồng việc khác nhau thì hai cách đo khác nhau | ✅ |
| Giao diện tầng Mục tiêu cho leader, bảng dữ liệu đã có mà app chưa dùng | Một cam kết đứng dưới đúng một mục tiêu cha | ⬜ |
| Tỉ lệ giờ sâu đổ đúng vào cam kết | Đo mức căn chỉnh, không chỉ đo tổng giờ | ⬜ |
| Làn TUẦN cho việc theo tuần và tháng | Nhịp lồng nhau; chữ trong app đã hứa mà chưa có chỗ | ⬜ |
| Nhãn 10 tiêu điểm dùng chung cả đội | Đã thay bằng 3 cam kết cá nhân ngày 05/08 | ⚰️ |

### Kết luận Triết lý 8

TL8 là chủ lực của Bài toán Hệ thống và là triết lý phải triển khai **trước**, không phải sau. Lý do nằm trong chính công thức của nó: cho 12 người vào phiên sâu trước khi có hướng chung là làm tăng vế tốc độ trong khi vế hướng bằng không — app càng hiệu quả, đội càng chạy nhanh về các hướng ngẫu nhiên. Việc cụ thể đầu tiên của nó không phải tính năng mà là dữ liệu: một trang mục tiêu tháng của ROVA, viết theo đúng bốn tầng, để bảng `muc_tieu` đã có sẵn trong cơ sở dữ liệu bắt đầu có nội dung thật. Chưa có trang đó thì mọi tính năng của TL8 là kệ sách chờ sách.

---

## MỤC 10 — CHỖ MỎNG VÀ ĐIỀU KIỆN GÃY

> Mục này chép thẳng các lỗi mà vòng soi ngược đã tìm ra, không giấu. Mỗi lỗi ghi hai thứ: nó gãy ở đâu, và cách chặn trước. Đây là mục làm bản đề xuất đáng tin, và cũng là mục Tracy nên đọc kỹ nhất. So với bản khung, một lỗi đã được phân xử (C3) và được đánh dấu; các lỗi khác giữ nguyên hiện trạng.

### 10.1. Giải pháp không chạm nỗi đau

| Mã | Chỗ gãy | Vì sao gãy | Cách chặn trước |
|---|---|---|---|
| **A1** | TL2 nhận nỗi đau kiệt sức của cả bộ máy, nhưng kê thuốc là nhịp nghỉ, nghi thức tắt máy, đổi tư thế | 6 tiền điều kiện của Maslach đều là biến tổ chức. Ở ROVA, hai dự án nền móng nằm trọn trên một người đang giữ ba dự án. Dạy người đó nghỉ không lấy bớt dự án thứ ba ra khỏi vai họ | Thêm một chỉ số cấp đội có chủ là số cam kết đang mở trên mỗi người, hiện ở nhịp tuần. Kèm một luật: giảm tải là quyết định của người giao, không phải kỷ luật của người nhận |
| **A2** | Nỗi đau thói tập trung suy giảm từng bị chấm TRỐNG hoàn toàn, nay chỉ là giao thức phụ bên trong TL1 | Tín hiệu sớm từ vài ngày chạy thật — chưa đủ làm bằng chứng, đủ làm giả thuyết: nhiều phiên héo có vẻ vì người dùng nhảy thẳng từ đống task sang bấm deepwork, bỏ qua khúc quyết định chọn việc. Nền chắc hơn nằm ở nghiên cứu: thói tập trung là trạng thái do môi trường gây ra và đảo ngược được, nhưng không tự đảo | Nâng ba bước quét 120 giây thành cửa bắt buộc trước nút bắt đầu phiên, và theo dõi tỉ lệ phiên héo qua nhiều tuần để kiểm giả thuyết |
| **A3** | Bài toán Tích luỹ được dán nhãn cho TL2, TL3, TL7 nhưng đơn vị đếm không đổi | Đơn vị đếm hiện là tổng giờ cộng dồn, mà sàn phiên là 5 phút. 24 phiên 5 phút bằng một phiên 120 phút trên bảng, dù giá trị nhận thức khác hẳn | Thêm ngưỡng chất lượng vào chính bảng đếm: chỉ phiên đủ dài mới vào số cộng dồn công khai. ⏳ Ngưỡng chạy theo mặc định 45 phút chứ không phải 120 — mốc 120 của nguồn là chuẩn vận động viên, không phải chuẩn ngày vào nghề; số đo của đội mới có vài ngày, chưa đủ tin để định ngưỡng. Phiên ngắn vẫn ghi nhưng ở gương soi riêng |

### 10.2. Đúng cho một người, gãy khi áp cho mười hai người

| Mã | Chỗ gãy | Vì sao gãy | Cách chặn trước |
|---|---|---|---|
| **B1** | TL4 trao câu 80 phần trăm là đủ vào tay người không có quyền định nghĩa 80 phần trăm | Một bạn nộp bản chưa soát chính tả và dẫn triết lý 4. Người duy nhất biết việc đó thuộc nhóm nào là người đặt hàng. Ở tổ chức phẳng, mọi tranh chấp loại này rơi thẳng lên Tracy mỗi ngày | Chia đôi: quyền chọn việc nào thuộc người có quyền quyết; quyền chọn mức hoàn thiện phải khai ngay lúc giao bằng một ô hai lựa chọn. Bỏ trống ô đó thì mặc định là phải chuẩn |
| **B2** | Mười hai khối sáng bất khả xâm phạm sinh ra một hàng chờ buổi chiều | Chia đôi ngày là giải pháp cho một người. Khi cả 12 người giữ khối sáng, mọi điểm cần chữ ký dồn vào buổi chiều của đúng một người. Chú ý cá nhân tăng, độ trễ hệ thống tăng theo | Cấp ngưỡng tự quyết cho từng lead, dưới ngưỡng thì không cần hỏi. Đặt trần số điểm quyết mỗi buổi chiều; vượt trần thì đẩy sang nhịp tuần |

### 10.3. Triết lý đá nhau

| Mã | Cặp va nhau | Nội dung va | Cách hoà giải |
|---|---|---|---|
| **C1** | TL4 bỏ bớt ↔ TL5 uỷ thác ↔ TL3 chân Người | Nút thắt của ROVA là sự chú ý chứ không phải giờ công, nên uỷ thác chỉ dời tải. Và app chặn cứng ở ba luống, nên việc không vào được app sẽ quay về đường cũ là giao bằng miệng — đúng nỗi đau gốc | Một luật thứ tự, ghi thành bước trong app: trước khi giao phải thấy suất trống của người nhận. Không còn suất thì buộc chọn công khai — bỏ bớt việc cũ của họ, hoặc không giao. Không có cửa thứ ba |
| **C2** | TL7 công thức giữ lời ↔ TL4 khuyến khích dừng việc | Một cam kết bị dừng đúng theo tinh thần TL4 sẽ rơi vào mẫu số như một lần lỡ hẹn. Hoặc hệ thống phạt đúng hành vi nó đang dạy, hoặc mọi người học cách gọi mọi việc bỏ dở là bỏ rơi chiến lược | Thêm trạng thái Dừng có tuyên bố, cần xác nhận của người nhận cam kết, đếm ở một cột riêng. Số lần dừng cao là tín hiệu chọn việc sai từ đầu, không phải tín hiệu thất hứa |
| **C3** | TL5 tuyên bố không xếp hạng ↔ app đã chạy đúng cái nó cấm | Một lưới 12 hàng có độ sáng so được bằng mắt LÀ một bảng xếp hạng, dù không đánh số. Cộng thêm ý Tracy ngày 09/08 về điểm đổi quà và bảng xếp hạng. Nếu gửi cho đội, mâu thuẫn lộ ra ngay ngày đầu | ✅ **ĐÃ PHÂN XỬ 11/08** — Tracy chốt giữ lưới (*"Giữ chứ đang hay"*), giữ cả đường bấm xuống. Bản này đã đi trọn đường thứ hai: nguyên lý TL5 viết lại cho trung thực, bù bằng luật đọc công bố với đội — đọc để gỡ chặn, không để chấm người — nói thành lời một lần trước ngày mở app cho 12 người |
| **C4** | TL2 đặt trần ↔ TL3 nâng trần | Một bên chạy 80 phần trăm và đặt trần giờ, một bên nâng trần bằng một giai đoạn quá tải có chủ ý | Đóng khung theo thời hạn: quá tải là chế độ có hạn kỳ tối đa 14 ngày, sau đó bắt buộc hạ tải. Mặc định vẫn là 80 phần trăm |
| **C5** | TL6 giảm tải ↔ TL3 nhận thêm trách nhiệm | Một bên bảo giảm tải, một bên bảo tăng tải để năng lực nở ra | Hai loại tải khác nhau: tải NHẬN THỨC phải giảm, tải TRÁCH NHIỆM mới được tăng. Đừng gộp |

### 10.4. Tính năng có thể phản tác dụng

| Mã | Tính năng | Lách bằng cách nào | Cách chặn trước |
|---|---|---|---|
| **D1** | Bảng vinh danh giờ tập trung | Giờ là tự bấm, sàn 5 phút, và app còn định cho sửa bản ghi phiên. Mở đồng hồ rồi đi họp là đủ. Nặng hơn: bảng này bỏ sót trọn lớp việc giao tiếp, nên người chăm khách nói điện thoại 6 tiếng mỗi ngày sẽ đứng cuối bảng suốt tháng vì làm đúng việc của mình | Bỏ trục giờ khỏi mọi bảng công khai, giữ ở gương soi riêng. Công khai chỉ hiện dạng có hoặc không: hôm nay có phiên sâu. ⚠️ Lưu ý ranh giới với quyết định giữ lưới 11/08: quyết định ấy áp cho lưới NHỊP NGÀY ở tab Việc cố định; bảng vinh danh GIỜ là bảng khác, và đề nghị này vẫn đứng — Tracy gạch nếu muốn giữ cả hai |
| **D2** | Chuông tỉnh thức lọt vào công thức điểm ngày | Chuông chỉ có điểm cộng, nên muốn số chuông đẹp thì phải trôi nhiều lần. Hiện chuông chưa vào bảng vinh danh, nhưng việc dựng công thức chấm điểm hiệu quả ngày đang mở, cửa vẫn chưa khoá | Ghi thành luật cứng trong đặc tả: chuông vĩnh viễn không vào công thức điểm và không so giữa người với người |
| **D3** | Điểm ngày dựa trên năm việc cố định do chính người làm khai | Khai năm việc nhẹ thì ngày nào cũng sáng. Và ô chưa khai việc đang là trạng thái trung tính, nên không khai còn rẻ hơn khai rồi làm | Danh mục việc cố định do lead duyệt một lần mỗi tháng, người làm không tự thêm bớt. Ô chưa khai việc quá 3 ngày phải đổi thành ô có màu |
| **D4** | Màn Dọn việc hôm qua chặn cứng khi mở app | Hiện chạy ổn với 7 người coreteam vào từ 10/08, trong đó 2 người dùng lâu nhất là tự nguyện. Với 12 người bị yêu cầu dùng, thao tác tốn ít công nhất mỗi sáng là tick Chưa xong hàng loạt để vào được app. Sau hai tuần cột dữ liệu đầy chữ Chưa xong và không nói lên điều gì | Chặn cứng khi số việc quá hạn còn ít. Vượt ngưỡng, đề xuất 5, thì đổi sang một câu hỏi tổng về việc đang nhận quá tải và muốn trả lại việc nào, rồi đẩy kết quả lên nhịp tuần cho người giao. Biến tín hiệu quá tải thành đầu vào quản trị thay vì một thao tác dọn |

### 10.5. Thứ tự triển khai sai

| Mã | Chỗ gãy | Vì sao gãy | Cách chặn trước |
|---|---|---|---|
| **E1** | Dạy trạng thái trước khi có hướng: TL1 đứng đầu, TL8 đứng cuối | Vault chưa có mục tiêu quý của ROVA, và 12 quyết định của buổi duyệt dự án 31/07 chưa được ghi lại ở đâu. Cho 12 người vào phiên sâu trước khi có hướng chung là làm tăng vế tốc độ trong khi vế hướng bằng không | Đảo thứ tự triển khai, giữ nguyên thứ tự trình bày: TL8 với một trang mục tiêu tháng hợp chu kỳ ROVA, rồi TL4, rồi TL1 cùng TL6, rồi TL7, rồi TL2, cuối cùng TL3 cùng TL5 |
| **E2** | Mở nhìn thấy nhau trước khi có nhịp gặp nhau | Chế độ Cả ROVA đã chạy 10/08, trong khi nhịp ngày và ô tuần vẫn chưa dựng và ROVA chưa chốt nhịp này. Không có chỗ nói chuyện thì cái duy nhất đội nhận được là hình ảnh về nhau, không kèm cách gỡ cho nhau — đó là định nghĩa của camera | Giữ chế độ Cả ROVA ở phạm vi hẹp cho tới khi có nhịp tuần thật đang chạy, và mở kèm một tuyên bố luật đọc. Sau quyết định giữ lưới 11/08, điều kiện này càng quan trọng: lưới đã chốt giữ, nên nhịp ngày và luật đọc phải xong TRƯỚC ngày mở app đợt 2 |

### 10.6. Chỗ mỏng nhất — không triết lý nào ràng buộc người giao việc

Tám triết lý đều ràng buộc người NHẬN việc. Không triết lý nào ràng buộc người GIAO việc. Trong khi đó cả 12 nỗi đau đều sinh ở khâu cấp phát: 13 việc cùng được gọi là dự án mà chưa phân loại, việc giao bằng miệng, không ai nhìn thấy tổng tải, và 6 tiêu điểm mở cùng lúc trong đó một tiêu điểm có hơn chục điểm nghẽn chờ Tracy phân xử.

Nếu 12 người chạy đủ tám triết lý mà đầu vào không đổi, app chỉ làm cho tình trạng quá tải trở nên đo được và nhìn thấy được, không làm nó nhỏ đi. Và khi đó chính bản đề xuất này trở thành bằng chứng cho đội thấy họ đang bị đo trong khi nguồn gây tải không bị chạm tới.

**Cách chặn trước:** ⏳ chạy theo mặc định — **có** thêm một lớp luật ở phía cấp phát, ràng buộc chính Tracy. Mỗi việc giao ra phải khai ba thứ trước khi vào app: loại việc gồm thời cơ, nền móng, gỡ chặn · mục tiêu cha · suất trống của người nhận. Người bị chặn là người giao. Lớp luật này vào lộ trình tính năng ngay đợt sau, vì không có nó thì tám triết lý chỉ làm quá tải trở nên đo được chứ không nhỏ đi.

**Phép thử một câu:** nếu Tracy nghỉ 2 tuần, số việc mới sinh ra có giảm không? Nếu có, nút thắt nằm ở người giao và không triết lý nào trong tám cái hiện chạm tới nó.

---

## MỤC 11 — BẢNG TỔNG

| # | Tên triết lý | Xuất xứ | Framework | Bài toán chính | Tính năng đã chạy |
|---|---|---|---|---|---|
| 1 | Chủ quyền Ý thức | 🟣 ghép | Wake Up and Flow | Trạng thái | 3 trên 6 |
| 2 | Vận động viên Điều hành | 🟣 ghép | ⚠️ Sống như sư tử, tên do bản luận đặt | Tích luỹ | 3 trên 7 |
| 3 | Đòn bẩy vô hạn | 🟣 ghép | Bộ ba đòn bẩy | Tích luỹ, qua Hệ thống | 0 trên 5, có 2 đã duyệt |
| 4 | Sự bỏ rơi chiến lược | 🟣 ghép | Bộ lọc hướng mục tiêu | Hệ thống | 3 trên 7 |
| 5 | Chỉ huy dàn nhạc | 🟣 ghép | ⚠️ Kiến trúc dòng chảy đội, ruột từ van den Hout | Hệ thống và Trạng thái ở tầng đội | 3 trên 6 |
| 6 | Tối giản hoá Nhận thức | 🟣 ghép | Cú đổ tải nhận thức | Trạng thái | 3 trên 6 |
| 7 | Giữ lời và Cuộc chơi | 🟢 vault | Cuộc chơi Giữ Lời | Tích luỹ | 4 trên 9 |
| 8 | Chồng mục tiêu chung | 🟢 vault | Bốn tầng một hướng | Hệ thống | 3 trên 6 |
| | **Tổng** | | | | **22 trên 52** |

*Ghi chú cách đếm: chỉ đếm các dòng ✅ 🔶 ⬜, không đếm dòng ⚰️. Khối Tổng quan 8 ô đếm một lần ở TL2, không đếm lại ở TL3. Nguyên lý thứ tự mắt nhìn đã được chuyển về bộ luật thiết kế nên không tính là tính năng.*

**Ba dòng chốt.**

**Một.** App Khu Vườn hôm nay đã hiện thực hoá khoảng 42 phần trăm bản giải pháp, tức 22 trên 52 tính năng, cộng thêm 3 tính năng đã duyệt đang chờ dựng và một ô Giờ vàng chờ một file SQL. Phần đã chạy tập trung dày nhất ở Triết lý 7 giữ lời và Triết lý 1 chủ quyền ý thức — nghĩa là app đang mạnh ở chỗ bắt người ta không im lặng và bảo vệ được một phiên sâu. Đó không phải ngẫu nhiên: hai triết lý ấy là hai cái có cơ chế rõ nhất, và app này lớn lên bằng cơ chế.

**Hai.** Phần trống nhiều nhất là Triết lý 3 đòn bẩy vô hạn, hiện không có tính năng nào đang chạy. Sau nó là Triết lý 2 vận động viên điều hành với 3 trên 7, mà phần lõi tích luỹ — ngưỡng hiệp sạch, nhật ký hành vi — đều còn trống. Ở tầng bài toán, chỗ trống nặng nhất là Bài toán Tích luỹ, vì đơn vị đếm hiện tại là tổng giờ cộng dồn mà không có ngưỡng chất lượng. Và ở tầng bao trùm, chỗ trống lớn nhất không nằm trong tám triết lý nào cả: không có triết lý nào ràng buộc người giao việc.

**Ba.** Bước sau là hai lộ trình, chỉ nêu tên ở đây theo yêu cầu của Tracy, nội dung viết sau khi Tracy gạch xong bản này: **Lộ trình tính năng** — xếp 31 tính năng còn lại theo thứ tự triển khai đã sửa ở Mục 10.5, làm hết những gì làm được theo thứ tự việc nào gỡ chặn nhiều nhất làm trước, không chia bản V1 hay V2 · **Lộ trình đào tạo cho đội** — các module dạy tám triết lý cho 12 người ROVA, rút gọn mạnh theo đặc thù đội có năng lực và dùng AI tốt, không dựng giàn giáo cho người mới.

---

## PHỤ LỤC — TRẠNG THÁI NĂM CÂU CHỜ TRACY CHỐT

> Bản khung đặt năm câu, mỗi câu kèm phương án mặc định. Tới bản đầy đủ này: **một câu đã được Tracy chốt**, bốn câu còn lại **chạy theo mặc định** và đã được viết thẳng vào thân bài với dấu ⏳. Không câu nào còn chặn việc viết; bốn câu ⏳ vẫn gạch được — gạch câu nào tôi sửa thân bài theo câu đó.

| # | Câu hỏi | Trạng thái | Đang chạy theo |
|---|---|---|---|
| 1 | **Bỏ chuỗi ngày, hay giữ?** Bằng chứng chống chuỗi rất mạnh: chỉ 0,90 phần trăm người đứt chuỗi quay lại mở chuỗi mới; cơ chế thật là dốc mục tiêu chứ không phải chuỗi. Nhưng Tracy đã chốt luật chuỗi ngày hai bản ngày 09/08, app đang có ô chuỗi đang giữ, và ⚠️ ngày 11/08 Tracy chốt thêm cơ chế *mất chuỗi thì trả giá để khôi phục* (100 squat, 3 km chạy, hoặc 50 chống đẩy) cho bình tưới vòng 2 — đúng văn hoá ROVA đang chạy thật | ⏳ Mặc định | Giữ chuỗi ở gương soi riêng của mỗi người, bỏ chuỗi khỏi mọi chỗ công khai và khỏi mọi công thức chấm điểm (TL7, tầng 8.7). ⚠️ Cơ chế trả giá 11/08 làm yếu một phần lập luận chống chuỗi — nó chính là đường quay lại sau cú đứt mà con số 0,90% đo sự thiếu vắng. Khi gạch câu này, phân xử cả cặp chuỗi và trả giá trong một lần |
| 2 | **Lưới 12 người có phải bảng xếp hạng không, và có giữ không?** | ✅ **Tracy chốt 11/08:** *"Giữ chứ đang hay"* | Giữ lưới nguyên trạng, giữ cả đường bấm xuống chi tiết cá nhân. Nguyên lý TL5 đã viết lại cho trung thực (tầng 6.4); phần bù bắt buộc là luật đọc công bố với đội một lần trước ngày mở app đợt 2, và nhịp ngày phải dựng trước khi mở rộng chế độ nhìn thấy nhau (Mục 10, E2) |
| 3 | **Điểm có đổi ra tiền hoặc quà thật không?** Tracy đề nghị ngày 09/08, đang căng với nguyên lý thưởng nhỏ đã nạp | ⏳ Mặc định | Không có bảng tỉ giá điểm đổi tiền. Tiền chỉ dùng để đặt cược, quà nhỏ dùng để công nhận, giữ mô hình đã chạy thật 154 ngày ở Game Kim Cương (TL7, tầng 8.4) |
| 4 | **Ngưỡng một hiệp sạch là bao nhiêu phút?** Nguồn nói 120 phút — chuẩn vận động viên, không phải chuẩn ngày vào nghề; số đo của đội mới có vài ngày, chưa đủ tin để định ngưỡng | ⏳ Mặc định | Đặt tạm 45 phút, chạy vài tuần rồi tính lại theo phân vị thật của đội (TL2, tầng 3.5 và Mục 10, A3) |
| 5 | **Có thêm lớp luật ràng buộc người giao việc không?** Đây là chỗ mỏng nhất của cả bản giải pháp, và người bị chặn sẽ là chính Tracy | ⏳ Mặc định | Có. Mỗi việc giao ra khai ba thứ: loại việc · mục tiêu cha · suất trống của người nhận. Vào lộ trình tính năng ngay đợt sau (Mục 10.6) |

---

*Bản đầy đủ, kết thúc. Tracy gạch trực tiếp trên bản này — gạch tới đâu tôi sửa tới đó, rồi mới sang hai bản lộ trình.*
