import '../../domain/entities/bus_booking.dart';
import '../../domain/entities/bus_booking_detail.dart';
import '../../domain/repositories/bus_booking_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../datasources/bus_booking_remote_data_source.dart';

class BusBookingRepositoryImpl implements BusBookingRepository {
  BusBookingRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final BusBookingRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<BusBooking> createBusBooking({
    required String showtimeId,
    required List<String> seatNumbers,
    int status = 1,
  }) async {
    final normalizedShowtimeId = showtimeId.trim();
    if (normalizedShowtimeId.isEmpty) {
      throw Exception('Showtime id khong hop le');
    }
    if (status != 1 && status != 2) {
      throw Exception('Invalid booking status');
    }

    final normalizedSeats = _normalizeSeatNumbers(seatNumbers);
    if (normalizedSeats.isEmpty) {
      throw Exception('Seat numbers are required');
    }

    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.createBusBooking(
      accessToken: accessToken,
      showtimeId: normalizedShowtimeId,
      seatNumbers: normalizedSeats,
      status: status,
    );

    if (response.code == 201 && response.data != null) {
      return response.data!;
    }

    if (response.code == 409) {
      if (response.unavailableSeats.isNotEmpty) {
        throw Exception(
          'Seats are not available: ${response.unavailableSeats.join(', ')}',
        );
      }
      throw Exception('Seats are not available');
    }

    if (response.code == 401) {
      throw Exception('Invalid user');
    }
    if (response.code == 404) {
      final message = response.message.trim();
      throw Exception(message.isNotEmpty ? message : 'Showtime not found');
    }

    final message = response.message.trim();
    if (message.isNotEmpty) {
      throw Exception(message);
    }
    throw Exception('Create booking failed');
  }

  @override
  Future<List<BusBooking>> getMyBusBookings() async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getMyBookings(
      accessToken: accessToken,
    );
    if (response.code == 200) {
      return response.data;
    }
    if (response.code == 401) {
      throw Exception('Invalid user');
    }
    final message = response.message.trim();
    throw Exception(message.isNotEmpty ? message : 'Khong the tai danh sach ve');
  }

  @override
  Future<BusBookingDetail> getBusBookingDetail({required String bookingId}) async {
    final normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty) {
      throw Exception('Booking id khong hop le');
    }

    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getBookingDetail(
      accessToken: accessToken,
      bookingId: normalizedBookingId,
    );
    if (response.code == 200 && response.data != null) {
      return response.data!;
    }
    if (response.code == 401) {
      throw Exception('Invalid user');
    }
    if (response.code == 404) {
      throw Exception('Khong tim thay thong tin ve');
    }
    final message = response.message.trim();
    throw Exception(message.isNotEmpty ? message : 'Khong the tai chi tiet ve');
  }

  Future<String> _requireAccessToken() async {
    final tokens = await authRepository.getSavedTokens();
    final accessToken = tokens?.accessToken;
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception('Chua dang nhap');
    }
    return accessToken.trim();
  }
}

List<String> _normalizeSeatNumbers(List<String> input) {
  final seen = <String>{};
  final result = <String>[];
  for (final seat in input) {
    final normalized = seat.trim().toUpperCase();
    if (normalized.isEmpty) {
      continue;
    }
    if (seen.contains(normalized)) {
      throw Exception('Duplicate seat numbers');
    }
    seen.add(normalized);
    result.add(normalized);
  }
  result.sort(_seatLabelComparator);
  return result;
}

int _seatLabelComparator(String left, String right) {
  final leftParts = _parseSeatLabel(left);
  final rightParts = _parseSeatLabel(right);
  if (leftParts.row != rightParts.row) {
    return leftParts.row.compareTo(rightParts.row);
  }
  if (leftParts.column != rightParts.column) {
    return leftParts.column.compareTo(rightParts.column);
  }
  return left.compareTo(right);
}

_SeatLabelParts _parseSeatLabel(String value) {
  final normalized = value.trim().toUpperCase();
  final regExp = RegExp(r'^([A-Z]+)(\d+)$');
  final match = regExp.firstMatch(normalized);
  if (match == null) {
    return _SeatLabelParts(row: 1 << 30, column: 1 << 30);
  }
  final letters = match.group(1) ?? '';
  final numbers = match.group(2) ?? '';
  var row = 0;
  for (final char in letters.codeUnits) {
    row = row * 26 + (char - 64);
  }
  final column = int.tryParse(numbers) ?? 0;
  return _SeatLabelParts(row: row, column: column);
}

class _SeatLabelParts {
  const _SeatLabelParts({required this.row, required this.column});

  final int row;
  final int column;
}
