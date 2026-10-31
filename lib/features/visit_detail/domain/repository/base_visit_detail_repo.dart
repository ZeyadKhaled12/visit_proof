import 'package:either_dart/either.dart';

import '../../../../core/network/error/failure.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../usecases/add_visit_comment_uc.dart';
import '../usecases/assign_technician_uc.dart';
import '../usecases/change_visit_service_uc.dart';
import '../usecases/change_visit_site_uc.dart';
import '../usecases/change_visit_status_uc.dart';
import '../usecases/delete_visit_uc.dart';
import '../usecases/get_visit_detail_uc.dart';
import '../usecases/reschedule_visit_uc.dart';
import '../usecases/unassign_technician_uc.dart';
import '../usecases/update_visit_info_uc.dart';

abstract class BaseVisitDetailRepo {
  Future<Either<Failure, VisitDetailModel>> getVisitDetail(
      GetVisitDetailParameters parameters);
  Future<Either<Failure, VisitDetailModel>> changeVisitStatus(
      ChangeVisitStatusParameters parameters);
  Future<Either<Failure, VisitDetailModel>> assignTechnician(
      AssignTechnicianParameters parameters);
  Future<Either<Failure, VisitDetailModel>> unassignTechnician(
      UnassignTechnicianParameters parameters);
  Future<Either<Failure, VisitDetailModel>> rescheduleVisit(
      RescheduleVisitParameters parameters);
  Future<Either<Failure, VisitDetailModel>> updateVisitInfo(
      UpdateVisitInfoParameters parameters);
  Future<Either<Failure, VisitDetailModel>> changeVisitService(
      ChangeVisitServiceParameters parameters);
  Future<Either<Failure, VisitDetailModel>> changeVisitSite(
      ChangeVisitSiteParameters parameters);
  Future<Either<Failure, VisitDetailModel>> addVisitComment(
      AddVisitCommentParameters parameters);
  Future<Either<Failure, void>> deleteVisit(DeleteVisitParameters parameters);
}
