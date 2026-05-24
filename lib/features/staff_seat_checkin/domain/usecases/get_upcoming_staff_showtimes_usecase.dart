import 'package:equatable/equatable.dart';

import '../entities/staff_upcoming_showtime.dart';
import '../repositories/staff_seat_checkin_repository.dart';

class GetUpcomingStaffShowtimesParams extends Equatable {
  const GetUpcomingStaffShowtimesParams({this.fromDate});

  final DateTime? fromDate;

  @override
  List<Object?> get props => [fromDate];
}

class GetUpcomingStaffShowtimesUseCase {
  GetUpcomingStaffShowtimesUseCase(this._repository);

  final StaffSeatCheckinRepository _repository;

  Future<StaffUpcomingShowtimeResult> call(
    GetUpcomingStaffShowtimesParams params,
  ) {
    return _repository.getUpcomingShowtimes(fromDate: params.fromDate);
  }
}
