import '../../domain/entities/staff_seat_map.dart';
import '../../domain/entities/staff_manual_checkin_info.dart';
import '../../domain/entities/staff_seat_status_history.dart';
import '../../domain/entities/staff_upcoming_showtime.dart';
import '../../domain/repositories/staff_seat_checkin_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../datasources/staff_seat_checkin_remote_data_source.dart';

class StaffSeatCheckinRepositoryImpl implements StaffSeatCheckinRepository {
  StaffSeatCheckinRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  final StaffSeatCheckinRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  @override
  Future<StaffUpcomingShowtimeResult> getUpcomingShowtimes({
    DateTime? fromDate,
  }) async {
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getUpcomingShowtimes(
      accessToken: accessToken,
      fromDate: fromDate == null ? null : _formatDateOnly(fromDate),
    );

    if (response.code == 200 && response.data != null) {
      return response.data!;
    }

    if (response.code == 401) {
      throw Exception('Phien dang nhap da het han');
    }
    if (response.code == 403) {
      throw Exception('Ban khong co quyen truy cap du lieu check-in');
    }
    final message = response.message.trim();
    throw Exception(
      message.isNotEmpty ? message : 'Khong the tai danh sach chuyen sap chay',
    );
  }

  @override
  Future<StaffSeatMap> getSeatMap({required String showtimeId}) async {
    final normalizedShowtimeId = showtimeId.trim();
    if (normalizedShowtimeId.isEmpty) {
      throw Exception('Showtime id khong hop le');
    }

    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getSeatMap(
      accessToken: accessToken,
      showtimeId: normalizedShowtimeId,
    );

    if (response.code == 200 && response.data != null) {
      return response.data!;
    }
    if (response.code == 404) {
      throw Exception('Khong tim thay so do ghe cua chuyen nay');
    }
    if (response.code == 401) {
      throw Exception('Phien dang nhap da het han');
    }
    if (response.code == 403) {
      throw Exception('Ban khong co quyen xem so do ghe cua chuyen nay');
    }

    final message = response.message.trim();
    throw Exception(message.isNotEmpty ? message : 'Khong the tai so do ghe');
  }

  @override
  Future<List<StaffSeatStatusHistory>> updateSeatStatus({
    required String showtimeId,
    required List<String> seatNumbers,
    int newStatus = 1,
    String reason = 'Khach mua truc tiep',
  }) async {
    final normalizedShowtimeId = showtimeId.trim();
    if (normalizedShowtimeId.isEmpty) {
      throw Exception('Showtime id khong hop le');
    }
    if (newStatus <= 0) {
      throw Exception('newStatus khong hop le');
    }

    final normalizedSeats = _normalizeSeatNumbers(seatNumbers);
    if (normalizedSeats.isEmpty) {
      throw Exception('Vui long chon it nhat 1 ghe');
    }

    final trimmedReason = reason.trim().isEmpty
        ? 'Khach mua truc tiep'
        : reason.trim();
    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.updateSeatStatus(
      accessToken: accessToken,
      showtimeId: normalizedShowtimeId,
      seatNumbers: normalizedSeats,
      newStatus: newStatus,
      reason: trimmedReason,
    );

    if (response.code == 200) {
      return response.data;
    }
    if (response.code == 204) {
      return const [];
    }
    if (response.code == 400) {
      final message = response.message.trim();
      throw Exception(
        message.isNotEmpty ? message : 'Du lieu cap nhat ghe khong hop le',
      );
    }
    if (response.code == 401) {
      throw Exception('Phien dang nhap da het han');
    }
    if (response.code == 403) {
      throw Exception('Ban khong co quyen cap nhat ghe cua chuyen nay');
    }
    if (response.code == 404) {
      throw Exception('Khong tim thay chuyen hoac ghe can cap nhat');
    }

    final message = response.message.trim();
    throw Exception(
      message.isNotEmpty ? message : 'Khong the cap nhat trang thai ghe',
    );
  }

  @override
  Future<StaffManualCheckinInfo> getManualCheckinInfo({
    required String showtimeId,
    required String seatNumber,
  }) async {
    final normalizedShowtimeId = showtimeId.trim();
    if (normalizedShowtimeId.isEmpty) {
      throw Exception('Showtime id khong hop le');
    }
    final normalizedSeatNumber = seatNumber.trim().toUpperCase();
    if (normalizedSeatNumber.isEmpty) {
      throw Exception('Vui long nhap ma ghe');
    }

    final accessToken = await _requireAccessToken();
    final response = await remoteDataSource.getManualCheckinInfo(
      accessToken: accessToken,
      showtimeId: normalizedShowtimeId,
      seatNumber: normalizedSeatNumber,
    );

    if (response.code == 200 && response.data != null) {
      return response.data!;
    }
    if (response.code == 400) {
      final message = response.message.trim();
      throw Exception(
        message.isNotEmpty ? message : 'Ma ghe hoac chuyen khong hop le',
      );
    }
    if (response.code == 401) {
      throw Exception('Phien dang nhap da het han hoac token khong hop le');
    }
    if (response.code == 404) {
      throw Exception(
        'Khong tim thay booking cho ghe nay trong chuyen da chon',
      );
    }

    final message = response.message.trim();
    throw Exception(
      message.isNotEmpty
          ? message
          : 'Khong the tra cuu thong tin check-in thu cong',
    );
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

String _formatDateOnly(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
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
      throw Exception('Danh sach ghe bi trung lap');
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
