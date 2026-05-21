import '../../../../core/models/paged_result.dart';
import '../entities/trip_search_item.dart';
import '../entities/trip_search_request.dart';

abstract class TripSearchRepository {
  Future<PagedResult<TripSearchItem>> searchTrips({
    required TripSearchRequest request,
  });
}
