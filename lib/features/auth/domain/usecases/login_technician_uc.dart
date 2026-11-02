import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_auth_repo.dart';

class LoginTechnicianUc
    extends BaseUseCase<AppSessionModel, LoginTechnicianParameters> {
  final BaseAuthRepo baseAuthRepo;

  LoginTechnicianUc(this.baseAuthRepo);

  @override
  Future<Either<Failure, AppSessionModel>> call(
      LoginTechnicianParameters parameters) async {
    return await baseAuthRepo.loginTechnician(parameters);
  }
}

class LoginTechnicianParameters {
  final String email;
  final String password;
  const LoginTechnicianParameters(
      {required this.email, required this.password});
}
