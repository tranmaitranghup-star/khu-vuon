#!/usr/bin/env bash
# Chạy TRỌN bộ thử của app Khu Vườn Tỉnh Thức.
#
# Đếm bằng MÃ THOÁT, không bằng cách tìm ký hiệu ❌ trong chữ in ra: có bài in
# `✗` chứ không in `❌`, nên lối quét theo ký hiệu từng bỏ sót nguyên một bài
# đang hỏng. Bài CHẾT lúc khởi động cũng nguy hơn ca đỏ, vì mọi ca bên trong nó
# biến mất trong im lặng — mã thoát bắt được cả hai.
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
