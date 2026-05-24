import '../../domain/entities/bus_seat_map.dart';
import '../../domain/entities/bus_showtime_detail.dart';
import '../../domain/repositories/bus_trip_repository.dart';
import '../datasources/bus_trip_remote_data_source.dart';

class BusTripRepositoryImpl implements BusTripRepository {
  BusTripRepositoryImpl({required this.remoteDataSource});

  final BusTripRemoteDataSource remoteDataSource;

  @override
  Future<BusShowtimeDetail> getBusShowtimeDetail({
    required String detailApi,
  }) async {
    if (detailApi.trim().isEmpty) {
      throw Exception('Detail API khong hop le');
    }
    final response = await remoteDataSource.getBusShowtimeDetail(
      detailApi: detailApi,
    );
    if (response.code != 200) {
      throw Exception(
        _detailMessage(
          code: response.code,
          message: response.message,
          fallback: 'Khong the tai chi tiet chuyen bus',
        ),
      );
    }
    final detail = response.data;
    if (detail == null) {
      throw Exception('Chi tiet chuyen bus khong ton tai');
    }
    return detail;
  }

  @override
  Future<BusSeatMap> getBusSeatMap({required String showtimeId}) async {
    if (showtimeId.trim().isEmpty) {
      throw Exception('Showtime id khong hop le');
    }

    final seatMapResponse = await remoteDataSource.getSeatMap(
      showtimeId: showtimeId,
    );
    if (seatMapResponse.code == 200 && seatMapResponse.data != null) {
      return seatMapResponse.data!;
    }

    final seatLayoutResponse = await remoteDataSource.getSeatLayout(
      showtimeId: showtimeId,
    );
    final seatStatusesResponse = await remoteDataSource.getSeatStatuses(
      showtimeId: showtimeId,
    );

    if (seatLayoutResponse.code == 200 && seatLayoutResponse.data != null) {
      if (seatStatusesResponse.code == 200) {
        return BusSeatMap(
          showtimeId: showtimeId,
          seatLayout: seatLayoutResponse.data!,
          seats: seatStatusesResponse.data,
        );
      }
    }

    if (seatMapResponse.code == 404 ||
        seatLayoutResponse.code == 404 ||
        seatStatusesResponse.code == 404) {
      throw Exception('Showtime hoac so do ghe khong ton tai');
    }

    final seatMapMessage = seatMapResponse.message.trim();
    final layoutMessage = seatLayoutResponse.message.trim();
    final seatsMessage = seatStatusesResponse.message.trim();
    final fallback = 'Khong the tai so do ghe cho chuyen bus';
    throw Exception(
      seatMapMessage.isNotEmpty
          ? seatMapMessage
          : (layoutMessage.isNotEmpty
                ? layoutMessage
                : (seatsMessage.isNotEmpty ? seatsMessage : fallback)),
    );
  }

  String _detailMessage({
    required int code,
    required String message,
    required String fallback,
  }) {
    if (code == 404) {
      return 'Showtime bus khong ton tai';
    }
    if (message.trim().isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
