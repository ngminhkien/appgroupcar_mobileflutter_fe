import '../entities/driver_profile.dart';

abstract class DriverRepository {
  Future<DriverProfile> createDriver({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    String? licenseDocumentImgPath,
  });

  Future<DriverProfile> updateDriver({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    required int verificationStatus,
    String? licenseDocumentImgPath,
  });

  Future<DriverProfile?> getCurrentDriverProfile();
}
