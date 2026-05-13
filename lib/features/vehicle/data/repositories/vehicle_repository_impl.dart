import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_data_source.dart';
import '../models/create_vehicle_request.dart';
import '../models/update_vehicle_request.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final VehicleRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<List<Vehicle>> getMyVehicles() async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getMyVehicles(
      accessToken: accessToken,
    );
    if (response.code != 200) {
      throw Exception(
        _messageOrFallback(response.message, 'Không thể tải danh sách xe'),
      );
    }
    return response.data;
  }

  @override
  Future<Vehicle> createVehicle({
    required String plateNumber,
    required String brand,
    required int seatCapacity,
    required int vehicleType,
    required String urlImagePath,
    required String registrationDocumentUrlPath,
  }) async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.createVehicle(
      request: CreateVehicleRequest(
        plateNumber: plateNumber,
        brand: brand,
        seatCapacity: seatCapacity,
        vehicleType: vehicleType,
        urlImagePath: urlImagePath,
        registrationDocumentUrlPath: registrationDocumentUrlPath,
      ),
      accessToken: accessToken,
    );
    if (response.code != 200) {
      throw Exception(_messageOrFallback(response.message, 'Tạo xe thất bại'));
    }
    final vehicle = response.data;
    if (vehicle == null) {
      throw Exception('Không có dữ liệu xe');
    }
    return vehicle;
  }

  @override
  Future<void> updateVehicle({
    required String id,
    String? plateNumber,
    String? brand,
    int? seatCapacity,
    int? vehicleType,
    String? urlImagePath,
    String? registrationDocumentUrlPath,
  }) async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.updateVehicle(
      id: id,
      request: UpdateVehicleRequest(
        plateNumber: plateNumber,
        brand: brand,
        seatCapacity: seatCapacity,
        vehicleType: vehicleType,
        urlImagePath: urlImagePath,
        registrationDocumentUrlPath: registrationDocumentUrlPath,
      ),
      accessToken: accessToken,
    );
    if (response.code != 200) {
      throw Exception(
        _messageOrFallback(response.message, 'Cập nhật xe thất bại'),
      );
    }
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
