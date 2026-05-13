import 'package:equatable/equatable.dart';

import '../entities/driver_profile.dart';
import '../repositories/driver_repository.dart';

class UpdateDriverUseCase {
  UpdateDriverUseCase(this._repository);

  final DriverRepository _repository;

  Future<DriverProfile> call(UpdateDriverParams params) {
    return _repository.updateDriver(
      name: params.name,
      identityNumber: params.identityNumber,
      licenseNumber: params.licenseNumber,
      licenseClass: params.licenseClass,
      verificationStatus: params.verificationStatus,
      licenseDocumentImgPath: params.licenseDocumentImgPath,
    );
  }
}

class UpdateDriverParams extends Equatable {
  const UpdateDriverParams({
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

  @override
  List<Object?> get props => [
    name,
    identityNumber,
    licenseNumber,
    licenseClass,
    verificationStatus,
    licenseDocumentImgPath,
  ];
}
