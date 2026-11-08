import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/core/demo/demo_seed.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/services/services_locator.dart';
import 'package:visit_proof/core/session/app_session.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/website/presentation/screens/website_scr.dart';
import 'package:visit_proof/features/website/presentation/studio_scenario.dart';
import 'package:visit_proof/features/website/presentation/widgets/website_widget_offer.dart';

StudioStep _step() => StudioScenario.stepFor(
    StudioScenario.leadingVisit(
            (LocalPref.sharedPreferences.getStringList('visits') ?? const [])
                .map((e) => VisitDetailModel.fromJson(jsonDecode(e))))
        ?.status,
    technician: AppSession.isTechnician);

/// The guide animates forever, so time is moved by hand.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Kept apart: the write queue of the data sources outlives one test's
/// simulated time, so only one test per file can create visits on screen.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    ServicesLocator().init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalPref.sharedPreferences = await SharedPreferences.getInstance();
    await DemoSeed.runScenario();
    await AuthRemoteDataSource().enterAsAdmin(const NoParameters());
  });

  Future<void> show(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 780);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const WebsiteApp());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('following Wizpoo completes the whole cycle', (tester) async {
    // The test font's letters are square, so long labels run out of room
    // only here.
    final report = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        report?.call(details);
      }
    };

    await show(tester);
    await _settle(tester);
    await tester.tap(find.text('Let us start'));
    await _settle(tester);
    await tester.tap(find.text('Got it'));
    await _settle(tester);

    Future<void> press(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await _settle(tester);
      await tester.tap(target);
      await _settle(tester);
      final error = tester.takeException();
      if (error != null) fail('$label: $error');
    }

    await press('New visit');
    await press('Schedule');
    expect(find.text('Step 2 of ${StudioStep.total}'), findsOneWidget);

    await press('Open dispatch');
    await press('Queue (1)');
    await press('Suggest technician');
    await press('Best match');
    await press('Assign');
    expect(_step(), StudioStep.becomeTechnician);

    await press('Enter as technician');
    expect(AppSession.isTechnician, isTrue);

    await press('Next: Start trip');
    await press('Start trip');
    await press('I agree to share my live location with the admin on every visit action.');
    await press('Confirm');
    expect(_step(), StudioStep.startWork);

    await press('Start work');
    expect(find.byType(CheckboxListTile), findsNothing);
    await press('Confirm');
    expect(_step(), StudioStep.complete);

    await press('Complete visit');
    expect(find.byType(CheckboxListTile), findsNothing);
    await press('Confirm');
    expect(_step(), StudioStep.collect);

    await press('Collect payment');
    await press('Send to admin');
    await _settle(tester);
    expect(find.text('Back to admin'), findsOneWidget);

    await press('Back to admin');
    await _settle(tester);
    // The office sees the proof and the invoice before any offer.
    expect(find.byType(WebsiteOfferCard), findsNothing);
    expect(find.textContaining('from site'), findsWidgets);

    await press('See the invoice');
    expect(find.byType(WebsiteOfferCard), findsNothing);
    expect(find.text('Remaining balance'), findsOneWidget);
    expect(find.textContaining('awaiting admin confirmation'), findsOneWidget);

    await press('See the offer');
    await _settle(tester);
    expect(find.byType(WebsiteOfferCard), findsOneWidget);
    FlutterError.onError = report;
  });
}
