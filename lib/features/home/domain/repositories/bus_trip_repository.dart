import '../entities/bus_seat_map.dart';
import '../entities/bus_showtime_detail.dart';

abstract class BusTripRepository {
  Future<BusShowtimeDetail> getBusShowtimeDetail({required String detailApi});

  Future<BusSeatMap> getBusSeatMap({required String showtimeId});
}
