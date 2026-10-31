import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../data/models/technician_day_off_model.dart';
import '../repository/base_dispatch_repo.dart';

class SetTechnicianDayOffUc extends BaseUseCase<List<TechnicianDayOffModel>,
    SetTechnicianDayOffParameters> {
  final BaseDispatchRepo baseDispatchRepo;

  SetTechnicianDayOffUc(this.baseDispatchRepo);

  @override
  Future<Either<Failure, List<TechnicianDayOffModel>>> call(
      SetTechnicianDayOffParameters parameters) async {
    return await baseDispatchRepo.setTechnicianDayOff(parameters);
  }
}

class SetTechnicianDayOffParameters {
  final String technicianID;
  final DateTime date;

  /// True marks the day off, false makes the technician available again.
  final bool isOff;

  const SetTechnicianDayOffParameters({
    required this.technicianID,
    required this.date,
    required this.isOff,
  });
}
