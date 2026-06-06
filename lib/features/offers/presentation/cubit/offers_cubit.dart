import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_shared_rides_usecase.dart';
import '../../domain/usecases/get_shipments_usecase.dart';
import '../../domain/usecases/create_shared_ride_usecase.dart';
import '../../domain/usecases/create_shipment_usecase.dart';
import 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(
    this._getSharedRidesUseCase,
    this._getShipmentsUseCase,
    this._createSharedRideUseCase,
    this._createShipmentUseCase,
  ) : super(const OffersState());

  final GetSharedRidesUseCase _getSharedRidesUseCase;
  final GetShipmentsUseCase _getShipmentsUseCase;
  final CreateSharedRideUseCase _createSharedRideUseCase;
  final CreateShipmentUseCase _createShipmentUseCase;

  Future<void> searchSharedRides({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    emit(state.copyWith(status: OffersStatus.loading, errorMessage: null));
    try {
      final results = await _getSharedRidesUseCase(
        pickupLocationId: pickupLocationId,
        dropoffLocationId: dropoffLocationId,
        startTime: startTime,
        endTime: endTime,
        startPrice: startPrice,
        endPrice: endPrice,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      emit(
        state.copyWith(
          status: results.isEmpty ? OffersStatus.empty : OffersStatus.success,
          sharedRides: results,
          shipments: const [],
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> searchShipments({
    String? pickupLocationId,
    String? dropoffLocationId,
    String? startTime,
    String? endTime,
    double? startPrice,
    double? endPrice,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    emit(state.copyWith(status: OffersStatus.loading, errorMessage: null));
    try {
      final results = await _getShipmentsUseCase(
        pickupLocationId: pickupLocationId,
        dropoffLocationId: dropoffLocationId,
        startTime: startTime,
        endTime: endTime,
        startPrice: startPrice,
        endPrice: endPrice,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      emit(
        state.copyWith(
          status: results.isEmpty ? OffersStatus.empty : OffersStatus.success,
          shipments: results,
          sharedRides: const [],
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> createSharedRide({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
  }) async {
    emit(state.copyWith(status: OffersStatus.loading, errorMessage: null));
    try {
      await _createSharedRideUseCase(
        vehicleId: vehicleId,
        departureTime: departureTime,
        estimatedDurationMinutes: estimatedDurationMinutes,
        basePrice: basePrice,
        offerRoutePoints: offerRoutePoints,
      );
      emit(state.copyWith(status: OffersStatus.success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: OffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> createShipment({
    required String vehicleId,
    required String departureTime,
    required int estimatedDurationMinutes,
    required double basePrice,
    required List<Map<String, dynamic>> offerRoutePoints,
    required Map<String, dynamic> cargo,
  }) async {
    emit(state.copyWith(status: OffersStatus.loading, errorMessage: null));
    try {
      await _createShipmentUseCase(
        vehicleId: vehicleId,
        departureTime: departureTime,
        estimatedDurationMinutes: estimatedDurationMinutes,
        basePrice: basePrice,
        offerRoutePoints: offerRoutePoints,
        cargo: cargo,
      );
      emit(state.copyWith(status: OffersStatus.success));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: OffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void reset() {
    emit(const OffersState());
  }
}
