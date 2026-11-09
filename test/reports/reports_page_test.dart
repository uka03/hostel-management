import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/reports/reports_page.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/shared/provider/session_store.dart';
import 'package:provider/provider.dart';

const _session = AuthSession(
  accessToken: 'a',
  refreshToken: 'r',
  expiresAt: 4102444800,
  user: AuthUser(id: 'me'),
);

class _Store implements SessionStore {
  @override
  Future<AuthSession?> read() async => _session;
  @override
  Future<void> write(AuthSession value) async {}
  @override
  Future<void> clear() async {}
}

Map<String, dynamic> _report(
  String id,
  String status, {
  String description = 'Чанга хөгжим. Шөнө бүр.',
  String? reply,
}) => {
  'id': id,
  'category': 'noise',
  'location': 'Коридор',
  'description': description,
  'status': status,
  'reply': reply,
  'has_photo': false,
  'created_at': DateTime.now().toUtc().toIso8601String(),
  'vote_count': 4,
  'voted': false,
};

class _Backend implements HttpClientAdapter {
  String role = 'resident';
  final calls = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object body = <String, dynamic>{};
    if (options.path == '/rest/v1/profiles') {
      body = [
        {'id': 'me', 'name': 'Би', 'role': role, 'status': 'active'},
      ];
    } else {
      final data = options.data as Map<String, dynamic>;
      if (data['action'] == 'list') {
        body = {
          'reports': [
            _report('open1', 'open'),
            _report('prog1', 'in_progress', description: 'Шүүгээ эвдэрсэн'),
            _report(
              'done1',
              'resolved',
              description: 'Хоол муудсан',
              reply: 'Цэвэрлэлээ',
            ),
          ],
        };
      } else {
        calls.add(data);
      }
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 8; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pump(WidgetTester tester, _Backend backend) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  addTearDown(tester.view.reset);

  final client = DioClient(tokenGetter: () => 'a', baseUrl: 'https://x.test');
  client.dio.httpClientAdapter = backend;
  final auth = AuthProvider(api: () => AuthApi(client.dio), store: _Store());
  await tester.runAsync(auth.restore);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider.value(value: client),
      ],
      child: const MaterialApp(
        locale: Locale('mn'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: ReportsPage(),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  testWidgets('every report is shown as anonymous', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('Нэргүй оршин суугч'), findsNWidgets(3));
    expect(find.text('Чанга хөгжим'), findsOneWidget);
    expect(find.text('Коридор · Шөнө бүр.'), findsOneWidget);
    expect(find.text('Саяхан'), findsNWidgets(3));
    expect(find.text('Менежер: Цэвэрлэлээ'), findsOneWidget);
  });

  testWidgets('filters by status', (tester) async {
    await _pump(tester, _Backend());

    await tester.ensureVisible(find.text('Шийдэгдсэн').first);
    await tester.pump();
    await tester.tap(find.text('Шийдэгдсэн').first);
    await tester.pump();

    expect(find.text('Нэргүй оршин суугч'), findsOneWidget);
    expect(find.text('Хоол муудсан'), findsOneWidget);
  });

  testWidgets('me too sends a vote', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.text('4').first);
    await _settle(tester);

    expect(backend.calls.single, {
      'action': 'vote',
      'report_id': 'open1',
      'voted': true,
    });
  });

  testWidgets('the form sends only after everything required is set', (
    tester,
  ) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Асуудал мэдэгдэх'));
    await tester.pumpAndSettle();
    expect(find.text('Та нэргүй байна'), findsOneWidget);

    ElevatedButton send() => tester.widget(find.byType(ElevatedButton));
    expect(send().onPressed, isNull);

    await tester.tap(find.text('Чимээ шуугиан'));
    await tester.enterText(find.byType(TextField), '  Хөгжим чанга  ');
    await tester.pump();
    expect(find.text('16 / 500'), findsOneWidget);
    expect(send().onPressed, isNull);

    await tester.ensureVisible(find.text('Жишээ: 2-р давхрын коридор'));
    await tester.pump();
    await tester.tap(find.text('Жишээ: 2-р давхрын коридор'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Коридор');
    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();
    expect(send().onPressed, isNotNull);

    await tester.ensureVisible(find.text('Нэргүйгээр илгээх'));
    await tester.tap(find.text('Нэргүйгээр илгээх'));
    await _settle(tester);
    await tester.pumpAndSettle();

    expect(backend.calls.single, {
      'action': 'create',
      'category': 'noise',
      'location': 'Коридор',
      'description': 'Хөгжим чанга',
    });
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('managers can set status and reply', (tester) async {
    final backend = _Backend()..role = 'manager';
    await _pump(tester, backend);

    await tester.tap(find.text('Шүүгээ эвдэрсэн'));
    await tester.pumpAndSettle();
    expect(find.text('Нэргүй оршин суугч'), findsOneWidget);

    await tester.tap(find.text('Шийдэгдсэн').last);
    await tester.enterText(find.byType(TextField), 'Засуулсан');
    await tester.pump();
    await tester.ensureVisible(find.text('Хадгалах'));
    await tester.tap(find.text('Хадгалах'));
    await _settle(tester);
    await tester.pump(const Duration(seconds: 4));

    expect(backend.calls.single, {
      'action': 'update',
      'report_id': 'prog1',
      'status': 'resolved',
      'reply': 'Засуулсан',
    });
  });

  testWidgets('residents get no manager controls', (tester) async {
    await _pump(tester, _Backend());

    await tester.tap(find.text('Шүүгээ эвдэрсэн'));
    await tester.pumpAndSettle();

    expect(find.text('Хадгалах'), findsNothing);
  });
}
