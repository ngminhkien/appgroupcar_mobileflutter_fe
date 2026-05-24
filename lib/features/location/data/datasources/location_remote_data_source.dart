import 'package:dio/dio.dart';

import '../models/location_search_request.dart';
import '../models/location_search_response.dart';

class LocationRemoteDataSource {
  LocationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LocationSearchResponse> searchLocations({
    required LocationSearchRequest request,
  }) async {
    final endpoint = request.availableForRoute
        ? '/locations/available-for-route'
        : '/locations';
    final response = await _dio.get(
      endpoint,
      queryParameters: request.toQueryParameters(),
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LocationSearchResponse.fromJson(data);
    }
    return LocationSearchResponse(
      code: response.statusCode ?? 0,
      message: '',
      data: null,
    );
  }
}
