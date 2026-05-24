import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bus_seat_map.dart';
import '../../domain/usecases/get_bus_seat_map_usecase.dart';
import '../models/bus_seat_selection_args.dart';
import 'bus_seat_selection_state.dart';

class BusSeatSelectionCubit extends Cubit<BusSeatSelectionState> {
  BusSeatSelectionCubit(this._getBusSeatMapUseCase)
    : super(const BusSeatSelectionState());

  final GetBusSeatMapUseCase _getBusSeatMapUseCase;

  Future<void> initialize(BusSeatSelectionArgs args) async {
    emit(
      state.copyWith(
        status: BusSeatSelectionStatus.loading,
        detail: args.detail,
        seatMap: null,
        selectedSeats: const [],
        errorMessage: null,
      ),
    );

    await _loadSeatMap(initialSelectedSeats: args.initialSelectedSeats);
  }

  Future<void> refresh() async {
    final detail = state.detail;
    if (detail == null) {
      return;
    }
    emit(
      state.copyWith(
        status: BusSeatSelectionStatus.loading,
        seatMap: null,
        errorMessage: null,
      ),
    );
    await _loadSeatMap(initialSelectedSeats: state.selectedSeats);
  }

  void toggleSeatSelection(String seatNumber) {
    final normalizedSeat = _normalizeSeat(seatNumber);
    if (normalizedSeat.isEmpty || !_isSeatAvailable(normalizedSeat)) {
      return;
    }
    final current = state.selectedSeats.toList();
    final existingIndex = current.indexWhere(
      (seat) => _normalizeSeat(seat) == normalizedSeat,
    );
    if (existingIndex >= 0) {
      current.removeAt(existingIndex);
    } else {
      current.add(normalizedSeat);
    }
    current.sort(_seatLabelComparator);
    emit(state.copyWith(selectedSeats: current));
  }

  void clearSelectedSeats() {
    if (state.selectedSeats.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedSeats: const []));
  }

  Future<void> _loadSeatMap({
    required List<String> initialSelectedSeats,
  }) async {
    final detail = state.detail;
    if (detail == null) {
      emit(
        state.copyWith(
          status: BusSeatSelectionStatus.failure,
          errorMessage: 'Khong co thong tin chuyen bus de tai so do ghe',
        ),
      );
      return;
    }

    try {
      final seatMap = await _getBusSeatMapUseCase(showtimeId: detail.id);
      final availableSeatKeys = seatMap.seats
          .where((seat) => seat.availability == BusSeatAvailability.available)
          .map((seat) => _normalizeSeat(seat.seatNumber))
          .where((seat) => seat.isNotEmpty)
          .toSet();

      final selectedSeats =
          initialSelectedSeats
              .map(_normalizeSeat)
              .where((seat) => availableSeatKeys.contains(seat))
              .toSet()
              .toList()
            ..sort(_seatLabelComparator);

      emit(
        state.copyWith(
          status: BusSeatSelectionStatus.success,
          seatMap: seatMap,
          selectedSeats: selectedSeats,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BusSeatSelectionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  bool _isSeatAvailable(String normalizedSeat) {
    final seatMap = state.seatMap;
    if (seatMap == null) {
      return false;
    }
    for (final seat in seatMap.seats) {
      if (_normalizeSeat(seat.seatNumber) == normalizedSeat) {
        return seat.availability == BusSeatAvailability.available;
      }
    }
    return false;
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
