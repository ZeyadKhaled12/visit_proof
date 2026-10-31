import 'package:either_dart/either.dart';

import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../domain/repository/base_dispatch_repo.dart';
import '../../domain/usecases/save_dispatch_settings_uc.dart';
import '../../domain/usecases/set_technician_day_off_uc.dart';
import '../datasource/dispatch_remote_data_source.dart';
import '../models/dispatch_settings_model.dart';
import '../models/technician_day_off_model.dart';

class DispatchRepo extends BaseDispatchRepo {
  final BaseDispatchRemoteDataSource baseDispatchRemoteDataSource;

  DispatchRepo(this.baseDispatchRemoteDataSource);

  @override
  Future<Either<Failure, DispatchSettingsModel>> getDispatchSettings(
          NoParameters parameters) =>
      _guard(() => baseDispatchRemoteDataSource.getDispatchSettings(parameters));

  @override
  Future<Either<Failure, DispatchSettingsModel>> saveDispatchSettings(
          SaveDispatchSettingsParameters parameters) =>
      _guard(
          () => baseDispatchRemoteDataSource.saveDispatchSettings(parameters));

  @override
  Future<Either<Failure, List<TechnicianDayOffModel>>> getTechnicianDaysOff(
          NoParameters parameters) =>
      _guard(
          () => baseDispatchRemoteDataSource.getTechnicianDaysOff(parameters));

  @override
  Future<Either<Failure, List<TechnicianDayOffModel>>> setTechnicianDayOff(
          SetTechnicianDayOffParameters parameters) =>
      _guard(
          () => baseDispatchRemoteDataSource.setTechnicianDayOff(parameters));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
