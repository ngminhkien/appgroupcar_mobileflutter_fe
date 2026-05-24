import 'package:equatable/equatable.dart';

enum StaffSeatAvailability { available, booked, disabled, unknown }

StaffSeatAvailability parseStaffSeatAvailability(String value) {
  switch (value.trim().toLowerCase()) {
    case 'available':
      return StaffSeatAvailability.available;
    case 'booked':
      return StaffSeatAvailability.booked;
    case 'disabled':
      return StaffSeatAvailability.disabled;
    default:
      return StaffSeatAvailability.unknown;
  }
}

class StaffSeatMap extends Equatable {
  const StaffSeatMap({
    required this.showtimeId,
    required this.seatLayout,
    required this.seats,
  });

  final String showtimeId;
  final StaffSeatLayout seatLayout;
  final List<StaffSeatStatus> seats;

  factory StaffSeatMap.fromJson(Map<String, dynamic> json) {
    final layout = _staffSeatReadMap(json['seatLayout']) ?? <String, dynamic>{};
    final rawSeats = _staffSeatReadList(json['seats']);
    return StaffSeatMap(
      showtimeId: _staffSeatReadString(json['showtimeId']),
      seatLayout: StaffSeatLayout.fromJson(layout),
      seats: rawSeats
          .whereType<Map<String, dynamic>>()
          .map(StaffSeatStatus.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [showtimeId, seatLayout, seats];
}

class StaffSeatLayout extends Equatable {
  const StaffSeatLayout({
    required this.id,
    required this.seatLayoutName,
    required this.seatCapacity,
    required this.layoutJson,
  });

  final String id;
  final String seatLayoutName;
  final int seatCapacity;
  final Map<String, dynamic>? layoutJson;

  factory StaffSeatLayout.fromJson(Map<String, dynamic> json) {
    return StaffSeatLayout(
      id: _staffSeatReadString(json['id']),
      seatLayoutName: _staffSeatReadString(json['seatLayoutName']),
      seatCapacity: _staffSeatReadInt(json['seatCapacity']),
      layoutJson: _staffSeatReadMap(json['layoutJson']),
    );
  }

  @override
  List<Object?> get props => [id, seatLayoutName, seatCapacity, layoutJson];
}

class StaffSeatStatus extends Equatable {
  const StaffSeatStatus({required this.seatNumber, required this.status});

  final String seatNumber;
  final String status;

  StaffSeatAvailability get availability => parseStaffSeatAvailability(status);

  factory StaffSeatStatus.fromJson(Map<String, dynamic> json) {
    return StaffSeatStatus(
      seatNumber: _staffSeatReadString(json['seatNumber']),
      status: _staffSeatReadString(json['status']),
    );
  }

  @override
  List<Object?> get props => [seatNumber, status];
}

int _staffSeatReadInt(Object? value) {
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

String _staffSeatReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

Map<String, dynamic>? _staffSeatReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<dynamic> _staffSeatReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
