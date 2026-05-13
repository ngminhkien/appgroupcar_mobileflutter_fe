# Auth, Profile, Driver Apply Guide

File này ghi lại hướng thiết kế mới cho đăng ký tài khoản, phần Cá nhân, và
luồng đăng ký trở thành tài xế/doanh nghiệp.

## 1. Quyết định chính

Màn hình đăng ký ở phần đăng nhập chỉ dùng để đăng ký user bình thường.

Không đặt đăng ký tài xế và doanh nghiệp ở màn hình `/register` nữa.

Luồng đúng:

```text
Người dùng đăng ký tài khoản thường
  -> đăng nhập app với role USER
  -> vào Cá nhân
  -> chọn đăng ký trở thành Tài xế hoặc Doanh nghiệp
  -> gửi hồ sơ apply
  -> chờ admin duyệt
  -> sau khi duyệt, lần đăng nhập/refresh token sau sẽ có thêm role/chức năng
```

Lý do:

```text
Driver/company cần duyệt.
Người dùng vẫn cần đăng nhập app như USER để xem trạng thái hồ sơ.
Sau khi được duyệt, app mới mở thêm nút/chức năng theo role.
```

## 2. Public register chỉ tạo user

Route:

```text
/register
```

Mục tiêu:

```text
Chỉ tạo tài khoản user bình thường để mua vé/sử dụng app.
```

API:

```text
POST /auth/register
```

Request không chọn avatar:

```json
{
  "fullName": "Nguyen Van A",
  "email": "user@example.com",
  "phoneNumber": "0123456789",
  "password": "123456",
  "avatar": null
}
```

Sau khi đăng ký thành công:

```text
Hiển thị thông báo thành công
Chuyển về /login
Không lưu token/local storage
```

## 3. Thiết kế lại phần Cá nhân

Không để toàn bộ logic trong một màn hình `UserProfileScreen` quá lớn.

Nên tách phần Cá nhân thành một feature có nhiều mục:

```text
lib/features/profile/
  presentation/
    pages/
      profile_screen.dart
      my_information_screen.dart
      wallet_screen.dart
      settings_screen.dart
      driver_apply_screen.dart
      company_apply_screen.dart
```

Gợi ý route:

```text
/profile                 -> màn hình menu Cá nhân
/profile/me              -> Thông tin của tôi, mới gọi API GET /User/me
/profile/wallet          -> Ví
/profile/settings        -> Cài đặt
/profile/driver/apply    -> Đăng ký trở thành tài xế
/profile/company/apply   -> Đăng ký doanh nghiệp
```

Màn hình `/profile` chỉ nên là menu điều hướng, không gọi quá nhiều API.

Màn hình `/profile/me` mới gọi API lấy thông tin user:

```text
GET /User/me
```

Như vậy sau này thêm Ví, Cài đặt, Hồ sơ tài xế, Hồ sơ doanh nghiệp sẽ không làm
màn hình Cá nhân bị rối.

## 4. Menu Cá nhân nên hiển thị gì

Với user bình thường:

```text
Thông tin của tôi
Ví
Đăng ký trở thành tài xế
Đăng ký doanh nghiệp
Cài đặt
Đăng xuất
```

Với user đã apply tài xế nhưng đang chờ duyệt:

```text
Thông tin của tôi
Ví
Hồ sơ tài xế: Đang chờ duyệt
Đăng ký doanh nghiệp
Cài đặt
Đăng xuất
```

Với user đã được duyệt role DRIVER:

```text
Thông tin của tôi
Ví
Hồ sơ tài xế
Tạo chuyến đi / tạo offer
Đăng ký doanh nghiệp nếu vẫn cho phép
Cài đặt
Đăng xuất
```

Việc hiện thêm nút phải dựa theo role/token hoặc trạng thái hồ sơ lấy từ API.

## 5. Luồng đăng ký tài xế

Chỉ user đã đăng nhập mới được gửi hồ sơ tài xế.

Route đề xuất:

```text
/profile/driver/apply
```

Feature đề xuất:

```text
lib/features/driver/
  data/
    datasources/
      driver_remote_data_source.dart
    models/
      create_driver_request.dart
      driver_response.dart
  domain/
    entities/
      driver_profile.dart
    repositories/
      driver_repository.dart
    usecases/
      create_driver_usecase.dart
      get_driver_by_user_id_usecase.dart
  presentation/
    bloc/
      driver_apply_bloc.dart
      driver_apply_event.dart
      driver_apply_state.dart
    pages/
      driver_apply_screen.dart
      driver_profile_screen.dart
```

## 6. API tạo driver

Endpoint:

```text
POST /marketdriver
```

Kiểu gửi:

```text
multipart/form-data
```

Form-data fields:

```text
name
identityNumber
licenseNumber
licenseClass
verificationStatus
licenseDocumentImg
```

Lưu ý UI:

```text
Field backend là name.
FE hiển thị label là "Tên nhà xe".
```

Request ví dụ:

```text
name: Nguyen Van B
identityNumber: 123456789
licenseNumber: A1234567
licenseClass: B2
verificationStatus: 1
licenseDocumentImg: file ảnh, tùy chọn
```

`verificationStatus` khi user tự gửi hồ sơ nên mặc định:

```text
1 = Pending
```

Không cho user tự chọn `Active`, `Inactive`, `Rejected`.

## 7. Response tạo driver

