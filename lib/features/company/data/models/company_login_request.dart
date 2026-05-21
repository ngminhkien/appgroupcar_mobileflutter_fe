class CompanyLoginRequest {
  const CompanyLoginRequest({
    required this.email,
    required this.businessLicenseNo,
  });

  final String email;
  final String businessLicenseNo;

  Map<String, dynamic> toJson() {
    return {
      'Email': email,
      'BusinessLicenseNo': businessLicenseNo,
    };
  }
}
