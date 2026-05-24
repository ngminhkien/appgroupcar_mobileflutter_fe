import '../../domain/entities/bus_showtime_detail.dart';

class BusShowtimeDetailResponse {
  const BusShowtimeDetailResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final BusShowtimeDetail? data;

  factory BusShowtimeDetailResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _detailReadMap(json['data']);
    return BusShowtimeDetailResponse(
      code: _detailReadInt(json['code']),
      message: _detailReadString(json['message']),
      data: dataMap == null ? null : BusShowtimeDetail.fromJson(dataMap),
    );
  }
}

int _detailReadInt(Object? value) {
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

String _detailReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _detailReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
