#!/usr/bin/env bash
# Chạy TRỌN bộ thử của app Khu Vườn Tỉnh Thức.
#
# ĐẾM BẰNG MÃ THOÁT, KHÔNG BẰNG CÁCH TÌM KÝ HIỆU ❌ TRONG CHỮ IN RA.
# Ngày 05/09 lối quét quen thuộc — chạy cả bộ rồi `grep "❌"` — báo 0 ca đỏ
# trong khi `thu-tuan-o-ngay.js` đang hỏng 5 ca, chỉ vì bài ấy in `✓`/`✗` chứ
# không in `✅`/`❌`. Mã thoát bắt được cả ca đỏ lẫn bài CHẾT lúc khởi động —
# mà bài chết còn nguy hơn, vì mọi ca bên trong nó biến mất trong im lặng.
#
# ⚠️ ĐO THÌ ĐO TRÊN `origin/main`, ĐỪNG ĐO TRÊN ĐĨA. Cây trên đĩa hay chậm hơn
#    vài mốc, và so hai bản cũ với nhau thì không chứng minh được gì.
#    Cách sạch: `git archive origin/main | tar -x -C <thư mục tạm>` rồi chạy ở đó.
cd "$(dirname "$0")" || exit 1
dat=0; hong=()
for f in thu-*.js; do node    "$f" >/dev/null 2>&1 && dat=$((dat+1)) || hong+=("$f"); done
for f in thu-*.py; do python3 "$f" >/dev/null 2>&1 && dat=$((dat+1)) || hong+=("$f"); done
tong=$((dat + ${#hong[@]}))
echo "── BỘ THỬ KHU VƯỜN ─────────────────────────"
echo "  đạt      : $dat/$tong"
if [ ${#hong[@]} -eq 0 ]; then echo "  ✅ xanh cả bộ"; else
  echo "  chưa đạt : ${#hong[@]}"
  for f in "${hong[@]}"; do echo "     🔴 $f   → chạy riêng để xem ca nào"; done
fi
exit ${#hong[@]}