Success:

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": "guid",
    "name": "Nguyen Van B",
    "identityNumber": "123456789",
    "licenseNumber": "A1234567",
    "licenseClass": "B2",
    "verificationStatus": 1,
    "licenseDocumentUrl": "https://..."
  }
}
```

Nếu lỗi CMND/CCCD đã tồn tại, FE nên hiển thị:

```text
Số CMND đã tồn tại
```

## 8. State cho đăng ký tài xế

Nên có state:

```text
name
identityNumber
licenseNumber
licenseClass
verificationStatus
licenseDocumentImgPath
status
errorMessage
successMessage
```

Status:

```text
initial
loading
success
failure
```

## 9. Validate đăng ký tài xế

Label FE và lỗi:

```text
Tên nhà xe:
  Không được trống
  "Vui lòng nhập họ tên tài xế"

Số CMND/CCCD:
  Không được trống
  Chỉ gồm số
  "Số CMND/CCCD không hợp lệ"

Số GPLX:
  Không được trống
  "Vui lòng nhập số GPLX"

Hạng GPLX:
  Không được trống
  "Vui lòng nhập hạng GPLX"

Ảnh GPLX:
  Tùy chọn
  Chấp nhận jpg/jpeg/png/webp/heic
```

Ghi chú: dù message theo backend ghi "họ tên tài xế", UI label vẫn là
`Tên nhà xe` theo yêu cầu.

## 10. Upload ảnh GPLX từ Photos

Tái sử dụng dependency đã cài:

```yaml
image_picker: ^1.1.2
```

Mẫu chọn ảnh:

```dart
final image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  imageQuality: 85,
  maxWidth: 1200,
);
```

Khi gửi API:

```dart
FormData.fromMap({
  'name': name,
  'identityNumber': identityNumber,
  'licenseNumber': licenseNumber,
  'licenseClass': licenseClass,
  'verificationStatus': 1,
  'licenseDocumentImg': await MultipartFile.fromFile(image.path),
});
```

Nếu không chọn ảnh thì không gửi field `licenseDocumentImg`.

## 11. API lấy thông tin driver

Endpoint:

```text
GET /marketdriver/{id}
```

Trong đó `{id}` là user id.

Response ví dụ:

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": "4a557665-96c2-49c4-4b77-08deaa962235",
    "identityNumber": "024205000473",
    "name": "Ah Mi So",
    "licenseNumber": "010243085472",
    "licenseClass": "A1",
    "verificationStatus": 2,
    "licenseDocumentUrl": "https://res.cloudinary.com/dq0taj0x9/image/upload/v1777979949/driver-avatars/ytsfixnkrim6fpomomxd.png",
    "user": null,
    "vehicles": [],
    "createdAt": "2026-05-05T11:19:09.554844",
    "lastUpdateAt": "2026-05-05T18:02:40.6948288",
    "deleteAt": null
  }
}
```

Mục đích:

```text
Kiểm tra user đã có hồ sơ driver chưa.
Hiển thị trạng thái đang chờ duyệt / đã duyệt / bị từ chối.
Quyết định có hiện nút apply driver nữa hay không.
```

## 12. Mapping trạng thái driver

Backend enum:

```text
Pending = 1
Active = 2
Inactive = 3
Rejected = 4
```

FE hiển thị:

```text
1 -> Đang chờ duyệt
2 -> Đã duyệt
3 -> Tạm ngưng
4 -> Bị từ chối
```

Logic UI:

```text
Pending:
  Không cho gửi lại hồ sơ mới
  Hiển thị trạng thái đang chờ duyệt

Active:
  Hiện thêm chức năng tài xế nếu token/role đã có DRIVER

Inactive:
  Hiển thị trạng thái tạm ngưng
  Không hiện chức năng tạo offer

Rejected:
  Có thể cho gửi lại hồ sơ hoặc chỉnh sửa, tùy backend hỗ trợ
```

## 13. Luồng role sau khi duyệt

Khi user đăng ký driver thành công:

```text
User vẫn là USER
Driver profile có verificationStatus = Pending
App chỉ hiển thị trạng thái chờ duyệt
```

Khi admin duyệt:

```text
Backend cập nhật driver thành Active
Backend nên cấp thêm role DRIVER cho user
User đăng nhập lại hoặc refresh token
Token mới có role DRIVER
App đọc role và hiện thêm nút/chức năng tài xế
```

Không nên tự mở chức năng tài xế ở FE chỉ vì API create driver trả success.

## 14. Đăng ký doanh nghiệp

Không đặt trong màn hình `/register`.

Nên đặt trong:

```text
/profile/company/apply
```

Luồng giống driver:

```text
User đăng nhập
Vào Cá nhân
Chọn Đăng ký doanh nghiệp
Nhập form doanh nghiệp
Gửi hồ sơ
Chờ admin duyệt
Sau khi duyệt, login/refresh token có thêm role/chức năng doanh nghiệp
```

Hiện chưa có contract API doanh nghiệp trong tài liệu này, nên chưa nên code
hard API. Khi có API, tạo feature riêng:

```text
lib/features/company/
```

## 15. Thứ tự triển khai đề xuất

1. Sửa `/register` chỉ còn form tạo user thường.
2. Tách `/profile` thành menu Cá nhân.
3. Chuyển API `GET /User/me` sang màn `/profile/me`.
4. Tạo feature `driver`.
5. Làm màn `/profile/driver/apply`.
6. Gọi `POST /marketdriver` bằng multipart/form-data.
7. Gọi `GET /marketdriver/{userId}` để hiển thị trạng thái hồ sơ.
8. Cập nhật menu/nút theo role và trạng thái driver.
9. Khi có API company, làm tương tự driver trong feature `company`.

## 16. Các lệnh cần chạy sau khi code

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Nếu muốn cài lên emulator:

```bash
flutter install --debug -d emulator-5554
```
