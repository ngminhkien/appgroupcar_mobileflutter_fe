import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetMyVehiclesUseCase {
  const GetMyVehiclesUseCase(this._repository);

  final VehicleRepository _repository;

  Future<List<Vehicle>> call() {
    return _repository.getMyVehicles();
  }
}
