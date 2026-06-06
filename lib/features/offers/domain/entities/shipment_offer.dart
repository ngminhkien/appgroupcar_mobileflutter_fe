import 'package:equatable/equatable.dart';

class ShipmentOffer extends Equatable {
  const ShipmentOffer({
    required this.driverName,
    required this.vehicleName,
    required this.vehicleUrlImage,
    required this.departureTime,
    required this.basePrice,
    required this.startPoint,
    required this.endPoint,
    required this.maxWeight,
    required this.maxVolume,
    required this.acceptFragile,
  });

  final String driverName;
  final String vehicleName;
  final String vehicleUrlImage;
  final String departureTime;
  final double basePrice;
  final String startPoint;
  final String endPoint;
  final double maxWeight;
  final double maxVolume;
  final bool acceptFragile;

  @override
  List<Object?> get props => [
    driverName,
    vehicleName,
    vehicleUrlImage,
    departureTime,
    basePrice,
    startPoint,
    endPoint,
    maxWeight,
    maxVolume,
    acceptFragile,
  ];
}
