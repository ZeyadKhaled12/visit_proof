import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_auth_repo.dart';

/// Called once in main(), before the first screen is shown.
class RestoreSessionUc extends BaseUseCase<AppSessionModel?, NoParameters> {
  final BaseAuthRepo baseAuthRepo;

  RestoreSessionUc(this.baseAuthRepo);

  @override
  Future<Either<Failure, AppSessionModel?>> call(
      NoParameters parameters) async {
    return await baseAuthRepo.restoreSession(parameters);
  }
}
