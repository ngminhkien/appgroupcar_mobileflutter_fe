import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_seat_map.dart';
import '../../domain/entities/staff_seat_status_history.dart';
import '../../domain/entities/staff_upcoming_showtime.dart';

enum StaffSeatMapStatus { initial, loading, success, failure }

enum StaffSeatCheckinActionStatus { initial, loading, success, failure }

const Object _staffDetailUnset = Object();

class StaffSeatCheckinDetailState extends Equatable {
  const StaffSeatCheckinDetailState({
    required this.showtime,
    this.seatMapStatus = StaffSeatMapStatus.initial,
    this.actionStatus = StaffSeatCheckinActionStatus.initial,
    this.seatMap,
    this.selectedSeats = const [],
    this.newStatus = 1,
    this.reason = 'Khach mua truc tiep',
    this.latestUpdates = const [],
    this.latestUpdatedAt,
    this.seatMapErrorMessage,
    this.actionErrorMessage,
  });

  final StaffUpcomingShowtime showtime;
  final StaffSeatMapStatus seatMapStatus;
  final StaffSeatCheckinActionStatus actionStatus;
  final StaffSeatMap? seatMap;
  final List<String> selectedSeats;
  final int newStatus;
  final String reason;
  final List<StaffSeatStatusHistory> latestUpdates;
  final DateTime? latestUpdatedAt;
  final String? seatMapErrorMessage;
  final String? actionErrorMessage;

  bool get isSubmitting => actionStatus == StaffSeatCheckinActionStatus.loading;

  bool get canSubmit =>
      selectedSeats.isNotEmpty &&
      seatMapStatus == StaffSeatMapStatus.success &&
      !isSubmitting;

  StaffSeatCheckinDetailState copyWith({
    StaffSeatMapStatus? seatMapStatus,
    StaffSeatCheckinActionStatus? actionStatus,
    Object? seatMap = _staffDetailUnset,
    List<String>? selectedSeats,
    int? newStatus,
    String? reason,
    List<StaffSeatStatusHistory>? latestUpdates,
    Object? latestUpdatedAt = _staffDetailUnset,
    Object? seatMapErrorMessage = _staffDetailUnset,
    Object? actionErrorMessage = _staffDetailUnset,
  }) {
    return StaffSeatCheckinDetailState(
      showtime: showtime,
      seatMapStatus: seatMapStatus ?? this.seatMapStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      seatMap: seatMap == _staffDetailUnset
          ? this.seatMap
          : seatMap as StaffSeatMap?,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      newStatus: newStatus ?? this.newStatus,
      reason: reason ?? this.reason,
      latestUpdates: latestUpdates ?? this.latestUpdates,
      latestUpdatedAt: latestUpdatedAt == _staffDetailUnset
          ? this.latestUpdatedAt
          : latestUpdatedAt as DateTime?,
      seatMapErrorMessage: seatMapErrorMessage == _staffDetailUnset
          ? this.seatMapErrorMessage
          : seatMapErrorMessage as String?,
      actionErrorMessage: actionErrorMessage == _staffDetailUnset
          ? this.actionErrorMessage
          : actionErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    showtime,
    seatMapStatus,
    actionStatus,
    seatMap,
    selectedSeats,
    newStatus,
    reason,
    latestUpdates,
    latestUpdatedAt,
    seatMapErrorMessage,
    actionErrorMessage,
  ];
}
