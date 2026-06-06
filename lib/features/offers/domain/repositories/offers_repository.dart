import '../entities/shared_ride_offer.dart';
import '../entities/shipment_offer.dart';

abstract class OffersRepository {
  Future<List<SharedRideOffer>> getSharedRides({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber,
    int pageSize,
  });

  Future<List<ShipmentOffer>> getShipments({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber,
    int pageSize,
  });

  Future<void> createSharedRide({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
  });

  Future<void> createShipment({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required Map<String, dynamic> cargo,
  });
}
