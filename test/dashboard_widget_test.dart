import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
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

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('overview shows KPIs and drills into visit analysis',
      (tester) async {
    final now = DateTime.now();
    final snapshot = DashboardSnapshotModel(
      loadedAt: now,
      visits: [
        VisitDetailModel(
            id: '1',
            visitNumber: 'VIS-000001',
            status: VisitStatus.completed,
            startDate: now.subtract(const Duration(hours: 3))),
      ],
    );
    final bloc =
        DashboardBloc(GetDashboardSnapshotUc(_FakeRepo(snapshot)));

    // Tall enough that every lazily built section is laid out.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 6000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) => DashboardBody(state: state),
        ),
      ),
    ));
    // Load through the real bloc and use case, backed by the fake repo.
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
    await tester.pumpAndSettle();

    expect(find.text('Operations overview'), findsOneWidget);
    expect(find.text('Completion'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Needs attention'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Visits').first);
    await tester.pumpAndSettle();
    expect(find.text('Visits over time'), findsOneWidget);
    expect(find.text('VIS-000001 · No client'), findsOneWidget);
  });
}
