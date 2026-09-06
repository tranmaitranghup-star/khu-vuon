# Đặc tả — lớp VẤN ĐỀ LIÊN PHÒNG BAN

> **Thuộc Đợt 2** của mảng ghi chú, gộp vào theo quyết định Tracy 05/09/2026. Luật vận hành đi kèm (thứ đội phải theo, không phụ thuộc công cụ) nằm ở `wiki/cong-ty/rova/van-de-lien-phong.md` — **đọc file đó trước**, file này chỉ lo phần máy.
>
> Nền nghiên cứu: `nghien-cuu-app-ghi-chu.md` (mục 4.4 ép cấu trúc · 5.5 ý định thực thi · 4.6 quyền đọc).
> Việc trên Linear: bốn nhát `TRI-111` → `TRI-114`, cộng `TRI-26` bảng con trỏ khách *(đã đổi phạm vi 05/09)*. Hai việc `TRI-27` quyền theo phòng ban và `TRI-28` bước kế tiếp **không còn chặn** lớp này — xem mục 6.

---

## 1. Nguyên tắc — dùng lại, không dựng song song

Ba thứ đã đặt hàng ở Đợt 2 gánh luôn lớp này, **không sinh bảng thứ hai làm cùng việc**:

| Thứ đã có trong Đợt 2 | Lớp vấn đề dùng nó làm gì |
|---|---|
| `khach_con_tro` (`TRI-26` **đổi phạm vi**, khoá số điện thoại `84xxx`) | dây neo khi vấn đề gắn một khách có tên — **con trỏ, không phải bảng khách** |
| `buoc_ke_tiep` (`TRI-28`) | **việc sinh ra sau khi chốt** — không dựng bảng việc riêng |
| Hàm quyền theo phòng ban (`TRI-27`) | lọc vấn đề có gắn khách |
| Khung nhìn `cho_ban` + khối **Chờ bạn** *(đã chạy)* | gom luôn vấn đề trỏ tên mình, cạnh năm loại đang chờ khác — thêm một nhánh `union all`, không dựng bảng |

⚠️ **Luật cứng chép lại từ `TRI-31`:** không dựng chỗ ghi nếu chưa dựng chỗ đọc. Bảng vấn đề chung phải lên **cùng một đợt** với bảng dữ liệu, không để đợt sau.

---

## 2. Bảng `van_de`

| Cột | Kiểu | Nghĩa |
|---|---|---|
| `id` | bigint identity | |
| `tieu_de` | text not null | một dòng, nói thẳng việc |
| `mo_ta` | text | |
| `nguoi_neu_id` | uuid → `nguoi` | người nêu |
| `chuc_nang_neu` | smallint → `chuc_nang` | phòng nêu, máy tự điền theo người nêu |
| `chuc_nang_nhan` | smallint → `chuc_nang` | phòng cần gỡ |
| `nguoi_nhan_id` | uuid → `nguoi` | **người nhận có tên** — luật chuyển giao điều 1 |
| `khach_sdt` | text | số điện thoại chuẩn hoá `84xxx`, **con trỏ sang CRM**, không phải khoá ngoại. Trống nếu vấn đề không gắn khách |
| `la_ca` | boolean default false | ⚠️ **nợ có ngày trả** — bật khi đây là ca của một khách, đang tạm ở app ① vì CRM chưa có chỗ chứa |
| `muc` | smallint default 2 | 1 nghiêm trọng · 2 vừa · 3 nhẹ. Chữ trên màn: chỉ mức 1 bày nhãn **Nghiêm trọng**, mức 2 và 3 không bày gì (Tracy đổi chữ 05/09) |
| `trang_thai` | text default `'moi'` | xem mục 3 |
| `han_tra_loi` | timestamptz | máy điền `tao_luc + 24h`, không cho người sửa |
| `nhan_luc` | timestamptz | lúc bấm **Nhận** |
| `dong_luc` · `nguoi_dong_id` | | chỉ điền được khi `nguoi_dong_id = nguoi_neu_id` |
| `loai_lap` | text | nhãn gom các ca cùng loại — nuôi luật lặp ba lần |
| `tao_luc` | timestamptz default now() | |

Bảng thứ hai `van_de_binh_luan` (`van_de_id` · `nguoi_id` · `noi_dung` · `tao_luc`) — mạch bàn luận, để hai phòng nói chuyện ngay tại chỗ thay vì trong Zalo.

⚠️ **Sửa 05/09 sau khi đối chiếu bản kiến trúc bốn app ngày 23/08.** Bản đầu của đặc tả này cho `khach_sdt` trỏ vào một bảng khách sống trong app Khu Vườn, trái dòng chặn *"dữ liệu thô của khách không sang app ① và ②"*. Khách thuộc kho CRM; app ① chỉ giữ **số điện thoại chuẩn hoá, tên hiển thị và link** — bản nhớ đệm chỉ đọc. Bản bao: `production/du-an/kien-truc-quan-tri-van-de-rova.md`.

