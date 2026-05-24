import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_bus_bookings_usecase.dart';
import 'my_tickets_state.dart';

class MyTicketsCubit extends Cubit<MyTicketsState> {
  MyTicketsCubit(this._getMyBusBookingsUseCase) : super(const MyTicketsState());

  final GetMyBusBookingsUseCase _getMyBusBookingsUseCase;

  Future<void> loadBookings({bool isRefresh = false}) async {
    emit(
      state.copyWith(
        status: MyTicketsStatus.loading,
        errorMessage: null,
        bookings: isRefresh ? state.bookings : const [],
      ),
    );
    try {
      final bookings = await _getMyBusBookingsUseCase();
      emit(
        state.copyWith(
          status: MyTicketsStatus.success,
          bookings: bookings,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MyTicketsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
