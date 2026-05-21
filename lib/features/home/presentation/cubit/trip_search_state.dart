import 'package:equatable/equatable.dart';

import '../../domain/entities/trip_search_item.dart';
import '../../domain/entities/trip_search_request.dart';

enum TripSearchStatus { initial, loading, success, empty, error }

const Object _unset = Object();

class TripSearchState extends Equatable {
  const TripSearchState({
    this.status = TripSearchStatus.initial,
    this.request,
    this.items = const [],
    this.pageNumber = 1,
    this.hasNextPage = false,
    this.isPaging = false,
    this.errorMessage,
  });

  final TripSearchStatus status;
  final TripSearchRequest? request;
  final List<TripSearchItem> items;
  final int pageNumber;
  final bool hasNextPage;
  final bool isPaging;
  final String? errorMessage;

  TripSearchState copyWith({
    TripSearchStatus? status,
    Object? request = _unset,
    List<TripSearchItem>? items,
    int? pageNumber,
    bool? hasNextPage,
    bool? isPaging,
    String? errorMessage,
  }) {
    return TripSearchState(
      status: status ?? this.status,
      request: request == _unset ? this.request : request as TripSearchRequest?,
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
    request,
    items,
    pageNumber,
    hasNextPage,
    isPaging,
    errorMessage,
  ];
}
