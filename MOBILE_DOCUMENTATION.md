# Mobile Documentation - AppGroupCar Flutter FE

Tai lieu nay la chuan lam viec cho repo mobile Flutter
`appgroupcar_mobileflutter_fe`. Pham vi cua repo nay chi la mobile/frontend.
Neu co nhac den backend C# .NET thi do chi la REST API ben ngoai ma app goi
toi, khong phai codebase hay kien truc cua du an mobile nay.

Muc tieu cua tai lieu:

- Giup developer moi hieu nhanh app dang co.
- Thong nhat cach chia folder, dat ten, viet UI, state, API, DI.
- Lam checklist truoc khi viet feature moi hoac giao viec cho nguoi khac.

## 1. Tong quan hien tai

- Project: Flutter app `appgroupcar_mobileflutter_fe`.
- Description trong `pubspec.yaml`: `Mobile app for AppGroupCar`.
- Package name: `appgroupcar_mobileflutter_fe`.
- Entry point: `lib/main.dart`.
- DI/service locator: `get_it` trong `lib/di/injection.dart`.
- Navigation: `go_router` trong `lib/core/routes/app_router.dart`.
- State management: `flutter_bloc`, dang dung ca `Bloc` va `Cubit`.
- API client: `dio`.
- Local storage: `shared_preferences`, boc lai bang `AuthTokenStorage`.
- Responsive UI: `flutter_screenutil`, design size `390 x 884`.
- Theme chung: `lib/core/theme/app_theme.dart` va `app_colors.dart`.

## 2. Ranh gioi voi backend va du an cu

Repo nay khong lien quan den du an .NET cu ve mat source code.

Quy uoc khi lam viec:

- Khong copy model/entity/service tu backend .NET sang Flutter mot cach may moc.
- Chi dua vao API contract: endpoint, method, request body, response body,
  status/error.
- Moi logic UI/mobile phai nam trong Flutter repo nay.
- Moi logic nghiep vu backend phai nam o backend, mobile chi validate nhung gi
  can cho UX va goi API.
- Neu API thay doi, update data model/datasource/repository trong feature tuong
  ung, khong sua tung man hinh rieng le.

Backend hien tai duoc app goi nhu REST API qua `Dio`. Base URL nam o
`lib/core/constants/api_constants.dart`:

- Web: `http://localhost:5039/`
- Android emulator: `http://10.0.2.2:5039/`
- iOS/desktop/khac: `http://localhost:5039/`

## 3. Tech stack

Runtime dependencies dang khai bao:

- `flutter_bloc`: state management.
- `equatable`: so sanh state/entity/value object.
- `go_router`: routing va redirect theo auth.
- `dio`: HTTP client.
- `shared_preferences`: local key-value storage.
- `get_it`: dependency injection/service locator.
- `json_annotation`: annotation cho JSON model.
- `flutter_screenutil`: responsive spacing/font/size.
- `flutter_svg`: SVG assets neu can.
- `logger`: dependency co san, chua thay duoc dung trong code hien tai.
- `flutter_dotenv`: dependency co san, chua thay duoc dung trong code hien tai.
- `awesome_dialog`: hien friendly error dialog trong `main.dart`.

Dev dependencies:

- `flutter_lints`: lint mac dinh cua Flutter.
- `build_runner` va `json_serializable`: generate JSON code cho model.

Luu y:

- `AppTheme` dang set `fontFamily: 'Inter'`, nhung `pubspec.yaml` chua khai
  bao font asset. Neu muon dam bao dung Inter tren moi may, can them font files
  vao `assets/fonts` va khai bao trong `pubspec.yaml`.
- `logger` va `flutter_dotenv` chi nen dua vao guideline chinh thuc sau khi da
  cau hinh va dung that trong code.

## 4. Cau truc thu muc

Tong quan:

```text
lib/
  main.dart
  di/
    injection.dart
  core/
    constants/
    network/
    routes/
    storage/
    theme/
    utils/
    widgets/
  features/
    auth/
    home/
    intro/
    location/
    offers/
    support/
    tickets/
    trips/
    user/
assets/
  icons/
  images/
test/
```

Y nghia:

- `lib/main.dart`: bootstrap app, init DI, check auth, tao router, global error
  handler, `MaterialApp.router`.
