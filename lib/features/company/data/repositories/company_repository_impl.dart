import '../../domain/entities/company_login_result.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/company_status.dart';
import '../../domain/entities/company_type.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_data_source.dart';
import '../models/company_login_request.dart';
import '../models/company_login_result_model.dart';
import '../models/company_model.dart';
import '../models/create_company_request.dart';
import '../models/update_company_request.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl({required this.remoteDataSource});

  final CompanyRemoteDataSource remoteDataSource;

  @override
  Future<CompanyProfile> createCompany({
    required String companyName,
    required String companyCode,
    String? logoPath,
    required String phone,
    String? email,
    required String address,
    required String provinceCode,
    String? districtCode,
    required String businessLicenseNo,
    String? taxCode,
    DateTime? licenseIssuedDate,
    String? licenseIssuedBy,
    required CompanyType companyType,
  }) async {
    final response = await remoteDataSource.createCompany(
      CreateCompanyRequest(
        companyName: companyName,
        companyCode: companyCode,
        logoPath: logoPath,
        phone: phone,
        email: email,
        address: address,
        provinceCode: provinceCode,
        districtCode: districtCode,
        businessLicenseNo: businessLicenseNo,
        taxCode: taxCode,
        licenseIssuedDate: licenseIssuedDate,
        licenseIssuedBy: licenseIssuedBy,
        companyType: companyType,
      ),
    );

    if (response.code != 201 && response.code != 200) {
      throw Exception(_extractErrorMessage(response.message, response.errors));
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Khong co du lieu cong ty tra ve');
    }

    final model = CompanyModel.fromJson(data);
    return model.toEntity();
  }

  @override
  Future<CompanyProfile> updateCompany({
    required String id,
    String? companyName,
    String? logoPath,
    String? phone,
    String? address,
    String? provinceCode,
    String? districtCode,
    String? businessLicenseNo,
  }) async {
    final response = await remoteDataSource.updateCompany(
      id: id,
      request: UpdateCompanyRequest(
        companyName: companyName,
        logoPath: logoPath,
        phone: phone,
        address: address,
        provinceCode: provinceCode,
        districtCode: districtCode,
        businessLicenseNo: businessLicenseNo,
      ),
    );

    if (response.code != 200) {
      throw Exception(_extractErrorMessage(response.message, response.errors));
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Khong co du lieu cong ty tra ve');
    }

    final model = CompanyModel.fromJson(data);
    return model.toEntity();
  }

  @override
  Future<CompanyLoginResult> checkCompanyStatus({
    required String email,
    required String businessLicenseNo,
  }) async {
    final response = await remoteDataSource.loginCompany(
      CompanyLoginRequest(email: email, businessLicenseNo: businessLicenseNo),
    );

    if (response.code != 200) {
      throw Exception(_extractErrorMessage(response.message, response.errors));
    }

    final apiMessage = _normalizeMessage(response.message);
    final data = response.data;
    if (data == null) {
      return CompanyLoginResult(
        companyId: '',
        status: _statusFromLoginMessage(apiMessage),
        message: apiMessage,
        description: null,
        pendingUpdateData: null,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Khong tim thay thong tin ho so cong ty');
    }

    final model = CompanyLoginResultModel.fromJson(data, message: apiMessage);
    if (model.companyId.trim().isEmpty) {
      throw Exception('Khong tim thay thong tin ho so cong ty');
    }
    return model.toEntity();
  }

  String _normalizeMessage(String message) {
    final text = message.trim();
    if (text.isNotEmpty) {
      return text;
    }
    return 'Da nhan duoc trang thai ho so cong ty';
  }

  CompanyStatus _statusFromLoginMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('tu choi') || lower.contains('tuchoi')) {
      return CompanyStatus.rejected;
    }
    if (lower.contains('cho duyet') || lower.contains('choduyet')) {
      return CompanyStatus.pending;
    }
    if (lower.contains('duyet')) {
      return CompanyStatus.approved;
    }
    return CompanyStatus.unknown;
  }

  String _extractErrorMessage(
    String message,
    Map<String, dynamic>? errors,
  ) {
    if (errors == null || errors.isEmpty) {
      return message.isNotEmpty ? message : 'Yeu cau that bai';
    }
    final firstEntry = errors.entries.first;
    final value = firstEntry.value;
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return message.isNotEmpty ? message : 'Yeu cau that bai';
  }
}
