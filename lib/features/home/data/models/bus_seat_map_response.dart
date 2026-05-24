import '../../domain/entities/bus_seat_map.dart';

class BusSeatMapResponse {
  const BusSeatMapResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final BusSeatMap? data;

  factory BusSeatMapResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _seatMapReadMap(json['data']);
    return BusSeatMapResponse(
      code: _seatMapReadInt(json['code']),
      message: _seatMapReadString(json['message']),
      data: dataMap == null ? null : BusSeatMap.fromJson(dataMap),
    );
  }
}

class BusSeatLayoutResponse {
  const BusSeatLayoutResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final BusSeatLayout? data;

  factory BusSeatLayoutResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _seatMapReadMap(json['data']);
    return BusSeatLayoutResponse(
      code: _seatMapReadInt(json['code']),
      message: _seatMapReadString(json['message']),
      data: dataMap == null ? null : BusSeatLayout.fromJson(dataMap),
    );
  }
}

class BusSeatStatusesResponse {
  const BusSeatStatusesResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  final int code;
  final String message;
  final List<BusSeatStatus> data;

  factory BusSeatStatusesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = _seatMapReadList(json['data']);
    return BusSeatStatusesResponse(
      code: _seatMapReadInt(json['code']),
      message: _seatMapReadString(json['message']),
      data: dataList
          .whereType<Map<String, dynamic>>()
          .map(BusSeatStatus.fromJson)
          .toList(),
    );
  }
}

int _seatMapReadInt(Object? value) {
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

String _seatMapReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _seatMapReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<dynamic> _seatMapReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
