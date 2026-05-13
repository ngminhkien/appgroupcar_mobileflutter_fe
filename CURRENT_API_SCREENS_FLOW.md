# Current API Screens Flow

File này chỉ thống kê các màn hình hiện tại đang có API thật hoặc render dữ
liệu lấy từ API. Các màn demo/static như Home, Vé của tôi, Hỗ trợ, Ví, Cài đặt,
Đăng ký doanh nghiệp placeholder không nằm trong danh sách chính.

## 1. Tổng quan route có API

```text
/intro
  -> kiểm tra/refresh phiên đăng nhập

/login
  -> đăng nhập

/register
  -> đăng ký user thường

/profile
  -> menu Cá nhân, có action đăng xuất

/profile/me
  -> render thông tin user từ API

/profile/driver/apply
  -> kiểm tra hồ sơ driver, render trạng thái driver, tạo hồ sơ driver

/profile/driver/vehicles
  -> danh sách xe của tài xế

/profile/driver/vehicles/create
  -> tạo mới xe

/profile/driver/vehicles/:id/edit
  -> cập nhật thông tin xe
```

## 2. Base URL

Base URL lấy từ:

```text
lib/core/constants/api_constants.dart
```

Hiện đang map theo platform:

```text
Android emulator: http://10.0.2.2:5039/
Web:              http://localhost:5039/
iOS/desktop:      http://localhost:5039/
```

## 3. Luồng khởi động app

Route:

```text
/intro
```

Màn hình:

```text
lib/features/intro/presentation/pages/intro_screen.dart
```

Luồng:

```text
IntroScreen
  -> AuthCubit.refreshSession()
  -> AuthRepository.refreshTokens()
  -> AuthRemoteDataSource.refreshToken()
  -> POST /Auth/refresh-token
```

Kết quả:

```text
Refresh token thành công -> /home
Refresh token thất bại hoặc chưa có token -> /login
```

Ghi chú:

```text
Màn này không render dữ liệu API ra UI.
Nó dùng API để quyết định điều hướng.
```

## 4. Màn đăng nhập

Route:

```text
/login
```

Màn hình:

```text
lib/features/auth/presentation/pages/login_screen.dart
```

Luồng:

```text
LoginScreen
  -> LoginBloc
  -> LoginUseCase
  -> AuthRepository.login()
  -> AuthRemoteDataSource.login()
  -> POST /Auth/login
```

Request:

```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

Response dùng trong app:

```text
accessToken
refreshToken
role lấy từ JWT
```

Sau khi login thành công:

```text
Lưu access token, refresh token, role
AuthCubit.setAuthenticated(role)
Đi tới /home
```

Lỗi:

```text
Hiển thị SnackBar từ message API/repository.
```

## 5. Màn đăng ký user thường

Route:

```text
/register
```

Màn hình:

```text
lib/features/auth/presentation/pages/register_screen.dart
```

Luồng:

```text
RegisterScreen
  -> RegisterBloc
  -> RegisterUseCase
  -> AuthRepository.register()
  -> AuthRemoteDataSource.register()
  -> POST /auth/register
```

Không chọn avatar thì gửi JSON:

```json
{
  "fullName": "Nguyen Van A",
  "email": "user@example.com",
  "phoneNumber": "0123456789",
  "password": "123456",
  "avatar": null
}
```

Có chọn avatar thì gửi:

```text
multipart/form-data
fullName
email
phoneNumber
password
avatar
```

Sau khi thành công:

```text
Hiển thị SnackBar thành công
Chuyển về /login
Không lưu token
```

Validate hiện có:

```text
fullName: bắt buộc
email: bắt buộc, đúng định dạng email
phoneNumber: bắt buộc, số 9-11 ký tự
password: tối thiểu 6 ký tự
avatar: tùy chọn, jpg/jpeg/png/webp/heic
```

## 6. Màn Cá nhân

Route:

```text
/profile
```

Màn hình:

```text
lib/features/profile/presentation/pages/profile_screen.dart
```

API/action hiện có:

```text
Đăng xuất
  -> AuthCubit.logout()
  -> AuthRepository.logout()
  -> AuthRemoteDataSource.logout()
  -> POST /Auth/logout
```

Màn này không gọi API để lấy profile. Nó chỉ là menu điều hướng và đọc role
hiện có trong `AuthCubit`.

Các mục điều hướng quan trọng:

```text
Thông tin của tôi       -> /profile/me
Đăng ký trở thành tài xế -> /profile/driver/apply
Đăng ký doanh nghiệp    -> /profile/company/apply, hiện là placeholder
```

## 7. Màn Thông tin của tôi

Route:

```text
/profile/me
```

Màn hình:

```text
lib/features/profile/presentation/pages/my_information_screen.dart
```

Luồng:

```text
MyInformationScreen
  -> UserProfileCubit.loadProfile()
  -> GetUserProfileUseCase
  -> UserRepository.getProfile()
  -> UserRemoteDataSource.fetchProfile()
  -> GET /User/me
