import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/dispatch_settings_model.dart';
import '../../data/models/technician_day_off_model.dart';
import '../usecases/save_dispatch_settings_uc.dart';
import '../usecases/set_technician_day_off_uc.dart';

abstract class BaseDispatchRepo {
  Future<Either<Failure, DispatchSettingsModel>> getDispatchSettings(
      NoParameters parameters);
  Future<Either<Failure, DispatchSettingsModel>> saveDispatchSettings(
      SaveDispatchSettingsParameters parameters);
  Future<Either<Failure, List<TechnicianDayOffModel>>> getTechnicianDaysOff(
      NoParameters parameters);
  Future<Either<Failure, List<TechnicianDayOffModel>>> setTechnicianDayOff(
      SetTechnicianDayOffParameters parameters);
}
