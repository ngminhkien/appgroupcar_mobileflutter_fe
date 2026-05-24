import '../../domain/entities/bus_booking.dart';

class MyBusBookingsResponse {
  const MyBusBookingsResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final List<BusBooking> data;

  factory MyBusBookingsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = _myBookingsReadList(json['data']);
    return MyBusBookingsResponse(
      code: _myBookingsReadInt(json['code']),
      message: _myBookingsReadString(json['message']),
      data: rawData
          .whereType<Map<String, dynamic>>()
          .map(BusBooking.fromJson)
          .toList(),
    );
  }
}

int _myBookingsReadInt(Object? value) {
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

String _myBookingsReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

List<dynamic> _myBookingsReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
