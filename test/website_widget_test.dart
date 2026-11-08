import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/core/demo/demo_seed.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/services/services_locator.dart';
import 'package:visit_proof/features/website/presentation/screens/website_request_scr.dart';
import 'package:visit_proof/features/website/presentation/screens/website_scr.dart';
import 'package:visit_proof/features/website/presentation/screens/website_studio_scr.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    ServicesLocator().init();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalPref.sharedPreferences = await SharedPreferences.getInstance();
    await DemoSeed.run();
  });

  Future<void> show(WidgetTester tester, Widget page) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(page);
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('the landing page builds', (tester) async {
    await show(tester, const MaterialApp(home: WebsiteScr()));
    expect(find.byType(WebsiteScr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the design studio builds with the app inside', (tester) async {
    await show(tester, const MaterialApp(home: WebsiteStudioScr()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(WebsiteStudioScr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the request page builds', (tester) async {
    await show(tester, const MaterialApp(home: WebsiteRequestScr()));
    expect(find.byType(WebsiteRequestScr), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
