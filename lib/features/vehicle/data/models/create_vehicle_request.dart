class CreateVehicleRequest {
  const CreateVehicleRequest({
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
}
