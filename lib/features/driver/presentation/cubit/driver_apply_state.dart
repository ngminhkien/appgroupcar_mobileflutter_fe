import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_profile.dart';

enum DriverApplyStatus {
  initial,
  checking,
  ready,
  submitting,
  success,
  failure,
}

const Object _unset = Object();

class DriverApplyState extends Equatable {
  const DriverApplyState({
    this.status = DriverApplyStatus.initial,
    this.existingDriver,
    this.licenseDocumentImgPath,
    this.hasCheckedExistingDriver = false,
    this.errorMessage,
    this.successMessage,
  });

  final DriverApplyStatus status;
  final DriverProfile? existingDriver;
  final String? licenseDocumentImgPath;
  final bool hasCheckedExistingDriver;
  final String? errorMessage;
  final String? successMessage;

  bool get isBusy =>
      status == DriverApplyStatus.checking ||
      status == DriverApplyStatus.submitting;

  DriverApplyState copyWith({
    DriverApplyStatus? status,
    Object? existingDriver = _unset,
    Object? licenseDocumentImgPath = _unset,
    bool? hasCheckedExistingDriver,
    String? errorMessage,
    String? successMessage,
  }) {
    return DriverApplyState(
      status: status ?? this.status,
      existingDriver: existingDriver == _unset
          ? this.existingDriver
          : existingDriver as DriverProfile?,
      licenseDocumentImgPath: licenseDocumentImgPath == _unset
          ? this.licenseDocumentImgPath
          : licenseDocumentImgPath as String?,
      hasCheckedExistingDriver:
          hasCheckedExistingDriver ?? this.hasCheckedExistingDriver,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    existingDriver,
    licenseDocumentImgPath,
    hasCheckedExistingDriver,
    errorMessage,
    successMessage,
  ];
}
