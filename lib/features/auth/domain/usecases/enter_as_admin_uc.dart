import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_auth_repo.dart';

/// The admin has no account: choosing the admin role opens the admin app.
class EnterAsAdminUc extends BaseUseCase<AppSessionModel, NoParameters> {
  final BaseAuthRepo baseAuthRepo;

  EnterAsAdminUc(this.baseAuthRepo);

  @override
  Future<Either<Failure, AppSessionModel>> call(
      NoParameters parameters) async {
    return await baseAuthRepo.enterAsAdmin(parameters);
  }
}
