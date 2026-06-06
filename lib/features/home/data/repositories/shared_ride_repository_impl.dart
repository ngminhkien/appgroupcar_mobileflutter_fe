import '../../domain/entities/shared_ride_detail.dart';
import '../../domain/repositories/shared_ride_repository.dart';
import '../datasources/shared_ride_remote_data_source.dart';

class SharedRideRepositoryImpl implements SharedRideRepository {
  SharedRideRepositoryImpl({required this.remoteDataSource});

  final SharedRideRemoteDataSource remoteDataSource;

  @override
  Future<SharedRideDetail> getSharedRideDetail({
    required String detailApi,
  }) async {
    if (detailApi.trim().isEmpty) {
      throw Exception('Detail API khong hop le');
    }
    final response = await remoteDataSource.getSharedRideDetail(
      detailApi: detailApi,
    );
    if (response.code != 200) {
      throw Exception(
        _detailMessage(
          code: response.code,
          message: response.message,
          fallback: 'Khong the tai chi tiet chuyen xe ghep',
        ),
      );
    }
    final detail = response.data;
    if (detail == null) {
      throw Exception('Chi tiet chuyen xe ghep khong ton tai');
    }
    return detail;
  }

  String _detailMessage({
    required int code,
    required String message,
    required String fallback,
  }) {
    if (code == 404) {
      return 'Chuyen xe ghep khong ton tai';
    }
    if (message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
