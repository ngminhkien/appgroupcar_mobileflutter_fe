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
  });

  final BusTripDetailStatus status;
  final String tripId;
  final String serviceCode;
  final String detailApi;
  final BusShowtimeDetail? detail;
  final List<String> selectedSeats;
  final String? errorMessage;

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
  ];
}
