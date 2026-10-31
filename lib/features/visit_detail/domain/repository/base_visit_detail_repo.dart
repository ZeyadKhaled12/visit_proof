import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../usecases/visit_detail_actions_uc.dart';

abstract class BaseVisitDetailRepo {
  Future<Either<Failure, VisitDetailModel>> getVisitDetail(GetVisitDetailParameters p);
  Future<Either<Failure, VisitDetailModel>> updateVisit(UpdateVisitParameters p);
  Future<Either<Failure, VisitDetailModel>> changeVisitStatus(ChangeVisitStatusParameters p);
  Future<Either<Failure, VisitDetailModel>> assignTechnician(AssignVisitTechnicianParameters p);
  Future<Either<Failure, VisitDetailModel>> unassignTechnician(UnassignVisitTechnicianParameters p);
  Future<Either<Failure, VisitDetailModel>> addAdminComment(AddVisitCommentParameters p);
}
