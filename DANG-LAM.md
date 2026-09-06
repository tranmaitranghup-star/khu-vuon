# ĐANG LÀM — bảng chia làn khi nhiều phiên cùng sửa app

> 📍 Chưa đọc `DOC-TRUOC.md` thì đọc nó trước — nó chỉ ra loại việc nào cần mở đúng file nào.

> Tracy chốt 13/08: *"tự phân chia nhau làm đi, phiên nào trước cũng được"*.
> File này là **kênh liên lạc duy nhất giữa các phiên** — không phiên nào nói
> chuyện được với phiên nào, nên ai vào cũng đọc đây trước, và ghi làn của mình
> vào đây trước khi sửa.

## Vì sao có file này

Chiều 13/08 có hai phiên chạy song song trên cùng `public/index.html`. Không ai
biết ai, hậu quả thấy ngay: một phiên chạy `git add public/anh` nên **gánh luôn
12 file ảnh của phiên kia** vào commit của mình (`2a0f54a`), rồi commit sau
(`86d4081`) gánh tiếp phần ô Giờ. Không mất dữ liệu — chỉ vì cả hai dùng chung
một cây làm việc, không phải hai nhánh — nhưng lịch sử lẫn lộn và người đọc
`git log` sau này không biết ai làm gì.

## ⚠️ GHI VÀO SỔ XONG THÌ COMMIT NGAY — sổ nằm trên đĩa làm KẸT CẢ NHÀ (05/09)

Ngày 05/09 cây chính chậm **43 commit** và **không pull được**, vì đúng hai file
này (`DANG-LAM.md` và `luu-tru/CHI-MUC-LAN.md`) bị sửa dở nằm trên đĩa: sáu phiên
cùng ghi sổ rồi để đó, không ai commit. Gộp lại phải gỡ tay **bốn** chỗ đụng độ.

**Vì sao nó tệ hơn vẻ ngoài:** một file sửa dở chặn `git pull` của MỌI phiên dùng
cây chính, chứ không riêng phiên viết nó. Và thứ chỉ nằm trên đĩa thì một cú
`checkout` hay `stash` lỡ tay là mất sạch, **không một dòng nào báo** — sổ vẫn
đọc được, chỉ thiếu vài làn.

**Luật:** ghi một dòng chỉ mục hay một mục bẫy xong thì `git add` đúng file ấy và
commit **ngay trong lượt đó**. Đừng để dành tới cuối phiên. Cây chính đang bẩn thì
đừng đè lên: commit phần của mình trước, rồi mới pull.

🪤 **Bảng chỉ mục đang có HAI LỐI ghi cùng lúc** — vài phiên chèn dòng mới lên
ĐẦU bảng, vài phiên nối xuống CUỐI. Nên một cú gộp sinh **hai** chỗ đụng độ thay
vì một. Chưa xếp lại (hơn 100 dòng, việc riêng); tới lúc gỡ thì nhớ là **cả hai
bên đều chỉ THÊM**, không bên nào xoá — nên luôn giữ cả hai, đừng chọn bỏ một
bên. Ngoại lệ duy nhất gặp hôm ấy: một phiên sửa lại **mã commit** của dòng đã
có, lúc ấy mới lấy bản mới đè bản cũ.

## Ba luật

1. **Chỉ đưa vào commit ĐÚNG file của mình.** `git add <từng-file>`. Cấm
   `git add -A`, cấm `git add <thư-mục>`.
2. **Trước khi sửa `public/index.html`, chạy `git diff public/index.html`.**
   Thấy thay đổi mình không viết → phiên khác đang làm dở. Cứ sửa phần của
   mình, nhưng **đừng dọn dẹp, đừng xếp lại, đừng đổi tên** những khối không
   thuộc làn mình.
3. **Ghi làn của mình vào bảng dưới khi bắt đầu, xoá đi khi xong.** Ghi cả tên
   khối/hàm mình chạm, đủ để phiên kia biết đường tránh.

> ⚠️ **Luật 1 vừa bị vi phạm hai chiều, 29/08 — chép lại vì nó sẽ tái diễn.** Hai phiên chạy song
> song (BG ở ô chọn giờ, DA ở dải cả ngày). Phiên BG chạy `git add public/index.html` nên commit
> `c87227f` mang tên *"Ô giờ máy tính"* **gánh luôn toàn bộ làn DA** — mã lên `main` dưới một cái tên
> không nói gì về nó. Cùng lúc, phiên BG ghi đè `DANG-LAM.md` bằng bản trong bộ nhớ của mình nên
> **xoá mất mục làn DA** vừa ghi vào đĩa mấy phút trước. Bài học: `git add <file>` KHÔNG đủ khi hai
> phiên cùng sửa MỘT file — trước khi commit phải `git diff --stat` và nếu thấy vùng lạ thì dừng
> lại; và trước khi ghi `DANG-LAM.md` phải đọc lại bản trên đĩa, đừng ghi đè bằng bản đang nhớ.

> 🔴 **LẦN THỨ BA, 31/08 — và lần này luật 2 cũng không cứu.** Làn HT (nút Hôm nay + hoàn tác) viết
> xong, thử tại máy đạt, ghi rõ "CHƯA COMMIT" và đang chờ Tracy gọi đẩy. Trong lúc chờ, làn Lịch cố
> định chạy `git add public/index.html` — commit `180f5a9` *"Lịch cố định: đổi tên, bỏ biểu tượng, nút
> khớp ô chọn nấc"* **gánh trọn làn HT** rồi đẩy thẳng lên `main`. Hai tính năng ra người dùng dưới một
> cái tên không nhắc tới chúng, trước khi Tracy kịp nói đẩy. Mục làn HT trong file này cũng bị commit
> theo, nên nó nằm trên `main` với dòng chữ "CHƯA COMMIT" — sai ngay lúc được ghi.
> **Không mất gì, mã còn nguyên** — nhưng ba lần liên tiếp cùng một nguyên nhân thì nó không còn là tai
> nạn. `git add <từng-file>` chỉ tách được khi hai làn ở HAI file khác nhau; `public/index.html` là MỘT
> file mà mọi làn đều đụng, nên với nó luật 1 vô nghĩa và luật 2 (soát `git diff` trước khi sửa) cũng
> vô nghĩa — nó soát lúc BẮT ĐẦU, còn tai nạn xảy ra lúc COMMIT.
> **Đường ra thật, chọn một:** ⓐ làn nào chạm `index.html` thì tách nhánh git riêng, gộp lúc xong; hoặc
> ⓑ trước mỗi `git commit`, chạy `git diff --cached --stat` **và** đọc lại mục 🟢 — thấy tên một làn
> khác đang mở trên cùng file thì DỪNG, commit phần mình bằng `git add -p`, đừng gánh cả file.

> 🔴 **LẦN THỨ TƯ, cũng 31/08 — và lần này là làn SK gánh làn CV.** Làn CV (chạm cả khối mở cửa Thông
> tin việc) viết xong, đo đạt, ghi rõ "CHƯA COMMIT" và đang chờ Tracy gọi đẩy. Làn SK commit `9efe9c6`
> *"Sự kiện: ba hướng trả lời, mời đích danh, bảng điểm danh"* rồi push — **mang trọn làn CV lên sóng**
> dưới một cái tên không nhắc gì tới nó, kể cả mục làn CV trong file này với dòng chữ "CHƯA COMMIT".
> Bốn lần, bốn làn khác nhau, một nguyên nhân: **`git add public/index.html` không tách được hai làn
> cùng ở trong nó.** Ai còn định chữa bằng cách "nhớ kỹ hơn" thì đây là bằng chứng thứ tư rằng trí nhớ
> không phải hàng rào. Hàng rào thật là ⓐ tách nhánh, hoặc ⓑ `git add -p`.
> Lần này không hại: mã CV đã đo đạt trước đó nên thứ lên sóng là bản chạy được, không phải bản viết dở.

> 🔁 **Ca đụng độ 29/08 — luật 1 KHÔNG cứu được khi hai làn cùng một file.** Làn BG và làn TW chạy
> song song trên `public/index.html`. BG commit `c87227f` và **gánh luôn mã của TW** vào commit mang tên
> mình, rồi đẩy thẳng lên sóng — một tính năng ra người dùng trước khi Tracy kịp nhìn nó. BG cũng ghi đè
> mục 🟢 thành *"Trống"*, xoá mất mục làn của TW đang mở. Không mất dữ liệu, nhưng cả hai chuyện đều là
> cùng một nguyên nhân: `git add <từng-file>` chỉ tách được khi hai làn ở HAI file khác nhau; cùng một
> file thì nó vô nghĩa. Hai làn cùng đụng `index.html` thì phải hẹn nhau — một làn commit trước, làn kia
> chờ — hoặc tách nhánh git thật.

## ⚠️ NHẮC TỚI TRACY TRONG TIN NHẮN GIỮA CÁC PHIÊN (01/09)

**Tracy đọc được tin nhắn giữa hai phiên.** Ngày 01/09 một phiên viết *"bà ấy đang sốt ruột vì đã
nói hai lần mà thứ ấy vẫn còn"*, và Tracy hỏi thẳng: *"sao lại gọi tôi là bà ấy để giao tiếp với
nhau???"*. Hai lỗi trong một câu, và cả hai sẽ lặp lại với mọi phiên sau nếu không ghi ra.

**① Gọi thẳng tên: "Tracy".** Không "bà ấy", không "cô ấy", không "chị ấy", không "anh ấy". Tracy
chưa bao giờ nói mình muốn được gọi bằng đại từ nào, và một cái tên không cho ai quyền suy ra điều
đó. Cần một đại từ thì dùng "người dùng". Khi nói VỚI Tracy thì vẫn là **"bạn"** như thường lệ
(xem [[xung-ho-toi-ban]]).

**② Đừng kể tâm trạng của Tracy cho phiên khác.** Cái này nặng hơn cái trên. *"Đã yêu cầu hai lần,
thứ ấy vẫn còn"* là dữ kiện — kể đi, nó cần cho việc. *"Đang sốt ruột"* là mình tự suy ra rồi kể
lại sau lưng, không phải việc của mình, và Tracy đọc thấy nguyên văn.

**Cách viết đúng:** *"Tracy đã yêu cầu hai lần, thứ ấy vẫn còn — tôi làm luôn."* Đủ mọi thứ phiên
kia cần biết, không thừa một chữ nào về người.

## ⚠️ ĐO BỘ THỬ THÌ ĐO TRÊN `origin/main`, KHÔNG ĐO TRÊN ĐĨA (01/09)

Nếp "9 đỏ trước, 9 đỏ sau — cùng một bộ bài" chỉ đúng khi **cả hai phía đều mới**. Ngày 01/09 tôi
báo nhầm rằng `thu-so-ghi-chu.js` đỏ sẵn trên `main`: cây làn của tôi mang bản bài thử **cũ hơn
một commit**, và tôi so nó với một bản `main` cũng cũ. Hai bản cũ giống nhau thì không chứng minh
được gì cả. Đo lại trên `origin/main` thật: **77/77 xanh**.

Phiên giữ làn ấy vấp cùng một chuyện theo chiều ngược: chạy bộ thử ở **cây chính** trước khi đẩy,
thấy xanh, nhưng cây chính chưa kéo commit về nên đang chấm bản cũ.

**Hai luật rút ra:**
1. `git fetch` rồi so với `git show origin/main:<file>`, đừng so với bản trên đĩa. Mấy hôm nay có
   nhiều làn đẩy liên tục — cây chính cũ đi trong vòng vài phút.
2. Chạy bài thử **trong làn của mình**, không chạy ở cây chính.

Cách đo sạch, một lệnh: rút cả bài thử lẫn `public/index.html` từ đúng `origin/main` ra một thư mục
tạm rồi chạy ở đó — không dính bản trên đĩa của bất kỳ bên nào.

## ⚠️ QUÉT BỘ THỬ BẰNG `grep ❌` BỎ SÓT MỘT BÀI ĐANG ĐỎ (05/09)

`thu-tuan-o-ngay.js` in bằng **`✓` và `✗`**, không phải `✅`/`❌` như 49 bài kia. Nên nếp quét quen
thuộc — chạy cả bộ rồi `grep "❌"` — báo **0 ca đỏ** trong khi bài ấy đang hỏng **5 ca**. Nó hỏng y
hệt trên `origin/main`, tức đã đỏ từ trước và không phiên nào thấy.

**Quét bằng MÃ THOÁT, đừng quét bằng ký hiệu:**

```bash
for f in thu-*.js; do node "$f" >/dev/null 2>&1 || echo "🔴 $f"; done
```

Cùng họ với luật *bài thử chết nguy hơn ca đỏ*: cả hai đều là bộ đo im lặng nói dối, và cả hai chỉ
lộ ra khi đối chiếu với `origin/main` chứ không khi nhìn một mình.

✅ **Năm ca ấy đã chữa xong 05/09 (làn CV, TRI-132)** — và hoá ra mã app không sai một dòng nào, hỏng
là ở cơ chế cắt vùng của chính bài thử. Xem mục bẫy ngay dưới.

## ⚠️ Ba bẫy đã biết trên file này — đọc trước khi sửa

Không phải luật chia làn, mà là **ba chỗ mã đã cắn người thật**. Cả ba đều thuộc loại thử tay từng
bước KHÔNG lộ ra, nên chép lại đây thay vì để mỗi phiên tự vấp một lần.

**① `taiVuon` đọc lại biến toàn cục SAU `await`.** Hai lượt chạy chồng nhau thì lượt VỀ sau ghi đè lượt
về trước, bất kể lượt nào được GỌI trước. Ca thật: bấm một dòng "chờ ký nhận" ở màn Hôm nay từng bắn hai
lượt `taiVuon` với hai giá trị `vuonCaDoi` khác nhau, lượt cũ về sau ghi `DONG_DOI = []` và xoá trắng
đúng cái khối vừa mở, kèm câu báo sai *"không thấy cam kết đó"*. Chữa bằng cách đặt cờ TRƯỚC khi mở màn
rồi chỉ một lượt tải. Khuôn đúng có sẵn ở `taiRova`: chốt `const caDoi = vuonCaDoi` ở đầu hàm, và sau
mỗi `await` thì `if (caDoi !== vuonCaDoi) return`. (Phát hiện bởi phiên cd + 7a, 27/08.)

**② Trong `moTab`, nhánh tải phải đọc `ten`, KHÔNG đọc `tabSang`.** `tabSang` là biến chỉ để giữ viên
thuốc sáng khi mở hồ sơ dự án (`'duanho'` → sáng ở tab `'duan'`). Đổi `if (ten==='duan')` thành
`if (tabSang==='duan')` — trông hợp lý, khác một chữ — thì mở hồ sơ dự án sẽ bắn thêm một lượt
`taiDuAn()` chồng lên bốn truy vấn `moHoSoDuAn` vừa chạy, tức đúng hình dạng bẫy ①. (7a chỉ ra, 27/08.)

**④ Chỗ dùng ô tick chỉ được thêm VỊ TRÍ, không được đụng `display`.** Luật gốc
`input[type=checkbox]` dựng hình dấu ✓ bằng khung flex (`inline-flex` + `align-items` + `justify-content`);
✓ là `::after` của chính ô. Khai đè `display:block` ở chỗ dùng là gỡ mất khung ấy — hai luật căn hết tác
dụng, `::after` tụt về `inline` nên bề rộng và bề cao khai ra không được đọc, nét ✓ trải dài ở mép và
đọc ra thành MỘT VẠCH DỌC. Ca thật: `.tlg-viec > input` giữ `display:block` từ lúc dựng, Tracy bắt được
30/08 trên điện thoại — *"chỉ bị ở view ngày thôi, view tuần không bị"*, vì nấc Tuần trên điện thoại vẽ
bằng `.tlw-viec` (chỉ khai `flex:none;margin:0`, giữ nguyên khung gốc) còn máy tính LÚC ẤY đang tắt ô
tick — nó bật lại cùng ngày, sau khi vá xong (làn OT).

