import 'package:equatable/equatable.dart';

import '../entities/staff_manual_checkin_info.dart';
import '../repositories/staff_seat_checkin_repository.dart';

class GetStaffManualCheckinInfoParams extends Equatable {
  const GetStaffManualCheckinInfoParams({
    required this.showtimeId,
    required this.seatNumber,
  });

  final String showtimeId;
  final String seatNumber;

  @override
  List<Object?> get props => [showtimeId, seatNumber];
}

class GetStaffManualCheckinInfoUseCase {
  GetStaffManualCheckinInfoUseCase(this._repository);

  final StaffSeatCheckinRepository _repository;

  Future<StaffManualCheckinInfo> call(GetStaffManualCheckinInfoParams params) {
    return _repository.getManualCheckinInfo(
      showtimeId: params.showtimeId,
      seatNumber: params.seatNumber,
    );
  }
}
