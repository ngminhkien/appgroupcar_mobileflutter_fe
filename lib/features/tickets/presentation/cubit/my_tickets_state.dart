import 'package:equatable/equatable.dart';

import '../../domain/entities/bus_booking.dart';

enum MyTicketsStatus { initial, loading, success, failure }

class MyTicketsState extends Equatable {
  const MyTicketsState({
    this.status = MyTicketsStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  final MyTicketsStatus status;
  final List<BusBooking> bookings;
  final String? errorMessage;

  MyTicketsState copyWith({
    MyTicketsStatus? status,
    List<BusBooking>? bookings,
    String? errorMessage,
  }) {
    return MyTicketsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}
