import '../repositories/offers_repository.dart';

class CreateSharedRideUseCase {
  CreateSharedRideUseCase(this._repository);

  final OffersRepository _repository;

  Future<void> call({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
  }) {
    return _repository.createSharedRide(
      vehicleId: vehicleId,
      departureTime: departureTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      basePrice: basePrice,
      offerRoutePoints: offerRoutePoints,
    );
  }
}
