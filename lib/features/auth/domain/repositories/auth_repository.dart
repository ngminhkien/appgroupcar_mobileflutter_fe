import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> login(String email, String password);
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? avatarPath,
  });
  Future<AuthTokens?> getSavedTokens();
  Future<AuthTokens?> refreshTokens();
  Future<void> logout();
  Future<void> clearTokens();
}
