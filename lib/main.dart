import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'di/injection.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  final authCubit = di.sl<AuthCubit>();
  await authCubit.checkAuth();
  final appRouter = AppRouter.createRouter(navigatorKey, authCubit);
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    _showFriendlyErrorDialog(details.exception);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Async error: $error');
      debugPrint('$stack');
    }
    _showFriendlyErrorDialog(error);
    return true;
  };
  runApp(
    BlocProvider.value(
      value: authCubit,
      child: MyApp(router: appRouter),
    ),
  );
}

void _showFriendlyErrorDialog(Object error) {
  final context = navigatorKey.currentContext;
  if (context == null) {
    return;
  }
  final message = _isNetworkError(error)
      ? 'Vui lòng kiểm tra internet'
      : 'Đã có sự cố xảy ra, thử lại sau';
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    title: 'Đã xảy ra sự cố!',
    desc: message,
    btnOkOnPress: () {},
    btnOkColor: Colors.red,
  ).show();
}

bool _isNetworkError(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final inner = error.error;
    if (inner is SocketException ||
        inner is TimeoutException ||
        inner is HandshakeException) {
      return true;
    }
  }
  return error is SocketException ||
      error is TimeoutException ||
      error is HandshakeException;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    // 390x884 is the standard iPhone 14/15 screen size from the Stitch UI
    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Velocity Transit',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
