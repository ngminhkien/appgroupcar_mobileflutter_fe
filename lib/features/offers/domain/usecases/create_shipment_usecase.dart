import '../repositories/offers_repository.dart';

class CreateShipmentUseCase {
  CreateShipmentUseCase(this._repository);

  final OffersRepository _repository;

  Future<void> call({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required Map<String, dynamic> cargo,
  }) {
    return _repository.createShipment(
      vehicleId: vehicleId,
      departureTime: departureTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      basePrice: basePrice,
      offerRoutePoints: offerRoutePoints,
      cargo: cargo,
    );
  }
}
