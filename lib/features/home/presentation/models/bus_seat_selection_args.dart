import '../../domain/entities/bus_showtime_detail.dart';

class BusSeatSelectionArgs {
  const BusSeatSelectionArgs({
    required this.detail,
    this.initialSelectedSeats = const [],
  });

  final BusShowtimeDetail detail;
  final List<String> initialSelectedSeats;
}
