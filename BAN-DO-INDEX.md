# Bản đồ `public/index.html`

> 🤖 **File này do máy sinh — đừng sửa tay.** Chạy lại: `python3 ban-do-index.py`
>
> **Dùng nó để làm gì:** `index.html` nặng khoảng **685 nghìn token**. Đọc trọn file một
> lần là chiếm hơn nửa bộ nhớ làm việc của phiên, và số đó bị trả lại ở **mọi lượt còn lại**.
> Bản đồ này nhẹ hơn khoảng **50 lần**: tra ra số dòng ở đây, rồi đọc đúng đoạn cần
> bằng `Read` có `offset` và `limit`. Xem CLAUDE.md Mục 2f.
>
> 📍 **Cửa vào của cả phiên là `DOC-TRUOC.md`** — nó chỉ ra loại việc nào đọc đúng file nào.

**Quy mô:** 38,720 dòng · 1204 hàm

| Vùng | Dòng | Số dòng | Khi nào cần đọc |
|---|---:|---:|---|
| Phần đầu HTML | 1–77 | 77 | Đổi thẻ meta, tiêu đề trang |
| Khối `<style>` | 78–9794 | 9717 | **Chỉ khi sửa giao diện.** Sửa logic thì không cần |
| Khối `<script>` | 9795–38720 | 28925 | **Chỉ khi sửa logic.** Sửa màu sắc, khoảng cách thì không cần |

---

## Hàm theo cụm chức năng

### Tiện ích chung
*Định dạng giờ, ngày, số; báo lỗi; thông báo nổi* — **dòng 11506–31622**, 17 hàm

```
phutTuChu@11506  baoLoiLuong@11523  baoLoiDem@11535  kiemCotDem@11547
baoLoiTask@11555  baoLoiNhip@11570  gioRo@11585  homNay@11594
thuHai@11595  ngayDep@11650  toast@11669  kiemCat@11922
nutCho@11942  venManMo@11985  baoLoiGhiChu@17203  baoLoiDoc@21101
baoLoiPhien@31622
```

### Đăng nhập và khởi động
*Vào app, tải dữ liệu lần đầu, khung xương chờ* — **dòng 11996–12421**, 10 hàm

```
dangNhap@11996  dangXuat@11999  khoiDong@12005  khoiDongThat@12010
truyVanTieuDiem@12133  taiTieuDiem@12136  napTieuDiem@12276  taiLuongDoi@12345
luongDangGieo@12389  veKhungXuong@12421
```

### Màn Hôm nay
*Thẻ việc trong ngày, ô tiêu chí, gieo nhanh, chốt ngày* — **dòng 12469–13131**, 14 hàm

```
taiHomNay@12469  veDemTask@12734  veTomTatLuong@12765  veOTieuChi@12840
veTieuChi@12861  veGieoNhanh@12879  diemHienTai@12898  veHomNay@12905
veKhoiChon@12987  moChonViec@13034  chonTick@13040  layViecVeHomNay@13101
ghiSo@13111  chotNgay@13131
```

### Việc: thêm, sửa, xoá
*Bảng việc ở tab Hôm nay và form sửa của nó* — **dòng 13056–14225**, 12 hàm

```
veFormSuaKho@13056  moSuaKho@13069  huySuaKho@13076  luuSuaKho@13078
sxTheoGio@13458  veTasks@13561  veChenhLech@13627  veDongTask@13664
xoaTask@13738  themTask@13835  doiTrangThai@14214  ttCu@14225
```

### Việc cố định theo tuần
*Lưới bảy ngày, nhịp lặp lại, chép tuần trước* — **dòng 14288–15620**, 9 hàm

```
taiTuan@14288  veTuan@14343  luuNhip@14514  xoaNhip@14581
chepTuanTruoc@14595  datSoTuan@15554  luoiViec@15572  oCua@15582
veBangDo@15620
```

### Checklist trong việc cố định
*Mục việc con và dấu tick của chúng* — **dòng 14923–15270**, 16 hàm

```
truyVanChecklist@14923  napChecklist@14931  timMuc@14949  veLaiChecklist@14956
khoiChecklist@15080  clThanTick@15094  nhac@15101  clThanSua@15108
clXo@15137  clSua@15150  clTick@15158  clDongBoSo@15182
clThemMuc@15230  clSuaMuc@15245  clXoaMuc@15255  clDoi@15270
```

### Chế độ Cả ROVA
*Lưới nhiều người, biểu đồ đường bốn tuần, xổ chi tiết* — **dòng 15719–16516**, 14 hàm

```
rvCong@15719  rvDoiKhung@15994  rvDoiTuan@16002  taiRova@16009
rvTrangThai@16048  veRova@16118  rvVeSo@16195  rvVeChuGiai@16230
rvdTai@16268  rvdVe@16316  rvX@16454  rvVeDuong@16456
rvXo@16484  rvVeChiTiet@16516
```

### Deep work
*Màn phiên tập trung: cây lớn dần, chuông tỉnh thức, ba cửa ra* — **dòng 15209–31789**, 108 hàm

```
dwNhipXongLuot@15209  dwDongDuoc@16636  dwImLangPhut@16646  dwGioKet@16658
dwDapNhip@16667  dwMoPhienMoi@16681  dwNenNay@16724  dwNenLaAnh@16725
dwDatNen@16727  dwHoaQuy@16793  dwDungDongHoa@16812  dwHoaHien@16853
phut@16860  dwHoaSoat@16871  dwVeNenDs@16875  dwNhoTTCu@16895
dwLayTTCu@16908  dwQuenTTCu@16915  dwTaiLaiMan@16920  dwMo@16944
dwDong@16985  dwThemMo@17014  dwCamKetPhien@17055  dwThemLuu@17062
dwNhanTheDi@17105  dwThemVeDs@17111  dwTheLuu@17144  dwNoteMo@17209
dwNoteLuu@17255  dwChonTask@17404  dwChonNhip@17405  dwBoXacNhan@17408
dwCapNhatNut@17409  dwVeUocLuong@17448  dwGhiUocLuong@17471  dwRng@17563
dwTamVoc@17574  dwTron@17585  dwBangMau@17593  dwDoanThan@17606
dwKhuon@17614  dwSvgCay@17677  dwVeHau@17775  dwVeTien@17821
dwVeCay@17839  dwVongVe@17852  phutPhien@17859  dwLamMs@17865
dwPhutDaChay@17868  dwChay@17870  dwMoChonNhip@17969  dwMoNhip@17984
dwVaoPhien@18003  dwVeNhanChay@18067  dwVe@18081  dwVeVongGio@18131
dwVeCuaSoHuy@18152  dwHuySom@18163  dwTraTTCu@18189  chonLoi@18246
dwChuongBam@18250  dwDemTuBam@18288  dwSoatNhacDung@18294  dwChuongLoi@18320
veChuong@18328  dwQuyNai@18457  dwXepNai@18479  dwVeNai@18493
dwChuongMo@18518  dwChuongXoa@18520  dwChuongTongKet@18529  dwThuNho@18547
dwMoLai@18558  dwVeDai@18571  dwVeDaiTam@18590  dwTamToggle@18600
dwTamDung@18602  dwTamDungVe@18620  dwTiepTuc@18631  hopHoiDong@18673
hopHoiMo@18674  dwHoiBoCuoc@18695  dwBoCuoc@18709  dwDongHopGhi@18723
dwKetThuc@18737  dwLuiPhien@18824  dwPhutCua@18857  dwVeTomTatCua@18866
dwSuaPhutCua@18880  dwLuuPhutCua@18897  dwCuaHan@18944  dwNhanNutCua@18958
dwChonCua@18972  dwXacNhanCua@19002  dwTheoTrangThai@19188  dwViecDaDong@19240
dwChanViecDong@19243  dwHuy@19250  dwKhoiPhuc@19282  phut@19318
dwNapChuong@19381  dwSoatPhienXa@19407  themNhanh@19537  phut@29439
dwSuaPhien@31633  dwLuuPhut@31710  dwXoaPhien@31761  dwXoaThat@31789
```

