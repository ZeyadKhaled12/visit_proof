import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/dispatch_settings_model.dart';
import '../repository/base_dispatch_repo.dart';

class GetDispatchSettingsUc
    extends BaseUseCase<DispatchSettingsModel, NoParameters> {
  final BaseDispatchRepo baseDispatchRepo;

  GetDispatchSettingsUc(this.baseDispatchRepo);

  @override
  Future<Either<Failure, DispatchSettingsModel>> call(
      NoParameters parameters) async {
    return await baseDispatchRepo.getDispatchSettings(parameters);
  }
}