**③ Thẻ gấp mới phải khai khoá vào `THE_THU`.** `gapThe` LẬT giá trị, nên khoá chưa khai thì cú bấm ĐẦU
lật `undefined` thành `true` — thu một khối vốn đã thu, và cửa chỉ mở ở cú bấm thứ hai. Ép mở một thẻ
thì đặt thẳng cờ, đừng gọi `gapThe` (án lệ `cbMoTheDaXong`).

> 🪤 **Ba bẫy làn HT gặp (31/08), chép lại vì sẽ tái diễn.**
> **① Một lớp thua `.lich-dau button`.** Luật cũ ấy là *một lớp cộng một tên thẻ*, nên `.lich-homnay`
> trần bị nó đè cỡ chữ 1.15rem (cỡ của hai mũi tên ‹ ›) bất kể đứng sau. Phải viết hai lớp
> `.lich-dau .lich-homnay`. **Bất kỳ nút mới nào thêm vào dải đầu đều dính.**
> **② `.toast-chong` khai `pointer-events:none`** — nút đầu tiên đặt trong một thông báo sẽ KHÔNG bấm
> được, và không có lỗi nào báo. Bật lại `pointer-events:auto` cho RIÊNG cái nút, đừng bật ở thẻ
> `.toast`: bật ở đó là cả chồng thông báo thành tấm chắn che app bên dưới.
> **③ Chụp và nhận phải TÁCH ĐÔI quanh câu `update`.** Gộp làm một thì một câu ghi hỏng vẫn để lại
> một cú trong ngăn, và Ctrl+Z sau đó ghi đè lên trạng thái đang đúng — hoàn tác một việc chưa từng
> xảy ra. Nên `htChup` chỉ trả bản chụp, `htNhan` mới đẩy vào ngăn, gọi sau khi máy chủ đã nhận.

---

> 📍 **Ba mục ⚠️ dưới đây nói về MÃ ĐANG CHẠY, không phải về một làn đã đóng** — nên chúng ở lại
> đây chứ không xuống `luu-tru/CHI-MUC-LAN.md` cùng các làn sinh ra chúng (AD · AF · AH). Ranh giới:
> dòng chỉ mục trả lời *"làn ấy đã chạm gì"*, còn ba mục này trả lời *"chỗ này sẽ cắn tôi thế nào
> nếu tôi sửa vào đấy"*. Ba dòng chỉ mục của AD · AF · AH KHÔNG chứa nội dung này, đã kiểm.
> *(Chép lại 01/09 sau khi đợt nén quét nhầm chúng xuống tệp toàn văn — xem mục Ba bẫy ở trên.)*

## ⚠️ Ba chỗ dễ vấp ở hàng "chưa xếp giờ" (làn AD, 01/09)

1. **`tlkCam` phải tra HAI nguồn.** `TL_KHO_DS` chỉ chứa việc `ngay IS NULL`. Việc trên hàng cả ngày
   nằm ở `TLG_VIEC` — bản chụp của dải vừa vẽ. Tra một nguồn thì chạm vào thanh không xảy ra chuyện
   gì, đúng cái lỗi câm mà `tlgVeLaiKho` từng phải chữa hồi 29/08. `tlgThaVao` cũng cần cả hai, nếu
   không `thoi_luong_du_kien` rơi mất và mọi khối thả xuống đều dài đúng một tiếng.
2. **Một dòng cao bao nhiêu là TUỲ MÀN.** Dưới 720px ở nấc Tuần thanh bỏ chữ, còn 7px; tính cứng 25px
   thì hàng cắt mất việc trong khi còn thừa chỗ. Đo được lúc soi bản thật: cột 39px, thanh 7px.
   Nấc Ngày đứng ngoài luật ấy — một cột rộng cả màn thì thanh vẫn mang chữ.
3. **Khay dùng `position:fixed`, KHÔNG `absolute`.** Muốn `absolute` thì `.tlg` phải mang `overflow`,
   mà `overflow` trên nó biến lưới thành một khối cuộn riêng và hàng tên thứ `position:sticky` sẽ
   dính vào lưới thay vì dính vào trang. Khay chừa lại 88px đáy cho thanh tab.

**Bài thử:** `node production/tinh-thuc-app/thu-hang-chua-xep-gio.js` — 32 ca, cắt thẳng khối gốc từ
`index.html`. Nếu sửa `tlgDaiChuaGio` hay `tlkCam` thì chạy lại trước khi đẩy.


## ⚠️ Bốn chỗ dễ vấp ở cú kéo vào lưới (làn AF, 01/09)

1. **Dò vùng thả phải dùng khung THẬT** (`getBoundingClientRect`), không
   `elementFromPoint`: khối đang bay nằm ngay dưới ngón nên `elementFromPoint`
   luôn trả về chính nó, và mọi phép dò dựa vào đó đều trả lời sai.
2. **`TLG_CUON` đã có người dùng** — biến ấy giữ chỗ cuộn của dải cũ từ trước.
   Bộ cuộn-theo-mép mới phải mang tên khác (`TLG_CUON_MEP`); khai trùng thì cả
   khối `<script>` ngã ngay ở lượt phân tích, không phải lúc chạy.
3. **Cảm ứng: ngón đi TRƯỚC khi giữ đủ `TLG_GIU` là cú vuốt để cuộn** — phải
   buông hẳn, đừng níu. Cùng luật `tlgKeoChay` đã dựng cho khối trên lưới.
4. **Khay phủ kín lưới**, nên kéo từ khay thì việc đầu tiên trong `tlgThVao` là
   đóng khay. Không thì ngón đang mang một việc đi tìm chỗ thả mà chỗ ấy bị che.

**Bài thử:** `node production/tinh-thuc-app/thu-keo-vao-luoi.js` — 30 ca.

5. **Kéo về kho khi việc đã có deep work KHÔNG phải chuyện nguy hiểm.** Bản đầu
   của `tlgVeKho` hỏi lại bằng `confirm`; Tracy bác ngay trong ngày — đó là một
   NHỊP LÀM VIỆC THƯỜNG NGÀY (làm dở, hết giờ, hẹn lúc khác), không phải một cú
   bấm cần xin phép. Nay hàm ấy GHI NHẬN thay vì hỏi: nâng `Chua_lam`/`Doing`
   lên `Chua_xong`, giữ nguyên phiên, và nói ra số phút đã bỏ vào. `Done` và
   `Blocked` đứng ngoài — đừng tự ý mở lại việc đã xong, cũng đừng đè nhãn
   làm-dở lên một việc đang tắc.


## ⚠️ Hai chỗ dễ vấp ở cột `co_cam_ket` (làn AH, 01/09)

1. **CỬA LÙI phải bọc MỌI cột có thể máy chủ chưa có.** `dwMoPhienMoi` vốn chỉ
   tách `may_ma`/`nhip_cuoi` ra khỏi gói lùi; `co_cam_ket` lúc đầu đi lẫn trong
   `goi` nên nó có mặt cả trong gói lùi — cú lùi khi ấy ngã đúng lỗi vừa lùi
   khỏi, và mở phiên hỏng hẳn trên máy chủ chưa chạy `nang-cap-loai-phien.sql`.
2. **Ghi `false` KHÁC bỏ trống.** Việc không có cam kết phải ghi thẳng `false`;
   để trống là một câu khác — *"chưa biết"* — và trigger bên máy chủ sẽ đi điền
   lại, tốn một lượt ghi cho một thứ app đã biết chắc.

**Bài thử:** `node production/tinh-thuc-app/thu-loai-phien.js` — 16 ca (phần app).
Phần máy chủ có bộ tự kiểm 11 mục nằm trong chính tệp SQL.

## ⚠️ Khung nhìn `gio_deepwork_theo_loai` nay có BA cột nguồn nhãn (làn SK10, 01/09)

Ba tệp lần lượt `create or replace` chính khung nhìn ấy, mỗi tệp thêm một nguồn:

| Nguồn nhãn | Nghĩa | Tệp dựng ra |
|---|---|---|
| `p.nhip_id` | phiên gắn vào một nhịp cố định | `nang-cap-gio-deepwork-theo-loai.sql` |
| `p.co_cam_ket` | việc gắn với phiên có mã cam kết | `nang-cap-loai-phien.sql` |
| `p.viec_co_dinh` | việc ấy được khai là việc cố định | `nang-cap-loai-viec-co-dinh.sql` |

**Chép định nghĩa từ tệp MỚI NHẤT, đừng chép từ tệp cũ.** Mất một nhánh thì
không lỗi nào bật lên — dải đo vẫn chạy, chỉ là giờ họp định kỳ lặng lẽ rơi về
nhóm "phát sinh" như trước, và con số đáng để mắt nhất của cả khối thành con số
kém tin cậy nhất. Đây đúng là họ lỗi mà mục `co_cam_ket` ngay trên đã cảnh báo,
chỉ khác chỗ hỏng: lần ấy hỏng vì join, lần này hỏng vì chép lại bản cũ.

`SO-SQL.sql` khối ② nay có một phép hỏi bắt được đúng chuyện này — nó đọc thân
khung nhìn và nói thẳng đang thiếu nhánh nào. Dán vào Supabase là thấy.

**🪤 Bẫy đã cắn ngay lượt chạy đầu (02/09):** trong Postgres, `x = 'co_dinh'` cho
ra **NULL chứ không phải false** khi `x` là NULL — mà `task.loai_viec` NULL chính
là đại đa số dòng. Câu lấp vì thế ghi NULL đè lên NULL và mục 9 bộ tự kiểm đỏ.
Chữa bằng `is not distinct from`. Tệp hôm trước không dính vì nó viết
`(tieu_diem_ma is not null)` — một phép hỏi NULL, vốn đã luôn trả true/false;
chép sang một phép so sánh BẰNG là đổi mất tính chất ấy mà nhìn thì y hệt.
**Mọi cột boolean chép từ một cột có thể NULL đều đi qua bẫy này.**

**Luật đi kèm cho cột `task.loai_viec` — KHÔNG GIỮ NGẦM.** Cam kết và loại việc
là hai trục khác nhau, mà ô chọn chỉ hiện được một dòng. Nên chọn một cam kết là
THÔI cố định: mọi cửa ghi đi qua `manhLoai()` và nó ghi `loai_viec = null`. Đừng
"tối ưu" bằng cách giữ lại nhãn cũ — giữ là đẻ ra một giá trị người dùng không
nhìn thấy và không sửa được, thứ luôn thành một con số sai không ai giải thích
nổi. Bộ tự kiểm mục 10 trong tệp SQL canh đúng bất biến này ở tầng dữ liệu.

## ⚠️ HAI CỬA SỰ KIỆN DÙNG CHUNG TÊN Ô — chỉ MỘT được sống trong cây (làn TND, 03/09)

App có hai lối vào cùng một việc *khai một sự kiện*: nút `+ Sự kiện` mở `lcMoForm`, và cú chạm
timeline rồi chọn *Sự kiện* mở `vcVeSuKien`. Hai khung ấy **cố ý mang cùng tên ô** (`lc-lap` ·
`lc-tl` · `lc-nt` · `lc-thu-o` …) để `lcLuu` và `lcDoiLap` chạy được ở cả hai mà không phải biết
mình đang đứng đâu. Đó là lựa chọn đúng, nhưng nó có một cái giá phải trả cho đủ:

**`getElementById` trả phần tử ĐẦU TIÊN trong cây.** Nên nếu khung của cửa vừa đóng còn nằm đó, mọi
lượt đọc của cửa đang mở đều trỏ nhầm sang nó — cửa trơ ra, ô không bày, **không một lỗi nào báo**.

Làn CGV (02/09) đã ghi bẫy này cho một chiều: *"`vcDong` phải xoá trắng `#vc-rieng-sk`"*. Chiều còn
lại thì bỏ sót — `lcDongCua` chỉ gỡ lớp `hien`, để nguyên `#lc-than` đầy ô trong cây — và nó nằm im
suốt từ hôm ấy. Nay `lcDongCua` dọn trắng khung khi đóng.

**Luật:** cửa nào đóng thì **dọn trắng khung của cửa ấy**, đừng chỉ giấu đi. Một luật, hai đầu.

**Kiểm bằng máy:** `thu-hai-cua-dong-bo.js` — lấy chuỗi HTML thật của cả hai khung, chạy luật ẩn/hiện
thật lên từng cái, so từng ô ở từng nhánh, và canh cả hai hàm đóng. Luật đầy đủ cho người: `CAU-TRUC-APP.md`
Mục 7 luật 12 (Tracy đặt 03/09).

## ⚠️ `rollback` TRONG TỆP SQL CUỐN NGƯỢC CẢ `alter table` (làn TNS, 03/09)

**Trình chạy SQL của Supabase bọc CẢ TỆP trong MỘT transaction.** Nên một cú `begin; … rollback;`
ở tầng ngoài cùng — dù chỉ định huỷ một dòng vừa chèn để thử — **huỷ luôn mọi thứ phía trên nó**,
kể cả `alter table add column`.

Đã cắn thật với `nang-cap-lich-thu-n-thang.sql`: Tracy chạy tệp, và câu tự kiểm cuối cùng báo
*column "tuan_thang" does not exist*. Cột không hề được tạo — mà **câu báo lỗi trỏ vào chỗ nó LỘ RA,
không trỏ vào chỗ nó hỏng**, nên đọc thẳng câu ấy thì đi tìm nhầm chỗ. Đây cũng là loại hỏng tệ nhất
của một bộ tự kiểm: nó *tự làm hỏng thứ nó đang đi kiểm*, rồi báo cáo trung thực về cái hỏng ấy.

**Luật:** trong tệp nâng cấp, **không dùng `begin`/`rollback` ở tầng ngoài cùng**. Muốn chèn thử rồi
bỏ thì bọc trong một khối `do $$ … $$` — khối ấy mở một transaction CON, nên bắt được lỗi bằng
`exception when …` và dọn dấu vết bằng một câu `delete`, mà không đụng tới transaction bao ngoài.
Câu "phải ngã" cũng viết trong khối con: ngã ở đó là một `raise notice`, ngã ở tầng ngoài là cả tệp
đổ. Kết quả đọc ở tab **Notices/Messages**, không phải tab Results.

`thu-thu-n-thang.js` khối ⑦ nay canh đúng luật này cho tệp của nó — bài thử sau cứ chép sang.

✅ **Bản vá đã chạy trót lọt trên máy chủ thật chiều 03/09** — cột `lich_chung.tuan_thang` có mặt, ràng buộc hai chiều đang làm việc (`phai_bang_khong = 0`). Dấu vết đã vào `SO-SQL.sql` nên máy dò trả lời được câu *tệp này đã chạy chưa* mà không cần sổ chép tay.

## ⚠️ Dấu huyền trong chú thích nằm giữa một chuỗi mẫu (làn SG, 01/09)

Đây là bẫy của **cả file**, không riêng một cụm: `public/index.html` dựng gần như mọi khối giao
diện bằng chuỗi mẫu (dấu huyền), và trong đó người ta hay chèn chú thích HTML để giải thích tại chỗ.

**Một dấu huyền trong chú thích là ĐÓNG chuỗi ngay tại đó.** Phần sau bị đọc thành biểu thức.
Ca thật: một comment `<!-- … (\`.nut-hinh.pha\`) … -->` bên trong chuỗi mẫu của `gnVeDoc` làm app
ném *"hinh is not defined"* lúc mở khung đọc.

**Vì sao hai lớp kiểm đều để lọt:**

