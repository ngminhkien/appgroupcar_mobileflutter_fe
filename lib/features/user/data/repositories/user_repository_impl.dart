import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final UserRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<UserProfile> getProfile() async {
    final tokens = await authRepository.getSavedTokens();
    final accessToken = tokens?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Chua dang nhap');
    }
    final response = await remoteDataSource.fetchProfile(accessToken);
    if (response.code != 200) {
      throw Exception(response.message);
    }
    return response.data;
  }
}
