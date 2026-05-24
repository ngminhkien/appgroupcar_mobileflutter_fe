import '../../../../core/models/paged_result.dart';
import '../../domain/entities/location_search_item.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';
import '../models/location_search_request.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({required this.remoteDataSource});

  final LocationRemoteDataSource remoteDataSource;

  @override
  Future<PagedResult<LocationSearchItem>> searchLocations({
    required String query,
    required bool isActive,
    required int pageNumber,
    required int pageSize,
    bool availableForRoute = false,
  }) async {
    final request = LocationSearchRequest(
      query: query,
      isActive: isActive,
      pageNumber: pageNumber,
      pageSize: pageSize,
      availableForRoute: availableForRoute,
    );
    final response = await remoteDataSource.searchLocations(request: request);
    if (response.code != 200) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Tim dia diem that bai',
      );
    }
    return response.data ??
        PagedResult<LocationSearchItem>(
          items: const [],
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
  }
}
