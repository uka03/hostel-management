import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/main.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/shared/provider/session_store.dart';

class _Store implements SessionStore {
  _Store(this.session);
  AuthSession? session;

  @override
  Future<AuthSession?> read() async => session;
  @override
  Future<void> write(AuthSession value) async => session = value;
  @override
  Future<void> clear() async => session = null;
}

class _Backend implements HttpClientAdapter {
  String profileStatus = 'pending';
  String? name = 'Бат';
  String verifyStatus = 'PENDING';
  int statusChecks = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(_reply(options)),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Object _reply(RequestOptions options) {
    if (options.path == '/rest/v1/profiles') {
      return [
        {'id': 'u1', 'name': name, 'role': 'resident', 'status': profileStatus},
      ];
    }
    if (options.path == '/rest/v1/rpc/cleaning_overview') {
      return {
        'today': '2026-11-09',
        'start_date': null,
        'versions': <Object>[],
        'overrides': <Object>[],
        'areas': <Object>[],
        'checked_area_ids': <Object>[],
        'done_periods': <Object>[],
        'members': <Object>[],
        'swaps': <Object>[],
        'pending_residents': <Object>[],
      };
    }
    if (options.path == '/rest/v1/rpc/set_my_name') {
      name = (options.data as Map)['p_name'] as String;
      return <String, dynamic>{};
    }
    if (options.path == '/rest/v1/rpc/purchases_overview') {
      return {
        'today': '2026-11-09',
        'active_count': 1,
        'total_amount': 0,
        'my_paid': 0,
        'my_share': 0,
        'purchases': <Object>[],
        'needed_items': <Object>[],
      };
    }
    if (options.path == '/rest/v1/rpc/my_notifications') {
      return {'unread_count': 0, 'items': <Object>[]};
    }
    if (options.path == '/functions/v1/reports') {
      return {'reports': <Object>[]};
    }
    final data = options.data as Map<String, dynamic>;
    if (data['action'] == 'start') {
      return {
        'session_id': 's1',
        'sms_uri': 'sms:144773?body=482916',
        'display_instruction': 'Та 144773 дугаарт илгээнэ үү.',
        'expires_at': DateTime.now()
            .add(const Duration(minutes: 5))
            .toIso8601String(),
      };
    }
    statusChecks++;
    if (verifyStatus != 'VERIFIED') return {'status': verifyStatus};
    return {
      'status': 'VERIFIED',
      'session': {
        'access_token': 'a',
        'refresh_token': 'r',
        'expires_at': 4102444800,
        'user': {'id': 'u1'},
      },
    };
  }

  @override
  void close({bool force = false}) {}
}

const _session = AuthSession(
  accessToken: 'a',
  refreshToken: 'r',
  expiresAt: 4102444800,
  user: AuthUser(id: 'u1'),
);

Future<void> _pumpApp(
  WidgetTester tester,
  _Backend backend,
  AuthSession? stored,
) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  addTearDown(tester.view.reset);

  final client = DioClient(tokenGetter: () => null, baseUrl: 'https://x.test');
  client.dio.httpClientAdapter = backend;
  final auth = AuthProvider(
    api: () => AuthApi(client.dio),
    store: _Store(stored),
  );
  await tester.runAsync(auth.restore);
  await tester.pumpWidget(MyApp(auth: auth, client: client));
  await tester.pumpAndSettle();
}

/// Lets real async work (the fake backend) finish, then rebuilds.
Future<void> _settle(WidgetTester tester) async {
  // Each round lets one more step of the request chain complete. Dio uses
  // timers internally, so the fake clock has to move as well.
  for (var round = 0; round < 8; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('SMS login: waits, then lands on approval screen', (
    tester,
  ) async {
    final backend = _Backend();
    await _pumpApp(tester, backend, null);
    expect(find.text('Утасны дугаараа оруулна уу'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '99112233');
    await tester.pump();
    expect(find.text('9911 2233'), findsOneWidget);
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('144773'), findsOneWidget);
    expect(find.text('482916'), findsOneWidget);
    expect(find.text('SMS илгээх'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);
    expect(backend.statusChecks, 1);
    expect(find.text('Зөвшөөрөл хүлээж байна'), findsNothing);

    await tester.tap(find.text('Хуулах').last);
    await _settle(tester);
    expect(find.text('Хуулсан'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Хуулсан'), findsNothing);

    backend.verifyStatus = 'VERIFIED';
    await tester.pump(const Duration(seconds: 4));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Зөвшөөрөл хүлээж байна'), findsOneWidget);

    // Polling has stopped: no further status checks.
    final checks = backend.statusChecks;
    await tester.pump(const Duration(seconds: 9));
    expect(backend.statusChecks, checks);
  });

  testWidgets('a new resident is asked for their name first', (tester) async {
    final backend = _Backend()..name = null;
    await _pumpApp(tester, backend, _session);
    expect(find.text('Нэрээ оруулна уу'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Сараа ');
    await tester.pump();
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await _settle(tester);

    expect(backend.name, 'Сараа');
    expect(find.text('Зөвшөөрөл хүлээж байна'), findsOneWidget);
  });

  testWidgets('continue stays disabled until the number is complete', (
    tester,
  ) async {
    await _pumpApp(tester, _Backend(), null);

    ElevatedButton button() => tester.widget(find.byType(ElevatedButton));
    await tester.enterText(find.byType(TextField), '9911');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '99112233');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('an expired code offers a new one', (tester) async {
    final backend = _Backend()..verifyStatus = 'EXPIRED';
    await _pumpApp(tester, backend, null);

    await tester.enterText(find.byType(TextField), '99112233');
    await tester.pump();
    await tester.tap(find.text('Үргэлжлүүлэх'));
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pump(const Duration(seconds: 3));
    await _settle(tester);

    expect(find.text('Шинэ код авах'), findsOneWidget);
    expect(find.text('SMS илгээх'), findsNothing);
  });

  testWidgets('tab shell fits at 360 px in Mongolian and switches tabs', (
    tester,
  ) async {
    final backend = _Backend()..profileStatus = 'active';
    await _pumpApp(tester, backend, _session);

    // Every label is in the tab bar; only the active page adds its title.
    expect(find.text('Нүүр'), findsOneWidget);
    for (final label in ['Мэдэгдэл', 'Профайл']) {
      expect(find.text(label), findsOneWidget);
    }
    // These two are also Home's quick actions.
    for (final label in ['Цэвэрлэгээ', 'Зардал']) {
      expect(find.text(label), findsNWidgets(2));
    }

    await tester.tap(find.text('Зардал').last);
    await _settle(tester);

    expect(find.text('Хамтын худалдан авалт'), findsOneWidget);
    expect(find.text('Нүүр'), findsOneWidget);
  });
}
