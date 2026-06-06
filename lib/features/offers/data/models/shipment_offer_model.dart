import '../../domain/entities/shipment_offer.dart';

class ShipmentOfferModel extends ShipmentOffer {
  const ShipmentOfferModel({
    required super.driverName,
    required super.vehicleName,
    required super.vehicleUrlImage,
    required super.departureTime,
    required super.basePrice,
    required super.startPoint,
    required super.endPoint,
    required super.maxWeight,
    required super.maxVolume,
    required super.acceptFragile,
  });

  factory ShipmentOfferModel.fromJson(Map<String, dynamic> json) {
    final cargo = json['cargoDetail'];
    final cargoMap = cargo is Map<String, dynamic>
        ? cargo
        : <String, dynamic>{};

    return ShipmentOfferModel(
      driverName: json['driverName'] as String? ?? '',
      vehicleName: json['vehicleName'] as String? ?? '',
      vehicleUrlImage: json['vehicleUrlImage'] as String? ?? '',
      departureTime: json['departureTime'] as String? ?? '',
      basePrice: _readDouble(json['basePrice']),
      startPoint: json['startPoint'] as String? ?? '',
      endPoint: json['endPoint'] as String? ?? '',
      maxWeight: _readDouble(cargoMap['maxWeight'] ?? json['maxWeight']),
      maxVolume: _readDouble(cargoMap['maxVolume'] ?? json['maxVolume']),
      acceptFragile: _readBool(
        cargoMap['acceptFragile'] ?? json['acceptFragile'],
      ),
    );
  }

  static double _readDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value.toInt() == 1;
    return false;
  }
}
