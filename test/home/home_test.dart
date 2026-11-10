import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/connection/model/cleaning_overview.dart';
import 'package:hostel/connection/model/purchases_overview.dart';
import 'package:hostel/connection/model/report.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/home/home_page.dart';
import 'package:hostel/pages/home/provider/home_summary.dart';
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

class _Backend implements HttpClientAdapter {
  List<String> order = const ['me', 'bat'];
  List<String> checked = const [];
  List<int> done = const [];
  bool reportsFail = false;
  int unread = 2;
  int markReadCalls = 0;
  String? startDate = '2026-11-11';
  final rpcCalls = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object body = <String, dynamic>{};
    var status = 200;
    final path = options.path;
    if (path == '/rest/v1/profiles') {
      body = [
        {'id': 'me', 'name': 'Ука', 'role': 'resident', 'status': 'active'},
      ];
    } else if (path.endsWith('/cleaning_overview')) {
      body = {
        'today': '2026-11-11',
        'start_date': startDate,
        'versions': [
          {'effective_period': 0, 'member_ids': order},
        ],
        'overrides': <Object>[],
        'areas': [
          {'id': 'a', 'name': 'Гал тогоо'},
          {'id': 'b', 'name': 'Коридор'},
          {'id': 'c', 'name': 'Хог'},
        ],
        'checked_area_ids': checked,
        'done_periods': done,
        'members': [
          {'id': 'me', 'name': 'Ука', 'active': true},
          {'id': 'bat', 'name': 'Бат', 'active': true},
        ],
        'swaps': <Object>[],
        'pending_residents': <Object>[],
      };
    } else if (path.endsWith('/purchases_overview')) {
      body = {
        'today': '2026-11-11',
        'active_count': 2,
        'total_amount': 4500,
        'my_paid': 0,
        'my_share': 0,
        'purchases': [
          {
            'id': 'p',
            'title': 'Шингэн',
            'amount': 4500,
            'buyer_id': 'bold',
            'buyer_name': 'Болд',
            'purchased_on': '2026-11-10',
            'my_share': 2250,
            'people_count': 2,
            'my_paid': false,
            'paid_count': 0,
          },
        ],
        'needed_items': [
          {
            'id': 'i',
            'name': 'Цаас',
            'requested_by': 'bat',
            'requested_on': '2026-11-10',
          },
          {
            'id': 'j',
            'name': 'Саван',
            'requested_by': 'bat',
            'requested_on': '2026-11-10',
          },
        ],
      };
    } else if (path.endsWith('/my_notifications')) {
      body = {
        'unread_count': unread,
        'items': [
          {
            'id': 'n1',
            'kind': 'paid',
            'data': {'person_name': 'Бат', 'title': 'Шингэн', 'amount': 2250},
            'created_at': '2026-11-10T04:00:00.000Z',
            'read': unread == 0,
          },
          {
            'id': 'n2',
            'kind': 'report_update',
            'data': {
              'location': 'Угаалга',
              'status': 'in_progress',
              'replied': false,
            },
            'created_at': '2026-11-10T03:00:00.000Z',
            'read': unread == 0,
          },
          {
            'id': 'n3',
            'kind': 'new_purchase',
            'data': {'person_name': 'Болд', 'title': 'Цаас', 'amount': 500},
            'created_at': '2026-11-09T03:00:00.000Z',
            'read': true,
          },
          {
            'id': 'n4',
            'kind': 'report_new',
            'data': {'category': 'damage', 'location': 'Гал тогоо'},
            'created_at': '2026-11-09T02:00:00.000Z',
            'read': true,
          },
        ],
      };
    } else if (path.endsWith('/mark_notifications_read')) {
      markReadCalls++;
      unread = 0;
    } else if (path == '/functions/v1/reports') {
      if (reportsFail) status = 500;
      body = {
        'reports': [
          {
            'id': 'r',
            'category': 'damage',
            'location': 'Угаалга',
            'description': 'Шүршүүр эвдэрсэн. Гоожиж байна.',
            'status': 'open',
            'reply': null,
            'has_photo': false,
            'created_at': '2026-11-10T04:00:00.000Z',
            'vote_count': 0,
            'voted': false,
          },
        ],
      };
    } else {
      rpcCalls.add(options.data as Map<String, dynamic>);
    }
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

Future<void> _settle(WidgetTester tester) async {
  for (var round = 0; round < 8; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<List<int>> _pump(WidgetTester tester, _Backend backend) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(360 * 3, 1000 * 3);
  addTearDown(tester.view.reset);

  final client = DioClient(tokenGetter: () => 'a', baseUrl: 'https://x.test');
  client.dio.httpClientAdapter = backend;
  final auth = AuthProvider(api: () => AuthApi(client.dio), store: _Store());
  await tester.runAsync(auth.restore);
  final opened = <int>[];
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
        home: HomePage(onOpenTab: opened.add),
      ),
    ),
  );
  await _settle(tester);
  return opened;
}

