# Khu Vườn Tỉnh Thức ROVA — triển khai lần đầu (~30 phút, làm một lần)

> 4 chặng. Chặng 1–2 cần tài khoản của Tracy nên AI không tự làm được,
> nhưng AI dẫn từng cú bấm qua Chrome được. Chặng 4 xong là đội dùng.

> ⚠️ **Nếu project Supabase ĐÃ tạo và đã chạy `schema.sql` từ trước:** không phải làm lại
> từ đầu. Chỉ cần mở **SQL Editor → New query** → dán trọn **`nang-cap-khu-vuon.sql`** → Run,
> rồi **`nang-cap-deepwork-tu-do.sql`** → Run, rồi kéo thả lại `index.html` lên Netlify.
> Hai file đó chạy lại nhiều lần cũng không sao.
>
> 🔄 **Nâng cấp 06/08 (deepwork tự do):** đã chạy đủ 3 file SQL từ trước thì chỉ cần chạy thêm
> **`nang-cap-deepwork-tu-do.sql`** + kéo thả lại `index.html`. Nội dung: bỏ khung 30 phút
> (đồng hồ đếm lên, sàn 5' · trần 120'/phiên) · kết thúc phiên qua BA CỬA (✅ Output ·
> 🔄 tiến độ · 🚧 nghẽn → task con) · nhịp bấm giờ được (không vào bảng vinh danh).

## Chặng 1 — Supabase (~10')
1. https://supabase.com → **New project** (tạo MỚI, đừng dùng chung project app Tiêu điểm).
   Đặt tên `tinh-thuc-rova`, region Singapore, ghi lại mật khẩu database.
2. **SQL Editor → New query** → dán trọn `schema.sql` → **Run**.
3. New query → dán trọn **`nang-cap-khu-vuon.sql`** → **Run** (lớp Khu Vườn: ba luống,
   một task một cây, hai bảng vinh danh). **Phải chạy sau `schema.sql`.**
4. New query → dán trọn **`nang-cap-deepwork-tu-do.sql`** → **Run** (lớp deepwork tự do:
   bỏ khung 30 phút, ba cửa ra, bấm giờ nhịp). **Phải chạy sau hai file trên.**
5. New query → dán trọn `seed-danh-muc-nhip.sql` → **Run** (nạp 144 nhịp gợi ý).
6. **Table Editor → nguoi** → sửa 11 dòng `nguoi-05@vidu.com` thành **email Google thật**
   của từng người (hỏi trong nhóm Lark — ai đăng nhập bằng email nào thì điền đúng email đó).
7. **Settings → API** → chép 2 thứ: `Project URL` và `anon public key`.

## Chặng 2 — Google OAuth (~10', phần rối nhất)
1. https://console.cloud.google.com → tạo project mới `tinh-thuc-rova`.
2. **APIs & Services → OAuth consent screen** → External → điền tên app + email → Save.
3. **Credentials → Create credentials → OAuth client ID** → loại **Web application**:
   - Authorized JavaScript origins: `https://<project>.supabase.co` và địa chỉ Netlify (thêm sau cũng được)
   - Authorized redirect URIs: `https://<project>.supabase.co/auth/v1/callback`
4. Chép **Client ID** + **Client Secret** → về Supabase → **Authentication → Providers →
   Google** → bật, dán vào, Save.

## Chặng 3 — điền cấu hình vào app (~1')
Mở `index.html`, sửa 2 dòng đầu phần `<script>`:
```
const SUPABASE_URL = 'https://<project>.supabase.co';
const SUPABASE_ANON_KEY = '<anon key>';
```
(Khoá `anon` sinh ra để nằm trong trang web — an toàn vì RLS đã khoá từng dòng.
 Thứ KHÔNG BAO GIỜ được dán vào đây: `service_role key` và mật khẩu database.)

## Chặng 4 — Cloudflare (đã dựng xong 06/08/2026)

