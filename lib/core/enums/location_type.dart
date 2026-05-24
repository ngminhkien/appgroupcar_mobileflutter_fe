enum LocationType {
  unknown(0),
  province(1),
  district(2),
  ward(3),
  busStation(4),
  landmark(5),
  depot(6),
  other(99);

  const LocationType(this.value);

  final int value;

  static LocationType fromValue(int value) {
    for (final type in LocationType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return LocationType.unknown;
  }
}

extension LocationTypeX on LocationType {
  bool get isAdministrative =>
      this == LocationType.province || this == LocationType.district;

  bool get isRouteStopAllowed =>
      this == LocationType.ward ||
      this == LocationType.busStation ||
      this == LocationType.landmark ||
      this == LocationType.depot;

  String get displayLabel {
    switch (this) {
      case LocationType.province:
        return 'Province';
      case LocationType.district:
        return 'District';
      case LocationType.ward:
        return 'Ward';
      case LocationType.busStation:
        return 'BusStation';
      case LocationType.landmark:
        return 'Landmark';
      case LocationType.depot:
        return 'Depot';
      case LocationType.other:
        return 'Other';
      case LocationType.unknown:
        return 'Unknown';
    }
  }
}
