import '../../domain/entities/vehicle.dart';

class VehicleResponse {
  const VehicleResponse({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final Vehicle? data;

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic> ? dataValue : null;
    return VehicleResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: dataMap == null ? null : Vehicle.fromJson(dataMap),
    );
  }
}

class VehicleListResponse {
  const VehicleListResponse({
    required this.code,
    required this.message,
    this.data = const [],
  });

  final int code;
  final String message;
  final List<Vehicle> data;

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final vehicles = dataValue is List
        ? dataValue
              .whereType<Map<String, dynamic>>()
              .map(Vehicle.fromJson)
              .toList()
        : <Vehicle>[];
    return VehicleListResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: vehicles,
    );
  }
}
