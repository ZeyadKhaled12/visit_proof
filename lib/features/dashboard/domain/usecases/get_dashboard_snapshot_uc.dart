import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/dashboard_snapshot_model.dart';
import '../repository/base_dashboard_repo.dart';

class GetDashboardSnapshotUc
    extends BaseUseCase<DashboardSnapshotModel, NoParameters> {
  final BaseDashboardRepo baseDashboardRepo;

  GetDashboardSnapshotUc(this.baseDashboardRepo);

  @override
  Future<Either<Failure, DashboardSnapshotModel>> call(
      NoParameters parameters) async {
    return await baseDashboardRepo.getDashboardSnapshot(parameters);
  }
}
