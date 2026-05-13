class UpdateVehicleRequest {
  const UpdateVehicleRequest({
    this.plateNumber,
    this.brand,
    this.seatCapacity,
    this.vehicleType,
    this.urlImagePath,
    this.registrationDocumentUrlPath,
  });

  final String? plateNumber;
  final String? brand;
  final int? seatCapacity;
  final int? vehicleType;
  final String? urlImagePath;
  final String? registrationDocumentUrlPath;
}
