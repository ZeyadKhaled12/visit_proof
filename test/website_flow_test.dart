import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/app/visit_proof_app.dart';
import 'package:visit_proof/configs/app_brand.dart';
import 'package:visit_proof/configs/app_offer.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:visit_proof/configs/app_translations.dart';
import 'package:visit_proof/core/demo/demo_mode.dart';
import 'package:visit_proof/core/demo/demo_seed.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/services/services_locator.dart';
import 'package:visit_proof/core/session/app_session.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/priority_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_menu_button.dart';
import 'package:visit_proof/features/add_visit/data/datasource/add_visit_remote_data_source.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:visit_proof/features/auth/domain/usecases/login_technician_uc.dart';
import 'package:visit_proof/features/auth/presentation/screens/tech_login_scr.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/clients/data/datasource/clients_remote_data_source.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/visit_detail/data/datasource/visit_detail_remote_data_source.dart';
import 'package:visit_proof/features/visit_detail/domain/usecases/assign_technician_uc.dart';
import 'package:visit_proof/features/visit_detail/domain/usecases/change_visit_status_uc.dart';
import 'package:visit_proof/features/visits/data/datasource/visits_remote_data_source.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/website/data/datasource/website_design_local_data_source.dart';
import 'package:visit_proof/features/website/data/models/website_request_model.dart';
import 'package:visit_proof/features/website/presentation/screens/website_request_scr.dart';
import 'package:visit_proof/features/website/presentation/screens/website_scr.dart';
import 'package:visit_proof/features/website/presentation/screens/website_studio_scr.dart';
import 'package:visit_proof/features/website/presentation/studio_scenario.dart';
import 'package:visit_proof/features/website/presentation/widgets/studio_widget_bot.dart';
import 'package:visit_proof/features/website/presentation/widgets/website_widget_offer.dart';

List<T> _read<T>(String key, T Function(Map<String, dynamic>) parse) =>
    (LocalPref.sharedPreferences.getStringList(key) ?? const [])
        .map((e) => parse(jsonDecode(e) as Map<String, dynamic>))
        .toList();

StudioStep _step() => StudioScenario.stepFor(
    StudioScenario.leadingVisit(_read('visits', VisitDetailModel.fromJson))
        ?.status,
    technician: AppSession.isTechnician);

/// The test font's letters are all as wide as they are tall, so only here
/// long labels can run out of room.
void _noRealErrors(WidgetTester tester, String during) {
  final error = tester.takeException();
  if (error != null && !'$error'.contains('overflowed')) {
    fail('$during: $error');
  }
}