- `lib/di/injection.dart`: noi duy nhat dang ky dependency bang `GetIt`.
- `lib/core`: code dung chung, khong phu thuoc vao feature cu the.
- `lib/features`: chia theo feature/domain man hinh.
- `assets`: anh, icon, font neu co.
- `test`: widget/unit tests.

## 5. Trang thai feature hien tai

Feature da co day du luong data-domain-presentation:

- `auth`: login, logout, refresh token, auth state, token storage.
- `user`: lay profile, hien profile, logout tu profile.

Feature hien tai chu yeu la UI/static/demo:

- `intro`: splash/intro screen, refresh session roi dieu huong.
- `home`: home/search UI, demo featured trips.
- `location`: location search UI, tra ve location qua `context.pop(result)`.
- `trips`: my trips/create trip UI, `TripCard`.
- `tickets`: my tickets UI.
- `offers`: offers UI.
- `support`: support UI.

Quy tac:

- Feature nao co API, data that, business flow thi phai tao du
  `data/domain/presentation`.
- Feature nao chi la UI placeholder/demo thi co the chi co `presentation`, nhung
  khi ket noi API phai refactor ve dung cau truc 3 lop.

## 6. Kien truc chuan

Huong kien truc cua project:

```text
UI/Page/Widget
  -> Bloc/Cubit
  -> UseCase
  -> Repository interface
  -> Repository implementation
  -> DataSource
  -> Dio/API or local storage
```

Quy tac phu thuoc:

- `presentation` duoc goi `domain`.
- `domain` khong duoc import Flutter UI, Dio, SharedPreferences, model DTO.
- `data` implement repository va goi datasource/model/API.
- UI khong goi truc tiep `Dio`, `DataSource`, hoac `RepositoryImpl`.
- UI chi doc state va dispatch event/goi method tren Bloc/Cubit.
- `core` khong import feature neu khong that su can. Ngoai le hien tai:
  `UnauthorizedInterceptor` can `AuthCubit` de refresh session.

Cau truc feature co API:

```text
lib/features/<feature>/
  data/
    datasources/
      <feature>_remote_data_source.dart
      <feature>_local_data_source.dart
    models/
      <request_or_response>.dart
      <request_or_response>.g.dart
    repositories/
      <feature>_repository_impl.dart
  domain/
    entities/
      <entity>.dart
    repositories/
      <feature>_repository.dart
    usecases/
      <action>_usecase.dart
  presentation/
    bloc/ or cubit/
      <feature>_bloc.dart
      <feature>_event.dart
      <feature>_state.dart
    pages/
      <feature>_screen.dart
    widgets/
      <feature>_<widget>.dart
```

## 7. App bootstrap

`main.dart` dang lam cac viec sau:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `di.init()` de dang ky dependencies.
3. Lay `AuthCubit` tu service locator.
4. `authCubit.checkAuth()` de doc token/role da luu.
5. Tao `GoRouter` bang `AppRouter.createRouter(navigatorKey, authCubit)`.
6. Dang ky global error handler:
   - `FlutterError.onError`
   - `PlatformDispatcher.instance.onError`
7. Chay app voi `BlocProvider.value(value: authCubit, child: MyApp(...))`.

Quy tac:

- Khong tao dependency truc tiep trong widget neu dependency do da nam trong DI.
- App-level Cubit nhu `AuthCubit` duoc provide o root.
- Feature-level Bloc/Cubit duoc provide gan man hinh can dung.

## 8. Dependency injection

Tat ca dependency dung chung phai dang ky trong `lib/di/injection.dart`.

Dang co:

- Core:
  - `SharedPreferences`
  - `AuthTokenStorage`
  - `Dio`
  - `UnauthorizedInterceptor`
- Auth:
  - `AuthLocalDataSource`
  - `AuthRemoteDataSource`
  - `AuthRepository`
  - `LoginUseCase`
  - `LogoutUseCase`
  - `RefreshTokenUseCase`
  - `LoginBloc`
  - `AuthCubit`
- User:
  - `UserRemoteDataSource`
  - `UserRepository`
  - `GetUserProfileUseCase`
  - `UserProfileCubit`

Quy tac dang ky:

- `registerLazySingleton`: dung cho service/repository/usecase/stateless object
  co the tai su dung.
