import 'package:equatable/equatable.dart';

class StaffManualCheckinInfo extends Equatable {
  const StaffManualCheckinInfo({
    required this.bookingId,
    required this.ticketCode,
    required this.showtimeId,
    required this.seatNumber,
    required this.bookingStatus,
    required this.customerId,
    required this.customerFullName,
    required this.customerPhone,
    required this.customerEmail,
    required this.isCheckedIn,
    required this.checkedInAtRaw,
    this.checkedInAt,
  });

  final String bookingId;
  final String ticketCode;
  final String showtimeId;
  final String seatNumber;
  final int bookingStatus;
  final String customerId;
  final String customerFullName;
  final String customerPhone;
  final String customerEmail;
  final bool isCheckedIn;
  final String checkedInAtRaw;
  final DateTime? checkedInAt;

  factory StaffManualCheckinInfo.fromJson(Map<String, dynamic> json) {
    final checkedInAtRaw = _manualReadString(json['checkedInAt']);
    return StaffManualCheckinInfo(
      bookingId: _manualReadString(json['bookingId']),
      ticketCode: _manualReadString(json['ticketCode']),
      showtimeId: _manualReadString(json['showtimeId']),
      seatNumber: _manualReadString(json['seatNumber']),
      bookingStatus: _manualReadInt(json['bookingStatus']),
      customerId: _manualReadString(json['customerId']),
      customerFullName: _manualReadString(json['customerFullName']),
      customerPhone: _manualReadString(json['customerPhone']),
      customerEmail: _manualReadString(json['customerEmail']),
      isCheckedIn: _manualReadBool(json['isCheckedIn']),
      checkedInAtRaw: checkedInAtRaw,
      checkedInAt: DateTime.tryParse(checkedInAtRaw),
    );
  }

  @override
  List<Object?> get props => [
    bookingId,
    ticketCode,
    showtimeId,
    seatNumber,
    bookingStatus,
    customerId,
    customerFullName,
    customerPhone,
    customerEmail,
    isCheckedIn,
    checkedInAtRaw,
    checkedInAt,
  ];
}

int _manualReadInt(Object? value) {
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

bool _manualReadBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

String _manualReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}
