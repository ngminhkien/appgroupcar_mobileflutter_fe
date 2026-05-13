import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<AuthTokens> login(String email, String password) async {
    final response = await remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    if (response.code != 200) {
      throw Exception(response.message);
    }
    final role = JwtDecoder.extractRole(response.data.accessToken);
    final normalizedRole = role?.toUpperCase();
    if (!_isAllowedRole(normalizedRole)) {
      throw Exception('Vai tro khong duoc ho tro');
    }
    final tokens = AuthTokens(
      accessToken: response.data.accessToken,
      refreshToken: response.data.refreshToken,
      role: normalizedRole,
    );
    await localDataSource.saveTokens(tokens);
    return tokens;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String? avatarPath,
  }) async {
    final response = await remoteDataSource.register(
      RegisterRequest(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        avatarPath: avatarPath,
      ),
    );
    if (response.code != 200) {
      final message = response.message.isNotEmpty
          ? response.message
          : 'Dang ky that bai';
      throw Exception(message);
    }
  }

  @override
  Future<AuthTokens?> getSavedTokens() => localDataSource.getTokens();

  @override
  Future<AuthTokens?> refreshTokens() async {
    final savedTokens = await localDataSource.getTokens();
    if (savedTokens == null) {
      return null;
    }
    final response = await remoteDataSource.refreshToken(
      RefreshTokenRequest(
        accessToken: savedTokens.accessToken,
        refreshToken: savedTokens.refreshToken,
      ),
    );
    if (response.code != 200 || response.data == null) {
      throw Exception(response.message);
    }
    final role = JwtDecoder.extractRole(response.data!.accessToken);
    final normalizedRole = role?.toUpperCase();
    if (!_isAllowedRole(normalizedRole)) {
      throw Exception('Vai tro khong duoc ho tro');
    }
    final tokens = AuthTokens(
      accessToken: response.data!.accessToken,
      refreshToken: response.data!.refreshToken,
      role: normalizedRole,
    );
    await localDataSource.saveTokens(tokens);
    return tokens;
  }

  @override
  Future<void> logout() async {
    final tokens = await localDataSource.getTokens();
    try {
      final accessToken = tokens?.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        await remoteDataSource.logout(accessToken);
      }
    } catch (_) {
      // Ignore remote logout errors so local sign-out always succeeds.
    } finally {
      await localDataSource.clearTokens();
    }
  }

  @override
  Future<void> clearTokens() => localDataSource.clearTokens();

  bool _isAllowedRole(String? role) {
    return role == 'USER' || role == 'DRIVER' || role == 'COMPANY';
  }
}