**Ca của một khách so với vấn đề của hệ thống.** Ranh giới hỏi bằng một câu: *đóng xong việc này thì ai được lợi — một khách, hay mọi khách sau này?* Một khách thì là **ca**, chỗ đúng của nó là CRM. Trong lúc CRM chưa có chỗ, ca nằm tạm ở bảng này với `la_ca = true`, và chuyển sang khi CRM sẵn sàng.

---

## 3. Sáu trạng thái

`moi` → `da_nhan` → `dang_xu_ly` → `xong` · rẽ ngang `cho_ben_khac` · lối ra `khong_lam`

| Trạng thái | Ai chuyển | Ghi chú |
|---|---|---|
| `moi` | máy, lúc tạo | đồng hồ 24 giờ bắt đầu chạy |
| `da_nhan` | người nhận | bấm **Nhận** → điền `nhan_luc`, đồng hồ dừng |
| `dang_xu_ly` | người nhận | |
| `cho_ben_khac` | người nhận | phải nêu chờ ai — nếu chờ phòng thứ ba thì mở vấn đề mới, nối quan hệ |
| `xong` | **chỉ người nêu** | người xử lý báo xong, người nêu xác nhận mới đóng |
| `khong_lam` | chỉ người nêu, hoặc CEO | |

---

## 4. Bốn màn hình

⚠️ **Chỗ đứng — Tracy chốt 05/09:** *"mình có kênh thông báo ấy, các vấn đề và thông báo đều đưa lên kênh đó đi"*. Vấn đề **không** có nút riêng trên thanh lề; nó về chung cửa với bảng tin, tức màn sau **nút loa**, chia làm **hai nấc viên thuốc**: *Vấn đề* · *Thông báo*.

Hai điều đi kèm quyết định ấy, đều là chỗ dễ làm sai:

- **Hai bảng, một cửa.** Vấn đề không nhập chung bảng `ban_tin`. Ngày 04/09 Tracy chốt ba luật cho bảng tin, và vấn đề ngược cả ba: *chỉ lead được đăng* ↔ ai cũng nêu được · *tin chỉ đưa tin, không sinh việc và không chấm ai đã làm* ↔ vấn đề có người nhận đích danh, có trạng thái, có đồng hồ · *tag phòng ban là nhãn nhận diện* ↔ `chuc_nang_nhan` là đích chuyển giao. Gộp bảng là gỡ chính ba luật ấy.
- **Hai nấc, không xếp chồng.** Bảng tin đã phải rời màn Hôm nay ngày 04/09 vì *"nhiều thông báo thì nó choán hết"*. Đặt vấn đề nằm trên bảng tin trong cùng một trang cuộn là dựng lại đúng bệnh ấy ở chỗ mới.
- **Chấm trên nút loa** nay suy từ hai nguồn: có tin đăng trong 24 giờ, **hoặc** có vấn đề chưa ai nhận đã quá hạn. Vẫn suy thẳng từ dấu thời gian nên app không phải nhớ ai đã xem gì.

Bản mẫu: `mau-van-de.html` · cửa chi tiết: `mau-van-de-chi-tiet.html`.

**① Bảng vấn đề chung** — chữ *"mọi người đều theo dõi được"* của Tracy nằm ở đây.
- Ai trong đội cũng mở được. Lọc theo phòng nêu · phòng nhận · trạng thái · mức.
- Thứ tự mặc định: **quá hạn nhận lên đầu**, rồi tới mức nghiêm trọng, rồi tới mới nhất.
- ⭐ **Hình bảng việc, không phải hình feed** *(làn VDL, 05/09 — Tracy chọn phương án A sau khi so kề ba bản trong `mau-van-de-linear.html`)*. Một vấn đề đúng **một hàng 40px**: vạch mức · vòng trạng thái · mã `VD-31` · tiêu đề một dòng · chip phòng nhận (đổi thành đồng hồ khi sát hạn hoặc quá hạn) · vòng chữ cái người nhận. Danh sách **gom theo nhóm trạng thái**, mỗi nhóm một đầu mục mang số đếm: *Quá hạn nhận · Mới · Đang xử lý · Chờ bên khác*, và khi xem việc đã đóng thì *Đã xong · Không làm*. Đo trên khung 640px: bản cũ lọt 2 việc, bản này lọt 7. Bốn thứ phải BỚT đi để có hình ấy — mô tả, ai nêu, số lượt bàn, và cả hàng nút — tất cả rời xuống cửa chi tiết.
- **Mức 1 nói bằng ba vạch đỏ 13px**, thôi đeo viên chữ *Nghiêm trọng*. Ô vạch giữ chỗ ở mọi dòng để lưới thẳng hàng, nhưng mức vừa và nhẹ không vẽ gì. **Trạng thái nói bằng vòng tròn**: rỗng xám là mới · nửa vàng là đang xử lý · viền nét đứt là chờ bên khác · đầy xanh là xong. Không dùng dấu ✓ hay ✕ (luật Tracy 04/09). **Chưa giao đích danh thì không vẽ vòng chữ cái** — một vòng rỗng đọc ra như một nút bị thiếu.
- ⚠️ Vấn đề có `khach_sdt` thì lọc qua hàm quyền `TRI-27` (sale thấy khách mình · CSKH thấy khách đã mua · BOD thấy hết). Vấn đề không gắn khách thì cả đội thấy — *đây là mặc định tôi đặt, Tracy gạch lại nếu muốn chặt hơn.*

