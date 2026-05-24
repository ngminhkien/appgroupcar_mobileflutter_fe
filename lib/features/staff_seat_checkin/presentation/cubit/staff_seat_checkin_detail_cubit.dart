import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/staff_seat_map.dart';
import '../../domain/usecases/get_staff_showtime_seat_map_usecase.dart';
import '../../domain/usecases/update_staff_seat_status_usecase.dart';
import 'staff_seat_checkin_detail_state.dart';

class StaffSeatCheckinDetailCubit extends Cubit<StaffSeatCheckinDetailState> {
  StaffSeatCheckinDetailCubit(
    this._getStaffShowtimeSeatMapUseCase,
    this._updateStaffSeatStatusUseCase, {
    required StaffSeatCheckinDetailState initialState,
  }) : super(initialState);

  final GetStaffShowtimeSeatMapUseCase _getStaffShowtimeSeatMapUseCase;
  final UpdateStaffSeatStatusUseCase _updateStaffSeatStatusUseCase;

  Future<void> initialize() async {
    await _loadSeatMap(showLoading: true);
  }

  Future<void> refreshSeatMap() async {
    await _loadSeatMap(showLoading: true);
  }

  void toggleSeatSelection(String seatNumber) {
    final normalizedSeat = _normalizeSeat(seatNumber);
    if (normalizedSeat.isEmpty || !_isSeatSelectable(normalizedSeat)) {
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

  void setReason(String value) {
    emit(state.copyWith(reason: value));
  }

  Future<void> submitOfflineBooking() async {
    if (!state.canSubmit) {
      return;
    }
    emit(
      state.copyWith(
        actionStatus: StaffSeatCheckinActionStatus.loading,
        actionErrorMessage: null,
      ),
    );
    try {
      final updates = await _updateStaffSeatStatusUseCase(
        UpdateStaffSeatStatusParams(
          showtimeId: state.showtime.id,
          seatNumbers: state.selectedSeats,
          newStatus: state.newStatus,
          reason: state.reason,
        ),
      );
      emit(
        state.copyWith(
          actionStatus: StaffSeatCheckinActionStatus.success,
          latestUpdates: updates,
          latestUpdatedAt: DateTime.now(),
          selectedSeats: const [],
          actionErrorMessage: null,
        ),
      );
      await _loadSeatMap(showLoading: true);
    } catch (error) {
      emit(
        state.copyWith(
          actionStatus: StaffSeatCheckinActionStatus.failure,
          actionErrorMessage: error.toString(),
        ),
      );
    }
  }

  void resetActionStatus() {
    if (state.actionStatus == StaffSeatCheckinActionStatus.initial &&
        (state.actionErrorMessage == null ||
            state.actionErrorMessage!.isEmpty)) {
      return;
    }
    emit(
      state.copyWith(
        actionStatus: StaffSeatCheckinActionStatus.initial,
        actionErrorMessage: null,
      ),
    );
  }

  void clearSeatMapErrorMessage() {
    if (state.seatMapErrorMessage == null ||
        state.seatMapErrorMessage!.isEmpty) {
      return;
    }
    emit(state.copyWith(seatMapErrorMessage: null));
  }

  Future<void> _loadSeatMap({required bool showLoading}) async {
    final hadData = state.seatMap != null;
    emit(
      state.copyWith(
        seatMapStatus: showLoading
            ? StaffSeatMapStatus.loading
            : state.seatMapStatus,
        seatMapErrorMessage: null,
      ),
    );
    try {
      final seatMap = await _getStaffShowtimeSeatMapUseCase(
        GetStaffShowtimeSeatMapParams(showtimeId: state.showtime.id),
      );

      final selectableSeats = seatMap.seats
          .where((seat) => seat.availability == StaffSeatAvailability.available)
          .map((seat) => _normalizeSeat(seat.seatNumber))
          .where((seat) => seat.isNotEmpty)
          .toSet();
      final selectedSeats =
          state.selectedSeats
              .map(_normalizeSeat)
              .where(selectableSeats.contains)
              .toSet()
              .toList()
            ..sort(_seatLabelComparator);

      emit(
        state.copyWith(
          seatMapStatus: StaffSeatMapStatus.success,
          seatMap: seatMap,
          selectedSeats: selectedSeats,
          seatMapErrorMessage: null,
        ),
      );
    } catch (error) {
      if (hadData) {
        emit(
          state.copyWith(
            seatMapStatus: StaffSeatMapStatus.success,
            seatMapErrorMessage: error.toString(),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          seatMapStatus: StaffSeatMapStatus.failure,
          seatMapErrorMessage: error.toString(),
        ),
      );
    }
  }

  bool _isSeatSelectable(String normalizedSeatNumber) {
    final seatMap = state.seatMap;
    if (seatMap == null) {
      return false;
    }
    for (final seat in seatMap.seats) {
      final key = _normalizeSeat(seat.seatNumber);
      if (key != normalizedSeatNumber) {
        continue;
      }
      return seat.availability == StaffSeatAvailability.available;
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
