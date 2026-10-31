import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class UnassignTechnicianUc
    extends BaseUseCase<VisitDetailModel, UnassignTechnicianParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  UnassignTechnicianUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      UnassignTechnicianParameters parameters) async {
    return await baseVisitDetailRepo.unassignTechnician(parameters);
  }
}

class UnassignTechnicianParameters {
  final String visitID;
  final String? reason;
  const UnassignTechnicianParameters({required this.visitID, this.reason});
}
