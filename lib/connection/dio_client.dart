import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hostel/connection/network_interceptor.dart';

/// The app's single HTTP client. Never create a `Dio()` anywhere else.
///
/// Set the server with `--dart-define=API_BASE_URL=https://...`.
class DioClient {
  DioClient({
    required String? Function() tokenGetter,
    VoidCallback? onUnauthorized,
    String baseUrl = const String.fromEnvironment('API_BASE_URL'),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           contentType: Headers.jsonContentType,
         ),
       ) {
    dio.interceptors.add(
      NetworkInterceptor(
        tokenGetter: tokenGetter,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  final Dio dio;

  void close() => dio.close();
}
