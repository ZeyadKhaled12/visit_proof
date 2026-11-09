import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/core/demo/demo_seed.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/services/services_locator.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/website/presentation/screens/website_scr.dart';
import 'package:visit_proof/features/website/presentation/widgets/studio_widget_dock.dart';
import 'package:visit_proof/features/website/presentation/widgets/website_widget_offer.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    ServicesLocator().init();
  });

  /// The visitor's visit is already finished and paid.
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalPref.sharedPreferences = await SharedPreferences.getInstance();
    await DemoSeed.runScenario();
    await AuthRemoteDataSource().enterAsAdmin(const NoParameters());
    final prefs = LocalPref.sharedPreferences;
    final visits = prefs.getStringList('visits')!;
    final visit = VisitDetailModel.fromJson(jsonDecode(visits.first)).copyWith(
        id: 'visitor',
        status: VisitStatus.completed,
        paymentStatus: PaymentStatus.paid);
    await prefs.setStringList(
        'visits', [jsonEncode(visit.toJson()), ...visits]);
  });

  Future<void> settle(WidgetTester tester, {int steps = 12}) async {
    for (var i = 0; i < steps; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Finder inDock(String label) => find.descendant(
      of: find.byType(StudioWidgetDock), matching: find.text(label));

  testWidgets('one press on the side panel opens the offer', (tester) async {
    final report = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        report?.call(details);
      }
    };
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const WebsiteApp());
    await settle(tester, steps: 15);

    await tester.tap(inDock('See the invoice'));
    await settle(tester);
    await tester.tap(inDock('See the invoice'));
    await settle(tester);
    await tester.tap(inDock('Continue'));
    await settle(tester);
    expect(find.byType(WebsiteOfferCard), findsNothing);

    await tester.tap(inDock('See the offer'));
    await settle(tester);
    expect(find.byType(WebsiteOfferCard), findsOneWidget);
    FlutterError.onError = report;
  });
}
