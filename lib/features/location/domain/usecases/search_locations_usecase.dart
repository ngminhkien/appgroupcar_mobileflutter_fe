import '../../../../core/models/paged_result.dart';
import '../entities/location_search_item.dart';
import '../repositories/location_repository.dart';

class SearchLocationsUseCase {
  SearchLocationsUseCase(this._repository);

  final LocationRepository _repository;

  Future<PagedResult<LocationSearchItem>> call(
    SearchLocationsParams params,
  ) async {
    return _repository.searchLocations(
      query: params.query,
      isActive: params.isActive,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

class SearchLocationsParams {
  const SearchLocationsParams({
    required this.query,
    this.isActive = true,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  final String query;
  final bool isActive;
  final int pageNumber;
  final int pageSize;
}
