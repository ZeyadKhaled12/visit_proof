import 'package:either_dart/either.dart';
import 'package:visit_proof/core/network/error/failure.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/technicians/data/datasource/technicians_remote_data_source.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/repository/base_technicians_repo.dart';
import 'package:visit_proof/features/technicians/domain/usecases/add_tech_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/remove_technician_uc.dart';

import '../../../../core/network/error/exception.dart';

class TechniciansRepo extends BaseTechniciansRepo {
  final BaseTechniciansRemoteDataSource baseTechniciansRemoteDataSource;

  TechniciansRepo(this.baseTechniciansRemoteDataSource);

  @override
  Future<Either<Failure, void>> addTech(AddTechParameters parameters) async {
    try {
      final result = await baseTechniciansRemoteDataSource.addTech(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, TechnicianDetailModel>> getTechDetail(
      GetTechDetailParameters parameters) async {
    try {
      final result =
          await baseTechniciansRemoteDataSource.getTechDetail(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, List<TechnicianModel>>> getTechnicians(
      NoParameters parameters) async {
    try {
      final result =
          await baseTechniciansRemoteDataSource.getTechnicians(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }

  @override
  Future<Either<Failure, void>> removeTechnician(
      RemoveTechnicianParameters parameters) async {
    try {
      final result =
          await baseTechniciansRemoteDataSource.removeTechnician(parameters);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure.openFun(failure.errorMessageModel));
    }
  }
}
