import '../entities/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens?> call() => _repository.refreshTokens();
}
