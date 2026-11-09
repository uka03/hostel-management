import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Attaches the Supabase API key and auth token, and logs traffic in debug
/// builds. A failed request never signs anyone out.
///
/// Logs carry only the method, path and status: never headers or bodies.
/// `/reports` traffic is not logged at all, because report anonymity has to
/// hold even against someone reading device logs. Matching is by path segment,
/// so report endpoints must have a `reports` segment: `/rest/v1/reports` or
/// `/functions/v1/reports`, not `/functions/v1/submit-report`.
class NetworkInterceptor extends Interceptor {
  NetworkInterceptor({
    required this.tokenGetter,
    this.apiKey,
    void Function(String message)? logger,
  }) : _log = logger ?? (kDebugMode ? debugPrint : _noLog);

  /// Set in `Options.extra` for calls made without a user session: requesting
  /// or verifying a code and refreshing the token. Refresh in particular must
  /// skip [tokenGetter], which would otherwise wait on itself.
  static const skipSessionKey = 'skipSession';

  final FutureOr<String?> Function() tokenGetter;
  final String? apiKey;
  final void Function(String message) _log;

  static void _noLog(String? _, {int? wrapWidth}) {}

  static bool isReportsPath(Uri uri) => uri.pathSegments.contains('reports');

  void _logFor(RequestOptions options, String outcome) {
    if (isReportsPath(options.uri)) return;
    _log('[API] ${options.method} ${options.uri.path} $outcome');
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (apiKey != null) {
      options.headers['apikey'] = apiKey;
    }
    if (options.extra[skipSessionKey] != true) {
      final token = await tokenGetter();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
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
    handler.next(err);
  }
}
