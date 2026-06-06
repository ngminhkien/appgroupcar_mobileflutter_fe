import 'package:equatable/equatable.dart';

class SharedRideDetail extends Equatable {
  const SharedRideDetail({
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
    this.totalSeats,
    this.availableSeats,
    this.tripType = 2,
    this.tripTypeName = 'Xe ghep',
  });

  final String id;
  final String companyId;
  final String companyName;
  final String departureDate;
  final String departureTime;
  final double price;
  final int status;
  final int seatCount;
  final SharedRideRouteDetail? route;
  final SharedRideVehicleDetail? vehicle;
  final SharedRideDriverDetail? driver;
  final int? totalSeats;
  final int? availableSeats;
  final int tripType;
  final String tripTypeName;

  DateTime? get departureDateTime {
    final date = departureDate.trim();
    if (date.isEmpty) {
      return null;
    }
    final time = departureTime.trim();
    final raw = time.isEmpty ? date : '${date}T$time';
    return DateTime.tryParse(raw);
  }

  factory SharedRideDetail.fromJson(Map<String, dynamic> json) {
    var routeMap = _readMap(json['route']);
    if (routeMap == null) {
      final rawPoints =
          json['routePoints'] ??
          (json['startPoint'] != null && json['endPoint'] != null
              ? [
                  {
                    'id': 'start-point-id',
                    'locationId': json['startPoint']['locationId'] ?? '',
                    'locationName': json['startPoint']['locationName'] ?? '',
                    'sequence': 1,
                    'stopType': 1,
                    'pickupAllowed': true,
                    'dropoffAllowed': false,
                  },
                  {
                    'id': 'end-point-id',
                    'locationId': json['endPoint']['locationId'] ?? '',
                    'locationName': json['endPoint']['locationName'] ?? '',
                    'sequence': 2,
                    'stopType': 5,
                    'pickupAllowed': false,
                    'dropoffAllowed': true,
                  },
                ]
              : null);
      if (rawPoints != null) {
        routeMap = {
          'id': json['routeId'] ?? json['id'] ?? '',
          'name': json['routeName'] ?? json['name'] ?? '',
          'companyId': json['companyId'] ?? '',
          'estimatedDurationMinutes': json['estimatedDurationMinutes'],
          'routePoints': rawPoints,
        };
      }
    }

    var vehicleMap = _readMap(json['vehicle']);
    if (vehicleMap == null &&
        (json['plateNumber'] != null || json['vehicleId'] != null)) {
      vehicleMap = {
        'companyVehicleId': json['vehicleId'] ?? json['companyVehicleId'] ?? '',
        'seatLayoutId': json['seatLayoutId'] ?? '',
        'seatLayoutName': json['seatLayoutName'] ?? '',
        'plateNumber': json['plateNumber'] ?? '',
        'seatCapacity': json['seatCapacity'] ?? json['totalSeats'] ?? 0,
        'vehicleType': json['vehicleType'] ?? 0,
        'urlImage': json['urlImage'] ?? '',
        'brand': json['brand'] ?? '',
      };
    }

    var driverMap = _readMap(json['driver']);
    if (driverMap == null &&
        (json['driverId'] != null ||
            json['driverName'] != null ||
            json['fullName'] != null)) {
      driverMap = {
        'companyDriverId': json['driverId'] ?? json['companyDriverId'] ?? '',
        'userId': json['userId'] ?? '',
        'fullName': json['driverName'] ?? json['fullName'] ?? '',
        'avatarUrl': json['avatarUrl'] ?? '',
        'licenseNumber': json['licenseNumber'] ?? '',
        'licenseClass': json['licenseClass'] ?? '',
        'driverRatingAverage': json['driverRatingAverage'] ?? 0.0,
        'driverRatingCount': json['driverRatingCount'] ?? 0,
      };
    }

    final parsedPrice = _readDouble(json['price'] ?? json['basePrice']);
    final totalSeatsVal = _readNullableInt(json['totalSeats']);
    final availableSeatsVal = _readNullableInt(json['availableSeats']);
    final seatCountVal = _readInt(json['seatCount'] ?? json['totalSeats']);
    final tripTypeVal = _readInt(json['tripType'] ?? 2);
    final tripTypeNameVal = _readString(json['tripTypeName'] ?? 'Xe ghep');

    var depDate = _readString(json['departureDate']);
    var depTime = _readString(json['departureTime']);
    if (depDate.isEmpty && depTime.isNotEmpty && depTime.contains('T')) {
      final parts = depTime.split('T');
      depDate = parts[0];
      depTime = parts[1].replaceAll('Z', '');
    }

    var compName = _readString(json['companyName']);
    if (compName.trim().isEmpty) {
      compName = 'Xe ghép';
    }

    return SharedRideDetail(
      id: _readString(json['id']),
      companyId: _readString(json['companyId'] ?? json['driverId']),
      companyName: compName,
      departureDate: depDate,
      departureTime: depTime,
      price: parsedPrice,
      status: _readInt(json['status']),
      seatCount: seatCountVal,
      route: routeMap == null ? null : SharedRideRouteDetail.fromJson(routeMap),
      vehicle: vehicleMap == null
          ? null
          : SharedRideVehicleDetail.fromJson(vehicleMap),
      driver: driverMap == null
          ? null
          : SharedRideDriverDetail.fromJson(driverMap),
      totalSeats: totalSeatsVal,
      availableSeats: availableSeatsVal,
      tripType: tripTypeVal,
      tripTypeName: tripTypeNameVal,
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
    totalSeats,
    availableSeats,
    tripType,
    tripTypeName,
  ];
}

class SharedRideRouteDetail extends Equatable {
  const SharedRideRouteDetail({
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
  final List<SharedRideRoutePointDetail> routePoints;

  factory SharedRideRouteDetail.fromJson(Map<String, dynamic> json) {
    final rawPoints = _readList(json['routePoints']);
    return SharedRideRouteDetail(
      id: _readString(json['id']),
      name: _readString(json['name']),
      companyId: _readString(json['companyId']),
      estimatedDurationMinutes: _readNullableInt(
        json['estimatedDurationMinutes'],
      ),
      routePoints: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(SharedRideRoutePointDetail.fromJson)
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

class SharedRideRoutePointDetail extends Equatable {
  const SharedRideRoutePointDetail({
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

  factory SharedRideRoutePointDetail.fromJson(Map<String, dynamic> json) {
    return SharedRideRoutePointDetail(
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

class SharedRideVehicleDetail extends Equatable {
  const SharedRideVehicleDetail({
    required this.companyVehicleId,
    required this.seatLayoutId,
    required this.seatLayoutName,
    required this.plateNumber,
    required this.seatCapacity,
    required this.vehicleType,
    required this.urlImage,
    this.brand = '',
  });

  final String companyVehicleId;
  final String seatLayoutId;
  final String seatLayoutName;
  final String plateNumber;
  final int seatCapacity;
  final int vehicleType;
  final String urlImage;
  final String brand;

  factory SharedRideVehicleDetail.fromJson(Map<String, dynamic> json) {
    return SharedRideVehicleDetail(
      companyVehicleId: _readString(
        json['companyVehicleId'] ?? json['vehicleId'],
      ),
      seatLayoutId: _readString(json['seatLayoutId']),
      seatLayoutName: _readString(json['seatLayoutName']),
      plateNumber: _readString(json['plateNumber']),
      seatCapacity: _readInt(json['seatCapacity']),
      vehicleType: _readInt(json['vehicleType']),
      urlImage: _readString(json['urlImage']),
      brand: _readString(json['brand']),
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
    brand,
  ];
}

class SharedRideDriverDetail extends Equatable {
  const SharedRideDriverDetail({
    required this.companyDriverId,
    required this.userId,
    required this.fullName,
    required this.avatarUrl,
    required this.licenseNumber,
    required this.licenseClass,
    this.driverRatingAverage = 0.0,
    this.driverRatingCount = 0,
  });

  final String companyDriverId;
  final String userId;
  final String fullName;
  final String avatarUrl;
  final String licenseNumber;
  final String licenseClass;
  final double driverRatingAverage;
  final int driverRatingCount;

  factory SharedRideDriverDetail.fromJson(Map<String, dynamic> json) {
    return SharedRideDriverDetail(
      companyDriverId: _readString(json['companyDriverId'] ?? json['driverId']),
      userId: _readString(json['userId']),
      fullName: _readString(json['fullName']),
      avatarUrl: _readString(json['avatarUrl']),
      licenseNumber: _readString(json['licenseNumber']),
      licenseClass: _readString(json['licenseClass']),
      driverRatingAverage: _readDouble(json['driverRatingAverage']),
      driverRatingCount: _readInt(json['driverRatingCount']),
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
    driverRatingAverage,
    driverRatingCount,
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
