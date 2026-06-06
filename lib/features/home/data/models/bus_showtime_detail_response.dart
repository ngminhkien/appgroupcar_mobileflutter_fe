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
    Map<String, dynamic>? dataMap;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      dataMap = json['data'] as Map<String, dynamic>;
    } else if (json.containsKey('id') ||
        json.containsKey('tripId') ||
        json.containsKey('price') ||
        json.containsKey('basePrice')) {
      dataMap = json;
    }
    var codeVal = _detailReadInt(json['code']);
    if (codeVal == 0 && (json['success'] == true || dataMap != null)) {
      codeVal = 200;
    }
    return BusShowtimeDetailResponse(
      code: codeVal,
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
