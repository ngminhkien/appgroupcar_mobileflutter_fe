import 'package:equatable/equatable.dart';

class PendingCompanyUpdateData extends Equatable {
  const PendingCompanyUpdateData({
    required this.companyId,
    required this.companyName,
    this.logoUrl,
    required this.phone,
    required this.address,
    required this.provinceCode,
    this.districtCode,
    required this.businessLicenseNo,
  });

  final String companyId;
  final String companyName;
  final String? logoUrl;
  final String phone;
  final String address;
  final String provinceCode;
  final String? districtCode;
  final String businessLicenseNo;

  @override
  List<Object?> get props => [
    companyId,
    companyName,
    logoUrl,
    phone,
    address,
    provinceCode,
    districtCode,
    businessLicenseNo,
  ];
}
