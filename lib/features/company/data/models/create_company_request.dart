import '../../domain/entities/company_type.dart';

class CreateCompanyRequest {
  const CreateCompanyRequest({
    required this.companyName,
    required this.companyCode,
    this.logoPath,
    required this.phone,
    this.email,
    required this.address,
    required this.provinceCode,
    this.districtCode,
    required this.businessLicenseNo,
    this.taxCode,
    this.licenseIssuedDate,
    this.licenseIssuedBy,
    required this.companyType,
  });

  final String companyName;
  final String companyCode;
  final String? logoPath;
  final String phone;
  final String? email;
  final String address;
  final String provinceCode;
  final String? districtCode;
  final String businessLicenseNo;
  final String? taxCode;
  final DateTime? licenseIssuedDate;
  final String? licenseIssuedBy;
  final CompanyType companyType;
}
