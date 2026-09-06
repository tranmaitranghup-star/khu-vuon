#!/usr/bin/env python3
"""Sinh BAN-DO-INDEX.md — bản đồ hàm của public/index.html.

Vì sao có file này: index.html nặng ~118 nghìn token. Đọc trọn nó một lần
là chiếm hơn nửa bộ nhớ làm việc của một phiên, và số đó bị trả lại ở MỌI
lượt còn lại. Bản đồ này nặng khoảng 3 nghìn token: đọc bản đồ, tra ra số
dòng, rồi chỉ đọc đúng đoạn cần.

Chạy lại sau mỗi đợt sửa lớn:  python3 ban-do-index.py
"""
import re
from pathlib import Path

GOC = Path(__file__).parent
NGUON = GOC / "public" / "index.html"
DICH = GOC / "BAN-DO-INDEX.md"

# Cụm chức năng: (tên cụm, mô tả, danh sách tiền tố tên hàm)
# Hàm không khớp tiền tố nào sẽ được xếp theo khoảng dòng của cụm gần nhất.
CUM = [
    ("Tiện ích chung",      "Định dạng giờ, ngày, số; báo lỗi; thông báo nổi", ["phutTuChu", "baoLoi", "kiemCot", "gioRo", "homNay", "thuHai", "ngayDep", "toast", "kiemCat", "nutCho", "venManMo"]),
    ("Đăng nhập và khởi động", "Vào app, tải dữ liệu lần đầu, khung xương chờ", ["dangNhap", "dangXuat", "khoiDong", "truyVanTieuDiem", "taiTieuDiem", "napTieuDiem", "taiLuongDoi", "luongDangGieo", "veKhungXuong"]),
    ("Màn Hôm nay",         "Thẻ việc trong ngày, ô tiêu chí, gieo nhanh, chốt ngày", ["taiHomNay", "veDemTask", "veTomTatLuong", "veOTieuChi", "veTieuChi", "veGieoNhanh", "diemHienTai", "veHomNay", "veKhoiChon", "moChonViec", "chonTick", "layViecVeHomNay", "ghiSo", "chotNgay"]),
    ("Việc: thêm, sửa, xoá", "Bảng việc ở tab Hôm nay và form sửa của nó", ["sxTheoGio", "veTasks", "veChenhLech", "veDongTask", "veFormSua", "moSua", "huySua", "luuSua", "xoaTask", "themTask", "doiTrangThai", "ttCu"]),
    ("Việc cố định theo tuần", "Lưới bảy ngày, nhịp lặp lại, chép tuần trước", ["taiTuan", "veTuan", "luuNhip", "xoaNhip", "chepTuanTruoc", "datSoTuan", "luoiViec", "oCua", "veBangDo"]),
    ("Checklist trong việc cố định", "Mục việc con và dấu tick của chúng", ["truyVanChecklist", "napChecklist", "timMuc", "veLaiChecklist", "khoiChecklist", "cl", "nhac"]),
    ("Chế độ Cả ROVA",      "Lưới nhiều người, biểu đồ đường bốn tuần, xổ chi tiết", ["rv", "vcdDoiCheDo", "taiRova", "veRova"]),
    ("Deep work",           "Màn phiên tập trung: cây lớn dần, chuông tỉnh thức, ba cửa ra", ["dw", "phutPhien", "chonLoi", "veChuong", "hopHoi", "phut", "themNhanh"]),
    ("Khu vườn",            "Bản vẽ vườn, luống, gieo hạt, thu hoạch", ["vuon", "taiVuon", "veNongTrai", "veHanHat", "veLuong", "veCay", "gieoHat", "moGieoNhanh"]),
    ("Bảng cam kết",        "Ba bảng cam kết, kho việc, nhóm gập được", ["congTu", "oSo", "pctChu", "coCotCapTren", "veCamKetDaDong", "veDsLuong", "gapNhom", "veNhomTask", "veBangCamKet", "oNgay", "moLich", "nhanNgay", "soCamKet", "dsach", "sxTaskCK", "veDongTaskCK", "veFormSuaTaskCK", "moSuaTaskCK", "huySuaTaskCK", "luuSuaTaskCK", "datHanKho", "themTaskCK", "dayVaoHomNay"]),
    ("Thẻ người và việc của đội", "Xem việc người khác trong bảng cam kết", ["veTheNguoi", "moTaskDoi", "veXoTaskDoi", "veDongTaskDoi", "moNhanCamKet", "veCamKetTrong", "taiDoi"]),
    ("Thu hoạch và nghiệm thu", "Đóng cam kết phải nộp output, cấp trên bấm Đã nhận", ["tickXong", "chotThuHoach", "moSuaOutput", "luuOutput", "nhanCamKet"]),
    ("Bảng gật, bảng chấm, giọt", "Các ô số nhỏ trên đầu màn hình", ["veBangGat", "veBangCham", "giotCua", "veGiot", "phutDeadline"]),
    ("Timeline",            "Dòng thời gian trong ngày", ["tlDoiNgay", "veTimeline"]),
    ("Tổng quan deep work", "Lưới ô vuông đậm nhạt, chuỗi ngày, giờ vàng", ["tq", "veTongQuan", "tinhGioVang"]),
    ("Danh sách việc",      "Tab danh sách và form sửa cam kết", ["taiTaskList", "biCat", "veDanhSachTask", "tkDong", "veFormSuaCK", "veLaiCK", "moSuaCK", "huySuaCK", "luuSuaCK"]),
    ("Màn Dọn việc hôm qua", "Luật 3b: bốn cửa xử lý việc chưa xong", ["kiemDon", "veDon", "don", "hoan"]),
    ("Điều hướng",          "Chuyển tab", ["moTab", "chuSach"]),
]

