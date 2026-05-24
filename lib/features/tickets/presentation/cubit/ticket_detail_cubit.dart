import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_bus_booking_detail_usecase.dart';
import 'ticket_detail_state.dart';

class TicketDetailCubit extends Cubit<TicketDetailState> {
  TicketDetailCubit(this._getBusBookingDetailUseCase)
    : super(const TicketDetailState());

  final GetBusBookingDetailUseCase _getBusBookingDetailUseCase;

  Future<void> loadDetail(String bookingId) async {
    final normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty) {
      emit(
        state.copyWith(
          status: TicketDetailStatus.failure,
          errorMessage: 'Booking id khong hop le',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TicketDetailStatus.loading,
        bookingId: normalizedBookingId,
        detail: null,
        errorMessage: null,
      ),
    );
    try {
      final detail = await _getBusBookingDetailUseCase(
        bookingId: normalizedBookingId,
      );
      emit(
        state.copyWith(
          status: TicketDetailStatus.success,
          detail: detail,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TicketDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (state.bookingId.trim().isEmpty) {
      return;
    }
    await loadDetail(state.bookingId);
  }
}
