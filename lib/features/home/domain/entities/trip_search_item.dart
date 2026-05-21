import 'package:equatable/equatable.dart';

import 'trip_route_point.dart';
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
    required this.routePoints,
    required this.reference,
    this.match,
  });

  final String tripId;
  final int tripType;
  final String tripTypeName;
  final String providerName;
  final DateTime? departureTime;
  final double price;
  final List<TripRoutePoint> routePoints;
  final TripSearchReference reference;
  final TripSearchMatch? match;

  factory TripSearchItem.fromJson(Map<String, dynamic> json) {
    final routePointsValue = json['routePoints'];
    final routePoints = routePointsValue is List
        ? routePointsValue
              .whereType<Map<String, dynamic>>()
              .map(TripRoutePoint.fromJson)
              .toList()
        : <TripRoutePoint>[];
    final referenceValue = json['reference'];
    final referenceMap = referenceValue is Map<String, dynamic>
        ? referenceValue
        : <String, dynamic>{};
    final matchValue = json['match'];
    final matchMap = matchValue is Map<String, dynamic> ? matchValue : null;

    return TripSearchItem(
      tripId: json['tripId'] as String? ?? '',
      tripType: _readInt(json['tripType']),
      tripTypeName: json['tripTypeName'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      departureTime: _tryParseDateTime(json['departureTime']),
      price: _readDouble(json['price']),
      routePoints: routePoints,
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

  @override
  List<Object?> get props => [
    tripId,
    tripType,
    tripTypeName,
    providerName,
    departureTime,
    price,
    routePoints,
    reference,
    match,
  ];
}