```

Header:

```text
Authorization: Bearer <accessToken>
```

Dữ liệu render:

```text
id
fullName
email
phoneNumber
roles
```

State UI:

```text
loading -> CircularProgressIndicator
success -> render thông tin user
failure -> hiển thị lỗi và nút Thử lại
```

Action phụ:

```text
Đăng xuất
  -> POST /Auth/logout
  -> clear local token
  -> /login
```

## 8. Màn đăng ký / hồ sơ tài xế

Route:

```text
/profile/driver/apply
```

Màn hình:

```text
lib/features/driver/presentation/pages/driver_apply_screen.dart
```

### 8.1 Kiểm tra hồ sơ driver hiện có

Khi mở màn:

```text
DriverApplyScreen
  -> DriverApplyCubit.checkExistingDriver()
  -> GetCurrentDriverProfileUseCase
  -> DriverRepository.getCurrentDriverProfile()
  -> UserRepository.getProfile()
  -> GET /User/me
  -> lấy user id
  -> DriverRemoteDataSource.getDriverByUserId()
  -> GET /marketdriver/{userId}
```

Header:

```text
Authorization: Bearer <accessToken>
```

Nếu có driver:

```text
Render trạng thái hồ sơ driver.
Không hiện form tạo mới.
```

Dữ liệu driver render:

```text
name                  -> FE hiển thị là Tên nhà xe
identityNumber
licenseNumber
licenseClass
verificationStatus
licenseDocumentUrl
```

Mapping trạng thái:

```text
1 -> Đang chờ duyệt
2 -> Đã duyệt
3 -> Tạm ngưng
4 -> Bị từ chối
```

Nếu `verificationStatus = 2`:

```text
Hiện nút Tạo chuyến đi.
```

### 8.2 Tạo hồ sơ driver

Nếu chưa có hồ sơ driver:

```text
Hiện form đăng ký trở thành tài xế.
```

Luồng submit:

```text
DriverApplyForm
  -> DriverApplyCubit.submit()
  -> CreateDriverUseCase
  -> DriverRepository.createDriver()
  -> DriverRemoteDataSource.createDriver()
  -> POST /marketdriver
```

Kiểu request:

```text
multipart/form-data
```

Form-data:

```text
name
identityNumber
licenseNumber
licenseClass
verificationStatus = 1
licenseDocumentImg, tùy chọn
```

Label UI:

```text
Backend field: name
FE label: Tên nhà xe
```

Upload ảnh:

```text
image_picker
ImageSource.gallery
licenseDocumentImg
```

Validate:

```text
Tên nhà xe: bắt buộc, lỗi "Vui lòng nhập họ tên tài xế"
Số CMND/CCCD: số, 9-12 ký tự
Số GPLX: bắt buộc
Hạng GPLX: bắt buộc
Ảnh GPLX: tùy chọn, jpg/jpeg/png/webp/heic
```

Sau khi tạo thành công:

```text
Hiển thị SnackBar thành công
Render lại trạng thái hồ sơ driver vừa tạo
Không mở role DRIVER ngay ở FE
Chờ backend/admin duyệt và cấp role trong token
```

### 8.3 Cập nhật hồ sơ driver

Khi đã có hồ sơ driver, màn hình hiển thị nút `Cập nhật thông tin`.

Luồng submit:

```text
DriverApplyScreen (Edit mode)
  -> DriverApplyCubit.updateDriver()
  -> UpdateDriverUseCase
  -> DriverRepository.updateDriver()
  -> DriverRemoteDataSource.updateDriver()
  -> PATCH /marketdriver/update
