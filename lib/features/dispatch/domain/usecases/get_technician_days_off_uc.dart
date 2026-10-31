import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/technician_day_off_model.dart';
import '../repository/base_dispatch_repo.dart';

class GetTechnicianDaysOffUc
    extends BaseUseCase<List<TechnicianDayOffModel>, NoParameters> {
  final BaseDispatchRepo baseDispatchRepo;

  GetTechnicianDaysOffUc(this.baseDispatchRepo);

  @override
  Future<Either<Failure, List<TechnicianDayOffModel>>> call(
      NoParameters parameters) async {
    return await baseDispatchRepo.getTechnicianDaysOff(parameters);
  }
}
