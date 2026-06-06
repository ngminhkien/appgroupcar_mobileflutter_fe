import '../../domain/entities/shared_ride_offer.dart';

class SharedRideOfferModel extends SharedRideOffer {
  const SharedRideOfferModel({
    required super.driverName,
    required super.vehicleName,
    required super.plateNumber,
    required super.vehicleUrlImage,
    required super.departureTime,
    required super.basePrice,
    required super.startPoint,
    required super.endPoint,
    required super.availableSeats,
  });

  factory SharedRideOfferModel.fromJson(Map<String, dynamic> json) {
    return SharedRideOfferModel(
      driverName: json['driverName'] as String? ?? '',
      vehicleName: json['vehicleName'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      vehicleUrlImage: json['vehicleUrlImage'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '',
      basePrice: _readDouble(json['basePrice']),
      startPoint: json['startPoint'] as String? ?? '',
      endPoint: json['endPoint'] as String? ?? '',
      availableSeats: _readInt(json['availableSeats']),
    );
  }

  static double _readDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
