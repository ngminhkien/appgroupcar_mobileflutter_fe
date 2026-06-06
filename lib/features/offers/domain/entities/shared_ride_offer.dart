import 'package:equatable/equatable.dart';

class SharedRideOffer extends Equatable {
  const SharedRideOffer({
    required this.driverName,
    required this.vehicleName,
    required this.plateNumber,
    required this.vehicleUrlImage,
    required this.departureTime,
    required this.basePrice,
    required this.startPoint,
    required this.endPoint,
    required this.availableSeats,
  });

  final String driverName;
  final String vehicleName;
  final String plateNumber;
  final String vehicleUrlImage;
  final String departureTime;
  final double basePrice;
  final String startPoint;
  final String endPoint;
  final int availableSeats;

  @override
  List<Object?> get props => [
    driverName,
    vehicleName,
    plateNumber,
    vehicleUrlImage,
    departureTime,
    basePrice,
    startPoint,
    endPoint,
    availableSeats,
  ];
}
