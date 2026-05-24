import 'package:equatable/equatable.dart';

class BusShowtimeDetail extends Equatable {
  const BusShowtimeDetail({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.departureDate,
    required this.departureTime,
    required this.price,
    required this.status,
    required this.seatCount,
    this.route,
    this.vehicle,
    this.driver,
  });

  final String id;
  final String companyId;
  final String companyName;
  final String departureDate;
  final String departureTime;
  final double price;
  final int status;
  final int seatCount;
  final BusRouteDetail? route;
  final BusVehicleDetail? vehicle;
  final BusDriverDetail? driver;

  DateTime? get departureDateTime {
    final date = departureDate.trim();
    if (date.isEmpty) {
      return null;
    }
    final time = departureTime.trim();
    final raw = time.isEmpty ? date : '${date}T$time';
    return DateTime.tryParse(raw);
  }

  factory BusShowtimeDetail.fromJson(Map<String, dynamic> json) {
    final routeMap = _readMap(json['route']);
    final vehicleMap = _readMap(json['vehicle']);
    final driverMap = _readMap(json['driver']);
    return BusShowtimeDetail(
      id: _readString(json['id']),
      companyId: _readString(json['companyId']),
      companyName: _readString(json['companyName']),
      departureDate: _readString(json['departureDate']),
      departureTime: _readString(json['departureTime']),
      price: _readDouble(json['price']),
      status: _readInt(json['status']),
      seatCount: _readInt(json['seatCount']),
      route: routeMap == null ? null : BusRouteDetail.fromJson(routeMap),
      vehicle: vehicleMap == null
          ? null
          : BusVehicleDetail.fromJson(vehicleMap),
      driver: driverMap == null ? null : BusDriverDetail.fromJson(driverMap),
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    companyName,
    departureDate,
    departureTime,
    price,
    status,
    seatCount,
    route,
    vehicle,
    driver,
  ];
}

class BusRouteDetail extends Equatable {
  const BusRouteDetail({
    required this.id,
    required this.name,
    required this.companyId,
    required this.estimatedDurationMinutes,
    required this.routePoints,
  });

  final String id;
  final String name;
  final String companyId;
  final int? estimatedDurationMinutes;
  final List<BusRoutePointDetail> routePoints;

  factory BusRouteDetail.fromJson(Map<String, dynamic> json) {
    final rawPoints = _readList(json['routePoints']);
    return BusRouteDetail(
      id: _readString(json['id']),
      name: _readString(json['name']),
      companyId: _readString(json['companyId']),
      estimatedDurationMinutes: _readNullableInt(
        json['estimatedDurationMinutes'],
      ),
      routePoints: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(BusRoutePointDetail.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    companyId,
    estimatedDurationMinutes,
    routePoints,
  ];
}

class BusRoutePointDetail extends Equatable {
  const BusRoutePointDetail({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.sequence,
    required this.stopType,
    required this.pickupAllowed,
    required this.dropoffAllowed,
  });

  final String id;
  final String locationId;
  final String locationName;
  final int sequence;
  final int stopType;
  final bool pickupAllowed;
  final bool dropoffAllowed;

  factory BusRoutePointDetail.fromJson(Map<String, dynamic> json) {
    return BusRoutePointDetail(
      id: _readString(json['id']),
      locationId: _readString(json['locationId']),
      locationName: _readString(json['locationName']),
      sequence: _readInt(json['sequence']),
      stopType: _readInt(json['stopType']),
      pickupAllowed: _readBool(json['pickupAllowed']),
      dropoffAllowed: _readBool(json['dropoffAllowed']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    locationId,
    locationName,
    sequence,
    stopType,
    pickupAllowed,
    dropoffAllowed,
  ];
}

class BusVehicleDetail extends Equatable {
  const BusVehicleDetail({
    required this.companyVehicleId,
    required this.seatLayoutId,
    required this.seatLayoutName,
    required this.plateNumber,
    required this.seatCapacity,
    required this.vehicleType,
    required this.urlImage,
  });

  final String companyVehicleId;
  final String seatLayoutId;
  final String seatLayoutName;
  final String plateNumber;
  final int seatCapacity;
  final int vehicleType;
  final String urlImage;

  factory BusVehicleDetail.fromJson(Map<String, dynamic> json) {
    return BusVehicleDetail(
      companyVehicleId: _readString(json['companyVehicleId']),
      seatLayoutId: _readString(json['seatLayoutId']),
      seatLayoutName: _readString(json['seatLayoutName']),
      plateNumber: _readString(json['plateNumber']),
      seatCapacity: _readInt(json['seatCapacity']),
      vehicleType: _readInt(json['vehicleType']),
      urlImage: _readString(json['urlImage']),
    );
  }

  @override
  List<Object?> get props => [
    companyVehicleId,
    seatLayoutId,
    seatLayoutName,
    plateNumber,
    seatCapacity,
    vehicleType,
    urlImage,
  ];
}

class BusDriverDetail extends Equatable {
  const BusDriverDetail({
    required this.companyDriverId,
    required this.userId,
    required this.fullName,
    required this.avatarUrl,
    required this.licenseNumber,
    required this.licenseClass,
  });

  final String companyDriverId;
  final String userId;
  final String fullName;
  final String avatarUrl;
  final String licenseNumber;
  final String licenseClass;

  factory BusDriverDetail.fromJson(Map<String, dynamic> json) {
    return BusDriverDetail(
      companyDriverId: _readString(json['companyDriverId']),
      userId: _readString(json['userId']),
      fullName: _readString(json['fullName']),
      avatarUrl: _readString(json['avatarUrl']),
      licenseNumber: _readString(json['licenseNumber']),
      licenseClass: _readString(json['licenseClass']),
    );
  }

  @override
  List<Object?> get props => [
    companyDriverId,
    userId,
    fullName,
    avatarUrl,
    licenseNumber,
    licenseClass,
  ];
}

String _readString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

double _readDouble(Object? value) {
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

int _readInt(Object? value) {
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

int? _readNullableInt(Object? value) {
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

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<dynamic> _readList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
