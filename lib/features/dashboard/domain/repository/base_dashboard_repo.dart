import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/dashboard_snapshot_model.dart';

abstract class BaseDashboardRepo {
  Future<Either<Failure, DashboardSnapshotModel>> getDashboardSnapshot(
      NoParameters parameters);
}
