import '../../domain/entities/staff_manual_checkin_info.dart';

class StaffManualCheckinInfoResponse {
  const StaffManualCheckinInfoResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final StaffManualCheckinInfo? data;

  factory StaffManualCheckinInfoResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = _readManualMap(json['data']);
    return StaffManualCheckinInfoResponse(
      code: _readManualInt(json['code']),
      message: _readManualString(json['message']),
      data: dataMap == null ? null : StaffManualCheckinInfo.fromJson(dataMap),
    );
  }
}

int _readManualInt(Object? value) {
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

String _readManualString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _readManualMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