void main() {
  group('dayPartAt uses Ulaanbaatar time', () {
    test('morning', () {
      // 21:30 UTC is 05:30 the next day there.
      expect(dayPartAt(DateTime.utc(2026, 11, 9, 21, 30)), DayPart.morning);
    });
    test('afternoon', () {
      expect(dayPartAt(DateTime.utc(2026, 11, 9, 5)), DayPart.afternoon);
    });
    test('evening and night', () {
      expect(dayPartAt(DateTime.utc(2026, 11, 9, 12)), DayPart.evening);
      expect(dayPartAt(DateTime.utc(2026, 11, 9, 18)), DayPart.evening);
    });
  });

  group('buildActivity', () {
    final report = Report(
      id: 'r',
      category: ReportCategory.noise,
      location: 'x',
      description: 'd',
      status: ReportStatus.open,
      hasPhoto: false,
      createdAt: DateTime.utc(2026, 11, 8, 3),
      voteCount: 0,
      voted: false,
    );
    PurchasesOverview purchases(String day) => PurchasesOverview(
      today: DateTime(2026, 11, 11),
      activeCount: 2,
      totalAmount: 0,
      myPaid: 0,
      myShare: 0,
      neededItems: const [],
      purchases: [
        Purchase(
          id: 'p',
          title: 't',
          amount: 1,
          buyerId: 'b',
          buyerName: 'Бат',
          purchasedOn: DateTime.parse(day),
          peopleCount: 2,
          myPaid: false,
          paidCount: 0,
        ),
      ],
    );

    test('puts the newest day first', () {
      final activity = buildActivity(
        purchases: purchases('2026-11-09'),
        reports: [report],
      );
      expect(activity.map((a) => a.kind), [
        HomeActivityKind.purchase,
        HomeActivityKind.report,
      ]);
    });

    test('a report activity carries no person', () {
      final activity = buildActivity(reports: [report]);
      expect(activity.single.personName, isNull);
    });

    test('names who finished a duty', () {
      final activity = buildActivity(
        cleaning: CleaningOverview(
          today: DateTime(2026, 11, 11),
          startDate: DateTime(2026, 11, 9),
          versions: const [
            RotationVersion(effectivePeriod: 0, memberIds: ['bat', 'me']),
          ],
          overrides: const [],
          areas: const [],
          checkedAreaIds: const [],
          donePeriods: const [0],
          members: const [CleaningMember(id: 'bat', name: 'Бат', active: true)],
          swaps: const [],
          pendingResidents: const [],
        ),
      );
      expect(activity.single.personName, 'Бат');
      expect(activity.single.day, DateTime.utc(2026, 11, 10));
    });

    test('respects the limit', () {
      expect(buildActivity(reports: [report, report], limit: 1).length, 1);
    });
  });

  testWidgets('on duty: marks every open area done', (tester) async {
    final backend = _Backend()..checked = ['a'];
    await _pump(tester, backend);

    expect(find.text('ТАНЫ ЖИЖҮҮР'), findsOneWidget);
    expect(find.text('Нийтийн талбайн цэвэрлэгээ'), findsOneWidget);
    expect(find.text('2 ажил'), findsOneWidget);

    await tester.tap(find.text('Хийсэн гэж тэмдэглэх'));
    await _settle(tester);

    expect(backend.rpcCalls, [
      {'p_area_id': 'b', 'p_checked': true},
      {'p_area_id': 'c', 'p_checked': true},
    ]);
  });

  testWidgets('a finished duty can not be marked again', (tester) async {
    final backend = _Backend()..done = [0];
    await _pump(tester, backend);

    await tester.tap(find.text('Дууссан'));
    await _settle(tester);

    expect(backend.rpcCalls, isEmpty);
  });

  testWidgets('not on duty: shows your next turn and the schedule', (
    tester,
  ) async {
    final backend = _Backend()..order = ['bat', 'me'];
    final opened = await _pump(tester, backend);

    expect(find.text('ТАНЫ ДАРААГИЙН ЖИЖҮҮР'), findsOneWidget);
    expect(find.text('11-р сарын 13, Баасан'), findsOneWidget);
    expect(find.text('Хийсэн гэж тэмдэглэх'), findsNothing);

    await tester.tap(find.text('Хуваарь харах'));
    expect(opened, [1]);
    expect(backend.rpcCalls, isEmpty);
  });

  testWidgets('no schedule yet says so', (tester) async {
    await _pump(tester, _Backend()..startDate = null);
    expect(find.text('Ээлж товлогдоогүй'), findsOneWidget);
  });

  testWidgets('quick actions open the right tabs', (tester) async {
    final opened = await _pump(tester, _Backend());

    expect(find.text('2 бараа дутуу'), findsOneWidget);
    await tester.tap(find.text('Цэвэрлэгээ'));
    await tester.tap(find.text('Зардал'));
    await tester.tap(find.text('Мэдэгдэх'));

    expect(opened, [1, 2, 3]);
  });

  testWidgets('recent activity mixes every feature', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('Болд Шингэн авлаа · ₮4,500'), findsOneWidget);
    expect(find.text('Нэргүй мэдэгдэл: Шүршүүр эвдэрсэн'), findsOneWidget);
    expect(find.text('Өчигдөр'), findsWidgets);
  });

  testWidgets('one failing section leaves the others', (tester) async {
    await _pump(tester, _Backend()..reportsFail = true);

    expect(find.text('Болд Шингэн авлаа · ₮4,500'), findsOneWidget);
    expect(find.textContaining('Нэргүй мэдэгдэл'), findsNothing);
  });

  testWidgets('the bell shows the unread count', (tester) async {
    await _pump(tester, _Backend());
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('no badge once everything is read', (tester) async {
    await _pump(tester, _Backend()..unread = 0);
    expect(
      find.byWidgetPredicate((w) => w is Badge && w.isLabelVisible),
      findsNothing,
    );
  });

  testWidgets('the bell lists notifications and marks them read', (
    tester,
  ) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Сонордуулга'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(find.text('Бат танд ₮2,250 төллөө'), findsOneWidget);
    expect(find.text('«Угаалга» мэдэгдэл: Явцад'), findsOneWidget);
    expect(find.text('Болд Цаас авлаа · таны хувь ₮500'), findsOneWidget);
    expect(
      find.text('Шинэ нэргүй мэдэгдэл: Эвдрэл / Засвар · Гал тогоо'),
      findsOneWidget,
    );
    expect(backend.markReadCalls, 1);
  });

  testWidgets('a notification opens its tab', (tester) async {
    final opened = await _pump(tester, _Backend());

    await tester.tap(find.byTooltip('Сонордуулга'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Бат танд ₮2,250 төллөө'));
    await tester.pumpAndSettle();

    expect(opened, [2]);
    expect(find.text('Сонордуулга'), findsNothing);
  });
}
