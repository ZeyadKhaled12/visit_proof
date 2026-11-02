import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../usecases/login_technician_uc.dart';

abstract class BaseAuthRepo {
  Future<Either<Failure, AppSessionModel>> loginTechnician(
      LoginTechnicianParameters parameters);
  Future<Either<Failure, AppSessionModel>> enterAsAdmin(
      NoParameters parameters);
  Future<Either<Failure, void>> logout(NoParameters parameters);
  Future<Either<Failure, AppSessionModel?>> restoreSession(
      NoParameters parameters);
}