### Khu vườn
*Bản vẽ vườn, luống, gieo hạt, thu hoạch* — **dòng 19573–22524**, 11 hàm

```
vuonVeCuaToi@19573  taiVuon@19580  veNongTrai@22291  veHanHat@22321
veLuong@22359  veLuongCua@22402  veLuongTrongGon@22426  veLuongTrong@22438
veCay@22464  gieoHat@22481  moGieoNhanh@22524
```

### Bảng cam kết
*Ba bảng cam kết, kho việc, nhóm gập được* — **dòng 19768–22027**, 23 hàm

```
congTu@19768  oSo@19781  pctChu@19784  coCotCapTren@19861
veCamKetDaDong@20143  veDsLuong@20238  gapNhom@20361  veNhomTask@20368
veBangCamKet@20415  oNgay@21260  moLich@21271  nhanNgay@21272
soCamKet@21700  dsach@21702  sxTaskCK@21709  veDongTaskCK@21715
veFormSuaTaskCK@21843  moSuaTaskCK@21882  huySuaTaskCK@21889  luuSuaTaskCK@21891
datHanKho@21971  themTaskCK@21986  dayVaoHomNay@22027
```

### Thẻ người và việc của đội
*Xem việc người khác trong bảng cam kết* — **dòng 22045–22849**, 7 hàm

```
veTheNguoi@22045  moTaskDoi@22128  veXoTaskDoi@22163  veDongTaskDoi@22205
moNhanCamKet@22234  veCamKetTrong@22244  taiDoi@22849
```

### Thu hoạch và nghiệm thu
*Đóng cam kết phải nộp output, cấp trên bấm Đã nhận* — **dòng 22632–22769**, 5 hàm

```
tickXong@22632  chotThuHoach@22675  moSuaOutput@22730  luuOutput@22747
nhanCamKet@22769
```

### Bảng gật, bảng chấm, giọt
*Các ô số nhỏ trên đầu màn hình* — **dòng 17528–23189**, 6 hàm

```
veGiotHomNay@17528  veBangGat@22908  veBangCham@22949  giotCua@23162
veGiot@23170  phutDeadline@23189
```

### Timeline
*Dòng thời gian trong ngày* — **dòng 23337–28813**, 2 hàm

```
tlDoiNgay@23337  veTimeline@28813
```

### Tổng quan deep work
*Lưới ô vuông đậm nhạt, chuỗi ngày, giờ vàng* — **dòng 31840–32022**, 5 hàm

```
tqChuoiNay@31840  tqChuoiDai@31851  veTongQuan@31869  tqMach@31990
tinhGioVang@32022
```

### Danh sách việc
*Tab danh sách và form sửa cam kết* — **dòng 32062–32405**, 9 hàm

```
biCat@32062  taiTaskList@32244  veDanhSachTask@32283  tkDong@32315
veFormSuaCK@32361  veLaiCK@32384  moSuaCK@32385  huySuaCK@32390
luuSuaCK@32405
```

### Màn Dọn việc hôm qua
*Luật 3b: bốn cửa xử lý việc chưa xong* — **dòng 12462–36946**, 18 hàm

```
dongBoTenNhip@12462  veDongLink@22602  dongCum@29111  hoanTac@31469
dongThemTask@32403  kiemDon@32513  veDon@32535  veDonDong@32585
donNgayHen@32695  donGhiChu@32702  donNgay@32706  donHanGo@32709
donCho@32710  donDatTT@32712  donLuu@32722  donHanhDong@32755
donDong@32833  dongLe@36946
```

### Điều hướng
*Chuyển tab* — **dòng 38509–38594**, 2 hàm

```
moTab@38509  chuSach@38594
```

### Chưa xếp cụm
*Hàm phụ nằm lồng trong hàm khác, hoặc cụm mới chưa khai trong `ban-do-index.py`*

