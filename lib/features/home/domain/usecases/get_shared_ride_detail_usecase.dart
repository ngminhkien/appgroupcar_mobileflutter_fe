import '../entities/shared_ride_detail.dart';
import '../repositories/shared_ride_repository.dart';

class GetSharedRideDetailUseCase {
  GetSharedRideDetailUseCase(this._repository);

  final SharedRideRepository _repository;

  Future<SharedRideDetail> call({required String detailApi}) {
    return _repository.getSharedRideDetail(detailApi: detailApi);
  }
}
