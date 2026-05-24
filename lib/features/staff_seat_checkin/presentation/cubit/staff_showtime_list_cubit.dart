import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_upcoming_staff_showtimes_usecase.dart';
import 'staff_showtime_list_state.dart';

class StaffShowtimeListCubit extends Cubit<StaffShowtimeListState> {
  StaffShowtimeListCubit(this._getUpcomingStaffShowtimesUseCase)
    : super(StaffShowtimeListState());

  final GetUpcomingStaffShowtimesUseCase _getUpcomingStaffShowtimesUseCase;

  Future<void> initialize() async {
    await loadShowtimes(fromDate: state.fromDate);
  }

  Future<void> setFromDate(DateTime fromDate) async {
    await loadShowtimes(fromDate: fromDate);
  }

  Future<void> refresh() async {
    await loadShowtimes(fromDate: state.fromDate);
  }

  Future<void> loadShowtimes({required DateTime fromDate}) async {
    final normalizedDate = DateTime(
      fromDate.year,
      fromDate.month,
      fromDate.day,
    );
    final hadData = state.items.isNotEmpty;
    emit(
      state.copyWith(
        status: StaffShowtimeListStatus.loading,
        fromDate: normalizedDate,
        errorMessage: null,
      ),
    );
    try {
      final result = await _getUpcomingStaffShowtimesUseCase(
        GetUpcomingStaffShowtimesParams(fromDate: normalizedDate),
      );
      emit(
        state.copyWith(
          status: StaffShowtimeListStatus.success,
          result: result,
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (hadData) {
        emit(
          state.copyWith(
            status: StaffShowtimeListStatus.success,
            errorMessage: error.toString(),
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: StaffShowtimeListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clearErrorMessage() {
    if (state.errorMessage == null || state.errorMessage!.isEmpty) {
      return;
    }
    emit(state.copyWith(errorMessage: null));
  }
}
