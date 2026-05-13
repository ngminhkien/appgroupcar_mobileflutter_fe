import 'dart:async';

import 'package:dio/dio.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../storage/auth_token_storage.dart';

class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({
    required this.authCubit,
    required this.tokenStorage,
    required this.dio,
  });

  final AuthCubit authCubit;
  final AuthTokenStorage tokenStorage;
  final Dio dio;

  Completer<bool>? _refreshCompleter;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 && !_shouldSkip(err.requestOptions)) {
      final refreshed = await _refreshSession();
      if (refreshed) {
        final newToken = tokenStorage.getAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        }
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          // fall through to forward the original error
        }
      }
    }
    handler.next(err);
  }

  bool _shouldSkip(RequestOptions options) {
    final path = options.path.toLowerCase();
    return path.contains('/auth/refresh-token') || path.contains('/auth/login');
  }

  Future<bool> _refreshSession() {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    authCubit
        .refreshSession()
        .then((value) {
          _refreshCompleter?.complete(value);
        })
        .catchError((_) {
          _refreshCompleter?.complete(false);
        })
        .whenComplete(() {
          _refreshCompleter = null;
        });
    return _refreshCompleter!.future;
  }
}
