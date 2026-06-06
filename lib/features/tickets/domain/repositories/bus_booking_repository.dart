import '../entities/bus_booking.dart';
import '../entities/bus_booking_detail.dart';

abstract class BusBookingRepository {
  Future<BusBooking> createBusBooking({
    required String showtimeId,
    required List<String> seatNumbers,
    required String pickupLocationId,
    required String dropoffLocationId,
    int status = 1,
  });

  Future<BusBooking> createOfferBooking({
    required String offerId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required double price,
  });

  Future<List<BusBooking>> getMyBusBookings();

  Future<BusBookingDetail> getBusBookingDetail({required String bookingId});
}
