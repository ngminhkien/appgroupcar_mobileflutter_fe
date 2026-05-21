import 'package:equatable/equatable.dart';

class LocationSearchItem extends Equatable {
  const LocationSearchItem({
    required this.id,
    required this.code,
    required this.name,
    required this.locationType,
    required this.locationTypeName,
    required this.locationTypeLabel,
    required this.displayName,
  });

  final String id;
  final String code;
  final String name;
  final int locationType;
  final String locationTypeName;
  final String locationTypeLabel;
  final String displayName;

  factory LocationSearchItem.fromJson(Map<String, dynamic> json) {
    return LocationSearchItem(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      locationType: _readInt(json['locationType']),
      locationTypeName: json['locationTypeName'] as String? ?? '',
      locationTypeLabel: json['locationTypeLabel'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'locationType': locationType,
      'locationTypeName': locationTypeName,
      'locationTypeLabel': locationTypeLabel,
      'displayName': displayName,
    };
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
    code,
    name,
    locationType,
    locationTypeName,
    locationTypeLabel,
    displayName,
  ];
}
