import '../../domain/entities/company_login_result.dart';
import '../../domain/entities/company_status.dart';
import 'pending_company_update_data_model.dart';

class CompanyLoginResultModel {
  const CompanyLoginResultModel({
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
  final PendingCompanyUpdateDataModel? pendingUpdateData;

  factory CompanyLoginResultModel.fromJson(
    Map<String, dynamic> json, {
    required String message,
  }) {
    final pendingValue = json['pendingUpdateData'];
    final pendingMap = pendingValue is Map<String, dynamic> ? pendingValue : null;
    return CompanyLoginResultModel(
      companyId: (json['companyId'] ?? '').toString(),
      status: CompanyStatus.fromCompanyLoginApiValue(_asInt(json['status'])),
      message: message,
      description: _asNullableString(json['description']),
      pendingUpdateData: pendingMap == null
          ? null
          : PendingCompanyUpdateDataModel.fromJson(pendingMap),
    );
  }

  CompanyLoginResult toEntity() {
    return CompanyLoginResult(
      companyId: companyId,
      status: status,
      message: message,
      description: description,
      pendingUpdateData: pendingUpdateData?.toEntity(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
