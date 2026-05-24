import 'package:equatable/equatable.dart';

import '../../domain/entities/bus_booking.dart';

enum BusBookingActionStatus { initial, loading, success, failure }

const Object _bookingActionUnset = Object();

class BusBookingActionState extends Equatable {
  const BusBookingActionState({
    this.status = BusBookingActionStatus.initial,
    this.booking,
    this.errorMessage,
  });

  final BusBookingActionStatus status;
  final BusBooking? booking;
  final String? errorMessage;

  BusBookingActionState copyWith({
    BusBookingActionStatus? status,
    Object? booking = _bookingActionUnset,
    Object? errorMessage = _bookingActionUnset,
  }) {
    return BusBookingActionState(
      status: status ?? this.status,
      booking: booking == _bookingActionUnset
          ? this.booking
          : booking as BusBooking?,
      errorMessage: errorMessage == _bookingActionUnset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, booking, errorMessage];
}
