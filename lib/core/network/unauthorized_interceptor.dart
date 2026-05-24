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
  static const String _retriedAfterRefreshKey = '_retried_after_refresh';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final isUnauthorized = _isUnauthorizedResponse(response);
    if (_canRefreshAndRetry(response.requestOptions, isUnauthorized)) {
      final retriedResponse = await _retryWithRefreshedToken(
        response.requestOptions,
      );
      if (retriedResponse != null) {
        return handler.resolve(retriedResponse);
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    if (_canRefreshAndRetry(err.requestOptions, isUnauthorized)) {
      final retriedResponse = await _retryWithRefreshedToken(err.requestOptions);
      if (retriedResponse != null) {
        return handler.resolve(retriedResponse);
      }
    }
    handler.next(err);
  }

  bool _canRefreshAndRetry(RequestOptions options, bool isUnauthorized) {
    if (!isUnauthorized) {
      return false;
    }
    if (_shouldSkip(options)) {
      return false;
    }
    return options.extra[_retriedAfterRefreshKey] != true;
  }

  bool _shouldSkip(RequestOptions options) {
    final path = options.path.toLowerCase();
    return path.contains('/auth/refresh-token') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/logout') ||
        path.contains('/companies/login');
  }

  Future<Response<dynamic>?> _retryWithRefreshedToken(
    RequestOptions requestOptions,
  ) async {
    final refreshed = await _refreshSession();
    if (!refreshed) {
      return null;
    }

    final newToken = tokenStorage.getAccessToken();
    if (newToken == null || newToken.isEmpty) {
      return null;
    }

    requestOptions.headers['Authorization'] = 'Bearer $newToken';
    requestOptions.extra[_retriedAfterRefreshKey] = true;

    try {
      return await dio.fetch(requestOptions);
    } catch (_) {
      return null;
    }
  }

  bool _isUnauthorizedResponse(Response response) {
    if (response.statusCode == 401) {
      return true;
    }
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code is int) {
        return code == 401;
      }
      if (code is num) {
        return code.toInt() == 401;
      }
      if (code is String) {
        return int.tryParse(code.trim()) == 401;
      }
    }
    return false;
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
