import 'package:dio/dio.dart';

import '../models/staff_manual_checkin_info_response.dart';
import '../models/staff_seat_map_response.dart';
import '../models/staff_upcoming_showtimes_response.dart';
import '../models/staff_update_seat_status_response.dart';

class StaffSeatCheckinRemoteDataSource {
  StaffSeatCheckinRemoteDataSource(this._dio);

  final Dio _dio;

  Future<StaffUpcomingShowtimesResponse> getUpcomingShowtimes({
    required String accessToken,
    String? fromDate,
  }) async {
    final normalizedDate = fromDate?.trim();
    final response = await _dio.get(
      '/seat-status-histories/showtimes/upcoming',
      queryParameters: normalizedDate == null || normalizedDate.isEmpty
          ? null
          : {'fromDate': normalizedDate},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseUpcomingResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<StaffSeatMapResponse> getSeatMap({
    required String accessToken,
    required String showtimeId,
  }) async {
    final response = await _dio.get(
      '/showtimes/$showtimeId/seat-map',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseSeatMapResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<StaffUpdateSeatStatusResponse> updateSeatStatus({
    required String accessToken,
    required String showtimeId,
    required List<String> seatNumbers,
    required int newStatus,
    required String reason,
  }) async {
    final response = await _dio.patch(
      '/seat-status-histories/status',
      data: {
        'showtimeId': showtimeId,
        'seatNumbers': seatNumbers,
        'newStatus': newStatus,
        'reason': reason,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseUpdateStatusResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<StaffManualCheckinInfoResponse> getManualCheckinInfo({
    required String accessToken,
    required String showtimeId,
    required String seatNumber,
  }) async {
    final response = await _dio.get(
      '/seat-status-histories/check-in-info',
      queryParameters: {'showtimeId': showtimeId, 'seatNumber': seatNumber},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseManualCheckinResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  StaffUpcomingShowtimesResponse _parseUpcomingResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return StaffUpcomingShowtimesResponse.fromJson(data);
    }
    return StaffUpcomingShowtimesResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }

  StaffSeatMapResponse _parseSeatMapResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return StaffSeatMapResponse.fromJson(data);
    }
    return StaffSeatMapResponse(code: fallbackCode, message: '', data: null);
  }

  StaffUpdateSeatStatusResponse _parseUpdateStatusResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return StaffUpdateSeatStatusResponse.fromJson(data);
    }
    return StaffUpdateSeatStatusResponse(
      code: fallbackCode,
      message: '',
      data: const [],
    );
  }

  StaffManualCheckinInfoResponse _parseManualCheckinResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return StaffManualCheckinInfoResponse.fromJson(data);
    }
    return StaffManualCheckinInfoResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }
}
