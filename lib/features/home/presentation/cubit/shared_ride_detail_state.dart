import 'package:equatable/equatable.dart';

import '../../domain/entities/shared_ride_detail.dart';

enum SharedRideDetailStatus { initial, loading, success, failure, unsupported }

const Object _sharedRideUnset = Object();

class SharedRideDetailState extends Equatable {
  const SharedRideDetailState({
    this.status = SharedRideDetailStatus.initial,
    this.tripId = '',
    this.serviceCode = '',
    this.detailApi = '',
    this.detail,
    this.errorMessage,
    this.selectedPickupLocation,
    this.selectedDropoffLocation,
  });

  final SharedRideDetailStatus status;
  final String tripId;
  final String serviceCode;
  final String detailApi;
  final SharedRideDetail? detail;
  final String? errorMessage;
  final SharedRideRoutePointDetail? selectedPickupLocation;
  final SharedRideRoutePointDetail? selectedDropoffLocation;

  SharedRideDetailState copyWith({
    SharedRideDetailStatus? status,
    String? tripId,
    String? serviceCode,
    String? detailApi,
    Object? detail = _sharedRideUnset,
    String? errorMessage,
    Object? selectedPickupLocation = _sharedRideUnset,
    Object? selectedDropoffLocation = _sharedRideUnset,
  }) {
    return SharedRideDetailState(
      status: status ?? this.status,
      tripId: tripId ?? this.tripId,
      serviceCode: serviceCode ?? this.serviceCode,
      detailApi: detailApi ?? this.detailApi,
      detail: detail == _sharedRideUnset
          ? this.detail
          : detail as SharedRideDetail?,
      errorMessage: errorMessage,
      selectedPickupLocation: selectedPickupLocation == _sharedRideUnset
          ? this.selectedPickupLocation
          : selectedPickupLocation as SharedRideRoutePointDetail?,
      selectedDropoffLocation: selectedDropoffLocation == _sharedRideUnset
          ? this.selectedDropoffLocation
          : selectedDropoffLocation as SharedRideRoutePointDetail?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tripId,
    serviceCode,
    detailApi,
    detail,
    errorMessage,
    selectedPickupLocation,
    selectedDropoffLocation,
  ];
}
