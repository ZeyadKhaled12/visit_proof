import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/dispatch_settings_model.dart';
import '../repository/base_dispatch_repo.dart';

class SaveDispatchSettingsUc
    extends BaseUseCase<DispatchSettingsModel, SaveDispatchSettingsParameters> {
  final BaseDispatchRepo baseDispatchRepo;

  SaveDispatchSettingsUc(this.baseDispatchRepo);

  @override
  Future<Either<Failure, DispatchSettingsModel>> call(
      SaveDispatchSettingsParameters parameters) async {
    return await baseDispatchRepo.saveDispatchSettings(parameters);
  }
}

class SaveDispatchSettingsParameters {
  final DispatchSettingsModel settings;
  const SaveDispatchSettingsParameters({required this.settings});
}
