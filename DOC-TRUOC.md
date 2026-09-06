# ĐỌC TRƯỚC — cửa vào mọi phiên sửa app Khu Vườn

> **Luật một dòng:** vào phiên thì đọc **file này** trước, rồi mở **đúng những file bảng dưới chỉ ra**
> cho loại việc đang làm. Không mở gì thêm cho tới khi biết mình cần gì.

## ⛔ LUẬT CỨNG: chạm mã thì mở làn riêng

Bạn không phải phiên duy nhất đang chạy. Trước khi sửa bất cứ thứ gì trong `public/`:

```bash
python3 production/tinh-thuc-app/lan.py mo XX "việc bạn sắp làm"
```

Nó dựng cho bạn một thư mục riêng ở `production/lan-app/XX/` trên một nhánh riêng — làm trong
đó, rồi `lan.py xong XX` để gộp lên `main`. Có hook git **chặn tay** nếu bạn commit mã từ cây
chính, nên đây không phải lời khuyên. Đang sửa dở rồi mới đọc dòng này thì thêm `--mang-theo`,
không mất gì cả. Đầy đủ: **`LUAT-LAN.md`** (một trang) · xem ai đang mở gì: `lan.py soi`.

## Vì sao có file này

`public/index.html` nặng **685 nghìn token** *(đo lại 05/09, làn VD4 — nó đã gấp đôi con số 345 nghìn ghi ở đây từ 28/08)* — đọc trọn một lần là chiếm hơn nửa bộ nhớ làm việc của
phiên, và con số đó **bị trả lại ở mọi lượt còn lại**. Bối cảnh trong một phiên chỉ tăng, không giảm,
nên một phiên dài gấp đôi tốn gấp **bốn**. Đó là chỗ token bốc hơi, không phải ở chữ viết ra.

Cách chữa không phải đọc ít đi rồi đoán — mà là **đọc đúng chỗ ngay từ đầu**. Bảng dưới là bản đồ đó.

## Đọc gì cho loại việc gì

