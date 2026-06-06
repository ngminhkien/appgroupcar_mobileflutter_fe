import 'package:dio/dio.dart';
import '../models/shared_ride_detail_response.dart';

class SharedRideRemoteDataSource {
  SharedRideRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SharedRideDetailResponse> getSharedRideDetail({
    required String detailApi,
  }) async {
    final response = await _dio.get(
      _normalizePath(detailApi),
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseSharedRideDetailResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return trimmed;
    }
    return '/$trimmed';
  }

  SharedRideDetailResponse _parseSharedRideDetailResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return SharedRideDetailResponse.fromJson(data);
    }
    return SharedRideDetailResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }
}
