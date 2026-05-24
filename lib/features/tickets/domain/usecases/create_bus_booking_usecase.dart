import 'package:equatable/equatable.dart';

import '../entities/bus_booking.dart';
import '../repositories/bus_booking_repository.dart';

class CreateBusBookingParams extends Equatable {
  const CreateBusBookingParams({
    required this.showtimeId,
    required this.seatNumbers,
    this.status = 1,
  });

  final String showtimeId;
  final List<String> seatNumbers;
  final int status;

  @override
  List<Object?> get props => [showtimeId, seatNumbers, status];
}

class CreateBusBookingUseCase {
  CreateBusBookingUseCase(this._repository);

  final BusBookingRepository _repository;

  Future<BusBooking> call(CreateBusBookingParams params) {
    return _repository.createBusBooking(
      showtimeId: params.showtimeId,
      seatNumbers: params.seatNumbers,
      status: params.status,
    );
  }
}
