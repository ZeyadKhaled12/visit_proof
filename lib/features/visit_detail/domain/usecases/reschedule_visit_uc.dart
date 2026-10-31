import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class RescheduleVisitUc
    extends BaseUseCase<VisitDetailModel, RescheduleVisitParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  RescheduleVisitUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      RescheduleVisitParameters parameters) async {
    return await baseVisitDetailRepo.rescheduleVisit(parameters);
  }
}

class RescheduleVisitParameters {
  final String visitID;
  final DateTime startDate;
  final String? reason;
  const RescheduleVisitParameters(
      {required this.visitID, required this.startDate, this.reason});
}
