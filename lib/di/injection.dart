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
import '../features/company/data/datasources/company_remote_data_source.dart';
import '../features/company/data/repositories/company_repository_impl.dart';
import '../features/company/domain/repositories/company_repository.dart';
import '../features/company/domain/usecases/check_company_status_usecase.dart';
import '../features/company/domain/usecases/create_company_usecase.dart';
import '../features/company/domain/usecases/update_company_usecase.dart';
import '../features/company/presentation/cubit/company_apply_cubit.dart';
import '../features/driver/data/datasources/driver_remote_data_source.dart';
import '../features/driver/data/repositories/driver_repository_impl.dart';
import '../features/driver/domain/repositories/driver_repository.dart';
import '../features/driver/domain/usecases/create_driver_usecase.dart';
import '../features/driver/domain/usecases/get_current_driver_profile_usecase.dart';
import '../features/driver/domain/usecases/update_driver_usecase.dart';
import '../features/driver/presentation/cubit/driver_apply_cubit.dart';
import '../features/home/data/datasources/home_search_local_data_source.dart';
import '../features/home/data/datasources/trip_search_remote_data_source.dart';
import '../features/home/data/datasources/bus_trip_remote_data_source.dart';
import '../features/home/data/repositories/bus_trip_repository_impl.dart';
import '../features/home/data/repositories/trip_search_repository_impl.dart';
import '../features/home/domain/repositories/bus_trip_repository.dart';
import '../features/home/domain/repositories/trip_search_repository.dart';
import '../features/home/domain/usecases/get_bus_seat_map_usecase.dart';
import '../features/home/domain/usecases/get_bus_showtime_detail_usecase.dart';
import '../features/home/domain/usecases/search_trips_usecase.dart';
import '../features/home/presentation/cubit/bus_seat_selection_cubit.dart';
import '../features/home/presentation/cubit/bus_trip_detail_cubit.dart';
import '../features/home/presentation/cubit/home_search_cubit.dart';
import '../features/home/presentation/cubit/trip_search_cubit.dart';
import '../features/location/data/datasources/location_remote_data_source.dart';
import '../features/location/data/repositories/location_repository_impl.dart';
import '../features/location/domain/repositories/location_repository.dart';
import '../features/location/domain/usecases/search_locations_usecase.dart';
import '../features/location/presentation/cubit/location_search_cubit.dart';
import '../features/staff_seat_checkin/data/datasources/staff_seat_checkin_remote_data_source.dart';
import '../features/staff_seat_checkin/data/repositories/staff_seat_checkin_repository_impl.dart';
import '../features/staff_seat_checkin/domain/repositories/staff_seat_checkin_repository.dart';
import '../features/staff_seat_checkin/domain/usecases/get_staff_manual_checkin_info_usecase.dart';
import '../features/staff_seat_checkin/domain/usecases/get_staff_showtime_seat_map_usecase.dart';
import '../features/staff_seat_checkin/domain/usecases/get_upcoming_staff_showtimes_usecase.dart';
import '../features/staff_seat_checkin/domain/usecases/update_staff_seat_status_usecase.dart';
import '../features/staff_seat_checkin/presentation/cubit/staff_manual_checkin_cubit.dart';
import '../features/staff_seat_checkin/presentation/cubit/staff_showtime_list_cubit.dart';
import '../features/tickets/data/datasources/bus_booking_remote_data_source.dart';
import '../features/tickets/data/repositories/bus_booking_repository_impl.dart';
import '../features/tickets/domain/repositories/bus_booking_repository.dart';
import '../features/tickets/domain/usecases/create_bus_booking_usecase.dart';
import '../features/tickets/domain/usecases/get_bus_booking_detail_usecase.dart';
import '../features/tickets/domain/usecases/get_my_bus_bookings_usecase.dart';
import '../features/tickets/presentation/cubit/bus_booking_action_cubit.dart';
import '../features/tickets/presentation/cubit/my_tickets_cubit.dart';
import '../features/tickets/presentation/cubit/ticket_detail_cubit.dart';
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

  // Features - Company
  sl.registerLazySingleton(() => CompanyRemoteDataSource(sl()));
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CreateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => CheckCompanyStatusUseCase(sl()));
  sl.registerFactory(() => CompanyApplyCubit(sl(), sl(), sl()));

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
  sl.registerLazySingleton(() => HomeSearchLocalDataSource(sl()));
  sl.registerLazySingleton(() => TripSearchRemoteDataSource(sl()));
  sl.registerLazySingleton(() => BusTripRemoteDataSource(sl()));
  sl.registerLazySingleton<BusTripRepository>(
    () => BusTripRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetBusShowtimeDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetBusSeatMapUseCase(sl()));
  sl.registerLazySingleton<TripSearchRepository>(
    () => TripSearchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SearchTripsUseCase(sl()));
  sl.registerFactory(() => HomeSearchCubit(sl()));
  sl.registerFactory(() => TripSearchCubit(sl()));
  sl.registerFactory(() => BusTripDetailCubit(sl()));
  sl.registerFactory(() => BusSeatSelectionCubit(sl()));

  // Features - Tickets
  sl.registerLazySingleton(() => BusBookingRemoteDataSource(sl()));
  sl.registerLazySingleton<BusBookingRepository>(
    () =>
        BusBookingRepositoryImpl(remoteDataSource: sl(), authRepository: sl()),
  );
  sl.registerLazySingleton(() => CreateBusBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBusBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBusBookingDetailUseCase(sl()));
  sl.registerFactory(() => BusBookingActionCubit(sl()));
  sl.registerFactory(() => MyTicketsCubit(sl()));
  sl.registerFactory(() => TicketDetailCubit(sl()));

  // Features - Location
  sl.registerLazySingleton(() => LocationRemoteDataSource(sl()));
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SearchLocationsUseCase(sl()));
  sl.registerFactory(() => LocationSearchCubit(sl()));

  // Features - Staff Seat Check-in
  sl.registerLazySingleton(() => StaffSeatCheckinRemoteDataSource(sl()));
  sl.registerLazySingleton<StaffSeatCheckinRepository>(
    () => StaffSeatCheckinRepositoryImpl(
      remoteDataSource: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetUpcomingStaffShowtimesUseCase(sl()));
  sl.registerLazySingleton(() => GetStaffShowtimeSeatMapUseCase(sl()));
  sl.registerLazySingleton(() => GetStaffManualCheckinInfoUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStaffSeatStatusUseCase(sl()));
  sl.registerFactory(() => StaffShowtimeListCubit(sl()));
  sl.registerFactory(() => StaffManualCheckinCubit(sl()));

  // Features - Trips
  // sl.registerFactory(() => TripsBloc(sl()));
}