| Việc đang làm | Mở đúng những thứ này | Tốn |
|---|---|---|
| **Mọi phiên, luôn luôn** | `DOC-TRUOC.md` (file này) + `LUAT-LAN.md` (luật cứng, một trang) + `DANG-LAM.md` — ba luật chống đụng độ · ba bẫy đã cắn người · làn nào đang mở · mục ⏳ việc còn treo | ~20 KB |
| **Sửa giao diện** (màu, khoảng cách, bố cục) | `BAN-DO-INDEX.md` mục **Bản đồ giao diện** → tra tiền tố / `#id` → `Grep` → `Read` đúng dòng | ~4 KB + đoạn |
| **Sửa logic** (hành vi, luồng, dữ liệu) | `BAN-DO-INDEX.md` mục **Hàm theo cụm** → tra `tenHam@dòng` → `Read` đúng hàm | ~4 KB + đoạn |
| **Hỏi "chỗ đó đang chạy thế nào"** | `DA-SOI-TRONG-MA.md` **trước đã** — đã dò một lần rồi, dò lại là trả tiền hai lần | ~10 KB |
| **Chạm cơ sở dữ liệu** | `schema.sql` + file `nang-cap-*.sql` gần nhất của đúng mảng đó | ~16 KB |
| **Bộ tự kiểm so chuỗi với một ràng buộc / policy / khung nhìn** | Mẫu `like` chỉ được chứa **tên cột** và **chuỗi trong nháy** — hai thứ duy nhất Postgres trả lại y nguyên. Nó KHÔNG cất lại nguyên văn câu bạn gõ: nó phân tích rồi in lại, và lúc in thì **từ khoá viết HOA**, ngoặc được thêm vào, khoảng cách đổi. `check (not rieng_tu or tieu_diem_ma is null)` cất vào thành `CHECK (((NOT rieng_tu) OR (tieu_diem_ma IS NULL)))`. Mẫu chứa từ khoá thì ra ❌ **oan** — mà ❌ oan tệ hơn không kiểm: nó dạy người đọc thôi tin cả bảng. Ca ⑨ của `thu-loai-ca-nhan.js` quét luật này bằng máy. *(Vấp 04/09, làn TKW.)* | — |
| **Viết một tệp `nang-cap-*.sql` mới** | Xếp bộ **TỰ KIỂM XUỐNG CUỐI**, số liệu tham khảo lên trước. Trình soạn SQL của Supabase chỉ bày kết quả của câu lệnh **cuối cùng** — đặt tự kiểm ở giữa là Tracy chạy xong nhìn thấy một bảng vô thưởng vô phạt, còn bảng đạt/chưa đạt thì khuất, phải chạy lại lượt nữa. Thêm `order by dat, so` để dòng chưa đạt nổi lên đầu. *(Vấp 04/09, làn CNH.)* | — |
| **Hỏi "tệp SQL nào đã chạy trên máy chủ"** | `SO-SQL.sql` — dán vào Supabase, chỉ đọc. Nó dò dấu vết riêng của từng tệp trong danh mục Postgres, **không** dựa vào sổ chép tay. ⚠️ Thêm một dòng dò thì dấu vết phải là thứ **đúng MỘT tệp** dựng ra: `grep -l` nó khắp thư mục trước, ra hai tên tệp là dấu vết hỏng — đưa xuống khối ② hỏi theo nội dung. Soát 01/09 bắt được hai dòng đang sáng ✅ oan vì phạm luật này | ~11 KB |
| **Chạm CAM KẾT · KHO · GIAO VIỆC** | `BAN-GIAO-SQL-giao-va-kho-cam-ket.md` **trước đã** — 4 bẫy, thứ tự chạy 2 tệp SQL, 6 hàm | ~9 KB |
| **Chạm CẤU TRÚC MÀN, thanh tab, bố cục khối** | `BAN-GIAO-kien-truc-bon-man.md` **trước đã** — bốn màn hiện tại, 9 bẫy, mã chết còn lại | ~9 KB |
| **Bàn kiến trúc: ba trục, hai phạm vi** | `kien-truc-app.html` — bản Tracy chốt 28/08, năm sơ đồ | ~9 KB |
| **Phát hành, hạ tầng, tên miền** | `HUONG-DAN-TRIEN-KHAI.md` | ~6 KB |
| **Sửa giao diện — trước khi gõ dòng đầu** | `CAU-TRUC-APP.md` **Mục 7** — mười một luật trình bày (không gạch chữ · vuông mép · khoảng cách khối), mỗi luật kèm cách kiểm | ~6 KB |
| ⛔ **`CAU-TRUC-APP.md`** phần còn lại | Phần cấu trúc **ĐÃ CŨ** từ 28/08. Ngoài Mục 7 thì đừng tin | — |
| **Tra một làn cũ ai từng chạm gì** | **`luu-tru/CHI-MUC-LAN.md` trước** — một dòng mỗi làn, đủ bẫy đã né và tên hàm đã chạm. Tra bằng `Grep` mã làn hoặc tên hàm, **đừng đọc trọn**. Chỉ khi dòng ấy chưa đủ mới mở `luu-tru/DANG-LAM-luu-tru.md` (toàn văn) | ~54 KB · ~334 KB |