P_HAM = re.compile(r"^\s*(?:async\s+)?function\s+([A-Za-z_$][\w$]*)\s*\(")
P_MUI = re.compile(r"^\s*(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?\(")
P_KHOI = re.compile(r"^\s*<(style|script)\b")
P_SEL = re.compile(r"^\s*([.#][\w-]+)")
P_ID = re.compile(r'\bid="([a-zA-Z][\w-]*)"')

# Tiền tố giao diện → màn/khối nó thuộc về. Chỉ để người đọc khỏi đoán;
# thiếu một tiền tố thì cột chú thích bỏ trống, không sao.
MAT = {
    "dw": "Màn deep work", "ck": "Bảng cam kết", "vcd": "Việc cố định theo tuần",
    "rv": "Chế độ Cả ROVA", "tq": "Tổng quan deep work", "don": "Màn Dọn việc hôm qua",
    "cl": "Checklist", "hoi": "Hộp hỏi / hộp thoại", "man": "Khung màn chung",
    "nut": "Nút bấm", "tt": "Huy hiệu trạng thái", "gio": "Ô nhập giờ",
    "vong": "Đồng hồ ba vòng", "luong": "Luống trong vườn", "cua": "Cửa sổ nổi",
    "task": "Thẻ việc", "tk": "Danh sách việc", "tl": "Timeline", "gc": "Ô ghi chú",
    "o": "Ô số nhỏ", "gat": "Bảng gật", "cham": "Bảng chấm", "vuon": "Khu vườn",
}


def tien_to(ten):
    t = ten.lstrip(".#")
    return t.split("-")[0] if "-" in t else t


def quet():
    dong = NGUON.read_text(encoding="utf-8").split("\n")
    ham, khoi = [], []
    for i, l in enumerate(dong, 1):
        m = P_HAM.match(l) or P_MUI.match(l)
        if m:
            ham.append((i, m.group(1)))
            continue
        m = P_KHOI.match(l)
        if m:
            khoi.append((i, m.group(1)))
    return dong, ham, khoi


