import 'package:equatable/equatable.dart';

import '../../domain/entities/bus_showtime_detail.dart';

enum BusTripDetailStatus { initial, loading, success, failure, unsupported }

const Object _busTripUnset = Object();

class BusTripDetailState extends Equatable {
  const BusTripDetailState({
    this.status = BusTripDetailStatus.initial,
    this.tripId = '',
    this.serviceCode = '',
    this.detailApi = '',
    this.detail,
    this.selectedSeats = const [],
    this.errorMessage,
    this.selectedPickupLocation,
    this.selectedDropoffLocation,
  });

  final BusTripDetailStatus status;
  final String tripId;
  final String serviceCode;
  final String detailApi;
  final BusShowtimeDetail? detail;
  final List<String> selectedSeats;
  final String? errorMessage;
  final BusRoutePointDetail? selectedPickupLocation;
  final BusRoutePointDetail? selectedDropoffLocation;

  bool get isBusService => serviceCode.trim().toUpperCase() == 'BUS';

  double get totalSelectedPrice {
    final price = detail?.price ?? 0;
    return price * selectedSeats.length;
  }

  BusTripDetailState copyWith({
    BusTripDetailStatus? status,
    String? tripId,
    String? serviceCode,
    String? detailApi,
    Object? detail = _busTripUnset,
    List<String>? selectedSeats,
    String? errorMessage,
    Object? selectedPickupLocation = _busTripUnset,
    Object? selectedDropoffLocation = _busTripUnset,
  }) {
    return BusTripDetailState(
      status: status ?? this.status,
      tripId: tripId ?? this.tripId,
      serviceCode: serviceCode ?? this.serviceCode,
      detailApi: detailApi ?? this.detailApi,
      detail: detail == _busTripUnset
          ? this.detail
          : detail as BusShowtimeDetail?,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      errorMessage: errorMessage,
      selectedPickupLocation: selectedPickupLocation == _busTripUnset
          ? this.selectedPickupLocation
          : selectedPickupLocation as BusRoutePointDetail?,
      selectedDropoffLocation: selectedDropoffLocation == _busTripUnset
          ? this.selectedDropoffLocation
          : selectedDropoffLocation as BusRoutePointDetail?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tripId,
    serviceCode,
    detailApi,
    detail,
    selectedSeats,
    errorMessage,
    selectedPickupLocation,
    selectedDropoffLocation,
  ];
}