> 🗄 **Ba tầng sổ chia làn, từ nhẹ tới nặng** (tách 01/09): `DANG-LAM.md` giữ thứ MỌI phiên cần ở
> mọi lượt — luật, bẫy, làn đang mở, việc còn treo. `luu-tru/CHI-MUC-LAN.md` giữ một dòng cho mỗi
> làn đã đóng. `luu-tru/DANG-LAM-luu-tru.md` giữ toàn văn. Trước khi tách, cả ba nằm chung một
> file **102 KB** và mọi phiên trả tiền cho cả ba ở mọi lượt; nay tầng đầu còn **20 KB**.
> **Khép một làn thì rút nó xuống một dòng NGAY** — đợi một đợt dọn là nó lại phình.
>
> 🪤 **Đợt nén ấy quét nhầm bốn mục, chép lại đây vì cách nó hỏng sẽ tái diễn.** Đoạn cắt lấy
> *"từ mục làn đầu tiên tới đầu mục 🗄"* — một mốc đầu và một mốc cuối, tưởng là gọn. Nhưng giữa
> hai mốc ấy còn có **mục ⏳ việc còn treo** và **ba mục ⚠️ chỗ dễ vấp**, và chúng bị cuốn theo mà
> không một dấu hiệu nào báo. Chính con số cũng nói dối theo: tầng đầu ra **10,8 KB** trông như
> một thành quả, mà 4 KB trong đó là thứ vừa bị chôn nhầm. Hai luật rút ra: **cắt theo TỪNG mục
> đã kê tên, đừng cắt theo một quãng giữa hai mốc**; và khi một phép dọn ra con số đẹp hơn dự
> tính thì đó là lúc phải soi, không phải lúc mừng.

> ⚠️ **Số đo trong file này lỗi thời rất nhanh.** Ngày 28/08 tôi thấy nó còn ghi *13.193 dòng · 423
> hàm* trong khi file đã là **19.731 dòng · 616 hàm** — chênh gần 50%. Bản đồ cũ thì tra ra số dòng
> sai, và mọi lượt `Read` theo nó đều trượt. **Dựng lại bản đồ trước khi tin nó**, một lệnh ở ngay dưới.

**Cách tra bản đồ:** `BAN-DO-INDEX.md` liệt kê **1.204 hàm** *(dựng lại 05/09)* theo cụm chức năng, mỗi hàm kèm số dòng dạng
`tenHam@5988`. Nó nhẹ hơn `index.html` khoảng **60 lần**. Bản đồ cũ thì dựng lại:

```bash
python3 production/tinh-thuc-app/ban-do-index.py
```

## Quy trình truy xuất — bốn bước, có số đo

`public/index.html` **là toàn bộ app trong một file**: 1% khung HTML · 29% kiểu dáng CSS · 70% mã chạy JS.
Tên `index.html` là quy ước web (file mặc định khi mở địa chỉ), không phải "chỉ mục".

**Số dòng lớn là địa chỉ, không phải quãng đường.** Đọc dòng 12084 không đi qua 12.083 dòng trước nó —
đo thật trên bản **38.719 dòng** *(05/09)*:

| Cách lấy | Tốn |
|---|---:|
| `Read` 60 dòng quanh dòng 12084 | **0,9k token** |
| `Grep -n` một tên selector hoặc tên hàm | **0,2–1,6k byte** |
| Đọc trọn khối `<style>` | 82k token |
| Đọc trọn file | **685k token** |

Chênh lệch giữa dòng đầu và dòng cuối bảng là **380 lần**. Bốn bước dưới đây đứng ở dòng đầu:

1. **Tra bản đồ** `BAN-DO-INDEX.md` (21 KB, ~5k token — nhẹ hơn file gốc **60 lần**).
   Sửa logic → mục *Hàm theo cụm*, lấy `tenHam@dòng`. Sửa giao diện → mục *Bản đồ giao diện*,
   lấy tiền tố nhóm hoặc `#id`.
2. **`Grep` để chốt số dòng chính xác.** Bản đồ chỉ ra chỗ tập trung; `Grep -n` cho địa chỉ đúng.
   Rẻ tới mức không cần tiếc: một tên thường chỉ hiện 3–10 lần trong cả file.
3. **`Read` có `offset` và `limit`** — 60 tới 150 dòng quanh đó là đủ cho một hàm.
4. **`Edit` rồi dừng.** Không đọc lại để kiểm.

