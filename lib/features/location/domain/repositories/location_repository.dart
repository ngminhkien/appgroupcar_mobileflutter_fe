import '../../../../core/models/paged_result.dart';
import '../entities/location_search_item.dart';

abstract class LocationRepository {
  Future<PagedResult<LocationSearchItem>> searchLocations({
    required String query,
    required bool isActive,
    required int pageNumber,
    required int pageSize,
    bool availableForRoute = false,
  });
}
