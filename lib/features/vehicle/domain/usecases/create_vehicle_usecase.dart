import 'package:equatable/equatable.dart';

import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class CreateVehicleUseCase {
  const CreateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<Vehicle> call(CreateVehicleParams params) {
    return _repository.createVehicle(
      plateNumber: params.plateNumber,
      brand: params.brand,
      seatCapacity: params.seatCapacity,
      vehicleType: params.vehicleType,
      urlImagePath: params.urlImagePath,
      registrationDocumentUrlPath: params.registrationDocumentUrlPath,
    );
  }
}

class CreateVehicleParams extends Equatable {
  const CreateVehicleParams({
    required this.plateNumber,
    required this.brand,
    required this.seatCapacity,
    required this.vehicleType,
    required this.urlImagePath,
    required this.registrationDocumentUrlPath,
  });

  final String plateNumber;
  final String brand;
  final int seatCapacity;
  final int vehicleType;
  final String urlImagePath;
  final String registrationDocumentUrlPath;

  @override
  List<Object?> get props => [
    plateNumber,
    brand,
    seatCapacity,
    vehicleType,
    urlImagePath,
    registrationDocumentUrlPath,
  ];
}
