import '../entities/bus_booking_detail.dart';
import '../repositories/bus_booking_repository.dart';

class GetBusBookingDetailUseCase {
  GetBusBookingDetailUseCase(this._repository);

  final BusBookingRepository _repository;

  Future<BusBookingDetail> call({required String bookingId}) {
    return _repository.getBusBookingDetail(bookingId: bookingId);
  }
}
