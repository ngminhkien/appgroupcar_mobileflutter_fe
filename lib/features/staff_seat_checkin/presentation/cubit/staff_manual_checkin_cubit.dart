import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_staff_manual_checkin_info_usecase.dart';
import 'staff_manual_checkin_state.dart';

class StaffManualCheckinCubit extends Cubit<StaffManualCheckinState> {
  StaffManualCheckinCubit(this._getStaffManualCheckinInfoUseCase)
    : super(const StaffManualCheckinState());

  final GetStaffManualCheckinInfoUseCase _getStaffManualCheckinInfoUseCase;

  Future<void> lookup({
    required String showtimeId,
    required String seatNumber,
  }) async {
    final normalizedSeat = seatNumber.trim().toUpperCase();
    if (normalizedSeat.isEmpty) {
      emit(
        state.copyWith(
          status: StaffManualCheckinStatus.failure,
          errorMessage: 'Vui long nhap ma ghe',
          lastSeatNumber: '',
          data: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: StaffManualCheckinStatus.loading,
        errorMessage: null,
        lastSeatNumber: normalizedSeat,
      ),
    );
    try {
      final info = await _getStaffManualCheckinInfoUseCase(
        GetStaffManualCheckinInfoParams(
          showtimeId: showtimeId,
          seatNumber: normalizedSeat,
        ),
      );
      emit(
        state.copyWith(
          status: StaffManualCheckinStatus.success,
          data: info,
          errorMessage: null,
          lastSeatNumber: normalizedSeat,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StaffManualCheckinStatus.failure,
          data: null,
          errorMessage: error.toString(),
          lastSeatNumber: normalizedSeat,
        ),
      );
    }
  }

  void reset() {
    emit(const StaffManualCheckinState());
  }
}
