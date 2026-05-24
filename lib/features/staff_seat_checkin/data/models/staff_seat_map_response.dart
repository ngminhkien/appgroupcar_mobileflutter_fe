import '../../domain/entities/staff_seat_map.dart';

class StaffSeatMapResponse {
  const StaffSeatMapResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final StaffSeatMap? data;

  factory StaffSeatMapResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _readSeatMapMap(json['data']);
    return StaffSeatMapResponse(
      code: _readSeatMapInt(json['code']),
      message: _readSeatMapString(json['message']),
      data: dataMap == null ? null : StaffSeatMap.fromJson(dataMap),
    );
  }
}

int _readSeatMapInt(Object? value) {
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

String _readSeatMapString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _readSeatMapMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
