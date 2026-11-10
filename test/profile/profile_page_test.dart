import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/auth/provider/phone.dart';
import 'package:hostel/pages/profile/profile_page.dart';
import 'package:hostel/shared/provider/auth_provider.dart';
import 'package:hostel/shared/provider/session_store.dart';
import 'package:provider/provider.dart';

const _session = AuthSession(
  accessToken: 'a',
  refreshToken: 'r',
  expiresAt: 4102444800,
  user: AuthUser(id: 'me', phone: '97680977331'),
);

class _Store implements SessionStore {
  @override
  Future<AuthSession?> read() async => _session;
  @override
  Future<void> write(AuthSession value) async {}
  @override
  Future<void> clear() async {}
}

class _Backend implements HttpClientAdapter {
  String role = 'resident';
  int myPaid = 12000;
  bool hasAccount = true;
  int overviewLoads = 0;
  final rpcCalls = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object body = <String, dynamic>{};
    final path = options.path;
    if (path == '/rest/v1/profiles') {
      body = [
        {
          'id': 'me',
          'name': 'Ука',
          'role': role,
          'status': 'active',
          if (hasAccount) ...{
            'bank_name': 'Хаан банк',
            'bank_account_number': '5000123456',
            'bank_account_holder': 'Ука Бат',
          },
        },
      ];
    } else if (path.endsWith('/profile_stats')) {
      body = {'cleaned_count': 12};
    } else if (path.endsWith('/cleaning_overview')) {
      body = {
        'today': '2026-11-09',
        'start_date': '2026-11-09',
        'versions': [
          {
            'effective_period': 0,
            'member_ids': ['bat', 'sara', 'tem', 'me'],
          },
        ],
        'overrides': <Object>[],
        'areas': <Object>[],
        'checked_area_ids': <Object>[],
        'done_periods': <Object>[],
        'members': <Object>[],
        'swaps': <Object>[],
        'pending_residents': <Object>[],
      };
    } else if (path.endsWith('/purchases_overview')) {
      overviewLoads++;
      body = {
        'today': '2026-11-09',
        'active_count': 6,
        'total_amount': 48600,
        'my_paid': myPaid,
        'my_share': 8100,
        'purchases': <Object>[],
        'needed_items': <Object>[],
      };
    } else {
      rpcCalls[path.split('/').last] = options.data;
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

Future<AuthProvider> _pump(
  WidgetTester tester,
  _Backend backend, {
  ValueNotifier<int>? tab,
}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(360 * 3, 1000 * 3);
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
      child: MaterialApp(
        locale: const Locale('mn'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: tab == null
            ? const ProfilePage()
            : ValueListenableBuilder<int>(
                valueListenable: tab,
                builder: (_, index, _) => IndexedStack(
                  index: index,
                  children: const [SizedBox(), ProfilePage()],
                ),
              ),
      ),
    ),
  );
  await _settle(tester);
  return auth;
}

void main() {
  test('maskMnPhone hides the last digits', () {
    expect(maskMnPhone('97680977331'), '+976 8097 ****');
    expect(maskMnPhone('+97680977331'), '+976 8097 ****');
    expect(maskMnPhone('123'), isNull);
  });

  testWidgets('shows who you are, with the number masked', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('Ука'), findsOneWidget);
    expect(find.text('+976 8097 ****'), findsOneWidget);
    expect(find.textContaining('7331'), findsNothing);
    expect(find.text('Оршин суугч'), findsOneWidget);
    expect(find.text('6 оршин суугч'), findsOneWidget);
  });

  testWidgets('labels managers', (tester) async {
    await _pump(tester, _Backend()..role = 'manager');
    expect(find.text('Менежер'), findsOneWidget);
  });

  testWidgets('shows real stats', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('12'), findsOneWidget);
    expect(find.text('11/15'), findsOneWidget);
    expect(find.text('₮3,900'), findsOneWidget);
    expect(find.text('Буцаж авах'), findsOneWidget);
  });

  testWidgets('says when you owe instead', (tester) async {
    await _pump(tester, _Backend()..myPaid = 0);

    expect(find.text('₮8,100'), findsOneWidget);
    expect(find.text('Төлөх'), findsOneWidget);
    expect(find.text('Буцаж авах'), findsNothing);
  });

  testWidgets('reloads when the tab is opened again', (tester) async {
    final backend = _Backend();
    final tab = ValueNotifier(0);
    await _pump(tester, backend, tab: tab);
    expect(backend.overviewLoads, 0, reason: 'hidden tabs do not load');

    tab.value = 1;
    await _settle(tester);
    expect(backend.overviewLoads, 1);

    tab.value = 0;
    await _settle(tester);
    tab.value = 1;
    await _settle(tester);
    expect(backend.overviewLoads, 2);
  });

  testWidgets('the bank row shows the account and edits it', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('Хаан банк · 5000123456'), findsOneWidget);
    await tester.tap(find.text('Дансны мэдээлэл'));
    await tester.pumpAndSettle();
    expect(find.text('Ука Бат'), findsOneWidget);
  });

  testWidgets('the bank row invites you to add one', (tester) async {
    await _pump(tester, _Backend()..hasAccount = false);
    expect(find.text('Данс нэмээгүй байна'), findsOneWidget);
  });

  testWidgets('changing language saves it', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.text('Хэл'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['set_my_preferences'], {
      'p_notifications_enabled': true,
      'p_language': 'en',
    });
  });

  testWidgets('the notifications switch saves it', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.byType(Switch));
    await _settle(tester);

    expect(backend.rpcCalls['set_my_preferences'], {
      'p_notifications_enabled': false,
      'p_language': 'mn',
    });
  });

  testWidgets('editing your name saves it', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Нэр засах'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' Уянга ');
    await tester.pump();
    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['set_my_name'], {'p_name': 'Уянга'});
  });

  testWidgets('signing out asks first', (tester) async {
    final auth = await _pump(tester, _Backend());

    await tester.tap(find.text('Гарах'));
    await tester.pumpAndSettle();
    expect(auth.status, AuthStatus.signedIn);

    await tester.tap(find.text('Гарах').last);
    await tester.pumpAndSettle();
    await _settle(tester);
    expect(auth.status, AuthStatus.signedOut);
  });
}
