import 'package:equatable/equatable.dart';

import '../../domain/entities/location_search_item.dart';

enum LocationSearchStatus { idle, loading, success, empty, error }

class LocationSearchState extends Equatable {
  const LocationSearchState({
    this.status = LocationSearchStatus.idle,
    this.query = '',
    this.items = const [],
    this.pageNumber = 1,
    this.hasNextPage = false,
    this.isPaging = false,
    this.errorMessage,
  });

  final LocationSearchStatus status;
  final String query;
  final List<LocationSearchItem> items;
  final int pageNumber;
  final bool hasNextPage;
  final bool isPaging;
  final String? errorMessage;

  LocationSearchState copyWith({
    LocationSearchStatus? status,
    String? query,
    List<LocationSearchItem>? items,
    int? pageNumber,
    bool? hasNextPage,
    bool? isPaging,
    String? errorMessage,
  }) {
    return LocationSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      items: items ?? this.items,
      pageNumber: pageNumber ?? this.pageNumber,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isPaging: isPaging ?? this.isPaging,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    items,
    pageNumber,
    hasNextPage,
    isPaging,
    errorMessage,
  ];
}
