import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/cleaning/cleaning_page.dart';
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

Map<String, dynamic> _overview({
  List<String> order = const ['me', 'bat', 'sara'],
  List<String> checked = const [],
  List<Map<String, dynamic>> swaps = const [],
}) => {
  'today': '2026-11-09',
  'start_date': '2026-11-09',
  'versions': [
    {'effective_period': 0, 'member_ids': order},
  ],
  'overrides': <Object>[],
  'areas': [
    {'id': 'kitchen', 'name': 'Гал тогоо'},
    {'id': 'hall', 'name': 'Коридор'},
  ],
  'checked_area_ids': checked,
  'done_periods': <Object>[],
  'members': [
    {'id': 'me', 'name': 'Би', 'active': true},
    {'id': 'bat', 'name': 'Бат', 'active': true},
    {'id': 'sara', 'name': 'Сараа', 'active': true},
  ],
  'swaps': swaps,
  'pending_residents': <Object>[],
};

class _Backend implements HttpClientAdapter {
  _Backend(this.overview);
  Map<String, dynamic> overview;
  String role = 'resident';
  final rpcCalls = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object? body = <String, dynamic>{};
    if (options.path == '/rest/v1/profiles') {
      body = [
        {'id': 'me', 'name': 'Би', 'role': role, 'status': 'active'},
      ];
    } else if (options.path.endsWith('/cleaning_overview')) {
      body = overview;
    } else {
      rpcCalls[options.path.split('/').last] = options.data;
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
        home: CleaningPage(),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  testWidgets('the duty person sees themself and can tick areas', (
    tester,
  ) async {
    final backend = _Backend(_overview());
    await _pump(tester, backend);

    expect(find.text('11/9–11/10 · 2 өдөр үлдсэн'), findsOneWidget);
    expect(find.text('0/2 хийгдсэн'), findsOneWidget);
    expect(find.text('11-р сарын 9, Даваа'), findsOneWidget);
    expect(find.text('Таны ээлж'), findsNWidgets(2));

    backend.overview = _overview(checked: ['kitchen']);
    await tester.tap(find.text('Гал тогоо'));
    await _settle(tester);

    expect(backend.rpcCalls['set_area_checked'], {
      'p_area_id': 'kitchen',
      'p_checked': true,
    });
    expect(find.text('1/2 хийгдсэн'), findsOneWidget);
    expect(find.text('Хийсэн'), findsOneWidget);
  });

  testWidgets('others can see the checklist but not tick it', (tester) async {
    final backend = _Backend(_overview(order: ['bat', 'me', 'sara']));
    await _pump(tester, backend);

    expect(find.text('Бат'), findsNWidgets(2));
    expect(find.text('Хийгээгүй'), findsNWidgets(2));
    expect(find.text('Дууссан'), findsNothing);

    await tester.tap(find.text('Гал тогоо'));
    await _settle(tester);
    expect(backend.rpcCalls, isEmpty);
  });

  testWidgets('an incoming swap can be accepted', (tester) async {
    final backend = _Backend(
      _overview(
        order: ['bat', 'me', 'sara'],
        swaps: [
          {
            'id': 's1',
            'requester_id': 'bat',
            'target_id': 'me',
            'requester_period': 0,
            'target_period': 1,
          },
        ],
      ),
    );
    await _pump(tester, backend);

    expect(find.textContaining('солихыг хүсэж байна'), findsOneWidget);
    await tester.tap(find.text('Зөвшөөрөх'));
    await _settle(tester);

    expect(backend.rpcCalls['respond_swap'], {
      'p_swap_id': 's1',
      'p_accept': true,
    });
  });

  testWidgets('swapping asks who to swap with', (tester) async {
    final backend = _Backend(_overview());
    await _pump(tester, backend);

    await tester.tap(find.text('Ээлж солих'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сараа').last);
    await _settle(tester);
    await tester.pumpAndSettle();

    // Period 5 is Сараа's second turn in the list.
    expect(backend.rpcCalls['request_swap'], {
      'p_my_period': 0,
      'p_their_period': 5,
    });
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('finished ticks every remaining area', (tester) async {
    final backend = _Backend(_overview(checked: ['kitchen']));
    await _pump(tester, backend);

    await tester.tap(find.text('Дууссан'));
    await _settle(tester);

    expect(backend.rpcCalls['set_area_checked'], {
      'p_area_id': 'hall',
      'p_checked': true,
    });
  });

  testWidgets('picking a period shows who is on duty then', (tester) async {
    final backend = _Backend(_overview());
    await _pump(tester, backend);

    await tester.tap(find.text('11'));
    await tester.pump();

    expect(find.text('11-р сарын 11, Лхагва'), findsOneWidget);
    expect(find.text('Бат'), findsNWidgets(2));
    expect(find.text('Удахгүй'), findsNWidgets(2));

    await tester.tap(find.text('Гал тогоо'));
    await _settle(tester);
    expect(backend.rpcCalls, isEmpty);
  });

  testWidgets('the calendar lists the rotation', (tester) async {
    final backend = _Backend(_overview());
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Ээлжийн хуваарь'));
    await tester.pumpAndSettle();

    expect(find.text('Явцад'), findsOneWidget);
    expect(find.text('11/11–11/12'), findsOneWidget);
    expect(find.text('Сараа'), findsWidgets);
  });

  testWidgets('managers get to the management screen', (tester) async {
    final backend = _Backend(_overview())..role = 'manager';
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Хуваарь удирдах'));
    await tester.pumpAndSettle();

    expect(find.text('Ээлжийн дараалал'), findsOneWidget);
    expect(find.text('Гал тогоо'), findsOneWidget);
  });

  testWidgets('residents have no management button', (tester) async {
    await _pump(tester, _Backend(_overview()));
    expect(find.byTooltip('Хуваарь удирдах'), findsNothing);
  });

  testWidgets('a schedule that has not started says so', (tester) async {
    final backend = _Backend(_overview()..['start_date'] = null);
    await _pump(tester, backend);
    expect(find.text('Хуваарь хараахан эхлээгүй байна.'), findsOneWidget);
  });
}
