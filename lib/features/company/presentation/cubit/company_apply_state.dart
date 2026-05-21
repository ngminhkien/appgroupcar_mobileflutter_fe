import 'package:equatable/equatable.dart';

import '../../domain/entities/company_login_result.dart';
import '../../domain/entities/company_profile.dart';

enum CompanyApplyStatus { initial, loading, success, failure }

enum CompanyApplyAction { none, checkStatus, create, update }

const Object _unset = Object();

class CompanyApplyState extends Equatable {
  const CompanyApplyState({
    this.status = CompanyApplyStatus.initial,
    this.action = CompanyApplyAction.none,
    this.logoPath,
    this.checkResult,
    this.latestCompany,
    this.errorMessage,
    this.successMessage,
  });

  final CompanyApplyStatus status;
  final CompanyApplyAction action;
  final String? logoPath;
  final CompanyLoginResult? checkResult;
  final CompanyProfile? latestCompany;
  final String? errorMessage;
  final String? successMessage;

  bool get isChecking =>
      status == CompanyApplyStatus.loading &&
      action == CompanyApplyAction.checkStatus;

  bool get isSubmitting =>
      status == CompanyApplyStatus.loading &&
      (action == CompanyApplyAction.create || action == CompanyApplyAction.update);

  CompanyApplyState copyWith({
    CompanyApplyStatus? status,
    CompanyApplyAction? action,
    Object? logoPath = _unset,
    Object? checkResult = _unset,
    Object? latestCompany = _unset,
    String? errorMessage,
    String? successMessage,
  }) {
    return CompanyApplyState(
      status: status ?? this.status,
      action: action ?? this.action,
      logoPath: logoPath == _unset ? this.logoPath : logoPath as String?,
      checkResult: checkResult == _unset
          ? this.checkResult
          : checkResult as CompanyLoginResult?,
      latestCompany: latestCompany == _unset
          ? this.latestCompany
          : latestCompany as CompanyProfile?,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    action,
    logoPath,
    checkResult,
    latestCompany,
    errorMessage,
    successMessage,
  ];
}