> ⚠️ **KHÔNG dùng Netlify nữa.** Hai lý do đã trả giá thật: ① Netlify tính **15 credit mỗi lượt
> deploy**, gói Free chỉ 300 credit/tháng → trần 20 lượt, mà pha xây app cần sửa hằng ngày;
> ② Netlify Drop serve **MỌI file** trong thư mục được kéo lên, nên `schema.sql` (có email thật
> của thành viên) từng tải được công khai. Nay app nằm trên Cloudflare, deploy không bị đếm,
> và chỉ thư mục `public/` được ra web.

**Hạ tầng hiện tại:**
- **Kho mã:** GitHub riêng tư `tranmaitranghup-star/khu-vuon-tinh-thuc` (repo phải RIÊNG TƯ —
  `schema.sql` có email thật).
- **Nơi chạy:** https://rovatinhthuc.tranmaitrang-hup.workers.dev
- **Cách phát hành:** đẩy mã lên nhánh `main` → Cloudflare tự build và phát hành. Không kéo thả gì.
- **Chỉ `public/` ra web** — khai trong `wrangler.jsonc`. File `.sql` và `.md` ở lại kho riêng tư.

**Thử:** mở địa chỉ trên điện thoại → Đăng nhập Google → thấy màn *Hôm nay* là xong.
Email chưa có trong bảng `nguoi` sẽ bị chặn với thông báo "nhắn Tracy" — đúng thiết kế.

## Sửa app từ nay

1. **Thử tại máy trước, không tốn gì:**
   ```
   cd production/tinh-thuc-app/public && python3 -m http.server 8080
   ```
   Mở `http://localhost:8080`, sửa `public/index.html` rồi F5 xem ngay. Lặp bao nhiêu lần cũng được.
   (Địa chỉ `http://localhost:8080/**` đã nằm trong Supabase Redirect URLs nên đăng nhập chạy được.)
2. **Chốt xong mới phát hành:** ghi một mốc Git rồi đẩy lên `main`. Cloudflare tự cập nhật app.
3. **Hỏng thì quay về bản trước** bằng lịch sử Git — điều trước đây không làm được.

## Sau này
- **Tên miền ROVA** (khi mua xong): Cloudflare → project `rovatinhthuc` → Domains → Add domain.
  Nhớ thêm tên miền mới vào Supabase URL Configuration.
- **Sao lưu dữ liệu:** `python3 production/tinh-thuc-backup/sao-luu.py` → lưu 8 bảng vào
  `raw/tinh-thuc-backup/<ngày>/`. Supabase Free KHÔNG có sao lưu tự động.
  ⚠️ **Trước ngày mở app cho đội phải bật lịch chạy tự động hằng ngày** (việc 23 trong hồ sơ G-01).
- **Thêm/bớt thành viên:** Supabase → Table Editor → bảng `nguoi`.
- **Gieo hạt / thu hoạch O:** làm thẳng trong app, tab 🌳 **Vườn**. Cả đội gieo và tick xong được
  (Tracy chốt 06/08: *"O xong nếu mọi người tick là xong rồi"*). Ba luống là hết —
  xong một hạt mới có chỗ gieo hạt sau, luật này cưỡng chế ở tầng cơ sở dữ liệu.
- **Mã nguồn lên GitHub** (tuỳ chọn): repo này chỉ có `index.html` + 2 file SQL — không có bí mật
  nào trong đó, công khai được. Nhưng repo riêng tư vẫn đủ dùng.

## ⚠️ Kiểm phát hành: gọi ĐÚNG địa chỉ gốc, không gọi `/index.html`

`https://rovatinhthuc.tranmaitrang-hup.workers.dev/index.html` trả **307** và 0 byte — máy chủ chuyển
hướng nó về `/`. `curl` không có `-L` thì nhận đúng cái vỏ rỗng ấy, nên phép dò *"bản mới lên chưa"*
đọc ra 0 dấu vết và vòng chờ chạy mãi dù bản mới đã lên từ lâu (mất 12 phút chờ hão, 29/08).

Dò bằng địa chỉ gốc, rồi so từng byte:

```bash
curl -sL https://rovatinhthuc.tranmaitrang-hup.workers.dev/ > /tmp/song.html
cmp -s public/index.html /tmp/song.html && echo "giống từng byte"
```
