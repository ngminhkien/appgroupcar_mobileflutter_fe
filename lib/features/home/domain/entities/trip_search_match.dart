import 'package:equatable/equatable.dart';

class TripSearchMatch extends Equatable {
  const TripSearchMatch({
    required this.exactPickupLocationId,
    required this.exactDropoffLocationId,
    required this.matchedPickupLocationId,
    required this.matchedDropoffLocationId,
    required this.pickupMatchType,
    required this.dropoffMatchType,
    required this.usedNearbyForPickup,
    required this.usedNearbyForDropoff,
  });

  final String exactPickupLocationId;
  final String exactDropoffLocationId;
  final String matchedPickupLocationId;
  final String matchedDropoffLocationId;
  final int pickupMatchType;
  final int dropoffMatchType;
  final bool usedNearbyForPickup;
  final bool usedNearbyForDropoff;

  factory TripSearchMatch.fromJson(Map<String, dynamic> json) {
    return TripSearchMatch(
      exactPickupLocationId: json['exactPickupLocationId'] as String? ?? '',
      exactDropoffLocationId: json['exactDropoffLocationId'] as String? ?? '',
      matchedPickupLocationId: json['matchedPickupLocationId'] as String? ?? '',
      matchedDropoffLocationId:
          json['matchedDropoffLocationId'] as String? ?? '',
      pickupMatchType: _readInt(json['pickupMatchType']),
      dropoffMatchType: _readInt(json['dropoffMatchType']),
      usedNearbyForPickup: _readBool(json['usedNearbyForPickup']),
      usedNearbyForDropoff: _readBool(json['usedNearbyForDropoff']),
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
    exactPickupLocationId,
    exactDropoffLocationId,
    matchedPickupLocationId,
    matchedDropoffLocationId,
    pickupMatchType,
    dropoffMatchType,
    usedNearbyForPickup,
    usedNearbyForDropoff,
  ];
}
