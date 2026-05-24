import '../../domain/entities/bus_booking_detail.dart';

class BusBookingDetailResponse {
  const BusBookingDetailResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final BusBookingDetail? data;

  factory BusBookingDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _bookingDetailReadMap(json['data']);
    return BusBookingDetailResponse(
      code: _bookingDetailReadInt(json['code']),
      message: _bookingDetailReadString(json['message']),
      data: dataMap == null ? null : BusBookingDetail.fromJson(dataMap),
    );
  }
}

int _bookingDetailReadInt(Object? value) {
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

String _bookingDetailReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _bookingDetailReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
