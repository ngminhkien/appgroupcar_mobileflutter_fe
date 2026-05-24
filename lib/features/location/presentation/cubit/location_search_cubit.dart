import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_locations_usecase.dart';
import 'location_search_state.dart';

class LocationSearchCubit extends Cubit<LocationSearchState> {
  LocationSearchCubit(this._searchLocationsUseCase)
    : super(const LocationSearchState());

  final SearchLocationsUseCase _searchLocationsUseCase;
  bool _availableForRoute = false;

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 400);
  static const int _defaultPageSize = 10;

  void setAvailableForRoute(bool value) {
    _availableForRoute = value;
  }

  void onQueryChanged(String value) {
    final query = value.trim();
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      emit(
        const LocationSearchState(
          status: LocationSearchStatus.idle,
          query: '',
          items: [],
          pageNumber: 1,
          hasNextPage: false,
          isPaging: false,
        ),
      );
      return;
    }

    emit(state.copyWith(query: query, errorMessage: null));

    _debounceTimer = Timer(_debounceDuration, () {
      _search(pageNumber: 1);
    });
  }

  Future<void> loadMore() async {
    if (state.query.isEmpty || !state.hasNextPage || state.isPaging) {
      return;
    }
    await _search(pageNumber: state.pageNumber + 1);
  }

  Future<void> retry() async {
    if (state.query.isEmpty) {
      return;
    }
    await _search(pageNumber: 1);
  }

  Future<void> _search({required int pageNumber}) async {
    if (state.query.isEmpty) {
      return;
    }

    if (pageNumber == 1) {
      emit(
        state.copyWith(
          status: LocationSearchStatus.loading,
          items: const [],
          pageNumber: 1,
          hasNextPage: false,
          isPaging: false,
          errorMessage: null,
        ),
      );
    } else {
      emit(state.copyWith(isPaging: true, errorMessage: null));
    }

    try {
      final result = await _searchLocationsUseCase(
        SearchLocationsParams(
          query: state.query,
          isActive: true,
          pageNumber: pageNumber,
          pageSize: _defaultPageSize,
          availableForRoute: _availableForRoute,
        ),
      );
      if (pageNumber == 1) {
        emit(
          state.copyWith(
            status: result.items.isEmpty
                ? LocationSearchStatus.empty
                : LocationSearchStatus.success,
            items: result.items,
            pageNumber: result.pageNumber,
            hasNextPage: result.hasNextPage,
            isPaging: false,
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: LocationSearchStatus.success,
          items: [...state.items, ...result.items],
          pageNumber: result.pageNumber,
          hasNextPage: result.hasNextPage,
          isPaging: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (pageNumber == 1) {
        emit(
          state.copyWith(
            status: LocationSearchStatus.error,
            items: const [],
            pageNumber: 1,
            hasNextPage: false,
            isPaging: false,
            errorMessage: error.toString(),
          ),
        );
        return;
      }

      emit(state.copyWith(isPaging: false, errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
