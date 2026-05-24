import 'package:equatable/equatable.dart';

enum BusSeatAvailability { available, booked, disabled, unknown }

BusSeatAvailability parseBusSeatAvailability(String value) {
  switch (value.trim().toLowerCase()) {
    case 'available':
      return BusSeatAvailability.available;
    case 'booked':
      return BusSeatAvailability.booked;
    case 'disabled':
      return BusSeatAvailability.disabled;
    default:
      return BusSeatAvailability.unknown;
  }
}

class BusSeatMap extends Equatable {
  const BusSeatMap({
    required this.showtimeId,
    required this.seatLayout,
    required this.seats,
  });

  final String showtimeId;
  final BusSeatLayout seatLayout;
  final List<BusSeatStatus> seats;

  factory BusSeatMap.fromJson(Map<String, dynamic> json) {
    final layoutMap = _seatReadMap(json['seatLayout']) ?? <String, dynamic>{};
    final rawSeats = _seatReadList(json['seats']);
    return BusSeatMap(
      showtimeId: _seatReadString(json['showtimeId']),
      seatLayout: BusSeatLayout.fromJson(layoutMap),
      seats: rawSeats
          .whereType<Map<String, dynamic>>()
          .map(BusSeatStatus.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [showtimeId, seatLayout, seats];
}

class BusSeatLayout extends Equatable {
  const BusSeatLayout({
    required this.id,
    required this.seatLayoutName,
    required this.seatCapacity,
    required this.layoutJson,
    required this.description,
  });

  final String id;
  final String seatLayoutName;
  final int seatCapacity;
  final Map<String, dynamic>? layoutJson;
  final String description;

  factory BusSeatLayout.fromJson(Map<String, dynamic> json) {
    final layout = _seatReadMap(json['layoutJson']);
    return BusSeatLayout(
      id: _seatReadString(json['id']),
      seatLayoutName: _seatReadString(json['seatLayoutName']),
      seatCapacity: _seatReadInt(json['seatCapacity']),
      layoutJson: layout,
      description: _seatReadString(json['description']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    seatLayoutName,
    seatCapacity,
    layoutJson,
    description,
  ];
}

class BusSeatStatus extends Equatable {
  const BusSeatStatus({required this.seatNumber, required this.status});

  final String seatNumber;
  final String status;

  BusSeatAvailability get availability => parseBusSeatAvailability(status);

  factory BusSeatStatus.fromJson(Map<String, dynamic> json) {
    return BusSeatStatus(
      seatNumber: _seatReadString(json['seatNumber']),
      status: _seatReadString(json['status']),
    );
  }

  @override
  List<Object?> get props => [seatNumber, status];
}

String _seatReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

int _seatReadInt(Object? value) {
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

Map<String, dynamic>? _seatReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<dynamic> _seatReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}
