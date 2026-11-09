import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hostel/connection/network_interceptor.dart';
import 'package:hostel/connection/supabase_config.dart';

/// The app's single HTTP client. Never create a `Dio()` anywhere else.
///
/// Paths are relative to the Supabase project: `/rest/v1/<table>`,
/// `/auth/v1/...` and `/functions/v1/<name>`.
class DioClient {
  DioClient({
    required FutureOr<String?> Function() tokenGetter,
    String baseUrl = SupabaseConfig.url,
    String apiKey = SupabaseConfig.publishableKey,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           contentType: Headers.jsonContentType,
         ),
       ) {
    dio.interceptors.add(
      NetworkInterceptor(tokenGetter: tokenGetter, apiKey: apiKey),
    );
  }

  final Dio dio;

  void close() => dio.close();
}
