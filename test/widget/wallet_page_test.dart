import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/wallet/presentation/pages/wallet_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

class _F extends ApiService {
  Map<String, dynamic> wallet = {
    'wallet': {
      'balance': 1500,
      'holding': 100,
      'totalEarned': 5000,
      'totalWithdrawn': 3500,
    },
    'transactions': [
      {
        'type': 'deposit',
        'amount': 200,
        'description': 'إيداع',
        'createdAt': '2026-01-01T10:00:00.000Z',
      },
      {
        'type': 'withdraw',
        'amount': -50,
        'description': 'سحب',
        'createdAt': '2026-01-02T10:00:00.000Z',
      },
    ],
  };
  List<Map<String, dynamic>> withdrawals = [
    {
      '_id': 'w1',
      'amount': 300,
      'status': 'pending',
      'createdAt': '2026-01-03T10:00:00.000Z',
    },
  ];
  bool failWallet = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getWallet() async {
    if (failWallet) throw Exception('network down');
    return _r({'data': wallet});
  }

  @override
  Future<Response> getMyWithdrawals() async => _r({'data': withdrawals});

  @override
  Future<Response> getMyPayments({String? direction, String? status}) async =>
      _r({'data': <Map<String, dynamic>>[]});

  @override
  Future<String?> getCurrentUserId() async => 'u1';

  @override
  Future<Response> requestWithdrawal({
    required num amount,
    String method = 'bank_transfer',
    Map<String, dynamic>? accountDetails,
  }) async {
    wallet = {
      ...wallet,
      'wallet': {
        'balance': ((wallet['wallet'] as Map)['balance'] as num) - amount,
        'holding': ((wallet['wallet'] as Map)['holding'] as num) + amount,
        'totalEarned': 5000,
        'totalWithdrawn': 3500,
      },
    };
    return _r({'success': true});
  }

  @override
  Future<Response> cancelWithdrawal(String withdrawalId) async {
    withdrawals = [];
    return _r({'success': true});
  }
}

void main() {
  late _F f;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: const WalletPage(),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('WalletPage', () {
    testWidgets('يعرض الرصيد والتحويلات وطلبات السحب', (tester) async {
      await pumpApp(tester);

      expect(find.text(r'$1500.00'), findsOneWidget);
      expect(find.text('إيداع'), findsOneWidget);
      expect(find.text('سحب'), findsOneWidget);
      expect(find.text(r'+$200.00'), findsOneWidget);
      expect(find.text(r'-$50.00'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('pending'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(find.text('pending'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('عند خطأ الجلب يعرض رسالة الخطأ وزر إعادة المحاولة', (
      tester,
    ) async {
      f.failWallet = true;
      await pumpApp(tester);

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('إعادة المحاولة بعد الفشل تعرض الرصيد', (tester) async {
      f.failWallet = true;
      await pumpApp(tester);

      f.failWallet = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(r'$1500.00'), findsOneWidget);
    });

    testWidgets('فتح حوار السحب وطلب مبلغ يحدّث الرصيد', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Withdraw Funds'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField).first, '200');
      await tester.tap(find.widgetWithText(FilledButton, 'Request'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(r'$1300.00'), findsOneWidget);
    });

    testWidgets('إلغاء سحب معلق يزيله من القائمة', (tester) async {
      await pumpApp(tester);

      await tester.scrollUntilVisible(
        find.byIcon(Icons.close),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.ensureVisible(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('pending'), findsNothing);
    });
  });
}
