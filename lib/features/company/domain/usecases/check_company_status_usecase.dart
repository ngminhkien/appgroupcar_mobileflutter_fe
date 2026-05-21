import 'package:equatable/equatable.dart';

import '../entities/company_login_result.dart';
import '../repositories/company_repository.dart';

class CheckCompanyStatusUseCase {
  const CheckCompanyStatusUseCase(this._repository);

  final CompanyRepository _repository;

  Future<CompanyLoginResult> call(CheckCompanyStatusParams params) {
    return _repository.checkCompanyStatus(
      email: params.email,
      businessLicenseNo: params.businessLicenseNo,
    );
  }
}

class CheckCompanyStatusParams extends Equatable {
  const CheckCompanyStatusParams({
    required this.email,
    required this.businessLicenseNo,
  });

  final String email;
  final String businessLicenseNo;

  @override
  List<Object?> get props => [email, businessLicenseNo];
}
