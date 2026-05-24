import 'package:equatable/equatable.dart';

import '../entities/staff_seat_map.dart';
import '../repositories/staff_seat_checkin_repository.dart';

class GetStaffShowtimeSeatMapParams extends Equatable {
  const GetStaffShowtimeSeatMapParams({required this.showtimeId});

  final String showtimeId;

  @override
  List<Object?> get props => [showtimeId];
}

class GetStaffShowtimeSeatMapUseCase {
  GetStaffShowtimeSeatMapUseCase(this._repository);

  final StaffSeatCheckinRepository _repository;

  Future<StaffSeatMap> call(GetStaffShowtimeSeatMapParams params) {
    return _repository.getSeatMap(showtimeId: params.showtimeId);
  }
}