- `registerFactory`: dung cho Bloc/Cubit co lifecycle gan voi man hinh.
- Neu them feature moi, dang ky dependency theo thu tu:
  datasource -> repository -> usecase -> bloc/cubit.
- Khong dung `sl()` tran lan trong UI tru khi tao Bloc/Cubit trong
  `BlocProvider(create: ...)`.

## 9. Routing

Router nam tai `lib/core/routes/app_router.dart`.

Routes hien co:

```text
/intro
/login
/forgot_password
/register
/home
/home_search
/search_results
/location_search
/my_trips
/create_trip
/my_tickets
/offers
/support
/profile
```

Auth redirect hien tai:

- Initial route: `/intro`.
- Khi `AuthStatus.unknown`: khong redirect.
- Khi unauthenticated:
  - Cho phep `/intro`, `/login`, `/register`, `/forgot_password`.
  - Cac route khac redirect ve `/login`.
- Khi authenticated:
  - Vao `/intro`, `/login`, `/register`, `/forgot_password` se redirect ve
    `/home`.

Quy tac navigation:

- Khai bao route o mot noi duy nhat: `AppRouter`.
- Khong hardcode route path o nhieu noi neu path bat dau dung lap lai nhieu lan.
  Nen them `AppRoutes` constants khi route tang len.
- Dung `context.go()` khi thay stack/dieu huong chinh.
- Dung `context.push()` khi can quay lai man truoc.
- Dung `context.pop(result)` khi man hinh con tra du lieu ve, vi du
  `LocationSearchScreen`.

## 10. Auth, token va role

Luon auth hien tai:

```text
LoginScreen
  -> LoginBloc
  -> LoginUseCase
  -> AuthRepository.login
  -> AuthRemoteDataSource.login
  -> POST /Auth/login
  -> JwtDecoder.extractRole(accessToken)
  -> AuthLocalDataSource.saveTokens
  -> AuthCubit.setAuthenticated
  -> /home
```

Refresh token:

```text
UnauthorizedInterceptor bat 401
  -> AuthCubit.refreshSession()
  -> AuthRepository.refreshTokens()
  -> POST /Auth/refresh-token
  -> save token moi
  -> retry request cu
```

Logout:

```text
UserProfileScreen
  -> UserProfileCubit.logout()
  -> LogoutUseCase
  -> AuthRepository.logout()
  -> POST /Auth/logout neu co access token
  -> clear local token
  -> AuthCubit.setUnauthenticated()
  -> /login
```

Endpoint dang dung:

- `POST /Auth/login`
- `POST /Auth/refresh-token`
- `POST /Auth/logout`
- `GET /User/me`

Role dang duoc ho tro:

- `USER`
- `DRIVER`

`AppBottomNavBar` doi menu theo role.

Quy tac token hien tai:

- Token duoc luu bang `AuthTokenStorage`.
- Protected datasource hien tai dang nhan access token tu repository va set
  header `Authorization` trong request.
- `UnauthorizedInterceptor` hien tai xu ly retry khi gap 401, chua phai
  interceptor gan token tu dong cho moi request.
- Neu sau nay them `AuthHeaderInterceptor` de tu dong gan token, phai cap nhat
  datasource de khong truyen token thu cong nua.

## 11. API va data layer

Datasource:

- Chi goi API/local storage.
- Chi validate response format toi thieu.
- Khong xu ly UI state.
- Khong dieu huong.
- Khong biet Bloc/Cubit.

Repository implementation:

- Goi datasource.
- Kiem tra `code/message/data` neu API tra ve envelope.
- Map DTO/model sang entity domain.
- Xu ly loi domain nhe, vi du role khong duoc ho tro.
- Khong import widget/UI.

UseCase:

- Moi use case lam mot hanh dong ro rang.
- Ten theo hanh dong: `LoginUseCase`, `LogoutUseCase`,
  `GetUserProfileUseCase`.
- Neu can input phuc tap, tao params class va extends `Equatable`.

Entity:

- Nam trong `domain/entities`.
- Uu tien immutable, `final`, `const constructor`.
- Dung `Equatable` neu entity/state can so sanh.
- Khong phu thuoc vao JSON annotation neu co the tach DTO rieng.

Model/DTO:

