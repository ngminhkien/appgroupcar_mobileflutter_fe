import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_type.dart';
import '../../domain/usecases/check_company_status_usecase.dart';
import '../../domain/usecases/create_company_usecase.dart';
import '../../domain/usecases/update_company_usecase.dart';
import 'company_apply_state.dart';

class CompanyApplyCubit extends Cubit<CompanyApplyState> {
  CompanyApplyCubit(
    this._createCompanyUseCase,
    this._updateCompanyUseCase,
    this._checkCompanyStatusUseCase,
  ) : super(const CompanyApplyState());

  final CreateCompanyUseCase _createCompanyUseCase;
  final UpdateCompanyUseCase _updateCompanyUseCase;
  final CheckCompanyStatusUseCase _checkCompanyStatusUseCase;

  void changeLogo(String? logoPath) {
    emit(
      state.copyWith(
        logoPath: logoPath,
        status: state.status == CompanyApplyStatus.failure
            ? CompanyApplyStatus.initial
            : state.status,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> checkStatus({
    required String email,
    required String businessLicenseNo,
  }) async {
    emit(
      state.copyWith(
        status: CompanyApplyStatus.loading,
        action: CompanyApplyAction.checkStatus,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final result = await _checkCompanyStatusUseCase(
        CheckCompanyStatusParams(
          email: email,
          businessLicenseNo: businessLicenseNo,
        ),
      );
      emit(
        state.copyWith(
          status: CompanyApplyStatus.success,
          action: CompanyApplyAction.checkStatus,
          checkResult: result,
          errorMessage: null,
          successMessage: result.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CompanyApplyStatus.failure,
          action: CompanyApplyAction.checkStatus,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> createCompany({
    required String companyName,
    required String companyCode,
    String? logoPath,
    required String phone,
    String? email,
    required String address,
    required String provinceCode,
    String? districtCode,
    required String businessLicenseNo,
    String? taxCode,
    DateTime? licenseIssuedDate,
    String? licenseIssuedBy,
    required CompanyType companyType,
  }) async {
    emit(
      state.copyWith(
        status: CompanyApplyStatus.loading,
        action: CompanyApplyAction.create,
        logoPath: logoPath,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final company = await _createCompanyUseCase(
        CreateCompanyParams(
          companyName: companyName,
          companyCode: companyCode,
          logoPath: logoPath,
          phone: phone,
          email: email,
          address: address,
          provinceCode: provinceCode,
          districtCode: districtCode,
          businessLicenseNo: businessLicenseNo,
          taxCode: taxCode,
          licenseIssuedDate: licenseIssuedDate,
          licenseIssuedBy: licenseIssuedBy,
          companyType: companyType,
        ),
      );
      emit(
        state.copyWith(
          status: CompanyApplyStatus.success,
          action: CompanyApplyAction.create,
          latestCompany: company,
          errorMessage: null,
          successMessage: 'Gui don dang ky cong ty thanh cong',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CompanyApplyStatus.failure,
          action: CompanyApplyAction.create,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> updateCompany({
    required String id,
    String? companyName,
    String? logoPath,
    String? phone,
    String? address,
    String? provinceCode,
    String? districtCode,
    String? businessLicenseNo,
  }) async {
    emit(
      state.copyWith(
        status: CompanyApplyStatus.loading,
        action: CompanyApplyAction.update,
        logoPath: logoPath,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final company = await _updateCompanyUseCase(
        UpdateCompanyParams(
          id: id,
          companyName: companyName,
          logoPath: logoPath,
          phone: phone,
          address: address,
          provinceCode: provinceCode,
          districtCode: districtCode,
          businessLicenseNo: businessLicenseNo,
        ),
      );
      emit(
        state.copyWith(
          status: CompanyApplyStatus.success,
          action: CompanyApplyAction.update,
          latestCompany: company,
          errorMessage: null,
          successMessage: 'Cap nhat ho so cong ty thanh cong',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CompanyApplyStatus.failure,
          action: CompanyApplyAction.update,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }
}
