import '../entities/bus_showtime_detail.dart';
import '../repositories/bus_trip_repository.dart';

class GetBusShowtimeDetailUseCase {
  GetBusShowtimeDetailUseCase(this._repository);

  final BusTripRepository _repository;

  Future<BusShowtimeDetail> call({required String detailApi}) {
    return _repository.getBusShowtimeDetail(detailApi: detailApi);
  }
}
