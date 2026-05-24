import '../entities/staff_seat_map.dart';
import '../entities/staff_manual_checkin_info.dart';
import '../entities/staff_seat_status_history.dart';
import '../entities/staff_upcoming_showtime.dart';

abstract class StaffSeatCheckinRepository {
  Future<StaffUpcomingShowtimeResult> getUpcomingShowtimes({
    DateTime? fromDate,
  });

  Future<StaffSeatMap> getSeatMap({required String showtimeId});

  Future<List<StaffSeatStatusHistory>> updateSeatStatus({
    required String showtimeId,
    required List<String> seatNumbers,
    int newStatus = 1,
    String reason = 'Khach mua truc tiep',
  });

  Future<StaffManualCheckinInfo> getManualCheckinInfo({
    required String showtimeId,
    required String seatNumber,
  });
}