| Lớp | Vì sao không thấy |
|---|---|
| `node --check` | mã **vẫn đúng cú pháp** — chỉ sai nghĩa |
| bài thử Node | chúng **gọi hàm**, không **nạp trang** |
| nạp app thật trong trình duyệt | ✅ lộ ra ngay lượt đầu |

**Luật rút ra:** chú thích để **NGOÀI** chuỗi mẫu, hoặc bỏ hết dấu huyền trong đó. Và sau một
đợt sửa lớn, **nạp cả app một lượt** — đó là lớp kiểm duy nhất bắt được họ lỗi "đúng cú pháp,
sai nghĩa".

## ⚠️ BÀI THỬ NGÃ VÌ THIẾU CỌC TRÔNG Y HỆT BÀI THỬ KHÔNG TỒN TẠI (làn DWS, 03/09)

Bốn bài thử của lưới lịch (`thu-mang-deepwork.js`, `thu-tuan-o-ngay.js`,
`thu-keo-doi-khoi.js`, `thu-keo-mep-va-o-den.js`) đều **cắt hàm gốc ra khỏi
`public/index.html`** rồi chạy trên cọc giả. Mỗi lần mã thêm một hàm mới mà hàm
đã cắt gọi tới — `daTre`, `lcDaiCuaKhung`, `tlgDaiChuaGio` — bài thử ngã ngay lượt
vẽ đầu bằng một `ReferenceError`, **trước khi in được một dòng ✅ hay ❌ nào**.

Không ai thấy. Một bộ thử im lặng đọc ra hệt một bộ thử đang xanh, và đó là lúc
nguy hiểm nhất: luật 31/08 về mảng deep work không còn ai canh suốt nhiều tuần.

**Trước khi tin bộ thử, chạy nó và nhìn dòng cuối có `n/n đạt` không.** Ngã vì
cọc thì thêm cọc, đừng bỏ qua.

**Quét cả bộ 03/09: 39 bài thử, 16 bài từng ngã. Làn BT vá 4, làn BT3 vá nốt 11.**
Nay **34 bài xanh · 4 bài chạy lại được nhưng đang báo đỏ · 1 bài chưa vá nổi**:

| Còn đỏ | Ca đỏ | Đó là gì |
|---|---|---|
| `thu-gio-ranh` | 5 | Giờ rảnh của nhóm (TRI-57) — bài thử **chưa từng chạy xanh lần nào**, nó ngã ngay từ khi ra đời |
| `thu-gieo-cam-ket` | 7 | Cửa gieo cam kết trong mốc dự án |
| `thu-cua-gop` | 2 | Khoang sự kiện trong cửa gộp: vẽ lại bao nhiêu lượt |
| `thu-luong-nghen` | *ngã* | Gác `veFormSua` — cửa đã thay hẳn bằng cửa Thông tin việc, phải **viết lại** chứ không vá được |

**Đừng nhìn 14 ca đỏ ấy như việc dọn dẹp.** Mỗi ca là một câu hỏi về mã, và câu
trả lời có thể là *mã sai* chứ không phải *bài thử cũ*. Lệnh quét cả bộ:

```bash
for f in thu-*.js; do R=$(node "$f" 2>&1 | tail -3); \
  echo "$R" | grep -q "Node.js v" && echo "NGÃ $f"; done
```

**Hai loại ngã, hai cách chữa khác hẳn nhau.** Thiếu cọc thì thêm cọc — hoặc tốt
hơn, **cắt luôn hàm thật ra** nếu nó còn trong mã, để bài thử gác mã chứ không gác
một bản chép. Mốc cắt không thấy thì phải soi: hàm đổi chữ ký thì sửa mốc, nhưng
hàm **đã bị gỡ** thì ca ấy đang canh một cơ chế đã chết — gỡ ca, đừng nới nó.
Ca ⑤ của `thu-keo-mep-va-o-den` là ví dụ: nó canh `gioNan`, đường gõ số mà Tracy
bỏ ngay chiều 29/08.

## ⚠️ Khoá `lich` trên một khối là ID BUỔI, không phải một cờ (làn DWS, 03/09)

`veKhoi` nhận diện khối sự kiện bằng `if (k.lich)`, và nhánh ấy đứng **trước**
nhánh mảng rời. Nên đừng đặt `lich: true` lên mảng rời để nó mượn màu buổi —
làm thế là mảng bị vẽ thành một buổi thứ hai, có ô tick, có tay nắm kéo. Dùng
một cờ riêng (`laBuoi`) rồi thêm lớp CSS ở chỗ vẽ. Cùng họ với bẫy `k.phien`
đã ghi trong mã hôm 31/08.

## ⚠️ TÊN LỚP TRẦN LÀ TÀI SẢN CHUNG — `.trai` đã là MỘT LUỐNG (làn CN, 04/09)

Dải sự kiện cả ngày mọc hai tay nắm để kéo, và bản đầu (03/09) đặt tên chúng là `trai`/`phai`.
Nhưng `.trai` đã có chủ từ lâu: đó là **một luống trong màn Khu Vườn** — viền gỗ 6px, `box-shadow`
gỗ, nền cỏ pixel. Selector `.tlg-ca .tlg-nam.trai` (0,3,0) đè được `width`·`height`·`inset`, nhưng
`border`·`padding`·`background` thì **không ai đè**, nên tay nắm trái phình thành 40×40 và vẽ ra
một cái luống cỏ tí hon đè lên đầu dải; tên sự kiện bị đẩy khuất khỏi khung.

**Vì sao nó khó truy:** tay nắm PHẢI vẫn đúng, vì `.phai` không có ai giành. Lỗi trông như "dải
hỏng một bên" — một hình dạng không gợi gì tới va chạm tên lớp.

**Luật rút ra:** đặt một tên lớp TRẦN mới thì `grep` nó trước. Và khi đã va thì **đổi tên của
mình**, đừng đè thêm CSS: một lớp trần dùng chung vẫn còn đó để người sau vấp lại. Nay là
`mep-trai`/`mep-phai`, và `thu-su-kien-nhieu-ngay.js` khối ⑨b canh cả tên mới lẫn việc tên ấy chưa
bị luật trần nào giành.

## ⚠️ Bốn chỗ dễ vấp ở bảng tin (làn BTN · BTL, 04/09)

> 🪤 **THANH LỀ XẾP THEO `order`, KHÔNG THEO DOM — và cụm mốc cũng nằm trong cuộc xếp ấy.**
> `#le-moc` là con ĐẦU TIÊN của `.le` trong HTML và mang `display:contents`, nên các nút mốc trở
> thành con trực tiếp của thanh ở `order:0`. Avatar mang `order:-1`. Vậy nên **đổi thứ tự trong
> bảng `NUT_LE` chỉ xếp lại các nút cùng `order`** — trên màn Hôm nay, cụm mốc vẫn chen vào giữa
> avatar và nút màn đầu tiên. Muốn một nút đứng sát dưới avatar thì phải cho nó `order:-1`
> (`.le #nut-bt`, làn LOA 04/09). Bẫy này sẽ cắn lại đúng như thế với nút thứ tư.
>
> 📍 **Bảng tin nay là MÀN RIÊNG** `#man-bangtin`, cửa vào là nút loa trên thanh lề. Nó từng nằm ở
> đầu màn Hôm nay đúng một buổi; Tracy bác vì *"nó bị choán hết mục hôm nay khi mà nhiều thông
> báo"*. Đừng đưa nó về chỗ cũ.

0. **`btChamMoi` là thứ duy nhất còn kéo người ta tới màn ấy.** Bảng tin ra màn riêng thì nó thôi
   đập vào mắt; chấm trên biểu tượng loa là cái bù lại. Nó chạy được nhờ `khoiDongThat` VẪN gọi
   `btTai()` dù màn đang đóng. Ai thấy lượt gọi ấy "thừa" mà gỡ đi thì chấm chỉ sáng sau khi người
   ta đã mở màn — tức đúng lúc nó hết việc, và không lỗi nào bật lên.


1. **`btSuaDuoc` là BẢN SAO của policy `ban_tin_sua_p`.** Đổi một bên mà quên bên kia thì hoặc bày
   ra một cái nút bấm vào bị từ chối, hoặc giấu mất một cửa người ta có quyền. Máy chủ mới là nơi
   ép; app chỉ giấu nút cho đỡ chọc vào cánh cửa khoá.
2. **`btVeCuaGiuNhap` phải nhặt bốn ô ra TRƯỚC khi vẽ lại.** Bấm một chip tag là dựng lại trọn
   khung cửa soạn tin; vẽ lại trắng trơn thì nuốt mất bản nháp người đang viết, và không một dấu
   hiệu nào báo là nó vừa mất.
3. **Tin `toan_cong_ty` CỐ Ý lọt mọi bộ lọc phòng.** Ai "tối ưu" thành lọc chặt theo mảng
   `chuc_nang_ids` là trả lời sai câu người ta đang hỏi — *"cái gì đang áp cho Sản phẩm"*.

4. **Link chỉ nhận `http`/`https`, rào ở `btLinkSach`.** Người đăng dán được bất cứ chuỗi gì; một
   `javascript:` nằm trong `href` là mã của người này chạy trong phiên đăng nhập của người kia. Và
   trong `btNoiHtml` thì **rào chữ TRƯỚC, nối link SAU** — ngược thứ tự là mở cửa cho thẻ HTML của
   người đăng chui vào trang người đọc.

**Bài thử:** `node production/tinh-thuc-app/thu-ban-tin.js` — 72 ca, cắt thẳng khối gốc từ
`index.html`. Sửa `btVe` · `btKhoang` · `btGonHan` · `btHop` · `btSuaDuoc` · `btLinkSach` ·
`btNoiHtml` · `btChamMoi` thì chạy lại trước khi đẩy.

🪤 **`thu-cu-phap.js` canh một luật dễ quên: chữ hiện ra màn gọi tập thể là "team", không phải
"đội".** Nó bắt được đúng một câu trong hộp hỏi gỡ tin của làn này. Chú thích trong mã thì không
sao — bài thử chỉ soi chuỗi hiện ra màn. Ai viết lời mới cho giao diện thì nhớ trước khi gõ.
## ⚠️ GOM MỘT CÂU LUẬT VỀ MỘT HÀM THÌ BA BỘ THỬ NGÃ (làn HS, 04/09)

Luật *"ai được sửa một sự kiện"* từng nằm chép tay ở bốn chỗ trong `index.html`. Gom cả bốn về
`lcDuocSua` — việc đúng, và chú thích cũ ngay tại chỗ cũng đã dặn làm — thì **ba bộ thử ngã ngay
với `ReferenceError`**: `thu-dai-ban.js` · `thu-mau-su-kien.js` · `thu-su-kien-nhieu-ngay.js`.

Lý do: ba bộ ấy **cắt từng hàm ra khỏi `index.html` rồi `eval` trong một phạm vi tự dựng** — cố ý,
để chạy mã thật chứ không chạy một bản chép. Nhưng phạm vi ấy chỉ có đúng những hàm chúng gọi tên.
Một hàm vừa nhận thêm phụ thuộc thì lát cắt cũ thiếu mất một mảnh, và **không có gì báo trước lúc
sửa** — mã trong trình duyệt vẫn chạy đúng, vì ở đó cả tệp cùng một phạm vi.

**Luật rút ra:** rút một câu luật ra thành hàm dùng chung thì `grep` tên hàm gọi nó trong `thu-*.js`
ngay sau đó, và thêm `${catHam('tênHàmMới')}` vào đúng những bộ đang cắt hàm gọi ấy. Nạp **mã thật**,
đừng stub — trừ khi bộ thử ấy hỏi về một chuyện khác hẳn và đã tự khai là đang giả (`thu-mau-su-kien.js`
hỏi về MÀU, `ME` của nó đang là `null`, nên `() => false` mới là câu đúng ở đó).

**Cách bắt:** so mã thoát của cả bộ thử giữa `origin/main` và làn của mình — bốn dòng shell ở mục
*ĐO BỘ THỬ THÌ ĐO TRÊN `origin/main`* phía trên. Chạy bộ thử của riêng mình thì không bao giờ thấy:
ba bộ ngã kia không nhắc gì tới quyền.

## ⚠️ MỘT CỤM CHỮ TRONG CHÚ THÍCH CŨNG BỊ BÀI THỬ GÁC-MÃ-NGUỒN TÍNH LÀ MÃ (làn DW2, 05/09)

`thu-thu-nho-phien.js` luật ⑥ quét từng dòng của `index.html` tìm `dwPhien = null` rồi đòi
`dwVeDai()` ở hai dòng kế. Tôi viết đúng luật ấy trong mã, nhưng để lại một chú thích cuối dòng:
`// NGAY SAU \`dwPhien = null\` — luật ⑥ của…`. Bài thử đọc chính dòng chú thích ấy như một chỗ
đặt `dwPhien = null` thứ hai, và dòng dưới nó không có `dwVeDai()` — **đỏ, dù mã đúng hoàn toàn**.

**Luật rút ra:** bài thử nào gác bằng cách quét văn bản mã nguồn thì **chú thích cũng là mã đối với
nó**. Nhắc tên một luật trong chú thích thì nhắc bằng lời (*"dải tắt ngay khi phiên rời tay"*),
đừng chép lại nguyên cụm chữ mà bài thử đang dò. Cùng họ với bẫy *dấu huyền trong chuỗi mẫu* ở trên:
cả hai đều là chuyện **văn bản**, không phải chuyện hành vi, nên chạy thử trong trình duyệt không
bao giờ thấy.

**Kèm theo, chiều ngược của bẫy làn HS:** móc một hàm mới vào một hàm LÕI (ở đây `datNghen` gọi
`dwTheoTrangThai`) kéo theo cả cụm phụ thuộc của hàm mới sang mọi bộ thử đang cắt hàm lõi ấy —
`thu-luong-nghen.js` ngã vì thiếu `dwLamMs`, `DW_SAN_PHUT`, `DW_TRAN_PHUT`, dù nó chẳng hỏi gì về
phiên deepwork. `grep` tên hàm lõi trong `thu-*.js` NGAY khi thêm lời gọi, đừng đợi lúc quét cả bộ.

## ⚠️ `btVe` NAY ẨN/HIỆN THEO NẤC, KHÔNG THEO "CÓ TIN HAY KHÔNG" (làn VD2, 05/09)

Màn `bangtin` từ 05/09 là **kênh thông báo hai nấc**: `Vấn đề` và `Thông báo`, biến `KTB_NAC`.
Hai chỗ sẽ cắn người sửa sau:

1. **`btVe` không còn tự quyết chuyện hiện hay ẩn.** Nó đọc `KTB_NAC`. Ai thêm một đường gọi
   `btVe()` từ chỗ khác mà quên đặt nấc thì khối im lặng không hiện, và không lỗi nào bật lên.
2. **Luật cũ *"chưa tin nào và mình không đăng được thì khối biến mất hẳn"* ĐÃ BỎ.** Nó đúng hồi
   bảng tin còn là một khối trên màn Hôm nay — ở đó một khung rỗng là phiền. Nay nó là một NẤC
   người ta chủ động bấm vào, và một nấc trắng trơn tệ hơn hẳn một dòng *"Chưa có tin nào"*.
   Dựng lại luật ấy là làm nấc Thông báo biến mất với người không phải lead.

Và một chuyện về bộ thử: **mã lớp vấn đề nằm TRONG lát cắt của `thu-ban-tin.js`** (`let BT_DS   =
[];` → `function moTab`). Hai bài thử ăn chung một khối nguồn, nên hỏng một bên thì cả hai đỏ.

## ⚠️ `await` Ở TẦNG NGOÀI CÙNG LÀM NODE ĐOÁN NHẦM SANG ESM (làn VD2, 05/09)

