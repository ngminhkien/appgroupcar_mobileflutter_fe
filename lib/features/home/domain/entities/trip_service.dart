enum TripService { bus, sharedRide, truck }

extension TripServiceX on TripService {
  String get apiValue {
    switch (this) {
      case TripService.bus:
        return 'Bus';
      case TripService.sharedRide:
        return 'SharedRide';
      case TripService.truck:
        return 'Truck';
    }
  }

  String get displayName {
    switch (this) {
      case TripService.bus:
        return 'Xe khach';
      case TripService.sharedRide:
        return 'Xe ghep';
      case TripService.truck:
        return 'Cho hang';
    }
  }

  String get subtitle {
    switch (this) {
      case TripService.bus:
        return 'Tuyen co dinh, gia tot';
      case TripService.sharedRide:
        return 'Di chung, linh hoat';
      case TripService.truck:
        return 'Giao nhanh trong ngay';
    }
  }

  static TripService? fromApiValue(String value) {
    switch (value.toLowerCase()) {
      case 'bus':
        return TripService.bus;
      case 'sharedride':
        return TripService.sharedRide;
      case 'truck':
        return TripService.truck;
      default:
        return null;
    }
  }
}
