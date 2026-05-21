import 'package:equatable/equatable.dart';

class TripRoutePoint extends Equatable {
  const TripRoutePoint({
    required this.locationId,
    required this.locationName,
    required this.sequence,
    required this.pickupAllowed,
    required this.dropoffAllowed,
  });

  final String locationId;
  final String locationName;
  final int sequence;
  final bool pickupAllowed;
  final bool dropoffAllowed;

  factory TripRoutePoint.fromJson(Map<String, dynamic> json) {
    return TripRoutePoint(
      locationId: json['locationId'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      sequence: _readInt(json['sequence']),
      pickupAllowed: _readBool(json['pickupAllowed']),
      dropoffAllowed: _readBool(json['dropoffAllowed']),
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

  static bool _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  @override
  List<Object?> get props => [
    locationId,
    locationName,
    sequence,
    pickupAllowed,
    dropoffAllowed,
  ];
}
