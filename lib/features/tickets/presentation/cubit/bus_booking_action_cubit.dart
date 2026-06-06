import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_bus_booking_usecase.dart';
import '../../domain/usecases/create_offer_booking_usecase.dart';
import 'bus_booking_action_state.dart';

class BusBookingActionCubit extends Cubit<BusBookingActionState> {
  BusBookingActionCubit(
    this._createBusBookingUseCase,
    this._createOfferBookingUseCase,
  ) : super(const BusBookingActionState());

  final CreateBusBookingUseCase _createBusBookingUseCase;
  final CreateOfferBookingUseCase _createOfferBookingUseCase;

  Future<void> createBooking({
    required String showtimeId,
    required List<String> seatNumbers,
    required String pickupLocationId,
    required String dropoffLocationId,
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
          pickupLocationId: pickupLocationId,
          dropoffLocationId: dropoffLocationId,
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

  Future<void> createOfferBooking({
    required String offerId,
    required String pickupLocationId,
    required String dropoffLocationId,
    required double price,
  }) async {
    emit(
      state.copyWith(
        status: BusBookingActionStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final booking = await _createOfferBookingUseCase(
        CreateOfferBookingParams(
          offerId: offerId,
          pickupLocationId: pickupLocationId,
          dropoffLocationId: dropoffLocationId,
          price: price,
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