**② Cửa *Ghi vấn đề*** — ba ô bắt buộc: tiêu đề · phòng nhận · người nhận. Mô tả, mức và khách nằm sau một dòng bấm mở, để người đang bực không phải đi qua sáu ô mới nói được điều mình muốn nói. Mức và mô tả để trống được. Gắn khách bằng ô tìm theo số điện thoại của `TRI-26`.

**③ Cửa chi tiết một vấn đề** *(làn VD4, 05/09)* — ruột **thứ ba** của cùng khung `#vd-cua`, cạnh cửa *Ghi vấn đề* và cửa *Giao cho ai*. Đây là chỗ chứa yêu cầu gốc thứ hai của Tracy — **bàn luận** — và cũng là chỗ ba nấc `dang_xu_ly` · `cho_ben_khac` · `khong_lam` được đặt. Chúng KHÔNG thuộc về một dòng trong danh sách — ba nấc ấy chỉ có nghĩa khi người bấm vừa đọc chuyện gì đang diễn ra. *(Sửa 05/09, làn VDL: từ khi danh sách sang hình bảng việc thì **cả** *Nhận* và *Đóng* cũng về đây, dòng không mang nút nào. Kéo theo đó, **cửa *Giao cho ai* mất glyph ⇢ trong dòng nên cũng về cửa này** — nó dựng ở tầng vẽ chứ không nhét vào `vdNutNac`, vì hàng ấy là hàng đổi TRẠNG THÁI còn giao lại là mở một cửa khác; trộn hai thứ vào một danh sách làm hỏng nghĩa của cả hai và phá tám ca thử.)*

- Bố cục: hàng viên (phòng nêu → phòng nhận · mức · khách) · tiêu đề · mô tả · dải lý lịch nền chìm (đồng hồ · ai nêu · nhãn gom) · hàng nút nấc · mạch bàn luận · ô soạn.
- **Cả dòng danh sách bấm được** để mở cửa này, không thêm nút *Xem* nào. *(Từ làn VDL dòng không còn nút con nào nên không còn cú bấm nào phải chặn — nhưng bài thử vẫn canh chiều ngược lại: thêm lại một nút vào dòng mà quên `stopPropagation` thì bấm Nhận sẽ bung luôn cửa chi tiết.)*
- **Một cửa, hai lối vào.** Dòng ở khối *Chờ bạn* mở ra đúng cửa ấy (luật *một cửa một mặc định*, Tracy 05/09), sau khi `await vdTai()` — `moTab` gọi `vdTai` mà không chờ.
- **Mạch bàn luận là một danh sách PHẲNG theo thời gian**, không phân cấp: một vấn đề có hai ba người và đích là đi tới một quyết định, nhánh chỉ làm mạch đứt ra.
- **Ghi thẳng, không có nháp chờ nút Lưu** — thứ người khác đang chờ đọc. Cả đội viết được (policy `ghi_van_de_bl` mở cho mọi thành viên); không ai sửa hay xoá được câu của người khác, và giao diện không bày nút nào cho việc ấy.
- ⭐ **`cho_ben_khac` bắt buộc kèm một bình luận.** Đặc tả đòi *"phải nêu chờ ai"* mà bảng `van_de` **không có cột nào chứa điều đó** — và đừng thêm cột cho một nấc dùng tới. Chỗ đúng của nó là mạch bàn luận: ô soạn trống thì nấc không đổi. Một cú bấm làm hai việc, **ghi câu trước, đổi nấc sau**.
- **Tin thời gian thực đi đường riêng** `vdCoTin`, không qua `RT_BANG` — `rtTaiLai` hoãn khi có cửa nổi đang mở, mà ở đây cửa ấy chính là thứ cần đổi. Tệp `nang-cap-realtime-van-de.sql`.

