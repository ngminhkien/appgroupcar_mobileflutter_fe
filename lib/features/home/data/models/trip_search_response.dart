import '../../../../core/models/paged_result.dart';
import '../../domain/entities/trip_search_item.dart';

class TripSearchResponse {
  const TripSearchResponse({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final PagedResult<TripSearchItem>? data;

  factory TripSearchResponse.fromJson(Map<String, dynamic> json) {
    final dataValue = json['data'];
    final dataMap = dataValue is Map<String, dynamic> ? dataValue : null;
    return TripSearchResponse(
      code: _readInt(json['code']),
      message: json['message'] as String? ?? '',
      data: dataMap == null
          ? null
          : PagedResult<TripSearchItem>.fromJson(
              dataMap,
              TripSearchItem.fromJson,
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
