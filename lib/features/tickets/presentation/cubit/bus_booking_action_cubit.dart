import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_bus_booking_usecase.dart';
import 'bus_booking_action_state.dart';

class BusBookingActionCubit extends Cubit<BusBookingActionState> {
  BusBookingActionCubit(this._createBusBookingUseCase)
    : super(const BusBookingActionState());

  final CreateBusBookingUseCase _createBusBookingUseCase;

  Future<void> createBooking({
    required String showtimeId,
    required List<String> seatNumbers,
    int status = 1,
  }) async {
    emit(
      state.copyWith(
        status: BusBookingActionStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final booking = await _createBusBookingUseCase(
        CreateBusBookingParams(
          showtimeId: showtimeId,
          seatNumbers: seatNumbers,
          status: status,
        ),
      );
      emit(
        state.copyWith(
          status: BusBookingActionStatus.success,
          booking: booking,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BusBookingActionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const BusBookingActionState());
  }
}