- Nam trong `data/models`.
- Dung cho request/response API.
- Ten ro nghia: `LoginRequest`, `LoginResponse`, `RefreshTokenResponse`.
- New model nen dung `json_serializable` neu response on dinh.
- Neu parse thu cong, phai handle nullable/type mismatch ro rang.

Response format dang duoc ky vong:

```json
{
  "code": 200,
  "message": "...",
  "data": {}
}
```

Quy tac loi:

- Datasource co the throw `Exception` hoac de `DioException` bubble len.
- Repository nen chuyen response loi thanh message co nghia.
- Bloc/Cubit map loi sang state failure.
- UI hien message tu state, khong parse response API trong widget.

## 12. State management

Project dung:

- `Bloc` cho flow co event ro rang, vi du `LoginBloc`.
- `Cubit` cho flow don gian/goi method truc tiep, vi du `AuthCubit`,
  `UserProfileCubit`.

State pattern:

```dart
enum FeatureStatus { initial, loading, success, failure }

class FeatureState extends Equatable {
  const FeatureState({
    this.status = FeatureStatus.initial,
    this.errorMessage,
  });

  final FeatureStatus status;
  final String? errorMessage;

  FeatureState copyWith({
    FeatureStatus? status,
    String? errorMessage,
  }) {
    return FeatureState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
```

Quy tac:

- State phai du thong tin cho UI render: loading, success data, failure message.
- Khong emit object mutable.
- Khong goi `context.go`, `ScaffoldMessenger`, dialog trong Bloc/Cubit.
- Navigation/snackbar/dialog nam trong UI layer, thuong o `BlocListener`.
- Khi state co field nullable can clear, can thiet ke `copyWith` co co che clear
  ro rang. Pattern hien tai `errorMessage: errorMessage` dang clear duoc loi,
  nhung cac field nhu `role/profile` can can than neu muon set ve null.

## 13. UI convention

UI hien dung Material 3, `AppColors`, `AppTheme`, `ScreenUtil`.

Quy tac chung:

- Dung `AppColors` va theme chung, khong rai mau magic khap noi.
- Dung `.w`, `.h`, `.sp`, `.r` tu `flutter_screenutil` cho spacing/size/radius
  trong UI mobile.
- Man hinh dung `Scaffold`, `SafeArea` khi phu hop.
- Widget dung chung dat trong `core/widgets`.
- Widget chi dung trong feature dat trong `features/<feature>/presentation/widgets`.
- Private widget helper trong cung file dung prefix `_`.
- Neu file screen qua dai hoac co nhieu helper, tach widget rieng.
- UI khong goi API truc tiep.
- UI khong doc/ghi token truc tiep.
- Form phai validate o UI truoc khi dispatch event.
- Text hien thi tieng Viet phai luu file bang UTF-8.

Pattern dang co:

- `LoginScreen`: `BlocProvider` + `BlocListener` + `BlocBuilder`.
- `UserProfileScreen`: `BlocProvider` + `BlocBuilder`.
- `VelocityTransitHomeScreen`: local state cho input tam thoi.
- `LocationSearchScreen`: local `TextEditingController`, tra ket qua bang
  `context.pop(title)`.
- `AppBottomNavBar`: widget chung, doc role tu `AuthCubit`.

Khuyen nghi:

- Cac text/brand name can thong nhat. Hien co `AppGroupCar`, `Velocity Transit`,
  `NexusRide`, `GroupCar` asset. Nen chon mot brand chinh truoc khi release.
- Cac UI demo dang co data hardcode tieng Anh/Viet tron lan; khi ket noi API
  can dua data sang Bloc/Cubit/repository, khong de trong widget.

## 14. Naming convention

File/folder:

- snake_case: `login_screen.dart`, `auth_remote_data_source.dart`.
- Feature folder la danh tu ngan gon: `auth`, `user`, `trips`.
- Generated file giu dung pattern: `login_request.g.dart`.

Class:

- PascalCase: `LoginScreen`, `AuthRemoteDataSource`, `GetUserProfileUseCase`.

Variable/method:

- camelCase: `getProfile`, `authCubit`, `accessToken`.

Boolean:

- Bat dau bang `is`, `has`, `can`, `should`: `isLoading`, `hasToken`.

Event/state:

