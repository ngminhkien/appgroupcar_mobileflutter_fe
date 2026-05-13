import 'package:dio/dio.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/Auth/login', data: request.toJson());
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LoginResponse.fromJson(data);
    }
    throw Exception('Dinh dang phan hoi khong hop le');
  }

  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await _dio.post(
      '/Auth/refresh-token',
      data: request.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return RefreshTokenResponse.fromJson(data);
    }
    throw Exception('Dinh dang phan hoi khong hop le');
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    final hasAvatar =
        request.avatarPath != null && request.avatarPath!.trim().isNotEmpty;
    final response = await _dio.post(
      '/auth/register',
      data: hasAvatar ? await _registerFormData(request) : request.toJson(),
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return RegisterResponse.fromJson(data);
    }
    throw Exception('Dinh dang phan hoi khong hop le');
  }

  Future<FormData> _registerFormData(RegisterRequest request) async {
    return FormData.fromMap({
      'fullName': request.fullName,
      'email': request.email,
      'phoneNumber': request.phoneNumber,
      'password': request.password,
      'avatar': await MultipartFile.fromFile(request.avatarPath!),
    });
  }

  Future<void> logout(String accessToken) async {
    await _dio.post(
      '/Auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
}
