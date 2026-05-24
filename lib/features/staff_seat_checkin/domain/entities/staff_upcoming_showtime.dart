import 'package:equatable/equatable.dart';

enum StaffBusShowtimeStatus {
  scheduled,
  active,
  delayed,
  cancelled,
  hidden,
  complete,
  unknown,
}

StaffBusShowtimeStatus parseStaffBusShowtimeStatus(int value) {
  switch (value) {
    case 1:
      return StaffBusShowtimeStatus.scheduled;
    case 2:
      return StaffBusShowtimeStatus.active;
    case 3:
      return StaffBusShowtimeStatus.delayed;
    case 4:
      return StaffBusShowtimeStatus.cancelled;
    case 5:
      return StaffBusShowtimeStatus.hidden;
    case 6:
      return StaffBusShowtimeStatus.complete;
    default:
      return StaffBusShowtimeStatus.unknown;
  }
}

class StaffUpcomingShowtimeResult extends Equatable {
  const StaffUpcomingShowtimeResult({
    required this.companyId,
    required this.fromDate,
    required this.total,
    required this.items,
  });

  final String companyId;
  final String fromDate;
  final int total;
  final List<StaffUpcomingShowtime> items;

  factory StaffUpcomingShowtimeResult.fromJson(Map<String, dynamic> json) {
    final rawItems = _staffReadList(json['items']);
    return StaffUpcomingShowtimeResult(
      companyId: _staffReadString(json['companyId']),
      fromDate: _staffReadString(json['fromDate']),
      total: _staffReadInt(json['total']),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(StaffUpcomingShowtime.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [companyId, fromDate, total, items];
}

class StaffUpcomingShowtime extends Equatable {
  const StaffUpcomingShowtime({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.companyVehicleId,
    required this.plateNumber,
    required this.companyDriverId,
    required this.driverName,
    required this.departureDate,
    required this.departureTime,
    required this.price,
    required this.status,
    required this.seatCount,
  });

  final String id;
  final String routeId;
  final String routeName;
  final String companyVehicleId;
  final String plateNumber;
  final String companyDriverId;
  final String driverName;
  final String departureDate;
  final String departureTime;
  final double price;
  final int status;
  final int seatCount;

  StaffBusShowtimeStatus get showtimeStatus =>
      parseStaffBusShowtimeStatus(status);

  DateTime? get departureDateTime {
    final date = departureDate.trim();
    if (date.isEmpty) {
      return null;
    }
    final time = departureTime.trim();
    final raw = time.isEmpty ? date : '${date}T$time';
    return DateTime.tryParse(raw);
  }

  factory StaffUpcomingShowtime.fromJson(Map<String, dynamic> json) {
    return StaffUpcomingShowtime(
      id: _staffReadString(json['id']),
      routeId: _staffReadString(json['routeId']),
      routeName: _staffReadString(json['routeName']),
      companyVehicleId: _staffReadString(json['companyVehicleId']),
      plateNumber: _staffReadString(json['plateNumber']),
      companyDriverId: _staffReadString(json['companyDriverId']),
      driverName: _staffReadString(json['driverName']),
      departureDate: _staffReadString(json['departureDate']),
      departureTime: _staffReadString(json['departureTime']),
      price: _staffReadDouble(json['price']),
      status: _staffReadInt(json['status']),
      seatCount: _staffReadInt(json['seatCount']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    routeId,
    routeName,
    companyVehicleId,
    plateNumber,
    companyDriverId,
    driverName,
    departureDate,
    departureTime,
    price,
    status,
    seatCount,
  ];
}

int _staffReadInt(Object? value) {
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

double _staffReadDouble(Object? value) {
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

String _staffReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

List<dynamic> _staffReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
