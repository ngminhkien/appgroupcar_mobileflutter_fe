import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trip_search_request.dart';
import '../../domain/usecases/search_trips_usecase.dart';
import 'trip_search_state.dart';

class TripSearchCubit extends Cubit<TripSearchState> {
  TripSearchCubit(this._searchTripsUseCase) : super(const TripSearchState());

  final SearchTripsUseCase _searchTripsUseCase;

  Future<void> search(TripSearchRequest request) async {
    emit(
      state.copyWith(
        status: TripSearchStatus.loading,
        request: request.copyWith(pageNumber: 1),
        items: const [],
        pageNumber: 1,
        hasNextPage: false,
        isPaging: false,
        errorMessage: null,
      ),
    );
    await _searchPage(pageNumber: 1);
  }

  Future<void> retry() async {
    final request = state.request;
    if (request == null) {
      return;
    }
    await search(request.copyWith(pageNumber: 1));
  }

  Future<void> loadMore() async {
    if (!state.hasNextPage || state.isPaging || state.request == null) {
      return;
    }
    emit(state.copyWith(isPaging: true, errorMessage: null));
    await _searchPage(pageNumber: state.pageNumber + 1);
  }

  Future<void> _searchPage({required int pageNumber}) async {
    final baseRequest = state.request;
    if (baseRequest == null) {
      return;
    }

    try {
      final result = await _searchTripsUseCase(
        baseRequest.copyWith(pageNumber: pageNumber),
      );

      if (pageNumber == 1) {
        emit(
          state.copyWith(
            status: result.items.isEmpty
                ? TripSearchStatus.empty
                : TripSearchStatus.success,
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
          status: TripSearchStatus.success,
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
            status: TripSearchStatus.error,
            items: const [],
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
}