**Khi chưa biết tên gì để tra** (kiểu *"sửa cái ô nhập giờ cho đẹp hơn"*): `Grep` chữ tiếng Việt hiện
trên màn hình, hoặc mở file mẫu tương ứng trong thư mục này (`mau-*.html`) — chúng nhỏ và tách riêng
từng khối, đọc trọn cũng rẻ.

## Ba thứ ĐỪNG đọc

1. **Đừng đọc trọn `public/index.html`.** Không có việc nào cần cả file. Tra bản đồ, rồi `Read` có
   `offset` và `limit`.
2. **Đừng đọc hồ sơ `tieu-diem/G-01`** khi việc là sửa mã. Nó là hồ sơ **điều hành** — quyết định của
   Tracy, câu hỏi đang chờ Tracy phân xử — không phải tài liệu kỹ thuật. Chỉ mở khi Tracy hỏi *"việc
   này tới đâu rồi"*, *"còn treo gì"*, hoặc khi cần ghi một quyết định vừa chốt.
3. **Đừng đọc lại file vừa sửa để kiểm.** `Edit` sai thì tự báo lỗi. Đọc lại chỉ tốn thêm một lần
   bằng cả đoạn đó.

## Nhịp làm việc

1. **Ghi làn của mình vào `DANG-LAM.md`** trước khi chạm `public/index.html` — đó là kênh liên lạc duy
   nhất giữa các phiên chạy song song. Ba luật chống đụng độ nằm ngay đầu file đó.
2. **Thử tại máy** — nhưng máy phục vụ của `preview_start` **không đọc được thư mục Desktop**
   (soát 31/08, làn SK2). Ba cách đều ngã: `phuc-vu.py` báo *"can't open file … Operation not
   permitted"*, `python3 -c` ngã lúc `import` vì thư mục hiện hành nằm trong đường tìm mô-đun, và
   phục vụ thẳng từ Desktop thì trả 404 cho mọi file dù file có thật. **Cách đi được:** chép `public/`
   sang thư mục nháp ngoài Desktop, rồi khai một cấu hình chạy `python3 -I -c "…"` (cờ `-I` bỏ thư
   mục hiện hành khỏi đường tìm mô-đun) phục vụ thư mục chép ấy. Nhớ chép lại sau mỗi lần sửa mã —
   bản đang xem là bản chép, không phải bản đang sửa.
3. **Chỉ đưa vào commit đúng file của mình** — `git add <từng-file>`. Cấm `git add -A`.
4. **Đẩy lên `main`** là Cloudflare tự phát hành. Không kéo thả gì.

## Việc đọc nhiều thì giao tác tử con

Cần soát nhiều chỗ trong `index.html` cùng lúc (kiểu *"tìm mọi nơi gọi hàm này"*) thì giao cho một tác
tử con: nó đọc xong trả về kết luận, bối cảnh của nó kết thúc theo nó, không nằm lại làm nặng phiên
chính. Đây là phần **tốn ít nhất** trong số đo — nên dùng nhiều hơn, không phải dè.

---

*Nền: CLAUDE.md Mục 2f (giữ phiên nhẹ). Dựng 2026-08-14 sau đợt đo — hồ sơ G-01 từ 236 KB xuống 103 KB,
`DANG-LAM.md` từ 32 KB xuống 14 KB.*

*Soát lại 2026-08-29: `DANG-LAM.md` đã phình lại lên **179 KB · 2.230 dòng · 44 làn**
— nó lớn hơn 12 lần con số ghi trong chính bảng trên mà không ai thấy, vì file này không tự đo
lấy mình. Đã rút 44 làn xuống chỉ mục một dòng, toàn văn sang `luu-tru/` → **13,9 KB**. Bài học:
mỗi lần khép một làn thì rút nó xuống một dòng NGAY, đừng đợi một đợt dọn.*
