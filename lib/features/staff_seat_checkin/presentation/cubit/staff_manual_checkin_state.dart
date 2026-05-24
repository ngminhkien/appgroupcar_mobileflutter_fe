import 'package:equatable/equatable.dart';

import '../../domain/entities/staff_manual_checkin_info.dart';

enum StaffManualCheckinStatus { initial, loading, success, failure }

const Object _manualUnset = Object();

class StaffManualCheckinState extends Equatable {
  const StaffManualCheckinState({
    this.status = StaffManualCheckinStatus.initial,
    this.data,
    this.errorMessage,
    this.lastSeatNumber = '',
  });

  final StaffManualCheckinStatus status;
  final StaffManualCheckinInfo? data;
  final String? errorMessage;
  final String lastSeatNumber;

  StaffManualCheckinState copyWith({
    StaffManualCheckinStatus? status,
    Object? data = _manualUnset,
    Object? errorMessage = _manualUnset,
    String? lastSeatNumber,
  }) {
    return StaffManualCheckinState(
      status: status ?? this.status,
      data: data == _manualUnset ? this.data : data as StaffManualCheckinInfo?,
      errorMessage: errorMessage == _manualUnset
          ? this.errorMessage
          : errorMessage as String?,
      lastSeatNumber: lastSeatNumber ?? this.lastSeatNumber,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, lastSeatNumber];
}
