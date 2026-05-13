import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._loginUseCase) : super(const LoginState()) {
    on<LoginRequested>(_onLoginRequested);
  }

  final LoginUseCase _loginUseCase;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final result = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      emit(state.copyWith(status: LoginStatus.success, role: result.role));
    } catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
