import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/entities/auth_tokens.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final AuthTokenStorage _storage;

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      role: tokens.role,
    );
  }

  Future<AuthTokens?> getTokens() async {
    final accessToken = _storage.getAccessToken();
    final refreshToken = _storage.getRefreshToken();
    if (accessToken == null || refreshToken == null) {
      return null;
    }
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: _storage.getRole(),
    );
  }

  Future<void> clearTokens() async {
    await _storage.clear();
  }
}
