import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/features/dashboard/data/models/dashboard_snapshot_model.dart';
import 'package:visit_proof/features/dashboard/domain/repository/base_dashboard_repo.dart';
import 'package:visit_proof/features/dashboard/domain/usecases/get_dashboard_snapshot_uc.dart';
import 'package:visit_proof/features/dashboard/presentation/controller/dashboard_bloc.dart';
import 'package:visit_proof/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

class _FakeRepo extends BaseDashboardRepo {
  _FakeRepo(this.snapshot);
  final DashboardSnapshotModel snapshot;

  @override
  Future<Either<Failure, DashboardSnapshotModel>> getDashboardSnapshot(
          NoParameters parameters) async =>
      Right(snapshot);
}

/// A phone-sized dashboard, so the tour really has to scroll to its stops.
Future<void> _showDashboard(WidgetTester tester,
    {required bool reduceMotion}) async {
  final now = DateTime.now();
  final bloc = DashboardBloc(GetDashboardSnapshotUc(_FakeRepo(
    DashboardSnapshotModel(loadedAt: now, visits: [
      VisitDetailModel(
          id: '1',
          visitNumber: 'VIS-000001',
          status: VisitStatus.completed,
          startDate: now.subtract(const Duration(hours: 3))),
    ]),
  )));
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 800);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    home: BlocProvider.value(
      value: bloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) => DashboardBody(state: state),
      ),
    ),
  ));
  bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

/// The tour keeps animating, so time is advanced by hand.
Future<void> _advance(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('tour visits every section and ends with the medal',
      (tester) async {
    await _showDashboard(tester, reduceMotion: false);

    await tester.tap(find.byTooltip('How this screen works'));
    await _advance(tester);
    expect(find.text('Master your dashboard'), findsOneWidget);

    await tester.tap(find.text('Start the mission'));
    await _advance(tester);
    expect(find.text('Stop 1 of 9'), findsOneWidget);
    expect(find.text('Your command center'), findsOneWidget);

    for (final title in [
      'Choose your time range',
      'Book new work',
      'Handle problems first',
      'Your four scores',
      'Today, live',
      'See the rhythm',
      'Meet your team',
      'Jump anywhere',
    ]) {
      await tester.tap(find.text('Next stop'));
      await _advance(tester);
      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Finish'));
    await _advance(tester);
    await _advance(tester);
    expect(find.text('Mission complete!'), findsOneWidget);
    expect(find.text('+90 XP'), findsOneWidget);

    await tester.tap(find.text('Back to work'));
    await _advance(tester);
    expect(find.byType(GWidgetTour), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with reduced motion the text appears at once', (tester) async {
    await _showDashboard(tester, reduceMotion: true);

    await tester.tap(find.byTooltip('How this screen works'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start the mission'));
    await tester.pumpAndSettle();

    expect(find.text('Stop 1 of 9'), findsOneWidget);
    await tester.tap(find.text('Skip tour'));
    await tester.pumpAndSettle();
    expect(find.byType(GWidgetTour), findsNothing);
  });
}