**④ Khối *Chờ bạn* mở rộng** *(đã chạy ở màn Hôm nay)* — vấn đề trỏ tên mình về đứng cạnh năm loại đang chờ khác, dùng lại đúng nút **Nhận** đã có. Một nhánh `union all` thứ bảy trong `cho_ban`, cộng một khoá trong `CB_LOAI` của app — quên khoá ấy thì ô đếm cộng một dòng mà danh sách không bày nó.

---

## 5. Bốn luật máy

1. **Đồng hồ 24 giờ.** `moi` quá `han_tra_loi` mà `nhan_luc` còn trống → dòng nổi đầu bảng chung, và hiện thêm ở màn của trưởng khối nhận. Không gửi thông báo dồn dập, chỉ một lần lúc chạm hạn.
2. **Chỉ người nêu được đóng.** Ràng buộc ở tầng máy chủ, không chỉ ở giao diện.
3. **Đếm lặp.** Cùng `loai_lap` đủ **ba** vấn đề trong 90 ngày → app hiện một dòng gợi ý mở việc sửa quy trình, giao cho trưởng khối nhận. Đây là chỗ hệ này thôi giỏi giải từng ca (`wiki/cong-ty/rova/van-de-lien-phong.md` mục 5).
4. **Chốt thì sinh việc.** Đóng một vấn đề ở trạng thái `xong` mà không có `buoc_ke_tiep` nào nối vào thì app hỏi lại một lần — theo IDS, buổi họp chưa sinh ra việc có chủ là chưa xong.

---

## 6. Thứ tự dựng

| Nhát | Việc | Phụ thuộc |
|---|---|---|
| 1 | Bảng `van_de` + `van_de_binh_luan` + ràng buộc mục 5 | `TRI-26` bảng con trỏ khách |
| 2 | Cửa nêu vấn đề + bảng chung *(cùng nhát, luật cứng)* | nhát 1 |
| 3 | Nhánh thứ bảy của khung nhìn `cho_ban` | nhát 1 |
| 4 | Đồng hồ 24 giờ + đếm lặp ba lần | nhát 2 |
| 5 | Cửa chi tiết + mạch bàn luận + ba nấc còn thiếu *(làn VD4, đã dựng)* | nhát 1 |

⚠️ **Sửa 05/09 — hai chỗ phụ thuộc khai sai, đã soi bằng máy.**

- **Nhát 3 không cần `TRI-31`.** Máy chủ đã có khung nhìn `cho_ban` — chính là *"thứ đang chờ người đang đăng nhập ra tay"*, sáu nhánh `union all`, sáu cột cứng (`loai · khoa · ten · ai · luc · cua_toi`), và app đã bày nó ở khối **Chờ bạn** ngay màn Hôm nay. Chú thích của khung nhìn viết sẵn cách nới: *"Thêm loại mới thì thêm một nhánh `union all`, không dựng bảng — và nhớ khai khoá tương ứng trong `CB_LOAI` của app, không thì ô đếm cộng một dòng mà danh sách không bày nó."* Vậy nhát 3 là **một nhánh thứ bảy** cộng một khoá trong `CB_LOAI`. Màn *Bàn giao cho tôi* của `TRI-31` là chỗ đọc cho **bước kế tiếp** của mảng ghi chú, một thứ khác.
- **Nhát 2 không cần `TRI-27`.** Hàm quyền theo phòng ban chỉ cần khi lọc vấn đề **có gắn khách**, mà `khach_con_tro` chỉ giữ số điện thoại, tên hiển thị và link — chưa có gì đáng che. Cắm hàm quyền vào lúc CRM nối thật.
- **Còn lại đúng một phụ thuộc thật:** luật *"chốt thì sinh việc"* của nhát 4 cần bảng `buoc_ke_tiep` (`TRI-28`), chưa dựng. Nhát 4 làm được phần đồng hồ và phần đếm lặp; riêng câu hỏi lại lúc đóng thì để lại.

---

## 7. Chưa chốt

- ❓ Buổi liên phòng đặt thứ mấy, ai chủ trì — chặn phần nhịp, không chặn phần mã.
- ⚠️ Ba nấc mức là do tôi đặt; nếu ROVA đã có thang riêng cho khiếu nại thì chép thang đó. Chữ của nấc 1 thì Tracy đã chốt: **Nghiêm trọng**.
- ⚠️ **Ba lối ra khi đóng vẫn còn thiếu** — luật máy 4 (*chốt thì sinh việc*) cần bảng `buoc_ke_tiep` của `TRI-28`, chưa dựng. Và **mở lại một vấn đề đã đóng**: cò máy chủ đỡ được (nó xoá dấu đóng), nhưng app chưa có nút — nấc thứ tư, không nằm trong ba nấc đang chết.
- ⚠️ `loai_lap` hiện là chữ tự do. Nếu để người nhập tay thì sẽ tản mát; bản sau nên gom thành danh sách chọn sinh từ chính dữ liệu.
