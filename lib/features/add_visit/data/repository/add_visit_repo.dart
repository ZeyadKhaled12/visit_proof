import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/features/add_visit/data/datasource/add_visit_remote_data_source.dart';
import 'package:visit_proof/features/add_visit/domain/repository/base_add_visit_repo.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

import '../../../../core/network/error/exception.dart';

class AddVisitRepo extends BaseAddVisitRepo {
  final BaseAddVisitRemoteDataSource baseAddVisitRemoteDataSource;

  AddVisitRepo(this.baseAddVisitRemoteDataSource);

  @override
  Future<Either<Failure, VisitDetailModel>> addVisit(
      AddVisitParameters parameters) async {
    try {
      final result = await baseAddVisitRemoteDataSource.addVisit(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
