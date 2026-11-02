import 'package:either_dart/either.dart';

import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../domain/repository/base_auth_repo.dart';
import '../../domain/usecases/login_technician_uc.dart';
import '../datasource/auth_remote_data_source.dart';

class AuthRepo extends BaseAuthRepo {
  final BaseAuthRemoteDataSource baseAuthRemoteDataSource;

  AuthRepo(this.baseAuthRemoteDataSource);

  @override
  Future<Either<Failure, AppSessionModel>> loginTechnician(
      LoginTechnicianParameters parameters) async {
    try {
      return Right(await baseAuthRemoteDataSource.loginTechnician(parameters));
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, AppSessionModel>> enterAsAdmin(
      NoParameters parameters) async {
    try {
      return Right(await baseAuthRemoteDataSource.enterAsAdmin(parameters));
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> logout(NoParameters parameters) async {
    try {
      return Right(await baseAuthRemoteDataSource.logout(parameters));
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  /// Runs before the app is shown, so a failure is not toasted: the user
  /// simply lands on the role selection.
  @override
  Future<Either<Failure, AppSessionModel?>> restoreSession(
      NoParameters parameters) async {
    try {
      return Right(await baseAuthRemoteDataSource.restoreSession(parameters));
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.errorMessageModel));
    }
  }
}
