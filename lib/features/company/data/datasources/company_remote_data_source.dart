import 'package:dio/dio.dart';

import '../models/company_api_response.dart';
import '../models/company_login_request.dart';
import '../models/create_company_request.dart';
import '../models/update_company_request.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CompanyApiResponse> createCompany(CreateCompanyRequest request) async {
    final response = await _dio.post(
      '/companies',
      data: await _createCompanyFormData(request),
      options: Options(validateStatus: (status) => status != null && status < 500),
    );
    return _parseApiResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<CompanyApiResponse> updateCompany({
    required String id,
    required UpdateCompanyRequest request,
  }) async {
    final response = await _dio.put(
      '/companies/$id',
      data: await _updateCompanyFormData(request),
      options: Options(validateStatus: (status) => status != null && status < 500),
    );
    return _parseApiResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<CompanyApiResponse> loginCompany(CompanyLoginRequest request) async {
    final response = await _dio.post(
      '/companies/login',
      data: request.toJson(),
      options: Options(validateStatus: (status) => status != null && status < 500),
    );
    return _parseApiResponse(
      response.data,
      fallbackCode: response.statusCode ?? 0,
    );
  }

  Future<FormData> _createCompanyFormData(CreateCompanyRequest request) async {
    final formMap = <String, dynamic>{
      'CompanyName': request.companyName,
      'CompanyCode': request.companyCode,
      'Phone': request.phone,
      'Address': request.address,
      'ProvinceCode': request.provinceCode,
      'BusinessLicenseNo': request.businessLicenseNo,
      'CompanyType': request.companyType.apiValue,
    };

    _putIfNotBlank(formMap, 'Email', request.email);
    _putIfNotBlank(formMap, 'DistrictCode', request.districtCode);
    _putIfNotBlank(formMap, 'TaxCode', request.taxCode);
    _putIfNotBlank(formMap, 'LicenseIssuedBy', request.licenseIssuedBy);

    final date = request.licenseIssuedDate;
    if (date != null) {
      formMap['LicenseIssuedDate'] = _formatDate(date);
    }

    final logoPath = request.logoPath;
    if (_hasText(logoPath)) {
      formMap['Logo'] = await MultipartFile.fromFile(logoPath!.trim());
    }

    return FormData.fromMap(formMap);
  }

  Future<FormData> _updateCompanyFormData(UpdateCompanyRequest request) async {
    final formMap = <String, dynamic>{};

    _putIfNotBlank(formMap, 'CompanyName', request.companyName);
    _putIfNotBlank(formMap, 'Phone', request.phone);
    _putIfNotBlank(formMap, 'Address', request.address);
    _putIfNotBlank(formMap, 'ProvinceCode', request.provinceCode);
    _putIfNotBlank(formMap, 'DistrictCode', request.districtCode);
    _putIfNotBlank(formMap, 'BusinessLicenseNo', request.businessLicenseNo);

    final logoPath = request.logoPath;
    if (_hasText(logoPath)) {
      formMap['Logo'] = await MultipartFile.fromFile(logoPath!.trim());
    }

    return FormData.fromMap(formMap);
  }

  CompanyApiResponse _parseApiResponse(
    dynamic data, {
    required int fallbackCode,
  }) {
    if (data is Map<String, dynamic>) {
      return CompanyApiResponse.fromJson(data, fallbackCode: fallbackCode);
    }
    return CompanyApiResponse(
      code: fallbackCode,
      message: '',
      data: null,
      errors: null,
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _putIfNotBlank(Map<String, dynamic> map, String key, String? value) {
    if (_hasText(value)) {
      map[key] = value!.trim();
    }
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
