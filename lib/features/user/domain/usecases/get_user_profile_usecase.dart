import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  GetUserProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<UserProfile> call() => _repository.getProfile();
}