- Event theo hanh dong qua khu/command: `LoginRequested`.
- State co enum status: `LoginStatus`, `UserProfileStatus`.

Repository/datasource:

- Interface: `<Feature>Repository`.
- Implementation: `<Feature>RepositoryImpl`.
- Remote datasource: `<Feature>RemoteDataSource`.
- Local datasource: `<Feature>LocalDataSource`.

UseCase:

- `<Action><Entity>UseCase` hoac `<Action>UseCase` neu feature da ro:
  `GetUserProfileUseCase`, `LoginUseCase`.

## 15. Them feature moi co API

Checklist:

1. Tao folder:

```text
lib/features/<feature>/
  data/datasources/
  data/models/
  data/repositories/
  domain/entities/
  domain/repositories/
  domain/usecases/
  presentation/bloc/ or presentation/cubit/
  presentation/pages/
  presentation/widgets/
```

2. Tao model request/response trong `data/models`.
3. Tao entity domain neu UI khong nen dung thang response DTO.
4. Tao repository interface trong `domain/repositories`.
5. Tao usecase trong `domain/usecases`.
6. Tao remote datasource goi API bang `Dio`.
7. Tao repository implementation map response sang entity.
8. Tao Bloc/Cubit va state.
9. Dang ky dependency trong `di/injection.dart`.
10. Tao screen/widget trong `presentation`.
11. Khai bao route trong `AppRouter` neu co man moi.
12. Viet test cho logic co rui ro: repository/usecase/bloc/widget.
13. Chay format/analyze/test.

Quy tac bo sung:

- Khong dua API endpoint vao widget.
- Khong duplicate DTO/entity neu co the tai su dung hop ly trong cung feature.
- Khong tao abstraction truoc khi co nhu cau that.

## 16. Them screen UI-only

Dung khi man hinh chua co API hoac chi la prototype.

Checklist:

1. Tao file trong `features/<feature>/presentation/pages`.
2. Neu co widget lap lai, tao trong `presentation/widgets`.
3. Dung `AppColors`, `AppTheme`, `ScreenUtil`.
4. Them route trong `AppRouter`.
5. Neu man hinh can bottom nav, dung `AppBottomNavBar`.
6. Ghi ro data demo trong code hoac comment ngan neu de tranh hieu nham.
7. Khi ket noi API, refactor sang Bloc/Cubit va data-domain-presentation.

## 17. Assets

Dang co:

- `assets/images/logoGroupCar.png`
- `assets/images/only-logo.png`
- `assets/icons/` dang duoc khai bao trong `pubspec.yaml`

Quy tac:

- Them asset vao dung folder va khai bao trong `pubspec.yaml` neu folder moi.
- Dung `Image.asset` cho PNG/JPG.
- Dung `flutter_svg` cho SVG neu co.
- Ten asset nen snake_case, khong dau, khong space.
- Khong hardcode kich thuoc anh qua lon neu co the responsive bang `.w/.h`.

## 18. Error handling

Dang co:

- Global friendly error dialog trong `main.dart` bang `AwesomeDialog`.
- Network error duoc detect bang `DioException`, `SocketException`,
  `TimeoutException`, `HandshakeException`.
- Bloc/Cubit hien loi qua `errorMessage`.
- UI thuong remove prefix `Exception: ` truoc khi hien.

Quy tac:

- Loi network/API o data/repository khong duoc lam crash app neu flow co the
  hien failure state.
- UI hien snackbar/dialog/loading dua tren state.
- Khong swallow error neu can user biet. Ngoai le hop ly: logout remote fail
  nhung van clear local token.
- Message hien thi cho user nen than thien, khong lo stack trace.
- Debug log chi nen dung `debugPrint` trong debug hoac `logger` neu project da
  thong nhat logger.

## 19. JSON va code generation

Dang co generated files:

- `login_request.g.dart`
- `login_response.g.dart`

Lenh generate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Quy tac:

- Sau khi sua model co `@JsonSerializable()`, phai chay build_runner.
- Khong sua file `.g.dart` bang tay.
- Request/response don gian co the parse manual, nhung feature moi nen uu tien
  `json_serializable` de dong nhat.

## 20. Test va quality gate

Test hien tai:

- `test/widget_test.dart`: test `MyApp` build duoc voi router dummy.

