import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_vehicle_usecase.dart';
import '../../domain/usecases/get_my_vehicles_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';
import 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit(
    this._getMyVehiclesUseCase,
    this._createVehicleUseCase,
    this._updateVehicleUseCase,
  ) : super(const VehicleState());

  final GetMyVehiclesUseCase _getMyVehiclesUseCase;
  final CreateVehicleUseCase _createVehicleUseCase;
  final UpdateVehicleUseCase _updateVehicleUseCase;

  Future<void> loadMyVehicles() async {
    emit(
      state.copyWith(
        status: VehicleStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final vehicles = await _getMyVehiclesUseCase();
      emit(
        state.copyWith(
          status: vehicles.isEmpty
              ? VehicleStatus.empty
              : VehicleStatus.success,
          vehicles: vehicles,
          errorMessage: null,
          successMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VehicleStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> createVehicle({
    required String plateNumber,
    required String brand,
    required int seatCapacity,
    required int vehicleType,
    required String urlImagePath,
    required String registrationDocumentUrlPath,
  }) async {
    emit(
      state.copyWith(
        status: VehicleStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      await _createVehicleUseCase(
        CreateVehicleParams(
          plateNumber: plateNumber,
          brand: brand,
          seatCapacity: seatCapacity,
          vehicleType: vehicleType,
          urlImagePath: urlImagePath,
          registrationDocumentUrlPath: registrationDocumentUrlPath,
        ),
      );
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Thêm mới xe thành công',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VehicleStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> updateVehicle({
    required String id,
    String? plateNumber,
    String? brand,
    int? seatCapacity,
    int? vehicleType,
    String? urlImagePath,
    String? registrationDocumentUrlPath,
  }) async {
    emit(
      state.copyWith(
        status: VehicleStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      await _updateVehicleUseCase(
        UpdateVehicleParams(
          id: id,
          plateNumber: plateNumber,
          brand: brand,
          seatCapacity: seatCapacity,
          vehicleType: vehicleType,
          urlImagePath: urlImagePath,
          registrationDocumentUrlPath: registrationDocumentUrlPath,
        ),
      );
      emit(
        state.copyWith(
          status: VehicleStatus.success,
          successMessage: 'Cập nhật xe thành công, thông tin sẽ được duyệt lại',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VehicleStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }
}
