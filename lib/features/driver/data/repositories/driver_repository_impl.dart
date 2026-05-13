import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_data_source.dart';
import '../models/create_driver_request.dart';
import '../models/update_driver_request.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
    required this.userRepository,
  });

  final DriverRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;
  final UserRepository userRepository;

  @override
  Future<DriverProfile> createDriver({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    String? licenseDocumentImgPath,
  }) async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.createDriver(
      request: CreateDriverRequest(
        name: name,
        identityNumber: identityNumber,
        licenseNumber: licenseNumber,
        licenseClass: licenseClass,
        licenseDocumentImgPath: licenseDocumentImgPath,
      ),
      accessToken: accessToken,
    );
    if (response.code != 200) {
      throw Exception(
        _messageOrFallback(response.message, 'Tạo tài xế thất bại'),
      );
    }
    final driver = response.data;
    if (driver == null) {
      throw Exception('Không có dữ liệu tài xế');
    }
    return driver;
  }

  @override
  Future<DriverProfile> updateDriver({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    required int verificationStatus,
    String? licenseDocumentImgPath,
  }) async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.updateDriver(
      request: UpdateDriverRequest(
        name: name,
        identityNumber: identityNumber,
        licenseNumber: licenseNumber,
        licenseClass: licenseClass,
        verificationStatus: verificationStatus,
        licenseDocumentImgPath: licenseDocumentImgPath,
      ),
      accessToken: accessToken,
    );
    if (response.code != 200) {
      throw Exception(
        _messageOrFallback(response.message, 'Cập nhật tài xế thất bại'),
      );
    }
    final driver = response.data;
    if (driver == null) {
      throw Exception('Không có dữ liệu tài xế');
    }
    return driver;
  }

  @override
  Future<DriverProfile?> getCurrentDriverProfile() async {
    final accessToken = await _requireAccessToken();
    final profile = await userRepository.getProfile();
    if (profile.id.isEmpty) {
      throw Exception('Không tìm thấy mã người dùng');
    }
    final response = await remoteDataSource.getDriverByUserId(
      userId: profile.id,
      accessToken: accessToken,
    );
    if (response.code == 200) {
      return response.data;
    }
    if (response.code == 404) {
      return null;
    }
    final lowerMessage = response.message.toLowerCase();
    if (lowerMessage.contains('not found') ||
        lowerMessage.contains('không tìm thấy') ||
        lowerMessage.contains('khong tim thay')) {
      return null;
    }
    throw Exception(
      _messageOrFallback(response.message, 'Không thể tải hồ sơ tài xế'),
    );
  }

  Future<String> _requireAccessToken() async {
    final tokens = await authRepository.getSavedTokens();
    final accessToken = tokens?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }
    return accessToken;
  }

  String _messageOrFallback(String message, String fallback) {
    return message.isNotEmpty ? message : fallback;
  }
}
