import 'package:equatable/equatable.dart';

class TripRoutePointSummary extends Equatable {
  const TripRoutePointSummary({
    required this.locationId,
    required this.locationName,
    required this.sequence,
    required this.stopType,
    required this.estimatedArrivalTime,
    required this.estimatedTravelMinutesFromDeparture,
  });

  final String locationId;
  final String locationName;
  final int sequence;
  final int stopType;
  final String? estimatedArrivalTime;
  final int? estimatedTravelMinutesFromDeparture;

  factory TripRoutePointSummary.fromJson(Map<String, dynamic> json) {
    return TripRoutePointSummary(
      locationId: json['locationId'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      sequence: _readInt(json['sequence']),
      stopType: _readInt(json['stopType']),
      estimatedArrivalTime: _readNullableString(json['estimatedArrivalTime']),
      estimatedTravelMinutesFromDeparture: _readNullableInt(
        json['estimatedTravelMinutesFromDeparture'],
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

  @override
  List<Object?> get props => [
    locationId,
    locationName,
    sequence,
    stopType,
    estimatedArrivalTime,
    estimatedTravelMinutesFromDeparture,
  ];
}
