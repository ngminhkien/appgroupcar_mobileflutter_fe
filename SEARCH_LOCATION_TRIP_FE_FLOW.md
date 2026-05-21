# Search Location + Search Trips FE Flow

## 1. Muc tieu
- Chuan hoa luong tim dia diem (`GET /Location`) va luong tim chuyen (`GET /api/search/trips`) theo kien truc hien tai cua app.
- Tach rieng ngay/gio khoi hanh o FE:
- `departureDate`: bat buoc.
- `departureTime`: tuy chon (co the bo trong neu user chi chon ngay).

## 2. Cong nghe va kien truc da dung
- Flutter + `flutter_bloc`:
- `LocationSearchCubit`: quan ly state tim dia diem.
- `HomeSearchCubit`: quan ly form tim chuyen trang chu.
- `TripSearchCubit`: quan ly ket qua tim chuyen.
- Dio:
- Goi `GET /Location` va `GET /api/search/trips`.
- SharedPreferences:
- Luu `lastPickupLocation`, `lastDropoffLocation`.
- Luu `lastServices`, `lastDepartureDate`, `lastDepartureTime`, `lastNearbyFlags`.
- Luu `recentSearches`.
- Kien truc feature-based:
- `presentation -> domain -> data`.
- UI khong goi API truc tiep.

## 3. API 1: Search Location (`GET /Location`)

### 3.1 Query params map
- `query`
- `isActive`
- `pageNumber`
- `pageSize`

### 3.2 State va hanh vi
- `idle`: chua nhap tu khoa.
- `loading`: dang goi API sau debounce 400ms.
- `success`: co danh sach ket qua, cho phep chon item.
- `empty`: khong co ket qua.
- `error`: loi API, hien snackbar + nut retry.

### 3.3 UI flow
1. User nhap text (>= 1 ky tu).
2. Debounce 400ms.
3. Goi API `/Location`.
4. Render list.
5. User chon item => `context.pop(LocationSearchItem)`.
6. Man hinh goi nhan duoc `id/code/displayName`.

### 3.4 Phan trang
- Scroll den gan cuoi list se goi `loadMore()`.
- Noi ket qua trang sau vao danh sach hien tai.

## 4. API 2: Search Trips (`GET /api/search/trips`)

### 4.1 Query params map
- `services=Bus&services=SharedRide...`
- `pickupLocationId`
- `dropoffLocationId`
- `departureDate` (YYYY-MM-DD, bat buoc)
- `departureTime` (HH:mm, tuy chon)
- `enableNearbySearch`
- `expandPickupLocation`
- `expandDropoffLocation`
- `pageNumber`
- `pageSize`
- Tuong thich query cu:
- `includeBus`
- `includeSharedRide`
- `includeTruck`
- Tuong thich cu them:
- Neu co `departureTime`, FE gui them `departureFrom` (ISO datetime).

### 4.2 State va hanh vi
- `loading`: render skeleton list.
- `success`: render danh sach chuyen.
- `empty`: render empty state.
- `error`: render loi + retry.
- `isPaging`: hien loading o cuoi list khi load them trang.

## 5. Man hinh 1: Home Search (Trang chu)

### 5.1 Truong form
- `selectedServices` (multi select).
- `pickupLocation`, `dropoffLocation` (chon qua `LocationSearchScreen`).
- `departureDate` (bat buoc).
- `departureTime` (tuy chon, co nut bo gio).
- `enableNearbySearch`, `expandPickupLocation`, `expandDropoffLocation`.

### 5.2 Validate
- Phai chon it nhat 1 service.
- Phai chon du pickup/dropoff.
- `departureDate` khong duoc < hom nay.
- Neu chon gio va ngay la hom nay:
- Gio khong duoc < thoi diem hien tai.
- Nut `Tim chuyen di` bi disable neu form chua hop le.

### 5.3 Local storage
- Load gia tri da dung lan truoc khi mo man hinh.
- Tu dong save lai khi user doi service/ngay/gio/co tim lan can.

## 6. Man hinh 2: Search Results

### 6.1 Input
- Nhan `TripSearchScreenArgs` tu Home Search:
- request params
- display name pickup/dropoff

### 6.2 Flow
1. Tao `TripSearchCubit`.
2. Tu dong goi `search(request)` khi vao man.
3. Hien loading -> success/empty/error.
4. Scroll cuoi danh sach -> `loadMore()`.
5. Nhan `reference.serviceCode + reference.detailApi` de dieu huong chi tiet.

## 7. Luong tong quan end-to-end
1. User mo Home.
2. Chon service.
3. Chon pickup/dropoff qua Location Search.
4. Chon ngay khoi hanh (gio co the bo trong).
5. Bam Tim chuyen.
6. FE goi `/api/search/trips` voi bo params hop le.
7. Hien ket qua + phan trang + retry khi loi.

## 8. Files code chinh da cap nhat
- `lib/features/location/presentation/pages/location_search_screen.dart`
- `lib/features/location/presentation/cubit/location_search_cubit.dart`
- `lib/features/home/presentation/pages/velocity_transit_home_screen.dart`
- `lib/features/home/presentation/cubit/home_search_cubit.dart`
- `lib/features/home/presentation/pages/search_results_screen.dart`
- `lib/features/home/domain/entities/trip_search_request.dart`
- `lib/features/home/data/datasources/home_search_local_data_source.dart`
