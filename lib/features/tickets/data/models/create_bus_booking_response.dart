import '../../domain/entities/bus_booking.dart';

class CreateBusBookingResponse {
  const CreateBusBookingResponse({
    required this.code,
    required this.message,
    this.data,
    this.unavailableSeats = const [],
  });

  final int code;
  final String message;
  final BusBooking? data;
  final List<String> unavailableSeats;

  factory CreateBusBookingResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    BusBooking? booking;
    var unavailableSeats = const <String>[];

    if (rawData is Map<String, dynamic>) {
      booking = BusBooking.fromJson(rawData);
    } else if (rawData is List<dynamic>) {
      unavailableSeats = rawData
          .map(_bookingReadString)
          .map((value) => value.trim().toUpperCase())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
    }

    return CreateBusBookingResponse(
      code: _bookingReadInt(json['code']),
      message: _bookingReadString(json['message']),
      data: booking,
      unavailableSeats: unavailableSeats,
    );
  }
}

int _bookingReadInt(Object? value) {
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

String _bookingReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}
