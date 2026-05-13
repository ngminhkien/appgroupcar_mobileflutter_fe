import 'package:dio/dio.dart';

import '../models/create_vehicle_request.dart';
import '../models/update_vehicle_request.dart';
import '../models/vehicle_response.dart';

class VehicleRemoteDataSource {
  VehicleRemoteDataSource(this._dio);

  final Dio _dio;

  Future<VehicleListResponse> getMyVehicles({
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/vehicle/my-vehicles',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseVehicleListResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<VehicleResponse> createVehicle({
    required CreateVehicleRequest request,
    required String accessToken,
  }) async {
    final response = await _dio.post(
      '/vehicle/create',
      data: await _createVehicleFormData(request),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseVehicleResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<VehicleResponse> updateVehicle({
    required String id,
    required UpdateVehicleRequest request,
    required String accessToken,
  }) async {
    final response = await _dio.put(
      '/vehicle/$id',
      data: await _updateVehicleFormData(request),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseVehicleResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<FormData> _createVehicleFormData(CreateVehicleRequest request) async {
    return FormData.fromMap({
      'plateNumber': request.plateNumber,
      'brand': request.brand,
      'seatCapacity': request.seatCapacity,
      'vehicleType': request.vehicleType,
      'urlImage': await MultipartFile.fromFile(request.urlImagePath),
      'registrationDocumentUrl': await MultipartFile.fromFile(
        request.registrationDocumentUrlPath,
      ),
    });
  }

  Future<FormData> _updateVehicleFormData(UpdateVehicleRequest request) async {
    final formMap = <String, dynamic>{};
    if (request.plateNumber?.trim().isNotEmpty == true) {
      formMap['plateNumber'] = request.plateNumber!.trim();
    }
    if (request.brand?.trim().isNotEmpty == true) {
      formMap['brand'] = request.brand!.trim();
    }
    if (request.seatCapacity != null) {
      formMap['seatCapacity'] = request.seatCapacity;
    }
    if (request.vehicleType != null) {
      formMap['vehicleType'] = request.vehicleType;
    }
    final imagePath = request.urlImagePath;
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      formMap['urlImage'] = await MultipartFile.fromFile(imagePath);
    }
    final documentPath = request.registrationDocumentUrlPath;
    if (documentPath != null && documentPath.trim().isNotEmpty) {
      formMap['registrationDocumentUrl'] = await MultipartFile.fromFile(
        documentPath,
      );
    }
    return FormData.fromMap(formMap);
  }

  VehicleResponse _parseVehicleResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return VehicleResponse.fromJson(data);
    }
    return VehicleResponse(code: fallbackCode, message: '');
  }

  VehicleListResponse _parseVehicleListResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return VehicleListResponse.fromJson(data);
    }
    return VehicleListResponse(code: fallbackCode, message: '');
  }
}
