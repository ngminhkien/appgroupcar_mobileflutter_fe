# Search Location + Search Trips FE Flow (Updated with BE breaking changes)

## 1. Muc tieu
- Dong bo FE voi backend moi cho 2 luong dang chay that:
- Search location.
- Search trips.
- FE uu tien dung `stopType` lam nguon chinh khi doc route points.
- Bo query params ngay/gio khoi hanh theo contract hien tai:
- `departureDate` bat buoc.
- `departureTime` tuy chon.

## 2. Enum dung chung (moi)

### 2.1 LocationType
- `Province = 1`
- `District = 2`
- `Ward = 3`
- `BusStation = 4`
- `Landmark = 5`
- `Depot = 6`
- `Other = 99`

Luu y: mapping cu `Landmark/Depot/Other = 4/5/6` da khong con dung.

### 2.2 RouteStopType (tach rieng)
- `Start = 1`
- `Pickup = 2`
- `Transit = 3`
- `Dropoff = 4`
- `End = 5`

## 3. API 1: Search Location

### 3.1 Endpoint
- User search chung:
- `GET /locations`
- Legacy alias: `GET /Location`
- Route/trip point search (driver flow):
- `GET /locations/available-for-route`
- Legacy alias: `GET /Location/available-for-route`

### 3.2 Query params
- `query`
- `isActive`
- `pageNumber`
- `pageSize`

### 3.3 FE implementation
- `LocationSearchScreenArgs.availableForRoute = false`:
- Goi `/locations`.
- `LocationSearchScreenArgs.availableForRoute = true`:
- Goi `/locations/available-for-route`.
- Phan trang, debounce, retry giu nguyen.

## 4. API 2: Search Trips (`GET /api/search/trips`)

### 4.1 Request
- Endpoint khong doi.
- FE van gui:
- `services`
- `pickupLocationId`
- `dropoffLocationId`
- `departureDate`
- `departureTime` (neu co)
- `enableNearbySearch`
- `expandPickupLocation`
- `expandDropoffLocation`
- `pageNumber`
- `pageSize`
- Va cac params tuong thich nguoc (`includeBus`, `includeSharedRide`, `includeTruck`, `departureFrom` khi co gio).

### 4.2 Response route points
- `routePoints` co them `stopType`.
- `pickupAllowed/dropoffAllowed` co the van ton tai de tuong thich tam thoi.
- FE da doi sang:
- Parse `stopType` truoc.
- Derive `pickupAllowed/dropoffAllowed` tu `stopType`.
- Chi fallback sang field bool cu khi khong co `stopType`.

### 4.3 UI Search Results
- Diem don/diem den duoc resolve uu tien theo `stopType` (Pickup/Start va Dropoff/End).
- Hien thi role route point theo `stopType` tren card ket qua.

## 5. Hanh vi Province/District khi search trip
- FE khong can tu expand tree bang tay nua.
- Neu user chon Province/District trong search location, backend tu mo rong theo descendants hop le.
- FE chi gui `pickupLocationId/dropoffLocationId` nhu binh thuong.

## 6. Validation route/create-edit (trang thai code hien tai)
- Backend da doi validation cho create/edit route + offer:
- Route stop chi hop le voi LocationType `3,4,5,6`.
- Bat buoc dung `stopType`, khong gui `pickupAllowed/dropoffAllowed`.
- Bat buoc dung 1 `Start`, 1 `End`, sequence lien tuc...
- Trong codebase FE hien tai, cac man hinh `create_trip/offers` van la UI demo, chua co datasource/repository goi:
- `POST /bus-routes`
- `PUT /bus-routes/{id}`
- `POST /Offer/shared-ride`
- `POST /Offer/shipment`
- Vi vay chua co diem goi API de patch payload thuc te trong nhom nay.

## 7. Files code chinh da cap nhat
- `lib/core/enums/location_type.dart`
- `lib/core/enums/route_stop_type.dart`
- `lib/features/location/domain/entities/location_search_item.dart`
- `lib/features/location/presentation/models/location_search_screen_args.dart`
- `lib/features/location/presentation/cubit/location_search_cubit.dart`
- `lib/features/location/domain/usecases/search_locations_usecase.dart`
- `lib/features/location/domain/repositories/location_repository.dart`
- `lib/features/location/data/repositories/location_repository_impl.dart`
- `lib/features/location/data/models/location_search_request.dart`
- `lib/features/location/data/datasources/location_remote_data_source.dart`
- `lib/features/home/domain/entities/trip_route_point.dart`
- `lib/features/home/presentation/pages/search_results_screen.dart`
- `lib/features/home/presentation/pages/velocity_transit_home_screen.dart`
