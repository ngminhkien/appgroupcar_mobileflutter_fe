import 'package:equatable/equatable.dart';

import '../entities/company_profile.dart';
import '../repositories/company_repository.dart';

class UpdateCompanyUseCase {
  const UpdateCompanyUseCase(this._repository);

  final CompanyRepository _repository;

  Future<CompanyProfile> call(UpdateCompanyParams params) {
    return _repository.updateCompany(
      id: params.id,
      companyName: params.companyName,
      logoPath: params.logoPath,
      phone: params.phone,
      address: params.address,
      provinceCode: params.provinceCode,
      districtCode: params.districtCode,
      businessLicenseNo: params.businessLicenseNo,
    );
  }
}

class UpdateCompanyParams extends Equatable {
  const UpdateCompanyParams({
    required this.id,
    this.companyName,
    this.logoPath,
    this.phone,
    this.address,
    this.provinceCode,
    this.districtCode,
    this.businessLicenseNo,
  });

  final String id;
  final String? companyName;
  final String? logoPath;
  final String? phone;
  final String? address;
  final String? provinceCode;
  final String? districtCode;
  final String? businessLicenseNo;

  @override
  List<Object?> get props => [
    id,
    companyName,
    logoPath,
    phone,
    address,
    provinceCode,
    districtCode,
    businessLicenseNo,
  ];
}
