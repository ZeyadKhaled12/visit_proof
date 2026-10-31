import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../repository/base_visit_detail_repo.dart';

class AssignTechnicianUc
    extends BaseUseCase<VisitDetailModel, AssignTechnicianParameters> {
  final BaseVisitDetailRepo baseVisitDetailRepo;

  AssignTechnicianUc(this.baseVisitDetailRepo);

  @override
  Future<Either<Failure, VisitDetailModel>> call(
      AssignTechnicianParameters parameters) async {
    return await baseVisitDetailRepo.assignTechnician(parameters);
  }
}

class AssignTechnicianParameters {
  final String visitID;
  final TechnicianModel technician;

  /// Optional new start time, applied together with the technician.
  final DateTime? startDate;

  /// Optional note, e.g. why a dispatch warning was overridden.
  final String? reason;

  const AssignTechnicianParameters({
    required this.visitID,
    required this.technician,
    this.startDate,
    this.reason,
  });
}
