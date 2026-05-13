import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit(this._getUserProfileUseCase, this._logoutUseCase)
    : super(const UserProfileState());

  final GetUserProfileUseCase _getUserProfileUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: UserProfileStatus.loading, errorMessage: null));
    try {
      final profile = await _getUserProfileUseCase();
      emit(state.copyWith(status: UserProfileStatus.success, profile: profile));
    } catch (error) {
      emit(
        state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> logout() async {
    emit(state.copyWith(isLoggingOut: true, errorMessage: null));
    try {
      await _logoutUseCase();
      emit(state.copyWith(isLoggingOut: false));
      return true;
    } catch (error) {
      emit(state.copyWith(isLoggingOut: false, errorMessage: error.toString()));
      return false;
    }
  }
}
