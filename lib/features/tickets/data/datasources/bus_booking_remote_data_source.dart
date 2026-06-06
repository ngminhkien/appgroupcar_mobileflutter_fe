import 'package:dio/dio.dart';

import '../models/bus_booking_detail_response.dart';
import '../models/create_bus_booking_response.dart';
import '../models/my_bus_bookings_response.dart';

class BusBookingRemoteDataSource {
  BusBookingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CreateBusBookingResponse> createBusBooking({
    required String accessToken,
    required String showtimeId,
    required List<String> seatNumbers,
    required String pickupLocationId,
    required String dropoffLocationId,
    required int status,
  }) async {
    final response = await _dio.post(
      '/bus-bookings',
      data: {
        'showtimeId': showtimeId,
        'status': status,
        'seatNumbers': seatNumbers,
        'pickupLocationId': pickupLocationId,
        'dropoffLocationId': dropoffLocationId,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseCreateResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<CreateBusBookingResponse> createOfferBooking({
    required String accessToken,
    required String offerId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required double price,
  }) async {
    final response = await _dio.post(
      '/Booking',
      data: {
        'offerId': offerId,
        'itemRequestDTOs': [
          {
            'pickupLocationId': pickupLocationId,
            'dropoffLocationId': dropoffLocationId,
            'price': price,
          },
        ],
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseCreateResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<MyBusBookingsResponse> getMyBookings({
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/bus-bookings/me',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseMyBookingsResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<BusBookingDetailResponse> getBookingDetail({
    required String accessToken,
    required String bookingId,
  }) async {
    final response = await _dio.get(
      '/bus-bookings/$bookingId/detail',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    return _parseBookingDetailResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  CreateBusBookingResponse _parseCreateResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return CreateBusBookingResponse.fromJson(data);
    }
    return CreateBusBookingResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }

  MyBusBookingsResponse _parseMyBookingsResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return MyBusBookingsResponse.fromJson(data);
    }
    return MyBusBookingsResponse(
      code: fallbackCode,
      message: '',
      data: const [],
    );
  }

  BusBookingDetailResponse _parseBookingDetailResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return BusBookingDetailResponse.fromJson(data);
    }
    return BusBookingDetailResponse(
      code: fallbackCode,
      message: '',
      data: null,
    );
  }
}
