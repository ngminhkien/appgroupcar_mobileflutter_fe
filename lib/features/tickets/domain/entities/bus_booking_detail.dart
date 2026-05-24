import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/bus_showtime_detail.dart';
import 'bus_booking.dart';

class BusBookingDetail extends Equatable {
  const BusBookingDetail({
    required this.booking,
    required this.showtime,
  });

  final BusBooking booking;
  final BusShowtimeDetail? showtime;

  String get bookingId => booking.bookingId;
  String get showtimeId => booking.showtimeId;
  String get userId => booking.userId;
  double get totalPrice => booking.totalPrice;
  int get status => booking.status;
  DateTime? get expireAt => booking.expireAt;
  List<BusBookingSeat> get seats => booking.seats;
  BusBookingStatus get bookingStatus => booking.bookingStatus;
  String get statusLabel => booking.statusLabel;
  String get primaryTicketCode => booking.primaryTicketCode;
  List<String> get seatNumbers => booking.seatNumbers;

  factory BusBookingDetail.fromJson(Map<String, dynamic> json) {
    final showtimeMap = _bookingDetailReadMap(json['showtime']);
    return BusBookingDetail(
      booking: BusBooking.fromJson(json),
      showtime: showtimeMap == null ? null : BusShowtimeDetail.fromJson(showtimeMap),
    );
  }

  @override
  List<Object?> get props => [booking, showtime];
}

Map<String, dynamic>? _bookingDetailReadMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
