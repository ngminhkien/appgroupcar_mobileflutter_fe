import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/shared_ride_offer.dart';
import '../../domain/entities/shipment_offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_remote_data_source.dart';

class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final OffersRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<List<SharedRideOffer>> getSharedRides({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await remoteDataSource.getSharedRides(
        pickupLocationId: pickupLocationId,
        dropoffLocationId: dropoffLocationId,
        startTime: startTime,
        endTime: endTime,
        startPrice: startPrice,
        endPrice: endPrice,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Không thể tải danh sách chuyến đi chung: $e');
    }
  }

  @override
  Future<List<ShipmentOffer>> getShipments({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await remoteDataSource.getShipments(
        pickupLocationId: pickupLocationId,
        dropoffLocationId: dropoffLocationId,
        startTime: startTime,
        endTime: endTime,
        startPrice: startPrice,
        endPrice: endPrice,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Không thể tải danh sách chuyến vận chuyển hàng: $e');
    }
  }

  @override
  Future<void> createSharedRide({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
  }) async {
    try {
      final token = await _requireAccessToken();
      final responseData = await remoteDataSource.createSharedRide(
        vehicleId: vehicleId,
        departureTime: departureTime,
        estimatedDurationMinutes: estimatedDurationMinutes,
        basePrice: basePrice,
        offerRoutePoints: offerRoutePoints,
        accessToken: token,
      );
      final code = responseData is Map
          ? (responseData['code'] as int? ?? 200)
          : 200;
      final message = responseData is Map
          ? (responseData['message'] as String? ?? '')
          : '';
      if (code != 200) {
        throw Exception(
          message.isNotEmpty ? message : 'Tạo chuyến đi chung thất bại',
        );
      }
    } catch (e) {
      throw Exception('Không thể tạo chuyến đi chung: $e');
    }
  }

  @override
  Future<void> createShipment({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required Map<String, dynamic> cargo,
  }) async {
    try {
      final token = await _requireAccessToken();
      final responseData = await remoteDataSource.createShipment(
        vehicleId: vehicleId,
        departureTime: departureTime,
        estimatedDurationMinutes: estimatedDurationMinutes,
        basePrice: basePrice,
        offerRoutePoints: offerRoutePoints,
        cargo: cargo,
        accessToken: token,
      );
      final code = responseData is Map
          ? (responseData['code'] as int? ?? 200)
          : 200;
      final message = responseData is Map
          ? (responseData['message'] as String? ?? '')
          : '';
      if (code != 200) {
        throw Exception(
          message.isNotEmpty ? message : 'Tạo chuyến vận chuyển hàng thất bại',
        );
      }
    } catch (e) {
      throw Exception('Không thể tạo chuyến vận chuyển hàng: $e');
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
}