Một bài thử `thu-*.js` có `await` ở tầng ngoài cùng thì Node coi tệp là mô-đun ESM và ngã ngay ở
`require` với `ERR_AMBIGUOUS_MODULE_SYNTAX` — **trước khi chạy một ca nào**. Nhìn từ ngoài nó
giống hệt một bài thử hỏng nặng, mà thật ra chỉ là chỗ đặt chữ `await`.

Gói thân bài vào `(async () => { … })()` là xong, giữ nguyên lối `require` của 50 bài kia. Cùng họ
với luật *bài thử chết nguy hơn ca đỏ*: quét bằng **mã thoát**, đừng quét bằng ký hiệu.

## ⚠️ BÀI THỬ CẮT VÙNG BẰNG `indexOf` DÒ TỪ ĐẦU TỆP → VÙNG RỖNG (làn CV, 05/09)

`thu-tuan-o-ngay.js` đỏ 5 ca mà **mã app không sai một dòng nào**. Bài thử cắt vùng ra khỏi
`index.html` bằng `SRC.slice(SRC.indexOf(A), SRC.indexOf(B))` — mốc cuối dò **từ đầu tệp**,
không phải từ sau mốc đầu. Commit `7cf576e` (TRI-119) thêm bản thứ hai của chú thích
`/* Vạch "bây giờ" chỉ vẽ khi` vào một hàm đứng **trước** `veKhoi`; `indexOf` trả về bản sớm,
mốc cuối rơi trước mốc đầu, `slice` trả về **chuỗi rỗng**.

**Vùng rỗng hỏng theo cả hai đường cùng lúc** — đó là chỗ độc của nó:

| | Vì sao |
|---|---|
| **5 ca đỏ oan** | mọi `includes` trên chuỗi rỗng đều sai |
| **1 ca xanh oan** | `!khoiPhien.includes('checkbox')` trên chuỗi rỗng thì **luôn đúng** |

Soát cả tệp thấy thêm hai vùng nữa đang hỏng lặng lẽ, cùng lớp: `media720` có mốc cuối **đã
biến mất khỏi app** → `slice(i, -1)` ôm **1,83 triệu ký tự** (gần trọn tệp), nên 3 ca thôi soi
trong khối 720px mà quét cả app rồi xanh vì lẽ đó; `mediaCU` lấy phải bản sớm của
`@media (hover:none){` → vùng phình từ 585 lên **40.486 ký tự**.

**Ba luật rút ra:**

1. **Mốc cuối luôn dò từ SAU mốc đầu** — `SRC.indexOf(cuoi, i + dau.length)`. Hàm `catKhoi`
   trong chính tệp ấy đã làm đúng từ đầu; 12 chỗ cắt viết thẳng trong thân bài thì không.
   Nay có `catVung` / `catCon` lo việc này, dùng chúng thay vì cắt tay.
2. **Mốc long ra thì phải KÊU THÀNH MỘT CA ĐỎ CÓ TÊN.** Không ném lỗi — ném là mất cả bài, thứ
   kho này xếp nguy hơn ca đỏ. Không lặng lẽ trả rác — rác thì vừa đỏ oan vừa xanh oan.
3. **Một ca đỏ chưa chắc là ca lỗi thời, và một ca xanh chưa chắc là ca còn soi gì.** Trước khi
   viết lại một ca cho "khớp luật mới", đo xem vùng nó soi có còn dài bao nhiêu ký tự đã.

**Cách soát bằng máy** — quét mọi chỗ cắt trong cả bộ thử, kêu tên vùng rỗng · mốc mất · mốc mơ hồ:

```bash
node production/tinh-thuc-app/soi-moc-cat.js
```

Nó soi **hai phần**, và phần ② mới là phần nặng đô:

| | Soi gì | Hỏng thì ra sao |
|---|---|---|
| ① | chỗ cắt viết tay `SRC.slice(SRC.indexOf(…), SRC.indexOf(…))` — kể cả dạng đã vá | bài vẫn chạy, chỉ **soi sai vùng** |
| ② | mốc truyền vào `catKhoi` · `catHam` · `catDong` của từng bài (283 lượt gọi) | cả 46 hàm ấy **ném lỗi** → **cả bài chết**, mọi ca im lặng biến mất |

Phần ② đáng giá vì một cú đổi tên hàm trong `index.html` làm chết **nhiều bài cùng lúc**, mà mã thoát
chỉ nói "bài này ngã" chứ không nói ngã vì mốc nào. Thử thật: đổi tên `phutDeadline` → công cụ gọi
đúng tên mốc đã long ở cả ba bài phụ thuộc nó, trước khi chạy bài nào.

Công cụ nhận `THU_FILE` như các bài thử, nên soi được bản trên `origin/main`:

```bash
git show origin/main:public/index.html > /tmp/m.html
THU_FILE=/tmp/m.html node production/tinh-thuc-app/soi-moc-cat.js
```

**Hai mức, và ranh giới giữa chúng là chỗ quyết định:** HỎNG (rỗng · mất mốc · dò-từ-đầu mà mốc có
nhiều bản) trả mã 1 · MONG MANH (mốc nhiều bản nhưng vùng hiện tại vẫn đúng) chỉ kể tên, trả mã 0.
Một công cụ báo đỏ trên kho đang lành sẽ dạy người đọc bỏ qua nó, rồi ngày nó báo đúng cũng không ai
nhìn. Cùng lẽ ấy, dạng `SRC.indexOf(A), SRC.indexOf(A) + 1500` là **cửa sổ dài cố định** chứ không
phải cặp mốc — so hai mốc với nhau ở đó ra ngay một ca đỏ oan, nên công cụ chỉ soi mốc đầu.
## ⚠️ HAI ĐƯỜNG REALTIME, VÀ VÌ SAO LỚP VẤN ĐỀ KHÔNG ĐI ĐƯỜNG CHUNG (làn VD4, 05/09)

`RT_BANG` → `rtCoTin` → `rtTaiLai`, và `rtTaiLai` **hoãn lại chừng nào còn một cửa sổ nổi đang
mở** (`rtBanRon`). Đúng đắn cho một bảng lịch: không ai muốn bị giật mất thứ đang gõ dở.

Nhưng cửa chi tiết một vấn đề thì ngược hẳn — **cái cửa đang mở CHÍNH LÀ thứ cần đổi.** Cho hai
bảng `van_de` và `van_de_binh_luan` vào `RT_BANG` là mạch bàn luận chỉ tự đổi sau khi người ta
đóng cửa lại, tức hỏng đúng việc nó sinh ra để làm. Nên chúng đi **người nghe riêng `vdCoTin`**,
cùng lối `phien_deepwork` đã đi và cũng cố ý vắng mặt trong `RT_BANG`.

Ba chỗ phải khớp nhau, sửa một chỗ là câm một đầu: mảng trong `rtMoKenh` · hàm `vdCoTin` · tệp
`nang-cap-realtime-van-de.sql`. Ca ⑫ của `thu-van-de.js` canh cả ba bằng máy, kể cả việc hai bảng
ấy **không** được lọt vào `RT_BANG`.

## ⚠️ CHUỖI MẪU CỦA BỘ THỬ KHÔNG CHỨA NỔI MỘT DẤU HUYỀN (làn VD4, 05/09)

Khối cọc `COC` của mọi bài `thu-*.js` là **một chuỗi mẫu** dựng bằng dấu huyền. Viết một chú thích
trong đó mà quen tay bọc tên hàm bằng dấu huyền là **cắt đôi chuỗi ấy**, và Node ngã ở dòng đầu
tiên với một câu nói về một danh hiệu bất ngờ — nhìn từ ngoài giống hệt một bài thử hỏng nặng.
Trong khối `COC` thì viết tên hàm trần, không bọc gì.

Cùng họ với bẫy `await` ở tầng ngoài cùng ngay trên: cả hai đều là chuyện **văn bản của bài thử**,
không phải chuyện hành vi của app — nên quét bằng **mã thoát**, đừng quét bằng ký hiệu.

## ⚠️ `rtBanRon` CHỈ CHE CỬA SỔ NỔI — MÀN TOÀN TRANG PHẢI TỰ KÊ TÊN (làn NTH, 06/09)

Tiếp mục realtime ngay trên, và đây là mặt hỏng thứ hai của cùng cơ chế. `rtBanRon` nhận đúng hai
dấu hiệu: `.cua-noi-nen.hien` (khung chung của mười một cửa sổ nổi) và con trỏ đang nằm trong một ô
nhập. **Màn `#don` không mang class ấy** — nó là màn toàn trang — nên nó vô hình với lá chắn, dù nó
là chỗ giữ nháp NHIỀU việc cùng lúc trong `DON_TAM`.

Hệ quả Tracy bắt được 06/09: *"tôi cứ ấn lưu 1 task là nó đóng cửa sổ trong khi còn nhiều task khác
cần dọn dẹp"*. Đường đi đủ dài để không ai đọc mã mà thấy — **bảng `task` nằm trong `RT_BANG`, nên
cú lưu của CHÍNH máy này bắn một tin về mình** → `rtTaiLai` → `taiHomNay` → `kiemDon`. Mà `kiemDon`
viết cho màn sáng: nó đóng màn, đặt lại `DON_KIEU='sang'`, và xoá trắng `DON_TAM`.

Ba thứ rút ra, cái thứ ba là cái đáng nhớ:

- Thêm một màn toàn trang có nháp thì **kê tên nó vào `rtBanRon`**, đừng trông vào class chung.
- Hàm nào chạy ở cuối `taiHomNay` thì từ 03/09 nó **không còn là hàm chỉ chạy lúc mở app** — nó chạy
  sau mỗi cú ghi của mọi người, kể cả của chính mình. Đọc lại mọi hàm ở đó với giả định ấy.
- `kiemDon` cũng **không được tin vào `NO_CU`** nữa: `taiHomNay` vừa dựng lại biến ấy từ khung nhìn
  `viec_con_no`, tức chỉ còn NỢ CŨ, còn phần việc của hôm nay mà nghi thức đắp vào đã bay. Nên phần
  gom việc tách thành `htGomViec()` để gọi lại được, và có `HT_DA_DON` giữ danh sách việc đã trả lời
  — thiếu sổ này thì việc chọn "⏳ Chưa xong" hiện lại ngay lượt sau, vì `Chua_xong` vẫn nằm trong
  `TT_MO`. Nhịp ③ tấm gương có cờ riêng `HT_GUONG`: cùng chế độ `'toi'` mà hai nhịp muốn hai thứ
  khác nhau từ một lượt tải lại.

## 🟢 Làn đang mở

*(Ai đang mở làn thì ghi mục của mình vào đây; xem nhanh bằng `python3 lan.py soi`.)*

### Làn NTH — 06/09: nghi thức hoàn tất hẹn NGÀY MAI, và lưu một việc không đóng cửa (TRI-135)

Hai lỗi Tracy nêu cùng lúc, hoá ra hai gốc rời nhau.

**① Ngày hẹn lại mặc định sai chiều.** `donNgayHen` trả `homNay()` cho cả hai chế độ — đúng khi nó
viết 16/08 (lúc ấy chỉ có màn sáng), sai từ khi cửa tối dựng 11/08 thừa hưởng mặc định ấy. Nay có
`donNgayMoi()` làm **một nguồn chân lý cho cả ba ngày mà cửa này đặt ra**: ngày hẹn lại, hạn việc gỡ
nghẽn, và ngày của việc báo lại người đang chờ. Chế độ `'sang'` → hôm nay; `'toi'` → ngày làm kế
tiếp, **bước qua Chủ nhật** vì cả app coi Chủ nhật là ngày nghỉ (Tracy chốt 06/09). Chữ dưới ô hạn
việc gỡ nay nói ra NGÀY (`mặc định thì sẽ là 07/09`) chứ không nói "hôm nay" — dòng cũ sẽ thành một
lời nói dối ở chế độ tối.

**② Cửa tự đóng sau mỗi cú lưu** — đường realtime, xem mục ⚠️ ngay trên.

Bộ thử `thu-man-don.js` thêm hai khối (tổng 17 ca mới) và phải vá phần khung để chạy được chúng:
`HOM_NAY` thành biến đổi được (cần thử ca tối thứ Bảy), DOM giả có vỏ `classList` cho `#don`, khai
lại `rvCong`/`laCN`/`rvChuNgay`/`TT_MO`/`TASKS` vì chúng nằm ngoài lát mã, và một cần gạt `__ht` cho
bốn thứ khai bằng `let` bên trong lát. Một ca cũ đổi lời: nhắc dưới ô hạn nay là "13/08" chứ không
phải "hôm nay".

### Làn CGL — 05/09: gỡ hàng chú giải khỏi hai lưới mới

Tracy nói với phiên khác, cầm ảnh bảng Lịch chung: *"xóa luôn chú thích đi k cần đâu"*. Hai lưới
của làn LG vừa dựng xong thì cũng đang có hàng ấy, mà chúng đứng cùng một màn — nên gỡ theo, không
đợi Tracy phải nói lần thứ hai cho cùng một thứ.

Giữ lại **đúng một dòng**: lời báo khi chưa đọc được sổ việc đã xong. Nó không phải chú giải mà là
một lời thú thật — thiếu nó thì lưới bày mọi buổi như thể chưa ai dự xong. Cùng chỗ bảng Lịch chung
đã giữ. Gỡ theo hai luật CSS chỉ sống trong hàng ấy (`.dbg-cg-ten`, `.dbg-cg-dk`) và `.dbg-tt` —
nhãn "chưa chốt" dạng thẻ chữ, nay nghĩa ấy do nét đứt nói.

Bài thử thêm mục ⑫ (72 ca): cấm hàng chú giải quay lại, canh `title` của khối vẫn kể đủ giờ · nhóm
nhận · con số, và canh lời thú thật vẫn hiện khi sổ việc đọc không được.

### Làn LG — 05/09: nấc "7 ngày" thành LƯỚI GIỜ (TRI-119, tiếp làn L7)

Tracy xem bản đầu rồi bác ngay: *"ko, có thêm cột giờ như là bảng timeline view tuần và tháng ý"*.
"Bảng timeline" là khối Lịch trình bên màn Hôm nay — nấc Tuần của nó có trục giờ, nấc Tháng là lưới
ô ngày. Nên nấc *7 ngày* dựng lại thành lưới giờ (`dbVeGio` + `dbKhoiGio`), còn nấc *Tháng* giữ
nguyên hình cũ, chỉ đổi tên hàm cho đúng việc: `dbVeLuoi`→`dbVeThang`, `dbTheLuoi`→`dbTheThang`.

**Năm điều đáng nhớ:**

1. **KHÔNG gọi `tlgThanLuoi`.** Hàm ấy dựng quanh việc của chính mình và mang theo cả bộ máy SỬA —
   kéo khối, nới hai mép, chạm ô trống thêm việc, ô tick trên khối. Ở màn nhìn nhịp cả đội thì mỗi
   đường ấy là một câu hỏi về quyền chưa ai trả lời. Nấc này **chỉ đọc**.
2. **Mượn HÌNH, không mượn LỚP.** `--tlg-h`, `--tlg-cot` và ba ngưỡng màn lấy đúng con số của
   `.tlg` để hai cuốn lịch không bày một giờ ở hai chiều cao. Nhưng tên lớp riêng (`dbt-`): bộ
   kéo–thả bắt phần tử theo `.tlg-cot` và `data-ngay`, dựng lại đúng tên ấy là mời nó bắt nhầm.
   `.tlg-hang` thì dùng chung được — nó chỉ khai một lưới bảy cột, không mang hành vi.
3. **Xếp chồng giờ đi bằng `tlgXepLan`** — hàm thuần, chỉ đọc `tu`/`den` rồi gán `lan`/`tongLan`.
   Chép lại phép ấy là dựng luật xếp chồng thứ hai cho cùng một app.