def xep_cum(ham):
    """Gán mỗi hàm vào một cụm theo tiền tố dài nhất khớp được."""
    bang = {ten: [] for ten, _, _ in CUM}
    con_lai = []
    for ln, ten_ham in ham:
        khop, dai = None, -1
        for ten_cum, _, tien_to in CUM:
            for t in tien_to:
                if ten_ham.startswith(t) and len(t) > dai:
                    khop, dai = ten_cum, len(t)
        (bang[khop] if khop else con_lai).append((ln, ten_ham))
    return bang, con_lai


def ban_do_giao_dien(dong, d_style, d_script):
    """Mặt còn thiếu của bản đồ: sửa giao diện thì tên hàm không giúp được gì.

    Khối <style> chiếm khoảng một phần ba file. Không có bản đồ cho nó thì mỗi
    lần sửa màu, khoảng cách hay bố cục đều phải mò — mà mò nghĩa là đọc trọn.
    """
    if not (d_style and d_script):
        return []
    css = dong[d_style - 1:d_script - 1]

    nhom = {}
    for i, l in enumerate(css, d_style):
        m = P_SEL.match(l)
        if m:
            nhom.setdefault(tien_to(m.group(1)), []).append((i, m.group(1)))

    ids = {}
    for i, l in enumerate(dong, 1):
        for ten in P_ID.findall(l):
            ids.setdefault(ten, i)

    r = ["---\n", "## Bản đồ giao diện — tra ở đây trước khi mò khối `<style>`\n"]
    r.append(f"Khối `<style>` dài **{len(css):,} dòng**. Không có việc nào cần đọc trọn nó. "
             "Tra nhóm ở bảng dưới → `Grep` tên chính xác trên `public/index.html` → `Read` đúng dòng.\n")
    r.append("| Tiền tố | Luật | Dải dòng | Khối nào |")
    r.append("|---|---:|---|---|")
    for t, ds in sorted(nhom.items(), key=lambda x: -len(x[1])):
        if len(ds) < 3:
            continue
        # Hai đầu mút vô dụng khi luật rải khắp file — chỉ ra chỗ TẬP TRUNG:
        # khoảng chứa 80% số luật ở giữa.
        ln = [x[0] for x in ds]
        lo, hi = ln[len(ln) // 10], ln[-1 - len(ln) // 10]
        dai = f"{lo}–{hi}" + (" *(+lẻ)*" if hi - lo < ln[-1] - ln[0] else "")
        r.append(f"| `{t}-` | {len(ds)} | {dai} | {MAT.get(t, '')} |")
    le = sum(len(ds) for t, ds in nhom.items() if len(ds) < 3)
    r.append(f"\n*{le} luật lẻ thuộc {sum(1 for ds in nhom.values() if len(ds) < 3)} tiền tố nhỏ "
             "không kê ở đây — `Grep` thẳng tên là ra.*\n")

    r.append("### Khối có `id` — tra thẳng một mảng màn hình\n")
    r.append(f"{len(ids)} khối. Dạng `tên@dòng-khai-báo`.\n")
    r.append("```")
    ds = sorted(ids.items(), key=lambda x: (tien_to(x[0]), x[1]))
    for i in range(0, len(ds), 4):
        r.append("  ".join(f"#{n}@{ln}" for n, ln in ds[i:i + 4]))
    r.append("```\n")
    return r


def main():
    dong, ham, khoi = quet()
    bang, con_lai = xep_cum(ham)
    d_style = next((i for i, k in khoi if k == "style"), None)
    d_script = next((i for i, k in khoi if k == "script"), None)

    r = []
    r.append("# Bản đồ `public/index.html`\n")
    r.append("> 🤖 **File này do máy sinh — đừng sửa tay.** Chạy lại: `python3 ban-do-index.py`\n>")
    kt_nguon = NGUON.stat().st_size // 3700
    r.append(f"> **Dùng nó để làm gì:** `index.html` nặng khoảng **{kt_nguon} nghìn token**. Đọc trọn file một")
    r.append("> lần là chiếm hơn nửa bộ nhớ làm việc của phiên, và số đó bị trả lại ở **mọi lượt còn lại**.")
    r.append("> Bản đồ này nhẹ hơn khoảng **50 lần**: tra ra số dòng ở đây, rồi đọc đúng đoạn cần")
    r.append("> bằng `Read` có `offset` và `limit`. Xem CLAUDE.md Mục 2f.\n>")
    r.append("> 📍 **Cửa vào của cả phiên là `DOC-TRUOC.md`** — nó chỉ ra loại việc nào đọc đúng file nào.\n")
    r.append(f"**Quy mô:** {len(dong):,} dòng · {len(ham)} hàm\n")
    r.append("| Vùng | Dòng | Số dòng | Khi nào cần đọc |")
    r.append("|---|---:|---:|---|")
    r.append(f"| Phần đầu HTML | 1–{(d_style or 1) - 1} | {(d_style or 1) - 1} | Đổi thẻ meta, tiêu đề trang |")
    if d_style and d_script:
        r.append(f"| Khối `<style>` | {d_style}–{d_script - 1} | {d_script - d_style} | **Chỉ khi sửa giao diện.** Sửa logic thì không cần |")
        r.append(f"| Khối `<script>` | {d_script}–{len(dong)} | {len(dong) - d_script} | **Chỉ khi sửa logic.** Sửa màu sắc, khoảng cách thì không cần |")
    r.append("")
    r.append("---\n")
    r.append("## Hàm theo cụm chức năng\n")

    for ten_cum, mo_ta, _ in CUM:
        ds = sorted(bang[ten_cum])
        if not ds:
            continue
        r.append(f"### {ten_cum}")
        r.append(f"*{mo_ta}* — **dòng {ds[0][0]}–{ds[-1][0]}**, {len(ds)} hàm\n")
        r.append("```")
        for i in range(0, len(ds), 4):
            r.append("  ".join(f"{n}@{ln}" for ln, n in ds[i:i + 4]))
        r.append("```\n")

    if con_lai:
        r.append("### Chưa xếp cụm")
        r.append("*Hàm phụ nằm lồng trong hàm khác, hoặc cụm mới chưa khai trong `ban-do-index.py`*\n")
        r.append("```")
        ds = sorted(con_lai)
        for i in range(0, len(ds), 5):
            r.append("  ".join(f"{n}@{ln}" for ln, n in ds[i:i + 5]))
        r.append("```\n")

    r.extend(ban_do_giao_dien(dong, d_style, d_script))

    r.append("---\n")
    r.append("## Cách đọc cho đúng\n")
    r.append("1. **Tra tên hàm trong bản đồ này** để lấy số dòng.")
    r.append("2. **`Read` với `offset` và `limit`** quanh số dòng đó — thường 80 tới 150 dòng là đủ.")
    r.append("3. **Không tìm thấy tên hàm** thì dùng `Grep` trên `public/index.html`, đừng đọc trọn file.")
    r.append("4. **Sau khi `Edit` thì không đọc lại để kiểm** — `Edit` sai sẽ tự báo lỗi.")
    r.append("5. **Sửa giao diện** thì chỉ đọc trong khối `<style>`; **sửa logic** thì chỉ đọc trong `<script>`.\n")
    DICH.write_text("\n".join(r), encoding="utf-8")
    print(f"✅ {DICH.name}: {len(ham)} hàm, {len(CUM)} cụm, {len(con_lai)} hàm chưa xếp")
    print(f"   Kích thước bản đồ: {DICH.stat().st_size:,} byte (~{DICH.stat().st_size // 3700} nghìn token)")
    print(f"   So với index.html: {NGUON.stat().st_size:,} byte (~{NGUON.stat().st_size // 3700} nghìn token)")


if __name__ == "__main__":
    main()
