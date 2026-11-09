import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/connection/network_interceptor.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status);
  final int status;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode({'secret': 'response-secret'}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late List<String> logs;

  (Dio, _FakeAdapter) build({int status = 200, String? token = 'tok-123'}) {
    final adapter = _FakeAdapter(status);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        NetworkInterceptor(
          tokenGetter: () => token,
          apiKey: 'pub-key',
          logger: logs.add,
        ),
      );
    return (dio, adapter);
  }

  setUp(() {
    logs = [];
  });

  test('attaches the bearer token', () async {
    final (dio, adapter) = build();
    await dio.get<dynamic>('/purchases');
    expect(adapter.last!.headers['Authorization'], 'Bearer tok-123');
  });

  test('sends no auth header without a token', () async {
    final (dio, adapter) = build(token: null);
    await dio.get<dynamic>('/purchases');
    expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
  });

  test('sends the API key with or without a session', () async {
    final (signedIn, signedInAdapter) = build();
    await signedIn.get<dynamic>('/purchases');
    expect(signedInAdapter.last!.headers['apikey'], 'pub-key');

    final (signedOut, signedOutAdapter) = build(token: null);
    await signedOut.get<dynamic>('/purchases');
    expect(signedOutAdapter.last!.headers['apikey'], 'pub-key');
  });

  test('logs only method, path and status', () async {
    final (dio, _) = build();
    await dio.post<dynamic>(
      '/purchases',
      queryParameters: {'q': 'query-secret'},
      data: {'note': 'request-secret'},
    );
    expect(logs, ['[API] POST /v1/purchases 200']);
  });

  group('/reports endpoints are never logged', () {
    const paths = ['/reports', '/reports/42', '/reports/42/votes'];

    for (final path in paths) {
      test('success: $path', () async {
        final (dio, _) = build();
        await dio.post<dynamic>(path, data: {'text': 'request-secret'});
        expect(logs, isEmpty);
      });

      test('failure: $path', () async {
        final (dio, _) = build(status: 500);
        await expectLater(
          dio.post<dynamic>(path, data: {'text': 'request-secret'}),
          throwsA(isA<DioException>()),
        );
        expect(logs, isEmpty);
      });
    }

    test('path matching is by whole segment', () {
      expect(
        NetworkInterceptor.isReportsPath(Uri.parse('https://a.b/v1/reports/1')),
        isTrue,
      );
      expect(
        NetworkInterceptor.isReportsPath(Uri.parse('https://a.b/v1/reportsx')),
        isFalse,
      );
    });
  });

  test('UserResponseData round-trips through JSON', () {
    final json = {
      'id': 'u1',
      'name': 'Бат',
      'role': 'manager',
      'status': 'active',
    };
    final user = UserResponseData.fromJson(json);
    expect(user.role, UserRole.manager);
    expect(user.toJson(), json);
  });
}