```

Kiểu request:

```text
multipart/form-data
```

Form-data:

```text
name
identityNumber
licenseNumber
licenseClass
verificationStatus = 1
licenseDocumenImg, tùy chọn
```

Lưu ý:

```text
Field upload cho update là licenseDocumenImg (không có chữ "t").
```

Validate:

```text
Tên nhà xe: bắt buộc, lỗi "Vui lòng nhập họ tên tài xế"
Số CMND/CCCD: số, 9-12 ký tự
Số GPLX: bắt buộc
Hạng GPLX: bắt buộc
Ảnh GPLX: tùy chọn, jpg/jpeg/png/webp/heic
```

Sau khi cập nhật thành công:

```text
Hiển thị SnackBar thành công
Reload dữ liệu driver để render trạng thái mới
```

### 8.4 Quản lý phương tiện (Vehicle)

Routes đề xuất:

```text
/profile/driver/vehicles
/profile/driver/vehicles/create
/profile/driver/vehicles/:id/edit
```

Lưu ý quyền:

```text
Chỉ tài xế đã đăng nhập mới truy cập được.
Driver đã đăng ký (kể cả Pending) vẫn được tạo và xem xe.
```

#### 8.4.1 Danh sách xe của tài xế

Luồng:

```text
VehicleListScreen
  -> VehicleCubit.loadMyVehicles()
  -> GetMyVehiclesUseCase
  -> VehicleRepository.getMyVehicles()
  -> VehicleRemoteDataSource.getMyVehicles()
  -> GET /vehicle/my-vehicles
```

Header:

```text
Authorization: Bearer <accessToken>
```

Response:

```text
VehicleDTO[]
```

State UI:

```text
loading -> list skeleton/loading
empty -> "Chưa có xe nào"
success -> render danh sách xe
failure -> hiển thị lỗi và nút thử lại
```

#### 8.4.2 Tạo mới xe

Luồng submit:

```text
VehicleCreateScreen
  -> VehicleCubit.createVehicle()
  -> CreateVehicleUseCase
  -> VehicleRepository.createVehicle()
  -> VehicleRemoteDataSource.createVehicle()
  -> POST /vehicle/create
```

Kiểu request:

```text
multipart/form-data
```

Form-data:

```text
plateNumber
brand
seatCapacity
vehicleType
urlImage
registrationDocumentUrl
```

Validate:

```text
plateNumber: bắt buộc, tối đa 20 ký tự
brand: bắt buộc, tối đa 50 ký tự
seatCapacity: bắt buộc, 1-50
vehicleType: bắt buộc
urlImage: bắt buộc, file ảnh
registrationDocumentUrl: bắt buộc, file ảnh
```

Sau khi tạo thành công:

```text
Hiển thị SnackBar thành công
Đi về danh sách xe của tài xế
```

#### 8.4.3 Cập nhật xe

Luồng submit:

```text
VehicleEditScreen
  -> VehicleCubit.updateVehicle()
  -> UpdateVehicleUseCase
  -> VehicleRepository.updateVehicle()
  -> VehicleRemoteDataSource.updateVehicle()
  -> PUT /vehicle/{id}
```

Kiểu request:

```text
multipart/form-data
```

Form-data (optional):

```text
plateNumber
brand
seatCapacity
vehicleType
urlImage
registrationDocumentUrl
```

Validate:

```text
Trường nào nhập thì validate như tạo mới, có thể để trống nếu không thay đổi.
Nếu không đổi ảnh/giấy tờ thì không gửi field file.
```

Sau khi cập nhật thành công:

```text
Hiển thị SnackBar thành công
Reload danh sách xe hoặc quay lại danh sách
```

## 9. Interceptor liên quan API protected

File:

```text
lib/core/network/unauthorized_interceptor.dart
```

Luồng khi API protected trả 401:

```text
API trả 401
  -> UnauthorizedInterceptor
  -> AuthCubit.refreshSession()
  -> POST /Auth/refresh-token
  -> lưu token mới
  -> retry request cũ
```

Không retry cho:

```text
/auth/refresh-token
/auth/login
```

## 10. Các màn không đưa vào danh sách chính

Các màn dưới đây hiện chưa gọi API thật hoặc đang là placeholder/static:

```text
/home
/home_search
/search_results
/location_search
/my_trips
/create_trip
/my_tickets
/offers
/support
/forgot_password
/profile/wallet
/profile/settings
/profile/company/apply
```

Ghi chú:

```text
UserProfileScreen cũ trong lib/features/user/presentation/pages/user_profile_screen.dart
vẫn còn file nhưng route hiện tại đã chuyển sang /profile và /profile/me.
```

## 11. Thứ tự người dùng thường gặp

Đăng ký user:

```text
/login
  -> /register
  -> POST /auth/register
  -> /login
```

Đăng nhập và xem thông tin:

```text
/intro
  -> POST /Auth/refresh-token nếu có token cũ
  -> /login nếu chưa có phiên
  -> POST /Auth/login
  -> /home
  -> /profile
  -> /profile/me
  -> GET /User/me
```

Đăng ký tài xế:

```text
/profile
  -> /profile/driver/apply
  -> GET /User/me
  -> GET /marketdriver/{userId}
  -> nếu chưa có hồ sơ: POST /marketdriver
  -> render trạng thái chờ duyệt
```
