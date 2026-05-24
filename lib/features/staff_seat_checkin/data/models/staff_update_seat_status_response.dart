import '../../domain/entities/staff_seat_status_history.dart';

class StaffUpdateSeatStatusResponse {
  const StaffUpdateSeatStatusResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final List<StaffSeatStatusHistory> data;

  factory StaffUpdateSeatStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawData = _readStatusList(json['data']);
    return StaffUpdateSeatStatusResponse(
      code: _readStatusInt(json['code']),
      message: _readStatusString(json['message']),
      data: rawData
          .whereType<Map<String, dynamic>>()
          .map(StaffSeatStatusHistory.fromJson)
          .toList(),
    );
  }
}

int _readStatusInt(Object? value) {
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

String _readStatusString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

List<dynamic> _readStatusList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
