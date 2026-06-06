import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/shared_ride_detail.dart';
import '../../domain/usecases/get_shared_ride_detail_usecase.dart';
import '../models/trip_detail_navigation_args.dart';
import 'shared_ride_detail_state.dart';

class SharedRideDetailCubit extends Cubit<SharedRideDetailState> {
  SharedRideDetailCubit(this._getSharedRideDetailUseCase)
    : super(const SharedRideDetailState());

  final GetSharedRideDetailUseCase _getSharedRideDetailUseCase;

  Future<void> initialize(TripDetailNavigationArgs args) async {
    final rawServiceCode = args.serviceCode.trim().toUpperCase();
    final normalizedServiceCode = rawServiceCode.replaceAll(
      RegExp(r'[-_\s]'),
      '',
    );
    final resolvedDetailApi =
        (normalizedServiceCode == 'SHAREDRIDE' ||
            normalizedServiceCode == 'SHARERIDE')
        ? '/Offer/${args.tripId.trim()}/detail'
        : args.detailApi.trim();
    emit(
      state.copyWith(
        status: SharedRideDetailStatus.loading,
        tripId: args.tripId.trim(),
        serviceCode: rawServiceCode,
        detailApi: resolvedDetailApi,
        detail: null,
        errorMessage: null,
        selectedPickupLocation: null,
        selectedDropoffLocation: null,
      ),
    );

    if (normalizedServiceCode != 'SHAREDRIDE' &&
        normalizedServiceCode != 'SHARERIDE') {
      emit(
        state.copyWith(
          status: SharedRideDetailStatus.unsupported,
          errorMessage:
              'Luong chi tiet cho service $rawServiceCode chua duoc ho tro trong luong xe ghep',
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
        status: SharedRideDetailStatus.loading,
        detail: null,
        errorMessage: null,
        selectedPickupLocation: null,
        selectedDropoffLocation: null,
      ),
    );
    await _loadDetail();
  }

  void selectPickupLocation(SharedRideRoutePointDetail? point) {
    if (state.selectedDropoffLocation != null &&
        point != null &&
        state.selectedDropoffLocation!.sequence <= point.sequence) {
      emit(
        state.copyWith(
          selectedPickupLocation: point,
          selectedDropoffLocation: null,
        ),
      );
    } else {
      emit(state.copyWith(selectedPickupLocation: point));
    }
  }

  void selectDropoffLocation(SharedRideRoutePointDetail? point) {
    emit(state.copyWith(selectedDropoffLocation: point));
  }

  Future<void> _loadDetail() async {
    try {
      final detail = await _getSharedRideDetailUseCase(
        detailApi: state.detailApi,
      );

      SharedRideRoutePointDetail? defaultPickup;
      SharedRideRoutePointDetail? defaultDropoff;

      if (detail.route != null) {
        final sortedPoints = detail.route!.routePoints.toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));

        for (final p in sortedPoints) {
          if (defaultPickup == null && (p.stopType == 1 || p.stopType == 2)) {
            defaultPickup = p;
          }
          if (p.stopType == 4 || p.stopType == 5) {
            defaultDropoff = p;
          }
        }
        defaultPickup ??= sortedPoints.isNotEmpty ? sortedPoints.first : null;
        defaultDropoff ??= sortedPoints.isNotEmpty ? sortedPoints.last : null;

        if (defaultPickup != null &&
            defaultDropoff != null &&
            defaultDropoff.sequence <= defaultPickup.sequence) {
          defaultDropoff = null;
        }
      }

      emit(
        state.copyWith(
          status: SharedRideDetailStatus.success,
          detail: detail,
          selectedPickupLocation: defaultPickup,
          selectedDropoffLocation: defaultDropoff,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SharedRideDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
