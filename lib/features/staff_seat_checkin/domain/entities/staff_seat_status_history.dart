import 'package:equatable/equatable.dart';

class StaffSeatStatusHistory extends Equatable {
  const StaffSeatStatusHistory({
    required this.seatNumber,
    required this.oldStatus,
    required this.newStatus,
    required this.changedAtRaw,
    this.changedAt,
  });

  final String seatNumber;
  final int oldStatus;
  final int newStatus;
  final String changedAtRaw;
  final DateTime? changedAt;

  factory StaffSeatStatusHistory.fromJson(Map<String, dynamic> json) {
    final seatNumber = _readStatusString(
      json['seatNumber'] ?? json['seatNo'] ?? json['number'],
    );
    final oldStatus = _readStatusInt(
      json['oldStatus'] ?? json['fromStatus'] ?? json['previousStatus'],
    );
    final newStatus = _readStatusInt(
      json['newStatus'] ?? json['toStatus'] ?? json['currentStatus'],
    );
    final changedAtRaw = _readStatusString(
      json['changedAt'] ??
          json['changedTime'] ??
          json['updatedAt'] ??
          json['createdAt'],
    );
    return StaffSeatStatusHistory(
      seatNumber: seatNumber,
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedAtRaw: changedAtRaw,
      changedAt: DateTime.tryParse(changedAtRaw),
    );
  }

  @override
  List<Object?> get props => [
    seatNumber,
    oldStatus,
    newStatus,
    changedAtRaw,
    changedAt,
  ];
}

int _readStatusInt(Object? value) {
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

String _readStatusString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}
