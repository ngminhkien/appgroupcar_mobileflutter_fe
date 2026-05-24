enum RouteStopType {
  unknown(0),
  start(1),
  pickup(2),
  transit(3),
  dropoff(4),
  end(5);

  const RouteStopType(this.value);

  final int value;

  static RouteStopType fromValue(int value) {
    for (final type in RouteStopType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return RouteStopType.unknown;
  }
}

extension RouteStopTypeX on RouteStopType {
  bool get pickupAllowed {
    switch (this) {
      case RouteStopType.start:
      case RouteStopType.pickup:
      case RouteStopType.transit:
        return true;
      case RouteStopType.dropoff:
      case RouteStopType.end:
      case RouteStopType.unknown:
        return false;
    }
  }

  bool get dropoffAllowed {
    switch (this) {
      case RouteStopType.transit:
      case RouteStopType.dropoff:
      case RouteStopType.end:
        return true;
      case RouteStopType.start:
      case RouteStopType.pickup:
      case RouteStopType.unknown:
        return false;
    }
  }

  String get displayLabel {
    switch (this) {
      case RouteStopType.start:
        return 'Start';
      case RouteStopType.pickup:
        return 'Pickup';
      case RouteStopType.transit:
        return 'Transit';
      case RouteStopType.dropoff:
        return 'Dropoff';
      case RouteStopType.end:
        return 'End';
      case RouteStopType.unknown:
        return 'Unknown';
    }
  }
}
