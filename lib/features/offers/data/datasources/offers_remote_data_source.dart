import 'package:dio/dio.dart';

import '../models/shared_ride_offer_model.dart';
import '../models/shipment_offer_model.dart';

class OffersRemoteDataSource {
  OffersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SharedRideOfferModel>> getSharedRides({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (pickupLocationId != null && pickupLocationId.isNotEmpty) {
      queryParams['PickupLocationId'] = pickupLocationId;
    }
    if (dropoffLocationId != null && dropoffLocationId.isNotEmpty) {
      queryParams['DropoffLocationId'] = dropoffLocationId;
    }
    if (startTime != null && startTime.isNotEmpty) {
      queryParams['startTime'] = startTime;
    }
    if (endTime != null && endTime.isNotEmpty) {
      queryParams['endTime'] = endTime;
    }
    if (startPrice != null) {
      queryParams['startPrice'] = startPrice;
    }
    if (endPrice != null) {
      queryParams['endPrice'] = endPrice;
    }

    final response = await _dio.get(
      '/Offer/shared-ride',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _parseList(response.data, SharedRideOfferModel.fromJson);
  }

  Future<List<ShipmentOfferModel>> getShipments({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'PageNumber': pageNumber,
      'PageSize': pageSize,
    };
    if (pickupLocationId != null && pickupLocationId.isNotEmpty) {
      queryParams['PickupLocationId'] = pickupLocationId;
    }
    if (dropoffLocationId != null && dropoffLocationId.isNotEmpty) {
      queryParams['DropoffLocationId'] = dropoffLocationId;
    }
    if (startTime != null && startTime.isNotEmpty) {
      queryParams['startTime'] = startTime;
    }
    if (endTime != null && endTime.isNotEmpty) {
      queryParams['endTime'] = endTime;
    }
    if (startPrice != null) {
      queryParams['startPrice'] = startPrice;
    }
    if (endPrice != null) {
      queryParams['endPrice'] = endPrice;
    }

    final response = await _dio.get(
      '/Offer/shipment',
      queryParameters: queryParams,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    return _parseList(response.data, ShipmentOfferModel.fromJson);
  }

  Future<dynamic> createSharedRide({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required String accessToken,
  }) async {
    final response = await _dio.post(
      '/Offer/shared-ride',
      data: {
        'vehicleId': vehicleId,
        'departureTime': departureTime,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'basePrice': basePrice,
        'offerRoutePoints': offerRoutePoints,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return response.data;
  }

  Future<dynamic> createShipment({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required Map<String, dynamic> cargo,
    required String accessToken,
  }) async {
    final response = await _dio.post(
      '/Offer/shipment',
      data: {
        'vehicleId': vehicleId,
        'departureTime': departureTime,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'basePrice': basePrice,
        'offerRoutePoints': offerRoutePoints,
        'cargo': cargo,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return response.data;
  }

  List<T> _parseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    if (json == null) return [];

    if (json is Map<String, dynamic>) {
      final dataValue = json['data'];
      if (dataValue != null) {
        return _parseList(dataValue, itemParser);
      }

      final itemsValue = json['items'];
      if (itemsValue is List) {
        return itemsValue
            .whereType<Map<String, dynamic>>()
            .map(itemParser)
            .toList();
      }
    }

    if (json is List) {
      return json.whereType<Map<String, dynamic>>().map(itemParser).toList();
    }

    return [];
  }
}
