#!/usr/bin/env bash
# Chạy TRỌN bộ thử của app Khu Vườn Tỉnh Thức.
#
# ĐẾM BẰNG MÃ THOÁT, KHÔNG BẰNG CÁCH TÌM KÝ HIỆU ❌ TRONG CHỮ IN RA.
# Ngày 05/09 lối quét quen thuộc — chạy cả bộ rồi `grep "❌"` — báo 0 ca đỏ
# trong khi `thu-tuan-o-ngay.js` đang hỏng 5 ca, chỉ vì bài ấy in `✓`/`✗` chứ
# không in `✅`/`❌`. Mã thoát bắt được cả ca đỏ lẫn bài CHẾT lúc khởi động.
#
# VÀ CHIA HAI NHÓM, vì hai thứ ấy không cùng một mức nguy (07/09):
#
#   · ca đỏ — bài chạy hết, một câu hỏi trả lời sai. Bài thử đang làm việc.
#   · CHẾT  — bài ngã trước khi hỏi được câu nào. Mọi ca bên trong biến mất
#             trong im lặng, và cột "chưa đạt" chỉ nhích đúng một con số y như
#             một vết xước.
#
# Chuyện đó vừa xảy ra thật: `thu-van-de.js` chết từ một làn nào đó không rõ
# ngày, mang theo 177 ca — trong đó 51 ca do các làn SAU viết thêm và chưa từng
# chạy lần nào. Người viết chúng nhìn bảng này, thấy một dòng 🔴 lẫn giữa các
# dòng khác, và đi tiếp. Một cái bảng gộp hai mức nguy vào một con số thì chính
# nó là chỗ hỏng, không phải người đọc.
#
# CÁCH NHẬN RA BÀI CHẾT: dấu vết ngăn xếp lời gọi. Node in các dòng mở đầu bằng
# `    at …`, Python in `Traceback (most recent call last):`. Một bài chạy hết
# rồi báo ca đỏ thì không in thứ ấy — nó chỉ in bảng ca của chính nó.
#
# ⚠️ ĐO THÌ ĐO TRÊN `origin/main`, ĐỪNG ĐO TRÊN ĐĨA. Cây trên đĩa hay chậm hơn
#    vài mốc, và so hai bản cũ với nhau thì không chứng minh được gì.
#    Cách sạch: `git archive origin/main | tar -x -C <thư mục tạm>` rồi chạy ở đó.
cd "$(dirname "$0")" || exit 1
dat=0; cado=(); chet=()

# Chạy một bài, xếp nó vào đúng một trong ba nhóm.
chay(){
  local may="$1" tep="$2" ra ma
  ra=$("$may" "$tep" 2>&1); ma=$?
  if [ $ma -eq 0 ]; then dat=$((dat+1)); return; fi
  if printf '%s\n' "$ra" | grep -qE '^Traceback \(most recent call last\):|^[[:space:]]+at '; then
    chet+=("$tep")
  else
    cado+=("$tep")
  fi
}

for f in thu-*.js; do chay node    "$f"; done
for f in thu-*.py; do chay python3 "$f"; done

hong=$(( ${#chet[@]} + ${#cado[@]} ))
tong=$(( dat + hong ))
echo "── BỘ THỬ KHU VƯỜN ─────────────────────────"
echo "  đạt      : $dat/$tong"
if [ $hong -eq 0 ]; then
  echo "  ✅ xanh cả bộ"
else
  # Bài chết đứng TRƯỚC: nó giấu nhiều thứ nhất nên phải được nhìn thấy trước.
  if [ ${#chet[@]} -gt 0 ]; then
    echo "  💀 CHẾT    : ${#chet[@]}   ← ngã trước khi hỏi được câu nào; mọi ca bên trong đang không chạy"
    for f in "${chet[@]}"; do echo "     💀 $f   → chạy riêng, đọc dòng lỗi đầu tiên"; done
  fi
  if [ ${#cado[@]} -gt 0 ]; then
    echo "  🔴 ca đỏ   : ${#cado[@]}"
    for f in "${cado[@]}"; do echo "     🔴 $f   → chạy riêng để xem ca nào"; done
  fi
fi
exit $hong
