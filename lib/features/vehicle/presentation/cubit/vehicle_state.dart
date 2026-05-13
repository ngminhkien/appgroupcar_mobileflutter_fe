import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle.dart';

enum VehicleStatus { initial, loading, success, empty, submitting, failure }

class VehicleState extends Equatable {
  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicles = const [],
    this.errorMessage,
    this.successMessage,
  });

  final VehicleStatus status;
  final List<Vehicle> vehicles;
  final String? errorMessage;
  final String? successMessage;

  bool get isLoading => status == VehicleStatus.loading;
  bool get isSubmitting => status == VehicleStatus.submitting;

  VehicleState copyWith({
    VehicleStatus? status,
    List<Vehicle>? vehicles,
    String? errorMessage,
    String? successMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, errorMessage, successMessage];
}
