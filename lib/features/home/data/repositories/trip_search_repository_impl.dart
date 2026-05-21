import '../../../../core/models/paged_result.dart';
import '../../domain/entities/trip_search_item.dart';
import '../../domain/entities/trip_search_request.dart';
import '../../domain/repositories/trip_search_repository.dart';
import '../datasources/trip_search_remote_data_source.dart';

class TripSearchRepositoryImpl implements TripSearchRepository {
  TripSearchRepositoryImpl({required this.remoteDataSource});

  final TripSearchRemoteDataSource remoteDataSource;

  @override
  Future<PagedResult<TripSearchItem>> searchTrips({
    required TripSearchRequest request,
  }) async {
    final response = await remoteDataSource.searchTrips(request: request);
    if (response.code != 200) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Tim chuyen di that bai',
      );
    }
    return response.data ??
        PagedResult<TripSearchItem>(
          items: const [],
          pageNumber: request.pageNumber,
          pageSize: request.pageSize,
        );
  }
}
