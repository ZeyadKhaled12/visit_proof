import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/datasource/services_remote_data_source.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/domain/repository/base_services_repo.dart';
import 'package:visit_proof/features/services/domain/usecases/add_service_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/remove_service_uc.dart';

import '../../../../core/network/error/exception.dart';

class ServicesRepo extends BaseServicesRepo {
  final BaseServicesRemoteDataSource baseServicesRemoteDataSource;

  ServicesRepo(this.baseServicesRemoteDataSource);

  @override
  Future<Either<Failure, List<ServiceModel>>> getServices(
      NoParameters parameters) async {
    try {
      final result = await baseServicesRemoteDataSource.getServices(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, ServiceModel>> addService(
      AddServiceParameters parameters) async {
    try {
      final result = await baseServicesRemoteDataSource.addService(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, List<GModelCatg>>> getCategories(
      NoParameters parameters) async {
    try {
      final result =
          await baseServicesRemoteDataSource.getCategories(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, List<ServiceModel>>> removeService(
      RemoveServiceParameters parameters) async {
    try {
      final result =
          await baseServicesRemoteDataSource.removeService(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
