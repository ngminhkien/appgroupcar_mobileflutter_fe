import 'package:equatable/equatable.dart';

import 'company_status.dart';
import 'pending_company_update_data.dart';

class CompanyLoginResult extends Equatable {
  const CompanyLoginResult({
    required this.companyId,
    required this.status,
    required this.message,
    this.description,
    this.pendingUpdateData,
  });

  final String companyId;
  final CompanyStatus status;
  final String message;
  final String? description;
  final PendingCompanyUpdateData? pendingUpdateData;

  bool get canUseForUpdate =>
      companyId.trim().isNotEmpty && status != CompanyStatus.approved;

  @override
  List<Object?> get props => [
    companyId,
    status,
    message,
    description,
    pendingUpdateData,
  ];
}
