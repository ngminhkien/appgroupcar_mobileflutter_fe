import 'package:equatable/equatable.dart';

enum BusBookingStatus { cash, paid, unknown }

BusBookingStatus parseBusBookingStatus(int value) {
  switch (value) {
    case 1:
      return BusBookingStatus.cash;
    case 2:
      return BusBookingStatus.paid;
    default:
      return BusBookingStatus.unknown;
  }
}

class BusBookingSeat extends Equatable {
  const BusBookingSeat({
    required this.seatId,
    required this.seatNumber,
    required this.ticketCode,
    required this.isCheckedIn,
    required this.checkedInAt,
  });

  final String seatId;
  final String seatNumber;
  final String ticketCode;
  final bool isCheckedIn;
  final DateTime? checkedInAt;

  factory BusBookingSeat.fromJson(Map<String, dynamic> json) {
    return BusBookingSeat(
      seatId: _bookingReadString(json['seatId']),
      seatNumber: _bookingReadString(json['seatNumber']),
      ticketCode: _bookingReadString(json['ticketCode']),
      isCheckedIn: _bookingReadBool(json['isCheckedIn']),
      checkedInAt: _bookingReadDateTime(json['checkedInAt']),
    );
  }

  @override
  List<Object?> get props => [
    seatId,
    seatNumber,
    ticketCode,
    isCheckedIn,
    checkedInAt,
  ];
}

class BusBooking extends Equatable {
  const BusBooking({
    required this.bookingId,
    required this.showtimeId,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.expireAt,
    required this.seats,
  });

  final String bookingId;
  final String showtimeId;
  final String userId;
  final double totalPrice;
  final int status;
  final DateTime? expireAt;
  final List<BusBookingSeat> seats;

  BusBookingStatus get bookingStatus => parseBusBookingStatus(status);

  String get statusLabel {
    switch (bookingStatus) {
      case BusBookingStatus.cash:
        return 'Cash';
      case BusBookingStatus.paid:
        return 'Paid';
      case BusBookingStatus.unknown:
        return 'Unknown';
    }
  }

  List<String> get seatNumbers {
    final normalized = seats
        .map((seat) => seat.seatNumber.trim().toUpperCase())
        .where((seat) => seat.isNotEmpty)
        .toList()
      ..sort(_seatLabelComparator);
    return normalized;
  }

  String get primaryTicketCode {
    for (final seat in seats) {
      final code = seat.ticketCode.trim();
      if (code.isNotEmpty) {
        return code;
      }
    }
    return '';
  }

  factory BusBooking.fromJson(Map<String, dynamic> json) {
    final rawSeats = _bookingReadList(json['seats']);
    return BusBooking(
      bookingId: _bookingReadString(json['bookingId']),
      showtimeId: _bookingReadString(json['showtimeId']),
      userId: _bookingReadString(json['userId']),
      totalPrice: _bookingReadDouble(json['totalPrice']),
      status: _bookingReadInt(json['status']),
      expireAt: _bookingReadDateTime(json['expireAt']),
      seats: rawSeats
          .whereType<Map<String, dynamic>>()
          .map(BusBookingSeat.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    bookingId,
    showtimeId,
    userId,
    totalPrice,
    status,
    expireAt,
    seats,
  ];
}

String _bookingReadString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

int _bookingReadInt(Object? value) {
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

double _bookingReadDouble(Object? value) {
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

bool _bookingReadBool(Object? value) {
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

DateTime? _bookingReadDateTime(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

List<dynamic> _bookingReadList(Object? value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}

int _seatLabelComparator(String left, String right) {
  final leftParts = _parseSeatLabel(left);
  final rightParts = _parseSeatLabel(right);
  if (leftParts.row != rightParts.row) {
    return leftParts.row.compareTo(rightParts.row);
  }
  if (leftParts.column != rightParts.column) {
    return leftParts.column.compareTo(rightParts.column);
  }
  return left.compareTo(right);
}

_SeatLabelParts _parseSeatLabel(String value) {
  final normalized = value.trim().toUpperCase();
  final regExp = RegExp(r'^([A-Z]+)(\d+)$');
  final match = regExp.firstMatch(normalized);
  if (match == null) {
    return _SeatLabelParts(row: 1 << 30, column: 1 << 30);
  }
  final letters = match.group(1) ?? '';
  final numbers = match.group(2) ?? '';
  var row = 0;
  for (final char in letters.codeUnits) {
    row = row * 26 + (char - 64);
  }
  final column = int.tryParse(numbers) ?? 0;
  return _SeatLabelParts(row: row, column: column);
}

class _SeatLabelParts {
  const _SeatLabelParts({required this.row, required this.column});

  final int row;
  final int column;
}