4. **Điện thoại thì CUỘN NGANG, không bóp bảy cột vào 337px** (mỗi cột còn 42px, tên đọc ra
   "Kick", "[Mr."). Khối Lịch trình giải cùng bài toán bằng cách bỏ chữ — lối ấy đúng cho NÓ vì nó
   có kéo–thả, mà kéo trong một máng cuộn ngang là hai cử chỉ giành một ngón tay. Trục giờ ghim mép
   trái, nền đục, đúng cách cột tên người đã chữa hôm 03/09.
5. **Cuộn sẵn tới buổi sớm nhất** khi vẽ xong. Dải tối thiểu là 7h–22h mà nhịp họp bắt đầu 9:30 —
   mở ra ở 7h là hai hàng rưỡi trống trước thứ người ta vào đây để xem.

🪤 **Bản đầu của làn này mượn NÉT ĐỨT cho "đã dời"** — đúng thứ luật gốc ở
`.tlg-viec.lich.chua-chot` cấm bằng chữ, và Tracy bắt ngay: *"dời đi thì màu xám nét liền còn dự
kiến thì nét đứt, đã thống nhất r mà"*. **Trên mọi lưới của app, nét đứt chỉ được nói một điều —
thứ này chưa chốt.** Nay hai lưới mới đọc `da_chot` (qua `dbBuoiCuaLuot` → `b.chot`) và vẽ dấu ấy
bằng `outline`, còn bóng của buổi đã dời thì xám nét liền. Một ca thử ở tầng CSS canh luôn: quét
khối kiểu dáng của hai lưới, `dashed` chỉ được xuất hiện trong đúng lớp `chua-chot`.

**Bài thử:** `thu-luoi-ngay.js` lên 67 ca — thêm mục ⑥ (trục giờ, chỗ đứng 2,5 giờ, cao 3 giờ, chỉ
đọc, không mượn lớp timeline, vạch giờ hiện tại) và ⑥b (dải tự co, ba buổi trùng giờ chia ba bề
ngang, hai buổi rời nhau vẫn trọn bề ngang). `thu-loc-coreteam` đổi 3 → **4** bảng cùng gọi
`dbLocNguoi`.

