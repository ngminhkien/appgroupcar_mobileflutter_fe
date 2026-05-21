import '../../../../core/models/paged_result.dart';
import '../entities/trip_search_item.dart';
import '../entities/trip_search_request.dart';
import '../repositories/trip_search_repository.dart';

class SearchTripsUseCase {
  SearchTripsUseCase(this._repository);

  final TripSearchRepository _repository;

  Future<PagedResult<TripSearchItem>> call(TripSearchRequest request) async {
    return _repository.searchTrips(request: request);
  }
}
