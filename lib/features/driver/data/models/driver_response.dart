import '../../domain/entities/driver_profile.dart';

class DriverResponse {
  const DriverResponse({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final DriverProfile? data;

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic> ? dataValue : null;
    return DriverResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: dataMap == null ? null : DriverProfile.fromJson(dataMap),
    );
  }
}
