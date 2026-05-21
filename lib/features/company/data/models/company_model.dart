import '../../domain/entities/company_profile.dart';
import '../../domain/entities/company_status.dart';
import '../../domain/entities/company_type.dart';

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.companyName,
    required this.companyCode,
    this.logoUrl,
    required this.phone,
    this.email,
    required this.companyType,
    required this.status,
    this.createdAt,
    this.description,
  });

  final String id;
  final String companyName;
  final String companyCode;
  final String? logoUrl;
  final String phone;
  final String? email;
  final CompanyType companyType;
  final CompanyStatus status;
  final DateTime? createdAt;
  final String? description;

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: (json['id'] ?? '').toString(),
      companyName: (json['companyName'] ?? '').toString(),
      companyCode: (json['companyCode'] ?? '').toString(),
      logoUrl: _asNullableString(json['logoUrl']),
      phone: (json['phone'] ?? '').toString(),
      email: _asNullableString(json['email']),
      companyType: CompanyType.fromApiValue(_asInt(json['companyType'])),
      status: CompanyStatus.fromApiValue(_asInt(json['status'])),
      createdAt: _parseDateTime(json['createdAt']),
      description: _asNullableString(json['description']),
    );
  }

  CompanyProfile toEntity() {
    return CompanyProfile(
      id: id,
      companyName: companyName,
      companyCode: companyCode,
      logoUrl: logoUrl,
      phone: phone,
      email: email,
      companyType: companyType,
      status: status,
      createdAt: createdAt,
      description: description,
    );
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
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

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