🪤 **Làn L7 sáng nay đã ghi đè mất một mục sổ của phiên khác** (`d344b36`, đúng cái mục "commit
ngay" ở đầu tệp này): làn mở lúc 12:35, mục ấy commit lúc 12:45, và cú gộp lấy bản sổ của làn. Lịch
sử còn nguyên nên không một dấu hiệu nào báo. **Làn sống lâu hơn vài phút thì trước khi gộp phải
`git fetch` rồi rebase, đừng chỉ hỏi mã có đụng nhau không.** Làn LG này đã rebase lên `606679d`
trước khi ghi sổ.

### Làn L7 — 05/09: hai khung nhìn lịch mới, 7 ngày và tháng (TRI-119)

Tracy: *"bổ sung thêm cả view 7 ngày + view tháng để tôi còn check lịch cố định toàn bộ rova cho
dễ"*, và chốt tiếp *"hiện hết cho tôi nhé"* cho ô ngày đông buổi.

Màn Vận hành nay có **năm** cách bày, không ba: `ranh` · `lich` · `chung` · **`tuan`** · **`thang`**.
Nút cũ *Lịch chung* đổi tên thành *Danh sách* — cả ba cái sau đều là lịch chung, tên nút phải nói
cách bày. Hai khung nhìn mới đi chung **một hàm** `dbVeLuoi(khu, d, tu, den, ai, xong, kieu)`, đọc
đúng sổ `dbBuoiCuaDai` mà bảng Danh sách đang đọc.

**Bốn chỗ dễ vấp, chép lại vì chúng sẽ tái diễn:**

1. **`dbBayNgay` từng có trần 14 ngày.** Nó dựng cho hai bảng tuần, và nó cắt cụt trong im lặng —
   lưới tháng sẽ vẽ đủ bảy cột mũ rồi thiếu quá nửa thân, không một dòng lỗi nào. Nay là **42**.
2. **Dải của lưới tháng là dải LƯỚI, không phải dải tháng** (`vhLuoiThang`): mở bằng thứ Hai của
   tuần chứa ngày 1, đóng bằng Chủ nhật của tuần chứa ngày cuối. Cắt đúng hai mép tháng thì lưới
   vẫn dựng ra, chỉ là mọi cột lệch khỏi tên thứ trên đầu nó.
3. **Bước tháng phải neo về ngày 1 trước khi cộng** (`vhNgaySauBuoc`). Đứng ở 31/01 mà cộng một
   tháng thì tháng Hai không có ngày 31 và trình duyệt đẩy tiếp sang 02/03 — nhảy hai tháng trong
   một cú bấm.
4. **`vhXaQua` nay hỏi CHÂN TIẾP THEO, không hỏi chỗ đang đứng.** Cùng một phép tính với `vhDoi`,
   nên nút › còn sáng thì bấm là đi. Bản trước để nút sáng ở tháng cuối cùng còn đi được rồi
   `vhDoi` lặng lẽ quay đầu.

**Bài thử:** `thu-luoi-ngay.js` (45 ca) — dải lưới tháng · bước tháng từ ngày 31 · trần 42 ngày ·
hiện hết buổi · tóm tắt bỏ qua ngày mượn · bóng không mang con số · lịch lặp mở đúng ngày gốc.
Hai bài cũ phải sửa theo, cả hai vì con số đếm chứ không vì hỏng: `thu-lich-toan-team.js` (ba nút →
năm nút) và `thu-loc-coreteam.js` (quãng cắt `dbVeChung → lcGhiThamDu` nay chứa cả hai lưới mới,
nên số chỗ gọi `dbLocNguoi` là 3).

**Bản mẫu tĩnh:** `node xuat-mau-luoi-ngay.js mau-luoi-ngay.html` — sinh từ chính `dbVeLuoi`, có
nút xem nền tối, dữ liệu giả bốn nhịp cố định hằng tuần của ROVA.

### 📌 Cho phiên đang giữ cây làm việc `lan-app/LL`

Việc của bạn **đã lên sóng** (`07b4409`), rồi **đã bị viết đè phần menu** ngay sau đó: Tracy đổi ô lọc từ chọn-một sang tick-nhiều và xin ghim chiều cao bảng, tôi làm ở làn LN2 (`105dc79`). Cây `lan-app/LL` nay **cũ hơn `main`** — đừng sửa tiếp trên đó. `python3 lan.py bo LL` rồi mở làn mới nếu còn việc. Chi tiết cả hai nhát nằm ở `luu-tru/CHI-MUC-LAN.md`, dòng LL và dòng LN2.

⚠️ **Hai lối nói "chìm" vẫn đứng cách nhau 14px trong thẻ Việc hôm nay.** Chip ô lọc đi `--o-nhap` + viền `--o-nhap-vien` + `var(--lom)`; hàng ngay dưới (làn HM, `524b097`) đi `--card2` + viền trong suốt + không bóng. **Chờ Tracy chốt lấy một lối** — đã nêu, chưa trả lời.

### Làn MCD — 05/09: đổi giờ chuỗi thì việc của CẢ ĐỘI đi theo (TRI-109)

Tracy 05/09, sau khi nghe hạn chế của TRI-107: *"làm luôn máy chủ"*.

**Vì sao phải là hàm ở máy chủ, không phải một policy rộng hơn.** `ghi_task` cho mỗi người sửa đúng
việc của chính mình — luật đúng, không nên nới. **RLS của Postgres chặn theo DÒNG chứ không theo
CỘT**, nên mở policy update cho việc của người khác là mở trọn cả dòng: nội dung, trạng thái, ghi
chú chốt. Một hàm `security definer` khoanh đúng ba cột giờ. Cùng lối `nhan_cam_ket` và
`danh_dau_da_xem_du_an` đã đi.

⚠️ **Một hàm `security definer` KHÔNG tự kiểm quyền là một cánh cửa mở** — RLS không chặn hộ nó. Hàm
này chép nguyên vế `using` của policy `sua_lich`: lead, hoặc người tạo sự kiện. Không rộng hơn một ly.

**Máy khách dò bằng chính lượt gọi**, không thêm câu hỏi nào: chưa chạy tệp SQL thì PostgREST trả
`PGRST202` và app rơi xuống đường máy khách cũ, chạy y như hôm qua. Lỗi **khác** thì nói thẳng ra —
một lỗi quyền mà lặng lẽ chạy tiếp đường cũ là giấu đúng thứ người dùng cần biết.

🪤 **Chữ ký hàm khai `integer`, không `smallint`,** dù kho lưu smallint. Máy khách gửi một số JSON,
và một chữ ký `smallint` là chỗ dễ sinh ra lỗi *"không tìm thấy hàm"* rất khó đọc. Phép gán xuống
cột smallint thì Postgres tự lo.

**Toast của hai đường nói hai điều khác nhau, có chủ ý:** đường máy chủ nói *"n việc của chuỗi"*,
đường cũ nói *"n việc CỦA TÔI"* — người đổi giờ phải biết ngay là việc của đồng đội chưa đi theo.

| Chạm | Thử |
|---|---|
| `lcTheoChuoi` · cờ `CO_DOI_CA_DOI` · tệp mới `nang-cap-doi-gio-viec-ca-doi.sql` · `SO-SQL.sql` | `thu-viec-theo-chuoi.js` — **20 phép kiểm** (nâng từ 11) |

⏳ **Chờ Tracy chạy tệp SQL trên Supabase.** Chưa chạy thì tính năng vẫn ở mức TRI-107 — chỉ việc của
người đổi giờ đi theo. Không có gì hỏng.

### Làn TV — 05/09: đổi giờ cả chuỗi thì việc đã đẻ đi theo (TRI-107)

Mã tự khai chỗ hở này là **cố ý**, và mục ⏳ của sổ này chép lại lời khai ấy suốt nhiều tuần. Tracy bác bỏ:

> *"Chỉ là giữ ở vận hành để nắm được sự thay đổi lịch trình thôi, chứ task là mang nghĩa thứ cần
> phải làm; nếu đã thay đổi sự kiện rồi thì task đó phải thay đổi theo chứ."*

**Nguyên lý rút ra, dùng cho mọi tính năng sau:** lịch trình là thứ để nhìn lại, task là thứ để làm.
Cái trước được phép giữ nguyên trạng cũ làm dấu vết; cái sau phải luôn nói đúng việc cần làm lúc này.

🪤 **Bẫy về CÁCH LÀM VIỆC, đáng nhớ hơn cả phần mã: lời tự khai trong mã không phải quyết định của
Tracy.** Một dòng chú thích viết "cố ý" chỉ chứng minh người viết lúc ấy nghĩ vậy. Đem hỏi lại thì
ngược hẳn. Gặp chữ "cố ý" trong mã hay trong sổ mà nó đang chặn một việc đáng làm thì hỏi, đừng tin.

**Luật "còn sạch" giữ nguyên** (Tracy chốt sau khi cân ba phương án): chỉ dời việc còn `Chua_lam` và
chưa có phiên deep work nào. Nới ở đây là nới **phạm vi**, không nới luật.

**Hai cửa đổi giờ, một đường mới `lcTheoChuoi`:** cú kéo với phạm vi *Tất cả sự kiện* (`lcLuuDoi`),
và cửa Lưu khi sửa một sự kiện có sẵn (`lcLuu`). Cửa thứ hai từng bị bỏ sót vì chú thích cũ ở đó
viết *"nhánh SỬA không đẻ việc nào nên không ai gọi hộ"* — đúng vế đầu, nhưng việc đã đẻ từ những
lượt trước vẫn còn đó và giờ của chúng vừa cũ đi.

⚠️ **Bốn chỗ dễ vấp, cả bốn đều im lặng khi sai:**
1. **Buổi đã dời riêng phải được chừa ra.** Dòng `kieu='doi'` trong `lich_chung_ngoai_le` là một
   quyết định cũ của người dùng; kéo nó về hàng là xoá quyết định ấy.
2. **Ngày không đổi, chỉ giờ đổi.** Với chuỗi định kỳ, ngày do luật lặp quyết — `patch` cố ý không
   mang cột `ngay`, khác `lcTheoViec` nơi một buổi lẻ dời được sang hẳn ngày khác.
3. **Chỉ với tới việc của chính mình.** `ghi_task` cho mỗi người sửa đúng việc của mình. Chuỗi mà
   nhiều người cùng đẻ việc thì việc của họ đứng ở giờ cũ tới khi máy họ chạy qua đây. Muốn đi hết
   phải có hàm ở máy chủ — **chưa làm**.
4. **Trần 500 và 1000**, chép của `lcDonViec`. Chuỗi chạy vài năm có thể đẻ nhiều hơn thế; phần dư
   giữ giờ cũ, không một tiếng kêu nào.

🪤 **Bài thử của chính làn này đỏ oan một lượt**, và cách nó hỏng sẽ tái diễn: phép kiểm so thứ tự
hai câu lệnh, mà lời nhắc *"Đọc `LC_SUA` TRƯỚC `lcDongCua()`"* nằm ngay trên đoạn mã — máy đọc thấy
tên hàm trong **chú thích** và tưởng lệnh gọi đứng trước. **So thứ tự thì bỏ chú thích trước đã.**

| Chạm | Thử |
|---|---|
| `lcLuuDoi` · `lcLuu` · hàm mới `lcTheoChuoi` · `DANG-LAM.md` | `thu-viec-theo-chuoi.js` — **11 phép kiểm** |

⚠️ **Nợ có sẵn, KHÔNG do làn này:** `thu-keo-su-kien.js` ngã lúc nạp hàm (dòng 166) — đã đối chiếu
trên `origin/main` sạch, nó ngã y hệt ở đó.

### Làn HN — 05/09: bảng Hôm nay tự đổi khi lịch thay đổi (TRI-106)

Tracy thử trên máy Andy: *"chỉnh lịch hôm nay ở timeline thì task ở bảng hôm nay không thay đổi"*.

**Bệnh gốc, một câu:** bảng việc hôm nay đọc mảng `TASKS`, và cả tệp chỉ có ĐÚNG MỘT chỗ nạp nó —
bên trong `taiHomNay()`. Sáu cửa sửa dữ liệu lại gọi `lamMoiCuaToi()`, hàm khi ấy chỉ nuôi màn Của
tôi. **Ba trong sáu cửa còn mang sẵn chú thích viết ĐÚNG điều cần làm rồi gọi nhầm ngay dòng dưới.**

**Cách vá:** kéo `taiHomNay()` vào chính `lamMoiCuaToi()`, và chỉ chạy khi màn Hôm nay đang hiện —
bảy cửa được vá một lượt, cửa thứ tám viết sau này không phải nhớ gì. Màn đang ẩn thì `moTab` vốn
đã gọi `taiHomNay()` lúc bấm quay lại, nên bỏ qua không mất gì.

🪤 **Bẫy đáng nhớ nhất của làn này: một chú thích đúng không cứu được một lệnh gọi sai.** Ba lời
nhắc viết rõ *"Bảng Hôm nay đọc `TASKS`, thứ chỉ `taiHomNay` dựng"* nằm ngay trên ba lệnh gọi nhầm,
và tồn tại nhiều tuần mà không ai thấy — vì mắt đọc lời nhắc rồi tin là việc đã làm. Thứ bắt được
nó là một bài thử chạy bằng máy, không phải một lần đọc kỹ hơn.

⚠️ **Máy chủ KHÔNG có lỗi — đã đo, đừng dò lại:** cả bốn bảng `lich_chung`, `lich_chung_tham_du`,
`lich_chung_ngoai_le`, `task` đều phát tin; độ trễ 330 ms; khoá công khai chưa đăng nhập nhận 0 tin
thêm và sửa, chỉ nhận tin xoá đúng như `nang-cap-realtime-lich.sql` đã lường. Quyền đọc của cả bốn
bảng là `la_thanh_vien()`, nên mọi tài khoản giống hệt nhau — lỗi này gặp ở mọi máy, không riêng máy
Andy.

| Chạm | Thử |
|---|---|
| `lamMoiCuaToi` · `tlkLuuViecMoi` · `tlkTraVeKho` · `DANG-LAM.md` | `thu-lam-moi-homnay.js` — **5 phép kiểm**, canh luật *"ghi xuống `task` thì phải có đường về bảng Hôm nay"* |

**Để lại cho TRI-108:** mười ba cửa ở bốn màn khác cũng ghi xuống `task` mà không làm mới bảng Hôm
nay. Cố ý không vá trong làn này — phạm vi TRI-106 dừng ở nhóm lịch và timeline, và chưa chắc cửa
nào cũng là lỗi. Tên chúng nằm trong `CHO_SOI` của bài thử.

### Làn GON — 04/09: ngày kết thúc chọn được · ô gọn · nhóm xa hơn · cửa gộp theo cùng thang

Tracy 04/09, năm việc: *"sửa cả cửa sổ này nữa"* (cửa gộp) · *"giờ kết thúc mở rộng cho lựa chọn cả
ngày kết thúc đi"* · *"các ô lựa chọn cho gọn hơn nữa đi to quá"* · *"khoảng cách giữa các nhóm xa
hơn nữa"* · *"Quyền của khách và 3 lựa chọn cho nhỏ đi"*.

🔴 **MỘT SỐ TÔI ĐỌC SAI, VÀ NÓ ĐÃ THÀNH MỘT LỖI THẬT.** Hôm nay tôi nói với Tracy *"kho chặn một
buổi ở 10 giờ"* và lấy đó làm lý do bày ngày kết thúc thành **chữ trơn suy ra** thay vì ô nhập.
Ràng buộc thật là `so_phut between 5 and 1440` (`nang-cap-lich-chung.sql:119`) — **hai mươi tư
giờ**. Con số 600 chỉ là `max` của cái ô nhập cũ, một giới hạn GIAO DIỆN tôi đọc nhầm thành một luật
của KHO. Hậu quả không dừng ở một câu nói sai: `lcLuu` cũng ghìm `so_phut` ở 600, nên **một buổi 12
tiếng bị cắt còn 10 lúc lưu, không một chữ nào báo**. Bài thử mới bắt được nó.
**Luật rút ra: giới hạn ở đường GHI phải chép từ ràng buộc của KHO, không chép từ một ô nhập —**
ô nhập bị gỡ đi thì con số của nó ở lại làm một cái trần vô danh.

**Bốn việc còn lại:**
- **Ô gọn hơn:** 40 → **34px**, bo 12 → 10px, chữ điều khiển .9 → **.86rem**. Ô Tên và ô Màu giữ
  **42px** riêng (dòng đầu được phép nặng hơn) — nhưng đi bằng **cặp biến `--o-to`/`--o-bo-to`**,
  không gõ tay hai chỗ.
- **Nhóm xa hơn:** hở giữa hai nhóm 22 → **28px**, trong nhóm vẫn 8px.
- **Khối Quyền nhỏ hơn cả bậc điều khiển** (.79rem, ô tick 17px) — **ngoại lệ có chủ ý** so với luật
  ba bậc: ba cái công tắc ít khi đụng tới không đáng nói to bằng ô Tên.
- **Cửa GỘP** dùng chung trọn bộ thang và cũng chia nhóm, nhóm AI liền một mạch.

🪤 **Ba cái bẫy trong một làn, cả ba đều là "con số tôi viết ra không ăn":**
1. **Đặc hiệu CSS.** `.lc-than input[type=date]{width:114px}` thua `.lc-so input[type=date]{width:auto}`
   — một lớp thua hai lớp. Khai 114px, đo ra **152px**. Nhìn thì tưởng trình duyệt bướng.
2. **`scrollWidth` của ô ngày KHÔNG báo tràn.** Ở 114px chữ số cuối của năm bị cắt mà máy vẫn nói
   "đủ chỗ". **Ô `input[type=date]` phải soi bằng mắt, đừng tin số.** Chốt ở 126px.
3. **Dấu huyền ngược trong chuỗi mẫu — lần thứ TƯ trong ngày.** Thôi trông vào trí nhớ: nay dọn bằng
   một vòng `re.sub` quét mọi chú thích HTML trong hai khuôn.

| Chạm | Thử |
|---|---|
| CSS thang (dùng chung `.lc-than` + `.vc-rieng`) · khuôn `lcMoForm` · khuôn `vcVeSuKien` · `lcDongBoPhut` · `lcVeNgayDen` · `lcDoiCaNgay` · `lcDoiDenNgay` · `lcLuu` (trần 600 → 1440) | `thu-loai-ca-nhan.js` — **150 ca** |

### Làn NHOM — 04/09: cửa Sự kiện chia BA NHÓM, hai nhịp hở

Tracy 04/09: *"sao có ô coreteam với mời thêm người lại ở xa nhau thế · nguyên tắc là phải xếp cùng
nhóm nội dung ở gần nhau chứ, tư duy trải nghiệm thao tác người dùng đi"*, và ngay sau đó *"các ô
cũng xa nhau ra"*.

**Hai câu ấy là MỘT luật: trong một nhóm thì sát, giữa hai nhóm thì xa.** Bản trước cho mọi thứ cách
đúng 14px — tức **không có nhóm nào cả**. Một khoảng cách duy nhất thì mắt không có cách nào đọc ra
bốn ô này thuộc về nhau còn ô thứ năm thì không. Và đó chính là lý do ô *Đối tượng* nằm cách nút
*Mời thêm người* bốn khối, dù hai ô ấy nói về **cùng một tập người**.

**Ba nhóm, mỗi nhóm một câu hỏi:**

| Nhóm | Gồm | Trả lời câu |
|---|---|---|
| ① | Trạng thái lịch — cả chuỗi | buổi này ở nấc nào |
| ② | `[Loại \| Đối tượng]` · Mời thêm người · Giờ cùng rảnh · Quyền của khách | **AI** |
| ③ | Thông tin trước sự kiện | nội dung |

Nhóm ② là chỗ sửa thật: Đối tượng nói nhóm nào nhận · Mời thêm người cộng tên vào đó · Giờ cùng rảnh
tính **TỪ** chính tập người ấy · Quyền của khách nói họ được làm gì. Rời một cái ra khỏi ba cái kia
là bắt mắt đi tìm.

**Hai nhịp hở:** trong nhóm **8px**, giữa hai nhóm **8+14 = 22px** — gần gấp ba. *Tỉ lệ* mới là thứ
dựng ra nhóm, không phải con số tuyệt đối.

⚠️ **Một chỗ lệch so với danh sách Tracy kê hôm nay:** ô *Loại sự kiện* chuyển từ **cuối** cửa lên
**đầu nhóm ②**. Bắt buộc, vì Tracy cũng đã chốt *"cho hộp chọn loại sự kiện và hộp chọn đối tượng ở
cùng 1 hàng cho gọn"* — mà Đối tượng phải nằm cạnh nút Mời. Muốn Loại về cuối thì phải tách hàng ấy
ra làm hai.

| Chạm | Thử |
|---|---|
| Khuôn `lcMoForm`: bọc ba `.lc-nhom` · CSS `.lc-nhom` | `thu-loai-ca-nhan.js` — **141 ca**, thêm 3 ca canh: nhóm AI liền một mạch không có khối lạ chen vào · đúng ba nhóm · hai nhịp hở |

### Làn DEU — 04/09: cửa Sự kiện về MỘT thang chữ, MỘT chiều cao ô

Tracy 04/09, ngay sau khi bố cục mới lên sóng: *"mấy ô ở ảnh 1 ko đều nhau nhìn lởm chởm quá · ảnh 2
nội dung cách ra đi · cỡ chữ to nhỏ lộn xộn nữa"*.

**ĐO TRƯỚC KHI SỬA, không ước lượng bằng mắt** — dựng trang thử từ CSS thật rồi đọc
`getComputedStyle` cho từng ô:

| Đo được ở bản trước | |
|---|---|
| Cỡ chữ trong MỘT cửa | **bảy** bậc: 16 · 14 · 13,1 · 12,8 · 12,5 · 12,2 · 10,9px |
| Ô đứng CÙNG một hàng | lệch tới **23px** — ô ngày 45px cạnh chip giờ 38px; nhãn *Cả ngày* 22px cạnh ô lặp 45px |

Ba lời than của Tracy là **một** lỗi: cửa này gom ô từ năm bộ khác nhau, mỗi bộ mang thang riêng.
Nay còn **ba bậc chữ** (1,05rem tên · 0,9rem mọi ô và nhãn · 0,74rem nhãn mục) và **một** chiều cao
40px, **một** bán kính 12px.

⚠️ **Bọc trong `.lc-than`, KHÔNG sửa lớp gốc.** `.o-ngay` · `.nut-nho` · `.tv-nhan` · `.lc-thu-nut`
còn phục vụ cửa Thông tin việc và bốn nấc lịch — chúng có nhịp riêng, sửa gốc là chỉnh một cửa rồi
làm lệch năm chỗ khác.

**Hai thứ chiều cao cứng làm lộ ra, cả hai đều phải vá kèm:** khai `height` mà bỏ đệm dọc thì chữ
dính mép trên (phải `align-items:center`), và bỏ cả đệm NGANG thì chữ bị cắt cụt — *"Đã chốt"* mất
đuôi. Đo mới thấy, nhìn thì tưởng nút hơi chật.

**Hàng thời gian gói thành HAI CỤM** (`.lc-cum`). Bốn ô rời thì lúc màn hẹp nó gãy ở bất cứ đâu —
chữ *tới* nằm lại cuối dòng trên còn giờ kết thúc rơi xuống dòng dưới, đọc ra như một câu cụt. Gói
lại thì chỗ gãy duy nhất là giữa hai cụm, và cả hai nửa đều đọc trọn nghĩa. Kèm theo: `input[type=date]`
có bề ngang nội tại **166px** do trình duyệt cho — đủ để đẩy cả hàng tràn dòng ở màn 390px, nên khai
cứng 126px.

| Chạm | Thử |
|---|---|
| CSS: khối thang mới trong `.lc-than` · `.lc-cum` · `.lc-o-muc` · ô ngày 126px · đệm ngang nút | `thu-loai-ca-nhan.js` — **138 ca**, thêm 8 ca canh: đúng ba bậc chữ · một biến chiều cao · không sửa lớp gốc · hàng thời gian gói cụm |
| Markup: bọc cặp nhãn+ô của *Trạng thái lịch* và *Quyền của khách* vào `.lc-o-muc` | |

### Làn GGC — 04/09: dựng lại cửa Sự kiện theo Lịch Google, và quyền của khách (TRI-105)

Tracy 04/09, kèm ảnh Lịch Google và lý do: *"tôi muốn thiết kế giống gg calendar để mọi người đỡ mất
công học lại cách dùng"*. Thứ tự trong cửa vì thế **không phải sở thích** — nó là thứ tự người ta đã
quen, và mọi lần muốn "cải tiến" nó đều là tự phá mất lý do chép nó.

**Bố cục mới, hai tầng.** Trên: ô màu + tên (chữ to nhất) · `ngày · giờ  tới  giờ · ngày` · `Cả ngày`
cạnh ô lặp. Dưới, sau một dải ngăn hở rộng gấp đôi: **Chi tiết sự kiện** — trạng thái · mời ai · giờ
cùng rảnh · quyền của khách · thông tin trước sự kiện · `Loại` cạnh `Đối tượng`.

**Bốn thứ đáng ghi vì chúng sẽ bị hiểu nhầm:**

1. **`lc-phut` không mất, nó ẩn.** Ba chỗ đọc nó (`lcVeRanh` tìm khe trống · `lcChonKhe` · `lcLuu`);
   bỏ hẳn là sửa ba nơi cho một cú đổi hình. `lcDongBoPhut` giữ nó khớp hai ô giờ.
2. **Đổi giờ BẮT ĐẦU thì giữ độ dài và dời giờ kết thúc** — đúng cách Lịch Google. Làm ngược lại là
   người ta dời buổi sang chiều rồi phát hiện nó dài thêm hai tiếng mà không ai nói gì.
3. **Ngày kết thúc của buổi CÓ GIỜ là chữ SUY RA, không phải ô nhập.** Kho chặn một buổi ở 10 giờ
   (`so_phut` ≤ 600), nên nó chỉ có thể là chính ngày ấy hoặc hôm sau. Bày ô nhập ở đó là mời người
   ta gõ vào thứ không lưu được. Buổi **Cả ngày** thì ngược lại — ô nhập thật, vì chuỗi nhiều ngày
   là thứ kho ghi được.
4. **`ghi_chu` chưa bao giờ bị bỏ** — chỉ ô nhập bị gỡ 01/09. Nay nó là *"Thông tin trước sự kiện"*,
   đúng chỗ Lịch Google đặt *Thêm nội dung mô tả*.

**Quyền của khách — hai ô gác màn hình, một ô gác kho.** `khach_moi` và `khach_xem_ds` chỉ đổi thứ
app bày ra. `khach_sua` mở một đường GHI nên phải nằm trong policy. Và vì RLS theo DÒNG chứ không
theo CỘT, **một cò** giữ `rieng_tu` + `tao_boi` khỏi tay khách — không có cách nào nói "sửa được tên,
không sửa được cờ riêng tư" bằng một policy.

| Chạm | |
|---|---|
| SQL | **tệp mới `nang-cap-quyen-khach.sql`** — 3 cột `khach_*` · cò `chan_khach_sua_cot_cam` · nới `sua_lich` |
| JS — mới | `CO_QUYEN_KHACH` · `lcGioCong` · `lcPhutTu` · `lcDongBoPhut` · `lcVeNgayDen` · `lcVeOMau` · `lcMoHopMau` · `LC_QUYEN` + `lcVeQuyen` + `lcDatQuyen` |
| JS — sửa | khuôn `lcMoForm` (dựng lại trọn) · `lcDoiCaNgay` · `gioDat` (móc đồng bộ) · `lcChonMau` · `lcLuu` · `lcOptLoai` (bỏ đuôi giảng giải) |
| CSS | `.lc-ten-hang` `.lc-ten-to` `.lc-o-mau` `#lc-mau-hop` `.lc-tg` `.lc-toi` `.lc-suy` `.lc-muc` `.lc-gc` |
| Không chạm | **cửa GỘP** (`vcVeSuKien`) vẫn bố cục cũ — Tracy nói *"cửa sổ sự kiện"*, và cửa gộp còn chung khoang với việc |

🪤 **Vấp lại đúng cái bẫy đã ghi sổ HAI LẦN trong ngày:** dấu huyền ngược trong một chú thích HTML
nằm **trong chuỗi mẫu** — 12 cái, và cả `lcMoForm` chết theo. Biết luật vẫn không đủ. **Cách kiểm rẻ
nhất: sau khi sửa một khuôn, cắt đúng hàm ấy ra rồi `new Function` nó** (`node -e`, xem lệnh trong
`thu-cu-phap.js`) — nó bắt trong một giây.

🪤 **Và một bẫy của bài thử:** ba ca đỏ oan vì `SRC.indexOf('id="lc-lap"')` vớ phải bản của **cửa
gộp**, thứ nằm trước trong tệp. **Mốc tìm quá rộng thì nó không đo cái mình định đo, mà cái sai ấy
nhìn y như một lỗi thật.** Nay khoanh về đúng khuôn `lcMoForm`.

⏳ **Chờ Tracy:** chạy `nang-cap-quyen-khach.sql`. Chưa chạy mà mã đã lên thì cả khối ba ô tick không
bày ra, mọi thứ còn lại chạy đủ.

### Làn GLC — 04/09: cửa Sự kiện hở 14px giữa các khối

Tracy 04/09: *"cửa sổ sự kiện cho dãn khoảng cách các khối ra cho tôi đi sát nhau quá"*. Nó đang là
**9px**; luật 11 Mục 7 `CAU-TRUC-APP.md` nói *giữa hai khối* là **14px**. Lấy đúng con số app đã
đặt, không tự chế một số mới — cửa này đứng cạnh mọi cửa khác, và một cửa thở khác nhịp thì mắt
nhận ra ngay dù không gọi được tên.

**Sửa CẢ HAI lớp, và phải cả hai:** `.vc-rieng` (khoang sự kiện trong cửa gộp) dựng **đúng bộ ô** của
cửa Sự kiện — `vcVeSuKien` chép nguyên bộ, trừ tên · ngày · giờ đã lên khoang chung. Để lệch là cùng
một biểu mẫu thở hai nhịp tuỳ người ta vào bằng cửa nào.

Đã soi mắt bằng một trang thử dựng từ CSS thật, so ba mức 9 · 14 · 16px cạnh nhau rồi mới chọn.

| Chạm | Thử |
|---|---|
| CSS: `.lc-than` · `.vc-rieng`, cả hai `gap:9px` → `gap:14px` | `thu-loai-ca-nhan.js` — **108 ca**, thêm hai ca canh đúng con số này |

### Làn NCN — 04/09: nút Cá nhân mượn hình nút Sự kiện, và BỎ NÉT GẠCH

Tracy 04/09: *"nút cá nhân xấu thế, làm đồng bộ với nút sự kiện đi và đừng gạch"*.

🪤 **Tôi phạm một luật đã có trong sổ, và biết nó.** `CAU-TRUC-APP.md` Mục 7 **luật 10**: *việc xong
lùi màu, KHÔNG gạch*. Bản đầu hôm nay vẫn dùng `text-decoration:line-through` cho trạng thái tắt.
Biết luật không đủ để khỏi phạm — **nên từ nay để máy canh**: ca ⑩ của `thu-loai-ca-nhan.js` quét cả
tệp, không được còn một nét gạch chữ nào.

**Cách chữa: nút MANG LUÔN lớp `.lich-nut-lc` của nút Sự kiện.** Hình dạng vì thế không có bản thứ
hai để trôi lệch — luật riêng chỉ còn đúng hai dòng, cho phần THẬT SỰ khác: đang bày thì nút đeo
chính màu của thứ nó đang bày. Màu lấy qua lớp `m-tim` trên chính thẻ nút, cùng đường mọi khối màu
khác đi, nên một ngày đổi họ tím thì nút đổi theo — không gõ thẳng mã màu.

Hai nấc khác nhau ở **độ đậm nền**, không ở một dấu vẽ thêm lên chữ. Đã soi mắt bằng một trang thử
dựng từ CSS thật, cả nền tối lẫn nền sáng.

| Chạm | |
|---|---|
| CSS | `.lich-nut-rieng` — từ 3 luật xuống 2, bỏ `opacity` và `line-through` |
| HTML | thẻ nút nay mang `lich-nut-lc lich-nut-rieng m-tim` |
| Thử | `thu-loai-ca-nhan.js` — **106 ca**, thêm ca canh luật không-gạch cho toàn app |

### Làn MTH — 04/09: màu riêng cho thứ cá nhân, và nút tắt chúng đi (TRI-104)

Tracy 04/09, ba câu rời: *"sự kiện cá nhân thì đổi cho tôi thành màu tím đi"* · *"còn task thì màu
hồng"* · *"cho tôi thêm nút bật tắt cả lịch cá nhân nha ở trong cả bảng timeline ấy"*.

**KHÔNG cần chạy SQL.** Màu SUY RA lúc vẽ, không cất vào kho — nên mọi dòng đã khai từ trước tự đổi
màu theo, không cần một câu lấp nào.

**Cờ riêng tư THẮNG màu sơn tay.** Hai màu này là *tín hiệu*, không phải sở thích: nhìn một cái là
biết khối nào ngoài công việc, và cái biết ấy không hỏng vì một cú sơn nhầm. Đổi lại thì phải trả
giá cho đúng: dải chọn màu **khoá lại** khi món đang khai là cá nhân, thay bằng một câu nói ra luật
(*"Sự kiện cá nhân luôn màu tím."*). Bày một dải bấm vào không đổi được gì là nói dối — luật KHÔNG
GIỮ NGẦM.

**Nút tắt che CẢ HAI thứ.** Một buổi riêng đã đẻ ra việc của nó; giấu buổi mà để việc nằm lại là
giấu nửa vời — người ngồi cạnh vẫn đọc được tên nó trên dòng việc.

🪤 **Hai lối CỐ Ý không đi qua cái nút — đừng "dọn cho nhất quán".** Bản vẽ là `lcCuaNgayVe`, tách
khỏi `lcCuaNgay` chứ không nhét cờ vào trong nó:
- `lcDeVieckHomNay` gọi `lcCuaNgay` — cờ nằm trong đó thì **tắt lịch cá nhân là thôi đẻ việc** cho
  những buổi ấy. Một cái nút XEM đi đổi DỮ LIỆU, hỏng lặng lẽ và khó lần ra.
- `lcRanhTim` đi thẳng `lcCuaNgayTu` — **tắt hiển thị không làm mình rảnh hơn** trong mắt công cụ tìm
  giờ. Khớp đúng điều Tracy chốt cùng ngày ở làn MSK.

Ba ca thử canh đúng hai ranh giới này.

| Chạm | |
|---|---|
| JS — mới | `mauSuKien` · `mauViec` · `TL_HIEN_RIENG` + `tlBatRieng` (nhớ qua localStorage, theo MÁY) · `lcCuaNgayVe` · `loaiOLa` · tham số `khoa` của `veDaiMau` |
| JS — sửa | 3 phễu sự kiện · 1 phễu việc timeline · 5 chỗ vẽ đọc thẳng `t.mau` · 3 nấc vẽ · bộ lọc `tasks` trong `veTimeline` · `lcDeViec` (`dong.mau`) · `lcDoiLoai` · ba lượt gọi dải màu · `tv-od` nhận `onchange` |
| CSS | `.lich-nut-rieng` — **trạng thái TẮT mới là trạng thái đeo màu**, vì tắt rồi quên mới là cái hỏng |
| Thử | `thu-loai-ca-nhan.js` **103 ca** · vá cốc 5 bài khác |

🪤 **Năm bài thử ngã cùng lúc, và bốn cái ngã vì cùng một lẽ:** khối cắt ra từ app nay gọi
`mauSuKien`/`mauViec`, mà cốc của chúng không có. Cái thứ năm ngã vì mốc cắt là **nguyên văn chữ ký
`veDaiMau`**, và tôi vừa thêm một tham số. **Đổi chữ ký một hàm thì `grep` tên nó trong `thu-*.js`
trước khi đóng làn** — mốc cắt theo chữ ký là loại mốc gãy lặng lẽ nhất. Và lúc vá cốc tôi lại vấp
đúng cái bẫy đã ghi ở làn CNH: một dấu huyền ngược trong câu chú thích tiếng Việt viết vào khối
`COC` là đóng chuỗi mẫu ngay giữa câu.

### Làn MSK — 04/09: sự kiện cá nhân MỜI ĐƯỢC NGƯỜI (TRI-103)

Tracy 04/09: *"mặc dù là sự kiện cá nhân nhưng mà cho nút mời người nữa đi"*.

**Một khái niệm đổi nghĩa trong ngày — chép lại vì nó giải thích mọi thứ khác.** Sáng nay "cá nhân"
được dựng thành **chỉ mình tôi**, và policy `doc_lich` viết đúng theo nghĩa ấy. Chiều Tracy đổi:
"cá nhân" nghĩa là **NGOÀI CÔNG VIỆC**, không phải **MỘT MÌNH**. Một buổi tennis, một bữa với người
nhà, một cái hẹn khám — đều không nên tính vào bảng của team, mà vẫn có người thứ hai trong đó.
Từ nay: *không góp số vào bảng nào của team* · *chỉ người trong cuộc nhìn thấy*, và danh sách người
trong cuộc dài hơn một.

⚠️ **Đây là một cú NỚI QUYỀN, không phải một cú dọn dẹp.** Mời một người là cho họ đọc dòng ấy —
không có cách nào vừa mời vừa giấu. Phiên sau đọc `doc_lich` đừng tưởng nó bị lỏng do sơ ý.

| Chạm | |
|---|---|
| SQL | **tệp mới `nang-cap-moi-vao-su-kien-ca-nhan.sql`** — nới ĐÚNG MỘT VẾ của `doc_lich`: `nguoi_id_dang_nhap() = any(nguoi_ids)` |
| JS | `lcVeMoi` (hàng mời nay chỉ ẩn ở cảnh "Cả công ty") · `lcLuu` (`nguoi_ids` = chính chủ + khách mời, `Set` dọn trùng) · `lcNhanPhamVi` (gỡ nhánh riêng) · `lcNhanLoai` (buổi đọc là *Cá nhân*, không phải *Việc cá nhân*) |
| Sổ | `SO-SQL.sql` · `thu-loai-ca-nhan.js` — **87 ca đạt** |
| Không chạm | `doc_task` · `doc_deepwork` — việc và phiên là của TỪNG NGƯỜI. Mời ai vào một buổi không phải là cho họ đọc việc riêng của mình; gộp hai chuyện ấy là nới nhầm chỗ |

✅ **Tracy trả lời ngay trong ngày — KHÔNG dựng khung nhìn "Bận".** Nguyên văn: *"ksao đâu lịch cá
nhân thì vẫn f ưu tiên lịch công việc"*. Nên hành vi hiện tại **đã đúng, không phải sửa gì**, và nó
đúng ở cả hai chiều mà không cần một dòng mã nào thêm:

- **Với người khác:** buổi cá nhân của tôi không về tay họ, nên nó không làm hẹp khung giờ chung.
  Người đi xếp lịch công việc thấy tôi rảnh, và đó chính là *"lịch công việc được ưu tiên"*.
- **Với chính tôi:** `lcRanhTim` quét trên `d.ds` — tập buổi máy chủ trả về cho TÔI — nên buổi cá
  nhân của tôi vẫn nằm trong danh sách bận của chính tôi. Không có chuyện app gợi ý cho tôi đúng cái
  giờ tôi đang đánh tennis.

Cùng một cơ chế RLS phục vụ cả hai câu trả lời, vì "ai đọc được dòng nào" đã là câu hỏi đúng ngay
từ đầu. **Đừng dựng khung nhìn giờ-bận cho việc này nữa** — nó sẽ đảo ngược một quyết định đã chốt.

### Làn LSK — 04/09: TRƯỜNG "LOẠI SỰ KIỆN", và lời sửa cho một chỗ làm ẩu (TRI-102)

Tracy 04/09: *"bổ sung thêm ở cửa sổ sự kiện 1 trường thông tin là sự kiện này thuộc loại nào (y như
task ý)"* — chọn **phương án B**: ô Loại bày đúng bộ dòng như ô của việc, tức có cả danh sách cam kết.

