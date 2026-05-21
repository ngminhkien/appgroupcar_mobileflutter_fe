import 'package:equatable/equatable.dart';

class HomeRecentSearch extends Equatable {
  const HomeRecentSearch({
    required this.pickupLocationId,
    required this.pickupDisplayName,
    required this.dropoffLocationId,
    required this.dropoffDisplayName,
    required this.createdAt,
  });

  final String pickupLocationId;
  final String pickupDisplayName;
  final String dropoffLocationId;
  final String dropoffDisplayName;
  final DateTime createdAt;

  factory HomeRecentSearch.fromJson(Map<String, dynamic> json) {
    final createdAtText = json['createdAt'] as String? ?? '';
    return HomeRecentSearch(
      pickupLocationId: json['pickupLocationId'] as String? ?? '',
      pickupDisplayName: json['pickupDisplayName'] as String? ?? '',
      dropoffLocationId: json['dropoffLocationId'] as String? ?? '',
      dropoffDisplayName: json['dropoffDisplayName'] as String? ?? '',
      createdAt: DateTime.tryParse(createdAtText) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickupLocationId': pickupLocationId,
      'pickupDisplayName': pickupDisplayName,
      'dropoffLocationId': dropoffLocationId,
      'dropoffDisplayName': dropoffDisplayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    pickupLocationId,
    pickupDisplayName,
    dropoffLocationId,
    dropoffDisplayName,
    createdAt,
  ];
}
