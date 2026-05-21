import 'package:equatable/equatable.dart';

import 'company_status.dart';
import 'company_type.dart';

class CompanyProfile extends Equatable {
  const CompanyProfile({
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

  @override
  List<Object?> get props => [
    id,
    companyName,
    companyCode,
    logoUrl,
    phone,
    email,
    companyType,
    status,
    createdAt,
    description,
  ];
}
