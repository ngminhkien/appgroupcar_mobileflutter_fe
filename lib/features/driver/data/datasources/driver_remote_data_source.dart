import 'package:dio/dio.dart';

import '../models/create_driver_request.dart';
import '../models/driver_response.dart';
import '../models/update_driver_request.dart';

class DriverRemoteDataSource {
  DriverRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DriverResponse> createDriver({
    required CreateDriverRequest request,
    required String accessToken,
  }) async {
    final response = await _dio.post(
      '/marketdriver',
      data: await _createDriverFormData(request),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseDriverResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<DriverResponse> updateDriver({
    required UpdateDriverRequest request,
    required String accessToken,
  }) async {
    final response = await _dio.patch(
      '/marketdriver/update',
      data: await _updateDriverFormData(request),
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseDriverResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<DriverResponse> getDriverByUserId({
    required String userId,
    required String accessToken,
  }) async {
    final response = await _dio.get(
      '/marketdriver/$userId',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return _parseDriverResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<FormData> _createDriverFormData(CreateDriverRequest request) async {
    final formMap = <String, dynamic>{
      'name': request.name,
      'identityNumber': request.identityNumber,
      'licenseNumber': request.licenseNumber,
      'licenseClass': request.licenseClass,
      'verificationStatus': request.verificationStatus,
    };
    final documentPath = request.licenseDocumentImgPath;
    if (documentPath != null && documentPath.trim().isNotEmpty) {
      formMap['licenseDocumentImg'] = await MultipartFile.fromFile(
        documentPath,
      );
    }
    return FormData.fromMap(formMap);
  }

  Future<FormData> _updateDriverFormData(UpdateDriverRequest request) async {
    final formMap = <String, dynamic>{
      'name': request.name,
      'identityNumber': request.identityNumber,
      'licenseNumber': request.licenseNumber,
      'licenseClass': request.licenseClass,
      'verificationStatus': request.verificationStatus,
    };
    final documentPath = request.licenseDocumentImgPath;
    if (documentPath != null && documentPath.trim().isNotEmpty) {
      // Backend expects licenseDocumenImg (without "t") for update.
      formMap['licenseDocumenImg'] = await MultipartFile.fromFile(
        documentPath,
      );
    }
    return FormData.fromMap(formMap);
  }

  DriverResponse _parseDriverResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return DriverResponse.fromJson(data);
    }
    return DriverResponse(code: fallbackCode, message: '');
  }
}
