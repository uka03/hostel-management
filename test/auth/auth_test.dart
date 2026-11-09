import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/connection/model/phone_verification.dart';
import 'package:hostel/connection/model/user_response_data.dart';
import 'package:hostel/connection/network_interceptor.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/shared/provider/session_store.dart';

class MemoryStore implements SessionStore {
  MemoryStore([this.session]);
  AuthSession? session;
  bool failing = false;

  @override
  Future<AuthSession?> read() async => session;
  @override
  Future<void> write(AuthSession value) async {
    if (failing) throw PlatformException(code: '-34018');
    session = value;
  }

  @override
  Future<void> clear() async {
    if (failing) throw PlatformException(code: '-34018');
    session = null;
  }
}

/// Answers each path from [replies]; records requests in [calls].
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.replies);
  final Map<String, (int, Object)> replies;
  final calls = <RequestOptions>[];
  final statusReplies = <(int, Object)>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final data = options.data;
    final isStatusCheck = data is Map && data['action'] == 'status';
    final (status, body) = isStatusCheck && statusReplies.isNotEmpty
        ? statusReplies.removeAt(0)
        : replies[options.path] ?? (500, <String, dynamic>{});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> sessionJson(String access, String refresh, int expiresAt) {
  return {
    'access_token': access,
    'refresh_token': refresh,
    'expires_at': expiresAt,
    'user': {'id': 'u1', 'phone': '97699112233'},
  };
}

AuthSession session(String access, String refresh, int expiresAt) =>
    AuthSession.fromJson(sessionJson(access, refresh, expiresAt));

const phoneVerify = '/functions/v1/phone-verify';
const profiles = '/rest/v1/profiles';

List<Map<String, dynamic>> profileRows(String status) => [
  {'id': 'u1', 'name': null, 'role': 'resident', 'status': status},
];

