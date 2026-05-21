import 'package:dio/dio.dart';

import '../../domain/entities/trip_search_request.dart';
import '../models/trip_search_response.dart';

class TripSearchRemoteDataSource {
  TripSearchRemoteDataSource(this._dio);

  final Dio _dio;

  Future<TripSearchResponse> searchTrips({
    required TripSearchRequest request,
  }) async {
    final response = await _dio.get(
      '/api/search/trips',
      queryParameters: request.toQueryParameters(),
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TripSearchResponse.fromJson(data);
    }
    return TripSearchResponse(
      code: response.statusCode ?? 0,
      message: '',
      data: null,
    );
  }
}
