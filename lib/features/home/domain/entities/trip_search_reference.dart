import 'package:equatable/equatable.dart';

class TripSearchReference extends Equatable {
  const TripSearchReference({
    required this.id,
    required this.tripType,
    required this.tripTypeName,
    required this.serviceCode,
    required this.detailApi,
  });

  final String id;
  final int tripType;
  final String tripTypeName;
  final String serviceCode;
  final String detailApi;

  factory TripSearchReference.fromJson(Map<String, dynamic> json) {
    return TripSearchReference(
      id: json['id'] as String? ?? '',
      tripType: _readInt(json['tripType']),
      tripTypeName: json['tripTypeName'] as String? ?? '',
      serviceCode: json['serviceCode'] as String? ?? '',
      detailApi: json['detailApi'] as String? ?? '',
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    tripType,
    tripTypeName,
    serviceCode,
    detailApi,
  ];
}
