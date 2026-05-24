import '../entities/bus_booking.dart';
import '../repositories/bus_booking_repository.dart';

class GetMyBusBookingsUseCase {
  GetMyBusBookingsUseCase(this._repository);

  final BusBookingRepository _repository;

  Future<List<BusBooking>> call() {
    return _repository.getMyBusBookings();
  }
}
