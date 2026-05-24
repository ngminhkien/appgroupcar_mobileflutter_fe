import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/company/presentation/pages/company_apply_screen.dart';
import '../../features/driver/presentation/pages/driver_apply_screen.dart';
import '../../features/home/presentation/models/trip_detail_navigation_args.dart';
import '../../features/home/presentation/models/bus_seat_selection_args.dart';
import '../../features/home/presentation/models/trip_search_screen_args.dart';
import '../../features/home/presentation/pages/bus_seat_selection_screen.dart';
import '../../features/home/presentation/pages/bus_trip_detail_screen.dart';
import '../../features/home/presentation/pages/search_results_screen.dart';
import '../../features/home/presentation/pages/velocity_transit_home_screen.dart';
import '../../features/intro/presentation/pages/intro_screen.dart';
import '../../features/location/presentation/models/location_search_screen_args.dart';
import '../../features/location/presentation/pages/location_search_screen.dart';
import '../../features/offers/presentation/pages/offers_screen.dart';
import '../../features/profile/presentation/pages/my_information_screen.dart';
import '../../features/profile/presentation/pages/profile_placeholder_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/support/presentation/pages/support_screen.dart';
import '../../features/tickets/presentation/pages/my_tickets_screen.dart';
import '../../features/tickets/presentation/pages/ticket_detail_screen.dart';
import '../../features/trips/presentation/pages/create_trip_screen.dart';
import '../../features/trips/presentation/pages/my_trips_screen.dart';
import '../../features/vehicle/domain/entities/vehicle.dart';
import '../../features/vehicle/presentation/pages/vehicle_form_screen.dart';
import '../../features/vehicle/presentation/pages/vehicle_list_screen.dart';
import '../../features/staff_seat_checkin/presentation/pages/staff_seat_checkin_detail_screen.dart';
import '../../features/staff_seat_checkin/presentation/pages/staff_showtime_checkin_screen.dart';

class AppRouter {
  static GoRouter createRouter(
    GlobalKey<NavigatorState> navigatorKey,
    AuthCubit authCubit,
  ) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/intro',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final status = authCubit.state.status;
        if (status == AuthStatus.unknown) {
          return null;
        }
        final location = state.uri.path;
        final role = authCubit.state.role?.toUpperCase();
        final isStaffCompany = role == 'STAFF_COMPANY';
        final isAuthRoute =
            location == '/login' ||
            location == '/register' ||
            location == '/forgot_password';
        final isIntro = location == '/intro';
        final isPublicCompanyRoute = location == '/company/apply';
        if (status == AuthStatus.unauthenticated) {
          if (isAuthRoute || isIntro || isPublicCompanyRoute) {
            return null;
          }
          return '/login';
        }
        if (status == AuthStatus.authenticated) {
          if (isStaffCompany) {
            final isStaffRoute = location.startsWith('/staff/check-in');
            final isStaffAllowedRoute =
                isStaffRoute ||
                location.startsWith('/profile') ||
                location == '/support';
            if (isAuthRoute || isIntro || location == '/home') {
              return '/staff/check-in';
            }
            if (!isStaffAllowedRoute) {
              return '/staff/check-in';
            }
            return null;
          }

          if (location.startsWith('/staff/check-in')) {
            return '/home';
          }
          if (isAuthRoute || isIntro) {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/intro',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgot_password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/company/apply',
          builder: (context, state) => const CompanyApplyScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const VelocityTransitHomeScreen(),
        ),
        GoRoute(
          path: '/home_search',
          builder: (context, state) => const VelocityTransitHomeScreen(),
        ),
        GoRoute(
          path: '/staff/check-in',
          builder: (context, state) => const StaffShowtimeCheckinScreen(),
        ),
        GoRoute(
          path: '/staff/check-in/detail',
          builder: (context, state) =>
              buildStaffSeatCheckinDetailRouteView(state.extra),
        ),
        GoRoute(
          path: '/search_results',
          builder: (context, state) {
            final args = state.extra is TripSearchScreenArgs
                ? state.extra! as TripSearchScreenArgs
                : null;
            return SearchResultsScreen(args: args);
          },
        ),
        GoRoute(
          path: '/location_search',
          builder: (context, state) {
            final args = state.extra is LocationSearchScreenArgs
                ? state.extra! as LocationSearchScreenArgs
                : const LocationSearchScreenArgs();
            return LocationSearchScreen(args: args);
          },
        ),
        GoRoute(
          path: '/search_results/detail',
          builder: (context, state) {
            final args = state.extra is TripDetailNavigationArgs
                ? state.extra! as TripDetailNavigationArgs
                : const TripDetailNavigationArgs(
                    tripId: '',
                    serviceCode: '',
                    detailApi: '',
                  );
            return BusTripDetailScreen(args: args);
          },
        ),
        GoRoute(
          path: '/search_results/detail/seats',
          builder: (context, state) {
            final args = state.extra is BusSeatSelectionArgs
                ? state.extra! as BusSeatSelectionArgs
                : null;
            if (args == null) {
              return const _MissingSeatSelectionArgsScreen();
            }
            return BusSeatSelectionScreen(args: args);
          },
        ),
        GoRoute(
          path: '/my_trips',
          builder: (context, state) => const MyTripsScreen(),
        ),
        GoRoute(
          path: '/create_trip',
          builder: (context, state) => const CreateTripScreen(),
        ),
        GoRoute(
          path: '/my_tickets',
          builder: (context, state) => const MyTicketsScreen(),
        ),
        GoRoute(
          path: '/my_tickets/:id',
          builder: (context, state) =>
              TicketDetailScreen(bookingId: state.pathParameters['id'] ?? ''),
        ),
        GoRoute(
          path: '/offers',
          builder: (context, state) => const OffersScreen(),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/me',
          builder: (context, state) => const MyInformationScreen(),
        ),
        GoRoute(
          path: '/profile/wallet',
          builder: (context, state) => const ProfilePlaceholderScreen(
            title: 'Ví',
            message: 'Chức năng ví sẽ được bổ sung ở bước tiếp theo.',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        GoRoute(
          path: '/profile/settings',
          builder: (context, state) => const ProfilePlaceholderScreen(
            title: 'Cài đặt',
            message: 'Các tùy chọn cài đặt tài khoản sẽ được bổ sung sau.',
            icon: Icons.settings_outlined,
          ),
        ),
        GoRoute(
          path: '/profile/driver/apply',
          builder: (context, state) => const DriverApplyScreen(),
        ),
        GoRoute(
          path: '/profile/driver/vehicles',
          builder: (context, state) => const VehicleListScreen(),
        ),
        GoRoute(
          path: '/profile/driver/vehicles/create',
          builder: (context, state) => const VehicleCreateScreen(),
        ),
        GoRoute(
          path: '/profile/driver/vehicles/:id/edit',
          builder: (context, state) {
            final initialVehicle = state.extra is Vehicle
                ? state.extra! as Vehicle
                : null;
            return VehicleEditScreen(
              id: state.pathParameters['id'] ?? '',
              initialVehicle: initialVehicle,
            );
          },
        ),
        GoRoute(
          path: '/profile/company/apply',
          builder: (context, state) => const CompanyApplyScreen(),
        ),
      ],
    );
  }
}

class _MissingSeatSelectionArgsScreen extends StatelessWidget {
  const _MissingSeatSelectionArgsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chon ghe'),
      ),
      body: const Center(
        child: Text('Khong co du lieu chon ghe. Vui long quay lai.'),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
