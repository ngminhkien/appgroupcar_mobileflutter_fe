import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_driver_usecase.dart';
import '../../domain/usecases/get_current_driver_profile_usecase.dart';
import '../../domain/usecases/update_driver_usecase.dart';
import 'driver_apply_state.dart';

class DriverApplyCubit extends Cubit<DriverApplyState> {
  DriverApplyCubit(
    this._createDriverUseCase,
    this._getCurrentDriverProfileUseCase,
    this._updateDriverUseCase,
  ) : super(const DriverApplyState());

  final CreateDriverUseCase _createDriverUseCase;
  final GetCurrentDriverProfileUseCase _getCurrentDriverProfileUseCase;
  final UpdateDriverUseCase _updateDriverUseCase;

  Future<void> checkExistingDriver() async {
    emit(
      state.copyWith(
        status: DriverApplyStatus.checking,
        hasCheckedExistingDriver: false,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final driver = await _getCurrentDriverProfileUseCase();
      emit(
        state.copyWith(
          status: DriverApplyStatus.ready,
          existingDriver: driver,
          hasCheckedExistingDriver: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DriverApplyStatus.failure,
          hasCheckedExistingDriver: false,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  void changeLicenseDocument(String? path) {
    emit(
      state.copyWith(
        licenseDocumentImgPath: path,
        status: state.status == DriverApplyStatus.failure
            ? DriverApplyStatus.ready
            : state.status,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> submit({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    String? licenseDocumentImgPath,
  }) async {
    emit(
      state.copyWith(
        status: DriverApplyStatus.submitting,
        licenseDocumentImgPath: licenseDocumentImgPath,
        hasCheckedExistingDriver: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final driver = await _createDriverUseCase(
        CreateDriverParams(
          name: name,
          identityNumber: identityNumber,
          licenseNumber: licenseNumber,
          licenseClass: licenseClass,
          licenseDocumentImgPath: licenseDocumentImgPath,
        ),
      );
      emit(
        state.copyWith(
          status: DriverApplyStatus.success,
          existingDriver: driver,
          hasCheckedExistingDriver: true,
          successMessage: 'Đã gửi hồ sơ tài xế, vui lòng chờ duyệt',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DriverApplyStatus.failure,
          hasCheckedExistingDriver: true,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> updateDriver({
    required String name,
    required String identityNumber,
    required String licenseNumber,
    required String licenseClass,
    required int verificationStatus,
    String? licenseDocumentImgPath,
  }) async {
    emit(
      state.copyWith(
        status: DriverApplyStatus.submitting,
        licenseDocumentImgPath: licenseDocumentImgPath,
        hasCheckedExistingDriver: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final driver = await _updateDriverUseCase(
        UpdateDriverParams(
          name: name,
          identityNumber: identityNumber,
          licenseNumber: licenseNumber,
          licenseClass: licenseClass,
          verificationStatus: verificationStatus,
          licenseDocumentImgPath: licenseDocumentImgPath,
        ),
      );
      emit(
        state.copyWith(
          status: DriverApplyStatus.success,
          existingDriver: driver,
          hasCheckedExistingDriver: true,
          successMessage: 'Cập nhật thông tin tài xế thành công',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DriverApplyStatus.failure,
          hasCheckedExistingDriver: true,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }
}
