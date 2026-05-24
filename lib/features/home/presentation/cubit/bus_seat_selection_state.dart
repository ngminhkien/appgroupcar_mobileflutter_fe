import 'package:equatable/equatable.dart';

import '../../domain/entities/bus_seat_map.dart';
import '../../domain/entities/bus_showtime_detail.dart';

enum BusSeatSelectionStatus { initial, loading, success, failure }

const Object _seatSelectionUnset = Object();

class BusSeatSelectionState extends Equatable {
  const BusSeatSelectionState({
    this.status = BusSeatSelectionStatus.initial,
    this.detail,
    this.seatMap,
    this.selectedSeats = const [],
    this.errorMessage,
  });

  final BusSeatSelectionStatus status;
  final BusShowtimeDetail? detail;
  final BusSeatMap? seatMap;
  final List<String> selectedSeats;
  final String? errorMessage;

  double get totalSelectedPrice {
    final price = detail?.price ?? 0;
    return price * selectedSeats.length;
  }

  BusSeatSelectionState copyWith({
    BusSeatSelectionStatus? status,
    Object? detail = _seatSelectionUnset,
    Object? seatMap = _seatSelectionUnset,
    List<String>? selectedSeats,
    Object? errorMessage = _seatSelectionUnset,
  }) {
    return BusSeatSelectionState(
      status: status ?? this.status,
      detail: detail == _seatSelectionUnset
          ? this.detail
          : detail as BusShowtimeDetail?,
      seatMap: seatMap == _seatSelectionUnset
          ? this.seatMap
          : seatMap as BusSeatMap?,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      errorMessage: errorMessage == _seatSelectionUnset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    detail,
    seatMap,
    selectedSeats,
    errorMessage,
  ];
}
