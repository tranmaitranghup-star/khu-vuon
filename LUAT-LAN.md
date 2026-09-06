# LUẬT LÀN — mỗi phiên một cây làm việc riêng

> **Đọc trước khi chạm `public/`. Một trang, ba lệnh.** Đây là luật CỨNG: có hook
> git chặn tay, không phải điều mỗi phiên tự nhớ.

## Luật một câu

**Mọi commit chạm `public/` phải đứng trên một nhánh `lan/*`, trong cây làm việc riêng của làn đó.**

Không ngoại lệ, kể cả khi sổ làn đang trống — sổ trống chỉ chứng minh chưa ai *khai*,
không chứng minh không ai đang sửa. Cả năm tai nạn trước đều xảy ra đúng lúc người
commit tin rằng mình đang làm một mình.

## Ba lệnh

```bash
python3 production/tinh-thuc-app/lan.py mo DW "Gộp phiên deep work vào khối việc"
python3 production/tinh-thuc-app/lan.py soi
python3 production/tinh-thuc-app/lan.py xong DW
```

`mo` dựng một thư mục riêng ở `production/lan-app/<MÃ>/` trên một nhánh riêng, lấy từ
`origin/main` mới nhất. Từ đó tới lúc khép làn, **chỉ sửa file trong thư mục ấy**.
Đang sửa dở ở cây chính thì thêm `--mang-theo`, nó bê nguyên phần đang dở sang.

`xong` xếp nhánh làn lên `origin/main` mới nhất, đẩy lên `main` (Cloudflare tự phát hành),
rồi gỡ thư mục làn. Gặp xung đột thật thì nó **dừng lại** và chỉ chỗ — đó là lúc hai làn
đổi cùng một chỗ, phải có người đọc và giữ cả hai ý.

`bo` bỏ một làn mà không gộp gì. Nhánh vẫn còn để lấy lại mã.

## Vì sao phải tách cây, không chỉ tách commit

Năm lần liên tiếp (13/08 · 29/08 hai lần · 31/08 hai lần) một phiên commit
`public/index.html` và mang theo mã của phiên khác lên `main` — có lần đẩy thẳng ra
người dùng một tính năng còn viết dở, dưới một cái tên không nhắc gì tới nó.

Ba luật cũ đều thất bại vì cùng một lẽ: **nhiều phiên chạy trên CÙNG một bản file trên đĩa.**
Khi phiên A gọi `git add public/index.html` thì mã của phiên B đã nằm sẵn trong file ấy.
`git add <từng-file>` chỉ tách được hai làn ở HAI file khác nhau, mà mọi làn đều đụng đúng
một file 1,6 MB. Soát `git diff` lúc bắt đầu cũng không cứu — tai nạn xảy ra lúc *commit*.

Tách cây thì hai phiên không còn chung bản file nào để mà mang theo nhau hay ghi đè nhau,
và việc gộp giao cho git: nó so từng dòng, gộp sạch khi hai làn đổi hai chỗ, và **báo xung đột**
khi đổi cùng chỗ thay vì im lặng nuốt.

## Hook chặn

`hook-chan-dung-do.py`, cài một lần cho cả repo (mọi cây làn dùng chung):

```bash
cd production/tinh-thuc-app && printf '#!/bin/sh\nCHUNG=$(git rev-parse --git-common-dir)\nGOC=$(cd "$(dirname "$CHUNG")" && pwd)\nexec python3 "$GOC/hook-chan-dung-do.py" "$@"\n' > "$(git rev-parse --git-common-dir)/hooks/pre-commit" && chmod +x "$(git rev-parse --git-common-dir)/hooks/pre-commit"
```

Nó chặn commit chạm `public/` khi bạn không đứng trên nhánh `lan/*`, và in ra đúng lệnh
cần chạy. Trên nhánh làn thì nó in `git diff --cached --stat` để bạn nhìn thấy mình đang
mang theo những gì.

Lối thoát, khi thật sự cần và có ý thức:

```bash
LAN_BO_QUA="lý do" git commit -m "..."
```

Mỗi lần đi lối thoát đều ghi vào `.git/lan/bo-qua.log`, đọc lại được.

## Sổ làn nằm ở đâu

`.git/lan/*.json` — chỗ **mọi cây cùng nhìn thấy**, vì các cây làn dùng chung một `.git`.
Để sổ trong repo thì mỗi cây một bản, hai phiên ghi hai nơi rồi gộp ra xung đột, và
`lan.py soi` sẽ không thấy nhau. Sổ ngoài repo thì luôn tức thời và không bao giờ phải gộp.

`DANG-LAM.md` vẫn giữ vai trò cũ: **kể lại bẫy đã cắn người** để phiên sau khỏi vấp lại.
Nó không còn là chỗ đăng ký chỗ đứng nữa — việc ấy nay do `lan.py` và git lo.

## Ba thứ luật này KHÔNG lo

1. **Hai làn cùng đổi một chỗ trong mã.** Git sẽ báo xung đột lúc `xong`; người phải đọc và
   quyết. Luật chỉ bảo đảm chuyện đó không trôi qua trong im lặng.
2. **Tài liệu `.md`.** Chúng không bị hook chặn, nên hai phiên vẫn ghi đè nhau được. Trước khi
   ghi một tệp tài liệu đang có người khác sửa, đọc lại bản trên đĩa — đừng ghi đè bằng bản
   đang nhớ trong đầu.
3. **Máy chủ.** Hai làn cùng đổi một bảng Supabase thì git không biết gì. Tệp `.sql` vẫn phải
   chạy theo thứ tự, và mỗi tệp tự khai nó dựng lại khung nhìn nào.
