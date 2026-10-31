import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';
import '../repository/base_visit_detail_repo.dart';

// Parameters belong in the usecase layer, matching AddVisitParameters.
class GetVisitDetailParameters {
  final String visitID;
  const GetVisitDetailParameters({required this.visitID});
}

class UpdateVisitParameters {
  final VisitDetailModel original;
  final VisitDetailModel updated;
  final bool allowPriceOverride;
  final String? reason;
  final VisitHistoryActorModel? actor;
  const UpdateVisitParameters({required this.original, required this.updated,
    this.allowPriceOverride = false, this.reason, this.actor});
}

class ChangeVisitStatusParameters {
  final String visitID;
  final VisitStatus status;
  final String? reason;
  final bool exceptionalApproval;
  final VisitHistoryActorModel? actor;
  const ChangeVisitStatusParameters({required this.visitID, required this.status,
    this.reason, this.exceptionalApproval = false, this.actor});
}

class AssignVisitTechnicianParameters {
  final String visitID;
  final TechnicianModel technician;
  final String? reason;
  final VisitHistoryActorModel? actor;
  const AssignVisitTechnicianParameters({required this.visitID,
    required this.technician, this.reason, this.actor});
}

class UnassignVisitTechnicianParameters {
  final String visitID;
  final VisitStatus destination; // scheduled OR draft
  final String? reason;
  final VisitHistoryActorModel? actor;
  const UnassignVisitTechnicianParameters({required this.visitID,
    this.destination = VisitStatus.scheduled, this.reason, this.actor});
}

class AddVisitCommentParameters {
  final String visitID;
  final String comment;
  final VisitHistoryActorModel? actor;
  const AddVisitCommentParameters({required this.visitID,
    required this.comment, this.actor});
}

class GetVisitDetailUc extends BaseUseCase<VisitDetailModel, GetVisitDetailParameters> {
  final BaseVisitDetailRepo repository;
  GetVisitDetailUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(GetVisitDetailParameters p) => repository.getVisitDetail(p);
}

class UpdateVisitUc extends BaseUseCase<VisitDetailModel, UpdateVisitParameters> {
  final BaseVisitDetailRepo repository;
  UpdateVisitUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(UpdateVisitParameters p) => repository.updateVisit(p);
}

class ChangeVisitStatusUc extends BaseUseCase<VisitDetailModel, ChangeVisitStatusParameters> {
  final BaseVisitDetailRepo repository;
  ChangeVisitStatusUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(ChangeVisitStatusParameters p) => repository.changeVisitStatus(p);
}

class AssignVisitTechnicianUc extends BaseUseCase<VisitDetailModel, AssignVisitTechnicianParameters> {
  final BaseVisitDetailRepo repository;
  AssignVisitTechnicianUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(AssignVisitTechnicianParameters p) => repository.assignTechnician(p);
}

class UnassignVisitTechnicianUc extends BaseUseCase<VisitDetailModel, UnassignVisitTechnicianParameters> {
  final BaseVisitDetailRepo repository;
  UnassignVisitTechnicianUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(UnassignVisitTechnicianParameters p) => repository.unassignTechnician(p);
}

class AddVisitCommentUc extends BaseUseCase<VisitDetailModel, AddVisitCommentParameters> {
  final BaseVisitDetailRepo repository;
  AddVisitCommentUc(this.repository);
  @override
  Future<Either<Failure, VisitDetailModel>> call(AddVisitCommentParameters p) => repository.addAdminComment(p);
}
