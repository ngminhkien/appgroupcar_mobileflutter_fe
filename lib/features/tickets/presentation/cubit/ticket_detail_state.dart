import 'package:equatable/equatable.dart';

import '../../domain/entities/bus_booking_detail.dart';

enum TicketDetailStatus { initial, loading, success, failure }

const Object _ticketDetailUnset = Object();

class TicketDetailState extends Equatable {
  const TicketDetailState({
    this.status = TicketDetailStatus.initial,
    this.bookingId = '',
    this.detail,
    this.errorMessage,
  });

  final TicketDetailStatus status;
  final String bookingId;
  final BusBookingDetail? detail;
  final String? errorMessage;

  TicketDetailState copyWith({
    TicketDetailStatus? status,
    String? bookingId,
    Object? detail = _ticketDetailUnset,
    Object? errorMessage = _ticketDetailUnset,
  }) {
    return TicketDetailState(
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      detail: detail == _ticketDetailUnset
          ? this.detail
          : detail as BusBookingDetail?,
      errorMessage: errorMessage == _ticketDetailUnset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, bookingId, detail, errorMessage];
}
