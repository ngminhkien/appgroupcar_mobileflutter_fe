import '../entities/bus_seat_map.dart';
import '../repositories/bus_trip_repository.dart';

class GetBusSeatMapUseCase {
  GetBusSeatMapUseCase(this._repository);

  final BusTripRepository _repository;

  Future<BusSeatMap> call({required String showtimeId}) {
    return _repository.getBusSeatMap(showtimeId: showtimeId);
  }
}