void main() {
  final now = DateTime.fromMillisecondsSinceEpoch(1000000 * 1000);
  const nowSeconds = 1000000;

  var clock = now;
  late Dio dio;
  late FakeAdapter adapter;
  late MemoryStore store;
  late AuthProvider auth;

  void setUpAuth(Map<String, (int, Object)> replies, [AuthSession? stored]) {
    clock = now;
    adapter = FakeAdapter(replies);
    store = MemoryStore(stored);
    late final AuthProvider provider;
    dio = Dio(BaseOptions(baseUrl: 'https://x.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        NetworkInterceptor(
          tokenGetter: () => provider.validAccessToken(),
          logger: (_) {},
        ),
      );
    provider = AuthProvider(
      api: () => AuthApi(dio),
      store: store,
      now: () => clock,
      delay: (d) async => clock = clock.add(d),
    );
    auth = provider;
  }

  group('normalizeMnPhone', () {
    test('accepts local and international forms', () {
      expect(normalizeMnPhone('99112233'), '+97699112233');
      expect(normalizeMnPhone('9911 2233'), '+97699112233');
      expect(normalizeMnPhone('+97699112233'), '+97699112233');
      expect(normalizeMnPhone('97699112233'), '+97699112233');
    });

    test('rejects anything else', () {
      expect(normalizeMnPhone(''), isNull);
      expect(normalizeMnPhone('9911223'), isNull);
      expect(normalizeMnPhone('991122334'), isNull);
      expect(normalizeMnPhone('abcdefgh'), isNull);
    });
  });

  group('SMS verification', () {
    Map<String, dynamic> started() => {
      'session_id': 's1',
      'sms_uri': 'sms:144773?body=482916',
      'display_instruction': 'instruction',
      'expires_at': now.add(const Duration(minutes: 5)).toIso8601String(),
    };

    final pending = (200, {'status': 'PENDING'});
    final expired = (200, {'status': 'EXPIRED'});
    final verified = (
      200,
      {
        'status': 'VERIFIED',
        'session': sessionJson('a1', 'r1', nowSeconds + 3600),
      },
    );

    test('PENDING then VERIFIED returns true and signs in', () async {
      setUpAuth({
        phoneVerify: (200, started()),
        profiles: (200, profileRows('pending')),
      });
      adapter.statusReplies.addAll([pending, verified]);
      await auth.restore();

      PhoneVerification? shown;
      final result = await auth.verifyPhone(
        '+97699112233',
        onStarted: (v) => shown = v,
      );

      expect(result, isTrue);
      expect(shown!.displayInstruction, 'instruction');
      expect(shown!.smsUri, 'sms:144773?body=482916');
      expect(clock.difference(now), const Duration(seconds: 6));
      expect(auth.status, AuthStatus.signedIn);
      expect(store.session!.accessToken, 'a1');
      expect(auth.user!.status, ResidentStatus.pending);
      expect(adapter.calls.last.queryParameters['id'], 'eq.u1');
      expect(adapter.calls.last.headers['Authorization'], 'Bearer a1');
    });

    test('a storage failure does not lose the login', () async {
      setUpAuth({
        phoneVerify: (200, started()),
        profiles: (200, profileRows('pending')),
      });
      adapter.statusReplies.add(verified);
      store.failing = true;
      await auth.restore();

      final result = await auth.verifyPhone('+97699112233', onStarted: (_) {});

      expect(result, isTrue);
      expect(auth.status, AuthStatus.signedIn);
      expect(auth.user!.status, ResidentStatus.pending);
    });

    test('an unreadable profile does not lose the login', () async {
      setUpAuth({
        phoneVerify: (200, started()),
        profiles: (
          200,
          [
            {'id': 'u1', 'role': 'unknown-role', 'status': 'active'},
          ],
        ),
      });
      adapter.statusReplies.add(verified);
      await auth.restore();

      final result = await auth.verifyPhone('+97699112233', onStarted: (_) {});

      expect(result, isTrue);
      expect(auth.status, AuthStatus.signedIn);
      expect(auth.user, isNull);
    });

    test('sign out survives a storage failure', () async {
      setUpAuth({
        phoneVerify: (200, started()),
        profiles: (200, profileRows('active')),
      });
      adapter.statusReplies.add(verified);
      await auth.verifyPhone('+97699112233', onStarted: (_) {});
      store.failing = true;

      auth.clear();
      await Future<void>.delayed(Duration.zero);

      expect(auth.status, AuthStatus.signedOut);
    });

    test('calls are made without a session', () async {
      setUpAuth({phoneVerify: (200, started())});
      adapter.statusReplies.add(expired);

      await auth.verifyPhone('+97699112233', onStarted: (_) {});

      expect(adapter.calls.first.data, {
        'action': 'start',
        'phone': '+97699112233',
      });
      for (final call in adapter.calls) {
        expect(call.headers.containsKey('Authorization'), isFalse);
      }
    });

    test('EXPIRED returns false and stays signed out', () async {
      setUpAuth({phoneVerify: (200, started())});
      adapter.statusReplies.add(expired);
      await auth.restore();

      final result = await auth.verifyPhone('+97699112233', onStarted: (_) {});

      expect(result, isFalse);
      expect(auth.status, AuthStatus.signedOut);
      expect(store.session, isNull);
    });

    test('stops at the deadline if it never leaves PENDING', () async {
      setUpAuth({phoneVerify: (200, started())});
      adapter.statusReplies.addAll(List.filled(1000, pending));
      await auth.restore();

      final result = await auth.verifyPhone('+97699112233', onStarted: (_) {});

      expect(result, isFalse);
      expect(auth.status, AuthStatus.signedOut);
      expect(
        clock.difference(now),
        lessThan(const Duration(minutes: 5, seconds: 34)),
      );
    });

    test('a failed check keeps waiting', () async {
      setUpAuth({
        phoneVerify: (200, started()),
        profiles: (200, profileRows('active')),
      });
      adapter.statusReplies.addAll([(500, <String, dynamic>{}), verified]);
      await auth.restore();

      expect(await auth.verifyPhone('+97699112233', onStarted: (_) {}), isTrue);
    });

    test('cancelling stops before checking again', () async {
      setUpAuth({phoneVerify: (200, started())});

      final result = await auth.verifyPhone(
        '+97699112233',
        onStarted: (_) {},
        isCancelled: () => true,
      );

      expect(result, isFalse);
      expect(adapter.calls, hasLength(1));
    });

    test('a rejected API key surfaces as an error', () async {
      setUpAuth({
        phoneVerify: (500, {'error_code': 'not_configured'}),
      });

      await expectLater(
        auth.verifyPhone('+97699112233', onStarted: (_) {}),
        throwsA(isA<DioException>()),
      );
      expect(auth.status, AuthStatus.loading);
    });
  });

  group('profile', () {
    test('a failed profile load keeps the session', () async {
      setUpAuth({profiles: (500, {})}, session('a1', 'r1', nowSeconds + 3600));

      await auth.restore();

      expect(auth.status, AuthStatus.signedIn);
      expect(auth.user, isNull);
    });

    test('refreshing picks up approval', () async {
      final replies = <String, (int, Object)>{
        profiles: (200, profileRows('pending')),
      };
      setUpAuth(replies, session('a1', 'r1', nowSeconds + 3600));
      await auth.restore();
      expect(auth.user!.status, ResidentStatus.pending);

      replies[profiles] = (200, profileRows('active'));
      await auth.refreshProfile();

      expect(auth.user!.status, ResidentStatus.active);
    });
  });

  group('session', () {
    final fresh = <String, (int, Object)>{
      profiles: (200, profileRows('active')),
    };

    test('restores a stored session', () async {
      setUpAuth(fresh, session('a1', 'r1', nowSeconds + 3600));
      expect(auth.status, AuthStatus.loading);
      await auth.restore();
      expect(auth.status, AuthStatus.signedIn);
    });

    test('uses a fresh token without refreshing', () async {
      setUpAuth(fresh, session('a1', 'r1', nowSeconds + 3600));
      await auth.restore();
      adapter.calls.clear();

      expect(await auth.validAccessToken(), 'a1');
      expect(adapter.calls, isEmpty);
    });

    test('concurrent callers share a single refresh', () async {
      setUpAuth({
        ...fresh,
        '/auth/v1/token': (200, sessionJson('a2', 'r2', nowSeconds + 3600)),
      }, session('a1', 'r1', nowSeconds + 10));
      await auth.restore();
      expect(store.session!.refreshToken, 'r2');
      adapter.calls.clear();

      // Expire the refreshed token by storing a nearly expired one again.
      setUpAuth({
        ...fresh,
        '/auth/v1/token': (200, sessionJson('a3', 'r3', nowSeconds + 3600)),
      }, session('a2', 'r2', nowSeconds + 10));
      final restoring = auth.restore();
      final tokens = await Future.wait([
        restoring.then((_) => auth.validAccessToken()),
        restoring.then((_) => auth.validAccessToken()),
      ]);

      expect(tokens, ['a3', 'a3']);
      expect(
        adapter.calls.where((c) => c.path == '/auth/v1/token'),
        hasLength(1),
      );
    });

    test('a rejected refresh token signs out', () async {
      setUpAuth({
        '/auth/v1/token': (400, {'error_code': 'refresh_token_not_found'}),
      }, session('a1', 'r1', nowSeconds + 10));
      await auth.restore();

      expect(await auth.validAccessToken(), isNull);
      expect(auth.status, AuthStatus.signedOut);
      expect(store.session, isNull);
    });

    test('a server error during refresh keeps the session', () async {
      setUpAuth({
        '/auth/v1/token': (500, {}),
      }, session('a1', 'r1', nowSeconds + 10));
      await auth.restore();

      expect(await auth.validAccessToken(), 'a1');
      expect(auth.status, AuthStatus.signedIn);
    });

    test('sign out clears locally even if the server fails', () async {
      setUpAuth({
        ...fresh,
        '/auth/v1/logout': (500, {}),
      }, session('a1', 'r1', nowSeconds + 3600));
      await auth.restore();

      await auth.signOut();

      expect(auth.status, AuthStatus.signedOut);
      expect(store.session, isNull);
    });

    test('a 401 on a signed-in call keeps the session', () async {
      setUpAuth({
        ...fresh,
        '/rest/v1/purchases': (401, {}),
      }, session('a1', 'r1', nowSeconds + 3600));
      await auth.restore();

      await expectLater(
        dio.get<dynamic>('/rest/v1/purchases'),
        throwsA(isA<DioException>()),
      );

      expect(auth.status, AuthStatus.signedIn);
      expect(store.session, isNotNull);
    });

    test('an unexplained refresh rejection keeps the session', () async {
      setUpAuth({
        '/auth/v1/token': (400, {'error_code': 'validation_failed'}),
      }, session('a1', 'r1', nowSeconds + 10));
      await auth.restore();

      expect(await auth.validAccessToken(), 'a1');
      expect(auth.status, AuthStatus.signedIn);
      expect(store.session, isNotNull);
    });

    test('restoring and refreshing the page never signs out', () async {
      setUpAuth({profiles: (401, {})}, session('a1', 'r1', nowSeconds + 3600));

      await auth.restore();
      await auth.refreshProfile();

      expect(auth.status, AuthStatus.signedIn);
    });

    test('a 401 on a public call does not touch the session', () async {
      setUpAuth({
        ...fresh,
        phoneVerify: (401, {}),
      }, session('a1', 'r1', nowSeconds + 3600));
      await auth.restore();

      await expectLater(
        auth.verifyPhone('+97699112233', onStarted: (_) {}),
        throwsA(isA<DioException>()),
      );

      expect(auth.status, AuthStatus.signedIn);
    });
  });
}
