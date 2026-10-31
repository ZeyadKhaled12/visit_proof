import 'package:either_dart/either.dart';

import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../domain/repository/base_dashboard_repo.dart';
import '../datasource/dashboard_remote_data_source.dart';
import '../models/dashboard_snapshot_model.dart';

class DashboardRepo extends BaseDashboardRepo {
  final BaseDashboardRemoteDataSource baseDashboardRemoteDataSource;

  DashboardRepo(this.baseDashboardRemoteDataSource);

  @override
  Future<Either<Failure, DashboardSnapshotModel>> getDashboardSnapshot(
      NoParameters parameters) async {
    try {
      final result =
          await baseDashboardRemoteDataSource.getDashboardSnapshot(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
