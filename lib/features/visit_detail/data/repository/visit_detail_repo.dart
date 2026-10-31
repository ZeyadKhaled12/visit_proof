import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/exception.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/repository/base_visit_detail_repo.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';
import '../datasource/visit_detail_remote_data_source.dart';

class VisitDetailRepo extends BaseVisitDetailRepo {
  final BaseVisitDetailRemoteDataSource source;
  VisitDetailRepo(this.source);

  Future<Either<Failure, VisitDetailModel>> _wrap(Future<VisitDetailModel> Function() fn) async {
    try { return Right(await fn()); }
    on ServerException catch (e) { return Left(ServerFailure.openFun(e.errorMessageModel)); }
  }

  @override
  Future<Either<Failure, VisitDetailModel>> getVisitDetail(GetVisitDetailParameters p) => _wrap(() => source.getVisitDetail(p));
  @override
  Future<Either<Failure, VisitDetailModel>> updateVisit(UpdateVisitParameters p) => _wrap(() => source.updateVisit(p));
  @override
  Future<Either<Failure, VisitDetailModel>> changeVisitStatus(ChangeVisitStatusParameters p) => _wrap(() => source.changeVisitStatus(p));
  @override
  Future<Either<Failure, VisitDetailModel>> assignTechnician(AssignVisitTechnicianParameters p) => _wrap(() => source.assignTechnician(p));
  @override
  Future<Either<Failure, VisitDetailModel>> unassignTechnician(UnassignVisitTechnicianParameters p) => _wrap(() => source.unassignTechnician(p));
  @override
  Future<Either<Failure, VisitDetailModel>> addAdminComment(AddVisitCommentParameters p) => _wrap(() => source.addAdminComment(p));
}
