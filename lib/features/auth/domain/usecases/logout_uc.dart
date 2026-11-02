import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../repository/base_auth_repo.dart';

class LogoutUc extends BaseUseCase<void, NoParameters> {
  final BaseAuthRepo baseAuthRepo;

  LogoutUc(this.baseAuthRepo);

  @override
  Future<Either<Failure, void>> call(NoParameters parameters) async {
    return await baseAuthRepo.logout(parameters);
  }
}
