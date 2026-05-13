import 'package:equatable/equatable.dart';

import '../entities/driver_profile.dart';
import '../repositories/driver_repository.dart';

class CreateDriverUseCase {
  CreateDriverUseCase(this._repository);

  final DriverRepository _repository;

  Future<DriverProfile> call(CreateDriverParams params) {
    return _repository.createDriver(
      name: params.name,
      identityNumber: params.identityNumber,
      licenseNumber: params.licenseNumber,
      licenseClass: params.licenseClass,
      licenseDocumentImgPath: params.licenseDocumentImgPath,
    );
  }
}

class CreateDriverParams extends Equatable {
  const CreateDriverParams({
    required this.name,
    required this.identityNumber,
    required this.licenseNumber,
    required this.licenseClass,
    this.licenseDocumentImgPath,
  });

  final String name;
  final String identityNumber;
  final String licenseNumber;
  final String licenseClass;
  final String? licenseDocumentImgPath;

  @override
  List<Object?> get props => [
    name,
    identityNumber,
    licenseNumber,
    licenseClass,
    licenseDocumentImgPath,
  ];
}
