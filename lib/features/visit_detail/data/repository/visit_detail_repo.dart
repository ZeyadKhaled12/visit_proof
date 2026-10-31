import 'package:either_dart/either.dart';

import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/failure.dart';
import '../../domain/repository/base_visit_detail_repo.dart';
import '../../domain/usecases/add_visit_comment_uc.dart';
import '../../domain/usecases/assign_technician_uc.dart';
import '../../domain/usecases/change_visit_service_uc.dart';
import '../../domain/usecases/change_visit_site_uc.dart';
import '../../domain/usecases/change_visit_status_uc.dart';
import '../../domain/usecases/delete_visit_uc.dart';
import '../../domain/usecases/get_visit_detail_uc.dart';
import '../../domain/usecases/reschedule_visit_uc.dart';
import '../../domain/usecases/unassign_technician_uc.dart';
import '../../domain/usecases/update_visit_info_uc.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../datasource/visit_detail_remote_data_source.dart';

class VisitDetailRepo extends BaseVisitDetailRepo {
  final BaseVisitDetailRemoteDataSource baseVisitDetailRemoteDataSource;

  VisitDetailRepo(this.baseVisitDetailRemoteDataSource);

  @override
  Future<Either<Failure, VisitDetailModel>> getVisitDetail(
          GetVisitDetailParameters parameters) =>
      _guard(() => baseVisitDetailRemoteDataSource.getVisitDetail(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> changeVisitStatus(
          ChangeVisitStatusParameters parameters) =>
      _guard(() =>
          baseVisitDetailRemoteDataSource.changeVisitStatus(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> assignTechnician(
          AssignTechnicianParameters parameters) =>
      _guard(() =>
          baseVisitDetailRemoteDataSource.assignTechnician(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> unassignTechnician(
          UnassignTechnicianParameters parameters) =>
      _guard(() =>
          baseVisitDetailRemoteDataSource.unassignTechnician(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> rescheduleVisit(
          RescheduleVisitParameters parameters) =>
      _guard(
          () => baseVisitDetailRemoteDataSource.rescheduleVisit(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> updateVisitInfo(
          UpdateVisitInfoParameters parameters) =>
      _guard(
          () => baseVisitDetailRemoteDataSource.updateVisitInfo(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> changeVisitService(
          ChangeVisitServiceParameters parameters) =>
      _guard(() =>
          baseVisitDetailRemoteDataSource.changeVisitService(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> changeVisitSite(
          ChangeVisitSiteParameters parameters) =>
      _guard(
          () => baseVisitDetailRemoteDataSource.changeVisitSite(parameters));

  @override
  Future<Either<Failure, VisitDetailModel>> addVisitComment(
          AddVisitCommentParameters parameters) =>
      _guard(
          () => baseVisitDetailRemoteDataSource.addVisitComment(parameters));

  @override
  Future<Either<Failure, void>> deleteVisit(DeleteVisitParameters parameters) =>
      _guard(() => baseVisitDetailRemoteDataSource.deleteVisit(parameters));

  /// Same try/catch as every repo in the app, written once.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
