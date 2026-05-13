class UpdateDriverRequest {
  const UpdateDriverRequest({
    required this.name,
    required this.identityNumber,
    required this.licenseNumber,
    required this.licenseClass,
    required this.verificationStatus,
    this.licenseDocumentImgPath,
  });

  final String name;
  final String identityNumber;
  final String licenseNumber;
  final String licenseClass;
  final int verificationStatus;
  final String? licenseDocumentImgPath;
}