```
apBanGiaoDien@9797  doiBanGiaoDien@9806  khoiDuocNhin@11402  soNgayLam@11621  di@11673
doCotGio@11747  timTask@11886  t@11888  t@11892  gioTask@11898
gioCong@11908  tenLoai@12199  nhanLoai@12201  optCamKet@12236  veChipCK@12303
o@12312  homQua@12432  chuHan@12795  oCay@13275  oChonTT@13286
ds@13287  veGhiChuChot@13346  tckDoiTT@13390  hoiHan@13392  gcDoiNhan@13407
veOGhiChu@13428  locHien@13470  locNguyen@13475  locChuChip@13482  veOLoc@13498
locBat@13529  locTatCa@13538  locMo@13543  locDong@13544  ghimCaoDs@13555
tkBamDong@13658  manhGio@13790  ghiTaskMoi@13805  loiBaoTaskMoi@13824  vcMo@13886
vcDong@13902  vcDoiLoai@13928  vcVeMau@13958  vcChonMau@13965  vcVeSuKien@13972
vcRanhLai@14037  vcLuuSuKien@14048  ten@14049  vcLuu@14075  goc@14079
boCuPhapLink@14151  tenViecGoNghen@14160  datNghen@14186  gcnDsNhip@14387  ds@14392
gcnMo@14396  ten@14399  gcnVe@14426  lay@14428  vcdHoiKhoi@14457
vcdTimHoacKhai@14490  soTuan@14536  vcdConTrong@14662  vcdOTrong@14666  vcdConChon@14675
vcdTuanChep@14685  veChonViec@14698  vcdVietMoi@14736  vcdMoDanhMuc@14746  veDsDanhMuc@14751
veMonDanhMuc@14772  vcdTick@14787  vcdLay@14799  vcdMoSuaTen@14827  vcdLuuTen@14847
veTrungTen@14880  vcdDungViecDo@14893  nhanLinkGon@14988  theLink@14997  duyetLink@15005
chuCoLink@15026  catGiuLink@15033  chuSoanDuoc@15055  veQtPhien@15064  ds@15067
richKhai@15316  richO@15317  richLuu@15331  richDoc@15342  richPhim@15377
richDan@15396  tho@15399  boiDen@15411  lkCam@15420  lkTheDangDung@15446
lkMoHop@15457  lkThoi@15496  lkBo@15504  lkChen@15513  dia@15515
tenGo@15517  nhan@15538  v@15584  o@15645  cau@15656
oNho@15660  lamMoiCuaToi@15747  rtBanRon@15797  rtTaiLai@15803  rtCoTin@15814
hdTai@15859  hdVe@15872  hdCoTin@15897  rtMoKenh@15902  canVeLaiVuon@15957
vcdVeDem@15963  taiVcd@15982  k@16052  nhomTheoKhoi@16092  o@16209
i@16231  tron@16232  o@16308  o@16340  delta@16396
cau@16527  DW_MAY@16609  xLech@16802  soHoa@16862  id@17056
han@17068  nd@17148  timTaskGC@17189  b@17193  veDsChon@17321
nhan@17350  veDsChonNhip@17364  ds@17365  veDsChonTask@17380  veGhiChuTruoc@17501
s@17564  g@17624  sau@17631  lay@17638  x@17642
moi@17742  ttSv@17905  mach@18258  m1@18299  veDenLong@18365
cuaNenNgoai@18666  ds@19191  vaoDeepTuLuoi@19506  capNhatDaiDoi@19555  ckDoiPhamVi@19566
gapThe@19904  khoCamKet@19929  coCotGiao@19945  veKhoCamKet@19947  moThemKho@20035
veThemVaoKho@20055  gieoVaoKho@20079  khoDatDang@20103  khoNhanViec@20108  khoTuChoi@20109
khoVaoVuon@20113  ckVeKho@20136  ckThaoTac@20633  veKhoHoi@20640  ckDuAnMo@20682
ckDuAnDong@20730  ckDuAnGhi@20732  ckNoteMo@20779  ckNoteTai@20791  hangDoc@20851
ckNoteVe@20881  ckCuaDong@20894  ckLuc@20920  ckTheGoiY@20931  docMotMau@20970
veCkNote@20984  ckDocKhoi@21016  ckVeNguon@21031  ckDocMoSua@21051  ckDocXong@21060
ckDocDoi@21068  ckDocLuu@21076  veCkNoteMau@21112  veCkChonBoThe@21148  ckBoTheTuTao@21167
ckBoTheLuu@21175  ckNoteDatThe@21188  x@21197  ckNoteLuuSua@21205  x@21208
ckNoteXoa@21231  oGio@21316  gioBangEl@21359  gioMocKeTiep@21388  gioPhutRaO@21394
gioBangDung@21402  gioOraPhut@21433  gioBangDat@21441  gioBangTrangTroi@21464  gioBangNgoai@21468
gioBangPhim@21475  nuot@21484  gioBangChon@21499  gioMo@21509  gioDong@21523
gioXoa@21533  gioDat@21537  nhanGio@21555  gioTuO@21557  oTuGio@21566
docThoiLuong@21608  dv@21613  nhatThoiLuong@21633  veChipTL@21645  tlNhatBo@21664
tlCua@21671  tenBoThoiLuong@21679  con@21684  tlNhatXong@21690  gc@21789
goc@21989  han@21993  han@22085  veCoDoiHan@22349  tachLink@22571
chiaOLink@22576  hrefLink@22584  veOLink@22593  ds@22594  lkThem@22609
lkXoa@22617  layChuoiLink@22627  dsCon@22637  out@22677  dsKho@22687
o@22731  ten@22774  doTuNgay@22800  doDoiNac@22813  doSangNut@22819
doVeLai@22840  cua@22873  veSoSanh@23000  dungNhau@23089  datNhan@23090
c@23165  treDeadline@23213  oDeadline@23241  TL_KHUNG@23296  tlMoc@23303
tlDoi@23321  xa@23330  tlDoiKhung@23339  tlDangOHomNay@23354  tlVeHomNay@23356
tlLay@23371  tlTenPhien@23416  t@23419  tlkLay@23444  tlQuenKho@23460
tlTheoKip@23478  lcOptNhom@23567  lcOptLoai@23586  lcLoaiDangKhai@23608  lcTenKhoi@23619
c@23620  lcNhomCuaLich@23626  ds@23627  lcChoToi@23639  lcTenAi@23661
n@23662  lcNguoiCuaLich@23669  ds@23671  lcNhanLoai@23693  lcNhanPhamVi@23704
rieng@23708  ten@23723  lcHopBuoc@23742  lcHopNgay@23757  lcNhanLap@23801
ds@23815  lcLuot@23842  n@23843  lcLay@23851  lcCuaNgay@23954
tlBatRieng@23979  lcCuaNgayVe@23991  lcCuaNgayTu@24001  lcLuotDai@24093  n@24094
lcDaiCuaKhung@24100  lcRanhNhom@24187  lcRanhTim@24206  lcRanhNhanNgay@24249  lcVeRanh@24255
tu@24267  lcChonKhe@24300  laDieuHanh@24403  vhCheDo@24423  vhMoc@24430
vhLuoiThang@24448  vhNgaySauBuoc@24463  vhDangOHomNay@24475  vhXaQua@24480  dbBanCuaNgay@24504
dbRanhChung@24527  dbNhanNgay@24538  dbVe@24546  dbBat@24594  dbChep@24602
lcMoDai@24613  g@24619  vhDoi@24644  vhVeHomNay@24653  vhDauDai@24665
dangOVanHanh@24683  veVanHanh@24687  ai@24703  dbThanDoi@24730  dbThanhCheDo@24739
nut@24741  dbCheDo@24760  dbLocKhoi@24770  dbLocNguoi@24778  dbLocBuoi@24802
dbLoiTrong@24828  dbTenBuoi@24849  dbBayNgay@24876  dbBuoiCuaLuot@24902  t@24904
tb@24905  ds@24907  dbLichCuaDai@24945  dbVeLich@24983  ds@24988
dbTaiXong@25115  dbNacCuaNguoi@25135  dbNacBuoi@25168  dbBuoiCuaDai@25197  dbVeChung@25244
dsDoi@25249  dbKhoiGio@25470  co@25478  dbVeGio@25517  dsDoi@25522
dbTheThang@25638  dbVeThang@25673  dsDoi@25678  lcGhiThamDu@25765  lcTraLoi@25784
lcVeLai@25831  lcChotRoiDong@25871  lcNhanDu@25880  lcXoaThamDu@25909  lcTickXong@25925
lcDuocSua@25954  lcChotViDaXong@25989  l@25991  lcMoBuoi@26002  l@26007
demSo@26043  lcNoO@26264  oTrong@26272  tbTrong@26273  lcOThongBao@26275
goc@26287  veLinks@26306  lcDungNhap@26336  tb@26340  lcNhapDoi@26352
tb@26355  gc@26356  lcNhapChu@26371  lcVeNutLuu@26391  lcLuuCua@26398
tbGhi@26415  gcGhi@26443  lcLuuRoiDong@26472  tbHoiLink@26497  tbThemLink@26522
url@26524  ten@26526  tbBoLink@26533  lcVeLaiGhiChu@26541  l@26544
lcNoteMo@26558  lcNoteDeep@26597  chu@26608  lcNoteGhi@26624  lcNoteDong@26636
lcDongBuoi@26647  lcDongHan@26652  lcHoiBoNhap@26680  lcNgayDich@26697  lcNgayLui@26703
lcNgayGon@26706  lcHoiHuy@26711  l@26713  lcHuyTheo@26731  lcHuy@26743
l@26754  lcSangViec@26805  l@26807  lcSangViecLam@26822  l@26825
lcKeoTha@26892  l@26893  lcDoiTheo@26916  lcThoiKeo@26924  lcDaiKeoMo@26947
lcDaiCot@26974  lcDaiKeoChay@26978  lcDaiKeoTha@27008  lcDaiThaXong@27028  l@27029
lcDaiDoiTheo@27047  lcDaiLuuDoi@27052  l@27054  lcLuuDoi@27097  l@27100
lcTheoViec@27175  lcTheoChuoi@27230  lcMoCua@27310  lcSuaChuoi@27323  l@27324
lcDongCua@27340  lcMoForm@27351  lcLuatMoi@27603  lcLuatTu@27612  lcNgayTu@27624
lcDongTu@27632  lcNhanDay@27653  lcNacDs@27666  lcNacCua@27688  lcVeNac@27709
lcVeThu@27736  lcBatThu@27754  lcDoiNac@27764  lcDoiNgayTu@27787  lcCaNgayDang@27806
lcSoNgayGiua@27813  lcDoiCaNgay@27824  lcDoiDenNgay@27852  lcODonVi@27864  lcOLoi@27869
lcMoTuyChinh@27874  lcTcHuy@27898  lcTcXong@27904  lcTcDat@27917  lcTcBatThu@27923
lcTcBatTuan@27931  lcVeSauLuot@27944  lcVeTc@27958  lcNgaySauNLuot@28017  lcSauLuot@28036
lcChotHan@28057  lcNhomDangKhai@28080  lcGioCong@28097  t@28099  lcSoNgayCach@28114
lcDongBoPhut@28117  tu@28135  den@28136  lcVeNgayDen@28165  tu@28168
lcVeOMau@28179  lcMoHopMau@28184  lcVeQuyen@28201  lcDatQuyen@28221  lcDoiLoai@28231
lcVeMoi@28243  bay@28254  lcDsMoi@28321  lcVeHopMoi@28328  lcMoHopMoi@28352
lcBatMoi@28368  lcBoMoi@28376  lcLuu@28382  lcNapViec@28625  lcDeVieckHomNay@28644
lcDeViec@28673  l@28677  cu@28725  lcDonViec@28760  tasks@28843
tlDauDai@28937  tlXaQua@28980  tlGomNgay@28984  chipCamKet@29020  tlgLayDuAn@29040
tlgKhoangTask@29064  tlgXepLan@29106  tlgLucVN@29136  gio@29144  tlgO@29157
tlgThem@29162  tlgThaVao@29176  t@29188  tlgKeoMo@29234  ngay@29250
tlgKeoVao@29272  tlgKeoThoi@29281  tlgKeoChay@29293  tlgKeoTha@29352  tlgDichNgoai@29389
tlgSangDich@29401  tlgGoGio@29411  tlgVeKho@29438  them@29442  tlgThMo@29460
tlgThVao@29476  tlgThChay@29491  tlgThDo@29508  tlgCuonMep@29532  chay@29538
tlgCuonThoi@29545  tlgThThoi@29551  tlgThTha@29566  tlgThCham@29580  tlgKhoSua@29600
tlgKhoCam@29607  tlgKhoXoa@29618  tlgLuuKhoang@29630  tlgDoGhim@29667  batDau@29674
tlgCuonToiGio@29685  tlgCnCao@29728  tlgCnDat@29737  tlgCnNoi@29746  tlgCnKeoMo@29751
tlgCnKeoChay@29759  tlgCnKeoTha@29762  tlgCnSangThanh@29774  tlgGapKho@29779  tlgVeLaiKho@29790
tlgDaiCaNgay@29804  trong@29807  nhom@29875  tlgDaiChuaGio@29902  tlgThanTuan@29964
tlgThanNgay@29988  tlgKhoiPhien@29999  tlgThanLuoi@30015  co@30200  tongDw@30226
tlgDaiKho@30360  daTre@30426  tvTim@30466  tvOptTT@30482  tvMo@30489
tvDong@30531  veDaiMau@30555  tvVeMau@30578  tvChonMau@30580  lcVeMau@30584
lcChonMau@30586  lcVeChot@30604  lcDatChot@30617  tvKhoangGio@30626  tvVePhu@30646
tvLuu@30675  goc@30678  tvLamNgay@30765  tvXoa@30795  tvSangSuKien@30825
lcNoiViecCu@30884  tltMenuPhim@30922  tltMenuDong@30926  tltMenu@30933  tlThanThang@30955
tlwThanTuan@31073  tlTick@31153  tlgGapDai@31226  tlkGom@31238  tlkVeKhay@31253
xo@31298  tlkVeThan@31308  o@31314  tlkBat@31326  tlkCam@31333
t@31339  tlkSangOngay@31360  tlkKeoOngayVaoTam@31374  htTimTask@31435  htChup@31447
htNhan@31462  tlkBoXuong@31498  tlkDat@31508  tk@31526  tlkMoThem@31542
tlkThoiThem@31547  tlkLuuViecMoi@31549  nd@31551  tlkTraVeKho@31576  tk@31580
o@31919  veTqLuoi@31947  taiHanhTrinh@32048  taiCaNhan@32093  veCaNhan@32102
dat@32104  caNgayDoc@32124  veHoSo@32129  khoi@32136  cap@32137
doc@32138  trong@32167  caMoSua@32182  caHuySua@32183  caLoc@32191
caLoi@32199  m@32200  caLuu@32208  d@32231  moThemTask@32396
ten@32407  nhanNutDon@32502  veODon@32669  gc@32762  htMo@32846
htThoat@32864  htHoanThanh@32870  htGuong@32894  g@32897  cbBaoLau@32945
cbMoVanDe@33015  veChoBan@33029  chuaLoc@33043  choBanMo@33062  cbNhanMo@33073
cbNhanViec@33087  cbTuChoiMo@33105  cbTuChoiGhi@33124  lyDo@33128  cbTraLaiMo@33161
cbRutLai@33175  cbPicMo@33192  cbNhanPic@33205  cbPicTuChoiMo@33217  cbPicTuChoiGhi@33236
lyDo@33240  cbPicTraLaiMo@33255  cbPicRutLai@33268  cbKyNhan@33296  cbMoTheDaXong@33321
nhayToi@33333  duQuangChu@33391  duNacMoc@33401  duDongThanhVien@33467  ds@33468
taiDuAn@33476  duVeLocChu@33508  duLoc@33529  duVeLuoi@33531  pb@33539
duCoMinh@33560  ds@33562  duVeThe@33566  tre@33568  moHoSoDuAn@33676
veHoSoDuAn@33714  dTrao@33774  nhomViec@33876  duMoSua@33961  o@33976
duPicNap@34031  duPicVe@34052  duPicChon@34086  duTraoMo@34091  duTraoGhi@34123
duRutTrao@34137  duLamMoiSauTrao@34150  duLuuSua@34155  duMoMoi@34190  duMoiNguoi@34204
duRutNguoi@34214  duNutTrangThai@34225  nut@34227  duDoiTrangThai@34249  duVeMoc@34259
duCachNhin@34293  duNacCk@34346  duVeDsMoc@34376  trai@34388  duVeCheckMoc@34399
duVeGiaiDoan@34434  thu@34443  duVeHaiNhomViec@34477  thu@34480  duGapKhoi@34517
duTickViec@34528  duVeBang@34550  duVeCot@34582  nutXong@34620  them@34625
duVeViecTrongCot@34642  thu@34648  duDuocGieo@34679  duVeCkThe@34704  duXepMoc@34738
duGhiMoc@34749  duKeoBat@34801  duKeoVao@34830  duKeoDungCotTam@34860  duKeoChay@34871
duKeoNgam@34890  cot@34893  hop@34894  duKeoLan@34907  duKeoThoi@34925
duKeoTha@34941  duNgaBaMo@34981  duNgaBaDong@34992  duNgaBaDi@34996  d@35020
duChonDoRpc@35029  duChonMo@35037  duChonDong@35110  duChonVe@35125  duChonLocDoi@35151
duChonTick@35153  duChonDaLoc@35158  duChonVeDs@35173  duChonVeNut@35187  duChonViKhoa@35200
giao@35213  duChonVeDong@35218  duChonGhi@35255  duGieoMo@35332  dsTV@35344
duGieoDong@35379  duGieoChoMinh@35397  duGieoChoChu@35401  duGieoChuNut@35402  duChoTrong@35426
duGieoGhi@35435  duVeGantt@35518  duCachNgay@35622  duLuiNgay@35625  duTickMoc@35631
duMocThem@35653  duMocMo@35680  duMocDong@35710  duMocLuu@35712  doiVai@35753
duFormMo@35762  duFormDong@35769  duVeForm@35808  duGiaTri@35857  duDocMocKhai@35858
duThemMocKhai@35865  duXoaMocKhai@35866  duLuuDuAn@35875  duMoDong@35915  doHua@35920
duDongDong@35976  duHienLyDo@35981  duLuuDong@35987  napDuAnChoGieo@36060  oChonDuAn@36084
nay@36087  gnGom@36193  hong@36224  dungCT@36227  treo@36288
taiGhiChu@36421  gnLocDs@36433  gnKhiNao@36443  gnVe@36457  dau@36479
gnMotDong@36507  gnVeDoc@36518  gnThemDuoc@36553  gnLoiTrong@36561  gnVeMau@36574
gnChon@36619  gnDatLoc@36624  gnGoTim@36625  gnCT@36626  gnLuuMau@36632
gnXoaMau@36691  gnDatThe@36710  gnThemY@36724  x@36743  gnMoi@36761
gnDiNguon@36772  mocHienNay@36840  veThanhLe@36877  moLe@36945  leNhay@36949
soiThanhLe@36968  btLead@37043  btSuaDuoc@37046  btConHan@37047  btTenNguoi@37048
btNgayGon@37049  btConMayNgay@37053  btConLaiChu@37058  btKhoang@37064  btGonHan@37075
btLaMoi@37084  btHop@37089  btTheTag@37092  btChamMoi@37109  btLinkSach@37120
btLinkChu@37127  btNoiHtml@37136  btTai@37146  btVe@37169  ds@37198
btDoiLoc@37241  btDoiCu@37242  btBung@37243  btMoCua@37248  btDongCua@37262
btVeCua@37271  chip@37272  btChip@37307  btChipChung@37312  btVeCuaGiuNhap@37317
lay@37318  btLuu@37329  ten@37330  link@37338  btGoHoi@37373
btGo@37384  tmLoc@37422  tmTai@37429  tmDoiView@37456  tmChips@37468
veTeam@37476  ks@37490  the@37516  tmVeNghi@37544  tmGapNghi@37561
tmNgay@37566  tmDong@37572  tmMoCua@37574  tmMoThem@37583  tmRuot@37591
tmNgayTrong@37676  tmChonKhoi@37680  tmLuu@37689  tmLoi@37741  m@37742
tmHoiNghi@37756  tmChoNghi@37767  tmMoLaiNghi@37778  vdDaDong@37816  vdQuaHan@37817
vdCuaToi@37819  vdTrongKhoi@37825  vdVanHanh@37826  c@37827  vdSuaDuoc@37830
vdToiNhan@37840  vdToiDong@37843  vdDemDoi@37847  vdXep@37851  vdHop@37858
vdChuanSdt@37865  vdConLai@37873  vdDongHo@37884  vdLap@37899  vdTai@37908
vdVe@37940  vdDoiLoc@38025  vdDoiXong@38026  ktbVeNac@38029  ktbNac@38040
vdMoCua@38050  khoi@38052  vdDongCua@38062  vdVeCua@38073  chip@38075
khoi@38081  vdMoGiao@38131  vdLuuGiao@38144  vdTickKhach@38158  vdBungThem@38162
vdChonKhoi@38163  vdChonNeu@38164  vdNhapDangCo@38166  v@38167  vdOptNguoi@38172
vdLuu@38181  ten@38183  khoi@38186  vdNhan@38229  vdDongVanDe@38243
vdToiXuLy@38280  vdToiBo@38285  vdNutNac@38292  vdLucBl@38315  gio@38319
vdCoTin@38333  vdTaiBl@38342  vdMoChiTiet@38353  vdVeChiTiet@38363  vdGuiBl@38431
noi@38433  vdDatNac@38457  vdChoBenKhac@38476  noi@38478  vdHoiKhongLam@38495
tabSang@38515  chuNhay@38608  luiDangMo@38637  luiNacTrenCung@38643  luiDongBo@38648
luiDongNac@38661
```

