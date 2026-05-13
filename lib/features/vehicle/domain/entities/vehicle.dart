import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.plateNumber,
    required this.brand,
    required this.seatCapacity,
    required this.vehicleType,
    required this.status,
    required this.urlImage,
    required this.registrationDocumentUrl,
    this.createdAt,
    this.lastUpdateAt,
  });

  final String id;
  final String driverId;
  final String driverName;
  final String plateNumber;
  final String brand;
  final int seatCapacity;
  final int vehicleType;
  final int status;
  final String urlImage;
  final String registrationDocumentUrl;
  final String? createdAt;
  final String? lastUpdateAt;

  bool get isPending => status == 1;
  bool get isActive => status == 2;
  bool get isInactive => status == 3;
  bool get isRejected => status == 4;

  String get vehicleTypeLabel => vehicleTypeLabelOf(vehicleType);

  String get statusLabel {
    switch (status) {
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

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      seatCapacity: _readInt(json['seatCapacity']),
      vehicleType: _readInt(json['vehicleType']),
      status: _readInt(json['status']),
      urlImage: json['urlImage'] as String? ?? '',
      registrationDocumentUrl: json['registrationDocumentUrl'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      lastUpdateAt: json['lastUpdateAt'] as String?,
    );
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    driverId,
    driverName,
    plateNumber,
    brand,
    seatCapacity,
    vehicleType,
    status,
    urlImage,
    registrationDocumentUrl,
    createdAt,
    lastUpdateAt,
  ];
}

String vehicleTypeLabelOf(int value) {
  switch (value) {
    case 1:
      return 'Xe 4 chỗ';
    case 2:
      return 'Xe 7 chỗ';
    case 3:
      return 'Xe đường dài';
    default:
      return value > 0 ? 'Loại $value' : 'Chưa xác định';
  }
}
