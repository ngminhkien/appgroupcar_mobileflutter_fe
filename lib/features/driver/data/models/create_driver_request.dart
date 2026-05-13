class CreateDriverRequest {
  const CreateDriverRequest({
    required this.name,
    required this.identityNumber,
    required this.licenseNumber,
    required this.licenseClass,
    this.verificationStatus = 1,
    this.licenseDocumentImgPath,
  });

  final String name;
  final String identityNumber;
  final String licenseNumber;
  final String licenseClass;
  final int verificationStatus;
  final String? licenseDocumentImgPath;
}
