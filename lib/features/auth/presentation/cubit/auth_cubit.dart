import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> checkAuth() async {
    final tokens = await _authRepository.getSavedTokens();
    final role = tokens?.role;
    if (role == null || role.isEmpty) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    emit(AuthState(status: AuthStatus.authenticated, role: role));
  }

  void setAuthenticated({required String role}) {
    emit(AuthState(status: AuthStatus.authenticated, role: role));
  }

  void setUnauthenticated() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<bool> refreshSession() async {
    try {
      final tokens = await _authRepository.refreshTokens();
      final role = tokens?.role?.toUpperCase();
      final isAllowedRole =
          role == 'USER' ||
          role == 'DRIVER' ||
          role == 'COMPANY' ||
          role == 'STAFF_COMPANY';
      if (tokens != null && isAllowedRole) {
        emit(AuthState(status: AuthStatus.authenticated, role: role));
        return true;
      }
      await _authRepository.clearTokens();
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return false;
    } catch (_) {
      await _authRepository.clearTokens();
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