🪤 **Cái sai được sửa ở đây, và nó là loại sai dễ lặp.** Hôm trước tôi nhét dòng *"Cá nhân"* vào bảng
`LC_NHOM` để làm nhanh — mà bảng ấy trả lời câu **AI NHẬN**. *"Loại gì"* là câu khác. Nó đá ngay
trong ngày: dòng thứ tám phải mang theo một ràng buộc mà bảy dòng kia không có (không mời được ai),
tức nó **chưa bao giờ thật sự cùng loài** với chúng — dấu hiệu đã ở ngay đó mà tôi bỏ qua.
**Luật rút ra: một dòng phải mang ràng buộc riêng để sống chung với các dòng còn lại thì nó không
thuộc danh sách ấy.** Nay `LC_NHOM` về đúng bảy dòng, và ô Loại lo phần còn lại.

**Một phân biệt CÓ CHỦ Ý ở tầng kho — đừng "dọn cho nhất quán".** Hai cột cùng chảy từ sự kiện xuống
việc của nó, theo hai luật khác nhau: `rieng_tu` **đồng bộ mãi** (nó là một *lời hứa* về quyền riêng
tư — một cột hứa mà trôi lệch được thì nó không còn là lời hứa), còn `tieu_diem_ma` **thừa hưởng lúc
ra đời rồi thôi** (nó là một *mặc định* — người ta được phép kéo riêng một việc sang cam kết khác, và
một cò đồng bộ sẽ giật nó về mà không hỏi).

| Chạm | |
|---|---|
| SQL | **tệp mới `nang-cap-loai-su-kien.sql`** — cột `lich_chung.tieu_diem_ma` (`on delete set null`) · ràng buộc `lich_ca_nhan_khong_cam_ket` · cò `cham_theo_su_kien_cha` **thay** `cham_rieng_tu_viec_cua_buoi` (nay mang hai cột) · câu lấp |
| JS — mới | `CO_LOAI_SK` · `lcOptLoai` · `lcLoaiCua` · `lcLoaiDangKhai` · `lcDoiLoai` · `lcNhanLoai` · CSS `.lcb-loai` |
| JS — sửa | `LC_NHOM` (gỡ dòng thứ tám) · `lcOptNhom` (về bản đơn giản) · `lcNhomCuaLich` (gỡ vế cờ) · `lcVeMoi` · `lcLuu` · hai chỗ dựng form · `lcMoBuoi` |
| Sổ | `SO-SQL.sql` (một dòng dò, hai nấc) · `thu-loai-ca-nhan.js` — **75 ca đạt** |
| Không chạm | `lcDeViec` — cò máy chủ điền `tieu_diem_ma` lúc chèn, app không phải nhớ |

⏳ **Chờ Tracy:** chạy `nang-cap-loai-su-kien.sql` (đã dán khối vào chat). Chưa chạy mà đẩy mã lên thì
ô Loại vẫn hiện, các dòng cam kết mờ đi kèm tên tệp — không hỏng gì.

### Làn GRC — 04/09: gập sẵn khối giờ rảnh, và dòng Cá nhân THÔI biến mất

Hai thứ Tracy báo ngay sau khi làn CNH lên sóng.

**① Khối *Giờ cả N người cùng rảnh* gập sẵn.** Một khoá `'lc-ranh-o': true` trong `THE_THU`. Nó là
thứ để TRA khi đang phân vân giờ, không phải thứ phải đọc mỗi lần khai — mở sẵn thì nó đẩy ô giờ, ô
lặp và ô ngày xuống dưới mép màn, tức đẩy chính những ô người ta mở cửa ra để điền.

**② Dòng "Cá nhân" TẮT chứ không GIẤU — bài học đáng giữ.** Bản đầu cho dòng ấy biến mất khi
`CO_RIENG_TU` false, đi theo lối `CO_LOAI_VIEC` đã đi. Tracy mở cửa sự kiện ra và không thấy nó, mà
**không có gì trên màn nói vì sao** — trong khi cùng lúc có ba nguyên nhân đều xảy ra được: máy chủ
chưa chạy tệp · trình duyệt còn giữ bản cũ · mã viết hỏng. Đã dò ra là nguyên nhân thứ hai (bản đang
chạy giống hệt `origin/main`, ba cột đã có trên máy chủ, không service worker), nhưng **phải dò mới
biết** — và đó chính là chỗ hỏng. Nay dòng ấy ở lại, mờ đi, kèm tên tệp cần chạy: đúng lối
`CO_CHOT_LICH` đã chọn. **Luật rút ra: một lựa chọn bị gác thì TẮT nó và nói lý do, đừng gỡ nó khỏi
danh sách — dòng vắng mặt không tự chẩn đoán được.**

