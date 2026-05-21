import '../entities/company_login_result.dart';
import '../entities/company_profile.dart';
import '../entities/company_type.dart';

abstract class CompanyRepository {
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
  });

  Future<CompanyProfile> updateCompany({
    required String id,
    String? companyName,
    String? logoPath,
    String? phone,
    String? address,
    String? provinceCode,
    String? districtCode,
    String? businessLicenseNo,
  });

  Future<CompanyLoginResult> checkCompanyStatus({
    required String email,
    required String businessLicenseNo,
  });
}
