import '../entities/driver_profile.dart';
import '../repositories/driver_repository.dart';

class GetCurrentDriverProfileUseCase {
  GetCurrentDriverProfileUseCase(this._repository);

  final DriverRepository _repository;

  Future<DriverProfile?> call() => _repository.getCurrentDriverProfile();
}
