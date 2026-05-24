import '../../domain/entities/staff_upcoming_showtime.dart';

class StaffUpcomingShowtimesResponse {
  const StaffUpcomingShowtimesResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final StaffUpcomingShowtimeResult? data;

  factory StaffUpcomingShowtimesResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _readUpcomingMap(json['data']);
    return StaffUpcomingShowtimesResponse(
      code: _readUpcomingInt(json['code']),
      message: _readUpcomingString(json['message']),
      data: dataMap == null
          ? null
          : StaffUpcomingShowtimeResult.fromJson(dataMap),
    );
  }
}

int _readUpcomingInt(Object? value) {
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

String _readUpcomingString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _readUpcomingMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