Lenh nen chay truoc khi giao code:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Neu chi sua documentation:

khong bat buoc chay cac lenh Dart/Flutter. Chi can doc lai file Markdown va
dam bao noi dung khop voi codebase hien tai. Khi co sua code Dart, hay chay
day du format/analyze/test.

Quy tac test:

- UseCase/repository co logic mapping/role/error nen co unit test.
- Bloc/Cubit co loading/success/failure nen co bloc/state test neu flow quan
  trong.
- Widget test cho man hinh co form/redirect/loading/error.
- Khong de test phu thuoc backend that; mock repository/datasource.

## 21. Coding style

Ap dung `flutter_lints`.

Quy tac:

- Dung `const` khi co the.
- Uu tien immutable data: `final`, `const constructor`.
- Khong de function/widget qua dai neu kho doc.
- Khong duplicate logic parse/error/route.
- Khong hardcode magic string neu dung nhieu noi.
- Comment ngan khi giai thich ly do, khong comment lai dieu code da noi ro.
- Import sap xep theo nhom: Dart/Flutter package, third-party package, local.
- Luu file text bang UTF-8. Khi doc bang PowerShell co tieng Viet, dung:

```powershell
Get-Content -Encoding UTF8 path\to\file.dart
```

## 22. Nhung diem can thong nhat them

Day la cac diem nen xu ly de project chuan hon:

- Brand name: dang co `AppGroupCar`, `NexusRide`,
  `GroupCar`. Can chon ten hien thi chinh.
- Route constants: hien route path dang hardcode o nhieu screen. Khi route tang,
  nen tao `AppRoutes`.
- Auth header: protected request dang gan token thu cong trong datasource. Neu
  muon chuan hon, them interceptor gan `Authorization` tu `AuthTokenStorage`.
- Logger/env: `logger` va `flutter_dotenv` da khai bao nhung chua dung. Neu
  can, cau hinh mot lan trong `core` roi cap nhat guideline.
- Font Inter: dang khai bao trong theme nhung chua khai bao font asset.
- Static demo data: home/search/trips/tickets/offers/support con hardcode. Khi
  co API, phai dua data vao Bloc/Cubit va repository.
- UI text tieng Viet: can dam bao tat ca file duoc save UTF-8 de tranh loi font
  khi mo bang tool khac.

## 23. Definition of done cho feature moi

Feature duoc xem la san sang giao khi:

- Folder dung cau truc feature-based.
- UI khong goi API truc tiep.
- Data/API call nam trong datasource.
- Repository map response va error ro rang.
- Bloc/Cubit co loading/success/failure.
- Route duoc khai bao dung noi.
- Dependency duoc dang ky trong DI.
- Token/auth role duoc xu ly theo luong auth hien co.
- Khong hardcode data that trong widget.
- Dart code da format.
- `flutter analyze` khong co loi moi.
- Test lien quan da duoc them hoac cap nhat neu logic co rui ro.

## 24. Vi du chuan

### Widget reusable

```dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

### Datasource

```dart
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/Auth/login', data: request.toJson());
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return LoginResponse.fromJson(data);
    }

    throw Exception('Dinh dang phan hoi khong hop le');
  }
}
```

### Repository

```dart
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final UserRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<UserProfile> getProfile() async {
    final tokens = await authRepository.getSavedTokens();
    final accessToken = tokens?.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Chua dang nhap');
    }

    final response = await remoteDataSource.fetchProfile(accessToken);
    if (response.code != 200) {
      throw Exception(response.message);
    }

    return response.data;
  }
}
```

### Bloc listener trong UI

```dart
BlocListener<LoginBloc, LoginState>(
  listenWhen: (previous, current) => previous.status != current.status,
  listener: (context, state) {
    if (state.status == LoginStatus.failure) {
      final message =
          state.errorMessage?.replaceFirst('Exception: ', '') ??
          'Dang nhap that bai';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    if (state.status == LoginStatus.success) {
      context.read<AuthCubit>().setAuthenticated(role: state.role ?? 'USER');
      context.go('/home');
    }
  },
  child: const LoginForm(),
)
```

---

Tai lieu nay nen duoc cap nhat moi khi thay doi kien truc, route, dependency,
API contract, hoac convention code.
