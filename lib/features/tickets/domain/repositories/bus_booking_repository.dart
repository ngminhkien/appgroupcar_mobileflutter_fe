import '../entities/bus_booking.dart';
import '../entities/bus_booking_detail.dart';

abstract class BusBookingRepository {
  Future<BusBooking> createBusBooking({
    required String showtimeId,
    required List<String> seatNumbers,
    int status = 1,
  });

  Future<List<BusBooking>> getMyBusBookings();

  Future<BusBookingDetail> getBusBookingDetail({required String bookingId});
}
