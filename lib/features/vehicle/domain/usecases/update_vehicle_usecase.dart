import 'package:equatable/equatable.dart';

import '../repositories/vehicle_repository.dart';

class UpdateVehicleUseCase {
  const UpdateVehicleUseCase(this._repository);

  final VehicleRepository _repository;

  Future<void> call(UpdateVehicleParams params) {
    return _repository.updateVehicle(
      id: params.id,
      plateNumber: params.plateNumber,
      brand: params.brand,
      seatCapacity: params.seatCapacity,
      vehicleType: params.vehicleType,
      urlImagePath: params.urlImagePath,
      registrationDocumentUrlPath: params.registrationDocumentUrlPath,
    );
  }
}

class UpdateVehicleParams extends Equatable {
  const UpdateVehicleParams({
    required this.id,
    this.plateNumber,
    this.brand,
    this.seatCapacity,
    this.vehicleType,
    this.urlImagePath,
    this.registrationDocumentUrlPath,
  });

  final String id;
  final String? plateNumber;
  final String? brand;
  final int? seatCapacity;
  final int? vehicleType;
  final String? urlImagePath;
  final String? registrationDocumentUrlPath;

  @override
  List<Object?> get props => [
    id,
    plateNumber,
    brand,
    seatCapacity,
    vehicleType,
    urlImagePath,
    registrationDocumentUrlPath,
  ];
}
