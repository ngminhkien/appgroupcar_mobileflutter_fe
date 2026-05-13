import 'package:dio/dio.dart';

import '../models/user_profile_response.dart';

class UserRemoteDataSource {
  UserRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserProfileResponse> fetchProfile(String accessToken) async {
    final response = await _dio.get(
      '/User/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return UserProfileResponse.fromJson(data);
    }
    throw Exception('Dinh dang phan hoi khong hop le');
  }
}
