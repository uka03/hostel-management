import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Attaches the auth token, logs traffic in debug builds and reports 401s.
///
/// Logs carry only the method, path and status: never headers or bodies.
/// `/reports` traffic is not logged at all, because report anonymity has to
/// hold even against someone reading device logs.
class NetworkInterceptor extends Interceptor {
  NetworkInterceptor({
    required this.tokenGetter,
    this.onUnauthorized,
    void Function(String message)? logger,
  }) : _log = logger ?? (kDebugMode ? debugPrint : _noLog);

  final String? Function() tokenGetter;
  final VoidCallback? onUnauthorized;
  final void Function(String message) _log;

  static void _noLog(String? _, {int? wrapWidth}) {}

  static bool isReportsPath(Uri uri) => uri.pathSegments.contains('reports');

  void _logFor(RequestOptions options, String outcome) {
    if (isReportsPath(options.uri)) return;
    _log('[API] ${options.method} ${options.uri.path} $outcome');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenGetter();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logFor(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    _logFor(err.requestOptions, 'failed: ${status ?? err.type.name}');
    if (status == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
