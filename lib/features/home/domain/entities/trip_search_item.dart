import 'package:equatable/equatable.dart';

import 'trip_route_point_summary.dart';
import 'trip_search_match.dart';
import 'trip_search_reference.dart';

class TripSearchItem extends Equatable {
  const TripSearchItem({
    required this.tripId,
    required this.tripType,
    required this.tripTypeName,
    required this.providerName,
    required this.departureTime,
    required this.price,
    required this.estimatedDurationMinutes,
    required this.estimatedArrivalTime,
    required this.startPoint,
    required this.endPoint,
    required this.matchedPickupPoint,
    required this.matchedDropoffPoint,
    required this.reference,
    this.match,
  });

  final String tripId;
  final int tripType;
  final String tripTypeName;
  final String providerName;
  final DateTime? departureTime;
  final double price;
  final int? estimatedDurationMinutes;
  final String? estimatedArrivalTime;
  final TripRoutePointSummary? startPoint;
  final TripRoutePointSummary? endPoint;
  final TripRoutePointSummary? matchedPickupPoint;
  final TripRoutePointSummary? matchedDropoffPoint;
  final TripSearchReference reference;
  final TripSearchMatch? match;

  factory TripSearchItem.fromJson(Map<String, dynamic> json) {
    final referenceValue = json['reference'];
    final referenceMap = referenceValue is Map<String, dynamic>
        ? referenceValue
        : <String, dynamic>{};
    final matchValue = json['match'];
    final matchMap = matchValue is Map<String, dynamic> ? matchValue : null;
    final startPointMap = _readMap(json['startPoint']);
    final endPointMap = _readMap(json['endPoint']);
    final matchedPickupPointMap = _readMap(json['matchedPickupPoint']);
    final matchedDropoffPointMap = _readMap(json['matchedDropoffPoint']);

    return TripSearchItem(
      tripId: json['tripId'] as String? ?? '',
      tripType: _readInt(json['tripType']),
      tripTypeName: json['tripTypeName'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      departureTime: _tryParseDateTime(json['departureTime']),
      price: _readDouble(json['price']),
      estimatedDurationMinutes: _readNullableInt(
        json['estimatedDurationMinutes'],
      ),
      estimatedArrivalTime: _readNullableString(json['estimatedArrivalTime']),
      startPoint: startPointMap == null
          ? null
          : TripRoutePointSummary.fromJson(startPointMap),
      endPoint: endPointMap == null
          ? null
          : TripRoutePointSummary.fromJson(endPointMap),
      matchedPickupPoint: matchedPickupPointMap == null
          ? null
          : TripRoutePointSummary.fromJson(matchedPickupPointMap),
      matchedDropoffPoint: matchedDropoffPointMap == null
          ? null
          : TripRoutePointSummary.fromJson(matchedDropoffPointMap),
      reference: TripSearchReference.fromJson(referenceMap),
      match: matchMap == null ? null : TripSearchMatch.fromJson(matchMap),
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

  static double _readDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime? _tryParseDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _readNullableString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    tripId,
    tripType,
    tripTypeName,
    providerName,
    departureTime,
    price,
    estimatedDurationMinutes,
    estimatedArrivalTime,
    startPoint,
    endPoint,
    matchedPickupPoint,
    matchedDropoffPoint,
    reference,
    match,
  ];
}
