import '../../domain/entities/pending_company_update_data.dart';

class PendingCompanyUpdateDataModel {
  const PendingCompanyUpdateDataModel({
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

  factory PendingCompanyUpdateDataModel.fromJson(Map<String, dynamic> json) {
    return PendingCompanyUpdateDataModel(
      companyId: (json['companyId'] ?? '').toString(),
      companyName: (json['companyName'] ?? '').toString(),
      logoUrl: _asNullableString(json['logoUrl']),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      provinceCode: (json['provinceCode'] ?? '').toString(),
      districtCode: _asNullableString(json['districtCode']),
      businessLicenseNo: (json['businessLicenseNo'] ?? '').toString(),
    );
  }

  PendingCompanyUpdateData toEntity() {
    return PendingCompanyUpdateData(
      companyId: companyId,
      companyName: companyName,
      logoUrl: logoUrl,
      phone: phone,
      address: address,
      provinceCode: provinceCode,
      districtCode: districtCode,
      businessLicenseNo: businessLicenseNo,
    );
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