| Chạm | |
|---|---|
| JS | `THE_THU` (thêm một khoá) · `lcNhomBay` → **`lcOptNhom`** (dựng cả chuỗi option, một hàm cho hai cửa) · `optCamKet` |
| Thử | `thu-loai-ca-nhan.js` — **54 ca đạt** |

### Làn CNH — 04/09: LOẠI CÁ NHÂN cho việc và sự kiện (TRI-100)

Tracy 04/09, duyệt phương án A: *"loại việc và sự kiện… không được tính vào dashboard của ROVA và
giữ riêng tư cho mọi người"* — khoá thật ở tầng quyền máy chủ, không che ở màn hình. Ba mặc định
Tracy để nguyên: sự kiện cá nhân **biến mất hẳn** khỏi lịch người khác (không hiện cả chữ *Bận*) ·
việc cá nhân **vẫn** tính giờ và vẫn mọc cây trong vườn của chính chủ · **mọi thành viên** dùng được.

| Chạm những chỗ này | |
|---|---|
| SQL | **tệp mới `nang-cap-loai-ca-nhan.sql`** — 3 cột `rieng_tu` · 3 chính sách đọc (`doc_task` · `doc_lich` · `doc_deepwork`) · 2 policy bảng con soi ngược dòng cha · 4 cò giữ cờ · 3 khung nhìn của bảng đội lọc thêm |
| JS — việc | `O_CA_NHAN` (mới) · `TEN_LOAI` · `HINH_LOAI` · `loaiCua` · `loaiCuaMa` (mới) · `khoaNhom` · `giaTriO` · `manhLoai` · `optCamKet` · `veChipCK` |
| JS — sự kiện | `LC_NHOM` (dòng thứ tám) · `lcNhomBay` (mới) · `lcNhomCuaLich` · `lcNhanPhamVi` · `lcVeMoi` · `lcLuu` |
| JS — khởi động | `CO_RIENG_TU` + một câu dò trong `doCotGio` · `COT_TASK` |
| Sổ | `SO-SQL.sql` (một dòng dò, hai nấc) · `thu-loai-phien.js` (cốc thiếu cờ mới) · **`thu-loai-ca-nhan.js` mới — 47 ca** |
| Không chạm | `pham_vi='ca_nhan'` sẵn có (nghĩa là *Mời người cụ thể*, khác hẳn) · `vuon_cay` · `gio_deepwork_theo_ngay` · `dem_task_theo_o` · `tien_do_o` — bốn khung nhìn ấy app chỉ đọc bằng `.eq('nguoi_id', ME.id)`, tức màn của riêng mình |

🪤 **Bẫy đã né, ghi lại vì nó sẽ tái diễn.** Hai dòng cuối `LC_NHOM` cùng `pham_vi:'ca_nhan'`, nên
vòng tìm trong `lcNhomCuaLich` **luôn dừng ở dòng đầu**. Thiếu vế cờ đứng trước vòng ấy thì mở SỬA
một sự kiện cá nhân ra sẽ thấy ô chọn nhảy về *Mời người cụ thể*, và bấm Lưu là **gỡ mất cờ riêng
tư** — không lỗi nào báo. Cùng hình dạng ấy ở `loaiCua`/`khoaNhom`/`giaTriO` bên việc: hỏi
`loai_viec` trước thì việc cá nhân rơi hết về *phát sinh*.

🪤 **Và một bẫy của chính bài thử:** khối `COC` trong `thu-*.js` là một **chuỗi mẫu**, nên một dấu
huyền ngược trong câu chú thích tiếng Việt viết thêm vào đó là đóng chuỗi ngay giữa câu — bài thử
ngã ở `SyntaxError` chứ không ngã ở một ca sai.

🪤 **Bẫy thứ ba, vấp thật lúc giao bài — thứ tự hai khối cuối một tệp SQL.** Trình soạn SQL của
Supabase chỉ bày kết quả của câu lệnh **CUỐI CÙNG**. Tệp xếp *tự kiểm* rồi mới tới *số liệu tham
khảo*, nên thứ Tracy nhìn thấy sau khi chạy là ba con số 0 — đúng nhưng không nói được gì — còn mười
dòng đạt/chưa đạt thì khuất, phải chạy lại một lượt nữa. **Câu quan trọng nhất phải đứng cuối.** Đã
đảo lại trong `nang-cap-loai-ca-nhan.sql` và ghi thành một dòng luật trong `DOC-TRUOC.md`; thêm
`order by dat, so` để dòng chưa đạt nổi lên đầu bảng.

✅ **04/09 — Tracy đã chạy SQL trên máy chủ thật, bộ tự kiểm 10 dòng đúng hết.** Làn gộp lên `main`
cùng ngày.

## ⏳ Còn treo — việc chưa dứt điểm dù làn đã đóng

Gom từ 44 làn trước khi chúng sang lưu trữ. **Không có việc nào chặn phiên mới sửa mã** — đây là
việc cần Tracy, hoặc việc cố ý để lại cho phiên sau.

| Cần ai | Việc | Từ làn |
|---|---|---|
| **Tracy** | **Thử tay chế độ Lịch trình trên máy thật.** Máy dựng không đăng nhập Google được nên bảng mới chỉ soi tới mức HTML sinh ra (28/28 ca xanh) và một bản mẫu tĩnh. Ba thứ đáng nhìn trước: chạm một buổi có mở đúng cửa buổi ấy không · cuộn ngang trên điện thoại có giữ được cột tên không · hẹn 1-1 của hai người khác có đúng là chỉ hiện chữ *Bận* không | TD |
| **Tracy** | **Thử tay hai nấc *Dự kiến · Đã chốt* trên máy thật.** SQL đã chạy 03/09 (**16 chốt · 0 dự kiến**, đúng câu tự kiểm ③). Ba thứ đáng nhìn: đặt một sự kiện sang *Dự kiến* rồi soi nét đứt ở cả ba nấc lịch · sự kiện dự kiến của hôm nay có đúng là **không** đẻ việc vào danh sách không · và **khối phiên deep work nay không còn nét viền nào** — nó chỉ còn họ màu lơ để tự nhận diện, có còn đọc ra ngay là *giờ đã chạy* không. Thêm hai thứ chốt sau đó cùng ngày: một sự kiện **chưa ai trả lời mà còn dự kiến** chỉ được đeo MỘT viền (nét đứt), và một buổi **đã dự xong** thì thôi nét đứt, chuỗi tự lên *đã chốt* | DK · ND2 · XD |
| **Tác tử** | 🧹 **Dọn bộ thử — 10/30 bài đang đỏ trên `main`, và không bài nào là lỗi app.** Đo 03/09, bốn lẽ khác nhau: ② bài chết lúc nạp vì khối cắt ra đụng `document` (`thu-keo-doi-khoi`, `thu-man-don`) · ③ bài chết vì khối cắt ra gọi sang hàm ngoài khối chưa có bản giả (`duViecCuaMoc` ở `thu-cua-gieo-vuon-day`; `daTre` ở `thu-mang-deepwork` và `thu-tuan-o-ngay`) · ③ bài **không tìm thấy mốc cắt** vì mã đã đổi (`thu-gieo-cam-ket`, `thu-keo-mep-va-o-den`, `thu-luong-nghen`) — loại này chết LẶNG đúng lúc cần nhất · ② bài chấm theo luật CŨ đã bị Tracy đổi: `thu-hang-chua-xep-gio` đòi nút ghi *"Sắp xếp việc"* trong khi nút đã đổi tên thành *"Kho việc"*, và `thu-thong-bao-buoi` đòi nút Lưu xám-rồi-sáng trong khi Tracy bỏ luật ấy 02/09 (nay nút luôn bấm được, nhãn đổi `Lưu`↔`Đóng`). ⚠️ Trong bài cuối, ca ĐỨNG TRƯỚC ca đỏ lại XANH vì nút giả mặc định `disabled=true` chứ không vì app làm gì — một ca xanh không kiểm gì cả, nên đừng tin con số "bao nhiêu ca đạt" trước khi dọn | CGV |
| **Tracy** | **Thử tay kéo một sự kiện trên máy thật.** Máy dựng không đăng nhập Google được nên đường GHI chưa chạy lần nào với dữ liệu thật — phần đã soi tới mức DOM: tay nắm mọc đúng người, kéo thì nhãn giờ chạy theo, thả thì hộp hỏi phạm vi bật ra, và gói gửi lên đã soi từng trường bằng một `sb` giả. Ba thứ đáng nhìn trước: dời một buổi rồi mở lại cửa buổi xem nó nói *đã dời riêng buổi này* chưa · buổi dời sang tuần khác có còn hiện không · ô tick và cú chạm mở cửa có bị cú kéo nuốt mất không | KS |
| phiên sau | **Ba bài thử đỏ SẴN từ trước, không phải do làn nào vừa rồi** (đã đối chiếu với bản trên `main` cũ): `thu-keo-doi-khoi.js` ngã ở *document is not defined* · `thu-keo-mep-va-o-den.js` tìm `function gioNan(` không còn trong mã · `thu-thong-bao-buoi.js` ngã ở *nutLuuGhiChu is not defined*. Một bài thử đỏ lâu ngày thì người ta thôi nhìn nó, và lúc ấy nó không còn canh gì nữa | KS |
| phiên sau | ⚠️ **Kho ĐANG có việc sơn màu `do`** — làn MB báo lại từ lần Tracy chạy tệp vá trên máy chủ thật chiều 01/09. Đỏ đã rút khỏi bảng chọn, nhưng ai siết ràng buộc `task_mau_hop_le` xuống đúng bảng chọn thì `add constraint` NGÃ NGAY và chính việc ấy hết sửa được. Danh sách phải giữ đủ **mười** tên: tám tên từng mời chọn cộng `do` · `xam` | MB · ba việc lẻ 01/09 |
| — | ✅ **DÒ LẠI 03/09 — không tệp `.sql` nào còn phải chạy.** Lần này dò **từ xa** qua API REST bằng khoá công khai của chính app (chỉ đọc, cùng cách `doCotGio()` tự dò mỗi lần mở app), đối chiếu cả 51 dấu vết khối ① lẫn 5 tệp sinh trong ngày. **Ba mục ⏭ trong bảng này hoá ra đã trả từ lâu** — `doi-buoi-rieng` · `thong-bao-buoi` (sổ ghi còn nợ từ 02/09) và `lich-dieu-hanh` (Tracy chạy chiều 03/09) — nên đã gỡ khỏi bảng. Hai chỗ máy dò cũ nói sai đã vá cùng lượt: một dấu vết bị tệp sau GỠ MẤT (`nang-cap-doc-ghi-chu` → xuống khối ② hỏi theo chuỗi), và hai con số đếm tệp trong tiêu đề đã lệch (bỏ hẳn, vì một cái sổ chép tay nhét giữa một cái máy dò thì rữa). Thêm ba câu hỏi mới vào khối ②: realtime lịch · thứ tự cặp tệp đè nhau · chuỗi doc-ghi-chu. **Tracy chạy ba câu ấy ngay chiều 03/09 — cả ba ✅:** realtime đã kê đủ bốn bảng · ràng buộc `ngoaile_doi_du_tham_so` là **bản mới, đúng thứ tự** (tức không ai chạy `doi-buoi-rieng` sau `su-kien-nhieu-ngay`) · chuỗi `doc-ghi-chu` → `doc-rieng-tu` đã chạy đủ. Cộng dòng `cho_ban.pic_moi` vẫn ✅ CÒN. Nên tính tới cuối 03/09 máy chủ **sạch hoàn toàn**, chỉ trừ tệp `nghi-thuc-hoan-tat` nói ở dưới. ⚠️ **Còn một tệp CHƯA chạy thật: `nang-cap-nghi-thuc-hoan-tat.sql`** (cột `nop_ngay.moi_mai` + policy `sua_nop_cua_minh`) — đã soi mã: app không đọc cột ấy ở đâu và cũng không có đường nào `update` `nop_ngay`, nên không có gì đang hỏng; nó dọn đường cho một tính năng chưa dựng | SQ |
| **Tracy** | **Thử nấc Tuần mới trên điện thoại thật.** Mã đã lên sóng nhưng chưa ai bấm nó trên máy thật — máy dựng không đăng nhập Google được nên chỉ soi tới mức DOM. Ba thứ đáng nhìn trước: ô tick trên nền chip tối có nặng mắt không · tên việc cắt ở đâu có đủ nhận ra việc không · chạm đầu ô có sang nấc Ngày đúng ngày không | TW |
| **Tracy** | **Ô thêm việc tràn ngang ở cửa sổ hẹp — sửa hay để đó?** (hỏi 30/08, lần 1, chưa trả lời). `#them-nd` trong `.hang2` giữ bề ngang cứng 395,8px nên đẩy màn Hôm nay tràn khỏi khung: 28px ở bề ngang 844px (điện thoại xoay ngang), 4px ở 900px. Sổ đã ghi cùng triệu chứng ở làn MU với số 42px tại 760px. Không thuộc làn nào đang mở nên chưa ai đụng | GP · MU |
| **Tracy** | **Thử tay luồng trao PIC trên máy thật**, sau khi chạy SQL: trao cho một người → họ thấy dòng ở khối *Chờ bạn* → nhận vai → nhìn lại khối Thành viên xem PIC cũ ở lại hay rời đúng như đã khai. Máy dựng không phục vụ được file nên làn TP chưa soi được tới mức DOM | TP |
| **Tracy** | **Năm câu chốt cho đợt 2–5 lưới giờ**: khung giờ cố định hay co giãn · kho việc đi đâu · màu theo phân loại · đè khối hay chia làn · số tuần | AL |
| **Tracy** | **Bốn mục giao diện cố ý hoãn, chờ nhìn bản thật**: nền `rgba(74,158,255,.14)` chép tay · bộ `--rv-*` biểu đồ ROVA · `--duong` ở mũ đầu màn · sàn cây. *(Thang lưới nhiệt `--b0..--b5` hai bản — Tracy duyệt 29/08: sáu bậc tách bạch, giữ nguyên.)* | X |
| **Tracy** | **Đường GHI xuống máy chủ chưa thử lần nào với dữ liệu thật** — máy dựng không đăng nhập Google được, nên mọi làn chạm ghi mới chỉ soi tới mức DOM | CM · CK · TV · AI · AD · AA |
| **Tracy** | **Cam kết của ĐỒNG ĐỘI đã xếp mốc ở dự án khác thì chưa cửa nào với tới** — cửa ngược `ckDuAnGhi` khoá `.eq('nguoi_id', ME.id)`, cửa xuôi thôi bày nó theo luật một-cam-kết-một-mốc. Gặp thật thì vá một dòng: cho `DU_CHON_DS` bày lại cam kết có `moc_id` mà `muc_tieu_id !== duA` | KT |
| phiên sau | **Phương án B của làn GC**: gỡ bốn hàm bất động `tlkDat` · `tlkTraVeKho` · `tlkSangOngay` · `tlkKeoOngayVaoTam`. Chạm cơ chế cầm việc mà hai bài thử hiện có không phủ | GC |
| phiên sau | **Ô tên thẻ cam kết cân bằng bằng CSS `subgrid`** (phương án B, đổi lại là không mất chữ) | OC |


## 🗄 Làn đã đóng — chỉ mục

**Đã dời sang `luu-tru/CHI-MUC-LAN.md`** (01/09). Bảng ấy phình tới 54 KB, mà nó chỉ cần thiết
khi có người đi tra một làn cũ — trong khi file này bị đọc ở **mọi lượt của mọi phiên** chạm app.
Đó đúng là lý lẽ mục này vẫn viết cho các làn đã đóng, nay áp lên chính nó (CLAUDE.md Mục 2f).

Tra một làn cũ: `grep -n "^| MB" luu-tru/CHI-MUC-LAN.md`, hoặc `grep` thẳng tên hàm.
Toàn văn: `luu-tru/DANG-LAM-luu-tru.md`.
