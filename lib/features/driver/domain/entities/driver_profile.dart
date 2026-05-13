import 'package:equatable/equatable.dart';

class DriverProfile extends Equatable {
  const DriverProfile({
    required this.id,
    required this.identityNumber,
    required this.name,
    required this.licenseNumber,
    required this.licenseClass,
    required this.verificationStatus,
    this.licenseDocumentUrl,
    this.createdAt,
    this.lastUpdateAt,
  });

  final String id;
  final String identityNumber;
  final String name;
  final String licenseNumber;
  final String licenseClass;
  final int verificationStatus;
  final String? licenseDocumentUrl;
  final String? createdAt;
  final String? lastUpdateAt;

  bool get isPending => verificationStatus == 1;
  bool get isActive => verificationStatus == 2;
  bool get isInactive => verificationStatus == 3;
  bool get isRejected => verificationStatus == 4;

  String get verificationStatusLabel {
    switch (verificationStatus) {
      case 1:
        return 'Đang chờ duyệt';
      case 2:
        return 'Đã duyệt';
      case 3:
        return 'Tạm ngưng';
      case 4:
        return 'Bị từ chối';
      default:
        return 'Không xác định';
    }
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as String? ?? '',
      identityNumber: json['identityNumber'] as String? ?? '',
      name: json['name'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      licenseClass: json['licenseClass'] as String? ?? '',
      verificationStatus: json['verificationStatus'] as int? ?? 0,
      licenseDocumentUrl: json['licenseDocumentUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      lastUpdateAt: json['lastUpdateAt'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    identityNumber,
    name,
    licenseNumber,
    licenseClass,
    verificationStatus,
    licenseDocumentUrl,
    createdAt,
    lastUpdateAt,
  ];
}
