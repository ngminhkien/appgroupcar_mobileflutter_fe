import '../../../../core/models/paged_result.dart';
import '../../domain/entities/location_search_item.dart';

class LocationSearchResponse {
  const LocationSearchResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final PagedResult<LocationSearchItem>? data;

  factory LocationSearchResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic> ? dataValue : null;
    return LocationSearchResponse(
      code: _readInt(json['code']),
      message: json['message'] as String? ?? '',
      data: dataMap == null
          ? null
          : PagedResult<LocationSearchItem>.fromJson(
              dataMap,
              LocationSearchItem.fromJson,
            ),
    );
  }

  static int _readInt(Object? value) {
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
}