/// The guide animates forever, so time is moved by hand.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The data sources simulate latency, and test time only moves when pumped.
Future<T> _done<T>(WidgetTester tester, Future<T> work) async {
  late T result;
  var finished = false;
  work.then((value) {
    result = value;
    finished = true;
  });
  for (var i = 0; i < 100 && !finished; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finished, isTrue);
  return result;
}

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

  tearDown(() async {
    await WebsiteDesignLocalDataSource.clear();
    AppSession.current.value = null;
  });

  test('the offer is one free month, then 15 dollars every 6 months', () {
    expect(AppOffer.freeMonths, 1);
    expect(AppOffer.usd(AppOffer.pricePerPeriod), r'$15');
    expect(AppOffer.periodMonths, 6);
    expect(AppOffer.monthlyEquivalent, r'$2.50');
    expect(AppOffer.monthlyPerUser, r'$0.25');
  });

  test('the sample company has only finished work', () async {
    final visits = _read('visits', VisitDetailModel.fromJson);
    expect(visits, isNotEmpty);
    expect(visits.length, lessThanOrEqualTo(30));
    expect(
        visits.every((e) =>
            e.status == VisitStatus.completed ||
            e.status == VisitStatus.cancel),
        isTrue);
    expect(_step(), StudioStep.createVisit);
  });

  test('every invoice of the sample company belongs to a visit', () {
    final visits = _read('visits', VisitDetailModel.fromJson);
    final invoices = _read('invoices', InvoiceDetailModel.fromJson);
    expect(invoices.length, visits.length);
    final ids = visits.map((e) => e.invoiceID).toSet();
    expect(invoices.every((e) => ids.contains(e.id)), isTrue);
  });

  testWidgets('the full cycle works on the scenario data, step by step',
      (tester) async {
    // The data sources show their messages through the app's navigator.
    await tester.pumpWidget(MaterialApp(
        navigatorKey: App.navigatorKey, home: const Scaffold()));
    final clients = await _done(tester,
        ClientsRemoteDataSource().getClients(const NoParameters()));
    final client = clients.first;
    final service = _read('services', ServiceModel.fromJson).first;
    final technician = _read('technicians', TechnicianDetailModel.fromJson)
        .first
        .convertToTechnicianModel();

    final created = await _done(
        tester,
        AddVisitRemoteDataSource().addVisit(AddVisitParameters(
            visitDetailModel: VisitDetailModel(
      client: VisitClientModel(
          id: client.id, name: client.name, sites: [client.site!]),
      site: client.site,
      category: service.category,
      price: service.defaultPrice,
      durationInMin: service.duration,
      serviceName: service.serviceName,
      priority: Priority.normal,
      startDate: DateTime.now().add(const Duration(hours: 1)),
      paymentStatus: PaymentStatus.unpaid,
      status: VisitStatus.scheduled,
    ))));
    expect(_step(), StudioStep.assign);

    final details = VisitDetailRemoteDataSource();
    await _done(
        tester,
        details.assignTechnician(AssignTechnicianParameters(
            visitID: created.id!, technician: technician)));
    expect(_step(), StudioStep.becomeTechnician);

    final person = _read('technicians', TechnicianDetailModel.fromJson).first;
    await _done(
        tester,
        AuthRemoteDataSource().loginTechnician(LoginTechnicianParameters(
            email: person.email!, password: person.password!)));
    expect(_step(), StudioStep.startTrip);
    final visible = await _done(
        tester, VisitsRemoteDataSource().getVisits(const NoParameters()));
    expect(visible.map((e) => e.id), contains(created.id));
    expect(
        visible.where((e) => e.status == VisitStatus.assigned).map((e) => e.id),
        [created.id]);

    Future<void> move(VisitStatus status) async {
      final visit = _read('visits', VisitDetailModel.fromJson).first;
      await _done(
          tester,
          details.changeVisitStatus(ChangeVisitStatusParameters(
              visitID: created.id!,
              status: status,
              location: DemoMode.locationFor(visit))));
    }

    await move(VisitStatus.onWay);
    expect(_step(), StudioStep.startWork);
    await move(VisitStatus.inProgress);
    expect(_step(), StudioStep.complete);
    await move(VisitStatus.completed);
    expect(_step(), StudioStep.backToAdmin);

    await _done(
        tester, AuthRemoteDataSource().enterAsAdmin(const NoParameters()));
    expect(_step(), StudioStep.finished);
  });

  test('every scenario text has an Arabic translation', () {
    final texts = <String>[
      for (final step in StudioStep.values) ...[
        step.title,
        step.hint,
        if (step.action != null) step.action!,
      ],
      ...StudioBotLines.all,
    ];
    expect(texts.where((t) => !arabicTranslations.containsKey(t)), isEmpty);
  });

  group('the design', () {
    test('comes back after closing the website, and can be cleared', () async {
      AppBrand.update(const AppBrandModel(
        colors: {AppBrandColor.primary: Color(0xFF0B63CE)},
        appName: 'Cool Air',
      ));
      AppTheme.darkMode.value = true;
      await WebsiteDesignLocalDataSource.save();

      AppBrand.reset();
      AppTheme.darkMode.value = false;
      WebsiteDesignLocalDataSource.restore();
      expect(AppBrand.value[AppBrandColor.primary], const Color(0xFF0B63CE));
      expect(AppBrand.value.appName, 'Cool Air');
      expect(AppTheme.isDark, isTrue);
      expect(WebsiteDesignLocalDataSource.restored, isTrue);

      await WebsiteDesignLocalDataSource.clear();
      expect(AppBrand.value.colors, isEmpty);
      expect(AppTheme.isDark, isFalse);
      expect(
          LocalPref.sharedPreferences
              .getString(WebsiteDesignLocalDataSource.key),
          isNull);
    });

    test('a damaged saved design is dropped', () async {
      await LocalPref.sharedPreferences
          .setString(WebsiteDesignLocalDataSource.key, '{not json');
      WebsiteDesignLocalDataSource.restore();
      expect(AppBrand.value.colors, isEmpty);
      expect(
          LocalPref.sharedPreferences
              .getString(WebsiteDesignLocalDataSource.key),
          isNull);
    });
  });

  test('the request carries the design and the changes wanted', () {
    AppBrand.update(const AppBrandModel(
        colors: {AppBrandColor.primary: Color(0xFF0B63CE)},
        appName: 'Cool Air'));
    final json = WebsiteRequestModel.fromStudio(
      name: ' Sara ',
      company: 'Cool Air',
      phone: '0500000000',
      email: '',
      requestedChanges: ' add a VAT number ',
    ).toJson();

    expect(json['name'], 'Sara');
    expect(json['requestedChanges'], 'add a VAT number');
    final design = json['design'] as Map<String, dynamic>;
    expect(design['appName'], 'Cool Air');
    expect((design['colors'] as Map)['primary'], '#0B63CE');
    expect(design['mode'], 'light');
    expect((json['offer'] as Map)['freeMonths'], 1);
  });

  group('on a phone', () {
    Future<void> show(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 780);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const WebsiteApp());
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('the website opens on the app, inside the admin dashboard',
        (tester) async {
      await show(tester);
      expect(find.byType(WebsiteStudioScr), findsOneWidget);
      expect(find.byType(WebsiteScr), findsNothing);
      expect(find.text('Hi, I am Wizpoo'), findsOneWidget);
      expect(find.text('New visit'), findsOneWidget);
      expect(find.text('For managing technicians and maintenance'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the app takes nearly the whole screen', (tester) async {
      await show(tester);
      final app = tester.getRect(find.byType(VisitProofApp));
      expect(app.height, greaterThanOrEqualTo(780 - 50));
      expect(app.width, 390);
    });

    testWidgets('Wizpoo introduces the flag, then points at the next button',
        (tester) async {
      await show(tester);
      await _settle(tester);
      await tester.tap(find.text('Let us start'));
      await _settle(tester);
      expect(find.text('Your help is always here'), findsOneWidget);

      final flag = tester.getRect(find.byTooltip('How this screen works'));
      expect(flag.height, lessThanOrEqualTo(40));
      expect(flag.top, 50, reason: 'hangs from the top of the app');

      await tester.tap(find.text('Got it'));
      await _settle(tester);
      expect(find.text('Step 1 of ${StudioStep.total}'), findsOneWidget);

      final ring = tester.getRect(find.byTooltip('Wizpoo'));
      final button = tester.getRect(find.text('New visit'));
      expect((ring.center - button.center).distance, lessThan(120),
          reason: 'Wizpoo flies next to the button to press');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the menu switches to a technician with no sign-in',
        (tester) async {
      await show(tester);
      await _settle(tester);
      await tester.tap(find.text('Let us start'));
      await _settle(tester);
      await tester.tap(find.text('Got it'));
      await _settle(tester);

      final menu = find.descendant(
          of: find.byType(VisitProofApp), matching: find.byType(GWidgetMenuButton));
      await tester.tap(menu.first);
      await _settle(tester);
      final drawerServices = find.descendant(
          of: find.byType(Drawer), matching: find.text('Services'));
      expect(drawerServices, findsOneWidget);
      expect(tester.getRect(drawerServices).bottom, lessThan(660),
          reason: 'every section shows without scrolling, even on a short phone');

      final toggle = find.text('Switch to technician');
      await tester.ensureVisible(toggle);
      await _settle(tester);
      await tester.tap(toggle);
      await _settle(tester);

      expect(AppSession.isTechnician, isTrue);
      expect(find.byType(TechLoginScr), findsNothing);
      _noRealErrors(tester, 'switch');
    });

    testWidgets('one tap changes the colors with the app still on screen',
        (tester) async {
      await show(tester);
      await tester.tap(find.byTooltip('Design your app'));
      await tester.pump(const Duration(milliseconds: 300));

      final preset = AppBrand.presets[1];
      await tester.tap(find.byTooltip(preset.name));
      await tester.pump(const Duration(milliseconds: 300));

      expect(AppBrand.value[AppBrandColor.primary], preset.primary);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('New visit'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every design tab fits', (tester) async {
      await show(tester);
      await tester.tap(find.byTooltip('Design your app'));
      await tester.pump(const Duration(milliseconds: 300));
      for (final tab in ['Colors', 'Text', 'Name and logo']) {
        await tester.tap(find.text(tab).last);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: tab);
      }
      await tester.tap(find.text('Colors'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byTooltip('Any color you want'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Main color'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('restarting the scenario keeps the design', (tester) async {
      AppBrand.update(const AppBrandModel(appName: 'Cool Air'));
      await WebsiteDesignLocalDataSource.save();
      await show(tester);

      await tester.tap(find.byTooltip('More'));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Start the scenario again'));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(PopupMenuItem<dynamic>), findsNothing);
      expect(_step(), StudioStep.createVisit);
      expect(_read('technicians', TechnicianDetailModel.fromJson), isNotEmpty);
      expect(
          LocalPref.sharedPreferences
              .getString(WebsiteDesignLocalDataSource.key),
          contains('Cool Air'));
      expect(AppSession.isAdmin, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the offer opens from the top bar', (tester) async {
      await show(tester);
      await tester.tap(find.byTooltip('The offer'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(WebsiteOfferCard), findsOneWidget);
      expect(find.text('First month free'), findsOneWidget);
      expect(find.text(r'$2.50'), findsNothing,
          reason: 'the price shares a line with its unit');
      expect(find.textContaining(r'$2.50', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sending a request shows the delivery message', (tester) async {
      await show(tester);
      await tester.tap(find.text('Request a copy'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(WebsiteRequestScr), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sara');
      await tester.enterText(fields.at(1), 'Cool Air');
      await tester.enterText(fields.at(2), '0500000000');
      await tester.enterText(fields.at(4), 'Add my VAT number');
      await tester.pump(const Duration(seconds: 1));

      final agree = find.byType(Checkbox);
      await tester.ensureVisible(agree);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(agree);
      await tester.pump(const Duration(milliseconds: 100));

      final send = find.text('Send my request');
      await tester.ensureVisible(send);
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(send);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('We have received your request'), findsOneWidget);
      expect(find.textContaining('very soon'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
