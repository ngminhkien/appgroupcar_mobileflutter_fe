import 'package:equatable/equatable.dart';

import '../entities/company_profile.dart';
import '../entities/company_type.dart';
import '../repositories/company_repository.dart';

class CreateCompanyUseCase {
  const CreateCompanyUseCase(this._repository);

  final CompanyRepository _repository;

  Future<CompanyProfile> call(CreateCompanyParams params) {
    return _repository.createCompany(
      companyName: params.companyName,
      companyCode: params.companyCode,
      logoPath: params.logoPath,
      phone: params.phone,
      email: params.email,
      address: params.address,
      provinceCode: params.provinceCode,
      districtCode: params.districtCode,
      businessLicenseNo: params.businessLicenseNo,
      taxCode: params.taxCode,
      licenseIssuedDate: params.licenseIssuedDate,
      licenseIssuedBy: params.licenseIssuedBy,
      companyType: params.companyType,
    );
  }
}

class CreateCompanyParams extends Equatable {
  const CreateCompanyParams({
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

  @override
  List<Object?> get props => [
    companyName,
    companyCode,
    logoPath,
    phone,
    email,
    address,
    provinceCode,
    districtCode,
    businessLicenseNo,
    taxCode,
    licenseIssuedDate,
    licenseIssuedBy,
    companyType,
  ];
}
