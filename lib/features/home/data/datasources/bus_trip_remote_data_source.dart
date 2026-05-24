import 'package:dio/dio.dart';

import '../models/bus_seat_map_response.dart';
import '../models/bus_showtime_detail_response.dart';

class BusTripRemoteDataSource {
  BusTripRemoteDataSource(this._dio);

  final Dio _dio;

  Future<BusShowtimeDetailResponse> getBusShowtimeDetail({
    required String detailApi,
  }) async {
    final response = await _dio.get(
      _normalizePath(detailApi),
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseBusShowtimeDetailResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<BusSeatMapResponse> getSeatMap({required String showtimeId}) async {
    final response = await _dio.get(
      '/showtimes/$showtimeId/seat-map',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseBusSeatMapResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<BusSeatLayoutResponse> getSeatLayout({
    required String showtimeId,
  }) async {
    final response = await _dio.get(
      '/showtimes/$showtimeId/seat-layout',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseBusSeatLayoutResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<BusSeatStatusesResponse> getSeatStatuses({
    required String showtimeId,
  }) async {
    final response = await _dio.get(
      '/showtimes/$showtimeId/seats',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseBusSeatStatusesResponse(
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

  BusShowtimeDetailResponse _parseBusShowtimeDetailResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return BusShowtimeDetailResponse.fromJson(data);
    }
    return BusShowtimeDetailResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }

  BusSeatMapResponse _parseBusSeatMapResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return BusSeatMapResponse.fromJson(data);
    }
    return BusSeatMapResponse(code: fallbackCode, message: '', data: null);
  }

  BusSeatLayoutResponse _parseBusSeatLayoutResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return BusSeatLayoutResponse.fromJson(data);
    }
    return BusSeatLayoutResponse(code: fallbackCode, message: '', data: null);
  }

  BusSeatStatusesResponse _parseBusSeatStatusesResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return BusSeatStatusesResponse.fromJson(data);
    }
    return BusSeatStatusesResponse(
      code: fallbackCode,
      message: '',
      data: const [],
    );
  }
}
