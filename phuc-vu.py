#!/usr/bin/env python3
"""Máy phục vụ tệp tĩnh cho app Khu Vườn — đường lui khi `python3 -m http.server` không chạy được.

VÌ SAO CÓ FILE NÀY. Trên máy Tracy, `python3 -m http.server` ngã ngay lúc dựng bộ đọc tham số:

    parser.add_argument('--directory', '-d', default=os.getcwd(), ...)
    PermissionError: [Errno 1] Operation not permitted

`os.getcwd()` bị chặn, mà dòng ấy chạy TRƯỚC khi ai kịp truyền `--directory`, nên không có
tham số nào cứu được. Ba làn liên tiếp (18/08 · 19/08 · 24/08) đều dừng ở đây và ghi
"chưa thử được tại máy". File này đi vòng: khai thẳng thư mục gốc, không hỏi thư mục hiện hành.

    python3 phuc-vu.py [cổng] [thư-mục]        # mặc định 8082 và ./public
"""
import functools, os, sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

GOC = os.path.dirname(os.path.abspath(__file__))
cong = int(sys.argv[1]) if len(sys.argv) > 1 else 8082
thu_muc = sys.argv[2] if len(sys.argv) > 2 else os.path.join(GOC, 'public')


class Phuc(SimpleHTTPRequestHandler):
    # Trình duyệt giữ bản cũ trong bộ nhớ đệm là thứ làm người sửa mã tưởng mình
    # sửa hụt. Máy phục vụ tại chỗ thì luôn trả bản mới.
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()


if __name__ == '__main__':
    handler = functools.partial(Phuc, directory=thu_muc)
    with ThreadingHTTPServer(('127.0.0.1', cong), handler) as may:
        print(f'Khu Vườn đang chạy tại http://localhost:{cong}/ — thư mục {thu_muc}', flush=True)
        may.serve_forever()
