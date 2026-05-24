import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_bus_showtime_detail_usecase.dart';
import '../models/trip_detail_navigation_args.dart';
import 'bus_trip_detail_state.dart';

class BusTripDetailCubit extends Cubit<BusTripDetailState> {
  BusTripDetailCubit(this._getBusShowtimeDetailUseCase)
    : super(const BusTripDetailState());

  final GetBusShowtimeDetailUseCase _getBusShowtimeDetailUseCase;

  Future<void> initialize(TripDetailNavigationArgs args) async {
    final normalizedServiceCode = args.serviceCode.trim().toUpperCase();
    emit(
      state.copyWith(
        status: BusTripDetailStatus.loading,
        tripId: args.tripId.trim(),
        serviceCode: normalizedServiceCode,
        detailApi: args.detailApi.trim(),
        detail: null,
        selectedSeats: const [],
        errorMessage: null,
      ),
    );

    if (normalizedServiceCode != 'BUS') {
      emit(
        state.copyWith(
          status: BusTripDetailStatus.unsupported,
          errorMessage:
              'Luong chi tiet cho service $normalizedServiceCode chua duoc ho tro',
        ),
      );
      return;
    }

    await _loadDetail();
  }

  Future<void> retryDetail() async {
    if (state.detailApi.trim().isEmpty) {
      return;
    }
    emit(
      state.copyWith(
        status: BusTripDetailStatus.loading,
        detail: null,
        selectedSeats: const [],
        errorMessage: null,
      ),
    );
    await _loadDetail();
  }

  void setSelectedSeats(List<String> seats) {
    final normalizedSeats =
        seats
            .map(_normalizeSeat)
            .where((seat) => seat.isNotEmpty)
            .toSet()
            .toList()
          ..sort(_seatLabelComparator);
    emit(state.copyWith(selectedSeats: normalizedSeats));
  }

  void clearSelectedSeats() {
    if (state.selectedSeats.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedSeats: const []));
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _getBusShowtimeDetailUseCase(
        detailApi: state.detailApi,
      );
      emit(
        state.copyWith(
          status: BusTripDetailStatus.success,
          detail: detail,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BusTripDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

String _normalizeSeat(String value) {
  return value.trim().toUpperCase();
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