---

## Bản đồ giao diện — tra ở đây trước khi mò khối `<style>`

Khối `<style>` dài **9,717 dòng**. Không có việc nào cần đọc trọn nó. Tra nhóm ở bảng dưới → `Grep` tên chính xác trên `public/index.html` → `Read` đúng dòng.

| Tiền tố | Luật | Dải dòng | Khối nào |
|---|---:|---|---|
| `dw-` | 280 | 5175–7735 *(+lẻ)* | Màn deep work |
| `du-` | 189 | 8392–9140 *(+lẻ)* |  |
| `tlg-` | 170 | 3681–4598 *(+lẻ)* |  |
| `lc-` | 112 | 5565–5925 *(+lẻ)* |  |
| `ck-` | 79 | 854–6868 *(+lẻ)* | Bảng cam kết |
| `hoi-` | 74 | 7867–8128 *(+lẻ)* | Hộp hỏi / hộp thoại |
| `dbc-` | 59 | 6330–6459 *(+lẻ)* |  |
| `tm-` | 58 | 9628–9726 *(+lẻ)* |  |
| `vcd-` | 57 | 1159–1707 *(+lẻ)* | Việc cố định theo tuần |
| `rv-` | 55 | 1463–1726 *(+lẻ)* | Chế độ Cả ROVA |
| `nut-` | 51 | 812–9268 *(+lẻ)* | Nút bấm |
| `bt-` | 45 | 9400–9597 *(+lẻ)* |  |
| `lcb-` | 43 | 6477–6660 *(+lẻ)* |  |
| `dbg-` | 42 | 6225–6292 *(+lẻ)* |  |
| `gn-` | 42 | 9290–9362 *(+lẻ)* |  |
| `man-` | 38 | 2304–2890 *(+lẻ)* | Khung màn chung |
| `tq-` | 36 | 3422–3470 *(+lẻ)* | Tổng quan deep work |
| `dbl-` | 36 | 6054–6310 *(+lẻ)* |  |
| `dbt-` | 36 | 6134–6189 *(+lẻ)* |  |
| `tlt-` | 35 | 4681–4852 *(+lẻ)* |  |
| `vd-` | 33 | 9456–9516 *(+lẻ)* |  |
| `dug-` | 32 | 9200–9235 *(+lẻ)* |  |
| `tt-` | 29 | 1330–9178 *(+lẻ)* | Huy hiệu trạng thái |
| `cl-` | 29 | 1275–1375 *(+lẻ)* | Checklist |
| `le-` | 29 | 2460–9279 *(+lẻ)* |  |
| `db-` | 29 | 5976–6048 *(+lẻ)* |  |
| `o-` | 26 | 981–8176 *(+lẻ)* | Ô số nhỏ |
| `don-` | 26 | 6906–8314 *(+lẻ)* | Màn Dọn việc hôm qua |
| `vc-` | 25 | 5329–5718 *(+lẻ)* |  |
| `tlw-` | 23 | 4280–4937 *(+lẻ)* |  |
| `cua-` | 23 | 5291–7125 *(+lẻ)* | Cửa sổ nổi |
| `rvd-` | 22 | 1596–1660 *(+lẻ)* |  |
| `duc-` | 22 | 9095–9119 *(+lẻ)* |  |
| `hn-` | 21 | 2887–3340 *(+lẻ)* |  |
| `mu-` | 19 | 672–770 *(+lẻ)* |  |
| `tlk-` | 18 | 5039–5076 *(+lẻ)* |  |
| `task-` | 16 | 884–1067 *(+lẻ)* | Thẻ việc |
| `lich-` | 16 | 3494–5519 *(+lẻ)* |  |
| `kh-` | 16 | 8815–8870 *(+lẻ)* |  |
| `kho-` | 15 | 2065–8867 *(+lẻ)* |  |
| `the-` | 14 | 549–2119 *(+lẻ)* |  |
| `tabbar-` | 14 | 2405–8679 *(+lẻ)* |  |
| `tv-` | 14 | 5463–6695 *(+lẻ)* |  |
| `ds-` | 13 | 1264–3398 *(+lẻ)* |  |
| `vuon-` | 13 | 1236–2749 *(+lẻ)* | Khu vườn |
| `nhom-` | 12 | 1103–1884 *(+lẻ)* |  |
| `luong-` | 12 | 1757–1785 *(+lẻ)* | Luống trong vườn |
| `gio-` | 12 | 2279–8196 *(+lẻ)* | Ô nhập giờ |
| `sua-` | 12 | 8145–8231 *(+lẻ)* |  |
| `tk-` | 11 | 591–3384 *(+lẻ)* | Danh sách việc |
| `vong-` | 11 | 635–651 *(+lẻ)* | Đồng hồ ba vòng |
| `chon-` | 11 | 1104–1128 *(+lẻ)* |  |
| `lcr-` | 11 | 5944–5963 *(+lẻ)* |  |
| `tc-` | 10 | 2204–8240 *(+lẻ)* |  |
| `vinh-` | 10 | 2232–2266 *(+lẻ)* |  |
| `out-` | 10 | 2355–2368 *(+lẻ)* |  |
| `m-` | 10 | 5441–5448 *(+lẻ)* |  |
| `ss-` | 9 | 2335–2831 |  |
| `cb-` | 9 | 8468–8525 |  |
| `gc-` | 8 | 914–6840 | Ô ghi chú |
| `qtp-` | 8 | 1389–7179 |  |
| `bang-` | 8 | 1794–2053 |  |
| `doi-` | 8 | 2228–2378 |  |
| `nha-` | 8 | 2959–2982 |  |
| `hd-` | 7 | 735–749 |  |
| `nhip-` | 7 | 799–805 |  |
| `khoi-` | 7 | 1046–1083 |  |
| `rvo-` | 7 | 1529–1543 |  |
| `bien-` | 7 | 3016–3029 |  |
| `gieo-` | 6 | 1767–1784 |  |
| `toast-` | 6 | 8267–8289 |  |
| `ht-` | 6 | 8316–8326 |  |
| `hs-` | 6 | 9758–9770 |  |
| `dau-` | 5 | 540–2916 |  |
| `cay-` | 5 | 1740–1749 |  |
| `muc-` | 5 | 2003–2012 |  |
| `nguoi-` | 5 | 2115–2184 |  |
| `do-` | 5 | 2305–2318 |  |
| `giot-` | 5 | 3474–3480 |  |
| `fab-` | 5 | 5101–5113 |  |
| `ckd-` | 5 | 6881–6889 |  |
| `nen-` | 5 | 7536–7543 |  |
| `tuan-` | 4 | 1668–1673 |  |
| `chip-` | 4 | 2173–2177 |  |
| `canh-` | 4 | 2935–2953 |  |
| `tl-` | 4 | 4724–5025 | Timeline |
| `chuong-` | 4 | 7201–7206 |  |
| `ktb-` | 4 | 9436–9445 |  |
| `pn-` | 4 | 9775–9779 |  |
| `chu-` | 3 | 1664–1667 |  |
| `bd-` | 3 | 1703–1706 |  |
| `cho-` | 3 | 2129–2131 |  |
| `tom-` | 3 | 2247–2255 |  |
| `cot2-` | 3 | 2732–2738 |  |
| `ten-` | 3 | 2986–2991 |  |
| `1034c6-` | 3 | 4355–4957 |  |
| `den-` | 3 | 7466–7474 |  |
| `dnb-` | 3 | 9070–9077 |  |

