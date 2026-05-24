import 'package:equatable/equatable.dart';

import '../entities/staff_seat_status_history.dart';
import '../repositories/staff_seat_checkin_repository.dart';

class UpdateStaffSeatStatusParams extends Equatable {
  const UpdateStaffSeatStatusParams({
    required this.showtimeId,
    required this.seatNumbers,
    this.newStatus = 1,
    this.reason = 'Khach mua truc tiep',
  });

  final String showtimeId;
  final List<String> seatNumbers;
  final int newStatus;
  final String reason;

  @override
  List<Object?> get props => [showtimeId, seatNumbers, newStatus, reason];
}

class UpdateStaffSeatStatusUseCase {
  UpdateStaffSeatStatusUseCase(this._repository);

  final StaffSeatCheckinRepository _repository;

  Future<List<StaffSeatStatusHistory>> call(
    UpdateStaffSeatStatusParams params,
  ) {
    return _repository.updateSeatStatus(
      showtimeId: params.showtimeId,
      seatNumbers: params.seatNumbers,
      newStatus: params.newStatus,
      reason: params.reason,
    );
  }
}
