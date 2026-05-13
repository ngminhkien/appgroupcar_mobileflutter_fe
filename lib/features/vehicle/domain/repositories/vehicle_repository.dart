import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getMyVehicles();

  Future<Vehicle> createVehicle({
    required String plateNumber,
    required String brand,
    required int seatCapacity,
    required int vehicleType,
    required String urlImagePath,
    required String registrationDocumentUrlPath,
  });

  Future<void> updateVehicle({
    required String id,
    String? plateNumber,
    String? brand,
    int? seatCapacity,
    int? vehicleType,
    String? urlImagePath,
    String? registrationDocumentUrlPath,
  });
}
