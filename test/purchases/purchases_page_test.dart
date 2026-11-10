import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/connection/auth_api.dart';
import 'package:hostel/connection/dio_client.dart';
import 'package:hostel/connection/model/auth_session.dart';
import 'package:hostel/l10n/app_localizations.dart';
import 'package:hostel/pages/purchases/purchases_page.dart';
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

Map<String, dynamic> _purchase(
  String id,
  String title,
  int amount,
  String buyer,
  String name,
  int share, {
  bool myPaid = false,
}) => {
  'id': id,
  'title': title,
  'amount': amount,
  'buyer_id': buyer,
  'buyer_name': name,
  'purchased_on': '2026-11-08',
  'my_share': share,
  'people_count': 6,
  'my_paid': myPaid,
  'paid_count': 2,
};

Map<String, dynamic> _item(
  String id,
  String name, {
  String requestedOn = '2026-11-07',
  String requestedBy = 'bat',
  String? claimedBy,
  String? claimedByName,
}) => {
  'id': id,
  'name': name,
  'requested_by': requestedBy,
  'requested_on': requestedOn,
  'claimed_by': claimedBy,
  'claimed_by_name': claimedByName,
};

class _Backend implements HttpClientAdapter {
  bool alreadyPaid = false;
  bool hasAccount = true;
  int paymentInfoCalls = 0;
  final rpcCalls = <String, dynamic>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Object body = <String, dynamic>{};
    if (options.path == '/rest/v1/profiles') {
      body = [
        {'id': 'me', 'name': 'Би', 'role': 'resident', 'status': 'active'},
      ];
    } else if (options.path.endsWith('/purchases_overview')) {
      body = {
        'today': '2026-11-09',
        'active_count': 6,
        'total_amount': 48600,
        'my_paid': 12000,
        'my_share': 8100,
        'purchases': [
          _purchase('p1', 'Аяга таваг', 12000, 'me', 'Би', 2000),
          _purchase(
            'p2',
            'Шүршигч',
            36600,
            'bat',
            'Болд',
            6100,
            myPaid: alreadyPaid,
          ),
        ],
        'needed_items': [
          _item('i1', 'Цаас'),
          _item('i2', 'Саван', requestedOn: '2026-11-09', requestedBy: 'me'),
          _item('i3', 'Уут', claimedBy: 'me', claimedByName: 'Би'),
          _item('i4', 'Шүүр', claimedBy: 'bat', claimedByName: 'Болд'),
        ],
      };
    } else if (options.path.endsWith('/purchase_payment_info')) {
      paymentInfoCalls++;
      body = hasAccount
          ? {
              'buyer_name': 'Болд',
              'bank_name': 'Хаан банк',
              'account_number': '5000123456',
              'account_holder': 'Болд Бат',
            }
          : {'buyer_name': 'Болд'};
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
  tester.view.physicalSize = const Size(360 * 3, 1100 * 3);
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
        home: PurchasesPage(),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _openHistory(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Худалдан авалтын түүх'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the split per person and your balance', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('6 хүнд тэнцүү хуваана'), findsOneWidget);
    expect(find.text('Хамтын сан'), findsOneWidget);
    expect(find.text('₮48,600'), findsOneWidget);
    expect(find.text('₮12,000'), findsWidgets);
    expect(find.text('₮8,100'), findsOneWidget);
    expect(find.text('Танд буцаж ирэх ₮3,900'), findsOneWidget);
    expect(find.textContaining('өрөө'), findsNothing);
  });

  testWidgets('lists the purchases I have not paid instead of history', (
    tester,
  ) async {
    await _pump(tester, _Backend());

    expect(find.text('Төлөөгүй худалдан авалт'), findsOneWidget);
    expect(find.text('₮6,100'), findsOneWidget, reason: 'total badge');
    expect(find.text('Шүршигч'), findsOneWidget);
    expect(find.text('Төлөх'), findsOneWidget);
    expect(find.text('Аяга таваг'), findsNothing, reason: 'I bought it');
  });

  testWidgets('says when every purchase is paid', (tester) async {
    await _pump(tester, _Backend()..alreadyPaid = true);

    expect(find.text('Бүх худалдан авалтаа төлсөн байна.'), findsOneWidget);
    expect(find.text('Шүршигч'), findsNothing);
  });

  testWidgets('the history button opens every purchase', (tester) async {
    await _pump(tester, _Backend());
    await _openHistory(tester);

    expect(find.text('Худалдан авалтын түүх'), findsOneWidget);
    expect(find.text('₮2,000 / хүн'), findsOneWidget);
    expect(find.text('Шүршигч'), findsOneWidget);
  });

  testWidgets('paid appears only on purchases someone else bought', (
    tester,
  ) async {
    await _pump(tester, _Backend());
    await _openHistory(tester);

    expect(find.text('Төлөх'), findsOneWidget);
    expect(find.text('2/5 төлсөн'), findsNWidgets(2));
  });

  Future<void> openPayment(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Төлөх'));
    await tester.pump();
    await tester.tap(find.text('Төлөх'));
    await _settle(tester);
    await tester.pumpAndSettle();
  }

  testWidgets('paid opens the buyer account, then records it', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await openPayment(tester);

    expect(backend.rpcCalls, isEmpty, reason: 'nothing saved until confirmed');
    expect(backend.paymentInfoCalls, 1);
    expect(find.text('Төлбөр төлөх'), findsOneWidget);
    expect(find.text('Хаан банк'), findsOneWidget);
    expect(find.text('Болд Бат'), findsOneWidget);
    expect(find.text('5000123456'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Dialog), matching: find.text('₮6,100')),
      findsOneWidget,
    );

    await tester.tap(find.text('Төлсөн').last);
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['set_share_paid'], {
      'p_purchase_id': 'p2',
      'p_paid': true,
    });
  });

  testWidgets('closing the popup records nothing', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await openPayment(tester);
    await tester.tap(find.text('Хаах'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls, isEmpty);
  });

  testWidgets('says so when the buyer has no account', (tester) async {
    final backend = _Backend()..hasAccount = false;
    await _pump(tester, backend);

    await openPayment(tester);

    expect(find.textContaining('оруулаагүй байна'), findsOneWidget);
    expect(find.text('Банк'), findsNothing);
  });

  testWidgets('paid can be undone', (tester) async {
    final backend = _Backend()..alreadyPaid = true;
    await _pump(tester, backend);
    await _openHistory(tester);
    expect(find.text('Төлөх'), findsNothing);

    await tester.ensureVisible(find.text('Төлсөн'));
    await tester.pump();
    await tester.tap(find.text('Төлсөн'));
    await _settle(tester);

    expect(backend.rpcCalls['set_share_paid'], {
      'p_purchase_id': 'p2',
      'p_paid': false,
    });
  });

  testWidgets('shows who bought what', (tester) async {
    await _pump(tester, _Backend());
    await _openHistory(tester);

    expect(find.text('Шүршигч'), findsOneWidget);
    expect(find.text('Болд · 11/8'), findsOneWidget);
  });

  testWidgets('describes each needed item', (tester) async {
    await _pump(tester, _Backend());

    expect(find.text('2 өдрийн өмнө хүссэн'), findsOneWidget);
    expect(find.text('Өнөөдөр хүссэн'), findsOneWidget);
    expect(find.text('Та авахаар болсон'), findsOneWidget);
    expect(find.text('Болд авахаар болсон'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('I will buy claims an item', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.text('Би авна').first);
    await _settle(tester);

    expect(backend.rpcCalls['claim_item'], {'p_item_id': 'i1'});
  });

  testWidgets('a receipt amount turns a claim into a purchase', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.text('Баримт'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1200');
    await tester.pump();
    expect(find.text('6 хүнд хуваавал нэг хүнд ₮200'), findsOneWidget);

    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['complete_item'], {
      'p_item_id': 'i3',
      'p_amount': 1200,
    });
  });

  testWidgets('a claim can be given up', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.text('Баримт'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Авахаа болих'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['unclaim_item'], {'p_item_id': 'i3'});
  });

  testWidgets('a purchase needs a name and an amount', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);

    await tester.tap(find.byTooltip('Худалдан авалт нэмэх'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Худалдан авалт нэмэх').last);
    await tester.pumpAndSettle();

    ElevatedButton save() => tester.widget(find.byType(ElevatedButton));
    expect(save().onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, ' Шампунь ');
    await tester.enterText(find.byType(TextField).last, '600');
    await tester.pump();
    expect(save().onPressed, isNotNull);

    await tester.tap(find.text('Хадгалах'));
    await tester.pumpAndSettle();
    await _settle(tester);

    expect(backend.rpcCalls['add_purchase'], {
      'p_title': 'Шампунь',
      'p_amount': 600,
    });
  });
}
