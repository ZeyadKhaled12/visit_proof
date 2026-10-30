import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/visits/data/datasource/visits_remote_data_source.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/domain/repository/base_visits_repo.dart';

import '../../../../core/network/error/exception.dart';

class VisitsRepo extends BaseVisitsRepo {
  final BaseVisitsRemoteDataSource baseVisitsRemoteDataSource;

  VisitsRepo(this.baseVisitsRemoteDataSource);

  @override
  Future<Either<Failure, List<VisitDetailModel>>> getVisits(
      NoParameters parameters) async {
    try {
      final result = await baseVisitsRemoteDataSource.getVisits(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