*41 luật lẻ thuộc 32 tiền tố nhỏ không kê ở đây — `Grep` thẳng tên là ra.*

### Khối có `id` — tra thẳng một mảng màn hình

432 khối. Dạng `tên@dòng-khai-báo`.

```
#avatar@9895  #bang-gat@10190  #bang-cham@10197  #bt-cua@10591
#bt-ten-cua@10594  #bt-than@10597  #bt-the@11085  #bt-muc@11087
#bt-nut-moi@11089  #bt-nut-cu@11091  #bt-loc@11095  #bt-ds@11096
#bt-ten@37277  #bt-noi@37279  #bt-tu@37289  #bt-den@37292
#bt-link@37297  #ca-anh@11139  #ca-ten@11140  #ca-vai@11140
#ca-hoso@11146  #ca-email@11177  #cb-the@10070  #cb-dem@10071
#cb-ds@10072  #cb-tuchoi-ly-do@33114  #cb-pic-ly-do@33226  #chao@9869
#ck-pv@10120  #ck-pv-toi@10121  #ck-pv-doi@10122  #ck-cua@10601
#ck-cua-ten@10604  #ck-cua-than@10607  #ck-doc-o@20988  #ck-doc-tt@20994
#ck-doc-luu@20997  #ck-note-sua-o@21115  #ck-bothe-o@21156  #cp-phut@18888
#cua-xong@10522  #cua-chua-xong@10525  #cua-nghen@10528  #db-khu@24731
#dh-so@33747  #dh-dich@33751  #dh-nguoi@33783  #dh-moc@33830
#dh-viec@33882  #dh-hoso@33895  #do-ngay@10161  #do-nac@10169
#don@10560  #don-tieude@10561  #don-thoat@10564  #don-phu@10566
#don-ds@10567  #don-vao@10569  #ds-nhip@9942  #ds-task@10016
#ds-luong@10134  #ds-doi@10244  #ds-tuan@10937  #du-dau-phu@10969
#du-loc-tt@10972  #du-loc-chu@10981  #du-loc-pb@10982  #du-dem@10983
#du-luoi@10990  #du-trong@10991  #du-cua@11208  #du-cua-ten@11211
#du-cua-than@11214  #du-moc-cua@11219  #du-moc-ten@11222  #du-moc-than@11225
#du-gieo-cua@11234  #du-gieo-ten-cua@11237  #du-gieo-than@11240  #du-chon-cua@11249
#du-chon-ten-cua@11252  #du-chon-loc@11255  #du-chon-than@11256  #du-chon-chan@11257
#du-ngaba-cua@11266  #du-ngaba-ten@11269  #du-ngaba-than@11272  #du-dong-cua@11280
#du-dong-ten@11283  #du-dong-than@11286  #du-chon-ds@35139  #du-chon-hong@35140
#du-chon-ok@35144  #du-gieo-ten@35353  #du-gieo-han@35357  #du-gieo-batdau@35359
#du-gieo-ai@35361  #du-gieo-ok@35369  #du-moc-ten-moi@35660  #du-moc-tu@35667
#du-moc-ngay@35669  #du-moc-ly-do@35701  #du-f-ten@35812  #du-f-ketqua@35815
#du-f-pb@35827  #du-f-moc@35840  #du-d-dukien@35929  #du-d-thucte@35931
#du-d-duoc@35937  #du-d-vuong@35939  #du-d-lansau@35941  #du-d-nhan@35960
#duho-ten@11000  #duho-chu@11001  #duho-sua@11006  #duho-than@11008
#dus-ten@33980  #dus-ketqua@33982  #dus-han@33984  #dus-pb@33986
#dus-pic@33990  #dus-mota@33995  #dus-link@33997  #dutr-ruot@33993
#dutr-olai@34078  #dutr-ai@34103  #dw@10255  #dw-nen@10267
#dw-nen-ngang@10275  #dw-vuon@10283  #dw-nai@10290  #dw-den@10294
#dw-nut-dong@10297  #dw-nut-them@10304  #dw-them@10307  #dw-them-o@10314
#dw-them-han-nut@10325  #dw-them-han-chu@10328  #dw-them-han@10329  #dw-them-ds@10335
#dw-nut-note@10343  #dw-note@10346  #dw-note-o@10362  #dw-phu@10373
#dw-vong-chay@10378  #dw-dongho@10382  #dw-nhan@10383  #dw-hom-nay@10387
#dw-chon@10390  #dw-doi-viec@10407  #dw-ds@10410  #dw-ghichu-truoc@10411
#dw-uoc@10421  #dw-uoc-o@10423  #dw-nen-ds@10433  #dw-batdau@10435
#dw-canh-khu@10445  #dw-task@10447  #dw-o-dang@10448  #dw-qt-phien@10449
#dw-hau@10451  #dw-cay@10452  #dw-tien@10453  #dw-vong3@10463
#dw-dongho2@10473  #dw-nhan2@10474  #dw-dang@10481  #dw-do@10482
#dw-chuong-loi@10490  #dw-chuong-ds@10491  #dw-dieu-khien@10497  #dw-nut-dung@10498
#dw-nut-tam@10501  #dw-hinh-tam@10502  #dw-nut-thu@10507  #dw-nut-ketthuc@10511
#dw-canh@10513  #dw-huy-som@10515  #dw-cua@10519  #dw-cua-tomtat@10520
#dw-cua-khoi@10535  #dw-cua-chu@10536  #dw-cua-han-hang@10544  #dw-cua-luu@10545
#dw-cua-lui@10549  #dw-dai@11302  #dw-dai-gio@11304  #dw-dai-viec@11305
#dw-dai-tam@11306  #dw-suong@17780  #dw-hao@17784  #dw-xa@17788
#fab@10890  #fab-them@10891  #gat-tieu-de@10182  #gcn-ds@14402
#gieo-ten-kho@20061  #gn-tim@11020  #gn-chip@11023  #gn-hong@11024
#gn-ds@11026  #gn-doc@11027  #gn-o@36576  #goi-y-nhip@10938
#hn-mu@9867  #hn-hiendien@9914  #hn-hang2@9939  #hn-codinh@9940
#hn-viec@9945  #hn-loc-chip@9958  #hn-loc-chu@9961  #hn-loc-nen@9966
#hn-loc@9967  #hoi-nen@10887  #hoi-hop@10887  #ht-them@10568
#ic-homnay@11311  #ic-camket@11312  #ic-duan@11313  #ic-vcd@11314
#ic-doi@11315  #kho-nd@13058  #kho-od@13060  #khoi-chon@9975
#kq-chu@9924  #kq-mota@9925  #ktb-nac@11071  #lc-cua@10719
#lc-ten-cua@10722  #lc-than@10725  #lc-tc-cua@10735  #lc-tc-ten@10738
#lc-tc-than@10741  #lc-ten@13980  #lc-gio@13980  #lc-tu@13980
#lc-loai@13989  #lc-ai-nhan@13993  #lc-pv-hang@13995  #lc-pv@13995
#lc-moi-hang@13997  #lc-moi-nut@13997  #lc-moi-ds@14000  #lc-ranh-o@14007
#lc-db@14013  #lc-phut@14019  #lc-lap@14021  #lc-thu-o@14027
#lc-o-mau@27399  #lc-mau-hop@27405  #lc-dai@27405  #lc-gio-o@27421
#lc-toi-chu@27424  #lc-gio-den-o@27425  #lc-den-ngay-o@27436  #lc-den-ngay@27437
#lc-ca-ngay@27446  #lc-chot@27483  #lc-quyen@27524  #lc-ghi-chu@27528
#lc-tc-buoc@27973  #lc-moi-hop@28361  #lcb-cua@10749  #lcb-ten@10752
#lcb-cong@10757  #lcb-than@10760  #lcb-note@10776  #lcb-note-ten@10779
#lcb-note-dw@10789  #lcb-note-o@10794  #lcb-note-ghi@10798  #lcb-tb-khu-truoc@26113
#lcb-tb-khu-sau@26146  #lcb-luu@26199  #lcr-tieu@14009  #lcr-ds@14011
#le-moc@11293  #le-nut@11295  #lk-ten@15472  #lk-dia@15477
#login-loi@9845  #man-mo@9829  #man-login@9837  #man-homnay@9863
#man-camket@10096  #man-doi@10159  #man-vcd@10917  #man-duan@10967
#man-duanho@10997  #man-ghichu@11016  #man-bangtin@11065  #man-vanhanh@11100
#man-team@11110  #man-toi@11137  #muc-ck-chu@10132  #ngay-chu@9869
#nut-vh@9882  #nut-bt@9884  #nut-so@9886  #nut-tm@9892
#nut-ban@9894  #nut-chot@10084  #rv-so@10949  #rv-lui@10952
#rv-tuan-chu@10953  #rv-toi@10954  #rv-khung@10957  #rv-luoi@10960
#rv-chu-giai@10961  #rvd-the@10233  #rvd-phu@10235  #rvd-so@10236
#rvd-gop@10237  #rvd-ds@10238  #rvd-chu@10239  #sp-phut@31700
#ss-the@10214  #ss-bd@10216  #tabbar@11310  #tb-link-ten@26506
#tb-link-url@26510  #tck-nd@21856  #tck-ngay-o@21858  #tck-tt@21860
#tck-hango-hang@21866  #thanh-le@11293  #the-lich@10022  #the-tk-ds@10064
#the-do-vcd@10922  #the-vcd@10929  #the-vcd-doi@10946  #the-tq@11148
#the-vuon-gat@20156  #them-nd@9986  #them-od-chip@9996  #them-od-so@9997
#them-od@9998  #them-han-nut@10000  #them-han-chu@10002  #them-han@10003
#them-gio-o@10012  #tk-timeline@10033  #tk-ds-dem@10066  #tk-ds@10067
#tk-xong@13610  #tk-lk@22598  #tk-output@22657  #tl-cam@10884
#tlk-o-them@31273  #tm-pv@11116  #tm-do@11120  #tm-khu@11121
#tm-cua@11192  #tm-cua-ten@11195  #tm-cua-than@11198  #tm-hoten@37610
#tm-ten@37614  #tm-sinh@37618  #tm-dt@37621  #tm-email@37628
#tm-vai@37638  #tm-cap@37643  #tm-lead@37649  #tm-dh@37654
#tm-qt@37659  #toast-chong@11318  #tq-dem@11150  #tq-so@11156
#tq-cuon@11162  #tq-thang@11163  #tq-luoi@11164  #tq-cau@11168
#tq-cat@11169  #tq-mach@11186  #tv-cua@10804  #tv-ten@10807
#tv-nd@10834  #tv-od@10838  #tv-ngay-nut@10840  #tv-ngay-chu@10843
#tv-ngay@10844  #tv-gio-o@10851  #tv-den-o@10854  #tv-tt@10855
#tv-phu@10858  #tv-gc-o@10864  #tv-dai@10866  #vc-ten@10623
#vc-nd@10632  #vc-the-viec@10640  #vc-the-sk@10642  #vc-han-nut@10651
#vc-han-chu@10654  #vc-han@10655  #vc-gio-o@10659  #vc-rieng-viec@10672
#vc-od@10673  #vc-rieng-sk@10675  #vc-dai@10679  #vc-chan@10686
#vcd-so@10923  #vcd-bang@10924  #vcd-dem@10930  #vcd-chon@10936
#vcd-doi@10948  #vcd-ten-o@14836  #vd-cua@10581  #vd-ten-cua@10584
#vd-than@10587  #vd-the@11073  #vd-muc@11075  #vd-nut-xong@11077
#vd-loc@11080  #vd-ds@11081  #vd-nut-moi@11082  #vd-ten@38086
#vd-ai@38101  #vd-co-khach@38105  #vd-khach@38109  #vd-mo@38113
#vd-muc-o@38115  #vd-lap@38121  #vd-bl-o@38419  #vh-khu@11103
#viec-cua@10620  #vong-chay@9920  #vong-so@9921  #vuon-tom-tat@10105
#vuon-kho@10147  #vuon-le@10149  #vuon-gat@10154  #vuon-kho-luoi@19989
```

---

## Cách đọc cho đúng

1. **Tra tên hàm trong bản đồ này** để lấy số dòng.
2. **`Read` với `offset` và `limit`** quanh số dòng đó — thường 80 tới 150 dòng là đủ.
3. **Không tìm thấy tên hàm** thì dùng `Grep` trên `public/index.html`, đừng đọc trọn file.
4. **Sau khi `Edit` thì không đọc lại để kiểm** — `Edit` sai sẽ tự báo lỗi.
5. **Sửa giao diện** thì chỉ đọc trong khối `<style>`; **sửa logic** thì chỉ đọc trong `<script>`.
