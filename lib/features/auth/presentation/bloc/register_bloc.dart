import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._registerUseCase) : super(const RegisterState()) {
    on<RegisterAvatarChanged>(_onRegisterAvatarChanged);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final RegisterUseCase _registerUseCase;

  void _onRegisterAvatarChanged(
    RegisterAvatarChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        avatarPath: event.avatarPath,
        status: RegisterStatus.initial,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        avatarPath: event.avatarPath,
        status: RegisterStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _registerUseCase(
        RegisterParams(
          fullName: event.fullName,
          email: event.email,
          phoneNumber: event.phoneNumber,
          password: event.password,
          avatarPath: event.avatarPath,
        ),
      );
      emit(
        state.copyWith(
          status: RegisterStatus.success,
          successMessage: 'Đăng ký thành công',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }
}
