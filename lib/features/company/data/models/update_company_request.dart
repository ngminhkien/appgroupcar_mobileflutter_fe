class UpdateCompanyRequest {
  const UpdateCompanyRequest({
    this.companyName,
    this.logoPath,
    this.phone,
    this.address,
    this.provinceCode,
    this.districtCode,
    this.businessLicenseNo,
  });

  final String? companyName;
  final String? logoPath;
  final String? phone;
  final String? address;
  final String? provinceCode;
  final String? districtCode;
  final String? businessLicenseNo;
}
