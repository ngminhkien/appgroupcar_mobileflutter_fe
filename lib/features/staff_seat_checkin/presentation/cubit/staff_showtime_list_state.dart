import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_upcoming_showtime.dart';

enum StaffShowtimeListStatus { initial, loading, success, failure }

const Object _staffListUnset = Object();

class StaffShowtimeListState extends Equatable {
  StaffShowtimeListState({
    this.status = StaffShowtimeListStatus.initial,
    DateTime? fromDate,
    this.result,
    this.errorMessage,
  }) : fromDate = _dateOnly(fromDate ?? DateTime.now());

  final StaffShowtimeListStatus status;
  final DateTime fromDate;
  final StaffUpcomingShowtimeResult? result;
  final String? errorMessage;

  List<StaffUpcomingShowtime> get items => result?.items ?? const [];

  bool get isEmpty =>
      status == StaffShowtimeListStatus.success && items.isEmpty;

  StaffShowtimeListState copyWith({
    StaffShowtimeListStatus? status,
    DateTime? fromDate,
    Object? result = _staffListUnset,
    Object? errorMessage = _staffListUnset,
  }) {
    return StaffShowtimeListState(
      status: status ?? this.status,
      fromDate: _dateOnly(fromDate ?? this.fromDate),
      result: result == _staffListUnset
          ? this.result
          : result as StaffUpcomingShowtimeResult?,
      errorMessage: errorMessage == _staffListUnset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, fromDate, result, errorMessage];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
