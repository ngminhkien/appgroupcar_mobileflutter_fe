import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../core/network/unauthorized_interceptor.dart';
import '../core/storage/auth_token_storage.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/presentation/bloc/login_bloc.dart';
import '../features/auth/presentation/bloc/register_bloc.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/driver/data/datasources/driver_remote_data_source.dart';
import '../features/driver/data/repositories/driver_repository_impl.dart';
import '../features/driver/domain/repositories/driver_repository.dart';
import '../features/driver/domain/usecases/create_driver_usecase.dart';
import '../features/driver/domain/usecases/get_current_driver_profile_usecase.dart';
import '../features/driver/domain/usecases/update_driver_usecase.dart';
import '../features/driver/presentation/cubit/driver_apply_cubit.dart';
import '../features/user/data/datasources/user_remote_data_source.dart';
import '../features/user/data/repositories/user_repository_impl.dart';
import '../features/user/domain/repositories/user_repository.dart';
import '../features/user/domain/usecases/get_user_profile_usecase.dart';
import '../features/user/presentation/bloc/user_profile_cubit.dart';
import '../features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import '../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../features/vehicle/domain/repositories/vehicle_repository.dart';
import '../features/vehicle/domain/usecases/create_vehicle_usecase.dart';
import '../features/vehicle/domain/usecases/get_my_vehicles_usecase.dart';
import '../features/vehicle/domain/usecases/update_vehicle_usecase.dart';
import '../features/vehicle/presentation/cubit/vehicle_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => AuthTokenStorage(sl()));

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  sl.registerLazySingleton(() => dio);

  // Features - Auth
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerFactory(() => LoginBloc(sl()));
  sl.registerFactory(() => RegisterBloc(sl()));
  sl.registerLazySingleton(() => AuthCubit(sl()));
  sl<Dio>().interceptors.add(
    UnauthorizedInterceptor(authCubit: sl(), tokenStorage: sl(), dio: sl()),
  );

  // Features - User
  sl.registerLazySingleton(() => UserRemoteDataSource(sl()));
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), authRepository: sl()),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerFactory(() => UserProfileCubit(sl(), sl()));

  // Features - Driver
  sl.registerLazySingleton(() => DriverRemoteDataSource(sl()));
  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      remoteDataSource: sl(),
      authRepository: sl(),
      userRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => CreateDriverUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentDriverProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDriverUseCase(sl()));
  sl.registerFactory(() => DriverApplyCubit(sl(), sl(), sl()));

  // Features - Vehicle
  sl.registerLazySingleton(() => VehicleRemoteDataSource(sl()));
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(remoteDataSource: sl(), authRepository: sl()),
  );
  sl.registerLazySingleton(() => GetMyVehiclesUseCase(sl()));
  sl.registerLazySingleton(() => CreateVehicleUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVehicleUseCase(sl()));
  sl.registerFactory(() => VehicleCubit(sl(), sl(), sl()));

  // Features - Home
  // sl.registerFactory(() => HomeBloc(sl()));

  // Features - Location
  // sl.registerFactory(() => LocationBloc(sl()));

  // Features - Trips
  // sl.registerFactory(() => TripsBloc(sl()));
}
